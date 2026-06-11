/*
MATCHMATRIX SQL 19_2_D Photo Provider Research Seed V1

CO TO JE:
- Doplňuje research řádky pro fotky hráčů, trenérů, loga a stadiony.
- Rozšiřuje ops.provider_missing_matrix o konkrétní kandidáty providerů.

K ČEMU TO JE:
- Abychom přesně věděli, odkud budeme brát vizuální assety.
- Abychom oddělili FREE zdroje od PAID zdrojů.
- Abychom připravili PC2 harvest i pro fotky/loga.

KDE TO UVIDÍME:
- OPS Panel V18
- Provider Command Center
- Missing Provider Matrix
- PC2 Harvest Readiness

JAK SE TO VYUŽIJE:
- Pro výběr providerů.
- Pro budoucí photo/logo workery.
- Pro webové profily hráčů, týmů, trenérů a stadionů.
*/

-- =====================================================
-- 1) Rozšíření tabulky o research sloupce
-- =====================================================

ALTER TABLE ops.provider_missing_matrix
ADD COLUMN IF NOT EXISTS research_provider_url TEXT;

ALTER TABLE ops.provider_missing_matrix
ADD COLUMN IF NOT EXISTS license_note TEXT;

ALTER TABLE ops.provider_missing_matrix
ADD COLUMN IF NOT EXISTS terms_check_required BOOLEAN DEFAULT true;

ALTER TABLE ops.provider_missing_matrix
ADD COLUMN IF NOT EXISTS harvest_ready_after_check BOOLEAN DEFAULT false;

ALTER TABLE ops.provider_missing_matrix
ADD COLUMN IF NOT EXISTS worker_needed TEXT;

ALTER TABLE ops.provider_missing_matrix
ADD COLUMN IF NOT EXISTS research_status TEXT DEFAULT 'OPEN';

ALTER TABLE ops.provider_missing_matrix
ADD COLUMN IF NOT EXISTS research_rank INTEGER DEFAULT 999;


-- =====================================================
-- 2) Kontrolní constraint pro research_status
-- =====================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'provider_missing_matrix_research_status_chk'
    ) THEN
        ALTER TABLE ops.provider_missing_matrix
        ADD CONSTRAINT provider_missing_matrix_research_status_chk
        CHECK (
            research_status IN (
                'OPEN',
                'CHECK_TERMS',
                'READY_FOR_TEST',
                'WAIT_FOR_PAID',
                'REJECTED',
                'APPROVED'
            )
        );
    END IF;
END $$;


-- =====================================================
-- 3) Update existujících TOP priorit
-- =====================================================

UPDATE ops.provider_missing_matrix
SET
    research_status = 'CHECK_TERMS',
    terms_check_required = true,
    harvest_ready_after_check = false,
    worker_needed = 'photo_asset_discovery_worker',
    research_rank = CASE
        WHEN sport_code = 'FB' AND entity_type = 'PLAYER_PHOTOS' THEN 1
        WHEN sport_code = 'FB' AND entity_type = 'TEAM_LOGOS' THEN 2
        WHEN sport_code = 'FB' AND entity_type = 'COACH_PHOTOS' THEN 3
        WHEN sport_code = 'FB' AND entity_type = 'STADIUM_PHOTOS' THEN 4
        WHEN entity_type = 'PLAYER_PHOTOS' THEN 10
        WHEN entity_type = 'TEAM_LOGOS' THEN 20
        WHEN entity_type = 'COACH_PHOTOS' THEN 30
        WHEN entity_type = 'STADIUM_PHOTOS' THEN 40
        ELSE 999
    END,
    updated_at = now()
WHERE layer_code = 'VISUAL_ASSETS';


-- =====================================================
-- 4) Konkrétní research doporučení podle entity
-- =====================================================

UPDATE ops.provider_missing_matrix
SET
    research_provider_url = 'https://commons.wikimedia.org/',
    license_note = 'FREE source candidate, but each image license must be checked and stored.',
    access_type = CASE
        WHEN access_type = 'UNKNOWN' THEN 'FREE'
        ELSE access_type
    END,
    api_available = true,
    automation_possible = true,
    next_action = 'Check Wikimedia Commons API coverage and image licenses.',
    updated_at = now()
WHERE recommended_provider ILIKE '%Wikimedia%'
  AND entity_type IN (
      'PLAYER_PHOTOS',
      'COACH_PHOTOS',
      'TEAM_LOGOS',
      'STADIUM_PHOTOS'
  );


UPDATE ops.provider_missing_matrix
SET
    research_provider_url = 'https://www.wikidata.org/',
    license_note = 'Metadata source candidate. Use mainly for entity linking and image reference discovery.',
    api_available = true,
    automation_possible = true,
    next_action = 'Check Wikidata entity IDs and image properties.',
    updated_at = now()
WHERE entity_type IN (
      'PLAYER_PHOTOS',
      'COACH_PHOTOS',
      'TEAM_LOGOS',
      'STADIUM_PHOTOS'
  )
  AND (
      recommended_provider ILIKE '%Wikipedia%'
      OR recommended_provider ILIKE '%Wikimedia%'
  );


UPDATE ops.provider_missing_matrix
SET
    license_note = 'Official site source candidate. Terms must be checked before automated downloading.',
    terms_check_required = true,
    harvest_ready_after_check = false,
    api_available = false,
    automation_possible = true,
    next_action = 'Check official site media usage terms and sitemap/RSS availability.',
    updated_at = now()
WHERE recommended_provider ILIKE '%Official%';


UPDATE ops.provider_missing_matrix
SET
    research_status = 'WAIT_FOR_PAID',
    terms_check_required = true,
    harvest_ready_after_check = false,
    license_note = 'Paid provider candidate. Check plan, endpoint availability and image redistribution rights.',
    next_action = 'Verify paid provider plan and image usage rights.',
    updated_at = now()
WHERE access_type = 'PAID';


-- =====================================================
-- 5) Dashboard view pro photo provider research
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_provider_research_v1 AS
SELECT
    research_rank,
    sport_code,
    sport_name,
    entity_type,
    current_status,
    priority_score,
    recommended_provider,
    access_type,
    research_provider_url,
    research_status,
    terms_check_required,
    harvest_ready_after_check,
    api_available,
    automation_possible,
    worker_needed,
    license_note,
    next_action,
    notes,
    updated_at
FROM ops.provider_missing_matrix
WHERE entity_type IN (
    'PLAYER_PHOTOS',
    'COACH_PHOTOS',
    'TEAM_LOGOS',
    'STADIUM_PHOTOS'
)
ORDER BY
    research_rank,
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- 6) Summary view
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_provider_research_summary_v1 AS
SELECT
    research_status,
    access_type,
    COUNT(*) AS rows_count,
    MIN(research_rank) AS best_rank,
    MAX(priority_score) AS max_priority
FROM ops.v_photo_provider_research_v1
GROUP BY
    research_status,
    access_type
ORDER BY
    best_rank,
    rows_count DESC;


-- =====================================================
-- 7) Quick check
-- =====================================================

SELECT
    research_status,
    access_type,
    COUNT(*) AS rows_count
FROM ops.v_photo_provider_research_v1
GROUP BY
    research_status,
    access_type
ORDER BY
    research_status,
    access_type;

