-- Loads CSV files into MySQL database tables

-- TODO: player table

set global local_infile=true;

LOAD DATA LOCAL INFILE 'csvs/pokemons.csv' INTO TABLE pokemon
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- TODO: PC table

LOAD DATA LOCAL INFILE 'csvs/gyms.csv' INTO TABLE gym
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'csvs/locations.csv' INTO TABLE locations -- works
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'csvs/spawns.csv' INTO TABLE spawns
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- TODO: fill in missing values in 3rd colmun
LOAD DATA LOCAL INFILE 'csvs/evolution.csv' INTO TABLE evolves
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'csvs/types.csv' INTO TABLE types
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'csvs/unlocks.csv' INTO TABLE unlocks
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

DELETE FROM types WHERE receiver = 'Fairy' OR effective_type = 'Fairy';

CREATE INDEX available_before_gym_idx ON locations (available_before_gym);
