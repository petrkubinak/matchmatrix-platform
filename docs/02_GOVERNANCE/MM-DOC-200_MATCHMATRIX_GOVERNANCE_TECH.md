# MM-DOC-200

# MATCHMATRIX GOVERNANCE

## TECH EDITION

---

## Informace o dokumentu

| Položka | Hodnota |
|---------|----------|
| Dokument | MM-DOC-200 |
| Název | MatchMatrix Governance |
| Edice | MM-DOC TECH |
| Verze | 1.1 |
| Stav | REVIEW |
| Datum aktualizace | 2026-07-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Stabilní Document ID | MM-DOC-200 |
| Aktivní soubor | `docs/02_GOVERNANCE/MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH.md` |
| Historický pracovní alias | MM-DOC-002 |

## Poznámka k identitě dokumentu

Stabilní a finální identita dokumentu Governance je **MM-DOC-200**.

Označení **MM-DOC-002** bylo použito v původních pracovních verzích a zůstává pouze historickým aliasem. Nesmí být znovu používáno jako aktivní Document ID.

V souladu s dokumentačním rámcem MatchMatrix existuje právě jeden aktivní soubor dokumentu. Číslo verze, stav, datum a historie změn se vedou uvnitř dokumentu. Předchozí řízená verze se při vydání nové verze přesouvá do `docs/99_ARCHIVE`.

## Úvod a účel dokumentu
MM-DOC-200 definuje systém pravidel, kontrolních mechanismů, odpovědností a rozhodovacích principů, které chrání dlouhodobou kvalitu, důvěryhodnost, bezpečnost a udržitelnost platformy MatchMatrix.

Governance neurčuje pouze to, zda je technická změna funkční. Určuje také:

- zda je změna dohledatelná,
- zda vychází z ověřených podkladů,
- zda zachovává původ a identitu dat,
- zda neporušuje již potvrzené vazby,
- zda je opakovatelná a auditovatelná,
- zda je právně a licenčně přijatelná,
- zda je připravena pro dlouhodobou správu lidmi i systémy AI.

## Rozsah dokumentu

- Governance databáze a datových změn,
- Governance providerů, zdrojů a licencí,
- Governance identit, mapování a slučování entit,
- prevence duplicit a řízení konfliktů,
- bezpečný režim auditů, validace a aplikace změn,
- správa skriptů, automatizace a provozního prostředí,
- dokumentační Governance a workflow Q3,
- správa terminologie a referenčního slovníku,
- využití AI Context, Project Snapshot a historie chatů,
- monitoring, incidenty, rizika a otevřené případy,
- dlouhodobý rozvoj Governance MatchMatrix.

## Související dokumenty

- MM-DOC-000 – MatchMatrix Documentation Framework
- MM-DOC-100 – MatchMatrix Master
- MM-DOC-300 – MatchMatrix Architecture
- MM-DOC-800 – MatchMatrix Development Handbook
- MM-DOC-900 – MatchMatrix Denní zápisy
- MM-DOC-1000 – Index dokumentů MatchMatrix
- MM-STD-001 až MM-STD-009
- MM-STD-1000 – Index standardů MatchMatrix
- MM-REF-001 – Slovník pojmů MatchMatrix
- MM-PRV-006 – Právní a licenční řízení providerů
- MM-PRV-007 – navazující providerová a právní dokumentace
- `docs/14_EXPORT/HISTORIE_CHATU/MM-EXP-20260727-01_EXTRAKCNI_MATICE_HISTORIE_CHATU_V1.xlsx`

## Historie verzí

| Verze | Datum | Popis |
|--------|-------|-------|
| 0.9 | 2026 | Původní pracovní verze vedená pod označením MM-DOC-002. |
| 1.0 | 2026-06-30 | První sjednocená REVIEW verze se základními oblastmi Database, Provider, Entity, Source, Script a Documentation Governance. |
| 1.1 | 2026-07-27 | Aktualizace podle ověřené historie projektových chatů, skutečného databázového a dokumentačního stavu, bezpečného režimu READ ONLY → VALIDATE ONLY → APPLY, belgického kanonizačního pilotu, pravidla jediné aktivní verze dokumentu a současného workflow Q3. Doplněna formální hierarchie a závěry hlavních kapitol podle výsledku A17 ze dne 2026-07-28. |

---

# Motto

> **Databázi lze vytvořit za několik měsíců. Dlouhodobě důvěryhodnou platformu lze udržet pouze pomocí jasných pravidel, ověřitelných rozhodnutí a kontrolovaných změn.**

---

# Obsah

1. Smysl Governance
2. Proč Governance vznikla
3. Základní filozofie a principy
4. Hierarchie důvěryhodnosti zdrojů
5. Database Governance
6. Governance životního cyklu dat
7. Provider, Source a Legal Governance
8. Entity Identity Governance
9. Duplicate Prevention a Conflict Governance
10. Governance zápasů a providerových identit
11. Bezpečný režim databázových změn
12. Kvalita dat, HOLD a odborné review
13. Script a Automation Governance
14. Provozní Governance PC1 a PC2
15. Documentation Governance
16. Terminology Governance
17. AI a Context Governance
18. Security a Access Governance
19. OPS, monitoring a provozní dohled
20. Incident, Change a Audit Governance
21. Governance jako konkurenční výhoda
22. Aktuální stav, otevřené otázky a další krok

---

# 1. Smysl Governance

Governance v projektu MatchMatrix nevznikla jako administrativní vrstva ani jako soubor formálních pravidel oddělených od praktického vývoje.

