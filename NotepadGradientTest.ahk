#Requires AutoHotkey v2.0
#Include Gdip_All.ahk

pToken := Gdip_Startup()

overlayGui := Gui("+LastFound +AlwaysOnTop -Caption +ToolWindow +E0x80020")
overlayGui.Show("x300 y300 w400 h300 NA")

w := 400, h := 300
hbm := CreateDIBSection(w, h)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
pGraphics := Gdip_GraphicsFromHDC(hdc)
Gdip_GraphicsClear(pGraphics, 0x80FF0000)

UpdateLayeredWindow(overlayGui.Hwnd, hdc, , , w, h, 255)

SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(pGraphics)

MsgBox "Check for a translucent red box at (300,300)"