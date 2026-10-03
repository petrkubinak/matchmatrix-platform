/* =============================================================================
CO:
    G4D-4 / ADDITIVE APPLY V1

K ČEMU:
    První trvalá fyzická implementace G4D-2 Design Freeze po úspěšném
    G4D-3 VALIDATE_ONLY.

    Trvale:
      - vytvoří 7 nových ops objektů,
      - vloží safe seed 17 / 35 / 17 / 57 / 27,
      - doplní canonical source_id do existujícího routingu,
      - zachová legacy source_name/source_origin/source_ref_id jako nullable,
      - nastaví canonical routing role a indexy,
      - zachová approval protection,
      - nevytvoří žádné coverage, binding ani routing řádky.

KDE:
    PostgreSQL matchmatrix / PC2

JAK:
    Spustit CELÝ skript najednou v DBeaveru.

DŮLEŽITÉ:
    TOTO JE APPLY.
    Po úspěšném COMMIT změny zůstanou v DB.

    Pokud se objeví jakákoli chyba PŘED COMMIT:
      - NEPOKRAČOVAT,
      - NESPOUŠTĚT COMMIT ručně,
      - spustit ROLLBACK;
      - poslat celý error.

OVĚŘENÝ PŘEDCHOZÍ STAV:
    G4D-3 VALIDATE_ONLY:
      PASS=17
      BLOCKER=0
      FINAL_STATUS=VALIDATE_ONLY_PASS
      POST_ROLLBACK=8/8 PASS

SAFE SEED:
    SOURCE_MASTER            17
    SOURCE_ALIAS             35
    SOURCE_SPORT             17
    SOURCE_AUDIT_EVIDENCE    57
    RUNTIME_ADAPTER          27

ZÁMĚRNĚ ZŮSTÁVÁ 0:
    SOURCE_ENTITY_TIME_COVERAGE
    SOURCE_ADAPTER_BINDING
    SOURCE_ROUTING

FYZICKÉ ROZHODNUTÍ PRO AKTIVNÍ ALIAS:
    Alias s valid_to IS NULL je považován za otevřený/aktivní.
    Pro (alias_type, normalized_alias) smí existovat nejvýše jeden takový alias.
============================================================================= */

BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION READ WRITE;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '180s';


/* ============================================================================
0. PRECHECK — MUSÍ PROJÍT BEZ VÝJIMKY
============================================================================ */

DO $$
DECLARE
    v_count bigint;
BEGIN
    IF current_database() <> 'matchmatrix' THEN
        RAISE EXCEPTION
            'BLOCKER: expected database matchmatrix, current=%',
            current_database();
    END IF;

    IF current_setting('transaction_read_only') <> 'off' THEN
        RAISE EXCEPTION
            'BLOCKER: G4D-4 APPLY requires READ WRITE transaction';
    END IF;

    IF to_regclass('ops.data_acquisition_source_routing') IS NULL THEN
        RAISE EXCEPTION
            'BLOCKER: ops.data_acquisition_source_routing does not exist';
    END IF;

    SELECT COUNT(*)
      INTO v_count
      FROM ops.data_acquisition_source_routing;

    IF v_count <> 0 THEN
        RAISE EXCEPTION
            'BLOCKER: routing must still be empty before G4D-4 APPLY; rows=%',
            v_count;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM (VALUES
            ('ops.source_master'),
            ('ops.source_alias'),
            ('ops.source_sport'),
            ('ops.source_entity_time_coverage'),
            ('ops.source_audit_evidence'),
            ('ops.runtime_adapter'),
            ('ops.source_adapter_binding')
        ) AS t(object_name)
        WHERE to_regclass(t.object_name) IS NOT NULL
    ) THEN
        RAISE EXCEPTION
            'BLOCKER: at least one G4D target table already exists';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema='ops'
          AND table_name='data_acquisition_source_routing'
          AND column_name='source_id'
    ) THEN
        RAISE EXCEPTION
            'BLOCKER: routing.source_id already exists';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM information_schema.columns
        WHERE table_schema='ops'
          AND table_name='data_acquisition_source_routing'
          AND column_name IN ('source_name','source_origin','source_ref_id')
          AND is_nullable='NO'
    ) <> 3 THEN
        RAISE EXCEPTION
            'BLOCKER: legacy routing baseline is not expected 3x NOT NULL';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM public.sports
        WHERE code IN ('AFB','BK','BSB','CK','FB','HB','HK','MMA','TN','VB')
          AND is_active=true
    ) <> 10 THEN
        RAISE EXCEPTION
            'BLOCKER: not all 10 frozen seed sports exist and are active';
    END IF;

    IF (SELECT COUNT(*) FROM ops.source_discovery_audit_tracker) <> 15
       OR (SELECT COUNT(*) FROM ops.source_commercial_model) <> 6
       OR (SELECT COUNT(*) FROM ops.source_legal_audit) <> 1
       OR (SELECT COUNT(*) FROM ops.source_activation_roadmap) <> 4
       OR (SELECT COUNT(*) FROM ops.source_intelligence_map) <> 6
       OR (SELECT COUNT(*) FROM ops.source_quality_score) <> 1
       OR (SELECT COUNT(*) FROM ops.source_coverage_matrix) <> 7
       OR (SELECT COUNT(*) FROM ops.source_review_results) <> 13
       OR (SELECT COUNT(*) FROM ops.source_verification_log) <> 8
    THEN
        RAISE EXCEPTION
            'BLOCKER: evidence baseline changed since G4D-3';
    END IF;
END
$$;


/* ============================================================================
1. LEGACY BASELINE PRO KONTROLU, ŽE APPLY NIC NEMAŽE
============================================================================ */

CREATE TEMP TABLE g4d4_legacy_baseline
(
    object_name text PRIMARY KEY,
    row_count bigint NOT NULL
)
ON COMMIT DROP;

INSERT INTO g4d4_legacy_baseline(object_name,row_count)
VALUES
('ops.global_source_registry',(SELECT COUNT(*) FROM ops.global_source_registry)),
('ops.source_discovery_master',(SELECT COUNT(*) FROM ops.source_discovery_master)),
('ops.source_discovery_audit_tracker',(SELECT COUNT(*) FROM ops.source_discovery_audit_tracker)),
('ops.source_commercial_model',(SELECT COUNT(*) FROM ops.source_commercial_model)),
('ops.source_legal_audit',(SELECT COUNT(*) FROM ops.source_legal_audit)),
('ops.source_activation_roadmap',(SELECT COUNT(*) FROM ops.source_activation_roadmap)),
('ops.source_intelligence_map',(SELECT COUNT(*) FROM ops.source_intelligence_map)),
('ops.source_quality_score',(SELECT COUNT(*) FROM ops.source_quality_score)),
('ops.source_coverage_matrix',(SELECT COUNT(*) FROM ops.source_coverage_matrix)),
('ops.source_review_results',(SELECT COUNT(*) FROM ops.source_review_results)),
('ops.source_verification_log',(SELECT COUNT(*) FROM ops.source_verification_log)),
('ops.provider_worker_registry',(SELECT COUNT(*) FROM ops.provider_worker_registry)),
('ops.provider_jobs',(SELECT COUNT(*) FROM ops.provider_jobs)),
('ops.provider_accounts',(SELECT COUNT(*) FROM ops.provider_accounts)),
('ops.provider_entity_coverage',(SELECT COUNT(*) FROM ops.provider_entity_coverage)),
('ops.provider_sport_matrix',(SELECT COUNT(*) FROM ops.provider_sport_matrix)),
('ops.data_acquisition_source_routing',(SELECT COUNT(*) FROM ops.data_acquisition_source_routing));


