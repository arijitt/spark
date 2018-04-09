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
# Get free ports and them as specific environment variables

Function get-available-port() 
{ 
  $SessionManagerEndpoint = $Env:SESSION_MANAGER_ENDPOINT
  $GetURL = "${SessionManagerEndpoint}/session-manager/v1/open-port"
  Write-Host "Getting open ports from $GetURL."
  $portNumber = Invoke-WebRequest -URI ${GetURL} -usebasicparsing -Method GET
  $portNumber
}

# Spark service ports

# Test ports

$sparkMasterPort = 7077
$sparkMasterWebPort = 9090
$sparkHistoryWebPort = 2040
$livyServerPort = 2022

# Dynamic ports

#$sparkMasterPort = get-available-port
#$sparkMasterWebPort = get-available-port
#$sparkHistoryWebPort = get-available-port
#$livyServerPort = get-available-port

# Store Local properties

$containerScriptPath = "$PSScriptRoot\PutContainerProperty.ps1"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_PORT")
$inputArguments += ("-value", $sparkMasterPort)

Invoke-Expression "$containerScriptPath $inputArguments"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_WEBUI_PORT")
$inputArguments += ("-value", $sparkMasterWebPort)

Invoke-Expression "$containerScriptPath $inputArguments"


$inputArguments = @()
$inputArguments += ("-key", "SPARK_HISTORY_WEBUI_PORT")
$inputArguments += ("-value", $sparkHistoryWebPort)

Invoke-Expression "$containerScriptPath $inputArguments"

$inputArguments = @()
$inputArguments += ("-key", "LIVY_SERVER_PORT")
$inputArguments += ("-value", $livyServerPort)

Invoke-Expression "$containerScriptPath $inputArguments"

# Store Global properties

$userScriptPath = "$PSScriptRoot\PutGlobalProperty.ps1"
$computerHostname = $env:COMPUTERNAME

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_URL")
$inputArguments += ("-value", "spark://$computerHostname`:$sparkMasterPort")

Invoke-Expression "$userScriptPath $inputArguments"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_WEBUI_URL")
$inputArguments += ("-value", "http://$computerHostname`:$sparkMasterWebPort")

Invoke-Expression "$userScriptPath $inputArguments"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_HISTORY_WEBUI_URL")
$inputArguments += ("-value", "http://$computerHostname`:$sparkHistoryWebPort")

Invoke-Expression "$userScriptPath $inputArguments"

$inputArguments = @()
$inputArguments += ("-key", "LIVY_SERVER_URL")
$inputArguments += ("-value", "http://$computerHostname`:$livyServerPort")

Invoke-Expression "$userScriptPath $inputArguments"

#Spark application ports

#spark.blockManager.port    (random)
#spark.broadcast.port       (random)
#spark.driver.port          (random)
#spark.executor.port        (random)
#spark.fileserver.port      (random)
#spark.replClassServer.port (random)

# Test ports

$sparkBlockManagerPort = 38000
$sparkBroadcastPort = 38001
$parkDriverPort = 38002
$sparkExecutorPort = 38003
$sparkFileServerPort = 38004
$sparkReplClassServerPort = 38005

# Dynamic ports

#$sparkBlockManagerPort = get-available-port
#$sparkBroadcastPort = get-available-port
#$parkDriverPort = get-available-port
#$sparkExecutorPort = get-available-port
#$sparkFileServerPort = get-available-port
#$sparkReplClassServerPort = get-available-port

# Store Local properties

$containerScriptPath = "$PSScriptRoot\PutContainerProperty.ps1"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_BLOCK_MANAGER_PORT")
$inputArguments += ("-value", $sparkBlockManagerPort)

Invoke-Expression "$containerScriptPath $inputArguments"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_BROADCAST_PORT")
$inputArguments += ("-value", $sparkBroadcastPort)

Invoke-Expression "$containerScriptPath $inputArguments"


$inputArguments = @()
$inputArguments += ("-key", "SPARK_DRIVER_PORT")
$inputArguments += ("-value", $parkDriverPort)

Invoke-Expression "$containerScriptPath $inputArguments"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_EXECUTOR_PORT")
$inputArguments += ("-value", $sparkExecutorPort)

Invoke-Expression "$containerScriptPath $inputArguments"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_FILE_SERVER_PORT")
$inputArguments += ("-value", $sparkFileServerPort)

Invoke-Expression "$containerScriptPath $inputArguments"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_REPL_CLASS_SERVER_PORT")
$inputArguments += ("-value", $sparkReplClassServerPort)

Invoke-Expression "$containerScriptPath $inputArguments"