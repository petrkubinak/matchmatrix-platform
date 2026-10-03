# MM-PRV-010

# MATCHMATRIX DATA ACQUISITION READINESS CHECKLIST

## ŘÍDICÍ CHECKLIST SPORTŮ, ENTIT, PROVIDERŮ A AUDITNÍ PŘIPRAVENOSTI

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PRV-010 |
| Document ID | MM-PRV-010 |
| Název dokumentu | MatchMatrix Data Acquisition Readiness Checklist |
| Typ dokumentu | DATA_ACQUISITION_READINESS_CHECKLIST |
| Dokumentační oblast | 05_PROVIDERS |
| Edice | MM-DOC TECH |
| Verze | 1.0 |
| Stav | DRAFT |
| Datum založení | 2026-09-24 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Cílové umístění | `docs/05_PROVIDERS/` |
| Aktivní soubor | `MM-PRV-010_MATCHMATRIX_DATA_ACQUISITION_READINESS_CHECKLIST_V1.md` |
| Navazuje na | MM-PRV-001 až MM-PRV-009 |
| Řídicí dokument | MM-PRV-009 – MatchMatrix Data Acquisition Blueprint a realizační plán |
| Pilotní sport | HB – Handball |
| Rozsáhlý harvest | BLOKOVÁN do dokončení globálního auditu |

---

# 1. Účel

Tento dokument je živý realizační checklist k `MM-PRV-009`.

Jeho úkolem je umožnit průběžně a jednoznačně sledovat:

- které sporty jsou zahájené, rozpracované, ověřené a auditované,
- které entity jsou skutečně pokryté,
- které časové režimy mají potvrzený zdroj,
- kde je znám PRIMARY a FALLBACK provider,
- kde je dokončeno technické, datové, obchodní a právní ověření,
- které entity jsou připravené pro harvest,
- zda sport prošel finálním auditem,
- zda lze ověřenou metodiku přenést na další sport,
- zda jsou všechny sporty připravené pro globální multisport audit,
- zda lze aktivovat placené providery,
- zda lze spustit hromadný historical harvest,
- zda je možné přejít na nepřetržitý CURRENT / FUTURE / LIVE provoz.

Checklist není náhradou Provider Registry ani Provider Matrix. Eviduje **stav realizace programu**, nikoliv duplicitní providerová fakta.

---

# 2. Stavové značky

| Značka | Stav | Význam |
|---|---|---|
| `[ ]` | NOT_STARTED | krok nebyl zahájen |
| `[-]` | IN_PROGRESS | krok probíhá |
| `[x]` | VERIFIED | krok byl dokončen a má důkaz |
| `[A]` | AUDIT_OK | krok byl dokončen a auditován |
| `[!]` | BLOCKED | existuje blocker |
| `[N/A]` | NOT_APPLICABLE | krok se pro daný sport nebo entitu nepoužije |

Pravidlo: stav `[x]` bez důkazu nebo odkazu na audit není platné dokončení.

---

# 3. Povinné dimenze jedné entity

Každá povinná entita musí být uzavřena nejméně v těchto dimenzích:

| Oblast | Kontrola |
|---|---|
| Entity Catalogue | je entita jednoznačně definována |
| HISTORY_FAN | zdroj hluboké historie nebo explicitní mezera |
| HISTORY_PREDICTION | zdroj a období pro modely |
| CURRENT | zdroj aktuálních dat |
| FUTURE | zdroj budoucích/plánovaných dat |
| PRIMARY | hlavní zdroj |
| FALLBACK | záložní zdroj nebo zdůvodněná absence |
| ENDPOINT / URL | technicky ověřený přístup |
| COVERAGE | reálně ověřený rozsah |
| TECHNICAL | RAW → parser → staging → map → merge cesta |
| COMMERCIAL | tarif, cena a limity |
| LEGAL | licence a práva pro plánované použití |
| CANONICAL | identity a merge pravidla |
| SMOKE TEST | omezený runtime test |
| HISTORICAL PILOT | pilotní backfill, je-li relevantní |
| EVIDENCE | auditní důkaz |
| FINAL STATUS | VERIFIED / BLOCKED / NOT_APPLICABLE |

