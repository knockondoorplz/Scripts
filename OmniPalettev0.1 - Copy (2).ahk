#Requires AutoHotkey v2.0
#SingleInstance Force
#Include JSON.ahk

; ==========================
; OmniPalette v0.1
; AHK v2.0.26
; ==========================

VaultRoot   := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃"
TargetFile  := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\Some @%$! Code\Some @%$! Code.md"

FavoritesFile := A_ScriptDir "\favorites.json"
RecentFile    := A_ScriptDir "\recent.json"

global CurrentTab      := "Search"
global Notes           := []
global DisplayedNotes  := []
global PaletteGui      := ""
global SearchBox       := ""
global NoteList        := ""
global Buttons         := Map()
global LastNotePath    := ""

OnMessage(0x24, WM_GETMINMAXINFO)

; ==========================
; HOTKEYS
; ==========================

!Space::
{
    global PaletteGui

    if IsObject(PaletteGui)
    {
        try {
            PaletteGui.Destroy()
            PaletteGui := ""
            return
        }
    }

    ShowOmniPalette()
}

Esc::
{
    if IsObject(PaletteGui)
        PaletteGui.Hide()
}

^#a::AppendToLastNote()
^!a::PrependToLastNote()
^+!c::AppendCode()
^+#c::PrependCode()

; ==========================
; SHOW GUI
; ==========================

ShowOmniPalette()
{
    global Notes
    global PaletteGui
    global SearchBox
    global NoteList
    global Buttons

    Notes := LoadNotes()

    if IsObject(PaletteGui)
        PaletteGui.Destroy()

    PaletteGui := Gui("+AlwaysOnTop +ToolWindow +Resize")
    PaletteGui.BackColor := "202020"
    PaletteGui.OnEvent("Size", PaletteResize)

    WinSetTransparent(210, PaletteGui.Hwnd)

    DragBar := PaletteGui.Add("Text", "x0 y0 w620 h0 0x4 cWhite", "  OmniPalette")
    DragBar.OnEvent("Click", DragWindow)

    ; SEARCH BOX
    SearchBox := PaletteGui.Add("Edit", "x10 y30 w360 h30", "")
    SearchBox.OnEvent("Change", RefreshList)

    ; TABS
    PaletteGui.Add("Button", "x10 y70 w80", "Search")
        .OnEvent("Click", (*) => SwitchTab("Search"))

    PaletteGui.Add("Button", "x95 y70 w80", "Recent")
        .OnEvent("Click", (*) => SwitchTab("Recent"))

    PaletteGui.Add("Button", "x180 y70 w80", "Favorites")
        .OnEvent("Click", (*) => SwitchTab("Favorites"))

    ; LISTVIEW
    NoteList := PaletteGui.Add("ListView", "x10 y110 w600 h250", ["Name","Folder"])
    NoteList.SetFont("s8","Segoe UI")
    NoteList.ModifyCol(1,200)
    NoteList.ModifyCol(2,600)

    NoteList.OnEvent("DoubleClick", (*) => OpenSelected())

    ; ACTION BUTTONS
    Buttons["Open"] := PaletteGui.Add("Button", "x10 y370 w70", "Open")
    Buttons["Open"].OnEvent("Click", (*) => OpenSelected())

    Buttons["Append"] := PaletteGui.Add("Button", "x90 y370 w70", "Append")
    Buttons["Append"].OnEvent("Click", (*) => AppendSelection())

    Buttons["Prepend"] := PaletteGui.Add("Button", "x170 y370 w70", "Prepend")
    Buttons["Prepend"].OnEvent("Click", (*) => PrependSelection())

    Buttons["Create"] := PaletteGui.Add("Button", "x250 y370 w70", "Create")
    Buttons["Create"].OnEvent("Click", (*) => CreateNote())
	
	Buttons["Favorite"] := PaletteGui.Add("Button", "x330 y370 w70", "Favorite")
    Buttons["Favorite"].OnEvent("Click", (*) => ToggleFavorite())

    PaletteGui.Show("w620 h430")
    RefreshList()
}

; ==========================
; DRAG + RESIZE
; ==========================

DragWindow(ctrl,*)
{
    PostMessage(0xA1, 2, , , ctrl.Gui.Hwnd)
}

