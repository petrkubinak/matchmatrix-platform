/*
CO:
STEP 10J – HB TARGET UNIVERSE × HISTORICAL FOOTPRINT RECONCILIATION

K ČEMU:
Porovnat 211 enabled HB ingest targetů proti skutečně uloženým
historickým api_handball datům.

CÍL:
Rozdělit targety na:
- HAS_CLEAN_HISTORY
- HAS_EXCEPTION_HISTORY
- NO_HISTORY_DATA

Současně ověřit:
- canonical league mapování,
- provider league mapování,
- tier rozložení,
- zda existují data mimo target universe.

DŮLEŽITÉ:
ops.ingest_targets je zde pouze OPERATIONAL TARGET SET.
Nevytváříme z něj canonical coverage truth.

JAK:
Pouze SELECT.
*/


WITH targets AS
(
    SELECT
        t.id AS ingest_target_id,
        t.sport_code,
        t.canonical_league_id,
        t.provider,
        t.provider_league_id,
        t.season,
        t.enabled,
        t.tier,
        t.run_group,
        t.fixtures_days_back,
        t.fixtures_days_forward,
        t.notes
    FROM ops.ingest_targets t
    WHERE t.provider = 'api_handball'
      AND t.sport_code = 'HB'
      AND t.season = '2024'
      AND t.enabled = true
),

history AS
(
    SELECT
        m.league_id AS canonical_league_id,
        lpm.provider_league_id::text AS provider_league_id,
        m.season::text AS season,

        COUNT(DISTINCT m.id) AS matches,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
        ) AS finished,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
              AND m.home_score IS NOT NULL
              AND m.away_score IS NOT NULL
        ) AS finished_with_score,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'SCHEDULED'
        ) AS scheduled,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'CANCELLED'
        ) AS cancelled,

        MIN(m.kickoff) AS first_kickoff,
        MAX(m.kickoff) AS last_kickoff

    FROM public.matches m

    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'

    LEFT JOIN public.league_provider_map lpm
      ON lpm.league_id = m.league_id
     AND lpm.provider = 'api_handball'

    WHERE m.kickoff < CURRENT_DATE

    GROUP BY
        m.league_id,
        lpm.provider_league_id::text,
        m.season::text
),

joined AS
(
    SELECT
        t.*,

        h.matches,
        h.finished,
        h.finished_with_score,
        h.scheduled,
        h.cancelled,
        h.first_kickoff,
        h.last_kickoff,

        CASE
            WHEN h.matches IS NULL
                THEN 'NO_HISTORY_DATA'

            WHEN h.finished = h.matches
             AND h.finished_with_score = h.matches
             AND h.scheduled = 0
             AND h.cancelled = 0
                THEN 'HAS_CLEAN_HISTORY'

            ELSE 'HAS_EXCEPTION_HISTORY'
        END AS history_state

    FROM targets t

    LEFT JOIN history h
      ON h.canonical_league_id = t.canonical_league_id
     AND h.provider_league_id = t.provider_league_id
     AND h.season = t.season
)


/* =========================================================
   1. HLAVNÍ SOUHRN
   ========================================================= */

SELECT
    COUNT(*) AS enabled_targets,

    COUNT(*) FILTER (
        WHERE history_state = 'HAS_CLEAN_HISTORY'
    ) AS targets_with_clean_history,

    COUNT(*) FILTER (
        WHERE history_state = 'HAS_EXCEPTION_HISTORY'
    ) AS targets_with_exception_history,

    COUNT(*) FILTER (
        WHERE history_state = 'NO_HISTORY_DATA'
    ) AS targets_without_history,

    COALESCE(SUM(matches), 0) AS stored_matches

FROM joined;


/* =========================================================
   2. SOUHRN PODLE TIER
   ========================================================= */

WITH targets AS
(
    SELECT *
    FROM ops.ingest_targets
    WHERE provider = 'api_handball'
      AND sport_code = 'HB'
      AND season = '2024'
      AND enabled = true
),

history AS
(
    SELECT
        m.league_id,
        lpm.provider_league_id::text AS provider_league_id,
        m.season::text AS season,

        COUNT(DISTINCT m.id) AS matches,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
        ) AS finished,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
              AND m.home_score IS NOT NULL
              AND m.away_score IS NOT NULL
        ) AS finished_with_score,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'SCHEDULED'
        ) AS scheduled,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'CANCELLED'
        ) AS cancelled

    FROM public.matches m

    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'

    LEFT JOIN public.league_provider_map lpm
      ON lpm.league_id = m.league_id
     AND lpm.provider = 'api_handball'

    WHERE m.kickoff < CURRENT_DATE

    GROUP BY
        m.league_id,
        lpm.provider_league_id::text,
        m.season::text
)

