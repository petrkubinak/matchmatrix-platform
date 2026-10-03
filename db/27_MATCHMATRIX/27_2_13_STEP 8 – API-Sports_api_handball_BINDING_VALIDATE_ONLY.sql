/*
CO:
STEP 8 – API-Sports -> api_handball SOURCE_ADAPTER_BINDING VALIDATE_ONLY.

K ČEMU:
Bez trvalé změny ověřit první tři technicky doložené bindingy:
fixtures, leagues, teams.

KDE:
Databáze matchmatrix.

JAK:
Guard kontroly -> 3 dočasné INSERTy -> kontrola -> ROLLBACK.
Players se záměrně nevkládají.
*/

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';

LOCK TABLE ops.source_adapter_binding
IN SHARE ROW EXCLUSIVE MODE;


/* =========================================================
   1. GUARD – OVĚŘENÍ VÝCHOZÍCH FAKTŮ
   ========================================================= */

DO $$
BEGIN

    -- Canonical API-Sports.
    IF NOT EXISTS (
        SELECT 1
        FROM ops.source_master
        WHERE source_id = 18
          AND source_code = 'api_sports'
          AND canonical_name = 'API-Sports'
          AND canonical_domain = 'api-sports.io'
    ) THEN
        RAISE EXCEPTION
            'Guard fail: source_id=18 není očekávaná API-Sports identita.';
    END IF;


    -- HB vztah zdroje.
    IF NOT EXISTS (
        SELECT 1
        FROM ops.source_sport
        WHERE source_id = 18
          AND sport_code = 'HB'
    ) THEN
        RAISE EXCEPTION
            'Guard fail: API-Sports nemá očekávaný vztah k HB.';
    END IF;


    -- Runtime adapter.
    IF NOT EXISTS (
        SELECT 1
        FROM ops.runtime_adapter
        WHERE adapter_id = 9
          AND adapter_code = 'api_handball'
          AND runtime_status = 'REGISTERED'
    ) THEN
        RAISE EXCEPTION
            'Guard fail: adapter_id=9 není očekávaný REGISTERED api_handball.';
    END IF;


    -- Aktivní účet.
    IF NOT EXISTS (
        SELECT 1
        FROM ops.provider_accounts
        WHERE id = 5
          AND provider = 'api_handball'
          AND is_active = true
          AND api_base_url = 'https://v1.handball.api-sports.io'
    ) THEN
        RAISE EXCEPTION
            'Guard fail: účet 5 neodpovídá api_handball/API-Sports endpointu.';
    END IF;


    -- Přesně tři CORE entity, které teď validujeme.
    IF (
        SELECT COUNT(*)
        FROM ops.provider_worker_registry
        WHERE provider = 'api_handball'
          AND sport_code = 'HB'
          AND entity IN ('fixtures', 'leagues', 'teams')
          AND is_supported = true
          AND is_active = true
    ) <> 3 THEN
        RAISE EXCEPTION
            'Guard fail: nejsou potvrzeny všechny tři HB CORE workery.';
    END IF;


    -- Players musí být registrovaný odděleně,
    -- ale v tomto STEP se binding nevytváří.
    IF NOT EXISTS (
        SELECT 1
        FROM ops.provider_worker_registry
        WHERE id = 49
          AND provider = 'api_handball'
          AND sport_code = 'HB'
          AND entity = 'players'
          AND is_supported = true
          AND is_active = true
    ) THEN
        RAISE EXCEPTION
            'Guard fail: očekávaný samostatný players worker 49 nebyl nalezen.';
    END IF;


    -- Pro API-Sports / api_handball nesmí už existovat binding.
    IF EXISTS (
        SELECT 1
        FROM ops.source_adapter_binding
        WHERE source_id = 18
           OR adapter_id = 9
    ) THEN
        RAISE EXCEPTION
            'Guard fail: API-Sports nebo api_handball už mají binding.';
    END IF;

END;
$$;


/* =========================================================
   2. DŮKAZ, ŽE VALIDATE_ONLY NEPOUŽIJE SEQUENCE
   ========================================================= */

SELECT
    'SEQUENCE_PRED_TESTEM' AS krok,
    last_value,
    is_called
FROM ops.source_adapter_binding_source_adapter_binding_id_seq;


/* =========================================================
   3. DOČASNÉ BINDINGY

   Záporná ID používáme záměrně:
   - VALIDATE_ONLY nesmí posunout sequence,
   - po ROLLBACK nezůstane žádná změna.
   ========================================================= */

INSERT INTO ops.source_adapter_binding (
    source_adapter_binding_id,
    source_id,
    adapter_id,
    sport_code,
    entity,
    account_id,
    worker_binding_id,
    binding_status,
    is_active,
    notes
)
VALUES
(
    -1001,
    18,
    9,
    'HB',
    'fixtures',
    5,
    NULL,
    'EVIDENCED',
    false,
    'STEP 8 VALIDATE_ONLY. API-Sports -> api_handball / HB / fixtures. '
    'Identity + endpoint + runtime worker evidence. '
    'Není runtime test, coverage confirmation ani routing approval.'
),
(
    -1002,
    18,
    9,
    'HB',
    'leagues',
    5,
    NULL,
    'EVIDENCED',
    false,
    'STEP 8 VALIDATE_ONLY. API-Sports -> api_handball / HB / leagues. '
    'Identity + endpoint + runtime worker evidence. '
    'Není runtime test, coverage confirmation ani routing approval.'
),
(
    -1003,
    18,
    9,
    'HB',
    'teams',
    5,
    NULL,
    'EVIDENCED',
    false,
    'STEP 8 VALIDATE_ONLY. API-Sports -> api_handball / HB / teams. '
    'Identity + endpoint + runtime worker evidence. '
    'Není runtime test, coverage confirmation ani routing approval.'
);


/* =========================================================
   4. KONTROLA UVNITŘ TESTU
   ========================================================= */

SELECT
    'UVNITR_TESTU' AS krok,
    COUNT(*) AS binding_rows
FROM ops.source_adapter_binding;


SELECT
    b.source_adapter_binding_id,
    b.source_id,
    s.canonical_name,
    b.adapter_id,
    a.adapter_code,
    b.sport_code,
    b.entity,
    b.account_id,
    b.worker_binding_id,
    b.binding_status,
    b.is_active
FROM ops.source_adapter_binding b
JOIN ops.source_master s
  ON s.source_id = b.source_id
JOIN ops.runtime_adapter a
  ON a.adapter_id = b.adapter_id
WHERE b.source_id = 18
ORDER BY b.entity;


/* =========================================================
   5. PLAYERS MUSÍ ZŮSTAT MIMO BINDING
   ========================================================= */

SELECT
    'PLAYERS_BINDING_ROWS' AS kontrola,
    COUNT(*) AS rows_count
FROM ops.source_adapter_binding
WHERE source_id = 18
  AND adapter_id = 9
  AND sport_code = 'HB'
  AND entity = 'players';


/* =========================================================
   6. ROLLBACK
   ========================================================= */

ROLLBACK;


/* =========================================================
   7. DŮKAZ NÁVRATU
   ========================================================= */

SELECT
    'PO_ROLLBACKU' AS krok,
    COUNT(*) AS binding_rows
FROM ops.source_adapter_binding
WHERE source_id = 18
   OR adapter_id = 9;


SELECT
    'SEQUENCE_PO_TESTU' AS krok,
    last_value,
    is_called
FROM ops.source_adapter_binding_source_adapter_binding_id_seq;