-- ============================================================================
-- MATCHMATRIX
-- 26_3_11_READ ONLY DOHLEDÁNÍ API IDENTIT MOUSCRON A LOKEREN PODLE ZÁPASOVÝCH SHOD
-- ============================================================================
--
-- CO:
--   Read-only důkazní audit pro poslední dvě nevyřešené historické identity:
--     986 = Mouscron
--     988 = Lokeren
--
-- K ČEMU:
--   Neurčuje identitu podle názvu. Hledá kandidátní API-Football tým podle:
--     - stejného data,
--     - stejné ligy API-Football (Jupiler Pro League = 144),
--     - stejné sezony,
--     - stejného známého soupeře,
--     - stejného home/away postavení,
--     - stejného výsledku.
--
--   Potom:
--     1) agreguje kandidátní API team_id podle počtu přesných zápasových shod,
--     2) kontroluje nejednoznačné a chybějící shody,
--     3) dohledá případný public.teams / team_provider_map protějšek,
--     4) pokud pro oba historické týmy vyjde právě jeden kandidát,
--        ověří i dva vzájemné zápasy Mouscron–Lokeren.
--
-- BEZPEČNOST:
--   - REPEATABLE READ READ ONLY
--   - žádný INSERT / UPDATE / DELETE / DDL / COMMIT
--   - pouze SELECT + závěrečný ROLLBACK read-only transakce
--
-- DŮLEŽITÉ:
--   Výsledek tohoto auditu ještě NENÍ APPLY.
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL TIME ZONE 'UTC';

-- ============================================================================
-- 1. SOUHRN DŮKAZNÍHO ROZSAHU
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_public_team_id, pair_label) AS (
    VALUES
        (972::bigint, 12940::bigint, 'Anderlecht'::text),
        (964, 13172, 'Antwerp'),
        (980, 12515, 'Beerschot VA'),
        (967, 12844, 'Cercle Brugge'),
        (975, 13032, 'Charleroi'),
        (976, 12803, 'Club Brugge'),
        (966, 12665, 'Dender'),
        (982, 13516, 'Eupen'),
        (977, 12254, 'Genk'),
        (979, 12719, 'Gent'),
        (981, 13043, 'Kortrijk'),
        (969, 12517, 'Mechelen'),
        (985, 15765, 'Oostende'),
        (974, 12636, 'OH Leuven'),
        (983, 13328, 'RWD Molenbeek'),
        (984, 12565, 'Seraing'),
        (971, 13537, 'Standard Liege'),
        (965, 13160, 'Union St. Gilloise'),
        (978, 12277, 'St. Truiden'),
        (968, 12993, 'Zulte Waregem'),
        (973, 13279, 'Westerlo'),
        (970, 12427, 'RAAL La Louviere'),
        (987, 13137, 'Waasland-Beveren / SK Beveren')
),
legacy AS (
    SELECT m.*
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
),
partial AS (
    SELECT
        m.*,
        hm.api_public_team_id AS mapped_home_public_team_id,
        am.api_public_team_id AS mapped_away_public_team_id,
        CASE
            WHEN hm.fd_uk_team_id IS NULL THEN m.home_team_id
            ELSE m.away_team_id
        END AS unresolved_historical_team_id,
        CASE
            WHEN hm.fd_uk_team_id IS NULL THEN 'HOME'
            ELSE 'AWAY'
        END AS unresolved_side,
        CASE
            WHEN hm.fd_uk_team_id IS NULL THEN am.api_public_team_id
            ELSE hm.api_public_team_id
        END AS known_opponent_public_team_id
    FROM legacy m
    LEFT JOIN team_map hm ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN team_map am ON am.fd_uk_team_id = m.away_team_id
    WHERE (hm.fd_uk_team_id IS NULL) <> (am.fd_uk_team_id IS NULL)
),
known_opponent_api AS (
    SELECT
        p.*,
        tpm.provider_team_id::bigint AS known_opponent_api_team_id
    FROM partial p
    JOIN public.team_provider_map tpm
      ON tpm.team_id = p.known_opponent_public_team_id
     AND tpm.provider = 'api_football'
     AND tpm.provider_team_id ~ '^[0-9]+$'
),
staging_latest AS (
    SELECT DISTINCT ON (f.fixture_id)
        f.fixture_id,
        f.kickoff,
        f.league_id,
        f.season,
        f.home_team_id,
        f.away_team_id,
        f.home_goals,
        f.away_goals,
        f.status,
        f.fetched_at,
        f.raw
    FROM staging.api_football_fixtures f
    WHERE f.league_id = 144
      AND f.season IN (2018, 2019, 2020)
    ORDER BY f.fixture_id, f.fetched_at DESC NULLS LAST
),
evidence AS (
    SELECT
        p.id AS historical_match_id,
        p.unresolved_historical_team_id,
        p.unresolved_side,
        p.kickoff AS historical_kickoff,
        p.season AS historical_season,
        p.home_score AS historical_home_score,
        p.away_score AS historical_away_score,
        p.known_opponent_public_team_id,
        p.known_opponent_api_team_id,
        s.fixture_id AS api_fixture_id,
        s.kickoff AS api_kickoff,
        s.season AS api_season,
        s.home_team_id AS api_home_team_id,
        s.away_team_id AS api_away_team_id,
        s.home_goals AS api_home_goals,
        s.away_goals AS api_away_goals,
        CASE
            WHEN p.unresolved_side = 'HOME' THEN s.home_team_id
            ELSE s.away_team_id
        END AS candidate_api_team_id,
        CASE
            WHEN p.unresolved_side = 'HOME'
                THEN s.raw #>> '{teams,home,name}'
            ELSE s.raw #>> '{teams,away,name}'
        END AS candidate_api_team_name
    FROM known_opponent_api p
    LEFT JOIN staging_latest s
      ON s.season = 2000 + LEFT(p.season, 2)::int
     AND (s.kickoff AT TIME ZONE 'UTC')::date = p.kickoff::date
     AND s.home_goals IS NOT DISTINCT FROM p.home_score
     AND s.away_goals IS NOT DISTINCT FROM p.away_score
     AND (
            (
                p.unresolved_side = 'HOME'
                AND s.away_team_id = p.known_opponent_api_team_id
            )
         OR (
                p.unresolved_side = 'AWAY'
                AND s.home_team_id = p.known_opponent_api_team_id
            )
         )
),
per_match AS (
    SELECT
        historical_match_id,
        unresolved_historical_team_id,
        COUNT(api_fixture_id)::bigint AS candidate_fixture_count
    FROM evidence
    GROUP BY historical_match_id, unresolved_historical_team_id
)
SELECT
    'KONTROLA'::text AS sekce,
    'TRANSACTION_READ_ONLY'::text AS kontrola,
    CASE WHEN current_setting('transaction_read_only') = 'on'
         THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    1::bigint AS ocekavano,
    CASE WHEN current_setting('transaction_read_only') = 'on'
         THEN 1::bigint ELSE 0::bigint END AS skutecnost,
    current_setting('transaction_isolation')::text AS detail

