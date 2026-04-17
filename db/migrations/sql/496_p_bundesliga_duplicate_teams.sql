-- 496_p_bundesliga_duplicate_teams.sql
-- Cíl:
-- najít duplicity týmů jen pro Bundesligu

SELECT
    t.id,
    t.name,
    COUNT(m.id) AS matches_count
FROM public.teams t
LEFT JOIN public.matches m
  ON m.home_team_id = t.id OR m.away_team_id = t.id
WHERE t.id IN (
    SELECT DISTINCT team_id
    FROM public.team_aliases
    WHERE LOWER(alias) IN (
        'union berlin',
        '1 heidenheim',
        'saint pauli',
        'bayern munich'
    )
)
GROUP BY t.id, t.name
ORDER BY t.name, matches_count DESC;