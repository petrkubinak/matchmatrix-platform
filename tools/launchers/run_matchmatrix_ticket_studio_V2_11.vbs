Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "C:\MatchMatrix-platform\tools"
WshShell.Run Chr(34) & "C:\Python314\python.exe" & Chr(34) & " " & Chr(34) & "C:\MatchMatrix-platform\tools\matchmatrix_ticket_studio_V2_11.py" & Chr(34), 0, False
