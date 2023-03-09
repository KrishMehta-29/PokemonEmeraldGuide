# PokemonEmeraldGuide

### Database Setup Instructions
1. `sudo mysql --local-infile=1 -u root -p`
2. `set global local_infile=true;`
3. Create MySQL database to store info in
4. `source setup-db.sql;`
5. `source load-db.sql;`