---

# 4. Globální přehled sportů

| Sport | Kód | Entity Catalogue | Source Matrix | Tech | Commercial | Legal | Historical Pilot | Sport Audit | SPORT COMPLETE |
|---|---:|---|---|---|---|---|---|---|---|
| Football | FB | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Hockey | HK | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Basketball | BK | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Tennis | TN | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MMA | MMA | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Darts | DRT | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Volleyball | VB | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Handball | HB | [-] | [-] | [-] | [-] | [-] | [ ] | [ ] | [ ] |
| Baseball | BSB | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Rugby | RGB | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Cricket | CK | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Field Hockey | FH | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| American Football | AFB | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Esports | ESP | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

---

# 5. Povinný checklist jednoho sportu

Tato tabulka se použije pro každý sport. Entitní řádky se upraví podle schváleného Entity Catalogue daného sportu.

| Doména | Entita | Povinná | H_FAN | H_PRED | CURRENT | FUTURE | PRIMARY | FALLBACK | Coverage | Tech | Commercial | Legal | Canonical | Smoke | Hist. pilot | Evidence | Final |
|---|---|---:|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| CORE | competitions / leagues | ANO | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| CORE | seasons / editions | ANO | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| CORE | teams / participants | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| CORE | fixtures / matches / events | ANO | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| CORE | results | ANO | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| CORE | standings / rankings | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| CORE | venues / locations | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| PEOPLE | players / athletes | ANO | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| PEOPLE | coaches | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| PEOPLE | staff | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| PEOPLE | referees / officials | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| PEOPLE | profiles / bio | ANO | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| PEOPLE | career history | ANO | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| PEOPLE | season statistics | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MATCH DETAIL | lineups / rosters | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MATCH DETAIL | incidents / events | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MATCH DETAIL | match statistics | ANO KDE DOSTUPNÉ | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MATCH DETAIL | player statistics | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MATCH DETAIL | injuries / absences | DLE SPORTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| ODDS | pre-match odds | DLE PRODUKTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| ODDS | live odds | DLE PRODUKTU | [N/A] | [N/A] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [N/A] | [ ] | [ ] |
| ODDS | markets / bookmakers | DLE PRODUKTU | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MEDIA/FAN | news / articles | ANO PRO FAN VRSTVU | [ ] | [N/A] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MEDIA/FAN | photos | DLE PRÁV | [ ] | [N/A] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MEDIA/FAN | video metadata / highlights | DLE PRÁV | [ ] | [N/A] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MEDIA/FAN | honours / achievements | ANO PRO FAN VRSTVU | [ ] | [N/A] | [ ] | [N/A] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MEDIA/FAN | records | ANO PRO FAN VRSTVU | [ ] | [N/A] | [ ] | [N/A] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| MEDIA/FAN | historical squads / context | ANO KDE RELEVANTNÍ | [ ] | [N/A] | [ ] | [N/A] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

---

# 6. Pilotní checklist – HB Handball

Handball je první referenční sport. Jeho úkolem není pouze dokončit házenou, ale ověřit správnost celé metodiky.

## 6.1 HB – Entity Catalogue

| Oblast | Entita | Stav | Poznámka / důkaz |
|---|---|---|---|
| CORE | competitions / leagues | [-] | rozpracováno |
| CORE | seasons | [ ] | |
| CORE | teams | [-] | stávající provider konfigurace existuje |
| CORE | fixtures / results | [-] | stávající provider konfigurace existuje |
| CORE | standings | [ ] | |
| CORE | venues | [ ] | |
| PEOPLE | players | [!] | stávající API people coverage je nutné nahradit / doplnit |
| PEOPLE | coaches | [-] | EHF kandidát + interní konfigurace |
| PEOPLE | staff | [-] | EHF kandidát |
| PEOPLE | profiles | [-] | EHF kandidát |
| PEOPLE | career history | [ ] | |
| PEOPLE | statistics | [ ] | |
| MATCH DETAIL | lineups | [ ] | |
| MATCH DETAIL | incidents | [ ] | |
| MATCH DETAIL | match statistics | [ ] | |
| MATCH DETAIL | player statistics | [ ] | |
| MATCH DETAIL | injuries / absences | [ ] | |
| ODDS | pre-match odds | [ ] | |
| ODDS | live odds | [ ] | |
| MEDIA/FAN | news | [ ] | |
| MEDIA/FAN | photos | [!] | právní review povinné |
| MEDIA/FAN | video | [!] | právní review povinné |
| MEDIA/FAN | honours / records | [ ] | |
| MEDIA/FAN | historical squads | [ ] | |