Jejím hlavním účelem je chránit dlouhodobou hodnotu společnosti MatchMatrix prostřednictvím ochrany:

- kvality dat,
- správné identity sportovních entit,
- dohledatelnosti původu informací,
- bezpečnosti změn,
- konzistence databázové architektury,
- právní a licenční použitelnosti zdrojů,
- znalostí zachycených v dokumentaci,
- kontinuity práce mezi lidmi, počítači a systémy AI.

Databáze představuje strategické aktivum společnosti. Governance zajišťuje, aby toto aktivum nebylo pouze rozsáhlé, ale také důvěryhodné, vysvětlitelné, rozšiřitelné a použitelné pro produkty a služby platformy.

Každé pravidlo Governance musí mít praktický důvod. Nemá vznikat pouze proto, aby existovalo. Musí reagovat na skutečné riziko, známý problém nebo potřebu dlouhodobého řízení.

---


## 1.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „1. Smysl Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „2. Proč Governance vznikla“, která rozvíjí další část řízeného dokumentu.

# 2. Proč Governance vznikla

V počáteční fázi vývoje bylo hlavním cílem vytvořit funkční databázovou architekturu a připravit systém pro získávání sportovních dat z různých poskytovatelů.

S růstem projektu se začaly objevovat problémy, které nebylo možné řešit pouze jednotlivými SQL opravami:

- stejný tým měl u různých providerů odlišné identifikátory,
- stejné osoby byly vedeny pod různými jmény,
- soutěže měly historické a současné varianty názvů,
- starší a aktuální zdroje používaly rozdílné struktury,
- některé zápasy byly staženy vícekrát,
- historické entity nebylo možné bezpečně sloučit s novodobými následníky,
- neúplné mapování mohlo vytvořit nesprávné kanonické vazby,
- ruční změny bez auditní stopy komplikovaly návrat a kontrolu,
- dokumentace a skutečný technický stav se mohly postupně rozcházet.

Jednorázová oprava může odstranit konkrétní chybu. Governance má zabránit tomu, aby stejný typ chyby vznikal opakovaně.

---


## 2.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „2. Proč Governance vznikla“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „3. Základní filozofie a principy“, která rozvíjí další část řízeného dokumentu.

# 3. Základní filozofie a principy

## 3.1 Ověřený stav má přednost před předpokladem

Rozhodnutí nesmí být založeno pouze na očekávání, historické paměti nebo podobnosti názvů. Před významnou změnou se ověřuje skutečný stav v databázi, repozitáři, dokumentaci nebo autorizovaném zdroji.

## 3.2 Jedna entita – jedna kanonická identita

Každá skutečná sportovní entita má mít jednu řízenou kanonickou identitu. Všechny providerové identity se zachovávají jako dohledatelné vazby, nikoli jako konkurující veřejné entity.

## 3.3 Původ dat se neztrácí

Normalizace ani merge nesmí odstranit informaci o tom, odkud data pocházejí. Provider, providerové ID, zdrojový payload, importní běh a mapovací rozhodnutí musí být podle významu dohledatelné.

## 3.4 Nevratná změna vyžaduje kontrolní body

Rizikové databázové změny procházejí odděleným auditem, transakční validací, řízeným APPLY a následnou kontrolou.

## 3.5 Automatizace nesmí zakrýt rozhodnutí

Automatizace je žádoucí tam, kde je pravidlo jednoznačné a měřitelné. Nejasné identity, konflikty, právní otázky nebo zásahy s vysokým dopadem musí zůstat v režimu REVIEW nebo HOLD.

## 3.6 Fyzické umístění neurčuje identitu

Document ID, canonical entity ID ani providerová identita se neurčuje pouze podle názvu souboru, složky nebo současného zobrazení. Identita je řízený a stabilní údaj.

## 3.7 Historie se zachovává

Předchozí verze dokumentů, auditní výsledky, mapovací rozhodnutí a významné databázové změny se archivují. Historie není překážkou; je důkazem vývoje a podkladem pro audit.

---


## 3.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „3. Základní filozofie a principy“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „4. Hierarchie důvěryhodnosti zdrojů“, která rozvíjí další část řízeného dokumentu.

# 4. Hierarchie důvěryhodnosti zdrojů

Při rozporu informací se používá následující orientační hierarchie:

1. aktuální ověřený stav produkční databáze nebo skutečného repozitáře,
2. výstup specializovaného READ ONLY auditu,
3. potvrzený výsledek transakčního `VALIDATE_ONLY`,
4. výsledek dokončeného `APPLY` a následného post-commit auditu,
5. aktuální aktivní řízená dokumentace,
6. novější ověřený Project Snapshot nebo AI Context Package,
7. denní zápisy, navazovací dokumenty a Git historie,
8. extrahovaná historie chatů,
9. starší pracovní dokumenty a archivní kopie,
10. neověřený předpoklad nebo paměť účastníka.

Tato hierarchie neznamená, že databáze nemůže obsahovat chybu. Znamená, že každé tvrzení musí být posuzováno podle aktuálnosti, původu, auditovatelnosti a vztahu ke skutečnému systému.

Historie chatů je významným důkazním podkladem. Není však automaticky autoritativní. Jednotlivé výroky mohou zachycovat pracovní hypotézu, neúplný stav nebo rozhodnutí, které bylo později změněno.

---


## 4.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „4. Hierarchie důvěryhodnosti zdrojů“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „5. Database Governance“, která rozvíjí další část řízeného dokumentu.

# 5. Database Governance

## 5.1 Účel

Database Governance chrání integritu databázových struktur, dat, vazeb, identit a provozních změn.

