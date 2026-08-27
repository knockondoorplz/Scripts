^#!r:: {
if not A_IsAdmin {
    try {
        Run('*RunAs "' A_ScriptFullPath '"')
    }
    ; ExitApp
}

    StartupPath := A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup"
    Shell := ComObject("WScript.Shell")
    
    ; CORRECT SYNTAX: Loop Files (two words)
    Loop Files StartupPath "\*.lnk"
    {
        Shortcut := Shell.CreateShortcut(A_LoopFileFullPath)
        Target := Shortcut.TargetPath
        
        if (SubStr(Target, -3) = ".ahk" && FileExist(Target)) {
            ; This forces CMD to stay open so you can read the error
            RunWait('cmd /k "' A_AhkPath '" "' Target '"')
        }
    }
    MsgBox("Al1 $r1pT5 f1r3d!", "System Status", "T2")
}

pause