$ErrorActionPreference  = "Stop"

# Import helper scripts
. $PSScriptRoot\RestHelpers.ps1
. $PSScriptRoot\CryptHelpers.ps1
. $PSScriptRoot\Authenticate.ps1
. $PSScriptRoot\AzureStorageHelpers.ps1

function Upload-Appx()
{
  [cmdletbinding()]
  param
  (
    [parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string]$AuthTokenJson,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceFile
  )

  $appxInfo = ExtractAppxInfo $SourceFile;
  UploadAppx $AuthTokenJson $SourceFile $appxInfo;
}

function Upload-AppxBundle()
{
  [cmdletbinding()]
  param
  (
    [parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string]$AuthTokenJson,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceFile
  )

  $bundleInfo = ExtractAppxBundleInfo $SourceFile;
  UploadAppx $AuthTokenJson $SourceFile $bundleInfo;
}

function UploadAppx()
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
    [Hashtable]$AppInfo
  )

  $AuthToken = @{}
  (ConvertFrom-Json $AuthTokenJson).psobject.properties | ForEach-Object { $AuthToken[$_.Name] = $_.Value }

  $LOBType = "microsoft.graph.windowsAppX"
  # Create a new MSI LOB app
  $FileName = [System.IO.Path]::GetFileName("$SourceFile")
  $appBody = GetAppBody $AppInfo
  $appBody.fileName = $FileName;
  $mobileApp = MakePostRequest "mobileApps" ($appBody | ConvertTo-Json) $AuthToken

  # Get the content version for the new app (this will always be 1 until the new app is committed).
  $appId = $mobileApp.id;
  $contentVersionUri = "mobileApps/$appId/$LOBType/contentVersions";
  $contentVersion = MakePostRequest $contentVersionUri "{}" $AuthToken;

  # Encrypt file and Get File Information
  $tempFile = [System.IO.Path]::GetDirectoryName("$SourceFile") + "\" + [System.IO.Path]::GetFileNameWithoutExtension("$SourceFile") + "_temp.bin"
  $encryptionInfo = EncryptFile $sourceFile $tempFile;
  [int] $originalSize = (Get-Item "$sourceFile").Length
  [int] $encriptedSize = (Get-Item "$tempFile").Length

  $encodedManifestBytes = [System.Text.Encoding]::ASCII.GetBytes($FileName)
  $encodedManifestXML = [Convert]::ToBase64String($encodedManifestBytes)

  # Create a new file entry in Azure for the upload
  $contentVersionId = $contentVersion.id;
  $fileBody = GetAppFileBody $FileName $originalSize $encriptedSize $encodedManifestXML;
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
function GetAppBody([parameter(Mandatory = $true)][hashtable] $info)
{
  $body = @{ "@odata.type" = "#microsoft.graph.windowsAppX" };
  $body.displayName = @{$false = $info.displayName; $true = $info.identityName}[[string]::IsNullOrEmpty($info.displayName)];
  $body.publisher = @{$false = $info.publisherDisplayName; $true = $info.identityPublisher}[[string]::IsNullOrEmpty($info.publisherDisplayName)];
  $body.description = @{$false = $info.description; $true = $body.displayName }[[string]::IsNullOrEmpty($info.description)];
  $body.fileName = $info.fileName;
  $body.applicableDeviceTypes = "desktop";
  $body.applicableArchitectures = $info.identityProcessorArhitecture;
  $body.isBundle = $info.isBundle;
  $body.identityName = $info.identityName;
  $body.identityPublisherHash = Get-IdentityPublisherHash($info.identityPublisher);
  $body.identityVersion = $info.identityVersion;
  $body.minimumSupportedOperatingSystem = @{
    "v10_0" = $true
  };
  return $body;
}

