-- ============================================================================
-- MATCHMATRIX 19_5_AD
-- CREATE FB PLAYER SEASON STATS NORMALIZED VIEW
--
-- CO TO JE:
--   Normalizovaný pohled nad staging.stg_provider_player_season_stats.
--
-- K ČEMU TO JE:
--   Převádí EAV statistiky (stat_name/stat_value)
--   do sloupcového formátu vhodného pro web,
--   Player Rating Engine a Form Engine.
--
-- KDE TO UVIDÍME:
--   ops.v_fb_player_season_stats_normalized_v1
--
-- JAK SE TO VYUŽIJE:
--   Player profile
--   Player comparison
--   Team strength
--   Prediction engine
--   Form engine
-- ============================================================================

DROP VIEW IF EXISTS ops.v_fb_player_season_stats_normalized_v1;

CREATE VIEW ops.v_fb_player_season_stats_normalized_v1 AS

SELECT
    provider,
    season,
    external_league_id,
    player_external_id,
    team_external_id,

    MAX(CASE WHEN stat_name = 'appearances'
        THEN NULLIF(stat_value,'')::numeric END) AS appearances,

    MAX(CASE WHEN stat_name = 'minutes_played'
        THEN NULLIF(stat_value,'')::numeric END) AS minutes_played,

    MAX(CASE WHEN stat_name = 'rating'
        THEN NULLIF(stat_value,'')::numeric END) AS rating,

    MAX(CASE WHEN stat_name = 'goals'
        THEN NULLIF(stat_value,'')::numeric END) AS goals,

    MAX(CASE WHEN stat_name = 'assists'
        THEN NULLIF(stat_value,'')::numeric END) AS assists,

    MAX(CASE WHEN stat_name = 'shots_total'
        THEN NULLIF(stat_value,'')::numeric END) AS shots_total,

    MAX(CASE WHEN stat_name = 'shots_on_target'
        THEN NULLIF(stat_value,'')::numeric END) AS shots_on_target,

    MAX(CASE WHEN stat_name = 'passes_total'
        THEN NULLIF(stat_value,'')::numeric END) AS passes_total,

    MAX(CASE WHEN stat_name = 'passes_key'
        THEN NULLIF(stat_value,'')::numeric END) AS key_passes,

    MAX(CASE WHEN stat_name = 'passes_accuracy'
        THEN NULLIF(stat_value,'')::numeric END) AS pass_accuracy,

    MAX(CASE WHEN stat_name = 'duels_total'
        THEN NULLIF(stat_value,'')::numeric END) AS duels_total,

    MAX(CASE WHEN stat_name = 'duels_won'
        THEN NULLIF(stat_value,'')::numeric END) AS duels_won,

    MAX(CASE WHEN stat_name = 'dribbles_attempts'
        THEN NULLIF(stat_value,'')::numeric END) AS dribbles_attempts,

    MAX(CASE WHEN stat_name = 'dribbles_success'
        THEN NULLIF(stat_value,'')::numeric END) AS dribbles_success,

    MAX(CASE WHEN stat_name = 'tackles_total'
        THEN NULLIF(stat_value,'')::numeric END) AS tackles_total,

    MAX(CASE WHEN stat_name = 'tackles_interceptions'
        THEN NULLIF(stat_value,'')::numeric END) AS tackles_interceptions,

    MAX(CASE WHEN stat_name = 'tackles_blocks'
        THEN NULLIF(stat_value,'')::numeric END) AS tackles_blocks,

    MAX(CASE WHEN stat_name = 'yellow_cards'
        THEN NULLIF(stat_value,'')::numeric END) AS yellow_cards,

    MAX(CASE WHEN stat_name = 'red_cards'
        THEN NULLIF(stat_value,'')::numeric END) AS red_cards,

    MAX(CASE WHEN stat_name = 'saves'
        THEN NULLIF(stat_value,'')::numeric END) AS saves,

    MAX(CASE WHEN stat_name = 'penalty_scored'
        THEN NULLIF(stat_value,'')::numeric END) AS penalty_scored,

    MAX(CASE WHEN stat_name = 'penalty_missed'
        THEN NULLIF(stat_value,'')::numeric END) AS penalty_missed,

    MAX(CASE WHEN stat_name = 'penalty_saved'
        THEN NULLIF(stat_value,'')::numeric END) AS penalty_saved

FROM staging.stg_provider_player_season_stats
WHERE provider = 'api_football'

GROUP BY
    provider,
    season,
    external_league_id,
    player_external_id,
    team_external_id;