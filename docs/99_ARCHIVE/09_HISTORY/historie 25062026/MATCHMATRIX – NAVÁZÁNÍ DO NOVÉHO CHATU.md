MATCHMATRIX – NAVÁZÁNÍ DO NOVÉHO CHATU

Datum: 22.06.2026
Stav: Infrastruktura dokončena, návrat k databázi a přípravě velkého harvestu.

1. INFRASTRUKTURA – DOKONČENO
PC2 – MATCHMATRIX SERVER
Hardware
CPU: Intel Core Ultra 9 285K
RAM: 64 GB DDR5
SSD: 2× Samsung 990 Pro 2 TB
OS: Windows 11
Serverové služby
Docker Desktop
PostgreSQL 16
Redis 7
Ověřeno

✅ Automatické zapnutí po výpadku proudu

BIOS:
Restore After AC Power Loss = Last State

✅ Automatické přihlášení Windows

✅ Automatické spuštění Docker Desktop

✅ Automatické spuštění PostgreSQL

✅ Automatické spuštění Redis

PC1 – MATCHMATRIX OPS
Ověřeno

✅ AutoLogin Windows nastaven

✅ DBeaver funkční

✅ VS Code funkční

✅ SSH na PC2 funkční

2. SÍŤ
DHCP rezervace DECO
PC2
Hostname: MatchMatrix
IP: 192.168.3.119
PC1
Hostname: MATCHMATRIX-OPS
IP: 192.168.3.111

Rezervace potvrzeny.

3. DOCKER

Aktuální kontejnery:

matchmatrix_postgres
STATUS = healthy

matchmatrix_redis
STATUS = healthy

Ověřeno po restartu.

4. STAV PROJEKTU MATCHMATRIX
Infrastruktura
STATUS = READY
COMPLETION = 100 %

Serverová část je připravena.

Není potřeba dále řešit:

BIOS
AutoLogin
Docker autostart
Redis
PostgreSQL
DHCP rezervace
5. KDE JSME SKONČILI V MATCHMATRIX

Vracíme se zpět k hlavnímu cíli:

PŘIPRAVIT DATABÁZI NA VELKÝ HARVEST DAT

Nejdříve chceme mít jistotu, že databáze je čistá, governance dokončená a všechny vrstvy připravené.

6. PRVNÍ ÚKOL V NOVÉM CHATU
AUDIT DATABÁZE PŘED HARVESTEM

Potřebujeme zkontrolovat:

Core Layer
sports
countries
leagues
seasons
teams
venues
matches
People Layer
players
coaches
player_provider_map
player_external_identity
photos
profiles
Media Layer
articles
article_team_map
article_player_map
Odds Layer
bookmakers
markets
odds
Governance
duplicate prevention
identity governance
provider mapping
canonical leagues
canonical teams
7. CÍL DALŠÍ FÁZE

Před spuštěním velkých harvestů chceme znát:

READY
PARTIAL
DATA_GAP
BLOCKED

pro každý sport.

8. PRIORITY SPORTŮ
Nejvyšší priorita
FB Football
HK Hockey
BK Basketball
VB Volleyball
HB Handball
BSB Baseball
CK Cricket
AFB American Football
9. DALŠÍ KROK PO OTEVŘENÍ NOVÉHO CHATU

Začni přesně touto větou:

MATCHMATRIX – pokračujeme po dokončení serverové infrastruktury.
Potřebujeme udělat kompletní audit databáze před velkým harvestem dat.

A navážeme rovnou na databázi, DBeaver a SQL audit bez dalšího řešení infrastruktury.

DNEŠNÍ VÝSLEDEK
PC2 SERVER 24/7 = HOTOVO
PC1 OPS = HOTOVO
DOCKER = HOTOVO
POSTGRESQL = HOTOVO
REDIS = HOTOVO
DHCP REZERVACE = HOTOVO

DALŠÍ FÁZE:
DOTAŽENÍ DATABÁZE PŘED VELKÝM HARVESTEM DAT

🚀 Zítra už se soustředíme čistě na MatchMatrix data, governance a harvest připravenost.