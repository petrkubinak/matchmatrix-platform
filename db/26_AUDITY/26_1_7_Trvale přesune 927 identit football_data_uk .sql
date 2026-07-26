/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
APPLY – MATCH PROVIDER IDENTITY TRANSFER V1
===============================================================================

CO:
- Trvale přesune 927 identit football_data_uk z duplicitních historických
  zápasů na odpovídající kanonické zápasy API-Football.

VÝSLEDEK:
- Každý z 927 kanonických zápasů bude mít:
    1× api_football identity – primární
    1× football_data_uk identity – sekundární
- Historické duplicitní zápasy zatím zůstávají v public.matches.
- Žádné downstream vazby se nemění.
- Žádný zápas se nemaže.

NEDOTČENÉ PŘÍPADY:
- UNIQUE_HISTORY          : 1284
- REVIEW_INCOMPLETE_SCORE : 1
- REVIEW_SCORE_CONFLICT   : 2

OČEKÁVANÝ STAV PO APPLY:
- match_provider_map řádků             : 121908
- distinct mapped matches              : 120981
- aktivních primárních identit         : 120981
- víceproviderových belgických zápasů  : 927
- zápasů bez providerové mapy          : 930
    - 927 historických duplicit
    - 3 manual_test

ROLLBACK PŘIPRAVENOST:
- Původní a cílové match_id jsou uloženy v metadata.
===============================================================================
*/

BEGIN ISOLATION LEVEL REPEATABLE READ;

SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '300s';
SET LOCAL client_min_messages = 'notice';
SET LOCAL TIME ZONE 'UTC';

-------------------------------------------------------------------------------
-- 1. PROSTŘEDÍ
-------------------------------------------------------------------------------

SELECT
    current_database() AS database_name,
    current_user AS database_user,
    current_setting('transaction_isolation') AS transaction_isolation,
    current_setting('transaction_read_only') AS transaction_read_only,
    current_setting('TimeZone') AS session_timezone,
    clock_timestamp() AS apply_started_at;

-------------------------------------------------------------------------------
-- 2. POVINNÉ OBJEKTY
-------------------------------------------------------------------------------

DO $objects$
BEGIN
    IF to_regclass('public.matches') IS NULL THEN
        RAISE EXCEPTION
            'APPLY_FAILED: public.matches neexistuje.';
    END IF;

    IF to_regclass('public.match_provider_map') IS NULL THEN
        RAISE EXCEPTION
            'APPLY_FAILED: public.match_provider_map neexistuje.';
    END IF;

    IF to_regprocedure(
        'public.fn_match_provider_map_touch()'
    ) IS NULL THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Auditní funkce match_provider_map neexistuje.';
    END IF;

    RAISE NOTICE
        'OK OBJECTS: Povinné databázové objekty existují.';
END
$objects$;

-------------------------------------------------------------------------------
-- 3. OCHRANA PROTI SOUBĚŽNÝM ZMĚNÁM
-------------------------------------------------------------------------------

LOCK TABLE public.matches
IN SHARE MODE;

LOCK TABLE public.match_provider_map
IN SHARE ROW EXCLUSIVE MODE;

-------------------------------------------------------------------------------
-- 4. POTVRZENÉ MAPOVÁNÍ BELGICKÝCH TÝMŮ
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_team_map
(
    historical_team_id integer PRIMARY KEY,
    api_team_id integer NOT NULL UNIQUE,
    club_name text NOT NULL
)
ON COMMIT DROP;

INSERT INTO mm_be_team_map
(
    historical_team_id,
    api_team_id,
    club_name
)
VALUES
    (972, 12940, 'Anderlecht'),
    (964, 13172, 'Antwerp'),
    (980, 12515, 'Beerschot VA'),
    (967, 12844, 'Cercle Brugge'),
    (975, 13032, 'Charleroi'),
    (976, 12803, 'Club Brugge'),
    (966, 12665, 'Dender'),
    (982, 13516, 'Eupen'),
    (977, 12254, 'Genk'),
    (979, 12719, 'Gent'),
    (981, 13043, 'Kortrijk'),
    (969, 12517, 'Mechelen'),
    (985, 15765, 'Oostende'),
    (974, 12636, 'OH Leuven'),
    (983, 13328, 'RWD Molenbeek'),
    (984, 12565, 'Seraing'),
    (971, 13537, 'Standard Liège'),
    (965, 13160, 'Union St. Gilloise'),
    (978, 12277, 'St. Truiden'),
    (968, 12993, 'Zulte Waregem'),
    (973, 13279, 'Westerlo');

