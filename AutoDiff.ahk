#Requires AutoHotkey v2

; ============================================================
; AutoDiff — Backup + Diff the active editor file
; Win+Alt+D → Diff using git diff (with delta if installed)
; ============================================================

#!d::  ; Diff
{
    activeFile := GetActiveEditorFile()
    if !activeFile
        return

    backup := activeFile ".bak"
    if !FileExist(backup) {
        MsgBox("No backup exists for:`n" activeFile)
        return
    }

    ; Use git diff --no-index
    cmd := 'cmd /k git --no-pager diff --no-index "' . backup . '" "' . activeFile . '"'

    ; If delta exists, use it (line-by-line, no ANSI)
    if FileExist("C:\Program Files\delta\delta.exe")
        cmd := 'cmd /k git --no-pager diff --no-index "' . backup . '" "' . activeFile . '" | delta --line-numbers --color=never'

    Run cmd
}

; ============================================================
; Detect active editor file
; ============================================================
GetActiveEditorFile() {
    win := WinGetTitle("A")

    if RegExMatch(win, "^(.*) - Notepad$", &m)
        return m[1]

    if RegExMatch(win, "^(.*) - Notepad\+\+$", &m)
        return m[1]

    if RegExMatch(win, "^(.*) - Visual Studio Code$", &m)
        return m[1]

    return ""
}

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