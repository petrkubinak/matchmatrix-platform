# MATCHMATRIX GOVERNANCE

# Založení a vedení číslování každé nové sekce

Verze: V1
Datum založení: 2026-06-24

---

# ÚČEL DOKUMENTU

Tento dokument stanovuje jednotný postup pro zakládání nových hlavních sekcí projektu MatchMatrix.

Cílem je zajistit:

* dlouhodobou přehlednost projektu
* jednotné číslování
* snadnou orientaci v architektuře
* možnost budoucího rozšiřování
* dohledatelnou historii vývoje
* jednotný standard napříč celým projektem

---

# DŮVOD VZNIKU

Během rozvoje MatchMatrix vzniklo velké množství projektových větví:

* Governance
* People Layer
* Media Layer
* Odds Layer
* Ticket Studio
* OPS Centrum
* Harvest Readiness
* Multisport

V červnu 2026 vznikla nová strategická vrstva:

## 24_SOURCE INTELLIGENCE LAYER

Jejím cílem je evidovat a řídit všechny zdroje dat používané v projektu MatchMatrix.

Právě při zakládání této vrstvy vznikla potřeba definovat jednotný standard pro vytváření všech budoucích hlavních sekcí.

---

# PRAVIDLO PRO NOVOU HLAVNÍ SEKCI

Pokud vznikne nová samostatná oblast projektu, musí být:

1. Přiděleno nové hlavní číslo.
2. Vytvořena nová složka v DB.
3. Vytvořen zakládací zápis.
4. Definována struktura podsložek.
5. Definováno číslování skriptů.
6. Definována návaznost na ostatní vrstvy systému.

Bez splnění těchto bodů nesmí vzniknout nová hlavní sekce.

---

# STRUKTURA ČÍSLOVÁNÍ

Používá se formát:

XX_Y_Z_N

kde:

* XX = hlavní sekce
* Y = oblast
* Z = podoblast
* N = verze

Příklad:

24_1_A_1

Význam:

* 24 = SOURCE INTELLIGENCE LAYER
* 1 = MASTER SOURCE MAP
* A = HANDBALL
* 1 = verze V1

Další verze:

24_1_A_2

24_1_A_3

24_1_A_4

---

# PRAVIDLO VERZOVÁNÍ

Nikdy nepřepisovat historii.

Každá významná změna:

V1 → V2

V2 → V3

V3 → V4

Historie musí být vždy dohledatelná.

---

# POVINNÁ STRUKTURA SLOŽEK

Každá nová hlavní sekce musí obsahovat:

00_schema

01_seed

02_validation

03_generation

04_merge

05_views

06_reports

07_audit

08_discovery

09_governance

10_panel

Pokud některá složka není aktuálně využita, zůstává připravena pro budoucí rozšíření.

---

# POVINNÉ UVÁDĚNÍ CESTY

U každého nového skriptu musí být vždy uvedeno:

Kam uložit

Název souboru

Číslo skriptu

Příklad:

C:\MatchMatrix-platform\db\24_SOURCE INTELLIGENCE LAYER\00_schema\

24_1_A_1_HB_SOURCE_MAP_V1.sql

---

# POVINNÁ MATCHMATRIX HLAVIČKA

Každý nový skript musí obsahovat jednotnou MatchMatrix hlavičku.

Minimální rozsah:

VRSTVA

OBLAST

SPORT

VERZE

CO TO JE

K ČEMU TO JE

KDE TO UVIDÍME

JAK SE TO VYUŽIJE

CO SKRIPT DĚLÁ

VSTUP

VÝSTUP

BUDOUCÍ VYUŽITÍ

NÁVAZNOST

AUTOR

---

# VZOR HLAVIČKY

```sql
/*
===============================================================================
MATCHMATRIX SQL 24_1_A_1
HB SOURCE MAP V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_1_MASTER_SOURCE_MAP

SPORT:
HB - HANDBALL

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Centrální registr zdrojů dat pro házenou.
- Evidence hráčů, trenérů, fotografií,
  statistik, médií a historických dat.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Řízení zdrojů dat.
- Řízení kvality dat.
- Řízení providerů.
- Podklad pro harvest.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_intelligence_map
- SOURCE COMMAND CENTER
- OPS Panel

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Harvest
- People Layer
- Media Layer
- Historical Layer
- Knowledge Graph

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Zakládá zdroje dat.
- Eviduje zdroje dat.
- Vyhodnocuje zdroje dat.

===============================================================================
VSTUP:
===============================================================================

- Provider audity
- Source discovery
- Ručně evidované zdroje

===============================================================================
VÝSTUP:
===============================================================================

- Source registry
- Source governance
- Harvest readiness

===============================================================================
BUDOUCÍ VYUŽITÍ:
===============================================================================

PEOPLE LAYER
MEDIA LAYER
KNOWLEDGE GRAPH
AI PREDICTIONS

===============================================================================
NÁVAZNOST:
===============================================================================

Předchází:
Audit zdrojů

Navazuje:
Seed zdrojů
Governance zdrojů
Panel zdrojů

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX
===============================================================================
*/
```

