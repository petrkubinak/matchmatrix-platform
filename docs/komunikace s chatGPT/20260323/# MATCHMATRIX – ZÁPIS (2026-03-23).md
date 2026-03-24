# MATCHMATRIX – ZÁPIS (2026-03-23)

## Dnešní hlavní posun
Dnes jsme dotáhli přechod z funkční ingest pipeline na řízený bootstrap přes panel.

## Co je hotovo

### 1. Audit panel + system tree
- audit panel V7 nově generuje `latest_system_tree.txt`
- máme textový přehled DB stromu + stromu složek projektu
- odpadla nutnost posílat strukturu jen přes screenshoty

### 2. Panel V9
- panel nyní ukazuje všech 14 sportů z `public.sports`
- přidán scroll pro sporty
- přidán scroll pro entity
- sporty bez enabled targetů jsou označené `[NO TARGETS]`
- opraveno, aby panel skutečně předával parametry do `run_ingest_cycle_v3.py`

### 3. Bootstrap targetů
- proveden bezpečný bootstrap `ops.ingest_targets` ze stávajících `public.leagues` + `public.league_provider_map`
- následně povolen `FB_BOOTSTRAP_V1` pro `api_football`

### 4. Planner bootstrap
- vytvořeny planner joby pro:
  - provider = `api_football`
  - sport = `FB`
  - entity = `fixtures`
  - run_group = `FB_BOOTSTRAP_V1`

### 5. První reálné běhy
- první run přes PowerShell proběhl úspěšně
- následně potvrzen i běh přes panel V9
- panel už nyní skutečně spouští:
  - `run_ingest_cycle_v3.py`
  - s filtry `--provider api_football --sport FB --entity fixtures --run-group FB_BOOTSTRAP_V1`

### 6. Free mode cleanup
- unsupported providery vypnuty
- odds pro `api_football / FB` v free režimu vypnuty
- staré odds error joby převedeny na `skipped`

## Důležité technické závěry

### A. Backend funguje správně
Problém nebyl v `run_ingest_cycle_v3.py`, ale v panelu, který původně neposílal filtry.

### B. Bootstrap queue funguje
`FB_BOOTSTRAP_V1` se skutečně claimuje a zpracovává.

### C. Warning != chyba
U části lig vrací API `No fixtures returned`, což je v bootstrapu normální a neznamená rozbitou pipeline.

### D. Free režim musí mít vlastní provozní pravidla
Odds a nepodporované providery je potřeba držet vypnuté, ale architekturu ponechat připravenou na placený tarif.

## Aktuální stav systému
- ingest cycle V3 = OK
- panel V9 = OK
- audit panel V7 = OK
- bootstrap FB fixtures = běží
- odds free mode = vypnuto
- unsupported providery = vypnuto

## Co navazuje příště
Další logický krok je:
1. kontrola coverage výsledků bootstrapu
2. rozhodnutí, zda pokračovat:
   - FB teams bootstrap
   - players pipeline
   - nebo další podporovaný sport

## Poznámka
Aktuální číslování SQL migrací pokračuje od:
- `217+`