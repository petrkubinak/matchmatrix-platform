MatchMatrix – zápis dneška
Téma: TheOdds parser, Ticket Studio odds coverage, identita týmů
1. Co jsme dnes definitivně potvrdili
Players mimo fotbal

Dřívější zjištění se potvrdilo jako správné strategické rozhodnutí:

API-Sports players mimo fotbal nejsou teď vhodné pro bulk ingest
hockey players endpoint neexistuje
basketball players endpoint je prakticky nepoužitelný pro ingest
volleyball / handball players endpoint není použitelný
Strategický závěr

Players teď neřešit.
Priorita zůstává:

Ticket Engine
matches
odds
predictions
Ticket Studio
2. Ticket Studio / UI stav
Co už funguje

Ticket Studio už není jen admin tabulka, ale reálně začíná fungovat jako produktové UI:

načítání zápasů
zobrazení kurzů
odds buttons
slip
zápis do DB
část kurzů se v UI už zobrazuje správně
Důležitý posun

Na začátku nebyly v Ticket Studiu skoro žádné kurzy.
Po úpravách TheOdds parseru se odds do DB začaly reálně ukládat a Ticket Studio už začalo kurzy zobrazovat.

3. Co jsme řešili na TheOdds parseru

Soubor:

C:\MatchMatrix-platform\ingest\theodds_parse_multi_FINAL.py
Postupně jsme odhalili tyto vrstvy problému:
A. Guard teams_present < 35

Byl příliš tvrdý.
Ligu zbytečně označoval jako RAW-only, i když TheOdds posílal validní subset trhu.

Výsledek
guard jsme odblokovali
leagues_raw_only šlo na 0
parser začal zpracovávat víc lig
B. find_match_id() měl příliš úzké časové okno

Původně bylo párování moc přísné.
Ukázalo se, že v DB některé fixtures existují, ale mají jiný kickoff než TheOdds.

Výsledek
rozšíření okna vedlo ke skoku v odds_inserted
parser začal nacházet víc zápasů
C. Aliasy a team matching

Postupně jsme doplnili TheOdds aliasy pro názvové varianty týmů.

Například:

Flamengo-RJ
Corinthians-SP
Palmeiras-SP
Libertad Asuncion
další
Výsledek
skipped_no_team se snížilo
ale ukázalo se, že aliasy nejsou hlavní finální problém
4. Hlavní dnešní zjištění – skutečný kořen problému
Klíčový problém už není parser samotný

Největší problém je:

duplicitní canonical team větve v public.teams

To znamená, že pro stejný klub existuje víc team_id, například z různých providerů:

football_data
football_data_uk
api_football
api_sport

A pak vzniká situace:

TheOdds resolver najde tým
ale namapuje ho na jiný team_id
než jaký používá public.matches
a find_match_id() pak zápas nenajde
Praktický příklad

U Arsenal / Bournemouth jsme ověřili:

TheOdds mapoval na jednu větev
matches používaly jinou větev
zápas v DB existoval
ale přes jiné team_id

Tím se definitivně potvrdilo, že:

ladíme identitu týmů v DB, ne jen TheOdds parser

5. Co jsme auditovali

Udělali jsme audit duplicitních větví týmů a jejich usage v matches.

Dnešní důležité výsledky

Pro klíčové týmy jsme získali přehled:

Arsenal
11910 → api_football → matches_used = 114
13102 → api_football → matches_used = 36
26871 → api_sport → matches_used = 1
1 → orphan / nepoužívaná větev → 0
Bournemouth
11905 → api_football → matches_used = 114
948 → football_data_uk → matches_used = 0
Lille OSC
504 → football_data → matches_used = 304
OGC Nice
505 → football_data → matches_used = 304
Sporting Clube de Braga
587 → football_data → matches_used = 294
Sporting Clube de Portugal
87 → football_data → matches_used = 304
6. Co z toho plyne
Master větve, které jsou teď správné

Pro tyto týmy už víme, která team_id větev je hlavní:

Arsenal → 11910
Bournemouth → 11905
Lille OSC → 504
OGC Nice → 505
Sporting Clube de Braga → 587
Sporting Clube de Portugal → 87
Důležitý závěr

Další ladění parseru už přináší jen malé zisky, pokud neuděláme:

sjednocení duplicitních canonical team větví

7. Současný reálný stav parseru

Poslední běhy ukazují:

parser už odds umí vkládat
Ticket Studio už odds umí číst
skipped_no_team je už menší problém
hlavní brzda je stále skipped_no_match
a to kvůli rozdělené týmové identitě
Prakticky

To znamená:

systém už funguje
ale není ještě stabilní
protože není sjednocená fotbalová team identity layer
8. Co se dnes ještě ukázalo

Když jsi napsal „co se děje“, šlo jen o to, že se do chatu propsal velký DB výpis / audit.
Nebyla to chyba projektu.
Naopak to pomohlo potvrdit, že v dumpu už máš i připravené mechanismy pro merge týmů.

9. Hlavní finální závěr dneška
Už neřešíme
další malé regexy donekonečna
další náhodné aliasy bez systému
players mimo fotbal
Teď řešíme

sjednocení duplicitních fotbalových týmů do jedné canonical osy

To je teď nejdůležitější vrstva pro:

odds
matches
predictions
Ticket Studio
budoucí multi-provider stabilitu
10. Doporučený další krok do nového chatu

Pokračovat tímto směrem:

pokračujeme: merge duplicitních football týmů na master team_id
začneme Arsenal + Bournemouth
Proč právě tohle

Protože už víme:

které větve jsou master
které jsou duplicitní
a další velký posun už nepřijde z parseru, ale ze sjednocení team_id
11. Krátký manažerský souhrn
Hotovo
Ticket Studio V2 funguje
TheOdds parser ukládá odds
odds se zobrazují v UI
identifikovali jsme hlavní příčinu zbývajících chyb
Nehotovo
sjednocení duplicitních team větví
stabilní mapování providerů na jednu canonical osu
úplné coverage napříč ligami
Priorita
merge duplicitních football týmů
stabilizace odds layer
teprve potom další rozšiřování