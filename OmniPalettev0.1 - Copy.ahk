#Requires AutoHotkey v2.0
#SingleInstance Force
#Include JSON.ahk

; ==========================
; OmniPalette v0.1
; AHK v2.0.26
; ==========================

VaultRoot := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃"
TargetFile := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\Some @%$! Code\Some @%$! Code.md"

FavoritesFile := A_ScriptDir "\favorites.json"
RecentFile := A_ScriptDir "\recent.json"


global CurrentTab := "Search"
global Notes := []
global DisplayedNotes:= []
global PaletteGui := ""
Global LastNotePath := ""
global SearchBox := ""
global NoteList := ""

global Buttons := Map()

OnMessage(0x24, WM_GETMINMAXINFO)

; ==========================
; HOTKEYS
; ==========================

!Space::
{
    global PaletteGui

    if IsObject(PaletteGui)
    {
        try
        {
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


; ==========================
; SHOW GUI
; ==========================

ShowOmniPalette()
{

global

Notes := LoadNotes()


if IsObject(PaletteGui)
{
    PaletteGui.Destroy()
}

PaletteGui := Gui("+AlwaysOnTop +ToolWindow +Resize")
PaletteGui.BackColor := "202020"

PaletteGui.OnEvent("Size", PaletteResize)

WinSetTransparent(210, PaletteGui.Hwnd)

DragBar := PaletteGui.Add("Text", "x0 y0 w620 h0 0x4 cWhite", "  OmniPalette")
    DragBar.OnEvent("Click", DragWindow)

; ---------------------------------------------------------
; SEARCH
; ---------------------------------------------------------

SearchBox := PaletteGui.Add(
    "Edit",
    "x10 y30 w360 h30",
    ""
)

SearchBox.OnEvent(
    "Change",
    RefreshList
)

; ---------------------------------------------------------
; TABS
; ---------------------------------------------------------

PaletteGui.Add(
    "Button",
    "x10 y70 w80",
    "Search"
).OnEvent(
    "Click",
    (*) => SwitchTab("Search")
)



PaletteGui.Add(
    "Button",
    "x95 y70 w80",
    "Recent"
).OnEvent(
    "Click",
    (*) => SwitchTab("Recent")
)



PaletteGui.Add(
    "Button",
    "x180 y70 w80",
    "Favorites"
).OnEvent(
    "Click",
    (*) => SwitchTab("Favorites")
)

; ---------------------------------------------------------
; LISTVIEW
; ---------------------------------------------------------

NoteList := PaletteGui.Add(
    "ListView",
    "x10 y110 w600 h250",
    ["Name","Folder"]
)

NoteList.SetFont("s8","Segoe UI")

NoteList.ModifyCol(1,200)
NoteList.ModifyCol(2,600)


NoteList.OnEvent(
    "DoubleClick",
    (*) => OpenSelected()
)

; ---------------------------------------------------------
; ACTION BUTTONS
; ---------------------------------------------------------

Buttons["Open"] := PaletteGui.Add(
    "Button",
    "x10 y370 w70",
    "Open"
)

Buttons["Open"].OnEvent(
    "Click",
    (*) => OpenSelected()
)



Buttons["Append"] := PaletteGui.Add(
    "Button",
    "x90 y370 w70",
    "Append"
)

Buttons["Append"].OnEvent(
    "Click",
    (*) => AppendSelected()
)



Buttons["Prepend"] := PaletteGui.Add(
    "Button",
    "x170 y370 w70",
    "Prepend"
)

Buttons["Prepend"].OnEvent(
    "Click",
    (*) => PrependSelected()
)



Buttons["Create"] := PaletteGui.Add(
    "Button",
    "x250 y370 w70",
    "Create"
)

Buttons["Create"].OnEvent(
    "Click",
    (*) => CreateNote()
)



PaletteGui.Show(
    "w620 h430"
)


RefreshList()

}

;---------------------------
; DRAGGABLE WINDOWS
;---------------------------

DragWindow(ctrl,*)
{
    PostMessage(
        0xA1,
        2,
        ,
        ,
        ctrl.Gui.Hwnd
    )
}

;---------------------------
; PALETTE RESIZE
;---------------------------

PaletteResize(gui, MinMax, Width, Height)
{
    global SearchBox
    global NoteList
    global Buttons

    SearchBox.Move(
        10,
        30,
        Width-20
    )
    
    listHeight := Max(120, Height-180)

    NoteList.Move(
        10,
        110,
        Width-20,
        listHeight
    )

    Buttons["Open"].Move(
        10,
        Height-50
    )

    Buttons["Append"].Move(
        90,
        Height-50
    )

    Buttons["Prepend"].Move(
        170,
        Height-50
    )

    Buttons["Create"].Move(
        250,
        Height-50
    )

}

WM_GETMINMAXINFO(wParam, lParam, *)
{
    NumPut("Int",620, lParam+24)
    NumPut("Int",430, lParam+28)
}

; ==========================
; TABS
; ==========================

SwitchTab(tab)
{

global CurrentTab

CurrentTab := tab

RefreshList()

}

; ==========================
; LIST UPDATE
; ==========================

RefreshList(*)
{

global DisplayedNotes

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
    if search = ""
    {
        DisplayedNotes.Push(note)
        continue
    }

    if (
        InStr(StrLower(note.Name), search)
     || InStr(StrLower(note.Path), search)
    )
        DisplayedNotes.Push(note)
}

}


NoteList.Delete()

for note in DisplayedNotes
{
    SplitPath(note.Path, , &dir)

    NoteList.Add(
        "",
        note.Name,
        dir
    )
}

}

; ==========================
; MAKE NOTE
; ==========================

MakeNote(path)
{
    SplitPath(
        path,
        &name,
        &folder,
        &ext,
        &nameNoExt
    )

    return {
        Name: name,
        Folder: folder,
        Path: path,
        Extension: ext,
        Created: FileGetTime(path,"C"),
        Modified: FileGetTime(path,"M")
    }
}

; ==========================
; NORMALIZE NOTES
; ==========================

NormalizeNotes(raw)
{
    notes := []

    for _, item in raw
    {
        notes.Push({
            Name: item["Name"],
            Folder: item.Has("Folder") ? item["Folder"] : "",
            Path: item["Path"],
            Extension: item.Has("Extension") ? item["Extension"] : ".md",
            Created: item.Has("Created") ? item["Created"] : "",
            Modified: item.Has("Modified") ? item["Modified"] : ""
        })
    }

    return notes
}

; ==========================
; LOAD NOTES
; ==========================

LoadNotes()
{
    global VaultRoot

    files := []

    Loop Files VaultRoot "\*.md", "R"
    {
        files.Push(
            MakeNote(A_LoopFileFullPath)
        )
    }

    return files
}

; ==========================
; FAVORITES
; ==========================

LoadFavorites()
{
    global FavoritesFile

    if !FileExist(FavoritesFile)
        return []

    return NormalizeNotes(
        JSON.parse(FileRead(FavoritesFile))
    )
}

; ==========================
; RECENT
; ==========================

;---------------------------
; LOAD RECENT
;---------------------------

LoadRecent()
{
    global RecentFile

    if !FileExist(RecentFile)
        return []

    return NormalizeNotes(
        JSON.parse(FileRead(RecentFile))
    )
}

;---------------------------
; ADD RECENT
;---------------------------

AddRecent(path)
{
    global RecentFile

    SplitPath(path, &name)

    arr := []

    if FileExist(RecentFile)
        arr := JSON.parse(FileRead(RecentFile))

    for i, note in arr
    {
        existing := note["Path"]

        if existing = path
        {
            arr.RemoveAt(i)
            break
        }
    }
    
    arr.InsertAt(
        1,
        MakeNote(path)
    )

    while arr.Length>20
        arr.Pop()

    if FileExist(RecentFile)
        FileDelete(RecentFile)

    FileAppend(
        JSON.stringify(arr),
        RecentFile,
        "UTF-8"
    )
}

; ==========================
; HELPERS
; ==========================

; ---------------------------------------------------------
; GET SELECTED TEXT
; ---------------------------------------------------------

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

; ---------------------------------------------------------
; GET SELECTED NOTE
; ---------------------------------------------------------

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

        payload :=
        Format(
        '{{"event_type":"{1}","path_or_node_id":"{2}","selected_text":"{3}"}}',
        eventType,
        StrReplace(path,'"','\"'),
        StrReplace(SubStr(selectedText,1,300),'"','\"')
        )

        req.Open(
        "POST",
        "http://127.0.0.1:8000/context/signal",
        false)

        req.SetRequestHeader(
        "Content-Type",
        "application/json")

        req.Send(payload)

    }
}

