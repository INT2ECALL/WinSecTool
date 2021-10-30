<# @aProjectFilename - can be relative path to solution file or absolute #>
<# @aMetadata        - specifies which value will be extracted from the MSBuild task item in the build result #>
<# @aCheckCopyLocal  - specifies to check "CopyLocal" flag for each MSBuild task item in the build result #>
param([string] $aMsBuildDllPath, [string] $aSolutionFile, [string] $aCheckCopyLocal, [string] $aWixExpected)

[string] $kProjectsRegEx = 'Project\("(?<Type>{[A-F0-9-]+})"\) = "(?<Name>.*?)", "(?<Path>.*?)", "(?<Guid>{[A-F0-9-]+})'

[string] $kSolutionNode           = "Solution"
[string] $kProjectsNode           = "Projects"
[string] $kProjectNode            = "Project"
[string] $kProjectConfigsNode     = "ProjectConfigurations"
[string] $kProjecConfigNode       = "ProjectConfiguration"
[string] $kSolConfigNode          = "SolutionConfiguration"
[string] $kConfigurationsNode     = "Configurations"
[string] $kConfigurationNode      = "Configuration"
[string] $kSolutionNode           = "Solution"
[string] $kFilePathNode           = "FilePath"
[string] $kPrimaryOutputsNode     = "PrimaryOutputs"
[string] $kReferencesOutputsNode  = "ReferencesOutputs"
[string] $kSourceFilesNode        = "SourceFiles"

[string] $kFileAtt            = "File"
[string] $kNameAtt            = "Name"
[string] $kTypeAtt            = "Type"
[string] $kPathAtt            = "Path"
[string] $kGuidAtt            = "Guid"
[string] $kProjectNameAtt     = "ProjectName"
[string] $kDefineConstantsAtt = "DefineConstants"
[string] $kKindAtt            = "Kind"
[string] $kPlatformAtt        = "Platform"


[string] $kGlobalSectionSolutionConfigs = "GlobalSection(SolutionConfigurationPlatforms) = preSolution"
[string] $kGlobalSectionProjectConfigs  = "GlobalSection(ProjectConfigurationPlatforms) = postSolution"
[string] $kGlobalSectionEnd             = "EndGlobalSection"
[string] $kActiveCfg                    = "ActiveCfg"

[string] $kResolveAssemblyReferencesTarget      = "ResolveAssemblyReferences"
[string] $kResolveProjectReferencesTarget       = "ResolveProjectReferences"
[string] $kGetCopyToOutputDirectoryItemsTarget  = "GetCopyToOutputDirectoryItems"
[string] $kBuildProjectOutputGroupTarget        = "BuiltProjectOutputGroup"
[string] $kGetTargetPathTarget                  = "GetTargetPath"

[string] $kFinalOutputPathMetadata = "FinalOutputPath"
[string] $kTargetPathMetadata      = "TargetPath"
[string] $kIdentityMetadata        = "Identity"
[string] $kProjectMetadata         = "Project"
[string] $kCopyLocalMedatada       = "CopyLocal"
[string] $kDefineConstantsMedatada = "DefineConstants"
[string] $kOutputPathMedatada      = "OutputPath"
[string] $kOutputFileNameMedatada  = "OutputFileName"
[string] $kDefineConstantsMedatada = "DefineConstants"

[string] $kLibFileExt     = ".lib"
[string] $kWixProjFileExt = ".wixproj"
[string] $kWixKindGuid    = "{930C7802-8A8C-48F9-8165-68863BCCD9DD}"
[string] $kAiProjectKind  = "{840C416C-B8F3-42BC-B0DD-F6BB14C9F8CB}"
[string] $kVdProjectKind  = "{54435603-DBB4-11D2-8724-00A0C9A8B90C}"
[string] $MSBuildPathDetectorDll = "../../third-party/msbuild/MSBuildPathDetector.dll"

