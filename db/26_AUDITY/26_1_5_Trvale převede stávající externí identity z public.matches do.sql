/*
===============================================================================
MATCHMATRIX – MATCH PROVIDER MAP
APPLY – LEGACY IDENTITY BACKFILL V1
===============================================================================

CO:
- Trvale převede stávající externí identity z public.matches do
  public.match_provider_map.

ZDROJ:
- public.matches.ext_source
- public.matches.ext_match_id

CÍL:
- public.match_provider_map

ROZSAH:
- Očekává přesně 121 908 úplných a unikátních identit.
- Očekává přesně 3 neúplné řádky, které zůstanou vyloučené.
- football_data_uk bude uložen jako SOURCE / DERIVED.
- Ostatní identity budou uloženy jako PROVIDER / NATIVE.

BEZPEČNOST:
- Transakční provedení.
- Při jakémkoli rozdílu proběhne automatický rollback celé transakce.
- public.matches se nemění.
- Žádné zápasy se neslučují ani nemažou.
- Downstream vazby se nemění.

REŽIM:
- APPLY
===============================================================================
*/

BEGIN ISOLATION LEVEL REPEATABLE READ;

SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '300s';
SET LOCAL client_min_messages = 'notice';

-------------------------------------------------------------------------------
-- 1. IDENTIFIKACE PROSTŘEDÍ
-------------------------------------------------------------------------------

SELECT
    current_database() AS database_name,
    current_user AS database_user,
    current_setting('transaction_isolation') AS transaction_isolation,
    current_setting('transaction_read_only') AS transaction_read_only,
    clock_timestamp() AS apply_started_at;

-------------------------------------------------------------------------------
-- 2. EXISTENCE POVINNÝCH OBJEKTŮ
-------------------------------------------------------------------------------

DO $object_check$
BEGIN
    IF to_regclass('public.matches') IS NULL THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Tabulka public.matches neexistuje.';
    END IF;

    IF to_regclass('public.match_provider_map') IS NULL THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Tabulka public.match_provider_map neexistuje.';
    END IF;

    IF to_regprocedure(
        'public.fn_match_provider_map_touch()'
    ) IS NULL THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Auditní funkce public.fn_match_provider_map_touch neexistuje.';
    END IF;

    RAISE NOTICE
        'OK OBJECTS: Zdrojová i cílová struktura existují.';
END
$object_check$;

-------------------------------------------------------------------------------
-- 3. OCHRANA PROTI SOUBĚŽNÝM ZMĚNÁM
-------------------------------------------------------------------------------

LOCK TABLE public.matches
IN SHARE MODE;

LOCK TABLE public.match_provider_map
IN SHARE ROW EXCLUSIVE MODE;

-------------------------------------------------------------------------------
-- 4. PŘESNÝ PŘEDBĚŽNÝ AUDIT
-------------------------------------------------------------------------------

DO $precheck$
DECLARE
    v_total_matches bigint;
    v_complete_rows bigint;
    v_incomplete_rows bigint;
    v_duplicate_groups bigint;
    v_target_rows bigint;
BEGIN
    SELECT COUNT(*)
    INTO v_total_matches
    FROM public.matches;

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
            btrim(ext_source::text) AS provider,
            btrim(ext_match_id::text) AS provider_match_id
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

    SELECT COUNT(*)
    INTO v_target_rows
    FROM public.match_provider_map;

    IF v_total_matches <> 121911 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Očekáváno 121911 zápasů, nalezeno %.',
            v_total_matches;
    END IF;

    IF v_complete_rows <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Očekáváno 121908 úplných identit, nalezeno %.',
            v_complete_rows;
    END IF;

    IF v_incomplete_rows <> 3 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Očekávány 3 neúplné identity, nalezeno %.',
            v_incomplete_rows;
    END IF;

    IF v_duplicate_groups <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Nalezeno % duplicitních providerových identit.',
            v_duplicate_groups;
    END IF;

    IF v_target_rows <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Cílová tabulka již obsahuje % řádků.',
            v_target_rows;
    END IF;

    RAISE NOTICE
        'OK PRECHECK: zápasy %, úplné identity %, neúplné identity %, duplicity %, cílové řádky %.',
        v_total_matches,
        v_complete_rows,
        v_incomplete_rows,
        v_duplicate_groups,
        v_target_rows;
END
$precheck$;

-------------------------------------------------------------------------------
-- 5. ZMRAZENÍ KANDIDÁTŮ V RÁMCI TRANSAKCE
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
-- 6. KONTROLA ZMRAZENÝCH KANDIDÁTŮ
-------------------------------------------------------------------------------

