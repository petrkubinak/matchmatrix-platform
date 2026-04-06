MATCHMATRIX – ZÁPIS A PLÁN NA DALŠÍ FÁZI
1. Kde teď skutečně jsme

Projekt už má silnou architekturu:

ops jako řídicí vrstvu,
staging jako ingest mezivrstvu,
public jako finální produktovou vrstvu,
planner, coverage logiku, provider priority, panel a auditní základ.

Současně ale platí důležitá realita:

Není pravda, že je připravený plný multisport harvest

Reálně je dnes stav takový:

FB: nejdále
HK: částečně reálně ověřené
BK: něco připravené, ale ne plně potvrzené
VB: něco připravené, ale ne plně potvrzené
ostatní sporty: hlavně pravidla, coverage, priority, entity, ale ne hotová end-to-end execution cesta.

To znamená:

hlavní cíl další fáze není

„spustit všechno najednou“

hlavní cíl další fáze je

projít sport po sportu, potvrdit skutečnou runtime připravenost, dopsat chybějící execution kroky, a teprve potom složit celkový orchestrátor.

2. Strategický směr

Bylo potvrzeno, že:

panel má být servisní, monitorovací a nouzové okno,
automat 24/7 má být hlavní produkční režim.

To je přesně směr, který teď budeme připravovat:

cílový stav

Automat:

sám rozhodne, co běží,
sám to spustí,
sám vyhodnotí výsledek,
a tobě pošle jen:
co proběhlo,
co selhalo,
co je potřeba upravit.
3. Co přesně budeme dělat krok za krokem

Budeme postupovat sport po sportu.

U každého sportu projdeme stejnou osnovu:

A. Provider realita

Zjistit:

který provider je pro sport skutečně použitelný dnes,
který je fallback,
co je jen planned,
co je runtime tested,
co je production usable.
B. Entity realita

Prověřit pro sport:

leagues
teams
fixtures
odds
players
player_stats
coaches
standings
C. Execution cesta

Zjistit:

jak se to opravdu spouští,
jestli přes unified runner,
legacy skript,
panel,
batch,
nebo ruční SQL návaznost.
D. Datový tok

Ověřit:

kam jdou raw data,
co jde do staging,
co jde do public,
co se případně obchází legacy větví.
E. Post-run návaznosti

Zjistit, co se musí po ingestu ještě dopočítat:

standings,
form,
ratings,
features,
případně downstream refresh pro Ticket Studio.
F. Runtime verdict

Každý sport dostane jen jeden finální stav:

AUTOMAT_READY
VALIDATE_FIRST
PARTIAL_ONLY
NOT_READY
G. Chybějící kroky do orchestrátoru

U každého sportu zapíšeme:

co chybí dodělat,
co jde pustit hned,
co se musí před PRO měsícem ještě připravit.
4. Pořadí sportů

Půjdeme v tomto pořadí:

1. FB – Football

Protože:

je hlavní AI a ticket sport,
má více provider větví,
přímo ovlivňuje Ticket Studio,
má nejvyšší návratnost.
2. HK – Hockey

Protože:

už má reálně ověřený ingest,
je druhý nejdůležitější z připravených sportů.
3. BK – Basketball

Protože:

už existuje částečná příprava,
ale je potřeba potvrdit execution realitu.
4. VB – Volleyball

Protože:

je částečně připravený,
ale nejspíš bude zatím spíš VALIDATE_FIRST.
5. Ostatní sporty

Zatím jen:

klasifikace,
definice chybějících kroků,
žádný ostrý harvest.
5. Co bude výsledkem této fáze

Na konci této série budeme mít:

A. finální whitelist sportů pro automat

Např.:

FB
HK
BK partial
VB partial
B. finální whitelist entit pro automat

Např.:

leagues
teams
fixtures
někde players
někde coaches
někde odds
jinde zatím ne
C. finální execution mapu

Pro každý sport:

čím se spouští,
v jakém pořadí,
co navazuje po doběhu.
D. podklad pro placený PRO měsíc

Abys ve chvíli, kdy aktivuješ placený účet, už:

nezjišťoval architekturu,
ale jen pustil připravený harvest engine a maximalizoval získaná data.
6. Zítřejší pracovní plán

