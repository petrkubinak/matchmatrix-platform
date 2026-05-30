/*
MATCHMATRIX SQL 109_V Create OPS Translation Bridge V1

CO TO JE:
- Napojení OPS katalogu blokací na existující public.ai_translations.

K ČEMU TO JE:
- Aby panel i web mohly zobrazovat OPS chyby v různých jazycích.
- Abychom nevytvářeli druhý překladový systém.
- Aby interní OPS kódy zůstaly stabilní a zobrazovaný text byl jazykový.

KDE TO UVIDÍME:
- Panel V18
- AI OPS
- BLOKOVANÉ / OPRAVY
- Web podle zvoleného jazyka uživatele

JAK SE TO VYUŽIJE:
- source_entity_type = 'ops_block_reason'
- source_entity_id = ops.block_reason_catalog.id
- target_language_code = cs/en/de/...
*/


INSERT INTO public.ai_translations (
    source_entity_type,
    source_entity_id,
    original_language_code,
    target_language_code,
    translated_title,
    translated_short,
    translated_long,
    translation_status,
    ai_model,
    ai_prompt_version,
    confidence_score,
    generated_at,
    created_at,
    updated_at
)
SELECT
    'ops_block_reason' AS source_entity_type,
    br.id AS source_entity_id,
    'cs' AS original_language_code,
    'cs' AS target_language_code,
    br.reason_name AS translated_title,
    br.description AS translated_short,
    br.recommended_fix AS translated_long,
    'confirmed_manual' AS translation_status,
    'manual_seed' AS ai_model,
    '109_V_ops_bridge_v1' AS ai_prompt_version,
    1.00 AS confidence_score,
    now() AS generated_at,
    now() AS created_at,
    now() AS updated_at
FROM ops.block_reason_catalog br
WHERE NOT EXISTS (
    SELECT 1
    FROM public.ai_translations t
    WHERE t.source_entity_type = 'ops_block_reason'
      AND t.source_entity_id = br.id
      AND t.target_language_code = 'cs'
);


CREATE OR REPLACE VIEW ops.v_ops_block_reason_translations_cs_v1 AS
SELECT
    br.reason_code,
    t.target_language_code AS language_code,
    t.translated_title AS nazev,
    t.translated_short AS popis,
    t.translated_long AS doporucena_oprava,
    t.translation_status,
    t.confidence_score,
    t.generated_at
FROM ops.block_reason_catalog br
LEFT JOIN public.ai_translations t
    ON t.source_entity_type = 'ops_block_reason'
   AND t.source_entity_id = br.id
   AND t.target_language_code = 'cs'
ORDER BY br.reason_code;


CREATE OR REPLACE VIEW ops.v_blocked_items_repair_queue_cs_v1 AS
SELECT
    q.repair_rank,
    q.provider,
    q.sport_code,
    q.entity,
    q.league_id,
    q.season,
    q.run_group,

    q.ai_decision,
    q.ai_risk_level,
    q.repair_priority,

    COALESCE(tr.nazev, q.repair_action) AS problem_cz,
    COALESCE(tr.popis, q.ai_reason) AS popis_cz,
    COALESCE(tr.doporucena_oprava, q.repair_detail) AS doporucena_oprava_cz,

    q.can_execute_now,
    q.generated_at

FROM ops.v_blocked_items_repair_queue_v1 q
LEFT JOIN ops.block_reason_catalog br
    ON (
        CASE
            WHEN q.ai_decision = 'POZASTAVIT' THEN 'PROVIDER_NO_DATA'
            WHEN q.ai_decision = 'POČKAT' THEN 'TIMEOUT'
            ELSE 'UNKNOWN'
        END
    ) = br.reason_code
LEFT JOIN ops.v_ops_block_reason_translations_cs_v1 tr
    ON tr.reason_code = br.reason_code
ORDER BY q.repair_rank;