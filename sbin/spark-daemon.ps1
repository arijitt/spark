#
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

# Runs a Spark command as a daemon.
#
# Environment Variables
#
#   SPARK_CONF_DIR  Alternate configuration directory. Default is ${SPARK_HOME}/conf.
#   SPARK_LOG_DIR   Where log files are stored. ${SPARK_HOME}/logs by default.
#   SPARK_MASTER    host:path where spark code should be rsync'd from
#   SPARK_PID_DIR   The pid files are stored. $USERPROFILE/tmp by default.
#   SPARK_IDENT_STRING   A string representing this instance of spark. $USER by default
#   SPARK_NICENESS The scheduling priority for daemons. Defaults to 0 (not applicable on Windows).
#   SPARK_NO_DAEMONIZE   If set, will run the proposed command in the foreground. It will not output a PID file (not applicable on Windows).
#

. $PSScriptRoot\Utilities.ps1

Function Create-Dir() 
{ 
  $directoryPath = $args[0]
 
  if (-not (Test-Path $directoryPath))
  {
    New-Item -ItemType Directory -Force -Path $directoryPath
  }

  if (-not (Test-Path $directoryPath))
  { 
    throw [System.ApplicationException] "$env:USERNAME does not have permission to create directory $directoryPath."
  }
}

Function Rotate-Spark-Log()
{
  $logFilePath = $args[0]
  $maxFileCount = $args[1]

  if (Test-Path $logFilePath) 
  {
    while ($maxFileCount -gt 1)
    {
      $previousFileIndex = $maxFileCount - 1

      if (Test-Path "$logFilePath.$previousFileIndex") { Move-Item "$logFilePath.$previousFileIndex" "$logFilePath.$maxFileCount" -Force }

      $maxFileCount = $previousFileIndex
    }
    
    Move-Item $logFilePath "$logFilePath.$maxFileCount" -Force
  }
}

Function Execute-Command()
{
  $commandInstance = $args[0]
  $commandScript = $args[1]
  $commandPath = $args[2]
  $commandArguments = $args[3]

  if (-not (Test-Path env:SPARK_PID_DIR)) { $SPARK_PID_DIR = "$env:USERPROFILE\tmp" }
  else { $SPARK_PID_DIR = $env:SPARK_PID_DIR }

  if (-not (Test-Path env:SPARK_IDENT_STRING)) { $SPARK_IDENT_STRING = $commandPath }
  else { $SPARK_IDENT_STRING = $env:SPARK_IDENT_STRING }

  if (-not (Test-Path env:SPARK_LOG_DIR)) { $SPARK_LOG_DIR = "$SPARK_HOME\logs" }
  else { $SPARK_LOG_DIR = $env:SPARK_LOG_DIR }

  if ($commandInstance -eq "*") { $commandIdentity = $SPARK_IDENT_STRING + "-" + $PID }
  else { $commandIdentity = $SPARK_IDENT_STRING + "-" + $commandInstance }

  #Check if process is already running if command instance is not wildcard

  if ($commandInstance -ne "*") 
  {
    $commandPidFilePath = "$SPARK_PID_DIR\spark-$commandIdentity-server.pid"

    if (Test-Path $commandPidFilePath) 
    { 
      $commandPid = Get-Content $commandPidFilePath

      if ((Get-Process -Id $commandPid -ErrorAction SilentlyContinue) -ne $Null) 
      { 
        throw [System.ApplicationException] "Command is already running with process Id $commandPid. Stop the command first."
      } 
    }
  }

  Create-Dir $SPARK_PID_DIR
  Create-Dir $SPARK_LOG_DIR

  $commandLogFilePath = "$SPARK_LOG_DIR\spark-$commandIdentity-server.out"
  $commandErrorFilePath = "$SPARK_LOG_DIR\spark-$commandIdentity-server.err"

  if (-not (Test-Path env:SPARK_MAX_LOG_FILES)) { $SPARK_MAX_LOG_FILES = 5 }
  else { $SPARK_MAX_LOG_FILES = [math]::Max($env:SPARK_MAX_LOG_FILES,  5) }

  Rotate-Spark-Log $commandLogFilePath $SPARK_MAX_LOG_FILES
  Rotate-Spark-Log $commandErrorFilePath $SPARK_MAX_LOG_FILES

  #$commandProcess = Start-Process $commandScript -ArgumentList "$commandPath $commandArguments" -RedirectStandardOutput $commandLogFilePath -RedirectStandardError $commandErrorFilePath -PassThru

  $commandProcess = Run-With-Retry -command 'Start-Process' -argument @{ FilePath=$commandScript; ArgumentList="$commandPath $commandArguments"; RedirectStandardOutput=$commandLogFilePath; RedirectStandardError=$commandErrorFilePath; PassThru=$true }

  $commandPid = $commandProcess.Id

  Write-Host "Command started with process Id $commandPid."

  #Wait 5 seconds for command to completely start

  Start-Sleep -s 5
  
  #Write out the process Id of the command process
  
  if ($commandInstance -eq "*") { $commandIdentity = $SPARK_IDENT_STRING + "-" + $commandPid }
  else { $commandIdentity = $SPARK_IDENT_STRING + "-" + $commandInstance }

  $commandPidFilePath = "$SPARK_PID_DIR\spark-$commandIdentity-server.pid"

  if ((Get-Process -Id $commandPid -ErrorAction SilentlyContinue) -ne $Null)
  {
    Set-Content -Path $commandPidFilePath -Value $commandPid

    Write-Host "Command process Id $commandPid recorded at $commandPidFilePath."
  }
  else { throw [System.ApplicationException] "Failed to start command: $commandScript $commandPath $commandArguments." }
}

