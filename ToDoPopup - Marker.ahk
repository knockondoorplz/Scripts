#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================================================================
; 1. FILE PATH CONFIGURATION
; =========================================================================
global FilePath1 := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\🔱👁‍🗨\🔱👁‍🗨.md"
global FilePath2 := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\♟Åcâdэмΐä💡\💿_Ċøðΐηg_💎\Scratchbox\Some @%$! Code\Some @%$! Code.md"
global FilePath3 := "H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\øмegå_🌓\Ambitia\Tools🔧\💻сøмքսէэя⌨️\Desktop Apps\AI Entities\ChatGPT\For ChatGPT\🎭For ChatGPT.md"

global ActiveFilePath := FilePath1
global MainGui := ""
global TabCtrl := ""
global TV := ""
global TextEditor := ""
global SearchInput := ""
global ReplaceInput := ""
global FullDocText := ""
global IsGuiVisible := false
global IsLoading := false
global LastKnownModTime := 0
global LastKnownCaretPos := 0

; Map to hold jump points per tab: JumpPoints[TabNum][PointNum] = CaretPosition
global JumpPoints := Map(1, Map(1,0, 2,0, 3,0), 2, Map(1,0, 2,0, 3,0), 3, Map(1,0, 2,0, 3,0))

BuildGUI()

; =========================================================================
; 2. SYSTEM-WIDE HOTKEYS
; =========================================================================

^!j::
{
    global IsGuiVisible
    if IsGuiVisible {
        DismissGUI()
    } else {
        OpenOrSwitchMode("NewBullet")
    }
}

^+!j:: OpenOrSwitchMode("ViewOnly")
^+#j:: OpenOrSwitchMode("RestoreCursor")

#UseHook ; Forces AHK to intercept hotkeys ahead of other apps

