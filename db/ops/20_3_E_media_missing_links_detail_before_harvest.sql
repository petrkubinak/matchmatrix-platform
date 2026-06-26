/*
MATCHMATRIX SCRIPT
NÁZEV:
20_3_E_media_missing_links_detail_before_harvest.sql

CO TO JE:
Detailní audit článků bez navázaných entit.

K ČEMU TO JE:
Zjistit, které články nemají napojení na:
- týmy
- hráče
- zápasy

KDE TO UVIDÍME:
DBeaver

JAK SE TO VYUŽIJE:
Příprava Media Layer před velkým harvestem.
Určí, kde potřebujeme doplnit entity matching.
*/

WITH team_links AS (
    SELECT DISTINCT article_id
    FROM public.article_team_map
),

player_links AS (
    SELECT DISTINCT article_id
    FROM public.article_player_map
),

match_links AS (
    SELECT DISTINCT article_id
    FROM public.article_match_map
)

SELECT
    a.id,
    a.published_at,
    a.title,

    CASE
        WHEN tl.article_id IS NULL THEN 'N'
        ELSE 'Y'
    END AS has_team_link,

    CASE
        WHEN pl.article_id IS NULL THEN 'N'
        ELSE 'Y'
    END AS has_player_link,

    CASE
        WHEN ml.article_id IS NULL THEN 'N'
        ELSE 'Y'
    END AS has_match_link,

    a.entity_count,
    a.article_quality_score,
    a.is_video,
    a.url

FROM public.articles a

LEFT JOIN team_links tl
    ON tl.article_id = a.id

LEFT JOIN player_links pl
    ON pl.article_id = a.id

LEFT JOIN match_links ml
    ON ml.article_id = a.id

WHERE
      tl.article_id IS NULL
   OR pl.article_id IS NULL
   OR ml.article_id IS NULL

ORDER BY
    a.article_quality_score DESC NULLS LAST,
    a.published_at DESC;