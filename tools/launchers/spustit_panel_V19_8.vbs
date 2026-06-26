' MATCHMATRIX - spuštění panelu V19.10 bez terminálu

Set WshShell = CreateObject("WScript.Shell")

WshShell.CurrentDirectory = "C:\MatchMatrix-platform"

WshShell.Run "C:\Python314\python.exe C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V19_10_STABLE_UI_PC2_NO_FREEZE.py", 1, False