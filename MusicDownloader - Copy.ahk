#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

#!y::
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

     

    ; FIX: Removed %(playlist_index)s - from the filename and added --embed-metadata
        ; Folder: Artist - Album, File: Title.ext
    cmd := "yt-dlp -x --audio-format mp3 --embed-metadata "
        . "-o ""C:\Users\brigi\Music\μюζικ\%(artist)s - %(album)s\%(title)s.%(ext)s"" "
        . """" . url . """"


    RunWait, %ComSpec% /c %cmd%,, Hide

    MsgBox, 64, Done, Playlist downloaded to:`n%outdir%
}
return
