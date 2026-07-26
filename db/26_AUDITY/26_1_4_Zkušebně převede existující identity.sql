/*
===============================================================================
MATCHMATRIX – MATCH PROVIDER MAP
VALIDATE ONLY – LEGACY IDENTITY BACKFILL V1
===============================================================================

CO:
- Zkušebně převede existující identity:
      public.matches.ext_source
      public.matches.ext_match_id
  do:
      public.match_provider_map

ROZSAH:
- Převádí pouze úplné a unikátní identity.
- Tři řádky manual_test bez ext_match_id vynechá.
- football_data_uk klasifikuje jako SOURCE / DERIVED.
- Ostatní současné identity klasifikuje jako PROVIDER / NATIVE.

BEZPEČNOST:
- Izolace REPEATABLE READ.
- Cílová tabulka musí být před spuštěním prázdná.
- Na konci je povinný ROLLBACK.
- public.matches se nemění.
- Žádné zápasy se neslučují ani nemažou.

REŽIM:
- VALIDATE ONLY
===============================================================================
*/

BEGIN ISOLATION LEVEL REPEATABLE READ;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '180s';
SET LOCAL client_min_messages = 'notice';

-------------------------------------------------------------------------------
-- 1. PROSTŘEDÍ
-------------------------------------------------------------------------------

SELECT
    current_database() AS database_name,
    current_user AS database_user,
    current_setting('transaction_isolation') AS transaction_isolation,
    current_setting('transaction_read_only') AS transaction_read_only,
    clock_timestamp() AS validation_started_at;

-------------------------------------------------------------------------------
-- 2. POVINNÉ PŘEDBĚŽNÉ KONTROLY
-------------------------------------------------------------------------------

DO $precheck$
DECLARE
    v_target_rows bigint;
    v_complete_rows bigint;
    v_incomplete_rows bigint;
    v_duplicate_groups bigint;
BEGIN
    IF to_regclass('public.matches') IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Tabulka public.matches neexistuje.';
    END IF;

    IF to_regclass('public.match_provider_map') IS NULL THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Tabulka public.match_provider_map neexistuje.';
    END IF;

    SELECT COUNT(*)
    INTO v_target_rows
    FROM public.match_provider_map;

    IF v_target_rows <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Cílová tabulka není prázdná. Obsahuje % řádků.',
            v_target_rows;
    END IF;

    SELECT
        COUNT(*) FILTER (
            WHERE ext_source IS NOT NULL
              AND btrim(ext_source::text) <> ''
              AND ext_match_id IS NOT NULL
              AND btrim(ext_match_id::text) <> ''
        ),
        COUNT(*) FILTER (
            WHERE ext_source IS NULL
               OR btrim(ext_source::text) = ''
               OR ext_match_id IS NULL
               OR btrim(ext_match_id::text) = ''
        )
    INTO
        v_complete_rows,
        v_incomplete_rows
    FROM public.matches;

    SELECT COUNT(*)
    INTO v_duplicate_groups
    FROM
    (
        SELECT
            btrim(ext_source::text),
            btrim(ext_match_id::text)
        FROM public.matches
        WHERE ext_source IS NOT NULL
          AND btrim(ext_source::text) <> ''
          AND ext_match_id IS NOT NULL
          AND btrim(ext_match_id::text) <> ''
        GROUP BY
            btrim(ext_source::text),
            btrim(ext_match_id::text)
        HAVING COUNT(*) > 1
    ) duplicate_identities;

    IF v_complete_rows = 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Nebyla nalezena žádná úplná identita.';
    END IF;

    IF v_duplicate_groups <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Zdroj obsahuje % duplicitních identit.',
            v_duplicate_groups;
    END IF;

    RAISE NOTICE
        'OK PRECHECK: úplné identity %, neúplné identity %, duplicity %, cílové řádky %.',
        v_complete_rows,
        v_incomplete_rows,
        v_duplicate_groups,
        v_target_rows;
END
$precheck$;

