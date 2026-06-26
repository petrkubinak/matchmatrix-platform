/*
MATCHMATRIX SQL 18_5_C
GOVERNANCE PANEL DETAIL V1

CO TO JE:
- Detailní view pro zobrazení governance oblastí v OPS Panelu V18.

K ČEMU TO JE:
- Přeloží technické entity do čitelných českých názvů.
- Přidá doporučení a stav pro panel.

KDE TO UVIDÍME:
- OPS Panel V18
- Governance tab
- Detailní tabulka governance oblastí

JAK SE TO VYUŽIJE:
- Rychlá kontrola, co je hotovo.
- Co je v HOLD.
- Co je ještě částečné.
- Co má být další akce.
*/

DROP VIEW IF EXISTS ops.v_governance_panel_detail_v1;

CREATE OR REPLACE VIEW ops.v_governance_panel_detail_v1 AS
SELECT
    CASE
        WHEN entity = 'team_duplicate_prevention' THEN 'Týmy'
        WHEN entity = 'player_identity_governance' THEN 'Hráči - identity'
        WHEN entity = 'player_provider_map_governance' THEN 'Hráči - provider mapy'
        WHEN entity = 'league_canonical_governance' THEN 'Ligy'
        ELSE entity
    END AS oblast,

    entity AS technicky_kod,

    CASE
        WHEN current_state IN ('CONFIRMED','READY') THEN 'Hotovo'
        WHEN current_state = 'CONTROLLED_HOLD' THEN 'Kontrolovaný HOLD'
        WHEN current_state = 'PARTIAL' THEN 'Částečně hotovo'
        WHEN current_state = 'REVIEW' THEN 'Ke kontrole'
        ELSE current_state
    END AS stav_cz,

    governance_score AS skore,

    state_reason AS vysvetleni,
    db_evidence_summary AS dukaz_v_db,
    next_action AS dalsi_krok,
    last_check_at AS posledni_kontrola,

    CASE
        WHEN governance_score >= 95 THEN 'READY'
        WHEN governance_score >= 85 THEN 'CONTROLLED'
        WHEN governance_score >= 60 THEN 'PARTIAL'
        ELSE 'REVIEW'
    END AS panel_status

FROM ops.v_governance_dashboard_v1
ORDER BY
    skore DESC,
    oblast;