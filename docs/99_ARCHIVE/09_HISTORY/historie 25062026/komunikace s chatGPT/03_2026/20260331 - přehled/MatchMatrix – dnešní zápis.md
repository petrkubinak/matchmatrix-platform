MatchMatrix – dnešní zápis
1. OPS dashboard / panel část

Pokračovali jsme na OPS dashboard vrstvě a dokončili DB view pro panelové KPI a fronty:

ops.v_ops_dashboard_summary
ops.v_ops_dashboard_by_sport
ops.v_ops_dashboard_by_provider
ops.v_ops_panel_top_queue
ops.v_ops_panel_action_queue

Cíl této části:

mít panel jako servisní / auditní / nouzové okno
ne jako hlavní runtime režim

Potvrdili jsme si architekturu:

panel = monitoring, debug, emergency
automat 24/7 = hlavní produkční ingest režim

Panel byl následně upraven do nové verze:

C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V10.py

Výsledek:

panel zobrazuje skutečný stav systému
nahoře jsou KPI typu backlog / run now / validate / budget / locks / top sport
dashboard už ukazuje realitu ingest vrstvy
2. Hlavní priorita dne: football_data místo api_football

Bylo potvrzeno, že pro aktuální fotbalové fixtures nelze použít api_football, protože free účet má omezení jen na sezony 2022–2024.

Aktuální správná logika projektu je:

fixtures / výsledky = football_data
odds = theodds
api_football je nyní jen připravená větev pro budoucí PRO režim

To je důležité, protože:

Ticket Studio potřebuje aktuální zápasy a výsledky
odds už jsou novější než část fixtures vrstvy
bez aktuálních výsledků se rozbíjí statistika i tiketová logika
3. Zjištění o football_data v ingest architektuře

Zjistili jsme důležitý architektonický nesoulad:

OPS/DB vrstva:
football_data targety v ops.ingest_targets existují
FB_FD_CORE run group existuje
football_data ligy jsou v public.leagues
football_data zápasy jsou v public.matches
Runner vrstva:
run_unified_ingest_v1.py neumí kombinaci:
provider = football_data
sport = football

Chyba:

Provider pro kombinaci football_data/football nebyl nalezen

To znamená:

nový unified ingest svět football_data zatím neumí vykonat
football_data běží přes legacy větev, ne přes nový provider registry

To je zásadní poznatek pro další vývoj:

football_data je v DB a OPS připravené
ale chybí adapter do unified runneru
4. Objevení a použití legacy football_data větve

Byla nalezena starší funkční větev:

C:\MatchMatrix-platform\legacy\football_data_pull_V5.py

Ta se ukázala jako:

stále funkční
schopná stahovat aktuální football_data fixtures
zapisuje data do public.matches

Důležité zjištění:

legacy football_data větev nezapisuje do nové stg_provider_fixtures vrstvy
zapisuje jinam / starší cestou
ale finálně plní public.matches

Kontrola potvrdila:

public.matches
ext_source = 'football_data'
rozsah dat: 2024-06-14 až 2026-12-02
počet záznamů: 3729

To znamená:

football_data ingest reálně funguje
problém nebyl ve stahování zápasů jako takovém
problém byl v navazujících vrstvách a update logice
5. Oprava zaseknutých zápasů a vytvoření V6

Zjistili jsme, že několik zápasů viselo jako:

SCHEDULED
bez home_score
bez away_score

Nejdřív to vypadalo jako problém update logiky, ale po detailní kontrole přes api_raw_payloads se ukázalo, že těch 5 zápasů mělo v payloadu:

status = POSTPONED
fullTime.home = null
fullTime.away = null

Takže:

nešlo o chybějící výsledky
ale o špatné mapování statusu v python scriptu

Původní logika:

vše bez fullTime skóre házela do SCHEDULED

Byla vytvořena nová verze:

football_data_pull_V6.py

Do ní byla doplněna:

