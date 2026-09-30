#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off  ; Mutes strict warnings globally for this utility

#!e:: {
    loop {
        selectedFolder := FileSelectFolder("C:\Users\brigi", , "Emergency File Browser (Esc to Exit)")
        if (selectedFolder = "")
            break
        
        Run('cmd.exe /c start "" "' selectedFolder '"')
    }
}