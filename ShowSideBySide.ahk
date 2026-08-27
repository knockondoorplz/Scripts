#Persistent

; Define variables
sideBySide = 80% ; Width percentage for side-by-side window arrangement
margin = 15 % ; Margin between windows

; Function to resize windows to fit side-by-side layout
ResizeWindows() {
    WinGet title, ahk_class, ahk_exe explorer.exe
    For win in title {
        WinActivate, %win%
        WinGet mmSize, mmsize, ahk_idahkui
        WinSet mmSize, 100% - sideBySide * mmSize / 100%, ahk_idahkui
        WinMove, ahk_idahkui, , (WinGet mmPos, x), (WinGet mmPos, y) + winGet mmSize, ahk_idahkui
    }
}

; Function to show windows side by side
ShowSideBySide() {
    ; Get all open windows
    WinGet title, ahk_class, ahk_exe explorer.exe
    For win in title {
        WinActivate, %win%
        WinGet mmSize, mmsize, ahk_idahkui
        WinSet mmSize, 100% - sideBySide * mmSize / 100%, ahk_idahkui
        WinMove, ahk_idahkui, , (WinGet mmPos, x), (WinGet mmPos, y) + winGet mmSize, ahk_idahkui

        ; Get window coordinates and size
        WinGet mmX, mmx, ahk_idahkui
        WinGet mmY, mmy, ahk_idahkui
        WinGet mmW, mmw, ahk_idahkui
        WinGet mmH, mmh, ahk_idahkui

        ; Calculate the side-by-side arrangement
        For i from 0 to (Len(title) - 1) {
            For j from (i + 1) to (Len(title) - 1) {
                If (j == (Len(title) - 1)) {
                    Break
                }
                WinGet mmSize, mmsize, ahk_idahkui
                WinSet mmSize, sideBySide * mmSize / Len(title), ahk_idahkui

                ; Calculate the position and size for the next window
                newWinX := mmX + (j - i) * (mmW + margin)
                newWinY := mmY
                newWinW := mmW
                newWinH := mmH

                ; Create a new window to hold the side-by-side arrangement
                WinCreate, , SideBySideWindow, %newWinX%, %newWinY%, %newWinW%, %newWinH%
                WinMove, SideBySideWindow, ahk_idahkui, (mmX + j * (mmW + margin)), (mmY), mmW, mmH

                ; Add the new window to the existing one
                WinActivate, SideBySideWindow, ahk_idahkui
                WinMove, SideBySideWindow, ahk_idahkui, (WinGet mmPos, x) + (j - i) * (mmW + margin), (WinGet
mmPos, y), mmW, mmH

                ; Remove the original window from the side-by-side arrangement
                WinClose, %win%
            }
        }
    }
}

; Main loop to continuously check for changes and resize windows
while 1 {
    ShowSideBySide()
    Sleep, 5000 ; Check every 5 seconds
}