/* ============================================================================
2. SOURCE_MASTER
============================================================================ */

CREATE TABLE ops.source_master
(
    source_id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    source_code text NOT NULL UNIQUE,
    canonical_name text NOT NULL,
    source_type text NOT NULL,
    lifecycle_status text NOT NULL,
    canonical_domain text NULL,
    owner_org text NULL,
    notes text NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT ck_source_master_required_text CHECK (
        btrim(source_code)<>'' AND
        btrim(canonical_name)<>'' AND
        btrim(source_type)<>'' AND
        btrim(lifecycle_status)<>''
    )
);


/* ============================================================================
3. SOURCE_ALIAS
============================================================================ */

CREATE TABLE ops.source_alias
(
    source_alias_id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    source_id bigint NOT NULL
        REFERENCES ops.source_master(source_id),

    alias_type text NOT NULL,
    alias_value text NOT NULL,
    normalized_alias text NOT NULL,

    valid_from date NULL,
    valid_to date NULL,
    evidence_ref text NULL,
    is_preferred boolean NOT NULL DEFAULT false,

    CONSTRAINT uq_source_alias_natural
        UNIQUE(source_id,alias_type,normalized_alias),

    CONSTRAINT ck_source_alias_required_text CHECK (
        btrim(alias_type)<>'' AND
        btrim(alias_value)<>'' AND
        btrim(normalized_alias)<>''
    ),

    CONSTRAINT ck_source_alias_validity CHECK (
        valid_from IS NULL
        OR valid_to IS NULL
        OR valid_to>=valid_from
    )
);

/* Jeden otevřený/aktivní normalizovaný alias smí patřit jen jednomu source_id. */
CREATE UNIQUE INDEX uq_source_alias_active_resolution
ON ops.source_alias(alias_type,normalized_alias)
WHERE valid_to IS NULL;

CREATE INDEX ix_source_alias_source
ON ops.source_alias(source_id);


/* ============================================================================
4. SOURCE_SPORT
============================================================================ */

CREATE TABLE ops.source_sport
(
    source_sport_id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    source_id bigint NOT NULL
        REFERENCES ops.source_master(source_id),
    sport_code text NOT NULL
        REFERENCES public.sports(code),
    relationship_status text NOT NULL,
    sport_specific_url text NULL,
    notes text NULL,

    CONSTRAINT uq_source_sport_natural
        UNIQUE(source_id,sport_code),

    CONSTRAINT ck_source_sport_required_text CHECK (
        btrim(sport_code)<>'' AND
        btrim(relationship_status)<>''
    )
);


/* ============================================================================
5. SOURCE_ENTITY_TIME_COVERAGE
============================================================================ */

CREATE TABLE ops.source_entity_time_coverage
(
    coverage_id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    source_id bigint NOT NULL
        REFERENCES ops.source_master(source_id),
    sport_code text NOT NULL
        REFERENCES public.sports(code),

    layer_type text NOT NULL,
    entity text NOT NULL,
    time_mode text NOT NULL,
    coverage_status text NOT NULL,

    history_from date NULL,
    history_to date NULL,
    quality_level text NULL,
    evidence_status text NULL,
    tested_at timestamptz NULL,
    notes text NULL,

    CONSTRAINT uq_source_entity_time_coverage_natural
        UNIQUE(source_id,sport_code,layer_type,entity,time_mode),

    CONSTRAINT ck_source_entity_time_coverage_required_text CHECK (
        btrim(sport_code)<>'' AND
        btrim(layer_type)<>'' AND
        btrim(entity)<>'' AND
        btrim(time_mode)<>'' AND
        btrim(coverage_status)<>''
    ),

    CONSTRAINT ck_source_entity_time_coverage_time_mode CHECK (
        time_mode=ANY(
            ARRAY[
                'HISTORY_FAN',
                'HISTORY_PREDICTION',
                'CURRENT',
                'FUTURE',
                'LIVE'
            ]::text[]
        )
    ),

    CONSTRAINT ck_source_entity_time_coverage_status CHECK (
        coverage_status=ANY(
            ARRAY[
                'UNKNOWN',
                'PLANNED',
                'TECH_READY',
                'RUNTIME_TESTED',
                'CONFIRMED',
                'BLOCKED'
            ]::text[]
        )
    ),

    CONSTRAINT ck_source_entity_time_coverage_history_range CHECK (
        history_from IS NULL
        OR history_to IS NULL
        OR history_to>=history_from
    )
);

CREATE INDEX ix_source_entity_time_coverage_lookup
ON ops.source_entity_time_coverage
   (sport_code,layer_type,entity,time_mode,coverage_status);


/* ============================================================================
6. SOURCE_AUDIT_EVIDENCE
============================================================================ */

CREATE TABLE ops.source_audit_evidence
(
    audit_evidence_id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    source_id bigint NOT NULL
        REFERENCES ops.source_master(source_id),

    audit_dimension text NOT NULL,
    evidence_key text NOT NULL,
    evidence_version text NOT NULL,
    result_status text NOT NULL,
    evidence_date timestamptz NOT NULL,

    evidence_url text NULL,
    result_detail text NULL,
    valid_until timestamptz NULL,
    reviewer text NULL,
    evidence_hash text NULL,

    CONSTRAINT uq_source_audit_evidence_natural UNIQUE(
        source_id,
        audit_dimension,
        evidence_key,
        evidence_version
    ),

    CONSTRAINT ck_source_audit_evidence_required_text CHECK (
        btrim(audit_dimension)<>'' AND
        btrim(evidence_key)<>'' AND
        btrim(evidence_version)<>'' AND
        btrim(result_status)<>''
    )
);

CREATE INDEX ix_source_audit_evidence_source
ON ops.source_audit_evidence(source_id,audit_dimension);


/* ============================================================================
7. RUNTIME_ADAPTER
============================================================================ */

CREATE TABLE ops.runtime_adapter
(
    adapter_id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    adapter_code text NOT NULL UNIQUE,

    /* Fyzický typ: technický provider/runtime adapter. */
    adapter_type text NOT NULL,

    /*
       REGISTERED      = workbook Runtime registr = ANO
       NOT_REGISTERED  = workbook Runtime registr = NE
    */
    runtime_status text NOT NULL,

    provider_class text NULL,
    base_worker text NULL,
    account_ref text NULL,
    notes text NULL,

    CONSTRAINT ck_runtime_adapter_required_text CHECK (
        btrim(adapter_code)<>'' AND
        btrim(adapter_type)<>'' AND
        btrim(runtime_status)<>''
    )
);


/* ============================================================================
8. SOURCE_ADAPTER_BINDING
============================================================================ */

CREATE TABLE ops.source_adapter_binding
(
    source_adapter_binding_id bigint
        GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    source_id bigint NOT NULL
        REFERENCES ops.source_master(source_id),

    adapter_id bigint NOT NULL
        REFERENCES ops.runtime_adapter(adapter_id),

    sport_code text NULL
        REFERENCES public.sports(code),

    entity text NULL,

    account_id bigint NULL,
    worker_binding_id bigint NULL,

    binding_status text NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    notes text NULL,

    CONSTRAINT ck_source_adapter_binding_required_text CHECK (
        btrim(binding_status)<>'' AND
        (entity IS NULL OR btrim(entity)<>'')
    )
);

