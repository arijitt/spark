@ECHO OFF

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0\spark-daemon.ps1'" "status" "org.apache.spark.deploy.master.Master" %USERNAME%