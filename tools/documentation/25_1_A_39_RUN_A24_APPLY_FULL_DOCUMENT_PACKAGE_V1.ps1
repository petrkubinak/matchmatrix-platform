#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = "C:\MatchMatrix-platform"
$Python = "C:\Users\Admin\AppData\Local\Python\pythoncore-3.14-64\python.exe"
$A24 = Join-Path $ProjectRoot "tools\documentation\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py"

$Documents = @(
    "docs\00_DOCUMENTATION\MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK.md",
    "docs\01_MASTER\MM-DOC-100_MATCHMATRIX_MASTER_TECH.md",
    "docs\02_GOVERNANCE\MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH.md",
    "docs\03_ARCHITECTURE\MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md",
    "docs\08_DEVELOPMENT\MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH.md",
    "docs\09_HISTORY\MM-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH.md",
    "docs\12_STANDARD\MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_DOKUMENTACE_A_VERZOVANI.md",
    "docs\12_STANDARD\MM-STD-004_STANDARD_NÁZVOSLOVÍ_A_STRUKTURY_DOKUMENTACE.md",
    "docs\12_STANDARD\MM-STD-007_IDENTIFIKACE_A_CISLOVANI_DOKUMENTU_MATCHMATRIX.md",
    "docs\10_REFERENCE\MM-STD-1000_INDEX_STANDARDŮ_MATCHMATRIX.md",
    "docs\10_REFERENCE\MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md",
    "docs\10_REFERENCE\MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX.md"
)

if (-not (Test-Path -LiteralPath $ProjectRoot)) { throw "Projektový kořen nebyl nalezen: $ProjectRoot" }
if (-not (Test-Path -LiteralPath $Python)) { throw "Python nebyl nalezen: $Python" }
if (-not (Test-Path -LiteralPath $A24)) { throw "A24 nebyl nalezen: $A24" }

Set-Location -LiteralPath $ProjectRoot

$GitDirText = (& git rev-parse --git-dir).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($GitDirText)) {
    throw "Nepodařilo se určit Git adresář."
}

if ([System.IO.Path]::IsPathRooted($GitDirText)) {
    $GitDir = [System.IO.Path]::GetFullPath($GitDirText)
}
else {
    $GitDir = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $GitDirText))
}

$ExcludePath = Join-Path $GitDir "info\exclude"
$ExcludeDirectory = Split-Path -Parent $ExcludePath
New-Item -ItemType Directory -Path $ExcludeDirectory -Force | Out-Null

$ExcludeOriginallyExisted = Test-Path -LiteralPath $ExcludePath
[byte[]]$OriginalExcludeBytes = @()

if ($ExcludeOriginallyExisted) {
    $OriginalExcludeBytes = [System.IO.File]::ReadAllBytes($ExcludePath)
    $CurrentExclude = [System.IO.File]::ReadAllText($ExcludePath)
}
else {
    $CurrentExclude = ""
}

$TemporaryBlock = @"
# BEGIN MATCHMATRIX A24 TEMPORARY EXCLUDES
/db/26_AUDITY/
/docs/14_EXPORT/HISTORIE_CHATU/
# END MATCHMATRIX A24 TEMPORARY EXCLUDES
"@

$ApplyStarted = $false

try {
    $Separator = ""
    if ($CurrentExclude.Length -gt 0 -and -not $CurrentExclude.EndsWith("`n")) {
        $Separator = "`r`n"
    }

    [System.IO.File]::WriteAllText(
        $ExcludePath,
        ($CurrentExclude + $Separator + $TemporaryBlock),
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host ""
    Write-Host "KONTROLA ČISTÉHO GIT STAVU" -ForegroundColor Cyan
    Write-Host ("-" * 79)

    $GitStatus = @(& git status --porcelain --untracked-files=all)
    if ($LASTEXITCODE -ne 0) { throw "Nepodařilo se načíst Git status." }

    if ($GitStatus.Count -gt 0) {
        $GitStatus | ForEach-Object { Write-Host $_ }
        throw "A24 APPLY zastaven: Git stav není čistý."
    }

    $CurrentBranch = (& git branch --show-current).Trim()
    $CurrentCommit = (& git rev-parse HEAD).Trim()

    if ($CurrentBranch -ne "main") {
        throw "Neočekávaná Git větev: $CurrentBranch"
    }

    Write-Host "BRANCH : $CurrentBranch"
    Write-Host "COMMIT : $CurrentCommit"
    Write-Host "STATUS : CLEAN" -ForegroundColor Green

    $Arguments = @($A24, "--apply")
    foreach ($Document in $Documents) {
        $Arguments += @("--document", $Document)
    }

    Write-Host ""
    Write-Host "SPOUŠTÍM A24 APPLY" -ForegroundColor Cyan
    Write-Host ("-" * 79)

    $ApplyStarted = $true
    & $Python @Arguments
    $A24ExitCode = $LASTEXITCODE

    if ($A24ExitCode -ne 0) {
        throw "A24 APPLY skončil návratovým kódem $A24ExitCode."
    }

    Write-Host ""
    Write-Host "A24 APPLY PRO VŠECH 12 DOKUMENTŮ DOKONČEN." -ForegroundColor Green
}
finally {
    if ($ExcludeOriginallyExisted) {
        [System.IO.File]::WriteAllBytes($ExcludePath, $OriginalExcludeBytes)
    }
    elseif (Test-Path -LiteralPath $ExcludePath) {
        Remove-Item -LiteralPath $ExcludePath -Force
    }

    Write-Host ""
    Write-Host "DOČASNÉ GIT VÝJIMKY BYLY OBNOVENY." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "VÝSLEDNÝ GIT STATUS" -ForegroundColor Cyan
    Write-Host ("-" * 79)
    & git status --short --untracked-files=all

    if (-not $ApplyStarted) {
        Write-Host ""
        Write-Host "A24 APPLY NEBYL SPUŠTĚN." -ForegroundColor Yellow
    }
}
