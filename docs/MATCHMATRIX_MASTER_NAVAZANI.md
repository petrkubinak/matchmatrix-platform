# MATCHMATRIX – MASTER NAVÁZÁNÍ

## 1. ÚČEL

Tento dokument je hlavní referenční bod projektu MatchMatrix.

Nejde o denní log.
Nejde o detailní historii troubleshootingů.

Tento dokument obsahuje:
- hlavní architekturu
- strategická pravidla
- cílový směr
- aktuální runtime stav
- dlouhodobou roadmapu

Detailní historické logy patří do:
- docs/history/
- reports/
- auditních SQL
- OPS tabulek

---

# 2. HLAVNÍ SMĚR PROJEKTU

MatchMatrix je:

- multisport datová platforma
- sports intelligence platform
- sports knowledge graph
- multi-provider architektura
- ticket engine
- media platform
- budoucí AI/rating systém

Cíl:
sjednotit:
- výsledky
- statistiky
- odds
- media
- people
- highlights
- community data
- historická data

do jedné propojené platformy.

---

# 3. PRODUKTOVÁ VIZE – PROFI + AMATÉRSKÉ SOUTĚŽE

MatchMatrix není pouze výsledkový systém.

Cílový směr:
- propojení profesionálního a amatérského sportu
- jednotná databázová vrstva
- jednotný rating engine
- jednotná media vrstva
- jednotný search/index systém

## 3.1 Profi soutěže

Profi soutěže:
- ingest přes providery
- automatický harvesting
- canonical merge
- media ingest
- odds
- people layer

## 3.2 Amatérské soutěže

Amatérské soutěže:
- budou vytvářeny komunitou
- musí být reálně existující
- musí být ověřené MatchMatrix administrací
- mohou být ručně spravované
- mohou být bez automatického provideru

Cíl:
umožnit amatérským soutěžím:
- vlastní profil
- tabulky
- statistiky
- ratingy
- historii
- media vrstvu
- porovnávání s jinými soutěžemi

## 3.3 Společná databázová logika

Profi i amatérské soutěže mají sdílet:
- canonical entities
- teams
- players
- matches
- rating engine
- statistické výpočty
- media layer
- search/index systém

Rozdíl:
- původ dat
- kvalita dat
- rozsah dat
- úroveň ověření

Příklad:

```text
league_level:
- professional
- amateur

data_origin:
- provider
- manual_verified
- community_verified

verification_status:
- pending
- verified
- rejected

4. HLAVNÍ ARCHITEKTONICKÉ PRAVIDLO

Každá vrstva může mít jiného providera.

Příklady:

CORE provider
ODDS provider
PEOPLE provider
MEDIA provider

Nesjednocujeme:

endpointy
JSON formáty
coverage logiku

Sjednocujeme:

technický pattern
staging/public flow
audit flow
orchestrace
naming
worker pattern

5. VRSTVY SYSTÉMU

5.1 CORE

Typicky:

leagues
teams
fixtures

5.2 ODDS
bookmaker odds
line movement
betting markets

5.3 PEOPLE
players
coaches
player stats
player profiles

5.4 MEDIA
articles
news
highlights
videos
social content

5.5 COMMUNITY
Budoucí vrstva:

amatérské soutěže
komunitní správa
ruční editace
verified community data

6. CÍLOVÝ TECHNICKÝ PATTERN

provider/source
→ RAW
→ staging
→ parser
→ merge
→ public canonical layer
→ audit
→ orchestration

7. STRUKTURA SLOŽEK

7.1 ingest/
Každý sport:

ingest/API-<Sport>/

Obsah:

.env
pull scripts
parse scripts

7.2 workers/
workers obsahuje:

orchestrace
hlavní runnery
layer orchestrátory

7.3 workers/media/
MEDIA workery:

workers/media/

Například:

pull_official_site_media_articles_v1.py
pull_rss_media_articles_v1.py
merge_media_articles_to_public_v1.py

7.4 db/checks/
Kontrolní SQL.

7.5 db/audit/
Auditní SQL.

8. ORCHESTRACE

Hlavní princip:

MASTER ORCHESTRATOR
├─ CORE cycle
├─ ODDS cycle
├─ PEOPLE cycle
└─ MEDIA cycle

Aktuální hlavní runtime orchestrátor:

workers/run_ingest_cycle_v3.py

MEDIA bude mít vlastní orchestrátor:

workers/run_media_pipeline_v1.py

9. ZDROJE PRAVDY
Hlavní pravda projektu:

OPS tabulky
runtime audity
planner
job_runs
auditní SQL
dashboardy/panely

Klíčové objekty:

ops.runtime_entity_audit
ops.sport_completion_audit
ops.ingest_targets
ops.ingest_planner
ops.provider_entity_coverage
ops.job_runs

Textový dokument nikdy nesmí přebít DB realitu.

10. AKTUÁLNÍ STAV

10.1 CORE
CONFIRMED / STABLE:

FB
HK
BK
HB
VB
CK
RGB
AFB
TN

Potvrzené entity:

leagues
teams
fixtures

Pipeline:

planner-driven
rerun-safe
merge-safe
multisport unified flow

10.2 PEOPLE
PEOPLE layer:

multi-provider architektura potvrzena

Aktuálně funkční:

FB
AFB
HK
BK
BSB
MMA

Použité providery:

api_football
api_american_football
sportsdataio

Strategie:
PEOPLE provider může být jiný než CORE provider.

10.3 ODDS
ODDS layer:

architektonicky připraven
hlavní validace po paid/API aktivaci

Primární football odds:

TheOdds

API-Sports odds:

planned po PRO aktivaci

10.4 MEDIA
MEDIA layer:

první reusable multisport architecture potvrzena

Aktuálně:

official_site ingest
RSS ingest
staging merge
public articles
alias mapping
media audit

Funkční:

NHL
NBA

PARTIAL:

UEFA
FIFA

Aktuální pattern:

official_site/rss
→ staging.stg_media_articles
→ public.media_articles
→ alias mapping
→ audit

Nová struktura:

workers/media/

11. STRATEGICKÁ ROADMAPA

Priorita:

stabilizace MEDIA layer

scheduler/autonomous harvesting

UI/API vrstva

entity search + graph

AI summaries

rating engine

community/amateur layer

machine learning/prediction layer

12. PRAVIDLA PRÁCE

postup po jedné akci
SQL pro DBeaver
ostatní kód pro VS terminál
vždy uvádět:
kam uložit
název souboru
jak spustit

Nepřeskakovat mezi vrstvami bez důvodu.

Při novém chatu:

navazovat přes tento master
navazovat přes auditní DB pravdu
navazovat přes poslední konkrétní krok