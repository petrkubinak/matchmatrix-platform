-- ============================================================
-- 136_hb_full_pipeline.sql
-- MatchMatrix - HB full pipeline
--
-- Kam ulozit:
-- C:\MatchMatrix-platform\db\sql\136_hb_full_pipeline.sql
--
-- Jak spustit:
-- DBeaver -> otevrit soubor -> spustit cely script
--
-- Co dela:
-- 1) doplni chybejici HB teams do staging.stg_provider_teams z fixtures fallbackem
-- 2) pripravi HB source teams z api_handball
-- 3) vytvori / opravi canonical HB teams
-- 4) doplni HB aliases
-- 5) opravi / doplni HB team_provider_map
-- 6) potvrdi HB canonical leagues z public.leagues
-- 7) vlozi HB fixtures do public.matches
-- 8) doplni league_id do HB matches
-- 9) vypise kontroly
--
-- Poznamka:
-- HB ma neuplny /teams endpoint, proto je soucasti scriptu
-- fallback "teams from fixtures". To je hlavni rozdil oproti BK/VB/AFB.
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 0) HB context
--    sport_id pro HB bereme bezpecne z existujicich HB lig,
--    jinak fallback na hodnotu 11 podle runtime mapy
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_hb_context;

CREATE TEMP TABLE tmp_hb_context AS
SELECT
    COALESCE(
        (
            SELECT l.sport_id
            FROM public.leagues l
            WHERE l.ext_source = 'api_handball'
            ORDER BY l.id
            LIMIT 1
        ),
        11
    ) AS sport_id;

SELECT * FROM tmp_hb_context;

-- ------------------------------------------------------------
-- 1) HB fallback teams from fixtures
--    doplni do staging.stg_provider_teams tymy,
--    ktere existuji ve fixtures, ale nevratil je /teams endpoint
-- ------------------------------------------------------------
INSERT INTO staging.stg_provider_teams (
    provider,
    sport_code,
    external_team_id,
    team_name,
    country_name,
    external_league_id,
    season,
    raw_payload_id,
    is_active
)
SELECT
    x.provider,
    x.sport_code,
    x.external_team_id,
    'UNKNOWN_' || x.external_team_id AS team_name,
    'UNKNOWN' AS country_name,
    MIN(x.external_league_id) AS external_league_id,
    MIN(x.season) AS season,
    MIN(x.raw_payload_id) AS raw_payload_id,
    TRUE AS is_active
FROM (
    SELECT
        sf.provider,
        sf.sport_code,
        sf.home_team_external_id AS external_team_id,
        sf.external_league_id,
        sf.season,
        sf.raw_payload_id
    FROM staging.stg_provider_fixtures sf
    WHERE sf.provider = 'api_handball'
      AND sf.sport_code = 'handball'
      AND sf.home_team_external_id IS NOT NULL
      AND btrim(sf.home_team_external_id) <> ''

    UNION ALL

    SELECT
        sf.provider,
        sf.sport_code,
        sf.away_team_external_id AS external_team_id,
        sf.external_league_id,
        sf.season,
        sf.raw_payload_id
    FROM staging.stg_provider_fixtures sf
    WHERE sf.provider = 'api_handball'
      AND sf.sport_code = 'handball'
      AND sf.away_team_external_id IS NOT NULL
      AND btrim(sf.away_team_external_id) <> ''
) x
LEFT JOIN staging.stg_provider_teams st
    ON st.provider = x.provider
   AND st.external_team_id = x.external_team_id
WHERE st.external_team_id IS NULL
GROUP BY
    x.provider,
    x.sport_code,
    x.external_team_id
ON CONFLICT (provider, external_team_id) DO NOTHING;

-- ------------------------------------------------------------
-- 2) HB source teams
--    preferujeme realna jmena pred UNKNOWN_* fallbackem
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_hb_src_teams;

CREATE TEMP TABLE tmp_hb_src_teams AS
SELECT DISTINCT ON (s.external_team_id)
       s.external_team_id,
       s.team_name,
       s.country_name,
       s.external_league_id,
       s.season,
       s.provider,
       s.sport_code,
       s.updated_at
FROM staging.stg_provider_teams s
WHERE s.provider = 'api_handball'
  AND s.sport_code = 'handball'
  AND s.external_team_id IS NOT NULL
  AND btrim(s.external_team_id) <> ''
  AND s.team_name IS NOT NULL
  AND btrim(s.team_name) <> ''
