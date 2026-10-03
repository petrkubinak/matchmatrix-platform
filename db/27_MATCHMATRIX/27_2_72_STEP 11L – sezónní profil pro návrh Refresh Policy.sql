-- CO: STEP 11L – sezónní profil pro návrh Refresh Policy
-- K ČEMU: Zjistit stav a časové hranice HB historických scope podle sezóny.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

SELECT
    h.time_mode,
    h.source_season_key,
    h.completion_status,
    count(*) AS scope_count,
    count(*) FILTER (
        WHERE h.scope_coverage_id IS NOT NULL
    ) AS exact_coverage_scopes,
    count(*) FILTER (
        WHERE h.verification_status IN ('COUNT_MATCH', 'RECONCILED')
    ) AS verified_scopes,
    min(h.scope_from) AS earliest_scope_from,
    max(h.scope_to) AS latest_scope_to,
    count(*) FILTER (
        WHERE h.scope_to IS NOT NULL AND h.scope_to < CURRENT_DATE
    ) AS scopes_with_past_end,
    count(*) FILTER (
        WHERE h.scope_to IS NULL
    ) AS scopes_without_end,
    max(h.completed_at) AS latest_completed_at,
    max(h.last_checked_at) AS latest_checked_at
FROM ops.harvest_scope_completion h
WHERE h.source_id = 18
  AND h.sport_code = 'HB'
  AND h.layer_type = 'CORE'
  AND h.entity = 'fixtures'
  AND h.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
GROUP BY h.time_mode, h.source_season_key, h.completion_status
ORDER BY h.source_season_key, h.time_mode, h.completion_status;