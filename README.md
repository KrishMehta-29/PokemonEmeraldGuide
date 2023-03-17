# PokemonEmeraldGuide

### Data Collection
Our data primarily comes from scraping [PokeAPI](https://pokeapi.co/) using custom Python scripts.
We make a lot of API calls to gather all the information neeeded about the Pokemon involved, type matchups,
evolutions, and routes.

### Database Setup Instructions
1. `sudo /etc/init.d/mysql start` then `sudo mysql --local-infile=1 -u root -p` to start MySQL server
2. `set global local_infile=true;`
3. `SET GLOBAL log_bin_trust_function_creators = 1;`
4. Create MySQL database called final to store info in, e.g. `create database final;`, `use final;`
5. `source grant-permissions.sql;`, then `source setup-passwords.sql;`
6. `source setup-db.sql;`
7. `source load-db.sql;`
8. `source setup-routines.sql`
