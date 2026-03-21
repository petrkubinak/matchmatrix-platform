MatchMatrix – pracovní zápis

Datum: 20.03.2026
Téma: Hockey (HK) – převod football šablony do dalšího sportu, příprava první reálné planner vrstvy

1. Hlavní cíl dne

Navázat na hotovou football šablonu a začít stejným způsobem stavět další sport, konkrétně Hockey (HK).

Cílem nebylo ještě spouštět ostrý ingest, ale připravit celý OPS/planner základ tak, aby šel další den udělat první reálný HK test běh.

Tím jsme pokračovali přesně podle strategie, kterou jsme si už potvrdili:

nejdřív udělat jeden sport pořádně jako šablonu

potom stejný model aplikovat na další sport

vše řídit přes ingest_targets, run_group, ingest_entity_plan, planner view a job katalog, ne chaoticky přes ad hoc spuštění

2. Výchozí stav a důležité zjištění

Na začátku se ukázalo, že teoretický návrh se musí přizpůsobit reálnému schématu databáze.

Během práce jsme si ověřili skutečné struktury tabulek a narazili na několik důležitých rozdílů oproti původním předpokladům:

2.1 ops.ingest_targets

Tabulka má mimo jiné tyto důležité sloupce:

sport_code

canonical_league_id

provider

provider_league_id

season

enabled

max_requests_per_run

run_group

Naopak zde neexistuje priority a v praxi jsme se museli řídit skutečným schématem, ne předpokladem. To dobře odpovídá i dřívějšímu dumpu a OPS vrstvě projektu

2.2 ops.ingest_entity_plan

Tady jsme ověřili, že tabulka má:

provider

sport_code

entity

enabled

priority

scope_type

requires_league

requires_season

default_run_group

ingest_mode

source_endpoint

target_table

worker_script

notes

Naopak neobsahuje:

requires_team

requires_player

requires_match

A navíc má check constraint na povolené scope_type, takže neprojde libovolná nová hodnota.

2.3 ops.provider_jobs

Tady jsme si ověřili reálné sloupce:

provider

sport_code

job_code

endpoint_code

ingest_mode

enabled

priority

batch_size

max_requests_per_run

retry_limit

cooldown_seconds

days_back

days_forward

notes

A tedy znovu: nešlo slepě převzít původní návrh, ale bylo nutné seed skript přizpůsobit skutečné OPS tabulce.

To byl důležitý přínos dneška:
nejen jsme stavěli HK vrstvu, ale zároveň jsme si zpřesnili reálný OPS model.

3. HK run groups – první vrstvení targetů

První hotový krok bylo rozdělení Hockey targetů do vrstev přes run_group.

Vznikl soubor:

C:\MatchMatrix-platform\db\ops\179_ops_hk_run_groups.sql

Protože v ops.ingest_targets nebyla k dispozici použitelná priorita/tier pro výběr TOP subsetu, zvolili jsme dočasně jednoduchý a bezpečný model:

vše pro HK se nejdřív nastavilo do HK_CORE

potom se prvních 20 targetů vybralo jako HK_TOP

Výsledek:

HK_CORE = 242

HK_TOP = 20

Tím vznikla první Hockey vrstva stejným principem, jaký jsme už používali u footballu:
sport → targety → run_group → planner

4. HK ingest entity plan – provider-aware vrstva

Další krok byl připravit entity plán pro api_hockey.

Vznikl soubor:

C:\MatchMatrix-platform\db\ops\180_seed_api_hockey_hk_ingest_entity_plan.sql

Při seedování jsme museli několikrát skript opravit podle reality schématu:

odstranily se neexistující sloupce requires_team, requires_player, requires_match

u entity coaches bylo nutné změnit scope_type z nepovoleného team_season na povolené league_season

Finální výsledek v ops.ingest_entity_plan pro api_hockey / HK:

leagues

teams

fixtures

odds

players

coaches

To je důležité zjištění i pro další práci:

odds už v HK plánu existují

HK tedy není jen minimalistický sport, ale má připravený širší entity model

Tím jsme u Hockey vytvořili stejný typ provider-aware entity plánu, jaký jsme už postavili u football vrstvy

5. HK planner view – TOP vrstva

Pak jsme z ingest_targets + ingest_entity_plan sestavili první skutečný planner pohled pro HK TOP vrstvu.

Vznikl soubor:

C:\MatchMatrix-platform\db\views\181_create_v_ops_hk_top_ingest_jobs.sql

Tento view spojil:

HK targety z ops.ingest_targets

HK entity plan z ops.ingest_entity_plan

a vygeneroval joby pro HK_TOP.

Kontrolní výsledek:

pro každou z entit bylo 20 jobů:

coaches = 20

fixtures = 20

leagues = 20

odds = 20

players = 20

teams = 20

To znamená:

20 TOP targetů

6 entit

tedy logicky 120 HK TOP planner řádků

6. HK test mode view

Protože teď jedeme ve free/test režimu, stejně jako jsme si určili dříve, vytvořili jsme test mode view jen pro základní entity potřebné pro první bezpečný běh:

leagues

teams

fixtures

Vznikl soubor:

C:\MatchMatrix-platform\db\views\182_create_v_ops_hk_top_ingest_jobs_test_mode.sql
Výsledek:

fixtures = 20

leagues = 20

teams = 20

Tím jsme vyřízli jen bezpečnou testovací část HK planneru, bez dalších entit.

To přesně odpovídá našemu aktuálnímu pracovnímu režimu:

free API

test mód

omezený scope

nejdřív ověřit architekturu, ne hned všechno spouštět

