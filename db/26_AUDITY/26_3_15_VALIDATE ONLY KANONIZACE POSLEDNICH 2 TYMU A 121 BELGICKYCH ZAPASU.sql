-- ============================================================================
-- MATCHMATRIX
-- 26_3_15_VALIDATE ONLY KANONIZACE POSLEDNICH 2 TYMU A 121 BELGICKYCH ZAPASU
-- ============================================================================
--
-- CO:
--   VALIDATE ONLY simulace posledni belgicke kanonizace.
--
--   Nove provider identity, potvrzene live API-Football:
--     public team 986 = Mouscron  -> api_football:743 = Royal Excel Mouscron
--     public team 988 = Lokeren   -> api_football:737 = historical Lokeren
--
--   DULEZITE:
--     14128 = Lokeren-Temse zustava samostatna nastupnicka identita.
--     24556 = Stade Mouscronnois je samostatna novejsi identita.
--
-- ARCHITEKTONICKE ROZHODNUTI VALIDACE:
--   Nevytvarime nove public.teams radky pro 743/737.
--   Existujici public.teams 986 a 988 jsou kanonicke entity a pouze k nim
--   doplnime druhou provider identitu do public.team_provider_map.
--
--   Tim se vyhneme zbytecne duplikaci stejneho historickeho klubu.
--
-- ROZSAH:
--   - 2 nove team_provider_map identity
--   - 121 poslednich legacy belgickych zapasu
--   - odpovidajici mm_match_ratings dimenze
--   - match_features se nemeni
--
-- BEZPECNOST:
--   - zadny COMMIT
--   - vsechny zmeny jsou pouze uvnitr transakce
--   - povinny ROLLBACK
--   - po ROLLBACK nasleduje samostatny READ ONLY audit obnoveneho stavu
-- ============================================================================


-- ============================================================================
-- A. VALIDATE ONLY TRANSAKCE
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET LOCAL TIME ZONE 'UTC';


-- ============================================================================
-- 1. SNAPSHOT 121 KANDIDATU PRED SIMULACI
-- ============================================================================

CREATE TEMP TABLE mm_26_3_15_candidates ON COMMIT DROP AS
SELECT
    m.id AS match_id,
    m.league_id AS old_league_id,
    m.home_team_id AS old_home_team_id,
    m.away_team_id AS old_away_team_id,
    m.kickoff AS old_kickoff,
    to_jsonb(m)
        - 'league_id'
        - 'home_team_id'
        - 'away_team_id'
        - 'updated_at' AS stable_match_payload
FROM public.matches m
WHERE m.sport_id = 1
  AND m.league_id = 4
  AND m.ext_source = 'football_data_uk';

CREATE TEMP TABLE mm_26_3_15_ratings_before ON COMMIT DROP AS
SELECT
    r.match_id,
    r.league_id AS old_league_id,
    r.home_team_id AS old_home_team_id,
    r.away_team_id AS old_away_team_id,
    r.kickoff AS old_kickoff,
    to_jsonb(r)
        - 'league_id'
        - 'home_team_id'
        - 'away_team_id'
        - 'kickoff'
        - 'updated_at' AS stable_rating_payload
FROM public.mm_match_ratings r
JOIN mm_26_3_15_candidates c
  ON c.match_id = r.match_id;

CREATE TEMP TABLE mm_26_3_15_features_before ON COMMIT DROP AS
SELECT
    f.match_id,
    to_jsonb(f) AS feature_payload
FROM public.match_features f
JOIN mm_26_3_15_candidates c
  ON c.match_id = f.match_id;


-- ============================================================================
-- 2. HARD PRECHECK GUARD
-- ============================================================================

DO $$
DECLARE
    v_candidates bigint;
    v_ratings bigint;
    v_features bigint;
    v_provider_conflicts bigint;
    v_existing_api_on_986_988 bigint;
    v_team_map_count bigint;
    v_global_matches bigint;
    v_global_provider_map bigint;
    v_global_orphans bigint;
