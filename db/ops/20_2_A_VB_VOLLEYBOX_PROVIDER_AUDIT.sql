/*
===============================================================================
MATCHMATRIX 20_2_A – VB VOLLEYBOX PROVIDER AUDIT
===============================================================================

CO TO JE:
Audit nového provider kandidáta Volleybox.

K ČEMU TO JE:
Před implementací provideru musíme ověřit:

- licenci
- podmínky použití
- dostupnost hráčů
- dostupnost týmů
- dostupnost profilů
- dostupnost fotografií
- možnost automatizace

KDE TO UVIDÍME:
OPS
Provider Discovery
Provider Validation
Provider Implementation

NAVAZUJE NA:
20_1_P7_accept_provider_action.sql

DALŠÍ KROK:
20_2_B_VB_VOLLEYBOX_RAW_PULL

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.provider_audit_registry (
    audit_id bigserial PRIMARY KEY,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),

    sport_code text,
    entity_type text,

    provider_name text,
    provider_type text,

    implementation_epic text,

    license_review_status text,
    terms_review_status text,

    players_available boolean,
    teams_available boolean,
    profiles_available boolean,
    photos_available boolean,

    api_available boolean,
    scraping_required boolean,

    audit_status text,
    audit_note text
);

INSERT INTO ops.provider_audit_registry (
    sport_code,
    entity_type,
    provider_name,
    provider_type,
    implementation_epic,

    license_review_status,
    terms_review_status,

    players_available,
    teams_available,
    profiles_available,
    photos_available,

    api_available,
    scraping_required,

    audit_status,
    audit_note
)
SELECT
    sport_code,
    entity_type,
    accepted_provider,
    provider_type,
    implementation_epic,

    'PENDING',
    'PENDING',

    NULL,
    NULL,
    NULL,
    NULL,

    NULL,
    NULL,

    'AUDIT_IN_PROGRESS',
    'Provider přijat z Discovery Engine. Čeká na audit.'
FROM ops.operator_provider_implementation_tasks
WHERE implementation_epic = '20_2_VB_VOLLEYBOX_PLAYERS'
AND NOT EXISTS (
    SELECT 1
    FROM ops.provider_audit_registry r
    WHERE r.implementation_epic =
          '20_2_VB_VOLLEYBOX_PLAYERS'
);