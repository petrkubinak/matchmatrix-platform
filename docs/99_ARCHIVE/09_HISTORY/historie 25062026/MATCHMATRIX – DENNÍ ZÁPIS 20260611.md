MATCHMATRIX – DENNÍ ZÁPIS
Datum: 11.06.2026
Oblast: PC2 Dependency Harvest Engine / CORE → PEOPLE → MEDIA řízení
Co jsme dnes dokončili
1. PC2 Dependency Harvest Queue

Dokončili jsme první funkční verzi závislostního harvest plánovače.

Poprvé jsme zavedli logiku:

CORE
 ↓
PEOPLE
 ↓
MEDIA
 ↓
ODDS
 ↓
CONTEXT

Místo ručního rozhodování systém ví:

nejdřív stáhni CORE
potom PEOPLE
potom MEDIA
2. PC2 Command Center

Vznikla nová vrstva:

ops.pc2_run_command_queue

která obsahuje:

sport
vrstvu
stav
příkaz
popis
další krok

Například:

HB CORE
TN CORE
AFB PEOPLE
BK PEOPLE
FB MEDIA
3. Execution Readiness Audit

Vznikl audit:

ops.v_pc2_execution_readiness_audit_v1

který umí rozlišit:

READY_TO_RUN
PLANNER_JOB_MISSING
ROUTING_ERROR
TARGET_MISSING
VERIFY_PEOPLE_WORKER

Díky tomu jsme našli skutečné chyby místo odhadů.

4. HB CORE (Handball)

Původní stav:

Planner queue prázdná
provider_league_id = NULL

Oprava:

ops.ingest_targets
↓
vygenerování planner jobů
↓
spuštění harvestu

Výsledek:

HB CORE FUNGUJE

Zpracovány desítky lig.

5. TN CORE (Tennis)

Původní stav:

api_tennis
↓
špatné routování
↓
pull_api_sport_fixtures.ps1

Výsledek:

ROUTING ERROR
Oprava

Vytvořili jsme:

tennis_standalone provider

a nový worker:

workers\tennis\run_tennis_standalone_fixtures_v1.py

který používá:

ingest\API-Tennis\pull_api_tennis_fixtures_v1.py
ingest\API-Tennis\parse_api_tennis_fixtures_v1.py
Finální výsledek

ATP:

RAW SAVED = 1
PARSED UPSERTS = 18
RESULT = OK

WTA:

RAW SAVED = 1
PARSED UPSERTS = 18
RESULT = OK

Souhrn:

Processed OK = 2
Errors = 0

Databáze:

planner done = 2
staging.api_tennis_fixtures = 87

Status:

TN CORE = HOTOVO
Co máme aktuálně rozjeté
READY
HB CORE
TN CORE
FB MEDIA
Čeká na opravu
AFB PEOPLE

důvod:

players nejsou routované správným workerem
Čeká na ověření
BK PEOPLE
BSB PEOPLE
CK PEOPLE
HK PEOPLE
VB PEOPLE

Musíme zjistit:

fungují přes unified ingest?

nebo

potřebují vlastní people worker?
Největší zjištění dne

Dnes jsme poprvé ověřili, že model:

PC2 Queue
↓
Planner
↓
Worker
↓
Pull
↓
Parser
↓
Staging

opravdu funguje.

To je velmi důležitý milník.

Co budeme dělat zítra
Priorita 1

Přestavba OPS Panelu V18

Cíl:

už žádné přepínání do DBeaveru

Panel musí umět:

SPUSTIT

RETRY

PENDING

READY

DONE

BLOCKED

CONTINUE

VYTVOŘIT JOB

SMAZAT JOB

VYTVOŘIT FIX TASK

přímo z GUI.

Priorita 2

AFB PEOPLE Routing Fix

Vyřešit:

ROUTING_ERROR_PLAYERS_NOT_GENERIC

a vytvořit správný people worker.

Priorita 3

People Layer Audit

Postupně:

BK
BSB
CK
HK
VB

Každý sport:

spustit
ověřit
opravit
vrátit do fronty
znovu spustit
Cíl na příští týden

Mít plně funkční:

PC2 Orchestration Center

které samo řídí:

CORE
PEOPLE
MEDIA
ODDS
CONTEXT

a umožní z panelu:

spouštět
opravovat
blokovat
vracet do fronty
testovat
ověřovat

bez jediného zásahu do DBeaveru.

Dlouhodobý cíl

Vybudovat:

MATCHMATRIX HARVEST OPERATING SYSTEM

kde:

Panel
↓
najde problém
↓
navrhne opravu
↓
vytvoří job
↓
spustí job
↓
ověří výsledek
↓
přepne další vrstvu

a celé PC2 bude schopné postupně automaticky budovat:

CORE
PEOPLE
MEDIA
ODDS
CONTEXT

pro všechny sporty v MatchMatrix.

DNES:
- PC2 panel už spouští reálné joby.
- HB CORE prošel další dávkou 10 lig OK.
- Zavedli jsme historii PC2 běhů: ops.pc2_execution_history.
- BK PEOPLE EMPTY_RUN byl zapsán do historie.
- Připravili jsme DB funkci pro automatický zápis historie.
- BK PEOPLE jsme znovu nasadili do planneru jako pending job.

ROZJETÉ:
- HB CORE pokračuje po dávkách.
- TN CORE je hotový přes standalone tennis worker.
- BK PEOPLE je připraven k novému testu.
- Panel V18.20 má PC2 action cards a základní akční ovládání.

ZÍTRA:
- Napojit panel na ops.fn_pc2_insert_execution_history_v1 automaticky po každém běhu.
- Spustit BK PEOPLE z panelu.
- Pokud BK spadne routingem, udělat BK standalone people worker.
- Přidat v panelu PC2 HISTORIE.
- Pokračovat stejným systémem pro BSB, CK, HK, VB.

CÍL:
- Vše řídit z panelu:
  READY → SPUSTIT → HISTORIE → OPRAVA → PENDING → SPUSTIT → DONE.