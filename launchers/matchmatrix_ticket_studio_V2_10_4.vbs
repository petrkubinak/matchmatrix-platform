Set WshShell = CreateObject("WScript.Shell")
cmd = "C:\Python314\python.exe ""C:\MatchMatrix-platform\tools\matchmatrix_ticket_studio_V2_10_4.py"""
WshShell.Run cmd, 0, False
