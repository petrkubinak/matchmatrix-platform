# MATCHMATRIX_AUDIT_MASTER.md

## 1. Účel projektu

MatchMatrix je budovaný jako globální sportovní datová a analytická platforma.  
Cílem je:

- vytvořit robustní databázi pro co nejvíce sportů
- pokrýt soutěže co nejhlouběji, ideálně až do nižších úrovní
- držet aktuální i historická data
- provozovat nad nimi statistiky, ratingy, predikce a Ticket Intelligence
- nabídnout webovou platformu pro uživatele po celém světě
- zůstat poradním systémem, ne bookmakerem

## 2. Hlavní pilíře projektu

### 2.1 Datová platforma
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

### 2.2 Historická vrstva
- 5 až 8 sezon zpět pro modely, statistiky a predikce
- desítky let zpět pro fanouškovskou a databázovou hodnotu

### 2.3 Aktuální vrstva
- aktuální soutěže
- aktuální zápasy
- aktuální kurzy
- Ticket Studio nad aktuálními daty

### 2.4 Ticket Intelligence
- generování tiketů a variant
- ukládání do DB
- historie a settlement
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

## 3. Aktuální architektura systému

### 3.1 OPS
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

### 3.2 STAGING
Surová a mezivrstva ingestu před merge do finálních tabulek.

### 3.3 WORK
Pomocná pracovní vrstva pro mezikroky, dávky, ruční doplnění a čištění.

### 3.4 PUBLIC
Finální produktová a aplikační vrstva:
- sportovní data
- Ticket Studio
- historie tiketů
- settlement
- analytika a pattern stats

## 4. Auditní závěr k OPS

OPS je už dnes robustní a dobře navržené.  
Problém není, že by chyběla architektura. Problém je, že vedle core logiky stále existují přechodové, testovací a sport-specifické vrstvy, takže je provozně horší orientace.

### 4.1 OPS core autority
- provider_sport_matrix = co provider umí
- sport_dimension_rules = jak se sport chová
- sport_entity_rules = které entity dávají pro sport smysl
- ingest_entity_plan = jak se entity ingestují pro provider a sport
- ingest_targets = co konkrétně chceme stahovat
- ingest_planner = co je ve frontě
- provider_jobs = jak se job technicky spouští

## 5. Audit ingest coverage

### 5.1 Technicky připravené sporty se základem leagues/teams/fixtures
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

### 5.2 Rozšíření nad základ
- api_football: player_stats = TECH_READY
- api_hockey: players = TECH_READY
- api_hockey: coaches = TECH_READY

### 5.3 Placeholder sporty
- api_tennis
- api_mma
- api_darts
- api_esports

### 5.4 Hlavní realita
Mnoho entit je v ingest_entity_plan nastaveno jako enabled=true, ale reálně jsou jen PLACEHOLDER bez plného technického napojení.

## 6. Audit planner reality

### 6.1 Fotbal
- fixtures: část done, ale obrovský zbytek stále pending
- teams: část done, ale obrovský zbytek stále pending
- players: něco done, část error, hodně pending
- odds: bez hotových běhů

### 6.2 Hokej
- teams a fixtures: částečně rozběhnuté
- coaches: částečně hotové
- leagues: mix done/pending/error
- odds a players: převážně pending

### 6.3 Basket přes api_sport
- fixtures a teams: částečně done
- leagues: error

### 6.4 Ostatní sporty
U mnoha sportů je jen jediný pokus leagues a ten skončil error, nebo je planner téměř prázdný.

## 7. Hlavní auditní závěr

MatchMatrix je dnes:
- silný architekturou
- slušně rozjetý ve fotbalu
- částečně rozjetý v hokeji a basketu
- strukturálně připravený pro další sporty
- ale zatím není produkčně hotový jako plně funkční multisport ingest systém

Je to stav:
**robustní základ + částečně funkční sporty + mnoho placeholderů**

## 8. Hlavní nedostatky

### 8.1 Kritické nedostatky
1. enabled=true neznamená provozně funkční
2. chybí jednotné rozlišení stavů entity:
   - PLACEHOLDER
   - TECH_READY
   - RUNTIME_TESTED
   - PRODUCTION_READY
   - BLOCKED_BY_PROVIDER
3. staging potřebuje pročistit a sjednotit
4. public potřebuje kontrolu, pročistit a dopropojovat
5. odds/players/coaches jsou mimo fotbal a hokej většinou slabé nebo jen připravené
6. placeholder sporty nejsou provozně rozjeté
7. planner ukazuje velké množství pending položek a jen omezené done výsledky

### 8.2 Provozní nedostatky
1. v OPS se dá ztratit kvůli množství views a speciálních vrstev
2. není ještě dostatečně jasné, co je core, co test a co legacy
3. chybí oficiální coverage matice sport × entity × stav

## 9. Doporučené pořadí prací

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
Teprve potom plošně otevírat další sporty.

## 10. Checklist k odškrtávání

### A. Vize a směr
- [x] MatchMatrix = globální sportovní databáze + analytika + ticket intelligence
- [x] Ticket Studio je aktuálně hlavní learning vstup
- [ ] Web a mobil jako další learning vstup
- [x] Primární cíl teď = dostat DB do stabilního stavu
- [ ] Navazující cíl = plně funkční web pro uživatele
- [ ] Sepsat oficiální definici produktu v 1 dokumentu

### B. OPS
- [x] OPS schema existuje a je robustní
- [x] OPS má core tabulky pro plán, frontu, joby, providery a pravidla
- [ ] Sepsat oficiální mapu OPS core tabulek
- [ ] Oddělit core views od test/spec views
- [ ] Určit přechodové a starší OPS prvky

### C. Ingest coverage
- [x] Máme výpis ingest_entity_plan
- [x] Máme technickou coverage matici
- [x] Je potvrzeno, že mnoho sportů má základní trio leagues/teams/fixtures
- [x] Je potvrzeno, že mnoho dalších entit je zatím jen strukturálně zapsaných
- [ ] Zavést rozlišení PLACEHOLDER / TECH_READY / RUNTIME_TESTED / PRODUCTION_READY / BLOCKED
- [ ] Vytvořit finální coverage matici po sportech a entitách
- [ ] Označit entity provozně ověřené
- [ ] Označit entity produkčně použitelné

### D. Reálný provoz planneru
- [x] Máme základní přehled done/pending/error podle provider/sport/entity
- [ ] Vyhodnotit planner coverage po sportech detailně
- [ ] Označit sporty s největším počtem pending bez výsledku
- [ ] Označit sporty s největším počtem error
- [ ] Oddělit ready sporty od experimentálních

### E. Data vrstvy
- [ ] Pročistit staging
- [ ] Identifikovat a odstranit paralelní staging logiku
- [ ] Zkontrolovat public strukturu
- [ ] Rozlišit core public tabulky od pomocných a legacy

### F. Ticket vrstva
- [ ] Dokončit audit runtime ticket vrstvy
- [ ] Dokončit audit history/variants/settlement vrstvy
- [ ] Určit finální learning core tabulky
- [ ] Zkontrolovat ticket_history_base na chybějící atributy

### G. Learning a produkt
- [ ] Definovat finální learning atributy
- [ ] Definovat scoring variant
- [ ] Definovat risk scoring
- [ ] Definovat webovou produktovou vrstvu
- [ ] Definovat monetizační vrstvy

## 11. Nejbližší doporučený další krok
Vytvořit detailní audit planneru po sportech a určit:
- co je runtime tested
- co je production ready
- co je pouze technicky připravené
- co je blokované providerem nebo nefunkčním endpointem
