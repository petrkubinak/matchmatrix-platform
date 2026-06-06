# MATCHMATRIX – SECOND PC HARVEST SERVER PLAN V1

## Cíl

Druhé PC bude sloužit jako výkonný harvest server pro masivní stahování dat od července 2026.

## Hlavní role druhého PC

- paralelní harvest dat
- historický backfill
- People pipeline
- media enrichment
- pomocné výpočty
- později možnost provozovat část scheduleru

## Minimální doporučení

- CPU: 12–16 jader
- RAM: 64 GB
- SSD/NVMe: 2 TB
- Windows 11 Pro
- stabilní LAN připojení
- Python 3.14
- Git
- VS Code
- Docker Desktop
- PostgreSQL klient
- DBeaver

## Doporučené rozdělení práce

### Hlavní PC

- PostgreSQL databáze
- OPS panel
- řízení scheduleru
- web vývoj
- kontrola výsledků

### Druhé PC

- API harvest
- People harvest
- media enrichment
- historical backfill
- batch workery

## Zásadní pravidlo

Druhé PC nesmí spouštět stejné joby naslepo.

Vše musí jít přes:

- ops.ingest_planner
- ops.worker_locks
- ops.scheduler_queue
- ops.project_milestones

## Co připravit před červencem

1. Git synchronizace projektu
2. `.env` konfigurace
3. přístup k PostgreSQL z druhého PC
4. test DB connection
5. test jednoho workeru
6. test lock systému
7. test batch harvestu
8. test logování do OPS

## Červencový režim

### Priorita 1

Football historical backfill

### Priorita 2

Hockey + Basketball

### Priorita 3

People layer

### Priorita 4

Ostatní sporty

## Bezpečnost

- žádné ruční duplicitní spouštění
- vše logovat
- každý worker musí zapisovat výsledek
- každá chyba musí jít do OPS/runtime logu
- žádný mazací skript bez potvrzení

## Stav

Milník v DB:

- SECOND_PC_READY
- plánované datum: 2026-06-15
- stav: PLANNED