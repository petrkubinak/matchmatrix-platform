param(
    [string]$LeagueId = "1",
    [string]$Season = "2024"
)

$ErrorActionPreference = "Stop"

$PROJECT_ROOT = "C:\MatchMatrix-platform"
$OUT_DIR = Join-Path $PROJECT_ROOT "data\raw\api_american_football\teams"

if (!(Test-Path $OUT_DIR)) {
    New-Item -ItemType Directory -Path $OUT_DIR -Force | Out-Null
}

# sjednoceni API-Sports key
$API_KEY = [Environment]::GetEnvironmentVariable("API_SPORTS_KEY", "Process")
if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    $API_KEY = [Environment]::GetEnvironmentVariable("API_SPORTS_KEY", "User")
}
if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    $API_KEY = [Environment]::GetEnvironmentVariable("API_SPORTS_KEY", "Machine")
}

if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    throw "Chybi API_AMERICAN_FOOTBALL_KEY v prostredi."
}

$BASE_URL = "https://v1.american-football.api-sports.io"
$URL = "$BASE_URL/teams?league=$LeagueId&season=$Season"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = Join-Path $OUT_DIR "api_american_football_teams_league_${LeagueId}_season_${Season}_$timestamp.json"

Write-Host "=============================================================="
Write-Host "MATCHMATRIX - AFB TEAMS PULL"
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