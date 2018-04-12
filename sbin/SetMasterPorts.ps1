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

. $PSScriptRoot\Utilities.ps1

# Spark service default ports

#$sparkMasterPort      7077
#$sparkMasterWebPort   8080
#$sparkHistoryWebPort  18080
#$livyServerPort       8998

# Spark service test ports

$sparkMasterPort = 7077
$sparkMasterWebPort = 9090
$sparkHistoryWebPort = 2040
$livyServerPort = 2022

# Spark service dynamic ports

#$sparkMasterPort = get-available-port
#$sparkMasterWebPort = get-available-port
#$sparkHistoryWebPort = get-available-port
#$livyServerPort = get-available-port

# Store Local properties

$containerScriptPath = "$PSScriptRoot\PutContainerProperty.ps1"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_PORT")
$inputArguments += ("-value", $sparkMasterPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_WEBUI_PORT")
$inputArguments += ("-value", $sparkMasterWebPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_HISTORY_WEBUI_PORT")
$inputArguments += ("-value", $sparkHistoryWebPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "LIVY_SERVER_PORT")
$inputArguments += ("-value", $livyServerPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

# Store Global properties

$userScriptPath = "$PSScriptRoot\PutGlobalProperty.ps1"
$hostAddress = get-host-ipv4-address

if ($hostAddress -eq $null) { $hostAddress = $env:COMPUTERNAME }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_URL")
$inputArguments += ("-value", "spark://$hostAddress`:$sparkMasterPort")

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$userScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_WEBUI_URL")
$inputArguments += ("-value", "http://$hostAddress`:$sparkMasterWebPort")

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$userScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_HISTORY_WEBUI_URL")
$inputArguments += ("-value", "http://$hostAddress`:$sparkHistoryWebPort")

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$userScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "LIVY_SERVER_URL")
$inputArguments += ("-value", "http://$hostAddress`:$livyServerPort")

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$userScriptPath`" $inputArguments" }

# Spark application default ports

#spark.blockManager.port    (random)
#spark.broadcast.port       (random)
#spark.driver.port          (random)
#spark.executor.port        (random)
#spark.fileserver.port      (random)
#spark.replClassServer.port (random)

# Spark application test ports

#$sparkBlockManagerPort = 38000
#$sparkBroadcastPort = 38001
#$parkDriverPort = 38002
#$sparkExecutorPort = 38003
#$sparkFileServerPort = 38004
#$sparkReplClassServerPort = 38005

# Spark application Dynamic ports

$sparkBlockManagerPort = get-available-port
$sparkBroadcastPort = get-available-port
$parkDriverPort = get-available-port
$sparkExecutorPort = get-available-port
$sparkFileServerPort = get-available-port
$sparkReplClassServerPort = get-available-port

# Store Local properties

$inputArguments = @()
$inputArguments += ("-key", "SPARK_BLOCK_MANAGER_PORT")
$inputArguments += ("-value", $sparkBlockManagerPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_BROADCAST_PORT")
$inputArguments += ("-value", $sparkBroadcastPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_DRIVER_PORT")
$inputArguments += ("-value", $parkDriverPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_EXECUTOR_PORT")
$inputArguments += ("-value", $sparkExecutorPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_FILE_SERVER_PORT")
$inputArguments += ("-value", $sparkFileServerPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_REPL_CLASS_SERVER_PORT")
$inputArguments += ("-value", $sparkReplClassServerPort)

run-with-retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }