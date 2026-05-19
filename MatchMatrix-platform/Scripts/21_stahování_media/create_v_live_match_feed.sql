-- =========================================================
-- MATCHMATRIX
-- LIVE MATCH FEED VIEW V1
-- =========================================================
--
-- Co view dělá:
-- ---------------------------------------------------------
-- Vrací live/frontend-ready feed pro:
-- - LIVE NOW
-- - homepage
-- - mobile app
-- - AI live feed
--
-- Výstup:
-- ---------------------------------------------------------
-- - score
-- - minute
-- - status
-- - logos
-- - flags
-- - sport icons
--
-- =========================================================

CREATE OR REPLACE VIEW public.v_live_match_feed AS

SELECT
    m.id AS match_id,

    m.kickoff,

    m.status,

    m.home_score,
    m.away_score,

    m.live_minute,

    s.id AS sport_id,
    s.name AS sport_name,
    s.icon_url AS sport_icon,

    l.id AS league_id,
    l.name AS league_name,
    l.logo_url AS league_logo,

    c.id AS country_id,
    c.name AS country_name,
    c.flag_url AS country_flag,

    ht.id AS home_team_id,
    ht.name AS home_team_name,
    ht.logo_url AS home_team_logo,

    at.id AS away_team_id,
    at.name AS away_team_name,
    at.logo_url AS away_team_logo

FROM public.matches m

LEFT JOIN public.sports s
    ON s.id = m.sport_id

LEFT JOIN public.leagues l
    ON l.id = m.league_id

LEFT JOIN public.countries c
    ON c.id = l.country_id

LEFT JOIN public.teams ht
    ON ht.id = m.home_team_id

LEFT JOIN public.teams at
    ON at.id = m.away_team_id

WHERE
    m.status IN
    (
        'LIVE',
        '1H',
        '2H',
        'HT',
        'ET',
        'PEN'
    )

ORDER BY
    m.live_minute DESC NULLS LAST,
    m.kickoff;