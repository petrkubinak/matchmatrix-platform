Set-Location "C:\MatchMatrix-Platform"

$RemotePanel = "\\192.168.3.119\matchmatrix\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
$LocalPanel = "C:\MatchMatrix-Platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
$RemoteHistory = "\\192.168.3.119\matchmatrix\tools\histori\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW_STEP_05_WORKFLOW_UI.py"

if (-not (Test-Path $RemotePanel)) {
    throw "Zdrojový panel na PC2 nebyl nalezen: $RemotePanel"
}

if (-not (Test-Path $RemoteHistory)) {
    Copy-Item $RemotePanel $RemoteHistory
}

$Text = [System.IO.File]::ReadAllText(
    $RemotePanel,
    [System.Text.Encoding]::UTF8
)

$OldBlock = @'
DOCUMENTATION_PYTHON_EXE = r"C:\Python314\python.exe"
DOCUMENTATION_TOOL_DIR = os.path.join(BASE_DIR, "tools", "documentation")
DOCUMENTATION_WORKSPACE_ROOT = os.path.join(
    BASE_DIR,
    "reports",
    "documentation",
    "standardization",
    "panel_workspaces"
)
'@

$NewBlock = @'
DOCUMENTATION_EXECUTION_MODE = "REMOTE_PC2"
DOCUMENTATION_PYTHON_EXE = r"C:\Python314\python.exe"
DOCUMENTATION_TOOL_DIR = os.path.join(
    DOCUMENTATION_ROOT,
    "tools",
    "documentation"
)
DOCUMENTATION_WORKSPACE_ROOT = os.path.join(
    DOCUMENTATION_ROOT,
    "reports",
    "documentation",
    "standardization",
    "panel_workspaces"
)
'@

$Count = (
    [regex]::Matches(
        $Text,
        [regex]::Escape($OldBlock)
    )
).Count

if ($Count -ne 1) {
    throw "Konfigurační blok – očekáván 1 výskyt, nalezeno: $Count"
}

$Text = $Text.Replace(
    $OldBlock,
    $NewBlock
)

$Utf8Bom = New-Object System.Text.UTF8Encoding($true)

[System.IO.File]::WriteAllText(
    $RemotePanel,
    $Text,
    $Utf8Bom
)

Copy-Item $RemotePanel $LocalPanel -Force

py.exe -3.14 -m py_compile $LocalPanel

if ($LASTEXITCODE -ne 0) {
    throw "Python syntaktická kontrola lokální kopie selhala."
}

Write-Host ""
Write-Host "=== Q3 PC1 CONTROL -> PC2 WORKSPACE ===" -ForegroundColor Cyan

Select-String `
    -Path $LocalPanel `
    -Pattern `
        "DOCUMENTATION_EXECUTION_MODE",
        "DOCUMENTATION_TOOL_DIR =",
        "DOCUMENTATION_WORKSPACE_ROOT =" |
    Select-Object LineNumber, Line |
    Format-Table -AutoSize

Write-Host ""
Write-Host "REMOTE PANEL: $RemotePanel"
Write-Host "LOCAL PANEL : $LocalPanel"
Write-Host "PYTHON SYNTAX: OK" -ForegroundColor Green
