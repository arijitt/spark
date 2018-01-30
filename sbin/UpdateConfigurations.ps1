# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copy a template file into a configuration file and update one or more
# configuration values in the configuration file

param 
( 
  [string]$FilePath,
  [string[]]$ConfigurationKeys,
  [string[]]$ConfigurationValues,
  [string] $ConfigurationDelimiter
)

if (!$FilePath) { Write-Host "Configuration file path is not specified with -FilePath. Skipping updating configurations."; ([Environment]::Exit(0)) }
if (!$ConfigurationKeys) { Write-Host "Configuration key is not specified with -ConfigurationKeys. Skipping updating configurations"; ([Environment]::Exit(0))  }
if (!$ConfigurationValues) { Write-Host "Configuration value is not specified with -ConfigurationValues. Skipping updating configurations"; ([Environment]::Exit(0)) }

if (!$ConfigurationDelimiter) { $ConfigurationDelimiter = " " }

if ($ConfigurationKeys.Length -ne $ConfigurationValues.Length) { throw [System.ArgumentException] "Key count $ConfigurationKeys.Length not equal to value count $ConfigurationValues.Length" }

if (-not (Test-Path "$FilePath.template")) { throw [System.ApplicationException] "Template file not found at $FilePath.template." }

#Replace if exists

$keyFoundStatus = New-Object bool[] $ConfigurationKeys.Length

$fileContent = Get-Content -Path "$FilePath.template" | % {
 
  $keyReplaced = $false;

  for ($i = 0; $i -lt $ConfigurationKeys.Length; ++$i)
  { 
    $ConfigurationKey = $ConfigurationKeys[$i]
    $ConfigurationValue = $ConfigurationValues[$i]   

    if ($_ -match $ConfigurationKey)
    {
       Write-Host "Key $ConfigurationKey updated to value $ConfigurationValue."

       $keyFoundStatus[$i] = $true
       $keyReplaced = $true
       "$ConfigurationKey $ConfigurationDelimiter $ConfigurationValue"   
    }
  }

  if ($keyReplaced -eq $false)
  {
       $_
  }
} | Out-File -Encoding ascii -filepath "$FilePath"

#Append those not found

for ($i = 0; $i -lt $ConfigurationKeys.Length; ++$i)
{
  if ($keyFoundStatus[$i] -eq $false)
  {
    $ConfigurationKey = $ConfigurationKeys[$i]
    $ConfigurationValue = $ConfigurationValues[$i]          

    Write-Host "Key $ConfigurationKey added with value $ConfigurationValue."

    "`r$ConfigurationKey $ConfigurationDelimiter $ConfigurationValue" | Out-File -Encoding ascii -filepath $FilePath -Append
  }
}

