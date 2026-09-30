#Requires AutoHotkey v2.0
#SingleInstance Force

; ---------------------------------------------------------------
; DIFFSELECT — capture two text selections, diff them, show it fast
;
; Ctrl+Alt+D       : capture selected text -> slot A
;                    (press again over different text) -> slot B,
;                    auto-runs `git diff --no-index` on A vs B,
;                    pops the diff up in a light GUI, clears slots
; Ctrl+Alt+Shift+D : manual reset -- clears slot A/B if you captured
;                    A and bailed before ever doing side B
; Ctrl+Win+D       : force-closes the popup and clears both temp
;                    files regardless of state, no matter what has
;                    focus. Note: Ctrl+Win+D is normally Windows'
;                    "new virtual desktop" shortcut -- this script's
;                    hook takes priority, but rebind below if you
;                    ever see a phantom desktop appear.
;
; Requires git.exe in PATH.
; ---------------------------------------------------------------

TempA := A_Temp "\diffselect_a.txt"
TempB := A_Temp "\diffselect_b.txt"
ResultFile := A_Temp "\diffselect_result.txt"
global CurrentDiffGui := 0

CaptureSelection() {
    savedClip := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(0.5) {
        A_Clipboard := savedClip
        return ""
    }
    text := A_Clipboard
    A_Clipboard := savedClip
    return text
}

FlashTip(msg, ms := 1800) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -ms)
}

CloseCurrentDiff(*) {
    global CurrentDiffGui
    if CurrentDiffGui {
        try CurrentDiffGui.Destroy()
        CurrentDiffGui := 0
    }
}

ShowDiffPopup(diffText) {
    global CurrentDiffGui
    CloseCurrentDiff()

    g := Gui("+AlwaysOnTop -Caption +Border +ToolWindow", "Diff")
    g.BackColor := "1e1e1e"
    g.MarginX := 6
    g.MarginY := 6

    lineCount := Max(StrSplit(diffText, "`n").Length, 3)
    width := Min(900, A_ScreenWidth - 80)
    height := Min(lineCount * 17 + 20, A_ScreenHeight - 120)

    edit := g.Add("Edit", "ReadOnly -Wrap +VScroll w" width " h" height
        " Background1e1e1e c00FF66", diffText)
    edit.SetFont("s10", "Consolas")

    g.Show("x" (A_ScreenWidth - width - 40) " y40")

    CurrentDiffGui := g
}

^#d:: {
    text := CaptureSelection()
    if (text = "") {
        FlashTip("DiffSelect: nothing selected / copy failed")
        return
    }

    if !FileExist(TempA) {
        FileAppend(text, TempA, "UTF-8")
        FlashTip("DiffSelect: slot A captured. Select side B and hit Ctrl+Alt+D again.", 2200)
        return
    }

    if FileExist(TempB)
        FileDelete(TempB)
    FileAppend(text, TempB, "UTF-8")

    if FileExist(ResultFile)
        FileDelete(ResultFile)

    cmd := 'cmd.exe /c git diff --no-index --no-prefix "' TempA '" "' TempB '" > "' ResultFile '" 2>&1'
    RunWait(cmd, , "Hide")

    diffText := ""
    if FileExist(ResultFile)
        diffText := FileRead(ResultFile, "UTF-8")

    if (diffText = "")
        diffText := "(No differences found)"

    ShowDiffPopup(diffText)

    ; clear slots either way, popup or not
    if FileExist(TempA)
        FileDelete(TempA)
    if FileExist(TempB)
        FileDelete(TempB)
}

^+!d:: {
    if FileExist(TempA)
        FileDelete(TempA)
    if FileExist(TempB)
        FileDelete(TempB)
    FlashTip("DiffSelect: slots cleared.")
}

^+#d:: {
    CloseCurrentDiff()
    if FileExist(TempA)
        FileDelete(TempA)
    if FileExist(TempB)
        FileDelete(TempB)
    FlashTip("DiffSelect: popup closed, slots cleared.")
}