UNION ALL

SELECT
    'ROZSAH',
    'PARTIAL_MATCHES_INPUT',
    CASE WHEN COUNT(*) = 119 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    119,
    COUNT(*)::bigint,
    '119 zápasů má přesně jednu již potvrzenou týmovou identitu.'
FROM partial

UNION ALL

SELECT
    'ROZSAH',
    'MOUSCRON_PARTIAL_MATCHES',
    CASE WHEN COUNT(*) = 91 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    91,
    COUNT(*)::bigint,
    'Mouscron má 93 legacy zápasů, z toho 2 jsou proti Lokeren.'
FROM partial
WHERE unresolved_historical_team_id = 986

UNION ALL

SELECT
    'ROZSAH',
    'LOKEREN_PARTIAL_MATCHES',
    CASE WHEN COUNT(*) = 28 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    28,
    COUNT(*)::bigint,
    'Lokeren má 30 legacy zápasů, z toho 2 jsou proti Mouscron.'
FROM partial
WHERE unresolved_historical_team_id = 988

UNION ALL

SELECT
    'DŮKAZ',
    'MATCHES_WITH_EXACTLY_ONE_API_FIXTURE_CANDIDATE',
    CASE WHEN COUNT(*) = 119 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    119,
    COUNT(*)::bigint,
    'Ideální výsledek: každý z 119 zápasů má právě jednu přesnou staging shodu.'
FROM per_match
WHERE candidate_fixture_count = 1

UNION ALL

SELECT
    'DŮKAZ',
    'MATCHES_WITH_ZERO_API_FIXTURE_CANDIDATES',
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'INFO_REVIEW' END,
    0,
    COUNT(*)::bigint,
    'Nulová hodnota znamená úplné staging pokrytí zkoumané skupiny.'
FROM per_match
WHERE candidate_fixture_count = 0

UNION ALL

SELECT
    'DŮKAZ',
    'MATCHES_WITH_MULTIPLE_API_FIXTURE_CANDIDATES',
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    0,
    COUNT(*)::bigint,
    'Jakákoli hodnota > 0 znamená nejednoznačný zápas.'