-------------------------------------------------------------------------------
-- 3. ZMRAZENÝ SEZNAM KANDIDÁTŮ
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_match_provider_backfill_candidates
ON COMMIT DROP
AS
SELECT
    m.id AS match_id,

    btrim(m.ext_source::text) AS provider,
    btrim(m.ext_match_id::text) AS provider_match_id,

    CASE
        WHEN btrim(m.ext_source::text) = 'football_data_uk'
            THEN 'SOURCE'
        ELSE 'PROVIDER'
    END::text AS identity_origin,

    CASE
        WHEN btrim(m.ext_source::text) = 'football_data_uk'
            THEN 'DERIVED'
        ELSE 'NATIVE'
    END::text AS external_id_kind

FROM public.matches m
WHERE m.ext_source IS NOT NULL
  AND btrim(m.ext_source::text) <> ''
  AND m.ext_match_id IS NOT NULL
  AND btrim(m.ext_match_id::text) <> '';

-------------------------------------------------------------------------------
-- 4. KONTROLA KANDIDÁTŮ
-------------------------------------------------------------------------------

DO $candidate_check$
DECLARE
    v_candidate_rows bigint;
    v_distinct_matches bigint;
    v_distinct_identities bigint;
    v_duplicate_identity_groups bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(DISTINCT match_id)
    INTO
        v_candidate_rows,
        v_distinct_matches
    FROM mm_match_provider_backfill_candidates;

    SELECT COUNT(*)
    INTO v_distinct_identities
    FROM
    (
        SELECT DISTINCT
            provider,
            provider_match_id
        FROM mm_match_provider_backfill_candidates
    ) identities;

    SELECT COUNT(*)
    INTO v_duplicate_identity_groups
    FROM
    (
        SELECT
            provider,
            provider_match_id
        FROM mm_match_provider_backfill_candidates
        GROUP BY
            provider,
            provider_match_id
        HAVING COUNT(*) > 1
    ) duplicates;

    IF v_candidate_rows <> v_distinct_matches THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Jeden zápas má v kandidátech více zdrojových identit.';
    END IF;

    IF v_candidate_rows <> v_distinct_identities THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Počet řádků neodpovídá počtu unikátních identit.';
    END IF;

    IF v_duplicate_identity_groups <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Kandidáti obsahují % duplicitních skupin.',
            v_duplicate_identity_groups;
    END IF;

    RAISE NOTICE
        'OK CANDIDATES: řádky %, zápasy %, unikátní identity %.',
        v_candidate_rows,
        v_distinct_matches,
        v_distinct_identities;
END
$candidate_check$;

-------------------------------------------------------------------------------
-- 5. ZKUŠEBNÍ BACKFILL
-------------------------------------------------------------------------------

INSERT INTO public.match_provider_map
(
    match_id,
    provider,
    provider_match_id,
    identity_origin,
    external_id_kind,
    mapping_status,
    is_primary,
    confidence_score,
    metadata
)
SELECT
    c.match_id,
    c.provider,
    c.provider_match_id,
    c.identity_origin,
    c.external_id_kind,
    'ACTIVE',
    true,
    100.00,

    jsonb_build_object(
        'migration',
        'MATCH_PROVIDER_MAP_BACKFILL_V1',
        'source_table',
        'public.matches',
        'source_columns',
        jsonb_build_array(
            'ext_source',
            'ext_match_id'
        ),
        'legacy_identity',
        true
    )

FROM mm_match_provider_backfill_candidates c
ORDER BY c.match_id;

-------------------------------------------------------------------------------
-- 6. ÚPLNÁ KONTROLA PO VLOŽENÍ
-------------------------------------------------------------------------------

DO $post_insert_validation$
DECLARE
    v_candidate_rows bigint;
    v_target_rows bigint;
    v_distinct_target_matches bigint;
    v_active_primary_rows bigint;
    v_missing_rows bigint;
    v_unexpected_rows bigint;
    v_duplicate_target_groups bigint;
    v_orphan_rows bigint;
