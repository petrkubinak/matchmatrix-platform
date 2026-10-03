-- ============================================================================
-- MATCHMATRIX
-- 26_3_12_READ ONLY DOHLEDÁNÍ MOUSCRON A LOKEREN V PUBLIC CANONICAL MATCHES
-- ============================================================================
--
-- CO:
--   Diagnostický READ ONLY audit po výsledku 26_3_11, kde staging
--   api_football_fixtures neobsahoval žádnou z 119 očekávaných historických shod.
--
-- K ČEMU:
--   1) potvrdit skutečné historické pokrytí staging.api_football_fixtures,
--   2) nehledat dál ve stagingu naslepo,
--   3) hledat důkaz Mouscron (986) a Lokeren (988) v již existující
--      kanonické vrstvě public.matches + public.match_provider_map,
--   4) používat známého kanonického soupeře, home/away postavení, skóre
--      a časovou blízkost zápasu,
--   5) vypsat kandidátní public.team_id a jejich API-Football provider identity.
--
-- BEZPEČNOST:
--   - REPEATABLE READ READ ONLY
--   - žádný INSERT / UPDATE / DELETE / DDL / COMMIT
--   - závěrečný ROLLBACK read-only transakce
--
-- DŮLEŽITÉ:
--   Tento audit NIC NEMAPUJE. Kandidát se nesmí potvrdit pouze podle názvu.
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL TIME ZONE 'UTC';

-- ============================================================================
-- 1. PROČ 26_3_11 NENAŠEL NIC VE STAGINGU
-- ============================================================================

SELECT
    'STAGING_COVERAGE'::text AS sekce,
    'API_FOOTBALL_LEAGUE_144_SEASONS_2018_2020'::text AS kontrola,
    COUNT(*)::bigint AS rows_total,
    COUNT(DISTINCT fixture_id)::bigint AS fixtures_distinct,
    MIN(season) AS min_season,
    MAX(season) AS max_season,
    MIN(kickoff) AS min_kickoff,
    MAX(kickoff) AS max_kickoff
FROM staging.api_football_fixtures
WHERE league_id = 144
  AND season IN (2018, 2019, 2020);

SELECT
    season,
    COUNT(*)::bigint AS rows_total,
    COUNT(DISTINCT fixture_id)::bigint AS fixtures_distinct,
    MIN(kickoff) AS min_kickoff,
    MAX(kickoff) AS max_kickoff
FROM staging.api_football_fixtures
WHERE league_id = 144
GROUP BY season
ORDER BY season;


-- ============================================================================
-- 2. VSTUPNÍ ROZSAH 119 PARTIAL ZÁPASŮ
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
)
SELECT
    unresolved_historical_team_id,
    CASE unresolved_historical_team_id
        WHEN 986 THEN 'Mouscron'
        WHEN 988 THEN 'Lokeren'
        ELSE '[NEZNÁMÝ]'
    END AS historical_team_name,
    COUNT(*)::bigint AS partial_matches,
    MIN(kickoff) AS first_match,
    MAX(kickoff) AS last_match
FROM partial
GROUP BY unresolved_historical_team_id
ORDER BY unresolved_historical_team_id;


-- ============================================================================
-- 3. KANDIDÁTNÍ SHODY V PUBLIC.MATCHES
-- ============================================================================
--
-- Hledání:
--   - cílová kanonická liga 20853,
--   - zápas má api_football provider identitu,
--   - známý soupeř je na stejné straně,
--   - skóre je stejné,
--   - kickoff je nejvýše 72 hodin od legacy záznamu.
--
-- Nevyžadujeme stejný calendar date, protože dřívější belgické audity
-- prokázaly rozdíly kickoff mezi providery.
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
api_target_matches AS (
    SELECT DISTINCT m.*
    FROM public.matches m
    JOIN public.match_provider_map p
      ON p.match_id = m.id
     AND p.provider = 'api_football'
    WHERE m.sport_id = 1
      AND m.league_id = 20853
),
candidate_matches AS (
    SELECT
        l.id AS legacy_match_id,
        l.unresolved_historical_team_id,
        l.unresolved_side,
        l.kickoff AS legacy_kickoff,
        l.home_score AS legacy_home_score,
        l.away_score AS legacy_away_score,
        l.known_opponent_public_team_id,

        a.id AS target_match_id,
        a.kickoff AS target_kickoff,
        a.home_team_id AS target_home_team_id,
        a.away_team_id AS target_away_team_id,
        a.home_score AS target_home_score,
        a.away_score AS target_away_score,

        CASE
            WHEN l.unresolved_side = 'HOME' THEN a.home_team_id
            ELSE a.away_team_id
        END AS candidate_public_team_id,

        ABS(EXTRACT(EPOCH FROM (a.kickoff - l.kickoff)))::bigint AS kickoff_diff_seconds
    FROM partial l
    JOIN api_target_matches a
      ON a.home_score IS NOT DISTINCT FROM l.home_score
     AND a.away_score IS NOT DISTINCT FROM l.away_score
     AND ABS(EXTRACT(EPOCH FROM (a.kickoff - l.kickoff))) <= 72 * 3600
     AND (
            (
                l.unresolved_side = 'HOME'
                AND a.away_team_id = l.known_opponent_public_team_id
            )
         OR (
                l.unresolved_side = 'AWAY'
                AND a.home_team_id = l.known_opponent_public_team_id
            )
         )
),
per_legacy AS (
    SELECT
        l.id AS legacy_match_id,
        l.unresolved_historical_team_id,
        COUNT(c.target_match_id)::bigint AS candidate_count,
        MIN(c.kickoff_diff_seconds) AS min_kickoff_diff_seconds
    FROM partial l
    LEFT JOIN candidate_matches c
      ON c.legacy_match_id = l.id
    GROUP BY l.id, l.unresolved_historical_team_id
)
SELECT
    'PUBLIC_MATCH_EVIDENCE'::text AS sekce,
    'PARTIAL_MATCHES_INPUT'::text AS kontrola,
    'INFO'::text AS stav,
    119::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    NULL::text AS detail
