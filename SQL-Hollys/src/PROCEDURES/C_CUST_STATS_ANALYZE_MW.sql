--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_ANALYZE_MW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_ANALYZE_MW" (
    P_COMP_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_CUST_LVL     IN  VARCHAR2,
    N_CUST_AGE     IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_MY_USER_ID	 IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    v_query VARCHAR2(30000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-15
    -- Description   :   회원분석 전체회원분석 탭
    -- ==========================================================================================
    v_query := '
      SELECT  TOT.COMP_CD
            , TOT.STOR_CD
            , TOT.STOR_NM
            , TOT.SALE_DT
            , TOT.CUST_ID
            , TOT.CUST_NM
            , TOT.CUST_STAT
            , TOT.CUST_AGE AS AGE_GROUP
            , TOT.CUST_LVL
            , TOT.CUST_SEX
            , TOT.ITEM_CD
            , TOT.ITEM_NM
            , TOT.CST_SALE_QTY
            , TOT.CST_SALE_AMT
            , TOT.CST_DC_AMT
            , TOT.CST_GRD_AMT
      FROM  MVW_C_CUST_DMS02 TOT
      
      WHERE   TOT.COMP_CD  = ''' || P_COMP_CD || '''
      AND     TOT.SALE_DT BETWEEN ''' || P_START_DT || ''' AND ''' || P_END_DT || '''                        
        ';

                IF N_BRAND_CD IS NOT NULL THEN
                  v_query := v_query || 
                    ' AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || P_MY_USER_ID || ''' AND BRAND_CD = TOT.BRAND_CD AND USE_YN = ''Y'')';
                END IF;
                
                IF N_STOR_CD IS NOT NULL THEN
                  v_query := v_query || 
                    ' AND TOT.STOR_CD = ''' || N_STOR_CD || '''';
                END IF;
                
                IF N_CUST_LVL IS NOT NULL THEN
                  v_query := v_query || 
                    ' AND TOT.LVL_CD = ''' || N_CUST_LVL || '''';
                END IF;  

                IF N_CUST_AGE IS NOT NULL THEN
                  v_query := v_query || 
                    ' AND GET_AGE_GROUP(TOT.CUST_AGE) = ''' || N_CUST_AGE || '''';
                END IF;
  
--    v_query := '
--       SELECT  MS.COMP_CD
--                            , MS.BRAND_CD
--                            , MS.STOR_CD
--                            , MS.SALE_DT
--                            , MS.CUST_ID
--                            , GET_AGE_GROUP(MS.CUST_AGE) AS CUST_AGE_GROUP
--                            , MS.CUST_LVL
--                            , MS.CUST_SEX
--                            , MS.ITEM_CD
--                            , MS.SALE_QTY
--                            , MS.SALE_AMT
--                            , MS.DC_AMT + MS.ENR_AMT as DC_AMT 
--                            , MS.GRD_AMT
--                      FROM  C_CUST_DMS MS
--    ';
    DBMS_OUTPUT.PUT_LINE(v_query);
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_STATS_ANALYZE_MW;

/
