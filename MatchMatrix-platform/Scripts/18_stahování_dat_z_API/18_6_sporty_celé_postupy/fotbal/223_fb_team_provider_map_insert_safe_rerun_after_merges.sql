-- =====================================================================
-- 223_fb_team_provider_map_insert_safe_rerun_after_merges.sql
-- MatchMatrix - rerun safe insert po merge cleanupu
-- =====================================================================

WITH unmapped AS (
    SELECT
        spt.provider,
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
),
unique_exact_match AS (
    SELECT
        u.provider,
        u.external_team_id,
        MIN(c.team_id) AS team_id,
        COUNT(*) AS matched_canonical_count
    FROM unmapped u
    JOIN canon c
      ON c.canonical_name_norm = u.team_name_norm
    GROUP BY
        u.provider,
        u.external_team_id
    HAVING COUNT(*) = 1
),
strict_candidates AS (
    SELECT
        m.team_id,
        m.provider,
        m.external_team_id
    FROM unique_exact_match m
    WHERE NOT EXISTS (
        SELECT 1
        FROM public.team_provider_map tpm1
        WHERE tpm1.provider = m.provider
          AND tpm1.provider_team_id = m.external_team_id
    )
      AND NOT EXISTS (
        SELECT 1
        FROM public.team_provider_map tpm2
        WHERE tpm2.provider = m.provider
          AND tpm2.team_id = m.team_id
    )
),
dedup_candidates AS (
    SELECT
        sc.team_id,
        sc.provider,
        sc.external_team_id,
        ROW_NUMBER() OVER (
            PARTITION BY sc.team_id, sc.provider
            ORDER BY
                CASE
                    WHEN sc.external_team_id ~ '^[0-9]+$'
                    THEN sc.external_team_id::bigint
                    ELSE 999999999999
                END,
                sc.external_team_id
        ) AS rn
    FROM strict_candidates sc
)
INSERT INTO public.team_provider_map
(
    team_id,
    provider,
    provider_team_id
)
SELECT
    dc.team_id,
    dc.provider,
    dc.external_team_id
FROM dedup_candidates dc
WHERE dc.rn = 1;

-- KONTROLA 1
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

-- KONTROLA 2
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
        WHEN matched_canonical_count = 1 THEN 'SHOULD_NOW_BE_MAPPABLE'
        ELSE 'MULTI_MATCH'
    END AS problem_type,
    COUNT(*) AS row_count
FROM scored
GROUP BY
    CASE
        WHEN matched_canonical_count = 0 THEN 'NO_EXACT_MATCH'
        WHEN matched_canonical_count = 1 THEN 'SHOULD_NOW_BE_MAPPABLE'
        ELSE 'MULTI_MATCH'
    END
ORDER BY row_count DESC;