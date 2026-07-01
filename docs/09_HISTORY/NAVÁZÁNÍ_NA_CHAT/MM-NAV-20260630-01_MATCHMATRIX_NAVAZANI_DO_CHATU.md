# MATCHMATRIX – NAVÁZÁNÍ DO NOVÉHO CHATU – 2026-06-30

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260630-01 |
| Název dokumentu | MATCHMATRIX – NAVÁZÁNÍ DO NOVÉHO CHATU – 2026-06-30 |
| Typ dokumentu | CHAT_CONTINUATION |
| Verze | 1.0 |
| Stav | REVIEW |
| Datum | 2026-06-30 |
| Pořadí v rámci dne | 01 |
| Autor | Petr Kubinák |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Pracovní oblast | Documentation Management, Terminology Governance, Remote Operator |
| Zdrojový denní zápis | MM-DL-20260630 |
| Primární prostředí | PC2 – `C:\MatchMatrix-platform` |
| Ovládací pracoviště | PC1 |
| Primární formát | Markdown (`.md`) |

> Tento dokument slouží jako přesný předávací kontext pro pokračování práce v novém chatu. Neobsahuje přístupový token webového panelu, protože token je dočasný provozní údaj konkrétního běhu.

---

# 1. Účel navázání

Cílem tohoto dokumentu je umožnit okamžité pokračování v dokumentační a terminologické větvi MatchMatrix bez opakovaného zjišťování již dokončených kroků.

Práce je aktuálně ve fázi:

```text
A23 – TERMINOLOGY CANDIDATE REVIEW
```

Strukturální standardizace historického denního zápisu `MM-DL-20260624` je hotová. Otevřeným bodem zůstává uživatelská terminologická revize 67 položek.

---

# 2. Výchozí stav projektu

## 2.1 Dokumentační identita

Bylo schváleno a zapsáno do MM-STD-007:

```text
Denní zápis:
MM-DL-YYYYMMDD

NAVÁZÁNÍ:
MM-NAV-YYYYMMDD-PP
```

Pro tento pracovní den platí:

```text
Denní zápis:
MM-DL-20260630

První NAVÁZÁNÍ:
MM-NAV-20260630-01
```

## 2.2 Hlavní zpracovávaný historický dokument

```text
Document ID:
MM-DL-20260624

Soubor:
MM-DL-20260624_MATCHMATRIX_DENNI_ZAPIS.md
```

Umístění kandidáta:

```text
C:\MatchMatrix-platform\reports\documentation\standardization\
canonical_candidates\
MM-DL-20260624_MATCHMATRIX_DENNI_ZAPIS.md
```

## 2.3 Stav historického dokumentu

```text
A17 SCORE          : 96.88 %
A17 FAIL           : 0
A17 CRITICAL       : 0
A17 HIGH           : 0
STRUCTURAL READY   : True
TERMINOLOGY OK     : False
CANONICAL PUBLISHED: False
```

Dokument je strukturálně připravený, ale nesmí být publikován před dokončením terminologické revize.

---

# 3. Co bylo dokončeno

## 3.1 MM-STD-007

Standard byl aktualizován na verzi `1.1`.

Doplněno:

- datumové `Document ID` pro denní zápisy,
- datum a pořadí pro dokumenty NAVÁZÁNÍ,
- pravidla jedinečnosti,
- doporučené názvy souborů,
- validační pravidla,
- migrační pravidla pro starší dokumenty.

## 3.2 A17

Soubor:

```text
tools/documentation/25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py
```

Dokončeno:

- podpora `MM-DL-YYYYMMDD`,
- podpora `MM-NAV-YYYYMMDD-PP`,
- kontrola skutečného kalendářního data,
- kontrola placeholderů,
- podpora standardní přípony `.md`,
- zachování starších pořadových identifikátorů.

## 3.3 A21

Soubor:

```text
tools/documentation/25_1_A_21_POLISH_STANDARDIZED_DOCUMENT_CANDIDATE_V1.py
```

Dokončeno:

- oprava počítadla trace comments,
- správně zjištěno 113 trace comments,
- odstraněno 113 trace comments,
- doplnění večerního výsledku pouze z existujícího obsahu,
- nulový počet položek pro ruční redakční kontrolu.

Poslední ověřený běh:

```text
CHANGES            : 52
MANUAL REVIEW      : 0
TRACE REMOVED      : 113
PLACEHOLDERS       : 1
READY FOR A17      : True
```

## 3.4 A22

Soubor:

```text
tools/documentation/25_1_A_22_PREPARE_DAILY_LOG_CANONICAL_APPROVAL_V1.py
```

Dokončeno:

- oprava Windows kódování výstupu A17,
- robustní dekódování UTF-8, systémového kódování, CP1250 a CP852,
- evidence-based date resolution,
- oprava data historického zápisu z `2026-06-30` na `2026-06-24`,
- vytvoření správného `Document ID`,
- nulový počet placeholderů,
- automatické spuštění A17,
- vytvoření terminologického reportu.

