# MATCHMATRIX PROJECT STRUCTURE GOVERNANCE

## 1. Stav DB governance

Hotovo:

- OPS views: 214/214
- OPS tables: 59/59
- PUBLIC tables: 129/129
- PUBLIC views: 100/100
- STAGING objects: 35/35

Celkem DB objektů auditováno: 537

## 2. Hlavní složky projektu

| Složka | Počet souborů | Stav | Poznámka |
|---|---:|---|---|
| fronted | 21823 | ACTIVE_REVIEW | Obsahuje node_modules/.next; reálný zdrojový kód cca 35 souborů |
| db | 1758 | ACTIVE_MASTER | SQL migrace, audity, databázová dokumentace |
| reports | 845 | ACTIVE | Výstupy auditů/reportů |
| docs | 394 | ACTIVE_MASTER | Projektová dokumentace |
| tools | 177 | ACTIVE_MASTER | Panely a lokální nástroje |
| ingest | 133 | ACTIVE_MASTER | Provider ingest skripty |
| workers | 130 | ACTIVE_MASTER | Backend workeři |
| logs | 85 | ACTIVE_REVIEW | Runtime/provozní logy |
| legacy | 26 | LEGACY_KEEP | Historické soubory |
| ops_admin | 24 | ACTIVE | Admin nástroje OPS |
| programs | 15 | ACTIVE_REVIEW | Pomocné programy |
| ops | 14 | ACTIVE | OPS podpůrná vrstva |
| data | 10 | ACTIVE | Lokální data |
| runtime_logs | 9 | ACTIVE_REVIEW | Runtime logy |
| system | 5 | ACTIVE | Systémové skripty |
| infra | 1 | ACTIVE_MASTER | Docker/infra konfigurace |
| backups | 1 | ACTIVE_REVIEW | Zálohy |
| launchers | 0 | ACTIVE_REVIEW | Připravená složka pro spouštěče |

## 3. Frontend realita

Složka `fronted` má 21 823 souborů hlavně kvůli:

- node_modules
- .next
- build/cache souborům

Reálný frontend zdroj:

- app/api/*
- app/page.tsx
- app/layout.tsx
- app/globals.css
- app/lib/db.ts
- components/*
- package.json
- config soubory

## 4. Backend realita

Workers:

- 122 Python workerů
- hlavní domény:
  - core
  - media
  - people
  - odds
  - ops
  - parsers
  - schedulers
  - planners
  - quality
  - diagnostics
  - experimental
  - archive

## 5. Projektové pravidlo od této chvíle

Každý nový objekt musí mít:

- název
- složku
- účel
- vstup
- výstup
- napojení na DB
- governance status

## 6. Hlavní cíl

Cílem governance není mazat hned.

Cílem je bezpečně vědět:

- co je MASTER
- co je ACTIVE
- co je REVIEW
- co je LEGACY
- co je kandidát na DROP
- co používá web
- co používá scheduler
- co používá panel
- co bude součástí produkční verze pro platící uživatele

## 7. Další kroky

1. Worker governance katalog
2. Ingest governance katalog
3. Tools/panel governance katalog
4. Frontend governance katalog
5. Dependency mapa: web → views → tables
6. Release readiness mapa