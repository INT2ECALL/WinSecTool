<#
 # Copyright 2002 - 2014 Caphyon LTD. All rights reserved.
 #
 # mailto: eng@caphyon.com
 # http://www.caphyon.com
 #
 #>

<# 
 # This script file contains helper functions that generate the XML digest
 # that is udes to create SMS_Application objects for SCCM 2012
 # 
 # VERY IMPORTANT: The script is dependent of the existence of the SCCM Admin Console
 # on the computer were it is ran.
 #
 #>


function Import-SCCMAssemblies($SCCMAdminConsolePath)
{
  $path = "$SCCMAdminConsolePath\Microsoft.ConfigurationManagement.ApplicationManagement.dll"
  if (Test-Path $path) 
  { 
    $t = [System.Reflection.Assembly]::LoadFrom($path)
  }
   
  $path = "$SCCMAdminConsolePath\Microsoft.ConfigurationManagement.ApplicationManagement.AppVInstaller.dll"
  if (Test-Path $path) 
  { 
    $t = [System.Reflection.Assembly]::LoadFrom($path)
  }
   
  $path = "$SCCMAdminConsolePath\Microsoft.ConfigurationManagement.ApplicationManagement.AppV5XInstaller.dll"
  if (Test-Path $path) 
  { 
    $t = [System.Reflection.Assembly]::LoadFrom($path)
  }

  $path = "$SCCMAdminConsolePath\Microsoft.ConfigurationManagement.ZipArchive.dll"
  if (Test-Path $path) 
  { 
    $t = [System.Reflection.Assembly]::LoadFrom($path)
  }

  $path = "$SCCMAdminConsolePath\Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll"
  if (Test-Path $path) 
  { 
    $t = [System.Reflection.Assembly]::LoadFrom($path)
  }

  $path = "$SCCMAdminConsolePath\Microsoft.ConfigurationManagement.ApplicationManagement.Win8Installer.dll"
  if (Test-Path $path) 
  { 
    $t = [System.Reflection.Assembly]::LoadFrom($path)
  }
}


function New-SmsApplication
{
  #Named parameters list for the function
  [CmdletBinding()]
  Param
  ( 
    [Parameter(Mandatory=$true)]
    [System.String]$appScopeId,
    
    [Parameter(Mandatory=$true)]
    [System.String]$appTitle,
    
    [System.String]$appDescription,
    
    [System.String]$appVersion,
    
    [System.String]$appPublisher,

    [System.String]$appLanguage
  )

  #Compute Authoring ScopeID. This should be provided by the SMS site
  $scopeid = $appScopeId   
  if ([System.String]::IsNullOrEmpty($scopeid)) 
  {
    $scopeid = "ScopeId_" + [System.Guid]::NewGuid().ToString() 
  }

  #Set the
  [Microsoft.ConfigurationManagement.ApplicationManagement.NamedObject]::DefaultScope = $scopeid

  #Create an unique id for the application and the deployment type
  $newApplicationID    = "Application_" + [System.Guid]::NewGuid().ToString()

  #Create SCCM 2012 object id for application and deployment type
  $newApplicationID = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.ObjectID($scopeid, $newApplicationID)

   #Create all the objects necessary for the creation of the application
  $newApplication = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.Application($newApplicationID)
  $newDisplayInfo = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.AppDisplayInfo

  #Setting Display Info
  $newDisplayInfo.Title       = $appTitle 
  $newDisplayInfo.Language    = $appLanguage 
  $newDisplayInfo.Description = $appDescription
  $newDisplayInfo.Publisher   = $appPublisher 
  $newDisplayInfo.Version     = $appVersion

  #Add display info to application
  $newApplication.DisplayInfo.Add($newDisplayInfo)

  #Setting default Language must be set and display info must exists
  $newApplication.DisplayInfo.DefaultLanguage = $appLanguage 
  $newApplication.Title                       = $appTitle 
  $newApplication.Version                     = 1
  $newApplication.Publisher                   = $appPublisher 
  $newApplication.Description                 = $appDescription
  $newApplication.SoftwareVersion             = $appVersion
  $newApplication.CustomId                    = $appTitle

  return $newApplication
}

