import requests
import json
import csv

# Stones: Water, Leaf, Moon, Sun, Fire, Thunder 

def findLink(evolvesFrom, pokemonLst):
    fromName = evolvesFrom['species']['name']

    if not 'evolves_to' in evolvesFrom:
        return None
    
    future = []

    for evolveTo in evolvesFrom['evolves_to']:
        if evolveTo['species']['name'] not in pokemonLst:
            continue

        if fromName not in pokemonLst:
            continue
        
        details = evolveTo['evolution_details'][0]
        if details['trigger']['name'] == "level-up":
            future.append(((fromName, evolveTo['species']['name']), evolveTo, details['min_level']))

        elif details['trigger']['name'] == "use-item":
            future.append(((fromName, evolveTo['species']['name']), evolveTo, details['item']['name']))

        elif details['trigger']['name'] == "trade":
            future.append(((fromName, evolveTo['species']['name']), evolveTo, str(1)))

        else:
            # Shed
            future.append(((fromName, evolveTo['species']['name']), evolveTo, str(1)))

            
    return future

with open('csvs/pokemons.csv', 'w',  newline='') as file:
    with open('csvs/evolution.csv', 'w', newline='') as evolve:

        writer = csv.writer(file)
        writer.writerow(["DexID", "Name", "bst", "type1", "type2"])

        evolveWriter = csv.writer(evolve)
        evolveWriter.writerow(["fromDexID, toDexID, method"])

        BASE_URL = "https://pokeapi.co/api/v2/"
        POKEDEX = "pokedex/4/"

        res = requests.get(BASE_URL + POKEDEX)
        json_object = res.json()

        pokemonSpecies = json_object["pokemon_entries"]
        echains = []

        pokemonLst = []
        pokemonMap = {}
        i = 0

        for pokemonS in pokemonSpecies:
            res = requests.get(pokemonS['pokemon_species']['url'])
            pokemonLst.append(pokemonS['pokemon_species']['name'])

            pokemons = res.json()['varieties']
            echain = res.json()['evolution_chain']['url']

            if echain not in echains:
                echains.append(echain)

            # SPRITES CAN BE GOT
            
            for pokemon in pokemons:
                if not pokemon['is_default']:
                    continue

                res = requests.get(pokemon['pokemon']['url'])
                r = res.json()
                stats = r['stats']
                types = r['types']
                name = r['name']            

                pokemonMap[r['name']] = r['id']    

                bst = 0
                for stat in stats:
                    bst += int(stat['base_stat'])

                ts = []
                for type in types:
                    ts.append(type['type']['name'])

                toWrite = [r['id'], r['name'], str(bst)] + ts
                writer.writerow(toWrite)
        

            i += 1
            if i % 20 == 0: print(i)

            if i > 1000:
                break

        allRelations = []

        for echain in echains:
            res = requests.get(echain)
            r = res.json()['chain']

            relations = []

            futuresToCheck = [r]

            while len(futuresToCheck) > 0:
                ra = futuresToCheck.pop(0)
                future = findLink(ra, pokemonLst)

                if future is None:
                    break 

                for f in future:
                    link, next, method = f
                    futuresToCheck.append(next)
                    relations.append((link, method))

            allRelations = allRelations + relations

        for relation in allRelations:
            (f, t), method = relation
            evolveWriter.writerow([pokemonMap[f], pokemonMap[t], method])
            # evolveWriter.writerow([f, t, method])




    

