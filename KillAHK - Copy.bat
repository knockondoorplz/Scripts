@echo off
:: This kills ANY process starting with 'AutoHotkey'
taskkill /F /FI "IMAGENAME eq AutoHotkey*" /T
echo Terminated all AutoHotkey processes.
pause