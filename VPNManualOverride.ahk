; --- SELF-ELEVATION BLOCK (Paste this at the very top) ---
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}
#SingleInstance Force

; --- YOUR NETWORK HOTKEYS ---
; Replace "Wi-Fi" with the exact name from ncpa.cpl
^+!v::
RunWait, netsh interface set interface "TP-Link_1254" admin=disabled,, hide
return

^+#v::
RunWait, netsh interface set interface "TP-Link_1254" admin=enabled,, hide
return