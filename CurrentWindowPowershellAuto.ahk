; Hotkey: Ctrl+Alt+A (Automate Current Folder)
+!a::
{
    ; 1. Check if you are looking at a File Explorer window
    if WinActive("ahk_class CabinetWClass")
    {
        ; Grab the path of the active File Explorer window
        for window in ComObjCreate("Shell.Application").Windows
        {
            if (window.HWND = WinExist("A"))
            {
                dirPath := window.Document.Folder.Self.Path
                break
            }
        }
        
        ; 2. Target any version of PowerShell or Windows Terminal
        if WinExist("ahk_class CASCADIA_HOST_WINDOW_CLASS") 
            or WinExist("ahk_class ConsoleWindowClass") 
            or WinExist("ahk_exe powershell.exe") 
            or WinExist("ahk_exe pwsh.exe")
        {
            WinActivate ; Bring the terminal to the foreground
            
            ; Clear any half-typed text with Escape
            Send, {Esc}
            Sleep, 50
            
            ; Type the cd command cleanly, then hit physical Enter
            Send, cd "{Raw}%dirPath%"
            Send, {Enter}
            Sleep, 100
            
            ; Type 'auto' and hit physical Enter
            Send, auto
            Send, {Enter}
        }
        else
        {
            MsgBox, 48, Ghost Error, No open PowerShell or Windows Terminal window found! Open one first.
        }
    }
}
return