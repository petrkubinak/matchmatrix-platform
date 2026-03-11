# MatchMatrix – režimy tvorby tiketů

Datum: 2026-03-09
Stav: návrh produktové logiky

Tento dokument definuje tři hlavní režimy práce s tikety v systému MatchMatrix.
Cílem je umožnit uživatelům různé úrovně práce se zápasy – od jednoduchého tipování až po pokročilé scénářové kombinace.

---

# 1. Režim Classic (klasické tipování)

Nejjednodušší režim.

Uživatel si vybírá jednotlivé zápasy a skládá standardní tiket podobně jako u klasických sázkových kanceláří.

### Funkce systému

MatchMatrix poskytuje ke každému zápasu:

* modelovou predikci výsledku
* pravděpodobnosti 1 / X / 2
* bookmaker odds
* implied probability
* edge (value)
* EV (expected value)
* základní statistiky týmů
* formu týmů
* head-to-head

### Charakteristika režimu

* uživatel vybírá zápasy ručně
* žádná bloková logika
* systém funguje jako **tipovací asistent**

---

# 2. Režim Blocks (blokové tipování)

Tento režim zavádí práci s bloky.

Blok je skupina zápasů, které mají stejný výsledek:

* 1
* X
* 2

### Typy bloků

Uživatel může zvolit:

* blok 1 zápasu
* blok 2 zápasů
* blok 3 zápasů

### Princip

Například blok 2 zápasů:

zápas A
zápas B

Varianta bloku:

1 → oba zápasy vyhrají domácí
X → oba zápasy skončí remízou
2 → oba zápasy vyhrají hosté

### Funkce systému

MatchMatrix poskytuje:

* statistiky zápasů
* predikce výsledků
* pravděpodobnost bloku
* doporučení bloků
* generování variant tiketů

Tento režim umožňuje:

* vytvářet více tiketových variant
* násobit kurzy v blocích
* řídit riziko přes varianty

---

# 3. Režim Scenario (scénářové tikety)

Toto je nejpokročilejší režim MatchMatrix.

Uživatel nevybírá jen jednotlivé tipy, ale **scénář dne**.

Scénář znamená, že několik zápasů sdílí podobný výsledek nebo kontext.

Například:

* hosté překvapí
* favorité selžou
* zápasy skončí remízou
* domácí týmy jsou oslabené
* týmy mají špatnou formu
* marodka nebo únava

### Struktura

Scénář může obsahovat až:

* 3 bloky
* až 3 zápasy v každém bloku

Maximálně tedy:

9 zápasů ve scénáři.

### Varianty

Každý blok má 3 možné výsledky:

1
X
2

Celkem vznikne:

3 × 3 × 3 = 27 variant tiketů

Uživatel může:

* hrát všech 27 variant
* nebo některé varianty odstřihnout

### Funkce systému

MatchMatrix poskytuje:

* synchronizační analýzu zápasů
* doporučené bloky
* synchronizační důvody
* statistiky scénáře
* pravděpodobnost jednotlivých variant
* doporučení které varianty odstranit

---

# Princip synchronizace zápasů

V režimu Scenario systém nehledá jen tip na výsledek.

Hledá **zápasy, které sdílejí podobný scénář**.

Synchronizace může být založena například na:

* špatné formě týmu
* psychickém tlaku
* sérii porážek
* zraněních
* slabé obraně
* přecenění bookmakerem
* otevřeném charakteru zápasu

Cílem je najít zápasy, které mohou dopadnout podobně.

---

# Architektura systému

Všechny tři režimy používají stejné datové vrstvy:

* matches
* odds
* ml_predictions
* value_bets
* team statistics
* match context

Nad nimi jsou postaveny různé vrstvy inteligence:

Classic → základní predikce
Blocks → blokové kombinace
Scenario → synchronizační scénáře

---

# Dlouhodobý plán

Po nasbírání historie tiketů bude MatchMatrix analyzovat:

* úspěšnost bloků
* úspěšnost scénářů
* úspěšnost kombinací lig
* úspěšnost kurzových profilů
* optimální počet variant tiketů

Na základě těchto dat vznikne další vrstva:

**Ticket Intelligence Layer**

která bude zlepšovat doporučení systému.

---

# Shrnutí

MatchMatrix nabídne tři režimy práce:

Classic → jednoduché tipování
Blocks → blokové kombinace
Scenario → scénářová synchronizace zápasů

Uživatel vždy rozhoduje sám.

Systém poskytuje:

* data
* statistiky
* predikce
* scénáře
* doporučení
