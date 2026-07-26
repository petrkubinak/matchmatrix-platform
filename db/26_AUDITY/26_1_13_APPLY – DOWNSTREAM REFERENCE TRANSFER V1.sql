/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
APPLY – DOWNSTREAM REFERENCE TRANSFER V1
===============================================================================

CO:
- Trvale převede 927 řádků public.match_features na kanonické zápasy.
- Trvale převede 927 řádků public.mm_match_ratings.
- U ratingů sjednotí:
    match_id,
    league_id,
    kickoff,
    home_team_id,
    away_team_id
  podle cílového zápasu API-Football.

ZACHOVÁ:
- všechny feature hodnoty,
- všechny ratingové hodnoty,
- počet řádků obou tabulek,
- existující stav ostatních osiřelých mm_match_ratings.

NEMĚNÍ:
- public.matches,
- public.match_provider_map,
- ostatní downstream tabulky.

ROLLBACK PŘIPRAVENOST:
- previous_match_id a target_match_id jsou trvale uloženy
  v public.match_provider_map.metadata.
- Původní zápasy zatím zůstávají v public.matches.
===============================================================================
*/

ROLLBACK;

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

    IF to_regclass('public.match_features') IS NULL THEN
        RAISE EXCEPTION
            'APPLY_FAILED: public.match_features neexistuje.';
    END IF;

    IF to_regclass('public.mm_match_ratings') IS NULL THEN
        RAISE EXCEPTION
            'APPLY_FAILED: public.mm_match_ratings neexistuje.';
    END IF;

    RAISE NOTICE
        'OK OBJECTS: Povinné tabulky existují.';
END
$objects$;

-------------------------------------------------------------------------------
-- 3. OCHRANA PROTI SOUBĚŽNÝM ZMĚNÁM
-------------------------------------------------------------------------------

LOCK TABLE public.matches
IN SHARE MODE;

LOCK TABLE public.match_provider_map
IN SHARE MODE;

LOCK TABLE public.match_features
IN SHARE ROW EXCLUSIVE MODE;

LOCK TABLE public.mm_match_ratings
IN SHARE ROW EXCLUSIVE MODE;

-------------------------------------------------------------------------------
-- 4. MIGRAČNÍ PLÁN
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_downstream_transfer_plan
ON COMMIT DROP
AS
SELECT DISTINCT
    (identity.metadata ->> 'previous_match_id')::bigint
        AS previous_match_id,

    (identity.metadata ->> 'target_match_id')::bigint
        AS target_match_id,

    previous_match.league_id::bigint
        AS previous_league_id,

    previous_match.kickoff
        AS previous_kickoff,

    previous_match.home_team_id::bigint
        AS previous_home_team_id,

    previous_match.away_team_id::bigint
        AS previous_away_team_id,

    target_match.league_id::bigint
        AS target_league_id,

    target_match.kickoff
        AS target_kickoff,

    target_match.home_team_id::bigint
        AS target_home_team_id,

    target_match.away_team_id::bigint
        AS target_away_team_id

FROM public.match_provider_map identity

JOIN public.matches previous_match
  ON previous_match.id =
     (identity.metadata ->> 'previous_match_id')::integer

JOIN public.matches target_match
  ON target_match.id =
     (identity.metadata ->> 'target_match_id')::integer

WHERE identity.metadata ->> 'belgium_identity_transfer'
      = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1';

CREATE UNIQUE INDEX mm_be_downstream_plan_previous_uq
    ON mm_be_downstream_transfer_plan(previous_match_id);

CREATE UNIQUE INDEX mm_be_downstream_plan_target_uq
    ON mm_be_downstream_transfer_plan(target_match_id);

-------------------------------------------------------------------------------
-- 5. VÝCHOZÍ STAV
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_downstream_baseline
ON COMMIT DROP
AS
SELECT
    (
        SELECT COUNT(*)
        FROM public.match_features
    ) AS features_total_rows,

    (
        SELECT COUNT(DISTINCT match_id)
        FROM public.match_features
    ) AS features_distinct_matches,

    (
        SELECT COUNT(*)
        FROM public.match_features features
        LEFT JOIN public.matches match
          ON match.id = features.match_id
        WHERE match.id IS NULL
    ) AS features_orphan_rows,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings
    ) AS ratings_total_rows,

    (
        SELECT COUNT(DISTINCT match_id)
        FROM public.mm_match_ratings
    ) AS ratings_distinct_matches,

    (
        SELECT COUNT(*)
        FROM public.mm_match_ratings ratings
        LEFT JOIN public.matches match
          ON match.id = ratings.match_id
        WHERE match.id IS NULL
    ) AS ratings_orphan_rows;

