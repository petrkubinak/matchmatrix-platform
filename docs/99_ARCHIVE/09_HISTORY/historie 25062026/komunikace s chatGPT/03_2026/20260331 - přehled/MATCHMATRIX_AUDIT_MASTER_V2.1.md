# MATCHMATRIX_AUDIT_MASTER_V2.md

## 1. Účel projektu

MatchMatrix je budovaný jako globální sportovní datová a analytická platforma.  
Cílem projektu je:

- vytvořit robustní databázi pro co nejvíce sportů
- pokrýt soutěže co nejhlouběji, ideálně i do nižších úrovní
- držet aktuální i historická data
- nad daty provozovat statistiky, ratingy, predikce a Ticket Intelligence
- nabídnout webovou platformu pro uživatele po celém světě
- zůstat poradním systémem, ne bookmakerem

---

## 2. Tvoje potvrzená vize projektu

### 2.1 Datová vrstva
- sporty
- soutěže
- sezóny
- týmy
- zápasy
- hráči
- trenéři
- kurzy
- standings
- statistiky
- ratingy

### 2.2 Historie
- 5 až 8 sezon zpět pro modely, statistiky a predikce
- desítky let zpět pro fanouškovskou a databázovou hodnotu

### 2.3 Aktuální vrstva
- aktuální soutěže
- aktuální zápasy
- aktuální kurzy
- Ticket Studio nad aktuálními daty

### 2.4 Ticket Intelligence
- generování tiketů a variant
- ukládání tiketů do DB
- history a settlement
- learning nad variantami
- budoucí doporučování vhodných bloků a fixů

### 2.5 Web a produkt
- web pro uživatele
- později mobil
- účty, předplatné, personalizace
- advisory model, ne sázení

### 2.6 Uživatelská data
- do budoucna možnost přidávat amatérské soutěže a týmy
- schvalovací workflow
- ratingy i pro amatérské týmy

---

## 3. Nejpodstatnější dnešní upřesnění

Tohle je zásadní:

### 3.1 Aktuálně jsi ve fázi přípravy
Nemáš zatím placené účty u providerů. Vše běží na free režimu.

### 3.2 Cíl dneška nebyl „stahovat všechno hned“
Cíl dneška byl:
- připravit architekturu
- připravit OPS planner
- připravit coverage logiku
- připravit provider priority logiku
- být připraven na měsíc placeného účtu tak, aby šlo vytěžit maximum dat

### 3.3 Po zaplacení PRO plánu musí systém fungovat jako harvest engine
To znamená:
- vědět, co je kde dostupné
- vědět, co ještě nemáme stažené
- vědět, co má vyšší prioritu
- vědět, co stahovat dnes a co zítra
- umět rozdělit limity mezi sporty a entity

---

## 4. Architektura systému

### 4.1 OPS
Řídicí centrum ingestu a provozu:
- ingest_targets
- ingest_entity_plan
- ingest_planner
- provider_jobs
- provider_sport_matrix
- sports_import_plan
- worker_locks
- job_runs
- dashboard a kontrolní views

### 4.2 STAGING
Surová a mezivrstva ingestu před merge do finálních tabulek.

### 4.3 WORK
Pomocná pracovní vrstva pro mezikroky, dávky, ruční doplnění a čištění.

### 4.4 PUBLIC
Finální produktová a aplikační vrstva:
- sportovní data
- Ticket Studio
- historie tiketů
- settlement
- analytika a pattern stats

---

## 5. Auditní závěr k OPS

OPS je už dnes robustní a správně navržené.  
Problém není v tom, že by chyběla architektura.  
Problém je, že vedle core logiky stále existují přechodové, testovací a sport-specifické vrstvy, takže je provozně horší orientace.

### 5.1 OPS core autority
- provider_sport_matrix = co provider umí
- sport_dimension_rules = jak se sport chová
- sport_entity_rules = které entity dávají pro sport smysl
- ingest_entity_plan = jak se entity ingestují pro provider a sport
- ingest_targets = co konkrétně chceme stahovat
- ingest_planner = co je ve frontě
- provider_jobs = jak se job technicky spouští

