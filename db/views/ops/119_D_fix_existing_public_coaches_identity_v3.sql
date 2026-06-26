/* ============================================================
MATCHMATRIX 119_D FIX EXISTING PUBLIC COACHES IDENTITY V3

CO TO JE:
- Doplnění provider identity do již existujících public.coaches.
- Řeší stav, kdy trenéři už existují podle jména,
  ale nemají ext_source, ext_coach_id ani sport_id.

K ČEMU TO JE:
- Aby se coaches dali jednoznačně párovat s API-Football.
- Aby další merge nepřidával duplicity.
- Aby bylo možné navázat team_coaches.

KDE TO UVIDÍME:
- public.coaches
- OPS Panel V18 → PEOPLE → Coaches
- runtime_entity_audit

JAK SE TO VYUŽIJE:
- People Layer
- Team profile
- Coach profile
- Match Context Engine
- Ticket Engine
============================================================ */

BEGIN;

WITH src AS (
    SELECT *
    FROM (
        SELECT
            s.*,
            ROW_NUMBER() OVER (
                PARTITION BY s.provider, s.external_coach_id
                ORDER BY
                    s.updated_at DESC NULLS LAST,
                    s.fetched_at DESC NULLS LAST,
                    s.created_at DESC NULLS LAST,
                    s.id DESC
            ) AS rn
        FROM staging.stg_provider_coaches s
        WHERE s.provider = 'api_football'
          AND s.sport_code = 'FB'
          AND s.external_coach_id IS NOT NULL
    ) x
    WHERE rn = 1
),
matched AS (
    SELECT
        c.id AS coach_id,
        src.*
    FROM src
    JOIN public.coaches c
        ON lower(trim(c.name)) = lower(trim(src.coach_name))
    WHERE c.ext_source IS NULL
      AND c.ext_coach_id IS NULL
)
UPDATE public.coaches c
SET
    sport_id = sp.id,
    ext_source = m.provider,
    ext_coach_id = m.external_coach_id,
    first_name = m.first_name,
    last_name = m.last_name,
    short_name = m.short_name,
    birth_date = m.birth_date,
    birth_place = m.birth_place,
    birth_country = m.birth_country,
    nationality = m.nationality,
    nationality_code = m.nationality_code,
    photo_url = m.photo_url,
    source_payload_hash = m.source_payload_hash,
    metadata = jsonb_build_object(
        'team_external_id', m.team_external_id,
        'team_name', m.team_name,
        'league_external_id', m.league_external_id,
        'league_name', m.league_name,
        'season', m.season,
        'source_endpoint', m.source_endpoint,
        'raw_payload_id', m.raw_payload_id,
        'fetched_at', m.fetched_at
    ),
    is_active = COALESCE(m.is_active, true),
    updated_at = now()
FROM matched m
LEFT JOIN public.sports sp
    ON sp.code = m.sport_code
WHERE c.id = m.coach_id;

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    state_reason = 'Existing public.coaches rows enriched with API-Football provider identity.',
    db_evidence_summary = 'public.coaches existing rows updated by name match from staging.stg_provider_coaches. Provider identity ext_source/ext_coach_id filled.',
    next_action = 'Napojit public.coaches na týmy přes public.team_coaches.',
    updated_at = now()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'coaches';

COMMIT;