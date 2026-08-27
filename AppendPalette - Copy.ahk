#Requires AutoHotkey v2.0

; ---------------------------------------------------------
; CONFIG
; ---------------------------------------------------------
VaultRoot := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃"
Global NotesList := []
Global LastNotePath := ""
Global PaletteGui, SearchEdit, NotesListBox
Global PreviewGui, PreviewEdit

; ---------------------------------------------------------
; HOTKEYS
; ---------------------------------------------------------

; Win+Shift+A → open palette
#+a::OpenPalette()

; Ctrl+Win+A → append clipboard to last selected note
^#a:: {
    global LastNotePath
    if (LastNotePath = "")
        return MsgBox("No last note yet.")

    text := A_Clipboard
    if (text = "")
        return MsgBox("Clipboard empty.")

    FileAppend("`r`n" text "`r`n", LastNotePath, "UTF-8")
}

; ---------------------------------------------------------
; MAIN PALETTE
; ---------------------------------------------------------

OpenPalette() {
    global PaletteGui, SearchEdit

    if !IsSet(PaletteGui) {
        BuildPaletteGui()
        LoadNotes()
    }

    SearchEdit.Value := ""
    RefreshNotesList("")
    PaletteGui.Show("Center")
    SearchEdit.Focus()
}

BuildPaletteGui() {
    global PaletteGui, SearchEdit, NotesListBox

    PaletteGui := Gui("+AlwaysOnTop +ToolWindow +Resize")
    PaletteGui.BackColor := "0x202020"
    WinSetTransparent(220, PaletteGui.Hwnd)

    ; draggable bar
    DragBar := PaletteGui.Add("Text", "x0 y0 w400 h20 0x4 cWhite", "  Append Palette")
    DragBar.OnEvent("Click", DragWindow)

    PaletteGui.Add("Text", "x10 y30 cWhite", "Search:")
    SearchEdit := PaletteGui.Add("Edit", "x70 y28 w320")
    SearchEdit.OnEvent("Change", SearchChanged)

    NotesListBox := PaletteGui.Add("ListBox", "x10 y60 w380 h260")
    NotesListBox.OnEvent("Change", NoteSelected)

    PaletteGui.Add("Button", "x10 y330 w80", "Append").OnEvent("Click", AppendToNote)
    PaletteGui.Add("Button", "x100 y330 w80", "Prepend").OnEvent("Click", PrependToNote)
    PaletteGui.Add("Button", "x190 y330 w80", "Open").OnEvent("Click", OpenNote)
    PaletteGui.Add("Button", "x280 y330 w80", "Close").OnEvent("Click", (*) => PaletteGui.Hide())

    BuildPreviewGui()
}

DragWindow(Ctrl, *) {
    PostMessage(0xA1, 2,,, Ctrl.Gui.Hwnd)
}

; ---------------------------------------------------------
; PREVIEW WINDOW
; ---------------------------------------------------------

BuildPreviewGui() {
    global PreviewGui, PreviewEdit

    PreviewGui := Gui("+AlwaysOnTop +ToolWindow")
    PreviewGui.BackColor := "0x101010"
    WinSetTransparent(230, PreviewGui.Hwnd)

    PreviewEdit := PreviewGui.Add("Edit", "x0 y0 w400 h300 ReadOnly -Wrap")
    PreviewEdit.SetFont("s9", "Consolas")

    ; ESC closes preview
    PreviewGui.OnEvent("Escape", (*) => PreviewGui.Hide())
}

; ---------------------------------------------------------
; LOAD NOTES
; ---------------------------------------------------------

LoadNotes() {
    global NotesList, VaultRoot

    NotesList := []
    Loop Files, VaultRoot "\*.md", "R" {
        NotesList.Push({
            Path: A_LoopFileFullPath,
            Name: SubStr(A_LoopFileFullPath, StrLen(VaultRoot) + 2)
        })
    }
}

; ---------------------------------------------------------
; SEARCH
; ---------------------------------------------------------

SearchChanged(*) {
    global SearchEdit
    RefreshNotesList(Trim(SearchEdit.Value))
}

RefreshNotesList(term) {
    global NotesList, NotesListBox

    NotesListBox.Delete()
    lower := StrLower(term)

    for note in NotesList {
        if (term = "" || InStr(StrLower(note.Name), lower))
            NotesListBox.Add([note.Name])
    }
}

; ---------------------------------------------------------
; NOTE SELECTION + PREVIEW
; ---------------------------------------------------------

NoteSelected(*) {
    global NotesListBox, NotesList, PreviewGui, PreviewEdit, LastNotePath

    path := GetSelectedNotePath()

    idx := NotesListBox.Value
    if (idx = 0)
        return

    name := NotesListBox.Text
    full := ""

    for note in NotesList {
        if (note.Name = name) {
            full := note.Path
            break
        }
    }
    if (full = "")
        return

    LastNotePath := full

    content := ""
    try
        content := FileRead(path, "UTF-8")
    catch
        content := ""

    lines := StrSplit(content, "`n")
    maxLines := 80
    shown := ""
    i := 0
    for _, line in lines {
        i++
        if (i > maxLines)
            break
        shown .= line "`r`n"
    }

    PreviewEdit.Value := full "`r`n`r`n" shown
    PreviewGui.Show("x+420 yCenter")
}

; ---------------------------------------------------------
; ACTIONS
; ---------------------------------------------------------

GetSelectedNotePath() {
    global NotesListBox, NotesList

    idx := NotesListBox.Value
    if (idx = 0)
        return ""

    name := NotesListBox.Text
    for note in NotesList {
        if (note.Name = name)
            return note.Path
    }
    return ""
}

GetCapture() {
    return A_Clipboard
}

AppendToNote(*) {
    path := GetSelectedNotePath()
    if (path = "")
        return MsgBox("No note selected.")

    text := GetCapture()
    if (text = "")
        return MsgBox("Clipboard empty.")

    FileAppend("`r`n" text "`r`n", path, "UTF-8")
}

PrependToNote(*) {
    path := GetSelectedNotePath()
    if (path = "")
        return MsgBox("No note selected.")

    text := GetCapture()
    if (text = "")
        return MsgBox("Clipboard empty.")

    content := ""
    try
        content := FileRead(path, "UTF-8")
    catch
        content := ""

    FileDelete(path)
    FileAppend(text "`r`n`r`n" content, path, "UTF-8")
}

OpenNote(*) {
    path := GetSelectedNotePath()
    if (path = "")
        return MsgBox("No note selected.")

    Run(Format('notepad.exe "{1}"', path))
}