FROM per_match
WHERE candidate_fixture_count > 1;


-- ============================================================================
-- 2. KANDIDÁTNÍ API IDENTITY – AGREGACE PŘES ZÁPASOVÉ DŮKAZY
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_public_team_id, pair_label) AS (
    VALUES
        (972::bigint, 12940::bigint, 'Anderlecht'::text),
        (964, 13172, 'Antwerp'),
        (980, 12515, 'Beerschot VA'),
        (967, 12844, 'Cercle Brugge'),
        (975, 13032, 'Charleroi'),
        (976, 12803, 'Club Brugge'),
        (966, 12665, 'Dender'),
        (982, 13516, 'Eupen'),
        (977, 12254, 'Genk'),
        (979, 12719, 'Gent'),
        (981, 13043, 'Kortrijk'),
        (969, 12517, 'Mechelen'),
        (985, 15765, 'Oostende'),
        (974, 12636, 'OH Leuven'),
        (983, 13328, 'RWD Molenbeek'),
        (984, 12565, 'Seraing'),
        (971, 13537, 'Standard Liege'),
        (965, 13160, 'Union St. Gilloise'),
        (978, 12277, 'St. Truiden'),
        (968, 12993, 'Zulte Waregem'),
        (973, 13279, 'Westerlo'),
        (970, 12427, 'RAAL La Louviere'),
        (987, 13137, 'Waasland-Beveren / SK Beveren')
),
legacy AS (
    SELECT m.*
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
),
partial AS (
    SELECT
        m.*,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN m.home_team_id ELSE m.away_team_id END
            AS unresolved_historical_team_id,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN 'HOME' ELSE 'AWAY' END
            AS unresolved_side,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN am.api_public_team_id ELSE hm.api_public_team_id END
            AS known_opponent_public_team_id
    FROM legacy m
    LEFT JOIN team_map hm ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN team_map am ON am.fd_uk_team_id = m.away_team_id
    WHERE (hm.fd_uk_team_id IS NULL) <> (am.fd_uk_team_id IS NULL)
),
p AS (
    SELECT
        x.*,
        tpm.provider_team_id::bigint AS known_opponent_api_team_id
    FROM partial x
    JOIN public.team_provider_map tpm
      ON tpm.team_id = x.known_opponent_public_team_id
     AND tpm.provider = 'api_football'
     AND tpm.provider_team_id ~ '^[0-9]+$'
),
staging_latest AS (
    SELECT DISTINCT ON (f.fixture_id)
        f.*
    FROM staging.api_football_fixtures f
    WHERE f.league_id = 144
      AND f.season IN (2018, 2019, 2020)
    ORDER BY f.fixture_id, f.fetched_at DESC NULLS LAST
),
evidence AS (
    SELECT
        p.id AS historical_match_id,
        p.unresolved_historical_team_id,
        s.fixture_id,
        CASE WHEN p.unresolved_side = 'HOME' THEN s.home_team_id ELSE s.away_team_id END
            AS candidate_api_team_id,
        CASE
            WHEN p.unresolved_side = 'HOME' THEN s.raw #>> '{teams,home,name}'
            ELSE s.raw #>> '{teams,away,name}'
        END AS candidate_api_team_name,
        p.season AS historical_season,
        p.kickoff AS historical_kickoff
    FROM p
    JOIN staging_latest s
      ON s.season = 2000 + LEFT(p.season, 2)::int
     AND (s.kickoff AT TIME ZONE 'UTC')::date = p.kickoff::date
     AND s.home_goals IS NOT DISTINCT FROM p.home_score
     AND s.away_goals IS NOT DISTINCT FROM p.away_score
     AND (
            (p.unresolved_side = 'HOME' AND s.away_team_id = p.known_opponent_api_team_id)
         OR (p.unresolved_side = 'AWAY' AND s.home_team_id = p.known_opponent_api_team_id)
         )
),
candidate_agg AS (
    SELECT
        unresolved_historical_team_id,
        candidate_api_team_id,
        candidate_api_team_name,
        COUNT(DISTINCT historical_match_id)::bigint AS exact_match_evidence,
        MIN(historical_kickoff) AS first_evidence_match,
        MAX(historical_kickoff) AS last_evidence_match,
        ARRAY_AGG(DISTINCT historical_season ORDER BY historical_season) AS legacy_seasons
    FROM evidence
    GROUP BY
        unresolved_historical_team_id,
        candidate_api_team_id,
        candidate_api_team_name
)
SELECT
    a.unresolved_historical_team_id,
    CASE a.unresolved_historical_team_id
        WHEN 986 THEN 'Mouscron'
        WHEN 988 THEN 'Lokeren'
        ELSE '[NEZNÁMÝ]'
    END AS historical_team_name,
    a.candidate_api_team_id,
    a.candidate_api_team_name,
    a.exact_match_evidence,
    a.first_evidence_match,
    a.last_evidence_match,
    a.legacy_seasons,
    ptpm.team_id AS existing_public_team_id,
    COALESCE(
        to_jsonb(pt)->>'name',
        to_jsonb(pt)->>'team_name',
        to_jsonb(pt)->>'canonical_name'
    ) AS existing_public_team_name,
    CASE
        WHEN ptpm.team_id IS NOT NULL THEN 'EXISTS_IN_PUBLIC_TEAM_PROVIDER_MAP'
        ELSE 'API_ID_NOT_YET_MAPPED_TO_PUBLIC_TEAM'
    END AS public_mapping_status
