-- This file contains SQL queries/UDFS/procedures/views that will be used in 
-- our guide.
-- These queries will probably be wrapped in Python in some other file,
-- so file is just to design/test them.

-- test players
insert into player values(1, 'bob', 1);
insert into player values(2,'bill', 3);

-- give bob some pokemon (treeko, lotad, slakoth)
insert into pc values(1,252,1); 
insert into pc values(1,270,1);
insert into pc values(1,287,1); 


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
    SELECT DISTINCT pkmn_name,bst
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

-- procedure to find all pokemon effective into type
DELIMITER !
CREATE PROCEDURE get_effective_pkmn (t VARCHAR(15))
BEGIN
    SELECT DISTINCT pkmn_name
    FROM pokemon NATURAL JOIN types
    WHERE receiver = t AND 
        (type1 IN 
            (SELECT effective_type FROM types WHERE receiver = t) 
        OR type2 IN 
            (SELECT effective_type FROM types WHERE receiver = t));
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
CREATE PROCEDURE getAvailablePkmn (pid INT)
BEGIN
    DECLARE levelCap INT DEFAULT 0;
    SELECT getLevelCap(pid) INTO levelCap;
    
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
    );
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


