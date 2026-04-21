-- =====================================================================
-- 211_fb_team_provider_map_insert_safe_exact_unique_dedup.sql
-- MatchMatrix - STRICT SAFE + DEDUP insert do public.team_provider_map
-- pro api_football
--
-- Pravidla:
-- 1) provider_team_id ještě není mapovaný
-- 2) exact-name match vrátí přesně 1 canonical team_id
-- 3) team_id ještě nemá provider='api_football'
-- 4) pokud více external_team_id míří na stejný team_id,
--    vezmeme jen 1 řádek (nejnižší external_team_id)
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

-- =====================================================================
-- KONTROLA 1 - coverage po insertu
-- =====================================================================
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

-- =====================================================================
-- KONTROLA 2 - kolik kandidátů bylo po dedupu
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
SELECT COUNT(*) AS dedup_safe_candidate_count
FROM dedup_candidates
WHERE rn = 1;

-- =====================================================================
-- KONTROLA 3 - kolizní kandidáti, kteří byli ořezáni dedupem
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
SELECT
    team_id,
    provider,
    COUNT(*) AS candidate_count,
    STRING_AGG(external_team_id, ', ' ORDER BY external_team_id) AS provider_team_ids
FROM dedup_candidates
GROUP BY team_id, provider
HAVING COUNT(*) > 1
ORDER BY candidate_count DESC, team_id
LIMIT 200;