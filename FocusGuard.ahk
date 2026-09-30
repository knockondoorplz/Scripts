#Requires AutoHotkey v2.0
#SingleInstance Force

global LastActiveWinID := 0
global LastTypingTime := 0

; 1. Listen for key events globally via a SINGLE InputHook instead of 50+ hotkeys
global KeyLogger := InputHook("V L0") ; Visible (V), zero length limit
KeyLogger.OnKeyDown := OnAnyKeyPressed
KeyLogger.Start()

OnAnyKeyPressed(ih, vk, sc) {
    global LastActiveWinID, LastTypingTime
    try {
        activeHwnd := WinGetID("A")
        
        ; Ignore AHK GUIs and menus so they don't count as typing targets
        activeClass := WinGetClass(activeHwnd)
        if (activeClass != "AutoHotkeyGUI" && activeClass != "#32768") {
            LastActiveWinID := activeHwnd
            LastTypingTime := A_TickCount
        }
    }
}

; 2. Enforce focus every 100ms without blocking popups or hotkeys
SetTimer(EnforceUniversalFocus, 100)

EnforceUniversalFocus() {
    global LastActiveWinID, LastTypingTime
    
    if (LastActiveWinID == 0 || LastTypingTime == 0)
        return

    ; Check if you typed within the last 2 seconds
    if (A_TickCount - LastTypingTime < 2000) {
        ; IF YOU ARE HOLDING A MODIFIER KEY (Alt, Ctrl, Win), STOP!
        ; You are likely firing a hotkey like !Space or ^!j
        if GetKeyState("Alt", "P") || GetKeyState("Ctrl", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
            return

        try {
            currentWin := WinGetID("A")
            currentClass := WinGetClass(currentWin)
            
            ; ALLOW AutoHotkey GUIs (OmniPalette, ToDo) and context menus to take focus freely
            if (currentClass == "AutoHotkeyGUI" || currentClass == "#32768")
                return

            if (currentWin != 0 && currentWin != LastActiveWinID && WinExist(LastActiveWinID)) {
                WinActivate(LastActiveWinID)
                
                targetTitle := WinGetTitle(LastActiveWinID)
                ToolTip("Focus Steal Blocked! Restored focus to: " . targetTitle)
                SetTimer(() => ToolTip(), -2500)
            }
        }
    }
}