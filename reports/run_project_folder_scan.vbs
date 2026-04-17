' run_project_folder_scan.vbs
' Účel:
' Vygeneruje seznam souborů pro složky:
' workers, ingest, ops, ops_admin, tools
'
' Výstupy:
' C:\MatchMatrix-platform\_scan_workers.txt
' C:\MatchMatrix-platform\_scan_ingest.txt
' C:\MatchMatrix-platform\_scan_ops.txt
' C:\MatchMatrix-platform\_scan_ops_admin.txt
' C:\MatchMatrix-platform\_scan_tools.txt
'
' Spuštění:
' dvojklikem na .vbs
'
' Poznámka:
' Spouští PowerShell skrytě.

Option Explicit

Dim shell
Dim projectRoot
Dim psCommand

Set shell = CreateObject("WScript.Shell")

projectRoot = "C:\MatchMatrix-platform"

psCommand = _
    "powershell -NoProfile -ExecutionPolicy Bypass -Command " & Chr(34) & _
    "$ErrorActionPreference = 'Stop'; " & _
    "Get-ChildItem '" & projectRoot & "\workers' -Recurse | Select-Object FullName | Out-File -Encoding UTF8 '" & projectRoot & "\_scan_workers.txt'; " & _
    "Get-ChildItem '" & projectRoot & "\ingest' -Recurse | Select-Object FullName | Out-File -Encoding UTF8 '" & projectRoot & "\_scan_ingest.txt'; " & _
    "Get-ChildItem '" & projectRoot & "\ops' -Recurse | Select-Object FullName | Out-File -Encoding UTF8 '" & projectRoot & "\_scan_ops.txt'; " & _
    "Get-ChildItem '" & projectRoot & "\ops_admin' -Recurse | Select-Object FullName | Out-File -Encoding UTF8 '" & projectRoot & "\_scan_ops_admin.txt'; " & _
    "Get-ChildItem '" & projectRoot & "\tools' -Recurse | Select-Object FullName | Out-File -Encoding UTF8 '" & projectRoot & "\_scan_tools.txt'; " & _
    "[System.Windows.MessageBox]::Show('Scan dokončen. TXT soubory jsou uložené v C:\MatchMatrix-platform','MatchMatrix Scan')" & _
    Chr(34)

shell.Run psCommand, 0, True