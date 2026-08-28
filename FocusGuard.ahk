#Requires AutoHotkey v2.0

; Prevent focus stealing while actively typing in Obsidian
#HotIf WinActive("ahk_exe obsidian.exe")
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
~*Space::
~*Backspace::
{
    ; Touch timestamp of last active typing
    global LastTypingTime := A_TickCount
}
#HotIf

; Monitor every 100ms: If we typed in Obsidian within 2 seconds, force window back if focus was stolen
SetTimer(EnforceObsidianFocus, 100)

EnforceObsidianFocus() {
    global LastTypingTime
    if (!IsSet(LastTypingTime))
        return

    ; If user typed in Obsidian within the last 2000ms
    if (A_TickCount - LastTypingTime < 2000) {
        if !WinActive("ahk_exe obsidian.exe") && WinExist("ahk_exe obsidian.exe") {
            WinActivate("ahk_exe obsidian.exe")
            ToolTip("Focus Steal Blocked!")
            SetTimer(() => ToolTip(), -1000)
        }
    }
}