CREATE UNIQUE INDEX uq_source_adapter_binding_active
ON ops.source_adapter_binding
   (source_id,adapter_id,sport_code,entity)
NULLS NOT DISTINCT
WHERE is_active=true;

CREATE INDEX ix_source_adapter_binding_adapter
ON ops.source_adapter_binding(adapter_id);


/* ============================================================================
9. SAFE SEED — SOURCE_MASTER = 17
============================================================================ */

INSERT INTO ops.source_master
(
    source_code,
    canonical_name,
    source_type,
    lifecycle_status,
    canonical_domain,
    notes
)
VALUES
('atp_tour','ATP Tour','TOUR_OPERATOR','FROZEN','atptour.com',
 'G4D-2 frozen identity seed; identity only.'),
('ehf','European Handball Federation','CONTINENTAL_FEDERATION','FROZEN','eurohandball.com',
 'G4D-2 frozen identity seed; identity only.'),
('euroleague','EuroLeague','CONTINENTAL_OPERATOR','FROZEN','euroleaguebasketball.net',
 'G4D-2 frozen identity seed; identity only.'),
('fiba','FIBA','GLOBAL_FEDERATION','FROZEN','fiba.basketball',
 'G4D-2 frozen identity seed; identity only.'),
('fifa','FIFA','GLOBAL_FEDERATION','FROZEN','fifa.com',
 'G4D-2 frozen identity seed; identity only.'),
('fivb','FIVB','GLOBAL_FEDERATION','FROZEN','fivb.com',
 'G4D-2 frozen identity seed; identity only.'),
('icc','ICC','GLOBAL_FEDERATION','FROZEN','icc-cricket.com',
 'G4D-2 frozen identity seed; identity only.'),
('ihf','International Handball Federation','GLOBAL_FEDERATION','FROZEN','ihf.info',
 'G4D-2 frozen identity seed; identity only.'),
('iihf','International Ice Hockey Federation','GLOBAL_FEDERATION','FROZEN','iihf.com',
 'G4D-2 frozen identity seed; identity only.'),
('nfl','NFL','GLOBAL_OPERATOR','FROZEN','nfl.com',
 'G4D-2 frozen identity seed; identity only.'),
('transfermarkt','Transfermarkt','KNOWLEDGE_BASE','FROZEN','transfermarkt.com',
 'G4D-2 frozen identity seed; identity only.'),
('uefa','UEFA','CONTINENTAL_FEDERATION','FROZEN','uefa.com',
 'G4D-2 frozen identity seed; identity only.'),
('ufc','UFC','GLOBAL_OPERATOR','FROZEN','ufc.com',
 'G4D-2 frozen identity seed; identity only.'),
('wbsc','WBSC','GLOBAL_FEDERATION','FROZEN','wbsc.org',
 'G4D-2 frozen identity seed; identity only.'),
('wikidata','Wikidata','KNOWLEDGE_BASE','FROZEN','wikidata.org',
 'G4D-2 frozen identity seed; identity only.'),
('wikimedia_commons','Wikimedia Commons','PHOTO_ARCHIVE','FROZEN','commons.wikimedia.org',
 'G4D-2 frozen identity seed; identity only.'),
('wta','WTA','TOUR_OPERATOR','FROZEN','wtatennis.com',
 'G4D-2 frozen identity seed; identity only.');


/* ============================================================================
10. SAFE SEED — SOURCE_ALIAS = 35
============================================================================ */

INSERT INTO ops.source_alias
(
    source_id,
    alias_type,
    alias_value,
    normalized_alias,
    evidence_ref,
    is_preferred
)
SELECT
    sm.source_id,
    v.alias_type,
    v.alias_value,
    v.normalized_alias,
    v.evidence_ref,
    (
        v.alias_type='SOURCE_NAME'
        AND v.alias_value=sm.canonical_name
    )
FROM (
    VALUES
    ('atp_tour','DOMAIN','atptour.com','atptour.com',
        'Normalizovaný existující source/base URL'),
    ('atp_tour','SOURCE_NAME','ATP Tour','atp tour',
        'Kanonický název zdroje'),

    ('ehf','DOMAIN','eurohandball.com','eurohandball.com',
        'Normalizovaný existující source/base URL'),
    ('ehf','SOURCE_NAME','European Handball Federation','european handball federation',
        'Kanonický název zdroje'),

    ('euroleague','DOMAIN','euroleaguebasketball.net','euroleaguebasketball.net',
        'Normalizovaný existující source/base URL'),
    ('euroleague','SOURCE_NAME','EuroLeague','euroleague',
        'Kanonický název zdroje'),

    ('fiba','DOMAIN','fiba.basketball','fiba.basketball',
        'Normalizovaný existující source/base URL'),
    ('fiba','SOURCE_NAME','FIBA','fiba',
        'Kanonický název zdroje'),

    ('fifa','DOMAIN','fifa.com','fifa.com',
        'Normalizovaný existující source/base URL'),
    ('fifa','SOURCE_NAME','FIFA','fifa',
        'Kanonický název zdroje'),

    ('fivb','DOMAIN','fivb.com','fivb.com',
        'Normalizovaný existující source/base URL'),
    ('fivb','SOURCE_NAME','FIVB','fivb',
        'Kanonický název zdroje'),

    ('icc','DOMAIN','icc-cricket.com','icc-cricket.com',
        'Normalizovaný existující source/base URL'),
    ('icc','SOURCE_NAME','ICC','icc',
        'Kanonický název zdroje'),

    ('ihf','DOMAIN','ihf.info','ihf.info',
        'Normalizovaný existující source/base URL'),
    ('ihf','SOURCE_NAME','International Handball Federation','international handball federation',
        'Kanonický název zdroje'),

    ('iihf','DOMAIN','iihf.com','iihf.com',
        'Normalizovaný existující source/base URL'),
    ('iihf','SOURCE_NAME','IIHF','iihf',
        'Stávající DB source_name variant'),
    ('iihf','SOURCE_NAME','International Ice Hockey Federation','international ice hockey federation',
        'Kanonický název zdroje'),

    ('nfl','DOMAIN','nfl.com','nfl.com',
        'Normalizovaný existující source/base URL'),
    ('nfl','SOURCE_NAME','NFL','nfl',
        'Kanonický název zdroje'),

    ('transfermarkt','DOMAIN','transfermarkt.com','transfermarkt.com',
        'Normalizovaný existující source/base URL'),
    ('transfermarkt','SOURCE_NAME','Transfermarkt','transfermarkt',
        'Kanonický název zdroje'),

    ('uefa','DOMAIN','uefa.com','uefa.com',
        'Normalizovaný existující source/base URL'),
    ('uefa','SOURCE_NAME','UEFA','uefa',
        'Kanonický název zdroje'),

    ('ufc','DOMAIN','ufc.com','ufc.com',
        'Normalizovaný existující source/base URL'),
    ('ufc','SOURCE_NAME','UFC','ufc',
        'Kanonický název zdroje'),

    ('wbsc','DOMAIN','wbsc.org','wbsc.org',
        'Normalizovaný existující source/base URL'),
    ('wbsc','SOURCE_NAME','WBSC','wbsc',
        'Kanonický název zdroje'),

    ('wikidata','DOMAIN','wikidata.org','wikidata.org',
        'Normalizovaný existující source/base URL'),
    ('wikidata','SOURCE_NAME','Wikidata','wikidata',
        'Kanonický název zdroje'),

    ('wikimedia_commons','DOMAIN','commons.wikimedia.org','commons.wikimedia.org',
        'Normalizovaný existující source/base URL'),
    ('wikimedia_commons','SOURCE_NAME','Wikimedia Commons','wikimedia commons',
        'Kanonický název zdroje'),

    ('wta','DOMAIN','wtatennis.com','wtatennis.com',
        'Normalizovaný existující source/base URL'),
    ('wta','SOURCE_NAME','WTA','wta',
        'Kanonický název zdroje')
) AS v(
    source_code,
    alias_type,
    alias_value,
    normalized_alias,
    evidence_ref
)
JOIN ops.source_master sm
  ON sm.source_code=v.source_code;


