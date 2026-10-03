/*
CO:
STEP 10C – API-HANDBALL REPRESENTATIVE REPLAY RECONCILIATION

K ČEMU:
Spojit výsledky STEP 10B s canonical league mapou
a uloženými historickými daty v DB.

CÍL:
Ověřit pro všech 5 runtime replay testů:
- jednoznačné provider → canonical league mapování,
- přesný DB počet zápasů,
- čistotu historického scope,
- shodu API count = DB count.

JAK:
Pouze SELECT.
Žádný zápis do DB.
*/


WITH replay AS (
    SELECT *
    FROM (
        VALUES
            (34::text,  '2024'::text, 240, '20260929121945937',
             'be7dcf3ba9b68b5d1e852282996e062e1b6a9729b866545380e49724875ae5d6'),

            (104::text, '2024'::text, 245, '20260929121946393',
             '280bbea33ecfdc82edf9fb434542446e6470286689268d48bb96244a4184c919'),

            (145::text, '2024'::text, 168, '20260929121946820',
             'd724b11d9f1dbbc1199c53d3affc68ba04fe0bb537eafab5ee2d3b21cdc50dcc'),

            (154::text, '2024'::text, 142, '20260929121947263',
             '87001ebc1fa3439c8a2f6b168239814d71d0c58c1863e6260b54e8757fbdaded'),

            (155::text, '2024'::text, 88,  '20260929121947655',
             'd1f598d6c73d4fd86583d5d20266bf6af24fc8693c2ad5b4de67d2648091799b')
    ) AS x(
        provider_league_id,
        source_season,
        api_results,
        run_id,
        payload_sha256
    )
),

mapped AS (
    SELECT
        r.*,
        lpm.league_id AS canonical_league_id,
        l.name AS canonical_league_name
    FROM replay r

    LEFT JOIN public.league_provider_map lpm
      ON lpm.provider = 'api_handball'
     AND lpm.provider_league_id::text = r.provider_league_id

    LEFT JOIN public.leagues l
      ON l.id = lpm.league_id
),

db_scope AS (
    SELECT
        m.league_id,
        m.season::text AS season,

        COUNT(DISTINCT m.id) AS db_matches,

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

    GROUP BY
        m.league_id,
        m.season::text
)

SELECT
    m.provider_league_id,
    m.canonical_league_id,
    m.canonical_league_name,
    m.source_season,

    m.api_results,
    d.db_matches,

    d.finished,
    d.finished_with_score,
    d.scheduled,
    d.cancelled,

    d.first_kickoff,
    d.last_kickoff,

    m.run_id,
    m.payload_sha256,

    CASE
        WHEN m.canonical_league_id IS NULL
            THEN 'NO_CANONICAL_MAP'

        WHEN d.db_matches IS NULL
            THEN 'NO_DB_SCOPE'

        WHEN m.api_results <> d.db_matches
            THEN 'COUNT_MISMATCH'

        WHEN d.finished <> d.db_matches
            THEN 'NOT_ALL_FINISHED'

        WHEN d.finished_with_score <> d.db_matches
            THEN 'MISSING_SCORE'

        WHEN d.scheduled <> 0
            THEN 'HAS_SCHEDULED'

        WHEN d.cancelled <> 0
            THEN 'HAS_CANCELLED'

        ELSE 'PASS'
    END AS reconciliation_status

FROM mapped m

LEFT JOIN db_scope d
  ON d.league_id = m.canonical_league_id
 AND d.season = m.source_season

ORDER BY
    m.provider_league_id::integer;