/*
===============================================================================
MATCHMATRIX 20_1_P3 – PROVIDER DISCOVERY ACTION
===============================================================================

CO TO JE:
SQL akce, která z operátorské chyby typu „chybí specializovaný provider“
vytvoří konkrétní úkol pro hledání nového providera.

K ČEMU TO JE:
Panel už nebude jen hlásit:

api_volleyball → HLEDAT PEOPLE PROVIDERA

ale založí úkol:

VB / PEOPLE / players
Najít náhradního providera pro Volleyball players.

KDE TO UVIDÍME:
OPS PANEL
→ DENNÍ PRÁCE
→ PROVIDER / DOPORUČENÍ

a následně v DB:
ops.source_discovery_tasks

JAK SE TO VYUŽIJE:
Operátor vybere problematický řádek VB a spustí akci HLEDAT PROVIDERA.
Systém zapíše discovery úkol, který později použijeme pro Provider Matrix.

NAVAZUJE NA:
20_1_P2_A_provider_context_view.sql
20_1_P2_B_operator_panel_provider_context_binding.py

DALŠÍ KROK:
20_1_P4_operator_provider_discovery_panel_binding.py

SOUBOR:
20_1_P3_provider_discovery_action.sql

KAM ULOŽIT:
C:\MatchMatrix-platform\db\ops\20_1\

JAK SPUSTIT:
DBeaver → spustit celý SQL skript.

CO OČEKÁVAT:
Pro VB vznikne úkol:
VB / players / RESEARCH_REQUIRED
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.operator_provider_discovery_actions (
    discovery_action_id bigserial PRIMARY KEY,
    created_at timestamptz NOT NULL DEFAULT now(),
    command_id bigint,
    sport_code text,
    sport_name text,
    target_layer text,
    entity_type text,
    current_provider text,
    discovery_reason text,
    recommended_action text,
    action_status text NOT NULL DEFAULT 'OPEN',
    created_by text NOT NULL DEFAULT 'MATCHMATRIX_PANEL'
);

CREATE OR REPLACE FUNCTION ops.fn_operator_create_provider_discovery_action_v1(
    p_command_id bigint,
    p_created_by text DEFAULT 'PANEL_OPERATOR'
)
RETURNS TABLE (
    success boolean,
    command_id bigint,
    sport_code text,
    entity_type text,
    current_provider text,
    action_status text,
    message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_row record;
    v_existing_id bigint;
BEGIN
    SELECT *
    INTO v_row
    FROM ops.v_operator_provider_context_v1
    WHERE id = p_command_id
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            false,
            p_command_id,
            NULL::text,
            NULL::text,
            NULL::text,
            'NOT_FOUND'::text,
            'Příkaz nebyl nalezen v operator provider context view.'::text;
        RETURN;
    END IF;

    IF COALESCE(v_row.provider_context_status, '') <> 'RESEARCH_REQUIRED' THEN
        RETURN QUERY
        SELECT
            false,
            p_command_id,
            v_row.sport_code::text,
            COALESCE(v_row.detected_entity, 'players')::text,
            COALESCE(v_row.detected_provider, 'UNKNOWN')::text,
            'NOT_REQUIRED'::text,
            'Pro tento řádek není potřeba hledat nového providera.'::text;
        RETURN;
    END IF;

    SELECT discovery_action_id
    INTO v_existing_id
    FROM ops.operator_provider_discovery_actions d
    WHERE d.sport_code = v_row.sport_code
  	  AND d.entity_type = COALESCE(v_row.detected_entity, 'players')
      AND d.action_status IN ('OPEN', 'IN_PROGRESS')
    ORDER BY discovery_action_id DESC
    LIMIT 1;

    IF v_existing_id IS NOT NULL THEN
        RETURN QUERY
        SELECT
            true,
            p_command_id,
            v_row.sport_code::text,
            COALESCE(v_row.detected_entity, 'players')::text,
            COALESCE(v_row.detected_provider, 'UNKNOWN')::text,
            'ALREADY_OPEN'::text,
            'Discovery úkol už existuje.'::text;
        RETURN;
    END IF;

    INSERT INTO ops.operator_provider_discovery_actions (
        command_id,
        sport_code,
        sport_name,
        target_layer,
        entity_type,
        current_provider,
        discovery_reason,
        recommended_action,
        created_by
    )
    VALUES (
        p_command_id,
        v_row.sport_code,
        v_row.sport_name,
        v_row.target_layer,
        COALESCE(v_row.detected_entity, 'players'),
        COALESCE(v_row.detected_provider, 'UNKNOWN'),
        COALESCE(v_row.provider_problem_cz, 'Chybí specializovaný provider.'),
        COALESCE(v_row.provider_next_step_cz, 'Najít náhradního providera.'),
        p_created_by
    );

    RETURN QUERY
    SELECT
        true,
        p_command_id,
        v_row.sport_code::text,
        COALESCE(v_row.detected_entity, 'players')::text,
        COALESCE(v_row.detected_provider, 'UNKNOWN')::text,
        'OPEN'::text,
        'Discovery úkol byl vytvořen.'::text;
END;
$$;

DROP VIEW IF EXISTS ops.v_operator_provider_discovery_actions_v1;

CREATE VIEW ops.v_operator_provider_discovery_actions_v1
AS
SELECT
    discovery_action_id,
    created_at,
    command_id,
    sport_code,
    sport_name,
    target_layer,
    entity_type,
    current_provider,
    discovery_reason,
    recommended_action,
    action_status,
    created_by
FROM ops.operator_provider_discovery_actions
ORDER BY
    CASE action_status
        WHEN 'OPEN' THEN 1
        WHEN 'IN_PROGRESS' THEN 2
        WHEN 'DONE' THEN 3
        ELSE 9
    END,
    created_at DESC;