PaletteResize(gui, MinMax, Width, Height)
{
    global SearchBox
    global NoteList
    global Buttons

    SearchBox.Move(10, 30, Width-20)

    listHeight := Max(120, Height-180)
    NoteList.Move(10, 110, Width-20, listHeight)

    Buttons["Open"].Move(10, Height-50)
    Buttons["Append"].Move(90, Height-50)
    Buttons["Prepend"].Move(170, Height-50)
    Buttons["Create"].Move(250, Height-50)
	Buttons["Favorite"].Move(330, Height-50)
}

WM_GETMINMAXINFO(wParam, lParam, *)
{
    NumPut("Int",620, lParam+24)
    NumPut("Int",430, lParam+28)
}

; ==========================
; TABS + LIST
; ==========================

SwitchTab(tab)
{
    global CurrentTab
    CurrentTab := tab
    RefreshList()
}

RefreshList(*)
{
    global DisplayedNotes
    global Notes
    global CurrentTab
    global SearchBox
    global NoteList

    DisplayedNotes := []

    if CurrentTab = "Favorites"
    {
        DisplayedNotes := LoadFavorites()
    }
    else if CurrentTab = "Recent"
    {
        DisplayedNotes := LoadRecent()
    }
    else
    {
        search := StrLower(Trim(SearchBox.Value))

        for note in Notes
        {
            if (search = "")
            {
                DisplayedNotes.Push(note)
                continue
            }

            if (InStr(StrLower(note.Name), search)
             || InStr(StrLower(note.Path), search))

            {
                DisplayedNotes.Push(note)
            }
        }
    }

    NoteList.Delete()

    for note in DisplayedNotes
    {
        SplitPath(note.Path, , &dir)
        NoteList.Add("", note.Name, dir)
    }
}

; ==========================
; NOTE MODEL + LOAD
; ==========================

MakeNote(path)
{
    SplitPath(path, &name, &folder, &ext, &nameNoExt)

    return {
        Name:     name,
        Folder:   folder,
        Path:     path,
        Extension: ext,
        Created:  FileGetTime(path,"C"),
        Modified: FileGetTime(path,"M")
    }
}

NormalizeNotes(arr)
{
    out := []

    for _, note in arr
    {
        if note.Has("Path")
            out.Push(MakeNote(note["Path"]))
    }

    return out
}

LoadNotes()
{
    global VaultRoot

    files := []

    Loop Files VaultRoot "\*.md", "R"
    {
        files.Push(MakeNote(A_LoopFileFullPath))
    }

    return files
}

; ==========================
; FAVORITES / RECENT
; ==========================

LoadRecent()
{
    global RecentFile

    if !FileExist(RecentFile)
        return []

    return NormalizeNotes(
        JSON.parse(FileRead(RecentFile))
    )
}

AddRecent(path)
{
    global RecentFile

    arr := []

    if FileExist(RecentFile)
        arr := JSON.parse(FileRead(RecentFile))

    ; remove existing
    for i, note in arr
    {
        if note["Path"] = path
        {
            arr.RemoveAt(i)
            break
        }
    }

    ; insert at top
    arr.InsertAt(1, MakeNote(path))

    while arr.Length > 20
        arr.Pop()

    if FileExist(RecentFile)
        FileDelete(RecentFile)

    FileAppend(JSON.stringify(arr), RecentFile, "UTF-8")
}


LoadFavorites()
{
    global FavoritesFile

    if !FileExist(FavoritesFile)
        return []

    return NormalizeNotes(
        JSON.parse(FileRead(FavoritesFile))
    )
}

ToggleFavorite()
{
    global FavoritesFile
    global DisplayedNotes
    global NoteList

    row := NoteList.GetNext()
    if !row
        return

    note := DisplayedNotes[row]
    path := note.Path
    if (path = "")
        return

    favs := []
    if FileExist(FavoritesFile)
        favs := JSON.parse(FileRead(FavoritesFile))

    ; remove if exists
    for i, f in favs
    {
        if f["Path"] = path
        {
            favs.RemoveAt(i)
            goto SaveFavs
        }
    }

    ; otherwise add
    favs.Push(MakeNote(path))

SaveFavs:
    if FileExist(FavoritesFile)
        FileDelete(FavoritesFile)

    FileAppend(JSON.stringify(favs), FavoritesFile, "UTF-8")
}

; ==========================
; HELPERS
; ==========================

GetSelectedText()
{
    clipSaved := ClipboardAll()
    A_Clipboard := ""

    Send("^c")

    if !ClipWait(0.5)
    {
        A_Clipboard := clipSaved
        return ""
    }

    text := A_Clipboard
    A_Clipboard := clipSaved
    return text
}

