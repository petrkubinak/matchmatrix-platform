-- MatchMatrix
-- 046_merge_player_season_statistics_live.sql
-- Merge ze staging.stg_provider_player_season_stats -> public.player_season_statistics
-- Přizpůsobeno aktuální live DB struktuře

INSERT INTO public.player_season_statistics (
    player_id,
    team_id,
    sport_id,
    league_id,
    season,
    appearances,
    lineups,
    minutes_played,
    rating,
    goals,
    assists,
    shots_total,
    shots_on_target,
    passes_total,
    passes_key,
    passes_accuracy,
    tackles_total,
    tackles_blocks,
    tackles_interceptions,
    duels_total,
    duels_won,
    dribbles_attempts,
    dribbles_success,
    fouls_drawn,
    fouls_committed,
    yellow_cards,
    red_cards,
    penalty_won,
    penalty_committed,
    penalty_scored,
    penalty_missed,
    penalty_saved,
    created_at,
    updated_at
)
SELECT
    ppm.player_id::integer                                     AS player_id,
    tpm.team_id                                                AS team_id,
    COALESCE(sp.id, 1)                                         AS sport_id,
    lpm.league_id                                              AS league_id,
    s.season                                                   AS season,

    COALESCE(MAX(CASE WHEN s.stat_name = 'appearances' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'lineups' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'minutes_played' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    MAX(CASE WHEN s.stat_name = 'rating' THEN NULLIF(REPLACE(s.stat_value, ',', '.'), '')::numeric END),

    COALESCE(MAX(CASE WHEN s.stat_name = 'goals' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'assists' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'shots_total' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name IN ('shots_on', 'shots_on_target') THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,

    COALESCE(MAX(CASE WHEN s.stat_name = 'passes_total' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'passes_key' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    MAX(CASE WHEN s.stat_name = 'passes_accuracy' THEN NULLIF(REPLACE(s.stat_value, ',', '.'), '')::numeric END),

    COALESCE(MAX(CASE WHEN s.stat_name = 'tackles_total' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name IN ('tackles_blocks', 'blocks') THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name IN ('tackles_interceptions', 'interceptions') THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,

    COALESCE(MAX(CASE WHEN s.stat_name = 'duels_total' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'duels_won' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,

    COALESCE(MAX(CASE WHEN s.stat_name = 'dribbles_attempts' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'dribbles_success' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,

    COALESCE(MAX(CASE WHEN s.stat_name = 'fouls_drawn' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'fouls_committed' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,

    COALESCE(MAX(CASE WHEN s.stat_name = 'yellow_cards' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'red_cards' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,

    COALESCE(MAX(CASE WHEN s.stat_name = 'penalty_won' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'penalty_committed' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'penalty_scored' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'penalty_missed' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,
    COALESCE(MAX(CASE WHEN s.stat_name = 'penalty_saved' THEN NULLIF(s.stat_value, '')::numeric END), 0)::integer,

    now(),
    now()
FROM staging.stg_provider_player_season_stats s
JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id
LEFT JOIN public.team_provider_map tpm
  ON tpm.provider = s.provider
 AND tpm.provider_team_id = s.team_external_id
LEFT JOIN public.league_provider_map lpm
  ON lpm.provider = s.provider
 AND lpm.provider_league_id = s.external_league_id
LEFT JOIN public.sports sp
  ON LOWER(sp.code) = LOWER(COALESCE(s.sport_code, 'football'))
WHERE ppm.player_id IS NOT NULL
GROUP BY
    ppm.player_id,
    tpm.team_id,
    COALESCE(sp.id, 1),
    lpm.league_id,
    s.season
ON CONFLICT (player_id, team_id, league_id, season)
DO UPDATE SET
    sport_id              = EXCLUDED.sport_id,
    appearances           = EXCLUDED.appearances,
    lineups               = EXCLUDED.lineups,
    minutes_played        = EXCLUDED.minutes_played,
    rating                = EXCLUDED.rating,
    goals                 = EXCLUDED.goals,
    assists               = EXCLUDED.assists,
    shots_total           = EXCLUDED.shots_total,
    shots_on_target       = EXCLUDED.shots_on_target,
    passes_total          = EXCLUDED.passes_total,
    passes_key            = EXCLUDED.passes_key,
    passes_accuracy       = EXCLUDED.passes_accuracy,
    tackles_total         = EXCLUDED.tackles_total,
    tackles_blocks        = EXCLUDED.tackles_blocks,
    tackles_interceptions = EXCLUDED.tackles_interceptions,
    duels_total           = EXCLUDED.duels_total,
    duels_won             = EXCLUDED.duels_won,
    dribbles_attempts     = EXCLUDED.dribbles_attempts,
    dribbles_success      = EXCLUDED.dribbles_success,
    fouls_drawn           = EXCLUDED.fouls_drawn,
    fouls_committed       = EXCLUDED.fouls_committed,
    yellow_cards          = EXCLUDED.yellow_cards,
    red_cards             = EXCLUDED.red_cards,
    penalty_won           = EXCLUDED.penalty_won,
    penalty_committed     = EXCLUDED.penalty_committed,
    penalty_scored        = EXCLUDED.penalty_scored,
    penalty_missed        = EXCLUDED.penalty_missed,
    penalty_saved         = EXCLUDED.penalty_saved,
    updated_at            = now();