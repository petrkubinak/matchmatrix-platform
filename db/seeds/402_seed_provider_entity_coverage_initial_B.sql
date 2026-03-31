-- ============================================
-- MATCHMATRIX
-- 402_seed_provider_entity_coverage_initial_B.sql
-- Účel:
-- První reálný seed coverage + priority logiky
-- pro planner a budoucí PRO harvest režim
-- ============================================

-- -------------------------------------------------
-- API-FOOTBALL (FB) = hlavní deep provider
-- -------------------------------------------------
UPDATE ops.provider_entity_coverage
SET
    coverage_status     = 'tech_ready',
    provider_priority   = 1,
    merge_priority      = 1,
    fetch_priority      = 10,
    quality_rating      = 'high',
    availability_scope  = 'limited_free',
    free_plan_supported = true,
    paid_plan_supported = true,
    expected_depth      = 'deep',
    is_primary_source   = true,
    is_fallback_source  = false,
    is_merge_source     = true,
    limitations         = 'Free plan omezený na sezony 2022-2024, odds omezeně nebo vůbec, players/statistiky limitovaně.',
    next_action         = 'Po aktivaci PRO spustit full harvest podle planner priority.'
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity IN ('leagues', 'teams', 'fixtures', 'players', 'player_season_stats', 'player_stats', 'coaches', 'odds');

UPDATE ops.provider_entity_coverage
SET
    availability_scope = 'paid_only',
    free_plan_supported = false,
    paid_plan_supported = true,
    coverage_status = 'planned',
    quality_rating = 'medium',
    expected_depth = 'extended',
    is_primary_source = false,
    is_fallback_source = true,
    limitations = 'Odds z api_football nejsou aktuálně hlavní zdroj pro MatchMatrix.',
    next_action = 'Používat spíše jako doplněk, hlavní odds zdroj je TheOdds.'
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'odds';

UPDATE ops.provider_entity_coverage
SET
    coverage_status = 'planned',
    availability_scope = 'limited_free',
    quality_rating = 'medium',
    expected_depth = 'extended',
    limitations = 'Players/coaches/player_season_stats vyžadují PRO a opatrné plánování request budgetu.',
    next_action = 'Připravit harvest dávky po sezonách a ligách.'
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity IN ('players', 'player_season_stats', 'coaches');

UPDATE ops.provider_entity_coverage
SET
    coverage_status = 'runtime_tested',
    availability_scope = 'limited_free',
    quality_rating = 'high',
    expected_depth = 'deep',
    limitations = 'Player stats už mají technické napojení, free plán ale limituje hloubku.',
    next_action = 'Po PRO zapnout prioritní harvest player_stats pro TOP ligy.'
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'player_stats';

-- -------------------------------------------------
-- FOOTBALL-DATA (FB) = historie / fallback / standings-like backbone
-- -------------------------------------------------
UPDATE ops.provider_entity_coverage
SET
    coverage_status     = 'runtime_tested',
    provider_priority   = CASE
                            WHEN entity = 'fixtures' THEN 2
                            WHEN entity = 'teams'    THEN 2
                            WHEN entity = 'leagues'  THEN 2
                            ELSE provider_priority
                          END,
    merge_priority      = CASE
                            WHEN entity = 'fixtures' THEN 2
                            WHEN entity = 'teams'    THEN 2
                            WHEN entity = 'leagues'  THEN 2
                            ELSE merge_priority
                          END,
    fetch_priority      = CASE
                            WHEN entity = 'fixtures' THEN 20
                            WHEN entity = 'teams'    THEN 21
                            WHEN entity = 'leagues'  THEN 22
                            ELSE fetch_priority
                          END,
    quality_rating      = 'high',
    availability_scope  = 'limited_free',
    free_plan_supported = true,
    paid_plan_supported = true,
    expected_depth      = 'extended',
    is_primary_source   = false,
    is_fallback_source  = true,
    is_merge_source     = true,
    limitations         = 'Silné pro historická a strukturální data, slabé pro players a odds.',
    next_action         = 'Používat jako historický a fallback zdroj pro fotbal.'
WHERE provider = 'football_data'
  AND sport_code = 'FB'
  AND entity IN ('leagues', 'teams', 'fixtures');

