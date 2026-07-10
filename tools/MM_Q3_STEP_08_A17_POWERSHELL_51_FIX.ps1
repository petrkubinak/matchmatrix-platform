# MATCHMATRIX
# Q3 STEP 08 - A17 POWERSHELL 5.1 FIX
# CO:
# - Opraví vložený PowerShell příkaz používaný tlačítkem A17 AUDIT.
# K ČEMU:
# - Zajistí kompatibilitu s Windows PowerShell 5.1 na PC1.
# KDE:
# - Aktivní Q3 panel na PC2 a synchronizovaná kopie na PC1.
# JAK:
# - Nahradí pouze blok powershell_script, vytvoří historickou kopii
#   a provede syntaktickou kontrolu na obou počítačích.

$ErrorActionPreference = "Stop"

if ($env:COMPUTERNAME -ieq "MATCHMATRIX") {
    throw "Tento instalační skript spusťte na PC1 (MATCHMATRIX-OPS), nikoli na PC2."
}

$RemoteHost = "192.168.3.119"
$RemotePanel = "\\192.168.3.119\matchmatrix\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
$LocalPanel = "C:\MatchMatrix-Platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
$RemoteHistory = "\\192.168.3.119\matchmatrix\tools\histori\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW_STEP_08_BEFORE_A17_POWERSHELL_FIX.py"
$RemotePython = "C:\Users\Admin\AppData\Local\Python\pythoncore-3.14-64\python.exe"
$RemotePanelLocalPath = "C:\MatchMatrix-Platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"

if (-not (Test-Path -LiteralPath $RemotePanel)) {
    throw "Aktivní Q3 panel na PC2 nebyl nalezen: $RemotePanel"
}

if (-not (Test-Path -LiteralPath $RemoteHistory)) {
    Copy-Item -LiteralPath $RemotePanel -Destination $RemoteHistory
}

$Text = [System.IO.File]::ReadAllText(
    $RemotePanel,
    [System.Text.Encoding]::UTF8
)

$Pattern = '(?ms)^            powershell_script = f""".*?^            """\r?\n\r?\n            encoded_command ='

$Matches = [regex]::Matches(
    $Text,
    $Pattern
)

if ($Matches.Count -ne 1) {
    throw "Blok powershell_script – očekáván 1 výskyt, nalezeno: $($Matches.Count)"
}

$Replacement = @'
            powershell_script = f"""
$ErrorActionPreference = "Stop"

try {{
    Invoke-Command -ComputerName {ps_host} -ScriptBlock {{
        param(
            $PythonExe,
            $AuditScript,
            $DocumentPath,
            $OutputDir,
            $ProjectRoot
        )

        $ErrorActionPreference = "Stop"

        Set-Location -LiteralPath $ProjectRoot

        New-Item -ItemType Directory -Path $OutputDir -Force |
            Out-Null

        & $PythonExe $AuditScript `
            --document $DocumentPath `
            --document-type AUTO `
            --output-dir $OutputDir `
            --stdout-findings 20

        $AuditExitCode = $LASTEXITCODE

        Write-Output "__MM_A17_EXIT_CODE__=$AuditExitCode"

        if ($AuditExitCode -ne 0) {{
            throw "A17 skoncil navratovym kodem $AuditExitCode"
        }}
    }} -ArgumentList {ps_python}, {ps_script}, {ps_document}, {ps_output}, {ps_project}

    exit 0
}}
catch {{
    Write-Error $_.Exception.Message
    exit 1
}}
"""

            encoded_command =
'@

$NewText = [regex]::Replace(
    $Text,
    $Pattern,
    $Replacement,
    1
)

$Utf8Bom = New-Object System.Text.UTF8Encoding($true)

[System.IO.File]::WriteAllText(
    $RemotePanel,
    $NewText,
    $Utf8Bom
)

Copy-Item `
    -LiteralPath $RemotePanel `
    -Destination $LocalPanel `
    -Force

py.exe -3.14 -m py_compile $LocalPanel

if ($LASTEXITCODE -ne 0) {
    throw "Syntaktická kontrola panelu na PC1 selhala."
}

$RemoteCompileResult = Invoke-Command `
    -ComputerName $RemoteHost `
    -ScriptBlock {
        param(
            $PythonExe,
            $PanelPath
        )

        & $PythonExe -m py_compile $PanelPath

        if ($LASTEXITCODE -ne 0) {
            throw "Syntaktická kontrola panelu na PC2 selhala."
        }

        "REMOTE PYTHON SYNTAX: OK"
    } `
    -ArgumentList `
        $RemotePython, `
        $RemotePanelLocalPath

Write-Host ""
Write-Host "=== Q3 STEP 08 - A17 POWERSHELL 5.1 FIX ===" -ForegroundColor Cyan

Select-String `
    -Path $LocalPanel `
    -Pattern `
        'powershell_script = f"""',
        'Invoke-Command -ComputerName',
        'Write-Output "__MM_A17_EXIT_CODE__=',
        'A17 skoncil navratovym kodem' |
    Select-Object LineNumber, Line |
    Format-Table -AutoSize

Write-Host ""
Write-Host $RemoteCompileResult
Write-Host "LOCAL PYTHON SYNTAX: OK" -ForegroundColor Green
Write-Host "HISTORY: $RemoteHistory"
Write-Host "REMOTE PANEL: $RemotePanel"
Write-Host "LOCAL PANEL : $LocalPanel"
