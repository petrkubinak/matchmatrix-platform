param(
    [Parameter(Mandatory = $false)]
    [string]$RunId = "",

    [Parameter(Mandatory = $false)]
    [string]$SportCode = "hockey",

    [Parameter(Mandatory = $false)]
    [string]$Provider = "api_hockey",

    [Parameter(Mandatory = $false)]
    [string]$EndpointName = "leagues",

    [Parameter(Mandatory = $false)]
    [string]$ApiBase = "https://v1.hockey.api-sports.io",

    [Parameter(Mandatory = $false)]
    [string]$ApiKey = ""
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    Write-Host "[pull_api_hockey_leagues] $Message"
}

function Load-DotEnvFile {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    if (-not (Test-Path $Path)) { return }

    Write-Log "Načítám ENV z: $Path"

    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()

        if ([string]::IsNullOrWhiteSpace($line)) { return }
        if ($line.StartsWith("#")) { return }

        $eqIndex = $line.IndexOf("=")
        if ($eqIndex -lt 1) { return }

        $name = $line.Substring(0, $eqIndex).Trim()
        $value = $line.Substring($eqIndex + 1).Trim()

        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

function Resolve-ApiKey {
    param([string]$ExplicitKey)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitKey)) {
        return $ExplicitKey
    }

    $key = [Environment]::GetEnvironmentVariable("API_SPORTS_KEY")
    if (-not [string]::IsNullOrWhiteSpace($key)) {
        Write-Log "Použit API klíč z ENV: API_SPORTS_KEY"
        return $key
    }

    $key = [Environment]::GetEnvironmentVariable("APISPORTS_KEY")
    if (-not [string]::IsNullOrWhiteSpace($key)) {
        Write-Log "Použit API klíč z ENV: APISPORTS_KEY"
        return $key
    }

    throw "Chybí API key. Předej -ApiKey nebo nastav ENV."
}

function Escape-SqlLiteral {
    param([string]$Value)

    if ($null -eq $Value) {
        return ""
    }

    return $Value.Replace("'", "''")
}

# Načtení ENV
Load-DotEnvFile ".env"
Load-DotEnvFile "C:/MatchMatrix-platform/.env"
Load-DotEnvFile "C:/MatchMatrix-platform/ingest/.env"

$ApiKey = Resolve-ApiKey -ExplicitKey $ApiKey

$Url = "$ApiBase/$EndpointName"

Write-Log "Sport      : $SportCode"
Write-Log "RunId      : $RunId"
Write-Log "Provider   : $Provider"
Write-Log "Endpoint   : $EndpointName"
Write-Log "API Base   : $ApiBase"
Write-Log "URL        : $Url"
Write-Log "Volám API-Hockey leagues endpoint..."

$headers = @{
    "x-apisports-key" = $ApiKey
}

$response = Invoke-RestMethod -Uri $Url -Headers $headers -Method GET

$results = 0
if ($null -ne $response.results) {
    $results = [int]$response.results
}

Write-Log "API call OK. Results: $results"

$payloadJson = $response | ConvertTo-Json -Depth 100 -Compress

$payloadHash = [System.BitConverter]::ToString(
    [System.Security.Cryptography.SHA256]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($payloadJson)
    )
).Replace("-", "").ToLower()

Write-Log "Payload SHA256: $payloadHash"

$providerSql   = Escape-SqlLiteral $Provider
$sportSql      = Escape-SqlLiteral $SportCode
$entitySql     = Escape-SqlLiteral "leagues"
$endpointSql   = Escape-SqlLiteral $EndpointName
$externalIdSql = Escape-SqlLiteral $SportCode
$payloadSql    = Escape-SqlLiteral $payloadJson
$hashSql       = Escape-SqlLiteral $payloadHash
$messageSql    = Escape-SqlLiteral "leagues pull OK | sport=$SportCode | results=$results | run_id=$RunId"

$sql = @"
INSERT INTO staging.stg_api_payloads
(
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    payload_json,
    payload_hash,
    parse_status,
    parse_message,
    created_at
)
VALUES
(
    '$providerSql',
    '$sportSql',
    '$entitySql',
    '$endpointSql',
    '$externalIdSql',
    NULL,
    '$payloadSql'::jsonb,
    '$hashSql',
    'pending',
    '$messageSql',
    now()
);
"@

# Ulož SQL do temp souboru kvůli dlouhému payloadu
$tempSqlFile = Join-Path $env:TEMP ("matchmatrix_api_hockey_leagues_" + $RunId + ".sql")
Set-Content -Path $tempSqlFile -Value $sql -Encoding UTF8

try {
    Write-Log "DB insert přes docker exec do kontejneru: matchmatrix_postgres"
    Get-Content -Path $tempSqlFile | docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix

    if ($LASTEXITCODE -ne 0) {
        throw "docker exec psql skončil s kódem $LASTEXITCODE"
    }
}
finally {
    if (Test-Path $tempSqlFile) {
        Remove-Item $tempSqlFile -Force
    }
}

Write-Log "Payload uložen do staging.stg_api_payloads"
Write-Log "Hotovo."