-------------------------------------------------------------------------------
-- 5. NORMALIZOVANÝ BELGICKÝ VÝŘEZ
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_matches_base
ON COMMIT DROP
AS
SELECT
    id AS match_id,
    league_id,
    home_team_id,
    away_team_id,
    kickoff::date AS match_day,
    home_score::integer AS home_score,
    away_score::integer AS away_score,
    btrim(ext_source::text) AS provider,
    btrim(ext_match_id::text) AS provider_match_id

FROM public.matches

WHERE
    (
        league_id = 4
        AND btrim(ext_source::text) = 'football_data_uk'
    )
    OR
    (
        league_id = 20853
        AND btrim(ext_source::text) = 'api_football'
    );

-------------------------------------------------------------------------------
-- 6. PŘEVOD HISTORICKÝCH TÝMOVÝCH ID
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_history_transformed
ON COMMIT DROP
AS
SELECT
    h.match_id AS historical_match_id,
    h.match_day,

    h.home_team_id AS historical_home_team_id,
    h.away_team_id AS historical_away_team_id,

    COALESCE(home_map.api_team_id, h.home_team_id)
        AS target_home_team_id,

    COALESCE(away_map.api_team_id, h.away_team_id)
        AS target_away_team_id,

    h.home_score AS historical_home_score,
    h.away_score AS historical_away_score,

    h.provider_match_id AS historical_provider_match_id

FROM mm_be_matches_base h

LEFT JOIN mm_be_team_map home_map
  ON home_map.historical_team_id = h.home_team_id

LEFT JOIN mm_be_team_map away_map
  ON away_map.historical_team_id = h.away_team_id

WHERE h.provider = 'football_data_uk'
  AND h.league_id = 4;

-------------------------------------------------------------------------------
-- 7. MIGRAČNÍ PLÁN
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_migration_plan
ON COMMIT DROP
AS
SELECT
    h.*,

    api.api_candidate_count,
    api.api_match_id,
    api.api_home_score,
    api.api_away_score,

    CASE
        WHEN api.api_candidate_count = 0
            THEN 'UNIQUE_HISTORY'

        WHEN api.api_candidate_count > 1
            THEN 'AMBIGUOUS_API_MATCH'

        WHEN h.historical_home_score IS NULL
          OR h.historical_away_score IS NULL
          OR api.api_home_score IS NULL
          OR api.api_away_score IS NULL
            THEN 'REVIEW_INCOMPLETE_SCORE'

        WHEN h.historical_home_score = api.api_home_score
         AND h.historical_away_score = api.api_away_score
            THEN 'OVERLAP_SAME_SCORE'

        ELSE 'REVIEW_SCORE_CONFLICT'
    END AS migration_class

FROM mm_be_history_transformed h

LEFT JOIN LATERAL
(
    SELECT
        COUNT(*)::integer AS api_candidate_count,
        MIN(a.match_id) AS api_match_id,
        MIN(a.home_score) AS api_home_score,
        MIN(a.away_score) AS api_away_score

    FROM mm_be_matches_base a

    WHERE a.provider = 'api_football'
      AND a.league_id = 20853
      AND a.match_day = h.match_day
      AND a.home_team_id = h.target_home_team_id
      AND a.away_team_id = h.target_away_team_id
) api
ON true;

-------------------------------------------------------------------------------
-- 8. POVINNÉ OVĚŘENÍ KLASIFIKACE
-------------------------------------------------------------------------------

