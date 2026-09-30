#Requires AutoHotkey v2.0

global LastActiveWinID := 0
global LastTypingTime := 0

#HotIf
~*a::
~*b::
~*c::
~*d::
~*e::
~*f::
~*g::
~*h::
~*i::
~*j::
~*k::
~*l::
~*m::
~*n::
~*o::
~*p::
~*q::
~*r::
~*s::
~*t::
~*u::
~*v::
~*w::
~*x::
~*y::
~*z::
~*0::
~*1::
~*2::
~*3::
~*4::
~*5::
~*6::
~*7::
~*8::
~*9::
~*Space::
~*Enter::
~*Backspace::
~*Tab::
~*,::
~*.::
~*/::
~*;::
~*'::
~*[::
~*]::
~*\::
~*-::
~*=::
~*`::
{
    global LastActiveWinID, LastTypingTime
    try {
        LastActiveWinID := WinGetID("A")
        LastTypingTime := A_TickCount
    }
}

SetTimer(EnforceUniversalFocus, 100)

EnforceUniversalFocus() {
    global LastActiveWinID, LastTypingTime
    
    if (LastActiveWinID == 0 || LastTypingTime == 0)
        return

    ; Require typing within the last 2 seconds
    if (A_TickCount - LastTypingTime < 2000) {
        currentWin := 0
        try {
            currentWin := WinGetID("A")
        } catch {
            return ; Target window disappeared mid-check, safely skip
        }
        
        if (currentWin != 0 && currentWin != LastActiveWinID && WinExist("ahk_id " . LastActiveWinID)) {
            WinActivate("ahk_id " . LastActiveWinID)
            
            try {
                targetTitle := WinGetTitle("ahk_id " . LastActiveWinID)
                ToolTip("Focus Steal Blocked! Restored focus to: " . targetTitle)
                SetTimer(() => ToolTip(), -2500)
            }
        }
    }
}

