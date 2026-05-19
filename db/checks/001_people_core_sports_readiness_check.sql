-- ============================================================
-- MATCHMATRIX - PEOPLE FALLBACK PROVIDERS SEED (V1)
-- ============================================================

-- =========================
-- BASKETBALL (BK)
-- =========================
INSERT INTO ops.provider_entity_coverage (
    provider, sport_code, entity,
    coverage_status, quality_rating,
    is_primary, is_fallback_source, priority,
    notes, next_action,
    created_at, updated_at
)
VALUES
('sportsdataio', 'BK', 'players', 'planned', 'unknown', false, true, 2,
 'Fallback provider pro basketball players (NBA/NCAA).',
 'Otestovat players endpoint + response_count.',
 now(), now());

-- =========================
-- BASEBALL (BSB)
-- =========================
INSERT INTO ops.provider_entity_coverage (...)
VALUES
('sportsdataio', 'BSB', 'players', 'planned', 'unknown', false, true, 2,
 'Fallback provider pro baseball players (MLB).',
 'Smoke test players API.',
 now(), now());

-- =========================
-- HOCKEY (HK)
-- =========================
INSERT INTO ops.provider_entity_coverage (...)
VALUES
('sportsdataio', 'HK', 'players', 'planned', 'unknown', false, true, 2,
 'Fallback provider pro hockey players (NHL).',
 'Otestovat coverage.',
 now(), now());

-- =========================
-- CRICKET (CK)
-- =========================
INSERT INTO ops.provider_entity_coverage (...)
VALUES
('sportmonks', 'CK', 'players', 'planned', 'unknown', false, true, 2,
 'Cricket players fallback (Sportmonks).',
 'Otestovat players + leagues scope.',
 now(), now());

-- =========================
-- TENNIS (TN)
-- =========================
INSERT INTO ops.provider_entity_coverage (...)
VALUES
('rapidapi_tennis', 'TN', 'players', 'planned', 'unknown', false, true, 2,
 'Tennis players (profiles/rankings).',
 'Otestovat players endpoint.',
 now(), now());

-- =========================
-- MMA
-- =========================
INSERT INTO ops.provider_entity_coverage (...)
VALUES
('sportsdataio', 'MMA', 'players', 'planned', 'unknown', false, true, 2,
 'MMA fighters fallback.',
 'Otestovat fighters endpoint.',
 now(), now());

-- ============================================================
-- KONTROLA
-- ============================================================
SELECT
    provider,
    sport_code,
    entity,
    coverage_status,
    is_primary,
    is_fallback_source,
    priority
FROM ops.provider_entity_coverage
WHERE entity = 'players'
ORDER BY sport_code, priority;