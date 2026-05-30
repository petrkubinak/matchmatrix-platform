Option Explicit

Dim shell, pythonExe, scriptPath, command
Set shell = CreateObject("WScript.Shell")

pythonExe = "C:\Python314\python.exe"
scriptPath = "C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V15.py"

command = Chr(34) & pythonExe & Chr(34) & " " & Chr(34) & scriptPath & Chr(34)

shell.CurrentDirectory = "C:\MatchMatrix-platform"
shell.Run command, 1, False
