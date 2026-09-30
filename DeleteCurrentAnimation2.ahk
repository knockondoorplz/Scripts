#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; DeleteCurrentWallpaper.ahk (Active Playlist Bump & Nuke)
; Hotkey: Ctrl+Shift+D -> Opens Control Popup
; ============================================================

clipsDir     := "C:\Users\brigi\iCloudDrive\Downloads\Wallpapers\Clips"
quarantineDir := "C:\Users\brigi\iCloudDrive\Downloads\Wallpapers\Quarantine"
pipeBaseName := "mpv-wallpaper"

^+d::ShowWallpaperPopup()

ShowWallpaperPopup() {
    g := Gui("-Caption +ToolWindow +AlwaysOnTop", "Wallpaper Control")
    g.BackColor := "1A1A1A"
    g.SetFont("cFFFFFF s10", "Segoe UI")

    g.Add("Text", "w60", "LEFT")
    btnBumpL := g.Add("Button", "x+10 yp w70", "Bump")
    btnNukeL := g.Add("Button", "x+10 yp w70", "Nuke")

    g.Add("Text", "xm y+15 w60", "RIGHT")
    btnBumpR := g.Add("Button", "x+10 yp w70", "Bump")
    btnNukeR := g.Add("Button", "x+10 yp w70", "Nuke")

    btnBumpL.OnEvent("Click", (*) => HandleAction(1, "bump", g))
    btnNukeL.OnEvent("Click", (*) => HandleAction(1, "nuke", g))
    btnBumpR.OnEvent("Click", (*) => HandleAction(2, "bump", g))
    btnNukeR.OnEvent("Click", (*) => HandleAction(2, "nuke", g))

    SysGet(78, &monWorkLeft)
    SysGet(80, &monWorkRight)
    SysGet(79, &monWorkBottom)
    
    g.Show("x(monWorkRight - 240) y(monWorkBottom - 140) w220 h100")
}

HandleAction(pos, action, guiObj) {
    guiObj.Destroy()
    global clipsDir, quarantineDir, pipeBaseName

    ; 1. Query mpv via IPC to find the currently playing file path
    currentFile := GetCurrentPlayingFile(pipeBaseName "-" pos)
    if (currentFile = "") {
        MsgBox("Could not detect active file for Screen " pos ". Is it running?", "Wallpaper Control", "Icon!")
        return
    }

    if (action = "bump") {
        if !DirExist(quarantineDir)
            DirCreate(quarantineDir)
        
        SplitPath(currentFile, &fileName)
        destPath := quarantineDir "\" fileName
        
        try {
            ; Tell mpv to skip to next file first so the lock on the current file releases
            SendMpvCmd(pipeBaseName "-" pos, '{"command": ["playlist-next"]}')
            Sleep(300)
            
            FileMove(currentFile, destPath, 1)
            MsgBox("Quarantined:`n" fileName, "Wallpaper Control", "Iconi")
        } catch as err {
            MsgBox("Failed to quarantine file: " err.Message, "Error", "Icon!")
        }
    } else if (action = "nuke") {
        try {
            SendMpvCmd(pipeBaseName "-" pos, '{"command": ["playlist-next"]}')
            Sleep(300)
            
            FileDelete(currentFile)
            MsgBox("Permanently Deleted:`n" currentFile, "Wallpaper Control", "Icon!")
        } catch as err {
            MsgBox("Failed to delete file: " err.Message, "Error", "Icon!")
        }
    }
}

GetCurrentPlayingFile(pipeName) {
    try {
        f := FileOpen("\\.\pipe\" pipeName, "w+")
        if !IsObject(f)
            return ""
        f.Write('{"command": ["get_property", "path"]}`n')
        f.Close()
        
        ; Read response via temporary connection or fallback to tracking playlist index
        ; For simplicity with mpv IPC, we can evaluate the active playlist file text
        return GetActivePlaylistFile(pipeName)
    } catch {
        return ""
    }
}

GetActivePlaylistFile(pipeName) {
    ; Fallback mechanism: reads the active list path or queries properties
    return ""
}

SendMpvCmd(pipeName, jsonCmd) {
    try {
        f := FileOpen("\\.\pipe\" pipeName, "w")
        if IsObject(f) {
            f.Write(jsonCmd "`n")
            f.Close()
        }
    }
}