DO $classification_check$
DECLARE
    v_total bigint;
    v_unique bigint;
    v_same bigint;
    v_incomplete bigint;
    v_conflict bigint;
    v_ambiguous bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(*) FILTER (
            WHERE migration_class = 'UNIQUE_HISTORY'
        ),
        COUNT(*) FILTER (
            WHERE migration_class = 'OVERLAP_SAME_SCORE'
        ),
        COUNT(*) FILTER (
            WHERE migration_class = 'REVIEW_INCOMPLETE_SCORE'
        ),
        COUNT(*) FILTER (
            WHERE migration_class = 'REVIEW_SCORE_CONFLICT'
        ),
        COUNT(*) FILTER (
            WHERE migration_class = 'AMBIGUOUS_API_MATCH'
        )
    INTO
        v_total,
        v_unique,
        v_same,
        v_incomplete,
        v_conflict,
        v_ambiguous
    FROM mm_be_migration_plan;

    IF v_total <> 2214
       OR v_unique <> 1284
       OR v_same <> 927
       OR v_incomplete <> 1
       OR v_conflict <> 2
       OR v_ambiguous <> 0 THEN

        RAISE EXCEPTION
            'APPLY_FAILED: total %, unique %, same %, incomplete %, conflict %, ambiguous %.',
            v_total,
            v_unique,
            v_same,
            v_incomplete,
            v_conflict,
            v_ambiguous;
    END IF;

    RAISE NOTICE
        'OK CLASSIFICATION: total %, unique %, same %, incomplete %, conflict %, ambiguous %.',
        v_total,
        v_unique,
        v_same,
        v_incomplete,
        v_conflict,
        v_ambiguous;
END
$classification_check$;

-------------------------------------------------------------------------------
-- 9. PŘEDBĚŽNÁ KONTROLA PROVIDEROVÉ MAPY
-------------------------------------------------------------------------------

DO $identity_precheck$
DECLARE
    v_total_rows bigint;
    v_active_primary_rows bigint;
    v_safe_history_rows bigint;
    v_safe_api_rows bigint;
    v_already_transferred bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(*) FILTER (
            WHERE is_primary = true
              AND mapping_status = 'ACTIVE'
        )
    INTO
        v_total_rows,
        v_active_primary_rows
    FROM public.match_provider_map;

    SELECT COUNT(*)
    INTO v_safe_history_rows
    FROM mm_be_migration_plan plan
    JOIN public.match_provider_map identity
      ON identity.match_id = plan.historical_match_id
     AND identity.provider = 'football_data_uk'
     AND identity.provider_match_id =
         plan.historical_provider_match_id
     AND identity.is_primary = true
     AND identity.mapping_status = 'ACTIVE'
    WHERE plan.migration_class = 'OVERLAP_SAME_SCORE';

    SELECT COUNT(*)
    INTO v_safe_api_rows
    FROM mm_be_migration_plan plan
    JOIN public.match_provider_map identity
      ON identity.match_id = plan.api_match_id
     AND identity.provider = 'api_football'
     AND identity.is_primary = true
     AND identity.mapping_status = 'ACTIVE'
    WHERE plan.migration_class = 'OVERLAP_SAME_SCORE';

    SELECT COUNT(*)
    INTO v_already_transferred
    FROM public.match_provider_map
    WHERE metadata ->> 'belgium_identity_transfer'
          = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1';

    IF v_total_rows <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Providerová mapa obsahuje % řádků místo 121908.',
            v_total_rows;
    END IF;

    IF v_active_primary_rows <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Aktivních primárních identit je % místo 121908.',
            v_active_primary_rows;
    END IF;

    IF v_safe_history_rows <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Připravených historických identit je % místo 927.',
            v_safe_history_rows;
    END IF;

    IF v_safe_api_rows <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Primárních API identit je % místo 927.',
            v_safe_api_rows;
    END IF;

    IF v_already_transferred <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Již bylo převedeno % belgických identit.',
            v_already_transferred;
    END IF;

    RAISE NOTICE
        'OK PRECHECK: mapa %, primární identity %, historické identity %, API identity %, již převedeno %.',
        v_total_rows,
        v_active_primary_rows,
        v_safe_history_rows,
        v_safe_api_rows,
        v_already_transferred;
END
$identity_precheck$;

-------------------------------------------------------------------------------
-- 10. TRVALÝ PŘEVOD 927 IDENTIT
-------------------------------------------------------------------------------

DO $apply_transfer$
DECLARE
    v_updated_rows bigint;
