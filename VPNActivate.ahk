; --- CLEAN ELEVATION BLOCK ---
; Fixes the "Keep Waiting" freeze loop by cleanly exiting the old instance
if (!A_IsAdmin) {
    Run, *RunAs "%A_ScriptFullPath%"
    ExitApp
}
#SingleInstance Force

; --- BACKGROUND VPN TOGGLE ---

; Connect Silently (Ctrl+Win+Alt+V)
^#!V::
; This forces an instant sound so we know the key register worked BEFORE Windows touches the VPN
SoundBeep, 1500, 300  
TrayTip, Debug Info, Hotkey Fired! Sending Start Command..., 2

; Execute the command
Run, sc start "WireGuardTunnel$JasonWireguard",, Hide
return

; Disconnect Silently (Shift+Win+Alt+V)
+#!V::
SoundBeep, 800, 300
TrayTip, Debug Info, Hotkey Fired! Sending Stop Command..., 2

Run, sc stop "WireGuardTunnel$JasonWireguard",, Hide
return