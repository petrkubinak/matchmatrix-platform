/*
MATCHMATRIX
038_players_enrichment_reseed_squads_team_based.sql

Cíl:
- zrušit player-based queue pro api_football_squads
- vytvořit team-based queue pro /players/squads?team={id}
*/

-- 1) smažeme původní squads prep joby
DELETE FROM ops.player_enrichment_plan
WHERE provider = 'api_football_squads'
  AND sport_code = 'football';


-- 2) vložíme DISTINCT team-based squads joby
INSERT INTO ops.player_enrichment_plan (
    provider,
    sport_code,
    entity,
    player_id,
    source_provider,
    source_external_player_id,
    external_team_id,
    external_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run
)
SELECT DISTINCT
    'api_football_squads' AS provider,
    'football' AS sport_code,
    'team_squad' AS entity,
    NULL::bigint AS player_id,
    'api_football' AS source_provider,
    NULL::text AS source_external_player_id,
    spp.external_team_id,
    spp.external_league_id,
    spp.season,
    'PLAYERS_SQUADS_TEAM_BASED_V1' AS run_group,
    15 AS priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS next_run
FROM staging.stg_provider_players spp
WHERE spp.provider = 'api_football'
  AND spp.sport_code = 'football'
  AND spp.external_team_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM ops.player_enrichment_plan pep
      WHERE pep.provider = 'api_football_squads'
        AND pep.sport_code = 'football'
        AND pep.entity = 'team_squad'
        AND COALESCE(pep.external_team_id, '') = COALESCE(spp.external_team_id, '')
        AND COALESCE(pep.external_league_id, '') = COALESCE(spp.external_league_id, '')
        AND COALESCE(pep.season, '') = COALESCE(spp.season, '')
  );