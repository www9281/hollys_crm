--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_ANALYZE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_ANALYZE" (
    P_COMP_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_CUST_LVL     IN  VARCHAR2,
    N_CUST_AGE     IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_MY_USER_ID   IN  VARCHAR2,
    N_YYMM_DIV     IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    v_query VARCHAR2(30000);
         
    V_START_DT   VARCHAR2(8);
    V_END_DT     VARCHAR2(8);
    
BEGIN

    V_START_DT := SUBSTR(P_START_DT,0,6);
    V_END_DT   := SUBSTR(P_END_DT ,0,6);    

    IF N_YYMM_DIV = 'Q' THEN 
        IF    INSTR(P_END_DT,'0199') > 0  THEN
            V_END_DT := SUBSTR(P_END_DT,0,4)||'03' ;
        ELSIF INSTR(P_END_DT,'0499') > 0  THEN 
            V_END_DT := SUBSTR(P_END_DT,0,4)||'06' ;
        ELSIF INSTR(P_END_DT,'0799') > 0  THEN
            V_END_DT := SUBSTR(P_END_DT,0,4)||'07' ;
        ELSIF INSTR(P_END_DT,'1099') > 0  THEN
            V_END_DT := SUBSTR(P_END_DT,0,4)||'12' ;
        END IF;
    ELSE
        V_START_DT := SUBSTR(P_START_DT,0,6);
        V_END_DT   := SUBSTR(P_END_DT ,0,6);
    END IF;
    

    v_query := '
      SELECT  TOT.COMP_CD
            , TOT.BRAND_CD
            , TOT.STOR_CD
            , (SELECT STOR_NM FROM STORE WHERE COMP_CD = TOT.COMP_CD AND STOR_CD = TOT.STOR_CD AND ROWNUM = 1) AS STOR_NM
            , TOT.SALE_DT
            , TOT.CUST_ID
            , (SELECT decrypt(CUST_NM) FROM C_CUST WHERE COMP_CD = TOT.COMP_CD AND CUST_ID = TOT.CUST_ID) AS CUST_NM
            , (SELECT GET_COMMON_CODE_NM(''01720'', CUST_STAT, ''KOR'') FROM C_CUST WHERE COMP_CD = TOT.COMP_CD AND CUST_ID = TOT.CUST_ID) AS CUST_STAT
            , (SELECT GET_COMMON_CODE_NM(''01760'', GET_AGE_GROUP(TOT.CUST_AGE), ''KOR'') FROM DUAL) AS AGE_GROUP
            , (SELECT LVL_NM FROM C_CUST_LVL WHERE LVL_CD = TOT.CUST_LVL) AS CUST_LVL
            , (SELECT DECODE(TOT.CUST_SEX, ''M'', ''남자'', ''F'', ''여자'') FROM DUAL) AS CUST_SEX
            , TOT.ITEM_CD
            , (SELECT ITEM_NM FROM ITEM WHERE COMP_CD = TOT.COMP_CD AND ITEM_CD = TOT.ITEM_CD) AS ITEM_NM
            , TOT.CST_SALE_QTY
            , TOT.CST_SALE_AMT
            , TOT.CST_DC_AMT
            , TOT.CST_GRD_AMT
      FROM  (
              SELECT   
                      MMS.COMP_CD
                    , MMS.BRAND_CD
                    , MMS.STOR_CD
                    , MMS.SALE_DT
                    , MMS.CUST_ID
                    , MMS.CUST_AGE
                    , MMS.CUST_LVL
                    , MMS.CUST_SEX
                    , MMS.ITEM_CD
                    , SUM(MMS.SALE_QTY)           AS CST_SALE_QTY
                    , SUM(MMS.SALE_AMT)           AS CST_SALE_AMT          
                    , SUM(MMS.DC_AMT)             AS CST_DC_AMT                                              
                    , SUM(MMS.GRD_AMT)            AS CST_GRD_AMT
              FROM   (
                      SELECT  /*+ INDEX(MS INDEX_ANAL02) */
                              MS.COMP_CD
                            , MS.BRAND_CD
                            , MS.STOR_CD
                            , SUBSTR(MS.SALE_DT,0,6) AS SALE_DT
                            , MS.CUST_ID
                            , MS.CUST_AGE
                            , MS.CUST_LVL
                            , MS.CUST_SEX
                            , MS.ITEM_CD
                            , MS.SALE_QTY
                            , MS.SALE_AMT
                            , MS.DC_AMT + MS.ENR_AMT as DC_AMT 
                            , MS.GRD_AMT
                      FROM  C_CUST_DMS MS
                      WHERE   MS.COMP_CD  = ''' || P_COMP_CD || '''
                      AND     SUBSTR(MS.SALE_DT,0,6) BETWEEN ''' || V_START_DT || ''' AND ''' || V_END_DT || '''                        
        ';

                IF N_BRAND_CD IS NOT NULL AND N_BRAND_CD <> '' THEN
                  v_query := v_query || 
                    ' AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || P_MY_USER_ID || ''' AND BRAND_CD = MS.BRAND_CD AND USE_YN = ''Y'')';
                END IF;
                
                IF N_STOR_CD IS NOT NULL THEN
                  v_query := v_query || 
                    ' AND MS.STOR_CD = ''' || N_STOR_CD || '''';
                END IF;
                
                IF N_CUST_LVL IS NOT NULL THEN
                  v_query := v_query || 
                    ' AND MS.CUST_LVL = ''' || N_CUST_LVL || '''';
                END IF;  

        v_query := v_query || '
                     ORDER BY MS.BRAND_CD, MS.SALE_DT DESC
                     ) MMS
              GROUP BY
                      MMS.COMP_CD
                    , MMS.BRAND_CD
                    , MMS.STOR_CD
                    , MMS.SALE_DT
                    , MMS.CUST_ID
                    , MMS.CUST_AGE
                    , MMS.CUST_LVL
                    , MMS.CUST_SEX
                    , MMS.ITEM_CD
             ) TOT
    ';

        IF N_CUST_AGE IS NOT NULL THEN
          v_query := v_query || 
            ' WHERE GET_AGE_GROUP(TOT.CUST_AGE) = ''' || N_CUST_AGE || '''';
        END IF;
  
    DBMS_OUTPUT.PUT_LINE(v_query);
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_STATS_ANALYZE;

/
