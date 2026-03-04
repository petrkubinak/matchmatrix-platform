-- 2026-03-02 EU leagues import (api_football) – FIXED (no women leagues, no regional/group leagues)
-- Save as: C:\MATCHMATRIX-PLATFORM\db\imports\2026-03-02_eu_leagues_api_football_apply.sql


-- 0) Source list (EU starter whitelist)
CREATE TEMP TABLE tmp_eu_src (
  bucket text,
  country text,
  country_code text,
  provider_league_id integer,
  league_name text,
  league_type text
) ON COMMIT DROP;

INSERT INTO tmp_eu_src(bucket,country,country_code,provider_league_id,league_name,league_type) VALUES
  ('EU_national_1_2','Albania','AL', 310, 'Superliga','League'),
  ('EU_national_1_2','Albania','AL', 311, '1st Division','League'),
  ('EU_national_1_2','Andorra','AD', 312, '1a Divisió','League'),
  ('EU_national_1_2','Andorra','AD', 313, '2a Divisió','League'),
  ('EU_national_1_2','Armenia','AM', 342, 'Premier League','League'),
  ('EU_national_1_2','Armenia','AM', 343, 'First League','League'),
  ('EU_national_1_2','Austria','AT', 218, 'Bundesliga','League'),
  ('EU_national_1_2','Austria','AT', 219, '2. Liga','League'),
  ('EU_national_1_2','Azerbaijan','AZ', 418, 'Birinci Dasta','League'),
  ('EU_national_1_2','Azerbaijan','AZ', 419, 'Premyer Liqa','League'),
  ('EU_national_1_2','Belarus','BY', 116, 'Premier League','League'),
  ('EU_national_1_2','Belarus','BY', 117, '1. Division','League'),
  -- Belgium national 1–2 (replaces regional amateur groups 148/149)
  ('EU_national_1_2','Belgium','BE', 144, 'First Division A','League'),
  ('EU_national_1_2','Belgium','BE', 145, 'First Division B','League'),
  -- Bosnia national 1 only (replaces entity/region league 316)
  ('EU_national_1_2','Bosnia','BA', 315, 'Premijer Liga','League'),
  ('EU_national_1_2','Bulgaria','BG', 172, 'First League','League'),
  ('EU_national_1_2','Bulgaria','BG', 173, 'Second League','League'),
  ('EU_national_1_2','Croatia','HR', 210, 'HNL','League'),
  ('EU_national_1_2','Croatia','HR', 946, 'Second NL','League'),
  ('EU_national_1_2','Cyprus','CY', 318, '1. Division','League'),
  ('EU_national_1_2','Cyprus','CY', 319, '2. Division','League'),
  ('EU_national_1_2','Czech-Republic','CZ', 345, 'Czech Liga','League'),
  ('EU_national_1_2','Czech-Republic','CZ', 346, 'FNL','League'),
  ('EU_national_1_2','Denmark','DK', 119, 'Superliga','League'),
  ('EU_national_1_2','Denmark','DK', 120, '1. Division','League'),
  ('EU_national_1_2','Estonia','EE', 328, 'Esiliiga A','League'),
  ('EU_national_1_2','Estonia','EE', 329, 'Meistriliiga','League'),
  ('EU_national_1_2','Finland','FI', 244, 'Veikkausliiga','League'),
  ('EU_national_1_2','Finland','FI', 245, 'Ykkönen','League'),
  -- France 1–2 (replaces women league 64)
  ('EU_national_1_2','France','FR', 61, 'Ligue 1','League'),
  ('EU_national_1_2','France','FR', 62, 'Ligue 2','League'),
  ('EU_national_1_2','Georgia','GE', 326, 'Erovnuli Liga 2','League'),
  ('EU_national_1_2','Georgia','GE', 327, 'Erovnuli Liga','League'),
  -- Germany 1–2 (replaces women league 82)
  ('EU_national_1_2','Germany','DE', 78, 'Bundesliga','League'),
  ('EU_national_1_2','Germany','DE', 79, '2. Bundesliga','League'),
  ('EU_national_1_2','Greece','GR', 197, 'Super League 1','League'),
  ('EU_national_1_2','Greece','GR', 494, 'Super League 2','League'),
  ('EU_national_1_2','Hungary','HU', 271, 'NB I','League'),
  ('EU_national_1_2','Hungary','HU', 272, 'NB II','League'),
  -- Iceland 1–2 (replaces wrong tier 166 = 2.Deild)
  ('EU_national_1_2','Iceland','IS', 164, 'Úrvalsdeild','League'),
  ('EU_national_1_2','Iceland','IS', 165, '1. Deild','League'),
  ('EU_national_1_2','Italy','IT', 135, 'Serie A','League'),
  ('EU_national_1_2','Italy','IT', 136, 'Serie B','League'),
  ('EU_national_1_2','Kazakhstan','KZ', 388, '1. Division','League'),
  ('EU_national_1_2','Kazakhstan','KZ', 389, 'Premier League','League'),
  ('EU_national_1_2','Kosovo','XK', 664, 'Superliga','League'),
  ('EU_national_1_2','Kosovo','XK', 1195, 'Liga E Pare','League'),
  ('EU_national_1_2','Latvia','LV', 364, '1. Liga','League'),
  ('EU_national_1_2','Latvia','LV', 365, 'Virsliga','League'),
  ('EU_national_1_2','Lithuania','LT', 361, '1 Lyga','League'),
  ('EU_national_1_2','Lithuania','LT', 362, 'A Lyga','League'),
  ('EU_national_1_2','Luxembourg','LU', 261, 'National Division','League'),
  ('EU_national_1_2','Macedonia','MK', 371, 'First League','League'),
  ('EU_national_1_2','Macedonia','MK', 372, 'Second League','League'),
  ('EU_national_1_2','Malta','MT', 392, 'Challenge League','League'),
  ('EU_national_1_2','Malta','MT', 393, 'Premier League','League'),
  ('EU_national_1_2','Moldova','MD', 394, 'Super Liga','League'),
  ('EU_national_1_2','Moldova','MD', 395, 'Liga 1','League'),
  ('EU_national_1_2','Montenegro','ME', 355, 'First League','League'),
  ('EU_national_1_2','Montenegro','ME', 356, 'Second League','League'),
  ('EU_national_1_2','Netherlands','NL', 88, 'Eredivisie','League'),
  ('EU_national_1_2','Netherlands','NL', 89, 'Eerste Divisie','League'),
  ('EU_national_1_2','Norway','NO', 103, 'Eliteserien','League'),
  ('EU_national_1_2','Norway','NO', 104, '1. Division','League'),
  ('EU_national_1_2','Poland','PL', 106, 'Ekstraklasa','League'),
  ('EU_national_1_2','Poland','PL', 107, 'I Liga','League'),
  ('EU_national_1_2','Portugal','PT', 94, 'Primeira Liga','League'),
  ('EU_national_1_2','Portugal','PT', 95, 'Segunda Liga','League'),
  -- Romania 1–2 (replaces women league 728)
  ('EU_national_1_2','Romania','RO', 283, 'Liga I','League'),
  ('EU_national_1_2','Romania','RO', 284, 'Liga II','League'),
  ('EU_national_1_2','Russia','RU', 235, 'Premier League','League'),
  ('EU_national_1_2','Russia','RU', 236, 'First League','League'),
  ('EU_national_1_2','San-Marino','SM', 404, 'Campionato','League'),
  ('EU_national_1_2','Serbia','RS', 286, 'Super Liga','League'),
  ('EU_national_1_2','Serbia','RS', 287, 'Prva Liga','League'),
  ('EU_national_1_2','Slovakia','SK', 332, 'Super Liga','League'),
  ('EU_national_1_2','Slovakia','SK', 506, '2. liga','League'),
  ('EU_national_1_2','Slovenia','SI', 373, '1. SNL','League'),
  ('EU_national_1_2','Slovenia','SI', 374, '2. SNL','League'),
  ('EU_national_1_2','Spain','ES', 140, 'La Liga','League'),
  ('EU_national_1_2','Spain','ES', 141, 'Segunda División','League'),
  -- Sweden 1–2 (replaces women league 549)
  ('EU_national_1_2','Sweden','SE', 113, 'Allsvenskan','League'),
  ('EU_national_1_2','Sweden','SE', 114, 'Superettan','League'),
  ('EU_national_1_2','Switzerland','CH', 207, 'Super League','League'),
  ('EU_national_1_2','Switzerland','CH', 208, 'Challenge League','League'),
  -- Turkey 1–2 (removes grouped 205)
  ('EU_national_1_2','Turkey','TR', 203, 'Süper Lig','League'),
  ('EU_national_1_2','Turkey','TR', 204, '1. Lig','League'),
  ('EU_national_1_2','Ukraine','UA', 333, 'Premier League','League'),
  ('EU_national_1_2','Ukraine','UA', 334, 'Persha Liga','League'),
  ('UKI_EN_1_4','England','GB-ENG', 39, 'Premier League','League'),
  ('UKI_EN_1_4','England','GB-ENG', 40, 'Championship','League'),
  ('UKI_EN_1_4','England','GB-ENG', 41, 'League One','League'),
  ('UKI_EN_1_4','England','GB-ENG', 42, 'League Two','League'),
  ('UKI_islands_1_2','Ireland','IE', 357, 'Premier Division','League'),
  ('UKI_islands_1_2','Ireland','IE', 358, 'First Division','League'),
  ('UKI_islands_1_2','Northern-Ireland','GB-NIR', 407, 'Championship','League'),
  ('UKI_islands_1_2','Northern-Ireland','GB-NIR', 408, 'Premiership','League'),
  ('UKI_islands_1_2','Scotland','GB-SCT', 179, 'Premiership','League'),
  ('UKI_islands_1_2','Scotland','GB-SCT', 180, 'Championship','League'),
  ('UKI_islands_1_2','Wales','GB-WLS', 110, 'Premier League','League'),
  ('UKI_islands_1_2','Wales','GB-WLS', 111, 'FAW Championship','League');

