; FL Studio Power User AHK Script

#IfWinActive ahk_exe FL64.exe

; 1. Quickly toggle the Browser (F8) and Picker Panel (Alt+P)
; Useful for when you have a screen-real-estate-heavy project
F1::Send {F8}
F2::Send !p

; 2. One-touch Master Export
; Triggers File > Export > Project bones (assuming you have mapped your shortcuts)
^e::Send !f{down 7}{enter}

; 3. Quick-Save and Back-up increment
; Saves, then sends a command to copy the current file to a 'QuickBackup' folder
; (Requires a designated folder)
^s::
{
    Send ^s
    Sleep 200
    ; Add logic here to move the file or trigger a custom script
    return
}

; 4. Focus Mixer (F9) and Playlist (F5) instantly
F3::Send {F9}
F4::Send {F5}

#IfWinActive