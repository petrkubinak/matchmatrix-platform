-- =====================================================================
-- 571_top4_team_identity_detail.sql
-- Účel:
-- detail identity pro TOP 4 bezpečné problem týmy
-- =====================================================================

WITH target_names AS (
    SELECT 'grêmio'::text AS raw_name
    UNION ALL SELECT '1. fc heidenheim'
    UNION ALL SELECT 'angers'
    UNION ALL SELECT 'auxerre'
),

team_base AS (
    SELECT
        t.id AS team_id,
        t.name AS canonical_name,
        lower(btrim(t.name)) AS canonical_name_norm
    FROM public.teams t
),

alias_base AS (
    SELECT
        a.team_id,
        a.alias,
        lower(btrim(a.alias)) AS alias_norm,
        a.source
    FROM public.team_aliases a
),

provider_map AS (
    SELECT
        pm.team_id,
        pm.provider,
        pm.provider_team_id
    FROM public.team_provider_map pm
),

matched_candidates AS (
    SELECT
        n.raw_name,
        tb.team_id,
        tb.canonical_name,
        'TEAM_NAME' AS match_source
    FROM target_names n
    JOIN team_base tb
      ON tb.canonical_name_norm = lower(btrim(n.raw_name))

    UNION ALL

    SELECT
        n.raw_name,
        ab.team_id,
        t.name AS canonical_name,
        'ALIAS' AS match_source
    FROM target_names n
    JOIN alias_base ab
      ON ab.alias_norm = lower(btrim(n.raw_name))
    JOIN public.teams t
      ON t.id = ab.team_id
)

SELECT
    mc.raw_name,
    mc.team_id,
    mc.canonical_name,
    mc.match_source,
    pm.provider,
    pm.provider_team_id
FROM matched_candidates mc
LEFT JOIN provider_map pm
  ON pm.team_id = mc.team_id
ORDER BY mc.raw_name, mc.team_id, pm.provider NULLS LAST, pm.provider_team_id NULLS LAST;

-- ---------------------------------------------------------------------
-- alias detail
-- ---------------------------------------------------------------------
WITH target_team_ids AS (
    SELECT DISTINCT mc.team_id
    FROM (
        SELECT t.id AS team_id
        FROM public.teams t
        WHERE lower(btrim(t.name)) IN ('grêmio', '1. fc heidenheim', 'angers', 'auxerre')

        UNION

        SELECT a.team_id
        FROM public.team_aliases a
        WHERE lower(btrim(a.alias)) IN ('grêmio', '1. fc heidenheim', 'angers', 'auxerre')
    ) mc
)
SELECT
    a.team_id,
    t.name AS canonical_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
JOIN target_team_ids x
  ON x.team_id = a.team_id
ORDER BY t.name, a.alias;

-- ---------------------------------------------------------------------
-- matches usage detail
-- ---------------------------------------------------------------------
WITH target_team_ids AS (
    SELECT DISTINCT mc.team_id
    FROM (
        SELECT t.id AS team_id
        FROM public.teams t
        WHERE lower(btrim(t.name)) IN ('grêmio', '1. fc heidenheim', 'angers', 'auxerre')

        UNION

        SELECT a.team_id
        FROM public.team_aliases a
        WHERE lower(btrim(a.alias)) IN ('grêmio', '1. fc heidenheim', 'angers', 'auxerre')
    ) mc
)
SELECT
    t.id AS team_id,
    t.name AS canonical_name,
    COUNT(*) FILTER (WHERE m.home_team_id = t.id) AS home_matches,
    COUNT(*) FILTER (WHERE m.away_team_id = t.id) AS away_matches,
    COUNT(*) AS total_matches
FROM public.teams t
LEFT JOIN public.matches m
  ON m.home_team_id = t.id
  OR m.away_team_id = t.id
JOIN target_team_ids x
  ON x.team_id = t.id
GROUP BY t.id, t.name
ORDER BY total_matches DESC, canonical_name;