GetSelected()
{
    global DisplayedNotes
    global NoteList

    row := NoteList.GetNext()
    if !row
        return ""

    return DisplayedNotes[row].Path
}

SendBiomeSignal(eventType, path, selectedText := "")
{
    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")

        payload := Format(
        '{{"event_type":"{1}","path_or_node_id":"{2}","selected_text":"{3}"}}',
        eventType,
        StrReplace(path,'"','\"'),
        StrReplace(SubStr(selectedText,1,300),'"','\"')
        )

        req.Open("POST", "http://127.0.0.1:8000/context/signal", false)
        req.SetRequestHeader("Content-Type", "application/json")
        req.Send(payload)
    }
}

; ==========================
; ACTIONS
; ==========================

OpenSelected()
{
    global LastNotePath

    path := GetSelected()
    if (path = "")
        return

    Run("notepad.exe " path)
    LastNotePath := path
    AddRecent(path)
    SendBiomeSignal("note_open", path)
}

CreateNote()
{
    global VaultRoot
    global DisplayedNotes
    global NoteList

    result := InputBox("Name:", "Create Note")
    if result.Result != "OK"
        return

    name := result.Value

    row := NoteList.GetNext()
    folder := VaultRoot

    if row
    {
        selected := DisplayedNotes[row]
        folder := selected["Folder"] ; map access
    }

    path := folder "\" name ".md"

    FileAppend("# " . name . "`r`n`r`n", path)
    Run("notepad.exe " path)
	
    AddRecent(path)
    SendBiomeSignal("note_create", path)
}

; ==========================
; APPEND/PREPEND
; ==========================

GetAppendTarget()
{
    global LastNotePath
    global TargetFile

    ; 1. Selected note
    sel := GetSelected()
    if (sel != "")
        return sel

    ; 2. Last note
    if (LastNotePath != "")
        return LastNotePath

    ; 3. Fallback target file
    return TargetFile
}

AppendSelection()
{
    global LastNotePath

    path := GetAppendTarget()
    if (path = "")
        return

    text := GetSelectedText()
    if (text = "")
        return

    FileAppend("`r`n" text "`r`n", path, "UTF-8")

    LastNotePath := path
    AddRecent(path)
    SendBiomeSignal("note_append", path, text)
}

PrependSelection()
{
    global LastNotePath

    path := GetAppendTarget()
    if (path = "")
        return

    text := GetSelectedText()
    if (text = "")
        return

    old := FileRead(path, "UTF-8")

    FileDelete(path)
    FileAppend(text "`r`n`r`n" old, path, "UTF-8")

    LastNotePath := path
    AddRecent(path)
    SendBiomeSignal("note_prepend", path, text)
}

AppendToLastNote() {
    global LastNotePath

    if (LastNotePath = "")
        return MsgBox("No last note yet.")

    text := A_Clipboard
    if (text = "")
        return MsgBox("Clipboard empty.")

    FileAppend("`r`n" text "`r`n", LastNotePath, "UTF-8")
    SendBiomeSignal("note_append", LastNotePath, text)
    AddRecent(LastNotePath)
}

PrependToLastNote() {
    global LastNotePath

    if (LastNotePath = "")
        return MsgBox("No last note yet.")

    text := A_Clipboard
    if (text = "")
        return MsgBox("Clipboard empty.")

    content := ""
    try content := FileRead(LastNotePath, "UTF-8")

    FileDelete(LastNotePath)
    FileAppend(text "`r`n" content, LastNotePath, "UTF-8")
    SendBiomeSignal("note_prepend", LastNotePath, text)
    AddRecent(LastNotePath)
}

AppendCode() {
    global TargetFile

    text := GetSelectedText()
    if (text = "")
        return

    FileAppend("`r`n" text "`r`n", TargetFile, "UTF-8")
    SendBiomeSignal("code_append", TargetFile, text)
    AddRecent(TargetFile)
}

PrependCode() {
    global TargetFile

    text := GetSelectedText()
    if (text = "")
        return

    contents := ""
    try contents := FileRead(TargetFile, "UTF-8")

    FileDelete(TargetFile)
    FileAppend(text "`r`n" contents, TargetFile, "UTF-8")
    SendBiomeSignal("code_prepend", TargetFile, text)
    AddRecent(TargetFile)
}
