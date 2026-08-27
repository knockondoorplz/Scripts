; ------------------------------------------------------------
; HOTKEY: Ctrl+Shift+D → Popup (Bottom‑Right)
; ------------------------------------------------------------
^+d::
    ShowWallpaperPopup()
return

; ------------------------------------------------------------
; POPUP UI (4‑button grid)
; ------------------------------------------------------------
ShowWallpaperPopup() {
    global

    Gui, WallpaperPopup:Destroy
    Gui, WallpaperPopup:+AlwaysOnTop -Caption +ToolWindow
    Gui, WallpaperPopup:Color, 1A1A1A
    Gui, WallpaperPopup:Font, cFFFFFF s10, Segoe UI

    ; Buttons
    Gui, WallpaperPopup:Add, Text, xm ym Section, LEFT
    Gui, WallpaperPopup:Add, Button, x+10 yp gBumpLeft, Bump
    Gui, WallpaperPopup:Add, Button, x+10 yp gNukeLeft, Nuke

    Gui, WallpaperPopup:Add, Text, xs y+20, RIGHT
    Gui, WallpaperPopup:Add, Button, x+10 yp gBumpRight, Bump
    Gui, WallpaperPopup:Add, Button, x+10 yp gNukeRight, Nuke

    ; Position bottom‑right
    SysGet, mon, MonitorWorkArea
    x := monRight - 200
    y := monBottom - 120

    Gui, WallpaperPopup:Show, x%x% y%y% w200 h100, WallpaperPopup
}

; ------------------------------------------------------------
; BUTTON HANDLERS
; ------------------------------------------------------------
BumpLeft:
    HandleWallpaperAction("left", "bump")
return

NukeLeft:
    HandleWallpaperAction("left", "nuke")
return

BumpRight:
    HandleWallpaperAction("right", "bump")
return

NukeRight:
    HandleWallpaperAction("right", "nuke")
return

; ------------------------------------------------------------
; MAIN ACTION HANDLER
; ------------------------------------------------------------
HandleWallpaperAction(side, action) {
    Gui, WallpaperPopup:Destroy

    transcoded := GetTranscodedForSide(side)
    if (!transcoded) {
        MsgBox, 48, Error, Could not find transcoded wallpaper for %side%.
        return
    }

    original := FindOriginalFromHash(transcoded)
    if (!original) {
        MsgBox, 48, Error, Could not locate original wallpaper file.
        return
    }

    if (action = "bump") {
        BumpFile(original)
        MsgBox, 64, Done, Bumped:`n%original%
    } else if (action = "nuke") {
        FileDelete, %original%
        MsgBox, 64, Done, Nuked:`n%original%
    }

    RefreshWallpaper()
}

; ------------------------------------------------------------
; MAP LEFT/RIGHT → Transcoded_000 / 001
; ------------------------------------------------------------
GetTranscodedForSide(side) {
    folder := A_AppData . "\Microsoft\Windows\Themes\"

    ; Determine which monitor is left/right
    SysGet, monCount, MonitorCount
    leftMon := ""
    rightMon := ""

    Loop, %monCount% {
        SysGet, mon, Monitor, %A_Index%
        if (A_Index = 1 || monLeft < leftEdge) {
            leftEdge := monLeft
            leftMon := A_Index
        }
        if (A_Index = 1 || monRight > rightEdge) {
            rightEdge := monRight
            rightMon := A_Index
        }
    }

    ; Windows assigns transcoded files in monitor order
    if (side = "left")
        return folder . "Transcoded_000"
    else
        return folder . "Transcoded_001"
}

; ------------------------------------------------------------
; HASH‑MATCH TRANSCODED FILE TO ORIGINAL
; ------------------------------------------------------------
FindOriginalFromHash(transcodedPath) {
    FileRead, data, %transcodedPath%
    if (ErrorLevel)
        return ""

    hash := HashData(data)

    root := "C:\Users\brigi\Pictures\_ΔЖДЭΣΨΦΞŦͶΠφħþµØęŋƋƍƏƔƕƈƹƼȢȶȹɚɞɸ\Yupdatum\"

    Loop, Files, %root%\*.*, R
    {
        FileRead, d2, %A_LoopFileFullPath%
        if (!ErrorLevel && HashData(d2) = hash)
            return A_LoopFileFullPath
    }

    return ""
}

; ------------------------------------------------------------
; SIMPLE HASH FUNCTION
; ------------------------------------------------------------
HashData(data) {
    hash := 0
    Loop, Parse, data
        hash := (hash * 131 + Asc(A_LoopField)) & 0xFFFFFFFF
    return hash
}

; ------------------------------------------------------------
; BUMP FILE UP ONE FOLDER
; ------------------------------------------------------------
BumpFile(path) {
    SplitPath, path, name, dir
    parent := SubStr(dir, 1, InStr(dir, "\", false, 0)-1)
    FileMove, %path%, %parent%\%name%
}

; ------------------------------------------------------------
; REFRESH WALLPAPER
; ------------------------------------------------------------
RefreshWallpaper() {
    DllCall("User32.dll\SystemParametersInfo", "UInt", 0x14, "UInt", 0, "Str", "", "UInt", 2)
}