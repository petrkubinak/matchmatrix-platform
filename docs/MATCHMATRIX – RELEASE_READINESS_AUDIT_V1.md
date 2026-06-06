# MATCHMATRIX – RELEASE READINESS AUDIT V1

Datum: 2026-06-03

# 1. EXECUTIVE SUMMARY

Po provedení kompletního governance auditu databáze, workerů, ingest vrstvy, OPS vrstvy a nástrojů je možné poprvé objektivně zhodnotit skutečný stav projektu MatchMatrix.

Projekt již není ve fázi prototypu.

Má:

* produkční databázovou architekturu
* produkční ingest architekturu
* produkční OPS vrstvu
* produkční scheduler
* produkční planner
* produkční media vrstvu
* produkční People vrstvu
* základ webové vrstvy

Největší část práce již není stavba infrastruktury.

Největší část práce je nyní:

1. doplnění datových mezer
2. dokončení sportů
3. dokončení webu
4. příprava produkčního spuštění

---

# 2. CO JE HOTOVO

## DATABASE

Governance audit dokončen.

### OPS

* 214 views
* 59 tables

Kompletně zmapováno.

### PUBLIC

* 129 tabulek
* 100 views

Kompletně zmapováno.

### STAGING

* 35 objektů

Kompletně zmapováno.

---

## INGEST

Hotovo:

* API-Football
* API-Hockey
* API-Sport
* Football-Data
* TheOdds

Připraveno:

* Tennis
* Volleyball
* Rugby
* Cricket
* American Football

---

## OPS

Hotovo:

* ingest planner
* scheduler
* autonomous launcher
* runtime audit
* provider routing
* provider health
* data gap engine

---

## PEOPLE

Hotovo:

* canonical players
* provider mapping
* season statistics
* player form

Rozpracováno:

* player match statistics
* player profiles
* coaches

---

## MEDIA

Hotovo:

* NHL
* NBA
* Premier League
* Bundesliga
* LaLiga
* UEFA

Rozpracováno:

* FIFA
* další fotbalové zdroje
* video vrstva

---

## MMR / ML

Hotovo:

* team ratings
* match ratings
* feature generation
* prediction pipeline

Rozpracováno:

* validace modelů
* betting edge engine

---

## TICKET ENGINE

Hotovo:

* generování tiketů
* blokový systém
* strategie
* settlement

Rozpracováno:

* UI
* doporučovací vrstva

---

# 3. CO JE ČÁSTEČNĚ HOTOVO

## Fotbal

Stav:

85–90 %

Chybí:

* větší objem player match stats
* coaches
* PRO backfill
* odds historie

---

## Hokej

Stav:

70–80 %

Chybí:

* people vrstva
* coaches
* statistiky

---

## Basketbal

Stav:

70–80 %

Chybí:

* people vrstva
* statistiky
* coaches

---

# 4. CO CHYBÍ

## WEB

Největší nedokončená oblast.

Chybí:

* registrace
* přihlášení
* předplatné
* platební brána
* uživatelské profily
* oblíbené týmy
* oblíbení hráči
* dashboard uživatele
* admin rozhraní

---

## PRODUKČNÍ UŽIVATELSKÁ VRSTVA

Chybí:

* Stripe
* správa předplatného
* notifikace
* emaily
* onboarding

---

## PEOPLE EXPANZE

Chybí:

* Handball
* Volleyball
* Rugby
* Cricket
* Baseball
* Tennis
* MMA

---

## MEDIA EXPANZE

Chybí:

* video feed
* highlights
* životopisy hráčů
* fan obsah
* komunitní obsah

---

# 5. PRIORITY

## PRIORITA 1

Dokončit fotbal na 100 %

Cíl:

* players
* player stats
* coaches
* PRO readiness

Odhad:

2–4 týdny

---

## PRIORITA 2

Dokončit HK + BK

Odhad:

2–3 týdny

---

## PRIORITA 3

People vrstva ostatních sportů

Odhad:

4–6 týdnů

---

## PRIORITA 4

Web V1

Odhad:

4–8 týdnů

---

## PRIORITA 5

Produkční spuštění

Odhad:

2–4 týdny

---

# 6. ČASOVÁ OSA

## ČERVEN 2026

* governance dokončena
* fotbal 100 %
* HK/BK výrazně posunout

---

## ČERVENEC 2026

* dokončit hlavní sporty
* připravit PRO měsíc
* začít masivní backfill

---

## SRPEN 2026

* druhé výkonné PC
* plný harvest
* miliony záznamů

---

## ZÁŘÍ 2026

* web beta
* interní testování

---

## ŘÍJEN 2026

* uzavřená beta

---

## LISTOPAD 2026

* veřejná beta

---

## PROSINEC 2026

* první platící uživatelé

---

# 7. CELKOVÉ HODNOCENÍ

Infrastruktura:
95 %

Databáze:
95 %

OPS:
95 %

Ingest:
90 %

Fotbal:
90 %

Hokej:
75 %

Basketbal:
75 %

People:
60 %

Media:
70 %

ML/MMR:
75 %

Web:
20 %

Produkční připravenost:
65 %

Celkový stav projektu:

75–80 %

Projekt je za bodem, kdy se řeší architektura.

Od této chvíle se hlavně dokončují vrstvy, doplňují data a staví web pro koncové uživatele.
