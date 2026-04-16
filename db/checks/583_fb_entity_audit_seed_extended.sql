UPDATE ops.fb_entity_audit
SET
    primary_provider = 'theodds',
    fallback_provider = 'api_football',
    coverage_status = 'runtime_tested',
    real_data_flow = TRUE,
    execution_mode = 'automatic',
    automator_ready = TRUE,
    requires_pro = FALSE,
    staging_table = 'public.odds / provider raw flow',
    public_dependency = 'public.odds + match linker',
    post_process = 'odds ingest + attach to canonical matches + audit unmatched',
    known_issues = 'TheOdds coverage hlavně top ligy a soutěže; linker a coverage gap musí být hlídané',
    notes = 'Primary odds source pro FB je TheOdds; api_football odds je jen doplněk, ne hlavní runtime směr',
    updated_at = now()
WHERE entity = 'odds';

UPDATE ops.fb_entity_audit
SET
    primary_provider = 'api_football',
    fallback_provider = NULL,
    coverage_status = 'planned',
    real_data_flow = FALSE,
    execution_mode = 'manual_only',
    automator_ready = FALSE,
    requires_pro = TRUE,
    staging_table = 'staging.stg_provider_players',
    public_dependency = 'public.players + player_provider_map',
    post_process = 'player canonical merge + provider mapping',
    known_issues = 'Players vyžadují PRO a opatrné plánování request budgetu',
    notes = 'Do orchestrátoru až po PRO režimu a po potvrzení harvest dávkování po sezonách a ligách',
    updated_at = now()
WHERE entity = 'players';

UPDATE ops.fb_entity_audit
SET
    primary_provider = 'api_football',
    fallback_provider = NULL,
    coverage_status = 'runtime_tested',
    real_data_flow = TRUE,
    execution_mode = 'validate_only',
    automator_ready = FALSE,
    requires_pro = TRUE,
    staging_table = 'staging.stg_provider_player_stats',
    public_dependency = 'public player stats vrstva',
    post_process = 'merge + validace coverage + návaznost na players',
    known_issues = 'Technické napojení existuje, ale free plán limituje hloubku; bez PRO nelze považovat za plně harvest-ready',
    notes = 'Nejblíž k zapnutí po PRO; před automatem potvrdit budget, kvalitu a vazbu na canonical players',
    updated_at = now()
WHERE entity = 'player_stats';

UPDATE ops.fb_entity_audit
SET
    primary_provider = 'api_football',
    fallback_provider = NULL,
    coverage_status = 'planned',
    real_data_flow = FALSE,
    execution_mode = 'manual_only',
    automator_ready = FALSE,
    requires_pro = TRUE,
    staging_table = 'staging future / season stats flow',
    public_dependency = 'public.player_season_statistics',
    post_process = 'season aggregation + merge + coverage validation',
    known_issues = 'Vyžaduje PRO, rozumné dávkování a kontrolu request budgetu',
    notes = 'Patří až do pozdější fáze po potvrzení players harvestu',
    updated_at = now()
WHERE entity = 'player_season_stats';

UPDATE ops.fb_entity_audit
SET
    primary_provider = 'api_football',
    fallback_provider = NULL,
    coverage_status = 'planned',
    real_data_flow = FALSE,
    execution_mode = 'manual_only',
    automator_ready = FALSE,
    requires_pro = TRUE,
    staging_table = 'staging future / coaches flow',
    public_dependency = 'coach/public future layer',
    post_process = 'coach ingest + canonical mapping',
    known_issues = 'Coaches vyžadují PRO a nejsou součástí prvního harvest automatu',
    notes = 'Nechat mimo orchestrátor v1',
    updated_at = now()
WHERE entity = 'coaches';

UPDATE ops.fb_entity_audit
SET
    primary_provider = 'derived_from_matches',
    fallback_provider = 'football_data refresh path',
    coverage_status = 'runtime_tested downstream',
    real_data_flow = TRUE,
    execution_mode = 'automatic',
    automator_ready = TRUE,
    requires_pro = FALSE,
    staging_table = NULL,
    public_dependency = 'public.league_standings',
    post_process = 'refresh standings from public.matches po ingestu fixtures/results',
    known_issues = 'Není to samostatný provider ingest; je to downstream refresh vrstva a musí běžet po update matches',
    notes = 'Patří do orchestrátoru jako povinný post-process po FB fixtures',
    updated_at = now()
WHERE entity = 'standings';