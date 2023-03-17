-- procedures and UDFs used by our app

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

-- procedure to get player_id from username (assuming all players have diff usernames)
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
    DECLARE nextgym INT;

    SELECT next_gym INTO nextgym
    FROM player
    WHERE player_id = pid;

    SELECT location_name
    FROM locations
    WHERE available_before_gym < nextgmy;
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