---

# ZAKLÁDACÍ ZÁPIS NOVÉ SEKCE

Před vytvořením nové hlavní sekce musí vzniknout zakládací dokument obsahující:

* proč sekce vzniká
* jaký problém řeší
* co bude obsahovat
* vazba na ostatní vrstvy
* navržené číslování
* budoucí rozšíření

---

# AKTUÁLNÍ STAV

Poslední založená hlavní sekce:

24_SOURCE INTELLIGENCE LAYER

Účel:

* Evidence zdrojů dat
* Evidence providerů
* Evidence fotografií
* Evidence historických zdrojů
* Evidence mediálních zdrojů
* Budoucí SOURCE COMMAND CENTER

---

# PRINCIP SOURCE INTELLIGENCE LAYER

Provider není zdroj.

Provider je pouze jeden z možných zdrojů.

MatchMatrix musí vědět:

* odkud data pochází
* jak kvalitní jsou
* jak hluboko sahá historie
* zda existují fotografie
* zda existují trenéři
* zda existují média
* zda existuje lepší alternativa

Tato vrstva bude dlouhodobě řídit:

* People Layer
* Media Layer
* Historical Layer
* Knowledge Graph
* AI Predikce
* Autonomní Harvest

---

# DOPLNĚNÍ: STRUKTURA SEKCE 24_SOURCE INTELLIGENCE LAYER

V rámci založení sekce 24 byla vytvořena pevná vnitřní struktura pro budoucí práci se zdroji dat.

## Hlavní sekce

24_SOURCE INTELLIGENCE LAYER

## Podsekce

24_1_MASTER SOURCE MAP

Účel:

* evidence všech známých zdrojů dat
* mapování zdrojů podle sportu a entity
* rozlišení kandidáta, ověřeného zdroje a aktivního zdroje

24_2_SOURCE MONITORING

Účel:

* průběžné sledování existujících zdrojů
* kontrola dostupnosti
* kontrola změn struktury webu/API
* kontrola změn robots.txt a podmínek použití

24_3_SOURCE COMMAND CENTER

Účel:

* budoucí panelová část pro řízení zdrojů
* přehled stavu zdrojů
* přehled otevřených discovery/review úkolů
* doporučení dalších kroků

24_4_SOURCE BUSINESS INTELLIGENCE

Účel:

* evidence placených a neplacených zdrojů
* evidence tarifů
* evidence cen
* evidence limitů
* evidence délky předplatného
* evidence množství requestů/dat
* vyhodnocení business přínosu a ROI

24_5_SOURCE GOVERNANCE

Účel:

* pravidla pro schvalování zdrojů
* pravidla pro vyřazování zdrojů
* evidence licencí
* evidence právních a robots kontrol
* řízení statusů DISCOVERY / CHECK_TERMS / VERIFIED / ACTIVE / BLOCKED

24_6_SOURCE DISCOVERY AUTOMATION

Účel:

* budoucí automatické hledání nových zdrojů
* automatická kontrola existujících zdrojů
* detekce nových endpointů, RSS, sitemap, archivů a sekcí webu
* návrh nových kandidátů do Source Map

---

# PRAVIDLO PRO SEKCI 24

Sekce 24 se neřídí pouze podle providerů.

Základní pravidlo:

ZDROJ JE NADŘAZENÝ PROVIDEROVI.

Provider je pouze jeden typ zdroje.

MatchMatrix musí evidovat:

* API providery
* oficiální ligové weby
* oficiální klubové weby
* federace
* svazy
* archivy
* Wikidata
* Wikimedia
* RSS
* sitemap
* media zdroje
* historické databáze
* placené profesionální feedy

---

# POVINNÝ OBCHODNÍ ROZSAH U ZDROJE

U každého zdroje se má postupně evidovat:

* zda je zdarma
* zda je placený
* zda existuje free trial
* jaké jsou tarify
* cena za měsíc
* cena za rok
* délka předplatného
* počet requestů za den
* počet requestů za měsíc
* rate limit
* historická hloubka
* pokrytí hráčů
* pokrytí trenérů
* pokrytí fotek
* pokrytí statistik
* pokrytí médií
* doporučený tarif
* business score
* ROI score

---

# CÍL SEKCE 24

Konečný cíl není pouze najít zdroje.

Konečný cíl je:

NAJÍT → OVĚŘIT → SCHVÁLIT → POUŽÍVAT → MONITOROVAT → PRŮBĚŽNĚ DOPLŇOVAT.

Každý sport musí postupně získat vlastní Source Map.

Příklad:

24_1_A = Handball Source Map
24_1_B = Hockey Source Map
24_1_C = Basketball Source Map
24_1_D = Baseball Source Map
24_1_E = American Football Source Map
24_1_F = Cricket Source Map
24_1_G = Tennis Source Map
24_1_H = Volleyball Source Map
24_1_I = Rugby Source Map
24_1_J = Field Hockey Source Map
24_1_K = MMA Source Map
24_1_L = Esports Source Map
24_1_M = Football Source Map

---


---

# KONEC DOKUMENTU
