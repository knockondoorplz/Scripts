#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; WallpaperPlayer.ahk
; Embeds mpv into the desktop's hidden WorkerW layer and plays
; a shuffled playlist of video clips as a live wallpaper.
; ============================================================

; ---------------- CONFIG ----------------
mpvPath   := "C:\Tools\mpv.exe"                          ; assumes mpv is on PATH; else set full path e.g. "C:\mpv\mpv.exe"
clipsDir  := A_MyDocuments "\Wallpapers\Clips"           ; folder full of normalized .mp4 clips
pipeName  := "\\.\pipe\mpv-wallpaper"                    ; IPC socket for skip/pause/reshuffle
; -----------------------------------------

mpvPID := 0

; ---------------- TRAY MENU ----------------
A_TrayMenu.Delete()
A_TrayMenu.Add("Start / Restart Wallpaper", (*) => StartWallpaper())
A_TrayMenu.Add("Stop Wallpaper", (*) => StopWallpaper())
A_TrayMenu.Add()
A_TrayMenu.Add("Next Clip", (*) => MpvCmd('{"command": ["playlist-next"]}'))
A_TrayMenu.Add("Pause / Resume", (*) => MpvCmd('{"command": ["cycle", "pause"]}'))
A_TrayMenu.Add("Reshuffle", (*) => MpvCmd('{"command": ["playlist-shuffle"]}'))
A_TrayMenu.Add()
A_TrayMenu.Add("Choose Clips Folder...", (*) => ChooseFolder())
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Start / Restart Wallpaper"
A_TrayMenu.ClickCount := 2
A_IconTip := "Wallpaper Player"

; ---------------- HOTKEYS ----------------
^!g::StartWallpaper()               ; Ctrl+Alt+G  -> (re)start
^!h::StopWallpaper()                ; Ctrl+Alt+H  -> stop
^!Right::MpvCmd('{"command": ["playlist-next"]}')   ; Ctrl+Alt+Right -> next clip
^!Space::MpvCmd('{"command": ["cycle", "pause"]}')  ; Ctrl+Alt+Space -> pause/resume
^!r::MpvCmd('{"command": ["playlist-shuffle"]}')    ; Ctrl+Alt+R -> reshuffle

; ---------------- CORE FUNCTIONS ----------------

StartWallpaper() {
    global mpvPID, mpvPath, clipsDir, pipeName

    StopWallpaper()  ; kill any existing instance first

    if !DirExist(clipsDir) {
        MsgBox("Clips folder not found:`n" clipsDir "`n`nSet clipsDir at the top of the script or use 'Choose Clips Folder...'", "Wallpaper Player", "Icon!")
        return
    }

    playlist := BuildPlaylist(clipsDir)
    if (playlist = "") {
        MsgBox("No .mp4 clips found in:`n" clipsDir, "Wallpaper Player", "Icon!")
        return
    }

    hwnd := GetWorkerW()
    if !hwnd {
        MsgBox("Could not find/create the WorkerW wallpaper layer. Try again, or restart Explorer.", "Wallpaper Player", "Icon!")
        return
    }

    args := Format('--wid={1} --loop-playlist=inf --shuffle --no-audio --no-osc --no-osd-bar --no-border --really-quiet --input-ipc-server={2} --playlist="{3}"',
        hwnd, pipeName, playlist)

    Run('"' mpvPath '" ' args, , "Hide", &pid)
    mpvPID := pid
}

StopWallpaper() {
    global mpvPID
    if mpvPID {
        try ProcessClose(mpvPID)
        mpvPID := 0
    }
    ; catch stray mpv instances launched by this script
    for proc in ComObjGet("winmgmts:").ExecQuery("SELECT ProcessId, CommandLine FROM Win32_Process WHERE Name='mpv.exe'") {
        if InStr(proc.CommandLine, "mpv-wallpaper")
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

; Sends a one-shot JSON command to mpv's IPC pipe (skip/pause/shuffle etc.)
MpvCmd(jsonCmd) {
    global pipeName
    try {
        f := FileOpen(pipeName, "w")
        if IsObject(f) {
            f.Write(jsonCmd "`n")
            f.Close()
        }
    }
}

; Triggers Progman's hidden "create WorkerW behind icons" behavior,
; then finds the WorkerW that has no SHELLDLL_DefView child (that's the
; one that sits BEHIND the icons — the actual wallpaper-drawing surface).
GetWorkerW() {
    DetectHiddenWindows(true)
    progman := WinExist("ahk_class Progman")
    if !progman
        return 0

    ; Ask Progman to spawn the WorkerW layer
    SendMessage(0x052C, 0, 0, , "ahk_class Progman")
    Sleep(200)

    target := 0
    for hwnd in WinGetList("ahk_class WorkerW") {
        ; the WorkerW that owns the icons has a SHELLDLL_DefView child;
        ; we want its sibling, which has none.
        if !DllCall("FindWindowEx", "ptr", hwnd, "ptr", 0, "str", "SHELLDLL_DefView", "ptr", 0, "ptr") {
            target := hwnd
        }
    }
    return target
}
