print("VERSION CHECK: TOTAL+HA+MOM+VOL")
print("FILE:", __file__)

import os
import math
import psycopg2
import statistics
from collections import deque
from psycopg2.extras import execute_values


# ====== PARAMETRY RATINGU (laditelné) ======
BASE_RATING = 1500.0     # start rating pro nový tým v lize
HOME_ADV = 30.0          # můžeš snížit (dřív 60), protože HA split už část home biasu chytá
SCALE = 300.0            # škála pro sigmoid (citlivost rozdílu ratingů)
K = 30.0                 # rychlost učení (větší = rychleji se mění rating)

DRAW_BASE = 0.27         # základní pravděpodobnost remízy
DRAW_MIN = 0.15
DRAW_MAX = 0.35

# jak moc se má aktualizovat i "specializace" home/away vůči total
# 1.0 = aktualizace stejná jako total (nejjednodušší, funguje dobře)
# 0.5 = konzervativnější specializace
HA_SPECIALIZATION_FACTOR = 1.0

# ===== Momentum / Volatility =====
MOM_SPAN = 6          # EWMA span
VOL_WINDOW = 10       # rolling okno pro delty
VOL_MIN_SAMPLES = 3   # od kolika hodnot počítat std

def sigmoid(x: float) -> float:
    return 1.0 / (1.0 + math.exp(-x))


def clamp(x: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, x))


def draw_probability(d: float) -> float:
    """
    Remíza je pravděpodobnější u vyrovnaných týmů.
    Čím větší absolutní rozdíl ratingu, tím remíza klesá.
    """
    adj = abs(d) / 800.0
    p = DRAW_BASE * (1.0 - adj)
    return clamp(p, DRAW_MIN, DRAW_MAX)


