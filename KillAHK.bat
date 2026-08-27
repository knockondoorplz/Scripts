@echo off
:: Re-run with Admin Privileges
fltmc >nul 2>&1 || (
    powershell Start-Process '%~f0' -Verb RunAs
    exit /b
)

:: Use WMIC to kill every process that has AutoHotkey in the name
:: This is more powerful than taskkill and covers v1 and v2 simultaneously
wmic process where "name like '%%AutoHotkey%%'" delete

exit