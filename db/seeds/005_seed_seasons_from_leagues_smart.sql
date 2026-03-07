-- =====================================================
-- MatchMatrix
-- Seed seasons from leagues - smart regional bootstrap
-- File: 005_seed_seasons_from_leagues_smart.sql
-- =====================================================

WITH target_years AS (
    SELECT 2023 AS season_year
    UNION ALL
    SELECT 2024 AS season_year
),
base AS (
    SELECT
        l.id AS league_id,
        l.name AS league_name,
        COALESCE(NULLIF(l.country, ''), 'Unknown') AS league_country,
        ty.season_year,

        CASE
            -- EUROPEAN AUTUMN -> SPRING MODEL
            WHEN l.country IN (
                'England','Scotland','Wales','Northern-Ireland','Ireland',
                'France','Germany','Italy','Spain','Portugal','Netherlands',
                'Belgium','Austria','Switzerland','Poland','Czech-Republic',
                'Slovakia','Hungary','Romania','Bulgaria','Croatia','Serbia',
                'Bosnia','Slovenia','Montenegro','North-Macedonia','Albania',
                'Greece','Cyprus','Denmark','Sweden','Norway','Finland',
                'Iceland','Ukraine','Belarus','Lithuania','Latvia','Estonia',
                'Luxembourg','Malta','Andorra','San-Marino','Liechtenstein',
                'Monaco','Moldova','Kosovo','Armenia','Georgia','Azerbaijan',
                'Turkey','Faroe-Islands','Russia'
            )
            OR l.country = 'Europe'
            THEN 'EU_AUTUMN_SPRING'

            -- SPRING -> AUTUMN / CALENDAR YEAR
            WHEN l.country IN (
                'Brazil','Argentina','Uruguay','Paraguay','Chile','Bolivia',
                'Peru','Ecuador','Colombia','Venezuela','South America',
                'World','USA','Canada','Mexico','Japan','South-Korea',
                'China','Australia','New-Zealand'
            )
            THEN 'CALENDAR_YEAR'

            -- DEFAULT BOOTSTRAP
            ELSE 'CALENDAR_YEAR'
        END AS season_model
    FROM public.leagues l
    CROSS JOIN target_years ty
)

INSERT INTO public.seasons
(
    league_id,
    season_code,
    season_label,
    start_date,
    end_date,
    is_current
)
SELECT
    b.league_id,

    CASE
        WHEN b.season_model = 'EU_AUTUMN_SPRING'
            THEN b.season_year::text
        ELSE
            b.season_year::text
    END AS season_code,

    CASE
        WHEN b.season_model = 'EU_AUTUMN_SPRING'
            THEN b.season_year::text || '/' || (b.season_year + 1)::text
        ELSE
            b.season_year::text
    END AS season_label,

    CASE
        WHEN b.season_model = 'EU_AUTUMN_SPRING'
            THEN make_date(b.season_year, 8, 1)
        ELSE
            make_date(b.season_year, 1, 1)
    END AS start_date,

    CASE
        WHEN b.season_model = 'EU_AUTUMN_SPRING'
            THEN make_date(b.season_year + 1, 5, 31)
        ELSE
            make_date(b.season_year, 12, 31)
    END AS end_date,

    CASE
        WHEN b.season_model = 'EU_AUTUMN_SPRING' AND b.season_year = 2024 THEN true
        WHEN b.season_model = 'CALENDAR_YEAR'     AND b.season_year = 2024 THEN true
        ELSE false
    END AS is_current
FROM base b
WHERE NOT EXISTS (
    SELECT 1
    FROM public.seasons s
    WHERE s.league_id = b.league_id
      AND s.season_code = b.season_year::text
);