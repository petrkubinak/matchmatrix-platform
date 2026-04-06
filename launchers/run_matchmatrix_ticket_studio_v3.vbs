Set WshShell = CreateObject("WScript.Shell")

' === KONFIGURACE ===
projectPath = "C:\MatchMatrix-platform"
pythonExe   = "C:\Python314\python.exe"
scriptPath  = projectPath & "\tools\matchmatrix_ticket_studio_V3_fix13.py"

' === COMMAND ===
cmd = "cmd.exe /k cd /d " & projectPath & " && " & pythonExe & " " & scriptPath

' === SPUŠTĚNÍ ===
WshShell.Run cmd, 0, False