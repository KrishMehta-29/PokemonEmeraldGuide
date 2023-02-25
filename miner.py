import requests
from bs4 import BeautifulSoup

BASE_URL = "https://pokemondb.net/location/#tab=loc-hoenn"
URL = "https://pokemondb.net/"

res = requests.get(BASE_URL)
locations = []

soup = BeautifulSoup(res.content, "html.parser")
anchors = soup.find_all('a', href=True)

for a in anchors:
    if "location/hoenn" in a['href']:
        locations.append(a['href'])
 
for location in locations:
    res = requests.get(URL + location)
    soup = BeautifulSoup(res.content, "html.parser")
    print(soup.prettify())

    break