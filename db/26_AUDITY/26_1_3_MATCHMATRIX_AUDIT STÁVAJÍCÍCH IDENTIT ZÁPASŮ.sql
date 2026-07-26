/*
===============================================================================
MATCHMATRIX – EXISTING MATCH IDENTITIES AUDIT
READ ONLY – PRE-BACKFILL VALIDATION V1
===============================================================================

CO:
- Audituje ext_source a ext_match_id v public.matches.
- Ověří připravenost pro backfill do public.match_provider_map.
- Odhalí duplicity, prázdné hodnoty a nejednotné providerové kódy.

K ČEMU:
- Unikátní index public.match_provider_map(provider, provider_match_id)
  nesmí být během backfillu porušen.
- Neplatné nebo nejednoznačné identity se nesmí vložit automaticky.

BEZPEČNOST:
- READ ONLY
- Žádné INSERT, UPDATE, DELETE ani DDL.
===============================================================================
*/

BEGIN TRANSACTION READ ONLY;

SET LOCAL statement_timeout = '120s';
SET LOCAL lock_timeout = '5s';
SET LOCAL client_min_messages = 'notice';

-------------------------------------------------------------------------------
-- 1. PROSTŘEDÍ A STAV CÍLOVÉ TABULKY
-------------------------------------------------------------------------------

SELECT
    current_database() AS database_name,
    current_user AS database_user,
    current_setting('transaction_isolation') AS transaction_isolation,
    current_setting('transaction_read_only') AS transaction_read_only,
    clock_timestamp() AS audit_started_at;

SELECT
    CASE
        WHEN to_regclass('public.matches') IS NOT NULL
            THEN 'OK'
        ELSE 'CHYBÍ'
    END AS public_matches,

    CASE
        WHEN to_regclass('public.match_provider_map') IS NOT NULL
            THEN 'OK'
        ELSE 'CHYBÍ'
    END AS public_match_provider_map;

SELECT
    COUNT(*) AS current_match_provider_map_rows
FROM public.match_provider_map;

-------------------------------------------------------------------------------
-- 2. OVĚŘENÍ ZDROJOVÝCH SLOUPCŮ
-------------------------------------------------------------------------------

SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'matches'
  AND column_name IN (
      'id',
      'sport_code',
      'ext_source',
      'ext_match_id'
  )
ORDER BY ordinal_position;

-------------------------------------------------------------------------------
-- 3. ZÁKLADNÍ SOUHRN public.matches
-------------------------------------------------------------------------------

SELECT
    COUNT(*) AS matches_total,

    COUNT(*) FILTER (
        WHERE ext_source IS NOT NULL
          AND btrim(ext_source::text) <> ''
    ) AS rows_with_ext_source,

    COUNT(*) FILTER (
        WHERE ext_match_id IS NOT NULL
          AND btrim(ext_match_id::text) <> ''
    ) AS rows_with_ext_match_id,

    COUNT(*) FILTER (
        WHERE ext_source IS NOT NULL
          AND btrim(ext_source::text) <> ''
          AND ext_match_id IS NOT NULL
          AND btrim(ext_match_id::text) <> ''
    ) AS complete_identity_rows,

    COUNT(*) FILTER (
        WHERE ext_source IS NULL
           OR btrim(ext_source::text) = ''
           OR ext_match_id IS NULL
           OR btrim(ext_match_id::text) = ''
    ) AS incomplete_identity_rows
FROM public.matches;

-------------------------------------------------------------------------------
-- 4. KLASIFIKACE ÚPLNOSTI IDENTIT
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN ext_source IS NOT NULL
         AND btrim(ext_source::text) <> ''
         AND ext_match_id IS NOT NULL
         AND btrim(ext_match_id::text) <> ''
            THEN 'COMPLETE'

        WHEN (
            ext_source IS NULL
            OR btrim(ext_source::text) = ''
        )
        AND ext_match_id IS NOT NULL
        AND btrim(ext_match_id::text) <> ''
            THEN 'MISSING_SOURCE'

        WHEN ext_source IS NOT NULL
         AND btrim(ext_source::text) <> ''
         AND (
            ext_match_id IS NULL
            OR btrim(ext_match_id::text) = ''
        )
            THEN 'MISSING_EXTERNAL_ID'

        ELSE 'BOTH_MISSING'
    END AS identity_state,

    COUNT(*) AS row_count
FROM public.matches
GROUP BY 1
ORDER BY row_count DESC, identity_state;

-------------------------------------------------------------------------------
-- 5. PROVIDEŘI – PŘESNÉ HODNOTY
-------------------------------------------------------------------------------

SELECT
    ext_source::text AS ext_source,
    COUNT(*) AS match_count,

    COUNT(*) FILTER (
        WHERE ext_match_id IS NOT NULL
          AND btrim(ext_match_id::text) <> ''
    ) AS complete_external_ids,

    COUNT(*) FILTER (
        WHERE ext_match_id IS NULL
           OR btrim(ext_match_id::text) = ''
    ) AS missing_external_ids,

    MIN(id) AS minimum_match_id,
    MAX(id) AS maximum_match_id
