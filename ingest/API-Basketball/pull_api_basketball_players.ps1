param(
    [string]$BaseUrl = "https://v1.basketball.api-sports.io",
    [string]$ApiKey = "",
    [string]$HostHeader = "v1.basketball.api-sports.io",
    [string]$TeamId = "",
    [string]$LeagueId = "",
    [string]$Season = "",
    [string]$Search = "",
    [string]$RunId = "",
    [string]$OutputPath = "",
    [int]$TimeoutSec = 60
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] $Message"
}

function Resolve-ApiKey {
    param([string]$ExplicitKey)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitKey)) {
        return $ExplicitKey
    }
    if (-not [string]::IsNullOrWhiteSpace($env:API_SPORTS_KEY)) {
        return $env:API_SPORTS_KEY
    }
    if (-not [string]::IsNullOrWhiteSpace($env:APISPORTS_KEY)) {
        return $env:APISPORTS_KEY
    }
    if (-not [string]::IsNullOrWhiteSpace($env:RAPIDAPI_KEY)) {
        return $env:RAPIDAPI_KEY
    }

    throw "Chybí API key. Nastav -ApiKey nebo env API_SPORTS_KEY / APISPORTS_KEY / RAPIDAPI_KEY."
}

function Invoke-BkRequest {
    param(
        [string]$Url,
        [string]$ApiKeyValue,
        [string]$HostValue,
        [int]$Timeout
    )

    $headers = @{
        "x-apisports-key" = $ApiKeyValue
    }

    if (-not [string]::IsNullOrWhiteSpace($HostValue)) {
        $headers["x-rapidapi-host"] = $HostValue
    }

    Write-Log "GET $Url"
    return Invoke-RestMethod -Method Get -Uri $Url -Headers $headers -TimeoutSec $Timeout
}

function Build-QueryString {
    param([hashtable]$Params)

    $pairs = @()
    foreach ($key in $Params.Keys) {
        $value = $Params[$key]
        if (-not [string]::IsNullOrWhiteSpace([string]$value)) {
            $encodedKey = [System.Uri]::EscapeDataString([string]$key)
            $encodedValue = [System.Uri]::EscapeDataString([string]$value)
            $pairs += "$encodedKey=$encodedValue"
        }
    }

    return ($pairs -join "&")
}

function Test-ResponseLooksValid {
    param([object]$Response)

    if ($null -eq $Response) {
        return $false
    }

    if ($Response.PSObject.Properties.Name -contains "errors") {
        $errors = $Response.errors

        if ($errors -is [string] -and -not [string]::IsNullOrWhiteSpace($errors)) {
            return $false
        }

        if ($errors -is [System.Collections.IDictionary] -and $errors.Count -gt 0) {
            return $false
        }
    }

    return $true
}

function Select-WorkingEndpoint {
    param(
        [string]$Base,
        [string]$ApiKeyValue,
        [string]$HostValue,
        [string]$Team,
        [string]$League,
        [string]$SeasonValue,
        [string]$SearchValue,
        [int]$Timeout
    )

    $candidateRequests = @()

    # 1) search má nejvyšší prioritu pro diagnostiku
    if (-not [string]::IsNullOrWhiteSpace($SearchValue)) {
        $qs = Build-QueryString @{
            search = $SearchValue
        }
        $candidateRequests += @{
            endpoint = "players"
            url      = "$Base/players?$qs"
        }
    }

    # 2) team + season
    if (-not [string]::IsNullOrWhiteSpace($Team)) {
        $qs = Build-QueryString @{
            team   = $Team
            season = $SeasonValue
        }
        $candidateRequests += @{
            endpoint = "players"
            url      = "$Base/players?$qs"
        }
    }

    # 3) league + season
    if (-not [string]::IsNullOrWhiteSpace($League)) {
        $qs = Build-QueryString @{
            league = $League
            season = $SeasonValue
        }
        $candidateRequests += @{
            endpoint = "players"
            url      = "$Base/players?$qs"
        }
    }

    # 4) fallback bez parametrů
    $candidateRequests += @{
        endpoint = "players"
        url      = "$Base/players"
    }

    $lastError = $null
    $lastUrl = ""
    $lastEndpoint = ""

    foreach ($candidate in $candidateRequests) {
        try {
            $lastUrl = $candidate.url
            $lastEndpoint = $candidate.endpoint

            $resp = Invoke-BkRequest -Url $candidate.url -ApiKeyValue $ApiKeyValue -HostValue $HostValue -Timeout $Timeout

            if (Test-ResponseLooksValid -Response $resp) {
                return @{
                    endpoint = $candidate.endpoint
                    url      = $candidate.url
                    response = $resp
                }
            }

            $lastError = "API vrátilo errors."
        }
        catch {
            $lastError = $_.Exception.Message
            Write-Log "Candidate failed: $lastEndpoint :: $lastError"
        }
    }

    throw "No working basketball players endpoint found. Last tried endpoint=$lastEndpoint url=$lastUrl error=$lastError"
}

$apiKeyValue = Resolve-ApiKey -ExplicitKey $ApiKey

Write-Host "=== MATCHMATRIX: BK PLAYERS RAW PULL ==="
Write-Host "provider=api_sport sport=BK entity=players"
Write-Host "team_id=$TeamId league_id=$LeagueId season=$Season search=$Search run_id=$RunId"

$result = Select-WorkingEndpoint `
    -Base $BaseUrl `
    -ApiKeyValue $apiKeyValue `
    -HostValue $HostHeader `
    -Team $TeamId `
    -League $LeagueId `
    -SeasonValue $Season `
    -SearchValue $Search `
    -Timeout $TimeoutSec

$response = $result.response
$json = $response | ConvertTo-Json -Depth 100

if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $dir = Split-Path -Parent $OutputPath
    if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.Encoding]::UTF8)
    Write-Log "Payload uložen do: $OutputPath"
}

$resultsCount = $null
if ($response.PSObject.Properties.Name -contains "results") {
    $resultsCount = $response.results
}

Write-Host "SUCCESS endpoint=$($result.endpoint)"
Write-Host "URL=$($result.url)"
Write-Host "RESULTS=$resultsCount"
exit 0