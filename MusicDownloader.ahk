#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Hotkey: Shift+ALT+P
+!p::
{
    base := "C:\Users\brigi\Music\μюζικ"
    url := Clipboard

    if (url = "")
    {
        MsgBox, 48, Error, Clipboard is empty. Copy a YouTube or YouTube Music URL first.
        return
    }

    FormatTime, timestamp,, yyyy-MM-dd_HH-mm-ss
    outdir := base . "\DL_" . timestamp

    FileCreateDir, %outdir%

    cmd := "yt-dlp -x --audio-format mp3 -o """ . outdir . "\%(playlist_index)s - %(title)s.%(ext)s"" """ . url . """"

    RunWait, %ComSpec% /c %cmd%,, Hide

    MsgBox, 64, Done, Playlist downloaded to:`n%outdir%
}
return

; Hotkey: Shift+Alt+P
+#p::
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