-------------------------------------------------------------------------------
-- 6. SNAPSHOT PŘENÁŠENÝCH HODNOT
-------------------------------------------------------------------------------

CREATE TEMP TABLE mm_be_feature_payload_snapshot
ON COMMIT DROP
AS
SELECT
    plan.previous_match_id,
    plan.target_match_id,

    to_jsonb(features)
        - ARRAY[
            'match_id',
            'updated_at'
          ]::text[] AS preserved_payload

FROM mm_be_downstream_transfer_plan plan

JOIN public.match_features features
  ON features.match_id = plan.previous_match_id;

CREATE TEMP TABLE mm_be_rating_payload_snapshot
ON COMMIT DROP
AS
SELECT
    plan.previous_match_id,
    plan.target_match_id,

    to_jsonb(ratings)
        - ARRAY[
            'match_id',
            'league_id',
            'kickoff',
            'home_team_id',
            'away_team_id'
          ]::text[] AS preserved_payload

FROM mm_be_downstream_transfer_plan plan

JOIN public.mm_match_ratings ratings
  ON ratings.match_id = plan.previous_match_id;

-------------------------------------------------------------------------------
-- 7. POVINNÉ KONTROLY PŘED APPLY
-------------------------------------------------------------------------------

DO $precheck$
DECLARE
    v_plan_rows bigint;
    v_previous_ids bigint;
    v_target_ids bigint;

    v_features_previous bigint;
    v_features_target bigint;

    v_ratings_previous bigint;
    v_ratings_target bigint;
    v_ratings_consistent bigint;

    v_feature_snapshot_rows bigint;
    v_rating_snapshot_rows bigint;

    v_null_target_dimensions bigint;
    v_provider_transfer_rows bigint;
BEGIN
    SELECT
        COUNT(*),
        COUNT(DISTINCT previous_match_id),
        COUNT(DISTINCT target_match_id),

        COUNT(*) FILTER (
            WHERE target_league_id IS NULL
               OR target_kickoff IS NULL
               OR target_home_team_id IS NULL
               OR target_away_team_id IS NULL
        )
    INTO
        v_plan_rows,
        v_previous_ids,
        v_target_ids,
        v_null_target_dimensions
    FROM mm_be_downstream_transfer_plan;

    SELECT COUNT(*)
    INTO v_features_previous
    FROM public.match_features features
    JOIN mm_be_downstream_transfer_plan plan
      ON features.match_id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_features_target
    FROM public.match_features features
    JOIN mm_be_downstream_transfer_plan plan
      ON features.match_id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_ratings_previous
    FROM public.mm_match_ratings ratings
    JOIN mm_be_downstream_transfer_plan plan
      ON ratings.match_id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_ratings_target
    FROM public.mm_match_ratings ratings
    JOIN mm_be_downstream_transfer_plan plan
      ON ratings.match_id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_ratings_consistent
    FROM public.mm_match_ratings ratings
    JOIN mm_be_downstream_transfer_plan plan
      ON ratings.match_id = plan.previous_match_id
    WHERE ratings.league_id =
              plan.previous_league_id
      AND ratings.kickoff =
              plan.previous_kickoff
      AND ratings.home_team_id =
              plan.previous_home_team_id
      AND ratings.away_team_id =
              plan.previous_away_team_id;

    SELECT COUNT(*)
    INTO v_feature_snapshot_rows
    FROM mm_be_feature_payload_snapshot;

    SELECT COUNT(*)
    INTO v_rating_snapshot_rows
    FROM mm_be_rating_payload_snapshot;

    SELECT COUNT(*)
    INTO v_provider_transfer_rows
    FROM public.match_provider_map
    WHERE metadata ->> 'belgium_identity_transfer'
          = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1';

    IF v_plan_rows <> 927
       OR v_previous_ids <> 927
       OR v_target_ids <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: plán %, previous %, target %.',
            v_plan_rows,
            v_previous_ids,
            v_target_ids;
    END IF;

    IF v_null_target_dimensions <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: % cílových zápasů nemá úplné dimenze.',
            v_null_target_dimensions;
    END IF;

    IF v_features_previous <> 927
       OR v_features_target <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: match_features previous %, target %.',
            v_features_previous,
            v_features_target;
    END IF;

    IF v_ratings_previous <> 927
       OR v_ratings_target <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: mm_match_ratings previous %, target %.',
            v_ratings_previous,
            v_ratings_target;
    END IF;

    IF v_ratings_consistent <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: S původními zápasy je konzistentních pouze % ratingů.',
            v_ratings_consistent;
    END IF;

    IF v_feature_snapshot_rows <> 927
       OR v_rating_snapshot_rows <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: snapshot features %, ratings %.',
            v_feature_snapshot_rows,
            v_rating_snapshot_rows;
    END IF;

    IF v_provider_transfer_rows <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Providerový převod obsahuje % identit místo 927.',
            v_provider_transfer_rows;
    END IF;

    RAISE NOTICE
        'OK PRECHECK: plán 927, features 927/0, ratings 927/0, dimenze 927, providerové identity 927.';
