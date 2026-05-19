-- ============================================================
-- 884_normalize_pending_team_squad_to_players_queue_v1.sql
-- MatchMatrix - normalize squads queue for existing players worker
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\audit\884_normalize_pending_team_squad_to_players_queue_v1.sql
--
-- Spustit v DBeaveru.
--
-- Účel:
-- - existující worker run_players_fetch_only_v1.py hledá api_football / football / players
-- - naše pending fronta je api_football_squads / football / team_squad
-- - proto pending řádky přepíšeme do kompatibilní fronty
-- ============================================================

BEGIN;

UPDATE ops.player_enrichment_plan
SET
    provider = 'api_football',
    entity = 'players',
    run_group = 'FB_PEOPLE',
    updated_at = NOW(),
    last_error = NULL
WHERE provider = 'api_football_squads'
  AND sport_code = 'football'
  AND entity = 'team_squad'
  AND status = 'pending';

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    run_group,
    status,
    COUNT(*) AS rows_count
FROM ops.player_enrichment_plan
GROUP BY
    provider,
    sport_code,
    entity,
    run_group,
    status
ORDER BY
    provider,
    sport_code,
    entity,
    run_group,
    status;