FROM candidate_agg a
LEFT JOIN public.team_provider_map ptpm
  ON ptpm.provider = 'api_football'
 AND ptpm.provider_team_id = a.candidate_api_team_id::text
LEFT JOIN public.teams pt
  ON pt.id = ptpm.team_id
ORDER BY
    a.unresolved_historical_team_id,
    a.exact_match_evidence DESC,
    a.candidate_api_team_id;


-- ============================================================================
-- 3. DETAIL VŠECH 119 ZÁPASOVÝCH DŮKAZŮ
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_public_team_id, pair_label) AS (
    VALUES
        (972::bigint, 12940::bigint, 'Anderlecht'::text),
        (964, 13172, 'Antwerp'),
        (980, 12515, 'Beerschot VA'),
        (967, 12844, 'Cercle Brugge'),
        (975, 13032, 'Charleroi'),
        (976, 12803, 'Club Brugge'),
        (966, 12665, 'Dender'),
        (982, 13516, 'Eupen'),
        (977, 12254, 'Genk'),
        (979, 12719, 'Gent'),
        (981, 13043, 'Kortrijk'),
        (969, 12517, 'Mechelen'),
        (985, 15765, 'Oostende'),
        (974, 12636, 'OH Leuven'),
        (983, 13328, 'RWD Molenbeek'),
        (984, 12565, 'Seraing'),
        (971, 13537, 'Standard Liege'),
        (965, 13160, 'Union St. Gilloise'),
        (978, 12277, 'St. Truiden'),
        (968, 12993, 'Zulte Waregem'),
        (973, 13279, 'Westerlo'),
        (970, 12427, 'RAAL La Louviere'),
        (987, 13137, 'Waasland-Beveren / SK Beveren')
),
legacy AS (
    SELECT m.*
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
),
partial AS (
    SELECT
        m.*,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN m.home_team_id ELSE m.away_team_id END
            AS unresolved_historical_team_id,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN 'HOME' ELSE 'AWAY' END
            AS unresolved_side,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN am.api_public_team_id ELSE hm.api_public_team_id END
            AS known_opponent_public_team_id
    FROM legacy m
    LEFT JOIN team_map hm ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN team_map am ON am.fd_uk_team_id = m.away_team_id
    WHERE (hm.fd_uk_team_id IS NULL) <> (am.fd_uk_team_id IS NULL)
),
p AS (
    SELECT
        x.*,
        tpm.provider_team_id::bigint AS known_opponent_api_team_id
    FROM partial x
    JOIN public.team_provider_map tpm
      ON tpm.team_id = x.known_opponent_public_team_id
     AND tpm.provider = 'api_football'
     AND tpm.provider_team_id ~ '^[0-9]+$'
),
staging_latest AS (
    SELECT DISTINCT ON (f.fixture_id)
        f.*
    FROM staging.api_football_fixtures f
    WHERE f.league_id = 144
      AND f.season IN (2018, 2019, 2020)
    ORDER BY f.fixture_id, f.fetched_at DESC NULLS LAST
)
SELECT
    p.id AS historical_match_id,
    p.unresolved_historical_team_id,
    CASE p.unresolved_historical_team_id
        WHEN 986 THEN 'Mouscron'
        WHEN 988 THEN 'Lokeren'
    END AS historical_team_name,
    p.unresolved_side,
    p.kickoff AS historical_kickoff,
    p.season AS historical_season,
    p.home_score AS historical_home_score,
    p.away_score AS historical_away_score,
    p.known_opponent_public_team_id,
    p.known_opponent_api_team_id,

    s.fixture_id AS api_fixture_id,
    s.kickoff AS api_kickoff,
    s.home_team_id AS api_home_team_id,
    s.raw #>> '{teams,home,name}' AS api_home_team_name,
    s.away_team_id AS api_away_team_id,
    s.raw #>> '{teams,away,name}' AS api_away_team_name,
    s.home_goals AS api_home_goals,
    s.away_goals AS api_away_goals,

    CASE WHEN p.unresolved_side = 'HOME' THEN s.home_team_id ELSE s.away_team_id END
        AS candidate_api_team_id,
    CASE
        WHEN p.unresolved_side = 'HOME' THEN s.raw #>> '{teams,home,name}'
        ELSE s.raw #>> '{teams,away,name}'
    END AS candidate_api_team_name
