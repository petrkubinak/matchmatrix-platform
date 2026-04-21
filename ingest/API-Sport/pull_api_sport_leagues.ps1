param(
    [Parameter(Mandatory = $false)]
    [string]$SportCode,

    [Parameter(Mandatory = $false)]
    [string]$LeagueId,

    [Parameter(Mandatory = $false)]
    [string]$Season,

    [Parameter(Mandatory = $false)]
    [string]$RunId,

    [Parameter(Mandatory = $false)]
    [string]$Provider = "api_sport",

    [Parameter(Mandatory = $false)]
    [string]$EndpointName = "leagues",

    [Parameter(Mandatory = $false)]
    [string]$ApiBase,

    [Parameter(Mandatory = $false)]
    [string]$ApiKey
)

function Write-Log {
    param([string]$Message)
    Write-Host "[pull_api_sport_leagues] $Message"
}

function Load-DotEnvFile {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    if (-not (Test-Path $Path)) { return }

    Write-Log "Nacitám ENV z: $Path"

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

function Resolve-ApiBase {
    param(
        [string]$CurrentApiBase,
        [string]$Sport
    )

    if (-not [string]::IsNullOrWhiteSpace($CurrentApiBase)) {
        return $CurrentApiBase
    }

    $sportValue = ""
    if ($null -ne $Sport) {
        $sportValue = [string]$Sport
    }

    $sportKey = $sportValue.Trim().ToLower()

    $apiBaseMap = @{
        football          = "https://v3.football.api-sports.io"
        hockey            = "https://v1.hockey.api-sports.io"
        basketball        = "https://v1.basketball.api-sports.io"
        baseball          = "https://v1.baseball.api-sports.io"
        volleyball        = "https://v1.volleyball.api-sports.io"
        handball          = "https://v1.handball.api-sports.io"
        rugby             = "https://v1.rugby.api-sports.io"
        mma               = "https://v1.mma.api-sports.io"
        american_football = "https://v1.american-football.api-sports.io"
        nfl               = "https://v1.american-football.api-sports.io"
    }

    if (-not $apiBaseMap.ContainsKey($sportKey)) {
        throw "Sport '$sportKey' neni podporovaný providerem api_sport."
    }

    return $apiBaseMap[$sportKey]
}

function Resolve-ApiKey {
    param(
        [string]$ExplicitKey,
        [string]$Sport
    )

    if (-not [string]::IsNullOrWhiteSpace($ExplicitKey)) {
        return $ExplicitKey
    }

    $key = [Environment]::GetEnvironmentVariable("API_SPORTS_KEY")
    if (-not [string]::IsNullOrWhiteSpace($key)) {
        Write-Log "Pouzit API klic z ENV: API_SPORTS_KEY"
        return $key
    }

    $key = [Environment]::GetEnvironmentVariable("APISPORTS_KEY")
    if (-not [string]::IsNullOrWhiteSpace($key)) {
        Write-Log "Pouzit API klic z ENV: APISPORTS_KEY"
        return $key
    }

    throw "Chybi API key. Predej -ApiKey nebo nastav ENV."
}

function Escape-SqlLiteral {
    param([string]$Value)

    if ($null -eq $Value) {
        return ""
    }

    return $Value.Replace("'", "''")
}

function Get-DbExecCommand {
    $dbHost = [Environment]::GetEnvironmentVariable("POSTGRES_HOST")
    $dbPort = [Environment]::GetEnvironmentVariable("POSTGRES_PORT")
    $dbName = [Environment]::GetEnvironmentVariable("POSTGRES_DB")
    $dbUser = [Environment]::GetEnvironmentVariable("POSTGRES_USER")
    $dbPass = [Environment]::GetEnvironmentVariable("POSTGRES_PASSWORD")

    if (
        -not [string]::IsNullOrWhiteSpace($dbHost) -and
        -not [string]::IsNullOrWhiteSpace($dbPort) -and
        -not [string]::IsNullOrWhiteSpace($dbName) -and
        -not [string]::IsNullOrWhiteSpace($dbUser)
    ) {
        return @{
            Mode = "local_psql_parts"
            Host = $dbHost
            Port = $dbPort
            Db   = $dbName
            User = $dbUser
            Pass = $dbPass
        }
    }

    return @{
        Mode      = "docker_exec"
        Container = "matchmatrix_postgres"
        Db        = "matchmatrix"
        User      = "matchmatrix"
    }
}

Load-DotEnvFile ".env"
Load-DotEnvFile "C:/MatchMatrix-platform/.env"
Load-DotEnvFile "C:/MatchMatrix-platform/ingest/.env"

$ApiBase = Resolve-ApiBase -CurrentApiBase $ApiBase -Sport $SportCode
$ApiKey  = Resolve-ApiKey -ExplicitKey $ApiKey -Sport $SportCode

$Url = "$ApiBase/leagues"

Write-Log "Sport      : $SportCode"
Write-Log "LeagueId   : $LeagueId"
Write-Log "Season     : $Season"
Write-Log "RunId      : $RunId"
Write-Log "Provider   : $Provider"
Write-Log "Endpoint   : $EndpointName"
Write-Log "API Base   : $ApiBase"
Write-Log "URL        : $Url"
Write-Log "Volam API-Sports leagues endpoint..."

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
$seasonSql     = Escape-SqlLiteral $Season
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
    NULLIF('$seasonSql',''),
    '$payloadSql'::jsonb,
    '$hashSql',
    'pending',
    '$messageSql',
    now()
);
"@

$db = Get-DbExecCommand

# SQL ulozime do docasneho souboru, at nenarazime na limit delky command line
$tempSqlFile = Join-Path $env:TEMP ("matchmatrix_api_sport_leagues_" + $RunId + ".sql")
Set-Content -Path $tempSqlFile -Value $sql -Encoding UTF8

try {
    if ($db.Mode -eq "docker_exec") {
        Write-Log "DB insert pres docker exec do kontejneru: $($db.Container)"
        Get-Content -Path $tempSqlFile | docker exec -i $($db.Container) psql -U $($db.User) -d $($db.Db)
        if ($LASTEXITCODE -ne 0) {
            throw "docker exec psql skoncil s kodem $LASTEXITCODE"
        }
    }
    else {
        Write-Log "DB insert pres local psql"
        $env:PGPASSWORD = $db.Pass
        psql -h $db.Host -p $db.Port -U $db.User -d $db.Db -f $tempSqlFile
        if ($LASTEXITCODE -ne 0) {
            throw "local psql skoncil s kodem $LASTEXITCODE"
        }
    }

    Write-Log "RAW payload insert OK."
}
finally {
    if (Test-Path $tempSqlFile) {
        Remove-Item $tempSqlFile -Force -ErrorAction SilentlyContinue
    }
}

# =========================================================
# PARSE BINDING -> stg_provider_leagues
# =========================================================
$ParserScript = "C:\MatchMatrix-platform\workers\run_parse_api_sport_leagues_v1.py"

if (Test-Path $ParserScript) {
    Write-Log "Spoustim parser: $ParserScript"

    & "C:\Python314\python.exe" $ParserScript `
        --provider $Provider `
        --sport $SportCode `
        --entity "leagues"

    if ($LASTEXITCODE -ne 0) {
        throw "Parser run_parse_api_sport_leagues_v1.py skoncil s kodem $LASTEXITCODE"
    }

    Write-Log "Parser dokoncen OK."
}
else {
    throw "Parser script nebyl nalezen: $ParserScript"
}