
-- =====================================================================
-- 208_fb_team_provider_map_audit_fix.sql
-- MatchMatrix - audit provider map pro api_football teams
-- FIX: public.teams používá sloupec name, ne canonical_team_name
-- =====================================================================

-- -------------------------------------------------
-- 1) Celkový přehled coverage
-- -------------------------------------------------
SELECT
    COUNT(*) AS stg_team_rows,
    COUNT(tpm.team_id) AS mapped_rows,
    COUNT(*) - COUNT(tpm.team_id) AS unmapped_rows
FROM staging.stg_provider_teams spt
LEFT JOIN public.team_provider_map tpm
       ON tpm.provider = spt.provider
      AND tpm.provider_team_id = spt.external_team_id
WHERE spt.provider = 'api_football'
  AND spt.sport_code = 'football';

-- -------------------------------------------------
-- 2) Nemapované týmy
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
LIMIT 300;

-- -------------------------------------------------
-- 3) Namapované týmy
-- -------------------------------------------------
SELECT
    spt.provider,
    spt.external_team_id,
    spt.team_name,
    tpm.team_id,
    t.name AS canonical_team_name
FROM staging.stg_provider_teams spt
JOIN public.team_provider_map tpm
  ON tpm.provider = spt.provider
 AND tpm.provider_team_id = spt.external_team_id
LEFT JOIN public.teams t
  ON t.id = tpm.team_id
WHERE spt.provider = 'api_football'
  AND spt.sport_code = 'football'
ORDER BY spt.team_name
LIMIT 300;

-- -------------------------------------------------
-- 4) Podezřelé duplicity v team_provider_map pro api_football
--    (jeden provider_team_id -> více canonical team_id)
-- -------------------------------------------------
SELECT
    tpm.provider,
    tpm.provider_team_id,
    COUNT(DISTINCT tpm.team_id) AS canonical_count,
    STRING_AGG(DISTINCT tpm.team_id::text, ', ' ORDER BY tpm.team_id::text) AS canonical_team_ids
FROM public.team_provider_map tpm
WHERE tpm.provider = 'api_football'
GROUP BY tpm.provider, tpm.provider_team_id
HAVING COUNT(DISTINCT tpm.team_id) > 1
ORDER BY canonical_count DESC, tpm.provider_team_id;

-- -------------------------------------------------
-- 5) Kandidáti podle stejného názvu v public.teams
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
JOIN canon c
  ON c.canonical_name_norm = u.team_name_norm
GROUP BY u.external_team_id, u.team_name
HAVING COUNT(c.team_id) >= 1
ORDER BY matched_canonical_count DESC, u.team_name
LIMIT 300;