FROM p
LEFT JOIN staging_latest s
  ON s.season = 2000 + LEFT(p.season, 2)::int
 AND (s.kickoff AT TIME ZONE 'UTC')::date = p.kickoff::date
 AND s.home_goals IS NOT DISTINCT FROM p.home_score
 AND s.away_goals IS NOT DISTINCT FROM p.away_score
 AND (
        (p.unresolved_side = 'HOME' AND s.away_team_id = p.known_opponent_api_team_id)
     OR (p.unresolved_side = 'AWAY' AND s.home_team_id = p.known_opponent_api_team_id)
     )
ORDER BY
    p.unresolved_historical_team_id,
    p.kickoff,
    p.id,
    s.fixture_id;


-- ============================================================================
-- 4. NEJEDNOZNAČNÉ / CHYBĚJÍCÍ ZÁPASOVÉ SHODY
-- ============================================================================
-- Ideální výsledek: PRÁZDNÉ.
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_public_team_id, pair_label) AS (
    VALUES
        (972::bigint, 12940::bigint, 'Anderlecht'::text),
        (964, 13172, 'Antwerp'),
        (980, 12515, 'Beerschot VA'),
        (967, 12844, 'Cercle Brugge'),
        (975, 13032, 'Charleroi'),
        (976, 12803, 'Club Brugge'),
        (966, 12665, 'Dender'),
        (982, 13516, 'Eupen'),
        (977, 12254, 'Genk'),
        (979, 12719, 'Gent'),
        (981, 13043, 'Kortrijk'),
        (969, 12517, 'Mechelen'),
        (985, 15765, 'Oostende'),
        (974, 12636, 'OH Leuven'),
        (983, 13328, 'RWD Molenbeek'),
        (984, 12565, 'Seraing'),
        (971, 13537, 'Standard Liege'),
        (965, 13160, 'Union St. Gilloise'),
        (978, 12277, 'St. Truiden'),
        (968, 12993, 'Zulte Waregem'),
        (973, 13279, 'Westerlo'),
        (970, 12427, 'RAAL La Louviere'),
        (987, 13137, 'Waasland-Beveren / SK Beveren')
),
legacy AS (
    SELECT m.*
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
),
partial AS (
    SELECT
        m.*,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN m.home_team_id ELSE m.away_team_id END
            AS unresolved_historical_team_id,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN 'HOME' ELSE 'AWAY' END
            AS unresolved_side,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN am.api_public_team_id ELSE hm.api_public_team_id END
            AS known_opponent_public_team_id
    FROM legacy m
    LEFT JOIN team_map hm ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN team_map am ON am.fd_uk_team_id = m.away_team_id
    WHERE (hm.fd_uk_team_id IS NULL) <> (am.fd_uk_team_id IS NULL)
),
p AS (
    SELECT
        x.*,
        tpm.provider_team_id::bigint AS known_opponent_api_team_id
    FROM partial x
    JOIN public.team_provider_map tpm
      ON tpm.team_id = x.known_opponent_public_team_id
     AND tpm.provider = 'api_football'
     AND tpm.provider_team_id ~ '^[0-9]+$'
),
staging_latest AS (
    SELECT DISTINCT ON (f.fixture_id)
        f.*
    FROM staging.api_football_fixtures f
    WHERE f.league_id = 144
      AND f.season IN (2018, 2019, 2020)
    ORDER BY f.fixture_id, f.fetched_at DESC NULLS LAST
),
matched AS (
    SELECT
        p.id AS historical_match_id,
        p.unresolved_historical_team_id,
        COUNT(s.fixture_id)::bigint AS candidate_fixture_count,
        ARRAY_AGG(s.fixture_id ORDER BY s.fixture_id)
            FILTER (WHERE s.fixture_id IS NOT NULL) AS api_fixture_ids,
        ARRAY_AGG(
            CASE WHEN p.unresolved_side = 'HOME' THEN s.home_team_id ELSE s.away_team_id END
            ORDER BY s.fixture_id
        ) FILTER (WHERE s.fixture_id IS NOT NULL) AS candidate_api_team_ids
    FROM p
    LEFT JOIN staging_latest s
      ON s.season = 2000 + LEFT(p.season, 2)::int
     AND (s.kickoff AT TIME ZONE 'UTC')::date = p.kickoff::date
     AND s.home_goals IS NOT DISTINCT FROM p.home_score
     AND s.away_goals IS NOT DISTINCT FROM p.away_score
     AND (
            (p.unresolved_side = 'HOME' AND s.away_team_id = p.known_opponent_api_team_id)
         OR (p.unresolved_side = 'AWAY' AND s.home_team_id = p.known_opponent_api_team_id)
         )
    GROUP BY
        p.id,
        p.unresolved_historical_team_id
)
SELECT *
FROM matched
WHERE candidate_fixture_count <> 1
ORDER BY unresolved_historical_team_id, historical_match_id;