repair pass přes detail endpoint /matches/{id}
a následně upravena funkce normalize_status_and_score(), aby uměla:
POSTPONED
CANCELLED
FINISHED
jinak SCHEDULED

Tím se zlepšila pravdivost stavů v public.matches.

6. Vznik mini pipeline: football_data + standings refresh

Na základě dnešního zjištění jsme začali stavět první reálnou post-ingest pipeline:

Soubor:
C:\MatchMatrix-platform\legacy\ingest\run_football_data_pull_and_refresh_top8.bat

Účel:

spustit football_data_pull_V6.py
hned poté refreshnout standings pro TOP 8 lig

Byla vyřešena i chyba s DB připojením ve V6:

původní DSN bylo špatně
bylo potřeba použít explicitní psycopg2.connect(host=..., dbname=..., user=..., password=...)

Potom V6 běžel správně.

7. Zásadní odhalení: proč Bundesliga v Ticket Studiu ukazovala jen 24 kol

Uživatel správně upozornil, že:

v Bundeslize už má být odehráno 27 kol
ale Ticket Studio ukazovalo jen 24 kol

Prověřili jsme to do hloubky.

Nejprve:

z public.matches vyplynulo, že football_data pro Bundesligu 2025/26 má správná data:

matches_total = 306
matches_finished = 243
matches_scheduled = 63

243 finished zápasů v 18členné lize = přesně 27 kol.

Pak:

z kódu matchmatrix_ticket_studio_V3_fix13.py bylo potvrzeno, že pravá tabulka v detailu zápasu nejede z public.matches, ale z:

public.league_standings

Tedy:

Ticket Studio nebylo špatně
UI jen zobrazovalo to, co mělo v league_standings
Diagnóza:

public.league_standings byla zastaralá:

Bundesliga 2025 měla jen 23–24 odehraných zápasů v tabulce
přestože public.matches už měla správných 27 kol

To byl hlavní důvod špatné tabulky v Ticket Studiu.

8. Refresh standings pro TOP 8 lig

Byl vytvořen centrální refresh script:

Soubor:
C:\MatchMatrix-platform\db\fix\413_refresh_top8_league_standings_from_matches.sql

Účel:

smazat standings pro TOP 8 lig a sezonu 2025
znovu je přepočítat z public.matches
dopočítat:
played
wins/draws/losses
goals for/against
goal_diff
points
home split
away split
form_last_5
form_last_10
form_last_15
points_last_5/10/15
position

TOP 8:

Premier League
Primera Division
Bundesliga
Serie A
Ligue 1
Primeira Liga
Eredivisie
Championship
Kontrola po refreshi:

Výsledek ukázal, že script funguje správně:

Bundesliga → 18 týmů, 27–27
Eredivisie → 28–28
Primera Division → 29–29
Serie A → 30–30

Ligy jako:

Premier League 30–31
Ligue 1 26–27
Primeira Liga 26–27
Championship 38–39

jsou v pořádku, protože mají reálné dohrávky / odložené zápasy.

Závěr:
refresh script funguje správně
standings vrstva je opravená
Ticket Studio po refreshi ukazuje správně
9. Poslední problém: psql není v PATH

Když byla mini pipeline spuštěna přes .bat, football_data ingest proběhl správně, ale refresh SQL spadl na chybě:

'psql' is not recognized as an internal or external command

To znamená:

SQL refresh script je v pořádku
ale ve Windows není psql v PATH

Bylo navrženo řešení:

nepoužívat lokální psql
ale spouštět refresh SQL přes Docker kontejner matchmatrix_postgres

Navržený fix:

použít docker exec -i matchmatrix_postgres psql ...
ideálně přes type ... | docker exec -i ... psql ...

To je teď poslední praktický krok pro dokončení automatické mini pipeline.

