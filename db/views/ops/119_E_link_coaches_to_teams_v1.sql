/* ============================================================
MATCHMATRIX 119_E LINK COACHES TO TEAMS V1

CO TO JE:
- Napojení trenérů z public.coaches na týmy přes public.team_coaches.
- Používá metadata uložená v public.coaches:
      metadata->>'team_external_id'
      metadata->>'team_name'
- Tým dohledává přes public.team_provider_map.

K ČEMU TO JE:
- Aby trenér nebyl jen samostatná osoba v People Layer.
- Aby měl vazbu na tým.
- Aby šlo zobrazit trenéra na profilu týmu.

KDE TO UVIDÍME:
- public.team_coaches
- OPS Panel V18 → PEOPLE → Coaches
- Web → profil týmu
- Web → profil trenéra

JAK SE TO VYUŽIJE:
- Team Intelligence
- Match Context Engine
- Ticket Engine
- Media Layer
- Budoucí historie trenérů podle klubů

POZNÁMKA:
- public.coaches už má ext_source/ext_coach_id.
- public.team_coaches řeší vazbu coach_id → team_id.
- Vazba je zatím CURRENT, protože staging data nemají přesné datum začátku/konce.
============================================================ */

BEGIN;

INSERT INTO public.team_coaches (
    team_id,
    coach_id,
    role_code,
    start_date,
    end_date,
    is_current,
    valid_from,
    valid_to,
    source_provider,
    source_payload_hash,
    confidence,
    notes,
    created_at,
    updated_at
)
SELECT
    tpm.team_id,
    c.id AS coach_id,
    'HEAD_COACH' AS role_code,
    NULL::date AS start_date,
    NULL::date AS end_date,
    true AS is_current,
    NULL::date AS valid_from,
    NULL::date AS valid_to,
    c.ext_source AS source_provider,
    c.source_payload_hash,
    0.80 AS confidence,
    'Auto-linked from public.coaches.metadata team_external_id. Date range unknown.' AS notes,
    now(),
    now()
FROM public.coaches c
JOIN public.team_provider_map tpm
    ON tpm.provider = c.ext_source
   AND tpm.provider_team_id = c.metadata->>'team_external_id'
WHERE c.ext_source IS NOT NULL
  AND c.ext_coach_id IS NOT NULL
  AND c.metadata ? 'team_external_id'
  AND c.metadata->>'team_external_id' IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_coaches tc
      WHERE tc.team_id = tpm.team_id
        AND tc.coach_id = c.id
        AND tc.source_provider = c.ext_source
  );

UPDATE ops.runtime_entity_audit
SET
    downstream_confirmed = true,
    state_reason = 'FB coaches merged to public.coaches and linked to teams through public.team_coaches.',
    db_evidence_summary = 'public.coaches has provider identity and public.team_coaches links coaches to canonical teams through team_provider_map.',
    next_action = 'Rozšířit coaches scope na více týmů a sezón; později doplnit historii start/end date.',
    updated_at = now()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'coaches';

COMMIT;