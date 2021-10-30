$ErrorActionPreference  = "Stop"

# Import helper scripts
. $PSScriptRoot\RestHelpers.ps1
. $PSScriptRoot\CryptHelpers.ps1
. $PSScriptRoot\Authenticate.ps1
. $PSScriptRoot\AzureStorageHelpers.ps1

function Upload-Msi
{
  [cmdletbinding()]
  param
  (
    [parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string]$AuthTokenJson,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceFile,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Publisher,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Description,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [version]$Version,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [guid]$ProductCode,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [guid]$UpgradeCode,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Language
  )


  $AuthToken = @{}
  (ConvertFrom-Json $AuthTokenJson).psobject.properties | ForEach-Object { $AuthToken[$_.Name] = $_.Value }

  $LOBType = "microsoft.graph.windowsMobileMSI"
  # Create a new MSI LOB app
  $FileName = [System.IO.Path]::GetFileName("$SourceFile")
  $mobileAppBody = GetMSIAppBody -displayName "$Name" -publisher "$Publisher" -description "$Description" -filename "$FileName" -identityVersion "$Version" -ProductCode "$ProductCode"
  $mobileApp = MakePostRequest "mobileApps" ($mobileAppBody | ConvertTo-Json) $AuthToken

  # Get the content version for the new app (this will always be 1 until the new app is committed).
  $appId = $mobileApp.id;
  $contentVersionUri = "mobileApps/$appId/$LOBType/contentVersions";
  $contentVersion = MakePostRequest $contentVersionUri "{}" $AuthToken;

  # Encrypt file and Get File Information
  $tempFile = [System.IO.Path]::GetDirectoryName("$SourceFile") + "\" + [System.IO.Path]::GetFileNameWithoutExtension("$SourceFile") + "_temp.bin"
  $encryptionInfo = EncryptFile $sourceFile $tempFile;
  $Size = (Get-Item "$sourceFile").Length
  $EncrySize = (Get-Item "$tempFile").Length

  # Create the manifest file used to install the application on the device
  $manifestXML = GetMsiInstallationManifest($UpgradeCode)
  $encodedManifestBytes = [System.Text.Encoding]::ASCII.GetBytes($manifestXML)
  $encodedManifestXML = [Convert]::ToBase64String($encodedManifestBytes)

  # Create a new file entry in Azure for the upload
  $contentVersionId = $contentVersion.id;
  $fileBody = GetAppFileBody "$FileName" $Size $EncrySize "$encodedManifestXML";
  $filesUri = "mobileApps/$appId/$LOBType/contentVersions/$contentVersionId/files";
  $file = MakePostRequest $filesUri ($fileBody | ConvertTo-Json) $AuthToken;
  # Wait for the file entry URI to be created
  $fileId = $file.id;
  $fileUri = "mobileApps/$appId/$LOBType/contentVersions/$contentVersionId/files/$fileId";
  $file = WaitForFileProcessing $fileUri "AzureStorageUriRequest" $AuthToken;

  # Uploade file to Azure Storage
  UploadFileToAzureStorage $file.azureStorageUri $tempFile;

  # Commit the file into Azure Storage and wait.
  $commitFileUri = "mobileApps/$appId/$LOBType/contentVersions/$contentVersionId/files/$fileId/commit";
  MakePostRequest $commitFileUri ($encryptionInfo | ConvertTo-Json) $AuthToken;
  $file = WaitForFileProcessing $fileUri "CommitFile" $AuthToken;

  # Commit the app.
  $commitAppUri = "mobileApps/$appId";
  $commitAppBody = GetAppCommitBody $contentVersionId $LOBType;
  MakePatchRequest $commitAppUri ($commitAppBody | ConvertTo-Json) $AuthToken;

  # Cleanup. Remove temp copy of MSI file.
  Remove-Item -Path "$tempFile" -Force

  # Sleep for 30 seconds to allow patch completion
  Start-Sleep 30
}

function GetMSIAppBody(
  [parameter(Mandatory = $true)] [string] $displayName, 
  [parameter(Mandatory = $true)] [string] $publisher, 
  [parameter(Mandatory = $true)] [string] $description, 
  [parameter(Mandatory = $true)] [string] $filename, 
  [parameter(Mandatory = $true)] [string] $identityVersion, 
  [parameter(Mandatory = $true)] [string] $ProductCode)
{
  $body = @{ "@odata.type" = "#microsoft.graph.windowsMobileMSI" };
  $body.displayName = $displayName;
  $body.publisher = $publisher;
  $body.description = $description;
  $body.fileName = $filename;
  $body.identityVersion = $identityVersion;
  $body.informationUrl = $null;
  $body.isFeatured = $false;
  $body.privacyInformationUrl = $null;
  $body.developer = "";
  $body.notes = "";
  $body.owner = "";
  $body.productCode = "$ProductCode";
  $body.productVersion = "$identityVersion";

  return $body;
}
function GetMsiInstallationManifest([parameter(Mandatory = $true)] [string] $UpgradeCode)
{
  [xml]$manifestXML = '<MobileMsiData
  MsiExecutionContext="Any"
  MsiRequiresReboot="false"
  MsiUpgradeCode=""
  MsiIsMachineInstall="true"
  MsiIsUserInstall="false"
  MsiIncludesServices="false"
  MsiContainsSystemRegistryKeys="false"
  MsiContainsSystemFolders="false"></MobileMsiData>'
  $manifestXML.MobileMsiData.MsiUpgradeCode = "$UpgradeCode"
  return $manifestXML.OuterXml.ToString()
}