UPDATE ops.provider_entity_coverage
SET
    coverage_status     = 'blocked',
    provider_priority   = 99,
    merge_priority      = 99,
    fetch_priority      = 99,
    quality_rating      = 'low',
    availability_scope  = 'unknown',
    free_plan_supported = false,
    paid_plan_supported = false,
    expected_depth      = 'basic',
    is_primary_source   = false,
    is_fallback_source  = false,
    is_merge_source     = false,
    limitations         = 'Football-Data není hlavní odds provider pro MatchMatrix.',
    next_action         = 'Neplánovat do harvestu, pokud nebude potvrzeno jinak.'
WHERE provider = 'football_data'
  AND sport_code = 'FB'
  AND entity = 'odds';

-- -------------------------------------------------
-- THEODDS (FB) = hlavní odds provider
-- pokud záznam ještě neexistuje v coverage, vložíme ho
-- -------------------------------------------------
INSERT INTO ops.provider_entity_coverage (
    provider,
    sport_code,
    entity,
    coverage_status,
    is_enabled,
    provider_priority,
    merge_priority,
    fetch_priority,
    quality_rating,
    availability_scope,
    free_plan_supported,
    paid_plan_supported,
    expected_depth,
    is_primary_source,
    is_fallback_source,
    is_merge_source,
    notes,
    limitations,
    next_action
)
VALUES (
    'theodds',
    'FB',
    'odds',
    'runtime_tested',
    true,
    1,
    1,
    10,
    'high',
    'limited_free',
    true,
    true,
    'extended',
    true,
    false,
    true,
    'Hlavní odds provider pro fotbal v MatchMatrix.',
    'Pokrytí hlavně top lig a soutěží.',
    'Po PRO nebo vyšším plánu rozšířit odds coverage podle dostupných trhů.'
)
ON CONFLICT (provider, sport_code, entity) DO UPDATE
SET
    coverage_status     = EXCLUDED.coverage_status,
    is_enabled          = EXCLUDED.is_enabled,
    provider_priority   = EXCLUDED.provider_priority,
    merge_priority      = EXCLUDED.merge_priority,
    fetch_priority      = EXCLUDED.fetch_priority,
    quality_rating      = EXCLUDED.quality_rating,
    availability_scope  = EXCLUDED.availability_scope,
    free_plan_supported = EXCLUDED.free_plan_supported,
    paid_plan_supported = EXCLUDED.paid_plan_supported,
    expected_depth      = EXCLUDED.expected_depth,
    is_primary_source   = EXCLUDED.is_primary_source,
    is_fallback_source  = EXCLUDED.is_fallback_source,
    is_merge_source     = EXCLUDED.is_merge_source,
    notes               = EXCLUDED.notes,
    limitations         = EXCLUDED.limitations,
    next_action         = EXCLUDED.next_action,
    updated_at          = now();

-- -------------------------------------------------
-- API-HOCKEY (HK) = hlavní provider pro hokej
-- -------------------------------------------------
UPDATE ops.provider_entity_coverage
SET
    coverage_status     = CASE
                            WHEN entity IN ('leagues', 'teams', 'fixtures') THEN 'runtime_tested'
                            WHEN entity IN ('players', 'coaches') THEN 'tech_ready'
                            WHEN entity = 'odds' THEN 'planned'
                            ELSE coverage_status
                          END,
    provider_priority   = 1,
    merge_priority      = 1,
    fetch_priority      = CASE
                            WHEN entity = 'leagues'  THEN 10
                            WHEN entity = 'teams'    THEN 20
                            WHEN entity = 'fixtures' THEN 30
                            WHEN entity = 'players'  THEN 40
                            WHEN entity = 'coaches'  THEN 50
                            WHEN entity = 'odds'     THEN 60
                            ELSE fetch_priority
                          END,
    quality_rating      = CASE
                            WHEN entity IN ('leagues', 'teams', 'fixtures') THEN 'high'
                            WHEN entity IN ('players', 'coaches') THEN 'medium'
                            ELSE 'unknown'
                          END,
    availability_scope  = 'limited_free',
    free_plan_supported = true,
    paid_plan_supported = true,
    expected_depth      = CASE
                            WHEN entity IN ('leagues', 'teams', 'fixtures') THEN 'extended'
                            ELSE 'basic'
                          END,
    is_primary_source   = true,
    is_fallback_source  = false,
    is_merge_source     = true,
    limitations         = 'Hokej má slabší/omezenou player coverage podle provider reality.',
    next_action         = 'Po PRO vytěžit leagues/teams/fixtures a ověřit players/coaches coverage v praxi.'
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity IN ('leagues', 'teams', 'fixtures', 'players', 'coaches', 'odds');

