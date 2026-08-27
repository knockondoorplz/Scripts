#Requires AutoHotkey v2.0
#SingleInstance Force
#Include JSON.ahk

; ==========================================
; OmniPalette v1.0
; AutoHotkey v2.0
; Jason + ChatGPT
; Obsidian Command Palette
; ==========================================

;===========================
; OmniPalette v1.0
;===========================

global App := OmniPalette()

!Space::App.Toggle()

Esc::{
    if App.Gui
        App.Gui.Hide()
}

^#a::App.AppendToLast()
^!a::App.PrependToLast()

^+!c::App.AppendToCode()
^+#c::App.PrependToCode()

class OmniPalette
{
    __New()
    {
        this.VaultRoot := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃"
        this.TargetFile := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\Some @%$! Code\Some @%$! Code.md"

        this.Storage := Storage(this)
        this.Biome := Biome(this)

        this.Notes := []
        this.Displayed := []

        this.LastNote := ""

        this.Gui := PaletteGUI(this)
    }

    Toggle()
    {
        if this.Gui.Visible
            this.Gui.Hide()
        else
            this.Show()
    }

    Show()
    {
        this.Notes := this.Storage.LoadNotes()
        this.Gui.Refresh()
        this.Gui.Show()
    }

    Open(path)
    {
        Run(path)

        this.LastNote := path

        this.Storage.AddRecent(path)
    }

    Append(path,text)
    {
        if (text="")
            return

        FileAppend("`r`n" text "`r`n",path,"UTF-8")

        this.LastNote:=path

        this.Storage.AddRecent(path)

        this.Biome.Signal("note_append",path,text)
    }

    Prepend(path,text)
    {
        if (text="")
            return

        old:=FileRead(path,"UTF-8")

        FileDelete(path)

        FileAppend(text "`r`n`r`n" old,path,"UTF-8")

        this.LastNote:=path

        this.Storage.AddRecent(path)

        this.Biome.Signal("note_prepend",path,text)
    }
}

class Storage
{
    __New(app)
    {
        this.App:=app
    }

    LoadNotes()
    {
    }

    LoadFavorites()
    {
    }

    SaveFavorites()
    {
    }

    LoadRecent()
    {
    }

    AddRecent(path)
    {
    }

    MakeNote(path)
    {
    }

    NormalizeNotes(raw)
    {
    }
}

class Biome
{
    __New(app)
    {
        this.App:=app
    }

    Signal(type,path,text:="")
    {
        ;WinHTTP POST
    }
}

class PaletteGUI
{
    __New(app)
    {
        this.App:=app

        this.Build()
    }

    Build()
    {
    }

    Refresh()
    {
    }

    Resize()
    {
    }

    GetSelected()
    {
    }
}

OpenButton.OnEvent(
    "Click",
    (*)=>this.App.Open(
        this.GetSelected()
    )
)

AppendButton.OnEvent(
    "Click",
    (*)=>this.App.Append(
        this.GetSelected(),
        GetSelectedText()
    )
)


PrependButton.OnEvent(
    "Click",
    (*)=>this.App.Prepend(
        this.GetSelected(),
        GetSelectedText()
    )
)

AppendSelected()
{
    this.Append(
        this.Gui.SelectedPath(),
        GetSelectedText()
    )
}