/* ============================================================================
11. SAFE SEED — SOURCE_SPORT = 17
============================================================================ */

INSERT INTO ops.source_sport
(
    source_id,
    sport_code,
    relationship_status
)
SELECT
    sm.source_id,
    v.sport_code,
    'OBSERVED_IN_CURRENT_DATA'
FROM (
    VALUES
    ('nfl','AFB'),
    ('euroleague','BK'),
    ('fiba','BK'),
    ('wbsc','BSB'),
    ('icc','CK'),
    ('fifa','FB'),
    ('transfermarkt','FB'),
    ('uefa','FB'),
    ('ehf','HB'),
    ('ihf','HB'),
    ('wikidata','HB'),
    ('wikimedia_commons','HB'),
    ('iihf','HK'),
    ('ufc','MMA'),
    ('atp_tour','TN'),
    ('wta','TN'),
    ('fivb','VB')
) AS v(source_code,sport_code)
JOIN ops.source_master sm
  ON sm.source_code=v.source_code;


/* ============================================================================
12. SAFE SEED — RUNTIME_ADAPTER = 27

Fyzické mapování:
    Runtime registr = ANO -> REGISTERED
    Runtime registr = NE  -> NOT_REGISTERED

adapter_type:
    PROVIDER
    = technický provider/runtime adapter; není to externí source identity.
============================================================================ */

INSERT INTO ops.runtime_adapter
(
    adapter_code,
    adapter_type,
    runtime_status,
    provider_class,
    notes
)
SELECT
    v.adapter_code,
    'PROVIDER',
    v.runtime_status,
    v.provider_class,
    'G4D-2 runtime inventory; db_sports=' || v.db_sports ||
    '; runtime_sports=' || COALESCE(v.runtime_sports,'<NULL>') ||
    '; source_binding=' || v.binding_state
FROM (
    VALUES
    ('api_american_football','REGISTERED','GenericApiSportProvider','AFB','AFB','UNRESOLVED'),
    ('api_baseball','REGISTERED','GenericApiSportProvider','BSB','BSB','UNRESOLVED'),
    ('api_basketball','NOT_REGISTERED',NULL,'BK',NULL,'UNRESOLVED'),
    ('api_cricket','REGISTERED','GenericApiSportProvider','CK','CK','UNRESOLVED'),
    ('api_darts','REGISTERED','GenericApiSportProvider','DRT','DRT','UNRESOLVED'),
    ('api_esports','REGISTERED','GenericApiSportProvider','ESP','ESP','UNRESOLVED'),
    ('api_field_hockey','REGISTERED','GenericApiSportProvider','FH','FH','UNRESOLVED'),
    ('api_football','REGISTERED','ApiFootballProvider','FB','FB','UNRESOLVED'),
    ('api_handball','REGISTERED','GenericApiSportProvider','HB','HB','UNRESOLVED'),
    ('api_hockey','REGISTERED','ApiHockeyProvider','HK','HK','UNRESOLVED'),
    ('api_mma','NOT_REGISTERED',NULL,'MMA',NULL,'UNRESOLVED'),
    ('api_rugby','REGISTERED','GenericApiSportProvider','RGB','RGB','UNRESOLVED'),
    ('api_sport','REGISTERED','GenericApiSportProvider',
        'BK | basketball | football | hockey | mma | tennis','BK','UNRESOLVED'),
    ('api_tennis','REGISTERED','GenericApiSportProvider','TN','TN','UNRESOLVED'),
    ('api_volleyball','REGISTERED','GenericApiSportProvider','VB','VB','UNRESOLVED'),
    ('betfair','NOT_REGISTERED',NULL,'FB',NULL,'UNRESOLVED'),
    ('football_data','NOT_REGISTERED',NULL,'FB',NULL,'UNRESOLVED'),
    ('official_site','NOT_REGISTERED',NULL,'FB',NULL,'MULTI_SOURCE_UNRESOLVED'),
    ('pinnacle','NOT_REGISTERED',NULL,'FB',NULL,'UNRESOLVED'),
    ('rapid_field_hockey','NOT_REGISTERED',NULL,'FH',NULL,'UNRESOLVED'),
    ('rapidapi_tennis','NOT_REGISTERED',NULL,'TN',NULL,'UNRESOLVED'),
    ('sportdataapi','NOT_REGISTERED',NULL,'FB',NULL,'UNRESOLVED'),
    ('sportmonks','NOT_REGISTERED',NULL,'CK',NULL,'UNRESOLVED'),
    ('sportradar','NOT_REGISTERED',NULL,'FB',NULL,'UNRESOLVED'),
    ('sportsdataio','NOT_REGISTERED',NULL,'BK | BSB | HK | MMA',NULL,'UNRESOLVED'),
    ('theodds','NOT_REGISTERED',NULL,'FB',NULL,'UNRESOLVED'),
    ('wikimedia','NOT_REGISTERED',NULL,'FB',NULL,'UNRESOLVED')
) AS v(
    adapter_code,
    runtime_status,
    provider_class,
    db_sports,
    runtime_sports,
    binding_state
);


/* ============================================================================
13. 61 LEGACY EVIDENCE -> 57 SOURCE_AUDIT_EVIDENCE + 4 HOLD
============================================================================ */

CREATE TEMP TABLE g4d4_legacy_evidence
(
    legacy_table text NOT NULL,
    legacy_row_id bigint NOT NULL,
    source_name text NOT NULL,
    audit_dimension text NOT NULL,
    result_status text NULL,
    evidence_date timestamptz NULL,
    evidence_url text NULL,
    result_detail text NULL,
    valid_until timestamptz NULL,
    reviewer text NULL,
    PRIMARY KEY(legacy_table,legacy_row_id)
)
ON COMMIT DROP;

INSERT INTO g4d4_legacy_evidence
SELECT
    'source_discovery_audit_tracker',
    t.audit_tracker_id,
    t.source_name,
    'SOURCE_DISCOVERY_AUDIT',
    COALESCE(t.audit_result,t.audit_status),
    COALESCE(t.completed_at,t.updated_at,t.created_at),
    t.source_url,
    to_jsonb(t)::text,
    NULL::timestamptz,
    NULL::text
FROM ops.source_discovery_audit_tracker t;

INSERT INTO g4d4_legacy_evidence
SELECT
    'source_commercial_model',
    t.commercial_id,
    t.source_name,
    'COMMERCIAL_MODEL',
    t.current_status,
    COALESCE(t.updated_at,t.created_at),
    NULL::text,
    to_jsonb(t)::text,
    NULL::timestamptz,
    NULL::text
FROM ops.source_commercial_model t;

