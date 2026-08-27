; Kill all AHK scripts except this one
KillOthers() {
    for proc in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process Where Name='AutoHotkey64.exe'") {
        if InStr(proc.CommandLine, A_ScriptFullPath)
            continue  ; skip this script
        proc.Terminate()
    }
}