#Requires AutoHotkey v2.0
Persistent

;=========================================================
; Settings
;=========================================================

KillDelay := 1800          ; milliseconds to hold before killing
ShakeThreshold := 1800     ; amount of shaking required

; Pick ANY font you want here.
; Try:
; Segoe UI Symbol
; Cascadia Code
; Noto Sans Symbols
; Symbola
; JetBrains Mono

Hue := 0

FontName := "Judas"

Glyphs := [
    "✦","✧","✶","✷","✸","✹","✺",
    "❂","◎","◉","✴","❋","✵"
]

GlyphIndex := 1

CoordMode("Mouse", "Screen")

;=========================================================
; Cursor Glyph
;=========================================================

Glow := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound")
Glow.BackColor := "EEAA99" ; any unused color
WinSetTransColor("EEAA99", Glow)

Glyph := Glow.AddText(
    "Center c00FF66 BackgroundTrans w40 h40",
    Glyphs[1]
)

Glyph.SetFont("s22", FontName)

Glow.Show("Hide NA")

WinSetTransparent(200, "ahk_id " Glow.Hwnd)

;=========================================================

SetTimer(WatchShake, 20)

WatchShake()
{
    global Glow, Glyph, Glyphs, GlyphIndex
    global KillDelay, ShakeThreshold

    static lastX := 0
    static lastY := 0

    static lastDirX := 0
    static lastDirY := 0

    static shake := 0
    static start := 0

    static lastTime := A_TickCount

    MouseGetPos(&x,&y)

    dx := x - lastX
    dy := y - lastY

    dist := Abs(dx) + Abs(dy)

    ;--------------------------------------------
    ; Band-pass filter (ignore noise + throws)
    ;--------------------------------------------

    if (dist < 6)
    {
        shake := Max(0, shake - 20)
    }

    ;--------------------------------------------
    ; Direction reversal detection
    ;--------------------------------------------

    dirX := (dx > 0) ? 1 : -1
    dirY := (dy > 0) ? 1 : -1

    reversal := 0

    if (lastDirX != 0 && dirX != lastDirX)
        reversal += 1

    if (lastDirY != 0 && dirY != lastDirY)
        reversal += 1

    lastDirX := dirX
    lastDirY := dirY

    ;--------------------------------------------
    ; Oscillation scoring (core logic)
    ;--------------------------------------------

    shake += (dist * 0.6)

    if (reversal > 0)
        shake += (reversal * 80)  ; THIS is what makes it intentional

    ; cap
    if (shake > 2000)
        shake := 2000

    ;--------------------------------------------
    ; Trigger window start (intent lock-in)
    ;--------------------------------------------

    if (shake > ShakeThreshold && start = 0)
        start := A_TickCount

    if (shake < ShakeThreshold)
        start := 0

    lastX := x
    lastY := y

    ;--------------------------------------------
    ; Progress (1.5s sustained oscillation required)
    ;--------------------------------------------

    progress := 0
    if (start)
        progress := Min(1, (A_TickCount - start) / KillDelay)

    ;--------------------------------------------
    ; Cursor follow
    ;--------------------------------------------

    CoordMode("Mouse", "Screen")
    MouseGetPos(&x, &y)
    Glow.Show("NA")
    Glow.Move(x - 20, y - 20)

    ;--------------------------------------------
    ; Glyph cycling (visual feedback)
    ;--------------------------------------------

    GlyphIndex++
    if (GlyphIndex > Glyphs.Length)
        GlyphIndex := 1

    Glyph.Text := Glyphs[GlyphIndex]

    ;--------------------------------------------
    ; Smooth ramp (feels less jittery)
    ;--------------------------------------------

    alpha := Round(20 + progress * 235)
    WinSetTransparent(alpha, "ahk_id " Glow.Hwnd)

    Glow.Show("NA")

    ;--------------------------------------------
    ; Kill action
    ;--------------------------------------------

    if (progress >= 1)
    {
        Glow.Hide()

        MouseGetPos(,, &hwnd)

        if hwnd
        {
            title := WinGetTitle("ahk_id " hwnd)
            ToolTip("Killing: " title)

            WinClose("ahk_id " hwnd)
            SetTimer(() => ToolTip(), -500)
        }

        shake := 0
        start := 0
        lastDirX := 0
        lastDirY := 0
    }
}