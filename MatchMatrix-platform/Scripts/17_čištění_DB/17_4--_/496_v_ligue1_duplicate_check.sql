-- 496_v_ligue1_duplicate_check.sql
-- Cíl:
-- zjistit správné canonical team_id pro hlavní Ligue 1 duplicity

SELECT
    t.id,
    t.name,
    COUNT(m.id) AS matches_count
FROM public.teams t
LEFT JOIN public.matches m
  ON m.home_team_id = t.id OR m.away_team_id = t.id
WHERE t.id IN (
    1018, 12102,   -- Angers
    506, 12104,    -- Lyon
    1019, 12116,   -- Auxerre
    1023, 12107,   -- Nantes
    505, 12108,    -- Nice
    1022, 12113    -- Strasbourg
)
GROUP BY t.id, t.name
ORDER BY t.name, matches_count DESC;