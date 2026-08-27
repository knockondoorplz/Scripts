^#!a:: {
if not A_IsAdmin {
    try {
        Run('*RunAs "' A_ScriptFullPath '"')
    }
    ; ExitApp
}

    ; Get current script process ID so we don't kill ourselves
    MyPID := DllCall("GetCurrentProcessId")
    
    ; Kill all AHK processes EXCEPT this one
    For Process in ComObject("WbemScripting.SWbemLocator").ConnectServer(".", "root\cimv2").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE 'AutoHotkey%'") {
        if (Process.ProcessId != MyPID) {
            ProcessClose(Process.ProcessId)
        }
    }

    Sleep(500)

    ; Launch everything in Startup
    StartupPath := A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup"
    Shell := ComObject("WScript.Shell")
    
    Loop Files StartupPath "\*.lnk"
    {
        Shortcut := Shell.CreateShortcut(A_LoopFileFullPath)
        Target := Shortcut.TargetPath
        
        if (SubStr(Target, -3) = ".ahk" && FileExist(Target)) {
            ; Use "Run" with the /r (restart) switch if needed, 
            ; but force the absolute path to the AHK v2 interpreter
            ; This forces CMD to stay open so you can read the error
            RunWait('cmd /k "' A_AhkPath '" "' Target '"')
        }
    }
    MsgBox("All AHK scripts have been reset (except this one!)", "System Status", "T2")
}

pause