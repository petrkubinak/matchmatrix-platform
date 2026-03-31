MatchMatrix – pracovní zápis
Datum: 10.03.2026

1. Cíl dne

Dokončit sjednocení staging vrstvy a převést historická data z původních sport-specifických tabulek do nového unified staging modelu.

Původní problém:

každý sport měl vlastní strukturu

football měl nejvíce tabulek

hockey měl jiné názvy

basketball zatím téměř nic

Cílem bylo vytvořit jednotnou ingest architekturu, aby bylo možné:

ingestovat více sportů

plánovat download přes scheduler

sjednotit parser

připravit data pro Ticket Engine.

2. Architektura databáze

Finální logická struktura:

public
produkční tabulky

staging
sjednocené ingest tabulky

ops
orchestrace a scheduler

work
pomocné pracovní tabulky
3. Unified staging tabulky

Vytvořeny a připraveny:

staging.stg\_api\_payloads

staging.stg\_provider\_leagues
staging.stg\_provider\_teams
staging.stg\_provider\_players
staging.stg\_provider\_fixtures
staging.stg\_provider\_odds
staging.stg\_provider\_events

staging.stg\_provider\_team\_stats
staging.stg\_provider\_player\_stats

Tyto tabulky jsou nezávislé na sportu.

4. Oprava indexů

Doplněny chybějící unikátní indexy pro správnou funkci ON CONFLICT.

Příklad:

(provider, external\_league\_id, season)
(provider, external\_team\_id)
(provider, external\_fixture\_id)
(provider, external\_player\_id)
5. Legacy → Unified staging bridge

Vytvořen worker:

workers/run\_legacy\_to\_staging\_bridge\_v2.py

Tento skript převádí data z:

staging.api\_football\_leagues
staging.api\_football\_teams
staging.api\_football\_fixtures

staging.api\_hockey\_leagues
staging.api\_hockey\_teams

do:

staging.stg\_provider\_leagues
staging.stg\_provider\_teams
staging.stg\_provider\_fixtures
6. Řešené problémy
1️⃣ chybějící unique constraint
there is no unique or exclusion constraint matching the ON CONFLICT specification

vyřešeno vytvořením indexů.

2️⃣ duplicate rows
ON CONFLICT DO UPDATE command cannot affect row a second time

příčina:

jeden tým existoval ve více sezónách

řešení:

SELECT DISTINCT ON (...)

aby bridge vybíral pouze jeden reprezentativní řádek.

7. Výsledek bridge

Po spuštění:

C:\\MatchMatrix-platform\\workers\\run\_legacy\_to\_staging\_bridge\_v2.py

stav unified staging:

stg\_provider\_leagues   = 1481
stg\_provider\_teams     = 974
stg\_provider\_fixtures  = 74583

Data jsou viditelná i v DBeaveru a odpovídají legacy tabulkám.

8. Stav ingest systému

Scheduler již funguje:

ops.scheduler\_queue
ops.ingest\_targets
ops.api\_budget\_status

Multi-sport scheduler:

run\_multisport\_scheduler\_v3

fronta:

ops.scheduler\_queue

executor:

run\_scheduler\_queue\_executor\_v2.py
9. API strategie

Cílem je využít API SPORT PRO plán.

Limity:

7500 requestů / den / sport

Cíl ingestu:

co nejvíce sportů

co nejvíce lig

i nižší soutěže kvůli fanouškům

např.

football
hockey
basketball
tennis
mma
volleyball
cricket
field hockey
esports
baseball
american football
10. Datová strategie

Ke každému zápasu chceme postupně získat:

fixtures

teams

leagues

players

odds

match events

team stats

player stats

články

komentáře

odkazy na oficiální stránky

klubové znaky

fan data

Cílem je vytvořit bohatý datový profil zápasu.

11. Další kroky (stav k 10.03)
1️⃣ odds bridge
api\_football\_odds
→ stg\_provider\_odds
2️⃣ players bridge
players\_import
player\_provider\_map\_import
→ stg\_provider\_players
3️⃣ merge do produkčních tabulek
stg\_provider\_leagues → public.leagues
stg\_provider\_teams   → public.teams
stg\_provider\_fixtures → public.matches
4️⃣ sjednocení ingest pipeline

