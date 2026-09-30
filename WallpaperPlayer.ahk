#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; WallpaperPlayer.ahk
; Embeds mpv into the desktop's hidden WorkerW layer and plays
; a shuffled playlist of video clips as a live wallpaper.
;
; The normalize watcher runs continuously in the background from
; the moment this script starts, independent of play/pause state -
; so clips are always pre-normalized and ready by the time you
; toggle playback on.
; ============================================================

; ---------------- CONFIG ----------------
mpvPath       := "mpv.exe"                                     ; on PATH now (C:\Tools) - no full path needed
rawDir        := "C:\Users\brigi\Videos\Anim\Raw"
clipsDir      := "C:\Users\brigi\Videos\Anim\Clips"
pipeName      := "mpv-wallpaper"
watcherScript := A_ScriptDir "\WatchAndNormalize.ps1"           ; must sit next to this .ahk file
; -----------------------------------------

mpvPID := 0
watcherPID := 0

; ---------------- TRAY MENU ----------------
A_TrayMenu.Delete()
A_TrayMenu.Add("Toggle Wallpaper Playback", (*) => TogglePlayback())
A_TrayMenu.Add()
A_TrayMenu.Add("Next Clip", (*) => MpvCmd('{"command": ["playlist-next"]}'))
A_TrayMenu.Add("Previous Clip", (*) => MpvCmd('{"command": ["playlist-prev"]}'))
A_TrayMenu.Add("Pause / Resume", (*) => MpvCmd('{"command": ["cycle", "pause"]}'))
A_TrayMenu.Add("Reshuffle", (*) => MpvCmd('{"command": ["playlist-shuffle"]}'))
A_TrayMenu.Add()
A_TrayMenu.Add("Choose Clips Folder...", (*) => ChooseFolder())
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Toggle Wallpaper Playback"
A_TrayMenu.ClickCount := 2
A_IconTip := "Wallpaper Player"

; ---------------- HOTKEYS ----------------
^!h::TogglePlayback()               ; Ctrl+Alt+H  -> single toggle: start if off, stop if on
^!Right::MpvCmd('{"command": ["playlist-next"]}')   ; Ctrl+Alt+Right -> next clip
^!Left::MpvCmd('{"command": ["playlist-prev"]}')    ; Ctrl+Alt+Left  -> previous clip
^!Space::MpvCmd('{"command": ["cycle", "pause"]}')  ; Ctrl+Alt+Space -> pause/resume
^!r::MpvCmd('{"command": ["playlist-shuffle"]}')    ; Ctrl+Alt+R -> reshuffle

; ---------------- STARTUP: watcher always runs ----------------
LaunchWatcher()
OnExit(CleanupOnExit)

; ---------------- CORE FUNCTIONS ----------------

TogglePlayback() {
    global mpvPID
    if mpvPID
        StopPlayback()
    else
        StartPlayback()
}

StartPlayback() {
    global mpvPID, mpvPath, clipsDir, rawDir, pipeName

    StopPlayback()  ; in case mpv is already running, kill it first

    if !DirExist(clipsDir)
        DirCreate(clipsDir)

    playlist := BuildPlaylist(clipsDir)
    if (playlist = "") {
        MsgBox("No normalized clips in " clipsDir " yet.`n`nDrop clips into:`n" rawDir "`nand they'll normalize automatically (usually within a few seconds), then try again.", "Wallpaper Player", "Icon!")
        return
    }

    hwnd := GetWorkerW()
    if !hwnd {
        MsgBox("Could not find/create the WorkerW wallpaper layer. Try again, or restart Explorer.", "Wallpaper Player", "Icon!")
        return
    }

    ; --hwdec=auto lets the GPU decode video instead of the CPU
    mpvArgs := Format('--wid={1} --loop-playlist=inf --shuffle --hwdec=auto --no-audio --no-osc --no-osd-bar --no-border --really-quiet --input-ipc-server=\\.\pipe\{2} --playlist="{3}"',
        hwnd, pipeName, playlist)

    Run('"' mpvPath '" ' mpvArgs, , "Hide", &pid)
    mpvPID := pid
}

StopPlayback() {
    global mpvPID
    if mpvPID {
        try ProcessClose(mpvPID)
        mpvPID := 0
    }
    for proc in ComObjGet("winmgmts:").ExecQuery("SELECT ProcessId, CommandLine FROM Win32_Process WHERE Name='mpv.exe'") {
        if InStr(proc.CommandLine, "mpv-wallpaper")
            try ProcessClose(proc.ProcessId)
    }
}

LaunchWatcher() {
    global watcherPID, watcherScript, rawDir, clipsDir, pipeName

    if watcherPID && ProcessExist(watcherPID)
        return  ; already running

    if !FileExist(watcherScript) {
        MsgBox("Watcher script not found next to this .ahk file:`n" watcherScript, "Wallpaper Player", "Icon!")
        return
    }

    psArgs := Format('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{1}" -RawDir "{2}" -ClipsDir "{3}" -PipeName "{4}"',
        watcherScript, rawDir, clipsDir, pipeName)
    Run('powershell.exe ' psArgs, , "Hide", &wpid)
    watcherPID := wpid
}

CleanupOnExit(*) {
    StopPlayback()
    global watcherPID
    if watcherPID {
        try ProcessClose(watcherPID)
    }
    for proc in ComObjGet("winmgmts:").ExecQuery("SELECT ProcessId, CommandLine FROM Win32_Process WHERE Name='powershell.exe'") {
        if InStr(proc.CommandLine, "WatchAndNormalize")
            try ProcessClose(proc.ProcessId)
    }
}

BuildPlaylist(folder) {
    listPath := A_Temp "\wallpaper_playlist.m3u"
    f := FileOpen(listPath, "w")
    if !IsObject(f)
        return ""
    count := 0
    Loop Files, folder "\*.mp4" {
        f.WriteLine(A_LoopFileFullPath)
        count++
    }
    f.Close()
    return count ? listPath : ""
}

MpvCmd(jsonCmd) {
    global pipeName
    try {
        f := FileOpen("\\.\pipe\" pipeName, "w")
        if IsObject(f) {
            f.Write(jsonCmd "`n")
            f.Close()
        }
    }
}

ChooseFolder() {
    global clipsDir
    chosen := DirSelect(clipsDir, 3, "Select your normalized clips folder")
    if chosen != "" {
        clipsDir := chosen
        StartPlayback()
    }
}

GetWorkerW() {
    DetectHiddenWindows(true)
    progman := WinExist("ahk_class Progman")
    if !progman
        return 0

    SendMessage(0x052C, 0, 0, , "ahk_class Progman")
    Sleep(200)

    target := 0
    for hwnd in WinGetList("ahk_class WorkerW") {
        if !DllCall("FindWindowEx", "ptr", hwnd, "ptr", 0, "str", "SHELLDLL_DefView", "ptr", 0, "ptr") {
            target := hwnd
        }
    }
    return target
}
