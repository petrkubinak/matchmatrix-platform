MATCHMATRIX MASTER NAVÁZÁNÍ
Stav projektu k 31.05.2026 – OPS Command Center, Historical Harvest a AI Orchestrace
CO JSME DNES DOKONČILI

Během dnešní práce jsme výrazně posunuli OPS vrstvu z pouhého monitoringu směrem ke skutečnému autonomnímu řízení projektu MatchMatrix.

Panel již není pouze přehled spuštěných procesů.

Panel začíná rozhodovat:

co chybí,
co má nejvyšší prioritu,
co má největší přínos pro celý projekt,
jaký další worker má být spuštěn.
111\_M – SMART CORE QUOTA QUEUE
CO TO JE

Inteligentní fronta CORE harvestu.

K ČEMU TO JE

Původní CORE harvest vybíral pouze nejvyšší pending úlohy.

To vedlo k tomu, že dlouhodobě běžel téměř výhradně fotbal.

VÝSLEDEK

Vznikla kvótovaná fronta:

Football      50 %
Hockey        15 %
Basketball    15 %
Ostatní       20 %
111\_N – MULTISPORT HISTORICAL CORE PLANNER
CO TO JE

Seed historických CORE úloh pro všechny sporty.

K ČEMU TO JE

Dříve byly pending úlohy téměř výhradně FB.

Nyní byly vytvořeny historické pending úlohy i pro:

HK
BK
HB
VB
AFB
BSB
CK
RGB
TN
MMA
ESP
FH
VÝSLEDEK

Historický harvest už není pouze fotbalový.

111\_O – PROVIDER AWARE API BUDGET
CO TO JE

Napojení budgetů na provider\_accounts.

K ČEMU TO JE

Limity se již nezadávají ručně.

Systém čte:

provider
plan
daily\_limit

z:

ops.provider\_accounts
AKTUÁLNÍ STAV

FREE režim:

100 requestů / sport / den

Budoucí PRO režim:

7500 requestů / sport / den

po změně provider účtu.

111\_P – SPORT DAILY BUDGET MONITOR
CO TO JE

Přehled denních limitů po sportech.

K ČEMU TO JE

Kontrola vytížení providerů.

PŘÍKLAD
Football      0 / 100
Hockey        0 / 100
Basketball    0 / 100
BUDOUCNOST

Po přechodu na PRO:

Football   1840 / 7500
Hockey      420 / 7500
Basketball  310 / 7500
111\_Q – SPORT COMPLETION DASHBOARD
CO TO JE

Souhrnný dashboard dokončenosti sportů.

Zdroj:

ops.v\_sport\_completion\_dashboard\_v1
K ČEMU TO JE

Ukazuje:

CORE
PEOPLE
MEDIA
ODDS
CELKOVÉ %
PENDING
DOPORUČENÁ AKCE
AKTUÁLNÍ STAV

Například:

Football      CORE\_HARVEST      3792 pending
Handball      CORE\_HARVEST      1266 pending
Hockey        CORE\_HARVEST       180 pending
Basketball    CORE\_HARVEST        54 pending
Volleyball    CORE\_HARVEST         6 pending
PANEL V17.11
NOVINKY
České KPI

Přepsány názvy KPI do češtiny.

Lepší čitelnost
širší KPI karty,
zalamování textu,
oprava kódování logů.
AI doporučená akce

Panel doporučuje další akci podle přínosu.

Manuál / Automat

Příprava na plně autonomní režim.

Denní limity sportů

Nový dashboard využití API limitů.

Projektový dashboard

Panel již ukazuje stav celého projektu.

AUTONOMNÍ OPS – NOVÁ FILOZOFIE

Původně:

Spusť další worker.

Nově:

Najdi nejslabší sport.
Najdi nejslabší vrstvu.
Najdi worker s nejvyšším přínosem.
Doporuč akci.
DLOUHODOBÁ VIZE AUTONOMNÍHO OPS
111\_R – AI ACTION RECOMMENDATION ENGINE V2

Cíl:

Panel nebude doporučovat pouze worker.

Bude doporučovat:

Sport
Vrstva
Důvod
Přínos
Akce

Příklad:

DOPORUČENO

SPORT:
HB

VRSTVA:
CORE

PŘÍNOS:
+3,4 % projektu

AKCE:
CORE\_INGEST\_V3
111\_S – AUTONOMOUS OPS BRAIN

Budoucí autonomní logika:

Najdi problém
↓
Spusť opravu
↓
Vyhodnoť výsledek
↓
Pokud nefunguje:
jiný worker
jiný provider
jiný plán
↓
Ulož zkušenost
↓
Pokračuj dál
HISTORICKÝ HARVEST – STRATEGIE
PRIORITA

Nejdříve:

historická data
co nejvíce sportů
co nejvíce providerů
co nejvíce sezón

Poté:

aktuální sezóna
2025/2026

