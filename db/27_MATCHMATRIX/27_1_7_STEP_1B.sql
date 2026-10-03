/*
===============================================================================
MATCHMATRIX – HB STEP 1B
AUDIT ŠKÁLOVATELNOSTI SPORT / PROVIDER / SOURCE ARCHITEKTURY
===============================================================================

CO:
    Prověří skutečnou strukturu a obsah klíčových databázových objektů
    potřebných pro budoucí dynamické rozšiřování MatchMatrix o další sporty.

K ČEMU:
    Ověřit:
    1. jak je definován master seznam sportů,
    2. zda počet sportů není technicky omezen,
    3. jak jsou dnes evidovány globální zdroje,
    4. zda jsou stejné zdroje duplikovány podle sportů,
    5. jak je připraven acquisition routing,
    6. jak je připraven acquisition checklist,
    7. zda nový model již pracuje s entity × time_mode,
    8. co bude nutné případně upravit před HB Provider Discovery.

KDE:
    PostgreSQL databáze: matchmatrix
    Schémata: public, ops

JAK:
    READ ONLY.

    Skript NEPROVÁDÍ:
    - CREATE
    - ALTER
    - DROP
    - INSERT
    - UPDATE
    - DELETE

===============================================================================
*/


-- ============================================================================
-- 1. PUBLIC.SPORTS – SKUTEČNÁ STRUKTURA MASTER TABULKY SPORTŮ
-- ============================================================================

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    udt_name,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'sports'
ORDER BY ordinal_position;


-- ============================================================================
-- 2. PUBLIC.SPORTS – CONSTRAINTS
-- ============================================================================

SELECT
    conrelid::regclass::text AS object_name,
    conname AS constraint_name,
    CASE contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'c' THEN 'CHECK'
        WHEN 'x' THEN 'EXCLUSION'
        ELSE contype::text
    END AS constraint_type,
    pg_get_constraintdef(oid, true) AS definition
FROM pg_constraint
WHERE conrelid = 'public.sports'::regclass
ORDER BY
    constraint_type,
    constraint_name;


-- ============================================================================
-- 3. PUBLIC.SPORTS – AKTUÁLNÍ OBSAH
-- ============================================================================

SELECT *
FROM public.sports
ORDER BY code;


-- ============================================================================
-- 4. PUBLIC.SPORTS – CELKOVÝ POČET SPORTŮ
-- ============================================================================

SELECT
    COUNT(*) AS sports_total
FROM public.sports;


-- ============================================================================
-- 5. GLOBAL SOURCE REGISTRY – AKTUÁLNÍ OBSAH
-- ============================================================================

SELECT
    source_id,
    sport_code,
    source_name,
    source_type,
    source_level,
    source_url,
    source_status,
    discovery_status,
    verification_status,
    commercial_status,
    people_supported,
    coaches_supported,
    photos_supported,
    statistics_supported,
    history_supported,
    media_supported,
    priority_score,
    notes,
    created_at,
    updated_at
FROM ops.global_source_registry
ORDER BY
    source_name,
    sport_code,
    source_id;


-- ============================================================================
-- 6. GLOBAL SOURCE REGISTRY – POČET ZÁZNAMŮ
-- ============================================================================

SELECT
    COUNT(*) AS registry_rows,
    COUNT(DISTINCT source_name) AS distinct_source_names,
    COUNT(DISTINCT sport_code) AS distinct_sports
FROM ops.global_source_registry;


-- ============================================================================
-- 7. STEJNÝ SOURCE_NAME VE VÍCE SPORTECH
--
-- CÍL:
--     Zjistit, zda dnešní "global" registry ve skutečnosti obsahuje
--     opakovanou identitu stejného zdroje pro různé sporty.
-- ============================================================================

SELECT
    source_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT sport_code) AS sport_count,
    STRING_AGG(
        DISTINCT sport_code,
        ', '
        ORDER BY sport_code
    ) AS sports
FROM ops.global_source_registry
GROUP BY source_name
HAVING COUNT(DISTINCT sport_code) > 1
ORDER BY
    sport_count DESC,
    source_name;


-- ============================================================================
-- 8. STEJNÁ SOURCE_URL VE VÍCE ZÁZNAMECH
--
-- Druhá kontrola identity.
-- Stejná URL může odhalit zdroj uložený vícekrát pod různými sporty
-- nebo pod různými názvy.
-- ============================================================================