BEGIN
    SELECT COUNT(*)
    INTO v_candidate_rows
    FROM mm_match_provider_backfill_candidates;

    SELECT
        COUNT(*),
        COUNT(DISTINCT match_id),
        COUNT(*) FILTER (
            WHERE is_primary = true
              AND mapping_status = 'ACTIVE'
        )
    INTO
        v_target_rows,
        v_distinct_target_matches,
        v_active_primary_rows
    FROM public.match_provider_map;

    SELECT COUNT(*)
    INTO v_missing_rows
    FROM mm_match_provider_backfill_candidates c
    LEFT JOIN public.match_provider_map t
      ON t.match_id = c.match_id
     AND t.provider = c.provider
     AND t.provider_match_id = c.provider_match_id
    WHERE t.id IS NULL;

    SELECT COUNT(*)
    INTO v_unexpected_rows
    FROM public.match_provider_map t
    LEFT JOIN mm_match_provider_backfill_candidates c
      ON c.match_id = t.match_id
     AND c.provider = t.provider
     AND c.provider_match_id = t.provider_match_id
    WHERE c.match_id IS NULL;

    SELECT COUNT(*)
    INTO v_duplicate_target_groups
    FROM
    (
        SELECT
            provider,
            provider_match_id
        FROM public.match_provider_map
        GROUP BY
            provider,
            provider_match_id
        HAVING COUNT(*) > 1
    ) duplicates;

    SELECT COUNT(*)
    INTO v_orphan_rows
    FROM public.match_provider_map t
    LEFT JOIN public.matches m
      ON m.id = t.match_id
    WHERE m.id IS NULL;

    IF v_target_rows <> v_candidate_rows THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Kandidáti %, vloženo %.',
            v_candidate_rows,
            v_target_rows;
    END IF;

    IF v_distinct_target_matches <> v_candidate_rows THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Počet namapovaných zápasů je % místo %.',
            v_distinct_target_matches,
            v_candidate_rows;
    END IF;

    IF v_active_primary_rows <> v_candidate_rows THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Aktivní primární identity % místo %.',
            v_active_primary_rows,
            v_candidate_rows;
    END IF;

    IF v_missing_rows <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Chybí % očekávaných mapování.',
            v_missing_rows;
    END IF;

    IF v_unexpected_rows <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: Nalezeno % neočekávaných mapování.',
            v_unexpected_rows;
    END IF;

    IF v_duplicate_target_groups <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: V cíli je % duplicitních skupin.',
            v_duplicate_target_groups;
    END IF;

    IF v_orphan_rows <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION_FAILED: V cíli je % osiřelých mapování.',
            v_orphan_rows;
    END IF;

    RAISE NOTICE
        'OK POST INSERT: kandidáti %, cílové řádky %, zápasy %, primární identity %, chybějící %, neočekávané %, duplicity %, orphan %.',
        v_candidate_rows,
        v_target_rows,
        v_distinct_target_matches,
        v_active_primary_rows,
        v_missing_rows,
        v_unexpected_rows,
        v_duplicate_target_groups,
        v_orphan_rows;
END
$post_insert_validation$;

-------------------------------------------------------------------------------
-- 7. SOUHRN PODLE PROVIDERŮ
-------------------------------------------------------------------------------

WITH source_counts AS
(
    SELECT
        provider,
        identity_origin,
        external_id_kind,
        COUNT(*) AS source_rows
    FROM mm_match_provider_backfill_candidates
    GROUP BY
        provider,
        identity_origin,
        external_id_kind
),
target_counts AS
(
    SELECT
        provider,
        identity_origin,
        external_id_kind,
        COUNT(*) AS target_rows
    FROM public.match_provider_map
    GROUP BY
        provider,
        identity_origin,
        external_id_kind
)
SELECT
    COALESCE(s.provider, t.provider) AS provider,
    COALESCE(
        s.identity_origin,
        t.identity_origin
    ) AS identity_origin,
    COALESCE(
        s.external_id_kind,
        t.external_id_kind
    ) AS external_id_kind,
    COALESCE(s.source_rows, 0) AS source_rows,
    COALESCE(t.target_rows, 0) AS target_rows,

    CASE
        WHEN COALESCE(s.source_rows, 0)
           = COALESCE(t.target_rows, 0)
            THEN 'OK'
        ELSE 'ROZDÍL'
    END AS comparison

