-- =====================================================================
-- 212_fb_team_provider_map_remaining_unmapped_audit.sql
-- MatchMatrix - audit zbývajících nenamapovaných FB týmů
-- =====================================================================

-- -------------------------------------------------
-- 1) Přesný počet zbývajících unmapped
-- -------------------------------------------------
SELECT
    COUNT(*) AS remaining_unmapped_rows
FROM staging.stg_provider_teams spt
LEFT JOIN public.team_provider_map tpm
       ON tpm.provider = spt.provider
      AND tpm.provider_team_id = spt.external_team_id
WHERE spt.provider = 'api_football'
  AND spt.sport_code = 'football'
  AND tpm.team_id IS NULL;

-- -------------------------------------------------
-- 2) Základní seznam zbývajících unmapped
-- -------------------------------------------------
SELECT
    spt.provider,
    spt.external_team_id,
    spt.team_name,
    spt.country_name,
    spt.external_league_id,
    spt.season
FROM staging.stg_provider_teams spt
LEFT JOIN public.team_provider_map tpm
       ON tpm.provider = spt.provider
      AND tpm.provider_team_id = spt.external_team_id
WHERE spt.provider = 'api_football'
  AND spt.sport_code = 'football'
  AND tpm.team_id IS NULL
ORDER BY spt.team_name
LIMIT 1000;

-- -------------------------------------------------
-- 3) Exact-name kandidáti v public.teams pro zbývající unmapped
-- -------------------------------------------------
WITH unmapped AS (
    SELECT
        spt.external_team_id,
        spt.team_name,
        LOWER(TRIM(spt.team_name)) AS team_name_norm
    FROM staging.stg_provider_teams spt
    LEFT JOIN public.team_provider_map tpm
           ON tpm.provider = spt.provider
          AND tpm.provider_team_id = spt.external_team_id
    WHERE spt.provider = 'api_football'
      AND spt.sport_code = 'football'
      AND tpm.team_id IS NULL
),
canon AS (
    SELECT
        t.id AS team_id,
        t.name,
        LOWER(TRIM(t.name)) AS canonical_name_norm
    FROM public.teams t
)
SELECT
    u.external_team_id,
    u.team_name,
    COUNT(c.team_id) AS matched_canonical_count,
    STRING_AGG(c.team_id::text, ', ' ORDER BY c.team_id::text) AS candidate_team_ids
FROM unmapped u
LEFT JOIN canon c
       ON c.canonical_name_norm = u.team_name_norm
GROUP BY u.external_team_id, u.team_name
ORDER BY matched_canonical_count DESC, u.team_name
LIMIT 1000;

-- -------------------------------------------------
-- 4) Rozpad podle typu problému
-- -------------------------------------------------
WITH unmapped AS (
    SELECT
        spt.external_team_id,
        spt.team_name,
        LOWER(TRIM(spt.team_name)) AS team_name_norm
    FROM staging.stg_provider_teams spt
    LEFT JOIN public.team_provider_map tpm
           ON tpm.provider = spt.provider
          AND tpm.provider_team_id = spt.external_team_id
    WHERE spt.provider = 'api_football'
      AND spt.sport_code = 'football'
      AND tpm.team_id IS NULL
),
canon AS (
    SELECT
        t.id AS team_id,
        LOWER(TRIM(t.name)) AS canonical_name_norm
    FROM public.teams t
),
scored AS (
    SELECT
        u.external_team_id,
        u.team_name,
        COUNT(c.team_id) AS matched_canonical_count
    FROM unmapped u
    LEFT JOIN canon c
           ON c.canonical_name_norm = u.team_name_norm
    GROUP BY u.external_team_id, u.team_name
)
SELECT
    CASE
        WHEN matched_canonical_count = 0 THEN 'NO_EXACT_MATCH'
        WHEN matched_canonical_count = 1 THEN 'SHOULD_ALREADY_BE_MAPPED_CHECK'
        ELSE 'MULTI_MATCH'
    END AS problem_type,
    COUNT(*) AS row_count
FROM scored
GROUP BY
    CASE
        WHEN matched_canonical_count = 0 THEN 'NO_EXACT_MATCH'
        WHEN matched_canonical_count = 1 THEN 'SHOULD_ALREADY_BE_MAPPED_CHECK'
        ELSE 'MULTI_MATCH'
    END
ORDER BY row_count DESC;