Aktuálně řízená databázová oblast zahrnuje zejména schémata:

- `staging`,
- `public`,
- `ops`,
- `documentation`,
- `work`.

Historické odkazy na samostatné aktivní schéma `runtime` se nesmí bez ověření přenášet do současné dokumentace. Provozní funkce mohou existovat v jiných schématech nebo vrstvách a jejich skutečné umístění se určuje podle aktuálního auditu databáze.

## 5.2 Zásady databázových objektů

Každý významný databázový objekt musí mít:

- jednoznačný účel,
- odpovídající schéma,
- jasnou odpovědnost,
- definované klíče a vazby,
- přiměřené indexy,
- dohledatelný vznik nebo změnu,
- návaznou dokumentaci,
- auditní nebo kontrolní mechanismus podle významu.

## 5.3 Ruční změny

Významná databázová změna se neprovádí pouze ručně v DBeaveru bez uloženého skriptu. Každá změna, kterou je potřeba vysvětlit, zopakovat nebo auditovat, musí existovat jako verzovaný SQL soubor.

## 5.4 Oddělení datových vrstev

Providerová data se nemají zapisovat přímo do veřejné vrstvy bez řízené normalizace a mapování.

Základní princip:

```text
provider → raw / staging → normalizace → mapování / merge → public → navazující vrstvy
```

Každá vrstva řeší vlastní odpovědnost. Přeskočení vrstvy musí být výjimečné, odůvodněné a zdokumentované.

---


## 5.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „5. Database Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „6. Governance životního cyklu dat“, která rozvíjí další část řízeného dokumentu.

# 6. Governance životního cyklu dat

## 6.1 Získání dat

Před aktivací provideru se ověřuje technická dostupnost, rozsah, limity, licence, kvalita a dlouhodobá perspektiva zdroje.

## 6.2 Bezpečné uložení

Zdrojová odpověď se ukládá způsobem, který umožňuje zpětně určit původ a případně znovu provést parser nebo mapování.

## 6.3 Normalizace

Normalizace sjednocuje technický formát, nikoli automaticky skutečnou identitu entity. Normalizovaný název není sám o sobě důkazem, že dvě entity jsou totožné.

## 6.4 Mapování

Mapování propojuje providerovou identitu s kanonickou identitou. Musí vycházet z více relevantních signálů, například:

- oficiálního ID nebo přímého providerového odkazu,
- shody soutěže a sezony,
- historického kontextu,
- časové návaznosti,
- zápasových shod,
- známé změny názvu,
- sídla nebo stadionu,
- potvrzeného nástupnictví.

## 6.5 Merge

Merge může aktualizovat kanonickou entitu pouze podle jasných priorit zdrojů a pravidel konfliktu. Nesmí bez kontroly přepsat ověřený údaj méně důvěryhodným zdrojem.

## 6.6 Publikace

Do veřejné vrstvy se publikuje výsledek, který je dostatečně identifikovaný, konzistentní a dohledatelný. Nejasné případy zůstávají mimo automatickou publikaci nebo jsou označeny odpovídajícím stavem.

---


## 6.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „6. Governance životního cyklu dat“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „7. Provider, Source a Legal Governance“, která rozvíjí další část řízeného dokumentu.

# 7. Provider, Source a Legal Governance

## 7.1 Žádný univerzální provider

MatchMatrix nepředpokládá, že jediný provider pokryje všechny sporty, soutěže, období a typy dat.

Governance proto řídí kombinaci zdrojů podle jejich skutečné role. U fotbalu například mohou různé zdroje poskytovat aktuální soutěže, novější historii, starší historická data nebo aktuální kurzy. Tyto role se nesmějí zaměňovat.

## 7.2 Hodnocení provideru

Každý provider se hodnotí nejméně podle těchto oblastí:

- podporované sporty a soutěže,
- dostupné historické období,
- kvalita identifikátorů,
- úplnost týmů, osob a zápasů,
- stabilita API nebo zdroje,
- limity a obchodní podmínky,
- licence a povolený způsob použití,
- možnost uchování a dalšího publikování dat,
- riziko závislosti na jednom dodavateli.

## 7.3 Historické pokrytí

Prioritní soutěže mají být pokryty od svého vzniku, případně od nejstaršího období, které je možné spolehlivě, legálně a technicky dohledat.

Nepoužívá se obecně stanovený mezní rok bez vztahu ke konkrétní soutěži.

## 7.4 Ověřený seznam soutěží

Počet prioritních nebo dostupných soutěží se neurčuje podle očekávání. Musí odpovídat skutečné odpovědi provideru a schválenému projektovému rozhodnutí.

Pro používaný účet Football-Data byla potvrzena odpověď `/competitions` obsahující 13 soutěží. Úkol uměle dohledat „14. soutěž“ byl odstraněn jako neplatný. FIFA World Cup zůstává prioritní soutěží i přes čtyřletý cyklus.

## 7.5 Licence a právní stav

Technická dostupnost neznamená automatické oprávnění data komerčně používat, uchovávat, obohacovat nebo publikovat.

Provider se nesmí přesunout do produkčního provozu bez přiměřeného právního a licenčního posouzení odpovídajícího jeho roli.

---


## 7.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „7. Provider, Source a Legal Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „8. Entity Identity Governance“, která rozvíjí další část řízeného dokumentu.

# 8. Entity Identity Governance

## 8.1 Kanonická identita

Kanonická identita reprezentuje skutečnou sportovní entitu uvnitř MatchMatrix. Providerové identity se k ní připojují pomocí mapovacích tabulek a auditovatelných pravidel.

