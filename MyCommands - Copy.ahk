; Press Ctrl + Shift + H to see what you CAN press
^+h::
FileLocation := "C:\Users\brigi\Documents\Jason\Scripts\All_My_Hotkeys.txt"

if !FileExist(FileLocation) {
    MsgBox, 16, Error, Run the PowerShell script first to build the map!
    return
}

; Read the hotkey map file
FileRead, LoadedKeys, %FileLocation%

; Toggle behavior: If the window exists, close it. If not, open it.
if WinExist("My Commands Workspace") {
    Gui, Destroy
    return
}

; Build a beautiful, minimal HUD window
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, 1A1A1A
Gui, Font, s11 c00FFCC, Consolas

; Add header text
Gui, Add, Text,, == CURRENT WORKSPACE ENVIRONMENT CAPABILITIES ==
Gui, Add, Text,, Press ESC or Ctrl+Shift+H to close this overlay.
Gui, Add, Text,, ---------------------------------------------------------------------

; Add the scrollable commands text
Gui, Font, s10 cFFFFFF, Consolas
Gui, Add, Edit, r25 w700 ReadOnly -E0x200 vScroll background1A1A1A, %LoadedKeys%

Gui, Show,, My Commands Workspace
return

; Hit Escape or change focus to clear the mental plane
GuiEscape:
GuiClose:
Gui, Destroy
return