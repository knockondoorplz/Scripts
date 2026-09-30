#Requires AutoHotkey v2.0

transStep := 15
transMin := 40
transMax := 255

^#,::AdjustTransparency(-transStep)
^#.::AdjustTransparency(transStep)

AdjustTransparency(delta) {
    global transMin, transMax
    trans := WinGetTransparent("A")
    if (trans = "")
        trans := 255
    trans := Max(transMin, Min(transMax, trans + delta))
    WinSetTransparent(trans, "A")
    ToolTip("Transparency: " trans)
    SetTimer(() => ToolTip(), -700)  ; auto-clear tooltip after 0.7s
}

#!t::  ; Win+Alt+T toggles transparency on active window
{
    trans := WinGetTransparent("A")
    if (trans = "" or trans = 255)
        WinSetTransparent(200, "A")  ; ~78% opacity
    else
        WinSetTransparent(255, "A")  ; fully opaque
}
