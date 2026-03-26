param(
    [string]$RunId = "",
    [string]$LeagueId = "",
    [string]$Season = ""
)

# ============================================================
# MATCHMATRIX - API HOCKEY COACHES PULL
# ============================================================

$BASE_URL = "https://v1.hockey.api-sports.io/coachs"
$envPath = "C:\MatchMatrix-platform\ingest\API-Hockey\.env"

if (-not (Test-Path $envPath)) {
    throw ".env nebyl nalezen: $envPath"
}

Get-Content $envPath | ForEach-Object {
    if ($_ -match '^\s*#') { return }
    if ($_ -match '^\s*$') { return }
    if ($_ -match '=') {
        $parts = $_ -split '=', 2
        $key = $parts[0].Trim()
        $value = $parts[1].Trim()
        [System.Environment]::SetEnvironmentVariable($key, $value)
    }
}

$API_KEY = $env:API_KEY
if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    $API_KEY = $env:APISPORTS_KEY
}

if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    throw "Chybí API key v .env (API_KEY nebo APISPORTS_KEY)."
}

$headers = @{
    "x-apisports-key" = $API_KEY
    "Accept" = "application/json"
}

Write-Host "=== MATCHMATRIX: API-HOCKEY COACHES PULL ==="

$PSQL = "docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -t -A"

# ------------------------------------------------------------
# 1) načtení 1 pending jobu
# ------------------------------------------------------------
$query = @"
select id, provider_league_id, season
from ops.ingest_planner
where provider = 'api_hockey'
  and sport_code = 'HK'
  and entity = 'coaches'
  and status = 'pending'
order by id
limit 1;
"@

$job = Invoke-Expression "$PSQL -c `"$query`""

if ([string]::IsNullOrWhiteSpace($job)) {
    Write-Host "Žádný job k dispozici."
    exit
}

$parts = $job.Trim() -split "\|"
$jobId = $parts[0].Trim()
$league = $parts[1].Trim()
$season = $parts[2].Trim()

Write-Host "JOB: $jobId league=$league season=$season"

if ([string]::IsNullOrWhiteSpace($league)) {
    throw "Job nemá provider_league_id."
}

# ------------------------------------------------------------
# 2) složení URL
# ------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($season)) {
    $url = "${BASE_URL}?team=$league"
} else {
    $url = "${BASE_URL}?team=$league&season=$season"
}

Write-Host "URL: $url"

# ------------------------------------------------------------
# 3) API call
# ------------------------------------------------------------
try {
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec 60
} catch {
    Write-Host "API CALL FAILED: $($_.Exception.Message)"

    $updateErr = @"
update ops.ingest_planner
set status = 'error'
where id = $jobId;
"@
    Invoke-Expression "$PSQL -c `"$updateErr`""
    throw
}

$json = $response | ConvertTo-Json -Depth 20 -Compress

# uložíme JSON do dočasného souboru, aby se nerozbil quoting v psql
$tempJsonPath = "C:\MatchMatrix-platform\logs\temp_api_hockey_coaches_payload.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($tempJsonPath, $json, $utf8NoBom)

if ([string]::IsNullOrWhiteSpace($season)) {
    $seasonSql = "NULL"
} else {
    $seasonSql = "'$season'"
}

$insert = @"
insert into staging.stg_api_payloads
(
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    payload_json,
    fetched_at,
    parse_status
)
values
(
    'api_hockey',
    'hockey',
    'coaches',
    'coachs',
    '$league',
    $seasonSql,
    pg_read_file('/var/lib/postgresql/temp_api_hockey_coaches_payload.json')::jsonb,
    now(),
    'pending'
);
"@

# zkopíruj soubor do kontejneru Postgres
docker cp $tempJsonPath matchmatrix_postgres:/var/lib/postgresql/temp_api_hockey_coaches_payload.json | Out-Null

Invoke-Expression "$PSQL -c `"$insert`""
# ------------------------------------------------------------
# 5) update planner
# ------------------------------------------------------------
$update = @"
update ops.ingest_planner
set status = 'done'
where id = $jobId;
"@

Invoke-Expression "$PSQL -c `"$update`""

Write-Host "DONE"