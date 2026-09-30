^#m::
for window in ComObjCreate("Shell.Application").Windows
{
    if (window.hwnd = WinActive("A"))
    {
        path := window.document.folder.self.path
        break
    }
}

Run powershell -NoProfile -Command "Get-ChildItem '%path%' -Recurse -Filter *.mov, *.gif, *.m4a, *.mp4, *.mp3, *.txt, *.md, *.ico | Move-Item -Destination '%path%'"
return