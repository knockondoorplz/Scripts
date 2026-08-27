#NoEnv
SetWorkingDir %A_ScriptDir%

StartupFolder := C:\Users\brigi\Documents\Jason\Scripts
OutputFile := "C:\Users\brigi\Documents\Jason\Scripts\MyAutohotkeys.txt"

if FileExist(OutputFile)
    FileDelete, %OutputFile%

FileAppend, === MY AUTOHOTKEY HOTKEYS ===`n`n, %OutputFile%

Loop, Files, %StartupFolder%\*.ahk
{
    CurrentFile := A_LoopFileFullPath
    FileAppend, --- File: %A_LoopFileName% ---`n, %OutputFile%
    
    Loop, Read, %CurrentFile%
    {
        ; Matches lines that have a hotkey assignment (contains ::) 
        ; and ignores comments (starting with ;)
        if (InStr(A_LoopReadLine, "::") && SubStr(LTrim(A_LoopReadLine), 1, 1) != ";")
        {
            FileAppend, %A_LoopReadLine%`n, %OutputFile%
        }
    }
    FileAppend, `n, %OutputFile%
}

Run, notepad.exe "%OutputFile%"
return