<############################################################################>
#Compute Retrieve XML digest for a Appv 4.x package 
function Get-SmsAppV4xApplicationXml
{
  #Named parameters list for the function
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory=$true)]
    [System.String]$sccmAdminConsolePath,
    
    [Parameter(Mandatory=$true)]
    [System.String]$packagePath,
    
    [Parameter(Mandatory=$true)]
    [System.String]$appScopeId,
    
    [Parameter(Mandatory=$true)]
    [System.String]$appTitle,
    
    [System.String]$appDescription,
    
    [System.String]$appVersion,
    
    [System.String]$appPublisher,

    [System.String]$appLanguage
  )

  #Load the referenced SCCM assemblies
  Import-SCCMAssemblies $sccmAdminConsolePath 
  
  $newApplication = New-SmsApplication $appScopeId $appTitle $appDescription $appVersion $appPublisher $appLanguage

  #Deployment Type AppV
  $newAppV4xContentImporter = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.AppvContentImporter
  $newAppV4xDeploymentType  = $newAppV4xContentImporter.CreateDeploymentType($packagePath)
  $newAppV4xDeploymentType.Installer.Contents[0].OnFastNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
  $newAppV4xDeploymentType.Installer.Contents[0].OnSlowNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
  $newApplication.DeploymentTypes.Add($newAppV4xDeploymentType)


  #Serialize the object to an xml blob
  $newApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToSTring($newApplication, $true)

  return $newApplicationXML
}

<############################################################################>

function Get-SmsAppV5xApplicationXml
{
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory=$true)]
    [System.String]$sccmAdminConsolePath,
    
    [Parameter(Mandatory=$true)]
    [System.String]$packagePath,
    
    [Parameter(Mandatory=$true)]
    [System.String]$appScopeId,
    
    [Parameter(Mandatory=$true)]
    [System.String]$appTitle,
    
    [System.String]$appDescription,
    
    [System.String]$appVersion,
    
    [System.String]$appPublisher,

    [System.String]$appLanguage
  )
  
  #Load the referenced SCCM assemblies
  Import-SCCMAssemblies $sccmAdminConsolePath 

  $newApplication = New-SmsApplication $appScopeId $appTitle $appDescription $appVersion $appPublisher $appLanguage

  #Deployment Type AppV
  $newAppV5xContentImporter  = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.Appv5XContentImporter
  $newAppV5xDeploymentType   = $newAppV5xContentImporter.CreateDeploymentType($packagePath)
  $newAppV5xDeploymentType.Installer.Contents[0].OnFastNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
  $newAppV5xDeploymentType.Installer.Contents[0].OnSlowNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
  $newApplication.DeploymentTypes.Add($newAppV5xDeploymentType)



  #Serialize the object to an xml blob
  $newApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToSTring($newApplication, $true)
  
  return $newApplicationXML
 }

<############################################################################>

function Get-SmsMsiApplicationXml
{
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory=$true)]
    [System.String]$sccmAdminConsolePath,
    
    [Parameter(Mandatory=$true)]
    [System.String]$packagePath,
    
    [Parameter(Mandatory=$true)]
    [System.String]$appScopeId,
    
    [Parameter(Mandatory=$true)] 
    [System.String]$appTitle,
    
    [System.String]$appDescription,
    
    [System.String]$appVersion,
    
    [System.String]$appPublisher,

    [System.String]$appLanguage
  )
  
  #Load the referenced SCCM assemblies
  Import-SCCMAssemblies $sccmAdminConsolePath 

  $newApplication = New-SmsApplication $appScopeId $appTitle $appDescription $appVersion $appPublisher $appLanguage

  #Deployment Type AppV
  $newMsiContentImporter  = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.MsiContentImporter
  $newMsiDeploymentType   = $newMsiContentImporter.CreateDeploymentType($packagePath)
  $newMsiDeploymentType.Installer.Contents[0].OnFastNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
  $newMsiDeploymentType.Installer.Contents[0].OnSlowNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
  $newApplication.DeploymentTypes.Add($newMsiDeploymentType)

  #Serialize the object to an xml blob
  $newApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToSTring($newApplication, $true)
  
  return $newApplicationXML
 }

 <############################################################################>

function Get-SmsWin8ApplicationXml
{
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory=$true)]
    [System.String]$sccmAdminConsolePath,
    
    [Parameter(Mandatory=$true)]
    [System.String]$packagePath,
    
    [Parameter(Mandatory=$true)]
    [System.String]$appScopeId,
    
    [Parameter(Mandatory=$true)]
    [System.String]$appTitle,
    
    [System.String]$appDescription,
    
    [System.String]$appVersion,
    
    [System.String]$appPublisher,

    [System.String]$appLanguage
  )
  
  #Load the referenced SCCM assemblies
  Import-SCCMAssemblies $sccmAdminConsolePath 

  $newApplication = New-SmsApplication $appScopeId $appTitle $appDescription $appVersion $appPublisher $appLanguage

  #Deployment Type AppV
  $newWin8ContentImporter  = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.Windows8AppContentImporter
  $newWin8DeploymentType   = $newWin8ContentImporter.CreateDeploymentType($packagePath)
  $newWin8DeploymentType.Installer.Contents[0].OnFastNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
  $newWin8DeploymentType.Installer.Contents[0].OnSlowNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
  $newApplication.DeploymentTypes.Add($newWin8DeploymentType)



  #Serialize the object to an xml blob
  $newApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToSTring($newApplication, $true)
  
  return $newApplicationXML
 }