[System.Collections.Generic.List[string]] $kIgnoreProjectTypes = New-Object System.Collections.Generic.List[string]
$kIgnoreProjectTypes.Add($kAiProjectKind)
$kIgnoreProjectTypes.Add($kVdProjectKind)

Function ParseSolutionFile([System.Xml.XmlDocument] $aSolDoc, [string] $aSolutionFilePath)
{
  [System.IO.StreamReader] $fileStream = New-Object System.IO.StreamReader $aSolutionFilePath
  
  <# <Solution> #>
  [System.Xml.XmlElement] $rootNode = $aSolDoc.CreateElement($kSolutionNode)
  $child = $aSolDoc.AppendChild($rootNode)
  $rootNode.SetAttribute($kFileAtt, $aSolutionFilePath)

  <# <Projects> #>
  [System.Xml.XmlElement] $projectsNode = $aSolDoc.CreateElement($kProjectsNode)
  $child = $rootNode.AppendChild($projectsNode)

  # Handle wix project
  if([System.IO.Path]::GetExtension($aSolutionFilePath) -eq $kWixProjFileExt)
  {
    [System.Xml.XmlElement] $configNode = $aSolDoc.CreateElement($kConfigurationNode)
    $child = $rootNode.AppendChild($configNode)

    [System.Xml.XmlElement] $projectConfigNode = $aSolDoc.CreateElement($kProjecConfigNode)
    $projectConfigNode.SetAttribute($kKindAtt, $kWixKindGuid)
    $projectConfigNode.SetAttribute($kPathAtt, $aSolutionFilePath)
    $projectConfigNode.SetAttribute($kNameAtt, "")
    $projectConfigNode.SetAttribute($kPlatformAtt, "")
    $child = $configNode.AppendChild($projectConfigNode)
    
    return;
  }

  while (!$fileStream.EndOfStream)
  {
    [string] $line = $fileStream.ReadLine()
    
    if ($line.StartsWith("Project("))
    {
      LoadProject $aSolDoc $projectsNode $line
    }
    
    if ($line.Contains($kGlobalSectionSolutionConfigs))
    {
      LoadSolutionConfigs $aSolDoc $fileStream
    }

    if ($line.Contains($kGlobalSectionProjectConfigs))
    {
      LoadProjectConfigs $aSolDoc $fileStream
    }
  }
  
  $fileStream.Close();
  return $solDoc;
}


Function LoadProject([System.Xml.XmlDocument] $aSolDoc, [System.Xml.XmlElement] $aProjectsNode, [string] $aProjectLine)
{
  [string] $kType = "Type"
  [string] $kName = "Name"
  [string] $kPath = "Path"
  [string] $kGuid = "Guid"
  
  [System.Text.RegularExpressions.Regex] $regex = New-Object System.Text.RegularExpressions.Regex $kProjectsRegEx
  [System.Text.RegularExpressions.Match] $match = $regex.Match($aProjectLine)
   
  if (!$match)
  {
    return
  }

  if ($match.Groups.Count -ne 5)
  {
    return
  }

  $type = $match.Groups[$kType].Value
  $name = $match.Groups[$kName].Value
  $path = $match.Groups[$kPath].Value
  $guid = $match.Groups[$kGuid].Value

  if ($name -eq $path)
  {
    return
  }

  [System.Xml.XmlElement] $projectNode = $aSolDoc.CreateElement($kProjectNode)
  $projectNode.SetAttribute($kTypeAtt, $type)
  $projectNode.SetAttribute($kNameAtt, $name)
  $projectNode.SetAttribute($kPathAtt, $path)
  $projectNode.SetAttribute($kGuidAtt, $guid)
  $child = $aProjectsNode.AppendChild($projectNode)
}