function ExtractAppxInfo([parameter(Mandatory = $true)] [string]$path)
{
  $appxInfo = @{};
  Add-Type -assembly "system.io.compression.filesystem";
  $appxArchive = [io.compression.zipfile]::OpenRead($path);

  # Extract data from the AppxManifest.xml file.

  $appxManifest = $appxArchive.Entries | where-object { $_.Name -eq "AppxManifest.xml"};
  $appxManifestStream = $appxManifest.Open();
  $appxManifestReader = New-Object IO.StreamReader($appxManifestStream);
  $appxManifestContent = $appxManifestReader.ReadToEnd();

  $ns = @{
    n = "http://schemas.microsoft.com/appx/manifest/foundation/windows10";
  };

  $appxInfo.identityPublisher = (Select-Xml -Content $appxManifestContent -Namespace $ns -XPath "/n:Package/n:Identity/@Publisher").Node.Value;
  $appxInfo.identityName = (Select-Xml -Content $appxManifestContent -Namespace $ns -XPath "/n:Package/n:Identity/@Name").Node.Value;
  $appxInfo.identityProcessorArhitecture = (Select-Xml -Content $appxManifestContent -Namespace $ns -XPath "/n:Package/n:Identity/@ProcessorArchitecture").Node.Value;
  $appxInfo.identityVersion = (Select-Xml -Content $appxManifestContent -Namespace $ns -XPath "/n:Package/n:Identity/@Version").Node.Value;
  $appxInfo.publisherDisplayName = (Select-Xml -Content $appxManifestContent -Namespace $ns -XPath "/n:Package/n:Properties/n:PublisherDisplayName").Node.InnerText ;
  $appxInfo.displayName = (Select-Xml -Content $appxManifestContent -Namespace $ns -XPath "/n:Package/n:Properties/n:DisplayName").Node.InnerText;
  $appxInfo.description = (Select-Xml -Content $appxManifestContent -Namespace $ns -XPath "/n:Package/n:Properties/n:Description").Node.InnerText;
  $appxInfo.isBundle = $false;

  $appxManifestReader.Close();
  $appxManifestStream.Close();


  # Close the archive.
  $appxArchive.Dispose();

  return $appxInfo;
}

function ExtractAppxBundleInfo([parameter(Mandatory = $true)] [string] $path)
{
  $bundleInfo = @{};

  Add-Type -assembly "system.io.compression.filesystem";
  $bundleArchive = [io.compression.zipfile]::OpenRead($path);

  # Read the display info from one of the bundled appx files.
  $bundledAppx = $bundleArchive.Entries | Where-Object { $_.Name -like "*.appx"} | Select-Object -First 1;
  $tempAppx = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath $bundledAppx.Name;
  [System.IO.Compression.ZipFileExtensions]::ExtractToFile($bundledAppx, $tempAppx, $true);
  $bundleInfo = ExtractAppxInfo($tempAppx);
  Remove-Item $tempAppx -Force;

  # Get all the package arhitectures contained by the bundle.
  $bundleManifest = $bundleArchive.Entries | Where-Object { $_.Name -eq "AppxBundleManifest.xml" };
  $bundleManifestStream = $bundleManifest.Open();
  $bundleManifestReader = New-Object IO.StreamReader($bundleManifestStream);
  $bundleManifestContent = $bundleManifestReader.ReadToEnd();

  $ns = @{
    n = "http://schemas.microsoft.com/appx/2013/bundle";
  };
  $applicationNodes = Select-Xml -Content $bundleManifestContent -Namespace $ns -XPath "/n:Bundle/n:Packages/n:Package[@Type='application']";
  $bundleArhitectures = "";
  foreach ($node in $applicationNodes)
  {
    $arhitecture = $node.Node.Attributes['Architecture'].Value;
    $bundleArhitectures += @{$false = ", $arhitecture"; $true = $arhitecture }[[string]::IsNullOrEmpty($bundleArhitectures)];
  }
  $bundleInfo.identityPublisher = (Select-Xml -Content $bundleManifestContent -Namespace $ns -XPath "/n:Bundle/n:Identity/@Publisher").Node.Value;
  $bundleInfo.identityName = (Select-Xml -Content $bundleManifestContent -Namespace $ns -XPath "/n:Bundle/n:Identity/@Name").Node.Value;
  $bundleInfo.identityVersion = (Select-Xml -Content $bundleManifestContent -Namespace $ns -XPath "/n:Bundle/n:Identity/@Version").Node.Value;
  $bundleInfo.identityProcessorArhitecture = $bundleArhitectures;
  $bundleManifestReader.Close();
  $bundleManifestStream.Close();

  # Mark package as bundle.
  $bundleInfo.isBundle = $true;

  # Close the archive.
  $bundleArchive.Dispose();
  return $bundleInfo;
}

function Get-IdentityPublisherHash([string] $publisherId)
{
  # The publisher hash is obtained by encding using Crockford Base 32 algrithm the first 8 bytes of
  # publisher SHA256
  $sha256 = [System.Security.Cryptography.SHA256]::Create();
  [byte[]] $hash = $sha256.ComputeHash([System.Text.Encoding]::Unicode.GetBytes($publisherId))[0..7]
  return (ConvertTo-Base32String $hash)
}