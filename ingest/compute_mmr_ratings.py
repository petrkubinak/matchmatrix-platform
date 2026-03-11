print("VERSION CHECK: TOTAL+HA+MOM+VOL")
print("FILE:", __file__)

import math
import statistics
from collections import deque

import psycopg2
from psycopg2.extras import execute_values


# ==========================================================
# MATCHMATRIX
# COMPUTE MMR RATINGS V2
# ==========================================================

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

# ====== PARAMETRY RATINGU (laditelné) ======
BASE_RATING = 1500.0
HOME_ADV = 30.0
SCALE = 300.0
K = 30.0

DRAW_BASE = 0.27
DRAW_MIN = 0.15
DRAW_MAX = 0.35

HA_SPECIALIZATION_FACTOR = 1.0

# ===== Momentum / Volatility =====
MOM_SPAN = 6
VOL_WINDOW = 10
VOL_MIN_SAMPLES = 3


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
    sql = """
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (table_name,))
        return {r[0] for r in cur.fetchall()}


def main() -> None:
    print("=== MATCHMATRIX: COMPUTE MMR RATINGS V2 (TOTAL+HOME/AWAY+MOM+VOL, per league) ===")

    with psycopg2.connect(**DB_CONFIG) as conn:
        conn.autocommit = False

        match_cols = get_table_columns(conn, "mm_match_ratings")
        team_cols = get_table_columns(conn, "mm_team_ratings")

        print("mm_match_ratings columns detected:", len(match_cols))
        print("mm_team_ratings columns detected:", len(team_cols))

        sql = """
        SELECT
          m.id AS match_id,
          m.league_id,
          m.kickoff,
          m.home_team_id,
          m.away_team_id,
          m.home_score,
          m.away_score
        FROM public.matches m
        WHERE m.status = 'FINISHED'
          AND m.home_score IS NOT NULL
          AND m.away_score IS NOT NULL
        ORDER BY m.league_id, m.kickoff, m.id;
        """

        with conn.cursor() as cur:
            cur.execute(sql)
            rows = cur.fetchall()

        print(f"Loaded finished matches: {len(rows)}")

        ratings: dict[tuple[int, int], dict[str, float]] = {}
        team_latest: dict[tuple[int, int], tuple[dict[str, float], int, object]] = {}

        def get_team_state(league_id: int, team_id: int) -> dict:
            st = ratings.get((league_id, team_id))
            if st is None:
                st = {
                    "total": BASE_RATING,
                    "home": BASE_RATING,
                    "away": BASE_RATING,
                    "mom": 0.0,
                    "vol": 0.0,
                    "history": deque(maxlen=VOL_WINDOW),
                }
                ratings[(league_id, team_id)] = st
            return st

        def score_to_result(home_score: int, away_score: int) -> tuple[float, float]:
            if home_score > away_score:
                return 1.0, 0.0
            if home_score < away_score:
                return 0.0, 1.0
            return 0.5, 0.5

        match_values = []
        team_values = []

        for match_id, league_id, kickoff, home_team_id, away_team_id, home_score, away_score in rows:
            home = get_team_state(league_id, home_team_id)
            away = get_team_state(league_id, away_team_id)

            # pre-match ratingy
            home_total_before = home["total"]
            away_total_before = away["total"]
            home_home_before = home["home"]
            away_away_before = away["away"]
            home_mom_before = home["mom"]
            away_mom_before = away["mom"]
            home_vol_before = home["vol"]
            away_vol_before = away["vol"]

            # total model
            d_total = (home_total_before + HOME_ADV) - away_total_before
            p_home_win_total = sigmoid(d_total / SCALE)
            p_draw = draw_probability(d_total)
            p_home = p_home_win_total * (1.0 - p_draw)
            p_away = (1.0 - p_home_win_total) * (1.0 - p_draw)

            # home/away specializace
            d_ha = (home_home_before + HOME_ADV) - away_away_before
            p_home_win_ha = sigmoid(d_ha / SCALE)

            # skutečný výsledek
            s_home, s_away = score_to_result(home_score, away_score)

            # delta total
            exp_home_total = p_home + 0.5 * p_draw
            exp_away_total = p_away + 0.5 * p_draw
            delta_home_total = K * (s_home - exp_home_total)
            delta_away_total = K * (s_away - exp_away_total)

            # delta home/away
            exp_home_ha = p_home_win_ha
            exp_away_ha = 1.0 - p_home_win_ha
            delta_home_ha = K * HA_SPECIALIZATION_FACTOR * (s_home - exp_home_ha)
            delta_away_ha = K * HA_SPECIALIZATION_FACTOR * (s_away - exp_away_ha)

            # aktualizace ratingů
            home["total"] += delta_home_total
            away["total"] += delta_away_total
            home["home"] += delta_home_ha
            away["away"] += delta_away_ha

            # momentum = EWMA z total delt
            alpha = 2.0 / (MOM_SPAN + 1.0)
            home["mom"] = alpha * delta_home_total + (1 - alpha) * home["mom"]
            away["mom"] = alpha * delta_away_total + (1 - alpha) * away["mom"]

            # volatility = std z posledních delt
            home["history"].append(delta_home_total)
            away["history"].append(delta_away_total)

            if len(home["history"]) >= VOL_MIN_SAMPLES:
                home["vol"] = statistics.pstdev(home["history"])
            if len(away["history"]) >= VOL_MIN_SAMPLES:
                away["vol"] = statistics.pstdev(away["history"])

            # match row
            rating_diff = home_total_before - away_total_before
            ha_diff = home_home_before - away_away_before
            momentum_diff = home_mom_before - away_mom_before
            volatility_diff = home_vol_before - away_vol_before
            volatility_sum = home_vol_before + away_vol_before

            match_row = {
                "match_id": match_id,
                "league_id": league_id,
                "kickoff": kickoff,
                "home_team_id": home_team_id,
                "away_team_id": away_team_id,
                "home_rating": home_total_before,
                "away_rating": away_total_before,
                "rating_diff": rating_diff,
                "created_at": kickoff,
                "home_rating_home": home_home_before,
                "away_rating_away": away_away_before,
                "home_momentum": home_mom_before,
                "away_momentum": away_mom_before,
                "home_volatility": home_vol_before,
                "away_volatility": away_vol_before,
                "ha_diff": ha_diff,
                "momentum_diff": momentum_diff,
                "volatility_diff": volatility_diff,
                "volatility_sum": volatility_sum,
            }

            match_values.append(match_row)

            # latest team state
            team_latest[(league_id, home_team_id)] = (home.copy(), match_id, kickoff)
            team_latest[(league_id, away_team_id)] = (away.copy(), match_id, kickoff)

        # team rows
        for (league_id, team_id), (state, last_match_id, last_kickoff) in team_latest.items():
            team_row = {
                "league_id": league_id,
                "team_id": team_id,
                "rating": state["total"],
                "rating_home": state["home"],
                "rating_away": state["away"],
                "momentum": state["mom"],
                "volatility": state["vol"],
                "last_match_id": last_match_id,
                "last_kickoff": last_kickoff,
                "updated_at": last_kickoff,
            }
            team_values.append(team_row)

        with conn.cursor() as cur:
            cur.execute("TRUNCATE TABLE public.mm_match_ratings")
            cur.execute("TRUNCATE TABLE public.mm_team_ratings")

            # mm_match_ratings
            match_insert_cols = [
                "match_id",
                "league_id",
                "kickoff",
                "home_team_id",
                "away_team_id",
                "home_rating",
                "away_rating",
                "rating_diff",
                "created_at",
                "home_rating_home",
                "away_rating_away",
                "home_momentum",
                "away_momentum",
                "home_volatility",
                "away_volatility",
                "ha_diff",
                "momentum_diff",
                "volatility_diff",
                "volatility_sum",
            ]

            match_tuples = [
                tuple(row.get(col) for col in match_insert_cols)
                for row in match_values
            ]

            if match_tuples:
                execute_values(
                    cur,
                    f"""
                    INSERT INTO public.mm_match_ratings
                    ({", ".join(match_insert_cols)})
                    VALUES %s
                    """,
                    match_tuples,
                    page_size=1000,
                )

            # mm_team_ratings
            team_insert_cols = [
                c for c in [
                    "league_id",
                    "team_id",
                    "rating",
                    "last_match_id",
                    "last_kickoff",
                    "updated_at",
                    "rating_home",
                    "rating_away",
                    "momentum",
                    "volatility",
                ]
                if c in team_cols
            ]

            team_tuples = [
                tuple(row.get(col) for col in team_insert_cols)
                for row in team_values
            ]

            if team_tuples:
                execute_values(
                    cur,
                    f"""
                    INSERT INTO public.mm_team_ratings
                    ({", ".join(team_insert_cols)})
                    VALUES %s
                    """,
                    team_tuples,
                    page_size=1000,
                )

        conn.commit()

        with conn.cursor() as cur:
            cur.execute("SELECT count(*) FROM public.mm_match_ratings")
            mm_match_count = cur.fetchone()[0]

            cur.execute("SELECT count(*) FROM public.mm_team_ratings")
            mm_team_count = cur.fetchone()[0]

        print(f"Saved mm_match_ratings: {mm_match_count}")
        print(f"Saved mm_team_ratings: {mm_team_count}")

if __name__ == "__main__":
    main()