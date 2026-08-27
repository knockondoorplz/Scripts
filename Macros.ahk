;────────────────────────────────────────────
; NEXUS HOTKEYS — base control framework
;────────────────────────────────────────────
; Author: You
; Purpose: Streamline creative workflow, system navigation, and FL Studio control
;────────────────────────────────────────────

; 🧠 AutoHotkey Codex: The Essential Brain Upload

;===== LAUNCH OPTIONS =====
#NoEnv
#SingleInstance Force
SendMode Input


;===== SYSTEM / NAVIGATION =====
; #IfWinActive ahk_exe explorer. Exe
>^j::Send !{Left}        ; Right Ctrl+J → Back
return
>^k::Send !{Right}       ; Right Ctrl+K → Forward
>^i::Send {F2}           ; Right Ctrl+I → Rename


;===== GLOBAL SYSTEM CONTROL =====
; +#X::ExitApp            ; Shift+Win+X → exit AHK
+#R::Reload             ; Shift+Win+R → reload script
+#P::Pause              ; Shift+Win+P → pause all hotkeys
^#x::WinClose, A         ; Ctrl+Win+X → force quit active window
^#Left::WinMove, A,, 0,0,960,1080  ; Win+← → move left half (adjust for your resolution)
^#Right::WinMove, A,, 960,0,960,1080 ; Win+→ → move right half

;===== FOCUS MODES (for DAW work) =====
; Toggle “focus mode” — kills distractions like Explorer/Taskbar popups
; (placeholder: can expand later with WinHide, process priority, etc.)
^!F::
    MsgBox, Focus mode engaged — clear the decks!
Return

;===== HOTSTRINGS / MACROS =====
::sig::N33DZ1LP⚡
:*:jlb0::jlb0467@gmail.com
:*:knocko::knockondoorplz@gmail.com
:*:dig0::digital.identifier0@gmail.com

;===== PERSONAL MACROS =====
^+!6::
Send, {Home}{Enter}{Up}-{Space}
return

^+!7::
Send, {Space 4}{Left 4}{Down}
return

^+#7::
Send, {Space 4}
return

^+!8::
Clipboard := ""
Send, ^c
ClipWait, 1
Lines := StrSplit(Clipboard, "`n", "`r")
NewText := ""
for index, line in Lines
{
    if (line = "" && index = Lines.MaxIndex())
        continue
    NewText .= "    " line
    if (index < Lines.MaxIndex())
        NewText .= "`n"
}
Clipboard := NewText
Send, ^v
return

;===== END OF SCRIPT =====

/*
;────────────────────────────────────────────
; FLOW STATE MODE — toggle all distractions off/on
;────────────────────────────────────────────

Flowstate := false

+!F:: ; Ctrl+Alt+F to toggle Flow State Mode
If (flowstate) {
    ; ==== TURN OFF FLOW MODE ====
    Flowstate := false
    Run, taskbar show
    Run, desktop show
    Run, powercfg -setactive SCHEME_BALANCED, , Hide
    Sleep, 100
    Run, nircmd. Exe monitor on  ; optional: if you’re using NirCmd for monitor control
    SoundPlay, *16              ; little “ding” to confirm
    TrayTip, Flow State, Disengaged — systems normal, 2, 1
} else {
    ; ==== TURN ON FLOW MODE ====
    Flowstate := true
    Run, taskbar hide
    Run, desktop hide
    Run, powercfg -setactive SCHEME_PERFORMANCE, , Hide
    Sleep, 100
    SoundPlay, *64              ; “click” tone for entry
    TrayTip, Flow State, Engaged — distractions nullified, 2, 1
}
Return
*\