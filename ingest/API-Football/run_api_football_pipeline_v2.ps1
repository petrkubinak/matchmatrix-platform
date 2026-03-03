
param(
    [int]$LeagueId,
    [int]$Season,
    [switch]$DoTeams,
    [switch]$DoFixtures,
    [string]$FixturesFrom,
    [string]$FixturesTo
)

$python = "python"

Write-Host "Running API-Football pipeline..."

if ($DoTeams) {
    & $python api_football_pull_v2.py $LeagueId $Season
}

if ($DoFixtures) {
    & $python api_football_pull_v2.py $LeagueId $Season $FixturesFrom $FixturesTo
}

Write-Host "Pipeline finished."
