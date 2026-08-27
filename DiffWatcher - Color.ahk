#Requires AutoHotkey v2

backupRoot := "C:\Tools\DiffWatcher\History"
lastTimes := Map()
watchedFolders := Map()

if !DirExist(backupRoot)
    DirCreate(backupRoot)

; ============================================================
; Get active editor file
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

; ============================================================
; Add active file's folder to watch list
; ============================================================
AddActiveFolder() {
    global watchedFolders

    activeFile := GetActiveEditorFile()
    if !activeFile
        return

    SplitPath(activeFile, , &dir)
    if dir && !watchedFolders.Has(dir)
        watchedFolders[dir] := true
}

; ============================================================
; Manual backup hotkey
; ============================================================
^!b::
{
    global backupRoot

    activeFile := GetActiveEditorFile()
    if !activeFile || !FileExist(activeFile)
        return

    id := PathToId(activeFile)
    folder := backupRoot "\" id
    DirCreate(folder)

    ts := FormatTime(A_Now, "yyyyMMdd-HHmmss")
    backup := folder "\" ts ".bak"

    Try FileCopy(activeFile, backup, 1)
    Catch {
        Sleep 50
        Try FileCopy(activeFile, backup, 1)
        Catch {
            MsgBox("Backup failed for:`n" activeFile)
            return
        }
    }

    TrayTip "DiffWatcher", "Backup updated for:`n" activeFile
}

; ============================================================
; Ctrl+Alt+W → watch active folder
; ============================================================
^!w:: AddActiveFolder()

; ============================================================
; Folder watcher
; ============================================================
WatchFolders() {
    global watchedFolders, lastTimes, backupRoot

    for dir, _ in watchedFolders {
        if !DirExist(dir)
            continue

        Loop Files, dir "\*.*", "F" {
            activeFile := A_LoopFileFullPath

            if InStr(activeFile, "\node_modules\") || InStr(activeFile, "\.git\") || InStr(activeFile, "\dist\") || InStr(activeFile, "\build\")
                continue

            if !IsTextFile(activeFile)
                continue

            t := FileGetTime(activeFile, "M")

            if !lastTimes.Has(activeFile) {
                lastTimes[activeFile] := t
                continue
            }

            if (t != lastTimes[activeFile]) {
                lastTimes[activeFile] := t

                id := PathToId(activeFile)
                folder := backupRoot "\" id
                DirCreate(folder)

                ts := FormatTime(A_Now, "yyyyMMdd-HHmmss")
                backup := folder "\" ts ".bak"

                Try FileCopy(activeFile, backup, 1)
                Catch {
                    Sleep 50
                    Try FileCopy(activeFile, backup, 1)
                }

                TrayTip "DiffWatcher", "Backup updated for:`n" activeFile
            }
        }
    }
}

SetTimer(WatchFolders, 1000)

; ============================================================
; Ctrl+Alt+D → diff latest backup
; ============================================================
^!d::
{
    global backupRoot

    activeFile := GetActiveEditorFile()
    if !activeFile || !FileExist(activeFile)
        return

    id := PathToId(activeFile)
    folder := backupRoot "\" id
    if !DirExist(folder) {
        MsgBox("No backups exist for:`n" activeFile)
        return
    }

    latest := ""
    Loop Files, folder "\*.bak" {
        if (latest = "" || A_LoopFileTimeModified > latest.time)
            latest := { time: A_LoopFileTimeModified, path: A_LoopFileFullPath }
    }

    if !latest {
        MsgBox("No backups found in:`n" folder)
        return
    }

    cmd := 'cmd /k git --no-pager diff --no-index "' . latest.path . '" "' . activeFile . '" | delta --line-numbers --color-only'
    Run cmd
}

; ============================================================
; Ctrl+Alt+P → timestamp picker (enhanced)
; ============================================================
^!p::
{
    global lb := "", backups := "", activeFile := "", folder := "", backupRoot

    activeFile := GetActiveEditorFile()
    if !activeFile || !FileExist(activeFile)
        return

    id := PathToId(activeFile)
    folder := backupRoot "\" id
    if !DirExist(folder) {
        MsgBox("No backups exist for:`n" activeFile)
        return
    }

    gui := Gui("+AlwaysOnTop", "Backups for " activeFile)
    gui.AddText(, "Select a backup:")

    lb := gui.AddListBox("w420 h220")

    backups := []
    Loop Files, folder "\*.bak" {
        readable := FormatTime(A_LoopFileTimeModified, "MMM d, yyyy h:mm tt")
        backups.Push({ path: A_LoopFileFullPath, label: readable })
        lb.Add(readable)
    }

    if backups.Length = 0 {
        gui.Destroy()
        MsgBox("No backups found in:`n" folder)
        return
    }

    gui.AddButton("Default", "Diff").OnEvent("Click", DiffHandler)
    gui.AddButton("x+10", "Restore").OnEvent("Click", RestoreHandler)
    gui.AddButton("x+10", "Open Folder").OnEvent("Click", OpenHandler)

    gui.Show()

    DiffHandler(*) {
        global backups, lb, activeFile
        idx := lb.Value
        if !idx
            return
        backup := backups[idx].path
        cmd := 'cmd /k git --no-pager diff --no-index "' . backup . '" "' . activeFile . '" | delta --line-numbers --color-only'
        Run cmd
    }

    RestoreHandler(*) {
        global backups, lb, activeFile
        idx := lb.Value
        if !idx
            return
        backup := backups[idx].path
        FileCopy(backup, activeFile, 1)
        TrayTip "DiffWatcher", "Restored:`n" activeFile
    }

    OpenHandler(*) {
        global folder
        Run folder
    }
}

; ============================================================
; Cleanup old backups
; ============================================================
CleanupHistory() {
    global backupRoot

    cutoff := DateAdd(A_Now, -15, "Days")

    Loop Files, backupRoot "\*", "R" {
        if (A_LoopFileAttrib ~= "D")
            continue
        if (A_LoopFileTimeModified < cutoff)
            FileDelete(A_LoopFileFullPath)
    }

    Loop Files, backupRoot "\*", "D R" {
        dir := A_LoopFileFullPath
        if !FileExist(dir "\*.*")
            DirDelete(dir)
    }
}

SetTimer(CleanupHistory, 86400000)

; ============================================================
; Helpers
; ============================================================
IsTextFile(path) {
    return RegExMatch(path, "\.(txt|md|ahk|py|ps1|js|ts|json|html?|css|ini|cfg|yaml|yml|log)$")
}

PathToId(path) {
    id := path
    id := StrReplace(id, ":", "_")
    id := StrReplace(id, "\", "_")
    id := StrReplace(id, "/", "_")
    id := StrReplace(id, "*", "_")
    id := StrReplace(id, "?", "_")
    id := StrReplace(id, Chr(34), "_")
    id := StrReplace(id, "<", "_")
    id := StrReplace(id, ">", "_")
    id := StrReplace(id, "|", "_")
    return id
}
