@ECHO OFF

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0\spark-daemon.ps1'" "start" "org.apache.spark.deploy.master.Master" %USERNAME% %*

PowerShell -NoProfile -ExecutionPolicy Bypass %~dp0\PutUserProperty.ps1 -key "MASTER_HOST" -value %NM_HOST%