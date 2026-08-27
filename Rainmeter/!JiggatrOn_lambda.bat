@echo off
:: Force unload both layouts first
start "" "C:\Program Files\Rainmeter\Rainmeter.exe" !UnloadLayout "!Jiggara!ntaskbar!"
start "" "C:\Program Files\Rainmeter\Rainmeter.exe" !UnloadLayout "!Jiggatr0n_lite!"
timeout /t 1 >nul

:: Check which one is currently active and load the other
:: Since batch can't directly check Rainmeter state, we'll toggle by a simple logic:
:: If Lite exists, load Taskbar; if Taskbar exists, load Lite
:: For now, just pick one—you can run a second batch to flip the other way

start "" "C:\Program Files\Rainmeter\Rainmeter.exe" !LoadLayout "!JiggatrOn_lambda"
start "" "C:\Program Files\Rainmeter\Rainmeter.exe" !RefreshAll
