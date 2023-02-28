-- This file contains SQL queries/UDFS/procedures/views that will be used in 
-- our guide.
-- These queries will probably be wrapped in Python in some other file,
-- so file is just to design/test them.




-- VERY BASIC QUERIES THAT MAY BE USED IN OTHER QUERIES:

-- all locations before gym X
SELECT *
FROM locations
WHERE available_before_gym <= 5;


-- which pokemon can be caught before gym X (not accounting for evolution)
SELECT DISTINCT dex_no
FROM (
    SELECT 
    FROM locations
    WHERE available_before_gym <= 5
) NATURAL JOIN spawns NATURAL JOIN unlocks
WHERE gym_no <= 5; --idk if this is right, can test when we have actual db



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