-- CO: STEP 12C – aktuálnost uložených zápasů api_handball
-- K ČEMU: Zjistit, zda průběžný sběr přinesl nedávné a nadcházející zápasy.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

SELECT
    count(*) AS celkem_zapasu,
    count(*) FILTER (
        WHERE m.kickoff >= CURRENT_DATE - 7
          AND m.kickoff < CURRENT_DATE
    ) AS poslednich_7_dni,
    count(*) FILTER (
        WHERE m.kickoff >= CURRENT_DATE
          AND m.kickoff < CURRENT_DATE + 15
    ) AS dnes_a_dalsich_14_dni,
    max(m.kickoff) AS nejpozdejsi_zapas,
    max(m.updated_at) AS posledni_aktualizace
FROM public.matches m
WHERE EXISTS (
    SELECT 1
    FROM public.match_provider_map pm
    WHERE pm.match_id = m.id
      AND pm.provider = 'api_handball'
);