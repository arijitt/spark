@ECHO OFF

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0\spark-daemon.ps1'" "stop" "org.apache.spark.deploy.history.HistoryServer" %USERNAME%