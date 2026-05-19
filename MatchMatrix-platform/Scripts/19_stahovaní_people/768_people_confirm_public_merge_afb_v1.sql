BEGIN;

UPDATE ops.provider_people_audit
SET
    technical_status = 'PUBLIC_MERGED',
    final_verdict = 'PUBLIC_CONFIRMED',
    data_quality_status = 'BASIC_OK',
    alternative_provider_needed = false,
    evidence_note = 'AFB players PEOPLE pipeline confirmed: RAW 746 -> staging.stg_provider_players=86 -> public.players/player_provider_map=86.',
    next_step = 'AFB players basic people pipeline hotová. Další krok: zobecnit RAW pull/parser/merge pro potvrzené people větve.',
    updated_at = now()
WHERE provider = 'api_american_football'
  AND sport_code = 'AFB'
  AND entity = 'players';

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    technical_status,
    final_verdict,
    evidence_note,
    next_step
FROM ops.provider_people_audit
WHERE provider = 'api_american_football'
  AND sport_code = 'AFB'
  AND entity = 'players';