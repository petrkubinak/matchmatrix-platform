/*
MATCHMATRIX SQL 117_T2
MEDIA TEAM KEYWORD CANDIDATES V2

CO TO JE:
- Přísnější kandidáti pro napojení článků na týmy podle titulku.

K ČEMU TO JE:
- Odstraní falešné shody typu:
  Thunder -> Thun
  breakout -> Brea
  interference -> Inter
  New York -> York

KDE TO UVIDÍME:
- ops.v_media_team_keyword_candidates_v1

JAK SE TO VYUŽIJE:
- Další krok 117_U bude bezpečně vkládat jen kandidáty s vysokou jistotou do public.article_team_map.
*/

CREATE OR REPLACE VIEW ops.v_media_team_keyword_candidates_v1 AS
WITH normalized AS (
    SELECT
        a.id AS article_id,
        a.title,
        LOWER(
            regexp_replace(
                regexp_replace(a.title, '[^[:alnum:]Á-ž]+', ' ', 'g'),
                '\s+',
                ' ',
                'g'
            )
        ) AS title_norm
    FROM public.articles a
),
team_norm AS (
    SELECT
        t.id AS team_id,
        t.name AS team_name,
        LOWER(
            regexp_replace(
                regexp_replace(t.name, '[^[:alnum:]Á-ž]+', ' ', 'g'),
                '\s+',
                ' ',
                'g'
            )
        ) AS team_norm
    FROM public.teams t
    WHERE LENGTH(t.name) >= 5
      AND t.name NOT IN (
          'Brea',
          'York',
          'Thun',
          'Inter',
          'Aves',
          'Gent',
          'Lens',
          'Bonn',
          'Oman',
          'Russia',
          'Derby',
          'Follo',
          'REAC',
          'Lancy'
      )
)
SELECT
    n.article_id,
    n.title,
    t.team_id,
    t.team_name,

    CASE
        WHEN n.title_norm = t.team_norm
            THEN 100

        WHEN n.title_norm LIKE '% ' || t.team_norm || ' %'
            THEN 95

        WHEN n.title_norm LIKE t.team_norm || ' %'
            THEN 94

        WHEN n.title_norm LIKE '% ' || t.team_norm
            THEN 94

        ELSE 0
    END AS match_score

FROM normalized n
JOIN team_norm t
    ON (
        n.title_norm = t.team_norm
        OR n.title_norm LIKE '% ' || t.team_norm || ' %'
        OR n.title_norm LIKE t.team_norm || ' %'
        OR n.title_norm LIKE '% ' || t.team_norm
    );