BEGIN
    SELECT COUNT(*) INTO v_candidates
    FROM mm_26_3_15_candidates;

    SELECT COUNT(*) INTO v_ratings
    FROM mm_26_3_15_ratings_before;

    SELECT COUNT(*) INTO v_features
    FROM mm_26_3_15_features_before;

    SELECT COUNT(*) INTO v_provider_conflicts
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id IN ('743', '737');

    SELECT COUNT(*) INTO v_existing_api_on_986_988
    FROM public.team_provider_map
    WHERE team_id IN (986, 988)
      AND provider = 'api_football';

    SELECT COUNT(*) INTO v_team_map_count
    FROM (
        VALUES
            (972::bigint, 12940::bigint),
            (964, 13172),
            (980, 12515),
            (967, 12844),
            (975, 13032),
            (976, 12803),
            (966, 12665),
            (982, 13516),
            (977, 12254),
            (979, 12719),
            (981, 13043),
            (969, 12517),
            (985, 15765),
            (974, 12636),
            (983, 13328),
            (984, 12565),
            (971, 13537),
            (965, 13160),
            (978, 12277),
            (968, 12993),
            (973, 13279),
            (970, 12427),
            (987, 13137),
            (986, 986),
            (988, 988)
    ) AS x(fd_uk_team_id, canonical_team_id);

    SELECT COUNT(*) INTO v_global_matches
    FROM public.matches;

    SELECT COUNT(*) INTO v_global_provider_map
    FROM public.match_provider_map;

    SELECT COUNT(*) INTO v_global_orphans
    FROM public.mm_match_ratings r
    LEFT JOIN public.matches m ON m.id = r.match_id
    WHERE m.id IS NULL;

    IF v_candidates <> 121 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: candidate legacy matches %, expected 121', v_candidates;
    END IF;

    IF v_ratings <> 121 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: candidate ratings %, expected 121', v_ratings;
    END IF;

    IF v_features <> 121 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: candidate match_features %, expected 121', v_features;
    END IF;

    IF v_provider_conflicts <> 0 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: api_football IDs 743/737 already mapped: % rows', v_provider_conflicts;
    END IF;

    IF v_existing_api_on_986_988 <> 0 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: teams 986/988 already have api_football identity: % rows', v_existing_api_on_986_988;
    END IF;

    IF v_team_map_count <> 25 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: team map count %, expected 25', v_team_map_count;
    END IF;

    IF v_global_matches <> 120981 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: public.matches %, expected 120981', v_global_matches;
    END IF;

    IF v_global_provider_map <> 121908 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: match_provider_map %, expected 121908', v_global_provider_map;
    END IF;

    IF v_global_orphans <> 78794 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: global rating orphans %, expected 78794', v_global_orphans;
    END IF;
END $$;

SELECT
    'PRECHECK'::text AS sekce,
    'SAFETY_GUARD'::text AS kontrola,
    'OK'::text AS stav,
    1::bigint AS ocekavano,
    1::bigint AS skutecnost,
    '121 candidates + 121 ratings + 121 features + 25 team mappings + no API 737/743 conflict.'::text AS detail;


-- ============================================================================
-- 3. SIMULACE DOPLNENI DVOU API PROVIDER IDENTIT
-- ============================================================================

WITH inserted AS (
    INSERT INTO public.team_provider_map
        (team_id, provider, provider_team_id)
    VALUES
        (986, 'api_football', '743'),
        (988, 'api_football', '737')
    RETURNING team_id, provider, provider_team_id
)
SELECT
    'SIMULACE'::text AS sekce,
    'TEAM_PROVIDER_IDENTITIES_INSERTED'::text AS kontrola,
    CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    2::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    STRING_AGG(team_id::text || ' -> ' || provider || ':' || provider_team_id, ', ' ORDER BY team_id) AS detail
FROM inserted;


-- ============================================================================
-- 4. SIMULACE PREVODU RATING DIMENZI
-- ============================================================================
-- Ratings se prevadeji PRED matches, aby kandidatni scope byl stale
-- jednoznacne dostupny pres puvodni league_id = 4.
-- ============================================================================