END
$precheck$;

-------------------------------------------------------------------------------
-- 8. APPLY public.match_features
-------------------------------------------------------------------------------

DO $apply_features$
DECLARE
    v_updated_rows bigint;
BEGIN
    UPDATE public.match_features features
    SET
        match_id = plan.target_match_id,
        updated_at = clock_timestamp()

    FROM mm_be_downstream_transfer_plan plan

    WHERE features.match_id = plan.previous_match_id;

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: match_features převedeno % místo 927.',
            v_updated_rows;
    END IF;

    RAISE NOTICE
        'OK FEATURES APPLY: Trvale připraveno 927 řádků.';
END
$apply_features$;

-------------------------------------------------------------------------------
-- 9. APPLY public.mm_match_ratings
-------------------------------------------------------------------------------

DO $apply_ratings$
DECLARE
    v_updated_rows bigint;
BEGIN
    UPDATE public.mm_match_ratings ratings
    SET
        match_id = plan.target_match_id,
        league_id = plan.target_league_id,
        kickoff = plan.target_kickoff,
        home_team_id = plan.target_home_team_id,
        away_team_id = plan.target_away_team_id

    FROM mm_be_downstream_transfer_plan plan

    WHERE ratings.match_id = plan.previous_match_id;

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: mm_match_ratings převedeno % místo 927.',
            v_updated_rows;
    END IF;

    RAISE NOTICE
        'OK RATINGS APPLY: Trvale připraveno a sjednoceno 927 řádků.';
END
$apply_ratings$;

-------------------------------------------------------------------------------
-- 10. ÚPLNÁ KONTROLA PŘED COMMIT
-------------------------------------------------------------------------------

DO $postcheck$
DECLARE
    v_features_previous bigint;
    v_features_target bigint;

    v_ratings_previous bigint;
    v_ratings_target bigint;
    v_ratings_aligned bigint;

    v_feature_payload_mismatches bigint;
    v_rating_payload_mismatches bigint;

    v_features_total bigint;
    v_features_distinct bigint;
    v_features_orphans bigint;

    v_ratings_total bigint;
    v_ratings_distinct bigint;
    v_ratings_orphans bigint;

    v_baseline_features_total bigint;
    v_baseline_features_distinct bigint;
    v_baseline_features_orphans bigint;

    v_baseline_ratings_total bigint;
    v_baseline_ratings_distinct bigint;
    v_baseline_ratings_orphans bigint;

    v_provider_transfer_rows bigint;
