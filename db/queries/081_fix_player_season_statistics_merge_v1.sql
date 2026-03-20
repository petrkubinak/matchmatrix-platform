-- ============================================================
-- MatchMatrix
-- 081_fix_player_season_statistics_merge_v1.sql
--
-- Fix merge pro player season stats
-- ============================================================

WITH pivoted AS (
    SELECT
        s.provider,
        s.sport_code,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id,

        MAX(CASE WHEN stat_name = 'appearances' THEN stat_value END)::int AS appearances,
        MAX(CASE WHEN stat_name = 'lineups' THEN stat_value END)::int AS lineups,
        MAX(CASE WHEN stat_name = 'minutes_played' THEN stat_value END)::int AS minutes_played,
        MAX(CASE WHEN stat_name = 'rating' THEN stat_value END)::numeric AS rating,
        MAX(CASE WHEN stat_name = 'goals' THEN stat_value END)::int AS goals,
        MAX(CASE WHEN stat_name = 'assists' THEN stat_value END)::int AS assists,
        MAX(CASE WHEN stat_name = 'shots_total' THEN stat_value END)::int AS shots_total,
        MAX(CASE WHEN stat_name = 'shots_on_target' THEN stat_value END)::int AS shots_on_target,
        MAX(CASE WHEN stat_name = 'passes_total' THEN stat_value END)::int AS passes_total,
        MAX(CASE WHEN stat_name = 'passes_key' THEN stat_value END)::int AS passes_key,
        MAX(CASE WHEN stat_name = 'passes_accuracy' THEN stat_value END)::int AS passes_accuracy,
        MAX(CASE WHEN stat_name = 'tackles_total' THEN stat_value END)::int AS tackles_total,
        MAX(CASE WHEN stat_name = 'tackles_interceptions' THEN stat_value END)::int AS tackles_interceptions,
        MAX(CASE WHEN stat_name = 'tackles_blocks' THEN stat_value END)::int AS tackles_blocks,
        MAX(CASE WHEN stat_name = 'duels_total' THEN stat_value END)::int AS duels_total,
        MAX(CASE WHEN stat_name = 'duels_won' THEN stat_value END)::int AS duels_won,
        MAX(CASE WHEN stat_name = 'fouls_committed' THEN stat_value END)::int AS fouls_committed,
        MAX(CASE WHEN stat_name = 'fouls_drawn' THEN stat_value END)::int AS fouls_drawn,
        MAX(CASE WHEN stat_name = 'yellow_cards' THEN stat_value END)::int AS yellow_cards,
        MAX(CASE WHEN stat_name = 'red_cards' THEN stat_value END)::int AS red_cards

    FROM staging.stg_provider_player_season_stats s
    GROUP BY
        s.provider,
        s.sport_code,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id
),

filtered AS (
    SELECT *
    FROM pivoted
    WHERE
        appearances IS NOT NULL
        OR minutes_played IS NOT NULL
        OR goals IS NOT NULL
        OR assists IS NOT NULL
        OR rating IS NOT NULL
),

mapped AS (
    SELECT
        pei.player_id,
        tpm.team_id,
        f.*
    FROM filtered f

    LEFT JOIN public.player_external_identity pei
        ON pei.provider = f.provider
        AND pei.external_player_id::text = f.player_external_id::text
        AND pei.external_team_id::text = f.team_external_id::text
        AND pei.external_league_id::text = f.external_league_id::text
        AND pei.season::text = f.season::text

    LEFT JOIN public.team_provider_map tpm
        ON tpm.provider = f.provider
        AND tpm.provider_team_id::text = f.team_external_id::text
)

INSERT INTO public.player_season_statistics (
    player_id,
    team_id,
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
    tackles_interceptions,
    tackles_blocks,
    duels_total,
    duels_won,
    fouls_committed,
    fouls_drawn,
    yellow_cards,
    red_cards
)
SELECT
    player_id,
    team_id,
    season::int,
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
    tackles_interceptions,
    tackles_blocks,
    duels_total,
    duels_won,
    fouls_committed,
    fouls_drawn,
    yellow_cards,
    red_cards
FROM mapped
WHERE player_id IS NOT NULL
AND team_id IS NOT NULL
ON CONFLICT DO NOTHING;