# MM-TPL-002

# ŠABLONA DENNÍHO ZÁPISU MATCHMATRIX

---

## Informace o šabloně

| Položka | Hodnota |
|---|---|
| Document ID | MM-TPL-002 |
| Název dokumentu | Šablona denního zápisu MatchMatrix |
| Typ dokumentu | TEMPLATE |
| Cílový typ dokumentu | DAILY_LOG |
| Edice | MM-TPL |
| Verze | 1.0 |
| Stav | DRAFT – NEEDS_USER_APPROVAL |
| Datum vytvoření | 2026-07-11 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Kanonické umístění | `docs/13_TEMPLATES/MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md` |
| Referenční dokument | `MM-DL-20260711_MATCHMATRIX_DENNI_ZAPIS.md`, verze 1.0 |
| Řídicí standardy | MM-DOC-900, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-009 |

---

## 1. Účel šablony

Tato šablona slouží k vytváření dokumentů typu `DAILY_LOG`.

Jejím cílem je zajistit, aby každý nový denní zápis:

- zachytil výchozí stav a cíl pracovního dne,
- popsal skutečně provedené práce a jejich důvody,
- oddělil přijatá rozhodnutí od otevřených úkolů,
- zaznamenal problémy včetně příčiny, řešení a výsledku,
- obsahoval ověřené technické výstupy,
- uzavřel den jednoznačným stavem,
- obsahoval CURRENT STATUS, AI CONTEXT, PROJECT SNAPSHOT a DATABASE SNAPSHOT,
- určil právě jeden hlavní další krok,
- měl jasnou vazbu na dokument NAVÁZÁNÍ,
- byl připraven pro audit A17 bez rozsáhlého ručního mapování v A19.

---

## 2. Pravidla použití

1. Nový denní zápis se vytvoří z obsahu mezi značkami `MM-TEMPLATE-START` a `MM-TEMPLATE-END`.
2. Všechny proměnné ve formátu `{{NAZEV_PROMENNE}}` musí být nahrazeny skutečnou hodnotou.
3. V dokončeném dokumentu nesmí zůstat žádná nevyplněná proměnná.
4. Číselná část identifikátoru `MM-DL-YYYYMMDD` odpovídá datu pracovního dne.
5. Jeden kalendářní den má standardně jeden hlavní denní zápis.
6. Do části **Provedené práce** patří jen skutečně provedené činnosti.
7. Do části **Přijatá rozhodnutí** patří pravidla a rozhodnutí platná i pro další práci.
8. Každý problém má obsahovat příčinu, analýzu, řešení a konečný výsledek.
9. Do části **Ověřené výsledky a technické výstupy** patří konkrétní důkazy: reporty, počty, stavové kódy, commity, cesty a databázové výsledky.
10. Část **NEXT STEP** obsahuje právě jeden hlavní krok.
11. Pokud je denní zápis po importu obsahově změněn, musí být zvýšena jeho verze.
12. Publikační pořadí je: finální A17 → kanonické uložení → Git commit → A24 VALIDATE_ONLY → A24 APPLY → A7.

---

## 3. Výstupní šablona

<!-- MM-TEMPLATE-START -->

# {{NAZEV_DOKUMENTU}}

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | {{DOCUMENT_ID}} |
| Název dokumentu | {{NAZEV_DOKUMENTU}} |
| Typ dokumentu | DAILY_LOG |
| Verze | {{VERZE}} |
| Stav | {{STAV}} |
| Datum | {{DATUM_YYYY_MM_DD}} |
| Datum a čas uzavření | {{DATUM_CAS_ISO_8601}} |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | {{PRACOVNI_OBLAST}} |
| Primární formát | Markdown (.md) |
| Kanonické umístění | `docs/09_HISTORY/DENNÍ_ZÁPISY/{{NAZEV_SOUBORU}}` |
| Předchozí denní zápis | `{{PREDCHOZI_DENNI_ZAPIS_NEBO_NENI}}` |
| Navazující dokument | `{{NAVAZUJICI_DOKUMENT_NEBO_BUDE_VYTVOREN}}` |

## 1. Identifikace denního zápisu

