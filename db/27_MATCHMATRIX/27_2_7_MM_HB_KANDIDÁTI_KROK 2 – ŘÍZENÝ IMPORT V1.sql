/* ============================================================================
CO: MM HB KANDIDÁTI – KROK 2 – ŘÍZENÝ IMPORT V1
K ČEMU: Vložit 30 nových kandidátů do ops.source_intelligence_map.
KDE: DBeaver, databáze matchmatrix. Spustit celý skript jako SQL skript.
JAK: APPLY v jedné transakci, kontroly před i po zápisu.
     Původních 6 řádků zůstane beze změny.
     Opakování stejné dávky nevloží duplicity.
     Při chybě spusťte ROLLBACK; a pošlete přesnou chybu.
============================================================================ */
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = pg_catalog, pg_temp;

DO $import$
DECLARE
  v_batch constant text := 'HB_CANDIDATES_20260928_V1';
  v_input jsonb;
  v_before jsonb;
  v_after jsonb;
  v_existing bigint[] := ARRAY[]::bigint[];
  v_match_ids bigint[];
  v_seq regclass;
  v_total bigint;
  v_inserted integer := 0;
  v_expected integer;
  v_i jsonb;
  v_row ops.source_intelligence_map%ROWTYPE;
BEGIN
  IF current_database() <> 'matchmatrix' THEN
    RAISE EXCEPTION 'BLOCKER: nesprávná databáze: %', current_database();
  END IF;

  IF current_setting('transaction_read_only') <> 'off' THEN
    RAISE EXCEPTION 'BLOCKER: připojení je READ ONLY';
  END IF;

  IF NOT has_table_privilege(
    current_user, 'ops.source_intelligence_map', 'INSERT'
  ) THEN
    RAISE EXCEPTION 'BLOCKER: chybí právo INSERT';
  END IF;

  LOCK TABLE ops.source_intelligence_map
    IN SHARE ROW EXCLUSIVE MODE;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_class
    WHERE oid = 'ops.source_intelligence_map'::regclass
      AND relkind = 'r'
      AND NOT relrowsecurity
      AND NOT relforcerowsecurity
  )
  OR EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgrelid = 'ops.source_intelligence_map'::regclass
      AND NOT tgisinternal
  )
  OR EXISTS (
    SELECT 1
    FROM pg_rewrite
    WHERE ev_class = 'ops.source_intelligence_map'::regclass
      AND rulename <> '_RETURN'
  ) THEN
    RAISE EXCEPTION
      'BLOCKER: změněný typ tabulky, RLS, trigger nebo pravidlo';
  END IF;

  v_seq := pg_get_serial_sequence(
    'ops.source_intelligence_map', 'source_map_id'
  )::regclass;

  IF v_seq IS NULL THEN
    RAISE EXCEPTION 'BLOCKER: chybí vlastněná sekvence ID';
  END IF;

  IF NOT (
    has_sequence_privilege(current_user, v_seq, 'USAGE')
    OR has_sequence_privilege(current_user, v_seq, 'UPDATE')
  ) THEN
    RAISE EXCEPTION 'BLOCKER: chybí právo používat sekvenci ID';
  END IF;

  WITH data(
    priority_order, candidate_ref, source_name, source_type,
    base_url, who_text, scope_text, evidence_url, price_text, remarks
  ) AS (
    VALUES
    (10, 'HB-CAND-001', 'API-Sports', 'DATA_PROVIDER', 'https://api-sports.io', 'Poskytovatel sportovních API', 'HB API; prověřit soutěže, týmy, zápasy, tabulky a kurzy', 'https://api-sports.io/sports/handball', 'Free 100 požadavků/den; placený PRO zobrazuje 15,00 za měsíční volbu. Měna a daně v načteném textu nedoloženy – cenu nepřenášet jako potvrzenou.', 'api_handball je existující adapter; toto není vytvoření canonical identity ani bindingu. STEP 4A z NAV-03 zůstává samostatným otevřeným bodem.'),
    (20, 'HB-CAND-002', 'Sportradar', 'DATA_PROVIDER', 'https://sportradar.com', 'Poskytovatel sportovních dat', 'HB API: výsledky, statistiky, profily, historie, LIVE; skutečný rozsah závisí na pokrytí', 'https://developer.sportradar.com/handball/reference/handball-overview', NULL, 'Dokumentace uvádí nejvýše tři sezóny ve výstupech Competition Seasons/Seasons; dostupnost hlubší historie je otevřená otázka, nikoliv potvrzené plné historické pokrytí.'),
    (30, 'HB-CAND-003', 'STATSCORE', 'DATA_PROVIDER', 'https://www.statscore.com', 'Poskytovatel sportovních dat', 'HB SportsAPI: zápasy, týmy a statistiky dle úrovně balíčku', 'https://www.statscore.com/coverage/sportsapi/handball/', 'Cena podle soutěží a úrovně; číselná nabídka nezjištěna.', NULL),
    (40, 'HB-CAND-004', 'Data Sports Group', 'DATA_PROVIDER', 'https://datasportsgroup.com', 'Poskytovatel sportovních dat', 'Produktová stránka HB API a živých výsledků; přesné entity prověřit', 'https://datasportsgroup.com/coverage/handball/', NULL, NULL),
    (50, 'HB-CAND-005', 'Goalserve', 'DATA_PROVIDER', 'https://www.goalserve.com', 'Poskytovatel datových feedů', 'HB zápasy, výsledky, tabulky a kurzy; XML/JSON', 'https://www.goalserve.com/en/sport-data-feeds/handball-api/prices', 'Veřejný ceník: 100 USD / 1 měsíc; 500 USD / 6 měsíců; 900 USD / 12 měsíců. Rozsah, daně a aktuální nabídku potvrdit.', NULL),
    (60, 'HB-CAND-006', 'BetsAPI', 'DATA_PROVIDER', 'https://betsapi.com', 'Poskytovatel výsledků a sázkových dat', 'Dokumentace obsahuje sport_id 78 = házená; entity a dostupné kurzy otestovat', 'https://betsapi.com/docs/GLOSSARY.html', NULL, NULL),
    (90, 'HB-CAND-009', 'Český svaz házené', 'FEDERATION', 'https://www.handball.cz', 'Národní svaz – Česko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (100, 'HB-CAND-010', 'Deutscher Handballbund', 'FEDERATION', 'https://www.dhb.de', 'Národní svaz – Německo', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (110, 'HB-CAND-011', 'DanskHåndbold', 'FEDERATION', 'https://danskhaandbold.dk', 'Národní svaz – Dánsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (120, 'HB-CAND-012', 'Norges Håndballforbund', 'FEDERATION', 'https://www.handball.no', 'Národní svaz – Norsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (130, 'HB-CAND-013', 'Svenska Handbollförbundet', 'FEDERATION', 'https://svenskhandboll.se', 'Národní svaz – Švédsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', 'https://svenskhandboll.se/nyheter', NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. Načtení hlavní stránky selhalo, dohledána stránka zpráv.'),
    (140, 'HB-CAND-014', 'Fédération Française de Handball', 'FEDERATION', 'https://www.ffhandball.fr', 'Národní svaz – Francie', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. Načtený obsah je velmi omezený; datové sekce ověřit.'),
    (150, 'HB-CAND-015', 'Real Federación Española de Balonmano', 'FEDERATION', 'https://www.rfebm.com', 'Národní svaz – Španělsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (160, 'HB-CAND-016', 'Związek Piłki Ręcznej w Polsce', 'FEDERATION', 'https://zprp.pl', 'Národní svaz – Polsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (170, 'HB-CAND-017', 'Magyar Kézilabda Szövetség', 'FEDERATION', 'https://www.mksz.hu', 'Národní svaz – Maďarsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. Načtený obsah je velmi omezený; datové sekce ověřit.'),
    (180, 'HB-CAND-018', 'Federația Română de Handbal', 'FEDERATION', 'https://frh.ro', 'Národní svaz – Rumunsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (190, 'HB-CAND-019', 'Hrvatski rukometni savez', 'FEDERATION', 'https://hrs.hr', 'Národní svaz – Chorvatsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (200, 'HB-CAND-020', 'Rokometna zveza Slovenije', 'FEDERATION', 'https://www.rokometna-zveza.si', 'Národní svaz – Slovinsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (210, 'HB-CAND-021', 'Schweizerischer Handball-Verband', 'FEDERATION', 'https://www.handball.ch', 'Národní svaz – Švýcarsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (220, 'HB-CAND-022', 'Österreichischer Handballbund', 'FEDERATION', 'https://www.oehb.at', 'Národní svaz – Rakousko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (230, 'HB-CAND-023', 'Slovenský zväz hádzanej', 'FEDERATION', 'https://www.slovakhandball.sk', 'Národní svaz – Slovensko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (240, 'HB-CAND-024', 'Federação de Andebol de Portugal', 'FEDERATION', 'https://portal.fpa.pt', 'Národní svaz – Portugalsko', 'K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv.', NULL, NULL, 'Nalezen web svazu; dostupnost konkrétních dat není potvrzena. '),
    (250, 'HB-CAND-025', 'Handball-Bundesliga', 'OFFICIAL_LEAGUE', 'https://www.opel-hbl.de', 'Ligový web / organizátor – Německo', 'K auditu: ligové zápasy, týmy, hráči, statistiky a historické sekce.', NULL, NULL, 'Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.'),
    (260, 'HB-CAND-026', 'Ligue Nationale de Handball', 'OFFICIAL_LEAGUE', 'https://www.lnh.fr', 'Ligový web / organizátor – Francie', 'Web uvádí kalendář, výsledky, týmy, hráče, statistiky a historii sezón.', NULL, NULL, 'Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.'),
    (270, 'HB-CAND-027', 'ASOBAL', 'OFFICIAL_LEAGUE', 'https://asobal.es', 'Ligový web / organizátor – Španělsko', 'Web uvádí kalendář, výsledky, týmy, statistiky a historické úspěchy.', NULL, NULL, 'Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.'),
    (280, 'HB-CAND-028', 'Superliga (Polsko)', 'OFFICIAL_LEAGUE', 'https://orlen-superliga.pl', 'Ligový web / organizátor – Polsko', 'K auditu: ligové výsledky, program a statistiky; aktuální web nese značku LOTTO Superliga.', NULL, NULL, 'Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.'),
    (290, 'HB-CAND-029', 'Svensk Elithandboll / Handbollsligan', 'OFFICIAL_LEAGUE', 'https://handbollsligan.se', 'Ligový web / organizátor – Švédsko', 'K auditu: mužské i ženské soutěže; ověřena ženská stránka týmových statistik.', 'https://handbollsligan.se/dam/lagstatistik/', NULL, 'Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.'),
    (300, 'HB-CAND-030', 'Asian Handball Federation', 'FEDERATION', 'https://asianhandball.org', 'Asijská házenkářská federace', 'K auditu: kontinentální soutěže, programy, výsledky a zprávy.', NULL, NULL, NULL),
    (310, 'HB-CAND-031', 'Confédération Africaine de Handball', 'FEDERATION', 'https://cahbonline.info', 'Africká házenkářská konfederace', 'K auditu: africké soutěže, účastníci, programy a výsledky.', NULL, NULL, NULL),
    (320, 'HB-CAND-032', 'North America and the Caribbean Handball Confederation', 'FEDERATION', 'https://norcahandball.com', 'Severoamerická a karibská házenkářská konfederace', 'K auditu: regionální soutěže, účastníci a výsledky.', NULL, NULL, NULL)
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'sport_code', 'HB',
      'sport_name', 'Házená',
      'entity_type', 'MULTI',
      'source_name', source_name,
      'source_type', source_type,
      'base_url', base_url,
      'priority_order', priority_order,
      'access_type', 'UNKNOWN',
      'license_status', 'NEEDS_REVIEW',
      'robots_status', 'NEEDS_REVIEW',
      'expected_depth', 'UNKNOWN',
      'current_status', 'DISCOVERY',
      'next_action',
        'Ověřit identitu, rozsah dat a podmínky použití; následně zahájit audit.',
      'notes', jsonb_build_object(
        'batch', v_batch,
        'candidate_ref', candidate_ref,
        'discovery_date', '2026-09-28',
        'discovery_only', true,
        'who', who_text,
        'candidate_scope', scope_text,
        'discovery_reference_url', coalesce(evidence_url, base_url),
        'price_observation', coalesce(
          price_text,
          'Nezjištěna; cenu datového přístupu ověřit při auditu.'
        ),
        'time_modes', jsonb_build_object(
          'HISTORY_FAN', 'UNKNOWN',
          'HISTORY_PREDICTION', 'UNKNOWN',
          'CURRENT', 'UNKNOWN',
          'FUTURE', 'UNKNOWN',
          'LIVE', 'UNKNOWN'
        ),
        'remarks', coalesce(remarks, '')
      )::text
    )
    ORDER BY priority_order
  )
  INTO v_input
  FROM data;

  IF jsonb_array_length(v_input) <> 30 THEN
    RAISE EXCEPTION
      'BLOCKER: vstup musí obsahovat přesně 30 kandidátů';
  END IF;

  IF (
    SELECT count(DISTINCT lower(x->>'source_name'))
    FROM jsonb_array_elements(v_input) x
  ) <> 30 THEN
    RAISE EXCEPTION 'BLOCKER: duplicitní názvy ve vstupu';
  END IF;

  -- Kontrola všech šesti původních záznamů.
  IF (
    SELECT count(*)
    FROM ops.source_intelligence_map m
    JOIN (
      VALUES
      (1::bigint, 'European Handball Federation', 'MULTI', 'FEDERATION', 'https://www.eurohandball.com', 'CHECK_TERMS'),
      (2::bigint, 'International Handball Federation', 'MULTI', 'FEDERATION', 'https://www.ihf.info', 'CHECK_TERMS'),
      (3::bigint, 'Wikidata', 'PLAYERS', 'KNOWLEDGE_BASE', 'https://www.wikidata.org', 'CHECK_TERMS'),
      (4::bigint, 'Wikimedia Commons', 'PHOTOS', 'PHOTO_ARCHIVE', 'https://commons.wikimedia.org', 'CHECK_TERMS'),
      (5::bigint, 'Official Club Websites', 'MULTI', 'OFFICIAL_CLUB', NULL, 'DISCOVER_CLUBS'),
      (6::bigint, 'Official League Websites', 'MULTI', 'OFFICIAL_LEAGUE', NULL, 'DISCOVER_LEAGUES')
    ) b(id, name, entity, typ, url, status)
      ON m.source_map_id = b.id
      AND m.sport_code = 'HB'
      AND m.source_name = b.name
      AND m.entity_type = b.entity
      AND m.source_type = b.typ
      AND nullif(rtrim(btrim(m.base_url), '/'), '')
          IS NOT DISTINCT FROM b.url
      AND m.current_status = b.status
  ) <> 6 THEN
    RAISE EXCEPTION
      'BLOCKER: původních 6 řádků neodpovídá zkontrolovanému stavu';
  END IF;

  -- Shoda názvu/domény pouze kontroluje duplicity.
  FOR v_i IN
    SELECT value FROM jsonb_array_elements(v_input)
  LOOP
    SELECT array_agg(m.source_map_id ORDER BY m.source_map_id)
    INTO v_match_ids
    FROM ops.source_intelligence_map m
    WHERE m.sport_code = 'HB'
      AND (
        lower(btrim(m.source_name))
          = lower(btrim(v_i->>'source_name'))
        OR regexp_replace(
          lower(split_part(
            regexp_replace(m.base_url, '^https?://', '', 'i'),
            '/', 1
          )),
          '^www\.', ''
        ) = regexp_replace(
          lower(split_part(
            regexp_replace(v_i->>'base_url', '^https?://', '', 'i'),
            '/', 1
          )),
          '^www\.', ''
        )
      );

    IF coalesce(cardinality(v_match_ids), 0) > 1 THEN
      RAISE EXCEPTION
        'BLOCKER: více shod pro %', v_i->>'source_name';

    ELSIF cardinality(v_match_ids) = 1 THEN
      SELECT *
      INTO STRICT v_row
      FROM ops.source_intelligence_map
      WHERE source_map_id = v_match_ids[1];

      -- Vynechat lze pouze přesné opakování stejné dávky.
      IF (
        to_jsonb(v_row)
          - ARRAY['source_map_id', 'created_at', 'updated_at', 'notes']
      ) IS DISTINCT FROM (
        to_jsonb(jsonb_populate_record(
          NULL::ops.source_intelligence_map, v_i
        ))
          - ARRAY['source_map_id', 'created_at', 'updated_at', 'notes']
      ) THEN
        RAISE EXCEPTION
          'BLOCKER: existující řádek má jiné hodnoty: %',
          v_i->>'source_name';
      END IF;

      IF v_row.notes::jsonb
          IS DISTINCT FROM (v_i->>'notes')::jsonb THEN
        RAISE EXCEPTION
          'BLOCKER: shoda patří jiné dávce nebo má jiné poznámky: %',
          v_i->>'source_name';
      END IF;

      v_existing := array_append(v_existing, v_row.source_map_id);
    END IF;
  END LOOP;

  SELECT count(*)
  INTO v_total
  FROM ops.source_intelligence_map;

  IF v_total <> 6 + cardinality(v_existing) THEN
    RAISE EXCEPTION
      'BLOCKER: neočekávaný počet řádků: %', v_total;
  END IF;

  v_expected := 30 - cardinality(v_existing);

  SELECT jsonb_agg(to_jsonb(m) ORDER BY m.source_map_id)
  INTO v_before
  FROM ops.source_intelligence_map m;

  INSERT INTO ops.source_intelligence_map (
    sport_code, sport_name, entity_type,
    source_name, source_type, base_url,
    country_code, league_name, team_name,
    priority_order, trust_score, automation_score,
    access_type, license_status, robots_status,
    supports_players, supports_coaches, supports_photos,
    supports_profiles, supports_career_history,
    supports_transfers, supports_injuries,
    supports_stats, supports_media,
    supports_historical_data, supports_live_data,
    historical_from_year, expected_depth, current_status,
    last_checked_at, next_action, notes
  )
  SELECT
    r.sport_code, r.sport_name, r.entity_type,
    r.source_name, r.source_type, r.base_url,
    NULL, NULL, NULL,
    r.priority_order, NULL, NULL,
    r.access_type, r.license_status, r.robots_status,
    NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL,
    NULL, NULL,
    NULL, NULL,
    NULL, r.expected_depth, r.current_status,
    NULL, r.next_action, r.notes
  FROM jsonb_populate_recordset(
    NULL::ops.source_intelligence_map, v_input
  ) r
  WHERE NOT EXISTS (
    SELECT 1
    FROM ops.source_intelligence_map m
    WHERE m.source_map_id = ANY(v_existing)
      AND m.source_name = r.source_name
  );

  GET DIAGNOSTICS v_inserted = ROW_COUNT;

  IF v_inserted <> v_expected THEN
    RAISE EXCEPTION
      'BLOCKER: vloženo %, očekáváno %', v_inserted, v_expected;
  END IF;

  -- Kontrola zachování všech dříve existujících řádků.
  SELECT jsonb_agg(to_jsonb(m) ORDER BY m.source_map_id)
  INTO v_after
  FROM ops.source_intelligence_map m
  WHERE m.source_map_id IN (
    SELECT (x->>'source_map_id')::bigint
    FROM jsonb_array_elements(v_before) x
  );

  IF v_after IS DISTINCT FROM v_before THEN
    RAISE EXCEPTION 'BLOCKER: změnil se původní řádek';
  END IF;

  IF (
    SELECT count(*) FROM ops.source_intelligence_map
  ) <> 36 THEN
    RAISE EXCEPTION 'BLOCKER: výsledný počet není 36';
  END IF;

  -- Kontrola všech uložených hodnot včetně NULL.
  FOR v_i IN
    SELECT value FROM jsonb_array_elements(v_input)
  LOOP
    SELECT *
    INTO STRICT v_row
    FROM ops.source_intelligence_map
    WHERE sport_code = 'HB'
      AND source_name = v_i->>'source_name';

    IF (
      to_jsonb(v_row)
        - ARRAY['source_map_id', 'created_at', 'updated_at', 'notes']
    ) IS DISTINCT FROM (
      to_jsonb(jsonb_populate_record(
        NULL::ops.source_intelligence_map, v_i
      ))
        - ARRAY['source_map_id', 'created_at', 'updated_at', 'notes']
    )
    OR v_row.notes::jsonb
        IS DISTINCT FROM (v_i->>'notes')::jsonb THEN
      RAISE EXCEPTION
        'BLOCKER: kontrola uložených hodnot selhala pro %',
        v_i->>'source_name';
    END IF;
  END LOOP;

  RAISE NOTICE
    'VALIDACE OK: vloženo %, již existovalo %, původní řádky zachovány; následuje COMMIT.',
    v_inserted, cardinality(v_existing);
END
$import$;

COMMIT;

-- Výsledky po COMMIT.
-- Při chybě výše tyto SELECTy samy nedokládají úspěch.
SELECT
  count(*) AS celkem_radku,
  count(*) FILTER (
    WHERE sport_code = 'HB'
  ) AS hb_radku,
  count(*) FILTER (
    WHERE source_map_id BETWEEN 1 AND 6
  ) AS puvodnich_radku,
  count(*) FILTER (
    WHERE sport_code = 'HB'
      AND current_status = 'DISCOVERY'
      AND notes LIKE '%HB_CANDIDATES_20260928_V1%'
  ) AS kandidatu_v_davce
FROM ops.source_intelligence_map;

SELECT
  source_map_id,
  source_name,
  source_type,
  current_status,
  supports_players,
  supports_stats,
  supports_historical_data,
  supports_live_data
FROM ops.source_intelligence_map
WHERE sport_code = 'HB'
ORDER BY priority_order NULLS LAST, source_map_id;