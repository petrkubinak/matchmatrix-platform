# ============================================================
# 614 - WORKER FILE SCAN
# ============================================================

$PROJECT_ROOT = "C:\MatchMatrix-platform"

$OUTPUT_FILE = "$PROJECT_ROOT\reports\614_worker_file_scan.csv"

Write-Host "START WORKER FILE SCAN..."

# folders to scan
$folders = @(
    "$PROJECT_ROOT\workers",
    "$PROJECT_ROOT\ingest"
)

$results = @()

foreach ($folder in $folders) {

    if (!(Test-Path $folder)) {
        Write-Host "SKIP: $folder not found"
        continue
    }

    Write-Host "SCAN: $folder"

    $files = Get-ChildItem -Path $folder -Recurse -File

    foreach ($file in $files) {

        $name = $file.Name.ToLower()

        # detect pattern
        if (
            $name -match "run_" -or
            $name -match "ingest" -or
            $name -match "parse" -or
            $name -match "pull" -or
            $name -match "merge"
        ) {

            # sport detection
            $sport = "UNKNOWN"

            if ($name -match "fb|football") { $sport = "FB" }
            elseif ($name -match "hk|hockey") { $sport = "HK" }
            elseif ($name -match "bk|basketball") { $sport = "BK" }
            elseif ($name -match "vb|volleyball") { $sport = "VB" }
            elseif ($name -match "hb|handball") { $sport = "HB" }

            # entity detection
            $entity = "UNKNOWN"

            if ($name -match "team") { $entity = "teams" }
            elseif ($name -match "fixture|match") { $entity = "fixtures" }
            elseif ($name -match "league") { $entity = "leagues" }
            elseif ($name -match "player") { $entity = "players" }
            elseif ($name -match "coach") { $entity = "coaches" }
            elseif ($name -match "odds") { $entity = "odds" }

            $results += [PSCustomObject]@{
                file_name  = $file.Name
                full_path  = $file.FullName
                sport      = $sport
                entity     = $entity
                folder     = $folder
            }
        }
    }
}

# export
$results | Export-Csv -Path $OUTPUT_FILE -NoTypeInformation -Encoding UTF8

Write-Host "DONE -> $OUTPUT_FILE"