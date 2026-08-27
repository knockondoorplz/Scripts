; Visual Engineering Setup Script
; Assigns naming conventions to your Peak Controllers
#IfWinActive ahk_exe FL64.exe

F1:: ; Run this once you have your 3 Peak Controllers loaded on your 3 tracks
{
    ; Select Mixer Track 10 (Low)
    Send, {F9} ; Open Mixer
    WinWaitActive, Mixer
    Send, ^1 ; (Assuming track 10 is ctrl+1 or similar)
    Sleep 100
    Send, {F2} ; Rename
    Send, Peak_Low{Enter}
    
    ; Repeat for others...
    ; This keeps your project consistent every time you start a new track
    MsgBox, Visual Bus Set Up: Peak_Low, Peak_Mid, Peak_High
}
return