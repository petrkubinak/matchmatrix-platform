MatchMatrix – podrobný zápis
Datum: 20.03.2026
Téma: football vrstvy, jobizace v SQL, příprava šablony pro další sporty
1. Hlavní cíl této části práce

Cílem nebylo jen “něco spustit”, ale správně navrhnout a připravit databázovou architekturu tak, aby:

ingest nebyl chaotický,

nebyl stavěný stylem „stáhni všechno“,

šel řídit po vrstvách,

šel řídit podle providerů,

šel řídit podle budgetu a priority,

a aby se stejný model dal později aplikovat i na další sporty.

Během této části jsme si potvrdili, že správná cesta není pustit multisport najednou, ale:

nejdřív udělat football kompletně,

pak stejnou šablonu použít na hockey,

potom basketball,

a další sporty už půjdou rychleji.

2. Klíčové architektonické pochopení

Na začátku jsme si vyjasnili velmi důležitou věc:

Současná TOP vrstva byla historicky dělána jen pro:

football

basketball

hockey

a navíc jen pro:

TOP ligy

úzký testovací subset

To znamenalo, že:

multisport základ v databázi už existoval,

ale planner a top ingest vrstva pořád reálně žila jen pro 3 sporty.

Zároveň jsme ověřili, že:

sport_entity_rules už máš připravené pro všechny sporty,

provider_sport_matrix už máš připravené pro všechny sporty,

ingest_entity_plan šel rozšířit na všechny sporty,

ale v_top_ingest_jobs* byly pořád navázané na v_top_ingest_targets, tedy na starý top-only svět.

Tím jsme si oddělili dvě roviny:

A. Multisport základ

To už v DB existuje.

B. Provozní ingest vrstva

Ta byla zatím reálně jen pro football/basket/hockey top subset.

Tohle bylo velmi důležité pochopit předtím, než bychom sahali do scheduleru nebo budget enginu.

3. Rozhodnutí o strategii ingestu

Padlo důležité rozhodnutí, že se nepůjde cestou:

jeden obří multisport planner pro všechno,

ani cestou okamžitého full ingestu všeho.

Místo toho jsme potvrdili správný model:

Ingest po vrstvách

pro každý sport zvlášť:

TOP

CORE / maintenance / historický základ

EXPANSION

později další vrstvy podle potřeby

Tohle je důležité, protože:

lépe to odpovídá realitě providerů,

lépe se to vejde do requestů,

lépe se to ladí,

lépe se to dá řídit v OPS,

a hlavně to odpovídá tomu, co od systému chceš.

4. Football – práce na vrstvách

Tady jsme udělali největší kus práce.

4.1 Vyčištění sport code

Odhalili jsme zbytek legacy kódu:

football

a sjednotili jsme football na canonical kód:

FB

Tím se srovnalo ingest_entity_plan a odstranil se historický chaos.

4.2 Rozdělení football targetů do vrstev

Postupně jsme přestali football brát jako jednu masu a začali jsme ho dělit do logických vrstev.

Nakonec vznikly 3 hlavní football vrstvy:

1. FB_TOP

úzká prioritní vrstva
provider:

api_football

charakter:

malý subset

nejvyšší priorita

vhodné pro nejrychlejší maintenance

2. FB_FD_CORE

původně pracovně FB_EU, ale po auditu jsme zjistili, že ten název není přesný

provider:

football_data

charakter:

historicky dobře naplněný dataset

maintenance základ

nízký provozní risk

vhodné jako core vrstva

Důležitá změna:

run_group jsme přejmenovali z FB_EU na FB_FD_CORE, protože se ukázalo, že to není čistě evropská vrstva, ale providerově vymezený core set.

3. FB_API_EXPANSION

provider:

api_football

charakter:

rozšiřující vrstva

širší subset lig

bohatší entity

řízená expanze

Tato vrstva byla oddělena od velké masy FOOTBALL_MAINTENANCE, abychom ji mohli řídit samostatně.

5. Provider-aware logika footballu

Velmi důležité zjištění bylo, že football není single-provider sport.

Zjistili jsme, že v targetech pro FB existují provideri:

api_football

football_data

api_sport

Zároveň jsme zjistili, že ingest_entity_plan byl původně pro football připraven jen pro:

api_football

To způsobovalo, že některé view nevycházely, protože join v OPS logice byl přes:

provider

sport_code

Proto jsme správně doplnili football plán i pro football_data, ale ne slepě pro všechny entity.

Pro football_data jsme rozumně přidali jen:

leagues

teams

fixtures

odds

a nepřidávali jsme tam zatím:

players

player_season_stats

coaches

Tím vznikla první skutečně provider-aware football vrstva.

6. Audit football_data

Udělali jsme velmi důležitý audit historického pokrytí football_data.

Ukázalo se, že pro hlavní ligy už máš prakticky hotovou historii.

Hlavní ligy s cca 9 sezónami

Například:

Premier League

Championship

Serie A

Primera Division

Ligue 1

Primeira Liga

Bundesliga

Eredivisie

Campeonato Brasileiro Série A

Rozsah sezón:

přibližně od 1819 do 2526

Tedy zhruba:

2018/19 až 2025/26

Závěr:
football_data už není provider pro velký backfill.

Je to spíš:

hotový historický zdroj,

maintenance zdroj,

core base.

