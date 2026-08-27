; Win + Alt + R to instantly reset File Explorer
#!r::
Run, taskkill /f /im explorer.exe,, Hide
Sleep, 400
Run, explorer.exe
return
