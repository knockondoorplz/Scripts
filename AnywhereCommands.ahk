#Requires AutoHotkey v2.0
#SingleInstance Force

; if FL updates you'll have to update this

Locations := Map(
    "𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃", 		"H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃",
    "projects", 	"H:\Jason's Files\!NTY1T10XYZ\𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃\øмegå_🌓\Ambitia\Projects\BiomeOS",
    "img",		"C:\Users\brigi\Documents\GitHub\Biome Simulator\img",
    "bio", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator",
    "biome",		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\BiomeCore",
    "chrono",		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Chronolog",
    "stream",		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Omnistream",
    "oll", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Ollama",
    "know",		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\KnowledgeOS",
    "cog", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Cognisphere",
    "glyph",		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Glyph Engine",
    "lab", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\ThoughtLab",
    "reflect", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\ReflectionGPT",
    "hover", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\HoverExplainer",
    "jig", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Jiggatron File Explorer",
    "omni", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Omnistream\Omnitotem",
    "plasma", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Plasma-Sprite",
    "widgets", 		"C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets",
    "scripts", 		"C:\Users\brigi\Documents\Jason\Scripts",
    "somecode", 	"H:\Jason's Files\Some !@#% Code",
    "command", 		"C:\Users\brigi\Documents\Jason\Command Archives\PowerShell-Console",
    "history", 		"C:\Tools\DiffWatcher\History",
    "stack",		"C:\Users\brigi\Documents\Jason\Scripts\Projects\Stack",
    "new", 		"C:\Users\brigi\Desktop\New Folder",
    "tools", 		"C:\Tools",

    "jasons", 		"H:\Jason's Files",
    "gloss",		"H:\Jason's Files\γλώσσα",
    "soft", 		"H:\Software",
    "libros", 		"H:\Audiolibros",
    "pdf", 		"H:\ΠΔΦ",
    "clip",		"C:\Users\brigi\iCloudDrive\Downloads\Wallpapers\Clips",
    "raw",		"C:\Users\brigi\iCloudDrive\Downloads\Wallpapers\Raw",
    "blooop", 		"C:\Users\brigi\Pictures\_ΔЖДЭΣΨΦΞŦͶΠφħþµØęŋƋƍƏƔƕƈƹƼȢȶȹɚɞɸ\Yupdatum\blooop",
    "screen",		"C:\Users\brigi\Pictures\Screenshots",
    "live",		"C:\Users\brigi\Videos\Live Wallpapers",
    "raiw",		"C:\Users\brigi\Documents\RainWallpaper\Themes",
    "rain", 		"H:\Rainmeter",
    "skin", 		"C:\Users\brigi\Documents\Rainmeter\Skins",
    "ui", 		"C:\Users\brigi\Documents\UI Customization",
    "icon", 		"C:\Users\brigi\Documents\UI Customization\Icons\;;Icons;;",
    "cursor", 		"C:\Users\brigi\AppData\Local\Microsoft\Windows\Cursors",

    "qoop", 		"C:\Users\brigi\Desktop\q[ɛɛ...ɜɜ]p",
    "music", 		"C:\Users\brigi\Music\μюζικ",
    "omega", 		"H:\_ⱺᴍꬲԍҩ",
    "great", 		"H:\ΞThe Great UpgradeΞ",
    "time",		"C:\Users\brigi\Documents\GitHub\Biome Simulator\TimeController",
    "vst", 		"C:\Program Files (x86)\VstPlugins",
    "v2", 		"C:\Program Files\Common Files\VST2",
    "v3", 		"C:\Program Files\Common Files\VST3",
    "fl", 		"C:\Program Files (x86)\Image-Line\FL Studio 2025",
    "fp", 		"C:\Users\brigi\Documents\Image-Line\Data\FL Studio\Projects",
    "gross", 		"C:\Users\brigi\Documents\Image-Line\Data\FL Studio\Presets\Plugin presets\Effects\Fruity Wrapper - IL Gross Beat",
    "massive", 		"C:\Program Files (x86)\Common Files\Native Instruments\Massive\Sounds",
    "sytrus",		"C:\Program Files (x86)\Image-Line\FL Studio 2025\Data\Patches\Plugin presets\Generators\Sytrus",
    "serum", 		"C:\Users\brigi\Documents\Xfer\Serum Presets",
    "vital", 		"C:\Users\brigi\Documents\Vital\User",

    "C", 		"C:\",
    "H", 		"H:\",
    "thispc", 		"This PC",
    "brigi", 		"C:\Users\brigi",
    "desk", 		"C:\Users\brigi\Desktop",
    "doc", 		"C:\Users\brigi\Documents",
    "down", 		"C:\Users\brigi\Downloads",
    "xzxz", 		"\\ENGINIO\Users\brigi\xzxz",
    "jason", 		"C:\Users\brigi\Documents\Jason",
    "word", 		"C:\Users\brigi\Documents\Jason\Word Documents",
    "pc", 		"C:\Users\brigi\Documents\Jason\PC Stuff",
    "icloud", 		"C:\Users\brigi\iCloudDrive\Downloads",
    "iphoto", 		"C:\Users\brigi\Pictures\iCloud Photos\Photos",
    "myapps", 		"C:\Users\brigi\Documents\My Apps",
    "appdata", 		"\\ENGINIO\Users\brigi\AppData",
    "programdata", 	"C:\ProgramData",
    "programfiles", 	"C:\Program Files",
    "programfiles86", 	"C:\Program Files (x86)",
    "recent", 		"C:\Users\brigi\AppData\Roaming\Microsoft\Windows\Recent",
    "startup", 		"C:\Users\brigi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup",
    "taskbar", 		"C:\Users\brigi\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar",
    "pinned",		"C:\Users\brigi\AppData\Roaming\OpenShell\Pinned",
    "font", 		"C:\Users\brigi\AppData\Local\Microsoft\Windows\Fonts",
)

