Option Explicit

Dim shell, fso, panelPath, pythonExe, command

panelPath = "C:\MatchMatrix-Platform\tools\matchmatrix_control_panel_V20_1_Q2_PC1_GLOSSARY_NAVIGATION.py"

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

If Not fso.FileExists(panelPath) Then
    MsgBox "Panel nebyl nalezen:" & vbCrLf & panelPath, vbCritical, "MatchMatrix"
    WScript.Quit 1
End If

shell.CurrentDirectory = "C:\MatchMatrix-Platform"

If fso.FileExists("C:\Python314\pythonw.exe") Then
    pythonExe = "C:\Python314\pythonw.exe"
    command = """" & pythonExe & """ """ & panelPath & """"
Else
    command = "pyw -3.14 """ & panelPath & """"
End If

shell.Run command, 0, False
