/*
===============================================================================
MATCHMATRIX 20_1_O – OPERATOR ACTION BUTTONS
===============================================================================

CO TO JE:
View, které převádí doporučení operátorského engine na konkrétní tlačítka v panelu.

K ČEMU TO JE:
Panel nebude ukazovat jen textové doporučení, ale připraví konkrétní akci:
- POKRAČOVAT
- OTEVŘÍT PROVIDER MATRIX
- OTEVŘÍT LOG
- RETRY / READY
- OPRAVIT
- BLOKOVAT

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ CHYBY / STOP
→ DOPORUČENÁ AKCE
→ TLAČÍTKO

Databáze:
ops.v_operator_action_buttons_v1

JAK SE TO VYUŽIJE:
Panel vezme button_code a button_label_cz a podle toho zobrazí správné tlačítko.
Později se button_code napojí na konkrétní Python funkci v panelu.

NAVAZUJE NA:
20_1_M_operator_result_classifier.sql
20_1_N_operator_recommendation_engine.sql

DALŠÍ KROK:
20_1_P_operator_panel_recommendation_binding.py

SOUBOR:
20_1_O_operator_action_buttons.sql

KAM ULOŽIT:
C:\MatchMatrix-platform\db\ops\20_1\

JAK SPUSTIT:
DBeaver → spustit celý SQL skript.

CO OČEKÁVAT:
VB dostane tlačítko:
OTEVŘÍT PROVIDER MATRIX

Hotové řádky dostanou:
POKRAČOVAT

Chyby workerů dostanou:
OTEVŘÍT LOG nebo RETRY / READY
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_action_buttons_v1;

CREATE VIEW ops.v_operator_action_buttons_v1
AS
SELECT
    r.id,
    r.sport_code,
    r.sport_name,
    r.target_layer,
    r.command_title,
    r.effective_status,
    r.classification_reason,
    r.operator_recommendation,
    r.recommendation_priority,

    CASE
        WHEN r.operator_recommendation = 'OTEVŘÍT PROVIDER MATRIX'
            THEN 'OPEN_PROVIDER_MATRIX'

        WHEN r.operator_recommendation = 'OTEVŘÍT ROUTING AUDIT'
            THEN 'OPEN_ROUTING_AUDIT'

        WHEN r.operator_recommendation = 'OTEVŘÍT LOG'
            THEN 'OPEN_LOG'

        WHEN r.operator_recommendation = 'POKRAČOVAT'
            THEN 'CONTINUE_NEXT'

        WHEN r.operator_recommendation = 'PROVÉST ANALÝZU'
            THEN 'OPEN_DETAIL_ANALYSIS'

        ELSE 'OPEN_DETAIL'
    END AS button_code,

    CASE
        WHEN r.operator_recommendation = 'OTEVŘÍT PROVIDER MATRIX'
            THEN '🔌 OTEVŘÍT PROVIDER MATRIX'

        WHEN r.operator_recommendation = 'OTEVŘÍT ROUTING AUDIT'
            THEN '🧭 OTEVŘÍT ROUTING AUDIT'

        WHEN r.operator_recommendation = 'OTEVŘÍT LOG'
            THEN '📄 OTEVŘÍT LOG'

        WHEN r.operator_recommendation = 'POKRAČOVAT'
            THEN '▶ POKRAČOVAT'

        WHEN r.operator_recommendation = 'PROVÉST ANALÝZU'
            THEN '🔎 OTEVŘÍT ANALÝZU'

        ELSE '🔎 DETAIL'
    END AS button_label_cz,

    CASE
        WHEN r.effective_status = 'FAILED'
            THEN true
        WHEN r.operator_recommendation = 'POKRAČOVAT'
            THEN true
        ELSE false
    END AS button_enabled,

    CASE
        WHEN r.recommendation_priority = 'RESEARCH_REQUIRED'
            THEN 'PURPLE'
        WHEN r.recommendation_priority = 'HIGH'
            THEN 'RED'
        WHEN r.recommendation_priority = 'MEDIUM'
            THEN 'YELLOW'
        ELSE 'GREEN'
    END AS button_color,

    CASE
        WHEN r.operator_recommendation = 'OTEVŘÍT PROVIDER MATRIX'
            THEN 'Přejdi na záložku PROVIDER MATRIX a ověř dostupnost people provideru pro sport.'

        WHEN r.operator_recommendation = 'OTEVŘÍT LOG'
            THEN 'Otevři detail posledního logu a najdi konkrétní chybu workeru.'

        WHEN r.operator_recommendation = 'OTEVŘÍT ROUTING AUDIT'
            THEN 'Zkontroluj routing workeru, provider a podporovanou entitu.'

        WHEN r.operator_recommendation = 'POKRAČOVAT'
            THEN 'Pokračuj další připravenou akcí v denní frontě.'

        ELSE 'Otevři detail řádku a rozhodni další postup.'
    END AS button_help_cz

FROM ops.v_operator_recommendation_engine_v1 r;