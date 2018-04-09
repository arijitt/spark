@ECHO OFF

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0\SetWorkerPorts.ps1'" %*