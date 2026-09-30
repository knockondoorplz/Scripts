#Requires AutoHotkey v2.0
#SingleInstance Force

global LastActiveWinID := 0
global IsGuarding := true

; Register Windows Shell Hook to catch focus changes instantly (Zero CPU overhead!)
myGui := Gui()
DllCall("RegisterShellHookWindow", "UInt", myGui.Hwnd)
msgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOKMESSAGE")
OnMessage(msgNum, ShellMessage)

ShellMessage(wParam, lParam, msg, hwnd) {
    global LastActiveWinID, IsGuarding
    if (!IsGuarding)
        return

    ; HSHELL_WINDOWACTIVATED = 4
    if (wParam = 4) {
        activeHwnd := lParam
        try {
            activeClass := WinGetClass(activeHwnd)
            ; Ignore AHK GUIs, tooltips, and context menus so they don't lock your workflow
            if (activeClass != "AutoHotkeyGUI" && activeClass != "#32768" && activeHwnd != A_ScriptHwnd) {
                LastActiveWinID := activeHwnd
            }
        }
    }
}

; Active Protection Enforcer: Triggers instantly on window change events
; If another app violently steals focus while you're actively working, it snaps back.
~LButton:: {
    global LastActiveWinID, IsGuarding
    if (!IsGuarding || LastActiveWinID == 0)
        return
        
    try {
        currentWin := WinGetID("A")
        currentClass := WinGetClass(currentWin)
        
        if (currentClass == "AutoHotkeyGUI" || currentClass == "#32768")
            return
            
        if (currentWin != 0 && currentWin != LastActiveWinID && WinExist(LastActiveWinID)) {
            ; Check if user is holding modifier keys (allowing intentional hotkey switches)
            if GetKeyState("Alt", "P") || GetKeyState("Ctrl", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
                return
                
            WinActivate(LastActiveWinID)
            ToolTip("Focus Guard Shielded! Restored focus.")
            SetTimer(() => ToolTip(), -1500)
        }
    }
}

; Toggle Focus Guard on/off using your custom modifier hotkey: >^>!f
>^>!f:: {
    global IsGuarding
    IsGuarding := !IsGuarding
    status := IsGuarding ? "ENABLED" : "DISABLED"
    ToolTip("FocusGuard V3 is now " . status)
    SetTimer(() => ToolTip(), -2000)
}