pro spuštění webu.

CÍLOVÝ STAV
OPS nebude pouze monitorovat.

OPS bude řídit MatchMatrix.

Bude rozhodovat:

co chybí
co má běžet
co má největší přínos
jak nejlépe využít API limity
jak dokončit vrstvy projektu
DALŠÍ CHAT – KONTINUACE

Pokračovat od:

111\_R – AI ACTION RECOMMENDATION ENGINE V2

poté

111\_S – AUTONOMOUS OPS BRAIN

poté

V17.11.03 – SPORT COMPLETION DASHBOARD V PANELU

a následně

historický harvest
People vrstva
Media vrstva
Odds vrstva
příprava druhého PC
příprava webu

🚀 MatchMatrix se posouvá z monitorovacího systému na autonomně řízenou datovou platformu.



AKTUALIZACE 2026-05-31 → 2026-06-01

AUTONOMNÍ OPS PLATFORM – STAV



Byla dokončena první produkční verze autonomního OPS řízení.



Hotové části:



111\_R Sport Completion Dashboard

111\_S Autonomous OPS Brain V1

111\_S Autonomous OPS Brain V2

111\_S Autonomous OPS Brain V3

111\_S Autonomous OPS Brain V4



Cíl:



Přesunout MatchMatrix od ručně spouštěných procesů k autonomnímu řízení celé platformy.



CO JE AUTONOMNÍ OPS BRAIN



OPS Brain je vrstva nad plannerem.



Nevykonává harvesting přímo.



Vyhodnocuje:



stav sportů

stav providerů

stav workerů

stav planneru

stav runtime auditů

stav media vrstvy

stav people vrstvy

stav datových mezer



a navrhuje další akce.



NOVÁ FILOZOFIE PLATFORMY



Dříve:



Člověk

&#x20; ↓

Spustí skript

&#x20; ↓

Vyhodnotí výsledek



Nově:



OPS Brain

&#x20; ↓

Vyhodnotí situaci

&#x20; ↓

Navrhne akci

&#x20; ↓

Scheduler

&#x20; ↓

Worker



Budoucí stav:



OPS Brain

&#x20; ↓

Scheduler

&#x20; ↓

Autonomous Dispatcher

&#x20; ↓

Worker

&#x20; ↓

Audit

&#x20; ↓

OPS Brain



Uzavřená autonomní smyčka.



SPORT COMPLETION DASHBOARD



Byl vytvořen nový přehled:



Core readiness

People readiness

Media readiness

Historical coverage

Sport readiness score



Výstup:



SPORT\_READY

SPORT\_NEAR\_READY

SPORT\_PARTIAL

DATA\_GAP



Dashboard se stává hlavním ukazatelem dokončenosti sportu.



AKTUÁLNÍ STAV SPORTŮ



Podle posledního auditu:



READY

Football

Hockey

Basketball

Handball

Volleyball

Rugby

Cricket

American Football

Tennis



Core vrstva potvrzena.



PEOPLE



Nejlépe připraveno:



Football

Basketball

American Football



Další sporty budou doplněny podle dostupnosti providerů.



DŮLEŽITÉ PRAVIDLO



Pokud některý provider neumí:



players

coaches

stats

odds

media



neznamená to blokaci sportu.



Najde se jiný provider.



Každá vrstva může používat jiný zdroj.



Toto je základní architektonické pravidlo MatchMatrix.



OPS TABULKY JSOU ZDROJ PRAVDY



Definitivně potvrzeno:



Textové dokumenty slouží pouze jako dokumentace.



Zdroj pravdy:



ops.runtime\_entity\_audit

ops.sport\_completion\_audit

ops.provider\_entity\_coverage

ops.ingest\_planner

ops.job\_runs



a další OPS objekty.



DALŠÍ PRIORITA

111\_S V5



Dokončit:



lepší scoring Brainu

odstranění duplicit akcí

MEDIA priority engine

PEOPLE priority engine

health scoring providerů

doporučování oprav

NÁSLEDUJÍCÍ VELKÝ KROK



Autonomous Dispatcher.



Cíl:



OPS Brain

&#x20;   ↓

vygeneruje akci

&#x20;   ↓

Dispatcher

&#x20;   ↓

spustí worker

&#x20;   ↓

worker provede ingest

&#x20;   ↓

audit

&#x20;   ↓

OPS Brain vyhodnotí výsledek



První skutečně autonomní verze MatchMatrix.



DLOUHODOBÝ CÍL



Vybudovat plně autonomní multisport platformu:



Core Layer

Odds Layer

People Layer

Media Layer

Community Layer

AI Layer



pro profesionální i ověřené amatérské soutěže podle dlouhodobé vize projektu.



Tímto bude zítra nový chat navazovat přes aktuální MASTER a poslední dokončený krok bude 111\_S Autonomous OPS Brain V4 → pokračování V5

