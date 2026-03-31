Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "C:\MatchMatrix-platform\tools"
WshShell.Run """C:\Python314\python.exe"" ""C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V5.py""", 0, False
Set WshShell = Nothing