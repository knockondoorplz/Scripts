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

FontName := "Faulmann Font"

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
Glow.BackColor := "0d98ba" ; EEAA99
WinSetTransColor("66ff00", Glow)

Glyph := Glow.AddText(
    "Center c00FF66 BackgroundTrans",
    Glyphs[1]
)

Glyph.SetFont("s28 Bold", "Faulman Font")

Glow.Show("Hide NA")

WinSetTransparent(200, "ahk_id " Glow.Hwnd)

;=========================================================

SetTimer(WatchShake, 20)

WatchShake()
{
    global Glow, Glyph, Glyphs, GlyphIndex, Hue
    global KillDelay, ShakeThreshold

    static lastX := 0
    static lastY := 0

    static lastDirX := 0
    static lastDirY := 0

    static shake := 0
    static start := 0

    static idleTime := 0
    static decayRate := 60

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
        idleTime += 20

        if (idleTime > 250)
        {
            shake := 0
            start := 0
        }
    }
    else
    {
        idleTime := 0
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

    ; Ignore huge throws (like whipping across both monitors)
    if (dist > 80)
    {
        shake := Max(0, shake - 40)
    }
    else if (dist >= 4)   ; ignore tiny noise
    {
        ; Small movement contributes only a little
        if (dist >= 4 && dist <= 60)
        {
            if (reversal)
                shake += 180
        }
    
        ; Direction reversals are what really matter
        if (reversal > 0)
            shake += reversal * 180
    }

    ; Passive decay so shake doesn't stay forever
    shake := Max(0, shake - 8)

    ; Cap
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

    radius := 6 + progress * 10
    angle := A_TickCount / 40

    Glow.Move(
        Round(x - 12 + Cos(angle) * radius),
        Round(y - 12 + Sin(angle) * radius)
    )

    Glow.Show("NA")

    ;--------------------------------------------
    ; Glyph cycling (visual feedback)
    ;--------------------------------------------

    GlyphIndex++
    if (GlyphIndex > Glyphs.Length)
        GlyphIndex := 1

    Glyph.Text := Glyphs[Random(1, Glyphs.Length)]

    Hue += 5
    if (Hue >= 360)
        Hue := 0

    r := Round(127 * (Sin((Hue) * 0.01745) + 1))
    g := Round(127 * (Sin((Hue + 120) * 0.01745) + 1))
    b := Round(127 * (Sin((Hue + 240) * 0.01745) + 1))

    Glyph.Opt("c" Format("{:02X}{:02X}{:02X}", r, g, b))

    ;--------------------------------------------
    ; Smooth ramp (feels less jittery)
    ;--------------------------------------------

    pulse := Sin(progress * 6.283) ; full cycle
    pulse := Abs(pulse)

    alpha := 80 + Round(175 * (pulse ** 1.8))
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