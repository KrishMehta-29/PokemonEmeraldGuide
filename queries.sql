-- This file contains SQL queries/UDFS/procedures/views that will be used in 
-- our guide.
-- These queries will probably be wrapped in Python in some other file,
-- so file is just to design/test them.

-- test players
insert into player values(1, 'bob', 1);
insert into player values(2,'bill', 3);

-- VERY BASIC QUERIES THAT MAY BE USED IN OTHER QUERIES:

-- all locations before gym X
SELECT *
FROM locations
WHERE available_before_gym <= 5;


-- which pokemon can be caught bY player w/ PLAYER_ID = X (not accounting for evolution)
SELECT DISTINCT pkmn_name
FROM locations NATURAL JOIN spawns NATURAL JOIN unlocks NATURAL JOIN player NATURAL JOIN pokemon
WHERE player_id = 1 AND available_before_gym <= next_gym AND gym_no < next_gym;



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