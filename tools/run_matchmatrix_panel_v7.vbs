Set WshShell = CreateObject("WScript.Shell")

' Nastavení cest
pythonExe = "C:\Python314\python.exe"
scriptPath = "C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V7_fixed.py"

' Spuštění panelu (skryté okno = 0, normální = 1)
WshShell.Run """" & pythonExe & """ """ & scriptPath & """", 0, False