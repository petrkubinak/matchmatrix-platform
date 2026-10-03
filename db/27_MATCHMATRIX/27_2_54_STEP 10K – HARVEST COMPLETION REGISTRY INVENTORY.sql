/*
CO:
STEP 10K – HARVEST COMPLETION REGISTRY INVENTORY

K ČEMU:
Zjistit, zda MatchMatrix již obsahuje databázový objekt,
který eviduje skutečné dokončení harvestu konkrétního datového scope.

HLEDANÁ SÉMANTIKA:
sport
× layer
× entity
× provider/source
× competition
× season / období
× time_mode
× expected
× harvested
× parsed
× merged
× rejected
× completion status
× completed_at

DŮLEŽITÉ:
Harvest Completion je samostatná odpovědnost.

NE:
Source Coverage
NE:
Routing
NE:
Refresh Policy
NE:
Planner queue

JAK:
Pouze SELECT.
Žádný DDL / INSERT / UPDATE / DELETE.
*/


/* =========================================================
   1. KANDIDÁTNÍ TABULKY A VIEWS PODLE NÁZVU
   ========================================================= */

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN (
    'ops',
    'runtime',
    'public',
    'staging'
)
AND (
       table_name ILIKE '%harvest%'
    OR table_name ILIKE '%completion%'
    OR table_name ILIKE '%complete%'
    OR table_name ILIKE '%backfill%'
    OR table_name ILIKE '%checkpoint%'
    OR table_name ILIKE '%progress%'
    OR table_name ILIKE '%ingest%'
)
ORDER BY
    table_schema,
    table_name;


/* =========================================================
   2. OBJEKTY S COMPLETION-LIKE SLOUPCI
   ========================================================= */

WITH objects AS
(
    SELECT
        table_schema,
        table_name,

        array_agg(
            column_name
            ORDER BY ordinal_position
        ) AS columns

    FROM information_schema.columns

    WHERE table_schema IN (
        'ops',
        'runtime',
        'public',
        'staging'
    )

    GROUP BY
        table_schema,
        table_name
)

SELECT
    table_schema,
    table_name,
    columns

FROM objects

WHERE
       columns::text ILIKE '%expected%'
    OR columns::text ILIKE '%harvested%'
    OR columns::text ILIKE '%fetched%'
    OR columns::text ILIKE '%downloaded%'
    OR columns::text ILIKE '%parsed%'
    OR columns::text ILIKE '%merged%'
    OR columns::text ILIKE '%rejected%'
    OR columns::text ILIKE '%completed%'
    OR columns::text ILIKE '%completion%'
    OR columns::text ILIKE '%checkpoint%'
    OR columns::text ILIKE '%progress%'

ORDER BY
    table_schema,
    table_name;


/* =========================================================
   3. OBJEKTY, KTERÉ MAJÍ SOUČASNĚ
      SPORT + PROVIDER/SOURCE + LEAGUE/SEASON
   ========================================================= */

WITH flags AS
(
    SELECT
        table_schema,
        table_name,

        bool_or(
            column_name IN (
                'sport_code',
                'sport_id'
            )
        ) AS has_sport,

        bool_or(
            column_name IN (
                'provider',
                'source_id',
                'source_code'
            )
        ) AS has_source,

        bool_or(
            column_name IN (
                'league_id',
                'canonical_league_id',
                'provider_league_id',
                'competition_id'
            )
        ) AS has_competition,

        bool_or(
            column_name IN (
                'season',
                'season_id',
                'source_season_key'
            )
        ) AS has_season,

        bool_or(
            column_name IN (
                'entity',
                'entity_type'
            )
        ) AS has_entity,

        bool_or(
            column_name IN (
                'time_mode'
            )
        ) AS has_time_mode,

        array_agg(
            column_name
            ORDER BY ordinal_position
        ) AS columns

    FROM information_schema.columns

    WHERE table_schema IN (
        'ops',
        'runtime',
        'public',
        'staging'
    )

    GROUP BY
        table_schema,
        table_name
)

SELECT
    table_schema,
    table_name,
    has_sport,
    has_source,
    has_competition,
    has_season,
    has_entity,
    has_time_mode,
    columns

FROM flags

WHERE has_sport = true
  AND has_source = true
  AND (
       has_competition = true
       OR has_season = true
  )

ORDER BY
    table_schema,
    table_name;


/* =========================================================
   4. DETAIL SLOUPCŮ PRO HARVEST / COMPLETION KANDIDÁTY
   ========================================================= */

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default

FROM information_schema.columns

WHERE table_schema IN (
    'ops',
    'runtime'
)

AND (
       table_name ILIKE '%harvest%'
    OR table_name ILIKE '%completion%'
    OR table_name ILIKE '%complete%'
    OR table_name ILIKE '%backfill%'
    OR table_name ILIKE '%checkpoint%'
    OR table_name ILIKE '%progress%'
    OR table_name ILIKE '%ingest%'
)

ORDER BY
    table_schema,
    table_name,
    ordinal_position;


/* =========================================================
   5. CONSTRAINTS PRO STEJNÉ KANDIDÁTY
   ========================================================= */

SELECT
    n.nspname AS table_schema,
    c.relname AS table_name,
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(
        con.oid,
        true
    ) AS definition

FROM pg_constraint con

JOIN pg_class c
  ON c.oid = con.conrelid

JOIN pg_namespace n
  ON n.oid = c.relnamespace

WHERE n.nspname IN (
    'ops',
    'runtime'
)

AND (
       c.relname ILIKE '%harvest%'
    OR c.relname ILIKE '%completion%'
    OR c.relname ILIKE '%complete%'
    OR c.relname ILIKE '%backfill%'
    OR c.relname ILIKE '%checkpoint%'
    OR c.relname ILIKE '%progress%'
    OR c.relname ILIKE '%ingest%'
)

ORDER BY
    n.nspname,
    c.relname,
    con.conname;


/* =========================================================
   6. INDEXY PRO STEJNÉ KANDIDÁTY
   ========================================================= */

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef

FROM pg_indexes

WHERE schemaname IN (
    'ops',
    'runtime'
)

AND (
       tablename ILIKE '%harvest%'
    OR tablename ILIKE '%completion%'
    OR tablename ILIKE '%complete%'
    OR tablename ILIKE '%backfill%'
    OR tablename ILIKE '%checkpoint%'
    OR tablename ILIKE '%progress%'
    OR tablename ILIKE '%ingest%'
)

ORDER BY
    schemaname,
    tablename,
    indexname;


/* =========================================================
   7. KOMENTÁŘE OBJEKTŮ
   ========================================================= */

SELECT
    n.nspname AS table_schema,
    c.relname AS table_name,
    obj_description(
        c.oid,
        'pg_class'
    ) AS table_comment

FROM pg_class c

JOIN pg_namespace n
  ON n.oid = c.relnamespace

WHERE n.nspname IN (
    'ops',
    'runtime'
)

AND c.relkind IN (
    'r',
    'p',
    'v',
    'm'
)

AND (
       c.relname ILIKE '%harvest%'
    OR c.relname ILIKE '%completion%'
    OR c.relname ILIKE '%complete%'
    OR c.relname ILIKE '%backfill%'
    OR c.relname ILIKE '%checkpoint%'
    OR c.relname ILIKE '%progress%'
    OR c.relname ILIKE '%ingest%'
)

ORDER BY
    n.nspname,
    c.relname;