-- ============================================================================
-- 5. OVĚŘENÍ DVOU VZÁJEMNÝCH ZÁPASŮ MOUSCRON ↔ LOKEREN
-- ============================================================================
-- Kandidátní API team_id se sem odvozují pouze tehdy, pokud pro daný historický
-- tým vyšel z 119 částečně mapovatelných zápasů právě JEDEN DISTINCT kandidát.
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_public_team_id, pair_label) AS (
    VALUES
        (972::bigint, 12940::bigint, 'Anderlecht'::text),
        (964, 13172, 'Antwerp'),
        (980, 12515, 'Beerschot VA'),
        (967, 12844, 'Cercle Brugge'),
        (975, 13032, 'Charleroi'),
        (976, 12803, 'Club Brugge'),
        (966, 12665, 'Dender'),
        (982, 13516, 'Eupen'),
        (977, 12254, 'Genk'),
        (979, 12719, 'Gent'),
        (981, 13043, 'Kortrijk'),
        (969, 12517, 'Mechelen'),
        (985, 15765, 'Oostende'),
        (974, 12636, 'OH Leuven'),
        (983, 13328, 'RWD Molenbeek'),
        (984, 12565, 'Seraing'),
        (971, 13537, 'Standard Liege'),
        (965, 13160, 'Union St. Gilloise'),
        (978, 12277, 'St. Truiden'),
        (968, 12993, 'Zulte Waregem'),
        (973, 13279, 'Westerlo'),
        (970, 12427, 'RAAL La Louviere'),
        (987, 13137, 'Waasland-Beveren / SK Beveren')
),
legacy AS (
    SELECT m.*
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
),
partial AS (
    SELECT
        m.*,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN m.home_team_id ELSE m.away_team_id END
            AS unresolved_historical_team_id,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN 'HOME' ELSE 'AWAY' END
            AS unresolved_side,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN am.api_public_team_id ELSE hm.api_public_team_id END
            AS known_opponent_public_team_id
    FROM legacy m
    LEFT JOIN team_map hm ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN team_map am ON am.fd_uk_team_id = m.away_team_id
    WHERE (hm.fd_uk_team_id IS NULL) <> (am.fd_uk_team_id IS NULL)
),
p AS (
    SELECT
        x.*,
        tpm.provider_team_id::bigint AS known_opponent_api_team_id
    FROM partial x
    JOIN public.team_provider_map tpm
      ON tpm.team_id = x.known_opponent_public_team_id
     AND tpm.provider = 'api_football'
     AND tpm.provider_team_id ~ '^[0-9]+$'
),
staging_latest AS (
    SELECT DISTINCT ON (f.fixture_id)
        f.*
    FROM staging.api_football_fixtures f
    WHERE f.league_id = 144
      AND f.season IN (2018, 2019, 2020)
    ORDER BY f.fixture_id, f.fetched_at DESC NULLS LAST
),
evidence AS (
    SELECT
        p.unresolved_historical_team_id,
        CASE WHEN p.unresolved_side = 'HOME' THEN s.home_team_id ELSE s.away_team_id END
            AS candidate_api_team_id
    FROM p
    JOIN staging_latest s
      ON s.season = 2000 + LEFT(p.season, 2)::int
     AND (s.kickoff AT TIME ZONE 'UTC')::date = p.kickoff::date
     AND s.home_goals IS NOT DISTINCT FROM p.home_score
     AND s.away_goals IS NOT DISTINCT FROM p.away_score
     AND (
            (p.unresolved_side = 'HOME' AND s.away_team_id = p.known_opponent_api_team_id)
         OR (p.unresolved_side = 'AWAY' AND s.home_team_id = p.known_opponent_api_team_id)
         )
),
unique_candidate AS (
    SELECT
        unresolved_historical_team_id,
        MIN(candidate_api_team_id)::bigint AS candidate_api_team_id
    FROM evidence
    GROUP BY unresolved_historical_team_id
    HAVING COUNT(DISTINCT candidate_api_team_id) = 1
),
mutual_legacy AS (
    SELECT m.*
    FROM legacy m
    WHERE (m.home_team_id = 988 AND m.away_team_id = 986)
       OR (m.home_team_id = 986 AND m.away_team_id = 988)
),
candidate_pair AS (
    SELECT
        (SELECT candidate_api_team_id
         FROM unique_candidate
         WHERE unresolved_historical_team_id = 986) AS mouscron_api_team_id,
        (SELECT candidate_api_team_id
         FROM unique_candidate
         WHERE unresolved_historical_team_id = 988) AS lokeren_api_team_id
)
SELECT
    ml.id AS historical_match_id,
    ml.kickoff AS historical_kickoff,
    ml.home_team_id AS historical_home_team_id,
    ml.away_team_id AS historical_away_team_id,
    ml.home_score AS historical_home_score,
    ml.away_score AS historical_away_score,

    cp.mouscron_api_team_id,
    cp.lokeren_api_team_id,

    s.fixture_id AS api_fixture_id,
    s.kickoff AS api_kickoff,
    s.home_team_id AS api_home_team_id,
    s.raw #>> '{teams,home,name}' AS api_home_team_name,
    s.away_team_id AS api_away_team_id,
    s.raw #>> '{teams,away,name}' AS api_away_team_name,
    s.home_goals AS api_home_goals,
    s.away_goals AS api_away_goals,

    CASE
        WHEN s.fixture_id IS NOT NULL THEN 'EXACT_MUTUAL_MATCH_CONFIRMED'
        ELSE 'NO_EXACT_MUTUAL_MATCH'
    END AS evidence_status
