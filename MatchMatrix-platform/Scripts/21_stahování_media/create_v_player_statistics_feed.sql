-- =========================================================
-- MATCHMATRIX
-- PLAYER STATISTICS FEED
-- =========================================================
--
-- Co view dělá:
-- ---------------------------------------------------------
-- Vrací frontend-ready player statistics.
--
-- Použití:
-- ---------------------------------------------------------
-- - player detail pages
-- - AI scouting
-- - player comparison
-- - predictions
-- - trending players
-- - fantasy layer
--
-- =========================================================

DROP VIEW IF EXISTS public.v_player_statistics_feed;

CREATE VIEW public.v_player_statistics_feed AS

SELECT
    pss.player_id,

    p.name AS player_name,

    p.photo_url,

    p.position,

    p.nationality,

    p.team_id,

    t.name AS team_name,

    t.logo_url AS team_logo,

    pss.league_id,

    l.name AS league_name,

    l.logo_url AS league_logo,

    pss.season,

    pss.appearances,
    pss.lineups,
    pss.minutes_played,
    pss.rating,
    pss.goals,
    pss.assists,

    pss.shots_total,
    pss.shots_on_target,

    pss.passes_total,
    pss.passes_key,
    pss.passes_accuracy,

    pss.tackles_total,
    pss.tackles_blocks,
    pss.tackles_interceptions,

    pss.duels_total,
    pss.duels_won,

    pss.dribbles_attempts,
    pss.dribbles_success,

    pss.fouls_drawn,
    pss.fouls_committed,

    pss.yellow_cards,
    pss.red_cards,

    pss.penalty_won,
    pss.penalty_committed,
    pss.penalty_scored,
    pss.penalty_missed,
    pss.penalty_saved,

    CASE
        WHEN pss.duels_total > 0
        THEN ROUND(
            (pss.duels_won::NUMERIC / pss.duels_total) * 100,
            2
        )
    END AS duel_win_percent,

    CASE
        WHEN pss.shots_total > 0
        THEN ROUND(
            (pss.shots_on_target::NUMERIC / pss.shots_total) * 100,
            2
        )
    END AS shot_accuracy_percent,

    CASE
        WHEN pss.dribbles_attempts > 0
        THEN ROUND(
            (pss.dribbles_success::NUMERIC / pss.dribbles_attempts) * 100,
            2
        )
    END AS dribble_success_percent

FROM public.player_season_statistics pss

LEFT JOIN public.players p
    ON p.id = pss.player_id

LEFT JOIN public.teams t
    ON t.id = pss.team_id

LEFT JOIN public.leagues l
    ON l.id = pss.league_id;