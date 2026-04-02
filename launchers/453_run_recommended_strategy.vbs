Set WshShell = CreateObject("WScript.Shell")

WshShell.Run "cmd /k ""C:\Python314\python.exe C:\MatchMatrix-platform\workers\452_auto_run_recommended_strategy.py""", 1, True

Set WshShell = Nothing