BEGIN
    SELECT
        features_total_rows,
        features_distinct_matches,
        features_orphan_rows,
        ratings_total_rows,
        ratings_distinct_matches,
        ratings_orphan_rows
    INTO
        v_baseline_features_total,
        v_baseline_features_distinct,
        v_baseline_features_orphans,
        v_baseline_ratings_total,
        v_baseline_ratings_distinct,
        v_baseline_ratings_orphans
    FROM mm_be_downstream_baseline;

    SELECT COUNT(*)
    INTO v_features_previous
    FROM public.match_features features
    JOIN mm_be_downstream_transfer_plan plan
      ON features.match_id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_features_target
    FROM public.match_features features
    JOIN mm_be_downstream_transfer_plan plan
      ON features.match_id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_ratings_previous
    FROM public.mm_match_ratings ratings
    JOIN mm_be_downstream_transfer_plan plan
      ON ratings.match_id = plan.previous_match_id;

    SELECT COUNT(*)
    INTO v_ratings_target
    FROM public.mm_match_ratings ratings
    JOIN mm_be_downstream_transfer_plan plan
      ON ratings.match_id = plan.target_match_id;

    SELECT COUNT(*)
    INTO v_ratings_aligned
    FROM public.mm_match_ratings ratings
    JOIN mm_be_downstream_transfer_plan plan
      ON ratings.match_id = plan.target_match_id
    WHERE ratings.league_id =
              plan.target_league_id
      AND ratings.kickoff =
              plan.target_kickoff
      AND ratings.home_team_id =
              plan.target_home_team_id
      AND ratings.away_team_id =
              plan.target_away_team_id;

    SELECT COUNT(*)
    INTO v_feature_payload_mismatches
    FROM mm_be_feature_payload_snapshot snapshot
    JOIN public.match_features features
      ON features.match_id = snapshot.target_match_id
    WHERE (
        to_jsonb(features)
            - ARRAY[
                'match_id',
                'updated_at'
              ]::text[]
    ) IS DISTINCT FROM snapshot.preserved_payload;

    SELECT COUNT(*)
    INTO v_rating_payload_mismatches
    FROM mm_be_rating_payload_snapshot snapshot
    JOIN public.mm_match_ratings ratings
      ON ratings.match_id = snapshot.target_match_id
    WHERE (
        to_jsonb(ratings)
            - ARRAY[
                'match_id',
                'league_id',
                'kickoff',
                'home_team_id',
                'away_team_id'
              ]::text[]
    ) IS DISTINCT FROM snapshot.preserved_payload;

    SELECT
        COUNT(*),
        COUNT(DISTINCT match_id)
    INTO
        v_features_total,
        v_features_distinct
    FROM public.match_features;

    SELECT COUNT(*)
    INTO v_features_orphans
    FROM public.match_features features
    LEFT JOIN public.matches match
      ON match.id = features.match_id
    WHERE match.id IS NULL;

    SELECT
        COUNT(*),
        COUNT(DISTINCT match_id)
    INTO
        v_ratings_total,
        v_ratings_distinct
    FROM public.mm_match_ratings;

    SELECT COUNT(*)
    INTO v_ratings_orphans
    FROM public.mm_match_ratings ratings
    LEFT JOIN public.matches match
      ON match.id = ratings.match_id
    WHERE match.id IS NULL;

    SELECT COUNT(*)
    INTO v_provider_transfer_rows
    FROM public.match_provider_map
    WHERE metadata ->> 'belgium_identity_transfer'
          = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1';

    IF v_features_previous <> 0
       OR v_features_target <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: features previous %, target %.',
            v_features_previous,
            v_features_target;
    END IF;

    IF v_ratings_previous <> 0
       OR v_ratings_target <> 927
       OR v_ratings_aligned <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: ratings previous %, target %, aligned %.',
            v_ratings_previous,
            v_ratings_target,
            v_ratings_aligned;
    END IF;

    IF v_feature_payload_mismatches <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Změněno % feature payloadů.',
            v_feature_payload_mismatches;
    END IF;

    IF v_rating_payload_mismatches <> 0 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Změněno % ratingových payloadů.',
            v_rating_payload_mismatches;
    END IF;

    IF v_features_total <> v_baseline_features_total
       OR v_features_distinct <> v_baseline_features_distinct
       OR v_features_orphans <> v_baseline_features_orphans THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Změněn souhrn match_features.';
    END IF;

    IF v_ratings_total <> v_baseline_ratings_total
       OR v_ratings_distinct <> v_baseline_ratings_distinct
       OR v_ratings_orphans <> v_baseline_ratings_orphans THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Změněn souhrn mm_match_ratings.';
    END IF;

    IF v_provider_transfer_rows <> 927 THEN
        RAISE EXCEPTION
            'APPLY_FAILED: Providerová mapa změnila stav.';
    END IF;

    RAISE NOTICE
        'OK POSTCHECK: features 927, ratings 927, dimenze 927, payloady beze změny, počty a orphan stav zachovány.';
END
$postcheck$;

-------------------------------------------------------------------------------
-- 11. SOUHRN PŘED COMMIT
-------------------------------------------------------------------------------

SELECT
    'MATCH_FEATURES_ON_PREVIOUS' AS check_name,
    COUNT(*)::text AS result
FROM public.match_features features
JOIN mm_be_downstream_transfer_plan plan
  ON features.match_id = plan.previous_match_id

UNION ALL

SELECT
    'MATCH_FEATURES_ON_TARGET',
    COUNT(*)::text
FROM public.match_features features
JOIN mm_be_downstream_transfer_plan plan
  ON features.match_id = plan.target_match_id

UNION ALL

SELECT
    'MATCH_RATINGS_ON_PREVIOUS',
    COUNT(*)::text
