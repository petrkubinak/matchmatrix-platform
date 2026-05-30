Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "C:\MatchMatrix-platform\tools"
WshShell.Run """C:\Python314\python.exe"" ""C:\MatchMatrix-platform\tools\matchmatrix_ticket_studio_V2_3.py""", 0, False
Set WshShell = Nothing