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

                    RunWait(
                        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' 
                        A_ScriptDir '\IndexScript.ps1" "' Script '"',
                        ,
                        "Hide"
                    )

                    MsgBox "Registered:`n" item.Name
                    return
                }
            }
        }
    }
}