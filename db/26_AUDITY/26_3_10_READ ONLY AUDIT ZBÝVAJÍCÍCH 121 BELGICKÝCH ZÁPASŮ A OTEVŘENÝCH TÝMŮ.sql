-- ============================================================================
-- MATCHMATRIX
-- 26_3_10_READ ONLY AUDIT ZBÝVAJÍCÍCH 121 BELGICKÝCH ZÁPASŮ A OTEVŘENÝCH TÝMŮ
-- ============================================================================
--
-- CO:
--   Read-only audit stavu po úspěšném APPLY 110 belgických historických zápasů.
--
-- K ČEMU:
--   1) potvrdit přesný zbytek 121 legacy zápasů,
--   2) potvrdit klasifikaci 119 PARTIALLY_MAPPABLE + 2 UNMAPPED_TEAM_REQUIRED,
--   3) vypsat přesné dosud nevyřešené historické týmové identity,
--   4) ukázat jejich zápasové období, počty a providerové identity,
--   5) připravit důkazní základ pro další identity research.
--
-- BEZPEČNOST:
--   - transakce je REPEATABLE READ READ ONLY,
--   - skript neobsahuje INSERT / UPDATE / DELETE / DDL,
--   - na konci pouze ROLLBACK read-only transakce.
--
-- VÝCHOZÍ OVĚŘENÝ STAV:
--   public.matches             = 120981
--   public.match_provider_map  = 121908
--   global orphan ratings      = 78794
--   legacy Belgium             = 121
--   fully mappable             = 0
--   partially mappable         = 119
--   unmapped team required     = 2
--
-- POZNÁMKA:
--   Název podobný jinému klubu NENÍ důkaz identity.
--   Tento audit nic automaticky nemapuje.
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL TIME ZONE 'UTC';

