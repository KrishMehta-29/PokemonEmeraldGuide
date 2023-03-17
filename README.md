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

### Usage Example
1. Let's say you want to run as a user, go to `client-app.py` and run this Python file
2. Now, we need to create an account. Type in `create user1 password1`. This is your username and password.
3. Now that we have an account, let's pretend we're playing Pokemon Emerald and we picked Mudkip as our starter,
so let's run `catch mudkip`.
4. Now if we run `show box`, it shows the Mudkip!
5. Now let's plan a team for taking on the first gym. Run `find best pokemon` to show a list of available pokemon
that are good for the first gym.
6. Let's say in our game we caught a Shroomish. So let's run `catch shroomish`.
7. Now let's say we beat the first Gym Leader in our Pokemon Emerald game. Run `update gym 2`.
8. Now the list of available locations and thus pokemon should have updated. Run 
`accessible locations` and `accessible pokemons` to see the lists.
9. Now continue to play the game and use our app to help guide you!
