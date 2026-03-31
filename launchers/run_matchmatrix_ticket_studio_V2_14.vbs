Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "cmd /c cd /d C:\MatchMatrix-platform\tools && C:\Python314\python.exe matchmatrix_ticket_studio_V2_14.py", 0, False