Zítra nezačneme orchestrátorem.
Zítra začneme FB auditem, protože ten je nejdůležitější.

ZÍTŘEJŠÍ HLAVNÍ CÍL

Dokončit FB audit a vyrobit z něj první hotový harvest blueprint.

7. Časový harmonogram na zítřek

Ber to jako pracovní rytmus, ne jako tvrdé SLA.
Je to cílový plán, podle kterého se budeme držet tempa.

BLOK 1 — 08:00 až 09:00
FB – provider a execution audit

Projdeme:

api_football
football_data
theodds

Určíme:

primary provider
fallback provider
co je runtime použitelné
co je jen připravené
Výstup bloku:
FB provider mapa
FB execution realita
FB primary/fallback strategie
BLOK 2 — 09:00 až 10:30
FB – entity audit

Prověříme:

leagues
teams
fixtures
odds
players
player_stats
coaches
standings

U každé entity určíme:

funguje / nefunguje
automat / validate / manual
chybí worker / chybí downstream / blocked provider
Výstup bloku:
FB entity matice
co jde do automatu
co zatím ne
BLOK 3 — 10:30 až 11:30
FB – data flow audit

Projít:

OPS
staging
public
legacy větve
downstream refresh

Ověřit:

kudy jdou fixtures,
kudy jdou odds,
co se obchází legacy logikou,
co je třeba po doběhu dopočítat.
Výstup bloku:
FB end-to-end flow
seznam návazností po ingestu
BLOK 4 — 11:30 až 12:30
FB – runtime verdict + potřebné úpravy

V tomto bloku určíme:

co je AUTOMAT_READY
co je VALIDATE_FIRST
co je PARTIAL_ONLY

A sepsat:

co ještě chybí před zapojením do orchestrátoru
Výstup bloku:
FB harvest verdict
konkrétní TODO list
BLOK 5 — 13:30 až 15:00
HK – zkrácený audit

Stejná osnova jako u FB, ale rychleji:

provider realita
entity
execution
post-run návaznosti
verdict
Výstup bloku:
HK harvest verdict
BLOK 6 — 15:00 až 16:00
BK – realistická kontrola

Cíl:

potvrdit, co je skutečně použitelné
oddělit realitu od jen nadefinovaných pravidel
Výstup bloku:
BK = validate / partial / not ready
BLOK 7 — 16:00 až 17:00
VB – realistická kontrola

Cíl:

potvrdit základ
rozhodnout, zda má smysl zahrnout do první verze automatu
Výstup bloku:
VB verdict
BLOK 8 — 17:00 až 18:00
Syntéza dne

Sečteme:

FB verdict
HK verdict
BK verdict
VB verdict

A z toho připravíme:

první whitelist pro orchestrátor v1
které sporty
které entity
jaké execution režimy
co jde automaticky
co jen validací
8. Co bych chtěl mít hotové na konci zítřka

Ideální stav na konci zítřka:

Hotovo
FB audit
HK audit
BK audit
VB audit
finální whitelist pro automat v1
seznam blokujících bodů pro ostatní sporty
Ne nutně hotovo
samotný Python orchestrátor
mail notifikace
full scheduler režim

To přijde až po této auditní fázi.

9. Jak budeme pracovat v chatu

Aby to bylo plynulé a nepřekrývalo se to:

vždy 1 blok = 1 výstup

Například:

teď FB provider realita
potom FB entity
potom FB execution
potom FB verdict

Tím nevznikne chaos a bude jasné, na co přesně navazujeme.

To navazuje i na tvoji preferenci jít po jedné akci na odpověď. Ta je pro tenhle typ práce ideální.

10. Shrnutí jednou větou

Zítra nezačneme psát orchestrátor naslepo.
Zítra systematicky projdeme FB → HK → BK → VB, určíme skutečnou runtime připravenost, a teprve z toho postavíme první ostrý whitelist pro celkový harvest automat.

11. Start point na zítřek

Zítra začneme přesně větou:

„jedeme FB audit – blok 1 provider realita“

A tím navážeme přesně na tenhle plán.

Když budeš chtít, v dalším kroku mi doplníš:

jestli chceš harmonogram posunout časově,
jestli chceš přidat večerní/noční blok,
nebo jestli chceš některý sport přesunout dřív.