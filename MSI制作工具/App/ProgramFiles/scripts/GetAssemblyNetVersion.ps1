<#
 # Copyright 2002 - 2014 Caphyon LTD. All rights reserved.
 #
 # mailto: eng@caphyon.com
 # http://www.caphyon.com
 #
 #>


<#
 # This cmdlet retrieves the .Net Framework version an assembly was built against.
 # VERY IMPORTANT: It works only for assemblies built against .Net 4 and higher
 #>

function Get-TargetDotNetVersion
{
  #Named parameters list for the function
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory=$True)]
    [string]$assemblyPath
  )

  $assembly = [System.Reflection.Assembly]::ReflectionOnlyLoadFrom($assemblyPath)
  $customAttributes = $assembly.GetCustomAttributesData()
  
  # Check for the TargetFrameworkAttribute attribute. It is available only for .Net 4.0 and higher
  $targetFramework = $customAttributes | Where-Object { $_.AttributeType.Name -eq 'TargetFrameworkAttribute' } | select -First 1
  if ( $targetFramework -eq $null )
  {
    return $null 
  }

  # Get the FrameworkDisplayName property 
  $frameworkDisplayName = $targetFramework.NamedArguments | Where-Object { $_.MemberName -eq 'FrameworkDisplayName' } | select -First 1
  $frameworkVersion = $frameworkDisplayName.TypedValue.Value
  
  # Extract the version from the FrameworkDisplayName. 
  $versionMatched = $frameworkVersion -match '\d+(\.\d+)+'
  if ( $versionMatched )
  {
    return $matches[0]
  }
  return $null
}




