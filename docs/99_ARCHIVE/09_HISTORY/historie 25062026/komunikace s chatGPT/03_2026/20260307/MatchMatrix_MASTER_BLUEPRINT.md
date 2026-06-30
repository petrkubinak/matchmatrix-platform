# MatchMatrix MASTER BLUEPRINT

Kompletní technický a architektonický přehled systému

------------------------------------------------------------------------

# 1. Vize projektu

MatchMatrix je sportovní datová a analytická platforma zaměřená na:

-   sběr sportovních dat z více zdrojů
-   vytváření vlastní sportovní databáze
-   výpočet ratingů týmů a lig (MMR)
-   machine learning predikce výsledků zápasů
-   analýzu bookmaker odds
-   inteligentní tvorbu tiketů (TicketMatrix)

Cílem není pouze predikovat zápasy, ale optimalizovat celé tikety.

------------------------------------------------------------------------

# 2. Hlavní architektura systému

DATA PROVIDERS ↓ INGEST LAYER ↓ RAW DATA STORAGE ↓ DATABASE (PostgreSQL)
↓ RATING ENGINE (MMR) ↓ FEATURE ENGINEERING ↓ ML TRAINING ↓ PREDICTIONS
↓ ODDS ANALYSIS ↓ TICKET ENGINE ↓ TICKET LEARNING ↓ FRONTEND
(TicketMatrix)

------------------------------------------------------------------------

# 3. Struktura projektu

Root:

C:`\MatchMatrix`{=tex}-platform

Hlavní složky:

backend backups data db docs experiments fronted infra ingest logs ops
ops_admin programs reports system

Poznámka: Složka fronted obsahuje frontend aplikaci (historický název).

------------------------------------------------------------------------

# 4. Data Providers

Zdroje dat:

-   API-Football
-   TheOdds API
-   Football-data
-   Transfermarkt
-   další API

------------------------------------------------------------------------

# 5. Data Ingest Layer

Složka:

ingest/

Podsložky:

api API-Football API-Hockey scrapers workers artifacts

Funkce:

-   stahování dat z API
-   ukládání RAW payloadů
-   parsování
-   mapování týmů
-   deduplikace

------------------------------------------------------------------------

# 6. Data Lake

data/

raw -- originální API data\
processed -- vyčištěná data\
exports -- exporty datasetů\
scraped_html -- scrapovaná data\
temporary_datasets -- pomocné dataset

------------------------------------------------------------------------

# 7. Database Layer

db/

migrations -- změny schématu\
seeds -- počáteční data\
scripts -- pomocné skripty\
sql -- SQL logika\
views -- analytické pohledy

------------------------------------------------------------------------

# 8. Rating Engine (MMR)

Komponenty:

team_rating home_rating away_rating momentum volatility

Tabulky:

mm_team_ratings\
mm_match_ratings

------------------------------------------------------------------------

# 9. Feature Engineering

Dataset:

ml_match_dataset_v2

------------------------------------------------------------------------

# 10. Machine Learning Layer

Modely:

GBM v1\
GBM v2\
GBM v3

Predikují:

p_home p_draw p_away

------------------------------------------------------------------------

# 11. Prediction Pipeline

Skripty:

predict_matches.py predict_matches_V2.py predict_matches_V3.py

Výstup:

ml_predictions

------------------------------------------------------------------------

# 12. Odds Layer

Tabulky:

bookmakers markets market_outcomes odds

------------------------------------------------------------------------

# 13. Ticket Intelligence Layer

tickets\
ticket_matches\
ticket_structures\
ticket_history\
ticket_patterns

------------------------------------------------------------------------

# 14. Ticket Engine

Algoritmus:

1.  výběr kandidátních zápasů
2.  výpočet value
3.  filtr pravděpodobností
4.  generování kombinací
5.  výpočet EV

------------------------------------------------------------------------

# 15. Výpočet pravděpodobnosti tiketu

P(ticket) = P1 × P2 × P3 × ...

------------------------------------------------------------------------

# 16. Expected Value

EV = P(ticket) × odds − (1 − P(ticket))

------------------------------------------------------------------------

# 17. Ticket Learning System

Analýza historie tiketů:

-   hit rate
-   ROI
-   úspěšnost struktur

------------------------------------------------------------------------

# 18. Frontend

Složka:

fronted/matchmatrix-web

------------------------------------------------------------------------

# 19. Backend

backend/

API + ticket engine + business logic

------------------------------------------------------------------------

# 20. Infrastruktura

infra/

docker configs

------------------------------------------------------------------------

# 21. Logging

logs/

denní logy reporty

------------------------------------------------------------------------

# 22. Zálohy

backups/

postgres dumps snapshots archiv exportů

------------------------------------------------------------------------

# 23. Reports

reports/

model reports analýzy

------------------------------------------------------------------------

# 24. Celkový systém

MatchMatrix =

SPORT DATA PLATFORM + ML PREDICTION ENGINE + BETTING INTELLIGENCE +
TICKET GENERATOR
