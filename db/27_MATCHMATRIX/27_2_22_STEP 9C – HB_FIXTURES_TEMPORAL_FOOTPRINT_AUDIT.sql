/*
CO:
STEP 9C – HB FIXTURES TEMPORAL FOOTPRINT AUDIT

K ČEMU:
Zjistit přesný aktuální časový rozsah, statusy a kvalitu
API-Sports / api_handball / HB fixtures v public vrstvě.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
Bez INSERT / UPDATE / DELETE / DDL.
*/


/* =========================================================
   1. REFERENČNÍ ČAS DATABÁZE
   ========================================================= */

SELECT
    CURRENT_DATE AS db_current_date,
    CURRENT_TIMESTAMP AS db_current_timestamp;


/* =========================================================
   2. DEFINICE HB MATCH SETU

   Používáme match_provider_map jako provider identity důkaz.
   DISTINCT match_id chrání proti případným více map řádkům.
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
    COUNT(*) AS total_matches,
    MIN(kickoff) AS oldest_kickoff,
    MAX(kickoff) AS newest_kickoff,
    MIN(updated_at) AS oldest_updated_at,
    MAX(updated_at) AS newest_updated_at,
    COUNT(DISTINCT season) AS distinct_seasons,
    COUNT(DISTINCT league_id) AS distinct_leagues
FROM hb;


/* =========================================================
   3. STATUS DISTRIBUCE
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
    status,
    COUNT(*) AS matches,
    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff
FROM hb
GROUP BY status
ORDER BY matches DESC, status;


/* =========================================================
   4. ČASOVÉ BUCKETY PODLE KICKOFF

   Zatím je NEPOVAŽUJEME za canonical time_mode.
   Je to pouze faktický časový profil dat.
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
    COUNT(*) FILTER (
        WHERE kickoff < CURRENT_DATE
    ) AS before_today,

    COUNT(*) FILTER (
        WHERE kickoff >= CURRENT_DATE
          AND kickoff < CURRENT_DATE + INTERVAL '1 day'
    ) AS today,

    COUNT(*) FILTER (
        WHERE kickoff >= CURRENT_DATE + INTERVAL '1 day'
    ) AS after_today,

    COUNT(*) FILTER (
        WHERE kickoff < CURRENT_TIMESTAMP::timestamp
    ) AS before_now,

    COUNT(*) FILTER (
        WHERE kickoff >= CURRENT_TIMESTAMP::timestamp
    ) AS now_or_future
FROM hb;


/* =========================================================
   5. LIVE KANDIDÁTI

   Nic zde neprohlašujeme za potvrzené LIVE.
   Jen zjišťujeme, zda DB obsahuje runtime znaky LIVE stavu.
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
    status,
    COUNT(*) AS rows_count,
    MIN(live_minute) AS min_live_minute,
    MAX(live_minute) AS max_live_minute
FROM hb
WHERE live_minute IS NOT NULL
   OR status ILIKE '%live%'
   OR status ILIKE '%progress%'
   OR status ILIKE '%half%'
GROUP BY status
ORDER BY rows_count DESC, status;


/* =========================================================
   6. FINISHED – KVALITA VÝSLEDKŮ

   Ověříme, kolik historických finished zápasů skutečně
   obsahuje oba konečné výsledky.
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
    COUNT(*) FILTER (
        WHERE status = 'FINISHED'
    ) AS finished_total,

    COUNT(*) FILTER (
        WHERE status = 'FINISHED'
          AND home_score IS NOT NULL
          AND away_score IS NOT NULL
    ) AS finished_with_score,

    COUNT(*) FILTER (
        WHERE status = 'FINISHED'
          AND (
              home_score IS NULL
              OR away_score IS NULL
          )
    ) AS finished_missing_score
FROM hb;


/* =========================================================
   7. SEASON DISTRIBUCE
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
    season,
    COUNT(*) AS matches,
    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff
FROM hb
GROUP BY season
ORDER BY first_kickoff, season;


/* =========================================================
   8. NEJSTARŠÍ HB ZÁPASY
   ========================================================= */

WITH hb_match_ids AS (
    SELECT DISTINCT match_id
    FROM public.match_provider_map
    WHERE provider = 'api_handball'
      AND mapping_status = 'ACTIVE'
)
SELECT
    m.id,
    m.season,
    m.league_id,
    m.kickoff,
    m.status,
    m.home_score,
    m.away_score,
    m.ext_source,
    m.ext_match_id
FROM public.matches m
JOIN hb_match_ids x
  ON x.match_id = m.id
ORDER BY m.kickoff, m.id
LIMIT 10;


/* =========================================================
   9. NEJNOVĚJŠÍ HB ZÁPASY
   ========================================================= */

WITH hb_match_ids AS (
    SELECT DISTINCT match_id
    FROM public.match_provider_map
    WHERE provider = 'api_handball'
      AND mapping_status = 'ACTIVE'
)
SELECT
    m.id,
    m.season,
    m.league_id,
    m.kickoff,
    m.status,
    m.home_score,
    m.away_score,
    m.ext_source,
    m.ext_match_id
FROM public.matches m
JOIN hb_match_ids x
  ON x.match_id = m.id
ORDER BY m.kickoff DESC, m.id DESC
LIMIT 10;


/* =========================================================
   10. PROVIDER MAP RECENCY

   Zjistíme, kdy byl api_handball provider map naposledy
   skutečně viděn / aktualizován.
   ========================================================= */

SELECT
    COUNT(*) AS mapping_rows,
    MIN(first_seen_at) AS first_mapping_seen,
    MAX(first_seen_at) AS last_mapping_first_seen,
    MAX(last_seen_at) AS latest_mapping_last_seen,
    MAX(updated_at) AS latest_mapping_updated_at
FROM public.match_provider_map
WHERE provider = 'api_handball'
  AND mapping_status = 'ACTIVE';