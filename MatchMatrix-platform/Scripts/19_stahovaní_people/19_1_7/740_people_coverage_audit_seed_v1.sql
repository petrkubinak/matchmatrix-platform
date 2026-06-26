/*
740_people_coverage_audit_seed_v1.sql

Účel:
- připraví PEOPLE coverage audit pro players + coaches
- neprovádí žádné stahování dat
- pouze nastaví OPS mapu: kde ověřit API-Sport/API-* a kde případně hledat jiného providera
*/

BEGIN;

WITH sport_provider AS (
    SELECT *
    FROM (VALUES
        ('api_football', 'FB',  10),
        ('api_hockey', 'HK',  20),
        ('api_sport', 'BK',  30),
        ('api_volleyball', 'VB',  40),
        ('api_handball', 'HB',  50),
        ('api_american_football', 'AFB', 60),
        ('api_baseball', 'BSB', 70),
        ('api_cricket', 'CK',  80),
        ('api_rugby', 'RGB', 90),
        ('api_tennis', 'TN', 100),
        ('api_mma', 'MMA', 110)
    ) AS x(provider, sport_code, base_priority)
),
people_entities AS (
    SELECT *
    FROM (VALUES
        ('players', 'players', 1),
        ('coaches', 'coaches', 2)
    ) AS x(entity, endpoint_name, entity_order)
),
seed_rows AS (
    SELECT
        sp.provider,
        sp.sport_code,
        pe.entity,
        pe.endpoint_name,
        sp.base_priority + pe.entity_order AS priority_rank
    FROM sport_provider sp
    CROSS JOIN people_entities pe
)

INSERT INTO ops.provider_people_audit (
    provider,
    sport_code,
    entity,
    provider_role,
    source_category,
    endpoint_name,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    usable_for_league,
    usable_for_team,
    usable_for_season,
    technical_status,
    data_quality_status,
    final_verdict,
    requires_pro,
    alternative_provider_needed,
    evidence_note,
    next_step,
    priority_rank,
    updated_at
)
SELECT
    provider,
    sport_code,
    entity,
    'primary_candidate',
    'people_layer',
    endpoint_name,
    false,
    false,
    false,
    false,
    false,
    false,
    'NOT_TESTED',
    'UNKNOWN',
    'WAIT_ENDPOINT_AUDIT',
    false,
    false,
    'Seed pro people coverage audit. Nejde o potvrzení funkčnosti endpointu.',
    'Ověřit endpoint u providera. Pokud endpoint neexistuje nebo nevrací použitelná data, označit alternative_provider_needed=true.',
    priority_rank,
    now()
FROM seed_rows
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    provider_role = EXCLUDED.provider_role,
    source_category = EXCLUDED.source_category,
    endpoint_name = EXCLUDED.endpoint_name,
    technical_status = EXCLUDED.technical_status,
    data_quality_status = EXCLUDED.data_quality_status,
    final_verdict = EXCLUDED.final_verdict,
    evidence_note = EXCLUDED.evidence_note,
    next_step = EXCLUDED.next_step,
    priority_rank = EXCLUDED.priority_rank,
    updated_at = now();

COMMIT;

SELECT *
FROM ops.provider_people_audit
ORDER BY priority_rank, provider, sport_code, entity;