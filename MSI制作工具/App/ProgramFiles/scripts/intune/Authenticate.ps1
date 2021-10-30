function Get-AuthToken
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [String] $User,
    [Parameter(Mandatory = $true)]
    [securestring] $Password
  )

  # Obtain the
  $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
  $tenant = $userUpn.Host

  # Import the Azure ActiveDirectory Assemblies.
  $adalAssembliesRoot = GetAzureActiveDirectoryAssembliesRoot
  $adal = Join-Path  -Path "$adalAssembliesRoot" -ChildPath "Microsoft.IdentityModel.Clients.ActiveDirectory.dll" -Resolve
  $adalforms = Join-Path -Path "$adalAssembliesRoot" -ChildPath "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll" -Resolve
  [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
  [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

  #Intune app client id.
  $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
  $resourceAppIdURI = "https://graph.microsoft.com"
  $authority = "https://login.microsoftonline.com/$tenant"

  try
  {
    $authContext = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext -ArgumentList $authority
    $userCredentials = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential -ArgumentList $User, $Password
    $authResult = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext, $resourceAppIdURI, $clientid, $userCredentials);
    if ($authResult.Result.AccessToken)
    {

      # Creating header for Authorization token
      $authHeader = @{
        'Content-Type' = 'application/json'
        'Authorization' = "Bearer " + $authResult.Result.AccessToken
        'ExpiresOn' = $authResult.Result.ExpiresOn
      }

      return (ConvertTo-Json $authHeader)
    }
    elseif ($authResult.Exception)
    {
      throw "An error occured getting access token: $($authResult.Exception.InnerException)"
    }
  }
  catch
  {
    throw $_.Exception.Message
  }
}

function GetAzureActiveDirectoryAssembliesRoot()
{
  $adalAssembliesRoot = "$PSScriptRoot\\..\\..\\third-party\\intune\\"
  if (Test-Path $adalAssembliesRoot)
  {
    return $adalAssembliesRoot;
  }

  $adalAssembliesRoot = "$PSScriptRoot\\..\\..\\third-party\\bin\\intune\\"
  if (Test-Path $adalAssembliesRoot)
  { 
    return $adalAssembliesRoot;
  }

  throw "Could not detect the Azure ActiveDirectory Assemblies location"
}
