import requests
import json
import csv

with open('csvs/pokemons.csv', 'w',  newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["DexID", "Name", "bst", "type1", "type2"])

    BASE_URL = "https://pokeapi.co/api/v2/"
    POKEDEX = "pokedex/4/"

    res = requests.get(BASE_URL + POKEDEX)
    json_object = res.json()

    pokemonSpecies = json_object["pokemon_entries"]

    pokemonLst = []
    i = 0

    for pokemonS in pokemonSpecies:
        res = requests.get(pokemonS['pokemon_species']['url'])

        pokemons = res.json()['varieties']

        # SPRITES CAN BE GOT
        
        for pokemon in pokemons:
            if not pokemon['is_default']:
                continue

            res = requests.get(pokemon['pokemon']['url'])
            r = res.json()
            stats = r['stats']
            types = r['types']
            name = r['name']

            bst = 0
            for stat in stats:
                bst += int(stat['base_stat'])

            ts = []
            for type in types:
            
                ts.append(type['type']['name'])

            toWrite = [r['id'], r['name'], str(bst)] + ts
            writer.writerow(toWrite)
      

        i += 1
        if i % 10 == 0: print(i)

        if i > 5:
            break
