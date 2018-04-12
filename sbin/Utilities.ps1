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
# Helper methods used elsewhere

Function Run-With-Retry
{
  param 
  ( [Parameter(Mandatory=$true)] [string]$command,
    [Parameter(Mandatory=$true)] [hashtable]$arguments, 
    [Parameter(Mandatory=$false)] [int]$retryCount = 3, 
    [Parameter(Mandatory=$false)] [int]$delayInSeconds = 2
  )

  $currentRetryCount = 0
  $isSuccessful = $false

  $formattedArguments = $arguments.Keys.ForEach({"-$($_): $($arguments.$_)"}) -join ' '

  while (-not $isSuccessful)
  {
    try
    {
      $commandOutput = & $Command @Arguments 2>&1

      $isSuccessful = $true
    }
    catch
    {
      if ($retryCount -ge $currentRetryCount)
      {
        Write-Host "Failed to run command $command with arguments $formattedArguments. Exhausted $retrycount tries." 

        throw
      }
      else
      {
        Write-Verbose "Failed to run command $command with arguments $formattedArguments. Retrying in {1} seconds."

        Start-Sleep $delayInSeconds
        
        $currentRetryCount++
      }
    }
  }

  $commandOutput
}

Function Get-Available-Port() 
{ 
  $SessionManagerEndpoint = $Env:SESSION_MANAGER_ENDPOINT
  $GetURL = "${SessionManagerEndpoint}/session-manager/v1/open-port"
  
  $portNumber = Run-With-Retry -command 'Invoke-WebRequest' -argument @{ URI=$GetURL; UseBasicParsing=$true; Method="GET"}
  Write-Host "Got open port $portNumber from $GetURL."

  $portNumber
}

Function Get-Host-IPV4-Address()
{
  $ipv4Address = & nslookup -type=A $env:COMPUTERNAME | select -Skip 4 -First 1 | % { $_.Split(':')[1].Trim() }
  $ipv4Address
}