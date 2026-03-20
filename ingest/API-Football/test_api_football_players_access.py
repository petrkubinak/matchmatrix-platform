import os
import requests

API_KEY = os.getenv("API_FOOTBALL_KEY", "").strip()

if not API_KEY:
    raise SystemExit("Chybí API_FOOTBALL_KEY.")

url = "https://v3.football.api-sports.io/players"
headers = {
    "x-apisports-key": API_KEY,
    "Accept": "application/json",
}
params = {
    "league": "95",
    "season": "2024",
    "page": "1",
}

resp = requests.get(url, headers=headers, params=params, timeout=60)

print("STATUS:", resp.status_code)
print("URL   :", resp.url)
print("HEADERS SENT:", {k: ("***" if "key" in k.lower() else v) for k, v in headers.items()})

print("\nRESPONSE TEXT:")
print(resp.text[:4000])