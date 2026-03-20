WITH pivoted AS (
    SELECT
        provider,
        sport_code,
        external_league_id,
        season,
        player_external_id,
        team_external_id
    FROM staging.stg_provider_player_season_stats
    GROUP BY
        provider,
        sport_code,
        external_league_id,
        season,
        player_external_id,
        team_external_id
)
SELECT
    COUNT(*) AS pivot_rows,
    COUNT(pei.player_id) AS mapped_players,
    COUNT(t.id) AS mapped_teams,
    COUNT(l.id) AS mapped_leagues
FROM pivoted p
LEFT JOIN public.player_external_identity pei
    ON pei.provider = p.provider
   AND pei.external_player_id = p.player_external_id
LEFT JOIN public.teams t
    ON t.external_team_id = p.team_external_id
LEFT JOIN public.leagues l
    ON l.external_league_id = p.external_league_id;