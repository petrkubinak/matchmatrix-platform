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

# KONEC DOKUMENTU
