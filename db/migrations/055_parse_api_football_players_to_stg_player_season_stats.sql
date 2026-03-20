-- ============================================================================
-- 055_parse_api_football_players_to_stg_player_season_stats.sql
-- Cíl:
--   Rozparsovat staging.stg_api_payloads (endpoint players)
--   do staging.stg_provider_player_season_stats
--
-- Důležité:
--   Endpoint "players" z API-Football je season-level / league-level statistika,
--   nikoliv match-level statistika.
-- ============================================================================

INSERT INTO staging.stg_provider_player_season_stats (
    provider,
    sport_code,
    external_league_id,
    season,
    player_external_id,
    team_external_id,
    stat_name,
    stat_value,
    raw_payload_id,
    source_endpoint,
    created_at,
    updated_at
)
SELECT
    p.provider,
    p.sport_code,
    stat_block -> 'league' ->> 'id'              AS external_league_id,
    stat_block -> 'league' ->> 'season'          AS season,
    player_obj ->> 'id'                          AS player_external_id,
    stat_block -> 'team' ->> 'id'                AS team_external_id,
    v.stat_name,
    v.stat_value,
    p.id                                         AS raw_payload_id,
    p.endpoint_name                              AS source_endpoint,
    NOW(),
    NOW()
FROM staging.stg_api_payloads p
CROSS JOIN LATERAL jsonb_array_elements(p.payload_json -> 'response') AS resp(player_row)
CROSS JOIN LATERAL (SELECT resp.player_row -> 'player' AS player_obj) po
CROSS JOIN LATERAL jsonb_array_elements(resp.player_row -> 'statistics') AS stat(stat_block)
CROSS JOIN LATERAL (
    VALUES
        ('games_appearences',      stat.stat_block -> 'games'       ->> 'appearences'),
        ('games_lineups',          stat.stat_block -> 'games'       ->> 'lineups'),
        ('games_minutes',          stat.stat_block -> 'games'       ->> 'minutes'),
        ('games_position',         stat.stat_block -> 'games'       ->> 'position'),
        ('games_rating',           stat.stat_block -> 'games'       ->> 'rating'),
        ('games_captain',          stat.stat_block -> 'games'       ->> 'captain'),

        ('goals_total',            stat.stat_block -> 'goals'       ->> 'total'),
        ('goals_assists',          stat.stat_block -> 'goals'       ->> 'assists'),
        ('goals_conceded',         stat.stat_block -> 'goals'       ->> 'conceded'),
        ('goals_saves',            stat.stat_block -> 'goals'       ->> 'saves'),

        ('shots_total',            stat.stat_block -> 'shots'       ->> 'total'),
        ('shots_on',               stat.stat_block -> 'shots'       ->> 'on'),

        ('passes_total',           stat.stat_block -> 'passes'      ->> 'total'),
        ('passes_key',             stat.stat_block -> 'passes'      ->> 'key'),
        ('passes_accuracy',        stat.stat_block -> 'passes'      ->> 'accuracy'),

        ('tackles_total',          stat.stat_block -> 'tackles'     ->> 'total'),
        ('tackles_blocks',         stat.stat_block -> 'tackles'     ->> 'blocks'),
        ('tackles_interceptions',  stat.stat_block -> 'tackles'     ->> 'interceptions'),

        ('dribbles_attempts',      stat.stat_block -> 'dribbles'    ->> 'attempts'),
        ('dribbles_success',       stat.stat_block -> 'dribbles'    ->> 'success'),
        ('dribbles_past',          stat.stat_block -> 'dribbles'    ->> 'past'),

        ('duels_total',            stat.stat_block -> 'duels'       ->> 'total'),
        ('duels_won',              stat.stat_block -> 'duels'       ->> 'won'),

        ('fouls_drawn',            stat.stat_block -> 'fouls'       ->> 'drawn'),
        ('fouls_committed',        stat.stat_block -> 'fouls'       ->> 'committed'),

        ('cards_yellow',           stat.stat_block -> 'cards'       ->> 'yellow'),
        ('cards_yellowred',        stat.stat_block -> 'cards'       ->> 'yellowred'),
        ('cards_red',              stat.stat_block -> 'cards'       ->> 'red'),

        ('penalty_won',            stat.stat_block -> 'penalty'     ->> 'won'),
        ('penalty_commited',       stat.stat_block -> 'penalty'     ->> 'commited'),
        ('penalty_scored',         stat.stat_block -> 'penalty'     ->> 'scored'),
        ('penalty_missed',         stat.stat_block -> 'penalty'     ->> 'missed'),
        ('penalty_saved',          stat.stat_block -> 'penalty'     ->> 'saved'),

        ('substitutes_in',         stat.stat_block -> 'substitutes' ->> 'in'),
        ('substitutes_out',        stat.stat_block -> 'substitutes' ->> 'out'),
        ('substitutes_bench',      stat.stat_block -> 'substitutes' ->> 'bench')
) AS v(stat_name, stat_value)
WHERE p.provider = 'api_football'
  AND p.sport_code = 'football'
  AND p.entity_type = 'players'
  AND p.endpoint_name = 'players'
  AND COALESCE((p.payload_json ->> 'results')::int, 0) > 0
  AND jsonb_typeof(p.payload_json -> 'response') = 'array'
  AND jsonb_array_length(p.payload_json -> 'response') > 0
  AND player_obj ->> 'id' IS NOT NULL
  AND stat_block -> 'league' ->> 'id' IS NOT NULL
  AND v.stat_value IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM staging.stg_provider_player_season_stats x
      WHERE x.provider = p.provider
        AND x.sport_code = p.sport_code
        AND COALESCE(x.external_league_id, '') = COALESCE(stat_block -> 'league' ->> 'id', '')
        AND COALESCE(x.season, '') = COALESCE(stat_block -> 'league' ->> 'season', '')
        AND x.player_external_id = player_obj ->> 'id'
        AND COALESCE(x.team_external_id, '') = COALESCE(stat_block -> 'team' ->> 'id', '')
        AND x.stat_name = v.stat_name
        AND COALESCE(x.source_endpoint, '') = COALESCE(p.endpoint_name, '')
  );