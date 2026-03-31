-- Audit Serie A: existují problematické zápasy v DB pod jiným časem / názvem?
-- Spouštět v DBeaveru

WITH target_pairs AS (
    SELECT *
    FROM (VALUES
        ('Sassuolo', 'Cagliari', '2026-04-04T13:00:00Z'),
        ('Cremonese', 'Bologna', '2026-04-05T13:00:00Z'),
        ('Pisa', 'Torino', '2026-04-05T16:00:00Z'),
        ('Inter Milan', 'AS Roma', '2026-04-05T18:45:00Z'),
        ('Lecce', 'Atalanta BC', '2026-04-06T13:00:00Z'),
        ('Udinese', 'Como', '2026-04-06T13:00:00Z'),
        ('Juventus', 'Genoa', '2026-04-06T16:00:00Z'),
        ('Napoli', 'AC Milan', '2026-04-06T18:45:00Z')
    ) AS x(home_name, away_name, kickoff_iso)
)
SELECT
    tp.home_name AS theodds_home,
    tp.away_name AS theodds_away,
    tp.kickoff_iso AS theodds_kickoff,
    m.id AS match_id,
    l.name AS league_name,
    ht.name AS db_home,
    at.name AS db_away,
    m.kickoff AS db_kickoff,
    m.status,
    m.ext_source,
    m.ext_match_id
FROM target_pairs tp
LEFT JOIN public.matches m
  ON m.kickoff BETWEEN (tp.kickoff_iso::timestamptz AT TIME ZONE 'UTC') - interval '72 hours'
                   AND (tp.kickoff_iso::timestamptz AT TIME ZONE 'UTC') + interval '72 hours'
LEFT JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.teams ht
  ON ht.id = m.home_team_id
LEFT JOIN public.teams at
  ON at.id = m.away_team_id
WHERE
    l.name ILIKE '%Serie A%'
    AND (
        lower(ht.name) ILIKE '%' || lower(replace(tp.home_name, ' Milan', '')) || '%'
        OR lower(at.name) ILIKE '%' || lower(replace(tp.away_name, ' Milan', '')) || '%'
        OR lower(ht.name) ILIKE '%' || lower(tp.home_name) || '%'
        OR lower(at.name) ILIKE '%' || lower(tp.away_name) || '%'
    )
ORDER BY tp.kickoff_iso, m.kickoff, m.id;