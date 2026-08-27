@echo off
echo ===============================
echo  Resetting Quick Access Cache...
echo ===============================

:: Kill Explorer so files unlock
taskkill /f /im explorer.exe

:: Delete cache files
del /f /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*"
del /f /q "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*"

:: Restart Explorer
start explorer.exe

echo.
echo Quick Access has been reset.
echo Try pinning folders again.
echo ===============================
pause