INSERT INTO g4d4_legacy_evidence
SELECT
    'source_legal_audit',
    t.legal_audit_id,
    t.source_name,
    'LEGAL_AUDIT',
    t.scraping_status,
    COALESCE(t.updated_at,t.created_at),
    COALESCE(
        t.terms_url,
        t.robots_url,
        t.source_url,
        t.sitemap_url,
        t.privacy_url
    ),
    to_jsonb(t)::text,
    NULL::timestamptz,
    NULL::text
FROM ops.source_legal_audit t;

INSERT INTO g4d4_legacy_evidence
SELECT
    'source_activation_roadmap',
    t.activation_id,
    t.source_name,
    'ACTIVATION_ROADMAP',
    t.activation_status,
    COALESCE(t.updated_at,t.created_at),
    NULL::text,
    to_jsonb(t)::text,
    NULL::timestamptz,
    NULL::text
FROM ops.source_activation_roadmap t;

INSERT INTO g4d4_legacy_evidence
SELECT
    'source_intelligence_map',
    t.source_map_id,
    t.source_name,
    'SOURCE_INTELLIGENCE',
    t.current_status,
    COALESCE(t.updated_at,t.created_at),
    t.base_url,
    to_jsonb(t)::text,
    NULL::timestamptz,
    NULL::text
FROM ops.source_intelligence_map t;

INSERT INTO g4d4_legacy_evidence
SELECT
    'source_quality_score',
    t.quality_id,
    t.source_name,
    'QUALITY_SCORE',
    t.recommendation,
    COALESCE(t.updated_at,t.created_at),
    NULL::text,
    to_jsonb(t)::text,
    NULL::timestamptz,
    NULL::text
FROM ops.source_quality_score t;

INSERT INTO g4d4_legacy_evidence
SELECT
    'source_coverage_matrix',
    t.coverage_id,
    t.source_name,
    'COVERAGE_MATRIX',
    t.coverage_status,
    COALESCE(t.updated_at,t.created_at),
    NULL::text,
    to_jsonb(t)::text,
    NULL::timestamptz,
    NULL::text
FROM ops.source_coverage_matrix t;

INSERT INTO g4d4_legacy_evidence
SELECT
    'source_review_results',
    t.review_result_id,
    t.source_name,
    'REVIEW:' || t.review_area,
    t.review_result,
    COALESCE(t.review_date::timestamptz,t.created_at),
    t.evidence_url,
    to_jsonb(t)::text,
    NULL::timestamptz,
    t.reviewer
FROM ops.source_review_results t;

INSERT INTO g4d4_legacy_evidence
SELECT
    'source_verification_log',
    t.verification_id,
    t.source_name,
    'VERIFICATION:' || t.verification_area,
    t.verification_result,
    COALESCE(t.verification_date,t.created_at),
    t.evidence_url,
    to_jsonb(t)::text,
    t.valid_until,
    t.verified_by
FROM ops.source_verification_log t;


CREATE TEMP TABLE g4d4_evidence_resolution
ON COMMIT DROP
AS
SELECT
    e.*,
    sa.source_id
FROM g4d4_legacy_evidence e
LEFT JOIN ops.source_alias sa
  ON sa.alias_type='SOURCE_NAME'
 AND sa.valid_to IS NULL
 AND sa.normalized_alias =
     lower(regexp_replace(btrim(e.source_name),'\s+',' ','g'));


DO $$
DECLARE
    v_all bigint;
    v_resolved bigint;
    v_hold bigint;
    v_bad_required bigint;
    v_bad_hold bigint;
BEGIN
    SELECT COUNT(*) INTO v_all
    FROM g4d4_evidence_resolution;

    SELECT COUNT(*) INTO v_resolved
    FROM g4d4_evidence_resolution
    WHERE source_id IS NOT NULL;

    SELECT COUNT(*) INTO v_hold
    FROM g4d4_evidence_resolution
    WHERE source_id IS NULL;

    SELECT COUNT(*) INTO v_bad_required
    FROM g4d4_evidence_resolution
    WHERE source_id IS NOT NULL
      AND (result_status IS NULL OR evidence_date IS NULL);

    SELECT COUNT(*) INTO v_bad_hold
    FROM g4d4_evidence_resolution
    WHERE source_id IS NULL
      AND source_name NOT IN (
          'Official Club Websites',
          'Official League Websites'
      );

    IF v_all<>61 OR v_resolved<>57 OR v_hold<>4 THEN
        RAISE EXCEPTION
            'BLOCKER: evidence resolution expected 61/57/4, got %/%/%',
            v_all,v_resolved,v_hold;
    END IF;

    IF v_bad_required<>0 THEN
        RAISE EXCEPTION
            'BLOCKER: resolved evidence contains NULL result_status/evidence_date; rows=%',
            v_bad_required;
    END IF;

    IF v_bad_hold<>0 THEN
        RAISE EXCEPTION
            'BLOCKER: unresolved evidence contains non-pseudo source rows=%',
            v_bad_hold;
    END IF;
END
$$;


INSERT INTO ops.source_audit_evidence
(
    source_id,
    audit_dimension,
    evidence_key,
    evidence_version,
    result_status,
    evidence_date,
    evidence_url,
    result_detail,
    valid_until,
    reviewer
)
SELECT
    source_id,
    audit_dimension,
    'legacy:' || legacy_table || ':' || legacy_row_id::text,
    'LEGACY_ROW_V1',
    result_status,
    evidence_date,
    evidence_url,
    result_detail,
    valid_until,
    reviewer
FROM g4d4_evidence_resolution
WHERE source_id IS NOT NULL;


/* ============================================================================
14. EXISTUJÍCÍ ROUTING -> CANONICAL SOURCE_ID
============================================================================ */

ALTER TABLE ops.data_acquisition_source_routing
    ADD COLUMN source_id bigint;

ALTER TABLE ops.data_acquisition_source_routing
    ALTER COLUMN source_id SET NOT NULL;

ALTER TABLE ops.data_acquisition_source_routing
    ALTER COLUMN source_name DROP NOT NULL;

ALTER TABLE ops.data_acquisition_source_routing
    ALTER COLUMN source_origin DROP NOT NULL;

ALTER TABLE ops.data_acquisition_source_routing
    ALTER COLUMN source_ref_id DROP NOT NULL;

ALTER TABLE ops.data_acquisition_source_routing
    ADD CONSTRAINT fk_data_acq_source_routing_source
    FOREIGN KEY(source_id)
    REFERENCES ops.source_master(source_id);

ALTER TABLE ops.data_acquisition_source_routing
    ADD CONSTRAINT fk_data_acq_source_routing_sport
    FOREIGN KEY(sport_code)
    REFERENCES public.sports(code);


/* Required canonical routing scope.
   Legacy source_name/source_origin už nejsou povinnou identitou. */
ALTER TABLE ops.data_acquisition_source_routing
    DROP CONSTRAINT ck_data_acq_source_routing_required_text;

ALTER TABLE ops.data_acquisition_source_routing
    ADD CONSTRAINT ck_data_acq_source_routing_required_text
    CHECK (
        btrim(sport_code)<>'' AND
        btrim(layer_type)<>'' AND
        btrim(entity)<>'' AND
        btrim(time_mode)<>'' AND
        btrim(source_role)<>''
    );


/* Canonical role vocabulary. REFERENCE se automaticky nemapuje. */
ALTER TABLE ops.data_acquisition_source_routing
    DROP CONSTRAINT ck_data_acq_source_routing_source_role;

