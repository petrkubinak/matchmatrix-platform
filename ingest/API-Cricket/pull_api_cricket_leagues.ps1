param(
    [string]$League = "IPL",
    [string]$Season = "2024"
)

$ErrorActionPreference = "Stop"

Write-Host "======================================================================"
Write-Host "MATCHMATRIX - API CRICKET LEAGUES PULL"
Write-Host "======================================================================"
Write-Host "League : $League"
Write-Host "Season : $Season"

$envPath = "C:\MatchMatrix-platform\.env"
if (Test-Path $envPath) {
    Get-Content $envPath | ForEach-Object {
        if ($_ -match '^\s*#') { return }
        if ($_ -match '^\s*$') { return }
        $parts = $_ -split '=', 2
        if ($parts.Count -eq 2) {
            [System.Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim())
        }
    }
}

$apiKey = $env:APISPORTS_KEY
if (-not $apiKey) {
    throw "Chybi API_SPORTS_KEY v .env"
}

$baseDir = "C:\MatchMatrix-platform"
$outDir = Join-Path $baseDir "data\raw\api_cricket\leagues"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = Join-Path $outDir "api_cricket_leagues_${League}_season_${Season}_$timestamp.json"

# TODO: uprav endpoint podle realne dokumentace providera
$url = "https://v1.cricket.api-sports.io/leagues?league=$League&season=$Season"

$headers = @{
    "x-rapidapi-key"  = $apiKey
    "x-rapidapi-host" = "v1.cricket.api-sports.io"
}

Write-Host "URL    : $url"
Write-Host "Output : $outFile"

$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec 120
$response | ConvertTo-Json -Depth 20 | Set-Content -Path $outFile -Encoding UTF8

Write-Host "DONE"
Write-Host "Saved: $outFile"