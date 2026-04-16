-- =====================================================================
-- 578_mapping_gap_candidates.sql
-- Účel:
-- najít canonical kandidáty pro 2 poslední čisté mapping gaps
-- =====================================================================

WITH targets AS (
    SELECT 'Sporting Cristal'::text AS raw_name
    UNION ALL
    SELECT 'Czech Republic'
),

team_names AS (
    SELECT
        t.id AS team_id,
        t.name AS canonical_name,
        lower(public.unaccent(t.name)) AS canonical_name_norm
    FROM public.teams t
),

alias_names AS (
    SELECT
        a.team_id,
        a.alias,
        a.source,
        lower(public.unaccent(a.alias)) AS alias_norm
    FROM public.team_aliases a
)

-- 1) přesný/části názvu v teams
SELECT
    'TEAM_NAME' AS candidate_source,
    trg.raw_name,
    tn.team_id,
    tn.canonical_name,
    NULL::text AS alias,
    NULL::text AS alias_source
FROM targets trg
JOIN team_names tn
  ON tn.canonical_name_norm LIKE '%' || lower(public.unaccent(trg.raw_name)) || '%'

UNION ALL

-- 2) přesný/části názvu v aliases
SELECT
    'ALIAS' AS candidate_source,
    trg.raw_name,
    an.team_id,
    t.name AS canonical_name,
    an.alias,
    an.source AS alias_source
FROM targets trg
JOIN alias_names an
  ON an.alias_norm LIKE '%' || lower(public.unaccent(trg.raw_name)) || '%'
JOIN public.teams t
  ON t.id = an.team_id

ORDER BY raw_name, candidate_source, canonical_name;