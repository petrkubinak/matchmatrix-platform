param(
  [int[]]$RunIds = @(23,28,24,33)
)

foreach ($rid in $RunIds) {
  Write-Host "=== FIX team_provider_map for run_id=$rid ==="

  docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -c "
WITH missing AS (
  SELECT DISTINCT f.home_team_id::text AS provider_team_id
  FROM staging.api_football_fixtures f
  LEFT JOIN public.team_provider_map tpm
    ON tpm.provider='api_football' AND tpm.provider_team_id=f.home_team_id::text
  WHERE f.run_id=$rid AND f.home_team_id IS NOT NULL AND f.home_team_id<>0 AND tpm.team_id IS NULL
  UNION
  SELECT DISTINCT f.away_team_id::text AS provider_team_id
  FROM staging.api_football_fixtures f
  LEFT JOIN public.team_provider_map tpm
    ON tpm.provider='api_football' AND tpm.provider_team_id=f.away_team_id::text
  WHERE f.run_id=$rid AND f.away_team_id IS NOT NULL AND f.away_team_id<>0 AND tpm.team_id IS NULL
),
ins_teams AS (
  INSERT INTO public.teams (name, ext_source, ext_team_id)
  SELECT 'Team ' || provider_team_id, 'api_football', provider_team_id
  FROM missing
  ON CONFLICT (ext_source, ext_team_id) DO NOTHING
  RETURNING id, ext_team_id
)
INSERT INTO public.team_provider_map (provider, provider_team_id, team_id)
SELECT 'api_football', t.ext_team_id, t.id
FROM public.teams t
JOIN missing m
  ON t.ext_source='api_football' AND t.ext_team_id=m.provider_team_id
ON CONFLICT (provider, provider_team_id) DO NOTHING;
"

  Write-Host "=== MERGE matches (034) for run_id=$rid ==="
  $sql34 = Get-Content "C:\MATCHMATRIX-PLATFORM\MatchMatrix-platform\Scripts\03_generation\030_upsert_api_football.sql\034_upsert_matches_api_football.sql" -Raw
  $sql34 | docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -v run_id=$rid

  docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -c "
SELECT $rid AS run_id,
       COUNT(DISTINCT f.fixture_id) FILTER (WHERE m.ext_match_id IS NULL) AS missing_now
FROM staging.api_football_fixtures f
LEFT JOIN public.matches m
  ON m.ext_source='api_football' AND m.ext_match_id=f.fixture_id::text
WHERE f.run_id=$rid;
"
}