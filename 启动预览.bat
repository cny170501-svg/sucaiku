@echo off
start "" http://127.0.0.1:8341/
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve.ps1"