Function Stop-Command()
{
  $commandInstance = $args[0]
  $commandPath = $args[1]

  if (-not (Test-Path env:SPARK_PID_DIR)) { $SPARK_PID_DIR = "$env:USERPROFILE\tmp" }
  else { $SPARK_PID_DIR = $env:SPARK_PID_DIR }

  if (-not (Test-Path env:SPARK_IDENT_STRING)) { $SPARK_IDENT_STRING = $commandPath }
  else { $SPARK_IDENT_STRING = $env:SPARK_IDENT_STRING }

  $commandIdentity = $SPARK_IDENT_STRING + "-" + $commandInstance
  $commandPidFileName = "spark-$commandIdentity-server.pid"

  foreach ($commandPidFile in (Get-ChildItem -Path $SPARK_PID_DIR -Filter $commandPidFileName))
  {
    $commandPidFilePath = "$SPARK_PID_DIR\$commandPidFile"

    $commandPid = Get-Content $commandPidFilePath

    #Stop-Process does not kill the entire process tree.

    Start-Process TASKKILL.exe -ArgumentList  "/PID $commandPid /T /F" -NoNewWindow -PassThru

    Remove-Item $commandPidFilePath

  }
}

Function Query-Command-Status()
{
  $commandInstance = $args[0]
  $commandPath = $args[1]

  if (-not (Test-Path env:SPARK_PID_DIR)) { $SPARK_PID_DIR = "$env:USERPROFILE\tmp" }
  else { $SPARK_PID_DIR = $env:SPARK_PID_DIR }

  if (-not (Test-Path env:SPARK_IDENT_STRING)) { $SPARK_IDENT_STRING = $commandPath }
  else { $SPARK_IDENT_STRING = $env:SPARK_IDENT_STRING }

  $commandIdentity = $SPARK_IDENT_STRING + "-" + $commandInstance
  $commandPidFileName = "spark-$commandIdentity-server.pid"

  $pidFound = $false

  foreach ($commandPidFile in (Get-ChildItem -Path $SPARK_PID_DIR -Filter $commandPidFileName))
  { 
    $commandPidFilePath = "$SPARK_PID_DIR\$commandPidFile"

    $commandPid = Get-Content $commandPidFilePath

    $pidFound = $true

    if ((Get-Process -Id $commandPid -ErrorAction SilentlyContinue) -ne $Null)
    {
      Write-Host "Command is running with process Id $commandPid."
    }
    else
    {
      Write-Host "Command is not running but was started with process Id $commandPid."
    }
  }
  
  if (!$pidFound)
  {
    Write-Host "Command is not running."
  }
}

