-- ============================================================================
-- MATCHMATRIX
-- 26_3_16_APPLY POSLEDNICH 2 TYMU A 121 BELGICKYCH ZAPASU
-- ============================================================================
--
-- CO:
--   Finalni APPLY posledni belgicke kanonizace po uspesnem 26_3_15 VALIDATE ONLY.
--
--   Potvrzene provider identity:
--     public team 986 = Mouscron -> api_football:743 = Royal Excel Mouscron
--     public team 988 = Lokeren  -> api_football:737 = historical Lokeren
--
--   Samostatne identity, ktere se NESMI sloucit:
--     api_football:14128 = Lokeren-Temse
--     api_football:24556 = Stade Mouscronnois
--
-- ARCHITEKTURA:
--   Nevytvarime nove public.teams radky.
--   Existujicim kanonickym tymum 986 a 988 pouze doplnime dalsi provider identitu.
--
-- ROZSAH:
--   - INSERT 2 radku do public.team_provider_map
--   - UPDATE 121 radku public.mm_match_ratings
--   - UPDATE 121 radku public.matches
--   - public.match_features se nemeni
--
-- BEZPECNOST:
--   READ ONLY AUDIT -> VALIDATE ONLY + ROLLBACK -> TENTO APPLY -> POST-COMMIT AUDIT
--
--   COMMIT probehne pouze pokud vsechny hard pre-commit kontroly projdou.
-- ============================================================================


-- ============================================================================
-- A. APPLY TRANSAKCE
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET LOCAL TIME ZONE 'UTC';


-- ============================================================================
-- 1. SNAPSHOT 121 KANDIDATU
-- ============================================================================

CREATE TEMP TABLE mm_26_3_16_candidates ON COMMIT DROP AS
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

CREATE TEMP TABLE mm_26_3_16_ratings_before ON COMMIT DROP AS
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
JOIN mm_26_3_16_candidates c
  ON c.match_id = r.match_id;

CREATE TEMP TABLE mm_26_3_16_features_before ON COMMIT DROP AS
SELECT
    f.match_id,
    to_jsonb(f) AS feature_payload
FROM public.match_features f
JOIN mm_26_3_16_candidates c
  ON c.match_id = f.match_id;


-- ============================================================================
-- 2. HARD PRECHECK
-- ============================================================================

DO $$
DECLARE
    v_candidates bigint;
    v_ratings bigint;
    v_features bigint;
    v_provider_conflicts bigint;
    v_existing_api_on_986_988 bigint;
    v_global_matches bigint;
    v_global_match_provider bigint;
    v_global_orphans bigint;
BEGIN
    SELECT COUNT(*) INTO v_candidates FROM mm_26_3_16_candidates;
    SELECT COUNT(*) INTO v_ratings FROM mm_26_3_16_ratings_before;
    SELECT COUNT(*) INTO v_features FROM mm_26_3_16_features_before;

    SELECT COUNT(*) INTO v_provider_conflicts
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id IN ('743', '737');

    SELECT COUNT(*) INTO v_existing_api_on_986_988
    FROM public.team_provider_map
    WHERE team_id IN (986, 988)
      AND provider = 'api_football';

    SELECT COUNT(*) INTO v_global_matches
    FROM public.matches;

    SELECT COUNT(*) INTO v_global_match_provider
    FROM public.match_provider_map;

    SELECT COUNT(*) INTO v_global_orphans
    FROM public.mm_match_ratings r
    LEFT JOIN public.matches m ON m.id = r.match_id
    WHERE m.id IS NULL;

    IF v_candidates <> 121 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: legacy candidates %, expected 121', v_candidates;
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

    IF v_global_matches <> 120981 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: public.matches %, expected 120981', v_global_matches;
    END IF;

    IF v_global_match_provider <> 121908 THEN
        RAISE EXCEPTION 'PRECHECK FAIL: match_provider_map %, expected 121908', v_global_match_provider;
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
    '121 matches + 121 ratings + 121 features + no API 737/743 conflict.'::text AS detail;


-- ============================================================================
-- 3. APPLY DVOU PROVIDER IDENTIT
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
    'APPLY'::text AS sekce,
    'TEAM_PROVIDER_IDENTITIES_INSERTED'::text AS kontrola,
    CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    2::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    STRING_AGG(team_id::text || ' -> ' || provider || ':' || provider_team_id, ', ' ORDER BY team_id) AS detail
FROM inserted;


