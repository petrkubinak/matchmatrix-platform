# =========================================================
# MATCHMATRIX – BUILD CHAT CONTEXT BUNDLE
# Finální clean verze:
# - bez self-copy warningu
# - README v UTF-8
# - sběr runtime / worker scan / football backfill / schema exportů
# =========================================================

$today = Get-Date -Format "yyyyMMdd"
$bundleDir = "C:\MatchMatrix-platform\reports\chat_context\$today"

if (!(Test-Path $bundleDir)) {
    New-Item -ItemType Directory -Path $bundleDir | Out-Null
}

Write-Host "======================================"
Write-Host "MATCHMATRIX CHAT CONTEXT BUNDLE START"
Write-Host "DATE: $today"
Write-Host "BUNDLE: $bundleDir"
Write-Host "======================================"

# ---------------------------------------------------------
# Helper: copy latest file by pattern
# - skips self-copy
# ---------------------------------------------------------
function Copy-LatestFileByPattern {
    param (
        [string]$SearchRoot,
        [string]$Pattern,
        [string]$Label
    )

    if (!(Test-Path $SearchRoot)) {
        Write-Host "[$Label] Search root not found: $SearchRoot"
        return
    }

    $file = Get-ChildItem $SearchRoot -Recurse -File |
        Where-Object { $_.Name -like $Pattern } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($file) {
        $targetPath = Join-Path $bundleDir $file.Name

        # ochrana proti kopírování souboru do sebe sama
        if ($file.FullName -eq $targetPath) {
            Write-Host "[$Label] Skipping self-copy: $($file.Name)"
            return
        }

        Copy-Item $file.FullName $targetPath -Force
        Write-Host "[$Label] Copied: $($file.Name)"
    }
    else {
        Write-Host "[$Label] No file found for pattern: $Pattern"
    }
}

# ---------------------------------------------------------
# Helper: copy files from latest dated schema directory
# ---------------------------------------------------------
function Copy-LatestSchemaDirFiles {
    param (
        [string]$BaseDir,
        [string]$Label
    )

    if (!(Test-Path $BaseDir)) {
        Write-Host "[$Label] Base dir not found: $BaseDir"
        return
    }

    $latestDir = Get-ChildItem $BaseDir -Directory |
        Sort-Object Name -Descending |
        Select-Object -First 1

    if ($latestDir) {
        Write-Host "[$Label] Latest schema dir: $($latestDir.FullName)"

        Get-ChildItem $latestDir.FullName -File | ForEach-Object {
            $targetPath = Join-Path $bundleDir $_.Name

            # ochrana proti kopírování souboru do sebe sama
            if ($_.FullName -eq $targetPath) {
                Write-Host "[$Label] Skipping self-copy: $($_.Name)"
            }
            else {
                Copy-Item $_.FullName $targetPath -Force
                Write-Host "[$Label] Copied: $($_.Name)"
            }
        }
    }
    else {
        Write-Host "[$Label] No dated folder found."
    }
}

# ---------------------------------------------------------
# 1. Spustit existující reporty
# ---------------------------------------------------------
cd C:\MatchMatrix-platform\db\scripts

Write-Host "-> Runtime audit export"
.\112_runtime_audit_export_V2.ps1

Write-Host "-> Worker file scan"
.\614_worker_file_scan_v2.ps1

Write-Host "-> Football backfill report"
.\run_api_football_backfill_report.ps1

Write-Host "-> Schema export"
C:\Python314\python.exe C:\MatchMatrix-platform\tools\export_schema_reports_v1.py

# ---------------------------------------------------------
# 2. Zkopírovat master navázání
# ---------------------------------------------------------
$masterFile = "C:\MatchMatrix-platform\docs\MATCHMATRIX_MASTER_NAVAZANI.md"
if (Test-Path $masterFile) {
    $masterTarget = Join-Path $bundleDir "MATCHMATRIX_MASTER_NAVAZANI.md"
    if ($masterFile -ne $masterTarget) {
        Copy-Item $masterFile $masterTarget -Force
        Write-Host "[MASTER] Copied: MATCHMATRIX_MASTER_NAVAZANI.md"
    }
    else {
        Write-Host "[MASTER] Skipping self-copy: MATCHMATRIX_MASTER_NAVAZANI.md"
    }
}
else {
    Write-Host "[MASTER] File not found: $masterFile"
}

# ---------------------------------------------------------
# 3. Zkopírovat nejnovější runtime audit / worker scan / FB backfill
# ---------------------------------------------------------
Copy-LatestFileByPattern -SearchRoot "C:\MatchMatrix-platform\reports" -Pattern "runtime_audit_*.txt" -Label "RUNTIME"
Copy-LatestFileByPattern -SearchRoot "C:\MatchMatrix-platform\reports" -Pattern "*worker_file_scan*.csv" -Label "WORKER_SCAN"
Copy-LatestFileByPattern -SearchRoot "C:\MatchMatrix-platform\logs"    -Pattern "api_football_backfill_status_*.txt" -Label "FB_BACKFILL"

# ---------------------------------------------------------
# 4. Zkopírovat nejnovější schema exporty
# ---------------------------------------------------------
Copy-LatestSchemaDirFiles -BaseDir "C:\MatchMatrix-platform\reports\prehled_sloupcu_tabulek_OPS"     -Label "OPS"
Copy-LatestSchemaDirFiles -BaseDir "C:\MatchMatrix-platform\reports\prehled_sloupcu_tabulek_staging" -Label "STAGING"
Copy-LatestSchemaDirFiles -BaseDir "C:\MatchMatrix-platform\reports\prehled_sloupcu_tabulek_public"  -Label "PUBLIC"

# ---------------------------------------------------------
# 5. README pro nový chat (UTF-8)
# ---------------------------------------------------------
$readmeFile = Join-Path $bundleDir "000_README_CHAT_CONTEXT.txt"

$readmeText = @"
MATCHMATRIX – CHAT CONTEXT BUNDLE

Tato složka obsahuje centralizovaný kontext pro nový chat.

Obsah typicky:
- MATCHMATRIX_MASTER_NAVAZANI.md
- runtime_audit_*.txt
- worker_file_scan*.csv
- api_football_backfill_status_*.txt
- ops_1_columns.txt / ops_2_table_counts.txt / ops_3_constraints.txt
- staging_1_columns.txt / staging_2_table_counts.txt / staging_3_constraints.txt
- public_1_columns.txt / public_2_table_counts.txt / public_3_constraints.txt

Doporučení pro nový chat:
1) vložit MATCHMATRIX_MASTER_NAVAZANI.md
2) vložit runtime_audit_*.txt
3) vložit worker_file_scan*.csv
4) podle potřeby vložit schema exporty OPS / staging / public
5) pokud řešíme football, přiložit i api_football_backfill_status_*.txt

Text pro nový chat:
Navazujeme v MatchMatrix na aktuální multisport ingest pattern: každý sport má vlastní ingest složku, runy jsou ve workers, football je speciální větev, non-FB sporty jedou přes společný technický pattern; aktuální pravda je v auditních tabulkách, runtime auditu, worker scan reportech a schema exportech. Pokračujeme podle přiloženého bundle.
"@

Set-Content -Path $readmeFile -Value $readmeText -Encoding UTF8
Write-Host "[README] Written: 000_README_CHAT_CONTEXT.txt (UTF-8)"

Write-Host "======================================"
Write-Host "MATCHMATRIX CHAT CONTEXT BUNDLE DONE"
Write-Host "BUNDLE READY: $bundleDir"
Write-Host "======================================"