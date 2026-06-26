/* MATCHMATRIX 119_C FIX PUBLIC COACHES EXISTING MODEL V2 */

BEGIN;

CREATE INDEX IF NOT EXISTS idx_coaches_sport_id
    ON public.coaches(sport_id);

CREATE INDEX IF NOT EXISTS ix_coaches_name
    ON public.coaches(name);

CREATE INDEX IF NOT EXISTS ix_coaches_ext_source_id
    ON public.coaches(ext_source, ext_coach_id)
    WHERE ext_source IS NOT NULL
      AND ext_coach_id IS NOT NULL;

CREATE OR REPLACE VIEW ops.v_public_coaches_model_status_v1 AS
SELECT
    'public.coaches' AS object_name,
    COUNT(*) AS rows_count,
    COUNT(*) FILTER (WHERE sport_id IS NOT NULL) AS with_sport_id,
    COUNT(*) FILTER (WHERE ext_source IS NOT NULL AND ext_coach_id IS NOT NULL) AS with_provider_identity,
    COUNT(*) FILTER (WHERE is_active = true) AS active_rows
FROM public.coaches;

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    public_merge_confirmed = true,
    downstream_confirmed = false,
    state_reason = 'Public coaches model already exists and was validated against current schema.',
    db_evidence_summary = 'public.coaches exists with id, name, birth_date, nationality, sport_id, ext_source, ext_coach_id, photo_url, metadata. Team relation is handled through team_coaches, not coaches.team_id.',
    next_action = 'Napojit staging.stg_provider_coaches do public.coaches a public.team_coaches.',
    updated_at = now()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'coaches';

COMMIT;