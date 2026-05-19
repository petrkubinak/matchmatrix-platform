DROP VIEW IF EXISTS public.v_live_match_feed_v2;

CREATE VIEW public.v_live_match_feed_v2 AS

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
    s.display_mode,

    l.id AS league_id,
    l.name AS league_name,
    l.logo_url AS league_logo,

    c.id AS country_id,
    c.name AS country_name,
    c.flag_url AS country_flag,

    -- =========================================
    -- HOME ENTITY
    -- =========================================

    ht.id AS home_entity_id,
    ht.name AS home_entity_name,

    CASE
        WHEN s.display_mode = 'team_vs_team'
            THEN ht.logo_url

        WHEN s.display_mode = 'player_vs_player'
            THEN COALESCE(
                hp.photo_url,
                '/assets/players/' || ht.id || '.png'
            )

        ELSE ht.logo_url
    END AS home_entity_image,

    -- =========================================
    -- AWAY ENTITY
    -- =========================================

    at.id AS away_entity_id,
    at.name AS away_entity_name,

    CASE
        WHEN s.display_mode = 'team_vs_team'
            THEN at.logo_url

        WHEN s.display_mode = 'player_vs_player'
            THEN COALESCE(
                ap.photo_url,
                '/assets/players/' || at.id || '.png'
            )

        ELSE at.logo_url
    END AS away_entity_image

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

LEFT JOIN public.players hp
    ON LOWER(hp.name) = LOWER(ht.name)

LEFT JOIN public.players ap
    ON LOWER(ap.name) = LOWER(at.name)

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