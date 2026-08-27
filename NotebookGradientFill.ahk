#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Gdip_All.ahk

pToken := Gdip_Startup()
OnExit((*) => Gdip_Shutdown(pToken))

overlayEnabled := true
intensity := 200
overlays := Map()
SetTimer(SyncOverlays, 150)

; add near the top with your other globals:
phase := 0
SetTimer(AnimatePhase, 80)

; ---------- Toggle & intensity hotkeys ----------

#!g::ToggleOverlay()
^+,::AdjustIntensity(-20)
^+.::AdjustIntensity(20)

ToggleOverlay() {
    global overlayEnabled, overlays
    overlayEnabled := !overlayEnabled
    if !overlayEnabled {
        for hwnd, ov in overlays.Clone() {
            try ov.gui.Destroy()
            overlays.Delete(hwnd)
        }
    }
    ToolTip("Rainbow overlay: " (overlayEnabled ? "ON" : "OFF"))
    SetTimer(() => ToolTip(), -700)
}

AdjustIntensity(delta) {
    global intensity, overlays
    intensity := Max(30, Min(255, intensity + delta))
    for hwnd, ov in overlays {
        DrawGradient(ov.gui.Hwnd, ov.w, ov.h)
    }
    ToolTip("Intensity: " intensity)
    SetTimer(() => ToolTip(), -700)
}

; ---------- Notepad rainbow overlay ----------

SyncOverlays() {
    global overlayEnabled, overlays
    if !overlayEnabled
        return
    active := Map()
    for hwnd in WinGetList("ahk_class Notepad") {
        if !WinExist("ahk_id " hwnd) || WinGetMinMax("ahk_id " hwnd) = -1
            continue
        active[hwnd] := true
        if !overlays.Has(hwnd) {
            try overlays[hwnd] := MakeOverlay(hwnd)
        } else {
            UpdateOverlay(hwnd, overlays[hwnd])
        }
    }
    for hwnd, ov in overlays.Clone() {
        if !active.Has(hwnd) {
            try ov.gui.Destroy()
            overlays.Delete(hwnd)
        }
    }
}

MakeOverlay(npHwnd) {
    WinGetPos(&x, &y, &w, &h, "ahk_id " npHwnd)
    g := Gui("+LastFound -Caption +ToolWindow +E0x80020")  ; note: +AlwaysOnTop removed
    g.Show("x" x " y" y " w" w " h" h " NA")
    DrawGradient(g.Hwnd, w, h)
    return {gui: g, w: w, h: h}
}

; replace +AlwaysOnTop with this — pins overlay directly above the Notepad window in z-order, nothing else
UpdateOverlay(npHwnd, ov) {
    WinClientGetPos(&x, &y, &w, &h, "ahk_id " npHwnd)
    if (w != ov.w || h != ov.h) {
        DrawGradient(ov.gui.Hwnd, w, h)
        ov.w := w, ov.h := h
    }
    ; SWP_NOSIZE=1, SWP_NOACTIVATE=0x10 — move+resize normally, then re-stack right above Notepad
    DllCall("SetWindowPos", "Ptr", ov.gui.Hwnd, "Ptr", npHwnd
        , "Int", x, "Int", y, "Int", w, "Int", h, "UInt", 0x10)
}

AnimatePhase() {
    global phase, overlays
    phase := Mod(phase + 4, 360)
    for hwnd, ov in overlays
        DrawGradient(ov.gui.Hwnd, ov.w, ov.h)
}

DrawGradient(hwnd, w, h) {
    global intensity, phase
    cx := w / 2, cy := h / 2
    hbm := CreateDIBSection(w, h)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    pGraphics := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(pGraphics, 4)
    Gdip_GraphicsClear(pGraphics, 0x00000000)

    ; pop-pulse: eases outward then snaps back, driven by phase
    t := Mod(phase, 180) / 180          ; 0..1 sawtooth
    pulse := 1 + 1.5 * (t / (1.01 - t)) ; asymptotic stretch as t nears 1
    pulse := Min(pulse, 6)               ; clamp so it doesn't blow past the window

    baseR := Min(w, h) * 0.35
    steps := 300
    Loop steps {
        a := (A_Index / steps) * 2 * 3.14159 * 3   ; 3 loops around
        freqX := 3, freqY := 2                      ; Lissajous ratio — change for different knot shapes
        r := baseR * (0.6 + 0.4 * Sin(freqY * a + phase/40)) * pulse
        x := cx + r * Cos(freqX * a + phase/60)
        y := cy + r * Sin(a)
        hue := Mod((a * 30) + phase, 360)
        col := HSVtoARGB(hue, 1.0, 1.0, intensity)
        pPen := Gdip_CreatePen(col, 1)
        if (A_Index > 1)
            Gdip_DrawLine(pGraphics, pPen, prevX, prevY, x, y)
        Gdip_DeletePen(pPen)
        prevX := x, prevY := y
    }

    UpdateLayeredWindow(hwnd, hdc, , , w, h, 255)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(pGraphics)
}