-- ============================================================================
-- 4. APPLY RATINGS
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
      FROM mm_26_3_16_candidates c
      JOIN team_map hm ON hm.fd_uk_team_id = c.old_home_team_id
      JOIN team_map am ON am.fd_uk_team_id = c.old_away_team_id
     WHERE r.match_id = c.match_id
    RETURNING r.match_id
)
SELECT
    'APPLY'::text AS sekce,
    'RATINGS_UPDATED'::text AS kontrola,
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    121::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    NULL::text AS detail
FROM updated;


-- ============================================================================
-- 5. APPLY MATCHES
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
      FROM mm_26_3_16_candidates c
      JOIN team_map hm ON hm.fd_uk_team_id = c.old_home_team_id
      JOIN team_map am ON am.fd_uk_team_id = c.old_away_team_id
     WHERE m.id = c.match_id
    RETURNING m.id
)
SELECT
    'APPLY'::text AS sekce,
    'MATCHES_UPDATED'::text AS kontrola,
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    121::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    NULL::text AS detail
FROM updated;


-- ============================================================================
-- 6. PRE-COMMIT HARD POSTCHECK
-- ============================================================================

DO $$
DECLARE
    v_target_matches bigint;
    v_legacy_remaining bigint;
    v_api_identities bigint;
    v_features bigint;
    v_aligned_ratings bigint;
    v_match_payload_ok bigint;
    v_rating_payload_ok bigint;
    v_feature_payload_ok bigint;
    v_global_matches bigint;
    v_global_match_provider bigint;
    v_global_orphans bigint;
BEGIN
    SELECT COUNT(*) INTO v_target_matches
    FROM public.matches m
    JOIN mm_26_3_16_candidates c ON c.match_id = m.id
    WHERE m.league_id = 20853;

    SELECT COUNT(*) INTO v_legacy_remaining
    FROM public.matches
    WHERE sport_id = 1
      AND league_id = 4
      AND ext_source = 'football_data_uk';

    SELECT COUNT(*) INTO v_api_identities
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND (
          (team_id = 986 AND provider_team_id = '743')
          OR
          (team_id = 988 AND provider_team_id = '737')
      );

    SELECT COUNT(*) INTO v_features
    FROM public.match_features f
    JOIN mm_26_3_16_candidates c ON c.match_id = f.match_id;

    SELECT COUNT(*) INTO v_aligned_ratings
    FROM public.mm_match_ratings r
    JOIN public.matches m ON m.id = r.match_id
    JOIN mm_26_3_16_candidates c ON c.match_id = r.match_id
    WHERE r.league_id = m.league_id
      AND r.home_team_id = m.home_team_id
      AND r.away_team_id = m.away_team_id
      AND r.kickoff IS NOT DISTINCT FROM m.kickoff;

    SELECT COUNT(*) INTO v_match_payload_ok
    FROM public.matches m
    JOIN mm_26_3_16_candidates c ON c.match_id = m.id
    WHERE (
        to_jsonb(m)
            - 'league_id'
            - 'home_team_id'
            - 'away_team_id'
            - 'updated_at'
    ) = c.stable_match_payload;

    SELECT COUNT(*) INTO v_rating_payload_ok
    FROM public.mm_match_ratings r
    JOIN mm_26_3_16_ratings_before b ON b.match_id = r.match_id
    WHERE (
        to_jsonb(r)
            - 'league_id'
            - 'home_team_id'
            - 'away_team_id'
            - 'kickoff'
            - 'updated_at'
    ) = b.stable_rating_payload;

    SELECT COUNT(*) INTO v_feature_payload_ok
    FROM public.match_features f
    JOIN mm_26_3_16_features_before b ON b.match_id = f.match_id
    WHERE to_jsonb(f) = b.feature_payload;

    SELECT COUNT(*) INTO v_global_matches
    FROM public.matches;

    SELECT COUNT(*) INTO v_global_match_provider
    FROM public.match_provider_map;

    SELECT COUNT(*) INTO v_global_orphans
    FROM public.mm_match_ratings r
    LEFT JOIN public.matches m ON m.id = r.match_id
    WHERE m.id IS NULL;

    IF v_target_matches <> 121 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: target matches %, expected 121', v_target_matches;
    END IF;

    IF v_legacy_remaining <> 0 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: legacy matches remain %, expected 0', v_legacy_remaining;
    END IF;

    IF v_api_identities <> 2 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: provider identities %, expected 2', v_api_identities;
    END IF;

    IF v_features <> 121 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: feature rows %, expected 121', v_features;
    END IF;

    IF v_aligned_ratings <> 121 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: aligned ratings %, expected 121', v_aligned_ratings;
    END IF;

    IF v_match_payload_ok <> 121 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: unchanged match payload %, expected 121', v_match_payload_ok;
    END IF;

    IF v_rating_payload_ok <> 121 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: unchanged rating payload %, expected 121', v_rating_payload_ok;
    END IF;

    IF v_feature_payload_ok <> 121 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: unchanged feature payload %, expected 121', v_feature_payload_ok;
    END IF;

    IF v_global_matches <> 120981 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: public.matches %, expected 120981', v_global_matches;
    END IF;

    IF v_global_match_provider <> 121908 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: match_provider_map %, expected 121908', v_global_match_provider;
    END IF;

    IF v_global_orphans <> 78794 THEN
        RAISE EXCEPTION 'PRECOMMIT FAIL: global rating orphans %, expected 78794', v_global_orphans;
    END IF;
