Set WshShell = CreateObject("WScript.Shell")

pythonExe = "C:\Python314\python.exe"
scriptPath = "C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V9.py"

WshShell.Run Chr(34) & pythonExe & Chr(34) & " " & Chr(34) & scriptPath & Chr(34), 0, False