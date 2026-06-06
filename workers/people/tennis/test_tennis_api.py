import http.client

conn = http.client.HTTPSConnection("tennis-api-atp-wta-itf.p.rapidapi.com")

headers = {
    "x-rapidapi-key": "TVUJ_KLIC",
    "x-rapidapi-host": "tennis-api-atp-wta-itf.p.rapidapi.com"
}

conn.request(
    "GET",
    "/tennis/v2/atp/player/",
    headers=headers
)

res = conn.getresponse()

print("STATUS:", res.status)
print("REASON:", res.reason)

data = res.read()

print(data.decode("utf-8")[:5000])