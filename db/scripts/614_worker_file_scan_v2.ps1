# ============================================================
# 614 - WORKER FILE SCAN V2
# path-aware scan
# ============================================================

$PROJECT_ROOT = "C:\MatchMatrix-platform"

$OUTPUT_FILE = "$PROJECT_ROOT\reports\614_worker_file_scan_v2.csv"

Write-Host "START WORKER FILE SCAN V2..."

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

        $name = ($file.Name + "").ToLower()
        $path = ($file.FullName + "").ToLower()

        if (
            $name -match "run_" -or
            $name -match "ingest" -or
            $name -match "parse" -or
            $name -match "pull" -or
            $name -match "merge"
        ) {

            # ------------------------------------------------
            # sport detection (path-aware)
            # ------------------------------------------------
            $sport = "UNKNOWN"

            if ($path -match "api-football|football-data|api_football|\\fb\\|football") {
                $sport = "FB"
            }
            elseif ($path -match "api-hockey|api_hockey|\\hk\\|hockey") {
                $sport = "HK"
            }
            elseif ($path -match "api-basketball|basketball|api_sport.*basketball|\\bk\\|pull_api_basketball") {
                $sport = "BK"
            }
            elseif ($path -match "api-volleyball|volleyball|\\vb\\|pull_api_volleyball") {
                $sport = "VB"
            }
            elseif ($path -match "handball|\\hb\\|pull_api_handball") {
                $sport = "HB"
            }

            # ------------------------------------------------
            # entity detection
            # ------------------------------------------------
            $entity = "UNKNOWN"

            if ($name -match "team") { $entity = "teams" }
            elseif ($name -match "fixture|match") { $entity = "fixtures" }
            elseif ($name -match "league") { $entity = "leagues" }
            elseif ($name -match "player") { $entity = "players" }
            elseif ($name -match "coach") { $entity = "coaches" }
            elseif ($name -match "odds") { $entity = "odds" }

            # ------------------------------------------------
            # role detection
            # ------------------------------------------------
            $role = "other"

            if ($name -match "^run_" -or $name -match "_run_" -or $name -match "runner") {
                $role = "runner"
            }
            elseif ($name -match "pull|fetch|download") {
                $role = "pull"
            }
            elseif ($name -match "parse|parser|transform") {
                $role = "parser"
            }
            elseif ($name -match "merge|upsert|sync") {
                $role = "merge"
            }
            elseif ($name -match "ingest") {
                $role = "ingest"
            }

            $results += [PSCustomObject]@{
                file_name = $file.Name
                full_path = $file.FullName
                folder    = $folder
                sport     = $sport
                entity    = $entity
                role      = $role
            }
        }
    }
}

$results |
    Sort-Object sport, entity, role, full_path |
    Export-Csv -Path $OUTPUT_FILE -NoTypeInformation -Encoding UTF8

Write-Host "DONE -> $OUTPUT_FILE"