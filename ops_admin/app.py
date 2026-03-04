import os
import json
import subprocess
from datetime import datetime
import pandas as pd
import psycopg2
import streamlit as st

# ====== CONFIG ======
# Použij DATABASE_URL např:
# postgresql://postgres:postgres@localhost:5432/postgres
DATABASE_URL = os.environ.get("DATABASE_URL", "")

# Cesty k tvým runnerům (upravíš 1x)
PS_PIPELINE = r"C:\MatchMatrix-platform\ingest\API-Football\run_api_football_pipeline.ps1"
SCRIPTS_ROOT = r"C:\MatchMatrix-platform\MatchMatrix-platform\Scripts"

# ====== DB HELPERS ======
def db_conn():
    if not DATABASE_URL:
        raise RuntimeError("DATABASE_URL env is not set.")
    return psycopg2.connect(DATABASE_URL)

def fetch_df(sql: str, params=None) -> pd.DataFrame:
    with db_conn() as conn:
        return pd.read_sql(sql, conn, params=params)

def exec_sql(sql: str, params=None):
    with db_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, params)
        conn.commit()

def start_job_run(job_code: str, params: dict) -> int:
    sql = """
    insert into ops.job_runs(job_code, params, status)
    values (%s, %s::jsonb, 'running')
    returning id
    """
    with db_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, (job_code, json.dumps(params)))
            run_id = cur.fetchone()[0]
        conn.commit()
    return run_id

def finish_job_run(run_id: int, status: str, message: str = "", details: dict | None = None):
    details = details or {}
    sql = """
    update ops.job_runs
    set status=%s, finished_at=now(), message=%s, details=%s::jsonb
    where id=%s
    """
    exec_sql(sql, (status, message, json.dumps(details), run_id))

# ====== RUNNERS ======
def run_powershell(cmd: list[str]) -> tuple[int, str]:
    p = subprocess.run(
        ["powershell", "-ExecutionPolicy", "Bypass", "-Command"] + cmd,
        capture_output=True,
        text=True
    )
    out = (p.stdout or "") + "\n" + (p.stderr or "")
    return p.returncode, out

st.set_page_config(page_title="MatchMatrix – Owner Admin", layout="wide")
st.title("MatchMatrix – Owner/Admin centrum")

# ---- Sidebar: DB status ----
with st.sidebar:
    st.header("Systém")
    st.write("Čas:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    st.write("DATABASE_URL:", "OK" if DATABASE_URL else "CHYBÍ (nastav env)")
    st.divider()

# ---- Tabs ----
tab1, tab2, tab3 = st.tabs(["Dashboard", "Jobs", "Ekonomika"])

# ===================== Dashboard =====================
with tab1:
    st.subheader("Poslední běhy jobů")
    df_runs = fetch_df("""
        select id, job_code, status, started_at, finished_at, message
        from ops.job_runs
        order by started_at desc
        limit 30
    """)
    st.dataframe(df_runs, use_container_width=True)

    st.subheader("Import zdraví (api_import_runs)")
    # pokud máš tabulku public.api_import_runs, ukážeme poslední záznamy
    try:
        df_imp = fetch_df("""
            select id, source, status, started_at, finished_at
            from public.api_import_runs
            order by started_at desc
            limit 20
        """)
        st.dataframe(df_imp, use_container_width=True)
    except Exception as e:
        st.info("Tabulka public.api_import_runs není dostupná nebo má jiné sloupce. (Doladíme.)")

# ===================== Jobs =====================
with tab2:
    st.subheader("Ingest targets (co taháme)")
    df_targets = fetch_df("""
        select id, sport_code, canonical_league_id, provider, provider_league_id, season, tier,
               enabled, fixtures_days_back, fixtures_days_forward, odds_days_forward, notes
        from ops.ingest_targets
        order by enabled desc, sport_code, tier, id
    """)
    st.dataframe(df_targets, use_container_width=True)

    st.divider()
    st.subheader("Spuštění jobů")

    colA, colB = st.columns(2)

    with colA:
        st.markdown("### 1) Daily Run (doporučeno)")
        st.caption("Pořadí: fixtures → odds → ratings → predictions → healthcheck")

        if st.button("▶ Spustit DAILY RUN"):
            job_run_id = start_job_run("daily_run", {"mode": "daily"})
            try:
                # Minimal: prozatím spustíme jen api_football pipeline pro všechny enabled targets api_football
                targets = fetch_df("""
                    select provider_league_id, season
                    from ops.ingest_targets
                    where enabled=true and provider='api_football'
                    order by tier asc, id asc
                """)

                logs = []
                for _, r in targets.iterrows():
                    league_id = int(r["provider_league_id"])
                    season = int(r["season"]) if str(r["season"]).isdigit() else 2025
                    rc, out = run_powershell([f"& '{PS_PIPELINE}' -LeagueId {league_id} -Season {season}"])
                    logs.append({"league_id": league_id, "season": season, "rc": rc})
                    if rc != 0:
                        raise RuntimeError(out)

                finish_job_run(job_run_id, "success", "Daily run OK", {"targets": logs})
                st.success("Daily run dokončen.")
            except Exception as e:
                finish_job_run(job_run_id, "failed", str(e)[:500], {})
                st.error(f"Chyba: {e}")

    with colB:
        st.markdown("### 2) Jednotlivé akce (on-demand)")
        target_id = st.selectbox(
            "Vyber ingest target",
            options=df_targets["id"].tolist() if not df_targets.empty else [],
        )

        if target_id:
            t = df_targets[df_targets["id"] == target_id].iloc[0]
            st.write("Target:", dict(t))

            if st.button("⬇ Ingest: fixtures+teams+matches (API-Football pipeline)"):
                job_run_id = start_job_run("ingest_fixtures", {"target_id": int(target_id)})
                try:
                    league_id = int(t["provider_league_id"])
                    season = int(t["season"]) if str(t["season"]).isdigit() else 2025
                    rc, out = run_powershell([f"& '{PS_PIPELINE}' -LeagueId {league_id} -Season {season}"])
                    if rc != 0:
                        raise RuntimeError(out)
                    finish_job_run(job_run_id, "success", "Ingest OK", {"stdout": out[-4000:]})
                    st.success("Ingest dokončen.")
                except Exception as e:
                    finish_job_run(job_run_id, "failed", str(e)[:500], {})
                    st.error(f"Chyba: {e}")

# ===================== Ekonomika =====================
with tab3:
    st.subheader("Ekonomika / uživatelé (placeholder)")
    st.info(
        "Tuhle část napojíme, až budeš mít tabulky users/subscriptions/payments "
        "(nebo aspoň logy návštěv a objednávek). Zatím ti sem dám základní kostru grafů."
    )
    st.markdown("- MAU/WAU/DAU\n- MRR/ARR\n- Konverze Free→Paid\n- Churn\n- ARPU")