# MM-TPL-001

# ŠABLONA NAVÁZÁNÍ DO NOVÉHO CHATU

---

## Informace o šabloně

| Položka | Hodnota |
|---|---|
| Document ID | MM-TPL-001 |
| Název dokumentu | Šablona navázání do nového chatu |
| Typ dokumentu | TEMPLATE |
| Cílový typ dokumentu | CHAT_CONTINUATION |
| Edice | MM-TPL |
| Verze | 1.0 |
| Stav | DRAFT – NEEDS_USER_APPROVAL |
| Datum vytvoření | 2026-07-11 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Kanonické umístění | `docs/13_TEMPLATES/MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md` |
| Referenční dokument | `MM-NAV-20260711-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md`, verze 1.1 |
| Řídicí standardy | MM-DOC-901, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-009 |

---

## 1. Účel šablony

Tato šablona slouží k vytváření dokumentů typu `CHAT_CONTINUATION`.

Jejím cílem je zajistit, aby každý nový navazovací dokument:

- obsahoval všechny povinné kapitoly,
- používal jednotné názvy kapitol,
- odděloval ověřený stav od plánů a otevřených úkolů,
- obsahoval jednoznačný AI CONTEXT,
- obsahoval PROJECT SNAPSHOT a DATABASE SNAPSHOT,
- určoval právě jeden doporučený další krok,
- byl připraven pro audit A17 bez rozsáhlého ručního mapování v A19.

---

## 2. Pravidla použití

1. Nový dokument se vytvoří z obsahu mezi značkami `MM-TEMPLATE-START` a `MM-TEMPLATE-END`.
2. Všechny proměnné ve formátu `{{NAZEV_PROMENNE}}` musí být nahrazeny skutečnou hodnotou.
3. V dokumentu nesmí po dokončení zůstat žádná nevyplněná proměnná.
4. Do části **Co bylo dokončeno** patří pouze ověřené výsledky.
5. Do části **Co zůstává rozpracováno** patří aktivní pracovní bloky.
6. Do části **OPEN QUESTIONS / otevřené úkoly** patří konkrétní dosud neprovedené úkoly.
7. Část **NEXT STEP** musí obsahovat právě jeden hlavní krok.
8. Cesty k souborům, názvy skriptů, Git commity a databázové údaje musí být technicky ověřené.
9. Pokud je dokument po importu obsahově změněn, musí být zvýšena jeho verze.
10. Publikační pořadí je: kanonický A17 → Git commit → A24 VALIDATE_ONLY → A24 APPLY → A7.

---

## 3. Výstupní šablona

<!-- MM-TEMPLATE-START -->

# {{NAZEV_DOKUMENTU}}

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | {{DOCUMENT_ID}} |
| Název dokumentu | {{NAZEV_DOKUMENTU}} |
| Typ dokumentu | CHAT_CONTINUATION |
| Verze | {{VERZE}} |
| Stav | {{STAV}} |
| Datum | {{DATUM_YYYY_MM_DD}} |
| Datum a čas uzavření | {{DATUM_CAS_ISO_8601}} |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | {{PRACOVNI_OBLAST}} |
| Primární formát | Markdown (.md) |
| Kanonické umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/{{NAZEV_SOUBORU}}` |
| Zdrojový denní zápis | `{{ZDROJOVY_DENNI_ZAPIS}}` |
| Předchozí navázání | `{{PREDCHOZI_NAVAZANI_NEBO_NENI}}` |

## 1. Identifikace navázání

| Položka | Hodnota |
|---|---|
| Document ID | {{DOCUMENT_ID}} |
| Název dokumentu | {{NAZEV_DOKUMENTU}} |
| Typ dokumentu | CHAT_CONTINUATION |
| Verze | {{VERZE}} |
| Stav | {{STAV}} |
| Datum | {{DATUM_YYYY_MM_DD}} |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | {{PRACOVNI_OBLAST}} |
| Primární formát | Markdown (.md) |
| Kanonické umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/{{NAZEV_SOUBORU}}` |
| Zdrojový denní zápis | `{{ZDROJOVY_DENNI_ZAPIS}}` |

## 2. Výchozí kontext

{{VYCHOZI_KONTEXT}}

<!-- Stručně popsat:
- z jakého pracovního stavu dokument vychází,
- na jaký denní zápis nebo předchozí navázání navazuje,
- proč je dokument vytvářen. -->

## 3. CURRENT STATUS

{{AKTUALNI_STAV}}

