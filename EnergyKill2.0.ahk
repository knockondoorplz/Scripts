#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

;==========================================================
; ShakeKill 2.0
;----------------------------------------------------------
;
; PURPOSE
; -------
; Rapidly close windows using an intentional left-right
; shake gesture.
;
; DESIGN PRINCIPLES
; -----------------
; • Reward oscillation, not distance.
; • Ignore tiny jitter.
; • Ignore huge cross-monitor throws.
; • Visuals communicate intent but never control behavior.
; • Small enough to stay out of the way.
; • Beautiful enough to enjoy using every day.
;
; "The cursor earns intent by changing its mind,
;  not by covering distance."
;
;==========================================================

;==========================================================
; User Settings
;==========================================================

KillDelay       := 1800     ; Hold time after intent lock.
ShakeThreshold  := 1800     ; Energy required before countdown.
IdleReset       := 250      ; Forget intent after standing still.
MinMovement     := 4        ; Ignore tiny jitter.
MaxMovement     := 60       ; Ignore huge monitor-spanning throws.
ReversalBonus   := 180      ; Reward changing direction.
PassiveDecay    := 8        ; Energy slowly leaks away.

global Wisp := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
Wisp.BackColor := "00FFFF"

Wisp.Show("w12 h12 Hide")
WinSetTransparent(180, Wisp.Hwnd)

;==========================================================
; State
;==========================================================
;
; "Settings" are chosen once.
;
; "State" changes every frame.
;
; Think of state as the script's short-term memory.
; Without it, every timer tick would forget everything
; that happened previously.
;==========================================================

Energy := 0
Hue := 0
LastDir := 0

;==========================================================
; InitializeRenderer()
;
; A function is a named machine.
;
; Instead of writing the same code over and over,
; we give the job a name.
;
; Later we'll simply say:
;
;     InitializeRenderer()
;
; and the entire machine runs.
;==========================================================

;==========================================================
; SHAKE CORE UPDATE (minimal, correct version)
;==========================================================

UpdateShake(x, lastX)
{
    global Energy, LastDir
    global MinMovement, MaxMovement
    global ReversalBonus, PassiveDecay

    dx := x - lastX

    ; ignore noise
    if (Abs(dx) < MinMovement)
        return

    ; ignore crazy jumps
    if (Abs(dx) > MaxMovement)
        return

    ; direction encoding
    dir := (dx > 0) ? 1 : -1

    ; reversal detection = the entire game
    if (LastDir != 0 && dir != LastDir)
    {
        Energy += ReversalBonus
    }
    else
    {
        ; small decay even during motion
        Energy -= PassiveDecay
    }

    LastDir := dir

    ; clamp
    if (Energy < 0)
        Energy := 0
}

CheckKill()
{
    global Energy, ShakeThreshold, KillDelay

    if (Energy >= ShakeThreshold)
    {
        Sleep KillDelay
        WinClose "A"
        Energy := 0
    }
}

RenderField(norm, angle)
{
    ; Placeholder.
    ; We'll build the renderer next.
}

RenderIntent(Energy)
{
    global Wisp

    MouseGetPos &mx, &my

    ToolTip("Mouse: " mx ", " my)

    size := 12
    Wisp.Move(mx - size//2, my - size//2)
    Wisp.Show("NA")
}

lastX := 0

SetTimer(MainLoop, 16)   ; ~60fps feel
SetTimer(CheckKill, 50)

MainLoop()
{
    global lastX, Energy

    MouseGetPos &x, &y

    UpdateShake(x, lastX)
    lastX := x

    RenderIntent(Energy)
}