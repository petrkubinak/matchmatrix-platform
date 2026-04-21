import json
from pathlib import Path

RAW_FILE = Path(
    r"C:\MatchMatrix-platform\data\raw\api_handball\leagues\latest_api_handball_leagues.json"
)

def main() -> None:
    if not RAW_FILE.exists():
        raise FileNotFoundError(f"Soubor neexistuje: {RAW_FILE}")

    with RAW_FILE.open("r", encoding="utf-8-sig") as f:
        data = json.load(f)

    print("=" * 70)
    print("MATCHMATRIX - INSPECT HB LEAGUES RAW")
    print("=" * 70)
    print(f"Soubor: {RAW_FILE}")
    print(f"Root type: {type(data).__name__}")
    print(f"Root keys: {list(data.keys()) if isinstance(data, dict) else 'N/A'}")

    response = data.get("response", []) if isinstance(data, dict) else []
    print(f"Response count: {len(response)}")
    print("-" * 70)

    if not response:
        print("response je prazdne.")
        return

    first = response[0]
    print("Prvni item - type:", type(first).__name__)

    if isinstance(first, dict):
        print("Prvni item - keys:", list(first.keys()))
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

    print("PRVNI ITEM JSON:")
    print(json.dumps(first, ensure_ascii=False, indent=2)[:12000])
    print("=" * 70)

if __name__ == "__main__":
    main()