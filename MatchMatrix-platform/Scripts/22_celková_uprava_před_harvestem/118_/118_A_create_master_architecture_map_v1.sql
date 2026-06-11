/*
MATCHMATRIX SQL 118_A
CREATE MASTER ARCHITECTURE MAP V1

CO TO JE:
- Zakládá centrální OPS tabulku s architekturou celé platformy.

K ČEMU TO JE:
- Aby panel V18, dokumentace a governance měly jednu mapu systému.

KDE TO UVIDÍME:
- OPS Panel V18 -> Architecture / Governance / Roadmap.

JAK SE TO VYUŽIJE:
- Panel bude číst vrstvy projektu z ops.master_architecture_map.
*/

CREATE TABLE IF NOT EXISTS ops.master_architecture_map (
    id BIGSERIAL PRIMARY KEY,
    layer_order INTEGER NOT NULL,
    layer_code TEXT NOT NULL UNIQUE,
    layer_name TEXT NOT NULL,
    what_is_it TEXT,
    purpose TEXT,
    input_source TEXT,
    output_target TEXT,
    master_objects TEXT,
    panel_usage TEXT,
    governance_status TEXT NOT NULL DEFAULT 'ACTIVE_MASTER',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO ops.master_architecture_map (
    layer_order,
    layer_code,
    layer_name,
    what_is_it,
    purpose,
    input_source,
    output_target,
    master_objects,
    panel_usage,
    governance_status
)
VALUES
(1, 'PROVIDER', 'Provider Layer',
 'Externí zdroje sportovních dat, people dat, media dat a odds dat.',
 'Získat data od API providerů, CSV zdrojů, RSS a oficiálních webů.',
 'API-Football, API-Sport, API-Hockey, Football-Data, TheOdds, SportsDataIO, RSS, Official Sites',
 'RAW / STAGING',
 'ops.provider_sport_matrix, ops.provider_entity_coverage, ops.provider_jobs',
 'Provider Command Center',
 'ACTIVE_MASTER'),

(2, 'RAW', 'Raw Layer',
 'Vrstva pro uložení původních odpovědí providerů bez úprav.',
 'Umožnit audit, reprocessing a kontrolu původních dat.',
 'Provider responses',
 'STAGING',
 'staging.*_raw, staging.stg_api_payloads',
 'Harvest / Runtime audit',
 'ACTIVE_MASTER'),

(3, 'STAGING', 'Staging Layer',
 'Normalizovaná mezivrstva před uložením do public modelu.',
 'Sjednotit provider data do technické struktury.',
 'RAW',
 'MERGE',
 'staging.stg_provider_fixtures, staging.stg_provider_teams, staging.stg_provider_players, staging.stg_provider_odds, staging.stg_media_articles',
 'Data Quality / Merge readiness',
 'ACTIVE_MASTER'),

(4, 'MERGE', 'Merge Layer',
 'Vrstva převodu staging dat do produkčního public modelu.',
 'Vytvořit kanonické ligy, týmy, zápasy, hráče, články a kurzy.',
 'STAGING',
 'PUBLIC',
 'workers merge scripts, provider maps',
 'Merge status / Runtime',
 'ACTIVE_MASTER'),

(5, 'PUBLIC', 'Public Layer',
 'Hlavní produkční datový model aplikace.',
 'Sloužit webu, analytice, ratingům, predikcím a tiketům.',
 'MERGE',
 'WEB / ML / TICKET ENGINE',
 'public.matches, public.teams, public.players, public.leagues, public.odds, public.articles',
 'Project Progress / Sport Readiness',
 'ACTIVE_MASTER'),

(6, 'PEOPLE', 'People Layer',
 'Vrstva hráčů, trenérů, profilů, fotek a statistik.',
 'Doplnit sportům lidskou vrstvu pro web, ratingy a predikce.',
 'Providers / STAGING / PUBLIC',
 'PUBLIC / WEB / ML',
 'ops.people_master_provider_matrix, ops.provider_people_audit',
 'People Command Center',
 'ACTIVE_MASTER'),

(7, 'MEDIA', 'Media Layer',
 'Články, videa, highlights a napojení na ligy, týmy, hráče a zápasy.',
 'Vytvořit obsahovou vrstvu pro web a engagement uživatelů.',
 'RSS, Official Sites, Media providers',
 'public.articles, media maps',
 'ops.media_refresh_queue, ops.media_source_health_audit, staging.stg_media_articles',
 'Media Command Center',
 'ACTIVE_MASTER'),

(8, 'ODDS', 'Odds Layer',
 'Kurzy, bookmakeři, markety, live odds a historické odds.',
 'Napojit betting data na zápasy, predikce a Ticket Engine.',
 'TheOdds, API provider odds endpoints',
 'public.odds',
 'ops.odds_provider_roadmap, public.odds',
 'Odds Command Center',
 'ACTIVE_MASTER'),

(9, 'ML_MMR', 'MMR / ML Layer',
 'Ratingy týmů, hráčů, zápasů a predikční modely.',
 'Vypočítat sílu týmů, formu, pravděpodobnosti a value edge.',
 'PUBLIC / PEOPLE / ODDS',
 'PREDICTIONS / TICKET ENGINE / WEB',
 'rating views, prediction views',
 'Prediction / Rating dashboard',
 'ACTIVE_MASTER'),

(10, 'TICKET_ENGINE', 'Ticket Engine',
 'Vrstva generování tiketů, strategií a settlementu.',
 'Nabízet uživateli hodnotové tipy a tikety.',
 'ML / ODDS / PUBLIC',
 'WEB',
 'ticket engine tables/views',
 'Ticket dashboard',
 'ACTIVE_MASTER'),

(11, 'WEB', 'Web Platform',
 'Uživatelská aplikace MatchMatrix.',
 'Zobrazit data, predikce, tikety, profily, media a komunitní obsah.',
 'PUBLIC / OPS / ML / TICKET ENGINE',
 'User interface',
 'frontend app, API routes',
 'Launch Progress',
 'ACTIVE_MASTER'),

(12, 'OPS', 'OPS Layer',
 'Řídicí, auditní a provozní vrstva systému.',
 'Řídit harvest, runtime, health, governance, incidenty a panel.',
 'All layers',
 'PANEL / AUTONOMOUS BRAIN',
 'ops.database_object_governance, ops.ingest_planner, ops.scheduler_queue',
 'OPS Center',
 'ACTIVE_MASTER'),

(13, 'AUTONOMOUS_BRAIN', 'Autonomous Brain',
 'Rozhodovací vrstva nad OPS.',
 'Doporučit nebo spustit další nejlepší akci podle stavu systému.',
 'OPS views / runtime / governance / provider health',
 'Scheduler / Panel / Dispatch',
 'ops.v_autonomous_ops_brain_v5, ops.autonomous_execution_queue',
 'Autonomní mozek',
 'ACTIVE_MASTER'),

(14, 'SECOND_PC', 'Second PC Harvest Server',
 'Výkonný harvest server pro masivní backfill.',
 'Stahovat velké objemy dat bezpečně přes planner a lock systém.',
 'OPS planner / scheduler',
 'RAW / STAGING / OPS logs',
 'ops.ingest_planner, ops.scheduler_queue, runtime logs',
 'Harvest Command Center',
 'ACTIVE_MASTER')
ON CONFLICT (layer_code) DO UPDATE SET
    layer_order = EXCLUDED.layer_order,
    layer_name = EXCLUDED.layer_name,
    what_is_it = EXCLUDED.what_is_it,
    purpose = EXCLUDED.purpose,
    input_source = EXCLUDED.input_source,
    output_target = EXCLUDED.output_target,
    master_objects = EXCLUDED.master_objects,
    panel_usage = EXCLUDED.panel_usage,
    governance_status = EXCLUDED.governance_status,
    updated_at = now();

CREATE OR REPLACE VIEW ops.v_master_architecture_map_v1 AS
SELECT
    layer_order,
    layer_code,
    layer_name,
    what_is_it,
    purpose,
    input_source,
    output_target,
    master_objects,
    panel_usage,
    governance_status,
    updated_at
FROM ops.master_architecture_map
ORDER BY layer_order;

SELECT * FROM ops.v_master_architecture_map_v1;