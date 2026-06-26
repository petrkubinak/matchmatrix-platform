/*
===============================================================================
MATCHMATRIX 20_1_P7 – ACCEPT PROVIDER ACTION
===============================================================================

CO TO JE:
Akce pro přijetí validovaného kandidáta providera.

K ČEMU TO JE:
Z kandidáta typu Volleybox vytvoří implementační úkol pro novou provider větev.

KDE TO UVIDÍME:
OPS PANEL
→ PROVIDER DISCOVERY
→ validovaný kandidát
→ ✅ PŘIJMOUT PROVIDERA

JAK SE TO VYUŽIJE:
Pokud má kandidát status VALID_RESEARCH nebo PARTIAL a dostatečné skóre,
panel vytvoří implementační záznam pro další práci.

NAVAZUJE NA:
20_1_P6_A_provider_validation_engine.sql

DALŠÍ KROK:
20_2_A_VB_VOLLEYBOX_PROVIDER_AUDIT.sql / .md
20_2_B_VB_VOLLEYBOX_RAW_PULL
20_2_C_VB_VOLLEYBOX_PARSE
20_2_D_VB_VOLLEYBOX_MERGE

SOUBOR:
20_1_P7_accept_provider_action.sql

KAM ULOŽIT:
C:\MatchMatrix-platform\db\ops\20_1\

JAK SPUSTIT:
DBeaver → spustit celý SQL skript.

CO OČEKÁVAT:
Pro Volleybox vznikne implementační úkol:
VB / players / Volleybox / IMPLEMENTATION_READY
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.operator_provider_implementation_tasks (
    implementation_task_id bigserial PRIMARY KEY,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    validation_id bigint NOT NULL,
    candidate_id bigint,
    discovery_action_id bigint,

    sport_code text,
    entity_type text,
    accepted_provider text,
    provider_type text,

    implementation_status text NOT NULL DEFAULT 'IMPLEMENTATION_READY',
    implementation_priority numeric(10,2),
    implementation_epic text,
    implementation_note text,

    created_by text NOT NULL DEFAULT 'MATCHMATRIX_PANEL'
);

CREATE OR REPLACE FUNCTION ops.fn_operator_accept_provider_candidate_v1(
    p_validation_id bigint,
    p_created_by text DEFAULT 'PANEL_OPERATOR'
)
RETURNS TABLE (
    success boolean,
    validation_id bigint,
    sport_code text,
    entity_type text,
    accepted_provider text,
    implementation_status text,
    message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_validation record;
    v_existing_id bigint;
    v_epic text;
BEGIN
    SELECT *
    INTO v_validation
    FROM ops.v_operator_provider_validation_v1 v
    WHERE v.validation_id = p_validation_id
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            false,
            p_validation_id,
            NULL::text,
            NULL::text,
            NULL::text,
            'NOT_FOUND'::text,
            'Validace nebyla nalezena.'::text;
        RETURN;
    END IF;

    IF COALESCE(v_validation.validation_score, 0) < 70 THEN
        RETURN QUERY
        SELECT
            false,
            p_validation_id,
            v_validation.sport_code::text,
            v_validation.entity_type::text,
            v_validation.candidate_provider::text,
            'REJECTED_LOW_SCORE'::text,
            'Provider nemá dostatečné validační skóre pro přijetí.'::text;
        RETURN;
    END IF;

    IF COALESCE(v_validation.validation_status, '') NOT IN ('VALID_RESEARCH', 'VALID', 'PARTIAL') THEN
        RETURN QUERY
        SELECT
            false,
            p_validation_id,
            v_validation.sport_code::text,
            v_validation.entity_type::text,
            v_validation.candidate_provider::text,
            'NOT_ACCEPTABLE_STATUS'::text,
            'Provider zatím nemá status vhodný k přijetí.'::text;
        RETURN;
    END IF;

    SELECT t.implementation_task_id
    INTO v_existing_id
    FROM ops.operator_provider_implementation_tasks t
    WHERE t.sport_code = v_validation.sport_code
      AND t.entity_type = v_validation.entity_type
      AND t.accepted_provider = v_validation.candidate_provider
      AND t.implementation_status IN ('IMPLEMENTATION_READY', 'IN_PROGRESS')
    ORDER BY t.implementation_task_id DESC
    LIMIT 1;

    IF v_existing_id IS NOT NULL THEN
        RETURN QUERY
        SELECT
            true,
            p_validation_id,
            v_validation.sport_code::text,
            v_validation.entity_type::text,
            v_validation.candidate_provider::text,
            'ALREADY_EXISTS'::text,
            'Implementační úkol už existuje.'::text;
        RETURN;
    END IF;

    v_epic :=
        '20_2_' ||
        COALESCE(v_validation.sport_code, 'SPORT') ||
        '_' ||
        UPPER(REPLACE(COALESCE(v_validation.candidate_provider, 'PROVIDER'), ' ', '_')) ||
        '_' ||
        UPPER(COALESCE(v_validation.entity_type, 'ENTITY'));

    INSERT INTO ops.operator_provider_implementation_tasks (
        validation_id,
        candidate_id,
        discovery_action_id,
        sport_code,
        entity_type,
        accepted_provider,
        provider_type,
        implementation_status,
        implementation_priority,
        implementation_epic,
        implementation_note,
        created_by
    )
    VALUES (
        p_validation_id,
        v_validation.candidate_id,
        v_validation.discovery_action_id,
        v_validation.sport_code,
        v_validation.entity_type,
        v_validation.candidate_provider,
        v_validation.provider_type,
        'IMPLEMENTATION_READY',
        v_validation.validation_score,
        v_epic,
        'Provider byl přijat jako kandidát k implementaci. Další krok: audit zdroje, licence/podmínky, návrh pulleru, parseru a merge do People vrstvy.',
        p_created_by
    );

    RETURN QUERY
    SELECT
        true,
        p_validation_id,
        v_validation.sport_code::text,
        v_validation.entity_type::text,
        v_validation.candidate_provider::text,
        'IMPLEMENTATION_READY'::text,
        'Provider byl přijat a implementační úkol byl vytvořen.'::text;
END;
$$;

DROP VIEW IF EXISTS ops.v_operator_provider_implementation_tasks_v1;

CREATE VIEW ops.v_operator_provider_implementation_tasks_v1
AS
SELECT
    t.implementation_task_id,
    t.validation_id,
    t.candidate_id,
    t.discovery_action_id,
    t.sport_code,
    t.entity_type,
    t.accepted_provider,
    t.provider_type,
    t.implementation_status,
    t.implementation_priority,
    t.implementation_epic,
    t.implementation_note,
    t.created_at,
    t.updated_at,
    t.created_by
FROM ops.operator_provider_implementation_tasks t
ORDER BY
    t.implementation_priority DESC NULLS LAST,
    t.created_at DESC;