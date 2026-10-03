/*
CO:
STEP 9L – EXACT COVERAGE SCOPE INVENTORY

K ČEMU:
Zjistit, zda MatchMatrix již má databázový objekt schopný evidovat
jemný coverage scope podle soutěže, sezony, období nebo provider league ID.

CÍL:
Nevytvářet nový objekt, pokud již vhodný existuje.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. TABULKY / VIEWS S COVERAGE, SCOPE, LEAGUE, SEASON
   ========================================================= */

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN ('ops', 'public', 'staging', 'runtime')
  AND (
       table_name ILIKE '%coverage%'
       OR table_name ILIKE '%scope%'
       OR table_name ILIKE '%routing%'
       OR table_name ILIKE '%harvest%'
       OR table_name ILIKE '%target%'
  )
ORDER BY
    table_schema,
    table_name;


/* =========================================================
   2. OBJEKTY OBSAHUJÍCÍ SOURCE + LEAGUE/SEASON/SCOPE
   ========================================================= */

WITH object_columns AS (
    SELECT
        table_schema,
        table_name,
        array_agg(column_name ORDER BY ordinal_position) AS columns
    FROM information_schema.columns
    WHERE table_schema IN ('ops', 'public', 'staging', 'runtime')
    GROUP BY
        table_schema,
        table_name
)
SELECT
    table_schema,
    table_name,
    columns
FROM object_columns
WHERE
    columns::text ILIKE '%source%'
AND (
       columns::text ILIKE '%league%'
    OR columns::text ILIKE '%competition%'
    OR columns::text ILIKE '%season%'
    OR columns::text ILIKE '%scope%'
    OR columns::text ILIKE '%history_from%'
    OR columns::text ILIKE '%history_to%'
)
ORDER BY
    table_schema,
    table_name;


/* =========================================================
   3. DETAIL SLOUPCŮ PRO NEJDŮLEŽITĚJŠÍ KANDIDÁTY
   ========================================================= */

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema IN ('ops', 'public', 'runtime')
  AND (
       table_name ILIKE '%coverage%'
       OR table_name ILIKE '%routing%'
       OR table_name ILIKE '%scope%'
       OR table_name ILIKE '%harvest%'
       OR table_name ILIKE '%target%'
  )
ORDER BY
    table_schema,
    table_name,
    ordinal_position;


/* =========================================================
   4. EXISTUJÍCÍ OBJEKTY, KTERÉ MAJÍ SOUČASNĚ
      SPORT + ENTITY + LEAGUE/SEASON
   ========================================================= */

WITH object_flags AS (
    SELECT
        table_schema,
        table_name,

        bool_or(column_name = 'sport_code') AS has_sport,
        bool_or(column_name = 'entity') AS has_entity,

        bool_or(
            column_name IN (
                'league_id',
                'competition_id',
                'provider_league_id'
            )
        ) AS has_competition_scope,

        bool_or(
            column_name IN (
                'season',
                'season_id',
                'history_from',
                'history_to',
                'date_from',
                'date_to'
            )
        ) AS has_time_scope,

        array_agg(column_name ORDER BY ordinal_position) AS columns

    FROM information_schema.columns

    WHERE table_schema IN ('ops', 'public', 'runtime')

    GROUP BY
        table_schema,
        table_name
)

SELECT
    table_schema,
    table_name,
    has_sport,
    has_entity,
    has_competition_scope,
    has_time_scope,
    columns

FROM object_flags

WHERE has_sport = true
  AND (
       has_competition_scope = true
       OR has_time_scope = true
  )

ORDER BY
    table_schema,
    table_name;