; Start File Explorer
^#!r::
Run, taskkill /f /im explorer.exe,, Hide
Sleep, 300
Run, explorer.exe
return

; Win + Alt + R to instantly reset File Explorer
#!r::
Run, taskkill /f /im explorer.exe,, Hide
Sleep, 400
Run, explorer.exe
return