## 8.2 Zákaz mapování pouze podle podobnosti názvu

Žádná zakázka, tým, osoba, soutěž ani jiná entita se nesmí automaticky určit pouze podle historického vzoru nebo textové podobnosti názvu.

Podobnost může sloužit jako kandidátní signál. Nesmí být jediným důkazem.

## 8.3 Historické entity a nástupnictví

Historický klub nemusí být totožný se současným klubem podobného názvu. Zánik, sloučení, přesun licence, obnovení nebo vznik nového právního subjektu mohou znamenat samostatnou kanonickou identitu.

Pokud není nástupnictví bezpečně doloženo, případ zůstává samostatný nebo v režimu REVIEW.

## 8.4 Příklad belgického pilotu

V belgickém historickém mapování byly potvrzeny bezpečné identity, například:

- historická identita RAAL byla propojena přes veřejnou kanonickou identitu s odpovídající identitou API-Football,
- historická identita Waasland-Beveren byla propojena na SK Beveren a odpovídající providerovou identitu,
- historické entity Lokeren a Mouscron zůstaly otevřené a nebyly automaticky sloučeny se současnými nebo nástupnickými subjekty.

Tento příklad potvrzuje, že některé vazby lze bezpečně automatizovat, zatímco jiné vyžadují samostatné historické entity a odborné rozhodnutí.

---


## 8.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „8. Entity Identity Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „9. Duplicate Prevention a Conflict Governance“, která rozvíjí další část řízeného dokumentu.

# 9. Duplicate Prevention a Conflict Governance

## 9.1 Prevence před opravou

Nejlepší duplicitní záznam je ten, který vůbec nevznikne. Merge proces proto musí kontrolovat dostupné identity a relevantní kombinace atributů ještě před vytvořením nové veřejné entity.

## 9.2 Druhy konfliktů

Systém rozlišuje nejméně:

- bezpečný překryv stejné události,
- neúplnou identitu,
- konflikt výsledku nebo skóre,
- konflikt soutěže nebo sezony,
- více možných kandidátů,
- historickou entitu bez bezpečného současného mapování,
- technickou duplicitu způsobenou opakovaným importem.

## 9.3 HOLD a REVIEW

Případy s nejednoznačným výsledkem se nesmějí automaticky spojit. Musí přejít do stavu HOLD, REVIEW nebo jiné odpovídající fronty.

## 9.4 Zachování downstream dat

Při odstranění duplicit nebo přesunu kanonické identity se předem kontrolují všechny cizí klíče a navazující tabulky. Funkce, ratingy, providerové vazby a další downstream data se musí bezpečně převést nebo zachovat.

---


## 9.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „9. Duplicate Prevention a Conflict Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „10. Governance zápasů a providerových identit“, která rozvíjí další část řízeného dokumentu.

# 10. Governance zápasů a providerových identit

## 10.1 Providerová mapa zápasů

Tabulka `public.match_provider_map` slouží k oddělení kanonické identity zápasu od jednotlivých providerových identit.

Jeden kanonický zápas může mít více providerových identit. To není duplicita, pokud všechny identity prokazatelně reprezentují stejnou událost.

## 10.2 Belgický kanonizační pilot

Belgický pilot ověřil řízený převod historických zápasů na kanonickou soutěž a současné týmové identity.

Potvrzený stav zahrnuje:

- úspěšně aplikovaných 1 053 plně mapovatelných historických zápasů,
- zachování celkového počtu `public.matches` na 120 981,
- zachování počtu řádků `public.match_provider_map` na 121 908,
- zachování providerových identit a payloadů,
- oddělené zachování globálního problému 78 794 osiřelých řádků `mm_match_ratings`, který nebyl součástí belgické změny.

Následující samostatná skupina 110 zápasů úspěšně prošla režimem `VALIDATE_ONLY`. Transakce byla vrácena zpět, a proto tato skupina v okamžiku uzavření validace nebyla trvale aplikována.

Po plánovaném APPLY přesně těchto 110 zápasů se očekává:

- 121 zbývajících legacy zápasů,
- 119 částečně mapovatelných případů,
- 2 případy vyžadující mapování obou týmů,
- 0 plně mapovatelných případů v daném scope.

Tyto skupiny se nesmějí směšovat. Již aplikovaných 1 053 zápasů se znovu nespouští a APPLY 110 zápasů nesmí zasáhnout zbývajících 121 případů.

## 10.3 Časové rozdíly

Rozdílný kickoff čas mezi historickým a současným zdrojem nemusí automaticky znamenat jiný zápas. Může vzniknout časovým pásmem, neúplným historickým údajem nebo pozdější opravou provideru.

Časová odchylka se posuzuje společně s týmy, soutěží, sezonou, datem, výsledkem a dalšími dostupnými signály.

---


## 10.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „10. Governance zápasů a providerových identit“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „11. Bezpečný režim databázových změn“, která rozvíjí další část řízeného dokumentu.

# 11. Bezpečný režim databázových změn

Rizikové změny se provádějí v následujícím pořadí:

```text
READ ONLY audit
→ přesné vymezení scope
→ VALIDATE_ONLY v transakci
→ kontrola výsledků a invariantu
→ ROLLBACK
→ samostatný APPLY
→ COMMIT
→ post-commit READ ONLY audit
```

## 11.1 READ ONLY audit

Audit musí určit:

- skutečný počet kandidátů,
- přesné identity a tabulky,
- konflikty a otevřené případy,
- dopad na downstream vazby,
- očekávané počty před a po změně.

## 11.2 VALIDATE_ONLY

