-- ============================================================================
-- MATCHMATRIX
-- 26_3_14_READ ONLY KONTROLA KONFLIKTU API IDENTIT 743 A 737
-- ============================================================================
--
-- CO:
--   Read-only databazovy audit pred dalsim krokem pro posledni dve belgicke
--   historicke tymove identity:
--
--     historical 986 = Mouscron
--       live API-Football kandidat: 743 = Royal Excel Mouscron
--
--     historical 988 = Lokeren
--       live API-Football kandidat: 737 = Lokeren
--
--   Oddelene nastupnicke / nove identity z live API:
--     24556 = Stade Mouscronnois (founded 2022)
--     14128 = Lokeren-Temse      (founded 2020)
--
-- K CEMU:
--   1) overit, zda API provider IDs 743 a 737 uz nejsou namapovane jinam,
--   2) overit, zda pro ne neexistuji skryte public.teams radky,
--   3) zobrazit aktualni provider identity historickych tymu 986 a 988,
--   4) potvrdit, ze Lokeren-Temse 14128 zustava oddelena identita,
--   5) potvrdit zbyvajicich 121 belgickych legacy zapasu,
--   6) vypsat schema/unikatni omezeni potrebna pro bezpecny VALIDATE ONLY krok.
--
-- BEZPECNOST:
--   - REPEATABLE READ READ ONLY
--   - zadny INSERT / UPDATE / DELETE / DDL / COMMIT
--   - pouze SELECT
--   - zaverem ROLLBACK read-only transakce
--
-- DULEZITE:
--   Tento skript jeste NIC NEMAPUJE.
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;


-- ============================================================================
-- 1. TRANSAKCNI BEZPECNOST + STAV BELGICKEHO ZBYTKU
-- ============================================================================

WITH
known_team_map(fd_uk_team_id, canonical_team_id) AS (
    VALUES
        (972::bigint, 12940::bigint),
        (964, 13172),
        (980, 12515),
        (967, 12844),
        (975, 13032),
        (976, 12803),
        (966, 12665),
        (982, 13516),
        (977, 12254),
        (979, 12719),
        (981, 13043),
        (969, 12517),
        (985, 15765),
        (974, 12636),
        (983, 13328),
        (984, 12565),
        (971, 13537),
        (965, 13160),
        (978, 12277),
        (968, 12993),
        (973, 13279),
        (970, 12427),
        (987, 13137)
),
legacy AS (
    SELECT m.*
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
),
classified AS (
    SELECT
        m.id,
        hm.fd_uk_team_id AS mapped_home,
        am.fd_uk_team_id AS mapped_away
    FROM legacy m
    LEFT JOIN known_team_map hm ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN known_team_map am ON am.fd_uk_team_id = m.away_team_id
)
SELECT
    'KONTROLA'::text AS sekce,
    'TRANSACTION_READ_ONLY'::text AS kontrola,
    CASE WHEN current_setting('transaction_read_only') = 'on'
         THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    1::bigint AS ocekavano,
    CASE WHEN current_setting('transaction_read_only') = 'on'
         THEN 1::bigint ELSE 0::bigint END AS skutecnost,
    current_setting('transaction_isolation')::text AS detail

UNION ALL

SELECT
    'ROZSAH',
    'LEGACY_MATCHES_TOTAL',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    'Stav po APPLY 110.'::text
FROM legacy

UNION ALL

SELECT
    'ROZSAH',
    'PARTIALLY_MAPPABLE_BEFORE_LAST_TWO_IDENTITIES',
    CASE WHEN COUNT(*) = 119 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    119,
    COUNT(*)::bigint,
    'Presne jedna strana patri mezi 23 jiz potvrzenych mapovani.'::text
FROM classified
WHERE (mapped_home IS NULL) <> (mapped_away IS NULL)

UNION ALL

SELECT
    'ROZSAH',
    'BOTH_OPEN_BEFORE_LAST_TWO_IDENTITIES',
    CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    2,
    COUNT(*)::bigint,
    'Dva vzajemne zapasy Mouscron-Lokeren.'::text
FROM classified
WHERE mapped_home IS NULL
  AND mapped_away IS NULL;


