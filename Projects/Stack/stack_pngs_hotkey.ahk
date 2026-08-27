^!`::
if WinActive("ahk_class CabinetWClass")
{
    for window in ComObjCreate("Shell.Application").Windows
    {
        if (window.HWND = WinActive("A"))
        {
            path := window.Document.Folder.Self.Path
            Run, % """C:\Python312\python.exe"" ""C:\Users\brigi\Documents\Jason\Scripts\Projects\Stack\stack_pngs.py"" """ path """", %path%

            break
        }
    }
}
return
