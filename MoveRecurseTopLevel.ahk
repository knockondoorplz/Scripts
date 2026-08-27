^#m::
for window in ComObjCreate("Shell.Application").Windows
{
    if (window.hwnd = WinActive("A"))
    {
        path := window.document.folder.self.path
        break
    }
}

Run powershell -NoProfile -Command "Get-ChildItem '%path%' -Recurse -Filter *.md | Move-Item -Destination '%path%'"
return