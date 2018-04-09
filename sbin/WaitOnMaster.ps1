param([string]${Key} = "key", [string]${Value} = "value")

$ItemGroup = "ItemGroup"
$SessionManagerHost = $Env:SESSION_MANAGER_HOST
$SessionId = $Env:SESSION_ID
$GetURL = "http://${SessionManagerHost}:2030/getvalue?key=${SessionId}WebPort"

$QuotedPort = Invoke-WebRequest -URI ${GetURL} -usebasicparsing
$SessionWebPort = $QuotedPort.Content.Replace("`"","") 

$StatusCode = -1

do 
{
	try 
	{
		Write-Host "Polling for Spark Master..."

		$GetURL = "http://${value}:${SessionWebPort}"

		$MasterResponse = Invoke-WebRequest -URI ${GetURL} -usebasicparsing
		$StatusCode = ${MasterResponse}.StatusCode

		Write-Host "Spark Master returned Status Code" ${StatusCode}
	} 
	catch 
	{

		Write-Host "Waiting on Spark Master..."
	}

} while ($StatusCode -ne 200)