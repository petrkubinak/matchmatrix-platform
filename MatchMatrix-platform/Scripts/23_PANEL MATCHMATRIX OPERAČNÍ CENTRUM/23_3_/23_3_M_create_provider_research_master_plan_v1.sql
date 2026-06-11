/*
MATCHMATRIX SQL 23_3_M

PROVIDER RESEARCH MASTER PLAN V1

CO TO JE:
- Centrální plán provider research před spuštěním PC2.

K ČEMU TO JE:
- Najít chybějící providery.
- Potvrdit existující providery.
- Připravit kompletní Provider Matrix pro CORE, PEOPLE, MEDIA a ODDS.

KDE TO UVIDÍME:
- OPS Panel
- Provider Command Center
- PC2 Dashboard
- Harvest Readiness

JAK SE TO VYUŽIJE:
- Před spuštěním historického harvestu.
- Před aktivací placených plánů.
- Pro budoucí automatické provider switching.

NAVAZUJE NA:
- 23_3_H People Queue
- 23_3_I People Execution Plan
- 23_3_J Media Audit
- 23_3_K Media Execution Plan
- 23_3_L Media Asset Plan

DALŠÍ KROK:
- 23_3_N Provider Priority Matrix
*/

DROP VIEW IF EXISTS ops.v_provider_research_master_plan_v1;

CREATE OR REPLACE VIEW ops.v_provider_research_master_plan_v1 AS

SELECT *
FROM (
VALUES

/* ===== PEOPLE ===== */

(1,'PEOPLE','FB','PLAYER_PHOTOS','CRITICAL',
 'Najít provider fotek hráčů',
 'Před Player Cards'),

(2,'PEOPLE','FB','COACH_PHOTOS','HIGH',
 'Najít provider fotek trenérů',
 'Před Coach Cards'),

(3,'PEOPLE','HK','PLAYERS','HIGH',
 'Vyřešit BLOCKED provider',
 'Před HK People History'),

(4,'PEOPLE','HB','PLAYERS','HIGH',
 'Vyřešit BLOCKED provider',
 'Před HB People History'),

(5,'PEOPLE','VB','PLAYERS','HIGH',
 'Vyřešit BLOCKED provider',
 'Před VB People History'),

(6,'PEOPLE','RGB','PLAYERS','HIGH',
 'Vyřešit BLOCKED provider',
 'Před Rugby People History'),

(7,'PEOPLE','BK','PLAYERS','HIGH',
 'Dokončit PARTIAL provider',
 'Před BK People History'),

(8,'PEOPLE','CK','PLAYERS','HIGH',
 'Dokončit PARTIAL provider',
 'Před Cricket People History'),

/* ===== MEDIA ===== */

(9,'MEDIA','FB','TEAM_LOGOS','CRITICAL',
 'Najít logo provider',
 'Před Team Cards'),

(10,'MEDIA','FB','STADIUM_PHOTOS','HIGH',
 'Najít stadium provider',
 'Před Stadium Pages'),

(11,'MEDIA','UEFA','ARTICLES','MEDIUM',
 'Rozšířit crawler',
 'Media Expansion'),

(12,'MEDIA','PREMIER_LEAGUE','ARTICLES','MEDIUM',
 'Rozšířit crawler',
 'Media Expansion'),

/* ===== ODDS ===== */

(13,'ODDS','ALL','HISTORICAL_ODDS','HIGH',
 'Prověřit dostupnost historických kurzů',
 'Před Odds Layer'),

/* ===== PAID READY ===== */

(14,'PROVIDER','HK','SPORTSDATAIO','HIGH',
 'Vyhodnotit placený plán',
 'PC2 Activation'),

(15,'PROVIDER','BSB','SPORTSDATAIO','HIGH',
 'Vyhodnotit placený plán',
 'PC2 Activation'),

(16,'PROVIDER','MMA','SPORTSDATAIO','HIGH',
 'Vyhodnotit placený plán',
 'PC2 Activation')

) AS t(
    priority_order,
    research_area,
    sport_code,
    target_entity,
    priority_level,
    research_task,
    business_reason
);