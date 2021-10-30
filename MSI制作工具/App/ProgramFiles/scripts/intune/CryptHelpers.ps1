function GenerateKey()
{
  try
  {
    $aes = [System.Security.Cryptography.Aes]::Create();
    $aesProvider = New-Object System.Security.Cryptography.AesCryptoServiceProvider;
    $aesProvider.GenerateKey();
    return $aesProvider.Key;
  }
  finally
  {
    if ($aesProvider -ne $null) { $aesProvider.Dispose(); }
    if ($aes -ne $null) { $aes.Dispose(); }
  }
}
function GenerateIV()
{
  try
  {
    $aes = [System.Security.Cryptography.Aes]::Create();
    return $aes.IV;
  }
  finally
  {
    if ($aes -ne $null) { $aes.Dispose(); }
  }
}
function EncryptFileWithIV(
  [parameter(Mandatory = $true)] [string] $sourceFile, 
  [parameter(Mandatory = $true)] [string] $targetFile, 
  [parameter(Mandatory = $true)] [byte[]] $encryptionKey, 
  [parameter(Mandatory = $true)] [byte[]] $hmacKey, 
  [parameter(Mandatory = $true)] [byte[]] $initializationVector)
{
  $bufferBlockSize = 1024 * 4;
  $computedMac = $null;

  try
  {
    $aes = [System.Security.Cryptography.Aes]::Create();
    $hmacSha256 = New-Object System.Security.Cryptography.HMACSHA256;
    $hmacSha256.Key = $hmacKey;
    $hmacLength = $hmacSha256.HashSize / 8;

    $buffer = New-Object byte[] $bufferBlockSize;
    $bytesRead = 0;

    $targetStream = [System.IO.File]::Open($targetFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read);
    $targetStream.Write($buffer, 0, $hmacLength + $initializationVector.Length);

    try
    {
      $encryptor = $aes.CreateEncryptor($encryptionKey, $initializationVector);
      $sourceStream = [System.IO.File]::Open($sourceFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read);
      $cryptoStream = New-Object System.Security.Cryptography.CryptoStream -ArgumentList @($targetStream, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write);

      $targetStream = $null;
      while (($bytesRead = $sourceStream.Read($buffer, 0, $bufferBlockSize)) -gt 0)
      {
        $cryptoStream.Write($buffer, 0, $bytesRead);
        $cryptoStream.Flush();
      }
      $cryptoStream.FlushFinalBlock();
    }
    finally
    {
      if ($cryptoStream -ne $null) { $cryptoStream.Dispose(); }
      if ($sourceStream -ne $null) { $sourceStream.Dispose(); }
      if ($encryptor -ne $null) { $encryptor.Dispose(); }
    }

    try
    {
      $finalStream = [System.IO.File]::Open($targetFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::Read)

      $finalStream.Seek($hmacLength, [System.IO.SeekOrigin]::Begin) > $null;
      $finalStream.Write($initializationVector, 0, $initializationVector.Length);
      $finalStream.Seek($hmacLength, [System.IO.SeekOrigin]::Begin) > $null;

      $hmac = $hmacSha256.ComputeHash($finalStream);
      $computedMac = $hmac;

      $finalStream.Seek(0, [System.IO.SeekOrigin]::Begin) > $null;
      $finalStream.Write($hmac, 0, $hmac.Length);
    }
    finally
    {
      if ($finalStream -ne $null) { $finalStream.Dispose(); }
    }
  }
  finally
  {
    if ($targetStream -ne $null) { $targetStream.Dispose(); }
    if ($aes -ne $null) { $aes.Dispose(); }
  }

  return $computedMac;
}
function EncryptFile(
  [parameter(Mandatory = $true)] [string] $sourceFile, 
  [parameter(Mandatory = $true)] [string] $targetFile)
{
  $encryptionKey = GenerateKey;
  $hmacKey = GenerateKey;
  $initializationVector = GenerateIV;

  # Create the encrypted target file and compute the HMAC value.
  $mac = EncryptFileWithIV $sourceFile $targetFile $encryptionKey $hmacKey $initializationVector;

  # Compute the SHA256 hash of the source file and convert the result to bytes.
  $fileDigest = (Get-FileHash $sourceFile -Algorithm SHA256).Hash;
  $fileDigestBytes = New-Object byte[] ($fileDigest.Length / 2);
  for ($i = 0; $i -lt $fileDigest.Length; $i += 2)
  {
    $fileDigestBytes[$i / 2] = [System.Convert]::ToByte($fileDigest.Substring($i, 2), 16);
  }

  # Return an object that will serialize correctly to the file commit Graph API.
  $encryptionInfo = @{};
  $encryptionInfo.encryptionKey = [System.Convert]::ToBase64String($encryptionKey);
  $encryptionInfo.macKey = [System.Convert]::ToBase64String($hmacKey);
  $encryptionInfo.initializationVector = [System.Convert]::ToBase64String($initializationVector);
  $encryptionInfo.mac = [System.Convert]::ToBase64String($mac);
  $encryptionInfo.profileIdentifier = "ProfileVersion1";
  $encryptionInfo.fileDigest = [System.Convert]::ToBase64String($fileDigestBytes);
  $encryptionInfo.fileDigestAlgorithm = "SHA256";

  $fileEncryptionInfo = @{};
  $fileEncryptionInfo.fileEncryptionInfo = $encryptionInfo;

  return $fileEncryptionInfo;
}

