#Requires AutoHotkey v2.0

#!s:: {
    TargetFolder := "C:\Users\brigi\Documents\Jason\Scripts"
    StartupFolder := A_AppData . "\Microsoft\Windows\Start Menu\Programs\Startup"
    
    ; Find newest file
    LatestFile := "", LatestTime := 0
    Loop Files, TargetFolder . "\*.ahk" {
        if (A_LoopFileTimeCreated > LatestTime) {
            LatestTime := A_LoopFileTimeCreated
            LatestFile := A_LoopFileFullPath
        }
    }
    
    if (LatestFile != "") {
        SplitPath(LatestFile, , , , &OutNameNoExt)
        LinkPath := StartupFolder . "\" . OutNameNoExt . ".lnk"
        FileCreateShortcut(LatestFile, LinkPath)
        
    }
}