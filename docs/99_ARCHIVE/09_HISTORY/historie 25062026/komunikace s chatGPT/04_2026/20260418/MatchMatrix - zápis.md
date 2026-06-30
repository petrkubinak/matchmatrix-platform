Perfektní, dnes jsme API-Házená (HB) dotáhli velmi daleko. Tady máš navazovací zápis pro zítřejší chat.

ZÁPIS – API-HÁZENÁ (HB)
Co jsme dnes dokončili
1. HB leagues
api_handball leagues jsme rozchodili end-to-end.
Opravili jsme parser podle skutečné struktury HB payloadu.
staging.stg_provider_leagues se plní správně.
Potvrzené příklady:
183 African Championship
131 Champions League
145 EHF European League
atd.
Výstup je rozpadnutý po sezonách a funguje korektně.
2. HB teams
Zjistili jsme, že původní provider_league_id = EHF je pro teams špatně.
Pro smoke test jsme opravili target na:
provider_league_id = 131
season = 2024
Po opravě začal teams endpoint vracet data.
staging.stg_provider_teams se naplnil správně.
Potvrzené týmy:
Aalborg
Barcelona
Din. Bucuresti
Eurofarm Pelister
Fredericia
Fuchse Berlin
Kielce
Kolstad
Nantes
PSG
RK Zagreb
SC Magdeburg
Sporting
Szeged
Veszprem
Wisla Plock
3. HB fixtures
Objevili jsme 2 klíčové věci:
pro handball není správný endpoint fixtures, ale games
pro handball fixtures nesmíme používat from/to, protože to v našem testu vracelo 0 výsledků
Opravili jsme shared soubor:
C:\MatchMatrix-platform\ingest\API-Sport\pull_api_sport_fixtures.ps1
Doplnili jsme:
handball -> games
auto-spuštění parseru run_parse_api_sport_fixtures_v1.py
Ručně jsme ověřili, že:
league=131
season=2024
bez from/to
vrací Results: 132
Parser fixtures jsme spustili ručně a následně i přes binding.
staging.stg_provider_fixtures je teď naplněné.
Potvrzený stav v DB
staging.stg_provider_fixtures
count = 132
příklady řádků:
164635 | 131 | 2024 | 4484 vs 694 | 2025-02-13 | FT | 28:31
164636 | 131 | 2024 | 791 vs 1157 | 2025-02-13 | FT | 30:24
164553 | 131 | 2024 | 172 vs 257 | 2024-09-11 | FT | 38:31
to potvrzuje, že HB fixtures staging parse funguje.
Aktuální stav HB
HB core pipeline je funkční
HB leagues ✅
HB teams ✅
HB fixtures ✅
Důležité technické poznámky
Opravené soubory
1.

C:\MatchMatrix-platform\ingest\API-Sport\pull_api_sport_fixtures.ps1

Co je tam důležité:

handball používá endpoint games
po raw insertu se automaticky spouští:
C:\MatchMatrix-platform\workers\run_parse_api_sport_fixtures_v1.py
2.

C:\MatchMatrix-platform\workers\run_parse_api_sport_fixtures_v1.py

parser existuje
čte staging.stg_api_payloads
bere entity_type = 'fixtures'
parseuje pending
upsertuje do staging.stg_provider_fixtures
pak přepíná payload na processed
3.

HB smoke test target
Aktuálně je ops.ingest_targets pro HB nastavený takto:

provider = api_handball
sport_code = HB
provider_league_id = 131
season = 2024

To je jen smoke test setup, ne finální HB coverage.

Co je potřeba zítra
Další logický krok

Zítra už nepokračujeme opravou HB core, to je hotové.

Budeme řešit:

Varianta A – dokončení HB do runtime audit vrstvy
zapsat HB leagues / teams / fixtures do runtime_entity_audit
přepnout z PLANNED / RUNNABLE na odpovídající stav
nejspíš minimálně:
leagues = CONFIRMED
teams = CONFIRMED
fixtures = CONFIRMED nebo PARTIAL/CONFIRMED podle požadované přísnosti
Varianta B – rozšíření HB targetů
teď máme otestovanou 1 soutěž (131)
další krok bude přidat více konkrétních HB soutěží místo obecného EHF
typicky:
131 Champions League
145 EHF European League
případně další podle priority