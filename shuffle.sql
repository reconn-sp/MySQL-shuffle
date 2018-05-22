
-- EXAMPLE table

-- make a copy of data for cursors
DROP TABLE IF EXISTS EXAMPLE_COPY;
CREATE TABLE EXAMPLE_COPY(
  ID BIGINT(20) PRIMARY KEY AUTO_INCREMENT,
  IDS BIGINT(20),
  BIRTHDAY DATE,
  PHONE VARCHAR(40),
  EMAIL VARCHAR(40),
  SSN VARCHAR(40)
);
-- add index to improve performance
CREATE INDEX EXAMPLE_IDS_INDEX ON EXAMPLE_COPY (IDS);
-- insert data from original table
INSERT INTO EXAMPLE_COPY (IDS, BIRTHDAY, PHONE, EMAIL, SSN) SELECT ID, BIRTHDAY, PHONE, EMAIL, SSN FROM EXAMPLE;
-- create procedure for copying
DROP PROCEDURE IF EXISTS EXAMPLE_SHUFFLE;
DELIMITER ;;
CREATE PROCEDURE EXAMPLE_SHUFFLE()
  BEGIN
    -- iteration variables
    DECLARE pointer BIGINT DEFAULT 0;
    DECLARE elements_num BIGINT DEFAULT (SELECT COUNT(*) FROM EXAMPLE_COPY);
    -- variables for cursors
    DECLARE cid BIGINT DEFAULT 0;
    DECLARE b DATE;
    DECLARE p VARCHAR(40);
    DECLARE e VARCHAR(40);
    DECLARE s VARCHAR(60);
    -- create cursors for existing data with random ordering (separately for independent shuffling
    DECLARE ids CURSOR FOR (SELECT IDS FROM EXAMPLE_COPY ORDER BY ID ASC);
    DECLARE births CURSOR FOR (SELECT BIRTHDAY FROM EXAMPLE_COPY ORDER BY RAND());
    DECLARE phones CURSOR FOR (SELECT PHONE FROM EXAMPLE_COPY ORDER BY RAND());
    DECLARE emails CURSOR FOR (SELECT EMAIL FROM EXAMPLE_COPY ORDER BY RAND());
    DECLARE ssns CURSOR FOR (SELECT SSN FROM EXAMPLE_COPY ORDER BY RAND());
    -- open cursors
    OPEN ids;
    OPEN births;
    OPEN phones;
    OPEN emails;
    OPEN ssns;

    -- iterate for each record
    WHILE pointer < elements_num DO
      FETCH ids INTO cid;
      FETCH births INTO b;
      FETCH phones INTO p;
      FETCH emails INTO e;
      FETCH ssns INTO s;
      -- update each row
      UPDATE EXAMPLE C SET C.BIRTHDAY = b, C.PHONE = p, C.EMAIL = e, C.SSN = s WHERE C.ID = cid;
      SET pointer = pointer + 1;
    END WHILE;
    END;
;;
DELIMITER ;
-- call new procedure
CALL EXAMPLE_SHUFFLE();
-- remove copy of data and procedure
DROP TABLE IF EXISTS EXAMPLE_COPY;
DROP PROCEDURE IF EXISTS EXAMPLE_SHUFFLE;