# MATCHMATRIX – DENNÍ ZÁPISY A NAVAZOVÁNÍ

**Aktualizace:** 16.06.2026  
**Účel dokumentu:** Průběžné denní zápisy.  
**Pravidlo:** Sem se zapisuje každý pracovní den: co jsme udělali, co jsme zjistili, co je problém, co je další krok. Důležité milníky se následně přenesou do MASTER SOUHRNU.

---

## 16.06.2026 – SOURCE DISCOVERY LAYER / AUTONOMOUS HARVEST

### Co jsme dnes řešili

Dnes jsme se zaměřili na zásadní otázku:

```text
Když provider nevrátí potřebná data,
umí MatchMatrix zjistit, kde je hledat jinde?
```

Došli jsme k závěru, že zatím systém uměl:

- poznat datovou mezeru,
- označit provider jako planned / runtime_tested / blocked,
- vytvořit fix task,
- pokračovat další akcí.

Ale ještě neuměl dostatečně říct:

```text
jaká data přesně potřebujeme
a kde je má systém hledat mimo API provider.
```

---

### 1. Entity Requirement Matrix

Vytvořena tabulka:

```text
ops.entity_requirement_matrix
```

Účel:

Definuje, jaká pole jsou potřeba pro jednotlivé entity.

Entity:

- PLAYERS,
- COACHES,
- FIXTURES,
- ODDS,
- MEDIA,
- PHOTOS.

Příklad pro PLAYERS:

- full_name,
- team_id,
- position,
- nationality,
- birth_date,
- provider_profile,
- photo_url.

Tím systém získal odpověď na otázku:

```text
Co znamená, že data jsou dostatečná?
```

---

### 2. Source Discovery Matrix

Vytvořena tabulka:

```text
ops.source_discovery_matrix
```

Účel:

Definuje, kde může systém hledat data, když hlavní provider nestačí.

Typy zdrojů:

- API_PROVIDER,
- OFFICIAL_TEAM_SITE,
- OFFICIAL_LEAGUE_SITE,
- FEDERATION_SITE,
- RSS,
- SITEMAP,
- WIKIDATA,
- WIKIMEDIA,
- CSV_OPEN_DATA,
- PAID_FEED,
- BOOKMAKER_SITE.

Tím systém získal odpověď na otázku:

```text
Kde hledat data, když API nestačí?
```

---

### 3. Source Discovery Engine

Vytvořeno view:

```text
ops.v_source_discovery_engine_v1
```

Účel:

Spojuje:

```text
co potřebujeme
+
kde to hledat
```

Výstup:

- required_field,
- source_type,
- trust_level,
- automation_level,
- license_risk,
- discovery_decision,
- discovery_score.

Rozhodnutí:

- AUTO_DISCOVERY_READY,
- HIGH_TRUST_MANUAL_REVIEW,
- FALLBACK_DISCOVERY_CANDIDATE,
- LICENSE_REVIEW_REQUIRED.

---

### 4. Missing Data Source Recommendations

Vytvořeno view:

```text
ops.v_missing_data_source_recommendations_v1
```

Účel:

Napojení Source Discovery Engine na reálné datové mezery z:

```text
ops.v_data_gap_engine_v2
```

Výstup říká:

```text
sport
entity
provider
coverage_status
required_field
source_type
recommended_mode
discovery_score
```

Tím systém začal ukazovat, co chybí a kde má hledat náhradní zdroj.

---

### 5. Source Discovery Summary

Vytvořeno view:

```text
ops.v_source_discovery_summary_v1
```

Účel:

Zjednodušit detailní pole na souhrn:

```text
sport
entity
provider
source_type
recommended_mode
missing_fields
best_score
```

Tím jsme vytvořili panelově použitelný přehled.

---

### 6. Source Discovery Queue

Vytvořeno view:

```text
ops.v_source_discovery_queue_v1
```

Účel:

Z přehledu vytvořit skutečnou prioritní frontu.

Výstup:

