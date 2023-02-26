import requests
import csv

BASE_URL = "https://pokeapi.co/api/v2/pokemon/"

spawns = []
locations = []

last_routes = ["Rusturf Tunnel","Granite Cave Stephen’s Room","Rt 110","Jagged Pass","Rt 115","Rt 120","Mossdeep City","Sky Pillar F5","Victory Road BF2"]

route = ""
encounter_type = "normal"
location_id = 0
cur_gym = 1
# (pokemon, route, encounter_type)
with open('locations.txt') as f:
    for line in f:
        # skip empty lines
        if line != '\n':
            # new route
            if line[0] != " ":
                route = line.strip()
                encounter_type = "normal"
                locations.append((location_id, route, cur_gym))

                if route in last_routes:
                    cur_gym += 1
                location_id += 1
            # special encounter types
            elif "surf" in line:
                encounter_type = "surf"
            elif "Old Rod" in line:
                encounter_type = "old rod"
            elif "Good Rod" in line:
                encounter_type = "good rod"
            elif "Super Rod" in line:
                encounter_type = "super rod"
            elif "underwater" in line:
                encounter_type = "underwater"
            elif "waterfall" in line:
                encounter_type = "waterfall"
            elif "go-goggles" in line:
                encounter_type = "go-goggles"
            # pokemon
            elif line.startswith("     "):
                pokemon = line.split()[0].lower()
                url = BASE_URL + pokemon
                response = requests.get(url)
                response = response.json()
                dex = response["id"]
                spawns.append((location_id, dex, encounter_type))

# Write to csv
with open('csvs/locations.csv', 'w') as file:
    writer = csv.writer(file)
    writer.writerow(["location_id", "location_name", "available_before"])

    for l in locations:
        writer.writerow([l[0],l[1],l[2]])

with open('csvs/spawns.csv', 'w') as file:
    writer = csv.writer(file)
    writer.writerow(["location_id", "dex_no", "item"])

    for l in spawns:
        writer.writerow([l[0],l[1],l[2]])