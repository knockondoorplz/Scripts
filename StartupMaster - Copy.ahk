#Requires AutoHotkey v2.0
#SingleInstance Force

LaunchAll() {
    Manifest := "C:\Users\brigi\Documents\Jason\Scripts\Manifest.txt"
    v1Path := "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe"
    v2Path := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" 

    if !FileExist(Manifest) {
        return
    }

    Loop read, Manifest {
        Target := Trim(A_LoopReadLine)
        if (FileExist(Target)) {
            v1 := "" 
            try {
                ; Using the File Object avoids the #Warn message
                f := FileOpen(Target, "r")
                v1 := f.ReadLine()
                f.Close()
            } catch {
                v1 := ""
            }
            
            interpreter := (InStr(v1, "v2")) ? v2Path : v1Path
            Run('"' interpreter '" /restart "' Target '"')
        }
    }
}
LaunchAll()