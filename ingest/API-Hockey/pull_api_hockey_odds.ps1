param(
    [string]$RunId = "manual",
    [string]$FixtureId
)

Write-Host "[HK ODDS] START"
Write-Host "FixtureId: $FixtureId"

$envPaths = @(
    ".env",
    "C:\MatchMatrix-platform\.env",
    "C:\MatchMatrix-platform\ingest\.env"
)

foreach ($path in $envPaths) {
    if (Test-Path $path) {
        Write-Host "[HK ODDS] Loading ENV from $path"
        Get-Content $path | ForEach-Object {
            if ($_ -match "=") {
                $parts = $_ -split "=", 2
                [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1])
            }
        }
    }
}

$apiKey = $env:API_SPORTS_KEY
$baseUrl = "https://v1.hockey.api-sports.io"
$url = "$baseUrl/odds?game=$FixtureId"

Write-Host "[HK ODDS] URL: $url"

$response = Invoke-RestMethod -Uri $url -Headers @{
    "x-apisports-key" = $apiKey
}

$json = $response | ConvertTo-Json -Depth 50

$hash = [System.BitConverter]::ToString(
    (New-Object System.Security.Cryptography.SHA256Managed).ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($json)
    )
) -replace "-", ""

Write-Host "[HK ODDS] HASH: $hash"

$sqlPath = "C:\MatchMatrix-platform\temp_hk_odds_insert.sql"

@"
INSERT INTO staging.stg_api_payloads
(provider, sport_code, entity_type, endpoint_name, external_id, payload_json, payload_hash, parse_status, created_at)
VALUES
('api_hockey', 'HK', 'odds', 'odds', '$FixtureId', `$mmjson`$
$json
`$mmjson`$::jsonb, '$hash', 'pending', now());
"@ | Set-Content -Path $sqlPath -Encoding UTF8

docker cp $sqlPath matchmatrix_postgres:/tmp/temp_hk_odds_insert.sql
docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -f /tmp/temp_hk_odds_insert.sql

Write-Host "[HK ODDS] DONE"