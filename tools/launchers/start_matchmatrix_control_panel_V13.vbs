' =============================================================================
' MATCHMATRIX CONTROL PANEL V13 - STARTER
' =============================================================================
'
' CO TO DĚLÁ:
' Spustí hlavní panel MatchMatrix bez nutnosti psát příkaz do terminálu.
'
' KAM ULOŽIT:
' C:\MatchMatrix-platform\tools\start_matchmatrix_control_panel_V13.vbs
'
' SPOUŠTĚNÍ:
' Dvojklikem na tento .vbs soubor.
'
' POZNÁMKA:
' Používá C:\Python314\python.exe a panel:
' C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V13.py
' =============================================================================

Option Explicit

Dim shell
Dim pythonExe
Dim scriptPath
Dim projectRoot
Dim command

Set shell = CreateObject("WScript.Shell")

projectRoot = "C:\MatchMatrix-platform"
pythonExe = "C:\Python314\python.exe"
scriptPath = projectRoot & "\tools\matchmatrix_control_panel_V13.py"

command = """" & pythonExe & """ """ & scriptPath & """"

shell.CurrentDirectory = projectRoot
shell.Run command, 1, False
