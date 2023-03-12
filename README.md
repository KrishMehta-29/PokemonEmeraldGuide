# PokemonEmeraldGuide

### Data Collection
Our data primarily comes from scraping [PokeAPI](https://pokeapi.co/) using custom Python scripts.
We make a lot of API calls to gather all the information neeeded about the Pokemon involved, type matchups,
evolutions, and routes.

### Database Setup Instructions
1. `sudo /etc/init.d/mysql start` then `sudo mysql --local-infile=1 -u root -p` to start MySQL server
2. `set global local_infile=true;`
3. `SET GLOBAL log_bin_trust_function_creators = 1;`
4. Create MySQL database to store info in, e.g. `create database pkmnemeralddb`, `use pkmnemeralddb`
5. `grant-permissions.sql`, then `source setup-passwords.sql`
6. `source setup-db.sql;`
7. `source load-db.sql;`
8. Change database names in `app.py` and `grant-permissions.sql` as necessary (to whatever you named the SQL database)
