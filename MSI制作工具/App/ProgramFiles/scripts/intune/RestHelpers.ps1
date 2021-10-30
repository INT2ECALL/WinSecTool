$baseUrl = "https://graph.microsoft.com/beta/deviceAppManagement/"
function MakeGetRequest(
  [parameter(Mandatory = $true)] [string] $collectionPath, 
  [parameter(Mandatory = $true)] [hashtable] $authToken)
{
  $uri = "$baseUrl$collectionPath";
  $request = "GET $uri";
  try
  {
    $response = Invoke-RestMethod $uri -Method Get -Headers $authToken;
    return $response;
  }
  catch
  {
    Write-Host -ForegroundColor Red $request;
    Write-Host -ForegroundColor Red $_.Exception.Message;
    throw;
  }
}
function MakePatchRequest(
  [parameter(Mandatory = $true)] [string] $collectionPath, 
  [parameter(Mandatory = $true)] [string] $body, 
  [parameter(Mandatory = $true)] [hashtable] $authToken)
{
  MakeRequest "PATCH" $collectionPath $body $authToken;
}

function MakePostRequest(
  [parameter(Mandatory = $true)] [string] $collectionPath, 
  [parameter(Mandatory = $true)] [string] $body, 
  [parameter(Mandatory = $true)] [hashtable] $authToken)
{
  MakeRequest "POST" $collectionPath $body $authToken;
}
function MakeRequest(
  [parameter(Mandatory = $true)] [ValidateSet("GET", "PATCH", "POST")][string] $verb, 
  [parameter(Mandatory = $true)] [string] $collectionPath, 
  [parameter(Mandatory = $true)] [string] $body, 
  [parameter(Mandatory = $true)] [hashtable] $authToken)
{
  $uri = "$baseUrl$collectionPath";
  $request = "$verb $uri";

  $headers = CloneObject $authToken;
  $headers["content-length"] = $body.Length;
  $headers["content-type"] = "application/json";

  try
  {
    $response = Invoke-RestMethod $uri -Method $verb -Headers $headers -Body $body;
    return $response;
  }
  catch
  {
    Write-Host -ForegroundColor Red $request;
    Write-Host -ForegroundColor Red $_.Exception.Message;
    throw;
  }
}

function CloneObject([parameter(Mandatory = $true)] [psobject] $deepCopyObject) 
{ 
  $stream = New-Object IO.MemoryStream; 
  $formatter = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter; 
  $formatter.Serialize($stream, $deepCopyObject); 
  $stream.Position = 0; 
  $formatter.Deserialize($stream); 
} 
