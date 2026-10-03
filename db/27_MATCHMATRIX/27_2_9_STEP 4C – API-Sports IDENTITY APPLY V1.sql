/*
CO: STEP 4C – API-Sports IDENTITY APPLY V1.
K ČEMU: Trvale uložit identitu ověřenou v STEP 4B.
KDE: Databáze matchmatrix.
JAK: Kontrola výchozího stavu, INSERT, kontrola, COMMIT.
*/

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';

LOCK TABLE
    ops.source_master,
    ops.source_alias,
    ops.source_sport
IN SHARE ROW EXCLUSIVE MODE;

DO $$
DECLARE
    v_source_id bigint;
    v_alias_id  bigint;
    v_sport_id  bigint;
    v_rows      integer;
BEGIN
    IF (SELECT COUNT(*) FROM ops.source_master) <> 17
       OR (SELECT COUNT(*) FROM ops.source_alias) <> 35
       OR (SELECT COUNT(*) FROM ops.source_sport) <> 17
    THEN
        RAISE EXCEPTION
            'Výchozí počty se změnily. Očekáváno 17 / 35 / 17. APPLY zastaven.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM ops.source_master
        WHERE lower(source_code)
                  IN ('api_sports', 'api-sports', 'apisports')
           OR lower(canonical_name)
                  IN ('api-sports', 'api sports', 'apisports')
           OR lower(COALESCE(canonical_domain, ''))
                  = 'api-sports.io'
    ) THEN
        RAISE EXCEPTION
            'Nalezena možná existující identita API-Sports. APPLY zastaven.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM ops.source_alias
        WHERE valid_to IS NULL
          AND lower(normalized_alias)
              IN ('api-sports', 'api sports', 'apisports',
                  'api_sports', 'api-sports.io')
    ) THEN
        RAISE EXCEPTION
            'Nalezen možný kolizní alias API-Sports. APPLY zastaven.';
    END IF;

    SELECT COALESCE(MAX(source_id), 0) + 1
      INTO v_source_id
      FROM ops.source_master;

    SELECT COALESCE(MAX(source_alias_id), 0) + 1
      INTO v_alias_id
      FROM ops.source_alias;

    SELECT COALESCE(MAX(source_sport_id), 0) + 1
      INTO v_sport_id
      FROM ops.source_sport;

    INSERT INTO ops.source_master (
        source_id, source_code, canonical_name,
        source_type, lifecycle_status, canonical_domain,
        owner_org, notes
    )
    VALUES (
        v_source_id, 'api_sports', 'API-Sports',
        'DATA_PROVIDER', 'FROZEN', 'api-sports.io',
        NULL,
        'STEP 4C IDENTITY APPLY V1 po úspěšném STEP 4B. '
        'Identita sama nepotvrzuje pokrytí ani oprávnění k harvestu.'
    );

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    IF v_rows <> 1 THEN
        RAISE EXCEPTION 'Zdroj: vloženo % řádků místo 1.', v_rows;
    END IF;

    INSERT INTO ops.source_alias (
        source_alias_id, source_id, alias_type,
        alias_value, normalized_alias,
        valid_from, valid_to, evidence_ref, is_preferred
    )
    VALUES
    (
        v_alias_id, v_source_id, 'SOURCE_NAME',
        'API-Sports', 'api-sports',
        NULL::date, NULL::date,
        'MM-NAV-20260927-03; STEP 4C IDENTITY APPLY V1', false
    ),
    (
        v_alias_id + 1, v_source_id, 'DOMAIN',
        'api-sports.io', 'api-sports.io',
        NULL::date, NULL::date,
        'MM-NAV-20260927-03; STEP 4C IDENTITY APPLY V1', false
    );

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    IF v_rows <> 2 THEN
        RAISE EXCEPTION 'Aliasy: vloženo % řádků místo 2.', v_rows;
    END IF;

    INSERT INTO ops.source_sport (
        source_sport_id, source_id, sport_code,
        relationship_status, sport_specific_url, notes
    )
    VALUES (
        v_sport_id, v_source_id, 'HB',
        'OBSERVED_IN_CURRENT_DATA',
        'https://v1.handball.api-sports.io',
        'STEP 4C IDENTITY APPLY V1; vztah ke sportu, '
        'nikoli schválení pokrytí nebo harvestu.'
    );

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    IF v_rows <> 1 THEN
        RAISE EXCEPTION 'Vztah HB: vloženo % řádků místo 1.', v_rows;
    END IF;

    -- Kontrola před potvrzením transakce.
    IF (SELECT COUNT(*) FROM ops.source_master) <> 18
       OR (SELECT COUNT(*) FROM ops.source_alias) <> 37
       OR (SELECT COUNT(*) FROM ops.source_sport) <> 18
    THEN
        RAISE EXCEPTION
            'Nesouhlasí výsledné počty 18 / 37 / 18. APPLY zastaven.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM ops.source_master
        WHERE source_id = v_source_id
          AND source_code = 'api_sports'
          AND canonical_name = 'API-Sports'
          AND source_type = 'DATA_PROVIDER'
          AND lifecycle_status = 'FROZEN'
          AND canonical_domain = 'api-sports.io'
    ) THEN
        RAISE EXCEPTION 'Výsledná identita neodpovídá návrhu.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM ops.source_alias
        WHERE source_id = v_source_id
          AND valid_from IS NULL
          AND valid_to IS NULL
          AND (
              (alias_type = 'SOURCE_NAME'
               AND alias_value = 'API-Sports'
               AND normalized_alias = 'api-sports')
              OR
              (alias_type = 'DOMAIN'
               AND alias_value = 'api-sports.io'
               AND normalized_alias = 'api-sports.io')
          )
    ) <> 2 THEN
        RAISE EXCEPTION 'Výsledné aliasy neodpovídají návrhu.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM ops.source_sport
        WHERE source_id = v_source_id
          AND sport_code = 'HB'
          AND relationship_status = 'OBSERVED_IN_CURRENT_DATA'
          AND sport_specific_url = 'https://v1.handball.api-sports.io'
    ) THEN
        RAISE EXCEPTION 'Výsledný vztah HB neodpovídá návrhu.';
    END IF;
END;
$$;

COMMIT;

-- Skutečný stav po potvrzení transakce.
SELECT
    (SELECT COUNT(*) FROM ops.source_master) AS zdroje,
    (SELECT COUNT(*) FROM ops.source_alias) AS aliasy,
    (SELECT COUNT(*) FROM ops.source_sport) AS vztahy_sportu;

SELECT
    s.source_id,
    s.source_code,
    s.canonical_name,
    s.lifecycle_status,
    a.alias_type,
    a.alias_value,
    a.normalized_alias,
    ss.sport_code,
    ss.relationship_status,
    ss.sport_specific_url
FROM ops.source_master s
JOIN ops.source_alias a ON a.source_id = s.source_id
JOIN ops.source_sport ss ON ss.source_id = s.source_id
WHERE s.source_code = 'api_sports'
ORDER BY a.alias_type;