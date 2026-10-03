-- CO: STEP 11N – časový rozsah šesti dokončených HB scope
-- K ČEMU: Porovnat doložené zápasy sezóny 2024 s canonical season daty.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

WITH complete_scopes AS (
    SELECT
        canonical_league_id,
        source_competition_key,
        source_season_key,
        expected_count,
        source_observed_count,
        merged_count
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
),
observed AS (
    SELECT
        m.league_id,
        m.season,
        count(*) AS provider_matches,
        min(m.kickoff) AS first_kickoff,
        max(m.kickoff) AS last_kickoff
    FROM public.matches m
    JOIN provider_match_ids pm ON pm.match_id = m.id
    WHERE m.season = '2024'
    GROUP BY m.league_id, m.season
),
season_meta AS (
    SELECT
        league_id,
        season_code,
        count(*) AS canonical_season_rows,
        min(season_label) AS season_label,
        min(start_date) AS earliest_start_date,
        max(end_date) AS latest_end_date
    FROM public.seasons
    WHERE season_code = '2024'
    GROUP BY league_id, season_code
)
SELECT
    h.canonical_league_id,
    l.name AS league_name,
    h.source_competition_key,
    h.source_season_key,
    h.expected_count,
    h.source_observed_count,
    h.merged_count,
    coalesce(o.provider_matches, 0) AS provider_matches_in_public,
    o.first_kickoff,
    o.last_kickoff,
    coalesce(s.canonical_season_rows, 0) AS canonical_season_rows,
    s.season_label,
    s.earliest_start_date,
    s.latest_end_date
FROM complete_scopes h
LEFT JOIN public.leagues l
    ON l.id = h.canonical_league_id
LEFT JOIN observed o
    ON o.league_id = h.canonical_league_id
   AND o.season = h.source_season_key
LEFT JOIN season_meta s
    ON s.league_id = h.canonical_league_id
   AND s.season_code = h.source_season_key
ORDER BY h.canonical_league_id;