# MatchMatrix -- Postup dalšího vývoje (Ticket Engine + Intelligent Ticket Layer)

Datum: 2026‑03‑07

Tento dokument shrnuje aktuální stav projektu MatchMatrix a doporučený
postup dalšího vývoje. Slouží jako referenční zápis pro další práci i
pro nové chaty.

------------------------------------------------------------------------

# 1. Aktuální stav systému

V databázi již existují dvě hlavní vrstvy:

## 1. Runtime Ticket Engine (již implementováno)

Tyto tabulky a funkce tvoří hlavní generátor tiketů:

-   templates
-   template_blocks
-   template_block_matches
-   template_fixed_picks
-   generated_runs
-   generated_tickets
-   generated_ticket_blocks

Funkce generátoru:

-   mm_preview_run(...)
-   mm_generate_run_engine(...)
-   mm_generate_tickets_engine(...)
-   mm_ui_run_tickets(...)
-   mm_ui_run_summary(...)

Logika systému:

-   max 3 bloky
-   každý blok obsahuje max 3 zápasy
-   všechny zápasy v bloku mají stejnou volbu (1 / X / 2)
-   konstantní zápasy jsou pevné
-   vzniká maximálně 27 variant tiketu

Výsledné tikety se ukládají do tabulek generated\_\*.

------------------------------------------------------------------------

# 2. Nové tabulky vytvořené dnes

Byla připravena sada tabulek pro budoucí analytickou a inteligentní
vrstvu systému.

Tyto tabulky nejsou v konfliktu s runtime enginem a budou sloužit pro
analýzu a učení systému.

## Intelligent Ticket Layer

-   ticket_settlements
-   ticket_pattern_stats
-   ticket_league_pattern_stats
-   ticket_generation_runs
-   ticket_variant_features
-   ticket_recommendation_feedback

Účel:

-   ukládání historie tiketů
-   statistiky úspěšnosti struktur tiketů
-   sledování ROI
-   analýza kombinací lig
-   feature dataset pro ML modely
-   sledování chování uživatelů

Tyto tabulky tvoří základ **Ticket Intelligence Layer**.

------------------------------------------------------------------------

# 3. Architektura systému

Celý systém bude rozdělen na dvě hlavní vrstvy.

## Layer 1 -- Runtime Ticket Engine

Generuje tikety.

Používané tabulky:

templates template_blocks template_block_matches template_fixed_picks
generated_runs generated_tickets generated_ticket_blocks

------------------------------------------------------------------------

## Layer 2 -- Ticket Intelligence Layer

Analyzuje historii tiketů.

Používané tabulky:

ticket_settlements ticket_pattern_stats ticket_league_pattern_stats
ticket_generation_runs ticket_variant_features
ticket_recommendation_feedback

------------------------------------------------------------------------

# 4. Důležitý princip systému

TicketMatrix nebude jen systém pro predikci zápasů.

Bude to systém pro:

**predikci tiketů**.

Model nebude optimalizovat jednotlivé zápasy, ale **celé struktury
tiketů**.

------------------------------------------------------------------------

# 5. Další plán vývoje

## Fáze 1 -- stabilizace runtime engine

Dokončit:

-   kontrolu generování 27 variant
-   výpočet odds
-   výpočet pravděpodobností

------------------------------------------------------------------------

## Fáze 2 -- sběr historických dat

Naplnit tabulky:

ticket_settlements ticket_variant_features

------------------------------------------------------------------------

## Fáze 3 -- statistická analýza tiketů

Naplnit:

ticket_pattern_stats ticket_league_pattern_stats

------------------------------------------------------------------------

## Fáze 4 -- Ticket Intelligence

Implementovat:

-   automatické generování tiketů
-   doporučování tiketů
-   filtraci podle ROI

------------------------------------------------------------------------

# 6. API data

Připravit ingest infrastrukturu a následně aktivovat placený API plán na
1 měsíc pro hromadný backfill dat.

------------------------------------------------------------------------

# 7. Dlouhodobý cíl

MatchMatrix =

Sport Data Platform\
+ Prediction Engine\
+ Betting Intelligence\
+ Ticket Generator

Hlavní výhoda:

**inteligentní generování tiketů z dat.**

------------------------------------------------------------------------

# 8. Další krok příště

1.  vytvořit analytická VIEW nad generated_tickets
2.  vytvořit dataset ticket_variant_features
3.  připravit ingest plán pro API data
4.  navrhnout ML pipeline pro Ticket Intelligence

------------------------------------------------------------------------

Konec zápisu.