Function Run-Command()
{
  $commandMode = $args[0]
  $commandInstance = $args[1]
  $commandPath = $args[2]
  $commandArguments = $args[3]

  #Preset SPARK_HOME but Will attempt to set SPARK_HOME if not set but this may not be visible to the command which requires it.

  if (-not (Test-Path env:SPARK_HOME)) 
  { 
    $SPARK_HOME=(Get-Item $PSScriptRoot).Parent.FullName
    [Environment]::SetEnvironmentVariable("SPARK_HOME", "$SPARK_HOME", "Process")
  } 
  else { $SPARK_HOME = $env:SPARK_HOME }

  switch ($commandMode)
  {
    "class" { Execute-Command $commandInstance $SPARK_HOME\bin\spark-class.cmd $commandPath $commandArguments }
    "submit" { Execute-Command $commandInstance $SPARK_HOME\bin\spark-submit.cmd $commandPath $commandArguments }
    "status" { Query-Command-Status $commandInstance $commandPath }
    "stop" { Stop-Command $commandInstance $commandPath }
    default  { throw [System.ApplicationException] "Unsupported command mode: $commandMode" }
  }
}

$Scriptusage="Usage: spark-daemon.ps1 [--config <conf-dir>] (start|stop|submit|status) <spark-command> <spark-instance-number> <args...>"

#Spark instance number is not used for now.

if ($args[0].Equals("--config")) 
{ 
  $configDirectoryPath = $args[1]
  $scriptAction = $args[2]
  $sparkCommand = $args[3]
  $sparkInstance = $args[4]

  if ($args.Length -gt 5) { $sparkCommandArguments = $args[5..$($args.Length - 1)] }
  else { $sparkCommandArguments = " " }
}
else 
{
  $scriptAction = $args[0]
  $sparkCommand = $args[1]
  $sparkInstance = $args[2]

  if ($args.Length -gt 3) { $sparkCommandArguments = $args[3..$($args.Length - 1)] }
  else { $sparkCommandArguments = " " }
}

Write-Host "Script action: spark-daemon $scriptAction $sparkCommand $sparkInstance $sparkCommandArguments"

if ($configDirectoryPath)
{
  if (-not (Test-Path $configDirectoryPath))
  {
    throw [System.ApplicationException] "Config directory path does not exist"
  }
  else
  {
    Write-Host "Setting SPARK_CONF_DIR to $configDirectoryPath"

    [Environment]::SetEnvironmentVariable("SPARK_CONF_DIR", "$configDirectoryPath", "Process")
  }
}
  
if (Test-Path "$SPARK_HOME\sbin\spark-config.cmd" -PathType Leaf) { Invoke-Item "$SPARK_HOME\sbin\spark-config.cmd" }
if (Test-Path "$SPARK_HOME\bin\load-spark-env.cmd" -PathType Leaf) { Invoke-Item "$SPARK_HOME\bin\load-spark-env.cmd"}

switch ($scriptAction)
{
  "start" { Run-Command "class" $sparkInstance $sparkCommand $sparkCommandArguments }
  "status" { Run-Command "status" $sparkInstance $sparkCommand }
  "stop" { Run-Command "stop" $sparkInstance $sparkCommand }
  "submit" { Run-Command "submit" $sparkInstance $sparkCommand $sparkCommandArguments }
  default { throw [System.ApplicationException] "Unsupported script action: $scriptAction" }
}
