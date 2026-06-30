# MATCHMATRIX – NAVÁZÁNÍ DO NOVÉHO CHATU

## Datum: 14.06.2026

# CO JSME DNES UDĚLALI

## 1. PC2 COMMAND CENTER

Pokračovali jsme v reálném testování PC2 fronty.

Cíl:

* neověřovat pouze existenci dat v public tabulkách
* ověřit, že skutečně fungují produkční harvest pipeline
* připravit vše pro budoucí autonomní stahování

Zásadní rozhodnutí:

DONE již neznamená:

"data někdy existovala"

DONE nově znamená:

"PULL → RAW → PARSE → MERGE → PUBLIC funguje a lze spustit znovu"

---

## 2. PANEL V19

Byla dokončena nová navigace:

### Přehled

* KPI nahoře
* Stav hlavních oblastí
* Dnešní priorita
* AI doporučení

### Denní práce

* přehlednější tabulky
* pravý akční panel
* menší horní sekce
* rychlé akce

Bylo odstraněno zamrzání záložky Denní práce.

---

## 3. BK PEOPLE AUDIT

Test:

run_players_fetch_bk_only_v1.py

Nalezen problém:

worker hledal:

API-Sport\pull_api_basketball_players.ps1

správně:

API-Basketball\pull_api_basketball_players.ps1

Opraveno.

Výsledek:

worker funguje
pull funguje

API vrací:

league endpoint pro players vyžaduje team_id

BK tedy není produkčně hotový.

Zjištěno:

public.players = 862

SportsDataIO data existují.

Rozhodnutí:

BK PEOPLE bude potřeba dokončit produkční pipeline.

---

## 4. BSB PEOPLE AUDIT

Spuštěn:

api_baseball players

Výsledek:

GenericApiSportProvider nepodporuje players.

Zjištěno:

public.players = 7109

Data existují, ale produkční harvest není dokončen.

---

## 5. CK PEOPLE AUDIT

Spuštěn:

api_cricket players

Výsledek:

GenericApiSportProvider nepodporuje players.

Zjištěno:

public.players = 236

Data existují, ale produkční harvest není dokončen.

---

## 6. HK PEOPLE AUDIT

Spuštěna kompletní HK pipeline:

run_players_pipeline_hk_v1.py

Výsledek:

STEP 1 selhal.

Testováno:

/players

a

/squads?team=1

Výsledek:

No working hockey players endpoint found.

Závěr:

HK PEOPLE přes api_hockey není produkčně funkční.

---

## 7. PŘENASTAVENÍ PC2 FRONTY

Původně:

BK
BSB
CK
HK

označeny jako DONE.

Po dnešním auditu:

vše přepnuto na:

BLOCKED

Důvod:

produkční autonomní pipeline není dokončena.

Staré testovací public data se již nepovažují za hotový harvest.

---

# AKTUÁLNÍ STAV

## CORE

HB CORE

STATUS:

DONE

Funguje.

---

TN CORE

STATUS:

DONE

Funguje.

---

## PEOPLE

AFB

STATUS:

BLOCKED

Nutné ověřit produkční pipeline.

---

BK

STATUS:

BLOCKED

Nutné dokončit team-based players pipeline.

---

BSB

STATUS:

BLOCKED

Nutný standalone players provider.

---

CK

STATUS:

BLOCKED

Nutný standalone players provider.

---

HK

STATUS:

BLOCKED

api_hockey players endpoint nefunguje.

Nutné najít nový provider.

---

VB

STATUS:

BLOCKED

Audit zatím neproveden.

---

# ZÁSADNÍ ROZHODNUTÍ

Od této chvíle:

DONE = lze znovu stáhnout

DONE ≠ data existují

Budeme ověřovat:

PULL
RAW
PARSE
MERGE
PUBLIC
AUDIT

pro každý sport zvlášť.

---

# ČÍM NAVÁŽEME ZÍTRA

## EPIC 19_3_A_HK_PROVIDER_RESEARCH

Vytvoříme provider audit.

Budeme hledat:

1. NHL Public API
2. SportsDataIO NHL
3. EliteProspects
4. další hockey providers

Pro každý provider zjistíme:

* hráči
* trenéři
* fotografie
* statistiky
* licence
* free / paid
* limity

---

# NÁSLEDUJÍCÍ SCRIPTY

Budou vytvořeny:

19_3_A_HK_PROVIDER_RESEARCH

19_3_B_HK_NHL_PUBLIC_PULL

19_3_C_HK_NHL_PUBLIC_PARSE

19_3_D_HK_NHL_PUBLIC_MERGE

19_3_E_HK_NHL_PUBLIC_PIPELINE

19_3_F_HK_PROVIDER_READINESS_AUDIT

---

# CÍL DALŠÍ ETAPY

Nezajímá nás:

"data už někde jsou"

Zajímá nás:

"umíme je znovu stáhnout"

Konečný cíl:

AUTONOMNÍ PEOPLE LAYER

pro všechny sporty:

AFB
BK
BSB
CK
HK
VB

včetně:

PULL → RAW → PARSE → MERGE → PUBLIC → AUDIT

a následně napojení do autonomního plánovače MatchMatrix.