Výsledek:

```text
DOCUMENT ID        : MM-DL-20260624
CANONICAL FILENAME : MM-DL-20260624_MATCHMATRIX_DENNI_ZAPIS.md
TERMINOLOGY TERMS  : 7
TERM CANDIDATES    : 74
FINAL STATUS       : DAILY_LOG_CANONICAL_CANDIDATE_READY_FOR_TERMINOLOGY_REVIEW
```

## 3.5 A23

Soubor:

```text
tools/documentation/25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py
```

A23 byl vytvořen jako řízený terminologický editor.

Předklasifikace:

```text
RAW CANDIDATES      : 74
CLEANED ITEMS       : 67
REMOVED/MERGED      : 7
EXISTING_TERM       : 0
NEW_TERM_CANDIDATE  : 21
ABBREVIATION        : 3
PROPER_NAME         : 5
TECHNICAL_IDENTIFIER: 12
FALSE_POSITIVE      : 26
```

První Tkinter verze nebyla vhodná pro ovládání z PC1. A23 byl proto rozšířen o webový režim:

```text
ENGINE:
A23_TERMINOLOGY_CANDIDATE_REVIEW_V1_1_WEB
```

---

# 4. Aktuální technický stav

## 4.1 Dvoupočítačová architektura

```text
PC1 – ovládací stanice:
192.168.3.111

PC2 – proces, data a webový server:
192.168.3.119
```

## 4.2 A23 webový panel

Spuštění na PC2:

```powershell
cd C:\MatchMatrix-platform

py -3.14 `
  .\tools\documentation\25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py `
  --web `
  --host 0.0.0.0 `
  --port 8765
```

A23 generuje dočasný přístupový token.

Pro otevření z PC1 se používá:

```text
http://192.168.3.119:8765/?token=<TOKEN_Z_AKTUALNIHO_BEHU>
```

Token se nesmí ukládat do dokumentace ani do Git repozitáře.

## 4.3 Síťové ověření

Listener na PC2:

```text
LocalAddress : 0.0.0.0
LocalPort    : 8765
```

Test z PC1:

```text
ComputerName     : 192.168.3.119
RemotePort       : 8765
SourceAddress    : 192.168.3.111
TcpTestSucceeded : True
```

Firewallové pravidlo:

```text
MatchMatrix A23 Web 8765
```

## 4.4 Známá drobná závada

A23 při automatickém sestavení URL vybral virtuální adresu:

```text
172.21.144.1
```

Správná LAN adresa PC2 je:

```text
192.168.3.119
```

Při otevření panelu je proto nutné nahradit pouze IP adresu. Port a token se nemění.

## 4.5 Uložený stav revize

```text
REVIEW RESUMED     : True
CONFIRMED          : 0
PENDING            : 67
ADD TO GLOSSARY    : 0
MERGE              : 1
FALSE POSITIVE     : 26
FINAL STATUS       : TERMINOLOGY_CANDIDATE_REVIEW_PENDING
```

---

# 5. Přijatá rozhodnutí

- MM-REF-001 se nesmí měnit automaticky.
- A23 smí vytvářet pouze stav revize a návrh změn.
- Strukturální a terminologické schválení jsou oddělené.
- Historický denní zápis nesmí být publikován před dokončením A23.
- PC1 je ovládací stanice; procesy a data zůstávají na PC2.
- Pro vzdálené ovládání se preferuje webový panel.
- Dočasné tokeny se neukládají do dokumentů.
- A17, A21, A22 a A23 se zatím nemají commitovat.
- Git commit se provede až po dokončení terminologické revize a finálním auditu.

---

# 6. Otevřené problémy

| Priorita | Oblast | Problém | Stav |
|---|---|---|---|
| HIGH | Terminologie | 67 položek čeká na uživatelské potvrzení | OPEN |
| MEDIUM | A23 | Automatická URL používá virtuální IP | OPEN |
| MEDIUM | Slovník | Návrh změn MM-REF-001 ještě nebyl schválen | BLOCKED |
| MEDIUM | Publikování | MM-DL-20260624 ještě není kanonicky publikován | BLOCKED |
| LOW | Git | A17–A23 zatím nejsou commitnuty | WAITING |

---

# 7. Přesný další krok

> **Otevřít webový panel A23 z PC1 a dokončit uživatelskou revizi všech 67 položek.**

## 7.1 Pořadí kontroly

```text
1. FALSE_POSITIVE
2. TECHNICAL_IDENTIFIER
3. PROPER_NAME
4. ABBREVIATION
5. NEW_TERM_CANDIDATE
```

## 7.2 Doporučená rozhodnutí

### FALSE_POSITIVE

```text
REJECT_FALSE_POSITIVE
```

### TECHNICAL_IDENTIFIER

```text
KEEP_REFERENCE_ONLY
```

### PROPER_NAME

```text
KEEP_REFERENCE_ONLY
```

