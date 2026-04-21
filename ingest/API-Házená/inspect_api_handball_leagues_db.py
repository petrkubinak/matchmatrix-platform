import json
import psycopg2

DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"

def main():
    print("=" * 70)
    print("MATCHMATRIX - INSPECT HB LEAGUES (DB RAW)")
    print("=" * 70)

    print("USING DSN:", DB_DSN) 

    conn = psycopg2.connect(DB_DSN)
    cur = conn.cursor()

    cur.execute("""
        select
            id,
            provider,
            sport_code,
            payload_json
        from staging.stg_api_payloads
        where provider = 'api_handball'
          and entity_type = 'leagues'
        order by id desc
        limit 1
    """)

    row = cur.fetchone()

    if not row:
        print("❌ Žádný payload nenalezen.")
        return

    payload_id, provider, sport_code, payload_json = row

    print(f"Payload ID: {payload_id}")
    print(f"Provider  : {provider}")
    print(f"Sport     : {sport_code}")
    print("-" * 70)

    if isinstance(payload_json, str):
        data = json.loads(payload_json)
    else:
        data = payload_json

    print("Root type:", type(data).__name__)
    print("Root keys:", list(data.keys()) if isinstance(data, dict) else "N/A")

    response = data.get("response", [])
    print("Response count:", len(response))
    print("-" * 70)

    if not response:
        print("❌ response je prázdné")
        return

    first = response[0]

    print("FIRST ITEM TYPE:", type(first).__name__)

    if isinstance(first, dict):
        print("FIRST ITEM KEYS:", list(first.keys()))
        print("-" * 70)

        for key, value in first.items():
            print(f"KEY: {key}")
            print(f"TYPE: {type(value).__name__}")

            if isinstance(value, dict):
                print("SUBKEYS:", list(value.keys()))
            elif isinstance(value, list):
                print("LIST COUNT:", len(value))
                if value:
                    sample = value[0]
                    print("FIRST ITEM TYPE:", type(sample).__name__)
                    if isinstance(sample, dict):
                        print("FIRST ITEM KEYS:", list(sample.keys()))
            else:
                print("VALUE:", value)

            print("-" * 70)

    print("FIRST ITEM JSON:")
    print(json.dumps(first, ensure_ascii=False, indent=2)[:10000])

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()