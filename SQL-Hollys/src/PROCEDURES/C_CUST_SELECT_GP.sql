--------------------------------------------------------
--  DDL for Procedure C_CUST_SELECT_GP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_SELECT_GP" 
(
    P_SEARCH      IN  VARCHAR2,
    O_COUNT       OUT NUMBER,
    O_CURSOR      OUT SYS_REFCURSOR
) IS
    SQL_CUST          VARCHAR2(20000);
    SQL_WHERE         VARCHAR2(20000);
 
BEGIN
    DBMS_OUTPUT.PUT_LINE(P_SEARCH);
    SQL_WHERE :=  GET_CUST_WHERE(P_SEARCH);
    SQL_CUST  :=  ' SELECT  COUNT(*)
                    FROM    C_CUST A
                  ' || SQL_WHERE;
    
    EXECUTE IMMEDIATE SQL_CUST INTO O_COUNT;
               
    SQL_CUST  :=  ' SELECT  A.CUST_ID,
                            decrypt(A.CUST_NM) AS CUST_NM,
                            FN_GET_FORMAT_HP_NO(decrypt(A.MOBILE)) AS MOBILE,
                            B.LVL_NM
                    FROM    C_CUST A
                    LEFT OUTER JOIN C_CUST_LVL B
                    ON      A.COMP_CD = B.COMP_CD
                    AND     A.LVL_CD = B.LVL_CD
                  ' || SQL_WHERE ||
                  ' AND     ROWNUM <= 1000';
                  
    DBMS_OUTPUT.PUT_LINE(SQL_CUST);
    OPEN O_CURSOR FOR SQL_CUST; 
    
END C_CUST_SELECT_GP;

/
