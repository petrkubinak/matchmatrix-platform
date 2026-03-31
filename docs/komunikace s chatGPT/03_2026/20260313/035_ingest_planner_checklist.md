# MatchMatrix – Ingest Planner checklist

## 035 – Ingest Planner V1

- [x] Navržen koncept `ops.ingest_planner`
- [x] Vytvořen SQL soubor `035_ops_create_ingest_planner.sql`
- [x] SQL tabulka `ops.ingest_planner` spuštěna v DB
- [x] Ověřena struktura tabulky v DBeaveru
- [x] Připraven `workers/build_ingest_planner_jobs.py`
- [ ] Otestován `build_ingest_planner_jobs.py` v `--dry-run`
- [ ] Otestován reálný insert planner jobů do DB
- [ ] Ověřen výpis planner jobů v DBeaveru
- [ ] Připravit worker pro čtení `ops.ingest_planner`
- [ ] Napojit planner na scheduler
- [ ] Napojit planner na panel V4
- [ ] Připravit FREE režim (2022–2024)
- [ ] Připravit PRO backfill režim
- [ ] Připravit retry logiku planner jobů
- [ ] Připravit statusy `pending / running / done / error`

## Doporučené testy

- [ ] Football + teams + FOOTBALL_MAINTENANCE
- [ ] Football + fixtures + FOOTBALL_MAINTENANCE
- [ ] Hockey + fixtures + FREE_TEST_PRIMARY
- [ ] Basketball + fixtures + FREE_TEST_PRIMARY

## Poznámky

- `ops.ingest_targets` je zatím částečně legacy.
- Football má explicitní season.
- Hockey a basketball mají aktivní targety s blank season.
- Planner V1 zatím generuje joby z aktivních `ingest_targets`.