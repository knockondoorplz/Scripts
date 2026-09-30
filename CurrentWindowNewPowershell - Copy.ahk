; ==========================================
; Hotkey: Ctrl+Alt+T (Warp Terminal to Current Folder)
; ==========================================
^!t::
    HandleTerminalRouting(False)
return

; ==========================================
; Hotkey: Ctrl+Alt+A (Warp Terminal + Auto-Clean Folder)
; ==========================================
^!a::
    HandleTerminalRouting(True)
return


; ==========================================
; CORE ROUTING ENGINE (Handles both hotkeys)
; ==========================================
HandleTerminalRouting(runAutoCommand) {
    if WinActive("ahk_class CabinetWClass")
    {
        ; 1. Grab the active path from File Explorer
        WinGetText, windowText, A
        Loop, Parse, windowText, `n, `r
        {
            if (SubStr(A_LoopField, 1, 9) = "Address: ")
            {
                dirPath := SubStr(A_LoopField, 10)
                break
            }
        }
        if (dirPath = "")
        {
            for window in ComObjCreate("Shell.Application").Windows
            {
                if (window.HWND = WinExist("A"))
                {
                    dirPath := window.Document.Folder.Self.Path
                    break
                }
            }
        }
        
        ; 2. CHECK: Is a terminal already running?
        if WinExist("ahk_exe WindowsTerminal.exe") 
            or WinExist("ahk_exe powershell.exe") 
            or WinExist("ahk_exe pwsh.exe")
        {
            WinActivate
            Sleep, 100
            
            Send, {Esc}
            Sleep, 50
            
            ; FIX: Separate the path from the Enter keypress
            Send, cd "{Raw}%dirPath%"
            Send, {Enter}
            
            if (runAutoCommand) {
                Sleep, 100
                Send, auto
                Send, {Enter}
            }
        }
        else
        {
            ; 3. If no terminal exists, launch a fresh one
            Run, wt.exe
            
            ; Wait for the new window to become active
            WinWaitActive, ahk_exe WindowsTerminal.exe,, 3
            
            ; Wait for Biome Simulator default path to finish loading
            Sleep, 800 
            
            Send, {Esc}
            Sleep, 50
            
            ; FIX: Separate the path from the Enter keypress here too
            Send, cd "{Raw}%dirPath%"
            Send, {Enter}
            
            if (runAutoCommand) {
                Sleep, 100
                Send, auto
                Send, {Enter}
            }
        }
    }
}

; Ctrl + Shift + Alt + T -> Open Windows Terminal as Admin
^+!t::
Run, *RunAs wt.exe
return