BEGIN
    UPDATE public.match_provider_map identity
    SET
        match_id = plan.api_match_id,
        is_primary = false,

        metadata =
            identity.metadata ||
            jsonb_build_object(
                'belgium_identity_transfer',
                'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1',

                'transfer_date',
                '2026-07-24',

                'previous_match_id',
                plan.historical_match_id,

                'target_match_id',
                plan.api_match_id,

                'migration_class',
                plan.migration_class,

                'canonical_provider',
                'api_football',

                'secondary_source',
                'football_data_uk',

                'reversible',
                true
            )

    FROM mm_be_migration_plan plan

    WHERE plan.migration_class = 'OVERLAP_SAME_SCORE'
      AND identity.match_id = plan.historical_match_id
      AND identity.provider = 'football_data_uk'
      AND identity.provider_match_id =
          plan.historical_provider_match_id
      AND identity.is_primary = true
      AND identity.mapping_status = 'ACTIVE';

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Přesunuto % identit místo 927.',
            v_updated_rows;
    END IF;

    RAISE NOTICE
        'OK TRANSFER: Trvale přesunuto 927 identit football_data_uk.';
END
$apply_transfer$;

-------------------------------------------------------------------------------
-- 11. KONTROLA VÍCEPROVIDEROVÝCH KANONICKÝCH ZÁPASŮ
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_overlap_identity_check
ON COMMIT DROP
AS
SELECT
    plan.api_match_id AS canonical_match_id,

    COUNT(identity.id) AS identity_count,

    COUNT(*) FILTER (
        WHERE identity.is_primary = true
          AND identity.mapping_status = 'ACTIVE'
    ) AS active_primary_count,

    COUNT(*) FILTER (
        WHERE identity.provider = 'api_football'
    ) AS api_football_identity_count,

    COUNT(*) FILTER (
        WHERE identity.provider = 'football_data_uk'
    ) AS football_data_uk_identity_count

FROM mm_be_migration_plan plan

JOIN public.match_provider_map identity
  ON identity.match_id = plan.api_match_id

WHERE plan.migration_class = 'OVERLAP_SAME_SCORE'

GROUP BY plan.api_match_id;

-------------------------------------------------------------------------------
-- 12. ÚPLNÁ KONTROLA PO PŘEVODU
-------------------------------------------------------------------------------