ORDER BY
    s.external_team_id,
    CASE
        WHEN s.team_name LIKE 'UNKNOWN_%' THEN 1
        ELSE 0
    END,
    s.updated_at DESC NULLS LAST,
    s.team_name;

-- ------------------------------------------------------------
-- 3) canonical HB teams
-- ------------------------------------------------------------
INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id
)
SELECT
    t.team_name,
    'api_handball',
    t.external_team_id
FROM tmp_hb_src_teams t
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams x
    WHERE x.ext_source = 'api_handball'
      AND x.ext_team_id = t.external_team_id
);

-- ------------------------------------------------------------
-- 3B) pokud uz canonical team existuje jako UNKNOWN_* a
--     ve stagingu uz mame realne jmeno, opravime canonical name
-- ------------------------------------------------------------
UPDATE public.teams pt
SET name = src.team_name
FROM tmp_hb_src_teams src
WHERE pt.ext_source = 'api_handball'
  AND pt.ext_team_id = src.external_team_id
  AND pt.name LIKE 'UNKNOWN_%'
  AND src.team_name NOT LIKE 'UNKNOWN_%';

-- ------------------------------------------------------------
-- 4) HB aliases
--    UNKNOWN_* aliase zamerne nevkladame
-- ------------------------------------------------------------
INSERT INTO public.team_aliases (
    team_id,
    alias,
    source
)
SELECT
    pt.id,
    src.team_name,
    'api_handball'
FROM tmp_hb_src_teams src
JOIN public.teams pt
  ON pt.ext_source = 'api_handball'
 AND pt.ext_team_id = src.external_team_id
WHERE src.team_name NOT LIKE 'UNKNOWN_%'
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_aliases a
      WHERE a.team_id = pt.id
        AND lower(btrim(a.alias)) = lower(btrim(src.team_name))
  );

-- ------------------------------------------------------------
-- 5) HB provider map
--    smazeme jen HB provider ids pro znamy source scope
--    a navazeme je znovu na HB canonical teams
-- ------------------------------------------------------------
DELETE FROM public.team_provider_map m
WHERE m.provider = 'api_handball'
  AND m.provider_team_id IN (
      SELECT external_team_id
      FROM tmp_hb_src_teams
  );

INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
SELECT
    pt.id,
    'api_handball',
    pt.ext_team_id
FROM public.teams pt
WHERE pt.ext_source = 'api_handball'
  AND EXISTS (
      SELECT 1
      FROM tmp_hb_src_teams s
      WHERE s.external_team_id = pt.ext_team_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m
      WHERE m.provider = 'api_handball'
        AND m.provider_team_id = pt.ext_team_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m2
      WHERE m2.team_id = pt.id
        AND m2.provider = 'api_handball'
  );

-- ------------------------------------------------------------
-- 6) HB source fixtures
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_hb_src_fixtures;

CREATE TEMP TABLE tmp_hb_src_fixtures AS
SELECT
    f.id,
    f.provider,
    f.sport_code,
    f.external_fixture_id,
    f.external_league_id,
    f.season,
    f.home_team_external_id,
    f.away_team_external_id,
    f.fixture_date,
    f.status_text,
    f.home_score,
    f.away_score,
    f.raw_payload_id,
    f.created_at,
    f.updated_at
FROM staging.stg_provider_fixtures f
WHERE f.provider = 'api_handball'
  AND f.sport_code = 'handball';

