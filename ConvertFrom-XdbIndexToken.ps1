param(
    [string]$Token = (Read-Host "Enter xdbtokenbytes_s value")
)

$bytes = [Convert]::FromBase64String($Token)
$ms = [System.IO.MemoryStream]::new($bytes, 0, $bytes.Length)
$bf = [System.Runtime.Serialization.Formatters.Binary.BinaryFormatter]::new()
$dict = $bf.Deserialize($ms);

Write-Output $dict
