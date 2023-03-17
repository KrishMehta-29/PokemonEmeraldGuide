-- This file contains SQL queries/UDFS/procedures/views that will be used in 
-- our guide.
-- These queries will probably be wrapped in Python in some other file,
-- so file is just to design/test them.

-- test players
-- insert into player values(1, 'bob', 1);
-- insert into player values(2,'bill', 3);

-- give bob some pokemon (treeko, lotad, slakoth)
-- insert into pc values(1,252,1); 
-- insert into pc values(1,270,1);
-- insert into pc values(1,287,1); 


-- VERY BASIC QUERIES THAT MAY BE USED IN OTHER QUERIES:

-- all locations before gym X
SELECT *
FROM locations
WHERE available_before_gym <= 5;

-- which pokemon can be caught bY player w/ PLAYER_ID = X (not accounting for evolution)
SELECT DISTINCT pkmn_name
FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
WHERE player_id = 1 AND available_before_gym <= next_gym AND gym_no < next_gym;

-- find types supereffective against given type
SELECT effective_type
FROM types
WHERE receiver = 'Grass';

-- find all pokemon that are effective against a given type
SELECT DISTINCT pkmn_name
FROM pokemon NATURAL JOIN types
WHERE receiver = 'Grass' AND 
    (type1 IN 
        (SELECT effective_type FROM types WHERE receiver = 'Grass') 
    OR type2 IN 
        (SELECT effective_type FROM types WHERE receiver = 'Grass'));

-- Current levelcap
-- find all pokemon that are effective against next gym leader:
SELECT DISTINCT pkmn_name
FROM pokemon NATURAL JOIN types NATURAL JOIN gym 
INNER JOIN player ON player.next_gym = gym.gym_no
WHERE receiver = gym_type AND player.player_id=1 AND
    (type1 IN 
        (SELECT effective_type FROM types WHERE receiver = gym_type) 
    OR type2 IN 
        (SELECT effective_type FROM types WHERE receiver = gym_type));

-- find all pokemon that the player owns that the player should use against next gym
SELECT DISTINCT pkmn_name
FROM pokemon NATURAL JOIN types NATURAL JOIN gym NATURAL JOIN pc
INNER JOIN player ON player.next_gym = gym.gym_no
WHERE receiver = gym_type AND player.player_id=1 AND
    (type1 IN 
        (SELECT effective_type FROM types WHERE receiver = gym_type) 
    OR type2 IN 
        (SELECT effective_type FROM types WHERE receiver = gym_type));

-- find top 6 pokemon that the player owns that the player should use against next gym
SELECT DISTINCT pkmn_name, bst
FROM pokemon NATURAL JOIN types NATURAL JOIN gym NATURAL JOIN pc
INNER JOIN player ON player.next_gym = gym.gym_no
WHERE receiver = gym_type AND player.player_id=1 AND
    (type1 IN 
        (SELECT effective_type FROM types WHERE receiver = gym_type) 
    OR type2 IN 
        (SELECT effective_type FROM types WHERE receiver = gym_type))
ORDER BY bst DESC
LIMIT 6;

-- get team from pc for next gym
DELIMITER !
CREATE PROCEDURE choose_team (pid INT)
BEGIN
    SELECT pkmn_name
    FROM pokemon NATURAL JOIN types NATURAL JOIN gym NATURAL JOIN pc
    INNER JOIN player ON player.next_gym = gym.gym_no
    WHERE receiver = gym_type AND player.player_id=pid AND
        (type1 IN 
            (SELECT effective_type FROM types WHERE receiver = gym_type) 
        OR type2 IN 
            (SELECT effective_type FROM types WHERE receiver = gym_type))
    ORDER BY bst DESC
    LIMIT 6;
END !
DELIMITER ;

-- procedure to update gym number for user
DELIMITER !
CREATE PROCEDURE update_gym (pid INT, gym_no INT)
BEGIN
    UPDATE player SET next_gym = gym_no WHERE player_id = pid;
END !
DELIMITER ;

-- function to get player_id from username (assuming all players have diff usernames)
DELIMITER !
CREATE FUNCTION getPid(un VARCHAR(20)) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE pid INT DEFAULT 0;

    SELECT MAX(player_id) INTO pid 
    FROM player
    WHERE username = un;
        
    RETURN pid;
END !
DELIMITER ;

SELECT MAX(player_id) 
FROM player
WHERE username = 'bob';

