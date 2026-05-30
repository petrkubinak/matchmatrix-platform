/*
MATCHMATRIX SQL 106_D
Audit provider routing candidates V1

Co dělá:
- ukáže pro každý sport + entity primárního providera
- ukáže fallback providera
- označí blocked endpoint
- označí provider gap
- navrhne next_action

Kam výsledek vede:
- pouze SELECT audit pro DBeaver
- nic nemění v DB

K čemu bude sloužit:
- základ pro V16 panel
- základ pro budoucí automatický provider routing

Web / aplikace:
- později z toho vzniknou status cards:
  SPORT + ENTITY → primary / fallback / blocked / gap / next action
*/

WITH base AS (
    SELECT
        pec.sport_code,
        pec.entity,
        pec.provider,
        pec.coverage_status,
        pec.is_enabled,
        COALESCE(pec.is_primary_source, pec.is_primary, false) AS is_primary_provider,
        pec.is_fallback_source AS is_fallback_provider,
        pec.provider_priority,
        pec.fetch_priority,
        pec.merge_priority,
        pec.quality_rating,
        pec.availability_scope,
        pec.free_plan_supported,
        pec.paid_plan_supported,
        pec.expected_depth,
        pec.source_endpoint,
        pec.target_table,
        pec.worker_script,
        pec.limitations,
        pec.next_action,
        pec.notes,
        pec.updated_at
    FROM ops.provider_entity_coverage pec
),
primary_provider AS (
    SELECT DISTINCT ON (sport_code, entity)
        sport_code,
        entity,
        provider AS primary_provider,
        coverage_status AS primary_status,
        source_endpoint AS primary_endpoint,
        target_table AS primary_target_table,
        worker_script AS primary_worker_script,
        next_action AS primary_next_action
    FROM base
    WHERE is_enabled = true
      AND (
            is_primary_provider = true
            OR coverage_status IN ('CONFIRMED', 'RUNNABLE', 'READY', 'PARTIAL')
          )
    ORDER BY
        sport_code,
        entity,
        is_primary_provider DESC,
        CASE coverage_status
            WHEN 'CONFIRMED' THEN 1
            WHEN 'RUNNABLE' THEN 2
            WHEN 'READY' THEN 3
            WHEN 'PARTIAL' THEN 4
            ELSE 9
        END,
        provider_priority ASC NULLS LAST,
        fetch_priority ASC NULLS LAST,
        merge_priority ASC NULLS LAST,
        updated_at DESC
),
fallback_provider AS (
    SELECT DISTINCT ON (sport_code, entity)
        sport_code,
        entity,
        provider AS fallback_provider,
        coverage_status AS fallback_status,
        source_endpoint AS fallback_endpoint,
        target_table AS fallback_target_table,
        worker_script AS fallback_worker_script,
        next_action AS fallback_next_action
    FROM base
    WHERE is_enabled = true
      AND (
            is_fallback_provider = true
            OR coverage_status IN ('PLANNED', 'PARTIAL', 'RUNNABLE')
          )
    ORDER BY
        sport_code,
        entity,
        is_fallback_provider DESC,
        CASE coverage_status
            WHEN 'RUNNABLE' THEN 1
            WHEN 'PARTIAL' THEN 2
            WHEN 'PLANNED' THEN 3
            ELSE 9
        END,
        provider_priority ASC NULLS LAST,
        fetch_priority ASC NULLS LAST,
        updated_at DESC
),
blocked AS (
    SELECT
        sport_code,
        entity,
        string_agg(provider || ' [' || coverage_status || ']', ', ' ORDER BY provider) AS blocked_endpoint
    FROM base
    WHERE coverage_status ILIKE '%BLOCK%'
       OR limitations ILIKE '%block%'
       OR limitations ILIKE '%endpoint%'
       OR notes ILIKE '%blocked%'
    GROUP BY sport_code, entity
),
all_pairs AS (
    SELECT DISTINCT sport_code, entity
    FROM base
)
SELECT
    ap.sport_code,
    ap.entity,

    pp.primary_provider,
    pp.primary_status,
    pp.primary_endpoint,
    pp.primary_target_table,
    pp.primary_worker_script,

    fp.fallback_provider,
    fp.fallback_status,
    fp.fallback_endpoint,
    fp.fallback_target_table,
    fp.fallback_worker_script,

    COALESCE(b.blocked_endpoint, '-') AS blocked_endpoint,

    CASE
        WHEN pp.primary_provider IS NULL
             AND fp.fallback_provider IS NULL
            THEN 'NO_PROVIDER_FOUND'

        WHEN pp.primary_provider IS NULL
             AND fp.fallback_provider IS NOT NULL
            THEN 'PRIMARY_PROVIDER_MISSING'

        WHEN pp.primary_status IN ('BLOCKED', 'ERROR', 'EMPTY_OR_BAD_SCOPE')
            THEN 'PRIMARY_BLOCKED'

        WHEN pp.primary_status IN ('PLANNED', 'PARTIAL')
            THEN 'PRIMARY_NOT_FULLY_CONFIRMED'

        WHEN fp.fallback_provider IS NULL
            THEN 'NO_FALLBACK_PROVIDER'

        ELSE 'OK'
    END AS provider_gap,

    CASE
        WHEN pp.primary_provider IS NULL
             AND fp.fallback_provider IS NULL
            THEN 'Najít nebo doplnit providera pro tuto sport/entity kombinaci.'

        WHEN pp.primary_provider IS NULL
             AND fp.fallback_provider IS NOT NULL
            THEN 'Povýšit fallback providera na primary nebo doplnit nového primary providera.'

        WHEN pp.primary_status IN ('BLOCKED', 'ERROR', 'EMPTY_OR_BAD_SCOPE')
            THEN 'Nepoužívat primary; ověřit fallback nebo najít alternativního providera.'

        WHEN pp.primary_status IN ('PLANNED', 'PARTIAL')
            THEN COALESCE(pp.primary_next_action, fp.fallback_next_action, 'Dokončit runtime test a potvrdit provider flow.')

        WHEN fp.fallback_provider IS NULL
            THEN 'Doplnit fallback providera pro bezpečný provider routing.'

        ELSE COALESCE(pp.primary_next_action, 'Routing je použitelný; připravit napojení do V16 panelu.')
    END AS next_action

FROM all_pairs ap
LEFT JOIN primary_provider pp
       ON pp.sport_code = ap.sport_code
      AND pp.entity = ap.entity
LEFT JOIN fallback_provider fp
       ON fp.sport_code = ap.sport_code
      AND fp.entity = ap.entity
      AND fp.fallback_provider IS DISTINCT FROM pp.primary_provider
LEFT JOIN blocked b
       ON b.sport_code = ap.sport_code
      AND b.entity = ap.entity
ORDER BY
    ap.sport_code,
    ap.entity;