| Položka | Hodnota |
|---|---|
| Document ID | {{DOCUMENT_ID}} |
| Název dokumentu | {{NAZEV_DOKUMENTU}} |
| Typ dokumentu | DAILY_LOG |
| Verze | {{VERZE}} |
| Stav | {{STAV}} |
| Datum | {{DATUM_YYYY_MM_DD}} |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | {{PRACOVNI_OBLAST}} |
| Primární formát | Markdown (.md) |
| Kanonické umístění | `docs/09_HISTORY/DENNÍ_ZÁPISY/{{NAZEV_SOUBORU}}` |
| Navazující dokument | `{{NAVAZUJICI_DOKUMENT_NEBO_BUDE_VYTVOREN}}` |

## 2. Výchozí stav

{{VYCHOZI_STAV}}

<!-- Popsat:
- stav projektu před zahájením práce,
- poslední dokončený krok,
- otevřené úkoly,
- známé problémy nebo blokace,
- soubor nebo dokument, na který dnešní práce navazuje. -->

## 3. Cíl pracovního dne

{{CIL_PRACOVNIHO_DNE}}

<!-- Uvést:
- hlavní cíl dne,
- případné vedlejší cíle,
- podmínky, podle kterých bude možné den považovat za úspěšně uzavřený. -->

## 4. Provedené práce

### 4.1 {{NAZEV_PRACOVNIHO_BLOKU_1}}

{{POPIS_PROVEDENE_PRACE_1}}

**Důvod:**

{{DUVOD_ZMENY_1}}

**Výsledek:**

{{VYSLEDEK_PRACE_1}}

**Důkaz:**

- soubor nebo skript: `{{SOUBOR_NEBO_SKRIPT_1}}`
- report nebo výstup: `{{REPORT_NEBO_VYSTUP_1}}`
- Git commit: `{{GIT_COMMIT_NEBO_NENI_1}}`

### 4.2 {{NAZEV_PRACOVNIHO_BLOKU_2}}

{{POPIS_PROVEDENE_PRACE_2}}

**Důvod:**

{{DUVOD_ZMENY_2}}

**Výsledek:**

{{VYSLEDEK_PRACE_2}}

**Důkaz:**

- soubor nebo skript: `{{SOUBOR_NEBO_SKRIPT_2}}`
- report nebo výstup: `{{REPORT_NEBO_VYSTUP_2}}`
- Git commit: `{{GIT_COMMIT_NEBO_NENI_2}}`

<!-- Podle potřeby přidat další podkapitoly 4.3, 4.4 atd.
Nevytvářet prázdné pracovní bloky. -->

## 5. Přijatá rozhodnutí

{{PRIJATA_ROZHODNUTI}}

<!-- Každé rozhodnutí popsat samostatně:
- co bylo rozhodnuto,
- proč,
- od kdy platí,
- čeho se týká,
- zda má být propsáno do standardu, hlavní dokumentace nebo paměti projektu. -->

## 6. Problémy a jejich řešení

### 6.1 {{NAZEV_PROBLEMU_1}}

**Příčina:**

{{PRICINA_PROBLEMU_1}}

**Analýza:**

{{ANALYZA_PROBLEMU_1}}

**Řešení:**

{{RESENI_PROBLEMU_1}}

**Výsledek:**

{{VYSLEDEK_RESENI_1}}

**Stav:**

{{STAV_PROBLEMU_1}}

<!-- Pokud se během dne neobjevil žádný významný problém, uvést:
„Během pracovního dne nebyl zaznamenán nový významný problém vyžadující samostatnou evidenci.“ -->

## 7. Ověřené výsledky a technické výstupy

| Oblast | Ověřený výsledek | Důkaz |
|---|---|---|
| {{OBLAST_1}} | {{OVERENY_VYSLEDEK_1}} | `{{DUKAZ_1}}` |
| {{OBLAST_2}} | {{OVERENY_VYSLEDEK_2}} | `{{DUKAZ_2}}` |
| {{OBLAST_3}} | {{OVERENY_VYSLEDEK_3}} | `{{DUKAZ_3}}` |

<!-- Zahrnout podle skutečné práce:
- A17/A24/A6/A7 výsledky,
- počty vložených nebo změněných záznamů,
- Git commit a push,
- SHA-256,
- cesty k aktivním souborům,
- databázové objekty,
- výsledky testů a auditů. -->

## 8. Výsledky dne a stav na konci dne

{{SOUHRN_VYSLEDKU_DNE}}

### Stav hlavních oblastí

| Oblast | Stav | Stručné vysvětlení |
|---|---|---|
| {{STAV_OBLAST_1}} | {{STAV_HODNOTA_1}} | {{STAV_VYSVETLENI_1}} |
| {{STAV_OBLAST_2}} | {{STAV_HODNOTA_2}} | {{STAV_VYSVETLENI_2}} |
| {{STAV_OBLAST_3}} | {{STAV_HODNOTA_3}} | {{STAV_VYSVETLENI_3}} |

