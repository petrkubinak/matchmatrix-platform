/*
CO:
STEP 9N – CANONICAL SEASON MODEL PRECHECK

K ČEMU:
Zjistit, zda MatchMatrix již obsahuje canonical model sezony,
který má být použit v novém exact coverage scope registru.

CÍL:
Nevytvářet volný text "season", pokud již existuje
jednoznačná season identita nebo league-season vazba.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
Žádný INSERT / UPDATE / DELETE / DDL.
*/


/* =========================================================
   1. OBJEKTY SOUVISEJÍCÍ SE SEZONOU
   ========================================================= */

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN ('public', 'ops', 'runtime', 'staging')
  AND (
       table_name ILIKE '%season%'
       OR table_name ILIKE '%league%'
       OR table_name ILIKE '%competition%'
  )
ORDER BY
    table_schema,
    table_name;


/* =========================================================
   2. VŠECHNY SLOUPCE TYPU SEASON / SEASON_ID
   ========================================================= */

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema IN ('public', 'ops', 'runtime', 'staging')
  AND (
       column_name ILIKE '%season%'
       OR column_name IN (
           'year',
           'season_year'
       )
  )
ORDER BY
    table_schema,
    table_name,
    ordinal_position;


/* =========================================================
   3. TABULKY, KTERÉ MAJÍ SOUČASNĚ LEAGUE + SEASON
   ========================================================= */

WITH c AS (
    SELECT
        table_schema,
        table_name,

        bool_or(
            column_name IN (
                'league_id',
                'canonical_league_id',
                'competition_id'
            )
        ) AS has_league,

        bool_or(
            column_name ILIKE '%season%'
        ) AS has_season,

        array_agg(
            column_name
            ORDER BY ordinal_position
        ) AS columns

    FROM information_schema.columns

    WHERE table_schema IN (
        'public',
        'ops',
        'runtime',
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
FROM c
WHERE has_league = true
  AND has_season = true
ORDER BY
    table_schema,
    table_name;


/* =========================================================
   4. FK, UNIQUE A PK PRO PŘÍPADNÉ SEASON TABULKY
   ========================================================= */

SELECT
    n.nspname AS table_schema,
    cls.relname AS table_name,
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS definition

FROM pg_constraint con

JOIN pg_class cls
  ON cls.oid = con.conrelid

JOIN pg_namespace n
  ON n.oid = cls.relnamespace

WHERE n.nspname IN ('public', 'ops', 'runtime')
  AND (
       cls.relname ILIKE '%season%'
       OR cls.relname ILIKE '%league%'
       OR cls.relname ILIKE '%competition%'
  )

ORDER BY
    n.nspname,
    cls.relname,
    con.conname;


/* =========================================================
   5. AKTUÁLNÍ SEASON HODNOTY PRO HB LEAGUE 24881
   ========================================================= */

SELECT
    league_id,
    season,
    COUNT(*) AS matches,
    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff

FROM public.matches

WHERE league_id = 24881

GROUP BY
    league_id,
    season

ORDER BY
    first_kickoff;


/* =========================================================
   6. INGEST TARGET PRO PROVIDER LEAGUE 131

   Pouze jako provozní reference, nikoliv canonical truth.
   ========================================================= */

SELECT
    to_jsonb(x) AS ingest_target
FROM ops.ingest_targets x
WHERE to_jsonb(x)::text ILIKE '%api_handball%'
  AND to_jsonb(x)::text LIKE '%131%'
LIMIT 20;