## 6.2 HB – povinné uzavírací gate

- [ ] Entity Catalogue schválen.
- [ ] `HB × ENTITY × TIME_MODE × SOURCE` matice kompletní.
- [ ] PRIMARY role kompletní.
- [ ] FALLBACK role kompletní nebo zdůvodněná absence.
- [ ] HISTORY_FAN pokrytí zmapované.
- [ ] HISTORY_PREDICTION pokrytí zmapované.
- [ ] CURRENT pokrytí zmapované.
- [ ] FUTURE pokrytí zmapované.
- [ ] Coverage audit dokončen.
- [ ] Commercial audit dokončen.
- [ ] Legal audit dokončen.
- [ ] Technický návrh dokončen.
- [ ] Smoke testy prošly.
- [ ] Historical pilot prošel.
- [ ] Canonical map / merge audit prošel.
- [ ] Provider health pravidla připravena.
- [ ] Kritické blockery = 0.
- [ ] SPORT FINAL AUDIT = PASS.
- [ ] HB označen `SPORT COMPLETE`.
- [ ] Metodika schválena pro přenos na další sport.

---

# 7. Audit po dokončení každého sportu

Sportovní audit musí ověřit:

- úplnost Entity Catalogue,
- pokrytí všech povinných entit,
- čtyři časové režimy tam, kde jsou relevantní,
- PRIMARY / FALLBACK / SUPPLEMENT role,
- skutečnou coverage,
- ověřené endpointy,
- technickou integrační cestu,
- request budget,
- commercial stav,
- legal stav,
- canonical identitu a merge,
- smoke test,
- historical pilot,
- otevřené blockery,
- vazbu na monitoring a dlouhodobý provoz.

Výsledek může být pouze:

`PASS`, `PASS_WITH_NONCRITICAL_GAPS`, nebo `FAIL`.

`PASS_WITH_NONCRITICAL_GAPS` je povolen pouze tehdy, pokud mezery neblokují požadovaný produktový scope a jsou explicitně evidované.

---

# 8. Přenos metodiky na další sport

Další sport se zahájí až po:

- uzavření HB pilotu,
- sportovním auditu HB,
- opravě případných nedostatků Blueprintu,
- opravě případných nedostatků checklistu,
- schválení metodiky.

Přenáší se **metodika**, nikoli předpoklad stejného providerového řešení.

Každý sport musí mít vlastní Entity Catalogue a vlastní zdrojovou realitu.

---

# 9. Globální multisport audit

Po dokončení všech aktivních sportů:

- [ ] všech 14 sportů má `SPORT COMPLETE`,
- [ ] žádná povinná entita není bez rozhodnutí,
- [ ] PRIMARY role jsou konzistentní,
- [ ] FALLBACK strategie je přiměřená,
- [ ] commercial model je kompletní,
- [ ] legal model je kompletní,
- [ ] placené tarify odpovídají skutečně potřebnému scope,
- [ ] request limity stačí na historical harvest i následný provoz,
- [ ] technické ingest cesty jsou auditovatelné,
- [ ] canonical merge pravidla jsou konzistentní,
- [ ] historical harvest je odhadnut časově i objemově,
- [ ] monitoring a stop podmínky jsou připravené,
- [ ] rollback / safe rerun postup existuje,
- [ ] GLOBAL MULTISPORT AUDIT = PASS.

---

# 10. Komerční aktivace providerů

K aktivaci nebo zaplacení placených providerů dojde až po `GLOBAL MULTISPORT AUDIT = PASS`.

