; ==============================================================================
; 1. OPEN TERMINAL AT ACTIVE FILE EXPLORER LOCATION
; Shortcut: Ctrl + Alt + T
; ==============================================================================
^!t::
ExplorerPath := GetActiveExplorerPath()
if (ExplorerPath != "")
{
    Run, wt.exe -d "%ExplorerPath%"
}
else
{
    Run, wt.exe
}
return


; ==============================================================================
; 2. OPEN TERMINAL AT ACTIVE FILE EXPLORER LOCATION (AS ADMIN)
; Shortcut: Ctrl + Shift + Alt + T
; ==============================================================================
^+!t::
ExplorerPath := GetActiveExplorerPath()
if (ExplorerPath != "")
{
    Run, *RunAs wt.exe -d "%ExplorerPath%"
}
else
{
    Run, *RunAs wt.exe
}
return


; ==============================================================================
; 3. PLAIN OLD TERMINAL AS ADMIN (DEFAULT LOCATION / SCRIPTS)
; Shortcut: Ctrl + Win + T  (Replaces #!t to avoid transparency script conflict)
; ==============================================================================
^#t::
Run, *RunAs wt.exe
return


; ==============================================================================
; HELPER FUNCTION: GRAB ACTIVE FILE EXPLORER PATH (AHK v1 Compatible)
; ==============================================================================
GetActiveExplorerPath() {
    WinGet, hwnd, ID, A
    try {
        for window in ComObjCreate("Shell.Application").Windows {
            if (window.HWND == hwnd) {
                return window.Document.Folder.Self.Path
            }
        }
    }
    return ""
}