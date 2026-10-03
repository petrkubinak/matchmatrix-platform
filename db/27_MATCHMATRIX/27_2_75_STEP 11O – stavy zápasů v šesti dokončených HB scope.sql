-- CO: STEP 11O – stavy zápasů v šesti dokončených HB scope
-- K ČEMU: Zjistit, zda dokončené scope obsahují i neuzavřené zápasy.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

WITH complete_scopes AS (
    SELECT canonical_league_id, source_season_key
    FROM ops.harvest_scope_completion
    WHERE source_id = 18
      AND sport_code = 'HB'
      AND layer_type = 'CORE'
      AND entity = 'fixtures'
      AND time_mode = 'HISTORY_FAN'
      AND completion_status = 'COMPLETE'
),
provider_match_ids AS (
    SELECT DISTINCT match_id
    FROM public.match_provider_map
    WHERE provider = 'api_handball'
)
SELECT
    c.canonical_league_id,
    l.name AS league_name,
    m.status,
    count(*) AS matches,
    count(*) FILTER (
        WHERE m.home_score IS NULL OR m.away_score IS NULL
    ) AS matches_without_full_score,
    min(m.kickoff) AS first_kickoff,
    max(m.kickoff) AS last_kickoff,
    max(m.updated_at) AS latest_match_update
FROM complete_scopes c
JOIN public.matches m
    ON m.league_id = c.canonical_league_id
   AND m.season = c.source_season_key
JOIN provider_match_ids pm
    ON pm.match_id = m.id
LEFT JOIN public.leagues l
    ON l.id = c.canonical_league_id
GROUP BY c.canonical_league_id, l.name, m.status
ORDER BY c.canonical_league_id, m.status;