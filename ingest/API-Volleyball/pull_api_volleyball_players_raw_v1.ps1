param(
    [string]$BaseUrl = "https://v1.volleyball.api-sports.io",
    [string]$ApiKey = "",
    [string]$HostHeader = "v1.volleyball.api-sports.io",
    [string]$Search = "Ivan",
    [int]$TimeoutSec = 60
)

$ErrorActionPreference = "Stop"

function Resolve-ApiKey {
    param([string]$ExplicitKey)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitKey)) { return $ExplicitKey }
    if (-not [string]::IsNullOrWhiteSpace($env:API_SPORTS_KEY)) { return $env:API_SPORTS_KEY }
    if (-not [string]::IsNullOrWhiteSpace($env:APISPORTS_KEY)) { return $env:APISPORTS_KEY }
    if (-not [string]::IsNullOrWhiteSpace($env:RAPIDAPI_KEY)) { return $env:RAPIDAPI_KEY }

    throw "Chybí API key."
}

$apiKeyValue = Resolve-ApiKey -ExplicitKey $ApiKey

$headers = @{
    "x-apisports-key" = $apiKeyValue
    "x-rapidapi-host" = $HostHeader
}

$url = "$BaseUrl/players?search=$([System.Uri]::EscapeDataString($Search))"

$rawDir = "C:\MatchMatrix-platform\data\raw\api_volleyball\players"
New-Item -ItemType Directory -Force -Path $rawDir | Out-Null

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$safeSearch = ($Search -replace '[^a-zA-Z0-9_-]', '_')
$outFile = Join-Path $rawDir "api_volleyball_players_search_${safeSearch}_${stamp}.json"

Write-Host "=== MATCHMATRIX: VB PLAYERS RAW SAVE V1 ==="
Write-Host "provider=api_volleyball sport=VB entity=players"
Write-Host "search=$Search"
Write-Host "GET $url"
Write-Host "OUT $outFile"

try {
    $resp = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -TimeoutSec $TimeoutSec

    $json = $resp | ConvertTo-Json -Depth 50
    Set-Content -Path $outFile -Value $json -Encoding UTF8

    $resultsCount = $null
    if ($resp.PSObject.Properties.Name -contains "results") {
        $resultsCount = $resp.results
    }

    Write-Host "SUCCESS"
    Write-Host "RESULTS=$resultsCount"
    Write-Host "RAW_SAVED=$outFile"
    exit 0
}
catch {
    Write-Host "FAIL"
    Write-Host $_.Exception.Message
    exit 1
}