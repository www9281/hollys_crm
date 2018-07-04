--------------------------------------------------------
--  DDL for Function GET_PART_KEY_9I
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_PART_KEY_9I" 
  ( V_OWNER VARCHAR2, V_NAME VARCHAR2, V_PART_TYPE VARCHAR2, V_KEY_COUNT NUMBER)
RETURN VARCHAR2 IS
     KEY_STRING   VARCHAR2(4000) := '';
  BEGIN

 FOR CUR_SQL IN (SELECT COLUMN_NAME, COLUMN_POSITION
	               FROM   SYS.ALL_PART_KEY_COLUMNS X 
	               WHERE  X.OWNER = UPPER(V_OWNER)
                 AND    X.NAME  = UPPER(V_NAME)
                 ORDER BY COLUMN_POSITION
	              ) LOOP

    IF (CUR_SQL.COLUMN_POSITION = 1) 
    THEN  KEY_STRING   := 'PARTITION BY '||V_PART_TYPE||' (';
    END IF;

    KEY_STRING   := KEY_STRING||CUR_SQL.COLUMN_NAME;

    IF (V_KEY_COUNT = CUR_SQL.COLUMN_POSITION) 
    THEN  KEY_STRING   := KEY_STRING||')';
    ELSE  KEY_STRING   := KEY_STRING||',';
    END IF;  

 END LOOP;   

 RETURN KEY_STRING;
END;

/