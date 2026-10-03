/*
CO:
STEP 9E – HB HISTORICAL REPLAY CANDIDATE SELECTION

K ČEMU:
Najít nejlepší čistý historický scope pro řízený runtime replay test
API-Sports / api_handball / HB / fixtures.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
Nic se nestahuje a nic se nemění.
*/


WITH hb_match_ids AS (
    SELECT DISTINCT match_id
    FROM public.match_provider_map
    WHERE provider = 'api_handball'
      AND mapping_status = 'ACTIVE'
),

quality AS (
    SELECT
        m.league_id,
        m.season,

        COUNT(*) AS total_matches,

        COUNT(*) FILTER (
            WHERE m.status = 'FINISHED'
        ) AS finished,

        COUNT(*) FILTER (
            WHERE m.status = 'FINISHED'
              AND m.home_score IS NOT NULL
              AND m.away_score IS NOT NULL
        ) AS finished_with_score,

        COUNT(*) FILTER (
            WHERE m.status = 'SCHEDULED'
        ) AS scheduled,

        COUNT(*) FILTER (
            WHERE m.status = 'CANCELLED'
        ) AS cancelled,

        MIN(m.kickoff) AS first_kickoff,
        MAX(m.kickoff) AS last_kickoff

    FROM public.matches m
    JOIN hb_match_ids h
      ON h.match_id = m.id

    GROUP BY
        m.league_id,
        m.season
)

SELECT
    q.league_id AS public_league_id,
    lpm.provider_league_id,
    q.season,

    q.total_matches,
    q.finished,
    q.finished_with_score,
    q.scheduled,
    q.cancelled,

    q.first_kickoff,
    q.last_kickoff

FROM quality q

JOIN public.league_provider_map lpm
  ON lpm.league_id = q.league_id
 AND lpm.provider = 'api_handball'

WHERE q.total_matches >= 100

  AND q.finished = q.total_matches

  AND q.finished_with_score = q.total_matches

  AND q.scheduled = 0

  AND q.cancelled = 0

ORDER BY
    q.total_matches DESC,
    q.league_id

LIMIT 20;