ALTER TABLE ops.data_acquisition_source_routing
    ADD CONSTRAINT ck_data_acq_source_routing_source_role
    CHECK (
        source_role=ANY(
            ARRAY[
                'PRIMARY',
                'FALLBACK',
                'MERGE',
                'VALIDATION',
                'NOT_USED'
            ]::text[]
        )
    );


/* Canonical aktivní route unikátní přes source_id. */
DROP INDEX ops.uq_data_acq_source_routing_active_source;

CREATE UNIQUE INDEX uq_data_acq_source_routing_active_source
ON ops.data_acquisition_source_routing
   (
       sport_code,
       layer_type,
       entity,
       time_mode,
       source_role,
       source_id
   )
WHERE is_active=true;


/* Max. jeden aktivní PRIMARY na přesný scope, bez podmínky APPROVED. */
DROP INDEX ops.uq_data_acq_source_routing_one_approved_primary;

CREATE UNIQUE INDEX uq_data_acq_source_routing_one_active_primary
ON ops.data_acquisition_source_routing
   (sport_code,layer_type,entity,time_mode)
WHERE is_active=true
  AND source_role='PRIMARY';


/* ============================================================================
15. APPLY VALIDATION
============================================================================ */

CREATE TEMP TABLE g4d4_validation
(
    sort_order integer PRIMARY KEY,
    check_id text NOT NULL,
    status text NOT NULL,
    detail text NOT NULL
)
ON COMMIT DROP;


/* P01 */
INSERT INTO g4d4_validation
SELECT
    10,
    'P01_SAFE_SEED_COUNTS',
    CASE WHEN
        (SELECT COUNT(*) FROM ops.source_master)=17
        AND (SELECT COUNT(*) FROM ops.source_alias)=35
        AND (SELECT COUNT(*) FROM ops.source_sport)=17
        AND (SELECT COUNT(*) FROM ops.source_audit_evidence)=57
        AND (SELECT COUNT(*) FROM ops.runtime_adapter)=27
        AND (SELECT COUNT(*) FROM ops.source_entity_time_coverage)=0
        AND (SELECT COUNT(*) FROM ops.source_adapter_binding)=0
        AND (SELECT COUNT(*) FROM ops.data_acquisition_source_routing)=0
    THEN 'PASS' ELSE 'BLOCKER' END,
    format(
        'master=%s; alias=%s; sport=%s; evidence=%s; adapter=%s; coverage=%s; binding=%s; routing=%s',
        (SELECT COUNT(*) FROM ops.source_master),
        (SELECT COUNT(*) FROM ops.source_alias),
        (SELECT COUNT(*) FROM ops.source_sport),
        (SELECT COUNT(*) FROM ops.source_audit_evidence),
        (SELECT COUNT(*) FROM ops.runtime_adapter),
        (SELECT COUNT(*) FROM ops.source_entity_time_coverage),
        (SELECT COUNT(*) FROM ops.source_adapter_binding),
        (SELECT COUNT(*) FROM ops.data_acquisition_source_routing)
    );


/* P02 */
INSERT INTO g4d4_validation
SELECT
    20,
    'P02_ROUTING_PHYSICAL_CONTRACT',
    CASE WHEN
        EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema='ops'
              AND table_name='data_acquisition_source_routing'
              AND column_name='source_id'
              AND data_type='bigint'
              AND is_nullable='NO'
        )
        AND (
            SELECT COUNT(*)
            FROM information_schema.columns
            WHERE table_schema='ops'
              AND table_name='data_acquisition_source_routing'
              AND column_name IN ('source_name','source_origin','source_ref_id')
              AND is_nullable='YES'
        )=3
    THEN 'PASS' ELSE 'BLOCKER' END,
    'source_id BIGINT NOT NULL; legacy source identifiers nullable';


/* P03 */
INSERT INTO g4d4_validation
SELECT
    30,
    'P03_EVIDENCE_RESOLUTION',
    CASE WHEN
        (SELECT COUNT(*) FROM g4d4_evidence_resolution)=61
        AND (
            SELECT COUNT(*)
            FROM g4d4_evidence_resolution
            WHERE source_id IS NOT NULL
        )=57
        AND (
            SELECT COUNT(*)
            FROM g4d4_evidence_resolution
            WHERE source_id IS NULL
        )=4
    THEN 'PASS' ELSE 'BLOCKER' END,
    format(
        'legacy=%s; resolved=%s; pseudo_hold=%s',
        (SELECT COUNT(*) FROM g4d4_evidence_resolution),
        (
            SELECT COUNT(*)
            FROM g4d4_evidence_resolution
            WHERE source_id IS NOT NULL
        ),
        (
            SELECT COUNT(*)
            FROM g4d4_evidence_resolution
            WHERE source_id IS NULL
        )
    );


/* G4C-V01 */
INSERT INTO g4d4_validation
SELECT
    101,
    'G4C-V01_EVIDENCE_EXACT_SOURCE',
    CASE WHEN
        (SELECT COUNT(*) FROM ops.source_audit_evidence)=57
        AND NOT EXISTS (
            SELECT 1
            FROM ops.source_audit_evidence e
            LEFT JOIN ops.source_master s
              ON s.source_id=e.source_id
            WHERE s.source_id IS NULL
        )
    THEN 'PASS' ELSE 'BLOCKER' END,
    '57 evidence rows resolve to exactly one SOURCE_MASTER.source_id';


/* G4C-V02 */
INSERT INTO g4d4_validation
SELECT
    102,
    'G4C-V02_ACTIVE_ALIAS_COLLISION',
    CASE WHEN
        NOT EXISTS (
            SELECT 1
            FROM ops.source_alias
            WHERE valid_to IS NULL
            GROUP BY alias_type,normalized_alias
            HAVING COUNT(DISTINCT source_id)>1
        )
        AND EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname='ops'
              AND tablename='source_alias'
              AND indexname='uq_source_alias_active_resolution'
              AND indexdef LIKE '%UNIQUE%'
              AND indexdef LIKE '%valid_to IS NULL%'
        )
    THEN 'PASS' ELSE 'BLOCKER' END,
    'Open/active alias uniqueness is both clean and physically enforced';


/* G4C-V03 */
INSERT INTO g4d4_validation
SELECT
    103,
    'G4C-V03_SOURCE_MASTER_SCOPE',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema='ops'
          AND table_name='source_master'
          AND column_name IN (
              'sport_code',
              'entity',
              'time_mode',
              'source_role',
              'worker_script'
          )
    ) THEN 'PASS' ELSE 'BLOCKER' END,
    'SOURCE_MASTER contains no sport/entity/time/routing/worker fields';


/* G4C-V04 */
INSERT INTO g4d4_validation
SELECT
    104,
    'G4C-V04_PRIMARY_REQUIRES_CONFIRMED',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM ops.data_acquisition_source_routing r
        WHERE r.is_active=true
          AND r.source_role='PRIMARY'
          AND NOT EXISTS (
              SELECT 1
              FROM ops.source_entity_time_coverage c
              WHERE c.source_id=r.source_id
                AND c.sport_code=r.sport_code
                AND c.layer_type=r.layer_type
                AND c.entity=r.entity
                AND c.time_mode=r.time_mode
                AND c.coverage_status='CONFIRMED'
          )
    ) THEN 'PASS' ELSE 'BLOCKER' END,
    'No active PRIMARY without matching CONFIRMED coverage';


