; Start File Explorer
^#!r::
Run, taskkill /f /im explorer.exe,, Hide
Sleep, 300
Run, explorer.exe
return
