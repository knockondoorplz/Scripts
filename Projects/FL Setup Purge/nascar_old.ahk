; NASCAR DAW Mode - AutoHotkey v1
#NoEnv
#Persistent
#SingleInstance force
SetBatchLines, -1
DetectHiddenWindows, On

; --- CONFIG ---
FL_EXE := "FL64.exe"
FL_FULLPATH := "C:\Program Files (x86)\Image-Line\FL Studio 2025\FL64.exe"
PWSH := "C:\Program Files\PowerShell\7\pwsh.exe"
AFFINITY_MASK := 0x8
PRIORITY_CLASS := "Realtime"
DAW_GRACE_SECONDS := 1
RESUME_DELAY_SECONDS := 45
SUSPEND_INSTEAD_OF_KILL := true

SuspendList := ["Capture2Text","Ditto","Obsidian","Code","MicrosoftEdge","msedge","RainWallpaper","Rainmeter","Dropbox","GoogleDriveFS","GoogleDrive","Grammarly","SumatraPDF","Everything","iCloud","Ollama","teamviewer","Comet","iTunes","libreoffice","Explorer"]
AutoRestartList := ["Capture2Text","Ditto","Obsidian","RainWallpaper","iCloud"]

gui_show := true
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Add, Text, vStatusText, NASCAR DAW: idle
Gui, Add, Button, gForceExit xm+10 ym+10 w80 h22, Kill DAW
Gui, Show, w140 h40 x10 y10, NASCAR DAW
if (!gui_show)
    Gui, Hide

inDaw := false
lastFLSeen := 0
lastFLGone := 0

SetTimer, WatchFL, 750
return

WatchFL:
{
    Process, Exist, %FL_EXE%
    pid := ErrorLevel
    if (pid) {
        lastFLSeen := A_TickCount
        if (!inDaw) {
            Sleep, % DAW_GRACE_SECONDS * 1000
            Process, Exist, %FL_EXE%
            if (ErrorLevel) {
                EnterDAW(pid)
                inDaw := true
                GuiControl,, StatusText, NASCAR DAW: ACTIVE
            }
        } else {
            EnsureAffinityAndPriority(pid)
        }
    } else {
        if (inDaw) {
            if (!lastFLGone)
                lastFLGone := A_TickCount
            if ((A_TickCount - lastFLGone) > (RESUME_DELAY_SECONDS * 1000)) {
                ExitDAW()
                inDaw := false
                lastFLGone := 0
                GuiControl,, StatusText, NASCAR DAW: idle
            }
        }
    }
}
return

EnterDAW(pid) {
    global SuspendList, AutoRestartList, PWSH, SUSPEND_INSTEAD_OF_KILL
    apps := SuspendList
    psCmd := "Try {"
    psCmd .= " $ErrorActionPreference='SilentlyContinue';"
    for index, app in apps {
        psCmd .= " Get-Process -Name '" app "' -ErrorAction SilentlyContinue | ForEach-Object { Suspend-Process -Id $_.Id -ErrorAction SilentlyContinue };"
    }
    psCmd .= " } Catch { Write-Output 'PSSuspend error' }"
    RunWait, %PWSH% -NoProfile -WindowStyle Hidden -Command "%psCmd%",, Hide

    WinGet, idList, List
    Loop, %idList%
    {
        this_id := idList%A_Index%
        WinGet, exe, ProcessName, ahk_id %this_id%
        WinGetTitle, title, ahk_id %this_id%
        if (exe != "") {
            if (exe = "FL64.exe" || exe = "FL.exe" || exe = "fooBar2000.exe") {
                ; keep
            } else {
                WinMinimize, ahk_id %this_id%
            }
        }
    }

    EnsureAffinityAndPriority(pid)
    return
}

ExitDAW() {
    global SuspendList, AutoRestartList, PWSH
    psCmd := "Try { $ErrorActionPreference='SilentlyContinue';"
    for index, app in SuspendList {
        psCmd .= " Get-Process -Name '" app "' -ErrorAction SilentlyContinue | ForEach-Object { Resume-Process -Id $_.Id -ErrorAction SilentlyContinue };"
    }
    psCmd .= " } Catch { Write-Output 'PSResume error' }"
    RunWait, %PWSH% -NoProfile -WindowStyle Hidden -Command "%psCmd%",, Hide

        ; --- WINDOW BLACKLIST ---
    BlacklistTitles := ["Default IME", "ForcePad Driver Tray Window", "NASCAR DAW"]
    BlacklistClasses := ["IME", "SynTPEnh", "ETDCtrl"]

    WinGet, idList, List
    Loop, %idList%
    {
        this_id := idList%A_Index%
        WinGet, exe, ProcessName, ahk_id %this_id%
        WinGetTitle, title, ahk_id %this_id%
        WinGetClass, class, ahk_id %this_id%

        ; Skip blacklisted titles
        for each, bad in BlacklistTitles
            if (InStr(title, bad))
                continue

        ; Skip blacklisted classes
        for each, badClass in BlacklistClasses
            if (class = badClass)
                continue

        ; Skip FL Studio + whitelisted apps
        if (exe = "FL64.exe" || exe = "FL.exe" || exe = "fooBar2000.exe")
            continue

        ; Minimize everything else
        if (exe != "")
            WinMinimize, ahk_id %this_id%
    }

    return
}

EnsureAffinityAndPriority(pid) {
    global PWSH, AFFINITY_MASK, PRIORITY_CLASS
    if (!pid) {
        Process, Exist, %FL_EXE%
        pid := ErrorLevel
        if (!pid)
            return
    }
    psCmd := "$p = Get-Process -Id " pid " -ErrorAction SilentlyContinue; if ($p) { try { $p.ProcessorAffinity = " AFFINITY_MASK "; $p.PriorityClass = '" PRIORITY_CLASS "' } catch { Write-Output 'Affinity/Prio Failed' } }"
    RunWait, %PWSH% -NoProfile -WindowStyle Hidden -Command "%psCmd%",, Hide
    return
}

ForceExit:
    ExitDAW()
    inDaw := false
    GuiControl,, StatusText, NASCAR DAW: manual restore
return

^!n::
    IfWinExist, NASCAR DAW
    {
        WinKill, NASCAR DAW
        TrayTip, NASCAR DAW, Daemon stopped, 2
        ExitApp
    } else {
        Run, %A_ScriptFullPath%
    }
return