SELECT
    source_url,
    COUNT(*) AS row_count,
    COUNT(DISTINCT source_name) AS source_name_count,
    COUNT(DISTINCT sport_code) AS sport_count,
    STRING_AGG(
        DISTINCT source_name,
        ' | '
        ORDER BY source_name
    ) AS source_names,
    STRING_AGG(
        DISTINCT sport_code,
        ', '
        ORDER BY sport_code
    ) AS sports
FROM ops.global_source_registry
WHERE source_url IS NOT NULL
  AND BTRIM(source_url) <> ''
GROUP BY source_url
HAVING COUNT(*) > 1
ORDER BY
    row_count DESC,
    source_url;


-- ============================================================================
-- 9. SOURCE NAME + TYPE – KONTROLA POTENCIÁLNÍCH DUPLICIT
-- ============================================================================

SELECT
    LOWER(BTRIM(source_name)) AS normalized_source_name,
    LOWER(BTRIM(source_type)) AS normalized_source_type,
    COUNT(*) AS row_count,
    COUNT(DISTINCT sport_code) AS sport_count,
    STRING_AGG(
        DISTINCT sport_code,
        ', '
        ORDER BY sport_code
    ) AS sports
FROM ops.global_source_registry
GROUP BY
    LOWER(BTRIM(source_name)),
    LOWER(BTRIM(source_type))
HAVING COUNT(*) > 1
ORDER BY
    row_count DESC,
    normalized_source_name;


-- ============================================================================
-- 10. PROVIDER × SPORT MATRIX – AKTUÁLNÍ ROZSAH
-- ============================================================================

SELECT
    id,
    provider,
    sport_code,
    sport_name,
    is_enabled,
    supports_leagues,
    supports_teams,
    supports_fixtures,
    supports_players,
    supports_player_stats,
    supports_odds,
    supports_coaches,
    supports_standings,
    notes,
    created_at,
    updated_at
FROM ops.provider_sport_matrix
ORDER BY
    sport_code,
    provider;


-- ============================================================================
-- 11. PROVIDER × SPORT MATRIX – SOUHRN PODLE SPORTU
-- ============================================================================

SELECT
    sport_code,
    MAX(sport_name) AS sport_name,
    COUNT(*) AS provider_rows,
    COUNT(*) FILTER (WHERE is_enabled) AS enabled_provider_rows,
    COUNT(DISTINCT provider) AS distinct_providers
FROM ops.provider_sport_matrix
GROUP BY sport_code
ORDER BY sport_code;


-- ============================================================================
-- 12. PROVIDER × SPORT MATRIX – PROVIDEŘI VE VÍCE SPORTECH
--
-- Tohle je důležité pro budoucí globální provider master.
-- ============================================================================

SELECT
    provider,
    COUNT(DISTINCT sport_code) AS sport_count,
    STRING_AGG(
        DISTINCT sport_code,
        ', '
        ORDER BY sport_code
    ) AS sports
FROM ops.provider_sport_matrix
GROUP BY provider
ORDER BY
    sport_count DESC,
    provider;


-- ============================================================================
-- 13. DATA ACQUISITION SOURCE ROUTING – STRUKTURA
-- ============================================================================

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    udt_name,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'data_acquisition_source_routing'
ORDER BY ordinal_position;


-- ============================================================================
-- 14. DATA ACQUISITION SOURCE ROUTING – CONSTRAINTS
-- ============================================================================

SELECT
    conrelid::regclass::text AS object_name,
    conname AS constraint_name,
    CASE contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'c' THEN 'CHECK'
        WHEN 'x' THEN 'EXCLUSION'
        ELSE contype::text
    END AS constraint_type,
    pg_get_constraintdef(oid, true) AS definition
FROM pg_constraint
WHERE conrelid = 'ops.data_acquisition_source_routing'::regclass
ORDER BY
    constraint_type,
    constraint_name;


-- ============================================================================
-- 15. DATA ACQUISITION SOURCE ROUTING – INDEXY
-- ============================================================================

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ops'
  AND tablename = 'data_acquisition_source_routing'
ORDER BY indexname;


-- ============================================================================
-- 16. DATA ACQUISITION SOURCE ROUTING – POČET ŘÁDKŮ
-- ============================================================================