FROM partial

UNION ALL

SELECT
    'PUBLIC_MATCH_EVIDENCE',
    'MATCHES_WITH_EXACTLY_ONE_CANDIDATE',
    'INFO',
    NULL::bigint,
    COUNT(*)::bigint,
    'Silný signál, ale stále pouze kandidátní důkaz.'::text
FROM per_legacy
WHERE candidate_count = 1

UNION ALL

SELECT
    'PUBLIC_MATCH_EVIDENCE',
    'MATCHES_WITH_ZERO_CANDIDATES',
    'INFO',
    NULL::bigint,
    COUNT(*)::bigint,
    'Může znamenat chybějící API historické pokrytí nebo větší časový rozdíl.'::text
FROM per_legacy
WHERE candidate_count = 0

UNION ALL

SELECT
    'PUBLIC_MATCH_EVIDENCE',
    'MATCHES_WITH_MULTIPLE_CANDIDATES',
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    0::bigint,
    COUNT(*)::bigint,
    'Více kandidátů znamená nejednoznačnost.'::text
FROM per_legacy
WHERE candidate_count > 1;


-- ============================================================================
-- 4. AGREGACE KANDIDÁTNÍCH PUBLIC TEAM IDENTIT
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
api_target_matches AS (
    SELECT DISTINCT m.*
    FROM public.matches m
    JOIN public.match_provider_map p
      ON p.match_id = m.id
     AND p.provider = 'api_football'
    WHERE m.sport_id = 1
      AND m.league_id = 20853
),
candidate_matches AS (
    SELECT
        l.id AS legacy_match_id,
        l.unresolved_historical_team_id,
        CASE
            WHEN l.unresolved_side = 'HOME' THEN a.home_team_id
            ELSE a.away_team_id
        END AS candidate_public_team_id,
        ABS(EXTRACT(EPOCH FROM (a.kickoff - l.kickoff)))::bigint AS kickoff_diff_seconds,
        a.id AS target_match_id
    FROM partial l
    JOIN api_target_matches a
      ON a.home_score IS NOT DISTINCT FROM l.home_score
     AND a.away_score IS NOT DISTINCT FROM l.away_score
     AND ABS(EXTRACT(EPOCH FROM (a.kickoff - l.kickoff))) <= 72 * 3600
     AND (
            (
                l.unresolved_side = 'HOME'
                AND a.away_team_id = l.known_opponent_public_team_id
            )
         OR (
                l.unresolved_side = 'AWAY'
                AND a.home_team_id = l.known_opponent_public_team_id
            )
         )
)
SELECT
    c.unresolved_historical_team_id,
    CASE c.unresolved_historical_team_id
        WHEN 986 THEN 'Mouscron'
        WHEN 988 THEN 'Lokeren'
        ELSE '[NEZNÁMÝ]'
    END AS historical_team_name,
    c.candidate_public_team_id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    ) AS candidate_public_team_name,
    COUNT(DISTINCT c.legacy_match_id)::bigint AS supporting_legacy_matches,
    COUNT(DISTINCT c.target_match_id)::bigint AS supporting_target_matches,
    MIN(c.kickoff_diff_seconds)::bigint AS min_kickoff_diff_seconds,
    MAX(c.kickoff_diff_seconds)::bigint AS max_kickoff_diff_seconds,
    STRING_AGG(
        DISTINCT tpm.provider || ':' || tpm.provider_team_id,
        ', ' ORDER BY tpm.provider || ':' || tpm.provider_team_id
    ) AS provider_identities
FROM candidate_matches c
LEFT JOIN public.teams t
  ON t.id = c.candidate_public_team_id
LEFT JOIN public.team_provider_map tpm
  ON tpm.team_id = c.candidate_public_team_id
