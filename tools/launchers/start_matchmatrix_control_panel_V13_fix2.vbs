Set WshShell = CreateObject("WScript.Shell")

projectRoot = "C:\MatchMatrix-platform"
pythonExe = "C:\Python314\python.exe"
panelScript = projectRoot & "\tools\matchmatrix_control_panel_V13_fix2.py"

cmd = Chr(34) & pythonExe & Chr(34) & " " & Chr(34) & panelScript & Chr(34)

WshShell.CurrentDirectory = projectRoot
WshShell.Run cmd, 1, False
