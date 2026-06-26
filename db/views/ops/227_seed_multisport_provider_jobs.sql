-- ============================================
-- 227_seed_multisport_provider_jobs.sql
-- MatchMatrix
-- Seed provider_jobs pro nové sporty ve stylu HK/BK
-- ============================================

BEGIN;

-- =========================================================
-- TENNIS
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_tennis','TN','api_tennis__TN_CORE__leagues',   'leagues',   'fast',   true,  4010, 50, 20, 3, 0, NULL, NULL, 'TN CORE leagues'),
('api_tennis','TN','api_tennis__TN_CORE__fixtures',  'fixtures',  'fast',   true,  4020, 50, 20, 3, 0, 7,    14,   'TN CORE fixtures'),
('api_tennis','TN','api_tennis__TN_CORE__players',   'players',   'fast',   true,  4030, 50, 20, 3, 0, NULL, NULL, 'TN CORE players'),
('api_tennis','TN','api_tennis__TN_CORE__rankings',  'rankings',  'medium', true,  4040, 50, 20, 3, 0, NULL, NULL, 'TN CORE rankings'),
('api_tennis','TN','api_tennis__TN_CORE__odds',      'odds',      'fast',   false, 4050, 50, 20, 3, 0, 0,    3,    'TN CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- MMA
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_mma','MMA','api_mma__MMA_CORE__leagues',   'leagues',   'fast',   true,  5010, 50, 20, 3, 0, NULL, NULL, 'MMA CORE promotions/events'),
('api_mma','MMA','api_mma__MMA_CORE__fixtures',  'fixtures',  'fast',   true,  5020, 50, 20, 3, 0, 30,   30,   'MMA CORE bouts'),
('api_mma','MMA','api_mma__MMA_CORE__players',   'players',   'fast',   true,  5030, 50, 20, 3, 0, NULL, NULL, 'MMA CORE fighters'),
('api_mma','MMA','api_mma__MMA_CORE__rankings',  'rankings',  'medium', true,  5040, 50, 20, 3, 0, NULL, NULL, 'MMA CORE rankings'),
('api_mma','MMA','api_mma__MMA_CORE__odds',      'odds',      'fast',   false, 5050, 50, 20, 3, 0, 0,    7,    'MMA CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- VOLLEYBALL
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_volleyball','VB','api_volleyball__VB_CORE__leagues',   'leagues',   'fast',   true,  6010, 50, 20, 3, 0, NULL, NULL, 'VB CORE leagues'),
('api_volleyball','VB','api_volleyball__VB_CORE__teams',     'teams',     'fast',   true,  6020, 50, 20, 3, 0, NULL, NULL, 'VB CORE teams'),
('api_volleyball','VB','api_volleyball__VB_CORE__fixtures',  'fixtures',  'fast',   true,  6030, 50, 20, 3, 0, 7,    14,   'VB CORE fixtures'),
('api_volleyball','VB','api_volleyball__VB_CORE__players',   'players',   'medium', true,  6040, 50, 20, 3, 0, NULL, NULL, 'VB CORE players'),
('api_volleyball','VB','api_volleyball__VB_CORE__coaches',   'coaches',   'medium', true,  6050, 50, 20, 3, 0, NULL, NULL, 'VB CORE coaches'),
('api_volleyball','VB','api_volleyball__VB_CORE__odds',      'odds',      'fast',   false, 6060, 50, 20, 3, 0, 0,    3,    'VB CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- HANDBALL
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_handball','HB','api_handball__HB_CORE__leagues',   'leagues',   'fast',   true,  7010, 50, 20, 3, 0, NULL, NULL, 'HB CORE leagues'),
('api_handball','HB','api_handball__HB_CORE__teams',     'teams',     'fast',   true,  7020, 50, 20, 3, 0, NULL, NULL, 'HB CORE teams'),
('api_handball','HB','api_handball__HB_CORE__fixtures',  'fixtures',  'fast',   true,  7030, 50, 20, 3, 0, 7,    14,   'HB CORE fixtures'),
('api_handball','HB','api_handball__HB_CORE__players',   'players',   'medium', true,  7040, 50, 20, 3, 0, NULL, NULL, 'HB CORE players'),
('api_handball','HB','api_handball__HB_CORE__coaches',   'coaches',   'medium', true,  7050, 50, 20, 3, 0, NULL, NULL, 'HB CORE coaches'),
('api_handball','HB','api_handball__HB_CORE__odds',      'odds',      'fast',   false, 7060, 50, 20, 3, 0, 0,    3,    'HB CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- BASEBALL
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_baseball','BSB','api_baseball__BSB_CORE__leagues',   'leagues',   'fast',   true,  8010, 50, 20, 3, 0, NULL, NULL, 'BSB CORE leagues'),
('api_baseball','BSB','api_baseball__BSB_CORE__teams',     'teams',     'fast',   true,  8020, 50, 20, 3, 0, NULL, NULL, 'BSB CORE teams'),
('api_baseball','BSB','api_baseball__BSB_CORE__fixtures',  'fixtures',  'fast',   true,  8030, 50, 20, 3, 0, 7,    14,   'BSB CORE fixtures'),
('api_baseball','BSB','api_baseball__BSB_CORE__players',   'players',   'medium', true,  8040, 50, 20, 3, 0, NULL, NULL, 'BSB CORE players'),
('api_baseball','BSB','api_baseball__BSB_CORE__coaches',   'coaches',   'medium', true,  8050, 50, 20, 3, 0, NULL, NULL, 'BSB CORE coaches'),
('api_baseball','BSB','api_baseball__BSB_CORE__odds',      'odds',      'fast',   false, 8060, 50, 20, 3, 0, 0,    3,    'BSB CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- RUGBY
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_rugby','RGB','api_rugby__RGB_CORE__leagues',   'leagues',   'fast',   true,  9010, 50, 20, 3, 0, NULL, NULL, 'RGB CORE leagues'),
('api_rugby','RGB','api_rugby__RGB_CORE__teams',     'teams',     'fast',   true,  9020, 50, 20, 3, 0, NULL, NULL, 'RGB CORE teams'),
('api_rugby','RGB','api_rugby__RGB_CORE__fixtures',  'fixtures',  'fast',   true,  9030, 50, 20, 3, 0, 7,    14,   'RGB CORE fixtures'),
('api_rugby','RGB','api_rugby__RGB_CORE__players',   'players',   'medium', true,  9040, 50, 20, 3, 0, NULL, NULL, 'RGB CORE players'),
('api_rugby','RGB','api_rugby__RGB_CORE__coaches',   'coaches',   'medium', true,  9050, 50, 20, 3, 0, NULL, NULL, 'RGB CORE coaches'),
('api_rugby','RGB','api_rugby__RGB_CORE__odds',      'odds',      'fast',   false, 9060, 50, 20, 3, 0, 0,    3,    'RGB CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- CRICKET
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_cricket','CK','api_cricket__CK_CORE__leagues',   'leagues',   'fast',   true,  10010, 50, 20, 3, 0, NULL, NULL, 'CK CORE leagues'),
('api_cricket','CK','api_cricket__CK_CORE__teams',     'teams',     'fast',   true,  10020, 50, 20, 3, 0, NULL, NULL, 'CK CORE teams'),
('api_cricket','CK','api_cricket__CK_CORE__fixtures',  'fixtures',  'fast',   true,  10030, 50, 20, 3, 0, 7,    14,   'CK CORE fixtures'),
('api_cricket','CK','api_cricket__CK_CORE__players',   'players',   'medium', true,  10040, 50, 20, 3, 0, NULL, NULL, 'CK CORE players'),
('api_cricket','CK','api_cricket__CK_CORE__coaches',   'coaches',   'medium', true,  10050, 50, 20, 3, 0, NULL, NULL, 'CK CORE coaches'),
('api_cricket','CK','api_cricket__CK_CORE__odds',      'odds',      'fast',   false, 10060, 50, 20, 3, 0, 0,    3,    'CK CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- FIELD HOCKEY
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_field_hockey','FH','api_field_hockey__FH_CORE__leagues',   'leagues',   'fast',   true,  11010, 50, 20, 3, 0, NULL, NULL, 'FH CORE leagues'),
('api_field_hockey','FH','api_field_hockey__FH_CORE__teams',     'teams',     'fast',   true,  11020, 50, 20, 3, 0, NULL, NULL, 'FH CORE teams'),
('api_field_hockey','FH','api_field_hockey__FH_CORE__fixtures',  'fixtures',  'fast',   true,  11030, 50, 20, 3, 0, 7,    14,   'FH CORE fixtures'),
('api_field_hockey','FH','api_field_hockey__FH_CORE__players',   'players',   'medium', true,  11040, 50, 20, 3, 0, NULL, NULL, 'FH CORE players'),
('api_field_hockey','FH','api_field_hockey__FH_CORE__coaches',   'coaches',   'medium', true,  11050, 50, 20, 3, 0, NULL, NULL, 'FH CORE coaches'),
('api_field_hockey','FH','api_field_hockey__FH_CORE__odds',      'odds',      'fast',   false, 11060, 50, 20, 3, 0, 0,    3,    'FH CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- AMERICAN FOOTBALL
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_american_football','AFB','api_american_football__AFB_CORE__leagues',   'leagues',   'fast',   true,  12010, 50, 20, 3, 0, NULL, NULL, 'AFB CORE leagues'),
('api_american_football','AFB','api_american_football__AFB_CORE__teams',     'teams',     'fast',   true,  12020, 50, 20, 3, 0, NULL, NULL, 'AFB CORE teams'),
('api_american_football','AFB','api_american_football__AFB_CORE__fixtures',  'fixtures',  'fast',   true,  12030, 50, 20, 3, 0, 7,    14,   'AFB CORE fixtures'),
('api_american_football','AFB','api_american_football__AFB_CORE__players',   'players',   'medium', true,  12040, 50, 20, 3, 0, NULL, NULL, 'AFB CORE players'),
('api_american_football','AFB','api_american_football__AFB_CORE__coaches',   'coaches',   'medium', true,  12050, 50, 20, 3, 0, NULL, NULL, 'AFB CORE coaches'),
('api_american_football','AFB','api_american_football__AFB_CORE__odds',      'odds',      'fast',   false, 12060, 50, 20, 3, 0, 0,    3,    'AFB CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- ESPORTS
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_esports','ESP','api_esports__ESP_CORE__leagues',   'leagues',   'fast',   true,  13010, 50, 20, 3, 0, NULL, NULL, 'ESP CORE leagues'),
('api_esports','ESP','api_esports__ESP_CORE__fixtures',  'fixtures',  'fast',   true,  13020, 50, 20, 3, 0, 7,    14,   'ESP CORE fixtures'),
('api_esports','ESP','api_esports__ESP_CORE__players',   'players',   'medium', true,  13030, 50, 20, 3, 0, NULL, NULL, 'ESP CORE players'),
('api_esports','ESP','api_esports__ESP_CORE__coaches',   'coaches',   'medium', true,  13040, 50, 20, 3, 0, NULL, NULL, 'ESP CORE coaches'),
('api_esports','ESP','api_esports__ESP_CORE__odds',      'odds',      'fast',   false, 13050, 50, 20, 3, 0, 0,    3,    'ESP CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

-- =========================================================
-- DARTS
-- =========================================================
INSERT INTO ops.provider_jobs
(provider, sport_code, job_code, endpoint_code, ingest_mode, enabled, priority, batch_size, max_requests_per_run, retry_limit, cooldown_seconds, days_back, days_forward, notes)
VALUES
('api_darts','DRT','api_darts__DRT_CORE__leagues',   'leagues',   'fast',   true,  14010, 50, 20, 3, 0, NULL, NULL, 'DRT CORE tournaments'),
('api_darts','DRT','api_darts__DRT_CORE__fixtures',  'fixtures',  'fast',   true,  14020, 50, 20, 3, 0, 7,    14,   'DRT CORE fixtures'),
('api_darts','DRT','api_darts__DRT_CORE__players',   'players',   'medium', true,  14030, 50, 20, 3, 0, NULL, NULL, 'DRT CORE players'),
('api_darts','DRT','api_darts__DRT_CORE__rankings',  'rankings',  'medium', true,  14040, 50, 20, 3, 0, NULL, NULL, 'DRT CORE rankings'),
('api_darts','DRT','api_darts__DRT_CORE__odds',      'odds',      'fast',   false, 14050, 50, 20, 3, 0, 0,    3,    'DRT CORE odds disabled until paid API')
ON CONFLICT (provider, sport_code, job_code)
DO UPDATE SET
    endpoint_code        = EXCLUDED.endpoint_code,
    ingest_mode          = EXCLUDED.ingest_mode,
    enabled              = EXCLUDED.enabled,
    priority             = EXCLUDED.priority,
    batch_size           = EXCLUDED.batch_size,
    max_requests_per_run = EXCLUDED.max_requests_per_run,
    retry_limit          = EXCLUDED.retry_limit,
    cooldown_seconds     = EXCLUDED.cooldown_seconds,
    days_back            = EXCLUDED.days_back,
    days_forward         = EXCLUDED.days_forward,
    notes                = EXCLUDED.notes,
    updated_at           = NOW();

COMMIT;