-- 1) Canonical mapping via public.leagues (ext_source/ext_league_id)
CREATE TEMP TABLE tmp_eu_canon AS
SELECT
  s.*,
  l.id AS canonical_league_id
FROM tmp_eu_src s
LEFT JOIN public.leagues l
  ON l.ext_source = 'api_football'
 AND l.ext_league_id::text = s.provider_league_id::text;

-- 2) Hard fail if any league is missing from public.leagues
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM tmp_eu_canon WHERE canonical_league_id IS NULL) THEN
    RAISE EXCEPTION 'Missing canonical leagues in public.leagues for some provider_league_id (api_football).';
  END IF;
END $$;

-- 3) whitelist (ops.league_import_plan)
INSERT INTO ops.league_import_plan(
  provider, provider_league_id, sport_code, season,
  enabled, tier, fixtures_days_back, fixtures_days_forward, odds_days_forward,
  notes, updated_at
)
SELECT
  'api_football',
  c.provider_league_id,
  'football',
  '2024',
  true,
  1,
  2,
  7,
  3,
  ('EU|'||c.bucket||'|'||c.country_code||'|'||c.league_name),
  now()
FROM tmp_eu_canon c
ON CONFLICT (provider, provider_league_id, season) DO UPDATE
SET
  enabled = EXCLUDED.enabled,
  tier = EXCLUDED.tier,
  fixtures_days_back = EXCLUDED.fixtures_days_back,
  fixtures_days_forward = EXCLUDED.fixtures_days_forward,
  odds_days_forward = EXCLUDED.odds_days_forward,
  notes = EXCLUDED.notes,
  updated_at = now();

