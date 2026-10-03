/*
CO:
STEP 9D – HB FIXTURES HISTORICAL QUALITY + REPLAY CANDIDATE AUDIT

K ČEMU:
1. Prověřit 110 historických zápasů stále označených SCHEDULED.
2. Ověřit duplicity provider match IDs.
3. Změřit kvalitu historických dat po ligách.
4. Najít konkrétní ligu vhodnou pro následný řízený runtime replay test.
5. Zjistit mapování public league_id -> api_handball provider league ID.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. PAST-SCHEDULED – SOUHRN
   ========================================================= */

WITH hb_match_ids AS (
    SELECT DISTINCT match_id
    FROM public.match_provider_map
    WHERE provider = 'api_handball'
      AND mapping_status = 'ACTIVE'
),
hb AS (
    SELECT m.*
    FROM public.matches m
    JOIN hb_match_ids x
      ON x.match_id = m.id
)
SELECT
    COUNT(*) AS past_scheduled_total,

    COUNT(*) FILTER (
        WHERE home_score IS NULL
          AND away_score IS NULL
    ) AS without_scores,

    COUNT(*) FILTER (
        WHERE home_score IS NOT NULL
           OR away_score IS NOT NULL
    ) AS with_any_score,

    MIN(kickoff) AS oldest_past_scheduled,
    MAX(kickoff) AS newest_past_scheduled,

    MIN(updated_at) AS oldest_updated_at,
    MAX(updated_at) AS newest_updated_at
FROM hb
WHERE status = 'SCHEDULED'
  AND kickoff < CURRENT_TIMESTAMP::timestamp;


/* =========================================================
   2. PAST-SCHEDULED – DISTRIBUCE PODLE LIGY
   ========================================================= */

WITH hb_match_ids AS (
    SELECT DISTINCT match_id
    FROM public.match_provider_map
    WHERE provider = 'api_handball'
      AND mapping_status = 'ACTIVE'
),
hb AS (
    SELECT m.*
    FROM public.matches m
    JOIN hb_match_ids x
      ON x.match_id = m.id
)
SELECT
    league_id,
    COUNT(*) AS scheduled_rows,
    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff
FROM hb
WHERE status = 'SCHEDULED'
  AND kickoff < CURRENT_TIMESTAMP::timestamp
GROUP BY league_id
ORDER BY scheduled_rows DESC, league_id;


/* =========================================================
   3. PAST-SCHEDULED – UKÁZKA
   ========================================================= */

WITH hb_match_ids AS (
    SELECT DISTINCT match_id
    FROM public.match_provider_map
    WHERE provider = 'api_handball'
      AND mapping_status = 'ACTIVE'
)
SELECT
    m.id,
    m.league_id,
    m.season,
    m.kickoff,
    m.status,
    m.home_score,
    m.away_score,
    m.ext_source,
    m.ext_match_id,
    m.updated_at
FROM public.matches m
JOIN hb_match_ids x
  ON x.match_id = m.id
WHERE m.status = 'SCHEDULED'
  AND m.kickoff < CURRENT_TIMESTAMP::timestamp
ORDER BY m.kickoff DESC, m.id
LIMIT 30;


/* =========================================================
   4. PROVIDER MATCH ID DUPLICITY
   ========================================================= */

SELECT
    provider_match_id,
    COUNT(*) AS map_rows,
    COUNT(DISTINCT match_id) AS distinct_matches
FROM public.match_provider_map
WHERE provider = 'api_handball'
  AND mapping_status = 'ACTIVE'
GROUP BY provider_match_id
HAVING COUNT(DISTINCT match_id) > 1
ORDER BY distinct_matches DESC, provider_match_id;


/* =========================================================
   5. KVALITA HISTORICKÝCH DAT PODLE LIGY
   ========================================================= */

WITH hb_match_ids AS (
    SELECT DISTINCT match_id
    FROM public.match_provider_map
    WHERE provider = 'api_handball'
      AND mapping_status = 'ACTIVE'
),
hb AS (
    SELECT m.*
    FROM public.matches m
    JOIN hb_match_ids x
      ON x.match_id = m.id
)
SELECT
    league_id,

    COUNT(*) AS total_matches,

    COUNT(*) FILTER (
        WHERE status = 'FINISHED'
    ) AS finished,

    COUNT(*) FILTER (
        WHERE status = 'FINISHED'
          AND home_score IS NOT NULL
          AND away_score IS NOT NULL
    ) AS finished_with_score,

    COUNT(*) FILTER (
        WHERE status = 'SCHEDULED'
    ) AS scheduled,

    COUNT(*) FILTER (
        WHERE status = 'CANCELLED'
    ) AS cancelled,

    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff

FROM hb
GROUP BY league_id
ORDER BY
    finished_with_score DESC,
    total_matches DESC,
    league_id;


/* =========================================================
   6. STRUKTURA LEAGUE_PROVIDER_MAP
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'league_provider_map'
ORDER BY ordinal_position;


/* =========================================================
   7. API_HANDBALL LEAGUE MAP – UKÁZKA
   ========================================================= */

SELECT
    to_jsonb(lpm) AS league_map
FROM public.league_provider_map lpm
WHERE to_jsonb(lpm)::text ILIKE '%api_handball%'
LIMIT 30;


/* =========================================================
   8. POČET API_HANDBALL LEAGUE MAP ŘÁDKŮ
   ========================================================= */

SELECT
    COUNT(*) AS api_handball_league_map_rows
FROM public.league_provider_map lpm
WHERE to_jsonb(lpm)::text ILIKE '%api_handball%';