7. HK execution order

Aby planner nebral joby nahodile, vytvořili jsme explicitní pořadí běhu.

Vznikl soubor:

C:\MatchMatrix-platform\db\views\183_create_v_ops_hk_top_test_execution_order.sql

Nastavili jsme pořadí:

leagues

teams

fixtures

Kontrolní výsledek:

leagues → 1 → 20

teams → 2 → 20

fixtures → 3 → 20

Tím je jasně definované pořadí prvního HK test běhu.

8. HK job catalog

Pak jsme z execution order pohledu vytvořili explicitní job katalog.

Vznikl soubor:

C:\MatchMatrix-platform\db\views\184_create_v_ops_hk_job_catalog.sql

Ten převedl planner řádky na katalog jobů s parametry jako:

layer

layer_order

provider

sport_code

entity

entity_order

run_group

target_count

planned_requests

job_code

Finální job katalog:

api_hockey__HK_TOP__leagues

api_hockey__HK_TOP__teams

api_hockey__HK_TOP__fixtures

Každý s:

target_count = 20

planned_requests = 20

To je první skutečně explicitní Hockey job model.

9. Seed HK jobů do ops.provider_jobs

Další krok byl dostat HK job katalog do provozní OPS tabulky.

Vznikl soubor:

C:\MatchMatrix-platform\db\ops\185_seed_hk_provider_jobs.sql

Během práce jsme museli seed několikrát upravit podle skutečného schématu ops.provider_jobs.

Nakonec se správně propsaly 3 HK test joby:

api_hockey__HK_TOP__leagues

api_hockey__HK_TOP__teams

api_hockey__HK_TOP__fixtures

s těmito hodnotami:

ingest_mode = fast

enabled = true

priority:

leagues = 2010

teams = 2020

fixtures = 2030

batch_size = 20

max_requests_per_run = 20

retry_limit = 3

cooldown_seconds = 0

days_back = 7

days_forward = 14

Tím už HK není jen teoretická view vrstva, ale má i seednuté provozní joby v OPS tabulce.

10. HK runnable jobs view

Na závěr jsme z job katalogu a ops.provider_jobs postavili první skutečně runnable HK vrstvu.

Vznikl soubor:

C:\MatchMatrix-platform\db\views\186_create_v_ops_hk_top_runnable_jobs.sql
Výsledek:

api_hockey__HK_TOP__leagues

api_hockey__HK_TOP__teams

api_hockey__HK_TOP__fixtures

s parametry:

fast

priority 2010 / 2020 / 2030

planned_requests = 20

A potom ještě vznikl kontrolní preview soubor:

C:\MatchMatrix-platform\db\checks\187_preview_hk_top_runnable_jobs.sql

který potvrdil stejný výsledný runnable set.

11. Co je po dnešku u Hockey hotové

Pro HK máme po dnešku připravenou kompletní první planner vrstvu:

Hotové SQL soubory

C:\MatchMatrix-platform\db\ops\179_ops_hk_run_groups.sql

C:\MatchMatrix-platform\db\ops\180_seed_api_hockey_hk_ingest_entity_plan.sql

C:\MatchMatrix-platform\db\views\181_create_v_ops_hk_top_ingest_jobs.sql

C:\MatchMatrix-platform\db\views\182_create_v_ops_hk_top_ingest_jobs_test_mode.sql

C:\MatchMatrix-platform\db\views\183_create_v_ops_hk_top_test_execution_order.sql

C:\MatchMatrix-platform\db\views\184_create_v_ops_hk_job_catalog.sql

C:\MatchMatrix-platform\db\ops\185_seed_hk_provider_jobs.sql

C:\MatchMatrix-platform\db\views\186_create_v_ops_hk_top_runnable_jobs.sql

C:\MatchMatrix-platform\db\checks\187_preview_hk_top_runnable_jobs.sql

Hotová logická vrstva

HK_TOP a HK_CORE

entity plan pro api_hockey

test mode pro HK

execution order

job catalog

seed do ops.provider_jobs

runnable joby

Finální runnable HK test set

leagues

teams

fixtures

To znamená, že HK je po dnešku připravený na první reálný planner test run.

12. Co dnes ještě neproběhlo

Neudělali jsme ještě samotný reálný běh workeru/planneru pro HK.

To bylo odloženo na zítřek.

Tedy:

architektura a OPS příprava = hotovo

první reálný test běh = zítra

To je správně, protože teď už půjdeme do běhu s připravenou a zkontrolovanou strukturou, ne naslepo.

13. Další krok zítra

Zítra navážeme přímo prvním reálným HK planner test runem:

cd C:\MatchMatrix-platform
C:\Python314\python.exe .\workers\run_ingest_planner_jobs.py --provider api_hockey --sport hockey --limit 3 --timeout-sec 300 --max-attempts 3

Očekávaný první běh:

leagues

teams

fixtures

A podle výsledku pak uděláme další krok:

buď oprava mappingu / worker napojení

nebo rozšíření na další HK vrstvy

případně přechod na HK_CORE

14. Hlavní závěr dne

Dnešek byl velmi důležitý, protože jsme z football šablony udělali první skutečný převod do dalšího sportu.

Tedy ne jen teorie, ale skutečné potvrzení, že model:

run_group

ingest_targets

ingest_entity_plan

planner view

execution order

job catalog

provider_jobs

runnable jobs

je přenositelný i na další sport.

To je přesně v souladu s cílem připravit systém ne jen pro top football, ale postupně pro plný multisport provoz

Až zítra navážeme, začneme rovnou tím HK test runem.