- queue_priority,
- sport_code,
- entity_type,
- provider,
- coverage_status,
- source_type,
- recommended_mode,
- missing_fields,
- best_score,
- discovery_task_type,
- task_status,
- suggested_action.

Zjištěné hlavní priority:

```text
HB players    HIGH_PRIORITY
HK players    HIGH_PRIORITY
VB players    HIGH_PRIORITY
RGB players   HIGH_PRIORITY
HK odds       HIGH_PRIORITY
VB odds       HIGH_PRIORITY
```

---

### 7. Source Discovery Dashboard

Vytvořeno view:

```text
ops.v_source_discovery_dashboard_v1
```

Účel:

Dashboard nad Source Discovery Queue pro OPS Panel / Source Discovery / Autonomous Brain.

Potvrzeno:

Discovery Engine generuje prioritní frontu napříč sporty:

- AFB,
- BK,
- BSB,
- CK,
- DRT,
- ESP,
- FB,
- FH,
- HB,
- HK,
- MMA,
- RGB,
- TN,
- VB.

---

### 8. Autonomous Harvest Loop V1

Byl vytvořen a dry-run testován worker:

```text
workers/ops/19_5_AL_autonomous_harvest_loop_v1.py
```

Dry-run potvrdil, že systém umí načíst kandidáty z:

```text
ops.v_automation_ready_queue_v4
```

a vybrat například:

- CK leagues,
- BSB leagues,
- AFB leagues,
- BK leagues,
- FB players.

Následně jsme ověřili CLI:

```text
workers/run_ingest_cycle_v3.py --help
```

a zjistili, že worker podporuje:

- `--sport`,
- `--entity`,
- `--run-group`,
- `--provider`,
- `--limit`,
- `--timeout-sec`.

Další nutná úprava:

Autonomous Harvest Loop musí pro CORE workery předávat přesné parametry, aby nespustil obecný cyklus bez filtru.

---

### Důležité zjištění dne

Dneškem se MatchMatrix posunul od:

```text
provider-driven harvest
```

k:

```text
source-discovery-driven harvest
```

Tedy systém už nezačíná pouze otázkou:

```text
Jaký provider máme?
```

ale také:

```text
Jaká data chybí?
Kde je můžeme hledat?
Jak důvěryhodný je zdroj?
Je možné ho automatizovat?
Je potřeba license review?
```

---

### Co je hotovo po dnešku

```text
ENTITY REQUIREMENT MATRIX       READY
SOURCE DISCOVERY MATRIX         READY
SOURCE DISCOVERY ENGINE         READY
MISSING DATA SOURCE REC.        READY
SOURCE DISCOVERY SUMMARY        READY
SOURCE DISCOVERY QUEUE          READY
SOURCE DISCOVERY DASHBOARD      READY
AUTONOMOUS HARVEST LOOP V1      DRY-RUN OK
```

---

### Co bude další krok

Další epic:

```text
19_5_AM_SOURCE_DISCOVERY_EXECUTOR_V1
```

Cíl:

```text
Source Discovery Queue
↓
ověřit kandidátní zdroj
↓
ověřit URL / API / RSS / sitemap / official site
↓
ověřit robots / license / terms
↓
zapsat do source_registry
↓
připravit harvest route
↓
vrátit do automation queue
```

Tím se začne uzavírat smyčka:

```text
DATA GAP
↓
SOURCE DISCOVERY
↓
SOURCE VALIDATION
↓
SOURCE REGISTRY
↓
HARVEST QUEUE
↓
WORKER
↓
STAGING
↓
PUBLIC
```

---

## Pravidlo pro další denní zápisy

Každý další den zapisovat:

```text
DATUM

CO JSME UDĚLALI

CO SE POVEDLO

CO SE NEPOVEDLO

CO JSME ZJISTILI

CO JE HOTOVO

CO JE BLOKOVANÉ

ČÍM NAVÁZAT PŘÍŠTĚ

MILNÍKY K PŘENESENÍ DO MASTER SOUHRNU
```

