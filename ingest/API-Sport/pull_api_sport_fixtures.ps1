param(
    [Parameter(Mandatory = $true)]
    [string]$SportCode,

    [Parameter(Mandatory = $true)]
    [string]$LeagueId,

    [Parameter(Mandatory = $false)]
    [string]$Season = "",

    [Parameter(Mandatory = $false)]
    [string]$From = "",

    [Parameter(Mandatory = $false)]
    [string]$To = "",

    [Parameter(Mandatory = $false)]
    [string]$RunId = "",

    [Parameter(Mandatory = $false)]
    [string]$Provider = "api_sport",

    [Parameter(Mandatory = $false)]
    [string]$ApiBase = "",

    [Parameter(Mandatory = $false)]
    [string]$ApiKey = "",

    [Parameter(Mandatory = $false)]
    [string]$EndpointName = "fixtures",

    [Parameter(Mandatory = $false)]
    [string]$ExternalId = "",

    [Parameter(Mandatory = $false)]
    [string]$DockerContainer = "matchmatrix_postgres",

    [Parameter(Mandatory = $false)]
    [switch]$SkipDb,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    Write-Host "[pull_api_sport_fixtures] $Message"
}

function Escape-SqlLiteral {
    param([AllowNull()][string]$Value)
    if ($null -eq $Value) { return "NULL" }
    return "'" + ($Value -replace "'", "''") + "'"
}

function Resolve-ApiKey {
    param([string]$ExplicitKey, [string]$Sport)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitKey)) {
        return $ExplicitKey
    }

    $candidates = @(
        "API_SPORTS_KEY",
        "API_SPORT_KEY",
        "API_KEY",
        "RAPIDAPI_KEY",
        ("API_{0}_KEY" -f $Sport.ToUpper()),
        ("API_{0}_SPORTS_KEY" -f $Sport.ToUpper())
    )

    foreach ($name in $candidates) {
        $value = [Environment]::GetEnvironmentVariable($name)
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            Write-Log "Použit API klíč z ENV: $name"
            return $value
        }
    }

    throw "Chybí API key. Předej -ApiKey nebo nastav ENV (např. API_SPORTS_KEY)."
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

    if ($sportKey -eq "tennis") {
        throw "Sport 'tennis' není podporovaný providerem api_sport. Pro TN použij samostatný tennis provider."
    }

    $apiBaseMap = @{
        football   = "https://v3.football.api-sports.io"
        hockey     = "https://v1.hockey.api-sports.io"
        basketball = "https://v1.basketball.api-sports.io"
        baseball   = "https://v1.baseball.api-sports.io"
        volleyball = "https://v1.volleyball.api-sports.io"
        handball   = "https://v1.handball.api-sports.io"
        rugby      = "https://v1.rugby.api-sports.io"
        mma        = "https://v1.mma.api-sports.io"
        nfl        = "https://v1.american-football.api-sports.io"
        nba        = "https://v1.nba.api-sports.io"
    }

    if (-not $apiBaseMap.ContainsKey($sportKey)) {
        throw "Sport '$sportKey' není podporovaný providerem api_sport v Resolve-ApiBase. Pro tento sport použij jiný provider."
    }

    return $apiBaseMap[$sportKey]
}

function Resolve-EndpointName {
    param(
        [string]$SportCode,
        [string]$RequestedEndpointName
    )

    $requested = ""
    if ($null -ne $RequestedEndpointName) {
        $requested = [string]$RequestedEndpointName
    }

    if (-not [string]::IsNullOrWhiteSpace($requested) -and $requested.Trim().ToLower() -ne "fixtures") {
        return $requested.Trim().ToLower()
    }

    $sportValue = ""
    if ($null -ne $SportCode) {
        $sportValue = [string]$SportCode
    }

    $sportKey = $sportValue.Trim().ToLower()

    switch ($sportKey) {
        "basketball" { return "games" }
        "hockey"     { return "games" }
        "baseball"   { return "games" }
        "volleyball" { return "games" }
        "handball"   { return "games" }
        default      { return "fixtures" }
    }
}

function Build-FixturesUrl {
    param(
        [string]$Base,
        [string]$ResolvedEndpointName,
        [string]$League,
        [string]$SeasonValue,
        [string]$FromValue,
        [string]$ToValue
    )

    $pairs = @()

    if (-not [string]::IsNullOrWhiteSpace($League)) {
        $pairs += "league=$League"
    }
    if (-not [string]::IsNullOrWhiteSpace($SeasonValue)) {
        $pairs += "season=$SeasonValue"
    }
    if (-not [string]::IsNullOrWhiteSpace($FromValue)) {
        $pairs += "from=$FromValue"
    }
    if (-not [string]::IsNullOrWhiteSpace($ToValue)) {
        $pairs += "to=$ToValue"
    }

    $query = ""
    if ($pairs.Count -gt 0) {
        $query = "?" + ($pairs -join "&")
    }

    if (-not [string]::IsNullOrWhiteSpace($ResolvedEndpointName)) {
        return ($Base.TrimEnd("/") + "/" + $ResolvedEndpointName.Trim() + $query)
    }

    throw "Build-FixturesUrl: ResolvedEndpointName je prázdný."
}

