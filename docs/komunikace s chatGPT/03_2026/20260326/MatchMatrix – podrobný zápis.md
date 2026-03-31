MatchMatrix – podrobný zápis
1. Co jsme dnes skutečně dokončili

Dnes jsme dotáhli do funkčního stavu players pipeline pro football a zároveň jsme ji propojili do panelu V9, aby běžela neinteraktivně a stabilně.

Původní problém byl, že players větev byla rozbitá na více místech:

starý runner volal PowerShell script, který čekal na RunId,
parse wrapper mířil na špatný parser,
transitional pipeline používala psql kroky, které na Windows padaly,
season stats merge narážel na chybějící player_provider_map.

Tohle jsme postupně opravili a dostali do stavu, kdy panel V9 spouští plně funkční workflow.

2. Co bylo opraveno
A. Players fetch vrstva

Byl opraven run_players_fetch_only_v1.py, aby fungoval jako dlouhodobý stabilní wrapper:

umí batch mode bez parametrů pro panel,
umí single mode s parametry pro ruční spuštění,
interně volá pull_api_football_players_v5.py.

Tím odpadl problém s interaktivním RunId.

B. Players parse vrstva

Byl opraven run_players_parse_only_v1.py, aby už nevolal parser profiles, ale správně:

run_player_season_statistics_stage_parser_v1.py

Tím se season stats začaly plnit do:

staging.stg_provider_player_season_stats
C. Stage parser season stats

V parseru season stats byla opravena insert logika tak, aby byla idempotentní a nespadla na duplicitním business klíči.
Výsledek:

parser lze pouštět opakovaně,
staging se stabilně naplňuje.
D. Players public merge

Proběhlo doplnění:

public.players
public.player_provider_map

Tím zmizel hlavní problém:

skipped missing player
E. Transitional players pipeline

Byl přepsán run_players_pipeline_transitional_v1.py, aby:

nevolal starý interaktivní PowerShell,
nevolal psql,
používal jen ověřené Python workery:
fetch
bridge
public players merge
season stats parse
season stats public merge
F. Panel V9

Panel V9 byl přepojen tak, aby players tlačítko nepoužívalo starý full runner, ale nový:

run_players_pipeline_transitional_v1.py

Tím se players pipeline rozjela přímo z panelu.

3. Potvrzené výsledky z běhů

Po finálním běhu z panelu V9 pipeline doběhla správně.

Poslední potvrzený stav:
public.players: 1482
public.player_provider_map: 1484
staging.stg_provider_player_season_stats: 36890
public.player_season_statistics: 1060
Stav merge:
processed grouped rows: 1190
merged rows: 1190
skipped missing player: 0
skipped missing league: 0
skipped missing team: 34

To znamená:

pipeline je funkční,
hráčské mapování už funguje,
zbývá jen menší datová mezera v části team mapování.
4. Co jsme zjistili u coaches

Začali jsme připravovat trenéry, protože dlouhodobý směr projektu je jasný:

hráči,
týmy,
trenéři,
historie,
a vazby mezi nimi.
Co bylo vytvořeno

Byla vytvořena tabulka:

public.team_coach_history

To je důležitý základ pro budoucí:

coach rating,
historii trenérů,
vazbu hráč ↔ trenér přes tým a čas.
Co jsme zjistili ve stagingu

staging.stg_provider_coaches má dobrou strukturu a obsahuje vše potřebné:

external_coach_id
team_external_id
league_external_id
season
source_endpoint
raw_payload_id

Takže staging model pro trenéry je použitelný.

Co jsme ověřili

Aktuální stav coaches dat byl:

staging.stg_provider_coaches = 0
public.coaches = 0
public.coach_provider_map = 0

Tedy u trenérů zatím nejsou stažená reálná data.

Hockey coaches test

Byl postaven a rozběhnut první api_hockey coaches pull script. Technicky se podařilo:

načíst planner job,
složit URL,
uložit payload do staging.stg_api_payloads.

Ale reálný payload ukázal, že hockey endpoint:

coachs
vrací:
"This endpoint do not exist."

Tedy:

HK coaches endpoint u tohoto providera neexistuje
problém není v našem scriptu, ale ve zdroji dat
5. Klíčové architektonické pochopení projektu

Důležité bylo dnes vyjasnit, že cílem není jen football nebo jen predikce.

Cílem MatchMatrix je velká sportovní databáze s více vrstvami. To sedí i na původní blueprint projektu, kde MatchMatrix není jen predikční systém, ale sportovní datová a analytická platforma s databází, ratingy, ML a Ticket Engine.

Dvě hlavní vrstvy
A. Core vrstva – dlouhá historie

Tady chceme až desítky let historie:

sporty
země
ligy
týmy
hráče
trenéry
historie hráčů v týmech
historie trenérů u týmů
identity a provider mapy
B. Match / analytics vrstva

Tady stačí menší horizont:

zápasy
odds
lineups
match events
player season stats
team season stats
injuries

Tohle je důležité pro:

MMR
ML
Ticket Engine
6. Co jsme si definitivně ujasnili jako budoucí směr

Dnes padlo důležité rozhodnutí:

Teď nepůjdeme primárně po coaches

Místo toho je lepší:

nejdřív dojet players pro další sporty

a teprve potom:

coaches

To je správně, protože:

hráči mají větší databázovou hodnotu pro fanoušky,
jsou základ pro historii, profily a vazby,
coach vrstva má největší smysl až nad hotovými:
players
teams
player_team_history

Jinými slovy:
nejdřív vybudujeme person core napříč sporty, a až potom na to nasadíme trenéry jako vyšší vrstvu.

7. Doporučený další směr
Priorita 1

Rozjet players pipeline pro další sporty

Pořadí:

HK
BK
VB

Důvod:

tyto sporty už máš v projektu nejvíc rozjeté,
máš tam planner logiku,
budou se dobře napojovat na současný model.
Priorita 2

Po multi-sport players rollout:

vrátit se k coaches

Ale už chytře:

tam, kde provider endpoint opravdu existuje,
nebo přes jiný zdroj dat.
Priorita 3

Jakmile budou hráči a týmy multi-sport:

rozšiřovat player_team_history
řešit derived vztahy
připravovat budoucí rating:
coach rating
player development rating
8. Co přesně budeme dělat příště
Nejbližší pokračování

Nepůjdeme dál v hockey coaches, protože endpoint neexistuje.

Příště pojedeme:

multi-sport players rollout

a vybereme si jeden sport jako další referenční implementaci.

Doporučené pořadí:

HK players
BK players
VB players
Praktický cíl dalšího dne

Pro vybraný sport:

ověřit planner a existující ingest
rozjet fetch
staging
provider map
public players
season stats, pokud endpoint existuje
9. Stav projektu po dnešku jednou větou

Po dnešku máš:

stabilní football players pipeline v panelu V9
hotový základ pro team_coach_history
potvrzeno, že api_hockey coaches endpoint neexistuje
a jasně určený další směr:
nejdřív players pro další sporty, potom coaches
10. Doporučený start příště

Až navážeme, nejlepší start bude:

„jedeme HK players“
nebo
„jedeme BK players“
nebo
„jedeme VB players“

Podle toho hned vezmeme jeden sport a pojedeme zase po jedné akci.