SELECT
    COUNT(*) AS routing_rows
FROM ops.data_acquisition_source_routing;


-- ============================================================================
-- 17. DATA ACQUISITION SOURCE ROUTING – AKTUÁLNÍ OBSAH
--
-- Pravděpodobně zatím prázdné.
-- Pokud existují řádky, chceme je před návrhem architektury vidět.
-- ============================================================================

SELECT *
FROM ops.data_acquisition_source_routing
ORDER BY 1;


-- ============================================================================
-- 18. DATA ACQUISITION CHECKLIST DEFINITION – STRUKTURA
-- ============================================================================

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    udt_name,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'data_acquisition_checklist_definition'
ORDER BY ordinal_position;


-- ============================================================================
-- 19. DATA ACQUISITION CHECKLIST DEFINITION – CONSTRAINTS
-- ============================================================================

SELECT
    conrelid::regclass::text AS object_name,
    conname AS constraint_name,
    CASE contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'c' THEN 'CHECK'
        WHEN 'x' THEN 'EXCLUSION'
        ELSE contype::text
    END AS constraint_type,
    pg_get_constraintdef(oid, true) AS definition
FROM pg_constraint
WHERE conrelid = 'ops.data_acquisition_checklist_definition'::regclass
ORDER BY
    constraint_type,
    constraint_name;


-- ============================================================================
-- 20. DATA ACQUISITION CHECKLIST DEFINITION – INDEXY
-- ============================================================================

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ops'
  AND tablename = 'data_acquisition_checklist_definition'
ORDER BY indexname;


-- ============================================================================
-- 21. CHECKLIST – CELKOVÝ POČET ŘÁDKŮ
-- ============================================================================

SELECT
    COUNT(*) AS checklist_rows
FROM ops.data_acquisition_checklist_definition;


-- ============================================================================
-- 22. CHECKLIST – POUŽITÉ SPORTY
--
-- Používáme SELECT *, zabalený přes JSONB, aby tento diagnostický krok
-- nebyl závislý na předpokladu dalších sloupců.
-- ============================================================================

SELECT
    to_jsonb(d)->>'sport_code' AS sport_code,
    COUNT(*) AS checklist_rows
FROM ops.data_acquisition_checklist_definition d
GROUP BY
    to_jsonb(d)->>'sport_code'
ORDER BY
    sport_code;


-- ============================================================================
-- 23. CHECKLIST – POUŽITÉ TIME MODES
--
-- Potvrzení, zda nový acquisition model skutečně obsahuje časovou dimenzi.
-- ============================================================================

SELECT
    to_jsonb(d)->>'time_mode' AS time_mode,
    COUNT(*) AS checklist_rows
FROM ops.data_acquisition_checklist_definition d
GROUP BY
    to_jsonb(d)->>'time_mode'
ORDER BY
    time_mode;


-- ============================================================================
-- 24. CHECKLIST – SPORT × LAYER
-- ============================================================================

SELECT
    to_jsonb(d)->>'sport_code' AS sport_code,
    to_jsonb(d)->>'layer_code' AS layer_code,
    COUNT(*) AS checklist_rows
FROM ops.data_acquisition_checklist_definition d
GROUP BY
    to_jsonb(d)->>'sport_code',
    to_jsonb(d)->>'layer_code'
ORDER BY
    sport_code,
    layer_code;


-- ============================================================================
-- 25. CHECKLIST – SPORT × ENTITY × TIME MODE
--
-- Pro HB očekáváme definovaných 80 entity/time scopes.
-- ============================================================================

SELECT
    to_jsonb(d)->>'sport_code' AS sport_code,
    to_jsonb(d)->>'entity_code' AS entity_code,
    to_jsonb(d)->>'time_mode' AS time_mode,
    COUNT(*) AS checklist_items
FROM ops.data_acquisition_checklist_definition d
GROUP BY
    to_jsonb(d)->>'sport_code',
    to_jsonb(d)->>'entity_code',
    to_jsonb(d)->>'time_mode'
ORDER BY
    sport_code,
    entity_code,
    time_mode;


-- ============================================================================
-- 26. CHECKLIST – POUŽITÉ CHECK KÓDY
-- ============================================================================

SELECT
    to_jsonb(d)->>'check_code' AS check_code,
    COUNT(*) AS checklist_rows
