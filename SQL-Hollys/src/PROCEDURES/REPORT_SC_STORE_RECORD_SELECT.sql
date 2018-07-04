--------------------------------------------------------
--  DDL for Procedure REPORT_SC_STORE_RECORD_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."REPORT_SC_STORE_RECORD_SELECT" 
(
    P_START_DT    IN    VARCHAR2,
    P_END_DT      IN    VARCHAR2,
    N_BRAND_CD    IN    VARCHAR2,
    O_CURSOR      OUT   SYS_REFCURSOR
) AS
    v_query     varchar(30000);
BEGIN
    v_query :=
             '
              SELECT
                GET_COMMON_CODE_NM(''00565'', A.STOR_TP, ''KOR'') AS STOR_TP
                ,GET_COMMON_CODE_NM(''00605'', A.TEAM_CD, ''KOR'') AS TEAM_NM
                ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = A.USER_ID) AS USER_NM
                ,(SELECT COUNT(1) FROM STORE WHERE SV_USER_ID = A.USER_ID) AS STOR_CNT
                ,COUNT(CUS.CUST_ID) AS NEW_CUST_CNT
                ,SUM(B.MSS_GRD_AMT) AS CUST_GRD_AMT
                ,SUM(A.JDS_GRD_AMT) AS TOT_GRD_AMT
                ,NVL(TO_CHAR(ROUND(SUM(B.MSS_GRD_AMT) / SUM(A.JDS_GRD_AMT) * 100, 2), ''990.99''), 0) AS TOT_GRD_AVG
              FROM
                  (
                    SELECT
                      STO.BRAND_CD
                      , STO.STOR_TP
                      , STO.STOR_CD
                      , HUS.USER_ID
                      , HUS.TEAM_CD
                      , SUM(JDS.BILL_CNT) AS JDS_BILL_CNT
                      , SUM(JDS.SALE_QTY) AS JDS_SALE_QTY
                      , SUM(JDS.GRD_AMT)  AS JDS_GRD_AMT
                    FROM STORE       STO
                        ,SALE_JDS    JDS
                        ,HQ_USER     HUS
                    WHERE STO.BRAND_CD = JDS.BRAND_CD
                      AND STO.STOR_CD  = JDS.STOR_CD
                      AND STO.SV_USER_ID = HUS.USER_ID
                      AND JDS.SALE_DT >= ''' || P_START_DT || ''' || ''01''
                      AND JDS.SALE_DT <= ''' || P_END_DT || ''' || ''31''
                    GROUP BY STO.BRAND_CD, STO.STOR_TP, STO.STOR_CD, HUS.USER_ID, HUS.TEAM_CD
                  ) A,
                  (
                    SELECT
                      STO.BRAND_CD
                      , STO.STOR_TP
                      , STO.STOR_CD
                      , HUS.USER_ID
                      , HUS.TEAM_CD
                      , SUM(MSS.BILL_CNT) AS MSS_BILL_CNT
                      , SUM(MSS.SALE_QTY) AS MSS_SALE_QTY
                      , SUM(MSS.GRD_AMT)  AS MSS_GRD_AMT
                    FROM STORE       STO
                        ,C_CUST_MSS  MSS
                        ,HQ_USER     HUS
                    WHERE STO.BRAND_CD = MSS.BRAND_CD
                      AND STO.STOR_CD  = MSS.STOR_CD
                      AND STO.SV_USER_ID = HUS.USER_ID
                      AND MSS.SALE_YM >= ''' || P_START_DT || '''
                      AND MSS.SALE_YM <= ''' || P_END_DT || '''
                    GROUP BY STO.BRAND_CD, STO.STOR_TP, STO.STOR_CD, HUS.USER_ID, HUS.TEAM_CD
                  ) B
                  , C_CUST CUS
              WHERE A.BRAND_CD = B.BRAND_CD (+)
                AND A.STOR_TP = B.STOR_TP (+)
                AND A.STOR_CD = B.STOR_CD (+)
                AND A.USER_ID = B.USER_ID (+)
                AND A.TEAM_CD = B.TEAM_CD (+)
                AND A.STOR_CD = CUS.STOR_CD (+)
                AND CUS.JOIN_DT >= ''' || P_START_DT || '''
                AND CUS.JOIN_DT <= ''' || P_END_DT || '''
              GROUP BY A.STOR_TP, A.USER_ID, A.TEAM_CD
             ';
              
    OPEN O_CURSOR FOR v_query;
END REPORT_SC_STORE_RECORD_SELECT;

/
