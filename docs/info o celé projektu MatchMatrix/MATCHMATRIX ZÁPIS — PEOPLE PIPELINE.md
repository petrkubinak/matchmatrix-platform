MATCHMATRIX ZÁPIS — PEOPLE PIPELINE DOKONČENÍ FB

Datum: 2026-06-01

CO JSME DNES DOKONČILI

Dokončili jsme audit a opravu celé PEOPLE vrstvy pro fotbal.

Byly opraveny:

ops.v_people_pipeline_summary_v1
ops.v_people_pipeline_audit_v1

Sjednotili jsme sport kódy:

football → FB
basketball → BK
hockey → HK
baseball → BSB
cricket → CK
american_football → AFB
field_hockey → FH

Doplnili jsme chybějící:

public.players.sport_id

pro všechny FB hráče.

FB PEOPLE FINÁLNÍ STAV
Provider: api_football

Raw payloads      : 412
Pending payloads  : 134
Parsed payloads   : 201

Staging players   : 5279
Public players    : 5314
Provider maps     : 5315

Coverage          : 100.00 %
Status            : READY

Důležité zjištění:

134 pending payloadů již neblokuje READY stav.

Důvod:

hráči jsou již v public.players
hráči jsou již v player_provider_map
coverage = 100 %

Proto je PEOPLE vrstva považována za dokončenou.

PEOPLE READY SPORTY
FB   Football
HK   Hockey
BK   Basketball
MMA  MMA
BSB  Baseball
CK   Cricket
AFB  American Football

Celkem:

7 sportů READY
PEOPLE DATA_GAP SPORTY
TN   Tennis
DRT  Darts
VB   Volleyball
HB   Handball
RGB  Rugby
FH   Field Hockey
ESP  Esports

Celkem:

7 sportů DATA_GAP
CO TO ZNAMENÁ PRO MATCHMATRIX

People vrstva je nyní dokončena pro:

Football
Hockey
Basketball
MMA
Baseball
Cricket
American Football

Tyto sporty již mají:

staging players
public players
provider mapping
OPS monitoring
Control Panel monitoring

a mohou být použity:

Profil hráče
Soupiska týmu
Statistiky hráčů
People Analytics
Player Ratings
Player Form
Player Comparison
AI analýzy
DALŠÍ DOPORUČENÝ KROK
TENNIS PEOPLE PIPELINE

Důvod:

Tennis už má připravené části ingest infrastruktury.
Má vlastní staging tabulky.
Je nejblíže dokončení z DATA_GAP sportů.

Cíl:

TN
0 → READY
DALŠÍ CHAT

Začít:

Pokračujeme MatchMatrix PEOPLE pipeline.

FB PEOPLE je dokončen:
coverage 100 %
status READY

READY sporty:
FB HK BK MMA BSB CK AFB

Chci začít připravovat TN Tennis PEOPLE pipeline.

Pošli první audit SQL.

Tím uzavíráme FB PEOPLE vrstvu jako READY a přecházíme na Tennis PEOPLE pipeline. 🚀