function Load-DotEnv {
    param([string[]]$Paths)

    foreach ($path in $Paths) {
        if (-not (Test-Path $path)) { continue }
        Write-Log "Načítám ENV z: $path"

        Get-Content $path | ForEach-Object {
            $line = $_.Trim()
            if ([string]::IsNullOrWhiteSpace($line)) { return }
            if ($line.StartsWith('#')) { return }
            $idx = $line.IndexOf('=')
            if ($idx -lt 1) { return }

            $name = $line.Substring(0, $idx).Trim()
            $value = $line.Substring($idx + 1).Trim().Trim('"')

            if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) {
                [Environment]::SetEnvironmentVariable($name, $value)
            }
        }
    }
}

function Get-DbExecCommand {
    $databaseUrl = [Environment]::GetEnvironmentVariable("DATABASE_URL")
    if (-not [string]::IsNullOrWhiteSpace($databaseUrl)) {
        return @{ Mode = "local_psql_url"; Value = $databaseUrl }
    }

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
            Mode  = "local_psql_parts"
            Host  = $dbHost
            Port  = $dbPort
            Db    = $dbName
            User  = $dbUser
            Pass  = $dbPass
        }
    }

    return @{ Mode = "docker_psql" }
}

function Invoke-SqlText {
    param(
        [string]$SqlText,
        [string]$DockerContainerName
    )

    $db = Get-DbExecCommand
    $tempSql = Join-Path $env:TEMP ("mm_api_sport_fixtures_{0}.sql" -f ([guid]::NewGuid().ToString("N")))
    Set-Content -Path $tempSql -Value $SqlText -Encoding UTF8

    try {
        switch ($db.Mode) {
            "local_psql_url" {
                Write-Log "DB insert přes lokální psql + DATABASE_URL"
                & psql "$($db.Value)" -v ON_ERROR_STOP=1 -f $tempSql
                if ($LASTEXITCODE -ne 0) {
                    throw "local psql (DATABASE_URL) skončil s kódem $LASTEXITCODE"
                }
                break
            }
            "local_psql_parts" {
                Write-Log "DB insert přes lokální psql + POSTGRES_*"
                $env:PGPASSWORD = $db.Pass
                & psql -h $db.Host -p $db.Port -U $db.User -d $db.Db -v ON_ERROR_STOP=1 -f $tempSql
                if ($LASTEXITCODE -ne 0) {
                    throw "local psql (POSTGRES_*) skončil s kódem $LASTEXITCODE"
                }
                break
            }
            default {
                Write-Log "DB insert přes docker exec do kontejneru: $DockerContainerName"
                Get-Content $tempSql | docker exec -i $DockerContainerName psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1
                if ($LASTEXITCODE -ne 0) {
                    throw "docker exec psql skončil s kódem $LASTEXITCODE"
                }
                break
            }
        }
    }
    finally {
        if (Test-Path $tempSql) {
            Remove-Item $tempSql -Force -ErrorAction SilentlyContinue
        }
    }
}

# ------------------------------------------------------------
# 1) ENV bootstrap
# ------------------------------------------------------------
Load-DotEnv @(
    ".env",
    "ingest/.env",
    "ingest/API-Sport/.env",
    "C:/MatchMatrix-platform/.env",
    "C:/MatchMatrix-platform/ingest/.env",
    "C:/MatchMatrix-platform/ingest/API-Sport/.env"
)

# ------------------------------------------------------------
# 2) Vstupní normalizace
# ------------------------------------------------------------
$SportCode = $SportCode.Trim().ToLower()
$LeagueId  = $LeagueId.Trim()
$Season    = $Season.Trim()
$From      = $From.Trim()
$To        = $To.Trim()
$Provider  = $Provider.Trim()

if (-not $Season -or $Season -eq "" -or $Season -eq "0") {
    $Season = "2024"
    Write-Log "Season not set or 0 -> using fallback 2024"
}

if ([string]::IsNullOrWhiteSpace($RunId)) {
    $RunId = Get-Date -Format "yyyyMMddHHmmssfff"
}

if ([string]::IsNullOrWhiteSpace($ExternalId)) {
    if (-not [string]::IsNullOrWhiteSpace($Season)) {
        $ExternalId = "$LeagueId`_$Season"
    }
    else {
        $ExternalId = $LeagueId
    }
}

