--------------------------------------------------------
--  DDL for Function GET_IOT_KEY_9I
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_IOT_KEY_9I" 
  ( V_OWNER VARCHAR2, V_NAME VARCHAR2)
RETURN VARCHAR2 IS
     KEY_STRING   VARCHAR2(4000) := '';
  BEGIN

 FOR CUR_SQL IN ( SELECT  X.COLUMN_NAME,
                          X.COLUMN_POSITION,
                          MAX(COLUMN_POSITION) OVER (PARTITION BY X.INDEX_NAME) MAX_COLUMN_POSITION
                  FROM    SYS.ALL_IND_COLUMNS X
                  WHERE   X.INDEX_OWNER = UPPER(V_OWNER)
                  AND     X.INDEX_NAME  = UPPER(V_NAME)
	              ) LOOP

    IF (CUR_SQL.COLUMN_POSITION = 1) 
    THEN  KEY_STRING   := KEY_STRING||' PRIMARY KEY (';
    END IF;

    KEY_STRING   := KEY_STRING||CUR_SQL.COLUMN_NAME;

    IF (CUR_SQL.MAX_COLUMN_POSITION = CUR_SQL.COLUMN_POSITION) 
    THEN  KEY_STRING   := KEY_STRING||')';
    ELSE  KEY_STRING   := KEY_STRING||',';
    END IF;  

 END LOOP;   

 RETURN KEY_STRING;
END;

/
