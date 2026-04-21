-- =====================================================================
-- 258_export_no_exact_match_buckets.sql
-- Rozdeleni NO_EXACT_MATCH do prvnich pracovnich bucketu
-- =====================================================================

WITH base AS (
    SELECT
        s.provider,
        s.external_team_id,
        s.team_name
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_football'
      AND COALESCE(s.sport_code, '') IN ('football', 'FB', '')
      AND NOT EXISTS (
          SELECT 1
          FROM public.team_provider_map m
          WHERE m.provider = s.provider
            AND m.provider_team_id = s.external_team_id
      )
      AND NOT EXISTS (
          SELECT 1
          FROM public.teams t
          WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(s.team_name))
      )
)
SELECT
    CASE
        WHEN team_name ~ '\?' THEN 'ENCODING_OR_BROKEN_TEXT'
        WHEN team_name ~* '(^| )(U16|U17|U18|U19|U20|U21|U23|W U20|W U19|W)$' THEN 'YOUTH_OR_WOMEN_NATIONAL'
        WHEN team_name ~* '(^| )(II|III|Amateurs|B)$' THEN 'B_TEAMS_OR_AMATEURS'
        WHEN team_name ~* '^(Afghanistan|Albania|Algeria|Andorra|Angola|Argentina|Armenia|Aruba|Austria|Azerbaijan|Bahrain|Bangladesh|Belarus|Belize|Benin|Bermuda|Bhutan|Bolivia|Bonaire|Bosnia|Botswana|Brunei|Bulgaria|Burkina Faso|Burundi|Cambodia|Cameroon|Canada|Cayman Islands|Central African Republic|Chile|China|Chinese Taipei|Comoros|Congo|Costa Rica|Cuba|Cyprus|Czech Republic|Denmark|Djibouti|Dominica|Dominican Republic|Egypt|El Salvador|England|Equatorial Guinea|Estonia|Ethiopia|Faroe Islands|Fiji|Finland|France|French Guyana|Gabon|Gambia|Georgia|Germany|Gibraltar|Greece|Grenada|Guatemala|Guinea|Guinea-Bissau|Guyana|Honduras|Hong Kong|Hungary|Iceland|India|Indonesia|Israel|Italy|Jamaica|Japan|Jordan|Kazakhstan|Kenya|Kosovo|Kuwait|Kyrgyzstan|Laos|Latvia|Lebanon|Lesotho|Libya|Liechtenstein|Luxembourg|Madagascar|Malawi|Malaysia|Maldives|Mali|Malta|Martinique|Mauritania|Mauritius|Mexico|Moldova|Mongolia|Montenegro|Morocco|Mozambique|Myanmar|Namibia|Nepal|Netherlands|New Caledonia|Nicaragua|Niger|Nigeria|Northern Ireland|North Korea|Norway|Oman|Palestine|Panama|Papua New Guinea|Paraguay|Peru|Philippines|Portugal|Puerto Rico|Qatar|Russia|Rwanda|San Marino|Saudi Arabia|Sierra Leone|Singapore|Slovakia|Solomon Islands|Spain|Sri Lanka|Sudan|Suriname|Sweden|Syria|Tajikistan|Tanzania|Thailand|Togo|Trinidad and Tobago|Tunisia|Turkey|Turkmenistan|Uganda|Ukraine|United Arab Emirates|United States|USA|Uzbekistan|Vanuatu|Venezuela|Vietnam|Wales|Yemen|Zambia|Zimbabwe)$'
            THEN 'NATIONAL_TEAMS'
        ELSE 'OTHER_CLUB_CASES'
    END AS bucket,
    provider,
    external_team_id,
    team_name
FROM base
ORDER BY bucket, team_name;