Function LoadSolutionConfigs([System.Xml.XmlDocument] $aSolDoc, [System.IO.StreamReader] $aFileStream)
{
  [string] $line = "";
  while(($line.Trim() -ne $kGlobalSectionEnd) -and (!$aFileStream.EndOfStream))
  {
    $line = $aFileStream.ReadLine().Trim()
    [System.Xml.XmlElement] $configNode = $aSolDoc.CreateElement($kConfigurationNode)
    if(ParseSolutionConfiguration $line $configNode)
    {
      $child = $rootNode.AppendChild($configNode)
    }
  }
}


Function LoadProjectConfigs([System.Xml.XmlDocument] $aSolDoc, [System.IO.StreamReader] $aFileStream)
{
  [string] $line = "";
  while (($line.Trim() -ne $kGlobalSectionEnd) -and (!$aFileStream.EndOfStream))
  {
    $line = $aFileStream.ReadLine().Trim()

    <# Skip configurations different from "ActiveCfg" #>
    if (!$line.Contains($kActiveCfg))
    {
      continue
    }

    <# Tokenize project Guid and solution/project configurations #>
    [string[]] $guidConfigsTokens = $line.Split('.')
    if($guidConfigsTokens.Length -ne 3)
    {
      continue
    }

    [string] $guid = $guidConfigsTokens[0].Trim()
    [string] $configsToken = $guidConfigsTokens[1] + $guidConfigsTokens[2]
    [string] $configsToken = $configsToken.Replace($kActiveCfg, "")
    [string] $guid = $guidConfigsTokens[0].Trim()

    [System.Xml.XmlElement] $solutionConfigNode = $aSolDoc.CreateElement($kSolConfigNode)
    if(!(ParseSolutionConfiguration $configsToken $solutionConfigNode))
    {
      continue;
    }

    $solutionConfigNode.SetAttribute($kGuidAtt, $guid)

    <# Get solution configuration for found configuration #>
    $solutionConfigNode = (GetSolConfigNode $aSolDoc $solutionConfigNode.GetAttribute($kNameAtt) $solutionConfigNode.GetAttribute($kPlatformAtt))
    if(!$solutionConfigNode)
    {
        continue
    }


    [System.Xml.XmlElement] $projectConfigNode = $aSolDoc.CreateElement($kProjecConfigNode)
    if(!(ParseProjectConfiguration $configsToken $projectConfigNode))
    {
      continue
    }

    [System.Xml.XmlElement] $projectNode = (GetProjectgNodeByGuid $aSolDoc $guid)
    if(!$projectNode)
    {
        continue
    }

    $projectConfigNode.SetAttribute($kProjectNameAtt, $projectNode.GetAttribute($kNameAtt))
    $projectConfigNode.SetAttribute($kKindAtt, $projectNode.GetAttribute($kTypeAtt))
    $projectConfigNode.SetAttribute($kPathAtt, $projectNode.GetAttribute($kPathAtt))
    $child = $solutionConfigNode.AppendChild($projectConfigNode)
  }
}



Function ParseSolutionConfiguration([string] $aConfigLine, [System.Xml.XmlElement] $aConfigNode)
{
  [string[]] $configPlatform = TokenizeConfigPlatform($aConfigLine, 0)
  if ($configPlatform.Count -ne 2)
  {
    return $false
  }

  $aConfigNode.SetAttribute($kNameAtt, $configPlatform[0].Trim())
  [string] $platform = if($configPlatform.Length -gt 1) {$configPlatform[1].Trim()} else {""}
  $aConfigNode.SetAttribute($kPlatformAtt, $platform)

  return $true
}

Function GetSolConfigNode([System.Xml.XmlDocument] $aSolDoc, [string] $aConfName, [string] $aPlatform)
{
    return $aSolDoc.SelectSingleNode([string]::Format( "Solution/Configuration[@Name='{0}' and @Platform='{1}']", $aConfName, $aPlatform))
}

Function GetProjectgNodeByGuid([System.Xml.XmlDocument] $aSolDoc, [string] $aProjectGuid)
{
    return $aSolDoc.SelectSingleNode([string]::Format("Solution/Projects/Project[@Guid='{0}']", $aProjectGuid))
}

