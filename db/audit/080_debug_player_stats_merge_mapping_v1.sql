SET client_encoding = 'UTF8';

-- ============================================================
-- MatchMatrix
-- 080_debug_player_stats_merge_mapping_v1.sql
--
-- Ucel:
-- debug pivot + mapovani player/team pro player season stats
-- ============================================================

\pset pager off
\pset border 1
\pset linestyle ascii
\pset null '(null)'

\echo
\echo ============================================================
\echo MATCHMATRIX - DEBUG PLAYER STATS MERGE MAPPING
\echo ============================================================
\echo

WITH pivoted AS (
    SELECT
        s.provider,
        s.sport_code,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id,

        MAX(CASE WHEN s.stat_name = 'appearances' THEN s.stat_value END) AS appearances,
        MAX(CASE WHEN s.stat_name = 'lineups' THEN s.stat_value END) AS lineups,
        MAX(CASE WHEN s.stat_name = 'minutes_played' THEN s.stat_value END) AS minutes_played,
        MAX(CASE WHEN s.stat_name = 'rating' THEN s.stat_value END) AS rating,
        MAX(CASE WHEN s.stat_name = 'goals' THEN s.stat_value END) AS goals,
        MAX(CASE WHEN s.stat_name = 'assists' THEN s.stat_value END) AS assists,
        MAX(CASE WHEN s.stat_name = 'shots_total' THEN s.stat_value END) AS shots_total,
        MAX(CASE WHEN s.stat_name = 'shots_on_target' THEN s.stat_value END) AS shots_on_target,
        MAX(CASE WHEN s.stat_name = 'passes_total' THEN s.stat_value END) AS passes_total,
        MAX(CASE WHEN s.stat_name = 'passes_key' THEN s.stat_value END) AS passes_key,
        MAX(CASE WHEN s.stat_name = 'passes_accuracy' THEN s.stat_value END) AS passes_accuracy,
        MAX(CASE WHEN s.stat_name = 'tackles_total' THEN s.stat_value END) AS tackles_total,
        MAX(CASE WHEN s.stat_name = 'tackles_interceptions' THEN s.stat_value END) AS tackles_interceptions,
        MAX(CASE WHEN s.stat_name = 'tackles_blocks' THEN s.stat_value END) AS tackles_blocks,
        MAX(CASE WHEN s.stat_name = 'duels_total' THEN s.stat_value END) AS duels_total,
        MAX(CASE WHEN s.stat_name = 'duels_won' THEN s.stat_value END) AS duels_won,
        MAX(CASE WHEN s.stat_name = 'fouls_committed' THEN s.stat_value END) AS fouls_committed,
        MAX(CASE WHEN s.stat_name = 'fouls_drawn' THEN s.stat_value END) AS fouls_drawn,
        MAX(CASE WHEN s.stat_name = 'yellow_cards' THEN s.stat_value END) AS yellow_cards,
        MAX(CASE WHEN s.stat_name = 'red_cards' THEN s.stat_value END) AS red_cards
    FROM staging.stg_provider_player_season_stats s
    GROUP BY
        s.provider,
        s.sport_code,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id
),
pivoted_scored AS (
    SELECT
        p.*,
        CASE
            WHEN p.appearances IS NOT NULL
              OR p.lineups IS NOT NULL
              OR p.minutes_played IS NOT NULL
              OR p.rating IS NOT NULL
              OR p.goals IS NOT NULL
              OR p.assists IS NOT NULL
              OR p.shots_total IS NOT NULL
              OR p.passes_total IS NOT NULL
              OR p.tackles_total IS NOT NULL
            THEN 1
            ELSE 0
        END AS has_any_data
    FROM pivoted p
)
SELECT 'pivot_rows_total' AS metric, COUNT(*)::text AS value
FROM pivoted_scored
UNION ALL
SELECT 'pivot_rows_with_data', COUNT(*)::text
FROM pivoted_scored
WHERE has_any_data = 1
UNION ALL
SELECT 'distinct_players_in_pivot', COUNT(DISTINCT player_external_id)::text
FROM pivoted_scored
UNION ALL
SELECT 'distinct_teams_in_pivot', COUNT(DISTINCT team_external_id)::text
FROM pivoted_scored
UNION ALL
SELECT 'distinct_leagues_in_pivot', COUNT(DISTINCT external_league_id)::text
FROM pivoted_scored
;