/* G4C-V05 */
INSERT INTO g4d4_validation
SELECT
    105,
    'G4C-V05_BLOCKED_CANNOT_ROUTE',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM ops.data_acquisition_source_routing r
        JOIN ops.source_entity_time_coverage c
          ON c.source_id=r.source_id
         AND c.sport_code=r.sport_code
         AND c.layer_type=r.layer_type
         AND c.entity=r.entity
         AND c.time_mode=r.time_mode
        WHERE r.is_active=true
          AND r.source_role IN ('PRIMARY','FALLBACK','MERGE')
          AND c.coverage_status='BLOCKED'
    ) THEN 'PASS' ELSE 'BLOCKER' END,
    'BLOCKED coverage has no active PRIMARY/FALLBACK/MERGE route';


/* G4C-V06 */
INSERT INTO g4d4_validation
SELECT
    106,
    'G4C-V06_RUNTIME_TESTED_NOT_APPROVAL',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM ops.data_acquisition_source_routing r
        JOIN ops.source_entity_time_coverage c
          ON c.source_id=r.source_id
         AND c.sport_code=r.sport_code
         AND c.layer_type=r.layer_type
         AND c.entity=r.entity
         AND c.time_mode=r.time_mode
        WHERE r.is_active=true
          AND r.decision_status='APPROVED'
          AND c.coverage_status='RUNTIME_TESTED'
          AND NOT EXISTS (
              SELECT 1
              FROM ops.source_entity_time_coverage c2
              WHERE c2.source_id=r.source_id
                AND c2.sport_code=r.sport_code
                AND c2.layer_type=r.layer_type
                AND c2.entity=r.entity
                AND c2.time_mode=r.time_mode
                AND c2.coverage_status='CONFIRMED'
          )
    ) THEN 'PASS' ELSE 'BLOCKER' END,
    'RUNTIME_TESTED alone does not create approved routing';


/* G4C-V07 */
INSERT INTO g4d4_validation
SELECT
    107,
    'G4C-V07_ONE_ACTIVE_PRIMARY',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM ops.data_acquisition_source_routing
        WHERE is_active=true
          AND source_role='PRIMARY'
        GROUP BY sport_code,layer_type,entity,time_mode
        HAVING COUNT(*)>1
    ) THEN 'PASS' ELSE 'BLOCKER' END,
    'At most one active PRIMARY per exact scope';


/* G4C-V08 */
INSERT INTO g4d4_validation
SELECT
    108,
    'G4C-V08_ADAPTER_NOT_COVERAGE',
    CASE WHEN
        (SELECT COUNT(*) FROM ops.runtime_adapter)=27
        AND (SELECT COUNT(*) FROM ops.source_entity_time_coverage)=0
    THEN 'PASS' ELSE 'BLOCKER' END,
    '27 adapter identities exist while coverage remains 0';


/* G4C-V09 */
INSERT INTO g4d4_validation
SELECT
    109,
    'G4C-V09_SPORT_CODE_RUNTIME_KEY_SEPARATION',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema='ops'
          AND table_name='runtime_adapter'
          AND column_name IN (
              'sport_code',
              'sport_key',
              'runtime_sport_key'
          )
    ) THEN 'PASS' ELSE 'BLOCKER' END,
    'Runtime sport identifiers are not conflated into canonical adapter fields';


/* G4C-V10 */
WITH current_counts AS (
    SELECT 'ops.global_source_registry' object_name, COUNT(*)::bigint row_count
    FROM ops.global_source_registry

    UNION ALL SELECT 'ops.source_discovery_master',COUNT(*)
    FROM ops.source_discovery_master

    UNION ALL SELECT 'ops.source_discovery_audit_tracker',COUNT(*)
    FROM ops.source_discovery_audit_tracker

    UNION ALL SELECT 'ops.source_commercial_model',COUNT(*)
    FROM ops.source_commercial_model

    UNION ALL SELECT 'ops.source_legal_audit',COUNT(*)
    FROM ops.source_legal_audit

    UNION ALL SELECT 'ops.source_activation_roadmap',COUNT(*)
    FROM ops.source_activation_roadmap

    UNION ALL SELECT 'ops.source_intelligence_map',COUNT(*)
    FROM ops.source_intelligence_map

    UNION ALL SELECT 'ops.source_quality_score',COUNT(*)
    FROM ops.source_quality_score

    UNION ALL SELECT 'ops.source_coverage_matrix',COUNT(*)
    FROM ops.source_coverage_matrix

    UNION ALL SELECT 'ops.source_review_results',COUNT(*)
    FROM ops.source_review_results

    UNION ALL SELECT 'ops.source_verification_log',COUNT(*)
    FROM ops.source_verification_log

    UNION ALL SELECT 'ops.provider_worker_registry',COUNT(*)
    FROM ops.provider_worker_registry

    UNION ALL SELECT 'ops.provider_jobs',COUNT(*)
    FROM ops.provider_jobs

    UNION ALL SELECT 'ops.provider_accounts',COUNT(*)
    FROM ops.provider_accounts

    UNION ALL SELECT 'ops.provider_entity_coverage',COUNT(*)
    FROM ops.provider_entity_coverage

    UNION ALL SELECT 'ops.provider_sport_matrix',COUNT(*)
    FROM ops.provider_sport_matrix

    UNION ALL SELECT 'ops.data_acquisition_source_routing',COUNT(*)
    FROM ops.data_acquisition_source_routing
),
diff AS (
    SELECT
        b.object_name,
        b.row_count baseline_count,
        c.row_count current_count
    FROM g4d4_legacy_baseline b
    JOIN current_counts c USING(object_name)
    WHERE b.row_count<>c.row_count
)
INSERT INTO g4d4_validation
SELECT
    110,
    'G4C-V10_NO_LEGACY_ROW_DELETE',
    CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'BLOCKER' END,
    'legacy row-count differences=' || COUNT(*)::text
FROM diff;


/* G4C-V11 */
INSERT INTO g4d4_validation
SELECT
    111,
    'G4C-V11_NO_GUESSED_TIME_COVERAGE',
    CASE WHEN
        (SELECT COUNT(*) FROM ops.source_entity_time_coverage)=0
    THEN 'PASS' ELSE 'BLOCKER' END,
    'No generic legacy coverage cloned into time modes; rows=0';


/* G4C-V12 */
INSERT INTO g4d4_validation
SELECT
    112,
    'G4C-V12_SOURCE_ADAPTER_IDENTITY_SEPARATED',
    CASE WHEN
        to_regclass('ops.source_master') IS NOT NULL
        AND to_regclass('ops.runtime_adapter') IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema='ops'
              AND table_name='source_master'
              AND column_name='adapter_id'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema='ops'
              AND table_name='runtime_adapter'
              AND column_name='source_id'
        )
    THEN 'PASS' ELSE 'BLOCKER' END,
    'External source identity and runtime adapter identity remain separate';


/* P04 */
INSERT INTO g4d4_validation
SELECT
    120,
    'P04_ROUTING_ROLE_INDEX_FK',
    CASE WHEN
        EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conrelid=
                'ops.data_acquisition_source_routing'::regclass
              AND conname='fk_data_acq_source_routing_source'
              AND contype='f'
        )
        AND EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conrelid=
                'ops.data_acquisition_source_routing'::regclass
              AND conname='fk_data_acq_source_routing_sport'
              AND contype='f'
        )
        AND EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname='ops'
              AND tablename='data_acquisition_source_routing'
              AND indexname='uq_data_acq_source_routing_active_source'
              AND indexdef LIKE '%source_id%'
        )
        AND EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname='ops'
              AND tablename='data_acquisition_source_routing'
              AND indexname='uq_data_acq_source_routing_one_active_primary'
              AND indexdef NOT LIKE '%decision_status%'
        )
        AND EXISTS (
            SELECT 1
            FROM pg_constraint c
            WHERE c.conrelid=
                'ops.data_acquisition_source_routing'::regclass
              AND c.conname='ck_data_acq_source_routing_source_role'
              AND pg_get_constraintdef(c.oid,true)
                    LIKE '%VALIDATION%'
              AND pg_get_constraintdef(c.oid,true)
                    LIKE '%NOT_USED%'
              AND pg_get_constraintdef(c.oid,true)
                    NOT LIKE '%REFERENCE%'
        )
    THEN 'PASS' ELSE 'BLOCKER' END,
    'canonical routing FK/index/role contract present';


