#Requires AutoHotkey v2

^#!k::

KillOthers() {
    ; List of processes to spare
    protected := ["KillOthers.ahk"]
    
    for proc in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process Where Name='AutoHotkey.exe' OR Name='AutoHotkey64.exe'") {
        cmd := proc.CommandLine
        shouldKill := true
        for p in protected {
            if InStr(cmd, p)
                shouldKill := false
        }
        if (shouldKill)
            proc.Terminate()
    }
}