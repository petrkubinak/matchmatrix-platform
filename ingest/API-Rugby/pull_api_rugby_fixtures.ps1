param(
    [string]$League = "51",
    [string]$Season = "2024"
)

$ErrorActionPreference = "Stop"

Write-Host "======================================================================"
Write-Host "MATCHMATRIX - API RUGBY FIXTURES PULL"
Write-Host "======================================================================"
Write-Host "League : $League"
Write-Host "Season : $Season"

$apiKey = $env:APISPORTS_KEY
if (-not $apiKey) {
    throw "Chybi APISPORTS_KEY v prostredi."
}

$baseDir = "C:\MatchMatrix-platform"
$outDir = Join-Path $baseDir "data\raw\api_rugby\fixtures"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = Join-Path $outDir "api_rugby_fixtures_${League}_season_${Season}_$timestamp.json"

$url = "https://v1.rugby.api-sports.io/games?league=$League&season=$Season"

$headers = @{
    "x-rapidapi-key"  = $apiKey
    "x-rapidapi-host" = "v1.rugby.api-sports.io"
}

Write-Host "URL    : $url"
Write-Host "Output : $outFile"

$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec 120
$response | ConvertTo-Json -Depth 30 | Set-Content -Path $outFile -Encoding UTF8

Write-Host "DONE"
Write-Host "Saved: $outFile"