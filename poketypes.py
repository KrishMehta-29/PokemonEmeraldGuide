import requests
import csv

BASE_URL = "https://pokeapi.co/api/v2/type/"

with open('csvs/types.csv', 'w') as file:
    writer = csv.writer(file)
    writer.writerow(["Receiver Type", "Super Effective Type"])

    for i in range(1, 19):
        url = BASE_URL + str(i)
        response = requests.get(url)
        response = response.json()

        base = response["name"]
        effective_against = response["damage_relations"]["double_damage_to"]
        for j in effective_against:
            writer.writerow([j["name"], base])
