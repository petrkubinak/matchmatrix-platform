ZÁPIS NA DNEŠEK – PŘÍPRAVA NA ZÍTŘEK
1. Co jsme dnes připravili

Dnes jsme nepokračovali naslepo v panelu ani orchestrátoru, ale připravili jsme si správný start pro sportovní audit po jednotlivých sportech.

Bylo potvrzeno, že:

nechceme zatím spouštět harvest pro všechny sporty,
protože reálně připravené jsou hlavně:
FB
částečně HK
něco z BK
něco z VB,
zatímco ostatní sporty mají hlavně pravidla, priority, coverage a entity plán, ale ne hotovou execution vrstvu.

To znamená:
nejdřív audit sport po sportu, potom orchestrátor.

2. Co jsme dnes konkrétně nachystali pro FB
A. FB provider realita

Potvrdili jsme:

api_football = hlavní deep provider pro leagues / teams / fixtures
football_data = runtime fallback + history provider pro leagues / teams / fixtures
theodds = hlavní odds provider
players / coaches / season stats = až PRO režim, ne orchestrátor v1
B. FB entity audit tabulka

Byla vytvořena:

ops.fb_entity_audit

A naplněna pro entity:

leagues
teams
fixtures
odds
players
player_stats
player_season_stats
coaches
standings
C. Dnešní nejdůležitější výstup

Máme už první pracovní whitelist pro FB:

FB – automaticky / v1 kandidáti
odds
standings
FB – validate first
leagues
teams
fixtures
FB – zatím mimo v1
players
player_stats
player_season_stats
coaches
3. Co to znamená architektonicky

Pro FB už se začíná rýsovat první skutečný harvest model:

FB orchestrátor v1 nebude

„všechno z api_football“

FB orchestrátor v1 bude

hybrid:

api_football jako deep primary směr
football_data jako fallback/history směr
theodds jako primary odds
standings jako povinný downstream refresh po fixtures/results

To je správně a odpovídá MatchMatrix modelu „best source per entity“, ne „jeden provider na všechno“.

PLÁN NA ZÍTŘEK
Hlavní cíl

Zítra začneme skutečný audit sport po sportu, a první bude:

FB audit – blok 2 entity realita

Protože provider realitu už máme připravenou dnes.

Časový harmonogram na zítřek
08:00–09:00
FB – entity realita

Projdeme řádek po řádku ops.fb_entity_audit a definitivně rozhodneme:

co zůstane validate_only
co povýšíme na automatic
co zůstane manual_only
co je requires_pro
Výstup:

finální FB entity verdict

09:00–10:30
FB – execution flow

U každé entity potvrdíme:

jak se skutečně spouští
jestli unified / legacy / panel / batch
jaká je reálná execution cesta
Výstup:

FB execution mapa

10:30–11:30
FB – datový tok

Prověříme:

OPS
staging
public
legacy odbočky
downstream refresh
Výstup:

FB end-to-end flow

11:30–12:30
FB – runtime verdict

Rozhodneme:

co jde do orchestrátoru v1
co je jen validate
co je až PRO
co bude patřit do mail reportu
Výstup:

FB harvest blueprint

13:30–15:00
HK audit

Stejná logika jako u FB, ale zkráceně.

Výstup:

HK verdict

15:00–16:00
BK audit

Oddělit realitu od jen nadefinovaných pravidel.

Výstup:

BK verdict

16:00–17:00
VB audit

Potvrdit, co je opravdu připravené.

Výstup:

VB verdict

17:00–18:00
Syntéza dne

Sečteme:

FB
HK
BK
VB

a připravíme:

první whitelist sportů pro orchestrátor v1
první whitelist entit pro orchestrátor v1
Kde zítra přesně navážeme

Začneme větou:

„jedeme FB audit – blok 2 entity realita“

A první vstup už máme hotový:
ops.fb_entity_audit

Krátké shrnutí jednou větou

Dnes jsme připravili správný start pro celkový harvest audit: místo chaosu kolem „všech sportů najednou“ máme připravený první skutečný FB blueprint, na kterém zítra postavíme první část orchestrátoru.

Až zítra začneš, napiš jen:
„jedeme FB audit – blok 2 entity realita“