UPDATE ops.provider_entity_coverage
SET
    coverage_status = 'blocked',
    quality_rating = 'low',
    availability_scope = 'unknown',
    expected_depth = 'basic',
    limitations = 'Players endpoint je v praxi omezený nebo problematický. Nutno ověřit reálnou paid coverage.',
    next_action = 'Po PRO udělat malý validation run, ne okamžitý full harvest.'
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'players';

-- -------------------------------------------------
-- API-SPORT / API-BASKETBALL / API-VOLLEYBALL a podobné
-- základní skeleton provider
-- -------------------------------------------------
UPDATE ops.provider_entity_coverage
SET
    coverage_status     = CASE
                            WHEN entity IN ('leagues', 'teams', 'fixtures') THEN 'tech_ready'
                            ELSE 'planned'
                          END,
    provider_priority   = 1,
    merge_priority      = 1,
    fetch_priority      = CASE
                            WHEN entity = 'leagues'  THEN 10
                            WHEN entity = 'teams'    THEN 20
                            WHEN entity = 'fixtures' THEN 30
                            WHEN entity = 'players'  THEN 50
                            WHEN entity = 'coaches'  THEN 60
                            WHEN entity = 'odds'     THEN 70
                            ELSE fetch_priority
                          END,
    quality_rating      = CASE
                            WHEN entity IN ('leagues', 'teams', 'fixtures') THEN 'medium'
                            ELSE 'low'
                          END,
    availability_scope  = 'limited_free',
    free_plan_supported = true,
    paid_plan_supported = true,
    expected_depth      = CASE
                            WHEN entity IN ('leagues', 'teams', 'fixtures') THEN 'basic'
                            ELSE 'basic'
                          END,
    is_primary_source   = true,
    is_fallback_source  = false,
    is_merge_source     = true,
    limitations         = 'Multisport provider vhodný hlavně pro základní skeleton dat.',
    next_action         = 'Po PRO prioritně stáhnout leagues/teams/fixtures a teprve potom testovat další entity.'
WHERE provider IN (
        'api_sport',
        'api_basketball',
        'api_volleyball',
        'api_handball',
        'api_baseball',
        'api_rugby',
        'api_cricket',
        'api_field_hockey',
        'api_american_football'
    )
  AND entity IN ('leagues', 'teams', 'fixtures', 'players', 'coaches', 'odds');

UPDATE ops.provider_entity_coverage
SET
    coverage_status = 'planned',
    quality_rating = 'low',
    expected_depth = 'basic',
    limitations = 'Odds/players/coaches jsou zatím slabé nebo neověřené.',
    next_action = 'Neřešit jako první harvest v PRO režimu; nejdřív základní data.'
WHERE provider IN (
        'api_sport',
        'api_basketball',
        'api_volleyball',
        'api_handball',
        'api_baseball',
        'api_rugby',
        'api_cricket',
        'api_field_hockey',
        'api_american_football'
    )
  AND entity IN ('players', 'coaches', 'odds');

-- -------------------------------------------------
-- Placeholder sporty / budoucí provider testy
-- -------------------------------------------------
UPDATE ops.provider_entity_coverage
SET
    coverage_status     = 'planned',
    provider_priority   = 50,
    merge_priority      = 50,
    fetch_priority      = 50,
    quality_rating      = 'unknown',
    availability_scope  = 'paid_only',
    free_plan_supported = false,
    paid_plan_supported = true,
    expected_depth      = 'unknown',
    is_primary_source   = false,
    is_fallback_source  = true,
    is_merge_source     = true,
    limitations         = 'Budoucí provider placeholder. Vyžaduje ověření coverage a ceny.',
    next_action         = 'Později validovat business vhodnost a technickou integraci.'
WHERE provider IN ('api_tennis', 'api_mma', 'api_darts', 'api_esports')
  AND entity IN ('leagues', 'teams', 'fixtures', 'players', 'coaches', 'odds', 'rankings');

