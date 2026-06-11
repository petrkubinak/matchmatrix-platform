MATCHMATRIX – ZÁPIS PRO NOVÝ CHAT
Datum: 05.06.2026

# AKTUÁLNÍ STAV PROJEKTU

Projekt MatchMatrix se nachází ve fázi, kdy je vybudována většina datového jádra, OPS vrstva, harvest infrastruktura a významná část People a Media Layer.

Máme:

* 120 000+ zápasů
* tisíce týmů
* tisíce hráčů
* PostgreSQL databázi
* staging/public architekturu
* Planner
* Scheduler
* OPS monitoring
* Provider Health
* People Layer základy
* Media Layer základy
* více sportů
* připravené harvest pipeline

Aktuální prioritou již není budování základní databáze, ale rozšiřování inteligentní vrstvy systému.

---

# NOVÁ INFRASTRUKTURA

## PC1 (současný Acer)

Role:

* PostgreSQL
* Redis
* Scheduler
* Planner
* OPS
* DBeaver
* VS Code

Plán:

* rozšířit RAM z 32 GB na 64 GB

---

## PC2 (nový server)

Vybraná sestava:

* Intel Core Ultra 9 285K
* ASUS PRIME RTX 5070 12G
* MSI MAG Z890 TOMAHAWK WIFI
* Kingston 64GB DDR5 (2x32GB)
* 2x Samsung 990 Pro 2TB
* ADATA XPG CORE REACTOR II 850W
* Fractal Design Pop Air Black Solid
* Noctua NH-D15 G2 HBC

Cena cca 78 700 Kč.

Role:

* Football Harvest
* Hockey Harvest
* Basketball Harvest
* People Layer
* Media Layer
* Historical Backfill
* AI experimenty
* Překlady článků
* AI sumarizace

Plán rozšíření:

Červenec:

* +64 GB RAM
* celkem 128 GB

Srpen:

* +4 TB NVMe
* celkem 8 TB NVMe

---

# DLOUHODOBÁ VIZE

Cílem není pouze sportovní databáze.

Cílem je vytvořit:

Největší sportovní databázi na světě.

Systém má pokrývat:

* profesionální sporty
* amatérské soutěže
* média
* statistiky
* kurzy
* predikce
* ticket engine
* AI vrstvu
* multijazyčný obsah

---

# AMATÉRSKÉ SOUTĚŽE

Jedna z klíčových konkurenčních výhod MatchMatrix.

Budoucí web umožní:

* registraci amatérské soutěže
* schválení administrátorem MatchMatrix
* správu soutěže
* správu týmů
* zadávání výsledků
* správu tabulek
* správu hráčů
* správu statistik

Po schválení bude amatérská soutěž fungovat podobně jako profesionální soutěž.

Automaticky:

* tabulky
* forma
* statistiky
* ratingy
* historie
* přehledy

---

# TICKET ENGINE

Klíčová funkcionalita projektu.

Nejde pouze o tvorbu tiketů.

Cíl:

Inteligentní návrh vhodných zápasů.

Například:

Uživatel vybere několik zápasů.

Systém:

* analyzuje formu
* analyzuje zranění
* analyzuje absenci klíčových hráčů
* analyzuje sílu soupeřů
* analyzuje motivaci týmů
* analyzuje historické výsledky
* analyzuje kurzy

Následně doporučí další vhodné zápasy do tiketu.

---

# MATCH INTELLIGENCE LAYER

Nejdůležitější budoucí vrstva.

Systém nebude pracovat pouze s databází.

Bude automaticky vyhledávat informace o konkrétních zápasech.

Například:

Domácí tým vs Hostující tým

Systém automaticky:

* najde oficiální web domácího týmu
* najde oficiální web hostujícího týmu
* najde ligový web
* stáhne články
* stáhne preview zápasu
* stáhne zprávy o zranění
* stáhne nominace
* stáhne informace o trenérech
* stáhne informace o absencích

---

# MATCH CONTEXT ENGINE

Nová plánovaná vrstva.

Automatický tok:

Zápas
↓
Vyhledání zdrojů
↓
Stažení článků
↓
AI analýza
↓
Vytažení faktů
↓
Uložení do DB
↓
Využití v predikci

---

# PLÁNOVANÉ TABULKY

120_A_create_match_context_engine_tables_v1.sql

Obsah:

team_sources

match_context_queue

match_context_facts

---

# PŘÍKLADY FAKTŮ

Typy:

INJURY

KEY_PLAYER_MISSING

COACH_CHANGE

LINEUP_NEWS

GOOD_FORM

BAD_FORM

TRANSFER

MOTIVATION

FATIGUE

TRAVEL

---

# BUDOUCÍ AI

Plánované využití RTX 5070:

* překlady článků
* AI shrnutí článků
* AI shrnutí zápasů
* AI klasifikace médií
* AI doporučení
* AI chatbot
* AI vyhledávání

---

# FILOZOFIE PROJEKTU

Frontend není první priorita.

Nejdříve:

1. Data
2. People Layer
3. Media Layer
4. Match Intelligence
5. Ticket Engine
6. Web

Web bude stavěn na silném datovém základu.

Cílem není vytvořit pouze sportovní web.

Cílem je vytvořit inteligentní sportovní platformu s největší sportovní databází na světě a unikátní analytickou vrstvou využitelnou pro sportovní fanoušky, amatérské soutěže i pokročilé tipování.

Ticket Engine není plánovaný od nuly.
V databázi již existuje rozsáhlá ticket vrstva:
tickets, ticket_blocks, ticket_variants, settlements, strategy catalog,
pattern stats, generated tickets, scenario blocks, recommendation feedback
a navazující views.

Další práce nebude tvorba základních tabulek, ale:
1. audit vazeb,
2. ověření settlement logiky,
3. napojení na Match Context Engine,
4. napojení na zranění / absence / články / formu,
5. vytvoření inteligentní vrstvy, která se učí z úspěšnosti tiketů.

Ticket Engine už není jen koncept.

V databázi již existují hlavní části:
- tickets
- ticket_blocks
- ticket_variants
- ticket_settlements
- ticket_pattern_stats
- ticket_strategy_catalog
- ticket_recommendation_feedback
- generated_tickets
- ml_predictions
- player_form
- team power views
- strategy ranking/recommendation views
- ticket history summary views

To znamená, že další práce nebude vytvářet Ticket Engine od nuly, ale:
1. zmapovat existující tabulky a views,
2. ověřit vazby mezi tiketem, blokem, zápasem a výsledkem,
3. ověřit settlement/vyhodnocení tiketů,
4. propojit ticket engine s Match Context Engine,
5. doplnit fakta z článků, zranění, absencí a formy,
6. učit doporučování podle historické úspěšnosti.

CO UŽ MÁME:
- generování tiketů
- bloky
- varianty
- strategie
- patterny
- vyhodnocení
- feedback
- ML predikce
- forma hráčů/týmů

CO DOPLNIT:
- napojení na zranění
- napojení na články
- napojení na oficiální weby týmů
- napojení na Match Context Facts
- inteligentní skládání tiketů podle reálných důvodů