<!-- Povolené stavové významy podle situace:
DOKONČENO, ČÁSTEČNÉ, ROZPRACOVÁNO, ČEKÁ, BLOKOVÁNO, CHYBA, BEZ ZMĚN. -->

## 9. CURRENT STATUS

{{CURRENT_STATUS}}

<!-- Uvést aktuální stav po skončení práce:
- aktivní soubory a skripty,
- stav pracovního stromu Git,
- poslední commit a push,
- stav panelu a workflow,
- execution host,
- DB host a DB target,
- poslední úspěšný nebo blokovaný technický krok. -->

## 10. AI CONTEXT

{{AI_CONTEXT}}

<!-- AI CONTEXT musí obsahovat:
- hlavní cíl pokračování,
- závazná technická pravidla,
- důležité cesty a aktivní nástroje,
- hostitelské a databázové omezení,
- způsob práce krok po kroku,
- co se nesmí změnit bez nového ověření,
- z čeho má AI při pokračování vycházet. -->

## 11. PROJECT SNAPSHOT

| Oblast | Ověřený stav k {{DATUM_YYYY_MM_DD}} |
|---|---|
| Aktivní pracovní blok | {{SNAPSHOT_AKTIVNI_PRACOVNI_BLOK}} |
| Aktivní panel nebo nástroj | {{SNAPSHOT_AKTIVNI_PANEL}} |
| Poslední dokončený výsledek | {{SNAPSHOT_POSLEDNI_VYSLEDEK}} |
| Git stav | {{SNAPSHOT_GIT_STAV}} |
| Dokumentační workflow | {{SNAPSHOT_DOKUMENTACNI_WORKFLOW}} |
| Databázový stav | {{SNAPSHOT_DATABAZOVY_STAV}} |
| Největší otevřený úkol | {{SNAPSHOT_NEJVETSI_OTEVRENY_UKOL}} |
| Následující pracovní blok | {{SNAPSHOT_NASLEDUJICI_BLOK}} |
| Dlouhodobý cíl | {{SNAPSHOT_DLOUHODOBY_CIL}} |

## 12. DATABASE SNAPSHOT

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | {{DB_DOCUMENTS}} |
| Verze dokumentů | {{DB_VERSIONS_TOTAL}} |
| Aktuální verze | {{DB_CURRENT_VERSIONS}} |
| Sekce | {{DB_SECTIONS}} |
| Vazby | {{DB_RELATIONS}} |
| Historie stavů | {{DB_STATUS_HISTORY}} |
| Importní běhy | {{DB_IMPORT_RUNS}} |

- Snapshot vytvořen: `{{DB_SNAPSHOT_CREATED_AT}}`
- Execution host: `{{DB_EXECUTION_HOST}}`
- DB host: `{{DB_HOST}}`
- DB target: `{{DB_TARGET}}`
- Zdroj ověření: `{{DB_VERIFICATION_SOURCE}}`

<!-- Pokud pracovní den dokumentační databázi neřešil, uvést poslední ověřený snapshot a jasně označit jeho čas. -->

## 13. OPEN QUESTIONS / otevřené úkoly

{{OPEN_QUESTIONS_A_OTEVRENE_UKOLY}}

<!-- Uvést:
- úkol,
- aktuální stav,
- prioritu,
- blokaci nebo závislost,
- očekávaný výsledek.
Nezaměňovat s dlouhodobou vizí projektu. -->

## 14. Plán pokračování

1. **{{PLAN_KROK_1}}**
   - {{PLAN_DETAIL_1}}

2. **{{PLAN_KROK_2}}**
   - {{PLAN_DETAIL_2}}

3. **{{PLAN_KROK_3}}**
   - {{PLAN_DETAIL_3}}

<!-- Uvést doporučené pořadí navazujících pracovních bloků.
Jeden bezprostřední krok musí být zopakován samostatně v následující kapitole NEXT STEP. -->

## 15. NEXT STEP – jeden hlavní další krok

**{{JEDEN_HLAVNI_DALSI_KROK}}**

{{UPRESNENI_DALSIHO_KROKU}}

<!-- Tato kapitola musí obsahovat právě jeden hlavní krok.
Nemá obsahovat celý dlouhodobý plán. -->

## 16. Vazby a NAVÁZÁNÍ

