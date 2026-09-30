>^b::
    biomeRunning := false

    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name='powershell.exe'")
    {
        if InStr(process.CommandLine, "Biome.ps1") {
            biomeRunning := true
            process.Terminate()
        }
    }

    if (!biomeRunning) {
        Run, powershell.exe -NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\BiomeCore\Start-BiomeCore.ps1",, Hide
    }
return
