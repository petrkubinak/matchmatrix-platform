param(
    [string]$LeagueId = "1",
    [string]$Season = "2024"
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# ENV LOAD
# ------------------------------------------------------------
$envFileCandidates = @(
    "C:\MatchMatrix-platform\ingest\API-American-Football\.env",
    "C:\MatchMatrix-platform\ingest\API-Sport\.env",
    "C:\MatchMatrix-platform\.env"
)

foreach ($envFile in $envFileCandidates) {
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            $line = $_.Trim()

            if ([string]::IsNullOrWhiteSpace($line)) { return }
            if ($line.StartsWith("#")) { return }
            if ($line -notmatch "=") { return }

            $parts = $line -split "=", 2
            $key = $parts[0].Trim()
            $value = $parts[1].Trim().Trim('"').Trim("'")

            if (-not [string]::IsNullOrWhiteSpace($key)) {
                [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }
}

# fallback alias pokud by byl klic pod jinym nazvem
if (-not $env:API_SPORTS_KEY -and $env:API_AMERICAN_FOOTBALL_KEY) {
    $env:API_SPORTS_KEY = $env:API_AMERICAN_FOOTBALL_KEY
}

$PROJECT_ROOT = "C:\MatchMatrix-platform"
$OUT_DIR = Join-Path $PROJECT_ROOT "data\raw\api_american_football\fixtures"

if (!(Test-Path $OUT_DIR)) {
    New-Item -ItemType Directory -Path $OUT_DIR -Force | Out-Null
}

$API_KEY = $env:API_SPORTS_KEY

if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    $API_KEY = $env:APISPORTS_KEY
}

if ([string]::IsNullOrWhiteSpace($API_KEY) -and (Test-Path "C:\MatchMatrix-platform\.env")) {
    $envLines = Get-Content "C:\MatchMatrix-platform\.env"

    foreach ($line in $envLines) {
        $trimmed = $line.Trim()

        if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
        if ($trimmed.StartsWith("#")) { continue }
        if ($trimmed -notmatch "=") { continue }

        $parts = $trimmed -split "=", 2
        $key = $parts[0].Trim()
        $value = $parts[1].Trim().Trim('"').Trim("'")

        if ($key -eq "API_SPORTS_KEY" -or $key -eq "APISPORTS_KEY") {
            $API_KEY = $value
            break
        }
    }
}

if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    throw "Chybi API_SPORTS_KEY v prostredi."
}

$BASE_URL = "https://v1.american-football.api-sports.io"
$URL = "$BASE_URL/games?league=$LeagueId&season=$Season"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = Join-Path $OUT_DIR "api_american_football_fixtures_league_${LeagueId}_season_${Season}_$timestamp.json"

Write-Host "=============================================================="
Write-Host "MATCHMATRIX - AFB FIXTURES PULL"
Write-Host "=============================================================="
Write-Host "PROJECT_ROOT : $PROJECT_ROOT"
Write-Host "BASE_URL     : $BASE_URL"
Write-Host "LEAGUE_ID    : $LeagueId"
Write-Host "SEASON       : $Season"
Write-Host "OUT_FILE     : $outFile"
Write-Host "=============================================================="
Write-Host "RUN:"
Write-Host $URL
Write-Host "--------------------------------------------------------------"

$headers = @{
    "x-apisports-key" = $API_KEY
}

$response = Invoke-RestMethod -Uri $URL -Headers $headers -Method Get -TimeoutSec 120

$response | ConvertTo-Json -Depth 100 | Out-File -FilePath $outFile -Encoding utf8

$itemCount = 0
if ($null -ne $response.response) {
    $itemCount = @($response.response).Count
}

Write-Host "RESULT OK"
Write-Host "items       : $itemCount"
Write-Host "saved_file  : $outFile"
Write-Host "=============================================================="