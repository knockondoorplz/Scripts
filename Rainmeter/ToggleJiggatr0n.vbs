Option Explicit

'======================
' CONFIGURATION
'======================
Dim RainmeterExe, LayoutLite, LayoutTaskbar
RainmeterExe = "C:\Program Files\Rainmeter\Rainmeter.exe"
LayoutLite = "!Jiggatr0n_lite"
LayoutTaskbar = "!Jiggara!ntaskbar!"

'======================
' VARIABLES
'======================
Dim fso, FlagFile, CurrentLayout
Dim FlagFileHandle, Shell

Set fso = CreateObject("Scripting.FileSystemObject")
Set Shell = CreateObject("WScript.Shell")

' Flag file stored next to this script
FlagFile = Left(WScript.ScriptFullName, Len(WScript.ScriptFullName) - Len(WScript.ScriptName)) & "toggleflag.txt"

' Create flag file if it does not exist
If Not fso.FileExists(FlagFile) Then
    Dim FlagFileCreate
    Set FlagFileCreate = fso.CreateTextFile(FlagFile, True)
    FlagFileCreate.WriteLine "Lite"
    FlagFileCreate.Close
End If

' Read current layout
Dim FlagFileRead
Set FlagFileRead = fso.OpenTextFile(FlagFile, 1) ' 1 = ForReading
CurrentLayout = Trim(FlagFileRead.ReadLine)
FlagFileRead.Close

'======================
' UNLOAD LAYOUTS
'======================
Shell.Run """" & RainmeterExe & """ !UnloadLayout """ & LayoutLite & """", 0, True
Shell.Run """" & RainmeterExe & """ !UnloadLayout """ & LayoutTaskbar & """", 0, True

' Small delay to ensure unload completes
WScript.Sleep 800

'======================
' LOAD NEXT LAYOUT
'======================
If CurrentLayout = "Lite" Then
    Shell.Run """" & RainmeterExe & """ !LoadLayout """ & LayoutTaskbar & """", 0, True
    CurrentLayout = "Taskbar"
Else
    Shell.Run """" & RainmeterExe & """ !LoadLayout """ & LayoutLite & """", 0, True
    CurrentLayout = "Lite"
End If

' Refresh all skins
Shell.Run """" & RainmeterExe & """ !RefreshAll""", 0, True

'======================
' UPDATE FLAG FILE
'======================
Dim FlagFileWrite
Set FlagFileWrite = fso.CreateTextFile(FlagFile, True)
FlagFileWrite.WriteLine CurrentLayout
FlagFileWrite.Close