<!-- Uvést pouze aktuálně ověřený stav:
- aktivní soubory a skripty,
- pracovní větev nebo oblast,
- stav panelu a workflow,
- execution host, DB host a DB target, pokud jsou relevantní. -->

## 4. Co bylo dokončeno

{{DOKONCENE_PRACE}}

<!-- Uvést pouze skutečně dokončené a ověřené výsledky.
Každý významný výsledek má obsahovat důkaz: report, commit, stav auditu nebo databázový výsledek. -->

## 5. Co zůstává rozpracováno

{{ROZPRACOVANE_PRACE}}

<!-- Popsat pracovní bloky, které již začaly, ale nejsou uzavřené. -->

## 6. OPEN QUESTIONS / otevřené úkoly

{{OTEVRENE_UKOLY}}

<!-- Uvést konkrétní neprovedené úkoly.
Nepopisovat zde obecnou dlouhodobou vizi, pokud není přímo součástí aktuálního pracovního bloku. -->

## 7. Rizika a upozornění

{{RIZIKA_A_UPOZORNENI}}

<!-- Pokud nejsou známa žádná rizika, uvést:
„K okamžiku uzavření dokumentu nebylo zjištěno nové kritické riziko.“
Nevynechávat celou kapitolu. -->

## 8. Přijatá rozhodnutí a platná pravidla

{{PRIJATA_ROZHODNUTI_A_PRAVIDLA}}

<!-- Uvést závazná rozhodnutí, která musí být v novém chatu zachována. -->

## 9. Ověřené zdroje, soubory a příkazy

{{OVERENE_ZDROJE_SOUBORY_A_PRIKAZY}}

<!-- Doporučené členění:
- aktivní soubory,
- historické soubory,
- reporty,
- Git commit,
- databázové objekty,
- ověřené příkazy. -->

## 10. AI CONTEXT

{{AI_CONTEXT}}

<!-- AI CONTEXT musí obsahovat:
- hlavní cíl pokračování,
- závazná technická pravidla,
- hostitelské a databázové omezení,
- způsob práce krok po kroku,
- co se nesmí měnit bez nového ověření,
- z čeho má AI při pokračování vycházet. -->

## 11. PROJECT SNAPSHOT

| Oblast | Ověřený stav |
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

## 13. NEXT STEP

**{{JEDEN_HLAVNI_DALSI_KROK}}**

{{UPRESNENI_DALSIHO_KROKU}}

<!-- Tato kapitola musí obsahovat právě jeden hlavní krok.
Nemá obsahovat celý plán dalších etap. -->

## 14. Technická dohledatelnost a uzavření

| Položka | Hodnota |
|---|---|
| Datum a čas uzavření | {{DATUM_CAS_ISO_8601}} |
| Git větev | `{{GIT_BRANCH}}` |
| Git commit | `{{GIT_COMMIT}}` |
| Stav pracovního stromu | {{GIT_WORKTREE_STATUS}} |
| Poslední A17 stav | {{A17_STATUS}} |
| Poslední A24 stav | {{A24_STATUS}} |
| Poslední A7 stav | {{A7_STATUS}} |
| Workspace | `{{WORKSPACE_PATH}}` |
| Kanonický soubor | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/{{NAZEV_SOUBORU}}` |

## Schválení dokumentu

- [ ] Byly nahrazeny všechny proměnné `{{...}}`.
- [ ] Byla ověřena správnost všech kapitol.
- [ ] Byla ověřena terminologie podle MM-REF-001 a MM-REF-002.
- [ ] Byl spuštěn finální A17.
- [ ] A17 neobsahuje žádný výsledek FAIL ani PARTIAL.
- [ ] Byla správně zvýšena verze, pokud se změnil již importovaný dokument.
- [ ] Uživatel schválil vytvoření kanonické verze.
- [ ] Git commit obsahuje pouze zamýšlené soubory.
- [ ] A24 VALIDATE_ONLY proběhl úspěšně.
- [ ] A24 APPLY a A7 byly spuštěny až po úspěšné validaci.

<!-- MM-TEMPLATE-END -->

---

## 4. Minimální audit před použitím

Před vytvořením kanonického dokumentu musí být ověřeno:

| Kontrola | Požadovaný výsledek |
|---|---|
| Nevyplněné proměnné `{{...}}` | 0 |
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
| 1.0 | 2026-07-11 | První návrh šablony vytvořený z ověřeného dokumentu MM-NAV-20260711-01 verze 1.1. | Petr / OpenAI ChatGPT |
