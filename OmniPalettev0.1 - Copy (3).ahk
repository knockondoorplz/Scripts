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

; FIX 1: Pass the function object directly, not a string name
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

^!l::AppendToLastNote()
^+!l::PrependToLastNote()
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
    if !FileExist(path)
    {
        SplitPath(path, &name, &folder, &ext, &nameNoExt)
        return {
            Name:      name,
            Folder:    folder,
            Path:      path,
            Extension: ext,
            Created:   "",
            Modified:  ""
        }
    }

    SplitPath(path, &name, &folder, &ext, &nameNoExt)

    return {
        Name:      name,
        Folder:    folder,
        Path:      path,
        Extension: ext,
        Created:   FileGetTime(path,"C"),
        Modified:  FileGetTime(path,"M")
    }
}

NormalizeNotes(arr)
{
    out := []

    for _, note in arr
    {
        if HasProp(note, "Path") || (Type(note) = "Map" && note.Has("Path"))
        {
            out.Push(MakeNote(note["Path"]))
            continue
        }

        if Type(note) = "String"
        {
            out.Push(MakeNote(note))
            continue
        }

        if HasProp(note, "Name") && HasProp(note, "Folder")
        {
            out.Push(note)
            continue
        }
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

    if (path = "" || !FileExist(path))
        return

    arr := []

    if FileExist(RecentFile)
        arr := JSON.parse(FileRead(RecentFile))

    for i, note in arr
    {
        if note["Path"] = path
        {
            arr.RemoveAt(i)
            break
        }
    }

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

    for i, f in favs
    {
        if f["Path"] = path
        {
            favs.RemoveAt(i)
            goto SaveFavs
        }
    }

    favs.Push(MakeNote(path))

SaveFavs:
    if FileExist(FavoritesFile)
        FileDelete(FavoritesFile)

    FileAppend(JSON.stringify(favs), FavoritesFile, "UTF-8")
}

; ==========================
; HELPERS
; ==========================

GetSelectedText(restoreGui := true)
{
    global PaletteGui

    ; If calling from GUI, minimize interference while grabbing clipboard
    if IsObject(PaletteGui) && PaletteGui.Hwnd
        PaletteGui.Hide()

    Sleep(50)

    clipSaved := ClipboardAll()
    A_Clipboard := ""

    Send("{Ctrl Up}{Alt Up}{Shift Up}{LWin Up}{RWin Up}")
    Sleep(30)
    Send("^c")

    if !ClipWait(0.4)
    {
        A_Clipboard := clipSaved
        if restoreGui && IsObject(PaletteGui)
            PaletteGui.Show()
        return ""
    }

    text := A_Clipboard
    A_Clipboard := clipSaved

    ; FIX 2: Explicitly restore GUI if requested
    if restoreGui && IsObject(PaletteGui)
        PaletteGui.Show()

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

;---------------------------
; SEND SIGNAL TO BIOME
;---------------------------

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
        folder := selected.Folder
    }

    path := folder "\" name ".md"

    FileAppend("# " name "`n`n", path)
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

    sel := GetSelected()
    if (sel != "")
        return sel

    if (LastNotePath != "")
        return LastNotePath

    return TargetFile
}

AppendSelection()
{
    global LastNotePath

    path := GetAppendTarget()
    if (path = "")
        return MsgBox("No append target found.")

    text := GetSelectedText(true)
    if (text = "")
        return MsgBox("No text was copied/selected.")

    try {
        f := FileOpen(path, "a", "UTF-8")
        f.Write("`r`n" text "`r`n")
        f.Close()
        TrayTip("OmniPalette", "Appended to " path, 1)
    } catch as Err {
        return MsgBox("Failed to append to file: " Err.Message)
    }

    LastNotePath := path
    AddRecent(path)
    SendBiomeSignal("note_append", path, text)
}

PrependSelection()
{
    global LastNotePath

    path := GetAppendTarget()
    if (path = "")
        return MsgBox("No target note selected.")

    text := GetSelectedText(true)
    if (text = "")
        return MsgBox("No text was copied/selected.")

    old := ""
    try old := FileRead(path, "UTF-8")

    try {
        f := FileOpen(path, "w", "UTF-8")
        f.Write(text "`r`n" old)
        f.Close()
        TrayTip("OmniPalette", "Prepended to " path, 1)
    } catch as Err {
        return MsgBox("Failed to update target file: " Err.Message)
    }

    LastNotePath := path
    AddRecent(path)
    SendBiomeSignal("note_prepend", path, text)
}

; ==========================
; HOTKEYS IMPLEMENTATION
; ==========================

AppendToLastNote() {
    global LastNotePath

    if (LastNotePath = "")
        return MsgBox("No last note active yet.")

    text := GetSelectedText(false)
    if (text = "")
        return MsgBox("No text selected to append.")

    try {
        f := FileOpen(LastNotePath, "a", "UTF-8")
        f.Write("`r`n" text "`r`n")
        f.Close()
        TrayTip("OmniPalette", "Appended to last note", 1)
    } catch as Err {
        return MsgBox("Append failed: " Err.Message)
    }

    SendBiomeSignal("note_append", LastNotePath, text)
    AddRecent(LastNotePath)
}

PrependToLastNote() {
    global LastNotePath

    if (LastNotePath = "")
        return MsgBox("No last note active yet.")

    text := GetSelectedText(false)
    if (text = "")
        return MsgBox("No text selected to prepend.")

    content := ""
    try content := FileRead(LastNotePath, "UTF-8")

    try {
        f := FileOpen(LastNotePath, "w", "UTF-8")
        f.Write(text "`r`n" content)
        f.Close()
        TrayTip("OmniPalette", "Prepended to last note", 1)
    } catch as Err {
        return MsgBox("Prepend failed: " Err.Message)
    }

    SendBiomeSignal("note_prepend", LastNotePath, text)
    AddRecent(LastNotePath)
}

AppendCode() {
    global TargetFile

    text := GetSelectedText(false)
    if (text = "")
        return MsgBox("No text selected for Code note.")

    try {
        f := FileOpen(TargetFile, "a", "UTF-8")
        f.Write("`r`n" text "`r`n")
        f.Close()
        TrayTip("OmniPalette", "Appended to Code Scratchbox", 1)
    } catch as Err {
        return MsgBox("Code append failed: " Err.Message)
    }

    SendBiomeSignal("code_append", TargetFile, text)
    AddRecent(TargetFile)
}

PrependCode() {
    global TargetFile

    text := GetSelectedText(false)
    if (text = "")
        return MsgBox("No text selected for Code note.")

    contents := ""
    try contents := FileRead(TargetFile, "UTF-8")

    try {
        f := FileOpen(TargetFile, "w", "UTF-8")
        f.Write(text "`r`n" contents)
        f.Close()
        TrayTip("OmniPalette", "Prepended to Code Scratchbox", 1)
    } catch as Err {
        return MsgBox("Code prepend failed: " Err.Message)
    }

    SendBiomeSignal("code_prepend", TargetFile, text)
    AddRecent(TargetFile)
}