# MATCHMATRIX – NAVÁZÁNÍ PRÁCE

## Autonomní harvest + Source Discovery vrstva

## 1. Co už máme

Máme připravený základ pro autonomní stahování:

* OPS Panel / PC2 Command Center
* `ops.v_automation_ready_queue_v4`
* `ops.v_autonomous_ops_brain_v5`
* `ops.runtime_entity_audit`
* `ops.fix_tasks`
* `ops.v_provider_routing_master_v2`
* `ops.v_data_gap_engine_v2`
* `19_5_AL_autonomous_harvest_loop_v1.py`

Autonomní smyčka už umí vybrat kandidáty z fronty a připravit spuštění workeru podle sportu, entity a run_group.

## 2. Co jsme zjistili

Samotný harvest nestačí. Systém musí vědět:

* jaká data jsou pro každou entitu potřeba,
* kdy jsou data dostatečná,
* kdy provider vrací málo / 0 dat,
* kdy má hledat fallback,
* kdy má hledat jiný zdroj mimo API.

Zdroje nejsou jen API. Budeme pracovat i s:

* oficiálními stránkami týmů,
* oficiálními stránkami lig,
* federacemi,
* RSS / sitemap,
* Wikidata / Wikimedia,
* CSV / open daty,
* placenými feedy,
* komunitními/ručními zdroji.

## 3. Cílový princip

Cíl je:

```text
Spustím panel
↓
systém sám vybere prioritu
↓
stahuje data
↓
pokud provider selže nebo vrátí 0 dat, nezastaví se
↓
zapíše problém
↓
pokračuje další prioritou
↓
najde nebo připraví alternativní zdroj
↓
vrátí opravený úkol zpět do fronty
```

## 4. Další struktura práce

### 19_5_AM – Entity Requirement Matrix

Definuje, jaká data jsou potřeba pro každou entitu.

Například:

* players: jméno, tým, pozice, datum narození, národnost, fotka
* coaches: jméno, tým, role, historie
* fixtures: datum, týmy, liga, skóre, status
* odds: bookmaker, market, outcome, odd, match link
* media: titulek, URL, zdroj, datum, tým/ligový kontext
* photos: URL, licence, zdroj, confidence

Výsledek:

```text
ops.entity_requirement_matrix
```

### 19_5_AN – Source Discovery Matrix

Definuje, odkud může systém data hledat.

Typy zdrojů:

```text
API_PROVIDER
OFFICIAL_LEAGUE_SITE
OFFICIAL_TEAM_SITE
FEDERATION_SITE
RSS
SITEMAP
WIKIDATA
WIKIMEDIA
CSV_OPEN_DATA
PAID_FEED
MANUAL_COMMUNITY
```

Výsledek:

```text
ops.source_discovery_matrix
```

### 19_5_AO – Provider / Source Discovery Engine

Vyhodnotí, co chybí a kde hledat náhradní zdroj.

Například:

```text
HB players vrací 0
↓
api_handball nepoužívat jako primary
↓
hledat official league/team roster source
↓
zapsat discovery task
```

Výsledek:

```text
ops.v_source_discovery_engine_v1
```

### 19_5_AP – Autonomous Harvest Loop V2

Rozšíření aktuálního workeru.

Nově bude umět:

* spouštět worker s přesnými parametry,
* rozpoznat 0 dat jako problém,
* zapsat fix task,
* vytvořit source discovery task,
* přeskočit na další úkol,
* neblokovat celý harvest.

Soubor:

```text
C:\MatchMatrix-platform\workers\ops\19_5_AP_autonomous_harvest_loop_v2.py
```

## 5. Čím pokračujeme hned

První další krok:

```text
19_5_AM_create_entity_requirement_matrix_v1.sql
```

Tím systému řekneme, co přesně znamená „potřebná data“.

Teprve potom může autonomní systém správně rozhodovat:

```text
data jsou dostačující
data jsou částečná
data chybí
provider selhal
potřebujeme nový zdroj
```

## 6. Směr projektu

Krátkodobě:

* dotáhnout autonomní harvest,
* definovat požadavky na data,
* připravit discovery zdrojů,
* opravit falešně potvrzené providery.

Střednědobě:

* PC2 bude stahovat data podle priorit,
* systém bude opravovat a přeřazovat chyby,
* webové vrstvy se budou stavět nad postupně plněnými daty.

Cíl:

```text
MatchMatrix bude schopný dlouhodobě sbírat CORE, PEOPLE, ODDS a MEDIA data bez ručního hlídání.
```