GROUP BY
    c.unresolved_historical_team_id,
    c.candidate_public_team_id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    )
ORDER BY
    c.unresolved_historical_team_id,
    supporting_legacy_matches DESC,
    c.candidate_public_team_id;


-- ============================================================================
-- 5. DETAIL NEJLEPŠÍCH ZÁPASOVÝCH DŮKAZŮ
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
api_target_matches AS (
    SELECT DISTINCT
        m.*,
        p.provider_match_id AS api_football_match_id
    FROM public.matches m
    JOIN public.match_provider_map p
      ON p.match_id = m.id
     AND p.provider = 'api_football'
    WHERE m.sport_id = 1
      AND m.league_id = 20853
)
SELECT
    l.id AS legacy_match_id,
    l.unresolved_historical_team_id,
    CASE l.unresolved_historical_team_id
        WHEN 986 THEN 'Mouscron'
        WHEN 988 THEN 'Lokeren'
    END AS historical_team_name,
    l.unresolved_side,
    l.kickoff AS legacy_kickoff,
    l.home_score AS legacy_home_score,
    l.away_score AS legacy_away_score,
    l.known_opponent_public_team_id,

    a.id AS target_match_id,
    a.api_football_match_id,
    a.kickoff AS target_kickoff,
    ROUND(ABS(EXTRACT(EPOCH FROM (a.kickoff - l.kickoff))) / 3600.0, 2)
        AS kickoff_diff_hours,
    a.home_team_id AS target_home_team_id,
    COALESCE(to_jsonb(ht)->>'name', to_jsonb(ht)->>'team_name',
             to_jsonb(ht)->>'canonical_name') AS target_home_team_name,
    a.away_team_id AS target_away_team_id,
    COALESCE(to_jsonb(at)->>'name', to_jsonb(at)->>'team_name',
             to_jsonb(at)->>'canonical_name') AS target_away_team_name,
    a.home_score AS target_home_score,
    a.away_score AS target_away_score,

    CASE
        WHEN l.unresolved_side = 'HOME' THEN a.home_team_id
        ELSE a.away_team_id
    END AS candidate_public_team_id
FROM partial l
JOIN api_target_matches a
  ON a.home_score IS NOT DISTINCT FROM l.home_score
 AND a.away_score IS NOT DISTINCT FROM l.away_score
 AND ABS(EXTRACT(EPOCH FROM (a.kickoff - l.kickoff))) <= 72 * 3600
 AND (
        (
            l.unresolved_side = 'HOME'
            AND a.away_team_id = l.known_opponent_public_team_id
        )
     OR (
            l.unresolved_side = 'AWAY'
            AND a.home_team_id = l.known_opponent_public_team_id
        )
     )
LEFT JOIN public.teams ht ON ht.id = a.home_team_id
LEFT JOIN public.teams at ON at.id = a.away_team_id
ORDER BY
    l.unresolved_historical_team_id,
    l.id,
    kickoff_diff_hours,
    a.id;


-- ============================================================================
-- 6. PŘÍMÉ PUBLIC TEAM / API-FOOTBALL IDENTITY KANDIDÁTŮ PODLE NÁZVU
-- ============================================================================
-- POUZE DOPLŇKOVÁ ORIENTACE.
-- Název není důkaz a tento výstup se nesmí použít samostatně k mapování.
-- ============================================================================

SELECT
    t.id AS public_team_id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    ) AS public_team_name,
    tpm.provider,
    tpm.provider_team_id,
    to_jsonb(t) AS team_record
FROM public.teams t
LEFT JOIN public.team_provider_map tpm
  ON tpm.team_id = t.id
WHERE
       LOWER(COALESCE(to_jsonb(t)->>'name', '')) LIKE '%mouscron%'
    OR LOWER(COALESCE(to_jsonb(t)->>'team_name', '')) LIKE '%mouscron%'
    OR LOWER(COALESCE(to_jsonb(t)->>'canonical_name', '')) LIKE '%mouscron%'
    OR LOWER(COALESCE(to_jsonb(t)->>'name', '')) LIKE '%lokeren%'
    OR LOWER(COALESCE(to_jsonb(t)->>'team_name', '')) LIKE '%lokeren%'
    OR LOWER(COALESCE(to_jsonb(t)->>'canonical_name', '')) LIKE '%lokeren%'
ORDER BY public_team_id, tpm.provider, tpm.provider_team_id;


-- ============================================================================
-- 7. ZÁVĚR
-- ============================================================================

SELECT
    'ZAVER'::text AS sekce,
    'PUBLIC_CANONICAL_IDENTITY_RESEARCH_STATUS'::text AS kontrola,
    'READ_ONLY_RESEARCH_COMPLETED'::text AS stav,
    'Vyhodnotit agregaci kandidátů a detail zápasových shod; nic nebylo změněno.'::text AS detail;

ROLLBACK;