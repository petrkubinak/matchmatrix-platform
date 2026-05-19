# ============================================================
# match_article_entities_v1.py
# MATCHMATRIX ARTICLE ENTITY MATCHER V1
#
# Účel:
# - projde public.articles
# - pokusí se najít:
#     teams
#     leagues
# - vytvoří vazby:
#     article_team_map
#     article_league_map
#
# První verze:
# - jednoduché text matching
# - LIKE / substring
#
# Budoucnost:
# - alias engine
# - NLP
# - embeddings
# - AI entity extraction
# ============================================================

from __future__ import annotations

import psycopg


DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)


# ============================================================
# DB LOADERS
# ============================================================

def load_articles(conn):

    sql = """
    SELECT
        a.id,
        COALESCE(a.title, ''),
        COALESCE(a.summary, ''),
        COALESCE(a.raw_text, ''),
        cs.name AS source_name
    FROM public.articles a
    LEFT JOIN public.content_sources cs
        ON cs.id = a.content_source_id
    ORDER BY a.id DESC
    LIMIT 100
    """

    return conn.execute(sql).fetchall()


def load_teams(conn, source_name):

    source_name = (source_name or "").upper()

    sport_code = None

    if source_name == "NHL":
        sport_code = "HK"

    elif source_name == "NBA":
        sport_code = "BK"

    elif source_name in ("UEFA", "FIFA"):
        sport_code = "FB"

    if not sport_code:
        return []

    sql = """
    SELECT DISTINCT
        t.id,
        t.name
    FROM public.teams t
    JOIN public.team_provider_map pm
        ON pm.team_id = t.id
    WHERE pm.provider =
        CASE
            WHEN %s = 'HK' THEN 'api_hockey'
            WHEN %s = 'BK' THEN 'api_sport'
            WHEN %s = 'FB' THEN 'api_football'
        END
    AND t.name IS NOT NULL
    AND length(t.name) >= 5
    """

    rows = conn.execute(
        sql,
        (
            sport_code,
            sport_code,
            sport_code,
        ),
    ).fetchall()

    blacklist = {
        "Real",
        "Inter",
        "Start",
        "Western",
        "Jordan",
        "Cavalier",
        "Brea",
    }

    filtered = []

    for row in rows:

        name = row[1]

        if name in blacklist:
            continue

        filtered.append(row)

    return filtered


def load_leagues(conn, source_name):

    source_name = (source_name or "").upper()

    provider = None

    if source_name == "NHL":
        provider = "api_hockey"

    elif source_name == "NBA":
        provider = "api_sport"

    elif source_name in ("UEFA", "FIFA"):
        provider = "api_football"

    if not provider:
        return []

    sql = """
    SELECT DISTINCT
        l.id,
        l.name
    FROM public.leagues l
    JOIN public.league_provider_map pm
        ON pm.league_id = l.id
    WHERE pm.provider = %s
      AND l.name IS NOT NULL
      AND length(l.name) >= 5
    """

    rows = conn.execute(
        sql,
        (provider,),
    ).fetchall()

    blacklist = {
        "Cup",
        "League",
        "Division",
        "Women",
        "Group",
        "Region",
        "National",
    }

    filtered = []

    for row in rows:

        name = row[1]

        if name in blacklist:
            continue

        filtered.append(row)

    return filtered

# ============================================================
# ALIASES
# ============================================================

def load_aliases(conn):

    sql = """
    SELECT
        entity_type,
        entity_id,
        alias_text,
        source_scope,
        provider_scope
    FROM public.media_entity_aliases
    WHERE is_active = true
    ORDER BY length(alias_text) DESC
    """

    return conn.execute(sql).fetchall()


# ============================================================
# MATCH HELPERS
# ============================================================

def normalize(text: str) -> str:

    return text.lower().strip()


def article_contains(article_text: str, entity_name: str) -> bool:

    article = f" {normalize(article_text)} "
    entity = f" {normalize(entity_name)} "

    return entity in article


# ============================================================
# INSERT MAPS
# ============================================================

def insert_article_team_map(conn, article_id, team_id):

    sql = """
    INSERT INTO public.article_team_map
    (
        article_id,
        team_id,
        created_at
    )
    VALUES
    (
        %s,
        %s,
        now()
    )
    ON CONFLICT DO NOTHING
    """

    conn.execute(sql, (article_id, team_id))