FROM public.mm_match_ratings ratings
JOIN mm_be_downstream_transfer_plan plan
  ON ratings.match_id = plan.previous_match_id

UNION ALL

SELECT
    'MATCH_RATINGS_ON_TARGET',
    COUNT(*)::text
FROM public.mm_match_ratings ratings
JOIN mm_be_downstream_transfer_plan plan
  ON ratings.match_id = plan.target_match_id

UNION ALL

SELECT
    'MATCH_RATINGS_TARGET_DIMENSIONS_ALIGNED',
    COUNT(*)::text
FROM public.mm_match_ratings ratings
JOIN mm_be_downstream_transfer_plan plan
  ON ratings.match_id = plan.target_match_id
WHERE ratings.league_id = plan.target_league_id
  AND ratings.kickoff = plan.target_kickoff
  AND ratings.home_team_id = plan.target_home_team_id
  AND ratings.away_team_id = plan.target_away_team_id;

SELECT
    'APPLY_VALIDATED – 927 DOWNSTREAM VAZEB V OBOU TABULKÁCH PŘIPRAVENO K COMMIT'
        AS pre_commit_status;

-------------------------------------------------------------------------------
-- 12. TRVALÉ ULOŽENÍ
-------------------------------------------------------------------------------

COMMIT;

-------------------------------------------------------------------------------
-- 13. AKTUALIZACE STATISTIK
-------------------------------------------------------------------------------

ANALYZE public.match_features;
ANALYZE public.mm_match_ratings;

-------------------------------------------------------------------------------
-- 14. KONEČNÝ POST-COMMIT AUDIT
-------------------------------------------------------------------------------

WITH transfer_plan AS
(
    SELECT DISTINCT
        (metadata ->> 'previous_match_id')::bigint
            AS previous_match_id,

        (metadata ->> 'target_match_id')::bigint
            AS target_match_id

    FROM public.match_provider_map

    WHERE metadata ->> 'belgium_identity_transfer'
          = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'
),
counts AS
(
    SELECT
        (
            SELECT COUNT(*)
            FROM public.match_features features
            JOIN transfer_plan plan
              ON features.match_id = plan.previous_match_id
        ) AS features_previous,

        (
            SELECT COUNT(*)
            FROM public.match_features features
            JOIN transfer_plan plan
              ON features.match_id = plan.target_match_id
        ) AS features_target,

        (
            SELECT COUNT(*)
            FROM public.mm_match_ratings ratings
            JOIN transfer_plan plan
              ON ratings.match_id = plan.previous_match_id
        ) AS ratings_previous,

        (
            SELECT COUNT(*)
            FROM public.mm_match_ratings ratings
            JOIN transfer_plan plan
              ON ratings.match_id = plan.target_match_id
        ) AS ratings_target,

        (
            SELECT COUNT(*)
            FROM public.mm_match_ratings ratings
            JOIN transfer_plan plan
              ON ratings.match_id = plan.target_match_id
            JOIN public.matches target_match
              ON target_match.id = plan.target_match_id
            WHERE ratings.league_id = target_match.league_id
              AND ratings.kickoff = target_match.kickoff
              AND ratings.home_team_id = target_match.home_team_id
              AND ratings.away_team_id = target_match.away_team_id
        ) AS ratings_aligned
)
SELECT
    CASE
        WHEN features_previous = 0
         AND features_target = 927
         AND ratings_previous = 0
         AND ratings_target = 927
         AND ratings_aligned = 927
        THEN
            'APPLY_OK – 927 DOWNSTREAM VAZEB TRVALE PŘEVEDENO'
        ELSE
            'APPLY_POST_COMMIT_WARNING – KONTROLNÍ POČTY SE NESHODUJÍ'
    END AS final_status,

    features_previous,
    features_target,
    ratings_previous,
    ratings_target,
    ratings_aligned

FROM counts;

-------------------------------------------------------------------------------
-- 15. CELKOVÉ POČTY TABULEK
-------------------------------------------------------------------------------

SELECT
    'public.match_features' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT match_id) AS distinct_match_ids,
    COUNT(*) FILTER (
        WHERE match.id IS NULL
    ) AS orphan_rows

FROM public.match_features child

LEFT JOIN public.matches match
  ON match.id = child.match_id

UNION ALL

SELECT
    'public.mm_match_ratings',
    COUNT(*),
    COUNT(DISTINCT child.match_id),
    COUNT(*) FILTER (
        WHERE match.id IS NULL
    )

FROM public.mm_match_ratings child

LEFT JOIN public.matches match
  ON match.id = child.match_id;