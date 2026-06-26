/*
MATCHMATRIX SQL 17_9_D

FIX MISSING CANONICAL DUPLICATES V1

CO TO JE:
- Audit a návrh oprav týmů vytvořených přes
  api_football_missing_canonical.

K ČEMU TO JE:
- Najde dvojice:
    api_football
    api_football_missing_canonical

- Připraví bezpečný merge plán.

KDE TO UVIDÍME:
- OPS Panel
- Data Quality
- Team Duplicate Prevention

JAK SE TO VYUŽIJE:
- Ověříme mapování.
- Potom vytvoříme finální merge skript.
*/

CREATE OR REPLACE VIEW ops.v_missing_canonical_team_fix_plan_v1 AS

WITH canonical AS (

    SELECT
        id AS canonical_team_id,
        lower(trim(name)) AS normalized_name,
        sport_id,
        ext_team_id,
        name AS canonical_name
    FROM public.teams
    WHERE ext_source = 'api_football'

),

missing AS (

    SELECT
        id AS missing_team_id,
        lower(trim(name)) AS normalized_name,
        sport_id,
        ext_team_id,
        name AS missing_name
    FROM public.teams
    WHERE ext_source = 'api_football_missing_canonical'

)

SELECT

    c.canonical_team_id,
    m.missing_team_id,

    c.canonical_name,
    m.missing_name,

    c.sport_id,

    c.ext_team_id,

    'MERGE_TO_CANONICAL' AS proposed_action

FROM canonical c
JOIN missing m
    ON c.sport_id = m.sport_id
   AND c.ext_team_id = m.ext_team_id
   AND c.normalized_name = m.normalized_name

ORDER BY
    c.canonical_name;