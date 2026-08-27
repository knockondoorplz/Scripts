; RegisterScript.ahk (v1 style)
^#!m::
    Manifest := "C:\Users\brigi\Documents\Jason\Scripts\Manifest.txt"
    paths := ""
    
    ; Logic identical to your working GitDiff
    for window in ComObjCreate("Shell.Application").Windows() {
        if (window.HWND = WinExist("A")) {
            for item in window.Document.SelectedItems() {
                if (SubStr(item.Path, -3) = ".ahk") {
                    paths .= item.Path "`n"
                }
            }
        }
    }
    
    if (paths != "") {
        FileAppend, %paths%, %Manifest%
        Run, powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\brigi\Documents\Jason\Scripts\Generate-HotkeyMap.ps1",, Hide
        MsgBox, 64, Status, Manifest updated!
    }
return