Naopak soutěže jako:

UEFA Champions League

FIFA World Cup

European Championship

Copa Libertadores

byly jen po jedné sezóně, takže ty jsme nebrali jako hotový historický základ.

Tím jsme si potvrdili, že FB_FD_CORE je správný název i role.

7. Football planner a test vrstvy

Pro football jsme postupně vytvořili několik SQL view, která dávají logickou strukturu.

7.1 Základní vrstvy

Byla připravena view pro:

v_fb_fd_core_ingest_jobs

v_fb_fd_core_ingest_jobs_test_mode

v_fb_api_expansion_ingest_jobs

v_fb_api_expansion_ingest_jobs_test_mode

Tím jsme získali oddělené test režimy pro:

football_data core

api_football expansion

7.2 Football test orchestrator

Pak jsme obě vrstvy spojili s top vrstvou a vznikl:

v_fb_test_mode_orchestrator

Ten už obsahuje:

FB_TOP

FB_FD_CORE

FB_API_EXPANSION

Tím jsme dostali první kompletní football test orchestrator.

7.3 Football execution order

Dalším krokem jsme udělali explicitní pořadí běhu:

nejdřív FB_TOP

pak FB_FD_CORE

pak FB_API_EXPANSION

A uvnitř vrstvy:

leagues

teams

fixtures

players

player_season_stats

coaches

Tím vznikla view:

v_fb_test_execution_order

Tato view už není jen logická, ale přímo provozně použitelná.

8. Football job katalog

Dále jsme football neponechali jen jako view logiku, ale převedli jsme ho na explicitní job katalog.

Vznikla view:

ops.v_fb_job_catalog

Ta pro každou football vrstvu vytvořila:

layer

layer_order

entity_order

job_code

target_count

planned_requests

minimální a maximální effective season

Tím football dostal první skutečně explicitní SQL job model.

9. Football joby v ops.provider_jobs

To byl jeden z nejdůležitějších výsledků dnešní práce.

Chtěli jsme football job katalog zapsat do:

ops.provider_jobs

Cestou jsme narazili na dvě důležité reálné věci:

9.1 Schema mismatch

Ukázalo se, že provider_jobs:

nemá sloupec entity

místo toho používá endpoint_code

Tím jsme si potvrdili, že:

není potřeba hned přidávat nový sloupec entity

entitu můžeme bezpečně reprezentovat přes endpoint_code

To bylo správné rozhodnutí, protože jsme se vyhnuli zbytečné změně schématu.

9.2 Check constraint na ingest_mode

První seed padl na constraint:

chk_provider_jobs_ingest_mode

Zjistili jsme, že povolené hodnoty jsou jen:

slow

medium

fast

Takže jsme seed skript opravili takto:

FB_TOP

fast

FB_FD_CORE

slow

FB_API_EXPANSION

medium

Tím se football joby správně propsaly do ops.provider_jobs.

10. Finální football job model

Po úspěšném seedování máš v ops.provider_jobs pro football těchto 15 jobů:

FB_TOP / api_football / fast

leagues

teams

fixtures

players

player_season_stats

coaches

FB_FD_CORE / football_data / slow

leagues

teams

fixtures

FB_API_EXPANSION / api_football / medium

leagues

teams

fixtures

players

player_season_stats

coaches

Tím je football:

vrstvený,

provider-aware,

zjobovaný,

a připravený jako šablona pro další sporty.

11. Co je teď o footballu definitivně hotové

Football už má v SQL databázi:

Konfigurační vrstvu

sport rules

provider mapu

entity plan

Target vrstvu

TOP

FD_CORE

API_EXPANSION

Planner vrstvu

test mode view

orchestrator

execution order

Job vrstvu

job catalog

seed do ops.provider_jobs

To znamená, že football už není rozdělaný jen “myšlenkově”, ale je skutečně připravený v OPS SQL modelu.

12. Hlavní závěr dnešní práce

Dnešní práce nebyla o tom něco jen kosmeticky přejmenovat.

Reálně jsme udělali toto:

rozsekali football na řízené vrstvy,

oddělili providery podle role,

potvrdili historickou sílu football_data,

vyčlenili expanzi v api_football,

vytvořili planner orchestrator,

vytvořili execution order,

vytvořili job katalog,

a zapsali football do ops.provider_jobs.

To je zásadní milestone.

Football je teď první sport, který máš opravdu připravený jako:

vrstvený,

plánovatelný,

jobizovaný,

OPS-ready.

13. Rozhodnutí pro další postup

Potvrdili jsme si, že je lepší pokračovat:

football jako šablona — hotovo

hokej jako druhý vzor

basketbal jako třetí vzor

potom ostatní sporty už půjdou rychleji, klidně po více najednou

To je lepší než se snažit zlomit celý multisport v jednom kroku.

14. Co bude následovat dál

Další krok už nebude další rozpitvávání footballu.

Další logická větev je:

Hokej

a stejně jako u footballu:

rozdělení targetů do vrstev

provider-aware pohled

view

orchestrator

execution order

job katalog

seed do ops.provider_jobs

15. Jednověté shrnutí

Dnes jsme z footballu udělali první kompletní sport v MatchMatrix, který je v SQL databázi připravený po vrstvách, po providerech a po jobech tak, aby šel později řídit jako součást skutečného multisport OPS systému.