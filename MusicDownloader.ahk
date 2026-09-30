#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Hotkey: Win+Alt+Y
#Requires AutoHotkey v1.1
#SingleInstance Force

#!y::
{
    base := "C:\Users\brigi\Music\μюζικ"
    url := Clipboard

    if (url = "")
    {
        MsgBox, 48, Error, Clipboard is empty. Copy a YouTube or YouTube Music URL first.
        return
    }

    ; Clean up potential whitespace or trailing newlines from clipboard
    url := Trim(url, "`r`n `t")

    ; Target output template matching your working command-line syntax
    outtmpl := base . "/%(artist|uploader)s - %(album|playlist_title|uploader)s/%(title)s.%(ext)s"

    ; Construct command safely utilizing explicit double quotes for the path
    cmd := "yt-dlp -x --audio-format mp3 --embed-metadata -o """ . outtmpl . """ """ . url . """"

    ; Debug line to verify exact string structure if needed
    ; FileAppend, %cmd%`n, %A_Temp%\debug_cmd.txt

    ; Execute via PowerShell capturing stdout/stderr cleanly
    RunWait, powershell -Command "& { %cmd% }" > "%A_Temp%\yt_out.txt",, Hide

    FileRead, yout, %A_Temp%\yt_out.txt

    ; Universal destination match
    RegExMatch(yout, "i)Destination:\s*(.*)$", m)

    if (m1 != "")
    {
        SplitPath, m1, , outfolder
        MsgBox, 64, Done, Playlist downloaded to:`n%outfolder%
    }
    else
    {
        MsgBox, 64, Done, Download completed, but output folder could not be detected. Check destination directory.
    }
}
return

; Hotkey: Ctrl+Alt+V
^!v::
    base := "H:\Audiolibros"
    url := Clipboard

    if (url = "")
    {
        MsgBox, 48, Error, Clipboard is empty. Copy a URL first.
        return
    }

    FormatTime, timestamp,, yyyy-MM-dd_HH-mm-ss
    outdir := base . "\DL_" . timestamp

    FileCreateDir, %outdir%

    ; Note the added -o before the path:
    cmd := "yt-dlp -o """ . outdir . "\%(playlist_index)s - %(title)s.%(ext)s"" """ . url . """"

    ; ",, Hide": Removed 'Hide' temporarily so you can see if yt-dlp prints an error
    RunWait, %ComSpec% /k %cmd%

    MsgBox, 64, Done, Playlist downloaded to:`n%outdir%
return