FROM public.matches
WHERE ext_source IS NOT NULL
  AND btrim(ext_source::text) <> ''
GROUP BY ext_source::text
ORDER BY match_count DESC, ext_source::text;

-------------------------------------------------------------------------------
-- 6. PROVIDEŘI – NORMALIZOVANÉ VARIANTY
--
-- Odhalí například:
-- api_football
-- API_FOOTBALL
-- api_football<mezera>
-------------------------------------------------------------------------------

SELECT
    lower(btrim(ext_source::text)) AS normalized_provider,
    COUNT(DISTINCT ext_source::text) AS exact_variants,
    array_agg(
        DISTINCT ext_source::text
        ORDER BY ext_source::text
    ) AS stored_variants,
    COUNT(*) AS match_count
FROM public.matches
WHERE ext_source IS NOT NULL
  AND btrim(ext_source::text) <> ''
GROUP BY lower(btrim(ext_source::text))
HAVING COUNT(DISTINCT ext_source::text) > 1
ORDER BY match_count DESC, normalized_provider;

-------------------------------------------------------------------------------
-- 7. DUPLICITNÍ EXTERNÍ IDENTITY
--
-- Každý vrácený řádek představuje kolizi s unikátním indexem:
-- uq_mpm_provider_identity(provider, provider_match_id)
-------------------------------------------------------------------------------

SELECT
    btrim(ext_source::text) AS provider,
    btrim(ext_match_id::text) AS provider_match_id,
    COUNT(*) AS canonical_match_rows,
    COUNT(DISTINCT id) AS distinct_match_ids,
    MIN(id) AS minimum_match_id,
    MAX(id) AS maximum_match_id
FROM public.matches
WHERE ext_source IS NOT NULL
  AND btrim(ext_source::text) <> ''
  AND ext_match_id IS NOT NULL
  AND btrim(ext_match_id::text) <> ''
GROUP BY
    btrim(ext_source::text),
    btrim(ext_match_id::text)
HAVING COUNT(*) > 1
ORDER BY
    canonical_match_rows DESC,
    provider,
    provider_match_id
LIMIT 200;

-------------------------------------------------------------------------------
-- 8. POČET DUPLICITNÍCH SKUPIN A DOTČENÝCH ŘÁDKŮ
-------------------------------------------------------------------------------

WITH duplicate_groups AS
(
    SELECT
        btrim(ext_source::text) AS provider,
        btrim(ext_match_id::text) AS provider_match_id,
        COUNT(*) AS row_count
    FROM public.matches
    WHERE ext_source IS NOT NULL
      AND btrim(ext_source::text) <> ''
      AND ext_match_id IS NOT NULL
      AND btrim(ext_match_id::text) <> ''
    GROUP BY
        btrim(ext_source::text),
        btrim(ext_match_id::text)
    HAVING COUNT(*) > 1
)
SELECT
    COUNT(*) AS duplicate_identity_groups,
    COALESCE(SUM(row_count), 0) AS rows_in_duplicate_groups,
    COALESCE(SUM(row_count - 1), 0) AS excess_duplicate_rows
FROM duplicate_groups;

-------------------------------------------------------------------------------
-- 9. DUPLICITY PO PROVIDERECH
-------------------------------------------------------------------------------

WITH duplicate_groups AS
(
    SELECT
        btrim(ext_source::text) AS provider,
        btrim(ext_match_id::text) AS provider_match_id,
        COUNT(*) AS row_count
    FROM public.matches
    WHERE ext_source IS NOT NULL
      AND btrim(ext_source::text) <> ''
      AND ext_match_id IS NOT NULL
      AND btrim(ext_match_id::text) <> ''
    GROUP BY
        btrim(ext_source::text),
        btrim(ext_match_id::text)
    HAVING COUNT(*) > 1
)
SELECT
    provider,
    COUNT(*) AS duplicate_identity_groups,
    SUM(row_count) AS rows_in_duplicate_groups,
    SUM(row_count - 1) AS excess_duplicate_rows
FROM duplicate_groups
GROUP BY provider
ORDER BY
    duplicate_identity_groups DESC,
    provider;

-------------------------------------------------------------------------------
-- 10. STEJNÉ EXTERNÍ ID POUŽITÉ U RŮZNÝCH PROVIDERŮ
--
-- Toto není automaticky chyba.
-- Slouží pouze k potvrzení, že unikátnost musí zahrnovat i provider.
-------------------------------------------------------------------------------

SELECT
    btrim(ext_match_id::text) AS provider_match_id,
    COUNT(DISTINCT btrim(ext_source::text)) AS provider_count,
    array_agg(
        DISTINCT btrim(ext_source::text)
        ORDER BY btrim(ext_source::text)
    ) AS providers,
    COUNT(*) AS row_count