Function ParseProjectConfiguration([string] $aConfigChunk, [System.Xml.XmlElement] $aConfigNode)
{
  [string[]] $configPlatform = TokenizeConfigPlatform($aConfigChunk, 1)
  if ($configPlatform.Length -eq 0)
  {
    return $false;
  }

  $aConfigNode.SetAttribute($kNameAtt, $configPlatform[0].Trim())
  [string] $platform = if($configPlatform.Length -gt 1) {$configPlatform[1].Trim()} else {""}
  
  $aConfigNode.SetAttribute($kPlatformAtt, $platform)

  return $true;
}

Function TokenizeConfigPlatform([string] $aChunk, [int] $aConfigPos)
{
  [string[]] $tokenizedConfigLine = $aChunk.Split('=')

  if ($tokenizedConfigLine.Count -ne 2)
  {
    return @()
  }

  return $tokenizedConfigLine[$aConfigPos].Split('|')
}

Function LoadSolutionConfigsData([System.Xml.XmlDocument] $aSolutionDocument,                                 
                                 [bool] $aCheckCopyLocal,
                                 [bool] $aWixExpected)
{
  [System.Xml.XmlElement] $rootNode = $aSolutionDocument.SelectSingleNode($kSolutionNode)
  if(!$rootNode)
  {
    return
  }

  [string] $solFile = $rootNode.GetAttribute($kFileAtt)
  [System.Xml.XmlNodeList] $solConfigNodes = $aSolutionDocument.SelectNodes("Solution/Configuration")
  foreach($configNode in $solConfigNodes)
  {
    [System.Xml.XmlNodeList] $projConfigNodes = $configNode.SelectNodes($kProjecConfigNode)
    foreach($projConfigNode in $projConfigNodes)
    {
      [string] $projFile = $projConfigNode.GetAttribute($kPathAtt)
      [string] $config = $projConfigNode.GetAttribute($kNameAtt)
      [string] $platform = $projConfigNode.GetAttribute($kPlatformAtt)
      [string] $kind = $projConfigNode.GetAttribute($kKindAtt)

      if($kVdProjectKind.Contains($kind))
      {
        continue
      }

      [System.Collections.Generic.List[string]] $targets = @($kBuildProjectOutputGroupTarget)
      if(!$aWixExpected)
      {
        $targets.Add($kGetCopyToOutputDirectoryItemsTarget)
        $targets.Add($kResolveAssemblyReferencesTarget)
        $targets.Add($kResolveProjectReferencesTarget)
      }

      $buildResult = (RunMSBuild $projFile $targets $config $platform $solFile)

      # Set primary output
      [System.Collections.Generic.List[string]] $primaryOutput = (LoadPrimaryOutput $buildResult)

      if($primaryOutput.Count -ne 0)
      {
        [System.Xml.XmlElement] $primaryOutputNode = $aSolutionDocument.CreateElement($kPrimaryOutputsNode)
        $child = $projConfigNode.AppendChild($primaryOutputNode)
        foreach($primaryOutputFile in $primaryOutput)
        {
          [System.Xml.XmlElement] $pathNode = $aSolutionDocument.CreateElement($kFilePathNode)
          $pathNode.InnerText = $primaryOutputFile
          $child = $primaryOutputNode.AppendChild($pathNode)
        }
      }

      # Set references output
      [System.Collections.Generic.List[string]] $referencesOutput = (LoadReferencesOutput $buildResult $aCheckCopyLocal)
      if($referencesOutput.Count -ne 0)
      {
        [System.Xml.XmlElement] $referencesOutputNode = $aSolutionDocument.CreateElement($kReferencesOutputsNode)
        $child = $projConfigNode.AppendChild($referencesOutputNode)
        foreach($referencesOutputFile in $referencesOutput)
        {
          [System.Xml.XmlElement] $pathNode = $aSolutionDocument.CreateElement($kFilePathNode)
          $pathNode.InnerText = $referencesOutputFile
          $child = $referencesOutputNode.AppendChild($pathNode)
        }
      }

      #Set project source files and defines for wix projects

      if($aWixExpected)
      {
        [System.Uri] $solutionUri = New-Object System.Uri($solFile)
        $prjAbsolutePath = New-Object System.Uri($solutionUri, $projFile)
        
        <# solution dir path must end with "/" for C++ projects which are using $(SolutionDir) property #>
        [string] $solutionDir = [System.IO.Path]::GetDirectoryName($solFile) + "\\"
        
        $globalProperties = New-Object 'system.collections.generic.dictionary[[string],[string]]'
        $globalProperties.Add("SkipInvalidConfigurations", "true")
        $globalProperties.Add("DesignTimeBuild", "true")

        if($platform -ne "")
        {
          $globalProperties.Add("Platform", $platform)
        }

        if($config -ne "")
        {
          $globalProperties.Add("Configuration", $config)
        }
        $globalProperties.Add("SolutionDir", $solutionDir)
        
        $projectCollection = New-Object Microsoft.Build.Evaluation.ProjectCollection($globalProperties)
        $project = $projectCollection.LoadProject($prjAbsolutePath.LocalPath)

        $projConfigNode.SetAttribute($kDefineConstantsAtt, $project.GetProperty($kDefineConstantsMedatada).EvaluatedValue)

        if($project.Items.Count -ne 0)
        {
          [System.Xml.XmlElement] $sourceFilesNode = $aSolutionDocument.CreateElement($kSourceFilesNode)
          $child = $projConfigNode.AppendChild($sourceFilesNode)

          foreach ($pi in $project.Items)
          {
            [System.Xml.XmlElement] $pathNode = $aSolutionDocument.CreateElement($kFilePathNode)
            if($pi.ItemType -eq "Compile")
            {
              $file = $pi.EvaluatedInclude
              if(!([System.IO.Path]::IsPathRooted($file)))
              {
                [System.Uri] $projUri = New-Object System.Uri($prjAbsolutePath.LocalPath)
                $file = (New-Object System.Uri($projUri, $file)).LocalPath
              }

              $pathNode.InnerText = $file
              $child = $sourceFilesNode.AppendChild($pathNode)
            }
          }
        }
      }
    }
  }
}