; ==========================
; ACTIONS
; ==========================

; ---------------------------------------------------------
; OPEN NOTE
; ---------------------------------------------------------

OpenSelected()
{

path := GetSelected()


if path = ""
    return

Run(path)

AddRecent(path)

}

; ---------------------------------------------------------
; CREATE NOTE
; ---------------------------------------------------------
; DisplayedNotes[row].Folder "\" name ".md"
CreateNote()
{

global VaultRoot

result := InputBox(
    "Name:",
    "Create Note"
)

if result.Result != "OK"
    return

name := result.Value

selected := DisplayedNotes[row]

folder := selected.Folder

path := folder "\" name ".md"

FileAppend(
    "# " name "`n`n",
    path
)

Run(path)

AddRecent(path)

}

; ---------------------------------------------------------
; APPEND SELECTED
; ---------------------------------------------------------

AppendSelected()
{

path := GetSelected()

global LastNotePath
LastNotePath := path

if path = ""
    return

text := GetSelectedText()

if text = ""
    return

FileAppend(
    "`r`n" text "`r`n",
    path,
    "UTF-8"
)

AddRecent(path)

}

; ---------------------------------------------------------
; PREPEND SELECTED
; ---------------------------------------------------------

PrependSelected()
{

path := GetSelected()
text := GetSelectedText()

global LastNotePath
LastNotePath := path

if path = ""
    return

if text=""
    return

old := FileRead(path,"UTF-8")

FileDelete(path)

FileAppend(
    text "`r`n`r`n" old,
    path,
    "UTF-8"
)

AddRecent(path)

}