FROM source_counts s
FULL OUTER JOIN target_counts t
  ON t.provider = s.provider
 AND t.identity_origin = s.identity_origin
 AND t.external_id_kind = s.external_id_kind

ORDER BY
    COALESCE(s.source_rows, t.target_rows) DESC,
    provider;

-------------------------------------------------------------------------------
-- 8. SOUHRNNÉ KONTROLY
-------------------------------------------------------------------------------

SELECT
    'CANDIDATE_ROWS' AS check_name,
    COUNT(*)::text AS result
FROM mm_match_provider_backfill_candidates

UNION ALL

SELECT
    'TARGET_ROWS',
    COUNT(*)::text
FROM public.match_provider_map

UNION ALL

SELECT
    'DISTINCT_MAPPED_MATCHES',
    COUNT(DISTINCT match_id)::text
FROM public.match_provider_map

UNION ALL

SELECT
    'ACTIVE_PRIMARY_IDENTITIES',
    COUNT(*)::text
FROM public.match_provider_map
WHERE is_primary = true
  AND mapping_status = 'ACTIVE'

UNION ALL

SELECT
    'FOOTBALL_DATA_UK_SOURCE_DERIVED',
    COUNT(*)::text
FROM public.match_provider_map
WHERE provider = 'football_data_uk'
  AND identity_origin = 'SOURCE'
  AND external_id_kind = 'DERIVED'

UNION ALL

SELECT
    'INCOMPLETE_SOURCE_ROWS_EXCLUDED',
    COUNT(*)::text
FROM public.matches
WHERE ext_source IS NULL
   OR btrim(ext_source::text) = ''
   OR ext_match_id IS NULL
   OR btrim(ext_match_id::text) = '';

-------------------------------------------------------------------------------
-- 9. VYLOUČENÉ ŘÁDKY
-------------------------------------------------------------------------------

SELECT
    id AS match_id,
    ext_source,
    ext_match_id
FROM public.matches
WHERE ext_source IS NULL
   OR btrim(ext_source::text) = ''
   OR ext_match_id IS NULL
   OR btrim(ext_match_id::text) = ''
ORDER BY id;

-------------------------------------------------------------------------------
-- 10. KONTROLNÍ VZOREK
-------------------------------------------------------------------------------

SELECT
    id,
    match_id,
    provider,
    provider_match_id,
    identity_origin,
    external_id_kind,
    mapping_status,
    is_primary,
    confidence_score,
    metadata
FROM public.match_provider_map
ORDER BY match_id
LIMIT 20;

-------------------------------------------------------------------------------
-- 11. STAV PŘED ROLLBACKEM
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM public.match_provider_map
        ) = (
            SELECT COUNT(*)
            FROM mm_match_provider_backfill_candidates
        )
        THEN
            'VALIDATE_ONLY_BACKFILL_OK – VŠECHNY KANDIDÁTNÍ IDENTITY OVĚŘENY'
        ELSE
            'VALIDATION_FAILED – POČTY SE NESHODUJÍ'
    END AS validation_status;

-------------------------------------------------------------------------------
-- 12. POVINNÝ ROLLBACK
-------------------------------------------------------------------------------

ROLLBACK;

-------------------------------------------------------------------------------
-- 13. KONEČNÁ KONTROLA PO ROLLBACKU
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN COUNT(*) = 0
        THEN
            'ROLLBACK_OK – MATCH_PROVIDER_MAP ZŮSTALA PRÁZDNÁ'
        ELSE
            'ROLLBACK_FAILED – V TABULCE ZŮSTALA DATA'
    END AS final_status,

    COUNT(*) AS remaining_rows
FROM public.match_provider_map;