END $$;


-- ============================================================================
-- 7. PRE-COMMIT REPORT
-- ============================================================================

SELECT
    'POSTCHECK'::text AS sekce,
    'TARGET_MATCH_DIMENSIONS_OK'::text AS kontrola,
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    121::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    NULL::text AS detail
FROM public.matches m
JOIN mm_26_3_16_candidates c ON c.match_id = m.id
WHERE m.league_id = 20853

UNION ALL

SELECT
    'POSTCHECK',
    'LEGACY_MATCHES_REMAINING',
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    0,
    COUNT(*)::bigint,
    NULL::text
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
    '986->743; 988->737'::text
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
    NULL::text
FROM public.match_features f
JOIN mm_26_3_16_candidates c ON c.match_id = f.match_id

UNION ALL

SELECT
    'DOWNSTREAM',
    'RATING_DIMENSIONS_ALIGNED',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    NULL::text
FROM public.mm_match_ratings r
JOIN public.matches m ON m.id = r.match_id
JOIN mm_26_3_16_candidates c ON c.match_id = r.match_id
WHERE r.league_id = m.league_id
  AND r.home_team_id = m.home_team_id
  AND r.away_team_id = m.away_team_id
  AND r.kickoff IS NOT DISTINCT FROM m.kickoff

UNION ALL

SELECT
    'GLOBAL',
    'MATCH_COUNT_UNCHANGED',
    CASE WHEN COUNT(*) = 120981 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    120981,
    COUNT(*)::bigint,
    NULL::text
FROM public.matches

UNION ALL

SELECT
    'GLOBAL',
    'MATCH_PROVIDER_MAP_COUNT_UNCHANGED',
    CASE WHEN COUNT(*) = 121908 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121908,
    COUNT(*)::bigint,
    NULL::text
FROM public.match_provider_map

UNION ALL

SELECT
    'GLOBAL',
    'GLOBAL_RATING_ORPHANS_UNCHANGED',
    CASE WHEN COUNT(*) = 78794 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    78794,
    COUNT(*)::bigint,
    NULL::text
FROM public.mm_match_ratings r
LEFT JOIN public.matches m ON m.id = r.match_id
WHERE m.id IS NULL;


SELECT
    'ZAVER'::text AS sekce,
    'APPLY_PRECOMMIT_STATUS'::text AS kontrola,
    'APPLY_PRECOMMIT_OK'::text AS stav,
    121::bigint AS ocekavano,
    121::bigint AS skutecnost,
    'Vsechny hard kontroly prosly. Nasleduje COMMIT.'::text AS detail;


-- ============================================================================
-- 8. FINALNI COMMIT
-- ============================================================================

COMMIT;


-- ============================================================================
-- B. POST-COMMIT READ ONLY AUDIT
-- ============================================================================

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL TIME ZONE 'UTC';


-- ============================================================================
-- 9. POST-COMMIT AUDIT
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
    'POST_COMMIT',
    'LEGACY_MATCHES_REMAINING',
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    0,
    COUNT(*)::bigint,
    'Belgicky football_data_uk legacy scope v league_id=4 je prazdny.'::text
FROM public.matches
WHERE sport_id = 1
  AND league_id = 4
  AND ext_source = 'football_data_uk'

UNION ALL

SELECT
    'POST_COMMIT',
    'LAST_121_CANONICAL_MATCHES_PRESENT',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    'Posledni skupina je identifikovana providerem football_data_uk a ucasti canonical teams 986/988.'::text
FROM public.matches
WHERE sport_id = 1
  AND league_id = 20853
  AND ext_source = 'football_data_uk'
  AND (
      home_team_id IN (986, 988)
      OR away_team_id IN (986, 988)
  )

UNION ALL

