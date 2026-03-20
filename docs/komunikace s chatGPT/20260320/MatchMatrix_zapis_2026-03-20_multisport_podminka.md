# MatchMatrix – pracovní zápis

## Datum
20.03.2026

## Hlavní podmínka pro další vývoj

**Celý projekt teď připravujeme primárně pro budoucí plný multisport provoz, ne jen pro top ligy.**

To znamená:

- cílem není připravit systém pouze pro několik top soutěží
- cílem je mít **nachystanou databázi, OPS vrstvu, planner a pipeline pro všechny vybrané sporty**
- cílem je mít systém připravený tak, aby šlo **postupně spouštět stahování pro všechny námi vybrané sporty a jejich soutěže**
- cílem je mít připravené podklady pro:
  - relevantní predikce
  - ratingy
  - trenérské vazby
  - další analytické a predikční výpočty
  - dlouhodobě i Ticket Intelligence vrstvu

## Aktuální praktická omezení

Aktuálně jedeme v **API free tarifu**.

To znamená:

- realisticky lze pracovat jen s omezeným rozsahem dat
- pro odzkoušení budeme používat **test mód**
- aktuální pracovní omezení je:
  - sezóny **2022 až 2024**
  - **bez odds**
- to stačí pro:
  - ověření databázové architektury
  - ověření planneru
  - ověření multisport pipeline logiky
  - testování staging/public flow
  - testování trenérských a dalších rozšiřujících vrstev

## Cílový směr po stránce dat

Datový cíl je tento:

- připravit strukturu pro **aktuální sezónu 2025/2026**
- postupně mít možnost jít **do historie cca 7 let**
- a to **napříč všemi vybranými sporty**
- ne pouze pro football, ale pro celý vybraný multisport rozsah

## Co jsme dnes připravili

Dnes jsme připravili základní multisport OPS a plánovací vrstvu:

- canonical sport codes
- sport registry
- sport dimension rules
- provider × sport matrix
- sport entity rules
- ingest entity plan
- top run_group logiku pro:
  - football
  - basketball
  - hockey
- view pro top ingest targety
- view pro top ingest jobs
- ordered view pro top ingest jobs
- runnable view jako základ pro první běh planneru

## Důležitý závěr

Top ligy jsou teď jen **pilotní provozní vrstva**.

Nejsou cílovým stavem projektu.

Cílový stav je:

- mít připravený systém pro **všechny námi vybrané sporty**
- mít připravené targety pro **všechny relevantní soutěže**
- mít připravený scheduler a planner tak, aby se ingest spouštěl **postupně a řízeně**
- mít databázi připravenou pro široké historické i aktuální pokrytí

## Pracovní režim do dalších kroků

Budeme pokračovat takto:

1. nejdřív připravit kompletní multisport strukturu
2. poté postupně doplňovat targety i mimo top ligy
3. vše držet v test módu podle limitů free API
4. připravovat systém už s výhledem na:
   - aktuální sezónu 2025/2026
   - historii 7 let
   - budoucí přechod na vyšší API plán
5. průběžně připravovat datový základ pro:
   - trenéry
   - rankingy
   - predikce
   - další rozšířené výpočty

## Hlavní podmínka pro další práci

**Vše navrhovat tak, aby systém byl připravený pro všechny vybrané sporty, všechny relevantní soutěže a postupný víceletý backfill, i když aktuálně testujeme jen omezený rozsah dat v free režimu.**
