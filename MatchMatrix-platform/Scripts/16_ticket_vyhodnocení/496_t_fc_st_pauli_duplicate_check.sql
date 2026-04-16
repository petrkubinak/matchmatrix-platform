-- 496_t_fc_st_pauli_duplicate_check.sql
-- Cíl:
-- ověřit duplicity pro FC St. Pauli a vybrat správný canonical team_id

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
        'fc st. pauli',
        'saint pauli'
    )
)
GROUP BY t.id, t.name
ORDER BY matches_count DESC, t.name;