def get_table_columns(conn, table_name: str) -> set[str]:
    schema = "public"
    sql = """
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = %s AND table_name = %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (schema, table_name))
        return {r[0] for r in cur.fetchall()}


def main():
    dsn = os.environ.get("DB_DSN")
    if not dsn:
        raise KeyError("DB_DSN")

    print("=== MATCHMATRIX: COMPUTE MMR RATINGS V2 (TOTAL+HOME/AWAY+MOM+VOL, per league) ===")

    with psycopg2.connect(dsn) as conn:
        conn.autocommit = False

        match_cols = get_table_columns(conn, "mm_match_ratings")
        team_cols = get_table_columns(conn, "mm_team_ratings")

        print("mm_match_ratings columns detected:", len(match_cols))
        print("mm_team_ratings columns detected:", len(team_cols))

        # 1) Načti všechny FINISHED zápasy se skóre (chronologicky per liga)
        sql = """
        SELECT
          m.id AS match_id,
          m.league_id,
          m.kickoff,
          m.home_team_id,
          m.away_team_id,
          m.home_score,
          m.away_score
        FROM matches m
        WHERE m.status = 'FINISHED'
          AND m.home_score IS NOT NULL
          AND m.away_score IS NOT NULL
        ORDER BY m.league_id, m.kickoff, m.id;
        """

        with conn.cursor() as cur:
            cur.execute(sql)
            rows = cur.fetchall()

        print(f"Loaded finished matches: {len(rows)}")

        # 2) Ratingy držíme v paměti per liga
        # (league_id, team_id) -> dict(total, home, away)
        ratings: dict[tuple[int, int], dict[str, float]] = {}
        team_latest: dict[tuple[int, int], tuple[dict[str, float], int, object]] = {}
        #             (league_id, team_id) -> (rating_dict, last_match_id, last_kickoff)

        def get_team_state(league_id: int, team_id: int) -> dict:
            st = ratings.get((league_id, team_id))
            if st is None:
                st = {
                    "total": BASE_RATING,
                    "home": BASE_RATING,
                    "away": BASE_RATING,
                    "mom": 0.0,
                    "vol": 0.0,
                    "deltas": deque(maxlen=VOL_WINDOW)
                }
                ratings[(league_id, team_id)] = st
            return st

        # 3) Batch pro mm_match_ratings
        batch = []

        for (match_id, league_id, kickoff, home_team_id, away_team_id, home_score, away_score) in rows:
            rh = get_team_state(league_id, home_team_id)
            ra = get_team_state(league_id, away_team_id)


            # PRE-MATCH snapshoty
            rh_total = rh["total"]
            ra_total = ra["total"]
            rh_home = rh["home"]
            ra_away = ra["away"]
            rh_mom = rh["mom"]
            ra_mom = ra["mom"]
            rh_vol = rh["vol"]
            ra_vol = ra["vol"]

            # HA-adjusted diff:
            # základ (total diff) + (home specialization) - (away specialization)
            # specialization = (home - total) / (away - total)
            d = (rh_total - ra_total) \
                + (rh_home - rh_total) \
                - (ra_away - ra_total)

            # volitelná globální domácí výhoda (už menší)
            d += HOME_ADV

            # 3-cestné pravděpodobnosti
            p_draw = draw_probability(d)
            p_home_raw = sigmoid(d / SCALE)
            p_away_raw = 1.0 - p_home_raw

            rest = (1.0 - p_draw)
            p_home = p_home_raw * rest
            p_away = p_away_raw * rest

            # očekávané "skóre" domácích (výhra=1, remíza=0.5, prohra=0)
            e_home = p_home + 0.5 * p_draw

            # skutečné skóre domácích
            if home_score > away_score:
                s_home = 1.0
            elif home_score < away_score:
                s_home = 0.0
            else:
                s_home = 0.5

            delta = K * (s_home - e_home)

            # UPDATE ratingů:
            # total se aktualizuje vždy
            rh["total"] += delta
            ra["total"] -= delta

            # home/away specializace:
            # domácí tým: home rating
            # hostující tým: away rating
            rh["home"] += delta * HA_SPECIALIZATION_FACTOR
            ra["away"] -= delta * HA_SPECIALIZATION_FACTOR

            alpha = 2.0 / (MOM_SPAN + 1.0)

            # Momentum (EWMA)
            rh["mom"] = rh["mom"] + alpha * (delta - rh["mom"])
            ra["mom"] = ra["mom"] + alpha * ((-delta) - ra["mom"])

            # Volatility
            rh["deltas"].append(delta)
            ra["deltas"].append(-delta)

            rh["vol"] = statistics.pstdev(rh["deltas"]) if len(rh["deltas"]) >= VOL_MIN_SAMPLES else 0.0
            ra["vol"] = statistics.pstdev(ra["deltas"]) if len(ra["deltas"]) >= VOL_MIN_SAMPLES else 0.0


            # (volitelně) můžeš lehce "tahat" home/away zpět k total kvůli stabilitě
            # např. po update: rh["home"] = 0.98*rh["home"] + 0.02*rh["total"]
            # zatím vypnuto, ať je to čisté

            # uložíme PRE-MATCH ratingy (ML features)
            row = {
                "match_id": match_id,
                "league_id": league_id,
                "kickoff": kickoff,
                "home_team_id": home_team_id,
                "away_team_id": away_team_id,
                "home_rating": rh_total,
                "away_rating": ra_total,
                "rating_diff": d,  # pozor: už obsahuje HA + HOME_ADV
            }
            # nové optional sloupce
            if "home_rating_home" in match_cols:
                row["home_rating_home"] = rh_home
            if "away_rating_away" in match_cols:
                row["away_rating_away"] = ra_away
            if "ha_diff" in match_cols:
                row["ha_diff"] = (rh_home - ra_away)

            # Momentum / Volatility snapshot
            if "home_momentum" in match_cols:
                row["home_momentum"] = rh_mom
            if "away_momentum" in match_cols:
                row["away_momentum"] = ra_mom
            if "home_volatility" in match_cols:
                row["home_volatility"] = rh_vol
            if "away_volatility" in match_cols:
                row["away_volatility"] = ra_vol

            if "momentum_diff" in match_cols:
                row["momentum_diff"] = (rh_mom - ra_mom)
            if "volatility_diff" in match_cols:
                row["volatility_diff"] = (rh_vol - ra_vol)
            if "volatility_sum" in match_cols:
                row["volatility_sum"] = (rh_vol + ra_vol)

            batch.append(row)

            team_latest[(league_id, home_team_id)] = (rh.copy(), match_id, kickoff)
            team_latest[(league_id, away_team_id)] = (ra.copy(), match_id, kickoff)

            if len(batch) >= 5000:
                upsert_match_ratings(conn, batch, match_cols)
                batch.clear()

        if batch:
            upsert_match_ratings(conn, batch, match_cols)
            batch.clear()

        # 4) UPSERT mm_team_ratings (latest snapshot)
        team_rows = []
        for (league_id, team_id), (r_dict, last_match_id, last_kickoff) in team_latest.items():
            tr = {
                "league_id": league_id,
                "team_id": team_id,
                "rating": r_dict["total"],
                "last_match_id": last_match_id,
                "last_kickoff": last_kickoff,
            }
            if "rating_home" in team_cols:
                tr["rating_home"] = r_dict["home"]
            if "rating_away" in team_cols:
                tr["rating_away"] = r_dict["away"]
            if "momentum" in team_cols:
                tr["momentum"] = r_dict["mom"]
            if "volatility" in team_cols:
                tr["volatility"] = r_dict["vol"]
            team_rows.append(tr)

        upsert_team_ratings(conn, team_rows, team_cols)

        conn.commit()
        print(f"Saved mm_match_ratings: {len(rows)}")
        print(f"Saved mm_team_ratings: {len(team_rows)}")
        print("Done.")


def upsert_match_ratings(conn, batch_rows: list[dict], match_cols: set[str]):
    """
    Upsert podle toho, jaké sloupce v tabulce existují (robustní vůči DB migracím).
    """
    base = [
        "match_id", "league_id", "kickoff", "home_team_id", "away_team_id",
        "home_rating", "away_rating", "rating_diff"
    ]

    # všechno volitelné, co máš v mm_match_ratings
    optional_candidates = [
        "home_rating_home", "away_rating_away",
        "home_momentum", "away_momentum",
        "home_volatility", "away_volatility",
        "ha_diff", "momentum_diff", "volatility_diff", "volatility_sum"
    ]

    optional = [c for c in optional_candidates if c in match_cols]
    cols = base + optional

    values = [tuple(r.get(c) for c in cols) for r in batch_rows]

    cols_sql = ", ".join(cols)
    update_sql = ", ".join(
        [f"{c} = EXCLUDED.{c}" for c in cols if c != "match_id"]
        + ["created_at = now()"]
    )

    with conn.cursor() as cur:
        execute_values(
            cur,
            f"""
            INSERT INTO mm_match_ratings ({cols_sql})
            VALUES %s
            ON CONFLICT (match_id) DO UPDATE SET
              {update_sql}
            """,
            values
        )
    conn.commit()

def upsert_team_ratings(conn, team_rows: list[dict], team_cols: set[str]):
    if not team_rows:
        return

    base = ["league_id", "team_id", "rating", "last_match_id", "last_kickoff"]
    optional = []
    for c in ("rating_home", "rating_away", "momentum", "volatility"):
        if c in team_cols:
            optional.append(c)

    cols = base + optional
    values = [tuple(r.get(c) for c in cols) for r in team_rows]

    cols_sql = ", ".join(cols)
    update_parts = []
    for c in cols:
        if c in ("league_id", "team_id"):
            continue
        update_parts.append(f"{c} = EXCLUDED.{c}")
    update_parts.append("updated_at = now()")
    update_sql = ", ".join(update_parts)

    with conn.cursor() as cur:
        execute_values(
            cur,
            f"""
            INSERT INTO mm_team_ratings ({cols_sql})
            VALUES %s
            ON CONFLICT (league_id, team_id) DO UPDATE SET
              {update_sql}
            """,
            values
        )
    conn.commit()


if __name__ == "__main__":
    main()