-- ============================================================================
-- 1. SOUHRNNÁ KONTROLA STAVU
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_team_id, pair_label) AS (
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
classified AS (
    SELECT
        m.id AS match_id,
        CASE
            WHEN hm.fd_uk_team_id IS NOT NULL
             AND am.fd_uk_team_id IS NOT NULL
                THEN 'FULLY_MAPPABLE'
            WHEN hm.fd_uk_team_id IS NOT NULL
              OR am.fd_uk_team_id IS NOT NULL
                THEN 'PARTIALLY_MAPPABLE'
            ELSE 'UNMAPPED_TEAM_REQUIRED'
        END AS mapping_class
    FROM legacy m
    LEFT JOIN team_map hm
        ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN team_map am
        ON am.fd_uk_team_id = m.away_team_id
),
unresolved_occurrences AS (
    SELECT m.id AS match_id, m.home_team_id AS team_id
    FROM legacy m
    LEFT JOIN team_map hm
        ON hm.fd_uk_team_id = m.home_team_id
    WHERE hm.fd_uk_team_id IS NULL

    UNION ALL

    SELECT m.id AS match_id, m.away_team_id AS team_id
    FROM legacy m
    LEFT JOIN team_map am
        ON am.fd_uk_team_id = m.away_team_id
    WHERE am.fd_uk_team_id IS NULL
),
checks AS (
    SELECT
        10 AS sort_order,
        'KONTROLA'::text AS sekce,
        'TRANSACTION_READ_ONLY'::text AS kontrola,
        CASE WHEN current_setting('transaction_read_only') = 'on'
             THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
        1::bigint AS ocekavano,
        CASE WHEN current_setting('transaction_read_only') = 'on'
             THEN 1::bigint ELSE 0::bigint END AS skutecnost,
        current_setting('transaction_isolation')::text AS detail

    UNION ALL

    SELECT 20, 'ROZSAH', 'LEGACY_MATCHES_TOTAL',
           CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
           121, COUNT(*)::bigint, NULL::text
    FROM legacy

    UNION ALL

    SELECT 30, 'ROZSAH', 'FULLY_MAPPABLE',
           CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
           0, COUNT(*)::bigint, NULL::text
    FROM classified
    WHERE mapping_class = 'FULLY_MAPPABLE'

    UNION ALL

    SELECT 40, 'ROZSAH', 'PARTIALLY_MAPPABLE',
           CASE WHEN COUNT(*) = 119 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
           119, COUNT(*)::bigint, NULL::text
    FROM classified
    WHERE mapping_class = 'PARTIALLY_MAPPABLE'

    UNION ALL

    SELECT 50, 'ROZSAH', 'UNMAPPED_TEAM_REQUIRED',
           CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
           2, COUNT(*)::bigint, NULL::text
    FROM classified
    WHERE mapping_class = 'UNMAPPED_TEAM_REQUIRED'

    UNION ALL

    SELECT 60, 'IDENTITY', 'UNRESOLVED_HISTORICAL_TEAM_IDS',
           CASE WHEN COUNT(DISTINCT team_id) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
           2, COUNT(DISTINCT team_id)::bigint,
           'Počet dosud nevyřešených historických týmových identit.'::text
    FROM unresolved_occurrences

    UNION ALL

    SELECT 100, 'GLOBAL', 'MATCH_COUNT_UNCHANGED',
           CASE WHEN COUNT(*) = 120981 THEN 'OK' ELSE 'INFO_CURRENT_STATE' END,
           120981, COUNT(*)::bigint,
           'Očekávání vychází z právě dokončeného APPLY 110.'::text
    FROM public.matches

    UNION ALL

    SELECT 110, 'GLOBAL', 'PROVIDER_MAP_COUNT_UNCHANGED',
           CASE WHEN COUNT(*) = 121908 THEN 'OK' ELSE 'INFO_CURRENT_STATE' END,
           121908, COUNT(*)::bigint,
           'Očekávání vychází z právě dokončeného APPLY 110.'::text
    FROM public.match_provider_map

    UNION ALL

    SELECT 120, 'GLOBAL', 'GLOBAL_RATING_ORPHANS_UNCHANGED',
           CASE WHEN COUNT(*) = 78794 THEN 'OK' ELSE 'INFO_CURRENT_STATE' END,
           78794, COUNT(*)::bigint,
           'Samostatný globální problém; tento audit jej nemění.'::text
    FROM public.mm_match_ratings r
    LEFT JOIN public.matches m
        ON m.id = r.match_id
    WHERE m.id IS NULL
)
SELECT
    sekce,
    kontrola,
    stav,
    ocekavano,
    skutecnost,
    detail
FROM checks
ORDER BY sort_order;


-- ============================================================================
-- 2. PŘESNÝ INVENTÁŘ DOSUD NEVYŘEŠENÝCH HISTORICKÝCH TÝMŮ
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_team_id, pair_label) AS (
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
unresolved_occurrences AS (
    SELECT
        m.id AS match_id,
        m.home_team_id AS team_id,
        'HOME'::text AS role,
        m.kickoff,
        m.season
    FROM legacy m
    LEFT JOIN team_map hm
        ON hm.fd_uk_team_id = m.home_team_id
    WHERE hm.fd_uk_team_id IS NULL

    UNION ALL

    SELECT
        m.id AS match_id,
        m.away_team_id AS team_id,
        'AWAY'::text AS role,
        m.kickoff,
        m.season
    FROM legacy m
    LEFT JOIN team_map am
        ON am.fd_uk_team_id = m.away_team_id
    WHERE am.fd_uk_team_id IS NULL
)
SELECT
    u.team_id AS historical_team_id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    ) AS historical_team_name,
    to_jsonb(t)->>'ext_source' AS team_ext_source,
    to_jsonb(t)->>'ext_team_id' AS team_ext_team_id,
    COUNT(DISTINCT u.match_id)::bigint AS affected_matches,
    COUNT(DISTINCT u.match_id) FILTER (WHERE u.role = 'HOME')::bigint AS as_home,
    COUNT(DISTINCT u.match_id) FILTER (WHERE u.role = 'AWAY')::bigint AS as_away,
    MIN(u.kickoff) AS first_kickoff,
    MAX(u.kickoff) AS last_kickoff,
    ARRAY_AGG(DISTINCT u.season ORDER BY u.season) AS seasons
FROM unresolved_occurrences u
LEFT JOIN public.teams t
    ON t.id = u.team_id
GROUP BY
    u.team_id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    ),
    to_jsonb(t)->>'ext_source',
    to_jsonb(t)->>'ext_team_id'
