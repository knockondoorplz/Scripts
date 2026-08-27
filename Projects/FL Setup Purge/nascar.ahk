#NoEnv
#Persistent
#SingleInstance force
SetBatchLines, -1
DetectHiddenWindows, On

; -----------------------------
; CONFIG
; -----------------------------
FL_EXE := "FL64.exe"
FL_FULLPATH := "C:\Program Files (x86)\Image-Line\FL Studio 2025\FL64.exe"
PWSH := "C:\Program Files\PowerShell\7\pwsh.exe"
AFFINITY_MASK := 0x8
PRIORITY_CLASS := "High"
DAW_GRACE_SECONDS := 1
RESUME_DELAY_SECONDS := 45

inDaw := false
affinitySet := false
lastFLSeen := 0
lastFLGone := 0
gui_show := true

; -----------------------------
; GUI (top-right of right monitor)
; -----------------------------
SysGet, mon1, Monitor, 1

guiW := 160
guiH := 50
guiX := mon1Right - guiW - 10
guiY := mon1Top + 10

Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, E0E0E0
Gui, Font, s9

Gui, Add, Text, vStatusText x10 y10 w140, NASCAR DAW: idle
Gui, Add, Button, gForceExit x10 y+5 w80 h24 +Border, Kill DAW

Gui, Show, w%guiW% h%guiH% x%guiX% y%guiY%, NASCAR DAW
if (!gui_show)
    Gui, Hide

; -----------------------------
; MAIN LOOP
; -----------------------------
SetTimer, WatchFL, 750
return

WatchFL:
Process, Exist, %FL_EXE%
pid := ErrorLevel

if (pid) {
    lastFLSeen := A_TickCount

    if (!inDaw) {
        Sleep, % DAW_GRACE_SECONDS * 1000
        Process, Exist, %FL_EXE%
        if (ErrorLevel) {
            inDaw := true
            affinitySet := false
            GuiControl,, StatusText, NASCAR DAW: ACTIVE
        }
    }

    if (inDaw && !affinitySet) {
        EnsureAffinityAndPriority(pid)
        affinitySet := true
    }
}
else {
    if (inDaw) {
        if (!lastFLGone)
            lastFLGone := A_TickCount

        if ((A_TickCount - lastFLGone) > (RESUME_DELAY_SECONDS * 1000)) {
            inDaw := false
            affinitySet := false
            lastFLGone := 0
            GuiControl,, StatusText, NASCAR DAW: idle
        }
    }
}
return

; -----------------------------
; PRIORITY + AFFINITY ONLY
; -----------------------------
EnsureAffinityAndPriority(pid) {
    global PWSH, AFFINITY_MASK, PRIORITY_CLASS, FL_EXE

    if (!pid) {
        Process, Exist, %FL_EXE%
        pid := ErrorLevel
        if (!pid)
            return
    }

    psCmd := ""
    psCmd .= "$p = Get-Process -Id " pid " -ErrorAction SilentlyContinue;"
    psCmd .= " if ($p) {"
    psCmd .= "  try {"
    psCmd .= "    $p.ProcessorAffinity = " AFFINITY_MASK ";"
    psCmd .= "    $p.PriorityClass = '" PRIORITY_CLASS "'"
    psCmd .= "  } catch {}"
    psCmd .= " }"

    RunWait, %PWSH% -NoProfile -WindowStyle Hidden -Command "%psCmd%",, Hide
    return
}

; -----------------------------
; MANUAL KILL BUTTON
; -----------------------------
ForceExit:
Process, Close, %FL_EXE%
GuiControl,, StatusText, NASCAR DAW: manual kill
return

; -----------------------------
; HOTKEY: Ctrl+Alt+N toggles script
; -----------------------------
^+!n::
IfWinExist, NASCAR DAW
{
    WinKill, NASCAR DAW
    ExitApp
} else {
    Run, %A_ScriptFullPath%
}
return