WITH
team_map(fd_uk_team_id, canonical_team_id) AS (
    VALUES
        (972::bigint, 12940::bigint),
        (964, 13172),
        (980, 12515),
        (967, 12844),
        (975, 13032),
        (976, 12803),
        (966, 12665),
        (982, 13516),
        (977, 12254),
        (979, 12719),
        (981, 13043),
        (969, 12517),
        (985, 15765),
        (974, 12636),
        (983, 13328),
        (984, 12565),
        (971, 13537),
        (965, 13160),
        (978, 12277),
        (968, 12993),
        (973, 13279),
        (970, 12427),
        (987, 13137),
        (986, 986),
        (988, 988)
),
updated AS (
    UPDATE public.mm_match_ratings r
       SET league_id = 20853,
           home_team_id = hm.canonical_team_id,
           away_team_id = am.canonical_team_id,
           kickoff = c.old_kickoff
      FROM mm_26_3_15_candidates c
      JOIN team_map hm ON hm.fd_uk_team_id = c.old_home_team_id
      JOIN team_map am ON am.fd_uk_team_id = c.old_away_team_id
     WHERE r.match_id = c.match_id
    RETURNING r.match_id
)
SELECT
    'SIMULACE'::text AS sekce,
    'RATINGS_UPDATED'::text AS kontrola,
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    121::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    NULL::text AS detail
FROM updated;


-- ============================================================================
-- 5. SIMULACE PREVODU 121 MATCHES DO KANONICKE LIGY
-- ============================================================================

WITH
team_map(fd_uk_team_id, canonical_team_id) AS (
    VALUES
        (972::bigint, 12940::bigint),
        (964, 13172),
        (980, 12515),
        (967, 12844),
        (975, 13032),
        (976, 12803),
        (966, 12665),
        (982, 13516),
        (977, 12254),
        (979, 12719),
        (981, 13043),
        (969, 12517),
        (985, 15765),
        (974, 12636),
        (983, 13328),
        (984, 12565),
        (971, 13537),
        (965, 13160),
        (978, 12277),
        (968, 12993),
        (973, 13279),
        (970, 12427),
        (987, 13137),
        (986, 986),
        (988, 988)
),
updated AS (
    UPDATE public.matches m
       SET league_id = 20853,
           home_team_id = hm.canonical_team_id,
           away_team_id = am.canonical_team_id
      FROM mm_26_3_15_candidates c
      JOIN team_map hm ON hm.fd_uk_team_id = c.old_home_team_id
      JOIN team_map am ON am.fd_uk_team_id = c.old_away_team_id
     WHERE m.id = c.match_id
    RETURNING m.id
)
SELECT
    'SIMULACE'::text AS sekce,
    'MATCHES_UPDATED'::text AS kontrola,
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    121::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    NULL::text AS detail
FROM updated;


-- ============================================================================
-- 6. POSTCHECK PO SIMULACI
-- ============================================================================

SELECT
    'POSTCHECK'::text AS sekce,
    'TARGET_MATCH_DIMENSIONS_OK'::text AS kontrola,
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    121::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    'Vsech 121 kandidatu je v league 20853 a obsahuje kanonicke team IDs.'::text AS detail
FROM public.matches m
JOIN mm_26_3_15_candidates c ON c.match_id = m.id
WHERE m.league_id = 20853
  AND m.home_team_id IN (
      12940,13172,12515,12844,13032,12803,12665,13516,12254,12719,
      13043,12517,15765,12636,13328,12565,13537,13160,12277,12993,
      13279,12427,13137,986,988
  )
  AND m.away_team_id IN (
      12940,13172,12515,12844,13032,12803,12665,13516,12254,12719,
      13043,12517,15765,12636,13328,12565,13537,13160,12277,12993,
      13279,12427,13137,986,988
  )

UNION ALL

SELECT
    'POSTCHECK',
    'LEGACY_MATCHES_REMAINING',
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    0,
    COUNT(*)::bigint,
    'Po plne simulaci nezustava zadny belgicky football_data_uk match v league_id=4.'::text
FROM public.matches
WHERE sport_id = 1
  AND league_id = 4
  AND ext_source = 'football_data_uk'

UNION ALL

SELECT
    'POSTCHECK',
    'API_IDENTITIES_737_743_PRESENT',
    CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    2,
    COUNT(*)::bigint,
    '986->743 a 988->737.'::text
FROM public.team_provider_map
WHERE provider = 'api_football'
  AND (
      (team_id = 986 AND provider_team_id = '743')
      OR
      (team_id = 988 AND provider_team_id = '737')
  )

UNION ALL

SELECT
    'DOWNSTREAM',
    'MATCH_FEATURE_ROWS_PRESERVED',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    'match_features jsou vazane pres match_id a nebyly meneny.'::text
FROM public.match_features f
JOIN mm_26_3_15_candidates c ON c.match_id = f.match_id

UNION ALL

