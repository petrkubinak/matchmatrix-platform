/* CO: MM HB kandidáti – KROK 1 – READ ONLY PRECHECK V1
   K ČEMU: Porovnat 34 kandidátů s existujícím registrem před importem.
   KDE: DBeaver, databáze matchmatrix, ops.source_intelligence_map.
   JAK: Spustit celý skript. Pouze SELECT; bez INSERT i bez změny sekvencí.
   Shoda webu/názvu je pouze varování proti duplicitám, nikoli canonical vazba.
*/
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL statement_timeout = '30s';

SELECT current_database() AS databaze, current_user AS uzivatel,
       inet_server_addr() AS server, inet_server_port() AS port,
       current_setting('transaction_read_only') AS pouze_cteni;

WITH kandidati(poradi, source_name, base_url, entity_type, source_type, expected_id) AS (
  VALUES
    (1, 'API-Sports', 'https://api-sports.io', 'MULTI', 'DATA_PROVIDER', NULL::bigint),
    (2, 'Sportradar', 'https://sportradar.com', 'MULTI', 'DATA_PROVIDER', NULL::bigint),
    (3, 'STATSCORE', 'https://www.statscore.com', 'MULTI', 'DATA_PROVIDER', NULL::bigint),
    (4, 'Data Sports Group', 'https://datasportsgroup.com', 'MULTI', 'DATA_PROVIDER', NULL::bigint),
    (5, 'Goalserve', 'https://www.goalserve.com', 'MULTI', 'DATA_PROVIDER', NULL::bigint),
    (6, 'BetsAPI', 'https://betsapi.com', 'MULTI', 'DATA_PROVIDER', NULL::bigint),
    (7, 'European Handball Federation', 'https://www.eurohandball.com', 'MULTI', 'FEDERATION', 1),
    (8, 'International Handball Federation', 'https://www.ihf.info', 'MULTI', 'FEDERATION', 2),
    (9, 'Český svaz házené', 'https://www.handball.cz', 'MULTI', 'FEDERATION', NULL::bigint),
    (10, 'Deutscher Handballbund', 'https://www.dhb.de', 'MULTI', 'FEDERATION', NULL::bigint),
    (11, 'DanskHåndbold', 'https://danskhaandbold.dk', 'MULTI', 'FEDERATION', NULL::bigint),
    (12, 'Norges Håndballforbund', 'https://www.handball.no', 'MULTI', 'FEDERATION', NULL::bigint),
    (13, 'Svenska Handbollförbundet', 'https://svenskhandboll.se', 'MULTI', 'FEDERATION', NULL::bigint),
    (14, 'Fédération Française de Handball', 'https://www.ffhandball.fr', 'MULTI', 'FEDERATION', NULL::bigint),
    (15, 'Real Federación Española de Balonmano', 'https://www.rfebm.com', 'MULTI', 'FEDERATION', NULL::bigint),
    (16, 'Związek Piłki Ręcznej w Polsce', 'https://zprp.pl', 'MULTI', 'FEDERATION', NULL::bigint),
    (17, 'Magyar Kézilabda Szövetség', 'https://www.mksz.hu', 'MULTI', 'FEDERATION', NULL::bigint),
    (18, 'Federația Română de Handbal', 'https://frh.ro', 'MULTI', 'FEDERATION', NULL::bigint),
    (19, 'Hrvatski rukometni savez', 'https://hrs.hr', 'MULTI', 'FEDERATION', NULL::bigint),
    (20, 'Rokometna zveza Slovenije', 'https://www.rokometna-zveza.si', 'MULTI', 'FEDERATION', NULL::bigint),
    (21, 'Schweizerischer Handball-Verband', 'https://www.handball.ch', 'MULTI', 'FEDERATION', NULL::bigint),
    (22, 'Österreichischer Handballbund', 'https://www.oehb.at', 'MULTI', 'FEDERATION', NULL::bigint),
    (23, 'Slovenský zväz hádzanej', 'https://www.slovakhandball.sk', 'MULTI', 'FEDERATION', NULL::bigint),
    (24, 'Federação de Andebol de Portugal', 'https://portal.fpa.pt', 'MULTI', 'FEDERATION', NULL::bigint),
    (25, 'Handball-Bundesliga', 'https://www.opel-hbl.de', 'MULTI', 'OFFICIAL_LEAGUE', NULL::bigint),
    (26, 'Ligue Nationale de Handball', 'https://www.lnh.fr', 'MULTI', 'OFFICIAL_LEAGUE', NULL::bigint),
    (27, 'ASOBAL', 'https://asobal.es', 'MULTI', 'OFFICIAL_LEAGUE', NULL::bigint),
    (28, 'Superliga (Polsko)', 'https://orlen-superliga.pl', 'MULTI', 'OFFICIAL_LEAGUE', NULL::bigint),
    (29, 'Svensk Elithandboll / Handbollsligan', 'https://handbollsligan.se', 'MULTI', 'OFFICIAL_LEAGUE', NULL::bigint),
    (30, 'Asian Handball Federation', 'https://asianhandball.org', 'MULTI', 'FEDERATION', NULL::bigint),
    (31, 'Confédération Africaine de Handball', 'https://cahbonline.info', 'MULTI', 'FEDERATION', NULL::bigint),
    (32, 'North America and the Caribbean Handball Confederation', 'https://norcahandball.com', 'MULTI', 'FEDERATION', NULL::bigint),
    (33, 'Wikidata', 'https://www.wikidata.org', 'PLAYERS', 'KNOWLEDGE_BASE', 3),
    (34, 'Wikimedia Commons', 'https://commons.wikimedia.org', 'PHOTOS', 'PHOTO_ARCHIVE', 4)
), normalizace AS (
  SELECT k.*,
    regexp_replace(lower(split_part(regexp_replace(k.base_url,
      '^https?://', '', 'i'), '/', 1)), '^www\.', '') AS domena
  FROM kandidati k
), shody AS (
  SELECT k.*, x.pocet, x.id, x.jmena, x.stavy,
         x.presna_shoda
  FROM normalizace k
  CROSS JOIN LATERAL (
    SELECT count(*) AS pocet, min(m.source_map_id) AS id,
           string_agg(m.source_name, ' | ' ORDER BY m.source_map_id) AS jmena,
           string_agg(coalesce(m.current_status, '(NULL)'), ' | '
             ORDER BY m.source_map_id) AS stavy,
           bool_and(m.source_name = k.source_name
             AND m.entity_type = k.entity_type AND m.source_type = k.source_type
             AND m.source_map_id = k.expected_id
             AND regexp_replace(lower(split_part(regexp_replace(m.base_url,
               '^https?://', '', 'i'), '/', 1)), '^www\.', '') = k.domena)
             AS presna_shoda
    FROM ops.source_intelligence_map m
    WHERE m.sport_code = 'HB'
      AND (lower(btrim(m.source_name)) = lower(btrim(k.source_name))
        OR regexp_replace(lower(split_part(regexp_replace(m.base_url,
          '^https?://', '', 'i'), '/', 1)), '^www\.', '') = k.domena
        OR m.source_map_id = k.expected_id)
  ) x
), vysledek AS (
  SELECT *, CASE
    WHEN pocet = 0 AND expected_id IS NULL THEN 'NOVY_KANDIDAT'
    WHEN pocet = 1 AND presna_shoda IS TRUE THEN 'ZACHOVAT_EXISTUJICI'
    ELSE 'PROVERIT_KOLIZI'
  END AS stav
  FROM shody
)
SELECT poradi, source_name AS zdroj, stav, pocet AS pocet_shod,
       id AS existujici_source_map_id, stavy AS stavajici_stav,
       jmena AS nalezene_nazvy,
       count(*) FILTER (WHERE stav = 'NOVY_KANDIDAT') OVER () AS novych_celkem,
       count(*) FILTER (WHERE stav = 'ZACHOVAT_EXISTUJICI') OVER () AS zachovat_celkem,
       count(*) FILTER (WHERE stav = 'PROVERIT_KOLIZI') OVER () AS kolizi_celkem
FROM vysledek ORDER BY poradi;

SELECT count(*) AS vsechny_radky,
       count(*) FILTER (WHERE sport_code = 'HB') AS hb_radky,
       has_table_privilege(current_user, 'ops.source_intelligence_map', 'INSERT')
         AS pravo_insert
FROM ops.source_intelligence_map;

-- Neočekávaný trigger či RLS musí být posouzen před zápisem.
SELECT c.relkind AS typ_objektu, c.relrowsecurity AS rls,
       c.relforcerowsecurity AS force_rls,
       (SELECT count(*) FROM pg_trigger t
        WHERE t.tgrelid = c.oid AND NOT t.tgisinternal) AS vlastni_triggery
FROM pg_class c WHERE c.oid = 'ops.source_intelligence_map'::regclass;

ROLLBACK;