Validace používá stejnou logiku jako budoucí APPLY, ale změny se na konci vracejí pomocí `ROLLBACK`.

Úspěšný VALIDATE_ONLY dokazuje, že změna je technicky proveditelná v daném okamžiku. Neznamená, že již byla aplikována.

## 11.3 APPLY

APPLY musí mít stejné přesné scope jako schválená validace. Pokud se mezitím změní databáze nebo vstupní podmínky, musí se validace zopakovat.

U významné změny se používají odpovídající zámky tabulek a kontrola cizích klíčů.

## 11.4 Post-commit audit

Po COMMIT se znovu ověřuje:

- počet změněných řádků,
- počet zbývajících kandidátů,
- zachování celkových počtů tam, kde se očekává invariance,
- stav providerových map,
- stav downstream dat,
- vznik nových duplicit nebo osiřelých vazeb.

---


## 11.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „11. Bezpečný režim databázových změn“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „12. Kvalita dat, HOLD a odborné review“, která rozvíjí další část řízeného dokumentu.

# 12. Kvalita dat, HOLD a odborné review

## 12.1 Stav není pouze OK nebo chyba

Governance používá více stavů podle jistoty a dopadu:

- potvrzeno,
- připraveno,
- čeká na validaci,
- REVIEW,
- HOLD,
- konflikt,
- data gap,
- neimplementováno,
- archivováno.

## 12.2 Manuální review je řízený krok

Odborné review není selháním automatizace. Je bezpečnostním mechanismem pro situace, kdy automatický systém nemá dostatek důkazů.

## 12.3 Měřitelné kontroly

Každá významná oblast má mít kontrolu, která dokáže odpovědět alespoň na otázky:

- Kolik záznamů bylo zpracováno?
- Kolik jich bylo změněno?
- Kolik zůstalo otevřených?
- Vznikly nové konflikty nebo duplicity?
- Zůstaly zachovány očekávané invariance?

---


## 12.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „12. Kvalita dat, HOLD a odborné review“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „13. Script a Automation Governance“, která rozvíjí další část řízeného dokumentu.

# 13. Script a Automation Governance

## 13.1 Skript jako řízený artefakt

SQL, Python, PowerShell a další významné skripty jsou součástí dlouhodobého systému. Musí být verzované, dohledatelné a srozumitelné.

## 13.2 Povinná hlavička

Aktivní skripty mají obsahovat jasné části:

- CO skript dělá,
- K ČEMU slouží,
- KDE pracuje,
- JAK se spouští,
- jaké má vstupy a výstupy,
- zda je READ ONLY, VALIDATE_ONLY nebo APPLY,
- jaká rizika nebo omezení se k němu vztahují.

## 13.3 Žádné pevné projektové cesty v Pythonu

Python skripty nesmějí běžně používat pevně zapsané absolutní cesty k projektu. Kořen projektu se odvozuje například pomocí `pathlib.Path` nebo řízené konfigurace.

## 13.4 Aktivní a historická verze

Uživatel udržuje v aktivní složce pouze dokončený aktivní soubor. Starší verze přesouvá do řízené historické složky. Při předání se proto poskytuje úplný aktivní soubor, nikoli směs aktivních a historických kopií.

## 13.5 Spouštěče

Panelové a uživatelské aplikace určené pro Windows mají podle potřeby obsahovat odpovídající `.vbs` spouštěč, aby bylo spuštění jednoduché a konzistentní.

---


## 13.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „13. Script a Automation Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „14. Provozní Governance PC1 a PC2“, která rozvíjí další část řízeného dokumentu.

# 14. Provozní Governance PC1 a PC2

## 14.1 Rozdělení rolí

- **PC1** slouží primárně pro řízení, vývoj, kontrolu, dokumentaci a uživatelskou práci.
- **PC2** slouží jako hlavní databázový a harvest uzel.

Toto rozdělení snižuje riziko, že dlouhodobé nebo náročné procesy naruší běžnou řídicí práci.

## 14.2 Hostitelská nezávislost panelu

Panel Q3 a další řídicí nástroje mají být schopny běžet na PC1 i PC2. Přístup k souborům a databázi se řeší konfigurací, UNC cestami nebo vzdáleným spuštěním, nikoli pevnou závislostí na jednom počítači.

## 14.3 Databázové připojení

Kroky prováděné na PC2 pracují s databází na `localhost` PC2. Řídicí počítač nesmí zaměňovat vlastní `localhost` za databázový server.

## 14.4 Zálohy a návrat

Před rizikovými zásahy musí existovat přiměřená možnost návratu. Může jít o databázovou zálohu, transakční rollback, archivní soubor, Git historii nebo kombinaci více mechanismů.

---


## 14.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „14. Provozní Governance PC1 a PC2“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „15. Documentation Governance“, která rozvíjí další část řízeného dokumentu.

# 15. Documentation Governance

## 15.1 Jediný aktivní soubor

Každý řízený dokument má právě jeden aktivní soubor. Verze a stav se vedou uvnitř dokumentu.

Aktivní název se běžně nemění při každé nové verzi. Předchozí verze se přesouvá do `docs/99_ARCHIVE`.

## 15.2 Stabilní hlavní identity

Hlavní dokumentační řada používá stabilní identity:

- MM-DOC-000 – Documentation Framework,
- MM-DOC-100 – Master,
- MM-DOC-200 – Governance,
- MM-DOC-300 – Architecture,
- MM-DOC-800 – Development Handbook,
- MM-DOC-900 – Denní zápisy.

