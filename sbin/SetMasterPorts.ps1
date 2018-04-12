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

#$sparkMasterPort = Get-Available-Port
#$sparkMasterWebPort = Get-Available-Port
#$sparkHistoryWebPort = Get-Available-Port
#$livyServerPort = Get-Available-Port

# Store Local properties

$containerScriptPath = "$PSScriptRoot\PutContainerProperty.ps1"

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_PORT")
$inputArguments += ("-value", $sparkMasterPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_WEBUI_PORT")
$inputArguments += ("-value", $sparkMasterWebPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_HISTORY_WEBUI_PORT")
$inputArguments += ("-value", $sparkHistoryWebPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "LIVY_SERVER_PORT")
$inputArguments += ("-value", $livyServerPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

# Store Global properties

$userScriptPath = "$PSScriptRoot\PutGlobalProperty.ps1"
$hostAddress = Get-Host-IPV4-Address

if ($hostAddress -eq $null) { $hostAddress = $env:COMPUTERNAME }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_URL")
$inputArguments += ("-value", "spark://$hostAddress`:$sparkMasterPort")

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$userScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_MASTER_WEBUI_URL")
$inputArguments += ("-value", "http://$hostAddress`:$sparkMasterWebPort")

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$userScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_HISTORY_WEBUI_URL")
$inputArguments += ("-value", "http://$hostAddress`:$sparkHistoryWebPort")

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$userScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "LIVY_SERVER_URL")
$inputArguments += ("-value", "http://$hostAddress`:$livyServerPort")

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$userScriptPath`" $inputArguments" }

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

$sparkBlockManagerPort = Get-Available-Port
$sparkBroadcastPort = Get-Available-Port
$parkDriverPort = Get-Available-Port
$sparkExecutorPort = Get-Available-Port
$sparkFileServerPort = Get-Available-Port
$sparkReplClassServerPort = Get-Available-Port

# Store Local properties

$inputArguments = @()
$inputArguments += ("-key", "SPARK_BLOCK_MANAGER_PORT")
$inputArguments += ("-value", $sparkBlockManagerPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_BROADCAST_PORT")
$inputArguments += ("-value", $sparkBroadcastPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_DRIVER_PORT")
$inputArguments += ("-value", $parkDriverPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_EXECUTOR_PORT")
$inputArguments += ("-value", $sparkExecutorPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_FILE_SERVER_PORT")
$inputArguments += ("-value", $sparkFileServerPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }

$inputArguments = @()
$inputArguments += ("-key", "SPARK_REPL_CLASS_SERVER_PORT")
$inputArguments += ("-value", $sparkReplClassServerPort)

Run-With-Retry -command "Invoke-Expression" -arguments @{ Command="& `"$containerScriptPath`" $inputArguments" }