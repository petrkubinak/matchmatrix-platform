# =============================================================================
# MatchMatrix
# AUDIT_MM_REF_001_002_PRESNY_V1.ps1
#
# ENGINE:
#   A_REF_SYNC_AUDIT_V1_1_RAW_TEXT_REGEX
#
# CO:
#   Přesně porovná pojmy v MM-REF-001 s klikacím rejstříkem MM-REF-002.
#
# K ČEMU:
#   Zjistí chybějící a nadbytečné pojmy bez započítání metadat,
#   souhrnů nebo historie verzí.
#
# KDE:
#   tools\documentation\AUDIT_MM_REF_001_002_PRESNY_V1.ps1
#
# JAK:
#   PROJECT_ROOT odvodí ze svého umístění.
#   Funguje lokálně na PC2 i z PC1 přes UNC.
#   Markdown načítá jako celý text; nepředává prázdné řádky do parametrů funkcí.
# =============================================================================

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Engine = "A_REF_SYNC_AUDIT_V1_1_RAW_TEXT_REGEX"

if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    throw "Nelze určit PSScriptRoot. Skript musí být spuštěn ze souboru .ps1."
}

$ToolsDir = Split-Path -Parent $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ToolsDir

$Ref001 = Join-Path $ProjectRoot `
    "docs\10_REFERENCE\MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md"

$Ref002 = Join-Path $ProjectRoot `
    "docs\10_REFERENCE\MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX.md"

Write-Host ""
Write-Host "MATCHMATRIX - PŘESNÝ AUDIT MM-REF-001 / MM-REF-002" -ForegroundColor Cyan
Write-Host ("=" * 78)
Write-Host "ENGINE      : $Engine"
Write-Host "SCRIPT_ROOT : $PSScriptRoot"
Write-Host "PROJECT_ROOT: $ProjectRoot"
Write-Host "MM-REF-001  : $Ref001"
Write-Host "MM-REF-002  : $Ref002"
Write-Host ""

if (-not (Test-Path -LiteralPath $Ref001 -PathType Leaf)) {
    throw "Chybí MM-REF-001: $Ref001"
}

if (-not (Test-Path -LiteralPath $Ref002 -PathType Leaf)) {
    throw "Chybí MM-REF-002: $Ref002"
}

$Text001 = Get-Content -LiteralPath $Ref001 -Raw -Encoding UTF8
$Text002 = Get-Content -LiteralPath $Ref002 -Raw -Encoding UTF8

if ([string]::IsNullOrWhiteSpace($Text001)) {
    throw "MM-REF-001 je prázdný: $Ref001"
}

if ([string]::IsNullOrWhiteSpace($Text002)) {
    throw "MM-REF-002 je prázdný: $Ref002"
}

$Pattern001 = '(?ms)^#\s+3\.\s+Překladový slovník\s*\r?\n(?<body>.*?)(?=^#\s+4\.\s+Souhrn verze)'
$Pattern002 = '(?ms)^#\s+2\.\s+Klikací rejstřík\s*\r?\n(?<body>.*?)(?=^#\s+3\.\s+Výklady pojmů)'

$Match001 = [regex]::Match($Text001, $Pattern001)
$Match002 = [regex]::Match($Text002, $Pattern002)

if (-not $Match001.Success) {
    throw "V MM-REF-001 nebyla nalezena sekce 3. Překladový slovník."
}

if (-not $Match002.Success) {
    throw "V MM-REF-002 nebyla nalezena sekce 2. Klikací rejstřík."
}

$Body001 = $Match001.Groups["body"].Value
$Body002 = $Match002.Groups["body"].Value

$Terms001 = [System.Collections.Generic.List[string]]::new()
$Terms002 = [System.Collections.Generic.List[string]]::new()

foreach ($Line in ($Body001 -split "\r?\n")) {
    if ($Line -match '^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|$') {
        $Term = $Matches[1].Trim()

        if (
            $Term -ne "Cizí výraz" -and
            $Term -ne "---" -and
            -not [string]::IsNullOrWhiteSpace($Term)
        ) {
            $Terms001.Add($Term)
        }
    }
}

foreach ($Line in ($Body002 -split "\r?\n")) {
    if (
        $Line -match '^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*\[Otevřít výklad\]\([^)]+\)\s*\|'
    ) {
        $Term = $Matches[1].Trim()

        if (-not [string]::IsNullOrWhiteSpace($Term)) {
            $Terms002.Add($Term)
        }
    }
}

$Unique001 = @($Terms001 | Sort-Object -Unique)
$Unique002 = @($Terms002 | Sort-Object -Unique)

$Missing = @(
    $Unique001 |
    Where-Object { $_ -notin $Unique002 } |
    Sort-Object
)

$Extra = @(
    $Unique002 |
    Where-Object { $_ -notin $Unique001 } |
    Sort-Object
)

Write-Host "VÝSLEDEK"
Write-Host ("-" * 78)
Write-Host "MM-REF-001 pojmů  : $($Unique001.Count)"
Write-Host "MM-REF-002 výkladů: $($Unique002.Count)"
Write-Host "Chybí v MM-REF-002: $($Missing.Count)"
Write-Host "Navíc v MM-REF-002: $($Extra.Count)"

Write-Host ""
Write-Host "=== POJMY CHYBĚJÍCÍ V MM-REF-002 ===" -ForegroundColor Yellow

if ($Missing.Count -eq 0) {
    Write-Host "Žádné."
}
else {
    $Missing | ForEach-Object { Write-Host "- $_" }
}

Write-Host ""
Write-Host "=== POJMY NAVÍC V MM-REF-002 ===" -ForegroundColor Yellow

if ($Extra.Count -eq 0) {
    Write-Host "Žádné."
}
else {
    $Extra | ForEach-Object { Write-Host "- $_" }
}

Write-Host ""
Write-Host ("=" * 78)
Write-Host "AUDIT DOKONČEN" -ForegroundColor Green