Historická pracovní označení MM-DOC-001, MM-DOC-002, MM-DOC-003, MM-DOC-004 a MM-DOC-005 zůstávají pouze historickými aliasy a nesmí být znovu používána jako aktivní identity těchto dokumentů.

## 15.3 Workflow Q3

Dokumentační workflow Q3 je rozděleno do čtyř fází:

1. Vybrat a analyzovat,
2. Opravit a zkontrolovat,
3. Vytvořit a schválit,
4. Publikovat.

Hlavní nástroje:

- **A17** – audit souladu se standardem,
- **A18** – standardizační návrh,
- **A19** – kontrola mapování,
- **A20** – builder dokumentu,
- **A24** – import do dokumentační databáze v režimech `VALIDATE_ONLY` a `APPLY`.

## 15.4 Dokumentační databáze

Ověřený projektový snapshot uvádí:

| Oblast | Počet |
|--------|------:|
| Dokumenty | 354 |
| Verze dokumentů | 360 |
| Aktuální verze | 354 |
| Sekce | 7 075 |
| Vazby | 495 |
| Importní běhy | 48 |

Tyto hodnoty jsou stavovým snapshotem, nikoli trvale neměnnou konstantou. Při nové publikaci se aktualizují podle skutečné databáze.

## 15.5 Historie chatů

Extrakční matice historie chatů obsahuje 146 projektových konverzací, 719 automaticky nalezených kandidátů na znalosti a 30 ručně kurátorovaných základních tvrzení.

Automaticky nalezený kandidát není automaticky schválená znalost. Musí být:

1. vyhodnocen,
2. porovnán s aktuálním stavem,
3. přiřazen ke správnému dokumentu,
4. případně formulován jako pravidlo, stav nebo otevřená otázka,
5. zkontrolován a publikován řízeným workflow.

---


## 15.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „15. Documentation Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „16. Terminology Governance“, která rozvíjí další část řízeného dokumentu.

# 16. Terminology Governance

## 16.1 Jedno referenční místo

Každý řízený pojem má mít jedno hlavní referenční místo v aktivním slovníku nebo příslušném odborném dokumentu.

## 16.2 Jeden aktivní MM-REF-001

Nesmí současně existovat více verzí slovníku označených jako aktivní. Starší, neúplné nebo pracovní varianty patří do historie.

## 16.3 Technické názvy a české rozhraní

Technické identifikátory, názvy tabulek, polí, API parametrů a zdrojových objektů se zachovávají v originální podobě.

Uživatelský panel a vysvětlující rozhraní používají české popisky a překlady, aby byla práce rychlá a srozumitelná. Překlad nesmí měnit technickou identitu objektu.

## 16.4 Nový pojem

Nový odborný pojem se před zavedením kontroluje proti aktivnímu slovníku. Pokud neexistuje, vytvoří se návrh definice, přiřadí se referenční dokument a projde odpovídajícím review.

---


## 16.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „16. Terminology Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „17. AI a Context Governance“, která rozvíjí další část řízeného dokumentu.

# 17. AI a Context Governance

## 17.1 AI není autorita bez zdroje

AI může analyzovat, navrhovat, porovnávat a připravovat dokumenty nebo skripty. Nemá však automaticky rozhodovat o nejasné identitě, právním stavu nebo nevratné změně bez ověřitelného podkladu.

## 17.2 Kontextové vrstvy

Pro navázání práce se používají zejména:

- aktivní řízená dokumentace,
- AI Context Package,
- Project Snapshot,
- Database Snapshot,
- denní zápisy,
- navazovací dokumenty,
- Git stav a historie,
- extrakční matice chatů.

Novější ověřený snapshot má přednost před starým navazovacím dokumentem, pokud zachycuje skutečně novější stav.

## 17.3 Rozlišení faktu, rozhodnutí a plánu

AI musí odlišovat:

- provedený a ověřený stav,
- schválené rozhodnutí,
- úspěšnou validaci bez APPLY,
- pracovní návrh,
- budoucí plán,
- otevřenou otázku.

Zaměnění těchto kategorií může způsobit opakování již provedené změny nebo naopak nesprávné tvrzení, že plánovaná změna již byla dokončena.

## 17.4 Praktický příklad

U skupiny 110 belgických zápasů je ověřeno `VALIDATE_ONLY_ROLLBACK_OK`. To znamená, že logika byla úspěšně otestována, ale změna ještě nebyla trvale aplikována.

AI ani dokumentace nesmí tento stav popsat jako dokončený APPLY.

---


## 17.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „17. AI a Context Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „18. Security a Access Governance“, která rozvíjí další část řízeného dokumentu.

# 18. Security a Access Governance

## 18.1 Minimální potřebná oprávnění

Skripty, účty a uživatelé mají používat pouze oprávnění potřebná pro daný úkol.

READ ONLY audit nemá běžet pod účtem nebo v režimu, který zbytečně umožňuje zápis.

## 18.2 Tajné údaje

Hesla, API klíče, tokeny a jiné citlivé hodnoty se neukládají přímo do verzovaných skriptů nebo veřejné dokumentace.

## 18.3 Oddělení validace a produkční změny

Tam, kde je to praktické, se validace a APPLY spouštějí jako oddělené kroky. Tím se snižuje riziko náhodného potvrzení změny při kontrole výsledků.

## 18.4 Přenos mezi počítači

Při vzdáleném spouštění na PC2 se musí jednoznačně určit cílový počítač, projektový kořen, databáze a uživatelský účet. Nejasné nebo implicitní cílení je bezpečnostní i provozní riziko.

---


## 18.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „18. Security a Access Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „19. OPS, monitoring a provozní dohled“, která rozvíjí další část řízeného dokumentu.