DO $candidate_check$
DECLARE
    v_candidate_rows bigint;
    v_distinct_matches bigint;
    v_distinct_identities bigint;
    v_fd_uk_rows bigint;
    v_other_rows bigint;
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
    ) unique_identities;

    SELECT COUNT(*)
    INTO v_fd_uk_rows
    FROM mm_match_provider_backfill_candidates
    WHERE provider = 'football_data_uk'
      AND identity_origin = 'SOURCE'
      AND external_id_kind = 'DERIVED';

    SELECT COUNT(*)
    INTO v_other_rows
    FROM mm_match_provider_backfill_candidates
    WHERE provider <> 'football_data_uk'
      AND identity_origin = 'PROVIDER'
      AND external_id_kind = 'NATIVE';

    IF v_candidate_rows <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Kandidátů je % místo 121908.',
            v_candidate_rows;
    END IF;

    IF v_distinct_matches <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Unikátních zápasů je % místo 121908.',
            v_distinct_matches;
    END IF;

    IF v_distinct_identities <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Unikátních providerových identit je % místo 121908.',
            v_distinct_identities;
    END IF;

    IF v_fd_uk_rows <> 23118 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: football_data_uk má % řádků místo 23118.',
            v_fd_uk_rows;
    END IF;

    IF v_other_rows <> 98790 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Ostatních providerových identit je % místo 98790.',
            v_other_rows;
    END IF;

    RAISE NOTICE
        'OK CANDIDATES: kandidáti %, zápasy %, identity %, football_data_uk %, ostatní %.',
        v_candidate_rows,
        v_distinct_matches,
        v_distinct_identities,
        v_fd_uk_rows,
        v_other_rows;
END
$candidate_check$;

-------------------------------------------------------------------------------
-- 7. TRVALÝ BACKFILL
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
        'migration_date',
        '2026-07-24',
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
-- 8. ÚPLNÁ KONTROLA PO INSERTU
-------------------------------------------------------------------------------

DO $post_insert_validation$
DECLARE
    v_target_rows bigint;
    v_distinct_matches bigint;
    v_active_primary_rows bigint;
    v_missing_rows bigint;
    v_unexpected_rows bigint;
    v_duplicate_identity_groups bigint;
    v_duplicate_primary_groups bigint;
    v_orphan_rows bigint;
    v_fd_uk_rows bigint;
    v_metadata_rows bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(DISTINCT match_id),
        COUNT(*) FILTER (
            WHERE is_primary = true
              AND mapping_status = 'ACTIVE'
        )
    INTO
        v_target_rows,
        v_distinct_matches,
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
    INTO v_duplicate_identity_groups
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
    ) duplicate_identities;

    SELECT COUNT(*)
    INTO v_duplicate_primary_groups
    FROM
    (
        SELECT match_id
        FROM public.match_provider_map
        WHERE is_primary = true
          AND mapping_status = 'ACTIVE'
        GROUP BY match_id
        HAVING COUNT(*) > 1
    ) duplicate_primaries;

    SELECT COUNT(*)
    INTO v_orphan_rows
    FROM public.match_provider_map t
    LEFT JOIN public.matches m
      ON m.id = t.match_id
    WHERE m.id IS NULL;

    SELECT COUNT(*)
    INTO v_fd_uk_rows
    FROM public.match_provider_map
    WHERE provider = 'football_data_uk'
      AND identity_origin = 'SOURCE'
      AND external_id_kind = 'DERIVED';

    SELECT COUNT(*)
    INTO v_metadata_rows
    FROM public.match_provider_map
    WHERE metadata ->> 'migration'
              = 'MATCH_PROVIDER_MAP_BACKFILL_V1'
      AND metadata ->> 'migration_date'
              = '2026-07-24'
      AND metadata ->> 'source_table'
              = 'public.matches'
      AND metadata ->> 'legacy_identity'
              = 'true';

    IF v_target_rows <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Cíl obsahuje % řádků místo 121908.',
            v_target_rows;
    END IF;

    IF v_distinct_matches <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Namapováno % zápasů místo 121908.',
            v_distinct_matches;
    END IF;

    IF v_active_primary_rows <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Aktivních primárních identit je % místo 121908.',
            v_active_primary_rows;
    END IF;

    IF v_missing_rows <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Chybí % očekávaných mapování.',
            v_missing_rows;
    END IF;

    IF v_unexpected_rows <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Nalezeno % neočekávaných mapování.',
            v_unexpected_rows;
    END IF;

    IF v_duplicate_identity_groups <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Nalezeno % duplicitních providerových identit.',
            v_duplicate_identity_groups;
    END IF;

    IF v_duplicate_primary_groups <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Nalezeno % zápasů s více aktivními primárními identitami.',
            v_duplicate_primary_groups;
    END IF;

    IF v_orphan_rows <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Nalezeno % osiřelých mapování.',
            v_orphan_rows;
    END IF;

    IF v_fd_uk_rows <> 23118 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: football_data_uk obsahuje % řádků místo 23118.',
            v_fd_uk_rows;
    END IF;

    IF v_metadata_rows <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Správná migrační metadata má % řádků místo 121908.',
            v_metadata_rows;
    END IF;

    RAISE NOTICE
        'OK POST INSERT: cílové řádky %, zápasy %, primární identity %, chybějící %, neočekávané %, duplicity identit %, duplicity primárních %, orphan %, football_data_uk %, metadata %.',
        v_target_rows,
        v_distinct_matches,
        v_active_primary_rows,
        v_missing_rows,
        v_unexpected_rows,
        v_duplicate_identity_groups,
        v_duplicate_primary_groups,
        v_orphan_rows,
        v_fd_uk_rows,
        v_metadata_rows;
