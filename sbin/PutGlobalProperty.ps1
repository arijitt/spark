param
(
  [Parameter(Mandatory=$true)][string]${Key} = "key",
  [Parameter(Mandatory=$true)][string]${Value} = "value"
)

$SessionManagerEndpoint = $Env:SESSION_MANAGER_ENDPOINT
$PutURL = "${SessionManagerEndpoint}/session-manager/v1/properties/${Key}"
Write-Host "Posting user properties to $PutURL with value=${Value}."
Invoke-WebRequest -URI ${PutURL} -usebasicparsing -Method PUT -Body ${Value}