$ApiBase = Resolve-ApiBase -CurrentApiBase $ApiBase -Sport $SportCode
$ApiKey  = Resolve-ApiKey -ExplicitKey $ApiKey -Sport $SportCode

$ResolvedEndpointName = Resolve-EndpointName -SportCode $SportCode -RequestedEndpointName $EndpointName

$Url = Build-FixturesUrl `
    -Base $ApiBase `
    -ResolvedEndpointName $ResolvedEndpointName `
    -League $LeagueId `
    -SeasonValue $Season `
    -FromValue $From `
    -ToValue $To

Write-Log "Sport      : $SportCode"
Write-Log "LeagueId   : $LeagueId"
Write-Log "Season     : $Season"
Write-Log "From       : $From"
Write-Log "To         : $To"
Write-Log "RunId      : $RunId"
Write-Log "Provider   : $Provider"
Write-Log "Endpoint   : $ResolvedEndpointName"
Write-Log "ExternalId : $ExternalId"
Write-Log "API Base   : $ApiBase"
Write-Log "URL        : $Url"

# ------------------------------------------------------------
# 3) API call
# ------------------------------------------------------------
$headers = @{
    "x-rapidapi-key"  = $ApiKey
    "x-rapidapi-host" = ("v1.{0}.api-sports.io" -f $SportCode)
}

Write-Log "Volám API-Sports fixtures endpoint..."
$response = Invoke-RestMethod -Uri $Url -Headers $headers -Method GET -TimeoutSec 120

if ($null -eq $response) {
    throw "API vrátilo prázdnou odpověď."
}

$payloadJson = $response | ConvertTo-Json -Depth 100 -Compress
$payloadHash = [System.BitConverter]::ToString(
    [System.Security.Cryptography.SHA256]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($payloadJson)
    )
).Replace("-", "").ToLower()

$resultsCount = 0
if ($response.PSObject.Properties.Name -contains 'results') {
    $resultsCount = [int]$response.results
}
elseif ($response.PSObject.Properties.Name -contains 'response' -and $null -ne $response.response) {
    try {
        $resultsCount = @($response.response).Count
    }
    catch {
        $resultsCount = 0
    }
}

Write-Log "API call OK. Results: $resultsCount"
Write-Log "Payload SHA256: $payloadHash"

if ($DryRun) {
    Write-Log "DRY RUN = bez insertu do DB."
    return
}

if ($SkipDb) {
    Write-Log "SKIP DB = payload nestoruji."
    return
}

# ------------------------------------------------------------
# 4) Insert do staging.stg_api_payloads
# FIX: payload musí jít do DB jako pending, ne processed
# processed nastavuje až parser run_parse_api_sport_fixtures_v1.py
# ------------------------------------------------------------
$providerSql   = Escape-SqlLiteral $Provider
$sportSql      = Escape-SqlLiteral $SportCode
$entitySql     = Escape-SqlLiteral "fixtures"
$endpointSql   = Escape-SqlLiteral $ResolvedEndpointName
$externalIdSql = Escape-SqlLiteral $ExternalId
$seasonSql     = if ([string]::IsNullOrWhiteSpace($Season)) { "NULL" } else { Escape-SqlLiteral $Season }
$hashSql       = Escape-SqlLiteral $payloadHash
$payloadSql    = Escape-SqlLiteral $payloadJson
$messageSql    = Escape-SqlLiteral ("fixtures pull OK | league={0} | season={1} | results={2} | run_id={3}" -f $LeagueId, $Season, $resultsCount, $RunId)

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
    $providerSql,
    $sportSql,
    $entitySql,
    $endpointSql,
    $externalIdSql,
    $seasonSql,
    $payloadSql::jsonb,
    $hashSql,
    'pending',
    $messageSql,
    now()
);
"@

Invoke-SqlText -SqlText $sql -DockerContainerName $DockerContainer

Write-Log "Payload uložen do staging.stg_api_payloads se stavem parse_status='pending'"

# ------------------------------------------------------------
# 5) Auto-parse binding -> stg_provider_fixtures
# ------------------------------------------------------------
$ParserScript = "C:\MatchMatrix-platform\workers\run_parse_api_sport_fixtures_v1.py"

if (Test-Path $ParserScript) {
    Write-Log "Spouštím parser: $ParserScript"

    & "C:\Python314\python.exe" $ParserScript

    if ($LASTEXITCODE -ne 0) {
        throw "Parser run_parse_api_sport_fixtures_v1.py skončil s kódem $LASTEXITCODE"
    }

    Write-Log "Parser dokončen OK."
}
else {
    throw "Parser script nebyl nalezen: $ParserScript"
}

Write-Log "Hotovo."