-- 4) provider mapping (public.league_provider_map)
-- NOTE: in this DB schema, the canonical league FK column is `league_id` (not canonical_league_id).
-- Unique key is (provider, provider_league_id).

INSERT INTO public.league_provider_map(
  league_id,
  provider,
  provider_league_id,
  created_at,
  updated_at
)
SELECT
  c.canonical_league_id AS league_id,
  'api_football'::text AS provider,
  c.provider_league_id,
  now(),
  now()
FROM tmp_eu_canon c
WHERE c.canonical_league_id IS NOT NULL
ON CONFLICT (provider, provider_league_id) DO UPDATE
SET
  league_id = EXCLUDED.league_id,
  updated_at = now();

-- 5) runtime targets (ops.ingest_targets)
INSERT INTO ops.ingest_targets(
  sport_code, canonical_league_id,
  provider, provider_league_id,
  season, enabled, tier,
  fixtures_days_back, fixtures_days_forward, odds_days_forward,
  notes, run_group, updated_at
)
SELECT
  'football',
  c.canonical_league_id,
  'api_football',
  c.provider_league_id,
  '2024',
  true,
  1,
  2,
  7,
  3,
  ('EU|'||c.bucket||'|'||c.country_code||'|'||c.league_name),
  c.bucket,
  now()
FROM tmp_eu_canon c
ON CONFLICT (provider, provider_league_id) DO UPDATE
SET
  canonical_league_id = EXCLUDED.canonical_league_id,
  season = EXCLUDED.season,
  enabled = EXCLUDED.enabled,
  tier = EXCLUDED.tier,
  fixtures_days_back = EXCLUDED.fixtures_days_back,
  fixtures_days_forward = EXCLUDED.fixtures_days_forward,
  odds_days_forward = EXCLUDED.odds_days_forward,
  notes = EXCLUDED.notes,
  run_group = EXCLUDED.run_group,
  updated_at = now();


-- Post-checks:
-- SELECT run_group, COUNT(*) FROM ops.ingest_targets WHERE provider='api_football' GROUP BY 1 ORDER BY 2 DESC;
-- SELECT COUNT(*) AS missing FROM tmp_eu_canon WHERE canonical_league_id IS NULL;