\echo
\echo ------------------------------------------------------------
\echo 1) TOP PIVOT ROWS S DATY
\echo ------------------------------------------------------------
WITH pivoted AS (
    SELECT
        s.provider,
        s.sport_code,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id,

        MAX(CASE WHEN s.stat_name = 'appearances' THEN s.stat_value END) AS appearances,
        MAX(CASE WHEN s.stat_name = 'lineups' THEN s.stat_value END) AS lineups,
        MAX(CASE WHEN s.stat_name = 'minutes_played' THEN s.stat_value END) AS minutes_played,
        MAX(CASE WHEN s.stat_name = 'rating' THEN s.stat_value END) AS rating,
        MAX(CASE WHEN s.stat_name = 'goals' THEN s.stat_value END) AS goals,
        MAX(CASE WHEN s.stat_name = 'assists' THEN s.stat_value END) AS assists
    FROM staging.stg_provider_player_season_stats s
    GROUP BY
        s.provider,
        s.sport_code,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id
)
SELECT *
FROM pivoted
WHERE appearances IS NOT NULL
   OR lineups IS NOT NULL
   OR minutes_played IS NOT NULL
   OR rating IS NOT NULL
   OR goals IS NOT NULL
   OR assists IS NOT NULL
ORDER BY NULLIF(minutes_played, '')::numeric DESC NULLS LAST
LIMIT 50;

\echo
\echo ------------------------------------------------------------
\echo 2) MAPOVANI PLAYER_EXTERNAL_ID -> PLAYER_ID
\echo ------------------------------------------------------------
WITH pivoted AS (
    SELECT
        s.provider,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id
    FROM staging.stg_provider_player_season_stats s
    GROUP BY
        s.provider,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id
)
SELECT
    COUNT(*) AS pivot_rows,
    COUNT(pei.player_id) AS mapped_players
FROM pivoted p
LEFT JOIN public.player_external_identity pei
    ON pei.provider = p.provider
   AND pei.external_player_id::text = p.player_external_id::text
   AND COALESCE(pei.external_team_id::text, '') = COALESCE(p.team_external_id::text, '')
   AND COALESCE(pei.external_league_id::text, '') = COALESCE(p.external_league_id::text, '')
   AND COALESCE(pei.season::text, '') = COALESCE(p.season::text, '');

\echo
\echo ------------------------------------------------------------
\echo 3) MAPOVANI TEAM_EXTERNAL_ID -> TEAM_PROVIDER_MAP
\echo ------------------------------------------------------------
WITH pivoted AS (
    SELECT
        s.provider,
        s.player_external_id,
        s.team_external_id
    FROM staging.stg_provider_player_season_stats s
    GROUP BY
        s.provider,
        s.player_external_id,
        s.team_external_id
)
SELECT
    COUNT(*) AS pivot_rows,
    COUNT(tpm.id) AS mapped_team_rows
FROM pivoted p
LEFT JOIN public.team_provider_map tpm
    ON tpm.ext_source = p.provider
   AND tpm.ext_team_id::text = p.team_external_id::text;

\echo
\echo ------------------------------------------------------------
\echo 4) KONKRETNI RANKING PROBLEMATICKEHO DUPLIKATU
\echo ------------------------------------------------------------
WITH pivoted AS (
    SELECT
        s.provider,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id,
        MAX(CASE WHEN s.stat_name = 'appearances' THEN s.stat_value END) AS appearances,
        MAX(CASE WHEN s.stat_name = 'lineups' THEN s.stat_value END) AS lineups,
        MAX(CASE WHEN s.stat_name = 'minutes_played' THEN s.stat_value END) AS minutes_played,
        MAX(CASE WHEN s.stat_name = 'rating' THEN s.stat_value END) AS rating,
        MAX(CASE WHEN s.stat_name = 'goals' THEN s.stat_value END) AS goals,
        MAX(CASE WHEN s.stat_name = 'assists' THEN s.stat_value END) AS assists
    FROM staging.stg_provider_player_season_stats s
    GROUP BY
        s.provider,
        s.external_league_id,
        s.season,
        s.player_external_id,
        s.team_external_id
)
SELECT *
FROM pivoted
WHERE player_external_id::text IN ('96387','335043')
ORDER BY player_external_id, team_external_id;