-- procedure to add pokemon to player's pc (catching a pokemon)
DELIMITER !
CREATE PROCEDURE add_pkmn_to_pc (pid INT, name VARCHAR(20))
BEGIN
    DECLARE dex INT;

    SELECT dex_no INTO dex
    FROM pokemon
    WHERE pkmn_name = name;

    INSERT INTO pc
        -- pokemon not already in pc; add row
        VALUES (pid, dex, 1)
    ON DUPLICATE KEY UPDATE 
        -- branch already in view; update existing row
        count = count + 1;
END !
DELIMITER ;

-- procedure to create user
DELIMITER !
CREATE PROCEDURE add_user (un VARCHAR(20))
BEGIN
    INSERT INTO player (username, next_gym) VALUES (un, 1);
END !
DELIMITER ;

-- admin procedure to insert pokemon to location
DELIMITER !
CREATE PROCEDURE admin_insert_location (loc INT, dex INT, item VARCHAR(20))
BEGIN
    INSERT INTO spawns VALUES (loc, dex, item);
END !
DELIMITER ;

-- admin procedure to update pokemon to location
DELIMITER !
CREATE PROCEDURE admin_update_location (old_loc INT, old_dex INT, new_loc INT)
BEGIN
    UPDATE spawns SET location_id = new_loc
        WHERE dex_no = dex AND location_id=old_loc;
END !
DELIMITER ;

-- admin procedure to delete pokemon to location
DELIMITER !
CREATE PROCEDURE admin_delete_location (loc INT, dex INT, item VARCHAR(20))
BEGIN
    DELETE FROM spawns WHERE location_id=loc AND dex_no=dex AND method=item;
END !
DELIMITER ;

-- procedure to find all pokemon on a given route
DELIMITER !
CREATE PROCEDURE findAllPokemonOnLocation (name VARCHAR(20))
BEGIN
    DECLARE lid VARCHAR(20);

    SELECT location_id INTO lid
    FROM locations
    WHERE location_name = name;

    SELECT DISTINCT pkmn_name
    FROM (
        SELECT dex_no
        FROM spawns
        WHERE location_id = lid
    ) as nums NATURAL JOIN pokemon;
END !
DELIMITER ;

-- procedure to find all accessible locations
DELIMITER !
CREATE PROCEDURE find_accessible_locations (pid INT)
BEGIN
    DECLARE nextgmy INT;

    SELECT next_gym INTO nextgym
    FROM player
    WHERE player_id = pid;

    SELECT location_name
    FROM locations
    WHERE available_before_gym < nextgmy;
END !
DELIMITER ;


-- procedure to create user
DELIMITER !
CREATE PROCEDURE add_user (un VARCHAR(20))
BEGIN
    INSERT INTO player (username, next_gym) VALUES (un, 1);
END !
DELIMITER ;

-- example trigger to add user to user table after making username/password
DELIMITER !
CREATE TRIGGER trg_user_insert AFTER INSERT
       ON user_info FOR EACH ROW
BEGIN
    CALL add_user(NEW.username);
END !
DELIMITER ;

-- procedure to find all pokemon effective into type
DELIMITER !
CREATE PROCEDURE get_effective_pkmn (pid INT)
BEGIN
    SELECT DISTINCT dex_no
    FROM pokemon NATURAL JOIN types NATURAL JOIN gym 
    INNER JOIN player ON player.next_gym = gym.gym_no
    WHERE receiver = gym_type AND player.player_id=pid AND
        (type1 IN 
            (SELECT effective_type FROM types WHERE receiver = gym_type) 
        OR type2 IN 
            (SELECT effective_type FROM types WHERE receiver = gym_type));
END !
DELIMITER ;

DELIMITER !
CREATE FUNCTION getLevelCap (player_id_inp INT) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE levelCap INT DEFAULT 0;

    SELECT SUM(gym_level_cap) INTO levelCap 
    FROM player INNER JOIN gym ON player.next_gym = gym.gym_no 
    WHERE player_id = player_id_inp;
        
    RETURN levelCap;
END !
DELIMITER ;