### 5.2 Důležité dnešní potvrzení
Planner v OPS je správně nachystaný jako mozek budoucího harvest režimu.  
Nejde jen o frontu jobů. Jde o budoucí systém, který po zaplacení PRO účtu rozhodne:
- co stáhnout
- odkud to stáhnout
- kdy to stáhnout
- co odložit na další den

---

## 6. Audit ingest coverage

### 6.1 Technicky připravené sporty se základem leagues/teams/fixtures
- api_football (FB)
- football_data (FB)
- api_hockey (HK)
- api_basketball (BK)
- api_sport (BK)
- api_volleyball (VB)
- api_handball (HB)
- api_baseball (BSB)
- api_rugby (RGB)
- api_cricket (CK)
- api_field_hockey (FH)
- api_american_football (AFB)

### 6.2 Rozšíření nad základ
- api_football: player_stats = runtime_tested
- api_hockey: leagues, teams, fixtures = runtime_tested
- api_hockey: coaches = tech_ready
- theodds: FB odds = runtime_tested
- football_data: FB leagues/teams/fixtures = runtime_tested

### 6.3 Placeholder sporty
- api_tennis
- api_mma
- api_darts
- api_esports

### 6.4 Hlavní realita
Mnoho entit je v ingest_entity_plan nebo coverage logice zapsáno jako enabled / planned / tech_ready, ale to ještě neznamená produkčně funkční ingest.

---

## 7. Dnešní nový klíčový posun

Dnes vznikla a byla naplněna nová řídicí vrstva:

### 7.1 ops.provider_entity_coverage
Tato tabulka je nový centrální mozek pro:
- provider × sport × entity
- coverage status
- provider priority
- merge priority
- fetch priority
- quality rating
- free vs paid dostupnost
- primary vs fallback role
- notes, limitations, next_action

### 7.2 Proč je zásadní
Bez této vrstvy planner neví:
- který provider je hlavní
- který provider je fallback
- co je jen free-limitované
- co dává smysl pustit až po placeném účtu
- co nemá smysl řešit teď
- co bude první harvest cíl po aktivaci PRO

---

## 8. Audit provider strategie

### 8.1 Nejde o „vybrat jednoho providera“
Správný model MatchMatrix je:
- více providerů paralelně
- best source per entity
- fallback source pro doplnění
- canonical merge do public vrstvy

### 8.2 Potvrzený model
Nesnažit se:
- jeden provider na všechno

Ale:
- kombinovat zdroje podle entity

---

## 9. Aktuální provider strategie podle dnešního stavu

### 9.1 Fotbal
#### Primary / hlavní
- api_football = hlavní deep provider pro leagues, teams, fixtures, players, player_stats
- theodds = hlavní odds provider

#### Secondary / fallback / history
- football_data = fallback a historický provider pro leagues, teams, fixtures
- sportdataapi = budoucí doplňkový provider
- pinnacle = budoucí odds doplněk
- betfair = budoucí odds doplněk
- sportradar = dlouhodobá enterprise budoucnost

#### Auditní závěr
Fotbal je hlavní AI a ticket sport projektu.

### 9.2 Hokej
#### Primary
- api_hockey = hlavní provider pro leagues, teams, fixtures, coaches

#### Problém
- players jsou aktuálně vyhodnocené jako blocked / problematické

#### Auditní závěr
Hokej je druhý nejdále, ale bez silné players vrstvy.

### 9.3 Basket
- api_basketball = základní skeleton
- api_sport = základní skeleton

Auditní závěr:
- zatím základní data
- ne hluboký AI sport

### 9.4 Volleyball
- api_volleyball = základní skeleton

### 9.5 Ostatní týmové sporty
- AFB, BSB, CK, FH, HB, RGB = základní skeleton
- leagues/teams/fixtures připravené
- odds/players/coaches většinou jen planned