SELECT
    t.tier,

    COUNT(*) AS targets,

    COUNT(*) FILTER (
        WHERE h.matches IS NOT NULL
    ) AS targets_with_history,

    COUNT(*) FILTER (
        WHERE h.matches IS NULL
    ) AS targets_without_history,

    COALESCE(SUM(h.matches), 0) AS stored_matches

FROM targets t

LEFT JOIN history h
  ON h.league_id = t.canonical_league_id
 AND h.provider_league_id = t.provider_league_id
 AND h.season = t.season

GROUP BY
    t.tier

ORDER BY
    t.tier;


/* =========================================================
   3. TARGETY BEZ HISTORICKÝCH DAT
   ========================================================= */

WITH targets AS
(
    SELECT
        t.id AS ingest_target_id,
        t.sport_code,
        t.canonical_league_id,
        t.provider,
        t.provider_league_id,
        t.season,
        t.enabled,
        t.tier,
        t.run_group,
        t.fixtures_days_back,
        t.fixtures_days_forward,
        t.notes
    FROM ops.ingest_targets t
    WHERE t.provider = 'api_handball'
      AND t.sport_code = 'HB'
      AND t.season = '2024'
      AND t.enabled = true
),

history AS
(
    SELECT
        m.league_id AS canonical_league_id,
        lpm.provider_league_id::text AS provider_league_id,
        m.season::text AS season,

        COUNT(DISTINCT m.id) AS matches,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
        ) AS finished,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
              AND m.home_score IS NOT NULL
              AND m.away_score IS NOT NULL
        ) AS finished_with_score,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'SCHEDULED'
        ) AS scheduled,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'CANCELLED'
        ) AS cancelled,

        MIN(m.kickoff) AS first_kickoff,
        MAX(m.kickoff) AS last_kickoff

    FROM public.matches m

    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'

    LEFT JOIN public.league_provider_map lpm
      ON lpm.league_id = m.league_id
     AND lpm.provider = 'api_handball'

    WHERE m.kickoff < CURRENT_DATE

    GROUP BY
        m.league_id,
        lpm.provider_league_id::text,
        m.season::text
),

joined AS
(
    SELECT
        t.*,

        h.matches,
        h.finished,
        h.finished_with_score,
        h.scheduled,
        h.cancelled,
        h.first_kickoff,
        h.last_kickoff,

        CASE
            WHEN h.matches IS NULL
                THEN 'NO_HISTORY_DATA'

            WHEN h.finished = h.matches
             AND h.finished_with_score = h.matches
             AND h.scheduled = 0
             AND h.cancelled = 0
                THEN 'HAS_CLEAN_HISTORY'

            ELSE 'HAS_EXCEPTION_HISTORY'
        END AS history_state

    FROM targets t

    LEFT JOIN history h
      ON h.canonical_league_id = t.canonical_league_id
     AND h.provider_league_id = t.provider_league_id::text
     AND h.season = t.season::text
)

SELECT
    ingest_target_id,
    tier,
    canonical_league_id,
    provider_league_id,
    season,
    run_group,
    notes

FROM joined

WHERE history_state = 'NO_HISTORY_DATA'

ORDER BY
    tier,
    provider_league_id::integer;


/* =========================================================
   4. TARGETY S HISTORICKOU VÝJIMKOU
   ========================================================= */

WITH targets AS
(
    SELECT
        t.id AS ingest_target_id,
        t.sport_code,
        t.canonical_league_id,
        t.provider,
        t.provider_league_id,
        t.season,
        t.enabled,
        t.tier,
        t.run_group,
        t.fixtures_days_back,
        t.fixtures_days_forward,
        t.notes
    FROM ops.ingest_targets t
    WHERE t.provider = 'api_handball'
      AND t.sport_code = 'HB'
      AND t.season = '2024'
      AND t.enabled = true
),

