--------------------------------------------------------
--  DDL for Function GET_PART_HIGH_VALUE_9I
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_PART_HIGH_VALUE_9I" 
  ( V_OWNER VARCHAR2, V_NAME VARCHAR2, V_PNAME VARCHAR2, V_PART_TYPE VARCHAR2 )
RETURN VARCHAR2 IS
     LONG_CHAR    VARCHAR2(4000);
  BEGIN

    SELECT HIGH_VALUE
    INTO   LONG_CHAR
    FROM   SYS.ALL_TAB_PARTITIONS
    WHERE  TABLE_OWNER    = UPPER(V_OWNER)
    AND    TABLE_NAME     = UPPER(V_NAME) 
    AND    PARTITION_NAME = UPPER(V_PNAME);

    SELECT DECODE(V_PART_TYPE,'LIST',' VALUES ('||LONG_CHAR||')',
                  'RANGE',' VALUES LESS THAN (' ||LONG_CHAR||')')
    INTO   LONG_CHAR
    FROM   DUAL;

     RETURN LONG_CHAR ;
END;

/