def insert_article_player_map(conn, article_id, player_id):

    sql = """
    INSERT INTO public.article_player_map
    (
        article_id,
        player_id,
        created_at
    )
    VALUES
    (
        %s,
        %s,
        now()
    )
    ON CONFLICT DO NOTHING
    """

    conn.execute(sql, (article_id, player_id))


def insert_article_league_map(conn, article_id, league_id):

    sql = """
    INSERT INTO public.article_league_map
    (
        article_id,
        league_id,
        created_at
    )
    VALUES
    (
        %s,
        %s,
        now()
    )
    ON CONFLICT DO NOTHING
    """

    conn.execute(sql, (article_id, league_id))


# ============================================================
# MAIN
# ============================================================

def main():

    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    articles = load_articles(conn)
    aliases = load_aliases(conn)
    
    print("=" * 80)
    print("MATCHMATRIX ARTICLE ENTITY MATCHER V1")
    print("=" * 80)
    print(f"ARTICLES: {len(articles)}")
    print("=" * 80)

    matched_teams = 0
    matched_leagues = 0

    for article in articles:

        article_id = article[0]

        source_name = article[4]

        teams = load_teams(
            conn,
            source_name,
        )

        leagues = load_leagues(
            conn,
            source_name,
        )

        article_text = " ".join([
            article[1],
            article[2],
            article[3],
        ])

        # ----------------------------------------------------
        # TEAM MATCH
        # ----------------------------------------------------
        #
        # DISABLED:
        # canonical team matching vytvářel false positives.
        #
        # Budoucnost:
        # - alias-first matching
        # - NLP matching
        # - embeddings
        #
        # for team in teams:
        #
        #     team_id = team[0]
        #     team_name = team[1]
        #
        #     if article_contains(article_text, team_name):
        #
        #         insert_article_team_map(
        #             conn,
        #             article_id,
        #             team_id,
        #         )
        #
        #         matched_teams += 1
        #
        #         print(f"TEAM MATCH: {team_name}")

        # ----------------------------------------------------
        # ALIAS MATCH
        # ----------------------------------------------------

        for alias in aliases:

            entity_type = alias[0]
            entity_id = alias[1]
            alias_text = alias[2]
            source_scope = alias[3]

            if source_scope:

                if source_scope.upper() != source_name.upper():
                    continue

            if article_contains(article_text, alias_text):

                if entity_type == "league":

                    if entity_id and entity_id > 0:

                        insert_article_league_map(
                            conn,
                            article_id,
                            entity_id,
                        )

                        matched_leagues += 1

                    print(
                        f"ALIAS LEAGUE MATCH: "
                        f"{alias_text} -> league_id={entity_id}"
                    )

                elif entity_type == "team":

                    if entity_id and entity_id > 0:

                        insert_article_team_map(
                            conn,
                            article_id,
                            entity_id,
                        )

                        matched_teams += 1

                    print(
                        f"ALIAS TEAM MATCH: "
                        f"{alias_text} -> team_id={entity_id}"
                    )
                
                elif entity_type == "player":

                    if entity_id and entity_id > 0:

                        insert_article_player_map(
                            conn,
                            article_id,
                            entity_id,
                        )

                    print(
                        f"ALIAS PLAYER MATCH: "
                        f"{alias_text} -> player_id={entity_id}"
                    )

        # ----------------------------------------------------
        # LEAGUE MATCH
        # ----------------------------------------------------
        #
        #for league in leagues:
        #
        #   league_id = league[0]
        #   league_name = league[1]
        #
        #    if article_contains(article_text, league_name):
        #
        #        insert_article_league_map(
        #            conn,
        #            article_id,
        #            league_id,
        #        )
        #
        #        matched_leagues += 1
        #
        #        print(f"LEAGUE MATCH: {league_name}")

    print("\n" + "=" * 80)
    print("DONE")
    print("=" * 80)
    print(f"TEAM MATCHES   : {matched_teams}")
    print(f"LEAGUE MATCHES : {matched_leagues}")
    print("=" * 80)

    conn.close()


if __name__ == "__main__":
    main()