function ConvertTo-Base32String([parameter(Mandatory = $true)] [byte[]] $byteArray)
{
  Set-Variable CROCKFORS_ALPHABET -Value "0123456789abcdefghjkmnpqrstvwxyz";
  Set-Variable B32_BLOCK_SIZE -Value 5;

  $originalLength = $byteArray.Length;
  $groupsCount = [Math]::floor($originalLength / $B32_BLOCK_SIZE);
  $extraBytes = $originalLength % $B32_BLOCK_SIZE;

  $buffer = $byteArray.Clone();

  for ($i = 0; $i -lt $groupsCount; $i++)
  {
    $currentGroup = $i * $B32_BLOCK_SIZE;
    $result += $CROCKFORS_ALPHABET[($buffer[$currentGroup] -shr 3)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup] -band 0x07) -shl 2) -bor ($buffer[$currentGroup + 1] -shr 6)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 1] -band 0x3F) -shr 1)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 1] -band 0x01) -shl 4) -bor ($buffer[$currentGroup + 2] -shr 4)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 2] -band 0x0F) -shl 1) -bor ($buffer[$currentGroup + 3] -shr 7)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 3] -band 0x7C) -shr 2)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 3] -band 0x03) -shl 3) -bor ($buffer[$currentGroup + 4] -shr 5)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 4] -band 0x1F))];
  }

  if ( $extraBytes -gt 0 )
  {
    $endBuffer = $byteArray[($groupsCount * $B32_BLOCK_SIZE)..($originalLength - 1)];
    $currentGroup = 0;
    $result += $CROCKFORS_ALPHABET[($endBuffer[$currentGroup] -shr 3)];
    if ( $extraBytes -gt 1 )
    {
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup] -band 0x07) -shl 2) -bor ($endBuffer[$currentGroup + 1] -shr 6)];
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 1] -band 0x3F) -shr 1)];
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 1] -band 0x01) -shl 4) -bor ($endBuffer[$currentGroup + 2] -shr 4)];
    }

    if ( $extraBytes -gt 2 )
    {
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 2] -band 0x0F) -shl 1) -bor ($endBuffer[$currentGroup + 3] -shr 7)];
    }

    if ( $extraBytes -gt 3)
    {
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 3] -band 0x7C) -shr 2)];
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 3] -band 0x03) -shl 3) -bor ($endBuffer[$currentGroup + 4] -shr 5)];
    }
  }

  return $result;
}