FROM ops.data_acquisition_checklist_definition d
GROUP BY
    to_jsonb(d)->>'check_code'
ORDER BY
    check_code;


-- ============================================================================
-- 27. CHECKLIST – GAP POLICY / DECISION REQUIRED
--
-- Použití JSONB zajistí bezpečný READ i kdyby se názvy některých
-- pomocných polí v budoucnu změnily.
-- ============================================================================

SELECT
    to_jsonb(d)->>'gap_policy' AS gap_policy,
    to_jsonb(d)->>'decision_required' AS decision_required,
    COUNT(*) AS checklist_rows
FROM ops.data_acquisition_checklist_definition d
GROUP BY
    to_jsonb(d)->>'gap_policy',
    to_jsonb(d)->>'decision_required'
ORDER BY
    gap_policy,
    decision_required;


-- ============================================================================
-- 28. KONTROLA SPORTŮ POUŽITÝCH V OPS, KTERÉ NEJSOU V PUBLIC.SPORTS
--
-- Pokud něco vrátí, máme nekonzistenci master katalogu sportů.
-- ============================================================================

SELECT DISTINCT
    x.sport_code,
    x.source_object
FROM (
    SELECT
        sport_code,
        'ops.provider_sport_matrix' AS source_object
    FROM ops.provider_sport_matrix

    UNION ALL

    SELECT
        sport_code,
        'ops.provider_entity_coverage'
    FROM ops.provider_entity_coverage

    UNION ALL

    SELECT
        sport_code,
        'ops.global_source_registry'
    FROM ops.global_source_registry

    UNION ALL

    SELECT
        sport_code,
        'ops.source_intelligence_map'
    FROM ops.source_intelligence_map

    UNION ALL

    SELECT
        sport_code,
        'ops.source_coverage_matrix'
    FROM ops.source_coverage_matrix

    UNION ALL

    SELECT
        sport_code,
        'ops.source_commercial_model'
    FROM ops.source_commercial_model

    UNION ALL

    SELECT
        sport_code,
        'ops.source_legal_audit'
    FROM ops.source_legal_audit

    UNION ALL

    SELECT
        sport_code,
        'ops.source_discovery_audit_tracker'
    FROM ops.source_discovery_audit_tracker
) x
LEFT JOIN public.sports s
       ON s.code = x.sport_code
WHERE x.sport_code IS NOT NULL
  AND s.code IS NULL
ORDER BY
    x.sport_code,
    x.source_object;


-- ============================================================================
-- 29. OPAČNÁ KONTROLA:
-- SPORTY V PUBLIC.SPORTS BEZ PROVIDER_SPORT_MATRIX
--
-- Toto není chyba.
-- Je to velmi důležitý budoucí stav:
-- nový sport může existovat dříve, než pro něj proběhne provider discovery.
-- ============================================================================

SELECT
    s.*,
    COALESCE(psm.provider_matrix_rows, 0) AS provider_matrix_rows
FROM public.sports s
LEFT JOIN (
    SELECT
        sport_code,
        COUNT(*) AS provider_matrix_rows
    FROM ops.provider_sport_matrix
    GROUP BY sport_code
) psm
    ON psm.sport_code = s.code
ORDER BY
    s.code;


-- ============================================================================
-- 30. FINÁLNÍ DIAGNOSTICKÝ SOUHRN
-- ============================================================================

SELECT
    (SELECT COUNT(*) FROM public.sports)
        AS sports_total,

    (SELECT COUNT(*) FROM ops.global_source_registry)
        AS global_source_registry_rows,

    (SELECT COUNT(DISTINCT source_name)
       FROM ops.global_source_registry)
        AS distinct_global_source_names,

    (SELECT COUNT(*) FROM ops.provider_sport_matrix)
        AS provider_sport_rows,

    (SELECT COUNT(DISTINCT provider)
       FROM ops.provider_sport_matrix)
        AS distinct_providers,

    (SELECT COUNT(*) FROM ops.provider_entity_coverage)
        AS provider_entity_coverage_rows,

    (SELECT COUNT(*) FROM ops.source_discovery_audit_tracker)
        AS discovery_tracker_rows,

    (SELECT COUNT(*) FROM ops.data_acquisition_source_routing)
        AS acquisition_routing_rows,

    (SELECT COUNT(*) FROM ops.data_acquisition_checklist_definition)
        AS checklist_definition_rows;