/*
===============================================================================
MATCHMATRIX 20_1_P6_A – PROVIDER VALIDATION ENGINE V1
===============================================================================

CO TO JE:
Validační engine pro kandidáty providerů nalezené přes Provider Discovery Engine.

K ČEMU TO JE:
Po nalezení kandidáta typu Volleybox / RapidAPI / Wikidata systém vyhodnotí,
jestli je kandidát vhodný pro daný sport a entitu.

KDE TO UVIDÍME:
OPS PANEL
→ PROVIDER DISCOVERY
→ kandidáti providerů
→ OVĚŘIT PROVIDERA

JAK SE TO VYUŽIJE:
Operátor vybere kandidáta a spustí validaci.
Systém zapíše:
- co provider pravděpodobně umí,
- co je nutné ověřit,
- skóre,
- status VALID / PARTIAL / REJECTED / LICENSE_REVIEW.

NAVAZUJE NA:
20_1_P3_provider_discovery_action.sql
20_1_P5_provider_discovery_engine_v1.sql

DALŠÍ KROK:
20_1_P6_B_provider_validation_panel_binding.py

SOUBOR:
20_1_P6_A_provider_validation_engine.sql

KAM ULOŽIT:
C:\MatchMatrix-platform\db\ops\20_1\

JAK SPUSTIT:
DBeaver → spustit celý SQL skript.

CO OČEKÁVAT:
Pro kandidáta Volleybox vznikne validační záznam se skóre a statusem.
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.operator_provider_validation (
    validation_id bigserial PRIMARY KEY,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    candidate_id bigint NOT NULL,
    discovery_action_id bigint,
    sport_code text,
    entity_type text,
    candidate_provider text,
    provider_type text,

    documentation_found boolean,
    api_found boolean,
    players_supported boolean,
    teams_supported boolean,
    profiles_supported boolean,
    photos_supported boolean,
    historical_data_supported boolean,

    access_status text,
    license_status text,
    validation_score numeric(10,2),
    validation_status text,
    validation_note text,

    created_by text NOT NULL DEFAULT 'MATCHMATRIX_VALIDATION_ENGINE'
);

CREATE OR REPLACE FUNCTION ops.fn_operator_validate_provider_candidate_v1(
    p_candidate_id bigint,
    p_created_by text DEFAULT 'PANEL_OPERATOR'
)
RETURNS TABLE (
    success boolean,
    candidate_id bigint,
    candidate_provider text,
    sport_code text,
    entity_type text,
    validation_score numeric,
    validation_status text,
    message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_candidate record;
    v_score numeric(10,2) := 0;
    v_status text := 'PARTIAL';
    v_note text := '';
    v_documentation_found boolean := false;
    v_api_found boolean := false;
    v_players_supported boolean := false;
    v_teams_supported boolean := false;
    v_profiles_supported boolean := false;
    v_photos_supported boolean := false;
    v_historical_data_supported boolean := false;
    v_license_status text := 'REVIEW_REQUIRED';
BEGIN
    SELECT *
    INTO v_candidate
    FROM ops.v_operator_provider_discovery_candidates_v1 c
    WHERE c.candidate_id = p_candidate_id
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            false,
            p_candidate_id,
            NULL::text,
            NULL::text,
            NULL::text,
            0::numeric,
            'NOT_FOUND'::text,
            'Kandidát providera nebyl nalezen.'::text;
        RETURN;
    END IF;

    -- Template validace pro VB players kandidáty.
    IF v_candidate.sport_code = 'VB'
       AND v_candidate.entity_type = 'players'
       AND LOWER(v_candidate.candidate_provider) LIKE '%volleybox%'
    THEN
        v_documentation_found := true;
        v_api_found := false;
        v_players_supported := true;
        v_teams_supported := true;
        v_profiles_supported := true;
        v_photos_supported := true;
        v_historical_data_supported := false;
        v_license_status := 'TERMS_REVIEW';
        v_score := 90;
        v_status := 'VALID_RESEARCH';
        v_note := 'Volleybox je silný kandidát pro volleyball people vrstvu. Nutné ověřit podmínky použití a způsob získání dat.';

    ELSIF v_candidate.sport_code = 'VB'
       AND v_candidate.entity_type = 'players'
       AND LOWER(v_candidate.candidate_provider) LIKE '%rapidapi%'
    THEN
        v_documentation_found := true;
        v_api_found := true;
        v_players_supported := true;
        v_teams_supported := true;
        v_profiles_supported := false;
        v_photos_supported := false;
        v_historical_data_supported := false;
        v_license_status := 'PLAN_REVIEW';
        v_score := 78;
        v_status := 'PARTIAL';
        v_note := 'RapidAPI alternativy mohou mít API endpointy, ale je nutné ověřit konkrétní provider, cenu, limity a players/rosters coverage.';

    ELSIF LOWER(v_candidate.candidate_provider) LIKE '%wikidata%'
       OR LOWER(v_candidate.candidate_provider) LIKE '%wikimedia%'
    THEN
        v_documentation_found := true;
        v_api_found := true;
        v_players_supported := true;
        v_teams_supported := false;
        v_profiles_supported := true;
        v_photos_supported := true;
        v_historical_data_supported := false;
        v_license_status := 'LICENSE_REVIEW';
        v_score := 68;
        v_status := 'PARTIAL';
        v_note := 'Wikidata/Wikimedia je vhodná pro profily, identifikátory a fotografie, ne jako hlavní roster provider.';

    ELSIF LOWER(v_candidate.candidate_provider) LIKE '%official%'
       OR LOWER(v_candidate.provider_type) LIKE '%official%'
    THEN
        v_documentation_found := true;
        v_api_found := false;
        v_players_supported := true;
        v_teams_supported := true;
        v_profiles_supported := true;
        v_photos_supported := false;
        v_historical_data_supported := false;
        v_license_status := 'TERMS_REVIEW';
        v_score := 70;
        v_status := 'PARTIAL';
        v_note := 'Oficiální federace nebo ligové weby jsou vhodné pro ověřené soupisky, ale mohou vyžadovat individuální parser.';

    ELSE
        v_documentation_found := false;
        v_api_found := false;
        v_players_supported := false;
        v_teams_supported := false;
        v_profiles_supported := false;
        v_photos_supported := false;
        v_historical_data_supported := false;
        v_license_status := 'RESEARCH_REQUIRED';
        v_score := 45;
        v_status := 'RESEARCH_REQUIRED';
        v_note := 'Kandidát vyžaduje ruční research.';
    END IF;

    DELETE FROM ops.operator_provider_validation v
    WHERE v.candidate_id = p_candidate_id;

    INSERT INTO ops.operator_provider_validation (
        candidate_id,
        discovery_action_id,
        sport_code,
        entity_type,
        candidate_provider,
        provider_type,
        documentation_found,
        api_found,
        players_supported,
        teams_supported,
        profiles_supported,
        photos_supported,
        historical_data_supported,
        access_status,
        license_status,
        validation_score,
        validation_status,
        validation_note,
        created_by
    )
    VALUES (
        p_candidate_id,
        v_candidate.discovery_action_id,
        v_candidate.sport_code,
        v_candidate.entity_type,
        v_candidate.candidate_provider,
        v_candidate.provider_type,
        v_documentation_found,
        v_api_found,
        v_players_supported,
        v_teams_supported,
        v_profiles_supported,
        v_photos_supported,
        v_historical_data_supported,
        v_candidate.access_status,
        v_license_status,
        v_score,
        v_status,
        v_note,
        p_created_by
    );

    RETURN QUERY
    SELECT
        true,
        p_candidate_id,
        v_candidate.candidate_provider::text,
        v_candidate.sport_code::text,
        v_candidate.entity_type::text,
        v_score::numeric,
        v_status::text,
        'Validace kandidáta byla vytvořena.'::text;
END;
$$;

DROP VIEW IF EXISTS ops.v_operator_provider_validation_v1;

CREATE VIEW ops.v_operator_provider_validation_v1
AS
SELECT
    v.validation_id,
    v.candidate_id,
    v.discovery_action_id,
    v.sport_code,
    v.entity_type,
    v.candidate_provider,
    v.provider_type,
    v.documentation_found,
    v.api_found,
    v.players_supported,
    v.teams_supported,
    v.profiles_supported,
    v.photos_supported,
    v.historical_data_supported,
    v.access_status,
    v.license_status,
    v.validation_score,
    v.validation_status,
    v.validation_note,
    v.created_at,
    v.updated_at,
    v.created_by
FROM ops.operator_provider_validation v
ORDER BY
    v.validation_score DESC NULLS LAST,
    v.validation_id DESC;