### 9.6 Placeholder sporty
- TN, MMA, DRT, ESP = budoucnost, ne současná harvest priorita

---

## 10. Reálný dnešní stav projektu

### 10.1 Co už existuje a je správně
- silná OPS architektura
- planner připravený na budoucí harvest mód
- coverage + priority tabulka
- Ticket Studio
- runtime ticket engine
- history a settlement vrstvy
- public datový model
- auditní základ

### 10.2 Co ještě není dotažené
- plně funkční multisport ingest
- vyčištěný staging
- dopropojovaný public
- jednotná coverage matice s runtime a production stavem
- harvest řízení podle request budgetu
- detailní progress reporting proti cílovému plánu

---

## 11. Hlavní nedostatky

### 11.1 Kritické nedostatky
1. enabled=true neznamená provozně funkční
2. chybí finální rozlišení stavů:
   - planned
   - tech_ready
   - runtime_tested
   - production_ready
   - blocked
3. staging potřebuje pročistit a sjednotit
4. public potřebuje kontrolu, pročistit a dopropojovat
5. players/coaches/odds mimo fotbal a část hokeje nejsou provozně dotažené
6. placeholder sporty nejsou připravené pro skutečný harvest
7. planner zatím neřídí harvest na základě coverage + priority + free/paid logiky

### 11.2 Provozní nedostatky
1. v OPS se dá ztratit kvůli množství views a speciálních vrstev
2. není ještě dostatečně jasné, co je core, co test a co legacy
3. chybí oficiální coverage matice sport × entity × stav
4. chybí harvest dashboard:
   - kolik máme staženo
   - kolik chybí
   - kolik requestů zbývá
   - co je zítra v plánu

---

## 12. Co dnes přesně navazuje na co

### 12.1 Logika toku
1. provider_sport_matrix říká, co provider umí
2. sport_dimension_rules a sport_entity_rules říkají, co dává smysl pro sport
3. ingest_entity_plan říká, co je technicky připravené
4. provider_entity_coverage říká priority a realitu free/paid/quality
5. ingest_targets říká, co chceme stáhnout
6. ingest_planner z toho dělá konkrétní práci
7. panel V9 to spouští a sleduje
8. staging chytá raw data
9. public drží canonical vrstvu
10. Ticket Studio a analytika nad tím staví další vrstvy

### 12.2 Správný cílový model
Ne:
- ruční spouštění chaotických jobů

Ale:
- coverage + targets + planner + panel + daily harvest orchestrace

---

## 13. Doporučené pořadí prací

### Fáze 1
Dotáhnout sporty s největší návratností:
1. fotbal
2. hokej
3. basket
4. volejbal

### Fáze 2
U těchto sportů rozšířit hloubku:
- odds
- players
- coaches
- standings
- stats

### Fáze 3
Vyčistit staging a public strukturu.

### Fáze 4
Napojit panel a planner na coverage + priority logiku.

### Fáze 5
Zavést harvest reporting:
- co máme
- co chybí
- jaký je stav proti plánu
- co se má stáhnout další den

### Fáze 6
Teprve potom ve větším rozsahu otevírat další sporty a další providery.

---

## 14. Praktický harvest cíl před zaplacením PRO účtu

Před zaplacením placeného účtu musí být připravené:

- coverage tabulka
- provider priority logika
- fetch priority logika
- merge priority logika
- planner workflow
- run groups
- targets
- panelové čtení stavu
- kontrola backlogu
- reporting postupu proti plánu

Tedy:
**nejen ingest, ale celý harvest systém**

---

## 15. Checklist k tisku

### A. Vize a směr
- [x] MatchMatrix = globální sportovní databáze + analytika + ticket intelligence
- [x] Ticket Studio je aktuálně hlavní learning vstup
- [ ] Web a mobil jako další learning vstup
- [x] Primární cíl teď = dostat DB do stabilního a harvest-ready stavu
- [ ] Navazující cíl = plně funkční web pro uživatele
- [ ] Sepsat oficiální definici produktu v 1 dokumentu