SELECT
    'DOWNSTREAM',
    'RATING_DIMENSIONS_ALIGNED',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    'Rating dimenze odpovidaji aktualnim match dimenzim.'::text
FROM public.mm_match_ratings r
JOIN public.matches m ON m.id = r.match_id
JOIN mm_26_3_15_candidates c ON c.match_id = r.match_id
WHERE r.league_id = m.league_id
  AND r.home_team_id = m.home_team_id
  AND r.away_team_id = m.away_team_id
  AND r.kickoff IS NOT DISTINCT FROM m.kickoff;


-- ============================================================================
-- 7. PAYLOAD INTEGRITY
-- ============================================================================

SELECT
    'IDENTITY'::text AS sekce,
    'MATCH_PAYLOAD_UNCHANGED'::text AS kontrola,
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    121::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    'Porovnani vsech match poli mimo dimenze a updated_at.'::text AS detail
FROM public.matches m
JOIN mm_26_3_15_candidates c ON c.match_id = m.id
WHERE (
    to_jsonb(m)
        - 'league_id'
        - 'home_team_id'
        - 'away_team_id'
        - 'updated_at'
) = c.stable_match_payload

UNION ALL

SELECT
    'DOWNSTREAM',
    'RATING_PAYLOAD_UNCHANGED',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    'Porovnani rating payloadu mimo dimenze, kickoff a updated_at.'::text
FROM public.mm_match_ratings r
JOIN mm_26_3_15_ratings_before b ON b.match_id = r.match_id
WHERE (
    to_jsonb(r)
        - 'league_id'
        - 'home_team_id'
        - 'away_team_id'
        - 'kickoff'
        - 'updated_at'
) = b.stable_rating_payload

UNION ALL

SELECT
    'DOWNSTREAM',
    'FEATURE_PAYLOAD_UNCHANGED',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    'match_features nebyly zmeneny.'::text
FROM public.match_features f
JOIN mm_26_3_15_features_before b ON b.match_id = f.match_id
WHERE to_jsonb(f) = b.feature_payload;


-- ============================================================================
-- 8. GLOBALNI OCHRANNE POCTY V SIMULACI
-- ============================================================================

SELECT
    'GLOBAL'::text AS sekce,
    'MATCH_COUNT_UNCHANGED'::text AS kontrola,
    CASE WHEN COUNT(*) = 120981 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    120981::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    NULL::text AS detail
FROM public.matches

UNION ALL

SELECT
    'GLOBAL',
    'MATCH_PROVIDER_MAP_COUNT_UNCHANGED',
    CASE WHEN COUNT(*) = 121908 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121908,
    COUNT(*)::bigint,
    'match_provider_map se pri teto migraci nemeni.'::text
FROM public.match_provider_map

UNION ALL

SELECT
    'GLOBAL',
    'TEAM_PROVIDER_MAP_DELTA',
    CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    2,
    COUNT(*)::bigint,
    'V simulaci vznikaji presne dve nove team provider identity.'::text
FROM public.team_provider_map
WHERE provider = 'api_football'
  AND provider_team_id IN ('737','743')

UNION ALL

SELECT
    'GLOBAL',
    'GLOBAL_RATING_ORPHANS_UNCHANGED',
    CASE WHEN COUNT(*) = 78794 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    78794,
    COUNT(*)::bigint,
    'Samostatny globalni problem zustava beze zmeny.'::text
FROM public.mm_match_ratings r
LEFT JOIN public.matches m ON m.id = r.match_id
WHERE m.id IS NULL;


-- ============================================================================
-- 9. PRE-ROLLBACK ZAVER
-- ============================================================================

