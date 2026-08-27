; Press Win + Alt + P to grab the newest installed folder and add it to the path
#!p::
Run *RunAs powershell.exe -NoProfile -Command "Add-LastInstalledToPath", , Hide
MsgBox, Sent request to add the most recently modified folder in Program Files to your PATH!
return