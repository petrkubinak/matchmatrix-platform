# MATCHMATRIX – ZÁPIS PRÁCE

## TEAM DEDUP PHASE 17_8 – DOKONČENO

Datum: 2026-06-07

---

# CO TO JE

První kompletní deduplikační a čisticí vlna nad tabulkou:

```text
public.teams
```

Cílem bylo odstranit historické duplicity vzniklé při postupném napojování providerů:

* api_football
* api_sport
* api_hockey
* football_data
* football_data_uk
* api_football_missing_canonical

a zároveň zachovat všechny důležité vazby.

---

# K ČEMU TO JE

Vyčištění hlavní tabulky týmů před:

* People Layer
* Odds Layer
* Media Layer
* Team Rating Engine
* Match Predictions
* Ticket Engine
* Web aplikací

Bez deduplikace by docházelo k:

* rozdělení statistik mezi více týmů
* chybným ratingům
* špatnému mapování hráčů
* duplicitním kartám týmů na webu
* problémům při napojení dalších providerů

---

# PROVEDENÉ KROKY

## 17_8_A

TEAM DUPLICATE AUDIT

Audit všech duplicitních týmů.

---

## 17_8_B

MASTER TEAM SELECTION

Výběr hlavního (MASTER) týmu.

---

## 17_8_C

MERGE CLASSIFICATION

Rozdělení týmů na:

```text
MASTER_KEEP
SAFE_LOW_USAGE_MERGE
SAFE_PROVIDER_MAP_MERGE
RISK_HAS_MATCHES
HOLD_NATIONAL_OR_YOUTH_TEAM
```

---

## 17_8_D

NATIONAL TEAM AUDIT

Oddělení reprezentací a mládežnických reprezentací.

Automatické slučování reprezentací bylo zakázáno.

---

## 17_8_E

SAFE MERGE PLAN

Příprava bezpečného merge plánu.

---

## 17_8_F

SAFE EXECUTION PLAN

Kontrola vazeb:

```text
matches
articles
provider maps
players
player statistics
aliases
league standings
```

---

## 17_8_G

SAFE DELETE

První vlna odstranění duplicit.

Výsledek:

```text
361 týmů odstraněno
```

---

## 17_8_H

PROVIDER MAP AUDIT

Audit provider map.

Výsledek:

```text
148 bezpečných kandidátů
```

---

## 17_8_I

PROVIDER MAP EXECUTION PLAN

Příprava přesunu provider map.

---

## 17_8_J

PROVIDER MAP MOVE

Přesun provider map na MASTER týmy.

Výsledek:

```text
148 provider map přesunuto
```

---

## 17_8_K

RECALCULATION

Přepočet po provider merge.

---

## 17_8_L

HOLD DEPENDENCY DETAIL AUDIT

Audit posledních blokací.

Výsledek:

```text
46 hráčů
2 league standings
```

---

## 17_8_M

PLAYER MOVE PLAN

Příprava přesunu hráčů.

Výsledek:

```text
46 hráčů připraveno
```

---

## 17_8_N

PLAYER MOVE EXECUTION

Přesun hráčů na MASTER týmy.

Výsledek:

```text
46 hráčů přesunuto
```

---

## 17_8_O

FINAL DELETE

Druhá vlna odstranění duplicit.

Výsledek:

```text
135 týmů odstraněno
```

---

# CELKOVÝ VÝSLEDEK

## Odstraněné týmy

```text
361
+
135
=
496 týmů
```

---

## Přesunuté provider mapy

```text
148
```

---

## Přesunutí hráči

```text
46
```

---

## Zbývající blokace

```text
1 tým
```

---

# POSLEDNÍ HOLD

```text
Keshla FC
```

Důvod:

```text
league_standings
```

Tým nebyl odstraněn.

Systém jej správně označil jako:

```text
HOLD_DEPENDENCY
```

---

# STAV PO DEDUPLIKACI

```text
MASTER_KEEP                     563
RISK_HAS_MATCHES                392
HOLD_NATIONAL_OR_YOUTH_TEAM     162
SAFE_PROVIDER_MAP_MERGE           3
HOLD_PROVIDER_ID_CONFLICT         2
HOLD_NO_SPORT_ID                  1
HOLD_DEPENDENCY                   1
```

---

# KDE TO UVIDÍME

## Databáze

```text
public.teams
public.players
public.team_provider_map
```

