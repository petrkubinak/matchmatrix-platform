-- ============================================================================
-- MATCHMATRIX 19_5_AF
-- CREATE MATCHMATRIX PLAYER RATING V2
--
-- KAM ULOŽIT:
--   C:\MatchMatrix-platform\db\ops\
--
-- NÁZEV SOUBORU:
--   19_5_AF_create_matchmatrix_player_rating_v2.sql
--
-- CO TO JE:
--   Druhá generace interního MatchMatrix Player Rating Engine.
--
-- K ČEMU TO JE:
--   Převádí sezónní statistiky hráčů na jednotný rating 0–100.
--
-- KDE TO UVIDÍME:
--   ops.v_matchmatrix_player_rating_v2
--
-- JAK SE TO VYUŽIJE:
--   Profil hráče, Player Ranking, Team Strength, Prediction Engine,
--   Ticket Engine a budoucí AI doporučení.
-- ============================================================================

DROP VIEW IF EXISTS ops.v_matchmatrix_player_rating_v2;

CREATE VIEW ops.v_matchmatrix_player_rating_v2 AS
SELECT
    player_external_id,
    team_external_id,
    external_league_id,
    season,
    appearances,
    minutes_played,
    rating AS provider_rating,
    goals,
    assists,

    ROUND(
        LEAST(
            100,
            (
                (COALESCE(rating, 0) / 10.0) * 35 +
                (LEAST(COALESCE(minutes_played,0),3000) / 3000.0) * 20 +
                (LEAST(COALESCE(goals,0),30) / 30.0) * 15 +
                (LEAST(COALESCE(assists,0),20) / 20.0) * 10 +
                (LEAST(COALESCE(appearances,0),38) / 38.0) * 10 +
                (LEAST(COALESCE(goals,0) + COALESCE(assists,0),40) / 40.0) * 10
            )
        )
    ,2) AS matchmatrix_rating
FROM ops.v_fb_player_season_stats_normalized_v1;