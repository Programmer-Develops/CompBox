@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0report\build_pdf.ps1"
pause
