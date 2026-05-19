param(
    [string]$RunId = "manual",
    [string]$FixtureId
)

Write-Host "[VB ODDS] START"
Write-Host "FixtureId: $FixtureId"

# === ENV LOAD ===
$envPaths = @(
    ".env",
    "C:\MatchMatrix-platform\.env",
    "C:\MatchMatrix-platform\ingest\.env"
)

foreach ($path in $envPaths) {
    if (Test-Path $path) {
        Write-Host "[VB ODDS] Loading ENV from $path"
        Get-Content $path | ForEach-Object {
            if ($_ -match "=") {
                $parts = $_ -split "=", 2
                [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1])
            }
        }
    }
}

$apiKey = $env:API_SPORTS_KEY
$baseUrl = "https://v1.volleyball.api-sports.io"

$url = "$baseUrl/odds?game=$FixtureId"

Write-Host "[VB ODDS] URL: $url"

$response = Invoke-RestMethod -Uri $url -Headers @{
    "x-apisports-key" = $apiKey
}

$json = $response | ConvertTo-Json -Depth 50

# HASH
$hash = [System.BitConverter]::ToString(
    (New-Object System.Security.Cryptography.SHA256Managed).ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($json)
    )
) -replace "-", ""

Write-Host "[VB ODDS] HASH: $hash"

$sqlPath = "C:\MatchMatrix-platform\temp_vb_odds_insert.sql"

@"
INSERT INTO staging.stg_api_payloads
(provider, sport_code, entity_type, endpoint_name, external_id, payload_json, payload_hash, parse_status, created_at)
VALUES
('api_volleyball', 'VB', 'odds', 'odds', '$FixtureId', `$mmjson`$
$json
`$mmjson`$::jsonb, '$hash', 'pending', now());
"@ | Set-Content -Path $sqlPath -Encoding UTF8

docker cp $sqlPath matchmatrix_postgres:/tmp/temp_vb_odds_insert.sql
docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -f /tmp/temp_vb_odds_insert.sql

Write-Host "[VB ODDS] DONE"