FROM mutual_legacy ml
CROSS JOIN candidate_pair cp
LEFT JOIN staging_latest s
  ON s.season = 2000 + LEFT(ml.season, 2)::int
 AND (s.kickoff AT TIME ZONE 'UTC')::date = ml.kickoff::date
 AND s.home_goals IS NOT DISTINCT FROM ml.home_score
 AND s.away_goals IS NOT DISTINCT FROM ml.away_score
 AND (
        (
            ml.home_team_id = 986
            AND s.home_team_id = cp.mouscron_api_team_id
            AND s.away_team_id = cp.lokeren_api_team_id
        )
     OR (
            ml.home_team_id = 988
            AND s.home_team_id = cp.lokeren_api_team_id
            AND s.away_team_id = cp.mouscron_api_team_id
        )
     )
ORDER BY ml.kickoff, ml.id, s.fixture_id;


-- ============================================================================
-- 6. ZÁVĚREČNÁ KLASIFIKACE DŮKAZU
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_public_team_id, pair_label) AS (
    VALUES
        (972::bigint, 12940::bigint, 'Anderlecht'::text),
        (964, 13172, 'Antwerp'),
        (980, 12515, 'Beerschot VA'),
        (967, 12844, 'Cercle Brugge'),
        (975, 13032, 'Charleroi'),
        (976, 12803, 'Club Brugge'),
        (966, 12665, 'Dender'),
        (982, 13516, 'Eupen'),
        (977, 12254, 'Genk'),
        (979, 12719, 'Gent'),
        (981, 13043, 'Kortrijk'),
        (969, 12517, 'Mechelen'),
        (985, 15765, 'Oostende'),
        (974, 12636, 'OH Leuven'),
        (983, 13328, 'RWD Molenbeek'),
        (984, 12565, 'Seraing'),
        (971, 13537, 'Standard Liege'),
        (965, 13160, 'Union St. Gilloise'),
        (978, 12277, 'St. Truiden'),
        (968, 12993, 'Zulte Waregem'),
        (973, 13279, 'Westerlo'),
        (970, 12427, 'RAAL La Louviere'),
        (987, 13137, 'Waasland-Beveren / SK Beveren')
),
legacy AS (
    SELECT m.*
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 4
      AND m.ext_source = 'football_data_uk'
),
partial AS (
    SELECT
        m.*,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN m.home_team_id ELSE m.away_team_id END
            AS unresolved_historical_team_id,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN 'HOME' ELSE 'AWAY' END
            AS unresolved_side,
        CASE WHEN hm.fd_uk_team_id IS NULL THEN am.api_public_team_id ELSE hm.api_public_team_id END
            AS known_opponent_public_team_id
    FROM legacy m
    LEFT JOIN team_map hm ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN team_map am ON am.fd_uk_team_id = m.away_team_id
    WHERE (hm.fd_uk_team_id IS NULL) <> (am.fd_uk_team_id IS NULL)
),
p AS (
    SELECT
        x.*,
        tpm.provider_team_id::bigint AS known_opponent_api_team_id
    FROM partial x
    JOIN public.team_provider_map tpm
      ON tpm.team_id = x.known_opponent_public_team_id
     AND tpm.provider = 'api_football'
     AND tpm.provider_team_id ~ '^[0-9]+$'
),
staging_latest AS (
    SELECT DISTINCT ON (f.fixture_id)
        f.*
    FROM staging.api_football_fixtures f
    WHERE f.league_id = 144
      AND f.season IN (2018, 2019, 2020)
    ORDER BY f.fixture_id, f.fetched_at DESC NULLS LAST
),
matched AS (
    SELECT
        p.id AS historical_match_id,
        p.unresolved_historical_team_id,
        COUNT(s.fixture_id)::bigint AS candidate_fixture_count,
        COUNT(DISTINCT CASE
            WHEN p.unresolved_side = 'HOME' THEN s.home_team_id
            ELSE s.away_team_id
        END)::bigint AS distinct_candidate_team_ids
    FROM p
    LEFT JOIN staging_latest s
      ON s.season = 2000 + LEFT(p.season, 2)::int
     AND (s.kickoff AT TIME ZONE 'UTC')::date = p.kickoff::date
     AND s.home_goals IS NOT DISTINCT FROM p.home_score
     AND s.away_goals IS NOT DISTINCT FROM p.away_score
     AND (
            (p.unresolved_side = 'HOME' AND s.away_team_id = p.known_opponent_api_team_id)
         OR (p.unresolved_side = 'AWAY' AND s.home_team_id = p.known_opponent_api_team_id)
         )
    GROUP BY p.id, p.unresolved_historical_team_id
),
team_candidates AS (
    SELECT
        p.unresolved_historical_team_id,
        COUNT(DISTINCT CASE
            WHEN p.unresolved_side = 'HOME' THEN s.home_team_id
            ELSE s.away_team_id
        END)::bigint AS distinct_candidate_api_team_ids
    FROM p
    LEFT JOIN staging_latest s
      ON s.season = 2000 + LEFT(p.season, 2)::int
     AND (s.kickoff AT TIME ZONE 'UTC')::date = p.kickoff::date
     AND s.home_goals IS NOT DISTINCT FROM p.home_score
     AND s.away_goals IS NOT DISTINCT FROM p.away_score
     AND (
            (p.unresolved_side = 'HOME' AND s.away_team_id = p.known_opponent_api_team_id)
         OR (p.unresolved_side = 'AWAY' AND s.home_team_id = p.known_opponent_api_team_id)
         )
    GROUP BY p.unresolved_historical_team_id
)
SELECT
    'ZAVER'::text AS sekce,
    'IDENTITY_EVIDENCE_STATUS'::text AS kontrola,
    CASE
        WHEN (SELECT COUNT(*) FROM matched WHERE candidate_fixture_count = 1) = 119
         AND (SELECT COUNT(*) FROM matched WHERE candidate_fixture_count <> 1) = 0
         AND (SELECT COUNT(*) FROM team_candidates WHERE distinct_candidate_api_team_ids = 1) = 2
        THEN 'TWO_UNIQUE_API_TEAM_CANDIDATES_CONFIRMED_BY_119_MATCHES'
        ELSE 'IDENTITY_EVIDENCE_REVIEW_REQUIRED'
    END AS stav,
    119::bigint AS ocekavano_jednoznacnych_zapasovych_shod,
    (SELECT COUNT(*)::bigint FROM matched WHERE candidate_fixture_count = 1)
        AS skutecnost_jednoznacnych_zapasovych_shod,
    2::bigint AS ocekavano_jednoznacnych_tymovych_kandidatu,
    (SELECT COUNT(*)::bigint
     FROM team_candidates
     WHERE distinct_candidate_api_team_ids = 1)
        AS skutecnost_jednoznacnych_tymovych_kandidatu,
    'Pokud je stav potvrzený, následuje ruční vyhodnocení konkrétních API team_id a teprve potom VALIDATE ONLY mapování 121 zápasů.'::text
        AS detail;

ROLLBACK;