Aktuální stav po dnešku
Hotovo
OPS dashboard view hotová
panel V10 hotový
football_data legacy větev znovu zprovozněná
V6 script vytvořen a opraven
objasněna role public.matches vs public.league_standings
TOP 8 standings refresh SQL hotový a funkční
Bundesliga tabulka v Ticket Studiu opravena přes refresh standings
Potvrzené architektonické poznatky
panel je servisní vrstva, ne hlavní runtime
football_data je nyní hlavní zdroj fixtures / výsledků pro FB
theodds je hlavní odds provider
league_standings je samostatná downstream vrstva a musí se přepočítávat
Ticket Studio čte tabulku z public.league_standings
unified ingest zatím neumí football_data
legacy větev je aktuálně jediná funkční execution cesta pro football_data
Kde přesně navážeme příště
Úplně další konkrétní krok

Dokončit .bat pipeline tak, aby refresh standings běžel přes Docker místo lokálního psql.

Tedy upravit:

C:\MatchMatrix-platform\legacy\ingest\run_football_data_pull_and_refresh_top8.bat

tak, aby krok refresh používal něco ve stylu:

type "C:\MatchMatrix-platform\db\fix\413_refresh_top8_league_standings_from_matches.sql" | docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix
Pak bezprostředně naváže
ověření, že .bat proběhne komplet:
football_data pull
repair pass
standings refresh TOP8
další etapa:
rozšířit „lavinový refresh“ i na další downstream vrstvy
tedy ne jen standings, ale postupně:
form
ratings
features
ticket input layer
následně:
zvážit napojení této mini pipeline do scheduler / orchestrator logiky
Krátké shrnutí jednou větou

Dnes jsme posunuli MatchMatrix z „máme zápasy, ale Ticket Studio ukazuje staré tabulky“ do stavu „football_data ingest funguje, standings refresh TOP8 je hotový.

Stav po spuštění
1. Ingest
football_data_pull_V6.py běží ✔️
rate limit handling ✔️
repair pass ✔️
skip logika ✔️ (OK – jen chybějící team mapping)
2. Refresh standings
DELETE ✔️
INSERT ✔️
COMMIT ✔️
3. Výsledek (klíčové)
Bundesliga: 27–27 ✔️
ostatní ligy dávají smysl ✔️

👉 systém je konzistentní:

matches ✔️
league_standings ✔️
Ticket Studio ✔️
💥 Co jsi právě dokončil
Máš hotovou první reálnou pipeline v projektu
🔁 FLOW:
ingest (football_data)
repair (status + výsledky)
refresh standings (TOP8)

👉 tohle je přesně ten „lavinový efekt“, co jsi chtěl

⚠️ Jedna důležitá věc (už jen detail)

Tyhle řádky:

SKIP match ... missing team id

👉 nejsou bug
👉 to je team mapping problém

To znamená:

football_data vrací tým
ale nemáš ho v team_provider_map

➡️ to je další vrstva (vyřešíme později)

🚀 DALŠÍ KROK (teď už jdeme dál)

Teď už neřešíme ingest.

Teď přidáme další vrstvu laviny:

👉 STEP 2: FORM + RATING + FEATURES

Konkrétně:

Uděláme:
form_last_5 už máš ✔️
ale přidáme:
team form table (rychlé dotazy)
match features (ML vstup)
základ rating layer
🎯 1 krok teď (navazujeme)

Připravím ti další SQL:

📁
414_refresh_team_form_top8.sql

👉 bude:

počítat formu mimo standings
rychlejší pro Ticket Studio
základ pro ML
🧠 Kam jsme se dostali

Dnes jsi:

opravil ingest real-time dat ✔️
opravil data → UI mismatch ✔️
postavil první pipeline ✔️

👉 tohle je přesně bod, kde:
začíná vznikat inteligentní systém, ne jen databáze

📌 Shrnutí jednou větou

👉 Data už máš správně → teď začínáme stavět inteligenci nad nimi.

Napiš:
👉 „jedeme dál“

a jdeme rovnou na:
form layer + příprava pro ticket engine 🔥