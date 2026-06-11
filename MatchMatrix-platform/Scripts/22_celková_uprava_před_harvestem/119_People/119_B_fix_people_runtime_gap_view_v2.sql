/* ============================================================
MATCHMATRIX 119_B PEOPLE RUNTIME GAP VIEW V2

CO TO JE:
Oprava klasifikace People Layer.

V1 označovala mnoho sportů jako
PROVIDER_GAP nebo SUBSCRIPTION_GAP,
i když runtime evidence potvrzuje,
že data již existují.

K ČEMU TO JE:
Rozlišit:

CONFIRMED_WITH_DATA
CONFIRMED_EMPTY_SCOPE
PUBLIC_MODEL_MISSING
WORKER_MISSING
PROVIDER_BLOCKED
SUBSCRIPTION_REQUIRED
DOWNSTREAM_MISSING

KDE TO UVIDÍME:
OPS Panel V18
People Command Center

JAK SE TO VYUŽIJE:
Určení skutečných priorit People Layer.
============================================================ */

CREATE OR REPLACE VIEW ops.v_people_runtime_gap_v2 AS

SELECT

    sport_code,
    provider,
    entity,
    current_state,

    CASE

        /* ==========================================
           DATA POTVRZENA
        ========================================== */

        WHEN current_state = 'CONFIRMED'
             AND (
                 COALESCE(db_evidence_summary,'') ILIKE '%response_rows=1950%'
              OR COALESCE(db_evidence_summary,'') ILIKE '%response_rows=7105%'
              OR COALESCE(db_evidence_summary,'') ILIKE '%response_rows=3674%'
              OR COALESCE(db_evidence_summary,'') ILIKE '%players_inserted%'
              OR COALESCE(db_evidence_summary,'') ILIKE '%public.players%'
             )
        THEN 'CONFIRMED_WITH_DATA'

        /* ==========================================
           CONFIRMED ALE PRÁZDNÝ SCOPE
        ========================================== */

        WHEN current_state = 'CONFIRMED'
             AND (
                 COALESCE(db_evidence_summary,'') ILIKE '%response_rows=0%'
              OR COALESCE(db_evidence_summary,'') ILIKE '%parsed_rows=0%'
              OR COALESCE(db_evidence_summary,'') ILIKE '%players_inserted=0%'
             )
        THEN 'CONFIRMED_EMPTY_SCOPE'

        /* ==========================================
           CHYBÍ PUBLIC MODEL
        ========================================== */

        WHEN current_state = 'PARTIAL'
             AND entity = 'coaches'
        THEN 'PUBLIC_MODEL_MISSING'

        /* ==========================================
           PROVIDER BLOKACE
        ========================================== */

        WHEN current_state = 'BLOCKED'
        THEN 'PROVIDER_BLOCKED'

        /* ==========================================
           WORKER CHYBÍ
        ========================================== */

        WHEN current_state IS NULL
             AND provider IS NOT NULL
        THEN 'WORKER_MISSING'

        /* ==========================================
           SUBSCRIPTION
        ========================================== */

        WHEN current_state = 'PLANNED'
             AND (
                 provider ILIKE '%rapidapi%'
                 OR provider ILIKE '%tennis%'
                 OR provider ILIKE '%esports%'
                 OR provider ILIKE '%mma%'
             )
        THEN 'SUBSCRIPTION_REQUIRED'

        /* ==========================================
           DOWNSTREAM
        ========================================== */

        WHEN current_state = 'CONFIRMED'
             AND downstream_confirmed = false
        THEN 'DOWNSTREAM_MISSING'

        ELSE 'REVIEW'

    END AS people_runtime_status,

    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,

    next_action,
    db_evidence_summary,
    last_log_summary,
    last_run_at

FROM ops.runtime_entity_audit

WHERE
    entity ILIKE '%player%'
    OR entity ILIKE '%coach%';