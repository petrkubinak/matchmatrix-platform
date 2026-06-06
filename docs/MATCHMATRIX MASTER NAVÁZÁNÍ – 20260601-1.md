# MATCHMATRIX MASTER NAVÁZÁNÍ — PEOPLE PROVIDER STRATEGY

Datum: 2026-06-01

---

# KDE JSME SKONČILI

Dokončili jsme PEOPLE PIPELINE audit a Tennis PEOPLE bootstrap.

Aktuální stav PEOPLE vrstvy:

FB   Football            READY
HK   Hockey              READY
BK   Basketball          READY
TN   Tennis              READY
MMA  MMA                 READY
BSB  Baseball            READY
CK   Cricket             READY
AFB  American Football   READY

Celkem:

8 READY sportů z 14

---

# TENNIS

Dokončeno:

112_F_bootstrap_tennis_players_from_fixtures_v1.sql

Výsledek:

TN staging players      138
TN public players       138
TN provider maps        138
coverage            100.00 %
status               READY

Python merge:

C:\MatchMatrix-platform\workers\people\tennis\merge_tennis_players_to_public_v1.py

Výsledek:

INSERTED PLAYERS : 138
INSERTED MAPS    : 138

TN = READY

---

# TENNIS PROFILE PROVIDER AUDIT

Testovaný provider:

tennis-api-atp-wta-itf

Nalezené endpointy:

getPlayers
getPlayerInfo
singlesRanking
doublesRanking
getPlayerSurfaceSummary
getPlayerTitles
getPlayerMatchStats

Výsledek testu:

HTTP 403
You are not subscribed to this API

Audit zapsán:

provider = tennis-api-atp-wta-itf
sport = TN
entity = players

STATUS:
BLOCKED_BY_SUBSCRIPTION

VERDICT:
NOT_USABLE_NOW

Závěr:

Provider existuje.
People data existují.
Vyžaduje subscription.

Později zařadit mezi PRO harvest providery.

---

# HANDBALL AUDIT

Audit provider_people_audit:

api_handball

players:
ENDPOINT_EXISTS_EMPTY

coaches:
ENDPOINT_EXISTS_EMPTY

Smoke test:

HTTP 200
response_count = 0

Znamená:

endpoint existuje
provider funguje
scope je pravděpodobně špatně
nebo provider nevrací data

---

# HANDBALL CORE STAV

HB teams:

1005

HB matches:

9275

HB staging players:

0

HB public players:

0

HB provider maps:

0

Závěr:

CORE vrstva je silná.

PEOPLE vrstva neexistuje.

---

# DŮLEŽITÝ OBJEV

Kontrola složky:

C:\MatchMatrix-platform\ingest\API-Házená\

Obsahuje pouze:

pull_api_handball_leagues.ps1
pull_api_handball_teams.ps1
pull_api_handball_fixtures.ps1

Nenalezeno:

pull_api_handball_players
parse_api_handball_players
merge_handball_players

To znamená:

Handball PEOPLE pipeline ve skutečnosti není dokončená.

Máme pouze historický smoke test.

---

# VOLLEYBALL

VB teams:

12

VB matches:

178

VB players:

0

VB provider maps:

0

Existují soubory:

pull_api_volleyball_players.ps1
pull_api_volleyball_players_raw_v1.ps1
parse_api_volleyball_players_v1.py

Bude nutné prověřit, proč se data nedostala do staging.

---

# PEOPLE PROVIDER AUDIT — HLAVNÍ ZÁVĚR

Dnes jsme zjistili zásadní věc:

Problém MatchMatrix už není:

* leagues
* teams
* fixtures

To máme velmi dobře pokryté.

Největší priorita projektu je nyní:

PEOPLE LAYER

Protože bez hráčů nevznikne:

* profil hráče
* rating hráče
* forma hráče
* statistiky hráče
* kariéra hráče
* H2H
* AI modely
* player pages
* player media
* komunitní funkce

---

# DALŠÍ KROK (PRVNÍ AKCE V NOVÉM CHATU)

Cíl:

PEOPLE PROVIDER MASTER MATRIX

Ne po sportech.

Pro všechny sporty najednou.

Zjistit:

SPORT
PROVIDER
PLAYERS
COACHES
PROFILES
RANKINGS
STATS
MEDIA
STATUS
COST

Rozdělení:

A) READY PROVIDERS
FB
HK
BK
TN
MMA
BSB
CK
AFB

B) ENDPOINT EXISTS
HB
VB
RGB

C) NEW PROVIDER NEEDED
DRT
FH
ESP

Výstup:

Jedna centrální tabulka všech sportů a všech PEOPLE providerů.

Podle ní rozhodneme:

* co opravíme
* co doplníme
* co koupíme v PRO měsíci
* kde hledat nové providery

---

# PRIORITA PRO DALŠÍ DEN

Neřešit jednotlivé sporty.

Udělat:

113_Z_PEOPLE_MASTER_PROVIDER_AUDIT_V1

a navrhnout kompletní PEOPLE strategii pro všech 14 sportů.

To je aktuálně nejdůležitější vrstva celého MatchMatrix.