# 19. OPS, monitoring a provozní dohled

Governance musí být měřitelná. Pravidlo bez kontroly se může postupně přestat dodržovat, aniž by si toho projekt všiml.

OPS vrstva má podle oblasti sledovat například:

- dostupnost providerů,
- poslední úspěšný harvest,
- počet chyb a retry,
- objem nových záznamů,
- neúplná mapování,
- HOLD a REVIEW fronty,
- duplicity,
- osiřelé vazby,
- stav dokumentačních auditů,
- rozdíl mezi očekávaným a skutečným stavem.

Panel nemá pouze ukazovat čísla. Má odpovídat na otázky:

- Co se děje?
- Je stav v pořádku?
- Pokud není, proč?
- Jaký je bezpečný další krok?

---


## 19.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „19. OPS, monitoring a provozní dohled“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „20. Incident, Change a Audit Governance“, která rozvíjí další část řízeného dokumentu.

# 20. Incident, Change a Audit Governance

## 20.1 Incident

Incident je stav, kdy dojde nebo hrozí:

- poškození dat,
- nesprávné mapování,
- ztráta původu,
- neoprávněná změna,
- výpadek důležitého procesu,
- publikace neověřeného obsahu,
- porušení právních nebo licenčních podmínek.

## 20.2 Reakce na incident

Doporučený postup:

1. zastavit další šíření dopadu,
2. zachovat logy a důkazy,
3. určit přesný scope,
4. provést READ ONLY audit,
5. rozhodnout o rollbacku nebo opravě,
6. ověřit výsledek,
7. zdokumentovat příčinu a preventivní opatření.

## 20.3 Change Governance

Významná změna musí mít:

- důvod,
- vlastníka nebo odpovědnou oblast,
- popis dopadu,
- způsob ověření,
- možnost návratu,
- aktualizaci dokumentace,
- související Git nebo databázovou stopu.

## 20.4 Audit jako opakovatelný nástroj

Audit nemá být jednorázový dotaz bez historie. Má existovat jako uložený skript nebo nástroj, který lze znovu spustit a porovnat výsledky v čase.

---


## 20.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „20. Incident, Change a Audit Governance“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „21. Governance jako konkurenční výhoda“, která rozvíjí další část řízeného dokumentu.

# 21. Governance jako konkurenční výhoda

Kvalitní Governance může působit jako zpomalení, protože před významnou změnou vyžaduje analýzu, validaci a dokumentaci.

Ve skutečnosti však snižuje dlouhodobé náklady projektu:

- brání opakovanému řešení stejných chyb,
- zrychluje přidávání nových providerů a sportů,
- umožňuje bezpečnou automatizaci,
- zvyšuje důvěryhodnost dat,
- usnadňuje spolupráci lidí a AI,
- chrání před ztrátou znalostí,
- zvyšuje připravenost pro komerční produkty a partnery.

Governance proto není pouze kontrolní vrstvou. Je strategickou schopností platformy.

---


## 21.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „21. Governance jako konkurenční výhoda“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „22. Aktuální stav, otevřené otázky a další krok“, která rozvíjí další část řízeného dokumentu.

# 22. Aktuální stav, otevřené otázky a další krok

## 22.1 Aktuální stav Governance

| Oblast | Stav | Poznámka |
|--------|------|----------|
| Database Governance | ACTIVE | Používán READ ONLY audit, VALIDATE_ONLY, APPLY a post-commit kontrola. |
| Provider Governance | ACTIVE | Role providerů se posuzují samostatně podle sportu, období a typu dat. |
| Entity Governance | ACTIVE | Kanonické identity a providerové mapy jsou základním principem. |
| Match Governance | ACTIVE | `public.match_provider_map` odděluje kanonické a providerové identity. |
| Duplicate Prevention | ACTIVE / DEVELOPMENT | Základní mechanismy existují, některé konfliktní skupiny zůstávají otevřené. |
| Source Governance | DEVELOPMENT | Probíhá doplňování právních, licenčních a historických zdrojů. |
| Documentation Governance | ACTIVE | Q3, A17–A24 a dokumentační databáze jsou používány. |
| Terminology Governance | ACTIVE / CLEANUP | Je nutné zachovat jediný aktivní MM-REF-001. |
| AI Context Governance | ACTIVE / DEVELOPMENT | Existuje AI Context Package, Project Snapshot a extrakční matice chatů. |
| Security Governance | DEVELOPMENT | Pravidla existují částečně, vyžadují samostatné rozpracování. |
| Billing Governance | PLANNED | Naváže na obchodní model a produkty. |

## 22.2 Otevřené databázové případy

- samostatný APPLY přesně 110 belgických zápasů po úspěšném VALIDATE_ONLY,
- post-commit READ ONLY audit této změny,
- oddělené řešení zbývajících 121 legacy zápasů,
- historická identita a další postup pro Lokeren a Mouscron,
- samostatné řešení 78 794 globálních osiřelých řádků `mm_match_ratings`,
- průběžné řízení duplicit, konfliktů výsledků a neúplných mapování.

## 22.3 Otevřené dokumentační případy

- aktualizace MM-DOC-300 podle skutečného databázového auditu,
- sjednocení MM-STD-003, MM-STD-004 a MM-STD-007,
- doplnění MM-STD-006 až MM-STD-009 do MM-STD-1000,
- určení jediného aktivního a úplného MM-REF-001,
- kontrola duplicitního stromu `docs/docs`,
- přesun odvozených exportů do odpovídající oblasti `docs/14_EXPORT`.

## 22.4 Další krok

