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

GetSelectedText() {
    ClipSaved := ClipboardAll          ; save full clipboard (incl. images)
    Clipboard := ""                    ; clear
    Send ^c                            ; copy selection
    ClipWait, 0.5                      ; wait up to 0.5 sec
    sel := Clipboard
    Clipboard := ClipSaved             ; restore clipboard
    return sel
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