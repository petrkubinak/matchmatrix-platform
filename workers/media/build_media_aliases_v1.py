# ============================================================
# build_media_aliases_v1.py
# MATCHMATRIX MEDIA ALIAS BUILDER V1
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
# HELPERS
# ============================================================

STOPWORDS = {
    "FC",
    "CF",
    "SC",
    "AC",
    "BK",
    "HC",
    "BC",
}


def create_team_aliases(conn):

    sql = """
    SELECT
        id,
        name
    FROM public.teams
    WHERE name IS NOT NULL
    """

    rows = conn.execute(sql).fetchall()

    inserted = 0

    for row in rows:

        team_id = row[0]
        team_name = row[1].strip()

        parts = team_name.split()

        if len(parts) < 2:
            continue

        alias = parts[-1]

        if alias.upper() in STOPWORDS:
            continue

        if len(alias) < 4:
            continue

        insert_sql = """
        INSERT INTO public.media_entity_aliases
        (
            entity_type,
            entity_id,
            alias_text,
            is_active,
            created_at
        )
        VALUES
        (
            'team',
            %s,
            %s,
            true,
            now()
        )
        ON CONFLICT DO NOTHING
        """

        conn.execute(
            insert_sql,
            (
                team_id,
                alias,
            )
        )

        inserted += 1

    return inserted


def create_player_aliases(conn):

    sql = """
    SELECT
        id,
        name
    FROM public.players
    WHERE name IS NOT NULL
    """

    rows = conn.execute(sql).fetchall()

    inserted = 0

    for row in rows:

        player_id = row[0]
        player_name = row[1].strip()

        parts = player_name.split()

        if len(parts) < 2:
            continue

        alias = parts[-1]

        if len(alias) < 4:
            continue

        insert_sql = """
        INSERT INTO public.media_entity_aliases
        (
            entity_type,
            entity_id,
            alias_text,
            is_active,
            created_at
        )
        VALUES
        (
            'player',
            %s,
            %s,
            true,
            now()
        )
        ON CONFLICT DO NOTHING
        """

        conn.execute(
            insert_sql,
            (
                player_id,
                alias,
            )
        )

        inserted += 1

    return inserted


# ============================================================
# MAIN
# ============================================================

def main():

    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    print("=" * 80)
    print("MATCHMATRIX MEDIA ALIAS BUILDER V1")
    print("=" * 80)

    teams = create_team_aliases(conn)
    print(f"TEAM ALIASES INSERTED: {teams}")

    players = create_player_aliases(conn)
    print(f"PLAYER ALIASES INSERTED: {players}")

    print("\n" + "=" * 80)
    print("DONE")
    print("=" * 80)

    conn.close()


if __name__ == "__main__":
    main()