/*
MATCHMATRIX SQL 120_F Media Title Opponent Resolver V1

CO TO JE:
- Resolver soupeřů z názvu článku.

K ČEMU TO JE:
- Doplní druhý tým tam, kde article_team_map našel jen jeden tým.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Připraví přesnější article -> match kandidáty bez přímého INSERTU.
*/

CREATE OR REPLACE VIEW ops.v_media_title_opponent_resolver_v1 AS
WITH title_team_hits AS (
    SELECT
        a.id AS article_id,
        a.title,
        a.published_at,
        a.content_source_id,
        a.url,
        t.id AS team_id,
        t.name AS team_name
    FROM public.articles a
    JOIN public.teams t
        ON a.title ILIKE '%' || t.name || '%'
),
cleaned AS (
    SELECT
        article_id,
        title,
        published_at,
        content_source_id,
        url,
        team_id,
        team_name
    FROM title_team_hits
    WHERE length(team_name) >= 4
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY article_id, team_id
            ORDER BY length(team_name) DESC
        ) AS rn
    FROM cleaned
)
SELECT
    article_id,
    title,
    published_at,
    content_source_id,
    url,
    team_id,
    team_name,
    now() AS resolved_at
FROM ranked
WHERE rn = 1;