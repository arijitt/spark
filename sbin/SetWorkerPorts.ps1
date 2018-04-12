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

. $PSScriptRoot\Utilities.ps1

#Spark application ports

#spark.blockManager.port    (random)
#spark.broadcast.port       (random)
#spark.driver.port          (random)
#spark.executor.port        (random)
#spark.fileserver.port      (random)
#spark.replClassServer.port (random)

# Test ports

#$sparkBlockManagerPort = 38000
#$sparkBroadcastPort = 38001
#$parkDriverPort = 38002
#$sparkExecutorPort = 38003
#$sparkFileServerPort = 38004
#$sparkReplClassServerPort = 38005

# Dynamic ports

$sparkBlockManagerPort = Get-Available-Port
$sparkBroadcastPort = Get-Available-Port
$parkDriverPort = Get-Available-Port
$sparkExecutorPort = Get-Available-Port
$sparkFileServerPort = Get-Available-Port
$sparkReplClassServerPort = Get-Available-Port

# Store Local properties

$containerScriptPath = "$PSScriptRoot\PutContainerProperty.ps1"

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
