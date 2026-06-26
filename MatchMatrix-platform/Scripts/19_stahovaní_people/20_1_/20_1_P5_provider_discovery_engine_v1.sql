/*
===============================================================================
MATCHMATRIX 20_1_P5 – PROVIDER DISCOVERY ENGINE V1
===============================================================================

CO TO JE:
První discovery engine pro hledání náhradního providera.

K ČEMU TO JE:
Po kliknutí na HLEDAT PROVIDERA už systém nezůstane jen u zápisu úkolu,
ale vytvoří kandidáty providerů pro daný sport / entitu.

KDE TO UVIDÍME:
OPS PANEL
→ DENNÍ PRÁCE
→ HLEDAT PROVIDERA

DB:
ops.operator_provider_discovery_candidates
ops.v_operator_provider_discovery_candidates_v1

JAK SE TO VYUŽIJE:
Pro VB / players engine vytvoří první kandidáty:
- VOLLEYBOX
- RAPIDAPI
- WIKIDATA
- OFFICIAL FEDERATION SITES
- SPORTS REFERENCE / MANUAL SOURCE

NAVAZUJE NA:
20_1_P3_provider_discovery_action.sql
20_1_P4_operator_provider_discovery_panel_binding.py

DALŠÍ KROK:
20_1_P6_provider_discovery_panel_results.py

SOUBOR:
20_1_P5_provider_discovery_engine_v1.sql

KAM ULOŽIT:
C:\MatchMatrix-platform\db\ops\20_1\

JAK SPUSTIT:
DBeaver → spustit celý SQL skript.

CO OČEKÁVAT:
Pro discovery_action_id vzniknou kandidáti providerů.
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.operator_provider_discovery_candidates (
    candidate_id bigserial PRIMARY KEY,
    created_at timestamptz NOT NULL DEFAULT now(),
    discovery_action_id bigint NOT NULL,
    sport_code text,
    entity_type text,
    candidate_provider text,
    provider_type text,
    expected_coverage text,
    access_status text,
    priority_score numeric(10,2),
    research_status text NOT NULL DEFAULT 'CANDIDATE',
    recommendation_note text,
    created_by text NOT NULL DEFAULT 'MATCHMATRIX_DISCOVERY_ENGINE'
);

CREATE OR REPLACE FUNCTION ops.fn_operator_run_provider_discovery_engine_v1(
    p_discovery_action_id bigint,
    p_created_by text DEFAULT 'PANEL_OPERATOR'
)
RETURNS TABLE (
    success boolean,
    discovery_action_id bigint,
    sport_code text,
    entity_type text,
    candidates_created integer,
    message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_action record;
    v_created integer := 0;
BEGIN
    SELECT *
    INTO v_action
    FROM ops.operator_provider_discovery_actions a
    WHERE a.discovery_action_id = p_discovery_action_id
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            false,
            p_discovery_action_id,
            NULL::text,
            NULL::text,
            0,
            'Discovery úkol nebyl nalezen.'::text;
        RETURN;
    END IF;

    DELETE FROM ops.operator_provider_discovery_candidates c
    WHERE c.discovery_action_id = p_discovery_action_id;

    IF v_action.sport_code = 'VB'
       AND v_action.entity_type = 'players'
    THEN
        INSERT INTO ops.operator_provider_discovery_candidates (
            discovery_action_id,
            sport_code,
            entity_type,
            candidate_provider,
            provider_type,
            expected_coverage,
            access_status,
            priority_score,
            research_status,
            recommendation_note,
            created_by
        )
        VALUES
        (
            p_discovery_action_id,
            'VB',
            'players',
            'Volleybox',
            'COMMUNITY / PROFILE DATABASE',
            'players, profiles, photos, teams',
            'RESEARCH_REQUIRED',
            95,
            'CANDIDATE',
            'První kandidát pro volleyball people vrstvu. Ověřit dostupnost, podmínky použití a možnost strukturovaného získání dat.',
            p_created_by
        ),
        (
            p_discovery_action_id,
            'VB',
            'players',
            'RapidAPI Volleyball alternatives',
            'API MARKETPLACE',
            'players nebo team rosters podle dostupného API',
            'RESEARCH_REQUIRED',
            85,
            'CANDIDATE',
            'Ověřit dostupné volleyball API na RapidAPI, hlavně players/rosters endpointy.',
            p_created_by
        ),
        (
            p_discovery_action_id,
            'VB',
            'players',
            'Wikidata / Wikimedia',
            'OPEN KNOWLEDGE',
            'profiles, photos, identifiers',
            'LICENSE_REVIEW',
            75,
            'CANDIDATE',
            'Vhodné hlavně pro profily a fotografie, ne kompletní soupisky.',
            p_created_by
        ),
        (
            p_discovery_action_id,
            'VB',
            'players',
            'Official federation / league sites',
            'OFFICIAL SITE',
            'team rosters, player profiles',
            'TERMS_REVIEW',
            70,
            'CANDIDATE',
            'Ověřit národní federace a ligové weby. Vhodné pro ruční nebo poloautomatický harvest.',
            p_created_by
        ),
        (
            p_discovery_action_id,
            'VB',
            'players',
            'Manual verified source',
            'MANUAL / SEMI-AUTO',
            'players by team / league',
            'MANUAL_REVIEW',
            55,
            'CANDIDATE',
            'Záložní varianta pro oficiální soutěže bez API.',
            p_created_by
        );

        GET DIAGNOSTICS v_created = ROW_COUNT;
    END IF;

    IF v_created = 0 THEN
        INSERT INTO ops.operator_provider_discovery_candidates (
            discovery_action_id,
            sport_code,
            entity_type,
            candidate_provider,
            provider_type,
            expected_coverage,
            access_status,
            priority_score,
            research_status,
            recommendation_note,
            created_by
        )
        VALUES (
            p_discovery_action_id,
            v_action.sport_code,
            v_action.entity_type,
            'UNKNOWN',
            'RESEARCH_REQUIRED',
            'unknown',
            'RESEARCH_REQUIRED',
            50,
            'CANDIDATE',
            'Pro tento sport zatím nemáme připravený discovery template. Nutný ruční research.',
            p_created_by
        );

        GET DIAGNOSTICS v_created = ROW_COUNT;
    END IF;

    UPDATE ops.operator_provider_discovery_actions a
    SET
        action_status = 'IN_PROGRESS'
    WHERE a.discovery_action_id = p_discovery_action_id;

    RETURN QUERY
    SELECT
        true,
        p_discovery_action_id,
        v_action.sport_code::text,
        v_action.entity_type::text,
        v_created,
        'Provider discovery kandidáti byli vytvořeni.'::text;
END;
$$;

DROP VIEW IF EXISTS ops.v_operator_provider_discovery_candidates_v1;

CREATE VIEW ops.v_operator_provider_discovery_candidates_v1
AS
SELECT
    c.candidate_id,
    c.discovery_action_id,
    a.command_id,
    c.sport_code,
    a.sport_name,
    c.entity_type,
    a.current_provider,
    c.candidate_provider,
    c.provider_type,
    c.expected_coverage,
    c.access_status,
    c.priority_score,
    c.research_status,
    c.recommendation_note,
    c.created_at,
    c.created_by
FROM ops.operator_provider_discovery_candidates c
LEFT JOIN ops.operator_provider_discovery_actions a
    ON a.discovery_action_id = c.discovery_action_id
ORDER BY
    c.priority_score DESC NULLS LAST,
    c.candidate_id ASC;