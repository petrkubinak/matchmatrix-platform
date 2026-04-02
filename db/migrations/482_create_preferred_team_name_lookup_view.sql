-- 482_create_preferred_team_name_lookup_view.sql
-- Cíl:
-- vytvořit preferovaný lookup názvů týmů:
-- 1) explicitně namapované canonical_team_map
-- 2) team_aliases
-- 3) canonical/self fallback
-- a vždy vrátit jen 1 preferovaný canonical_team_id na název

DROP VIEW IF EXISTS public.v_preferred_team_name_lookup;

CREATE VIEW public.v_preferred_team_name_lookup AS
WITH base_names AS (

    -- 1) explicitně namapované provider týmy -> canonical
    SELECT
        lower(trim(tp.name)) AS team_name_key,
        ctm.canonical_team_id,
        tc.name AS canonical_team_name,
        'mapped_team_name' AS source_type,
        CASE ctm.status
            WHEN 'confirmed' THEN 1
            WHEN 'review' THEN 2
            WHEN 'auto' THEN 3
            ELSE 9
        END AS priority
    FROM public.canonical_team_map ctm
    JOIN public.teams tp
      ON tp.id = ctm.provider_team_id
    JOIN public.teams tc
      ON tc.id = ctm.canonical_team_id

    UNION ALL

    -- 2) aliasy týmů -> canonical
    SELECT
        lower(trim(ta.alias)) AS team_name_key,
        ta.team_id AS canonical_team_id,
        tc.name AS canonical_team_name,
        'team_alias' AS source_type,
        4 AS priority
    FROM public.team_aliases ta
    JOIN public.teams tc
      ON tc.id = ta.team_id
    WHERE ta.alias IS NOT NULL
      AND btrim(ta.alias) <> ''

    UNION ALL

    -- 3) canonical/self fallback podle jména týmu
    SELECT
        lower(trim(t.name)) AS team_name_key,
        t.id AS canonical_team_id,
        t.name AS canonical_team_name,
        'self_team_name' AS source_type,
        CASE
            WHEN t.ext_source IN ('football_data', 'football_data_uk') THEN 5
            WHEN t.ext_source IS NULL THEN 6
            WHEN t.ext_source = 'api_football' THEN 7
            ELSE 8
        END AS priority
    FROM public.teams t
    WHERE t.name IS NOT NULL
      AND btrim(t.name) <> ''
),
ranked AS (
    SELECT
        team_name_key,
        canonical_team_id,
        canonical_team_name,
        source_type,
        priority,
        ROW_NUMBER() OVER (
            PARTITION BY team_name_key
            ORDER BY priority, canonical_team_id
        ) AS rn
    FROM base_names
)
SELECT
    team_name_key,
    canonical_team_id,
    canonical_team_name,
    source_type,
    priority
FROM ranked
WHERE rn = 1;

-- kontrola
SELECT
    source_type,
    COUNT(*) AS rows_count
FROM public.v_preferred_team_name_lookup
GROUP BY source_type
ORDER BY source_type;