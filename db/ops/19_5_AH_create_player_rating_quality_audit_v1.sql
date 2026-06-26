-- ============================================================================
-- MATCHMATRIX 19_5_AH
-- PLAYER RATING QUALITY AUDIT V1
--
-- KAM ULOŽIT:
--   C:\MatchMatrix-platform\db\ops\
--
-- NÁZEV SOUBORU:
--   19_5_AH_create_player_rating_quality_audit_v1.sql
--
-- CO TO JE:
--   Audit kvality dat hráče pro rating engine.
--
-- K ČEMU TO JE:
--   Oddělení hráčů s málo daty od skutečně slabých hráčů.
--
-- KDE TO UVIDÍME:
--   ops.v_player_rating_quality_audit_v1
--
-- JAK SE TO VYUŽIJE:
--   Player Ranking
--   Web Profil
--   Prediction Engine
-- ============================================================================

DROP VIEW IF EXISTS ops.v_player_rating_quality_audit_v1;

CREATE VIEW ops.v_player_rating_quality_audit_v1 AS

SELECT
    player_external_id,
    team_external_id,
    external_league_id,
    season,

    appearances,
    minutes_played,
    provider_rating,
    goals,
    assists,
    matchmatrix_rating,

    CASE

        WHEN appearances IS NULL
            OR appearances < 5
            OR minutes_played < 300
        THEN 'INSUFFICIENT_DATA'

        WHEN matchmatrix_rating >= 75
        THEN 'TOP_PLAYER'

        WHEN matchmatrix_rating >= 60
        THEN 'GOOD_PLAYER'

        WHEN matchmatrix_rating >= 40
        THEN 'REGULAR_PLAYER'

        ELSE 'LOW_RATED_PLAYER'

    END AS quality_bucket

FROM ops.v_matchmatrix_player_rating_v3;