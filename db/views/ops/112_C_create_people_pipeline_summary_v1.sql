/*
MATCHMATRIX SQL 112_C

CO TO JE:
- Souhrnný PEOPLE dashboard po sportech.

K ČEMU TO JE:
- Panel nebude zobrazovat každý provider zvlášť.
- Uvidíš skutečný stav PEOPLE vrstvy za celý sport.

KDE TO UVIDÍME:
- OPS panel
- AI OPS
- People Dashboard

JAK SE TO VYUŽIJE:
- Brain rychle pozná které sporty mají PEOPLE hotové.
*/

CREATE OR REPLACE VIEW ops.v_people_pipeline_summary_v1 AS
SELECT
    sport_code,

    COUNT(DISTINCT provider) AS providers,

    SUM(raw_payloads) AS raw_payloads,
    SUM(raw_pending) AS raw_pending,
    SUM(raw_parsed) AS raw_parsed,
    SUM(raw_error) AS raw_error,

    SUM(staging_players) AS staging_players,
    SUM(staging_distinct_players) AS staging_distinct_players,

    SUM(public_players) AS public_players,
    SUM(provider_maps) AS provider_maps,

    CASE
        WHEN SUM(staging_distinct_players) = 0 THEN 0
        ELSE ROUND(
            (SUM(public_players)::numeric /
             SUM(staging_distinct_players)::numeric) * 100,
            2
        )
    END AS coverage_pct,

    CASE
        WHEN SUM(public_players) > 0
         AND SUM(public_players) = SUM(staging_distinct_players)
            THEN 'READY'

        WHEN SUM(public_players) > 0
         AND SUM(public_players) < SUM(staging_distinct_players)
            THEN 'PARTIAL'

        WHEN SUM(staging_distinct_players) > 0
         AND SUM(public_players) = 0
            THEN 'READY_FOR_MERGE'

        WHEN SUM(raw_pending) > 0
            THEN 'RAW_PENDING_PARSE'

        ELSE 'DATA_GAP'
    END AS sport_people_status

FROM ops.v_people_pipeline_audit_v1
GROUP BY sport_code
ORDER BY sport_code;