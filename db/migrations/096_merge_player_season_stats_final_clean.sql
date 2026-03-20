-- ============================================================================
-- 096_merge_player_season_stats_final_clean.sql
-- OPRAVENÁ VERZE
-- Cíl:
--   FINÁLNÍ stabilní merge bez duplicit
-- ============================================================================

WITH s_clean AS (
    SELECT DISTINCT
        provider,
        sport_code,
        external_league_id,
        team_external_id,
        player_external_id,
        season,
        stat_name,
        stat_value
    FROM staging.stg_provider_player_season_stats
    WHERE lower(sport_code) = 'football'
),

pivot AS (
    SELECT
        provider,
        external_league_id,
        team_external_id,
        player_external_id,
        season,

        MAX(CASE WHEN stat_name = 'games_appearences' THEN NULLIF(stat_value,'')::int END) AS appearances,
        MAX(CASE WHEN stat_name = 'games_lineups' THEN NULLIF(stat_value,'')::int END) AS lineups,
        MAX(CASE WHEN stat_name = 'games_minutes' THEN NULLIF(stat_value,'')::int END) AS minutes_played,
        MAX(CASE WHEN stat_name = 'games_rating' THEN NULLIF(stat_value,'')::numeric END) AS rating,

        MAX(CASE WHEN stat_name = 'goals_total' THEN NULLIF(stat_value,'')::int END) AS goals,
        MAX(CASE WHEN stat_name = 'goals_assists' THEN NULLIF(stat_value,'')::int END) AS assists,

        MAX(CASE WHEN stat_name = 'shots_total' THEN NULLIF(stat_value,'')::int END) AS shots_total,
        MAX(CASE WHEN stat_name = 'shots_on' THEN NULLIF(stat_value,'')::int END) AS shots_on_target,

        MAX(CASE WHEN stat_name = 'passes_total' THEN NULLIF(stat_value,'')::int END) AS passes_total,
        MAX(CASE WHEN stat_name = 'passes_key' THEN NULLIF(stat_value,'')::int END) AS passes_key,
        MAX(CASE WHEN stat_name = 'passes_accuracy' THEN NULLIF(stat_value,'')::numeric END) AS passes_accuracy,

        MAX(CASE WHEN stat_name = 'tackles_total' THEN NULLIF(stat_value,'')::int END) AS tackles_total,
        MAX(CASE WHEN stat_name = 'tackles_blocks' THEN NULLIF(stat_value,'')::int END) AS tackles_blocks,
        MAX(CASE WHEN stat_name = 'tackles_interceptions' THEN NULLIF(stat_value,'')::int END) AS tackles_interceptions,

        MAX(CASE WHEN stat_name = 'duels_total' THEN NULLIF(stat_value,'')::int END) AS duels_total,
        MAX(CASE WHEN stat_name = 'duels_won' THEN NULLIF(stat_value,'')::int END) AS duels_won,

        MAX(CASE WHEN stat_name = 'dribbles_attempts' THEN NULLIF(stat_value,'')::int END) AS dribbles_attempts,
        MAX(CASE WHEN stat_name = 'dribbles_success' THEN NULLIF(stat_value,'')::int END) AS dribbles_success,

        MAX(CASE WHEN stat_name = 'fouls_drawn' THEN NULLIF(stat_value,'')::int END) AS fouls_drawn,
        MAX(CASE WHEN stat_name = 'fouls_committed' THEN NULLIF(stat_value,'')::int END) AS fouls_committed,

        MAX(CASE WHEN stat_name = 'cards_yellow' THEN NULLIF(stat_value,'')::int END) AS yellow_cards,
        MAX(CASE WHEN stat_name = 'cards_red' THEN NULLIF(stat_value,'')::int END) AS red_cards,

        MAX(CASE WHEN stat_name = 'penalty_won' THEN NULLIF(stat_value,'')::int END) AS penalty_won,
        MAX(CASE WHEN stat_name = 'penalty_commited' THEN NULLIF(stat_value,'')::int END) AS penalty_committed,
        MAX(CASE WHEN stat_name = 'penalty_scored' THEN NULLIF(stat_value,'')::int END) AS penalty_scored,
        MAX(CASE WHEN stat_name = 'penalty_missed' THEN NULLIF(stat_value,'')::int END) AS penalty_missed,
        MAX(CASE WHEN stat_name = 'penalty_saved' THEN NULLIF(stat_value,'')::int END) AS penalty_saved

    FROM s_clean
    GROUP BY
        provider,
        external_league_id,
        team_external_id,
        player_external_id,
        season
),

src AS (
    SELECT
        ppm.player_id,
        tpm.team_id,
        1 AS sport_id,
        lpm.league_id,
        p.season,
        p.appearances,
        p.lineups,
        p.minutes_played,
        p.rating,
        p.goals,
        p.assists,
        p.shots_total,
        p.shots_on_target,
        p.passes_total,
        p.passes_key,
        p.passes_accuracy,
        p.tackles_total,
        p.tackles_blocks,
        p.tackles_interceptions,
        p.duels_total,
        p.duels_won,
        p.dribbles_attempts,
        p.dribbles_success,
        p.fouls_drawn,
        p.fouls_committed,
        p.yellow_cards,
        p.red_cards,
        p.penalty_won,
        p.penalty_committed,
        p.penalty_scored,
        p.penalty_missed,
        p.penalty_saved
    FROM pivot p
    JOIN public.player_provider_map ppm
      ON ppm.provider = p.provider
     AND ppm.provider_player_id = p.player_external_id
    JOIN public.team_provider_map tpm
      ON tpm.provider = p.provider
     AND tpm.provider_team_id = p.team_external_id
    JOIN public.league_provider_map lpm
      ON lpm.provider = p.provider
     AND lpm.provider_league_id = p.external_league_id
),

deleted AS (
    DELETE FROM public.player_season_statistics ps
    USING src
    WHERE ps.player_id = src.player_id
      AND ps.team_id = src.team_id
      AND ps.league_id = src.league_id
      AND ps.season = src.season
)

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
    NOW(),
    NOW()
FROM src;