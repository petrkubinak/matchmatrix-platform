/*
MATCHMATRIX SQL 119_B
AUDIT SPORT COMPLETION PEOPLE MISMATCH V1

CO TO JE:
- Audit porovnává Sport Completion proti People Pipeline.

K ČEMU TO JE:
- Ověří, proč má Sport Completion people_pct = 0,
  i když People Pipeline ukazuje hráče a provider mapy.

KDE TO UVIDÍME:
- DBeaver nyní.
- Později panel V18 -> Sport Completion detail.

JAK SE TO VYUŽIJE:
- Podle výsledku opravíme výpočet v_sport_completion_dashboard_v2/v3.
*/

CREATE OR REPLACE VIEW ops.v_sport_completion_people_mismatch_audit_v1 AS
SELECT
    sc.sport_code,
    sc.sport_name,
    sc.core_pct,
    sc.people_pct AS sport_completion_people_pct,
    sc.media_pct,
    sc.odds_pct,
    sc.total_pct,
    sc.sport_readiness,
    sc.recommended_focus,

    ps.providers AS people_providers,
    ps.raw_payloads AS people_raw_payloads,
    ps.raw_pending AS people_raw_pending,
    ps.raw_parsed AS people_raw_parsed,
    ps.raw_error AS people_raw_error,
    ps.staging_players,
    ps.staging_distinct_players,
    ps.public_players,
    ps.provider_maps,
    ps.coverage_pct AS people_pipeline_coverage_pct,
    ps.sport_people_status,

    CASE
        WHEN COALESCE(sc.people_pct, 0) = 0
         AND COALESCE(ps.coverage_pct, 0) > 0
            THEN 'MISMATCH_PEOPLE_EXISTS_BUT_COMPLETION_ZERO'

        WHEN COALESCE(sc.people_pct, 0) <> COALESCE(ps.coverage_pct, 0)
            THEN 'MISMATCH_PERCENT_DIFFERS'

        ELSE 'OK'
    END AS audit_status,

    CASE
        WHEN COALESCE(sc.people_pct, 0) = 0
         AND COALESCE(ps.coverage_pct, 0) > 0
            THEN 'Sport Completion nebere data z ops.v_people_pipeline_summary_v1 nebo špatně joinuje sport_code.'

        WHEN ps.sport_code IS NULL
            THEN 'Sport chybí v People Pipeline summary.'

        ELSE 'Bez kritického rozdílu.'
    END AS audit_note,

    now() AS generated_at
FROM ops.v_sport_completion_dashboard_v2 sc
LEFT JOIN ops.v_people_pipeline_summary_v1 ps
    ON ps.sport_code = sc.sport_code
ORDER BY
    CASE
        WHEN COALESCE(sc.people_pct, 0) = 0
         AND COALESCE(ps.coverage_pct, 0) > 0 THEN 1
        WHEN COALESCE(sc.people_pct, 0) <> COALESCE(ps.coverage_pct, 0) THEN 2
        ELSE 3
    END,
    sc.sport_code;

SELECT *
FROM ops.v_sport_completion_people_mismatch_audit_v1;