-- ============================================================================
-- 2. PRESNE API-FOOTBALL PROVIDER IDENTITY 737 / 743 + NASTUPNICKE IDENTITY
-- ============================================================================

SELECT
    tpm.team_id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NAZEV NENALEZEN]'
    ) AS public_team_name,
    tpm.provider,
    tpm.provider_team_id,
    CASE tpm.provider_team_id
        WHEN '743' THEN 'KANDIDAT: Royal Excel Mouscron'
        WHEN '737' THEN 'KANDIDAT: historical Lokeren'
        WHEN '24556' THEN 'ODDELENA NOVEJSI IDENTITA: Stade Mouscronnois'
        WHEN '14128' THEN 'ODDELENA NASTUPNICKA IDENTITA: Lokeren-Temse'
        ELSE 'INFO'
    END AS identity_role,
    to_jsonb(tpm) AS provider_map_record
FROM public.team_provider_map tpm
LEFT JOIN public.teams t
  ON t.id = tpm.team_id
WHERE tpm.provider = 'api_football'
  AND tpm.provider_team_id IN ('743', '737', '24556', '14128')
ORDER BY tpm.provider_team_id, tpm.team_id;


-- ============================================================================
-- 3. PUBLIC.TEAMS RADKY S PRESNYM API EXTERNAL ID
-- ============================================================================

SELECT
    t.id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NAZEV NENALEZEN]'
    ) AS team_name,
    to_jsonb(t)->>'ext_source' AS ext_source,
    to_jsonb(t)->>'ext_team_id' AS ext_team_id,
    to_jsonb(t) AS team_record
FROM public.teams t
WHERE
       (to_jsonb(t)->>'ext_source' = 'api_football'
        AND to_jsonb(t)->>'ext_team_id' IN ('743', '737', '24556', '14128'))
    OR t.id IN (986, 988, 12819)
ORDER BY t.id;


-- ============================================================================
-- 4. AKTUALNI PROVIDER IDENTITY HISTORICKYCH TYMU 986 A 988
-- ============================================================================

SELECT
    t.id AS historical_team_id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NAZEV NENALEZEN]'
    ) AS historical_team_name,
    tpm.provider,
    tpm.provider_team_id,
    to_jsonb(tpm) AS provider_map_record
FROM public.teams t
LEFT JOIN public.team_provider_map tpm
  ON tpm.team_id = t.id
WHERE t.id IN (986, 988)
ORDER BY t.id, tpm.provider, tpm.provider_team_id;


-- ============================================================================
-- 5. KONFLIKTNI KONTROLA PRESNYCH KANDIDATU 743 A 737
-- ============================================================================
-- Idealni vysledek pred vytvorenim nove kanonicke identity:
--   candidate_provider_map_rows = 0
--   candidate_ext_source_rows   = 0
--
-- Pokud je nektera hodnota > 0, nic se nema vytvaret bez rucniho vyhodnoceni.
-- ============================================================================

WITH
provider_conflicts AS (
    SELECT *
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id IN ('743', '737')
),
team_conflicts AS (
    SELECT t.*
    FROM public.teams t
    WHERE to_jsonb(t)->>'ext_source' = 'api_football'
      AND to_jsonb(t)->>'ext_team_id' IN ('743', '737')
)
SELECT
    'IDENTITY_CONFLICT_CHECK'::text AS sekce,
    'API_PROVIDER_MAP_ROWS_737_743'::text AS kontrola,
    CASE WHEN COUNT(*) = 0 THEN 'OK_UNMAPPED' ELSE 'REVIEW_EXISTING_MAPPING' END AS stav,
    0::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    'Presne API provider IDs 737 a 743.'::text AS detail
FROM provider_conflicts

UNION ALL

SELECT
    'IDENTITY_CONFLICT_CHECK',
    'PUBLIC_TEAMS_EXT_ROWS_737_743',
    CASE WHEN COUNT(*) = 0 THEN 'OK_UNMAPPED' ELSE 'REVIEW_EXISTING_TEAM' END,
    0,
    COUNT(*)::bigint,
    'Public team radky primo vznikle z API IDs 737/743.'::text
