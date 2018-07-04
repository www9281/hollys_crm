--------------------------------------------------------
--  DDL for Procedure C_CUST_USER_ANALYSIS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_USER_ANALYSIS" (
    P_COMP_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_MY_BRAND_CD  IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_CUST_STAT    IN  VARCHAR2,
    N_CUST_GRADE   IN  VARCHAR2,
    N_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    v_query varchar2(30000);
BEGIN
--------------------------------- 전체 회원 분석 대비----------------------------------
    v_query := 
              'SELECT  CU.CUST_ID
                   ,  DECRYPT(CU.CUST_NM) AS CUST_NM
                   ,  CU.LVL_CD
                   ,  CL.LVL_NM
                   ,  CU.CUST_STAT
                   ,  CU.JOIN_DT
                   ,  DIFF                AS JOIN_DAYS
                   ,  BILL_CNT
                   ,  RANK () OVER (ORDER BY BILL_CNT DESC NULLS LAST) BILL_RANK
                   ,  DECODE(DIFF_RANGE, 0, 0, NVL(TO_CHAR(ROUND(BILL_CNT / DIFF_RANGE * CASE WHEN DIFF_RANGE < 7 THEN DIFF_RANGE ELSE 7 END, 2), ''990.99''), ''0'')) AS  BILL_AVG_WEEK
                   ,  SALE_QTY
                   ,  GRD_AMT
                   ,  RANK () OVER (ORDER BY GRD_AMT DESC NULLS LAST) GRD_RANK
                   ,  SUB.SAV_MLG         AS MLG_SUM
                   ,  RANK () OVER (ORDER BY SUB.SAV_MLG DESC NULLS LAST) MLG_RANK
                   ,  SUB.SAV_PT         AS PNT_SUM
                   ,  RANK () OVER (ORDER BY SUB.SAV_PT DESC NULLS LAST) PNT_RANK
                   ,  MD_QTY
                   ,  MD_AMT
                   ,  DECODE(MD_QTY, 0, 0, NVL(TO_CHAR(ROUND(MD_AMT / MD_QTY, 2), ''990.99''), ''0''))                                           AS  MD_AVG_PRIC
                   ,  RANK () OVER (ORDER BY MD_AMT DESC NULLS LAST) MD_RANK
                   ,  DECODE(DIFF_RANGE, 0, 0, NVL(TO_CHAR(ROUND(MD_QTY / DIFF_RANGE * CASE WHEN DIFF_RANGE < 7 THEN DIFF_RANGE ELSE 7 END, 2), ''990.99''), ''0''))   AS  MD_AVG_WEEK
                   ,  DECODE(BILL_CNT, 0, 0, NVL(TO_CHAR(ROUND(MD_QTY / BILL_CNT, 2), ''990.99''), ''0''))                                       AS  MD_BILL_QTY
                   ,  EP_QTY
                   ,  EP_AMT
                   ,  DECODE(EP_QTY, 0, 0, NVL(TO_CHAR(ROUND(EP_AMT / EP_QTY, 2), ''990.99''), ''0''))                                           AS  EP_AVG_PRIC
                   ,  RANK () OVER (ORDER BY EP_AMT DESC NULLS LAST) EP_RANK
                FROM  C_CUST CU
                   ,  (
                          SELECT  CU.COMP_CD
                               ,  CU.CUST_ID
                               ,  CU.DIFF
                               ,  CU.DIFF_RANGE
                               ,  DSS.BILL_CNT
                               ,  DMS.SALE_QTY
                               ,  DMS.GRD_AMT
                               ,  CSH.SAV_MLG
                               ,  CSH.SAV_PT
                               ,  DMS.MD_QTY
                               ,  DMS.MD_AMT
                               ,  DMS.EP_QTY
                               ,  DMS.EP_AMT
                            FROM  (
                                      SELECT  COMP_CD,  CUST_ID
                                           ,  TO_DATE( ''' || P_END_DT || ''', ''YYYYMMDD'') - TO_DATE(JOIN_DT, ''YYYYMMDD'') + 1  AS  DIFF
                                           ,  CASE WHEN JOIN_DT <  ''' || P_START_DT || ''' THEN TO_DATE( ''' || P_END_DT || ''', ''YYYYMMDD'') - TO_DATE( ''' || P_START_DT || ''', ''YYYYMMDD'')
                                                   ELSE TO_DATE( ''' || P_END_DT || ''', ''YYYYMMDD'') - TO_DATE(JOIN_DT, ''YYYYMMDD'')
                                                   END + 1                                                             AS  DIFF_RANGE
                                        FROM  C_CUST
                                  )  CU 
                               ,  (
                                      SELECT  DSS.COMP_CD
                                           ,  DSS.CUST_ID
                                           ,  SUM(DSS.BILL_CNT - DSS.RTN_BILL_CNT) BILL_CNT 
                                        FROM  C_CUST_DSS DSS
                                           ,  STORE      STO
                                       WHERE  STO.BRAND_CD = DSS.BRAND_CD
                                         AND  STO.STOR_CD  = DSS.STOR_CD
                                         AND  DSS.COMP_CD   =  ''' || P_COMP_CD || '''
                                         AND  DSS.SALE_DT BETWEEN  ''' || P_START_DT || ''' AND  ''' || P_END_DT || '''
                                         AND     (''001'' = '''||N_BRAND_CD||''' OR STO.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND STO.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                                       GROUP  BY COMP_CD
                                           ,  CUST_ID
                                  )  DSS
                               ,  (
                                      SELECT  DMS.COMP_CD, DMS.CUST_ID
                                           ,  SUM(SALE_QTY)                             AS  SALE_QTY
                                           ,  SUM(GRD_AMT)                              AS  GRD_AMT
                                           ,  SUM(CASE WHEN IT.SAV_MLG_YN = ''Y'' THEN SALE_QTY ELSE 0 END) AS MD_QTY    
                                           ,  SUM(CASE WHEN IT.SAV_MLG_YN = ''Y'' THEN GRD_AMT  ELSE 0 END) AS MD_AMT    
                                           ,  SUM(CASE WHEN IT.SAV_MLG_YN = ''N'' THEN SALE_QTY ELSE 0 END) AS EP_QTY
                                           ,  SUM(CASE WHEN IT.SAV_MLG_YN = ''N'' THEN GRD_AMT  ELSE 0 END) AS EP_AMT
                                        FROM  C_CUST_DMS DMS
                                           ,  STORE      STO 
                                           ,  ITEM       IT
                                       WHERE  DMS.BRAND_CD  = STO.BRAND_CD
                                         AND  DMS.STOR_CD   = STO.STOR_CD
                                         AND  DMS.BRAND_CD  = IT.BRAND_CD(+)  
                                         AND  DMS.ITEM_CD   = IT.ITEM_CD(+)
                                         AND  DMS.COMP_CD   =  ''' || P_COMP_CD || '''
                                         AND  DMS.SALE_DT BETWEEN  ''' || P_START_DT || ''' AND  ''' || P_END_DT || '''
                                         AND  (''001'' = '''||N_BRAND_CD||''' OR STO.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND STO.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                                       GROUP  BY DMS.COMP_CD
                                           ,  DMS.CUST_ID
                                  )  DMS
                               ,  (
                                     SELECT  CD.COMP_CD,  CD.CUST_ID
                                          ,  SUM(CSH.SAV_MLG)   AS  SAV_MLG
                                          ,  SUM(CSH.SAV_PT)   AS  SAV_PT
                                       FROM  C_CARD          CD
                                          ,  C_CARD_SAV_HIS  CSH
                                      WHERE  CD.COMP_CD   = CSH.COMP_CD
                                        AND  CD.CARD_ID   = CSH.CARD_ID  
                                        AND  CD.COMP_CD   =  ''' || P_COMP_CD || '''
                                        AND  CSH.USE_DT BETWEEN  ''' || P_START_DT || ''' AND  ''' || P_END_DT || '''
                                        AND  CSH.USE_YN   = ''Y''
                                      GROUP  BY CD.COMP_CD
                                          ,  CD.CUST_ID 
                                  )  CSH
                           WHERE  CU.COMP_CD  = DSS.COMP_CD
                             AND  CU.CUST_ID  = DSS.CUST_ID
                             AND  CU.COMP_CD  = DMS.COMP_CD
                             AND  CU.CUST_ID  = DMS.CUST_ID
                             AND  CU.COMP_CD  = CSH.COMP_CD(+)
                             AND  CU.CUST_ID  = CSH.CUST_ID(+)
                      )  SUB
                      ,  (
                            SELECT  CL.COMP_CD
                                 ,  CL.LVL_CD
                                 ,  NVL(L.LANG_NM, CL.LVL_NM)   AS LVL_NM
                              FROM  C_CUST_LVL  CL
                                 ,  (
                                        SELECT  PK_COL
                                             ,  LANG_NM
                                          FROM  LANG_TABLE
                                         WHERE  TABLE_NM    = ''C_CUST_LVL''
                                           AND  COL_NM      = ''LVL_NM''
                                           AND  LANGUAGE_TP = ''' || N_LANGUAGE_TP || '''
                                           AND  USE_YN      = ''Y''
                                    )           L
                             WHERE  L.PK_COL(+)     = LPAD(CL.LVL_CD, 10, '' '')
                               AND  CL.COMP_CD      =  ''' || P_COMP_CD || '''
                               AND  CL.USE_YN       = ''Y''
                         )           CL    
               WHERE  CU.COMP_CD  = SUB.COMP_CD
                 AND  CU.CUST_ID  = SUB.CUST_ID
                 AND  CU.COMP_CD  = CL.COMP_CD
                 AND  CU.LVL_CD   = CL.LVL_CD
                 AND  CU.COMP_CD  =  ''' || P_COMP_CD || '''
                 AND  ( ''' || N_CUST_STAT || ''' IS NULL OR CU.CUST_STAT =  ''' || N_CUST_STAT || ''')
                 AND  ( ''' || N_CUST_GRADE || ''' IS NULL OR CU.LVL_CD =  ''' || N_CUST_GRADE || ''')
               ORDER  BY SUB.GRD_AMT DESC NULLS LAST,  DIFF';
                
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_USER_ANALYSIS;

/
