function UploadFileToAzureStorage(
  [parameter(Mandatory = $true)] [string]$sasUri, 
  [parameter(Mandatory = $true)] [string]$filepath)
{
  # Chunk size = 1 MiB
  $chunkSizeInBytes = 1024 * 1024;

  # Read the whole file and find the total chunks.
  #[byte[]]$bytes = Get-Content $filepath -Encoding byte;
  # Using ReadAllBytes method as the Get-Content used alot of memory on the machine
  [byte[]]$bytes = [System.IO.File]::ReadAllBytes($filepath);
  $chunks = [Math]::Ceiling($bytes.Length / $chunkSizeInBytes);

  # Upload each chunk.
  $ids = @();
  $cc = 1

  foreach ($chunk in 0..($chunks - 1)) 
  {
    $id = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($chunk.ToString("0000")));
    $ids += $id;

    $start = $chunk * $chunkSizeInBytes;
    $end = [Math]::Min($start + $chunkSizeInBytes - 1, $bytes.Length - 1);
    $body = $bytes[$start..$end];

    Write-Progress -Activity "Uploading File to Azure Storage" -status "Uploading chunk $cc of $chunks" `
      -percentComplete ($cc / $chunks * 100)
    $cc++

    $uploadResponse = UploadAzureStorageChunk $sasUri $id $body;
  }

  Write-Progress -Completed -Activity "Uploading File to Azure Storage"

  Write-Host

  # Finalize the upload.
  $uploadResponse = FinalizeAzureStorageUpload $sasUri $ids;
}

function UploadAzureStorageChunk(
  [parameter(Mandatory = $true)] [string] $sasUri, 
  [parameter(Mandatory = $true)] [string] $id, 
  [parameter(Mandatory = $true)] [byte[]] $body)
{
  $uri = "$sasUri&comp=block&blockid=$id";
  $request = "PUT $uri";

  $iso = [System.Text.Encoding]::GetEncoding("iso-8859-1");
  $encodedBody = $iso.GetString($body);
  $headers = @{
    "x-ms-blob-type" = "BlockBlob"
  };

  if ($logRequestUris) { Write-Host $request; }
  if ($logHeaders) { WriteHeaders $headers; }

  try
  {
    Invoke-WebRequest $uri -Method Put -Headers $headers -Body $encodedBody;
  }
  catch
  {
    Write-Host -ForegroundColor Red $request;
    Write-Host -ForegroundColor Red $_.Exception.Message;
    throw;
  }

}

function FinalizeAzureStorageUpload(
  [parameter(Mandatory = $true)] [string] $sasUri, 
  [parameter(Mandatory = $true)] [string[]] $ids )
{
  $uri = "$sasUri&comp=blocklist";
  $request = "PUT $uri";

  $xml = '<?xml version="1.0" encoding="utf-8"?><BlockList>';
  foreach ($id in $ids)
  {
    $xml += "<Latest>$id</Latest>";
  }
  $xml += '</BlockList>';

  if ($logRequestUris) { Write-Host $request; }
  if ($logContent) { Write-Host -ForegroundColor Gray $xml; }

  try
  {
    Invoke-RestMethod $uri -Method Put -Body $xml;
  }
  catch
  {
    Write-Host -ForegroundColor Red $request;
    Write-Host -ForegroundColor Red $_.Exception.Message;
    throw;
  }
}
function WaitForFileProcessing(
  [parameter(Mandatory = $true)] [string] $fileUri, 
  [parameter(Mandatory = $true)] [string] $stage, 
  [parameter(Mandatory = $true)] [hashtable] $authToken)
{
  $attempts = 60;
  $waitTimeInSeconds = 1;

  $successState = "$($stage)Success";
  $pendingState = "$($stage)Pending";

  $file = $null;
  while ($attempts -gt 0)
  {
    $file = MakeGetRequest $fileUri $authToken;

    if ($file.uploadState -eq $successState)
    {
      break;
    }
    elseif ($file.uploadState -ne $pendingState)
    {
      throw "File upload state is not success: $($file.uploadState)";
    }

    Start-Sleep $waitTimeInSeconds;
    $attempts--;
  }

  if ($file -eq $null)
  {
    throw "File request did not complete in the allotted time.";
  }

  return $file;
}

function GetAppFileBody(
  [parameter(Mandatory = $true)] [string] $name, 
  [parameter(Mandatory = $true)] [int] $size, 
  [parameter(Mandatory = $true)] [int] $sizeEncrypted, 
  [parameter(Mandatory = $true)] [string] $manifest)
{
  $body = @{ "@odata.type" = "#microsoft.graph.mobileAppContentFile" };
  $body.name = $name;
  $body.size = $size;
  $body.sizeEncrypted = $sizeEncrypted;
  $body.manifest = $manifest;

  return $body;
}

function GetAppCommitBody(
  [parameter(Mandatory = $true)] [string] $contentVersionId, 
  [parameter(Mandatory = $true)] [string] $LobType)
{
  $body = @{ "@odata.type" = "#$LobType" };
  $body.committedContentVersion = $contentVersionId;

  return $body;
}