FROM team_conflicts;


-- ============================================================================
-- 6. POTVRZENI, ZE LOKEREN-TEMSE JE ODDELENA DB IDENTITA
-- ============================================================================

SELECT
    t.id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NAZEV NENALEZEN]'
    ) AS team_name,
    to_jsonb(t)->>'ext_source' AS ext_source,
    to_jsonb(t)->>'ext_team_id' AS ext_team_id,
    tpm.provider,
    tpm.provider_team_id,
    CASE
        WHEN tpm.provider = 'api_football'
         AND tpm.provider_team_id = '14128'
        THEN 'SEPARATE_SUCCESSOR_IDENTITY_CONFIRMED'
        ELSE 'INFO'
    END AS status
FROM public.teams t
LEFT JOIN public.team_provider_map tpm
  ON tpm.team_id = t.id
WHERE t.id = 12819
   OR (tpm.provider = 'api_football' AND tpm.provider_team_id = '14128')
ORDER BY t.id, tpm.provider, tpm.provider_team_id;


-- ============================================================================
-- 7. SCHEMA PUBLIC.TEAMS A TEAM_PROVIDER_MAP PRO NAVRH VALIDATE ONLY
-- ============================================================================

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('teams', 'team_provider_map')
ORDER BY table_name, ordinal_position;


-- ============================================================================
-- 8. UNIQUE / PRIMARY / FOREIGN KEY CONSTRAINTS
-- ============================================================================

SELECT
    c.conrelid::regclass::text AS table_name,
    c.conname AS constraint_name,
    c.contype AS constraint_type,
    pg_get_constraintdef(c.oid) AS constraint_definition
FROM pg_constraint c
WHERE c.conrelid IN (
    'public.teams'::regclass,
    'public.team_provider_map'::regclass
)
ORDER BY c.conrelid::regclass::text, c.contype, c.conname;


-- ============================================================================
-- 9. GLOBALNI OCHRANNE POCTY
-- ============================================================================

SELECT
    'GLOBAL'::text AS sekce,
    'MATCH_COUNT_UNCHANGED'::text AS kontrola,
    CASE WHEN COUNT(*) = 120981 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    120981::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost
FROM public.matches

UNION ALL

SELECT
    'GLOBAL',
    'PROVIDER_MAP_COUNT_UNCHANGED',
    CASE WHEN COUNT(*) = 121908 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121908,
    COUNT(*)::bigint
FROM public.match_provider_map

UNION ALL

SELECT
    'GLOBAL',
    'GLOBAL_RATING_ORPHANS_UNCHANGED',
    CASE WHEN COUNT(*) = 78794 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    78794,
    COUNT(*)::bigint
FROM public.mm_match_ratings r
LEFT JOIN public.matches m
  ON m.id = r.match_id
WHERE m.id IS NULL;


-- ============================================================================
-- 10. ZAVER
-- ============================================================================

WITH
provider_conflicts AS (
    SELECT COUNT(*)::bigint AS n
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id IN ('743', '737')
),
team_conflicts AS (
    SELECT COUNT(*)::bigint AS n
    FROM public.teams t
    WHERE to_jsonb(t)->>'ext_source' = 'api_football'
      AND to_jsonb(t)->>'ext_team_id' IN ('743', '737')
)
SELECT
    'ZAVER'::text AS sekce,
    'API_737_743_DATABASE_CONFLICT_STATUS'::text AS kontrola,
    CASE
        WHEN (SELECT n FROM provider_conflicts) = 0
         AND (SELECT n FROM team_conflicts) = 0
        THEN 'NO_DATABASE_CONFLICT_FOR_API_737_743'
        ELSE 'EXISTING_DATABASE_IDENTITY_REVIEW_REQUIRED'
    END AS stav,
    (SELECT n FROM provider_conflicts) AS provider_map_rows,
    (SELECT n FROM team_conflicts) AS public_team_rows,
    'Dalsi krok az po vyhodnoceni: navrhnout VALIDATE ONLY kanonizaci poslednich dvou tymu a 121 zapasu.'::text AS detail;

ROLLBACK;