; ==========================
; HOTKEYS
; ==========================

; ---------------------------------------------------------
; ; Ctrl+Win+A → APPEND TO LAST NOTE
; ---------------------------------------------------------

^#a:: {
    global LastNotePath
    if (LastNotePath = "")
        return MsgBox("No last note yet.")

    text := A_Clipboard
    if (text = "")
        return MsgBox("Clipboard empty.")

    FileAppend("`r`n" text "`r`n", LastNotePath, "UTF-8")

    SendBiomeSignal(
        "note_append",
        LastNotePath,
        text
    )

    AddRecent(LastNotePath)
}

; ---------------------------------------------------------
; Ctrl+Alt+A → PREPEND TO LAST NOTE
; ---------------------------------------------------------

^!a:: {
    global LastNotePath

    if (LastNotePath = "")
        return MsgBox("No last note yet.")

    text := A_Clipboard

    if (text = "")
        return MsgBox("Clipboard empty.")

    content := ""

    try
        content := FileRead(LastNotePath, "UTF-8")

    FileDelete(LastNotePath)
    FileAppend(text "`r`n" content, LastNotePath, "UTF-8")

    SendBiomeSignal(
        "note_append",
        LastNotePath,
        text
    )

    AddRecent(LastNotePath)
}

; ---------------------------------------------------------
; CTRL+SHIFT+ALT+C -> APPEND TO SOME @%$! CODE
; ---------------------------------------------------------
; (text, FileAppend, SendBiomeSignal)

^+!c::{
    text := GetSelectedText()

    if (text = "")
        return

    FileAppend("`r`n" text, TargetFile, "UTF-8")

    SendBiomeSignal(
        "code_append",
        TargetFile,
        text
    )

    AddRecent(TargetFile)
}

; ---------------------------------------------------------
; CTRL+SHIFT+WIN+C -> PREPEND TO SOME @%$! CODE
; ---------------------------------------------------------
; (text, contents, FileDelete, FileAppend, SendBiomeSignal)

^+#c::{
    text := GetSelectedText()

    if (text = "")
        return

    contents := ""

    try
        contents := FileRead(TargetFile,"UTF-8")

    FileDelete(TargetFile)

    FileAppend(
        text "`r`n" contents,
        TargetFile,
        "UTF-8"
    )

    SendBiomeSignal(
        "code_prepend",
        TargetFile,
        text
    )

    AddRecent(TargetFile)
}