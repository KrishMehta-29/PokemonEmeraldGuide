import requests
import json

BASE_URL = "https://pokeapi.co/api/v2/"
POKEDEX = "pokedex/4/"

res = requests.get(BASE_URL + POKEDEX)
json_object = res.json()

pokemonSpecies = json_object["pokemon_entries"]

pokemonLst = []

for pokemonS in pokemonSpecies:
    res = requests.get(pokemonS['pokemon_species']['url'])

    pokemons = res.json()['varieties']

    # SPRITES CAN BE GOT
    
    for pokemon in pokemons:
        res = requests.get(pokemon['pokemon']['url'])
        print(json.dumps(res.json(), indent=2))
    
    break
