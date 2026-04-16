-- 496_o_find_ambiguous_aliases.sql
-- Cíl:
-- najít aliasy, které míří na více canonical team_id
-- právě ty pravděpodobně dělají falešné PAIR_MISSING

SELECT
    LOWER(a.alias) AS alias_norm,
    COUNT(DISTINCT a.team_id) AS team_count,
    STRING_AGG(DISTINCT a.team_id::text, ', ' ORDER BY a.team_id::text) AS team_ids,
    STRING_AGG(DISTINCT t.name, ' | ' ORDER BY t.name) AS team_names
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
GROUP BY LOWER(a.alias)
HAVING COUNT(DISTINCT a.team_id) > 1
ORDER BY team_count DESC, alias_norm;