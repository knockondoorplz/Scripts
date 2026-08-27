#Requires AutoHotkey v2.0
#SingleInstance Force

#Include C:\Users\brigi\Documents\Jason\Scripts\JSON.ahk

LaunchAll() {

    IndexFile := "C:\Users\brigi\Documents\Jason\Scripts\ScriptIndex.json"

    v1Path := "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe"
    v2Path := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"

    if !FileExist(IndexFile)
        return

    JsonText := FileRead(IndexFile, "UTF-8")
    JsonText := StrReplace(JsonText, Chr(0xFEFF), "")

    try {
        scripts := JSON.parse(JsonText)
    }
    catch Error as e {
        MsgBox(e.Message)
        return
    }

    for script in scripts {
        Target := script["path"]

        if !FileExist(Target)
            continue

        version := ""

        try {
            f := FileOpen(Target, "r")
            version := f.ReadLine()
            f.Close()
        }

        interpreter := InStr(version, "v2")
            ? v2Path
            : v1Path

        Run('"' interpreter '" /restart "' Target '"')
    }
}

LaunchAll()