# mm_env.ps1  (konfigurace pro MatchMatrix ops)

# 1) Připojení na DB (doporučeno přes DATABASE_URL)
# Příklad pro docker postgres:
# postgresql://postgres:postgres@localhost:5432/postgres
if (-not $env:DATABASE_URL) {
  # Pokud nechceš env proměnnou, můžeš ji nastavit tady natvrdo:
  # $env:DATABASE_URL = "postgresql://postgres:postgres@localhost:5432/postgres"
}

# 2) Cesty k runnerům / skriptům
# API-Football pipeline (ten co dělá: pull->staging->merge)
$Global:API_FOOTBALL_PIPELINE = "C:\MatchMatrix-platform\ingest\API-Football\run_api_football_pipeline.ps1"

# Root scripts (pokud budeš chtít pouštět SQL přímo)
$Global:SCRIPTS_ROOT = "C:\MatchMatrix-platform\MatchMatrix-platform\Scripts"

# 3) Logy
$Global:LOG_DIR = "C:\MatchMatrix-platform\logs"