| Vazba | Dokument |
|---|---|
| Předchozí denní zápis | `{{PREDCHOZI_DENNI_ZAPIS_NEBO_NENI}}` |
| Navazující dokument | `{{NAVAZUJICI_DOKUMENT_NEBO_BUDE_VYTVOREN}}` |
| Související standard nebo hlavní dokument | `{{SOUVISEJICI_DOKUMENT_1}}` |
| Související report | `{{SOUVISEJICI_REPORT_1}}` |

{{POPIS_VAZBY_NA_NAVAZANI}}

<!-- Uvést, zda:
- vzniká nový dokument NAVÁZÁNÍ,
- se aktualizuje existující NAVÁZÁNÍ,
- denní zápis nevyžaduje samostatné navázání. -->

## 17. Technická dohledatelnost a uzavření

| Položka | Hodnota |
|---|---|
| Datum a čas uzavření | {{DATUM_CAS_ISO_8601}} |
| Git větev | `{{GIT_BRANCH}}` |
| Git commit | `{{GIT_COMMIT}}` |
| Git push | {{GIT_PUSH_STATUS}} |
| Stav pracovního stromu | {{GIT_WORKTREE_STATUS}} |
| Poslední A17 stav | {{A17_STATUS}} |
| Poslední A24 stav | {{A24_STATUS}} |
| Poslední A7 stav | {{A7_STATUS}} |
| Workspace | `{{WORKSPACE_PATH}}` |
| Kanonický soubor | `docs/09_HISTORY/DENNÍ_ZÁPISY/{{NAZEV_SOUBORU}}` |

## Schválení dokumentu

- [ ] Byly nahrazeny všechny proměnné `{{...}}`.
- [ ] Byla ověřena správnost všech kapitol.
- [ ] Byla ověřena terminologie podle MM-REF-001 a MM-REF-002.
- [ ] Provedené práce odpovídají skutečně dokončeným činnostem.
- [ ] Ověřené výsledky obsahují dohledatelné důkazy.
- [ ] CURRENT STATUS odpovídá stavu na konci dne.
- [ ] AI CONTEXT umožňuje bezpečné pokračování práce.
- [ ] PROJECT SNAPSHOT a DATABASE SNAPSHOT obsahují aktuální nebo časově označené hodnoty.
- [ ] NEXT STEP obsahuje právě jeden hlavní krok.
- [ ] Byla správně zvýšena verze, pokud se změnil již importovaný dokument.
- [ ] Byl spuštěn finální A17.
- [ ] A17 neobsahuje žádný výsledek FAIL ani PARTIAL.
- [ ] Uživatel schválil vytvoření kanonické verze.
- [ ] Git commit obsahuje pouze zamýšlené soubory.
- [ ] A24 VALIDATE_ONLY proběhl úspěšně.
- [ ] A24 APPLY a A7 byly spuštěny až po úspěšné validaci.

<!-- MM-TEMPLATE-END -->

---

## 4. Minimální audit před použitím

| Kontrola | Požadovaný výsledek |
|---|---|
| Formát Document ID | `MM-DL-YYYYMMDD` |
| Název souboru | `MM-DL-YYYYMMDD_MATCHMATRIX_DENNI_ZAPIS.md` |
| Nevyplněné proměnné `{{...}}` | 0 |
| Povinné kapitoly DAILY_LOG | Přítomné |
| CURRENT STATUS | Přítomný a aktuální |
| AI CONTEXT | Přítomný |
| PROJECT SNAPSHOT | Přítomný |
| DATABASE SNAPSHOT | Přítomný nebo časově označený |
| OPEN QUESTIONS | Přítomné |
| NEXT STEP | Právě jeden hlavní krok |
| Vazba na NAVÁZÁNÍ | Vyplněná |
| A17 FAIL | 0 |
| A17 PARTIAL | 0 |
| Terminologie | Ručně ověřena nebo zpracována terminologickým workflow |
| Verze | Zvýšena při změně již importovaného obsahu |
| Git pracovní strom | Bez nesouvisejících změn |
| A24 VALIDATE_ONLY | Úspěšný |
| A24 APPLY | Spuštěn až po validaci |
| A7 | VERIFIED |

---

## 5. Historie verzí

| Verze | Datum | Změna | Autor |
|---|---|---|---|
| 1.0 | 2026-07-11 | První návrh šablony vytvořený z ověřeného dokumentu MM-DL-20260711. Doplněny povinné kontextové sekce podle MM-STD-009. | Petr / OpenAI ChatGPT |
