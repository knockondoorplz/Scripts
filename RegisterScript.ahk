#Requires AutoHotkey v2.0
#SingleInstance Force


^#!m::
{
    Shell := ComObject("Shell.Application")

    for window in Shell.Windows()
    {
        if (window.HWND = WinExist("A"))
        {
            for item in window.Document.SelectedItems()
            {
                if (SubStr(item.Path, -4) = ".ahk")
                {
                    Script := item.Path

                    ExitCode := RunWait(
                        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' 
                        A_ScriptDir '\IndexScript.ps1" "' Script '"',
                        ,
                        "Hide"
                    )
                    
                    if (ExitCode != 0)
                    {
                        MsgBox "Registration FAILED:`n`n"
                            . item.Name
                            . "`n`nPowerShell exit code: "
                            . ExitCode
                    
                        return
                    }
                    
                    MsgBox "Registered:`n" item.Name
                }
            }
        }
    }
}