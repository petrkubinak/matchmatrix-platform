/*
MATCHMATRIX SQL 106_E
Create provider routing master view V1

CO TO JE:
- Jednotný master view pro provider routing napříč sporty a entitami.
- Bere existující DB realitu z OPS vrstvy.
- Nevytváří novou tabulku, pouze sjednocuje už existující informace.

K ČEMU TO JE:
- Aby panel V16 nemusel číst 5 různých tabulek/views.
- Aby automat, scheduler a panel měly jeden společný zdroj pravdy.
- Aby bylo jasné:
  primary provider,
  fallback provider,
  runtime stav,
  blocked stav,
  automation ready,
  next action.

NA CO TO BUDE:
- Provider routing
- Failover rozhodování
- V16 panel status cards
- Scheduler / future autopilot
- Audit sport + entity připravenosti

KDE TO POUŽIJEME:
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V16.py
- budoucí scheduler
- budoucí automation runner
- DBeaver audit výstupy
*/

CREATE OR REPLACE VIEW ops.v_provider_routing_master AS
WITH base AS (
    SELECT
        pes.provider,
        pes.sport_code,
        pes.entity,
        pes.coverage_status,
        pes.quality_rating,
        pes.availability_scope,
        pes.free_plan_supported,
        pes.paid_plan_supported,
        pes.expected_depth,
        pes.is_primary_source,
        pes.is_fallback_source,
        pes.is_merge_source,
        pes.is_enabled,
        pes.provider_priority,
        pes.fetch_priority,
        pes.merge_priority,
        pes.total_targets,
        pes.enabled_targets,
        pes.pending_cnt,
        pes.running_cnt,
        pes.done_cnt,
        pes.error_cnt,
        pes.skipped_cnt,
        pes.runtime_status,
        pes.is_ready,
        pes.last_attempt,
        pes.next_run,
        pes.notes,
        pes.limitations,
        pes.next_action
    FROM ops.v_provider_entity_status pes
),
ranked AS (
    SELECT
        b.*,
        ROW_NUMBER() OVER (
            PARTITION BY b.sport_code, b.entity
            ORDER BY
                CASE WHEN b.is_primary_source THEN 1 ELSE 2 END,
                CASE
                    WHEN b.coverage_status IN ('runtime_tested', 'CONFIRMED', 'confirmed') THEN 1
                    WHEN b.coverage_status IN ('tech_ready', 'RUNNABLE', 'runnable') THEN 2
                    WHEN b.coverage_status IN ('planned', 'PLANNED') THEN 3
                    WHEN b.coverage_status IN ('blocked', 'BLOCKED') THEN 9
                    ELSE 5
                END,
                b.provider_priority ASC NULLS LAST,
                b.fetch_priority ASC NULLS LAST,
                b.merge_priority ASC NULLS LAST
        ) AS provider_rank
    FROM base b
),
primary_choice AS (
    SELECT
        sport_code,
        entity,
        provider AS primary_provider,
        coverage_status AS primary_status,
        runtime_status AS primary_runtime_status,
        is_ready AS primary_is_ready,
        limitations AS primary_limitations,
        next_action AS primary_next_action
    FROM ranked
    WHERE provider_rank = 1
),
fallback_choice AS (
    SELECT DISTINCT ON (sport_code, entity)
        sport_code,
        entity,
        provider AS fallback_provider,
        coverage_status AS fallback_status,
        runtime_status AS fallback_runtime_status,
        is_ready AS fallback_is_ready,
        limitations AS fallback_limitations,
        next_action AS fallback_next_action
    FROM ranked
    WHERE is_fallback_source = true
       OR provider_rank > 1
    ORDER BY
        sport_code,
        entity,
        CASE WHEN is_fallback_source THEN 1 ELSE 2 END,
        provider_rank
),
blocked AS (
    SELECT
        sport_code,
        entity,
        STRING_AGG(
            provider || ' [' || COALESCE(coverage_status, 'unknown') || ']',
            ', '
            ORDER BY provider
        ) AS blocked_providers
    FROM base
    WHERE LOWER(COALESCE(coverage_status, '')) LIKE '%block%'
       OR LOWER(COALESCE(runtime_status, '')) LIKE '%block%'
       OR LOWER(COALESCE(limitations, '')) LIKE '%block%'
       OR LOWER(COALESCE(notes, '')) LIKE '%block%'
    GROUP BY sport_code, entity
),
pairs AS (
    SELECT DISTINCT
        sport_code,
        entity
    FROM base
)
SELECT
    p.sport_code,
    p.entity,

    pc.primary_provider,
    pc.primary_status,
    pc.primary_runtime_status,
    pc.primary_is_ready,

    fc.fallback_provider,
    fc.fallback_status,
    fc.fallback_runtime_status,
    fc.fallback_is_ready,

    COALESCE(bl.blocked_providers, '-') AS blocked_providers,

    CASE
        WHEN pc.primary_provider IS NULL THEN 'PRIMARY_MISSING'
        WHEN LOWER(COALESCE(pc.primary_status, '')) LIKE '%block%' THEN 'PRIMARY_BLOCKED'
        WHEN pc.primary_is_ready = true AND fc.fallback_provider IS NOT NULL THEN 'READY_WITH_FALLBACK'
        WHEN pc.primary_is_ready = true THEN 'READY_NO_FALLBACK'
        WHEN fc.fallback_provider IS NOT NULL THEN 'PRIMARY_NOT_READY_WITH_FALLBACK'
        ELSE 'NOT_READY'
    END AS routing_status,

    CASE
        WHEN pc.primary_is_ready = true
          AND (
                fc.fallback_provider IS NOT NULL
                OR pc.primary_status IN ('runtime_tested', 'CONFIRMED', 'confirmed')
              )
        THEN true
        ELSE false
    END AS automation_ready,

    CASE
        WHEN pc.primary_provider IS NULL
            THEN 'Doplnit primary providera pro sport/entity.'
        WHEN LOWER(COALESCE(pc.primary_status, '')) LIKE '%block%'
            THEN 'Primary provider je blokovaný; použít fallback nebo najít nového providera.'
        WHEN pc.primary_is_ready = true AND fc.fallback_provider IS NULL
            THEN 'Doplnit fallback providera pro bezpečný routing.'
        WHEN pc.primary_is_ready = false AND fc.fallback_provider IS NOT NULL
            THEN 'Ověřit fallback runtime a případně ho povýšit.'
        ELSE COALESCE(pc.primary_next_action, fc.fallback_next_action, 'Bez další akce.')
    END AS routing_next_action

FROM pairs p
LEFT JOIN primary_choice pc
       ON pc.sport_code = p.sport_code
      AND pc.entity = p.entity
LEFT JOIN fallback_choice fc
       ON fc.sport_code = p.sport_code
      AND fc.entity = p.entity
      AND fc.fallback_provider IS DISTINCT FROM pc.primary_provider
LEFT JOIN blocked bl
       ON bl.sport_code = p.sport_code
      AND bl.entity = p.entity
ORDER BY
    p.sport_code,
    p.entity;