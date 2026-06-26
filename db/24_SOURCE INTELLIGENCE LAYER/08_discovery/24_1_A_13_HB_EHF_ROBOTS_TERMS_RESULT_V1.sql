/*
===============================================================================
MATCHMATRIX SQL 24_1_A_13
HB EHF ROBOTS TERMS RESULT V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_5_SOURCE AUDIT RESULTS

SPORT:
HB - HANDBALL

ZDROJ:
European Handball Federation (EHF)

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Výsledek prvního kompletního auditu zdroje EHF.
- Souhrn všech zjištění z robots.txt, privacy policy,
  player profiles, team profiles a statistik.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Evidence ověřených zdrojů.
- Evidence kvality dat.
- Evidence rozsahu pokrytí.
- Podklad pro HB Master Source Map.

==============================================================================
KDE TO UVIDÍME:
==============================================================================

- ops.source_review_results
- ops.source_verification_log

==============================================================================
JAK SE TO VYUŽIJE:
==============================================================================

- Podklad pro HB Master Source Map.
- Podklad pro další audit národních lig.

===============================================================================
*/

INSERT INTO ops.source_review_results
(
    sport_code,
    source_name,
    review_area,
    review_item,
    review_result,
    evidence_url,
    evidence_note,
    next_action
)
VALUES
('HB','European Handball Federation','LEGAL','Robots.txt','PASS',
 'https://www.eurohandball.com/robots.txt',
 'Robots.txt veřejně dostupný. Crawl-delay 5. Sitemapy dostupné.',
 'RESPECT_CRAWL_DELAY_5'),

('HB','European Handball Federation','LEGAL','Privacy Policy','PASS',
 NULL,
 'Privacy Policy nalezena. Potvrzuje zpracování player info: name, photo, weight, height a statistics. Latest update 2026-04-09.',
 'ARCHIVE_PRIVACY_POLICY'),

('HB','European Handball Federation','DISCOVERY','Sitemap','PASS',
 'https://www.eurohandball.com/sitemap.xml',
 'Sitemap potvrzuje soutěže, news, clubs, player stats, history a další URL.',
 'USE_FOR_DISCOVERY'),

('HB','European Handball Federation','PEOPLE','Player profiles','PASS',
 NULL,
 'Ověřen veřejný hráčský profil: Emil Jakobsen. Obsahuje jméno, věk, místo narození, národnost, výšku, pozici, klub, góly, historii soutěží a klubů.',
 'MAP_PLAYER_PROFILE_FIELDS'),

('HB','European Handball Federation','PEOPLE','Coach profiles','PASS',
 NULL,
 'Ověřen týmový profil SG Flensburg-Handewitt. Obsahuje Head Coach, Coach, Assistant Coach, Goalkeeper Coach a další staff.',
 'MAP_COACH_AND_STAFF_FIELDS'),

('HB','European Handball Federation','PEOPLE','Team roster','PASS',
 NULL,
 'Týmový profil obsahuje aktivní hráče, brankáře, hráče v poli, věk, výšku, pozici, číslo dresu, góly a hráče kteří klub opustili.',
 'MAP_TEAM_ROSTER_FIELDS'),

('HB','European Handball Federation','MEDIA','Photos/media assets','PASS',
 NULL,
 'Screenshoty potvrzují fotografie hráčů, trenérů a staffu na týmových profilech.',
 'REVIEW_PHOTO_LICENSE'),

('HB','European Handball Federation','HISTORY','Historical archive','PASS',
 NULL,
 'Ověřena historie reprezentace Austria s historií EHF/IHF soutěží minimálně od European Championship 1994.',
 'MAP_HISTORY_DEPTH'),

('HB','European Handball Federation','SPORT_CORE','Competition coverage','PARTIAL',
 NULL,
 'EHF pokrývá hlavně mezinárodní a evropské soutěže. Národní domácí ligy nejsou v EHF pokrytí jako samostatné ligové sezóny.',
 'START_NATIONAL_LEAGUES_DISCOVERY');

INSERT INTO ops.source_verification_log
(
    sport_code,
    source_name,
    verification_area,
    verification_item,
    verification_result,
    evidence_url,
    evidence_note,
    next_action
)
VALUES
('HB','European Handball Federation','LEGAL','Robots.txt','VERIFIED_PASS',
 'https://www.eurohandball.com/robots.txt',
 'Crawl-delay 5, sitemapy dostupné, bez globální blokace User-agent *.',
 'RESPECT_CRAWL_DELAY_5'),

('HB','European Handball Federation','DISCOVERY','Sitemap','VERIFIED_PASS',
 'https://www.eurohandball.com/sitemap.xml',
 'Sitemap obsahuje soutěže, clubs, news, player stats, history a mnoho klubových URL.',
 'USE_FOR_DISCOVERY'),

('HB','European Handball Federation','PEOPLE','Player and coach data','VERIFIED_PASS',
 NULL,
 'EHF obsahuje hráče, trenéry, staff, fotky, statistiky, historii a soupisky.',
 'BUILD_HB_EHF_FIELD_MAP'),

('HB','European Handball Federation','COVERAGE','National leagues','VERIFIED_PARTIAL',
 NULL,
 'EHF je výborný zdroj pro evropské/mezinárodní soutěže, ale ne pro domácí národní ligy.',
 'CONTINUE_WITH_HB_NATIONAL_LEAGUES_DISCOVERY');

SELECT
    source_name,
    review_area,
    review_item,
    review_result,
    next_action,
    review_date
FROM ops.source_review_results
WHERE sport_code = 'HB'
  AND source_name = 'European Handball Federation'
ORDER BY review_area, review_item;