MATCHMATRIX – DENNÍ ZÁPIS

Datum: 14.06.2026
EPIC: 19_5_PC2_PEOPLE_MEDIA_ACTIVATION

Co jsme dnes dokončili
1. FB MEDIA vrstva na PC2 zprovozněna

Odhalili jsme chybný routing:

PC2_MEDIA_FB
↓
run_ingest_planner_jobs.py
↓
run_unified_ingest_v1.py
↓
ERROR
official_site/football/media není podporováno

Po analýze jsme zjistili, že MEDIA nesmí používat Unified Ingest.

Byl přesměrován na:

workers/media/pull_official_site_media_articles_v1.py

a command:

id=9

byl kompletně opraven.

2. FB MEDIA harvest úspěšně spuštěn

Výsledek:

PROCESSED = 151
INSERTED  = 100
RETURN_CODE = 0

Funkční zdroje:

UEFA
Premier League
LaLiga
Bundesliga

Dočasně nefunkční:

FIFA      = EMPTY
Serie A   = EMPTY
Ligue 1   = 404
3. PC2 panel ověřen

Potvrdili jsme:

PC2 Command Center
↓
spustí worker
↓
worker běží
↓
vrací výsledek
↓
panel zapisuje stav

První skutečný end-to-end běh z panelu.

4. BK PEOPLE ověřeno

Spuštěn:

run_players_fetch_bk_only_v1.py

Výsledek:

worker OK
provider OK
DB zápis OK
response_count = 0

Technicky funkční.

Datově zatím prázdné.

5. AFB PEOPLE routing opraven

Původně:

run_ingest_planner_jobs.py

což vedlo na:

GenericApiSportProvider

a končilo:

players nejsou podporovány
6. Nalezen správný worker

Audit odhalil:

workers/run_people_pipeline_v22_from_planner.py

a potvrzen registry:

PEOPLE_PIPELINE_V22
7. AFB PC2 command opraven

Command id:

3

nově používá:

workers/run_people_pipeline_v22_from_planner.py
8. AFB planner job opraven

Job:

8821

původně:

provider_league_id = NULL

opraveno na:

provider_league_id = NFL
season = 2024
9. AFB PEOPLE finální výsledek

Pipeline proběhla:

HTTP OK
players endpoint OK
league scope OK

ale provider vrátil:

response_count = 0

Výsledek:

AFB PEOPLE = TECH_READY_EMPTY

To znamená:

worker funguje
routing funguje
planner funguje
provider vrací 0 hráčů

Není to chyba MatchMatrix.

Aktuální stav PC2
HOTOVO
CORE
HB CORE
TN CORE
MEDIA
FB MEDIA
PEOPLE
BK PEOPLE = TECH_READY_EMPTY
AFB PEOPLE = TECH_READY_EMPTY
Stav připravenosti
FB MEDIA              READY
AFB PEOPLE            TECH_READY_EMPTY
BK PEOPLE             TECH_READY_EMPTY
BSB PEOPLE            READY_TO_TEST
CK PEOPLE             READY_TO_TEST
HK PEOPLE             READY_TO_TEST
VB PEOPLE             READY_TO_TEST
Čím budeme pokračovat zítra
PRIORITA 1

BSB PEOPLE

Prověřit:

command_id=5

stejně jako dnes AFB.

Cíl:

ověřit routing
ověřit worker
ověřit provider
ověřit data
PRIORITA 2

CK PEOPLE

Stejný postup.

PRIORITA 3

HK PEOPLE

Zjistit:

api_hockey endpoint

protože zde očekáváme skutečný provider problém.

PRIORITA 4

VB PEOPLE

Audit:

provider
worker
planner
Stav projektu na konci dne
PC2_CORE_LAYER           READY
PC2_MEDIA_LAYER          READY
PC2_COMMAND_CENTER       WORKING
FB_MEDIA_LAYER           READY
AFB_PEOPLE_PIPELINE      TECH_READY
BK_PEOPLE_PIPELINE       TECH_READY
NEXT_TARGET              BSB PEOPLE

Dnes jsme poprvé prokázali, že PC2 Command Center skutečně řídí reálné harvesty a že umíme diagnostikovat rozdíl mezi:

ROUTING ERROR
WORKER ERROR
PROVIDER ERROR
EMPTY DATA

To je pro další rozšiřování People Layer velmi důležitý krok.

Dobrou, zítra navážeme na BSB PEOPLE (command_id=5).