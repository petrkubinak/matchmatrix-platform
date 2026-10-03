/*
CO:
STEP 9B – HB FIXTURES TEMPORAL EVIDENCE PRECHECK

K ČEMU:
Zjistit skutečný aktuální DB důkaz pro API-Sports / api_handball / HB / fixtures
před vytvořením prvních SOURCE_ENTITY_TIME_COVERAGE řádků.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
Bez INSERT / UPDATE / DELETE / DDL.
*/


-- =========================================================
-- 1. STRUKTURA PUBLIC.MATCHES
-- =========================================================

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'matches'
ORDER BY ordinal_position;


/* =========================================================
   2. STRUKTURA MATCH PROVIDER MAP
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'match_provider_map'
ORDER BY ordinal_position;


/* =========================================================
   3. UKÁZKOVÉ ŘÁDKY MATCH_PROVIDER_MAP

   to_jsonb používáme záměrně:
   uvidíme přesné názvy a obsah sloupců bez domněnek.
   ========================================================= */

SELECT
    to_jsonb(x) AS sample_row
FROM public.match_provider_map x
LIMIT 5;


/* =========================================================
   4. API_HANDBALL ŘÁDKY V PROVIDER MAP

   JSON přístup chrání diagnostiku proti neznámému názvu
   providerového sloupce.
   ========================================================= */

SELECT
    to_jsonb(x) AS api_handball_sample
FROM public.match_provider_map x
WHERE to_jsonb(x)::text ILIKE '%api_handball%'
LIMIT 10;


/* =========================================================
   5. UKÁZKOVÉ PUBLIC.MATCHES
   ========================================================= */

SELECT
    to_jsonb(m) AS sample_match
FROM public.matches m
LIMIT 5;


/* =========================================================
   6. STAGING FIXTURE TABULKY – INVENTORY
   ========================================================= */

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
  AND (
       table_name ILIKE '%fixture%'
       OR table_name ILIKE '%match%'
       OR table_name ILIKE '%payload%'
  )
ORDER BY table_name;


/* =========================================================
   7. API_HANDBALL SOUVISEJÍCÍ OPS / STAGING / PUBLIC OBJEKTY
   ========================================================= */

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN ('ops', 'staging', 'public')
  AND (
       table_name ILIKE '%handball%'
       OR table_name ILIKE '%provider%'
       OR table_name ILIKE '%fixture%'
  )
ORDER BY table_schema, table_name;