-- 013_seed_import_plan_eu_exact_v1.sql
-- Zdroj: public.leagues (ext_source='api_football') = máme přesné názvy + ext_league_id
-- Cíl: ops.league_import_plan (jen fotbal) pro:
--  - GB-ENG: 1-4 divize
--  - 1-2 ligy: SI, SK, HR, BG, DK, CY, RO, GB-SCT, GB-WAL, GB-NIR, IE, IL, GR, HU
-- (Velké trhy ES/DE/IT/FR/NL/PT/BE/AT/CH/CZ/PL/TR dořešíme druhým seedem 1-3 přes názvy.)

BEGIN;

WITH wanted AS (
  -- country, exact league name, api_football league_id (ext_league_id), tier
  SELECT * FROM (VALUES
    -- England (1-4)
    ('England','Premier League','39',1),
    ('England','Championship','40',2),
    ('England','League One','41',3),
    ('England','League Two','42',4),

    -- Scotland (1-2)
    ('Scotland','Premiership','179',1),
    ('Scotland','Championship','180',2),

    -- Northern Ireland (1-2)
    ('Northern-Ireland','Premiership','408',1),
    ('Northern-Ireland','Championship','407',2),

    -- Wales (1-2)
    ('Wales','Premier League','110',1),
    ('Wales','FAW Championship','111',2),

    -- Ireland (1-2)
    ('Ireland','Premier Division','357',1),
    ('Ireland','First Division','358',2),

    -- Israel (1-2)
    ('Israel','Ligat Ha''al','383',1),
    ('Israel','Liga Leumit','382',2),

    -- Greece (1-2)
    ('Greece','Super League 1','197',1),
    ('Greece','Super League 2','494',2),

    -- Hungary (1-2)
    ('Hungary','NB I','271',1),
    ('Hungary','NB II','272',2),

    -- Slovakia (1-2)
    ('Slovakia','Super Liga','332',1),
    ('Slovakia','2. liga','506',2),

    -- Slovenia (1-2)
    ('Slovenia','1. SNL','373',1),
    ('Slovenia','2. SNL','374',2),

    -- Croatia (1-2)
    ('Croatia','HNL','210',1),
    ('Croatia','First NL','211',2),

    -- Bulgaria (1-2)
    ('Bulgaria','First League','172',1),
    ('Bulgaria','Second League','173',2),

    -- Denmark (1-2)
    ('Denmark','Superliga','119',1),
    ('Denmark','1. Division','120',2),

    -- Cyprus (1-2)
    ('Cyprus','1. Division','318',1),
    ('Cyprus','2. Division','319',2),

    -- Romania (1-2)
    ('Romania','Liga I','283',1),
    ('Romania','Liga II','284',2)
  ) AS t(country, league_name, provider_league_id, tier)
),
src AS (
  SELECT
    'api_football'::text AS provider,
    w.provider_league_id::text AS provider_league_id,
    'football'::text AS sport_code,
    ''::text AS season,
    true AS enabled,
    w.tier::int AS tier,
    2::int AS fixtures_days_back,
    3::int AS fixtures_days_forward,
    0::int AS odds_days_forward,
    ('EU exact v1 | ' || w.country || ' | tier=' || w.tier || ' | ' || w.league_name)::text AS notes
  FROM wanted w
  JOIN public.leagues l
    ON l.ext_source='api_football'
   AND l.ext_league_id::text = w.provider_league_id::text
   AND l.country = w.country
   AND l.name = w.league_name
   AND l.sport_id = 1
)
INSERT INTO ops.league_import_plan
(provider, provider_league_id, sport_code, season, enabled, tier,
 fixtures_days_back, fixtures_days_forward, odds_days_forward, notes, created_at, updated_at)
SELECT
  provider, provider_league_id, sport_code, season, enabled, tier,
  fixtures_days_back, fixtures_days_forward, odds_days_forward, notes, now(), now()
FROM src
ON CONFLICT (provider, provider_league_id, season)
DO UPDATE SET
  enabled = EXCLUDED.enabled,
  tier = EXCLUDED.tier,
  fixtures_days_back = EXCLUDED.fixtures_days_back,
  fixtures_days_forward = EXCLUDED.fixtures_days_forward,
  odds_days_forward = EXCLUDED.odds_days_forward,
  notes = EXCLUDED.notes,
  updated_at = now();

COMMIT;