WITH checks AS (
    SELECT
        (SELECT COUNT(*) FROM public.matches m
         JOIN mm_26_3_15_candidates c ON c.match_id = m.id
         WHERE m.league_id = 20853) AS target_matches,

        (SELECT COUNT(*) FROM public.matches
         WHERE sport_id = 1
           AND league_id = 4
           AND ext_source = 'football_data_uk') AS legacy_remaining,

        (SELECT COUNT(*) FROM public.team_provider_map
         WHERE provider = 'api_football'
           AND (
             (team_id = 986 AND provider_team_id = '743')
             OR
             (team_id = 988 AND provider_team_id = '737')
           )) AS new_team_identities,

        (SELECT COUNT(*) FROM public.mm_match_ratings r
         JOIN public.matches m ON m.id = r.match_id
         JOIN mm_26_3_15_candidates c ON c.match_id = r.match_id
         WHERE r.league_id = m.league_id
           AND r.home_team_id = m.home_team_id
           AND r.away_team_id = m.away_team_id
           AND r.kickoff IS NOT DISTINCT FROM m.kickoff) AS aligned_ratings
)
SELECT
    'ZAVER'::text AS sekce,
    'VALIDATE_ONLY_PRE_ROLLBACK_STATUS'::text AS kontrola,
    CASE
        WHEN target_matches = 121
         AND legacy_remaining = 0
         AND new_team_identities = 2
         AND aligned_ratings = 121
        THEN 'VALIDATE_ONLY_PRE_ROLLBACK_OK'
        ELSE 'VALIDATE_ONLY_PRE_ROLLBACK_REVIEW_REQUIRED'
    END AS stav,
    121::bigint AS ocekavano,
    target_matches::bigint AS skutecnost,
    'Po tomto vysledku musi nasledovat ROLLBACK, nikoli COMMIT.'::text AS detail
FROM checks;


-- ============================================================================
-- 10. POVINNY ROLLBACK VALIDATE ONLY
-- ============================================================================

ROLLBACK;


-- ============================================================================
-- B. POST-ROLLBACK READ ONLY AUDIT
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL TIME ZONE 'UTC';


-- ============================================================================
-- 11. OVERENI OBNOVENEHO STAVU
-- ============================================================================

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
    'ROLLBACK',
    'LEGACY_MATCHES_RESTORED',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    'Vsech 121 zapasu je znovu v puvodnim legacy scope.'::text
FROM public.matches
WHERE sport_id = 1
  AND league_id = 4
  AND ext_source = 'football_data_uk'

UNION ALL

SELECT
    'ROLLBACK',
    'API_IDENTITIES_737_743_REMOVED',
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    0,
    COUNT(*)::bigint,
    'Simulovane team_provider_map radky byly vraceny zpet.'::text
FROM public.team_provider_map
WHERE provider = 'api_football'
  AND provider_team_id IN ('737','743')

UNION ALL

SELECT
    'ROLLBACK',
    'MATCH_COUNT_RESTORED',
    CASE WHEN COUNT(*) = 120981 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    120981,
    COUNT(*)::bigint,
    NULL::text
FROM public.matches

UNION ALL

SELECT
    'ROLLBACK',
    'MATCH_PROVIDER_MAP_COUNT_RESTORED',
    CASE WHEN COUNT(*) = 121908 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121908,
    COUNT(*)::bigint,
    NULL::text
FROM public.match_provider_map

UNION ALL

SELECT
    'ROLLBACK',
    'GLOBAL_RATING_ORPHANS_RESTORED',
    CASE WHEN COUNT(*) = 78794 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    78794,
    COUNT(*)::bigint,
    NULL::text
FROM public.mm_match_ratings r
LEFT JOIN public.matches m ON m.id = r.match_id
WHERE m.id IS NULL;


-- ============================================================================
-- 12. FINALNI POST-ROLLBACK STATUS
-- ============================================================================

WITH state AS (
    SELECT
        (SELECT COUNT(*) FROM public.matches
         WHERE sport_id = 1
           AND league_id = 4
           AND ext_source = 'football_data_uk') AS legacy_matches,

        (SELECT COUNT(*) FROM public.team_provider_map
         WHERE provider = 'api_football'
           AND provider_team_id IN ('737','743')) AS simulated_identities,

        (SELECT COUNT(*) FROM public.match_provider_map) AS match_provider_rows
)
SELECT
    'ZAVER'::text AS sekce,
    'VALIDATE_ONLY_ROLLBACK_STATUS'::text AS kontrola,
    CASE
        WHEN legacy_matches = 121
         AND simulated_identities = 0
         AND match_provider_rows = 121908
        THEN 'VALIDATE_ONLY_ROLLBACK_OK'
        ELSE 'VALIDATE_ONLY_ROLLBACK_REVIEW_REQUIRED'
    END AS stav,
    121::bigint AS ocekavano,
    legacy_matches::bigint AS skutecnost,
    'Databaze je po VALIDATE ONLY obnovena do puvodniho stavu.'::text AS detail
FROM state;

ROLLBACK;