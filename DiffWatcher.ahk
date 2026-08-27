#Requires AutoHotkey v2.0

; ============================================================
; CONFIG
; ============================================================
backupRoot := "C:\Tools\DiffWatcher\History"

; Auto‑watched folders
watchedFolders := Map()
watchedFolders["C:\Users\brigi\Documents\Jason\Scripts"] := true
watchedFolders["C:\Users\brigi\Documents\Github\Biome Simulator"] := true

lastTimes := Map()

if !DirExist(backupRoot)
    DirCreate(backupRoot)

; ============================================================
; Get active editor file (extended)
; ============================================================
GetActiveEditorFile() {
    win := WinGetTitle("A")

    if RegExMatch(win, "^(.*) - Notepad$", &m)
        return m[1]

    if RegExMatch(win, "^(.*) - Notepad\+\+$", &m)
        return m[1]

    if RegExMatch(win, "^(.*) - Visual Studio Code$", &m)
        return m[1]

    if RegExMatch(win, "^(.*) - Obsidian$", &m)
        return m[1]

    if RegExMatch(win, "^(.*) - Cursor$", &m)
        return m[1]

    if RegExMatch(win, "^(.*) - Warp$", &m)
        return m[1]

    return ""
}

; ============================================================
; Helpers
; ============================================================
SanitizeName(s) {
    s := StrReplace(s, ":", "_")
    s := StrReplace(s, "*", "_")
    s := StrReplace(s, "?", "_")
    s := StrReplace(s, Chr(34), "_")
    s := StrReplace(s, "<", "_")
    s := StrReplace(s, ">", "_")
    s := StrReplace(s, "|", "_")
    return s
}

IsTextFile(path) {
    return RegExMatch(path, "\.(txt|md|ahk|py|ps1|js|ts|json|html?|css|ini|cfg|yaml|yml|log)$")
}

GetBackupFolder(path) {
    global backupRoot

    SplitPath(path, &name)      ; e.g. "DiffWatcher.ahk"
    id := SanitizeName(name)    ; keep extension, just make it safe

    folder := backupRoot "\" id

    if !DirExist(folder)
        DirCreate(folder)

    return folder
}