finální pipeline:

scheduler
→ provider download
→ stg\_api\_payloads
→ parser
→ stg\_provider\_\*
→ public.\*
12. Stav projektu (10.03)

✔ multi-sport scheduler funguje
✔ unified staging model vytvořen
✔ legacy football data převedena
✔ legacy hockey data převedena
✔ databázová architektura stabilní

MatchMatrix je připraven na:

masivní ingest dat přes API SPORT PRO.

Update – 11.03.2026

1. Stabilizace pipeline

Dokončeny a ověřeny následující kroky:

Players bridge
Unified staging → public merge
Compute MMR ratings
Predict matches

Pipeline byla úspěšně spuštěna přes MatchMatrix Control Panel V2.

2. Rozhodnutí o architektuře ingestu

Bylo rozhodnuto zrušit původní api\_\* tabulky.

Důvody:

duplikovaly strukturu staging tabulek

komplikovaly ingest pipeline

nebyly multi-sport kompatibilní

Nový model:

provider
→ stg\_\*
→ public.\*
3. Finální staging model

Hlavní ingest tabulky:

stg\_api\_payloads

stg\_provider\_leagues
stg\_provider\_teams
stg\_provider\_players
stg\_provider\_fixtures
stg\_provider\_odds

stg\_provider\_events
stg\_provider\_team\_stats
stg\_provider\_player\_stats

Tyto tabulky jsou nyní jediným vstupem pro public databázi.

4. Stabilizace Control Panel V2

Byl vytvořen MatchMatrix Control Panel V2, který umožňuje ruční orchestrace pipeline.

Panel obsahuje sekce:

DAILY DATA
CORE PIPELINE
CONTEXT DATA
TICKET ENGINE

Funkce panelu:

spouštění jednotlivých kroků

restart pipeline od vybraného kroku

zobrazení logů

kontrola posledního běhu

Panel slouží jako operační nástroj pro debugging pipeline.

5. Úprava UI panelu

Provedeny úpravy:

scrollovatelný levý panel

dynamické rozložení

zmenšení velikosti fontu

lepší rozmístění tlačítek

oddělení log panelu

Panel je nyní stabilní a použitelný pro každodenní práci.

6. Další zdroje dat

Aktuálně využívané zdroje:

Football
football-data
(API doplnění top lig)
API-Football
≈ 1200 lig
Odds
TheOdds provider
Další sporty
API-Hockey
API-Basketball
API-Tennis
7. Další krok projektu

Další vývoj bude směřovat k plně orchestrovanému ingest systému.

Cíl:

scheduler
→ provider ingest
→ staging normalizace
→ public merge
→ rating models
→ predictions
8. Plán další práce

Další implementace:

1️⃣ odds bridge
provider odds
→ stg\_provider\_odds
2️⃣ players bridge stabilizace
players\_import
→ stg\_provider\_players
3️⃣ staging orchestrator

bude vytvořen centrální orchestrátor:

workers/run\_staging\_orchestrator\_v1.py

ten bude řídit ingest kroků.

4️⃣ automatizace pipeline

budoucí produkční model:

scheduler
→ ingest orchestration
→ public merge
→ model computation

Control Panel bude sloužit pouze pro:

monitoring

ruční zásah

debugging.

9. Stav projektu (11.03)

✔ unified staging architektura stabilní
✔ legacy bridge dokončen
✔ pipeline funguje end-to-end
✔ MMR ratingy generovány
✔ predikce zápasů funkční
✔ Control Panel V2 stabilní

MatchMatrix je nyní připraven na:

plně orchestrovaný multi-sport ingest.

Konec dne

Dnešní práce ukončena.

Další krok:

dokončit orchestraci ingest pipeline a plnění všech stg\_\* tabulek

MatchMatrix – pracovní zápis

Datum



11.03.2026



1\. Cíl dne



Dokončit Unified Ingest V1 a napojit ho na existující ingest skripty tak, aby:



ingest byl multisport



byl řízený centrálně přes panel



byl připravený na scheduler a run\_group



Současně jsme chtěli zachovat existující PowerShell ingest skripty, aby se nemusely hned přepisovat.



2\. Nová architektura ingestu



