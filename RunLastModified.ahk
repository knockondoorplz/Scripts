#Requires AutoHotkey v2.0

#!l:: {
    TargetFolder := "C:\Users\brigi\Documents\Jason\Scripts"
    LatestFile := "", LatestTime := 0
    
    ; This looks for the newest .ahk file in your folder
    Loop Files, TargetFolder "\*.ahk"
    {
        if (A_LoopFileTimeModified > LatestTime) {
            LatestTime := A_LoopFileTimeModified
            LatestFile := A_LoopFileFullPath
        }
    }
    
    ; If we found a file, run it
    if (LatestFile != "") {
        Run(LatestFile)
        SoundBeep(523, 60)
        SoundBeep(659, 60)
    } else {
        MsgBox("No .ahk files found in " TargetFolder)
    }
}