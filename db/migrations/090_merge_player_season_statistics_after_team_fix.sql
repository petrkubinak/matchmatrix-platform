-- ============================================================================
-- 090_merge_player_season_statistics_after_team_fix.sql
-- Cíl:
--   Finální merge season-level player stats po doplnění team_provider_map
-- ============================================================================

WITH src AS (
    SELECT
        ppm.player_id,
        tpm.team_id,
        sp.id AS sport_id,
        lpm.league_id,
        s.season,

        MAX(CASE WHEN s.stat_name = 'games_appearences'     THEN NULLIF(s.stat_value, '')::integer END) AS appearances,
        MAX(CASE WHEN s.stat_name = 'games_lineups'         THEN NULLIF(s.stat_value, '')::integer END) AS lineups,
        MAX(CASE WHEN s.stat_name = 'games_minutes'         THEN NULLIF(s.stat_value, '')::integer END) AS minutes_played,
        MAX(CASE WHEN s.stat_name = 'games_rating'          THEN NULLIF(s.stat_value, '')::numeric END) AS rating,

        MAX(CASE WHEN s.stat_name = 'goals_total'           THEN NULLIF(s.stat_value, '')::integer END) AS goals,
        MAX(CASE WHEN s.stat_name = 'goals_assists'         THEN NULLIF(s.stat_value, '')::integer END) AS assists,

        MAX(CASE WHEN s.stat_name = 'shots_total'           THEN NULLIF(s.stat_value, '')::integer END) AS shots_total,
        MAX(CASE WHEN s.stat_name = 'shots_on'              THEN NULLIF(s.stat_value, '')::integer END) AS shots_on_target,

        MAX(CASE WHEN s.stat_name = 'passes_total'          THEN NULLIF(s.stat_value, '')::integer END) AS passes_total,
        MAX(CASE WHEN s.stat_name = 'passes_key'            THEN NULLIF(s.stat_value, '')::integer END) AS passes_key,
        MAX(CASE WHEN s.stat_name = 'passes_accuracy'       THEN NULLIF(s.stat_value, '')::numeric END) AS passes_accuracy,

        MAX(CASE WHEN s.stat_name = 'tackles_total'         THEN NULLIF(s.stat_value, '')::integer END) AS tackles_total,
        MAX(CASE WHEN s.stat_name = 'tackles_blocks'        THEN NULLIF(s.stat_value, '')::integer END) AS tackles_blocks,
        MAX(CASE WHEN s.stat_name = 'tackles_interceptions' THEN NULLIF(s.stat_value, '')::integer END) AS tackles_interceptions,

        MAX(CASE WHEN s.stat_name = 'duels_total'           THEN NULLIF(s.stat_value, '')::integer END) AS duels_total,
        MAX(CASE WHEN s.stat_name = 'duels_won'             THEN NULLIF(s.stat_value, '')::integer END) AS duels_won,

        MAX(CASE WHEN s.stat_name = 'dribbles_attempts'     THEN NULLIF(s.stat_value, '')::integer END) AS dribbles_attempts,
        MAX(CASE WHEN s.stat_name = 'dribbles_success'      THEN NULLIF(s.stat_value, '')::integer END) AS dribbles_success,

        MAX(CASE WHEN s.stat_name = 'fouls_drawn'           THEN NULLIF(s.stat_value, '')::integer END) AS fouls_drawn,
        MAX(CASE WHEN s.stat_name = 'fouls_committed'       THEN NULLIF(s.stat_value, '')::integer END) AS fouls_committed,

        MAX(CASE WHEN s.stat_name = 'cards_yellow'          THEN NULLIF(s.stat_value, '')::integer END) AS yellow_cards,
        MAX(CASE WHEN s.stat_name = 'cards_red'             THEN NULLIF(s.stat_value, '')::integer END) AS red_cards,

        MAX(CASE WHEN s.stat_name = 'penalty_won'           THEN NULLIF(s.stat_value, '')::integer END) AS penalty_won,
        MAX(CASE WHEN s.stat_name = 'penalty_commited'      THEN NULLIF(s.stat_value, '')::integer END) AS penalty_committed,
        MAX(CASE WHEN s.stat_name = 'penalty_scored'        THEN NULLIF(s.stat_value, '')::integer END) AS penalty_scored,
        MAX(CASE WHEN s.stat_name = 'penalty_missed'        THEN NULLIF(s.stat_value, '')::integer END) AS penalty_missed,
        MAX(CASE WHEN s.stat_name = 'penalty_saved'         THEN NULLIF(s.stat_value, '')::integer END) AS penalty_saved

    FROM staging.stg_provider_player_season_stats s
    JOIN public.sports sp
      ON lower(sp.code) = lower(s.sport_code)
    JOIN public.player_provider_map ppm
      ON ppm.provider = s.provider
     AND ppm.provider_player_id = s.player_external_id
    JOIN public.team_provider_map tpm
      ON tpm.provider = s.provider
     AND tpm.provider_team_id = s.team_external_id
    JOIN public.league_provider_map lpm
      ON lpm.provider = s.provider
     AND lpm.provider_league_id = s.external_league_id
    GROUP BY
        ppm.player_id,
        tpm.team_id,
        sp.id,
        lpm.league_id,
        s.season
),

deleted AS (
    DELETE FROM public.player_season_statistics pss
    USING src
    WHERE pss.player_id = src.player_id
      AND pss.team_id   = src.team_id
      AND pss.sport_id  = src.sport_id
      AND pss.league_id = src.league_id
      AND pss.season    = src.season
    RETURNING pss.id
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