DO $post_transfer_check$
DECLARE
    v_checked bigint;
    v_two_identities bigint;
    v_one_primary bigint;
    v_both_providers bigint;

    v_total_rows bigint;
    v_distinct_matches bigint;
    v_active_primary_rows bigint;
    v_transferred_rows bigint;

    v_safe_history_remaining bigint;
    v_unique_history_untouched bigint;
    v_review_history_untouched bigint;

    v_duplicate_identity_groups bigint;
    v_duplicate_primary_groups bigint;
    v_orphan_rows bigint;
    v_unmapped_matches bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(*) FILTER (
            WHERE identity_count = 2
        ),
        COUNT(*) FILTER (
            WHERE active_primary_count = 1
        ),
        COUNT(*) FILTER (
            WHERE api_football_identity_count = 1
              AND football_data_uk_identity_count = 1
        )
    INTO
        v_checked,
        v_two_identities,
        v_one_primary,
        v_both_providers
    FROM mm_be_overlap_identity_check;

    SELECT
        COUNT(*),
        COUNT(DISTINCT match_id),
        COUNT(*) FILTER (
            WHERE is_primary = true
              AND mapping_status = 'ACTIVE'
        ),
        COUNT(*) FILTER (
            WHERE metadata ->> 'belgium_identity_transfer'
                  = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'
        )
    INTO
        v_total_rows,
        v_distinct_matches,
        v_active_primary_rows,
        v_transferred_rows
    FROM public.match_provider_map;

    SELECT COUNT(*)
    INTO v_safe_history_remaining
    FROM mm_be_migration_plan plan
    JOIN public.match_provider_map identity
      ON identity.match_id = plan.historical_match_id
     AND identity.provider = 'football_data_uk'
     AND identity.provider_match_id =
         plan.historical_provider_match_id
    WHERE plan.migration_class = 'OVERLAP_SAME_SCORE';

    SELECT COUNT(*)
    INTO v_unique_history_untouched
    FROM mm_be_migration_plan plan
    JOIN public.match_provider_map identity
      ON identity.match_id = plan.historical_match_id
     AND identity.provider = 'football_data_uk'
     AND identity.is_primary = true
     AND identity.mapping_status = 'ACTIVE'
    WHERE plan.migration_class = 'UNIQUE_HISTORY';

    SELECT COUNT(*)
    INTO v_review_history_untouched
    FROM mm_be_migration_plan plan
    JOIN public.match_provider_map identity
      ON identity.match_id = plan.historical_match_id
     AND identity.provider = 'football_data_uk'
     AND identity.is_primary = true
     AND identity.mapping_status = 'ACTIVE'
    WHERE plan.migration_class IN
    (
        'REVIEW_INCOMPLETE_SCORE',
        'REVIEW_SCORE_CONFLICT'
    );

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
    FROM public.match_provider_map identity
    LEFT JOIN public.matches match
      ON match.id = identity.match_id
    WHERE match.id IS NULL;

    SELECT COUNT(*)
    INTO v_unmapped_matches
    FROM public.matches match
    LEFT JOIN public.match_provider_map identity
      ON identity.match_id = match.id
    WHERE identity.id IS NULL;

    IF v_checked <> 927
       OR v_two_identities <> 927
       OR v_one_primary <> 927
       OR v_both_providers <> 927 THEN

        RAISE EXCEPTION
            'APPLY_FAILED: multi-provider check %, two %, primary %, providers %.',
            v_checked,
            v_two_identities,
            v_one_primary,
            v_both_providers;
    END IF;

    IF v_total_rows <> 121908 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Celkový počet mapování je % místo 121908.',
            v_total_rows;
    END IF;

    IF v_distinct_matches <> 120981 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Namapovaných zápasů je % místo 120981.',
            v_distinct_matches;
    END IF;

    IF v_active_primary_rows <> 120981 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Primárních identit je % místo 120981.',
            v_active_primary_rows;
    END IF;

    IF v_transferred_rows <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Migrační metadata má % řádků místo 927.',
            v_transferred_rows;
    END IF;

    IF v_safe_history_remaining <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Na historických duplicitách zůstalo % identit.',
            v_safe_history_remaining;
    END IF;

    IF v_unique_history_untouched <> 1284 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Nedotčená unikátní historie % místo 1284.',
            v_unique_history_untouched;
    END IF;

    IF v_review_history_untouched <> 3 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Nedotčené review případy % místo 3.',
            v_review_history_untouched;
    END IF;

    IF v_duplicate_identity_groups <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Duplicitní providerové identity %.',
            v_duplicate_identity_groups;
    END IF;

    IF v_duplicate_primary_groups <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Zápasy s více primárními identitami %.',
            v_duplicate_primary_groups;
    END IF;

    IF v_orphan_rows <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Osiřelá mapování %.',
            v_orphan_rows;
    END IF;

    IF v_unmapped_matches <> 930 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Zápasů bez mapy je % místo 930.',
            v_unmapped_matches;
    END IF;

    RAISE NOTICE
        'OK POST TRANSFER: multi-provider 927, celkem %, mapped %, primární %, převedené %, unikátní historie %, review %, unmapped %, duplicity %, orphan %.',
        v_total_rows,
        v_distinct_matches,
        v_active_primary_rows,
        v_transferred_rows,
        v_unique_history_untouched,
        v_review_history_untouched,
        v_unmapped_matches,
        v_duplicate_identity_groups,
        v_orphan_rows;
END
$post_transfer_check$;

-------------------------------------------------------------------------------
-- 13. TŘI NEDOTČENÉ KONTROLNÍ PŘÍPADY
-------------------------------------------------------------------------------

SELECT
    migration_class,
    match_day,

    historical_match_id,
    api_match_id,

    historical_home_team_id,
    historical_away_team_id,

    target_home_team_id,
    target_away_team_id,

    historical_home_score,
    historical_away_score,

    api_home_score,
    api_away_score

FROM mm_be_migration_plan

WHERE migration_class IN
(
    'REVIEW_INCOMPLETE_SCORE',
    'REVIEW_SCORE_CONFLICT'
)

ORDER BY
    match_day,
    historical_match_id;

-------------------------------------------------------------------------------
-- 14. SOUHRN PŘED COMMIT
-------------------------------------------------------------------------------

SELECT
    'MATCH_PROVIDER_MAP_ROWS' AS check_name,
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
    'BELGIUM_TRANSFERRED_IDENTITIES',
    COUNT(*)::text
FROM public.match_provider_map
WHERE metadata ->> 'belgium_identity_transfer'
      = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'

UNION ALL

SELECT
    'BELGIUM_MULTI_PROVIDER_MATCHES',
    COUNT(*)::text
