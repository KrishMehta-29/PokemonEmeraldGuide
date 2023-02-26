-- clean up old tables
DROP TABLE IF EXISTS unlocks;
DROP TABLE IF EXISTS types;
DROP TABLE IF EXISTS evolves;
DROP TABLE IF EXISTS spawns;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS gyms;
DROP TABLE IF EXISTS pc;
DROP TABLE IF EXISTS pokemon;
DROP TABLE IF EXISTS player;


-- TODO: FOREIGN KEY STUFF


-- represents a user of our guide, stores user-specific information like
-- how far they have progressed and what they've unlocked
CREATE TABLE player (
    player_id INT PRIMARY KEY,
    player_name VARCHAR(30) NOT NULL,
    badges INT NOT NULL
);

-- represents a pokemon in the game
CREATE TABLE pokemon (
    dex_no INT PRIMARY KEY,
    pkmn_name VARCHAR(15) NOT NULL,
    bst INT NOT NULL,
    type1 VARCHAR(9) NOT NULL,
    type2 VARCHAR(9)
);

-- represents all the pokeon a player has caught
CREATE TABLE pc (
    player_id INT,
    dex_no INT,
    count INT NOT NULL,
    PRIMARY KEY (player_id, dex_no),
    FOREIGN KEY (player_id) REFERENCES player(player_id),
    FOREIGN KEY (dex_no) REFERENCES pokemon(dex_no)
);

-- represents all gym battles in the game
CREATE TABLE gym (
    gym_no INT PRIMARY KEY,
    gym_leader VARCHAR(15) NOT NULL,
    gym_type VARCHAR(9) NOT NULL,
    gym_level_cap INT NOT NULL
);

-- represents all locations in the game
CREATE TABLE location (
    location_id INT PRIMARY KEY,
    location_name VARCHAR(30) NOT NULL,
    available_before_gym INT NOT NULL
);

-- represents all pokemon spawns in a location
CREATE TABLE spawns (
    location_id INT,
    dex_no INT,
    method VARCHAR(10) NOT NULL,
    PRIMARY KEY (location_id, dex_no),
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    FOREIGN KEY (dex_no) REFERENCES pokemon(dex_no)
);

-- represents all pokemon evolutions in the game
CREATE TABLE evolves (
    dex_no INT,
    goes_to_dex_no INT,
    evolve_level INT NOT NULL,
    PRIMARY KEY (dex_no, goes_to_dex_no),
    FOREIGN KEY (dex_no) REFERENCES pokemon(dex_no)
);

-- represents which types are good into others
CREATE TABLE types (
    receiver VARCHAR(9),
    effective_type VARCHAR(9),
    PRIMARY KEY (receiver, effective_type)
);

-- represents what items/method beating a gym will unlock
CREATE TABLE unlocks (
    gym_no INT,
    method VARCHAR(10),
    PRIMARY KEY (gym_no, method),
    FOREIGN KEY (gym_no) REFERENCES gym(gym_no),
);