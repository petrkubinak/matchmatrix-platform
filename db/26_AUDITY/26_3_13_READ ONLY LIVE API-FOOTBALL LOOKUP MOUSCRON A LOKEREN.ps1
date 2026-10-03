# =============================================================================
# MATCHMATRIX
# 26_3_13_READ ONLY LIVE API-FOOTBALL LOOKUP MOUSCRON A LOKEREN.ps1
# =============================================================================
#
# CO:
#   Přímý read-only dotaz na API-Football pro poslední dvě nevyřešené
#   historické týmové identity:
#     - Royal Excel Mouscron / Mouscron
#     - Sporting Lokeren / KSC Lokeren
#
# K ČEMU:
#   Lokální staging ani public canonical vrstva neobsahují historické
#   API-Football zápasy 2018-2021. Tento skript proto ověří živé providerové
#   katalogy bez jakéhokoli zápisu do PostgreSQL.
#
# KDE:
#   Spustit na PC2 z PowerShellu.
#
# JAK:
#   Skript očekává API klíč v proměnné prostředí:
#     API_FOOTBALL_KEY
#   případně jako fallback:
#     APISPORTS_KEY
#
# BEZPEČNOST:
#   - nic nezapisuje do DB,
#   - nemění žádný projektový soubor,
#   - API klíč nikdy nevypisuje,
#   - provádí pouze HTTP GET.
# =============================================================================

$ErrorActionPreference = "Stop"

$ApiKey = $env:API_FOOTBALL_KEY
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = $env:APISPORTS_KEY
}

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw @"
API-Football klíč nebyl nalezen.
Očekávám proměnnou prostředí API_FOOTBALL_KEY nebo APISPORTS_KEY.
Klíč sem neposílej a nevypisuj ho do konzole.
"@
}

$BaseUrl = "https://v3.football.api-sports.io"
$Headers = @{
    "x-apisports-key" = $ApiKey
}

function Invoke-ApiFootballGet {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathAndQuery
    )

    $Uri = "$BaseUrl$PathAndQuery"
    $Result = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers -TimeoutSec 60

    [PSCustomObject]@{
        Uri        = $Uri
        Get        = $Result.get
        Parameters = $Result.parameters
        Errors     = $Result.errors
        Results    = $Result.results
        Paging     = $Result.paging
        Response   = $Result.response
    }
}

function Show-TeamSearch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Search
    )

    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "TEAM SEARCH: $Search" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Cyan

    $Encoded = [System.Uri]::EscapeDataString($Search)
    $R = Invoke-ApiFootballGet "/teams?search=$Encoded"

    if ($R.Errors -and $R.Errors.PSObject.Properties.Count -gt 0) {
        Write-Host "API ERRORS:" -ForegroundColor Yellow
        $R.Errors | ConvertTo-Json -Depth 8
    }

    Write-Host "RESULTS: $($R.Results)"

    if (-not $R.Response -or $R.Response.Count -eq 0) {
        Write-Host "ŽÁDNÉ VÝSLEDKY" -ForegroundColor Yellow
        return
    }

    $R.Response |
        ForEach-Object {
            [PSCustomObject]@{
                team_id     = $_.team.id
                name        = $_.team.name
                code        = $_.team.code
                country     = $_.team.country
                founded     = $_.team.founded
                national    = $_.team.national
                venue_id    = $_.venue.id
                venue_name  = $_.venue.name
                venue_city  = $_.venue.city
            }
        } |
        Format-Table -AutoSize
}

function Show-LeagueSeasonTeams {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Season
    )

    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Magenta
    Write-Host "JUPILER PRO LEAGUE 144 / SEASON $Season" -ForegroundColor Magenta
    Write-Host "===============================================================================" -ForegroundColor Magenta

    $R = Invoke-ApiFootballGet "/teams?league=144&season=$Season"

    if ($R.Errors -and $R.Errors.PSObject.Properties.Count -gt 0) {
        Write-Host "API ERRORS:" -ForegroundColor Yellow
        $R.Errors | ConvertTo-Json -Depth 8
    }

    Write-Host "RESULTS: $($R.Results)"

    if (-not $R.Response -or $R.Response.Count -eq 0) {
        Write-Host "ŽÁDNÉ VÝSLEDKY / HISTORICKÁ SEZONA NENÍ PRO ÚČET DOSTUPNÁ" -ForegroundColor Yellow
        return
    }

    $R.Response |
        ForEach-Object {
            [PSCustomObject]@{
                team_id    = $_.team.id
                name       = $_.team.name
                country    = $_.team.country
                founded    = $_.team.founded
                venue_name = $_.venue.name
            }
        } |
        Sort-Object name |
        Format-Table -AutoSize
}

Write-Host "MATCHMATRIX - LIVE API-FOOTBALL TEAM IDENTITY LOOKUP" -ForegroundColor Green
Write-Host "HTTP GET ONLY / DB WRITE DISABLED" -ForegroundColor Green

$Searches = @(
    "Royal Excel Mouscron",
    "Mouscron",
    "Mouscron Peruwelz",
    "Excel Mouscron",
    "Sporting Lokeren",
    "KSC Lokeren",
    "Lokeren Oost-Vlaanderen",
    "Lokeren"
)

foreach ($Search in $Searches) {
    Show-TeamSearch -Search $Search
}

foreach ($Season in @(2018, 2019, 2020)) {
    Show-LeagueSeasonTeams -Season $Season
}

Write-Host ""
Write-Host "===============================================================================" -ForegroundColor Green
Write-Host "LIVE API-FOOTBALL LOOKUP COMPLETE" -ForegroundColor Green
Write-Host "Nic nebylo zapsáno do databáze." -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Green