END
$post_insert_validation$;

-------------------------------------------------------------------------------
-- 9. POROVNÁNÍ PO PROVIDERECH PŘED COMMIT
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
-- 10. SOUHRN PŘED COMMIT
-------------------------------------------------------------------------------

SELECT
    'TARGET_ROWS' AS check_name,
    COUNT(*)::text AS result
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
    'EXCLUDED_INCOMPLETE_SOURCE_ROWS',
    COUNT(*)::text
FROM public.matches
WHERE ext_source IS NULL
   OR btrim(ext_source::text) = ''
   OR ext_match_id IS NULL
   OR btrim(ext_match_id::text) = '';

-------------------------------------------------------------------------------
-- 11. STAV PŘED COMMIT
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM public.match_provider_map
        ) = 121908
        THEN
            'APPLY_VALIDATED – PŘIPRAVENO K COMMIT'
        ELSE
            'APPLY_FAILED – NESPRÁVNÝ POČET ŘÁDKŮ'
    END AS pre_commit_status;

-------------------------------------------------------------------------------
-- 12. TRVALÉ ULOŽENÍ
-------------------------------------------------------------------------------

COMMIT;

-------------------------------------------------------------------------------
-- 13. AKTUALIZACE STATISTIK OPTIMALIZÁTORU
-------------------------------------------------------------------------------

ANALYZE public.match_provider_map;

-------------------------------------------------------------------------------
-- 14. KONEČNÝ POST-COMMIT AUDIT
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN COUNT(*) = 121908
         AND COUNT(DISTINCT match_id) = 121908
         AND COUNT(*) FILTER (
                WHERE is_primary = true
                  AND mapping_status = 'ACTIVE'
             ) = 121908
        THEN
            'APPLY_OK – 121908 IDENTIT TRVALE ULOŽENO'
        ELSE
            'APPLY_POST_COMMIT_WARNING – KONTROLNÍ POČTY SE NESHODUJÍ'
    END AS final_status,

    COUNT(*) AS target_rows,

    COUNT(DISTINCT match_id) AS distinct_mapped_matches,

    COUNT(*) FILTER (
        WHERE is_primary = true
          AND mapping_status = 'ACTIVE'
    ) AS active_primary_identities

FROM public.match_provider_map;

-------------------------------------------------------------------------------
-- 15. KONEČNÝ PŘEHLED PROVIDERŮ
-------------------------------------------------------------------------------

SELECT
    provider,
    identity_origin,
    external_id_kind,
    mapping_status,
    is_primary,
    COUNT(*) AS row_count
FROM public.match_provider_map
GROUP BY
    provider,
    identity_origin,
    external_id_kind,
    mapping_status,
    is_primary
ORDER BY
    row_count DESC,
    provider;

-------------------------------------------------------------------------------
-- 16. VYLOUČENÉ ŘÁDKY, KTERÉ ZŮSTALY BEZ MAPY
-------------------------------------------------------------------------------

SELECT
    m.id AS match_id,
    m.ext_source,
    m.ext_match_id
FROM public.matches m
LEFT JOIN public.match_provider_map p
  ON p.match_id = m.id
WHERE p.id IS NULL
ORDER BY m.id;