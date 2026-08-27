#Requires AutoHotkey v2

; ============================================================
; DiffWatcher — Backup + Diff the active editor file
; Win+Alt+B → Backup
; Win+Alt+D → Diff using git diff (with delta if installed)
; ============================================================

#!b::  ; Backup
{
    file := GetActiveEditorFile()
    if !file
        return

    backup := file ".bak"
    FileCopy(file, backup, 1)
    SoundBeep(750, 150)
}

#!d::  ; Diff
{
    file := GetActiveEditorFile()
    if !file
        return

    backup := file ".bak"
    if !FileExist(backup) {
        MsgBox("No backup exists for:`n" file)
        return
    }

    ; Use git diff --no-index
    cmd := 'cmd /k git diff --no-index --color "' . backup . '" "' . file . '"'

    ; If delta exists, use it
    if FileExist("C:\Program Files\delta\delta.exe")
        cmd := 'cmd /k git diff --no-index "' . backup . '" "' . file . '" | delta'

    Run cmd
}

; ============================================================
; Detect active editor file
; ============================================================
GetActiveEditorFile() {
    win := WinGetTitle("A")

    ; Notepad
    if RegExMatch(win, "^(.*) - Notepad$", &m)
        return m[1]

    ; Notepad++
    if RegExMatch(win, "^(.*) - Notepad\+\+$", &m)
        return m[1]

    ; VSCode
    if RegExMatch(win, "^(.*) - Visual Studio Code$", &m)
        return m[1]

    return ""
}