FROM public.matches
WHERE ext_source IS NOT NULL
  AND btrim(ext_source::text) <> ''
  AND ext_match_id IS NOT NULL
  AND btrim(ext_match_id::text) <> ''
GROUP BY btrim(ext_match_id::text)
HAVING COUNT(DISTINCT btrim(ext_source::text)) > 1
ORDER BY provider_count DESC, row_count DESC
LIMIT 100;

-------------------------------------------------------------------------------
-- 11. NEOBVYKLÉ NEBO RIZIKOVÉ EXTERNÍ IDENTIFIKÁTORY
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN ext_match_id IS NULL
            THEN 'NULL'

        WHEN btrim(ext_match_id::text) = ''
            THEN 'BLANK'

        WHEN ext_match_id::text <> btrim(ext_match_id::text)
            THEN 'LEADING_OR_TRAILING_WHITESPACE'

        WHEN length(btrim(ext_match_id::text)) > 200
            THEN 'LONGER_THAN_200'

        WHEN btrim(ext_match_id::text) ~ '[[:cntrl:]]'
            THEN 'CONTROL_CHARACTER'

        ELSE 'OTHER'
    END AS issue_type,

    COUNT(*) AS row_count
FROM public.matches
WHERE ext_match_id IS NULL
   OR btrim(ext_match_id::text) = ''
   OR ext_match_id::text <> btrim(ext_match_id::text)
   OR length(btrim(ext_match_id::text)) > 200
   OR btrim(ext_match_id::text) ~ '[[:cntrl:]]'
GROUP BY 1
ORDER BY row_count DESC, issue_type;

-------------------------------------------------------------------------------
-- 12. PŘEDPOKLÁDANÝ BEZPEČNÝ BACKFILL
--
-- READY_FOR_DIRECT_BACKFILL:
-- kompletní identita a v public.matches není duplicitní.
--
-- REQUIRES_REVIEW:
-- kompletní, ale stejná providerová identita je na více zápasech.
--
-- NOT_ELIGIBLE:
-- chybí provider nebo externí ID.
-------------------------------------------------------------------------------

WITH identity_counts AS
(
    SELECT
        btrim(ext_source::text) AS provider,
        btrim(ext_match_id::text) AS provider_match_id,
        COUNT(*) AS occurrence_count
    FROM public.matches
    WHERE ext_source IS NOT NULL
      AND btrim(ext_source::text) <> ''
      AND ext_match_id IS NOT NULL
      AND btrim(ext_match_id::text) <> ''
    GROUP BY
        btrim(ext_source::text),
        btrim(ext_match_id::text)
),
classified AS
(
    SELECT
        m.id,

        CASE
            WHEN m.ext_source IS NULL
              OR btrim(m.ext_source::text) = ''
              OR m.ext_match_id IS NULL
              OR btrim(m.ext_match_id::text) = ''
                THEN 'NOT_ELIGIBLE'

            WHEN ic.occurrence_count = 1
                THEN 'READY_FOR_DIRECT_BACKFILL'

            ELSE 'REQUIRES_REVIEW'
        END AS backfill_state
    FROM public.matches m
    LEFT JOIN identity_counts ic
      ON ic.provider = btrim(m.ext_source::text)
     AND ic.provider_match_id = btrim(m.ext_match_id::text)
)
SELECT
    backfill_state,
    COUNT(*) AS row_count
FROM classified
GROUP BY backfill_state
ORDER BY
    CASE backfill_state
        WHEN 'READY_FOR_DIRECT_BACKFILL' THEN 1
        WHEN 'REQUIRES_REVIEW' THEN 2
        WHEN 'NOT_ELIGIBLE' THEN 3
        ELSE 4
    END;

-------------------------------------------------------------------------------
-- 13. KONTROLA SOUČASNÉ CÍLOVÉ TABULKY
-------------------------------------------------------------------------------

SELECT
    COUNT(*) AS target_rows,
    COUNT(DISTINCT match_id) AS mapped_matches,
    COUNT(*) FILTER (
        WHERE is_primary = true
          AND mapping_status = 'ACTIVE'
    ) AS active_primary_rows
FROM public.match_provider_map;

-------------------------------------------------------------------------------
-- 14. KONEČNÝ STAV AUDITU
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN to_regclass('public.match_provider_map') IS NULL
            THEN 'AUDIT_FAILED – CÍLOVÁ TABULKA CHYBÍ'

        WHEN EXISTS (
            SELECT 1
            FROM public.match_provider_map
        )
            THEN 'AUDIT_WARNING – CÍLOVÁ TABULKA JIŽ OBSAHUJE DATA'

        ELSE 'READ_ONLY_AUDIT_OK – PŘIPRAVENO K VYHODNOCENÍ BACKFILLU'
    END AS final_status;

ROLLBACK;