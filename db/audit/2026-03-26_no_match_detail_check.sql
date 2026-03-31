SELECT
    m.id AS match_id,
    l.name AS league_name,
    ht.name AS home_team,
    at.name AS away_team,
    m.kickoff,
    m.status,
    m.ext_source,
    m.ext_match_id
FROM public.matches m
LEFT JOIN public.leagues l ON l.id = m.league_id
LEFT JOIN public.teams ht ON ht.id = m.home_team_id
LEFT JOIN public.teams at ON at.id = m.away_team_id
WHERE
    (
        lower(ht.name) LIKE '%arsenal%' OR lower(at.name) LIKE '%arsenal%'
    )
    AND
    (
        lower(ht.name) LIKE '%bournemouth%' OR lower(at.name) LIKE '%bournemouth%'
    )
    AND m.kickoff BETWEEN ('2026-04-11T12:30:00Z'::timestamptz AT TIME ZONE 'UTC') - interval '96 hours'
                     AND ('2026-04-11T12:30:00Z'::timestamptz AT TIME ZONE 'UTC') + interval '96 hours'
ORDER BY m.kickoff, m.id;