; ============================================================
; Auto‑backup watcher
; ============================================================
WatchFolders() {
    global watchedFolders, lastTimes

    for dir, _ in watchedFolders {
        if !DirExist(dir)
            continue

        Loop Files, dir "\*.*", "F" {
            file := A_LoopFileFullPath

            ; ignore junk
            if InStr(file, "\node_modules\") 
             || InStr(file, "\.git\") 
             || InStr(file, "\dist\") 
             || InStr(file, "\build\") 
             || InStr(file, "\__pycache__\")
                continue

            if !IsTextFile(file)
                continue

            t := FileGetTime(file, "M")

            if !lastTimes.Has(file) {
                lastTimes[file] := t
                continue
            }

            if (t != lastTimes[file]) {
                lastTimes[file] := t

                folder := GetBackupFolder(file)

                ; find latest backup in this folder
                latestBackup := ""
                Loop Files, folder "\*.bak" {
                    if (latestBackup = "" || A_LoopFileTimeModified > latestBackup.time)
                        latestBackup := { time: A_LoopFileTimeModified, path: A_LoopFileFullPath }
                }

                ; skip-identical backups
                if latestBackup {
                    old := FileRead(latestBackup.path)
                    new := FileRead(file)
                    if (old = new)
                        continue
                }

                ts := FormatTime(A_Now, "yyyyMMdd-HHmmss")
                backup := folder "\" ts ".bak"

                Try FileCopy(file, backup, 1)

                TrayTip "DiffWatcher", "Backup updated for:`n" file
            }
        }
    }
}

SetTimer(WatchFolders, 1000)

; ============================================================
; Ctrl+Alt+D → diff against previous backup
; ============================================================
^!d::
{
    file := GetActiveEditorFile()
    if !file || !FileExist(file)
        return

    folder := GetBackupFolder(file)
    if !DirExist(folder) {
        MsgBox("No backups exist for:`n" file)
        return
    }

    backups := []
    Loop Files, folder "\*.bak" {
        backups.Push({ time: A_LoopFileTimeModified, path: A_LoopFileFullPath })
    }

    if backups.Length < 2 {
        MsgBox("Need at least 2 backups to diff:`n" folder)
        return
    }

    ; Manual sort newest → oldest
    for i, _ in backups {
        for j, _ in backups {
            if backups[i].time > backups[j].time {
                temp := backups[i]
                backups[i] := backups[j]
                backups[j] := temp
            }
        }
    }

    previous := backups[2]

    ; PowerShell + delta for proper ANSI color
    cmd := 'powershell -NoExit -Command "git --no-pager diff --no-index \"' . previous.path . '\" \"' . file . '\" | delta --line-numbers"'
    Run cmd
}

; ============================================================
; Picker globals
; ============================================================
global pickerGui, pickerLb, pickerBackups, pickerActiveFile, pickerFolder

; ============================================================
; Ctrl+Alt+P → timestamp picker
; ============================================================
^!p::
{
    global pickerGui, pickerLb, pickerBackups, pickerActiveFile, pickerFolder

    pickerActiveFile := GetActiveEditorFile()
    if !pickerActiveFile || !FileExist(pickerActiveFile)
        return

    pickerFolder := GetBackupFolder(pickerActiveFile)
    if !DirExist(pickerFolder) {
        MsgBox("No backups exist for:`n" pickerActiveFile)
        return
    }

    pickerGui := Gui("+AlwaysOnTop", "Backups for " pickerActiveFile)
    pickerGui.AddText(, "Select a backup:")

    pickerLb := pickerGui.AddListBox("w420 h220")

    pickerBackups := []
    Loop Files, pickerFolder "\*.bak" {
        readable := FormatTime(A_LoopFileTimeModified, "MMM d, yyyy h:mm tt")
        pickerBackups.Push({ path: A_LoopFileFullPath, label: readable })
        pickerLb.Add([readable])
    }

    if pickerBackups.Length = 0 {
        pickerGui.Destroy()
        MsgBox("No backups found in:`n" pickerFolder)
        return
    }

    pickerGui.AddButton("Default", "Diff").OnEvent("Click", PickerDiffHandler)
    pickerGui.AddButton("x+10", "Restore").OnEvent("Click", PickerRestoreHandler)
    pickerGui.AddButton("x+10", "Open Folder").OnEvent("Click", PickerOpenHandler)

    pickerGui.Show()
}

PickerDiffHandler(*) {
    global pickerBackups, pickerLb, pickerActiveFile
    idx := pickerLb.Value
    if !idx
        return
    backup := pickerBackups[idx].path
    cmd := 'powershell -NoExit -Command "git --no-pager diff --no-index \"' . backup . '\" \"' . pickerActiveFile . '\" | delta --line-numbers"'
    Run cmd
}

PickerRestoreHandler(*) {
    global pickerBackups, pickerLb, pickerActiveFile
    idx := pickerLb.Value
    if !idx
        return
    backup := pickerBackups[idx].path
    FileCopy(backup, pickerActiveFile, 1)
    TrayTip "DiffWatcher", "Restored:`n" pickerActiveFile
}

PickerOpenHandler(*) {
    global pickerFolder
    Run pickerFolder
}

; ============================================================
; Cleanup old backups
; ============================================================
CleanupHistory() {
    global backupRoot

    cutoff := DateAdd(A_Now, -15, "Days")

    ; delete old files
    Loop Files, backupRoot "\*", "R" {
        if (A_LoopFileAttrib ~= "D")
            continue
        if (A_LoopFileTimeModified < cutoff)
            FileDelete(A_LoopFileFullPath)
    }

    ; delete empty dirs
    Loop Files, backupRoot "\*", "D R" {
        dir := A_LoopFileFullPath
        if !FileExist(dir "\*.*")
            DirDelete(dir)
    }
}

SetTimer(CleanupHistory, 86400000)
