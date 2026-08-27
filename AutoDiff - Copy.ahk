#Requires AutoHotkey v2.0

#!d:: {
    TargetFolder := "C:\Users\brigi\Documents\Jason\Scripts"
    ; 1. Find the newest script
    LatestFile := "", LatestTime := 0
    Loop Files, TargetFolder "\*.ahk" {
        if (A_LoopFileTimeModified > LatestTime) {
            LatestTime := A_LoopFileTimeModified
            LatestFile := A_LoopFileFullPath
        }
    }
    
    ; 2. Define a backup file (e.g., script_backup.ahk)
    BackupFile := LatestFile . ".bak"
    
    ; 3. If a backup exists, run a diff
    if FileExist(BackupFile) {
        ; This opens a command window, shows the diff, and waits for you to close it
        Run('cmd /k fc "' LatestFile '" "' BackupFile '"')
    } else {
        MsgBox("No backup found! Save a backup first.")
    }
}

; Press Win + Alt + B to backup the last modified script
#!b:: {
    TargetFolder := "C:\Users\brigi\Documents\Jason\Scripts"
    LatestFile := "", LatestTime := 0
    Loop Files, TargetFolder "\*.ahk" {
        if (A_LoopFileTimeModified > LatestTime) {
            LatestTime := A_LoopFileTimeModified
            LatestFile := A_LoopFileFullPath
        }
    }
    
    if (LatestFile != "") {
        FileCopy(LatestFile, LatestFile ".bak", 1) ; The '1' overwrites the old backup
        SoundBeep(750, 200) ; A different tone to confirm backup
    }
}