; Jump Function

Jump(name) {
    global Locations
    if !Locations.Has(name) {
        MsgBox("Unknown location: " name)
        return
    }

    path := Locations[name]

    ; Ensure substring matching is enabled so it catches "Emergency File Browser - C:\..."
    DetectHiddenWindows(true)
    
    ; Look for ANY window containing your emergency browser title
    if WinExist("Emergency File Browser") {
        WinActivate("Emergency File Browser")
        ToolTip("Jump caught Emergency Browser for: " . name)
        SetTimer(() => ToolTip(), -2000)
        return
    }

    ; Fallback to standard Explorer COM windows if explorer is responsive
    try {
        for window in ComObject("Shell.Application").Windows {
            try {
                if InStr(window.FullName, "explorer.exe") {
                    window.Visible := true
                    window.Navigate(path)
                    WinActivate("ahk_id " window.HWND)
                    return
                }
            }
        }
    } catch {
        ; COM object hung, skip to fresh launch
    }

    ; Final Fallback
    Run('explorer.exe "' path '"')
}

; Biome Source Code

^#!1::Jump("scripts")
^#!2::Jump("widgets")
^#!3::Jump("projects")
^#!4::Jump("bio")
^#!5::Jump("biome")
^#!6::Jump("know")
^#!7::Jump("plasma")
^#!8::Jump("hover")
^#!9::Jump("reflect")
^#!0::Jump("oll")

; Workspace

^+#1::Jump("𐌰𐌹𐍂𐌿𐌽𐍄𐌹𐌲𐌹𐍃")
^+#2::Jump("somecode")
^+#3::Jump("command")
^+#4::Jump("history")
^+#5::Jump("stack")
^+#6::Jump("new")
^+#7::Jump("tools")
^+#8::Jump("jasons")
^+#9::Jump("gloss")
^+#0::Jump("libros")

; System

^+!1::Jump("C")
^+!2::Jump("H")
^+!3::Jump("programfiles")
^+!4::Jump("programfiles86")
^+!5::Jump("programdata")
^+!6::Jump("appdata")
^+!7::Jump("myapps")
^+!8::Jump("taskbar")
^+!9::Jump("recent")
^+!0::Jump("startup")

; Libraries

#!0::Jump("xzxz")
#!1::Jump("desk")
#!2::Jump("doc")
#!3::Jump("down")
#!4::Jump("thispc")
#!5::Jump("brigi")
#!6::Jump("jason")
#!7::Jump("word")
#!8::Jump("pc")

; Media

^!1::Jump("icloud")
^!2::Jump("iphoto")
^!3::Jump("blooop")
^!4::Jump("soft")
^!5::Jump("pdf")
^!6::Jump("libros")
^!7::Jump("font")
^!8::Jump("ui")
^!9::Jump("icon")
^!0::Jump("cursor")


; Music — typed @ commands

:*:@music::{
    Jump("music")
}

:*:@omega::{
    Jump("omega")
}

:*:@great::{
    Jump("great")
}

:*:@qoop::{
    Jump("qoop")
}

:*:@time::{
    Jump("time")
}

:*:@vst::{
    Jump("vst")
}

:*:@v2::{
    Jump("v2")
}

:*:@v3::{
    Jump("v3")
}

:*:@fl::{
    Jump("fl")
}

:*:@fp::{
    Jump("fp")
}

:*:@gross::{
    Jump("gross")
}

:*:@massive::{
    Jump("massive")
}

:*:@sytrus::{
    Jump("sytrus")
}

:*:@serum::{
    Jump("serum")
}

:*:@vital::{
    Jump("vital")
}

:*:@screen::{
    Jump("screen")
}

:*:@live::{
    Jump("live")
}

:*:@raiw::{
    Jump("raiw")
}

:*:@rain::{
    Jump("rain")
}

:*:@skin::{
    Jump("skin")
}

:*:@clip::{
    Jump("clip")
}

:*:@raw::{
    Jump("raw")
}

:*:@profile::{
Run("notepad.exe C:\Users\brigi\Documents\PowerShell\profile.ps1")
}