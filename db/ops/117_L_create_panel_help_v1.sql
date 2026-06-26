/*
MATCHMATRIX SQL 117_L
PANEL HELP V1

CO TO JE:
- Centrální tabulka nápověd pro OPS panel.

K ČEMU TO JE:
- Aby klikací vysvětlení CORE / PEOPLE / MEDIA / ODDS / HARVEST / AI OPS nebylo natvrdo v Pythonu.

KDE TO UVIDÍME:
- OPS Panel V17+ po kliknutí na kartu nebo záložku.

JAK SE TO VYUŽIJE:
- Texty půjdou upravovat v DBeaveru bez úpravy panelu.
*/

CREATE TABLE IF NOT EXISTS ops.panel_help (
    help_code text PRIMARY KEY,
    title text NOT NULL,
    co_to_je text,
    k_cemu_to_je text,
    kde_to_uvidime text,
    jak_se_vyuzije text,
    co_zvysi_procento text,
    doporuceny_krok text,
    is_active boolean NOT NULL DEFAULT true,
    sort_order integer NOT NULL DEFAULT 999,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

INSERT INTO ops.panel_help (
    help_code,
    title,
    co_to_je,
    k_cemu_to_je,
    kde_to_uvidime,
    jak_se_vyuzije,
    co_zvysi_procento,
    doporuceny_krok,
    sort_order
)
VALUES
(
    'CORE',
    'DETAIL VRSTVY :: CORE',
    'CORE vrstva = základní sportovní data: sporty, ligy, týmy, zápasy, výsledky a provider mapy.',
    'Je to základ pro celý web, predikce, tikety, ratingy a statistiky.',
    'Přehled, Roadmapa, Harvest, webové stránky, zápasy, ligy, týmy.',
    'Bez CORE vrstvy nejde správně počítat forma, rating, tiket engine ani navazovat People / Media / Odds.',
    'Doplnění lig, týmů, zápasů, výsledků, provider map a merge do public tabulek.',
    'Dokončovat CORE po sportech a hlídat hlavně sporty s DATA GAP.',
    10
),
(
    'PEOPLE',
    'DETAIL VRSTVY :: PEOPLE',
    'PEOPLE vrstva = hráči, trenéři, profily, player stats a provider mapy.',
    'Slouží pro profily hráčů, sestavy, statistiky, formu hráčů a budoucí predikce.',
    'PEOPLE záložka, profily hráčů, detail týmu, detail zápasu, budoucí web.',
    'Propojí hráče a trenéry se sporty, týmy a zápasy.',
    'Spuštění PEOPLE pipeline, doplnění player_provider_map, statistik a smoke testů providerů.',
    'Pokračovat po sportech: FB → BK → HK → HB → VB → AFB.',
    20
),
(
    'MEDIA',
    'DETAIL VRSTVY :: MEDIA',
    'MEDIA vrstva = články, zprávy, videa, highlights, thumbnails a entity matching.',
    'Slouží pro obsah webu, trending, SEO, fan engagement a přehled kolem týmů/hráčů.',
    'MEDIA dashboard, detail zápasu, detail týmu, detail hráče, budoucí homepage.',
    'Články a videa se budou párovat na ligy, týmy, hráče a zápasy.',
    'Více zdrojů, parsery, article_match_map, entity matcher, thumbnail/video enrichment.',
    'Dokončit match linking článků a rozšířit football media.',
    30
),
(
    'ODDS',
    'DETAIL VRSTVY :: ODDS',
    'ODDS vrstva = kurzy, bookmakeři, trhy, value detection a ticket intelligence.',
    'Slouží pro tiket engine, hodnotové kurzy, porovnání bookmakerů a budoucí predikce.',
    'KURZY záložka, tiket engine, detail zápasu, budoucí value bets sekce.',
    'Kurzy se musí napojit na canonical matches, jinak je nelze použít pro tiket engine.',
    'Smoke test odds endpointů, odds staging, merge do public.odds, propojení na zápasy.',
    'Zatím připravit workery a SQL. Velký růst přijde po aktivaci PRO účtu.',
    40
),
(
    'HARVEST',
    'DETAIL VRSTVY :: HARVEST',
    'HARVEST = připravenost celé platformy na velké hromadné stahování dat.',
    'Kontroluje DB, People, Media, Odds, locky, panel a dry-run připravenost.',
    'HARVEST záložka, Mission Control, druhé PC, PRO backfill.',
    'Rozhoduje, jestli už je bezpečné pustit větší harvest bez rozbití dat.',
    'Vyřešit readiness mezery, locky, dry-run, provider roadmap a data gap.',
    'Nejdřív dokončit readiness nad 70 %, pak první bezpečný dry-run.',
    50
),
(
    'AI_OPS',
    'DETAIL VRSTVY :: AI OPS',
    'AI OPS = autonomní mozek MatchMatrix, doporučení, skóre, fronta akcí a učení z výsledků.',
    'Pomáhá rozhodovat, co spustit, co pozastavit, co opravit a co nechat čekat.',
    'AI OPS záložka, doporučená akce, autonomní akce, roadmapa.',
    'Vyhodnocuje provider health, worker health, data gap, readiness a výsledky běhů.',
    'Lepší runtime evidence, méně chyb workerů, více úspěšných autonomních akcí.',
    'Napojit detail nápovědy a pak rozšířit AI OPS dashboard o Brain V5.',
    60
)
ON CONFLICT (help_code) DO UPDATE SET
    title = EXCLUDED.title,
    co_to_je = EXCLUDED.co_to_je,
    k_cemu_to_je = EXCLUDED.k_cemu_to_je,
    kde_to_uvidime = EXCLUDED.kde_to_uvidime,
    jak_se_vyuzije = EXCLUDED.jak_se_vyuzije,
    co_zvysi_procento = EXCLUDED.co_zvysi_procento,
    doporuceny_krok = EXCLUDED.doporuceny_krok,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();