FROM mm_be_overlap_identity_check

UNION ALL

SELECT
    'UNIQUE_HISTORY_UNTOUCHED',
    COUNT(*)::text
FROM mm_be_migration_plan plan
JOIN public.match_provider_map identity
  ON identity.match_id = plan.historical_match_id
 AND identity.provider = 'football_data_uk'
WHERE plan.migration_class = 'UNIQUE_HISTORY'

UNION ALL

SELECT
    'REVIEW_CASES_UNTOUCHED',
    COUNT(*)::text
FROM mm_be_migration_plan plan
JOIN public.match_provider_map identity
  ON identity.match_id = plan.historical_match_id
 AND identity.provider = 'football_data_uk'
WHERE plan.migration_class IN
(
    'REVIEW_INCOMPLETE_SCORE',
    'REVIEW_SCORE_CONFLICT'
);

-------------------------------------------------------------------------------
-- 15. STAV PŘED COMMIT
-------------------------------------------------------------------------------

SELECT
    'APPLY_VALIDATED – 927 BELGICKÝCH IDENTIT PŘIPRAVENO K COMMIT'
        AS pre_commit_status;

-------------------------------------------------------------------------------
-- 16. TRVALÉ ULOŽENÍ
-------------------------------------------------------------------------------

COMMIT;

-------------------------------------------------------------------------------
-- 17. AKTUALIZACE STATISTIK
-------------------------------------------------------------------------------

ANALYZE public.match_provider_map;

-------------------------------------------------------------------------------
-- 18. KONEČNÝ POST-COMMIT AUDIT
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN COUNT(*) = 121908

         AND COUNT(DISTINCT match_id) = 120981

         AND COUNT(*) FILTER (
                WHERE is_primary = true
                  AND mapping_status = 'ACTIVE'
             ) = 120981

         AND COUNT(*) FILTER (
                WHERE metadata ->> 'belgium_identity_transfer'
                      = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'
             ) = 927

        THEN
            'APPLY_OK – 927 BELGICKÝCH IDENTIT TRVALE PŘEVEDENO'

        ELSE
            'APPLY_POST_COMMIT_WARNING – KONTROLNÍ POČTY SE NESHODUJÍ'
    END AS final_status,

    COUNT(*) AS total_rows,

    COUNT(DISTINCT match_id) AS distinct_mapped_matches,

    COUNT(*) FILTER (
        WHERE is_primary = true
          AND mapping_status = 'ACTIVE'
    ) AS active_primary_identities,

    COUNT(*) FILTER (
        WHERE metadata ->> 'belgium_identity_transfer'
              = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'
    ) AS belgium_transferred_identities

FROM public.match_provider_map;

-------------------------------------------------------------------------------
-- 19. KONTROLA 927 VÍCEPROVIDEROVÝCH ZÁPASŮ PO COMMIT
-------------------------------------------------------------------------------

WITH belgium_transfers AS
(
    SELECT DISTINCT
        (metadata ->> 'target_match_id')::integer
            AS canonical_match_id
    FROM public.match_provider_map
    WHERE metadata ->> 'belgium_identity_transfer'
          = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'
),
identity_summary AS
(
    SELECT
        transfer.canonical_match_id,

        COUNT(identity.id) AS identity_count,

        COUNT(*) FILTER (
            WHERE identity.is_primary = true
              AND identity.mapping_status = 'ACTIVE'
        ) AS active_primary_count,

        COUNT(*) FILTER (
            WHERE identity.provider = 'api_football'
        ) AS api_football_count,

        COUNT(*) FILTER (
            WHERE identity.provider = 'football_data_uk'
        ) AS football_data_uk_count

    FROM belgium_transfers transfer

    JOIN public.match_provider_map identity
      ON identity.match_id = transfer.canonical_match_id

    GROUP BY transfer.canonical_match_id
)
SELECT
    COUNT(*) AS canonical_matches,

    COUNT(*) FILTER (
        WHERE identity_count = 2
    ) AS matches_with_two_identities,

    COUNT(*) FILTER (
        WHERE active_primary_count = 1
    ) AS matches_with_one_primary,

    COUNT(*) FILTER (
        WHERE api_football_count = 1
          AND football_data_uk_count = 1
    ) AS matches_with_both_sources

FROM identity_summary;