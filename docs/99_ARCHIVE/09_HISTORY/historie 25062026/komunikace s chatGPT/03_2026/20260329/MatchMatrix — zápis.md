MatchMatrix — zápis
Datum
2026
Hlavní cíl dneška

Vyřešit robustní databázovou vrstvu pro ligové tabulky / standings a současně opravit problém, proč v Premier League vycházelo nesmyslně 52 zápasů na tým místo reálného stavu.

Co jsme dnes dokončili
1. Založili jsme databázovou vrstvu pro standings

Byla vytvořena logika pro:

standings_rules
league_standings
refresh funkce pro přepočet tabulek
produktový whitelist lig pro Ticket Studio

Směr je správný:

robustní DB pro aktuální i historická data
rychlé čtení pro UI
základ pro detail zápasu, tabulky, formu a další analytiku
2. Naplnili jsme standings_rules

Byla připravena a naplněna pravidla bodování pro týmové sporty:

Football
Hockey
Basketball
Volleyball
Handball
Baseball
Rugby
Cricket
Field Hockey
American Football

Tím máme centrální bodovací logiku pro multi-sport databázi.

3. Vytvořili jsme league_standings

Tabulka se úspěšně naplnila a po refreshi měla:

8842 řádků

To potvrdilo, že základní výpočet tabulek nad public.matches funguje.

4. Zavedli jsme produktovou vrstvu pro Ticket Studio

Byla vytvořena tabulka:

public.product_active_leagues

A do ní byl zaveden whitelist pro aktivní soutěže Ticket Studia pro sezonu 2526, konkrétně:

Bundesliga
Campeonato Brasileiro Série A
Championship
Eredivisie
Ligue 1
Premier League
Primeira Liga
Primera Division
Serie A
Copa Libertadores
FIFA World Cup
European Championship
UEFA Champions League

Tím jsme oddělili:

širokou historickou DB
a produktovou vrstvu pro aktuální použití
5. Odhalili jsme hlavní problém v Premier League

Při kontrole Premier League league_id = 6, season = '2526' vycházelo:

all_rows = 520
distinct_matches = 260
duplicate_rows = 260

To znamená, že každý zápas byl uložen 2×.

Bylo ověřeno i na konkrétním příkladu:

Liverpool FC vs AFC Bournemouth

kde oba řádky byly stejné ve všem kromě ext_match_id prefixu:

1|2526|15/08/2025|Liverpool|Bournemouth
6|2526|15/08/2025|Liverpool|Bournemouth

Tedy:

nešlo o jiný zápas,
nešlo o jiný zdroj,
šlo o dvojitý insert stejného match řádku.

Duplicitní charakter stejné soutěže byl potvrzen i v auditním výpisu.

6. Opravili jsme duplicity v public.matches

Byl proveden cleanup pro football_data_uk podle identity zápasu:

league_id
season
kickoff
home_team_id
away_team_id
ext_source

a ignorovali jsme ext_match_id, protože právě ten falešně rozlišoval dva stejné zápasy.

Po cleanupu pro Premier League 2526 vyšlo správně:

260
260
0

tedy:

260 řádků celkem
260 unikátních zápasů
0 duplicit
7. Opravili jsme produktové standings

Po novém refreshi a znovuvytvoření view v_current_product_standings už Premier League 2526 vrací správnou tabulku o 20 týmech a 26 odehraných zápasech na tým.

Finální výsledek Premier League 2526:

Arsenal FC — 26 — 57 b
Manchester City FC — 26 — 53 b
Aston Villa FC — 26 — 50 b
Manchester United FC — 26 — 45 b
Chelsea FC — 26 — 44 b
Liverpool FC — 26 — 42 b
Brentford FC — 26 — 40 b
Everton FC — 26 — 37 b
AFC Bournemouth — 26 — 37 b
Newcastle United FC — 26 — 36 b
Sunderland AFC — 26 — 36 b
Fulham FC — 26 — 34 b
Crystal Palace FC — 26 — 32 b
Brighton & Hove Albion FC — 26 — 31 b
Leeds United FC — 26 — 30 b
Tottenham Hotspur FC — 26 — 29 b
Nottingham Forest FC — 26 — 27 b
West Ham United FC — 26 — 24 b
Burnley FC — 26 — 18 b
Wolverhampton Wanderers FC — 26 — 9 b

Tím je potvrzeno, že:

tabulka už počítá správně,
produktová vrstva funguje,
deduplikace zabrala.
Co je teď hotové
Datově hotové
standings_rules
league_standings
product_active_leagues
v_current_product_standings
deduplikace football_data_uk pro zápasy
Premier League 2526 ověřena jako správná
Architektonicky hotové
oddělení historické DB a produktové vrstvy
připravený základ pro detail zápasu
připravený základ pro zobrazení tabulky a formy v UI
Co je potřeba udělat dál
Další správný krok

Teď už neřešit znovu standings, ale napojit Ticket Studio detail zápasu (i) na novou databázovou vrstvu.

To znamená:

do okna detailu zápasu napojit:
domácí pozice v tabulce
hostující pozice v tabulce
body
skóre
forma:
posledních 5
posledních 10
posledních 15
případně rozdíl pozic a bodů
Jak pokračovat v novém chatu

Do nového chatu pošli tuto větu:

Pokračujeme v MatchMatrix. Máme hotové standings_rules, league_standings, product_active_leagues, odstraněné duplicity football_data_uk v matches a správně spočtenou Premier League 2526 v v_current_product_standings. Další krok: napojit detail zápasu v Ticket Studiu (ikona i) na tabulku, formu 5/10/15 a produktovou vrstvu.

První konkrétní krok v novém chatu

Hned navážeme na:

V3_fix11 / V3_fix12 — napojení okna i na DB

v_current_product_standings
forma 5/10/15
pozice týmů
body
stručné shrnutí
Krátké shrnutí jednou větou

Dnes jsme vybudovali a ověřili robustní databázovou vrstvu ligových tabulek, našli a odstranili dvojité inserty zápasů v football_data_uk, a dostali produktovou Premier League 2526 do správného stavu s 26 odehranými zápasy na tým.