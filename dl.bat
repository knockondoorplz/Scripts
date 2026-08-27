@echo off
setlocal

:: Read URL from clipboard
for /f "usebackq delims=" %%A in (`powershell -command "Get-Clipboard"`) do set URL=%%A

if "%URL%"=="" (
    echo No URL found in clipboard.
    pause
    exit /b
)

:: Base music folder
set BASE=C:\Users\brigi\Music\μюζик

:: Create a timestamped subfolder so each run is separate
for /f "tokens=1-4 delims=/- " %%a in ("%date%") do (
    set YYYY=%%d
    set MM=%%b
    set DD=%%c
)
set HH=%time:~0,2%
set HH=%HH: =0%
set MIN=%time:~3,2%
set SEC=%time:~6,2%

set OUTDIR=%BASE%\DL_%YYYY%-%MM%-%DD%_%HH%-%MIN%-%SEC%

mkdir "%OUTDIR%"

echo Downloading to: %OUTDIR%
echo URL: %URL%

:: FIX: Keeps filenames clean, but embeds the track number into the MP3 metadata tags
yt-dlp -x --audio-format mp3 --embed-metadata -o "%OUTDIR%\%%(title)s.%%(ext)s" "%URL%"

echo Done.
pause