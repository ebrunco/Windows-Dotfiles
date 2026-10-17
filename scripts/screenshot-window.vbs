' Launches screenshot-window.ps1 with no console window at all.
' (powershell -WindowStyle Hidden still flashes one before it hides.)
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)

' Debug trail: one line per launch (screenshot.log is git-ignored).
Set trail = fso.OpenTextFile(dir & "\screenshot.log", 8, True)
trail.WriteLine Now & "  vbs launched"
trail.Close

shell.Run "powershell -STA -NoProfile -ExecutionPolicy Bypass -File """ & dir & "\screenshot-window.ps1""", 0, False
