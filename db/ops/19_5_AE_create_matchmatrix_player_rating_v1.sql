DROP VIEW IF EXISTS ops.v_player_rating_engine_v1;

CREATE VIEW ops.v_player_rating_engine_v1 AS

SELECT
    p.player_external_id,
    p.team_external_id,
    p.external_league_id,
    p.season,

    p.appearances,
    p.minutes_played,
    p.rating,
    p.goals,
    p.assists,

    ROUND(
        LEAST(
            100,

            (
                COALESCE(p.rating,0) * 8.0
            )

            +

            (
                COALESCE(p.goals,0) * 1.5
            )

            +

            (
                COALESCE(p.assists,0) * 1.0
            )

            +

            (
                LEAST(COALESCE(p.minutes_played,0),3000) / 100.0
            )

            +

            (
                LEAST(COALESCE(p.appearances,0),38) * 0.25
            )

            -

            (
                COALESCE(p.red_cards,0) * 2.0
            )

            -

            (
                COALESCE(p.yellow_cards,0) * 0.20
            )
        )
    ,2) AS matchmatrix_rating

FROM ops.v_fb_player_season_stats_normalized_v1 p;