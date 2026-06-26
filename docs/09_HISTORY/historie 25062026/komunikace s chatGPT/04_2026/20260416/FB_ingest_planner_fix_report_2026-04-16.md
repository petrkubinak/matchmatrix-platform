# MatchMatrix – FB ingest/planner fix report (2026-04-16)

## Cíl
Zafixovat FB fixtures pipeline tak, aby se už nevracela do rozbitého stavu kvůli planner/run_group/sport_code nesouladu.

## Finální zjištění
Problém nebyl v pull scriptu `api_football fixtures`, ale v orchestrace vrstvě:

1. `ops.ingest_targets` obsahoval správné targety.
2. `run_unified_ingest_batch_v1.py` uměl fixtures stáhnout do stagingu.
3. `run_ingest_cycle_v3.py` uměl spustit planner → parse → merge.
4. Kritický problém byl v tom, že pro větev:
   - provider = `api_football`
   - sport = `FB`
   - entity = `fixtures`
   - run_group = `EU_top,EU_exact_v1`

   chyběly nebo neseděly řádky v `ops.ingest_planner`.

## Co bylo zafixováno
### 1) Run group sjednocení
Aktivní FB targets byly sjednoceny na:
- `EU_top,EU_exact_v1`

### 2) Planner seed
Do `ops.ingest_planner` byly doplněny joby z `ops.ingest_targets` pro:
- provider = `api_football`
- sport_code = `FB`
- entity = `fixtures`
- run_group = `EU_top,EU_exact_v1`

### 3) Sport code sjednocení
Pro planner slice bylo potvrzeno, že panel i planner worker pracují korektně s:
- `sport_code = 'FB'`

Ne s:
- `football`

Tohle je důležité pravidlo pro další práci.

---

## ZAFIXOVANÁ PRAVIDLA
### Jediný zdroj pravdy
`ops.ingest_targets` = master konfigurace

### Pracovní fronta
`ops.ingest_planner` = queue pro planner worker

### Povolené sport_code
Používat konzistentně zkratky:
- `FB`
- `HK`
- `BK`
- `VB`
- `AFB`
- atd.

Nepřepínat mezi `FB` a `football` uvnitř DB planner vrstvy.

---

## Doporučený provozní pattern
### Krok 1
Nejdřív musí být `ops.ingest_targets` správně naplněné a aktivní.

### Krok 2
Před planner během musí existovat odpovídající řádky v `ops.ingest_planner`.

### Krok 3
Teprve potom spouštět:
- **Ingest cycle (planner)**

To spustí:
1. planner worker
2. extract teams from fixtures raw
3. parse teams
4. parse fixtures
5. unified staging → public merge

---

## Potvrzený úspěšný běh
### Ingest cycle log – výsledek
- Processed planner jobs: **5**
- Teams extractor: **YES**
- Teams parser: **YES**
- Fixtures parser: **YES**
- Merge executed: **YES**
- Final status: **OK**

### Důležité metriky z merge
- `matches updated`: **1650**
- `matches inserted`: **79610**
- `public.matches`: **111285**

To potvrzuje, že:
- planner funguje
- parse funguje
- merge funguje
- `api_football` se propsal až do `public.matches`

---

## Praktický závěr
FB fixtures pipeline je po této opravě systémově průchozí:

- ingest → OK
- planner → OK
- parse → OK
- merge → OK
- public.matches → OK

---

## Co už znovu nerozbíjet
1. Neměnit planner `sport_code` mezi `FB` a `football`.
2. Nemazat planner řádky bez znovunaplnění.
3. Nespouštět ingest cycle bez validní planner fronty.
4. Nemíchat staré run_group (`FB_BOOTSTRAP_V1`, `FOOTBALL_MAINTENANCE*`) s novou aktivní větví, pokud k tomu není jasný důvod.

---

## Doporučení na trvalé dotažení
Další stabilizační krok:
- automatizovat seed `ops.ingest_planner` z `ops.ingest_targets`
- ideálně jako samostatný opakovatelný krok před `ingest_cycle`
- nebo přímo jako úvodní část `run_ingest_cycle_v3.py`

Tím se odstraní nutnost ručního doplňování planneru v budoucnu.

---

## Jednověté navázání do dalšího chatu
Navazujeme po zafixování FB fixtures orchestrace; planner pro `api_football / FB / fixtures / EU_top,EU_exact_v1` byl správně naplněn, ingest cycle zpracoval 5 planner jobů, proběhl parse i unified merge a `public.matches` se úspěšně naplnilo, takže další správná větev je trvale zautomatizovat planner seed z `ops.ingest_targets`.
