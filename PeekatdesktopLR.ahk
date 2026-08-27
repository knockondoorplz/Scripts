#Requires AutoHotkey v1.1

global MinimizedWindows := {}

#!Left::ToggleMonitor(2)
#!Right::ToggleMonitor(1)

ToggleMonitor(monNum) {
    SysGet, mon, Monitor, %monNum%
    
    if (MinimizedWindows.HasKey(monNum) && MinimizedWindows[monNum].MaxIndex() > 0) {
        for index, hwnd in MinimizedWindows[monNum] {
            if WinExist("ahk_id " hwnd)
                WinRestore, ahk_id %hwnd%
        }
        MinimizedWindows[monNum] := []
        return
    }

    MinimizedWindows[monNum] := []
    WinGet, id, List
    Loop, %id% {
        this_id := id%A_Index%
        
        WinGetTitle, title, ahk_id %this_id%
        WinGetClass, class, ahk_id %this_id%
        WinGetPos, x, y, w, h, ahk_id %this_id%
        
        ; STRICTURE FILTER: Ignore Taskbar, Start Menu, and System Shells
        if (class = "Shell_TrayWnd" || class = "Button" || class = "Shell_SecondaryTrayWnd" || class = "WorkerW" || class = "Progman")
            continue
            
        ; Calculate Center for accurate monitor assignment
        centerX := x + (w / 2)
        
        if (centerX >= monLeft && centerX < monRight) {
            ; Skip Task Manager if it refuses to move
            WinGet, proc, ProcessName, ahk_id %this_id%
            if (proc = "Taskmgr.exe")
                continue
                
            WinMinimize, ahk_id %this_id%
            MinimizedWindows[monNum].Push(this_id)
        }
    }
}