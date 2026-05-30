Set WshShell = CreateObject("WScript.Shell")
command = "powershell.exe -ExecutionPolicy Bypass -File ""C:\MatchMatrix-platform\db\scripts\1000_build_chat_context_bundle_v1.ps1"""
WshShell.Run command, 1, True