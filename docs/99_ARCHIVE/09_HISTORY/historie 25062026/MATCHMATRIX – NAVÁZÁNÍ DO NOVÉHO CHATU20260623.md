# MATCHMATRIX – SPORT COMPLETION GOVERNANCE

## ZÁKLADNÍ PRAVIDLO

Hlavní pracovní jednotkou projektu není:

* provider
* endpoint
* worker
* tabulka

Hlavní pracovní jednotkou projektu je:

SPORT

---

## DEFINICE SPORT READY

Sport může být označen jako READY pouze tehdy, pokud jsou dokončeny všechny vrstvy:

CORE
PEOPLE
MEDIA
ODDS

a současně jsou potvrzeny všechny klíčové části pipeline:

* pull_confirmed
* raw_confirmed
* staging_confirmed
* provider_map_confirmed
* public_merge_confirmed
* downstream_confirmed

v tabulce:

ops.runtime_entity_audit

---

## POSTUP PRÁCE

Pořadí práce:

1. Vybrat sport
2. Dokončit CORE
3. Dokončit PEOPLE
4. Dokončit MEDIA
5. Dokončit ODDS
6. Ověřit runtime_entity_audit
7. Označit SPORT READY
8. Přesunout se na další sport

---

## DŮLEŽITÉ PRAVIDLO

Neřešíme izolovaně:

* fixtures
* players
* teams
* parsery
* merge skripty

Tyto části jsou pouze podúkoly.

Skutečný cíl je:

SPORT READY

---

## AUTONOMOUS HARVEST READY

Sport je připraven pro autonomní harvest pouze tehdy, pokud:

* existuje planner
* existuje worker
* existuje parser
* existuje merge
* existuje governance kontrola
* existuje runtime audit

a celý řetězec lze spustit bez manuálního zásahu.

---

## PŘÍKLAD HB (HAND BALL)

Aktuální stav:

CORE:

* leagues READY
* fixtures READY
* parser READY
* staging READY
* merge PARTIAL

Blokátor:

* 463 chybějících týmů
* 4853 blokovaných fixtures

Status:

HB ≠ SPORT READY

Další krok:

HB Teams Completion
→ Team Provider Map
→ Fixtures Merge
→ CORE READY

Poté pokračovat:

PEOPLE
MEDIA
ODDS

a následně označit:

HB = SPORT READY

---

## DLOUHODOBÝ CÍL

Připravit všechny sporty do stavu:

AUTONOMOUS HARVEST READY

tak, aby bylo možné spustit:

PC2 MASTER HARVEST

bez manuálních zásahů.

Teprve po dosažení tohoto stavu bude spuštěn velký historický harvest všech sportů.