### Skutečný nový projektový termín

```text
Kategorie  : NEW_TERM_CANDIDATE
Rozhodnutí : ADD_TO_GLOSSARY
Potvrzeno  : ANO
```

## 7.3 Kandidáti vyžadující individuální posouzení

- Source Intelligence,
- Source Intelligence Layer,
- Source Discovery,
- Source Discovery Master,
- Source Discovery Queue,
- Source Discovery Audit Tracker,
- Source Discovery Dashboard,
- National League Discovery,
- Activation Roadmap,
- Commercial Model,
- Quality Score.

## 7.4 Kritérium dokončení A23

```text
CONFIRMED : 67
PENDING   : 0

FINAL STATUS:
TERMINOLOGY_CANDIDATE_REVIEW_CONFIRMED
```

---

# 8. Pravidla pro pokračování

- Neměnit přímo MM-REF-001.
- Neměnit ručně A22 terminologický report.
- Neměnit kanonický kandidát během terminologické revize.
- Každou položku v A23 označit jako potvrzenou až po skutečné kontrole.
- Hromadné potvrzení používat pouze nad viditelnými položkami s jistotou HIGH.
- Po dokončení revize zkontrolovat návrh změn slovníku.
- Teprve následný samostatný krok smí aplikovat schválené změny do MM-REF-001.
- Po změně slovníku znovu spustit terminologický audit a A17.
- Kanonické publikování provést až po nulovém počtu blokujících nálezů.
- Git commit provést až po úplném uzavření řetězce.

---

# 9. Soubory a umístění

## 9.1 Produkční skripty

```text
C:\MatchMatrix-platform\tools\documentation\
25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py
25_1_A_21_POLISH_STANDARDIZED_DOCUMENT_CANDIDATE_V1.py
25_1_A_22_PREPARE_DAILY_LOG_CANONICAL_APPROVAL_V1.py
25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py
```

## 9.2 Kanonický kandidát

```text
C:\MatchMatrix-platform\reports\documentation\standardization\
canonical_candidates\
MM-DL-20260624_MATCHMATRIX_DENNI_ZAPIS.md
```

## 9.3 Terminologický report A22

```text
C:\MatchMatrix-platform\reports\documentation\standardization\
canonical_candidates\
MM-DL-20260624_TERMINOLOGY_REPORT.json
```

## 9.4 Stav revize A23

```text
C:\MatchMatrix-platform\reports\documentation\standardization\
terminology_reviews\
MM-DL-20260624_TERMINOLOGY_REVIEW_STATE.json
```

## 9.5 Návrh změn slovníku

```text
C:\MatchMatrix-platform\reports\documentation\standardization\
terminology_reviews\
MM-DL-20260624_TERMINOLOGY_GLOSSARY_PROPOSAL.md
```

## 9.6 Referenční slovník

```text
C:\MatchMatrix-platform\docs\10_REFERENCE\
MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX.md
```

---

# 10. Očekávaný výsledek pokračování

Po dokončení navazujícího pracovního bloku se očekává:

```text
A23 REVIEW                  : CONFIRMED
CONFIRMED ITEMS             : 67
PENDING ITEMS               : 0
GLOSSARY PROPOSAL           : READY
MM-REF-001                  : STÁLE BEZE ZMĚNY
MM-DL-20260624 PUBLICATION  : STÁLE BLOKOVÁNO DO DALŠÍHO KROKU
DATABASE IMPACT             : NONE
```

Následně bude možné připravit další bezpečný skript, který:

1. načte pouze potvrzený A23 review state,
2. vytvoří diff navržených změn MM-REF-001,
3. vyžádá samostatné uživatelské schválení,
4. teprve potom vytvoří novou verzi slovníku,
5. znovu spustí terminologický a compliance audit,
6. připraví historický denní zápis ke kanonickému publikování.

---

# 11. Bezpečnostní stav

```text
GLOSSARY MODIFIED  : False
DOCUMENT MODIFIED  : False
ARCHIVE MODIFIED   : False
DATABASE MODIFIED  : False
CANONICAL PUBLISHED: False
```

Neexistuje žádná nevratná změna. Všechny otevřené kroky jsou řízené a auditovatelné.

---

# 12. Závěr

Dokumentační řetězec je strukturálně funkční a historický zápis `MM-DL-20260624` je připraven k dokončení terminologické governance.

Nejdůležitější změnou je přechod A23 na webové ovládání. Tím je respektována cílová architektura MatchMatrix:

```text
PC2 = procesy, data a služby
PC1 = ovládání a uživatelská kontrola
```

Nový chat nesmí začít dalším vývojem skriptů. Nejprve je nutné dokončit uživatelskou revizi 67 terminologických položek v A23.

---

## Historie verzí

| Verze | Datum | Popis |
|---|---|---|
| 1.0 | 2026-06-30 | První navazovací dokument dne. Zachycuje stav A17–A23, webový panel PC1 → PC2 a přesný další krok terminologické revize. |