### B. OPS
- [x] OPS schema existuje a je robustní
- [x] OPS má core tabulky pro plán, frontu, joby, providery a pravidla
- [x] Je potvrzeno, že planner je správný základ pro budoucí harvest režim
- [ ] Sepsat oficiální mapu OPS core tabulek
- [ ] Oddělit core views od test/spec views
- [ ] Určit přechodové a starší OPS prvky

### C. Coverage a provider logika
- [x] Máme ops.provider_entity_coverage
- [x] Máme první seed provider priority logiky
- [x] Máme free vs paid základ
- [x] Máme primary vs fallback logiku
- [ ] Doplnit production_ready stav
- [ ] Doplnit blocked_by_provider logiku tam, kde to dává smysl detailněji
- [ ] Dovyplnit notes / limitations / next_action pro všechny důležité entity

### D. Ingest coverage
- [x] Máme výpis ingest_entity_plan
- [x] Máme technickou coverage matici
- [x] Je potvrzeno, že mnoho sportů má základní trio leagues/teams/fixtures
- [x] Je potvrzeno, že mnoho dalších entit je zatím jen planned
- [ ] Vytvořit finální coverage matici po sportech a entitách
- [ ] Označit entity runtime ověřené
- [ ] Označit entity produkčně použitelné

### E. Planner a runtime realita
- [x] Máme základní přehled done/pending/error podle provider/sport/entity
- [ ] Přenést runtime klasifikaci do coverage nebo view
- [ ] Označit sporty s největším pending backlogem
- [ ] Označit sporty s největším error rizikem
- [ ] Rozdělit sporty na:
  - production_ready
  - runtime_tested
  - tech_ready
  - planned
  - blocked

### F. Data vrstvy
- [ ] Pročistit staging
- [ ] Identifikovat a odstranit paralelní staging logiku
- [ ] Zkontrolovat public strukturu
- [ ] Rozlišit core public tabulky od pomocných a legacy

### G. Ticket vrstva
- [ ] Dokončit audit runtime ticket vrstvy
- [ ] Dokončit audit history/variants/settlement vrstvy
- [ ] Určit finální learning core tabulky
- [ ] Zkontrolovat ticket_history_base na chybějící atributy

### H. Learning a produkt
- [ ] Definovat finální learning atributy
- [ ] Definovat scoring variant
- [ ] Definovat risk scoring
- [ ] Definovat webovou produktovou vrstvu
- [ ] Definovat monetizační vrstvy

### I. Harvest připravenost před PRO
- [x] Máme planner základ
- [x] Máme coverage základ
- [x] Máme provider priority základ
- [ ] Napojit coverage logiku na planner
- [ ] Napojit coverage logiku na panel V9
- [ ] Zavést stav: co máme staženo vs co chybí
- [ ] Zavést denní harvest reporting
- [ ] Zavést „co se stáhne zítra“ logiku
- [ ] Připravit request budget strategii na 7500 req / den / sport

---

## 16. Nejbližší doporučený další krok

Další správný krok je:

### 16.1 Vytvořit view pro panel a planner
Cíl:
- číst provider coverage + priority + runtime realitu z jednoho místa

### 16.2 Panel V9
Doplnit do panelu:
- coverage status
- priority
- free vs paid
- progress proti plánu
- co je dnes připraveno ke stahování
- co se plánuje na zítra

### 16.3 Planner
Napojit planner na:
- provider_entity_coverage
- priority
- harvest-ready logiku

---

## 17. Shrnutí jednou větou

MatchMatrix dnes už není jen databáze a pár ingest skriptů.  
Je to rozestavěný **multi-provider harvest a analytický systém**, který je potřeba ještě dotažením coverage, planner logiky, staging/public čistoty a panelového reportingu připravit na krátké, ale maximálně vytěžené PRO období.
