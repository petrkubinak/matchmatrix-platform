-- ============================================================================
-- MATCHMATRIX 19_5_AI
-- PLAYER FORM ENGINE V1
--
-- KAM ULOŽIT:
--   C:\MatchMatrix-platform\db\ops\
--
-- NÁZEV SOUBORU:
--   19_5_AI_create_player_form_engine_v1.sql
--
-- CO TO JE:
--   Výpočet aktuální formy hráče z posledních 5 zápasů.
--
-- K ČEMU TO JE:
--   Doplní sezónní rating o aktuální trend výkonu hráče.
--
-- KDE TO UVIDÍME:
--   ops.v_player_form_engine_v1
--
-- JAK SE TO VYUŽIJE:
--   Player Card, Player Detail, Team Strength, Prediction Engine, Ticket Engine.
-- ============================================================================

DROP VIEW IF EXISTS ops.v_player_form_engine_v1;

CREATE VIEW ops.v_player_form_engine_v1 AS
WITH ranked_matches AS (
    SELECT
        pms.player_id,
        pms.team_id,
        pms.match_id,
        m.kickoff,
        pms.minutes_played,
        pms.goals,
        pms.assists,
        pms.rating,
        pms.yellow_cards,
        pms.red_cards,
        ROW_NUMBER() OVER (
            PARTITION BY pms.player_id
            ORDER BY m.kickoff DESC NULLS LAST, pms.match_id DESC
        ) AS rn
    FROM public.player_match_statistics pms
    JOIN public.matches m
        ON m.id = pms.match_id
    WHERE m.kickoff IS NOT NULL
),
last5 AS (
    SELECT *
    FROM ranked_matches
    WHERE rn <= 5
)
SELECT
    player_id,
    MAX(team_id) AS team_id,
    COUNT(*) AS matches_count,
    SUM(COALESCE(minutes_played,0)) AS minutes_last5,
    SUM(COALESCE(goals,0)) AS goals_last5,
    SUM(COALESCE(assists,0)) AS assists_last5,
    ROUND(AVG(rating),2) AS avg_match_rating_last5,
    SUM(COALESCE(yellow_cards,0)) AS yellow_cards_last5,
    SUM(COALESCE(red_cards,0)) AS red_cards_last5,

    ROUND(
        LEAST(
            100,
            GREATEST(
                0,
                40
                + ((COALESCE(AVG(rating),6.0) - 6.0) * 15)
                + (LEAST(SUM(COALESCE(minutes_played,0)),450) / 450.0) * 20
                + (LEAST(SUM(COALESCE(goals,0)),5) / 5.0) * 20
                + (LEAST(SUM(COALESCE(assists,0)),5) / 5.0) * 12
                - (SUM(COALESCE(yellow_cards,0)) * 1.0)
                - (SUM(COALESCE(red_cards,0)) * 4.0)
            )
        )
    ,2) AS form_rating,

    CASE
        WHEN COUNT(*) < 3 THEN 'INSUFFICIENT_MATCH_DATA'
        WHEN ROUND(
            LEAST(
                100,
                GREATEST(
                    0,
                    40
                    + ((COALESCE(AVG(rating),6.0) - 6.0) * 15)
                    + (LEAST(SUM(COALESCE(minutes_played,0)),450) / 450.0) * 20
                    + (LEAST(SUM(COALESCE(goals,0)),5) / 5.0) * 20
                    + (LEAST(SUM(COALESCE(assists,0)),5) / 5.0) * 12
                    - (SUM(COALESCE(yellow_cards,0)) * 1.0)
                    - (SUM(COALESCE(red_cards,0)) * 4.0)
                )
            )
        ,2) >= 80 THEN 'HOT_FORM'
        WHEN ROUND(
            LEAST(
                100,
                GREATEST(
                    0,
                    40
                    + ((COALESCE(AVG(rating),6.0) - 6.0) * 15)
                    + (LEAST(SUM(COALESCE(minutes_played,0)),450) / 450.0) * 20
                    + (LEAST(SUM(COALESCE(goals,0)),5) / 5.0) * 20
                    + (LEAST(SUM(COALESCE(assists,0)),5) / 5.0) * 12
                    - (SUM(COALESCE(yellow_cards,0)) * 1.0)
                    - (SUM(COALESCE(red_cards,0)) * 4.0)
                )
            )
        ,2) >= 60 THEN 'GOOD_FORM'
        ELSE 'NORMAL_OR_LOW_FORM'
    END AS form_bucket

FROM last5
GROUP BY player_id;