/* P05 */
INSERT INTO g4d4_validation
SELECT
    130,
    'P05_APPROVAL_PROTECTION_PRESERVED',
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_constraint c
        WHERE c.conrelid=
            'ops.data_acquisition_source_routing'::regclass
          AND c.conname='ck_data_acq_source_routing_approval'
          AND pg_get_constraintdef(c.oid,true)
                LIKE '%approved_at IS NOT NULL%'
          AND pg_get_constraintdef(c.oid,true)
                LIKE '%approved_by IS NOT NULL%'
          AND pg_get_constraintdef(c.oid,true)
                LIKE '%decision_note IS NOT NULL%'
    ) THEN 'PASS' ELSE 'BLOCKER' END,
    'APPROVED still requires approved_at, approved_by and decision_note';


/* ============================================================================
16. PŘED COMMIT — BLOKER = OKAMŽITĚ STOP
============================================================================ */

DO $$
DECLARE
    v_blockers bigint;
BEGIN
    SELECT COUNT(*)
      INTO v_blockers
      FROM g4d4_validation
     WHERE status='BLOCKER';

    IF v_blockers <> 0 THEN
        RAISE EXCEPTION
            'G4D-4 APPLY BLOCKED: validation blockers=%; transaction will not be committed',
            v_blockers;
    END IF;
END
$$;


/* Výstup před COMMIT */
SELECT
    check_id,
    status,
    detail
FROM g4d4_validation
ORDER BY sort_order;

SELECT
    COUNT(*) FILTER (WHERE status='PASS') AS pass_count,
    COUNT(*) FILTER (WHERE status='BLOCKER') AS blocker_count,
    CASE
        WHEN COUNT(*) FILTER (WHERE status='BLOCKER')=0
            THEN 'APPLY_READY_TO_COMMIT'
        ELSE 'APPLY_BLOCKED'
    END AS final_status
FROM g4d4_validation;


/* ============================================================================
17. TRVALÝ COMMIT
============================================================================ */

COMMIT;


/* ============================================================================
18. POST-COMMIT VERIFICATION — TRVALÝ STAV
============================================================================ */

SELECT *
FROM (
    SELECT
        10 AS sort_order,
        'TARGET_TABLES_PRESENT'::text AS check_id,
        CASE WHEN (
            SELECT COUNT(*)
            FROM (VALUES
                ('ops.source_master'),
                ('ops.source_alias'),
                ('ops.source_sport'),
                ('ops.source_entity_time_coverage'),
                ('ops.source_audit_evidence'),
                ('ops.runtime_adapter'),
                ('ops.source_adapter_binding')
            ) AS t(object_name)
            WHERE to_regclass(t.object_name) IS NOT NULL
        )=7 THEN 'PASS' ELSE 'BLOCKER' END AS status,
        '7/7 G4D target tables must exist after COMMIT'::text AS detail

    UNION ALL

    SELECT
        20,
        'SAFE_SEED_COUNTS',
        CASE WHEN
            (SELECT COUNT(*) FROM ops.source_master)=17
            AND (SELECT COUNT(*) FROM ops.source_alias)=35
            AND (SELECT COUNT(*) FROM ops.source_sport)=17
            AND (SELECT COUNT(*) FROM ops.source_audit_evidence)=57
            AND (SELECT COUNT(*) FROM ops.runtime_adapter)=27
        THEN 'PASS' ELSE 'BLOCKER' END,
        format(
            'master=%s; alias=%s; sport=%s; evidence=%s; adapter=%s',
            (SELECT COUNT(*) FROM ops.source_master),
            (SELECT COUNT(*) FROM ops.source_alias),
            (SELECT COUNT(*) FROM ops.source_sport),
            (SELECT COUNT(*) FROM ops.source_audit_evidence),
            (SELECT COUNT(*) FROM ops.runtime_adapter)
        )

    UNION ALL

    SELECT
        30,
        'HOLD_TABLES_EMPTY',
        CASE WHEN
            (SELECT COUNT(*) FROM ops.source_entity_time_coverage)=0
            AND (SELECT COUNT(*) FROM ops.source_adapter_binding)=0
            AND (SELECT COUNT(*) FROM ops.data_acquisition_source_routing)=0
        THEN 'PASS' ELSE 'BLOCKER' END,
        format(
            'coverage=%s; binding=%s; routing=%s',
            (SELECT COUNT(*) FROM ops.source_entity_time_coverage),
            (SELECT COUNT(*) FROM ops.source_adapter_binding),
            (SELECT COUNT(*) FROM ops.data_acquisition_source_routing)
        )

    UNION ALL

    SELECT
        40,
        'ROUTING_SOURCE_ID_PRESENT',
        CASE WHEN EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema='ops'
              AND table_name='data_acquisition_source_routing'
              AND column_name='source_id'
              AND data_type='bigint'
              AND is_nullable='NO'
        ) THEN 'PASS' ELSE 'BLOCKER' END,
        'canonical source_id BIGINT NOT NULL is persistent'

    UNION ALL

    SELECT
        50,
        'ROUTING_CANONICAL_INDEXES',
        CASE WHEN
            EXISTS (
                SELECT 1
                FROM pg_indexes
                WHERE schemaname='ops'
                  AND tablename='data_acquisition_source_routing'
                  AND indexname='uq_data_acq_source_routing_active_source'
                  AND indexdef LIKE '%source_id%'
            )
            AND EXISTS (
                SELECT 1
                FROM pg_indexes
                WHERE schemaname='ops'
                  AND tablename='data_acquisition_source_routing'
                  AND indexname='uq_data_acq_source_routing_one_active_primary'
                  AND indexdef NOT LIKE '%decision_status%'
            )
        THEN 'PASS' ELSE 'BLOCKER' END,
        'canonical active-source and one-active-primary indexes persistent'

    UNION ALL

    SELECT
        60,
        'ACTIVE_ALIAS_UNIQUENESS',
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname='ops'
              AND tablename='source_alias'
              AND indexname='uq_source_alias_active_resolution'
              AND indexdef LIKE '%UNIQUE%'
        ) THEN 'PASS' ELSE 'BLOCKER' END,
        'open alias uniqueness index persistent'

    UNION ALL

    SELECT
        70,
        'APPROVAL_PROTECTION_PRESERVED',
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_constraint c
            WHERE c.conrelid=
                'ops.data_acquisition_source_routing'::regclass
              AND c.conname='ck_data_acq_source_routing_approval'
        ) THEN 'PASS' ELSE 'BLOCKER' END,
        'routing approval protection persists'

    UNION ALL

    SELECT
        80,
        'G4D4_APPLY_COMPLETE',
        'PASS',
        'G4D-4 additive physical migration committed'
) q
ORDER BY sort_order;
