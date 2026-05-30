-- =========================================================
-- MATCHMATRIX
-- PLAYER SEASON STATISTICS MERGE V1
-- =========================================================
--
-- Co skript dělá:
-- ---------------------------------------------------------
-- Přenáší player season statistics:
--
-- staging.stg_provider_player_season_stats
-- ->
-- public.player_season_statistics
--
-- Výstup:
-- ---------------------------------------------------------
-- - player profiles
-- - scouting
-- - AI ratings
-- - player comparisons
-- - predictions
-- - form engine
-- - fantasy layer
--
-- Web/App:
-- ---------------------------------------------------------
-- - player detail pages
-- - statistics tabs
-- - AI comparison engine
-- - trending players
--
-- =========================================================


INSERT INTO public.player_season_statistics
(
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
    ppm.player_id,

    MAX(tpm.team_id) AS team_id,

    sp.id AS sport_id,

    lpm.league_id,

    st.season,

    MAX(CASE WHEN st.stat_name = 'appearances' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'lineups' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'minutes_played' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'rating' THEN NULLIF(st.stat_value, '')::NUMERIC END),
    MAX(CASE WHEN st.stat_name = 'goals' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'assists' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'shots_total' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'shots_on_target' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'passes_total' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'passes_key' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'passes_accuracy' THEN NULLIF(st.stat_value, '')::NUMERIC END),
    MAX(CASE WHEN st.stat_name = 'tackles_total' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'tackles_blocks' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'tackles_interceptions' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'duels_total' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'duels_won' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'dribbles_attempts' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'dribbles_success' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'fouls_drawn' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'fouls_committed' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'yellow_cards' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'red_cards' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'penalty_won' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'penalty_committed' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'penalty_scored' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'penalty_missed' THEN NULLIF(st.stat_value, '')::INTEGER END),
    MAX(CASE WHEN st.stat_name = 'penalty_saved' THEN NULLIF(st.stat_value, '')::INTEGER END),

    NOW(),
    NOW()

FROM staging.stg_provider_player_season_stats st

INNER JOIN public.player_provider_map ppm
    ON ppm.provider = st.provider
    AND ppm.provider_player_id = st.player_external_id

LEFT JOIN public.team_provider_map tpm
    ON tpm.provider = st.provider
    AND tpm.provider_team_id = st.team_external_id

INNER JOIN public.league_provider_map lpm
    ON lpm.provider = st.provider
    AND lpm.provider_league_id = st.external_league_id

INNER JOIN public.sports sp
    ON LOWER(sp.code) = LOWER(st.sport_code)
    OR LOWER(sp.name) = LOWER(st.sport_code)

GROUP BY
    ppm.player_id,
    sp.id,
    lpm.league_id,
    st.season

ON CONFLICT (player_id, league_id, season)

DO UPDATE SET
    appearances = EXCLUDED.appearances,
    lineups = EXCLUDED.lineups,
    minutes_played = EXCLUDED.minutes_played,
    rating = EXCLUDED.rating,
    goals = EXCLUDED.goals,
    assists = EXCLUDED.assists,
    shots_total = EXCLUDED.shots_total,
    shots_on_target = EXCLUDED.shots_on_target,
    passes_total = EXCLUDED.passes_total,
    passes_key = EXCLUDED.passes_key,
    passes_accuracy = EXCLUDED.passes_accuracy,
    tackles_total = EXCLUDED.tackles_total,
    tackles_blocks = EXCLUDED.tackles_blocks,
    tackles_interceptions = EXCLUDED.tackles_interceptions,
    duels_total = EXCLUDED.duels_total,
    duels_won = EXCLUDED.duels_won,
    dribbles_attempts = EXCLUDED.dribbles_attempts,
    dribbles_success = EXCLUDED.dribbles_success,
    fouls_drawn = EXCLUDED.fouls_drawn,
    fouls_committed = EXCLUDED.fouls_committed,
    yellow_cards = EXCLUDED.yellow_cards,
    red_cards = EXCLUDED.red_cards,
    penalty_won = EXCLUDED.penalty_won,
    penalty_committed = EXCLUDED.penalty_committed,
    penalty_scored = EXCLUDED.penalty_scored,
    penalty_missed = EXCLUDED.penalty_missed,
    penalty_saved = EXCLUDED.penalty_saved,
    updated_at = NOW();