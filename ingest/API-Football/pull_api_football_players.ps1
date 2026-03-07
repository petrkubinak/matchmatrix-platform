
param(
    [string]$Season = "2024"
)

$ErrorActionPreference = "Stop"

$API_KEY = $env:API_FOOTBALL_KEY
if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    $API_KEY = $env:APIFOOTBALL_KEY
}

if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    throw "Chybí API key. Nastav API_FOOTBALL_KEY nebo APIFOOTBALL_KEY."
}

$headers = @{
    "x-apisports-key" = $API_KEY
}

function Escape-SqlText {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value -or $Value -eq "") {
        return "NULL"
    }

    $escaped = $Value.Replace("'", "''")
    return "'$escaped'"
}

Write-Host "Načítám seznam lig z league_provider_map..."

$query = @"
SELECT league_id, provider_league_id
FROM public.league_provider_map
WHERE provider = 'api_football'
  AND provider_league_id IN ('39','140','78','135','61','88','94','40');
"@

$leagues = docker exec matchmatrix_postgres psql -U matchmatrix -d matchmatrix -t -A -F"," -c "$query"

if (-not $leagues) {
    Write-Host "Nebyla nalezena žádná liga v league_provider_map pro provider=api_football."
    exit
}

$leagueCount = 0

foreach ($row in $leagues) {

    if ([string]::IsNullOrWhiteSpace($row)) {
        continue
    }

    $cols = $row.Split(",")

    if ($cols.Count -lt 2) {
        continue
    }

    $league_id = $cols[0].Trim()
    $api_league = $cols[1].Trim()

    if ([string]::IsNullOrWhiteSpace($league_id) -or [string]::IsNullOrWhiteSpace($api_league)) {
        continue
    }

    $leagueCount++
    Write-Host "Processing league $league_id (API $api_league)"

    $page = 1

    while ($true) {

        $url = "https://v3.football.api-sports.io/players?league=$api_league&season=$Season&page=$page"
        Write-Host "URL: $url"

        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -ErrorAction Stop
        }
        catch {
            Write-Host "API error for league $api_league page $page"
            Write-Host $_.Exception.Message
            break
        }

        if ($null -eq $response -or $null -eq $response.response -or $response.response.Count -eq 0) {
            Write-Host "No data for league $api_league page $page"
            break
        }

        foreach ($item in $response.response) {

            $player = $item.player

            $sql = @"
INSERT INTO staging.players_import
(
    provider_code,
    provider_player_id,
    player_name,
    birth_date,
    nationality
)
VALUES
(
    'api_football',
    $(Escape-SqlText "$($player.id)"),
    $(Escape-SqlText "$($player.name)"),
    $(Escape-SqlText "$($player.birth.date)"),
    $(Escape-SqlText "$($player.nationality)")
);
"@

            try {
                docker exec matchmatrix_postgres psql -U matchmatrix -d matchmatrix -c "$sql" | Out-Null
            }
            catch {
                Write-Host "SQL insert error for player id $($player.id)"
                Write-Host $_.Exception.Message
            }
        }

        Write-Host "Page $page done"
        $page++

        Start-Sleep -Seconds 2
    }
}

Write-Host "Hotovo. Zpracovaných lig: $leagueCount"