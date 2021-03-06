--------------------------------------------------------
--  DDL for Function GET_AGE_GROUP
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_AGE_GROUP" 
(
     A_AGE      NUMBER
) RETURN          VARCHAR2 DETERMINISTIC
IS
    L_RET_VALUE     VARCHAR2(10) := '00';
BEGIN

    SELECT  CODE_CD INTO L_RET_VALUE
    FROM    COMMON COM                   
    WHERE   A_AGE BETWEEN COM.VAL_N1 AND COM.VAL_N2 
    AND     COM.CODE_TP = '01760'     
    AND     COM.USE_YN  = 'Y'
    AND     ROWNUM      = 1;
 
    RETURN L_RET_VALUE;

END GET_AGE_GROUP;

/