Function LoadPrimaryOutput($buildResult)
{
  [System.Collections.Generic.List[string]] $outputs = New-Object System.Collections.Generic.List[string]
  foreach ($item in $buildResult.ResultsByTarget[$kBuildProjectOutputGroupTarget].Items)
  {
    $filePath = $item.GetMetadata($kFinalOutputPathMetadata)
    if($filePath -eq "")
    {
      $filePath = $item.ItemSpec
    }

    $outputs.Add($filePath)
  }

  if($outputs.Count -eq 0)
  {
    return $outputs
  }

  [string] $outputDir = [System.IO.Path]::GetDirectoryName($outputs[0])
  foreach ($item in $buildResult.ResultsByTarget[$kGetCopyToOutputDirectoryItemsTarget].Items)
  {
    $outputs.Add([System.IO.Path]::Combine($outputDir, $item.GetMetadata($kTargetPathMetadata)))
  }

  return $outputs
}

Function LoadReferencesOutput($buildResult, [bool] $aCheckCopyLocal)
{
  [System.Collections.Generic.List[string]] $outputs = New-Object System.Collections.Generic.List[string]
  
  foreach ($item in $buildResult.ResultsByTarget[$kResolveAssemblyReferencesTarget].Items)
  {
    if($aCheckCopyLocal -and ($item.GetMetadata($kCopyLocalMedatada).ToLower() -ne "true"))
    {
      continue
    }

    # Skip .lib files
    [string] $referenceFile = $item.GetMetadata($kIdentityMetadata)
    if([System.IO.Path]::GetExtension($referenceFile) -ne $kLibFileExt)
    {
      $outputs.Add($referenceFile)
    }
  }
  
  foreach ($item in $buildResult.ResultsByTarget[$kResolveProjectReferencesTarget].Items)
  {
  # Skip .lib files
    [string] $referenceFile = $item.GetMetadata($kIdentityMetadata)
    if([System.IO.Path]::GetExtension($referenceFile) -ne $kLibFileExt)
    {
      $outputs.Add($referenceFile)
    }
  }

  return $outputs;
}


