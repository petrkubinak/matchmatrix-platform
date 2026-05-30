Set WshShell = CreateObject("WScript.Shell")

pythonExe = "C:\Python314\python.exe"
scriptPath = "C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V8.py"

WshShell.Run """" & pythonExe & """ """ & scriptPath & """", 0, False