Po nahrazení aktivního souboru touto verzí 1.1 navázat dokumentem:

> **MM-DOC-300 – MatchMatrix Architecture, verze 1.1**

Architecture musí převzít pouze technická pravidla a skutečný stav architektury. Governance má zůstat referenčním místem pro pravidla, kontrolní body, stavy, rozhodovací principy a bezpečnost změn.

---


## 22.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „22. Aktuální stav, otevřené otázky a další krok“ v rámci dokumentu MM-DOC-200 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost směřuje k závěru dokumentu a k navazujícím kontextovým, auditním a publikačním krokům.

# Závěr dokumentu

Dokument MM-DOC-200 uzavírá řízený popis oblasti Governance MatchMatrix. Shrnuje pravidla, ověřený stav, odpovědnosti a vazby, které jsou potřebné pro další bezpečnou práci v projektu MatchMatrix. Přínos dokumentu spočívá v jednotném a dohledatelném zachycení této oblasti pro vývoj, audit, rozhodování a dlouhodobou správu. Návaznost pokračuje kontextovými sekcemi AI CONTEXT, PROJECT SNAPSHOT, CURRENT STATUS, OPEN QUESTIONS a NEXT STEP.

# AI CONTEXT

**Role dokumentu:** Hlavní referenční dokument pro řízení kvality, pravidel, bezpečných změn, identit, providerů, zdrojů, dokumentace a provozní důvěryhodnosti platformy MatchMatrix.

**Navazuje na:** MM-DOC-000 a MM-DOC-100.

**Technickou realizaci rozvádí:** MM-DOC-300 a MM-DOC-800.

**Provozní historii poskytuje:** MM-DOC-900, denní zápisy, navazovací dokumenty a Git historie.

**Základní pravidlo pro AI:** Rozlišovat mezi ověřeným stavem, APPLY, VALIDATE_ONLY s rollbackem, pracovním návrhem a budoucím plánem. Neprovádět nejasné identity nebo nevratné změny pouze podle názvu či historického vzoru.

---

# PROJECT SNAPSHOT

- MatchMatrix je multisportovní datová, znalostní a analytická platforma.
- Datový tok používá oddělené vrstvy provider → raw/staging → normalizace → mapování/merge → public → downstream.
- Hlavní databázová schémata posledního referenčního auditu jsou `staging`, `public`, `ops`, `documentation` a `work`.
- `public.match_provider_map` obsahuje 121 908 providerových identit zápasů.
- `public.matches` obsahuje 120 981 kanonických zápasů.
- Belgický pilot má dokončený APPLY 1 053 zápasů.
- Dalších 110 zápasů má úspěšný VALIDATE_ONLY s rollbackem a čeká na samostatný APPLY.
- Zbývajících 121 případů není součástí tohoto APPLY.
- Dokumentační workflow Q3 a nástroje A17–A24 jsou implementovány a používány.
- Dokumentační databáze obsahuje podle posledního ověřeného snapshotu 354 dokumentů a 360 verzí.
- Historie chatů byla zpracována do extrakční matice a slouží jako ověřovací podklad pro nové verze dokumentace.

---

# DATABASE SNAPSHOT

| Ukazatel | Ověřený stav |
|----------|--------------:|
| `public.matches` | 120 981 |
| `public.match_provider_map` | 121 908 |
| Belgické zápasy – dokončený APPLY | 1 053 |
| Belgické zápasy – VALIDATE_ONLY, rollback | 110 |
| Belgické legacy případy po budoucím APPLY 110 | 121 |
| Z toho částečně mapovatelné | 119 |
| Z toho oba týmy nemapované | 2 |
| Globální osiřelé `mm_match_ratings` | 78 794 |
| Dokumenty v dokumentační DB | 354 |
| Verze dokumentů | 360 |
| Aktuální verze | 354 |
| Sekce dokumentů | 7 075 |
| Dokumentační vazby | 495 |
| Importní běhy | 48 |

*Snapshot zachycuje stav potvrzený při přípravě verze 1.1. Před další databázovou změnou se hodnoty znovu ověřují READ ONLY auditem.*

---

# CURRENT STATUS

| Oblast | Stav |
|--------|------|
| Database Governance | ACTIVE |
| Provider Governance | ACTIVE |
| Entity Identity Governance | ACTIVE |
| Match Provider Mapping | ACTIVE |
| Duplicate Prevention | ACTIVE / DEVELOPMENT |
| Source a Legal Governance | DEVELOPMENT |
| Documentation Governance | ACTIVE |
| Terminology Governance | CLEANUP / ACTIVE |
| AI Context Governance | ACTIVE / DEVELOPMENT |
| Security Governance | DEVELOPMENT |
| Billing Governance | PLANNED |

---

# OPEN QUESTIONS

- Jak bude formálně řízeno historické nástupnictví klubů a jiných sportovních subjektů?
- Které části providerového a licenčního hodnocení budou blokovat produkční aktivaci automaticky?
- Jak bude centralizována Security Governance, správa účtů, tajných údajů a vzdáleného spouštění?
- Jak budou řízeny modelové verze ratingů, predikcí a Ticket Engine?
- Jak bude probíhat pravidelná revalidace aktivních mapování po příchodu kvalitnějšího zdroje?
- Jak budou propojeny dokumentační nálezy, databázové audity a OPS incidenty v jednotném panelu?

---

# NEXT STEP

Nahradit aktivní soubor `MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH.md` touto verzí 1.1.

Poté připravit novou verzi `MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md`, která popíše skutečnou aktuální technickou architekturu a odstraní historické nebo neověřené odkazy.