ORDER BY affected_matches DESC, historical_team_id;


-- ============================================================================
-- 3. PROVIDEROVÉ IDENTITY DOSUD NEVYŘEŠENÝCH HISTORICKÝCH TÝMŮ
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_team_id, pair_label) AS (
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
unresolved_team_ids AS (
    SELECT DISTINCT x.team_id
    FROM (
        SELECT m.home_team_id AS team_id
        FROM legacy m
        LEFT JOIN team_map hm
            ON hm.fd_uk_team_id = m.home_team_id
        WHERE hm.fd_uk_team_id IS NULL

        UNION ALL

        SELECT m.away_team_id AS team_id
        FROM legacy m
        LEFT JOIN team_map am
            ON am.fd_uk_team_id = m.away_team_id
        WHERE am.fd_uk_team_id IS NULL
    ) x
)
SELECT
    u.team_id AS historical_team_id,
    COALESCE(
        to_jsonb(t)->>'name',
        to_jsonb(t)->>'team_name',
        to_jsonb(t)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    ) AS historical_team_name,
    p.provider,
    p.provider_team_id,
    to_jsonb(p) AS provider_map_record
FROM unresolved_team_ids u
LEFT JOIN public.teams t
    ON t.id = u.team_id
LEFT JOIN public.team_provider_map p
    ON p.team_id = u.team_id
ORDER BY historical_team_id, p.provider, p.provider_team_id;


-- ============================================================================
-- 4. DVA ZÁPASY, KDE JSOU DOSUD NEVYŘEŠENÉ OBA TÝMY
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_team_id, pair_label) AS (
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
)
SELECT
    m.id AS match_id,
    m.kickoff,
    m.season,
    m.home_team_id AS historical_home_team_id,
    COALESCE(
        to_jsonb(ht)->>'name',
        to_jsonb(ht)->>'team_name',
        to_jsonb(ht)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    ) AS historical_home_team_name,
    m.away_team_id AS historical_away_team_id,
    COALESCE(
        to_jsonb(at)->>'name',
        to_jsonb(at)->>'team_name',
        to_jsonb(at)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    ) AS historical_away_team_name,
    m.ext_source,
    m.ext_match_id,
    to_jsonb(m) AS full_match_record
FROM public.matches m
LEFT JOIN team_map hm
    ON hm.fd_uk_team_id = m.home_team_id
LEFT JOIN team_map am
    ON am.fd_uk_team_id = m.away_team_id
LEFT JOIN public.teams ht
    ON ht.id = m.home_team_id
LEFT JOIN public.teams at
    ON at.id = m.away_team_id
WHERE m.sport_id = 1
  AND m.league_id = 4
  AND m.ext_source = 'football_data_uk'
  AND hm.fd_uk_team_id IS NULL
  AND am.fd_uk_team_id IS NULL
ORDER BY m.kickoff, m.id;


-- ============================================================================
-- 5. DETAIL VŠECH 121 ZBÝVAJÍCÍCH LEGACY ZÁPASŮ
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_team_id, pair_label) AS (
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
)
SELECT
    CASE
        WHEN hm.fd_uk_team_id IS NOT NULL
         AND am.fd_uk_team_id IS NOT NULL
            THEN 'FULLY_MAPPABLE'
        WHEN hm.fd_uk_team_id IS NOT NULL
          OR am.fd_uk_team_id IS NOT NULL
            THEN 'PARTIALLY_MAPPABLE'
        ELSE 'UNMAPPED_TEAM_REQUIRED'
    END AS mapping_class,
    m.id AS match_id,
    m.kickoff,
    m.season,

    m.home_team_id AS historical_home_team_id,
    COALESCE(
        to_jsonb(ht)->>'name',
        to_jsonb(ht)->>'team_name',
        to_jsonb(ht)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    ) AS historical_home_team_name,
    hm.api_team_id AS confirmed_target_home_team_id,
    hm.pair_label AS confirmed_home_pair,

    m.away_team_id AS historical_away_team_id,
    COALESCE(
        to_jsonb(at)->>'name',
        to_jsonb(at)->>'team_name',
        to_jsonb(at)->>'canonical_name',
        '[NÁZEV NENALEZEN]'
    ) AS historical_away_team_name,
    am.api_team_id AS confirmed_target_away_team_id,
    am.pair_label AS confirmed_away_pair,

    m.ext_source,
    m.ext_match_id,

    CASE
        WHEN hm.fd_uk_team_id IS NULL
         AND am.fd_uk_team_id IS NULL
            THEN 'OBĚ IDENTITY OTEVŘENÉ'
        WHEN hm.fd_uk_team_id IS NULL
            THEN 'OTEVŘENÝ HOME TÝM'
        WHEN am.fd_uk_team_id IS NULL
            THEN 'OTEVŘENÝ AWAY TÝM'
        ELSE 'ŽÁDNÁ OTEVŘENÁ IDENTITA'
    END AS review_reason
