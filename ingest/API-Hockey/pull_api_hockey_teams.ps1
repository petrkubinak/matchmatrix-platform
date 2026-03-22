param(
  [Parameter(Mandatory=$true)][string]$RunId,
  [Parameter(Mandatory=$false)][int]$Season,
  [Parameter(Mandatory=$false)][int]$LeagueId
)

$ErrorActionPreference = "Stop"

# načti .env (stejně jako jinde)
$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) { throw ".env not found at $envFile" }

foreach ($line in Get-Content $envFile) {
  if ($line -match "^\s*([^#][^=]+?)\s*=\s*(.*)\s*$") {
    $name  = $matches[1].Trim()
    $value = $matches[2].Trim()
    [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
  }
}

$base = $env:APISPORTS_HOCKEY_BASE
if ([string]::IsNullOrWhiteSpace($base)) { $base = "https://v1.hockey.api-sports.io" }

$key = $env:APISPORTS_KEY
if ([string]::IsNullOrWhiteSpace($key)) { throw "APISPORTS_KEY missing" }

$headers = @{ "x-apisports-key" = $key }

# název kontejneru si případně uprav podle tvého dockeru
$pgContainer = "matchmatrix_postgres"

function Exec-Psql($sql) {
  $sql | docker exec -i $pgContainer psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -At
}

# ligy: buď jedna konkrétní, nebo všechny z mapy
if ($PSBoundParameters.ContainsKey('LeagueId')) {
  $leagues = @("$LeagueId")
} else {
  $leaguesText = Exec-Psql @"
select provider_league_id
from public.league_provider_map
where provider='api_hockey'
order by provider_league_id::int;
"@
  $leagues = $leaguesText -split "`n"
}

foreach ($league in $leagues) {
  $league = $league.Trim()
  if ($league -eq "") { continue }

  $url = "$base/teams?league=$league&season=$Season"
  Write-Host "Pulling HOCKEY TEAMS RAW... $url run_id=$RunId"

  $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method GET

  # JSON do jedné řádky + escapování apostrofů pro SQL
  $json = ($resp | ConvertTo-Json -Depth 80 -Compress).Replace("'", "''")

  $insertSql = @"
insert into staging.api_hockey_teams_raw(run_id, fetched_at, payload)
values ($RunId, now(), '$json'::jsonb);
"@

  Exec-Psql $insertSql | Out-Null
}

Write-Host "DONE"