Byl vytvořen nový Unified Ingest Runner.



Soubor:



ingest/run\_unified\_ingest\_v1.py



Tento runner přijímá parametry:



\--provider

\--sport

\--entity

\--league-id

\--season

\--run-group

\--days-ahead

\--force



Generuje také automaticky:



run\_id = YYYYMMDDHHMMSS



který je předáván PowerShell skriptům.



3\. Provider vrstva



Byla vytvořena nová struktura:



ingest/providers



obsahuje:



base\_provider.py

provider\_registry.py

api\_football\_provider.py

api\_hockey\_provider.py

Funkce této vrstvy



Odděluje:



Unified ingest logiku

↓

provider specifické skripty



Například:



api\_football\_provider.py



volá:



pull\_api\_football\_leagues.ps1

pull\_api\_football\_teams.ps1

pull\_api\_football\_fixtures.ps1

pull\_api\_football\_odds.ps1

4\. Testované entity

Football leagues



Spuštění:



run\_unified\_ingest\_v1.py

\--provider api\_football

\--sport football

\--entity leagues



Výsledek:



Leagues inserted into staging

STATUS: OK

Football teams



Zjištěno:



PowerShell skript vyžaduje parametry:



LeagueId

Season



Proto byl wrapper upraven tak, aby vyžadoval:



\--league-id

\--season



Test:



\--league-id 39

\--season 2022



Výsledek:



Teams inserted into staging: 20

STATUS: OK

Football fixtures



Zjištěno:



PowerShell skript vyžaduje:



LeagueId

Season



Proto byl wrapper upraven stejně jako u teams.



Test bude probíhat:



\--league-id 39

\--season 2025

5\. Klíčové zjištění dne



Fixtures ani teams nejdou stahovat globálně.



Musí se stahovat:



po jednotlivých ligách



Například:



league\_id = 39

season = 2025



To znamená, že ingest musí běžet:



for each league:

&#x20;   pull teams

&#x20;   pull fixtures

6\. Role tabulky ops.ingest\_targets



Bylo potvrzeno, že správný zdroj pro seznam lig je tabulka:



ops.ingest\_targets



Ta obsahuje:



provider

provider\_league\_id

season

run\_group

enabled



a slouží jako:



seznam lig které se mají ingestovat



Podle:



run\_group



například:



EU\_top

EU\_exact\_v1

FOOTBALL\_MAINTENANCE\_TOP

7\. Správná architektura ingestu



Finální model bude:



scheduler

↓

run\_group

↓

ops.ingest\_targets

↓

provider\_league\_id + season

↓

run\_unified\_ingest\_v1

↓

provider wrapper

↓

PowerShell ingest

↓

staging

8\. Panel MatchMatrix



Panel:



ops/matchmatrix\_control\_panel\_V3.py



je připraven jako hlavní ovládací UI.



Spouštění:



run\_matchmatrix\_control\_panel.bat



panel bude postupně řídit:



ingest

merge

ratings

predictions

ticket engine

9\. Scheduler



Soubor:



workers/run\_multisport\_scheduler\_v4.py



bude orchestrátor pipeline.



V budoucnu bude číst:



ops.ingest\_targets



a generovat joby podle:



run\_group

10\. Stav systému na konci dne



Funkční:



Unified ingest runner

provider wrapper

football leagues ingest

football teams ingest

control panel V3



Částečně připraveno:



football fixtures ingest

multisport scheduler

run\_group ingest model



Připraveno na další krok:



batch ingest přes ingest\_targets

11\. Plán na zítřek



Další implementační kroky:



1



Vytvořit:



run\_unified\_ingest\_batch\_v1.py



který:



načte ingest\_targets



a spustí ingest pro každou ligu.



2



Napojit batch ingest na:



scheduler

3



Přepojit panel aby spouštěl:



batch ingest



místo jednotlivých lig.



4



Otestovat:



football fixtures batch

football odds

hockey ingest

12\. Shrnutí



Unified Ingest V1 je funkční.



Projekt MatchMatrix má nyní:



stabilní ingest vrstvu



provider architekturu



panel pro ovládání



připravený scheduler model



Dalším krokem je batch ingest přes ops.ingest\_targets, který umožní plně automatický ingest lig podle run\_group.





