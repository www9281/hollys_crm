--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_ANALYZE_COMPARE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_ANALYZE_COMPARE" (
    P_COMP_CD       IN  VARCHAR2,
    N_BRAND_CD      IN  VARCHAR2,
    N_CUST_LVL      IN  VARCHAR2,
    N_CUST_STAT     IN  VARCHAR2,
    P_START_DT      IN  VARCHAR2,
    P_END_DT        IN  VARCHAR2,
    P_LAST_START_DT IN  VARCHAR2,
    P_LAST_END_DT   IN  VARCHAR2,
    N_LANGUAGE_TP   IN  VARCHAR2,
    P_MY_USER_ID    IN  VARCHAR2,
    N_YYMM_DIV      IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
) IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-15
    -- Description   :   회원분석 전체회원분석 탭
    -- ==========================================================================================
    OPEN O_CURSOR FOR
      SELECT  CU.CUST_ID
         ,  CUST_WEB_ID
         ,  DECRYPT(CU.CUST_NM) AS CUST_NM
         ,  CU.LVL_CD
         ,  CL.LVL_NM
         ,  CU.CUST_STAT
         ,  TO_CHAR(CU.INST_DT, 'YYYYMMDD') AS JOIN_DT
         ,  CASE WHEN SUB.DIFF > 0 THEN TO_CHAR(SUB.DIFF) ELSE '-' END AS JOIN_DAYS
         ,  SUB.BILL_CNT                AS  BILL_CNT  
         ,  SUB.BILL_RANK               AS  BILL_RANK
         ,  COP.BILL_CNT                AS  C_BILL_CNT  
         ,  COP.BILL_RANK               AS  C_BILL_RANK
         ,  SUB.SAV_MLG                 AS  MLG_SUM
         ,  SUB.MLG_RANK                AS  MLG_RANK
         ,  COP.SAV_MLG                 AS  C_MLG_SUM
         ,  COP.MLG_RANK                AS  C_MLG_RANK
         ,  SUB.SALE_QTY                AS  SALE_QTY
         ,  SUB.GRD_AMT                 AS  GRD_AMT 
         ,  SUB.GRD_RANK                AS  GRD_RANK 
         ,  COP.SALE_QTY                AS  C_SALE_QTY
         ,  COP.GRD_AMT                 AS  C_GRD_AMT 
         ,  COP.GRD_RANK                AS  C_GRD_RANK 
         ,  SUB.MD_QTY                  AS  MD_QTY
         ,  SUB.MD_AMT                  AS  MD_AMT
         ,  SUB.MD_RANK                 AS  MD_RANK
         ,  SUB.MD_AVG_WEEK             AS  MD_AVG_WEEK
         ,  SUB.MD_DAYS                 AS  MD_DAYS
         ,  SUB.MD_AVG_QTY              AS  MD_AVG_QTY
         ,  COP.MD_QTY                  AS  C_MD_QTY
         ,  COP.MD_AMT                  AS  C_MD_AMT
         ,  COP.MD_RANK                 AS  C_MD_RANK
         ,  COP.MD_AVG_WEEK             AS  C_MD_AVG_WEEK
         ,  COP.MD_DAYS                 AS  C_MD_DAYS
         ,  COP.MD_AVG_QTY              AS  C_MD_AVG_QTY
         ,  SUB.EP_QTY                  AS  EP_QTY
         ,  SUB.EP_AMT                  AS  EP_AMT
         ,  SUB.EP_RANK                 AS  EP_RANK
         ,  COP.EP_QTY                  AS  C_EP_QTY
         ,  COP.EP_AMT                  AS  C_EP_AMT
         ,  COP.EP_RANK                 AS  C_EP_RANK
         ,  P_START_DT                  AS  SCH_GFR_DATE
         ,  P_END_DT                    AS  SCH_GTO_DATE
         ,  P_LAST_START_DT             AS  SCH_LAST_FR_DT
         ,  P_LAST_END_DT               AS  SCH_LAST_TO_DT
      FROM  C_CUST CU
         ,  (
                SELECT  CU.COMP_CD
                     ,  CU.CUST_ID
                     ,  CU.DIFF
                     ,  CU.DIFF_RANGE
                     ,  DSS.BILL_CNT
                     ,  RANK () OVER (ORDER BY DSS.BILL_CNT DESC NULLS LAST)                AS  BILL_RANK
                     ,  CSH.SAV_MLG
                     ,  RANK () OVER (ORDER BY CSH.SAV_MLG DESC NULLS LAST)                 AS  MLG_RANK
                     ,  DMS.SALE_QTY
                     ,  DMS.GRD_AMT
                     ,  RANK () OVER (ORDER BY DMS.GRD_AMT DESC NULLS LAST)                 AS  GRD_RANK
                     ,  DMS.MD_QTY
                     ,  DMS.MD_AMT
                     ,  RANK () OVER (ORDER BY DMS.MD_AMT DESC NULLS LAST)                  AS  MD_RANK
                     ,  CASE WHEN CU.DIFF_RANGE <= 0 THEN 0 
                             ELSE ROUND(DMS.MD_QTY / CU.DIFF_RANGE * CASE WHEN CU.DIFF_RANGE < 7 THEN CU.DIFF_RANGE ELSE 7 END, 2)
                             END                                                            AS  MD_AVG_WEEK
                     ,  DMS.MD_DAYS
                     ,  DECODE(DMS.MD_DAYS, 0, 0, ROUND(DMS.MD_QTY / DMS.MD_DAYS, 2))       AS  MD_AVG_QTY
                     ,  DMS.EP_QTY
                     ,  DMS.EP_AMT      
                     ,  RANK () OVER (ORDER BY DMS.EP_AMT DESC NULLS LAST)                  AS  EP_RANK           
                  FROM  (
                            SELECT  COMP_CD,  CUST_ID
                                 ,  TO_DATE(P_END_DT, 'YYYYMMDD') - TO_DATE(TO_CHAR(INST_DT, 'YYYYMMDD')) + 1  AS  DIFF
                                 ,  CASE WHEN TO_CHAR(INST_DT, 'YYYYMMDD') <  P_START_DT THEN TO_DATE(P_END_DT, 'YYYYMMDD') - TO_DATE(P_START_DT, 'YYYYMMDD')
                                         ELSE TO_DATE(P_END_DT, 'YYYYMMDD') - TO_DATE(TO_CHAR(INST_DT, 'YYYYMMDD'))
                                    END + 1 AS  DIFF_RANGE
                              FROM  C_CUST  CU
                             WHERE  CU.COMP_CD  = P_COMP_CD
                               AND  (N_CUST_STAT IS NULL OR CU.CUST_STAT = N_CUST_STAT)
                               AND  (N_CUST_STAT IS NULL OR CU.LVL_CD = N_CUST_STAT)
                        )  CU 
                     ,  (
                            SELECT  DSS.COMP_CD, DSS.CUST_ID
                                 ,  SUM(BILL_CNT - RTN_BILL_CNT) BILL_CNT 
                              FROM  C_CUST_DSS DSS
                                 ,  STORE      STO
                             WHERE  STO.BRAND_CD = DSS.BRAND_CD
                               AND  STO.STOR_CD  = DSS.STOR_CD
                               AND  DSS.COMP_CD   =  P_COMP_CD
                               AND  DSS.SALE_DT BETWEEN  P_START_DT AND P_END_DT
                               AND  (STO.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                                     AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = STO.BRAND_CD AND USE_YN = 'Y')))
                             GROUP  BY DSS.COMP_CD, DSS.CUST_ID
                        )  DSS
                     ,  (
                            SELECT  DMS.COMP_CD, DMS.CUST_ID
                                 ,  SUM(SALE_QTY)                             AS  SALE_QTY
                                 ,  SUM(GRD_AMT)                              AS  GRD_AMT
                                 ,  SUM(CASE WHEN IT.SAV_MLG_YN = 'Y' THEN SALE_QTY ELSE 0 END) AS MD_QTY    
                                 ,  SUM(CASE WHEN IT.SAV_MLG_YN = 'Y' THEN GRD_AMT  ELSE 0 END) AS MD_AMT    
                                 ,  COUNT(DISTINCT (CASE WHEN IT.SAV_MLG_YN = 'Y' THEN SALE_DT ELSE NULL END))  AS MD_DAYS
                                 ,  SUM(CASE WHEN IT.SAV_MLG_YN = 'N' THEN SALE_QTY ELSE 0 END) AS EP_QTY
                                 ,  SUM(CASE WHEN IT.SAV_MLG_YN = 'N' THEN GRD_AMT  ELSE 0 END) AS EP_AMT
                              FROM  C_CUST_DMS DMS
                                 ,  STORE      STO
                                 ,  ITEM       IT
                             WHERE  DMS.BRAND_CD  = STO.BRAND_CD
                               AND  DMS.STOR_CD   = STO.STOR_CD
                               AND  DMS.BRAND_CD  = IT.BRAND_CD(+)  
                               AND  DMS.ITEM_CD   = IT.ITEM_CD(+)
                               AND  DMS.COMP_CD   = P_COMP_CD
                               AND  DMS.SALE_DT BETWEEN P_START_DT AND P_END_DT
                               AND  (STO.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                                     AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = STO.BRAND_CD AND USE_YN = 'Y')))
                             GROUP  BY DMS.COMP_CD
                                 ,  DMS.CUST_ID
                        )  DMS
                     ,  (
                           SELECT  CD.COMP_CD,  CD.CUST_ID
                                ,  SUM(CSH.SAV_MLG)   AS  SAV_MLG
                             FROM  C_CARD          CD
                                ,  C_CARD_SAV_HIS  CSH
                            WHERE  CD.COMP_CD  = CSH.COMP_CD
                              AND  CD.CARD_ID  = CSH.CARD_ID  
                              AND  CD.COMP_CD   =  P_COMP_CD
                              AND  CSH.USE_DT BETWEEN  P_START_DT AND P_END_DT
                              AND  CSH.USE_YN   = 'Y'
                            GROUP  BY CD.COMP_CD,  CD.CUST_ID 
                        )  CSH
                 WHERE  CU.COMP_CD  = DSS.COMP_CD
                   AND  CU.CUST_ID  = DSS.CUST_ID
                   AND  CU.COMP_CD  = DMS.COMP_CD
                   AND  CU.CUST_ID  = DMS.CUST_ID
                   AND  CU.COMP_CD  = CSH.COMP_CD(+)
                   AND  CU.CUST_ID  = CSH.CUST_ID(+)
            )  SUB
         ,  (
                SELECT  CU.COMP_CD
                     ,  CU.CUST_ID
                     ,  DSS.BILL_CNT
                     ,  RANK () OVER (ORDER BY DSS.BILL_CNT DESC NULLS LAST)                AS  BILL_RANK
                     ,  CSH.SAV_MLG
                     ,  RANK () OVER (ORDER BY CSH.SAV_MLG DESC NULLS LAST)                 AS  MLG_RANK
                     ,  DMS.SALE_QTY
                     ,  DMS.GRD_AMT
                     ,  RANK () OVER (ORDER BY DMS.GRD_AMT DESC NULLS LAST)                 AS  GRD_RANK
                     ,  DMS.MD_QTY
                     ,  DMS.MD_AMT
                     ,  RANK () OVER (ORDER BY DMS.MD_AMT DESC NULLS LAST)                  AS  MD_RANK
                     ,  CASE WHEN CU.DIFF_RANGE <= 0 THEN 0 
                             ELSE ROUND(DMS.MD_QTY / CU.DIFF_RANGE * CASE WHEN CU.DIFF_RANGE < 7 THEN CU.DIFF_RANGE ELSE 7 END, 2)
                             END                                                            AS  MD_AVG_WEEK
                     ,  DMS.MD_DAYS
                     ,  DECODE(DMS.MD_DAYS, 0, 0, ROUND(DMS.MD_QTY / DMS.MD_DAYS, 2))       AS  MD_AVG_QTY
                     ,  DMS.EP_QTY
                     ,  DMS.EP_AMT      
                     ,  RANK () OVER (ORDER BY DMS.EP_AMT DESC NULLS LAST)                  AS  EP_RANK           
                  FROM  (
                            SELECT  COMP_CD,  CUST_ID
                                 ,  TO_DATE(P_LAST_END_DT, 'YYYYMMDD') - TO_DATE(TO_CHAR(INST_DT, 'YYYYMMDD')) + 1  AS  DIFF
                                 ,  CASE WHEN TO_CHAR(INST_DT, 'YYYYMMDD') < P_LAST_START_DT THEN TO_DATE(P_LAST_END_DT, 'YYYYMMDD') - TO_DATE(P_LAST_START_DT, 'YYYYMMDD')
                                         ELSE TO_DATE(P_LAST_END_DT, 'YYYYMMDD') - TO_DATE(TO_CHAR(INST_DT, 'YYYYMMDD'))
                                    END + 1 AS  DIFF_RANGE
                              FROM  C_CUST  CU
                             WHERE  CU.COMP_CD  =  P_COMP_CD
                               AND  (N_CUST_STAT IS NULL OR CU.CUST_STAT =  N_CUST_STAT)
                               AND  (N_CUST_STAT IS NULL OR CU.LVL_CD = N_CUST_STAT)
                        )  CU 
                     ,  (
                            SELECT  DSS.COMP_CD,  DSS.CUST_ID
                                 ,  SUM(BILL_CNT - RTN_BILL_CNT) BILL_CNT 
                              FROM  C_CUST_DSS DSS
                                 ,  STORE      STO
                             WHERE  STO.BRAND_CD = DSS.BRAND_CD
                               AND  STO.STOR_CD  = DSS.STOR_CD
                               AND  DSS.COMP_CD   =  P_COMP_CD
                               AND  DSS.SALE_DT BETWEEN P_LAST_START_DT AND P_LAST_END_DT
                               AND  (STO.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                                     AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = STO.BRAND_CD AND USE_YN = 'Y')))
                             GROUP  BY DSS.COMP_CD,  DSS.CUST_ID
                        )  DSS
                     ,  (
                            SELECT  DMS.COMP_CD, DMS.CUST_ID
                                 ,  SUM(SALE_QTY)                             AS  SALE_QTY
                                 ,  SUM(GRD_AMT)                              AS  GRD_AMT
                                 ,  SUM(CASE WHEN IT.SAV_MLG_YN = 'Y' THEN SALE_QTY ELSE 0 END) AS MD_QTY    
                                 ,  SUM(CASE WHEN IT.SAV_MLG_YN = 'Y' THEN GRD_AMT  ELSE 0 END) AS MD_AMT    
                                 ,  COUNT(DISTINCT (CASE WHEN IT.SAV_MLG_YN = 'Y' THEN SALE_DT ELSE NULL END))  AS MD_DAYS
                                 ,  SUM(CASE WHEN IT.SAV_MLG_YN = 'N' THEN SALE_QTY ELSE 0 END) AS EP_QTY
                                 ,  SUM(CASE WHEN IT.SAV_MLG_YN = 'N' THEN GRD_AMT  ELSE 0 END) AS EP_AMT
                              FROM  C_CUST_DMS DMS
                                 ,  STORE      STO
                                 ,  ITEM       IT
                             WHERE  DMS.BRAND_CD  = STO.BRAND_CD
                               AND  DMS.STOR_CD   = STO.STOR_CD
                               AND  DMS.BRAND_CD  = IT.BRAND_CD(+)  
                               AND  DMS.ITEM_CD   = IT.ITEM_CD(+)
                               AND  DMS.COMP_CD   = P_COMP_CD
                               AND  DMS.SALE_DT BETWEEN P_LAST_START_DT AND P_LAST_END_DT
                               AND  (STO.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                                     AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = STO.BRAND_CD AND USE_YN = 'Y')))
                             GROUP  BY DMS.COMP_CD, DMS.CUST_ID
                        )  DMS
                     ,  (
                           SELECT  CD.COMP_CD,  CD.CUST_ID
                                ,  SUM(CSH.SAV_MLG)   AS  SAV_MLG
                             FROM  C_CARD          CD
                                ,  C_CARD_SAV_HIS  CSH
                            WHERE  CD.COMP_CD  = CSH.COMP_CD
                              AND  CD.CARD_ID  = CSH.CARD_ID  
                              AND  CD.COMP_CD   =  P_COMP_CD
                              AND  CSH.USE_DT BETWEEN P_LAST_START_DT AND P_LAST_END_DT
                              AND  CSH.USE_YN   = 'Y'
                            GROUP  BY CD.COMP_CD,  CD.CUST_ID 
                        )  CSH
                 WHERE  CU.COMP_CD  = DSS.COMP_CD
                   AND  CU.CUST_ID  = DSS.CUST_ID
                   AND  CU.COMP_CD  = DMS.COMP_CD
                   AND  CU.CUST_ID  = DMS.CUST_ID
                   AND  CU.COMP_CD  = CSH.COMP_CD(+)
                   AND  CU.CUST_ID  = CSH.CUST_ID(+)
            )  COP
            ,  (
                  SELECT  CL.COMP_CD
                       ,  CL.LVL_CD
                       ,  NVL(L.LANG_NM, CL.LVL_NM)   AS LVL_NM
                    FROM  C_CUST_LVL  CL
                       ,  (
                              SELECT  PK_COL
                                   ,  LANG_NM
                                FROM  LANG_TABLE
                               WHERE  TABLE_NM    = 'C_CUST_LVL'
                                 AND  COL_NM      = 'LVL_NM'
                                 AND  LANGUAGE_TP = N_LANGUAGE_TP
                                 AND  USE_YN      = 'Y'
                          )           L
                   WHERE  L.PK_COL(+)     = LPAD(CL.LVL_CD, 10, ' ')
                     AND  CL.COMP_CD      = P_COMP_CD
                     AND  CL.USE_YN       = 'Y'
               )           CL    
     WHERE  CU.COMP_CD  = SUB.COMP_CD
       AND  CU.CUST_ID  = SUB.CUST_ID
       AND  CU.COMP_CD  = COP.COMP_CD(+)
       AND  CU.CUST_ID  = COP.CUST_ID(+)
       AND  CU.COMP_CD  = CL.COMP_CD
       AND  CU.LVL_CD   = CL.LVL_CD
     ORDER  BY SUB.BILL_RANK,  SUB.DIFF;
    
END C_CUST_STATS_ANALYZE_COMPARE;

/
