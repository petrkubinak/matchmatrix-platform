/*
===============================================================================
MATCHMATRIX 20_1_P2_A – OPERATOR PROVIDER CONTEXT VIEW
===============================================================================

CO TO JE:
View, které doplní k operátorské chybě kontext providera.

K ČEMU TO JE:
Panel nebude ukazovat pouze:
OTEVŘÍT PROVIDER MATRIX

ale rovnou:
api_volleyball
→ HLEDAT PEOPLE PROVIDERA

KDE TO UVIDÍME:
OPS PANEL
→ DENNÍ PRÁCE
→ sloupec PROVIDER / DOPORUČENÍ
→ horní box CHYBY / STOP
→ detail řádku

JAK SE TO VYUŽIJE:
Operátor hned uvidí:
- který provider je problém,
- jaká entita selhala,
- proč selhala,
- co s tím má udělat.

NAVAZUJE NA:
20_1_M_operator_result_classifier.sql
20_1_N_operator_recommendation_engine.sql
20_1_O_operator_action_buttons.sql
20_1_P_operator_panel_recommendation_binding.py

DALŠÍ KROK:
20_1_P2_B_operator_panel_provider_context_binding.py

SOUBOR:
20_1_P2_A_provider_context_view.sql

KAM ULOŽIT:
C:\MatchMatrix-platform\db\ops\20_1\

JAK SPUSTIT:
DBeaver → spustit celý SQL skript.

CO OČEKÁVAT:
VB ukáže:
api_volleyball
→ HLEDAT PEOPLE PROVIDERA
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_provider_context_v1;

CREATE VIEW ops.v_operator_provider_context_v1
AS
SELECT
    b.id,
    b.sport_code,
    b.sport_name,
    b.target_layer,
    b.command_title,
    b.effective_status,
    b.classification_reason,
    b.operator_recommendation,
    b.recommendation_priority,
    b.button_code,
    b.button_label_cz,
    b.button_help_cz,
    b.button_enabled,
    b.button_color,

    q.run_group,
    q.worker_name,
    q.worker_script,
    q.command_text,
    q.last_result,

    CASE
        WHEN q.last_result ILIKE '%provider=api_volleyball%' THEN 'api_volleyball'
        WHEN q.last_result ILIKE '%api_volleyball%' THEN 'api_volleyball'
        WHEN q.last_result ILIKE '%api_hockey%' THEN 'api_hockey'
        WHEN q.last_result ILIKE '%api_cricket%' THEN 'api_cricket'
        WHEN q.last_result ILIKE '%sportsdataio%' THEN 'sportsdataio'
        WHEN q.last_result ILIKE '%api_football%' THEN 'api_football'
        WHEN q.last_result ILIKE '%api_basketball%' THEN 'api_basketball'
        WHEN q.last_result ILIKE '%api_sport%' THEN 'api_sport'
        ELSE NULL
    END AS detected_provider,

    CASE
        WHEN q.command_text ILIKE '%players%' THEN 'players'
        WHEN q.command_text ILIKE '%fixtures%' THEN 'fixtures'
        WHEN q.command_text ILIKE '%teams%' THEN 'teams'
        WHEN q.command_text ILIKE '%leagues%' THEN 'leagues'
        WHEN q.command_text ILIKE '%media%' THEN 'media'
        ELSE NULL
    END AS detected_entity,

    CASE
        WHEN b.classification_reason = 'CHYBÍ SPECIALIZOVANÝ PROVIDER'
            THEN 'Provider nepodporuje požadovanou entitu.'

        WHEN q.last_result ILIKE '%není podporována%'
            THEN 'Endpoint nebo entita není v aktuálním provider workeru podporována.'

        WHEN q.last_result ILIKE '%RESULT: ERROR%'
            THEN 'Worker doběhl s vnitřní chybou.'

        ELSE 'Bez provider problému.'
    END AS provider_problem_cz,

    CASE
        WHEN b.sport_code = 'VB'
         AND b.target_layer = 'PEOPLE'
         AND b.effective_status = 'FAILED'
            THEN 'Najít specializovaného PEOPLE providera pro Volleyball players.'

        WHEN b.classification_reason = 'CHYBÍ SPECIALIZOVANÝ PROVIDER'
            THEN 'Ověřit Provider Matrix a Missing Provider Matrix.'

        WHEN b.effective_status = 'DONE'
            THEN 'Pokračovat další připravenou akcí.'

        ELSE 'Otevřít detail a rozhodnout další postup.'
    END AS provider_next_step_cz,

    CASE
        WHEN b.classification_reason = 'CHYBÍ SPECIALIZOVANÝ PROVIDER'
            THEN COALESCE(
                (
                    SELECT m.provider_type
					FROM ops.provider_missing_matrix m
                    WHERE m.sport_code = b.sport_code
                      AND m.entity_type ILIKE '%PLAYER%'
                    ORDER BY m.priority_score DESC NULLS LAST
                    LIMIT 1
                ),
                'UNKNOWN'
            )

        ELSE NULL
    END AS suggested_provider,

    CASE
        WHEN b.classification_reason = 'CHYBÍ SPECIALIZOVANÝ PROVIDER'
            THEN 'RESEARCH_REQUIRED'

        WHEN b.effective_status = 'FAILED'
            THEN 'FIX_REQUIRED'

        WHEN b.effective_status = 'DONE'
            THEN 'OK'

        ELSE 'CHECK'
    END AS provider_context_status,

    CASE
        WHEN b.classification_reason = 'CHYBÍ SPECIALIZOVANÝ PROVIDER'
            THEN
                COALESCE(
                    CASE
                        WHEN q.last_result ILIKE '%api_volleyball%' THEN 'api_volleyball'
                        WHEN q.last_result ILIKE '%api_hockey%' THEN 'api_hockey'
                        WHEN q.last_result ILIKE '%api_cricket%' THEN 'api_cricket'
                        ELSE NULL
                    END,
                    'UNKNOWN'
                )
                || ' → HLEDAT PEOPLE PROVIDERA'

        WHEN b.effective_status = 'DONE'
            THEN 'OK → POKRAČOVAT'

        ELSE b.operator_recommendation
    END AS provider_recommendation_short_cz

FROM ops.v_operator_action_buttons_v1 b
LEFT JOIN ops.pc2_run_command_queue q
    ON q.id = b.id;