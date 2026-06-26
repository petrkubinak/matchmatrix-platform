/*
===============================================================================
MATCHMATRIX 20_1_N – OPERATOR RECOMMENDATION ENGINE
===============================================================================
CO TO JE:
Generuje doporučenou akci pro operátora.

K ČEMU TO JE:
Převádí klasifikovanou chybu na konkrétní doporučení.

NAVAZUJE NA:
20_1_L_operator_error_explanation.sql
20_1_M_operator_result_classifier.sql

DALŠÍ KROK:
20_1_O_operator_action_buttons.sql
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_recommendation_engine_v1;

CREATE VIEW ops.v_operator_recommendation_engine_v1
AS
SELECT
    c.id,
    c.sport_code,
    c.sport_name,
    c.target_layer,
    c.command_title,
    c.effective_status,
    c.classification_reason,

    CASE

        WHEN c.classification_reason =
             'CHYBÍ SPECIALIZOVANÝ PROVIDER'
        THEN 'OTEVŘÍT PROVIDER MATRIX'

        WHEN c.classification_reason =
             'ROUTING ERROR'
        THEN 'OTEVŘÍT ROUTING AUDIT'

        WHEN c.classification_reason =
             'WORKER ERROR'
        THEN 'OTEVŘÍT LOG'

        WHEN c.effective_status = 'FAILED'
        THEN 'PROVÉST ANALÝZU'

        ELSE 'POKRAČOVAT'

    END AS operator_recommendation,

    CASE

        WHEN c.classification_reason =
             'CHYBÍ SPECIALIZOVANÝ PROVIDER'
        THEN 'RESEARCH_REQUIRED'

        WHEN c.classification_reason =
             'ROUTING ERROR'
        THEN 'HIGH'

        WHEN c.classification_reason =
             'WORKER ERROR'
        THEN 'MEDIUM'

        ELSE 'LOW'

    END AS recommendation_priority

FROM ops.v_operator_result_classifier_v1 c;