; =========================================================================
; UNIVERSAL PERSISTENT MARKERS (!m then 1..9 to Place | #!m then 1..9 to Jump)
; =========================================================================

>^j::
{
    ToolTip("📍 Place Marker: Press 1-9")
    ih := InputHook("L1 T4", "{Esc}")
    ih.Start()
    ih.Wait()
    ToolTip()
    
    if (ih.Input != "") {
        SendText("📍" . ih.Input)
    }
}

>^>!j::
{
    ToolTip("🚀 Jump to Marker: Press 1-9")
    ih := InputHook("L1 T4", "{Esc}")
    ih.Start()
    ih.Wait()
    ToolTip()
    
    if (ih.Input != "") {
        targetTag := "📍" . ih.Input
        Send("^f")
        Sleep(100)
        SendText(targetTag)
        Sleep(100)
        
        if WinActive("ahk_exe Code.exe") || WinActive("ahk_exe obsidian.exe") {
            Send("{Escape}")
        } else {
            Send("{Enter}{Escape}")
        }
    }
}

; =========================================================================
; 3. GUI-FOCUSED HOTKEYS
; =========================================================================
#HotIf (IsObject(MainGui) && MainGui.Hwnd && WinActive("ahk_id " . MainGui.Hwnd))

Esc:: DismissGUI()

!n::
{
    if IsObject(TextEditor)
        ControlSend("- ", TextEditor)
}

^f::
{
    global SearchInput
    if IsObject(SearchInput) {
        SearchInput.Focus()
        Send("^a")
    }
}

^h::
{
    global ReplaceInput
    if IsObject(ReplaceInput) {
        ReplaceInput.Focus()
        Send("^a")
    }
}

^s:: SaveCurrentDocument(true)

#HotIf

; =========================================================================
; 4. CORE CONTROLLER & JUMP ENGINE
; =========================================================================

SetScriptJumpPoint(PointNum) {
    global TabCtrl, TextEditor, JumpPoints
    if !IsObject(TextEditor) || !IsObject(TabCtrl)
        return
    
    currentTab := TabCtrl.Value
    buf := Buffer(8, 0)
    SendMessage(0x00B0, buf.Ptr, buf.Ptr + 4, TextEditor) ; EM_GETSEL
    caretPos := NumGet(buf, 0, "UInt")
    
    JumpPoints[currentTab][PointNum] := caretPos
    ToolTip("📍 Spawn Point " . PointNum . " Saved!")
    SetTimer(() => ToolTip(), -1000)
}

JumpToScriptPoint(PointNum) {
    global TabCtrl, TextEditor, JumpPoints
    if !IsObject(TextEditor) || !IsObject(TabCtrl)
        return

    currentTab := TabCtrl.Value
    targetPos := JumpPoints[currentTab][PointNum]
    
    TextEditor.Focus()
    SendMessage(0x00B1, targetPos, targetPos, TextEditor) ; EM_SETSEL
    SendMessage(0x00B7, 0, 0, TextEditor)                 ; EM_SCROLLCARET
    ToolTip("🚀 Jumped to Point " . PointNum)
    SetTimer(() => ToolTip(), -1000)
}

OpenOrSwitchMode(ModeName) {
    global IsGuiVisible
    if !IsGuiVisible {
        ShowGUI(ModeName)
    } else {
        LoadFileToEditor(ModeName)
    }
}

DismissGUI() {
    global MainGui, IsGuiVisible
    if IsGuiVisible {
        SaveCurrentCursorPosition()
        SaveCurrentDocument(false)
        MainGui.Hide()
        IsGuiVisible := false
    }
}

SaveCurrentCursorPosition() {
    global TextEditor, LastKnownCaretPos
    if IsObject(TextEditor) && TextEditor.Hwnd {
        buf := Buffer(8, 0)
        SendMessage(0x00B0, buf.Ptr, buf.Ptr + 4, TextEditor)
        LastKnownCaretPos := NumGet(buf, 0, "UInt")
    }
}

ReadUtf8File(Path) {
    if !FileExist(Path)
        return ""
    try {
        fileObj := FileOpen(Path, "r", "UTF-8")
        content := fileObj.Read()
        fileObj.Close()
        return content
    } catch {
        return ""
    }
}

; =========================================================================
; 5. GUI BUILDER & LOADER ENGINE
; =========================================================================

BuildGUI() {
    global MainGui, TabCtrl, TV, TextEditor, SearchInput, ReplaceInput
    
    MainGui := Gui("+AlwaysOnTop +ToolWindow +Resize", "🌊 Vector Aqua Vault")
    MainGui.BackColor := "0x0a1e3f"
    
    MainGui.SetFont("s9 Bold c0x00d2ff", "Segoe UI Emoji")
    MainGui.Add("Text", "x10 y10 w45 h20", "🔍 Find:")
    
    MainGui.SetFont("s9 Norm c0x000000", "Segoe UI")
    SearchInput := MainGui.Add("Edit", "x55 y6 w120 h22 c0x000000")
    SearchInput.OnEvent("Change", OnSearchChange)

    MainGui.SetFont("s9 Bold c0x00ffcc", "Segoe UI Emoji")
    MainGui.Add("Text", "x185 y10 w45 h20", "🔄 Swap:")
    
    MainGui.SetFont("s9 Norm c0x000000", "Segoe UI")
    ReplaceInput := MainGui.Add("Edit", "x230 y6 w120 h22 c0x000000")

    BtnReplace := MainGui.Add("Button", "x358 y5 w65 h24", "Swap All")
    BtnReplace.OnEvent("Click", OnReplaceClick)

    BtnSave := MainGui.Add("Button", "x430 y5 w100 h24", "💾 Save (Ctrl+S)")
    BtnSave.OnEvent("Click", (*) => SaveCurrentDocument(true))

    MainGui.SetFont("s9 Bold c0xe0f7fa", "Segoe UI")
    TabCtrl := MainGui.Add("Tab2", "x10 y34 w740 h500", ["🔱 Vault", "📋 Code Scratchbox", "🎭 ChatGPT Notes"])
    TabCtrl.UseTab()

    TV := MainGui.Add("TreeView", "x15 y65 w240 h460 Background0x061830 c0xe0f7fa -Lines")

    MainGui.SetFont("s10 Norm c0xffffff", "Consolas")
    TextEditor := MainGui.Add("Edit", "x260 y65 w485 h460 Background0x051428 c0xffffff Multi WantTab VScroll HScroll")
    
    TextEditor.OnEvent("Change", (*) => QueueAutoSave())
    TabCtrl.OnEvent("Change", OnTabChange)
    TV.OnEvent("ItemSelect", OnNodeSelect)

    SetTimer(CheckExternalFileEdits, 1000)
}

ShowGUI(Mode := "NewBullet") {
    global MainGui, IsGuiVisible
    MainGui.Show("Center w760 h545")
    IsGuiVisible := true
    try WinSetTransparent(235, MainGui.Hwnd)
    LoadFileToEditor(Mode)
}

OnTabChange(Ctrl, *) {
    global ActiveFilePath, FilePath1, FilePath2, FilePath3
    SaveCurrentDocument(false)
    switch Ctrl.Value {
        case 1: ActiveFilePath := FilePath1
        case 2: ActiveFilePath := FilePath2
        case 3: ActiveFilePath := FilePath3
    }
    LoadFileToEditor("ViewOnly")
}

LoadFileToEditor(OpenMode := "NewBullet") {
    global TV, TextEditor, TabCtrl, ActiveFilePath, FullDocText, LastKnownModTime, LastKnownCaretPos, IsLoading
    
    if !IsObject(TV) || !IsObject(TextEditor)
        return

    IsLoading := true

    TV.Opt("-Redraw")
    TV.Delete()
    FullDocText := ""

    if !FileExist(ActiveFilePath) {
        IsLoading := false
        TV.Opt("+Redraw")
        TextEditor.Value := "⚠️ File not found at path:`n" . ActiveFilePath
        return
    }

    FullDocText := ReadUtf8File(ActiveFilePath)
    LastKnownModTime := FileGetTime(ActiveFilePath, "M")

    currentTab := IsObject(TabCtrl) ? TabCtrl.Value : 1
    caretPos := 0

    ; --- TAB 1 SPECIFIC TOP-INSERTION LOGIC ---
    if (currentTab == 1 && OpenMode == "NewBullet") {
        FullDocText := "- `r`n" . FullDocText
        caretPos := 2 ; Lands cursor directly right after "- " on line 1
    } 
    else if (OpenMode == "RestoreCursor") {
        caretPos := Min(LastKnownCaretPos, StrLen(FullDocText))
    }

    TextEditor.Value := FullDocText

    RootID := TV.Add("📜 FULL DOCUMENT", 0, "Expand Select")
    Parents := [0, 0, 0, 0, 0, 0]

    Loop Parse, FullDocText, "`n", "`r" {
        line := A_LoopField
        if RegExMatch(line, "^(#+)\s+(.*)", &match) {
            level := StrLen(match[1])
            title := match[2]

            parentId := RootID
            Loop level - 1 {
                idx := level - A_Index
                if (Parents[idx] != 0) {
                    parentId := Parents[idx]
                    break
                }
            }

            CurrentID := TV.Add(title, parentId, "Expand")
            Parents[level] := CurrentID
            
            Loop 6 - level
                Parents[level + A_Index] := 0
        }
    }

    TV.Opt("+Redraw")
    
    TextEditor.Focus()
    SendMessage(0x00B1, caretPos, caretPos, TextEditor) ; EM_SETSEL
    SendMessage(0x00B7, 0, 0, TextEditor)                 ; EM_SCROLLCARET

    IsLoading := false
}

QueueAutoSave() {
    global IsLoading
    if IsLoading
        return
    static AutoSaveCallback := () => SaveCurrentDocument(false)
    SetTimer(AutoSaveCallback, 0)
    SetTimer(AutoSaveCallback, -400)
}

SaveCurrentDocument(showNotification := true) {
    global ActiveFilePath, TextEditor, LastKnownModTime, IsLoading
    if !IsObject(TextEditor) || IsLoading
        return

    SplitPath(ActiveFilePath, &fileName, &fileDir)
    if (fileDir != "" && !DirExist(fileDir)) {
        try DirCreate(fileDir)
    }

    try {
        fileObj := FileOpen(ActiveFilePath, "w", "UTF-8")
        fileObj.Write(TextEditor.Value)
        fileObj.Close()

        try FileSetTime(A_Now, ActiveFilePath)
        LastKnownModTime := FileGetTime(ActiveFilePath, "M")

        if showNotification {
            ToolTip("💾 Saved!")
            SetTimer(() => ToolTip(), -1000)
        }
    } catch {
        if showNotification {
            ToolTip("❌ Save Failed")
            SetTimer(() => ToolTip(), -1000)
        }
    }
}

CheckExternalFileEdits() {
    global ActiveFilePath, LastKnownModTime, IsGuiVisible, IsLoading
    if !IsGuiVisible || IsLoading || !FileExist(ActiveFilePath)
        return

    try {
        currentModTime := FileGetTime(ActiveFilePath, "M")
        if (LastKnownModTime != 0 && currentModTime != LastKnownModTime) {
            LastKnownModTime := currentModTime
            LoadFileToEditor("ViewOnly")
        }
    }
}

OnNodeSelect(Control, ItemID) {
    global TextEditor
    if !IsObject(TextEditor)
        return

    itemText := TV.GetText(ItemID)
    if (itemText == "📜 FULL DOCUMENT" || itemText == "")
        return

    pos := InStr(TextEditor.Value, itemText)
    if pos {
        TextEditor.Focus()
        SendMessage(0x00B1, pos - 1, pos - 1, TextEditor)
        SendMessage(0x00B7, 0, 0, TextEditor)
    }
}

OnSearchChange(GuiCtrl, *) {
    global TextEditor
    if !IsObject(TextEditor)
        return

    query := GuiCtrl.Value
    if (query == "")
        return

    pos := InStr(TextEditor.Value, query)
    if pos {
        TextEditor.Focus()
        SendMessage(0x00B1, pos - 1, pos + StrLen(query) - 1, TextEditor)
        SendMessage(0x00B7, 0, 0, TextEditor)
    }
}

OnReplaceClick(*) {
    global SearchInput, ReplaceInput, TextEditor
    if !IsObject(TextEditor)
        return

    findStr := SearchInput.Value
    replaceStr := ReplaceInput.Value

    if (findStr == "")
        return

    if InStr(TextEditor.Value, findStr) {
        TextEditor.Value := StrReplace(TextEditor.Value, findStr, replaceStr)
        SaveCurrentDocument(true)
    }
}