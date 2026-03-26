MatchMatrix – zápis dnešního postupu
1. Co jsme dnes řešili

Hlavní cíl byl ověřit a stabilizovat multi-sport ingest pipeline pro teams, konkrétně pro:

VB / volleyball
BK / basketball
HK / hockey

Současně jsme řešili, aby scheduler nejel jen:

INGEST → MERGE

ale správně:

INGEST → PARSER → MERGE

To odpovídá cílové ingest architektuře projektu MatchMatrix, kde se nejdřív ukládá RAW payload, potom se parsuje do stagingu a teprve potom mergeuje do public vrstvy. To je v souladu s celkovým blueprintem projektu.

2. Co je dnes hotové
A. Scheduler byl rozšířen o parser krok

Do run_ingest_cycle_v3.py byl doplněn mezikrok:

STEP 1C - PARSE API SPORT TEAMS

Tím se pipeline posunula na správný tvar:

STEP 1 – planner worker
STEP 1B – extract teams from fixtures raw
STEP 1C – parse API sport teams
STEP 2 – staging to public merge

To znamená, že parser už není ruční mezikrok, ale je součástí automatického běhu scheduleru.

B. Volleyball (VB) – teams flow funguje end-to-end

U volleyballu se podařilo ověřit kompletní tok:

API pull proběhl
RAW payload se uložil do staging.stg_api_payloads
parser zapsal data do staging.stg_provider_teams
merge je propsal do public
Ověřený výsledek pro VB teams:
teams inserted: 12
team_provider_map inserted: 12
league_teams inserted: 12

To je první plně potvrzený multi-sport teams flow mimo football.

C. Volleyball (VB) – fixtures také fungují

U fixtures jsme ověřili, že nově vložená data opravdu patří volleyballu, ne basketbalu.

Ověření:

Z public.matches jsme zjistili:

sport_id = 10 má 178 zápasů
poslední vložené řádky mají:
ext_source = api_volleyball
sport_id = 10

Tím je potvrzeno:

Výsledek:
178 nových zápasů patří volleyballu
ingest fixtures pro VB funguje správně
D. Basketball (BK) – opraven API host

U basketbalu se nejprve ukázalo, že teams pull padá na chybném hostu:

původně se skládal host z provideru
vznikalo špatně:
v1.sport.api-sports.io

To bylo opraveno v:

C:\MatchMatrix-platform\ingest\API-Sport\pull_api_sport_teams.ps1

Nově se host skládá podle sportu, takže pro BK jde správně na basketball API host.

Tím jsme odstranili technickou chybu v API volání.

E. Basketball (BK) – planner byl prázdný, vytvořen test job

Zjistili jsme, že pro BK nebyl žádný relevantní řádek v ops.ingest_planner, takže scheduler neměl co zpracovat.

Proto byl vložen testovací planner job pro:

provider = api_sport
sport_code = BK
entity = teams
provider_league_id = 12
season = 2024
run_group = BK_TOP

Poté se běh správně rozjel.

F. Basketball (BK) – flow technicky funguje, ale test target vrátil 0 dat

Po opravě hostu a vložení planner jobu proběhlo:

planner OK
ingest OK
payload se uložil
parser se spustil
merge doběhl

Ale kontrola RAW payloadu ukázala:

"results": 0,
"response": []
Závěr pro BK:
pipeline není rozbitá
problém není v parseru ani merge
konkrétní test:
league = 12
season = 2024
vrátil z API 0 teams

To znamená, že je třeba příště otestovat jiný BK target, který vrací reálná data.

G. Hockey (HK) – stále běží jinou, starší větví

U hokeje se ukázalo, že scheduler job sice běží, ale teams script:

nefunguje stejně jako nový API-Sport flow
neukládá payload do stejné RAW/parsing pipeline
parser pak hlásí:
Payloads: 0
merge nevkládá nic

Navíc teams pull u HK obíhá hromadně mnoho lig místo toho, aby jel čistě přes konkrétní planner target.

Závěr pro HK:
HK zatím není sjednocený s novým VB/BK flow
je stále na starší větvi
bude potřeba ho později převést na stejný model jako VB
3. Aktuální stav podle sportů
Volleyball (VB)

Stav: hotový a ověřený základ

Funguje:

teams ingest
parser
merge
fixtures ingest
zápis do public

Potvrzeno:

teams inserted = 12
team_provider_map inserted = 12
league_teams inserted = 12
matches inserted = 178

VB je teď referenční správný model.

Basketball (BK)

Stav: technicky rozběhnuto, ale bez reálných teams dat v testovaném targetu

Funguje:

planner
API host
pull
payload insert
parser
merge flow

Problém:

testovaný league 12 / season 2024 vrací results = 0

Potřeba příště:

najít jiný BK target s nenulovými daty
znovu otestovat teams flow na skutečně živé lize
Hockey (HK)

Stav: stará větev

Funguje:

job se claimne
teams script se spustí

Problém:

nejede přes nový RAW → parser → staging model
parser nic nevidí
merge nic nevkládá

Potřeba příště:

sjednotit HK teams flow s novým VB/BK modelem
4. Co jsme si dnes potvrdili

Dnešní nejdůležitější závěry:

Nový scheduler flow s parserem funguje
VB je první plně funkční multi-sport základ mimo football
BK už není technicky blokovaný hostem
BK test selhal jen na prázdných datech, ne na kódu
HK je zatím mimo nový standard a bude se muset předělat
Bez stabilního:
leagues
teams
fixtures
provider map
merge toku
nemá smysl jít naplno do players

A to je důležité i z pohledu dalšího cíle projektu, protože Ticket Engine a navazující inteligentní vrstva musí stát nad čistou a správně strukturovanou sportovní databází.

5. Kde jsme teď vůči hlavnímu cíli

Ty správně říkáš, že hotovo bude až ve chvíli, kdy budou fungovat:

players
další hráčské vrstvy
a později i další provideři

To stále hotové není.

Ale dnešek byl důležitý, protože jsme si potvrdili, že základní ingest kostra pro další sporty už se dá rozšiřovat bez chaosu.

6. Na co navážeme příště

Příště navážeme takto, po jedné věci:

Další reálný krok

Najít funkční BK target pro teams, který vrátí nenulová data.

To znamená:

vytáhnout BK ligy/targety
vybrat konkrétní použitelný provider_league_id + season
znovu pustit BK teams test

Až bude BK potvrzený stejně jako VB, budeme mít:

VB = nový flow ověřený
BK = nový flow ověřený
HK = kandidát na sjednocení

Teprve potom bude dávat smysl pokračovat do:

players
a následně dalších providerů
7. Krátké shrnutí jednou větou

Dnes jsme úspěšně zautomatizovali parser ve scheduleru, potvrdili plně funkční volleyball teams+fixtures flow, opravili basketbalový API host a zjistili, že BK testovaný target vrací 0 dat, zatímco hockey ještě běží po staré větvi.