-- ------------------------------------------------------------
-- 7) merge HB fixtures do public.matches
--    league_id zatim nechame NULL a doplnime ho v dalsim kroku
-- ------------------------------------------------------------
INSERT INTO public.matches (
    league_id,
    home_team_id,
    away_team_id,
    kickoff,
    status,
    home_score,
    away_score,
    ext_source,
    ext_match_id,
    sport_id
)
SELECT
    NULL AS league_id,
    mph.team_id AS home_team_id,
    mpa.team_id AS away_team_id,
    f.fixture_date::timestamp AS kickoff,
    CASE
        WHEN upper(coalesce(f.status_text, '')) IN ('FT', 'AOT', 'FINISHED') THEN 'FINISHED'
        WHEN upper(coalesce(f.status_text, '')) IN ('NS', 'TBD', 'SCHEDULED') THEN 'SCHEDULED'
        WHEN upper(coalesce(f.status_text, '')) IN ('LIVE', '1H', '2H', 'HT', 'ET', 'P') THEN 'LIVE'
        WHEN upper(coalesce(f.status_text, '')) IN ('POSTP', 'PST', 'POSTPONED') THEN 'POSTPONED'
        WHEN upper(coalesce(f.status_text, '')) IN ('CANC', 'CAN', 'CANCELLED', 'ABD', 'AWD', 'INT') THEN 'CANCELLED'
        ELSE 'SCHEDULED'
    END AS status,
    CASE
        WHEN upper(coalesce(f.status_text, '')) IN ('FT', 'AOT', 'FINISHED')
         AND coalesce(f.home_score, '') ~ '^\d+$'
        THEN f.home_score::int
        ELSE NULL
    END AS home_score,
    CASE
        WHEN upper(coalesce(f.status_text, '')) IN ('FT', 'AOT', 'FINISHED')
         AND coalesce(f.away_score, '') ~ '^\d+$'
        THEN f.away_score::int
        ELSE NULL
    END AS away_score,
    f.provider AS ext_source,
    f.external_fixture_id AS ext_match_id,
    c.sport_id
FROM tmp_hb_src_fixtures f
CROSS JOIN tmp_hb_context c
JOIN public.team_provider_map mph
    ON mph.provider = f.provider
   AND mph.provider_team_id = f.home_team_external_id
JOIN public.team_provider_map mpa
    ON mpa.provider = f.provider
   AND mpa.provider_team_id = f.away_team_external_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.matches m
    WHERE m.ext_source = f.provider
      AND m.ext_match_id = f.external_fixture_id
);

-- ------------------------------------------------------------
-- 8) dopln league_id do HB matches
--    vazeme podle ext_source/ext_league_id z public.leagues
-- ------------------------------------------------------------
UPDATE public.matches m
SET league_id = l.id
FROM tmp_hb_src_fixtures f
JOIN public.leagues l
  ON l.ext_source = 'api_handball'
 AND l.ext_league_id = f.external_league_id
JOIN tmp_hb_context c
  ON true
WHERE m.ext_source = 'api_handball'
  AND m.ext_match_id = f.external_fixture_id
  AND m.sport_id = c.sport_id
  AND (
      m.league_id IS NULL
      OR m.league_id <> l.id
  );

COMMIT;

-- ------------------------------------------------------------
-- 9) kontroly
-- ------------------------------------------------------------

-- HB canonical teams
SELECT
    count(*) AS hb_canonical_teams
FROM public.teams
WHERE ext_source = 'api_handball';

-- HB provider map
SELECT
    count(*) AS hb_team_provider_map_rows
FROM public.team_provider_map
WHERE provider = 'api_handball'
  AND provider_team_id IN (
      SELECT external_team_id
      FROM staging.stg_provider_teams
      WHERE provider = 'api_handball'
        AND sport_code = 'handball'
  );

-- HB missing team map na fixtures
SELECT
    COUNT(*) AS hb_fixtures_missing_team_map
FROM staging.stg_provider_fixtures sf
LEFT JOIN public.team_provider_map htp
  ON htp.provider = sf.provider
 AND htp.provider_team_id = sf.home_team_external_id
LEFT JOIN public.team_provider_map atp
  ON atp.provider = sf.provider
 AND atp.provider_team_id = sf.away_team_external_id
WHERE sf.provider = 'api_handball'
  AND (
      htp.team_id IS NULL
      OR atp.team_id IS NULL
  );

-- HB matches summary
SELECT
    ext_source,
    sport_id,
    status,
    count(*) AS cnt
FROM public.matches
WHERE ext_source = 'api_handball'
GROUP BY ext_source, sport_id, status
ORDER BY cnt DESC, status;

-- HB league mapping summary
SELECT
    m.league_id,
    l.name AS league_name,
    count(*) AS cnt
FROM public.matches m
LEFT JOIN public.leagues l
    ON l.id = m.league_id
WHERE m.ext_source = 'api_handball'
GROUP BY m.league_id, l.name
ORDER BY cnt DESC, l.name;

-- posledni HB matches
SELECT
    id,
    ext_match_id,
    league_id,
    status,
    home_score,
    away_score,
    kickoff
FROM public.matches
WHERE ext_source = 'api_handball'
ORDER BY id DESC
LIMIT 20;