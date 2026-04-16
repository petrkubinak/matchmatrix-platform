-- 479_create_canonical_team_resolve_view.sql
-- Cíl:
-- vytvořit jednotný resolve pohled:
-- provider team -> canonical team

DROP VIEW IF EXISTS public.v_canonical_team_resolve;

CREATE VIEW public.v_canonical_team_resolve AS
SELECT
    ctm.provider,
    ctm.provider_team_id,
    ctm.canonical_team_id,
    t_can.name AS canonical_team_name,
    ctm.status,
    ctm.note
FROM public.canonical_team_map ctm
LEFT JOIN public.teams t_can
       ON t_can.id = ctm.canonical_team_id

UNION ALL

-- fallback: canonical tým je sám sobě canonical
SELECT
    COALESCE(t.ext_source, 'canonical') AS provider,
    t.id AS provider_team_id,
    t.id AS canonical_team_id,
    t.name AS canonical_team_name,
    'self' AS status,
    'Self canonical fallback' AS note
FROM public.teams t;

-- kontrola
SELECT
    provider,
    status,
    COUNT(*) AS rows_count
FROM public.v_canonical_team_resolve
GROUP BY provider, status
ORDER BY provider, status;