---

## OPS Panel

```text
OPS -> TEAM DEDUP
OPS -> DATA QUALITY
OPS -> CLEANUP
```

---

# JAK SE TO VYUŽIJE

Vyčištěná databáze bude sloužit pro:

```text
People Layer
Media Layer
Odds Layer
Predictions
Ticket Engine
Team Ratings
Player Ratings
Web aplikaci
Mobilní aplikaci
```

a především:

```text
správné mapování budoucích providerů
```

---

# DALŠÍ KROK

Nová etapa:

```text
17_9 TEAM DUPLICATE PREVENTION
```

Cíl:

```text
zabránit vzniku nových duplicit
```

Namísto dalšího čištění budeme budovat ochranu:

```text
Provider Guard
Alias Guard
Canonical Guard
Insert Protection
Duplicate Monitoring
```

tak, aby se podobná situace již neopakovala.

---

# MILESTONE

```text
MATCHMATRIX MILESTONE

TEAM DEDUP PHASE 17_8
STATUS: COMPLETED

496 týmů odstraněno
148 provider map přesunuto
46 hráčů přesunuto

Databáze public.teams výrazně vyčištěna.
Připraveno pro Team Duplicate Prevention (17_9).

17_9 TEAM DUPLICATE PREVENTION – DOKONČENO
CO TO JE

Vrstva ochrany proti vzniku nových duplicitních týmů při ingestu dat z providerů.

K ČEMU TO JE

Zabraňuje opětovnému vytváření duplicit v:

public.teams
team_provider_map
team_aliases

při budoucím stahování dat z:

api_football
api_sport
api_hockey
football_data
budoucí PRO providery
PROVEDENÉ KROKY
17_9_A Audit .................. DONE
17_9_B Canonical Audit ........ DONE
17_9_C Merge Candidates ....... DONE
17_9_D Missing Canonical Plan . DONE
17_9_E Reference Audit ........ DONE
17_9_F Missing Canonical Merge  DONE
17_9_G Arsenal Duplicate ...... DONE
17_9_H Review Hold ............ DONE
17_9_I Dashboard .............. DONE
17_9_J Insert Guard ........... DONE
17_9_K Guard Summary .......... DONE
FINÁLNÍ STAV
CRITICAL = 0
HIGH     = 7
MEDIUM   = 84
LOW      = 352

STATUS = CONTROLLED_HOLD
GOVERNANCE STATUS
TEAM_DUPLICATE_PREVENTION = READY
TEAM_CANONICAL_CLEANUP    = READY
TEAM_INSERT_GUARD         = ACTIVE
KDE TO UVIDÍME

OPS Panel:

OPS → TEAM DEDUP
OPS → DATA QUALITY
OPS → GOVERNANCE
OPS → INGEST HEALTH
JAK SE TO VYUŽIJE

Při každém budoucím ingestu:

Provider
    ↓
Provider Guard
    ↓
Canonical Guard
    ↓
Alias Guard
    ↓
Insert Guard
    ↓
public.teams

Nový tým se vytvoří pouze tehdy, pokud skutečně neexistuje.

AKTUÁLNÍ STAV TEAM LAYER

Po 17_8 + 17_9:

TEAM DEDUP ................. READY
TEAM CANONICAL ............. READY
TEAM INSERT GUARD .......... ACTIVE
TEAM GOVERNANCE ............ READY

Týmová vrstva je nyní na úrovni, kdy můžeš bez větších obav pokračovat ve velkých backfillech a později i v PRO harvestu.

DOPORUČENÝ DALŠÍ BLOK

Souhlasím s návrhem:

18_A PLAYER IDENTITY GOVERNANCE

Protože podle celé strategie MatchMatrix:

Hráči = základ People Layer
People Layer = základ statistik
Statistiky = základ predikcí
Predikce = základ Ticket Engine

Až připojíš další providery (SportsDataIO, PRO API-Football, další sporty), největší riziko duplicit už nebude u týmů, ale u hráčů.

Navrhovaná série:

18_A Player Identity Audit
18_B Player Canonical Audit
18_C Player Duplicate Detection
18_D Player Alias Governance
18_E Player Provider Identity Map
18_F Player Merge Candidates
18_G Player Duplicate Prevention Guard
18_H Player Governance Dashboard

To by byla přirozená návaznost na dokončenou Team Governance vrstvu.
```
