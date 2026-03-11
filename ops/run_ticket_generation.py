import os
import sys
import psycopg2

from lib.job_logger import logged_job


def main():
    if len(sys.argv) < 3:
        raise RuntimeError("Použití: python run_ticket_generation.py <template_id> <bookmaker_id>")

    template_id = int(sys.argv[1])
    bookmaker_id = int(sys.argv[2])

    dsn = os.environ.get("DB_DSN")
    if not dsn:
        raise RuntimeError("Chybí DB_DSN")

    with logged_job("ticket_generation", params={"template_id": template_id, "bookmaker_id": bookmaker_id}):
        with psycopg2.connect(dsn) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT estimated_tickets, preview_warnings
                    FROM public.mm_preview_run(%s, %s)
                    """,
                    (template_id, bookmaker_id),
                )
                row = cur.fetchone()
                if not row:
                    raise RuntimeError("mm_preview_run nevrátil žádný výsledek.")

                estimated_tickets, preview_warnings = row
                preview_warnings = preview_warnings or []

                blocking = [w for w in preview_warnings if "Chybí odds" in w or "0 validních" in w]
                if blocking:
                    raise RuntimeError(f"Ticket generation blocked: {' | '.join(blocking)}")

                cur.execute(
                    """
                    SELECT public.mm_generate_run_engine(%s, %s, NULL, NULL, 200000)
                    """,
                    (template_id, bookmaker_id),
                )
                run_id = cur.fetchone()[0]

            conn.commit()

    print("Generated run_id:", run_id)


if __name__ == "__main__":
    main()