<# aSolutionFile - full path to solutionfile #>
<# aTarget       - build target name #>
Function RunMSBuild([string] $aProjectFilename, [string[]] $aTargets, [string] $aConfiguration, [string] $aPlatform, [string] $aSolutionFile) 
{ 
  $buildManager = New-Object Microsoft.Build.Execution.BuildManager
  
  $solutionUri = New-Object System.Uri($aSolutionFile)
  $prjAbsolutePath = (New-Object System.Uri($solutionUri, $aProjectFilename)).LocalPath
  
  <# solution dir path must end with "/" for C++ projects which are using $(SolutionDir) property #>
  $solutionDir = [System.IO.Path]::GetDirectoryName($aSolutionFile) + "\"
  $globalProperties = New-Object 'system.collections.generic.dictionary[[string],[string]]'
  $globalProperties.Add("SkipInvalidConfigurations", "true")
  $globalProperties.Add("DesignTimeBuild", "true")

  if($aPlatform -ne "")
  {
    $globalProperties.Add("Platform", $aPlatform.Replace(" ", ""))
  }

  if($aConfiguration -ne "")
  {
    $globalProperties.Add("Configuration", $aConfiguration)
  }
  
  if($aSolutionFile -ne $aProjectFilename)
  {
    $globalProperties.Add("SolutionDir", $solutionDir)
  }

  $projectCollection = New-Object Microsoft.Build.Evaluation.ProjectCollection $globalProperties
  $projectCollection.LoadProject($prjAbsolutePath)

  $buildParameters = New-Object Microsoft.Build.Execution.BuildParameters $projectCollection
  $buildManager.BeginBuild($buildParameters)
  
  $requestData = New-Object Microsoft.Build.Execution.BuildRequestData -ArgumentList @($prjAbsolutePath, $globalProperties, [nullstring]::Value, $aTargets, $null)
  $submission = $buildManager.PendBuildRequest($requestData)
  return $submission.Execute()
}

if(($PSVersionTable.PSVersion.Major -eq 2) -or ($PSVersionTable.PSVersion.Major -eq 1))
{
  Write-Host "PowerShell 3.0 not detected. The import operation failed. Please install PowerShell 3.0 or higher version and retry."
  exit 11111
}

Try
{
  $msbuildAssemblyName = [System.Reflection.AssemblyName]::GetAssemblyName($aMsBuildDllPath)
  [void][System.Reflection.Assembly]::Load($msbuildAssemblyName)
}
Catch
{
  Write-Host "Unable to load MSBuild assemblies"
  exit 11111
}

[System.Xml.XmlDocument] $aSolDoc = New-Object System.Xml.XmlDocument

Try
{
  ParseSolutionFile $aSolDoc $aSolutionFile
}
Catch
{
  Write-Host "$ Unable to parse solution file: $($aSolutionFile)"
  exit 11111
}

[bool] $checkCopyLocal = ($aCheckCopyLocal.ToLower() -eq "true")
[bool] $wixExpected = ($aWixExpected.ToLower() -eq "true")

Try
{
  LoadSolutionConfigsData $aSolDoc $checkCopyLocal $wixExpected
}
Catch
{
  $Error[0].Exception.Message
  exit 11111
}

Write-Host $aSolDoc.OuterXml