FROM public.matches m
LEFT JOIN team_map hm
    ON hm.fd_uk_team_id = m.home_team_id
LEFT JOIN team_map am
    ON am.fd_uk_team_id = m.away_team_id
LEFT JOIN public.teams ht
    ON ht.id = m.home_team_id
LEFT JOIN public.teams at
    ON at.id = m.away_team_id
WHERE m.sport_id = 1
  AND m.league_id = 4
  AND m.ext_source = 'football_data_uk'
ORDER BY
    CASE
        WHEN hm.fd_uk_team_id IS NULL AND am.fd_uk_team_id IS NULL THEN 0
        ELSE 1
    END,
    m.kickoff,
    m.id;


-- ============================================================================
-- 6. ZÁVĚR
-- ============================================================================

WITH
team_map(fd_uk_team_id, api_team_id, pair_label) AS (
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
classified AS (
    SELECT
        CASE
            WHEN hm.fd_uk_team_id IS NOT NULL
             AND am.fd_uk_team_id IS NOT NULL
                THEN 'FULLY_MAPPABLE'
            WHEN hm.fd_uk_team_id IS NOT NULL
              OR am.fd_uk_team_id IS NOT NULL
                THEN 'PARTIALLY_MAPPABLE'
            ELSE 'UNMAPPED_TEAM_REQUIRED'
        END AS mapping_class
    FROM legacy m
    LEFT JOIN team_map hm
        ON hm.fd_uk_team_id = m.home_team_id
    LEFT JOIN team_map am
        ON am.fd_uk_team_id = m.away_team_id
),
unresolved_team_ids AS (
    SELECT DISTINCT team_id
    FROM (
        SELECT m.home_team_id AS team_id
        FROM legacy m
        LEFT JOIN team_map hm
            ON hm.fd_uk_team_id = m.home_team_id
        WHERE hm.fd_uk_team_id IS NULL

        UNION ALL

        SELECT m.away_team_id AS team_id
        FROM legacy m
        LEFT JOIN team_map am
            ON am.fd_uk_team_id = m.away_team_id
        WHERE am.fd_uk_team_id IS NULL
    ) x
)
SELECT
    'ZAVER'::text AS sekce,
    'READ_ONLY_REMAINING_121_STATUS'::text AS kontrola,
    CASE
        WHEN (SELECT COUNT(*) FROM legacy) = 121
         AND (SELECT COUNT(*) FROM classified WHERE mapping_class = 'FULLY_MAPPABLE') = 0
         AND (SELECT COUNT(*) FROM classified WHERE mapping_class = 'PARTIALLY_MAPPABLE') = 119
         AND (SELECT COUNT(*) FROM classified WHERE mapping_class = 'UNMAPPED_TEAM_REQUIRED') = 2
         AND (SELECT COUNT(*) FROM unresolved_team_ids) = 2
        THEN 'READ_ONLY_REMAINING_121_OK'
        ELSE 'READ_ONLY_REMAINING_121_REVIEW_REQUIRED'
    END AS stav,
    121::bigint AS ocekavano_legacy,
    (SELECT COUNT(*)::bigint FROM legacy) AS skutecnost_legacy,
    2::bigint AS ocekavano_otevrene_tymy,
    (SELECT COUNT(*)::bigint FROM unresolved_team_ids) AS skutecnost_otevrene_tymy,
    'Další krok je identity research dvou otevřených týmů; tento skript nic nemění.'::text AS detail;

ROLLBACK;