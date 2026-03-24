-- ============================================
-- 230_seed_multisport_ingest_targets.sql
-- Multisport CORE targets - finální verze podle reálného schema
-- ============================================

BEGIN;

INSERT INTO ops.ingest_targets
(
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    fixtures_days_back,
    fixtures_days_forward,
    odds_days_forward,
    max_requests_per_run,
    notes,
    run_group
)
VALUES
    ('TN',  10001, 'api_tennis',            'ATP',        '2024', true, 1,  7, 14, 3, 20, 'ATP Tour',                 'TN_CORE'),
    ('TN',  10002, 'api_tennis',            'WTA',        '2024', true, 1,  7, 14, 3, 20, 'WTA Tour',                 'TN_CORE'),

    ('MMA', 11001, 'api_mma',               'UFC',        '2024', true, 1, 30, 30, 7, 20, 'UFC events',               'MMA_CORE'),

    ('VB',  12001, 'api_volleyball',        'FIVB',       '2024', true, 1,  7, 14, 3, 20, 'FIVB competitions',        'VB_CORE'),

    ('HB',  13001, 'api_handball',          'EHF',        '2024', true, 1,  7, 14, 3, 20, 'EHF competitions',         'HB_CORE'),

    ('BSB', 14001, 'api_baseball',          'MLB',        '2024', true, 1,  7, 14, 3, 20, 'MLB',                      'BSB_CORE'),

    ('RGB', 15001, 'api_rugby',             'SixNations', '2024', true, 1,  7, 14, 3, 20, 'Six Nations',              'RGB_CORE'),

    ('CK',  16001, 'api_cricket',           'IPL',        '2024', true, 1,  7, 14, 3, 20, 'Indian Premier League',    'CK_CORE'),

    ('FH',  17001, 'api_field_hockey',      'FIH',        '2024', true, 1,  7, 14, 3, 20, 'FIH competitions',         'FH_CORE'),

    ('AFB', 18001, 'api_american_football', 'NFL',        '2024', true, 1,  7, 14, 3, 20, 'NFL',                      'AFB_CORE'),

    ('ESP', 19001, 'api_esports',           'CSGO',       '2024', true, 1,  7, 14, 3, 20, 'CSGO tournaments',         'ESP_CORE'),

    ('DRT', 20001, 'api_darts',             'PDC',        '2024', true, 1,  7, 14, 3, 20, 'PDC tour',                 'DRT_CORE')
ON CONFLICT DO NOTHING;

COMMIT;

-- kontrola
SELECT sport_code, provider, canonical_league_id, provider_league_id, season, run_group, enabled
FROM ops.ingest_targets
WHERE sport_code IN ('TN','MMA','VB','HB','BSB','RGB','CK','FH','AFB','ESP','DRT')
ORDER BY sport_code, provider, canonical_league_id;