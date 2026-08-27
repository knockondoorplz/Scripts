#Requires AutoHotkey v2.0
#SingleInstance Force

Locations := Map(
    "bio", "C:\Users\brigi\Documents\GitHub\Biome Simulator",
    "biome", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\BiomeCore",
    "chrono", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Chronolog",
    "stream", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Omnistream",
    "oll", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Ollama",
    "know", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\KnowledgeOS",
    "cog", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Cognisphere",
    "glyph", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Glyph Engine",
    "rain", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Rainmanager",
    "lab", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\ThoughtLab",
    "reflect", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\ReflectionGPT",
    "hover", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\HoverExplainer",
    "jig", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Jiggatron File Explorer",
    "omni", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Omnistream\Omnitotem",
    "plasma", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets\Plasma-Sprite",
    "widgets", "C:\Users\brigi\Documents\GitHub\Biome Simulator\Widgets",
    "scripts", "C:\Users\brigi\Documents\Jason\Scripts",
    "samples", "H:\_ⱺᴍꬲԍҩ",
    "startup", "C:\Users\brigi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup",
    "new", "C:\Users\brigi\Desktop\New Folder"

)

Jump(name) {
    global Locations

    if !Locations.Has(name) {

        MsgBox("Unknown location: " name)
        return
    }

    path := Locations[name]

    ; Find an existing Explorer window.
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

    ; No Explorer? Make one.
    Run('explorer.exe "' path '"')
}

^#!1::Jump("scripts")
^#!2::Jump("bio")
^#!3::Jump("widgets")
^#!4::Jump("biome")
^#!5::Jump("lab")
^#!7::Jump("stream")
^#!8::Jump("plasma")
^#!9::Jump("hover")
^#!0::Jump("oll")
^+#1::Jump("reflect")
^+#2::Jump("know")
^+#3::Jump("chrono")
^+#z::Jump("samples")
^+#n::Jump("new")
^+0::Jump("startup")