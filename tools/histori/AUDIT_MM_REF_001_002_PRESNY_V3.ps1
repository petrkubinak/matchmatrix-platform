# MatchMatrix - presny audit synchronizace MM-REF-001 / MM-REF-002
$ErrorActionPreference = "Stop"

$ProjectRoot = "C:\MatchMatrix-platform"

$Ref001 = Join-Path $ProjectRoot `
    "docs\10_REFERENCE\MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md"

$Ref002 = Join-Path $ProjectRoot `
    "docs\10_REFERENCE\MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX.md"

if (-not (Test-Path -LiteralPath $Ref001)) {
    throw "Chybi MM-REF-001: $Ref001"
}

if (-not (Test-Path -LiteralPath $Ref002)) {
    throw "Chybi MM-REF-002: $Ref002"
}

function Get-MarkdownSection {
    param(
        [Parameter(Mandatory)]
        [string[]] $Lines,

        [Parameter(Mandatory)]
        [string] $StartPattern,

        [Parameter(Mandatory)]
        [string] $EndPattern
    )

    $startIndex = -1
    $endIndex = $Lines.Count

    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($startIndex -lt 0 -and $Lines[$i] -match $StartPattern) {
            $startIndex = $i + 1
            continue
        }

        if ($startIndex -ge 0 -and $Lines[$i] -match $EndPattern) {
            $endIndex = $i
            break
        }
    }

    if ($startIndex -lt 0) {
        throw "Nebyla nalezena pocatecni sekce: $StartPattern"
    }

    if ($endIndex -le $startIndex) {
        throw "Nebyla nalezena platna koncova sekce: $EndPattern"
    }

    return $Lines[$startIndex..($endIndex - 1)]
}

$Lines001 = Get-Content -LiteralPath $Ref001 -Encoding UTF8
$Lines002 = Get-Content -LiteralPath $Ref002 -Encoding UTF8

# MM-REF-001: pouze tabulka v sekci "3. Prekladovy slovnik"
$Section001 = Get-MarkdownSection `
    -Lines $Lines001 `
    -StartPattern '^#\s+3\.\s+Překladový slovník\s*$' `
    -EndPattern '^#\s+4\.\s+Souhrn verze'

$Terms001 = foreach ($Line in $Section001) {
    if ($Line -match '^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|$') {
        $Term = $Matches[1].Trim()

        if (
            $Term -ne "Cizí výraz" -and
            $Term -ne "---"
        ) {
            $Term
        }
    }
}

# MM-REF-002: pouze klikaci rejstrik v sekci 2
$Section002 = Get-MarkdownSection `
    -Lines $Lines002 `
    -StartPattern '^#\s+2\.\s+Klikací rejstřík\s*$' `
    -EndPattern '^#\s+3\.\s+Výklady pojmů\s*$'

$Terms002 = foreach ($Line in $Section002) {
    if (
        $Line -match '^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*\[Otevřít výklad\]\([^)]+\)\s*\|'
    ) {
        $Matches[1].Trim()
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

Write-Host ""
Write-Host "=== PRESNY AUDIT MM-REF-001 / MM-REF-002 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "MM-REF-001 pojmu : $($Unique001.Count)"
Write-Host "MM-REF-002 vykladu: $($Unique002.Count)"
Write-Host "Chybi v MM-REF-002: $($Missing.Count)"
Write-Host "Navic v MM-REF-002: $($Extra.Count)"

Write-Host ""
Write-Host "=== POJMY CHYBEJICI V MM-REF-002 ===" -ForegroundColor Yellow

if ($Missing.Count -eq 0) {
    Write-Host "Zadne."
}
else {
    $Missing | ForEach-Object { Write-Host "- $_" }
}

Write-Host ""
Write-Host "=== POJMY NAVIC V MM-REF-002 ===" -ForegroundColor Yellow

if ($Extra.Count -eq 0) {
    Write-Host "Zadne."
}
else {
    $Extra | ForEach-Object { Write-Host "- $_" }
}

Write-Host ""
Write-Host "Audit dokoncen." -ForegroundColor Green
