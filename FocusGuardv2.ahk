#Requires AutoHotkey v2.0
#SingleInstance Force

global LastActiveWinID := 0
global IsGuarding := true

; Register Windows Shell Hook to catch focus changes instantly (Zero CPU polling!)
myGui := Gui()
DllCall("RegisterShellHookWindow", "UInt", myGui.Hwnd)
msgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOKMESSAGE")
OnMessage(msgNum, ShellMessage)

ShellMessage(wParam, lParam, msg, hwnd) {
    global LastActiveWinID, IsGuarding
    if (!IsGuarding)
        return

    ; HSHELL_WINDOWACTIVATED = 4, HSHELL_GETMINRECT = 5
    if (wParam = 4) {
        activeHwnd := lParam
        try {
            activeClass := WinGetClass(activeHwnd)
            ; Ignore AHK GUIs, tooltips, and context menus
            if (activeClass != "AutoHotkeyGUI" && activeClass != "#32768" && activeHwnd != A_ScriptHwnd) {
                LastActiveWinID := activeHwnd
            }
        }
    }
}

; Global Hotkey to toggle Focus Guard on/off if an app fights too hard:
#!f:: {
    global IsGuarding
    IsGuarding := !IsGuarding
    status := IsGuarding ? "ENABLED" : "DISABLED"
    ToolTip("FocusGuard is now " . status)
    SetTimer(() => ToolTip(), -2000)
}