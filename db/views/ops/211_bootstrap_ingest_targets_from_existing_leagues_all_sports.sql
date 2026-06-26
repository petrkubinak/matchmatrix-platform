-- 211_bootstrap_ingest_targets_from_existing_leagues_all_sports.sql
-- MatchMatrix
-- Bezpečný bootstrap ingest targetů ze stávajících canonical leagues + provider map.
-- Nezakládá nové ligy. Neřeší ještě provider-specific leagues ingest.
-- Jen doplní ops.ingest_targets tam, kde už v DB existuje:
--   1) public.leagues
--   2) public.sports
--   3) public.league_provider_map
--
-- Doporučené spuštění:
-- DBeaver -> matchmatrix DB -> Execute script
--
-- Výsledek:
-- - doplní chybějící ingest targets pro sporty/ligy, které už mají provider mapování
-- - nezdvojí existující targety
-- - nastaví rozumné defaulty pro free/test režim
--
-- Poznámka:
-- Pokud některé sporty stále nebudou mít targety, znamená to, že zatím chybí:
-- - public.leagues
-- nebo
-- - public.league_provider_map
-- pro daný sport/provider.

BEGIN;

-- =========================================================
-- 0) VOLITELNÁ KONTROLA PŘED
-- =========================================================
-- SELECT sport_code, provider, COUNT(*)
-- FROM ops.ingest_targets
-- GROUP BY sport_code, provider
-- ORDER BY sport_code, provider;

-- =========================================================
-- 1) DOPLNĚNÍ TARGETŮ ZE STÁVAJÍCÍCH LIG A PROVIDER MAP
-- =========================================================
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
    created_at,
    updated_at,
    run_group
)
SELECT
    s.code AS sport_code,
    l.id AS canonical_league_id,
    lpm.provider,
    lpm.provider_league_id,
    CASE
        -- free/test režim: default 2024
        WHEN s.code = 'FB' THEN '2024'
        WHEN s.code IN ('HK', 'BK') THEN '2025'
        ELSE '2024'
    END AS season,
    FALSE AS enabled,              -- bezpečně nejdřív založit jako disabled
    COALESCE(l.tier, 3) AS tier,
    7 AS fixtures_days_back,
    14 AS fixtures_days_forward,
    3 AS odds_days_forward,
    20 AS max_requests_per_run,
    'BOOTSTRAP_FROM_EXISTING_LEAGUES_ALL_SPORTS_V1' AS notes,
    NOW() AS created_at,
    NOW() AS updated_at,
    CASE
        WHEN s.code = 'FB' THEN 'FB_BOOTSTRAP_V1'
        WHEN s.code = 'HK' THEN 'HK_BOOTSTRAP_V1'
        WHEN s.code = 'BK' THEN 'BK_BOOTSTRAP_V1'
        ELSE s.code || '_BOOTSTRAP_V1'
    END AS run_group
FROM public.leagues l
JOIN public.sports s
    ON s.id = l.sport_id
JOIN public.league_provider_map lpm
    ON lpm.league_id = l.id
LEFT JOIN ops.ingest_targets t
    ON t.canonical_league_id = l.id
   AND t.provider = lpm.provider
   AND t.provider_league_id = lpm.provider_league_id
   AND COALESCE(t.season, '') = CASE
        WHEN s.code = 'FB' THEN '2024'
        WHEN s.code IN ('HK', 'BK') THEN '2025'
        ELSE '2024'
   END
WHERE t.id IS NULL;

-- =========================================================
-- 2) VOLITELNÉ ZAPNUTÍ JEN PRO SPORTY, KDE CHCEŠ PANEL/PLANNER TEST
--    TADY NECHÁVÁM DEFAULTNĚ VYPNUTÉ
-- =========================================================
-- Pokud budeš chtít další krok, uděláme samostatný enable script.
-- Tím si zachováš kontrolu.

-- =========================================================
-- 3) VÝSTUPNÍ KONTROLY
-- =========================================================

-- A) Kolik targetů je nově po sportech
-- (spusť po INSERTu)
-- SELECT
--     sport_code,
--     provider,
--     enabled,
--     COUNT(*) AS targets
-- FROM ops.ingest_targets
-- GROUP BY sport_code, provider, enabled
-- ORDER BY sport_code, provider, enabled;

-- B) Které ligy pořád nemají žádný target
-- (užitečné pro další bootstrap krok)
-- SELECT
--     s.code AS sport_code,
--     s.name AS sport_name,
--     l.id   AS league_id,
--     l.name AS league_name
-- FROM public.leagues l
-- JOIN public.sports s
--   ON s.id = l.sport_id
-- LEFT JOIN ops.ingest_targets t
--   ON t.canonical_league_id = l.id
-- WHERE t.id IS NULL
-- ORDER BY s.code, l.name;

COMMIT;