SELECT
    'POST_COMMIT',
    'API_IDENTITIES_737_743_PRESENT',
    CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    2,
    COUNT(*)::bigint,
    '986->api_football:743; 988->api_football:737.'::text
FROM public.team_provider_map
WHERE provider = 'api_football'
  AND (
      (team_id = 986 AND provider_team_id = '743')
      OR
      (team_id = 988 AND provider_team_id = '737')
  )

UNION ALL

SELECT
    'POST_COMMIT',
    'LOKEREN_TEMSE_SEPARATE_IDENTITY_PRESERVED',
    CASE WHEN COUNT(*) = 1 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    1,
    COUNT(*)::bigint,
    'api_football:14128 zustava mapovano pouze na samostatny public team 12819.'::text
FROM public.team_provider_map
WHERE team_id = 12819
  AND provider = 'api_football'
  AND provider_team_id = '14128'

UNION ALL

SELECT
    'GLOBAL',
    'MATCH_COUNT_UNCHANGED',
    CASE WHEN COUNT(*) = 120981 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    120981,
    COUNT(*)::bigint,
    NULL::text
FROM public.matches

UNION ALL

SELECT
    'GLOBAL',
    'MATCH_PROVIDER_MAP_COUNT_UNCHANGED',
    CASE WHEN COUNT(*) = 121908 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121908,
    COUNT(*)::bigint,
    NULL::text
FROM public.match_provider_map

UNION ALL

SELECT
    'GLOBAL',
    'GLOBAL_RATING_ORPHANS_UNCHANGED',
    CASE WHEN COUNT(*) = 78794 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    78794,
    COUNT(*)::bigint,
    NULL::text
FROM public.mm_match_ratings r
LEFT JOIN public.matches m ON m.id = r.match_id
WHERE m.id IS NULL;


-- ============================================================================
-- 10. POST-COMMIT DOWNSTREAM AUDIT POSLEDNI SKUPINY
-- ============================================================================

WITH last_group AS (
    SELECT m.id, m.league_id, m.home_team_id, m.away_team_id, m.kickoff
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 20853
      AND m.ext_source = 'football_data_uk'
      AND (
          m.home_team_id IN (986, 988)
          OR m.away_team_id IN (986, 988)
      )
)
SELECT
    'DOWNSTREAM'::text AS sekce,
    'LAST_GROUP_MATCH_FEATURE_ROWS'::text AS kontrola,
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
    121::bigint AS ocekavano,
    COUNT(*)::bigint AS skutecnost,
    NULL::text AS detail
FROM public.match_features f
JOIN last_group g ON g.id = f.match_id

UNION ALL

SELECT
    'DOWNSTREAM',
    'LAST_GROUP_RATING_DIMENSIONS_ALIGNED',
    CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
    121,
    COUNT(*)::bigint,
    NULL::text
FROM public.mm_match_ratings r
JOIN last_group g ON g.id = r.match_id
WHERE r.league_id = g.league_id
  AND r.home_team_id = g.home_team_id
  AND r.away_team_id = g.away_team_id
  AND r.kickoff IS NOT DISTINCT FROM g.kickoff;


-- ============================================================================
-- 11. FINALNI STATUS
-- ============================================================================

WITH final_state AS (
    SELECT
        (SELECT COUNT(*)
         FROM public.matches
         WHERE sport_id = 1
           AND league_id = 4
           AND ext_source = 'football_data_uk') AS legacy_remaining,

        (SELECT COUNT(*)
         FROM public.matches
         WHERE sport_id = 1
           AND league_id = 20853
           AND ext_source = 'football_data_uk'
           AND (home_team_id IN (986,988) OR away_team_id IN (986,988))) AS final_121,

        (SELECT COUNT(*)
         FROM public.team_provider_map
         WHERE provider = 'api_football'
           AND (
             (team_id = 986 AND provider_team_id = '743')
             OR
             (team_id = 988 AND provider_team_id = '737')
           )) AS provider_identities
)
SELECT
    'ZAVER'::text AS sekce,
    'POST_COMMIT_AUDIT_STATUS'::text AS kontrola,
    CASE
        WHEN legacy_remaining = 0
         AND final_121 = 121
         AND provider_identities = 2
        THEN 'POST_COMMIT_AUDIT_OK'
        ELSE 'POST_COMMIT_AUDIT_REVIEW_REQUIRED'
    END AS stav,
    121::bigint AS ocekavano,
    final_121::bigint AS skutecnost,
    'Pokud je stav OK, posledni belgicky legacy scope je kanonizovan.'::text AS detail
FROM final_state;

ROLLBACK;