-- -------------------------------------------------
-- Budoucí providery - INSERT placeholder coverage
-- -------------------------------------------------
INSERT INTO ops.provider_entity_coverage (
    provider,
    sport_code,
    entity,
    coverage_status,
    is_enabled,
    provider_priority,
    merge_priority,
    fetch_priority,
    quality_rating,
    availability_scope,
    free_plan_supported,
    paid_plan_supported,
    expected_depth,
    is_primary_source,
    is_fallback_source,
    is_merge_source,
    notes,
    limitations,
    next_action
)
SELECT *
FROM (
    VALUES
    ('sportdataapi', 'FB', 'leagues',  'planned', true, 3, 3, 30, 'medium', 'paid_only', false, true, 'extended', false, true, true, 'Budoucí doplňkový provider pro fotbal.', 'Nutno otestovat coverage a cenu.', 'Později ověřit a porovnat s api_football.'),
    ('sportdataapi', 'FB', 'teams',    'planned', true, 3, 3, 31, 'medium', 'paid_only', false, true, 'extended', false, true, true, 'Budoucí doplňkový provider pro fotbal.', 'Nutno otestovat coverage a cenu.', 'Později ověřit a porovnat s api_football.'),
    ('sportdataapi', 'FB', 'fixtures', 'planned', true, 3, 3, 32, 'medium', 'paid_only', false, true, 'extended', false, true, true, 'Budoucí doplňkový provider pro fotbal.', 'Nutno otestovat coverage a cenu.', 'Později ověřit a porovnat s api_football.'),
    ('sportdataapi', 'FB', 'odds',     'planned', true, 2, 2, 15, 'medium', 'paid_only', false, true, 'extended', false, true, true, 'Budoucí odds doplněk pro fotbal.', 'Nutno porovnat s TheOdds.', 'Později udělat coverage test.'),

    ('pinnacle',     'FB', 'odds',     'planned', true, 2, 2, 12, 'high',   'paid_only', false, true, 'deep',     false, true, true, 'Budoucí sharp odds provider.', 'Vyžaduje samostatnou integraci a účet.', 'Později ověřit obchodní a technickou vhodnost.'),
    ('betfair',      'FB', 'odds',     'planned', true, 3, 3, 13, 'high',   'paid_only', false, true, 'deep',     false, true, true, 'Budoucí exchange odds provider.', 'Vyžaduje samostatnou integraci a účet.', 'Později ověřit obchodní a technickou vhodnost.'),
    ('sportradar',   'FB', 'fixtures', 'planned', true, 5, 5, 50, 'high',   'paid_only', false, true, 'deep',     false, true, true, 'Enterprise provider placeholder.', 'Pravděpodobně drahé enterprise řešení.', 'Pouze dlouhodobá budoucnost.')
) AS v(
    provider,
    sport_code,
    entity,
    coverage_status,
    is_enabled,
    provider_priority,
    merge_priority,
    fetch_priority,
    quality_rating,
    availability_scope,
    free_plan_supported,
    paid_plan_supported,
    expected_depth,
    is_primary_source,
    is_fallback_source,
    is_merge_source,
    notes,
    limitations,
    next_action
)
ON CONFLICT (provider, sport_code, entity) DO UPDATE
SET
    coverage_status     = EXCLUDED.coverage_status,
    is_enabled          = EXCLUDED.is_enabled,
    provider_priority   = EXCLUDED.provider_priority,
    merge_priority      = EXCLUDED.merge_priority,
    fetch_priority      = EXCLUDED.fetch_priority,
    quality_rating      = EXCLUDED.quality_rating,
    availability_scope  = EXCLUDED.availability_scope,
    free_plan_supported = EXCLUDED.free_plan_supported,
    paid_plan_supported = EXCLUDED.paid_plan_supported,
    expected_depth      = EXCLUDED.expected_depth,
    is_primary_source   = EXCLUDED.is_primary_source,
    is_fallback_source  = EXCLUDED.is_fallback_source,
    is_merge_source     = EXCLUDED.is_merge_source,
    notes               = EXCLUDED.notes,
    limitations         = EXCLUDED.limitations,
    next_action         = EXCLUDED.next_action,
    updated_at          = now();