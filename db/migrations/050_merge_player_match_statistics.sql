-- ============================================================================
-- 050_merge_player_match_statistics.sql
-- OPRAVENÁ VERZE
-- ============================================================================
-- Cíl:
--   Naplnit public.player_match_statistics ze staging.stg_provider_player_stats
--
-- Opravy:
--   1) public.matches používá ext_source místo provider
--   2) public.player_match_statistics vyžaduje team_id
--   3) cílové sloupce jsou minutes_played, shots_on_target apod.
-- ============================================================================

WITH base AS (
    SELECT
        s.provider,
        s.sport_code,
        s.external_fixture_id,
        s.player_external_id,
        s.team_external_id,
        s.stat_name,
        s.stat_value,

        ppm.player_id,
        m.id AS match_id,
        t.id AS team_id

    FROM staging.stg_provider_player_stats s

    JOIN public.player_provider_map ppm
      ON ppm.provider = s.provider
     AND ppm.provider_player_id = s.player_external_id

    JOIN public.matches m
      ON m.ext_source = s.provider
     AND m.ext_match_id = s.external_fixture_id

    JOIN public.teams t
      ON t.ext_source = s.provider
     AND t.ext_team_id = s.team_external_id

    WHERE s.stat_value IS NOT NULL
),

pivoted AS (
    SELECT
        player_id,
        match_id,
        team_id,

        MAX(CASE WHEN stat_name = 'minutes'            THEN NULLIF(stat_value, '')::int END)     AS minutes_played,
        MAX(CASE WHEN stat_name = 'goals'              THEN NULLIF(stat_value, '')::int END)     AS goals,
        MAX(CASE WHEN stat_name = 'assists'            THEN NULLIF(stat_value, '')::int END)     AS assists,
        MAX(CASE WHEN stat_name = 'shots_total'        THEN NULLIF(stat_value, '')::int END)     AS shots_total,
        MAX(CASE WHEN stat_name = 'shots_on'           THEN NULLIF(stat_value, '')::int END)     AS shots_on_target,
        MAX(CASE WHEN stat_name = 'passes_total'       THEN NULLIF(stat_value, '')::int END)     AS passes_total,
        MAX(CASE WHEN stat_name = 'passes_accurate'    THEN NULLIF(stat_value, '')::int END)     AS passes_accurate,
        MAX(CASE WHEN stat_name = 'passes_key'         THEN NULLIF(stat_value, '')::int END)     AS key_passes,
        MAX(CASE WHEN stat_name = 'dribbles_attempts'  THEN NULLIF(stat_value, '')::int END)     AS dribbles_attempted,
        MAX(CASE WHEN stat_name = 'dribbles_success'   THEN NULLIF(stat_value, '')::int END)     AS dribbles_successful,
        MAX(CASE WHEN stat_name = 'tackles_total'      THEN NULLIF(stat_value, '')::int END)     AS tackles,
        MAX(CASE WHEN stat_name = 'rating'             THEN NULLIF(stat_value, '')::numeric END) AS rating

    FROM base
    GROUP BY player_id, match_id, team_id
)

INSERT INTO public.player_match_statistics (
    match_id,
    team_id,
    player_id,
    minutes_played,
    goals,
    assists,
    shots_total,
    shots_on_target,
    passes_total,
    passes_accurate,
    key_passes,
    dribbles_attempted,
    dribbles_successful,
    tackles,
    rating,
    created_at,
    updated_at
)
SELECT
    p.match_id,
    p.team_id,
    p.player_id,
    p.minutes_played,
    COALESCE(p.goals, 0),
    COALESCE(p.assists, 0),
    COALESCE(p.shots_total, 0),
    COALESCE(p.shots_on_target, 0),
    COALESCE(p.passes_total, 0),
    COALESCE(p.passes_accurate, 0),
    COALESCE(p.key_passes, 0),
    COALESCE(p.dribbles_attempted, 0),
    COALESCE(p.dribbles_successful, 0),
    COALESCE(p.tackles, 0),
    p.rating,
    NOW(),
    NOW()
FROM pivoted p

ON CONFLICT (match_id, player_id)
DO UPDATE SET
    team_id              = EXCLUDED.team_id,
    minutes_played       = EXCLUDED.minutes_played,
    goals                = EXCLUDED.goals,
    assists              = EXCLUDED.assists,
    shots_total          = EXCLUDED.shots_total,
    shots_on_target      = EXCLUDED.shots_on_target,
    passes_total         = EXCLUDED.passes_total,
    passes_accurate      = EXCLUDED.passes_accurate,
    key_passes           = EXCLUDED.key_passes,
    dribbles_attempted   = EXCLUDED.dribbles_attempted,
    dribbles_successful  = EXCLUDED.dribbles_successful,
    tackles              = EXCLUDED.tackles,
    rating               = EXCLUDED.rating,
    updated_at           = NOW();