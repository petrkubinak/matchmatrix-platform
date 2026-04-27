Set WshShell = CreateObject("WScript.Shell")
command = "cmd /c C:\Python314\python.exe C:\MatchMatrix-platform\tools\export_schema_reports_v1.py"
WshShell.Run command, 1, True