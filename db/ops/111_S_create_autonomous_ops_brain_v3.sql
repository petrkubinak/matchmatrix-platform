/*
MATCHMATRIX SQL 111_S
AUTONOMOUS OPS BRAIN V3

CO TO JE:
- Opravený Brain Score.
- Sjednocuje sport_code.
- Seskupuje duplicity.
- Blokuje entity, které nejsou implementované.
- Převádí AI rozhodnutí na RUN / WAIT / HOLD.

K ČEMU TO JE:
- Aby Brain nespouštěl opakovaně nulové CORE joby.
- Aby nespouštěl HK odds, když ještě nejsou implementované.
- Aby doporučoval skutečně nejpřínosnější další akci.

KDE TO UVIDÍME:
- ops.v_autonomous_ops_brain_v3

JAK SE TO VYUŽIJE:
- Panel
- 111_S launcher
- budoucí autonomní řízení MatchMatrix
*/

CREATE OR REPLACE VIEW ops.v_autonomous_ops_brain_v3 AS
WITH normalized AS (
    SELECT
        CASE
            WHEN sport_code = 'football' THEN 'FB'
            WHEN sport_code = 'hockey' THEN 'HK'
            WHEN sport_code = 'basketball' THEN 'BK'
            ELSE sport_code
        END AS sport_code,

        provider,
        entity,
        league_id,
        season,
        run_group,

        MIN(recommendation_rank) AS recommendation_rank,
        MAX(empty_runs) AS empty_runs,
        MAX(empty_pct) AS empty_pct,

        MAX(ai_decision) AS ai_decision,
        MAX(ai_risk_level) AS ai_risk_level,
        MAX(ai_reason) AS ai_reason,
        BOOL_OR(autonomous_safe) AS autonomous_safe,
        MAX(generated_at) AS generated_at,

        COUNT(*) AS grouped_count
    FROM ops.v_panel_ai_recommendations_v1
    GROUP BY
        CASE
            WHEN sport_code = 'football' THEN 'FB'
            WHEN sport_code = 'hockey' THEN 'HK'
            WHEN sport_code = 'basketball' THEN 'BK'
            ELSE sport_code
        END,
        provider,
        entity,
        league_id,
        season,
        run_group
),

brain AS (
    SELECT
        n.*,

        s.sport_name,
        s.total_pct,
        s.sport_readiness,
        s.recommended_focus,

        CASE
            WHEN n.provider = 'api_hockey'
             AND n.sport_code = 'HK'
             AND n.entity = 'odds'
                THEN true
            ELSE false
        END AS is_not_implemented,

        CASE
            WHEN n.ai_decision = 'POZASTAVIT' THEN 0
            WHEN n.ai_decision = 'POČKAT' THEN 20
            WHEN n.ai_decision = 'OPATRNÝ RETRY' THEN 65
            ELSE 40
        END
        +
        CASE
            WHEN s.recommended_focus = 'MEDIA_LAYER' THEN 25
            WHEN s.recommended_focus = 'PEOPLE_LAYER' THEN 20
            WHEN s.recommended_focus = 'ODDS_LAYER' THEN 10
            WHEN s.recommended_focus = 'CORE_HARVEST' THEN 5
            ELSE 0
        END
        -
        COALESCE(n.empty_runs, 0) * 10
        -
        CASE
            WHEN n.entity <> LOWER(REPLACE(COALESCE(s.recommended_focus, ''), '_LAYER', ''))
             AND s.recommended_focus IN ('PEOPLE_LAYER', 'MEDIA_LAYER', 'ODDS_LAYER')
                THEN 15
            ELSE 0
        END AS raw_brain_score

    FROM normalized n
    LEFT JOIN ops.v_sport_completion_dashboard_v2 s
        ON s.sport_code = n.sport_code
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE
                WHEN is_not_implemented THEN 1
                ELSE 0
            END,
            GREATEST(raw_brain_score, 0) DESC,
            recommendation_rank ASC
    ) AS brain_rank,

    provider,
    sport_code,
    sport_name,
    entity,
    league_id,
    season,
    run_group,

    total_pct,
    sport_readiness,
    recommended_focus,

    ai_decision,
    ai_risk_level,
    autonomous_safe,

    empty_runs,
    empty_pct,
    grouped_count,

    is_not_implemented,

    GREATEST(raw_brain_score, 0) AS brain_score,

    CASE
        WHEN is_not_implemented THEN 'HOLD'
        WHEN ai_decision = 'POZASTAVIT' THEN 'HOLD'
        WHEN ai_decision = 'POČKAT' THEN 'WAIT'
        WHEN GREATEST(raw_brain_score, 0) >= 80 THEN 'RUN'
        WHEN GREATEST(raw_brain_score, 0) >= 50 THEN 'RUN_WITH_CAUTION'
        WHEN GREATEST(raw_brain_score, 0) >= 20 THEN 'WAIT'
        ELSE 'HOLD'
    END AS brain_decision,

    CASE
        WHEN is_not_implemented
            THEN 'Entita zatím není implementovaná ve workeru, nespouštět automaticky.'
        WHEN ai_decision = 'POZASTAVIT'
            THEN 'AI doporučuje pozastavit po opakovaných neúspěšných pokusech.'
        WHEN ai_decision = 'POČKAT'
            THEN 'AI doporučuje počkat a nespouštět hned znovu.'
        WHEN GREATEST(raw_brain_score, 0) >= 80
            THEN 'Vysoké skóre, nízké riziko, vhodné pro autonomní spuštění.'
        WHEN GREATEST(raw_brain_score, 0) >= 50
            THEN 'Možné spustit opatrně.'
        ELSE 'Nízké skóre nebo nevhodný focus.'
    END AS brain_decision_reason,

    ai_reason,
    generated_at

FROM brain
ORDER BY
    brain_rank;