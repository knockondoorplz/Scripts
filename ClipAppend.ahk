;--------------------------------------------------------
; AutoHotkey script for saving selected text to a file
; ^+!c  = Ctrl + Shift + Alt + C -> append to END of file
; ^+#c = Ctrl + Shift + Win + C -> insert at BEGINNING
;--------------------------------------------------------

; Adjust this if you use AHK v2:
#Requires AutoHotkey v1.1+

; Path to your file
TargetFile := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\Some @%$! Code\Some @%$! Code.md"

;---------------------------
; Helper: get selected text
;---------------------------

GetSelectedText()
{
    clipSaved := ClipboardAll()

    A_Clipboard := ""

    Send("^c")

    if !ClipWait(0.5)
    {
        A_Clipboard := clipSaved
        return ""
    }

    text := A_Clipboard
    A_Clipboard := clipSaved

    return text
}

;--------------------------------------------------------
; ^+!c  → append selection to END of file + newline
;--------------------------------------------------------

^+!c::
    text := GetSelectedText()
    if (text != "")
    {
        FileAppend, % text . "`r`n", %TargetFile%
    }
return

;--------------------------------------------------------
; ^+#c → insert selection at BEGINNING of file + newline
;--------------------------------------------------------

^+#c::
    text := GetSelectedText()
    if (text != "")
    {
        FileRead, contents, %TargetFile%
        FileDelete, %TargetFile%
        FileAppend, % text . "`r`n" . contents, %TargetFile%
    }
return