DELIMITER !
CREATE PROCEDURE getBestPokemon (pid INT)
BEGIN   
    DECLARE levelCap INT DEFAULT 0;
    SELECT getLevelCap(pid) INTO levelCap;

    SELECT * 
    FROM (
        (
            SELECT DISTINCT dex_no
            FROM pokemon NATURAL JOIN types NATURAL JOIN gym 
            INNER JOIN player ON player.next_gym = gym.gym_no
            WHERE receiver = gym_type AND player.player_id=pid AND
                (type1 IN 
                    (SELECT effective_type FROM types WHERE receiver = gym_type) 
                OR type2 IN 
                    (SELECT effective_type FROM types WHERE receiver = gym_type))
        ) INTERSECT (
            (
                SELECT goes_to_dex_no as dex_no 
                FROM evolves NATURAL JOIN (
                    SELECT goes_to_dex_no as dex_no
                    FROM evolves NATURAL JOIN (
                        SELECT DISTINCT dex_no
                        FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
                        WHERE player_id = pid AND available_before_gym <= next_gym AND gym_no < next_gym
                    ) as pkmn_available
                    WHERE evolves.evolve_level < levelCap) as pkmn_found
                WHERE evolves.evolve_level < levelCap
            ) UNION (
                SELECT goes_to_dex_no as dex_no
                FROM evolves NATURAL JOIN (
                    SELECT DISTINCT dex_no
                    FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
                    WHERE player_id = pid AND available_before_gym <= next_gym AND gym_no < next_gym
                ) as pkmn_available
                WHERE evolves.evolve_level < levelCap
            ) UNION (
                SELECT DISTINCT dex_no
                FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
                WHERE player_id = pid AND available_before_gym <= next_gym AND gym_no < next_gym 
            )
        )
    ) as result NATURAL JOIN pokemon;
END !
DELIMITER ;


-- gets available pokemon to catch
DELIMITER !
CREATE PROCEDURE getAvailablePkmn (pid INT)
BEGIN
    DECLARE levelCap INT DEFAULT 0;
    SELECT getLevelCap(pid) INTO levelCap;
    
    SELECT pkmn_name 
    FROM pokemon NATURAL JOIN (
    (
        SELECT goes_to_dex_no as dex_no 
        FROM evolves NATURAL JOIN (
            SELECT goes_to_dex_no as dex_no
            FROM evolves NATURAL JOIN (
                SELECT DISTINCT dex_no
                FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
                WHERE player_id = pid AND available_before_gym <= next_gym AND gym_no < next_gym
            ) as pkmn_available
            WHERE evolves.evolve_level < levelCap) as pkmn_found
        WHERE evolves.evolve_level < levelCap
    ) UNION (
        SELECT goes_to_dex_no as dex_no
        FROM evolves NATURAL JOIN (
            SELECT DISTINCT dex_no
            FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
            WHERE player_id = pid AND available_before_gym <= next_gym AND gym_no < next_gym
        ) as pkmn_available
        WHERE evolves.evolve_level < levelCap
    ) UNION (
        SELECT DISTINCT dex_no
        FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
        WHERE player_id = pid AND available_before_gym <= next_gym AND gym_no < next_gym 
    )) as t;
END !
DELIMITER ;

-- which pokemon can be caught bY player w/ PLAYER_ID = X (accounting for evolution)
SELECT *
FROM pokemon NATURAL JOIN 
    ((
        SELECT goes_to_dex_no as dex_no 
        FROM evolves NATURAL JOIN (
            SELECT goes_to_dex_no as dex_no
            FROM evolves NATURAL JOIN (
                SELECT DISTINCT dex_no
                FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
                WHERE player_id = 1 AND available_before_gym <= next_gym AND gym_no < next_gym
            ) as pkmn_available
            WHERE evolves.evolve_level < 15) as pkmn_found
        WHERE evolves.evolve_level < 15
    ) UNION (
        SELECT goes_to_dex_no as dex_no
        FROM evolves NATURAL JOIN (
            SELECT DISTINCT dex_no
            FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
            WHERE player_id = 1 AND available_before_gym <= next_gym AND gym_no < next_gym
        ) as pkmn_available
        WHERE evolves.evolve_level < 15
    ) UNION (
        SELECT DISTINCT dex_no
        FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
        WHERE player_id = 1 AND available_before_gym <= next_gym AND gym_no < next_gym 
    )) as pokemonAvailable 

-- supereffective types on gym (idk if this is the best way to do this????)
DELIMITER !
CREATE FUNCTION is_supereffective (receiver_t VARCHAR, attacker_t VARCHAR) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE t1 VARCHAR(9);
    DECLARE t2 VARCHAR(9);
    DECLARE cur CURSOR FOR types;
    DECLARE super INT DEFAULT 0;
    -- When fetch is complete, handler sets flag
    -- 02000 is MySQL error for "zero rows fetched"
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
    SET done = 1;
    OPEN cur;
    WHILE NOT done DO
        FETCH cur INTO t1, t2;
        IF NOT done THEN
            IF t1 = receiver_t AND t2 = attacker_t THEN
                SET super = 1;
            END IF;
        END IF;
    END WHILE;
    CLOSE cur;
    RETURN super;
END !
DELIMITER ;


