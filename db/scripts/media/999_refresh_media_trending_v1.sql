-- ====================================================================
-- MATCHMATRIX MEDIA TRENDING ENGINE V1
-- ====================================================================

TRUNCATE TABLE public.media_trending_teams;

INSERT INTO public.media_trending_teams
(
    team_id,
    article_count,
    total_score,
    weighted_score,
    calculated_at
)
SELECT
    t.id AS team_id,

    COUNT(*) AS article_count,

    SUM(
        COALESCE(a.article_quality_score, 0)
    ) AS total_score,

    ROUND(
        SUM(
            (
                COALESCE(a.article_quality_score, 0)
            )
            *
            (
                CASE
                    WHEN a.is_video = true THEN 1.25
                    ELSE 1.00
                END
            )
        )::numeric,
        2
    ) AS weighted_score,

    NOW()

FROM public.article_team_map atm
JOIN public.teams t
    ON t.id = atm.team_id
JOIN public.articles a
    ON a.id = atm.article_id

WHERE
    a.article_quality_score >= 70

GROUP BY
    t.id;

-- ====================================================================
-- LEAGUES
-- ====================================================================

TRUNCATE TABLE public.media_trending_leagues;

INSERT INTO public.media_trending_leagues
(
    league_id,
    article_count,
    total_score,
    weighted_score,
    calculated_at
)
SELECT
    l.id AS league_id,

    COUNT(*) AS article_count,

    SUM(
        COALESCE(a.article_quality_score, 0)
    ) AS total_score,

    ROUND(
        SUM(
            (
                COALESCE(a.article_quality_score, 0)
            )
            *
            (
                CASE
                    WHEN a.is_video = true THEN 1.20
                    ELSE 1.00
                END
            )
        )::numeric,
        2
    ) AS weighted_score,

    NOW()

FROM public.article_league_map alm
JOIN public.leagues l
    ON l.id = alm.league_id
JOIN public.articles a
    ON a.id = alm.article_id

WHERE
    a.article_quality_score >= 70

GROUP BY
    l.id;