history AS
(
    SELECT
        m.league_id AS canonical_league_id,
        lpm.provider_league_id::text AS provider_league_id,
        m.season::text AS season,

        COUNT(DISTINCT m.id) AS matches,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
        ) AS finished,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
              AND m.home_score IS NOT NULL
              AND m.away_score IS NOT NULL
        ) AS finished_with_score,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'SCHEDULED'
        ) AS scheduled,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'CANCELLED'
        ) AS cancelled,

        MIN(m.kickoff) AS first_kickoff,
        MAX(m.kickoff) AS last_kickoff

    FROM public.matches m

    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'

    LEFT JOIN public.league_provider_map lpm
      ON lpm.league_id = m.league_id
     AND lpm.provider = 'api_handball'

    WHERE m.kickoff < CURRENT_DATE

    GROUP BY
        m.league_id,
        lpm.provider_league_id::text,
        m.season::text
),

joined AS
(
    SELECT
        t.*,

        h.matches,
        h.finished,
        h.finished_with_score,
        h.scheduled,
        h.cancelled,
        h.first_kickoff,
        h.last_kickoff,

        CASE
            WHEN h.matches IS NULL
                THEN 'NO_HISTORY_DATA'

            WHEN h.finished = h.matches
             AND h.finished_with_score = h.matches
             AND h.scheduled = 0
             AND h.cancelled = 0
                THEN 'HAS_CLEAN_HISTORY'

            ELSE 'HAS_EXCEPTION_HISTORY'
        END AS history_state

    FROM targets t

    LEFT JOIN history h
      ON h.canonical_league_id = t.canonical_league_id
     AND h.provider_league_id = t.provider_league_id::text
     AND h.season = t.season::text
)

SELECT
    ingest_target_id,
    tier,
    canonical_league_id,
    provider_league_id,
    season,

    matches,
    finished,
    finished_with_score,
    scheduled,
    cancelled,

    first_kickoff,
    last_kickoff,

    history_state

FROM joined

WHERE history_state = 'HAS_EXCEPTION_HISTORY'

ORDER BY
    scheduled DESC,
    cancelled DESC,
    matches DESC;


/* =========================================================
   5. HISTORICKÁ DATA MIMO ENABLED TARGET UNIVERSE
   ========================================================= */

WITH targets AS
(
    SELECT
        canonical_league_id,
        provider_league_id::text AS provider_league_id,
        season::text AS season

    FROM ops.ingest_targets

    WHERE provider = 'api_handball'
      AND sport_code = 'HB'
      AND season = '2024'
      AND enabled = true
),

history AS
(
    SELECT
        m.league_id AS canonical_league_id,
        lpm.provider_league_id::text AS provider_league_id,
        m.season::text AS season,

        COUNT(DISTINCT m.id) AS matches

    FROM public.matches m

    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'

    LEFT JOIN public.league_provider_map lpm
      ON lpm.league_id = m.league_id
     AND lpm.provider = 'api_handball'

    WHERE m.kickoff < CURRENT_DATE

    GROUP BY
        m.league_id,
        lpm.provider_league_id::text,
        m.season::text
)

SELECT
    h.*

FROM history h

LEFT JOIN targets t
  ON t.canonical_league_id = h.canonical_league_id
 AND t.provider_league_id = h.provider_league_id
 AND t.season = h.season

WHERE t.canonical_league_id IS NULL

ORDER BY
    h.matches DESC,
    h.canonical_league_id;


/* =========================================================
   6. TARGET MAP CONSISTENCY
   ========================================================= */

SELECT
    t.id AS ingest_target_id,
    t.canonical_league_id,
    t.provider_league_id,

    lpm.league_id AS mapped_canonical_league_id,
    lpm.provider_league_id AS mapped_provider_league_id,

    CASE
        WHEN lpm.league_id IS NULL
            THEN 'NO_PROVIDER_MAP'

        WHEN lpm.league_id <> t.canonical_league_id
            THEN 'CANONICAL_MISMATCH'

        WHEN lpm.provider_league_id::text
             <> t.provider_league_id::text
            THEN 'PROVIDER_ID_MISMATCH'

        ELSE 'PASS'
    END AS map_status

FROM ops.ingest_targets t

LEFT JOIN public.league_provider_map lpm
  ON lpm.provider = 'api_handball'
 AND lpm.provider_league_id::text
     = t.provider_league_id::text

WHERE t.provider = 'api_handball'
  AND t.sport_code = 'HB'
  AND t.season = '2024'
  AND t.enabled = true

ORDER BY
    map_status DESC,
    t.provider_league_id::integer;