Před nákupem musí být potvrzeno:

- [ ] přesný provider,
- [ ] přesný plán,
- [ ] cena a měna,
- [ ] billing period,
- [ ] request / concurrency limity,
- [ ] historical access,
- [ ] live / future access,
- [ ] sporty a entity, které tarif skutečně pokryje,
- [ ] právní oprávnění,
- [ ] plánovaná doba historical harvestu,
- [ ] dlouhodobá CURRENT/FUTURE role,
- [ ] datum schválení.

---

# 11. Hromadný historical harvest

Spuštění je povoleno pouze po dokončení globálního auditu a aktivaci potřebných tarifů.

- [ ] harvest plán po sportech existuje,
- [ ] harvest plán po entitách existuje,
- [ ] časové bloky jsou definované,
- [ ] request budget je definovaný,
- [ ] checkpointy jsou definované,
- [ ] DB growth monitoring je zapnutý,
- [ ] duplicate/orphan kontroly jsou připravené,
- [ ] canonical attach monitoring je připravený,
- [ ] stop podmínky jsou definované,
- [ ] safe rerun je ověřený,
- [ ] průběžný harvest report je připravený.

---

# 12. Audit historických dat

Po ukončení historical harvestu:

- [ ] očekávaná období jsou pokryta,
- [ ] známé mezery jsou zdokumentované,
- [ ] soutěže a sezony jsou konzistentní,
- [ ] identity jsou canonicalizované,
- [ ] duplicity jsou pod kontrolou,
- [ ] orphan záznamy jsou auditované,
- [ ] výsledky a stavy eventů jsou konzistentní,
- [ ] PEOPLE vazby jsou auditované,
- [ ] statistiky mají správné vazby,
- [ ] provenance je dohledatelná,
- [ ] HISTORICAL DATA AUDIT = PASS.

---

# 13. Přechod na nepřetržitý CURRENT / FUTURE / LIVE provoz

Po `HISTORICAL DATA AUDIT = PASS`:

- [ ] CURRENT scheduler aktivní,
- [ ] FUTURE scheduler aktivní,
- [ ] PREMATCH cadence aktivní,
- [ ] LIVE cadence/stream aktivní tam, kde je podporován,
- [ ] POSTMATCH finalizace aktivní,
- [ ] delayed correction refresh aktivní,
- [ ] provider health monitoring aktivní,
- [ ] rate-limit monitoring aktivní,
- [ ] schema-drift monitoring aktivní,
- [ ] freshness monitoring aktivní,
- [ ] incident/fallback postup aktivní,
- [ ] dlouhodobá revalidace providerů naplánována.

Výsledek:

`DATA READY = PASS`

---

# 14. Návaznost na web

`DATA READY = PASS` umožňuje přejít do závěrečné přípravy veřejného produktu.

Web však smí být veřejně spuštěn až po samostatném webovém readiness procesu podle dokumentační řady `MM-WEB`.

Požadované budoucí gate:

- `DATA READY`,
- `WEB PRODUCT READY`,
- `UX READY`,
- `DESIGN SYSTEM READY`,
- `PERFORMANCE READY`,
- `ACCESSIBILITY READY`,
- `SECURITY/PRIVACY READY`,
- `SEO READY`,
- `OBSERVABILITY READY`,
- `WEB LAUNCH AUDIT = PASS`.

---

# 15. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026-09-24 | DRAFT | Založen centrální checklist Data Acquisition programu. Definován sportovní, entitní, auditní, commercial, historical harvest, continuous update a web-readiness postup. |

---

# AI CONTEXT

**Role dokumentu:** Živý realizační checklist k `MM-PRV-009`.

**Pilot:** HB – Handball.

**Kritické pravidlo:** další sport se neotevírá jako dokončená implementace metodiky, dokud pilotní sport neprojde auditním gate.

**Kritické pravidlo 2:** placené providery se aktivují až po globálním multisport auditu.

**Kritické pravidlo 3:** po historical harvestu musí následovat historical data audit před přechodem na nepřetržitý provoz.

**Kritické pravidlo 4:** `DATA READY` není totéž jako `WEB READY`.
