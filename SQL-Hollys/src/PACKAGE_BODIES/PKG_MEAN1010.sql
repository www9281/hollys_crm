--------------------------------------------------------
--  DDL for Package Body PKG_MEAN1010
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MEAN1010" AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    전체
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-31         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-03-31
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);

    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM

    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  /*+ NO_MERGE LEADING(CST) */ ]'
        ||CHR(13)||CHR(10)||Q'[         CST.STD_YM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CST.TOT_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CST.NEW_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / CST.TOT_CUST_CNT * 100 END AS OPER_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT  / MSS.CST_BILL_CNT       END AS CST_BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN (JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) = 0 THEN 0 ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE (JDS.TOT_GRD_AMT - MSS.CST_GRD_AMT) / (JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) ]'
        ||CHR(13)||CHR(10)||Q'[         END AS NCST_BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0 ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN (SUM(JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) OVER()) = 0 THEN 0 ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE (SUM(JDS.TOT_GRD_AMT - MSS.CST_GRD_AMT)OVER()) / (SUM(JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) OVER()) ]'
        ||CHR(13)||CHR(10)||Q'[         END AS T_NCST_BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_SALE_QTY/JDS.TOT_SALE_QTY *100    as   CST_SALE_RATE ]'                
        ||CHR(13)||CHR(10)||Q'[      ,  JDS.TOT_SALE_QTY - MSS.CST_SALE_QTY AS NCST_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (JDS.TOT_SALE_QTY - MSS.CST_SALE_QTY)/JDS.TOT_SALE_QTY*100  as NCST_SALE_RATE ]'       
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_GRD_AMT/JDS.TOT_GRD_AMT*100  as  CST_GRD_RATE ]'     
        ||CHR(13)||CHR(10)||Q'[      ,  JDS.TOT_GRD_AMT  - MSS.CST_GRD_AMT  AS NCST_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (JDS.TOT_GRD_AMT  - MSS.CST_GRD_AMT)/JDS.TOT_GRD_AMT*100  AS NCST_GRD_RATE ]'     
        ||CHR(13)||CHR(10)||Q'[   FROM  ( ]'    
        ||CHR(13)||CHR(10)||Q'[           SELECT  /*+ NO_MERGE LEADING(CST) */ ]'
        ||CHR(13)||CHR(10)||Q'[                   CST.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.STD_YM ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(CASE WHEN CST.JOIN_DT <=   V01.STD_YM||'31' AND SUBSTR(NVL(CST.LEAVE_DT, '99991231'), 1, 8) >= V01.STD_YM||'31' THEN 1 ELSE 0 END) TOT_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(CASE WHEN CST.JOIN_DT LIKE V01.STD_YM||'%'  AND SUBSTR(NVL(CST.LEAVE_DT, '99991231'), 1, 8) >= V01.STD_YM||'31' THEN 1 ELSE 0 END) NEW_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[             FROM  C_CUST     CST ]'
        ||CHR(13)||CHR(10)||Q'[                ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[                ,  ( ]'
        ||CHR(13)||CHR(10)||Q'[                     SELECT  TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD'), ROWNUM - 1), 'YYYYMM') STD_YM ]'
        ||CHR(13)||CHR(10)||Q'[                       FROM  TAB ]'
        ||CHR(13)||CHR(10)||Q'[                      WHERE  ROWNUM <= (MONTHS_BETWEEN(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), ]'
        ||CHR(13)||CHR(10)||Q'[                                                       TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD')) + 1) ]'
        ||CHR(13)||CHR(10)||Q'[                   ) V01 ]'
        ||CHR(13)||CHR(10)||Q'[            WHERE  S.COMP_CD  = CST.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              AND  S.BRAND_CD = CST.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[              AND  S.STOR_CD  = CST.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              AND  CST.COMP_CD = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[              AND  SUBSTR(NVL(CST.LEAVE_DT, '99991231'), 1, 8)  >= :PSV_GFR_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              AND  CST.CUST_STAT IN ('2', '9') ]'
        ||CHR(13)||CHR(10)||Q'[              AND  CST.JOIN_DT<= :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              AND  EXISTS ( ]'
        ||CHR(13)||CHR(10)||Q'[                            SELECT  1 ]'
        ||CHR(13)||CHR(10)||Q'[                              FROM  C_CUST_MLVL MVL ]'
        ||CHR(13)||CHR(10)||Q'[                             WHERE  MVL.COMP_CD = CST.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                               AND  MVL.CUST_ID = CST.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                               AND  MVL.SALE_YM = V01.STD_YM ]'
        ||CHR(13)||CHR(10)||Q'[                               AND  (:PSV_LVL_CD IS NULL OR MVL.CUST_LVL = :PSV_LVL_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                           ) ]'
        ||CHR(13)||CHR(10)||Q'[            GROUP  BY CST.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.STD_YM ]'
        ||CHR(13)||CHR(10)||Q'[         ) CST ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ( ]'
        ||CHR(13)||CHR(10)||Q'[           SELECT  /*+ NO_MERGE LEADING(MSS) */ ]'
        ||CHR(13)||CHR(10)||Q'[                   MSS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MSS.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MSS.BILL_CNT)           AS CST_BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MSS.SALE_QTY)           AS CST_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MSS.GRD_AMT)            AS CST_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[             FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[                     SELECT  /*+ NO_MERGE */ ]'
        ||CHR(13)||CHR(10)||Q'[                             MSS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM ]'
        ||CHR(13)||CHR(10)||Q'[                       FROM  C_CUST_MSS MSS ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  S_STORE  S ]'
        ||CHR(13)||CHR(10)||Q'[                      WHERE  S.COMP_CD  = MSS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  S.BRAND_CD = MSS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  S.STOR_CD  = MSS.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  MSS.SALE_YM >= SUBSTR(:PSV_GFR_DATE, 1, 6) ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  MSS.SALE_YM <= SUBSTR(:PSV_GTO_DATE, 1, 6) ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  MSS.CUST_LVL = NVL(:PSV_LVL_CD, MSS.CUST_LVL) ]'
        ||CHR(13)||CHR(10)||Q'[                   ) MSS ]'
        ||CHR(13)||CHR(10)||Q'[            GROUP  BY MSS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MSS.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[         ) MSS ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ( ]'
        ||CHR(13)||CHR(10)||Q'[           SELECT  /*+ NO_MERGE LEADING(JDS) */ ]'
        ||CHR(13)||CHR(10)||Q'[                   :PSV_COMP_CD                AS COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUBSTR(JDS.SALE_DT, 1, 6 )  AS SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(JDS.BILL_CNT)           AS TOT_BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(JDS.SALE_QTY)           AS TOT_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(JDS.GRD_AMT)            AS TOT_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[             FROM  SALE_JDS JDS ]'
        ||CHR(13)||CHR(10)||Q'[                ,  S_STORE  S   ]'
        ||CHR(13)||CHR(10)||Q'[            WHERE  S.COMP_CD  = JDS.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              AND  S.BRAND_CD = JDS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[              AND  S.STOR_CD  = JDS.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              AND  JDS.SALE_DT  >= :PSV_GFR_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              AND  JDS.SALE_DT  <= :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[            GROUP  BY SUBSTR(JDS.SALE_DT, 1, 6 ) ]'
        ||CHR(13)||CHR(10)||Q'[         ) JDS ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CST.COMP_CD   = MSS.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CST.STD_YM    = MSS.SALE_YM(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CST.COMP_CD   = JDS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CST.STD_YM    = JDS.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY CST.STD_YM ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_GFR_DATE, PSV_GTO_DATE, PSV_GFR_DATE,
                         PSV_COMP_CD, 
                         PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_LVL_CD, PSV_LVL_CD,
                         PSV_GFR_DATE, PSV_GTO_DATE, PSV_LVL_CD,
                         PSV_COMP_CD,
                         PSV_GFR_DATE, PSV_GTO_DATE;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    점포
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-31         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-03-31
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);

    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM

    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  MSS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(MSS.STOR_CD, JDS.STOR_CD) as STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(MSS.SALE_YM, JDS.SALE_YM) as SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT / MSS.CST_BILL_CNT END AS CST_BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN (SUM(CST_BILL_CNT) OVER()) = 0 THEN 0 ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN (NVL(JDS.TOT_BILL_CNT,0) - NVL(MSS.CST_BILL_CNT,0) ) = 0 THEN 0 ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE  (NVL(JDS.TOT_GRD_AMT,0) - NVL(MSS.CST_GRD_AMT,0)) / (NVL(JDS.TOT_BILL_CNT,0) - NVL(MSS.CST_BILL_CNT,0))  END AS NCST_BILL_AMT ]'                  
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(JDS.TOT_SALE_QTY,0) - NVL(MSS.CST_SALE_QTY,0) AS NCST_SALE_QTY ]'                   
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(JDS.TOT_GRD_AMT,0) - NVL(MSS.CST_GRD_AMT,0)  AS NCST_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_SALE_QTY/JDS.TOT_SALE_QTY *100                     AS CST_SALE_RATE ]'                
        ||CHR(13)||CHR(10)||Q'[      ,  (JDS.TOT_SALE_QTY - MSS.CST_SALE_QTY)/JDS.TOT_SALE_QTY*100  AS NCST_SALE_RATE ]'       
        ||CHR(13)||CHR(10)||Q'[      ,  MSS.CST_GRD_AMT/JDS.TOT_GRD_AMT*100                        AS CST_GRD_RATE ]'     
        ||CHR(13)||CHR(10)||Q'[      ,  (JDS.TOT_GRD_AMT  - MSS.CST_GRD_AMT)/JDS.TOT_GRD_AMT*100    AS NCST_GRD_RATE ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_STORE S ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  ( ]'
        ||CHR(13)||CHR(10)||Q'[           SELECT  MSS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MSS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MSS.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MSS.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MSS.BILL_CNT)           AS CST_BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MSS.SALE_QTY)           AS CST_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MSS.GRD_AMT)            AS CST_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[             FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[                     SELECT  MSS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MSS.GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.STOR_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM ]'
        ||CHR(13)||CHR(10)||Q'[                       FROM  C_CUST_MSS MSS ]'
        ||CHR(13)||CHR(10)||Q'[                      WHERE  MSS.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  MSS.SALE_YM >= SUBSTR(:PSV_GFR_DATE, 1, 6) ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  MSS.SALE_YM <= SUBSTR(:PSV_GTO_DATE, 1, 6) ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  MSS.CUST_LVL = NVL(:PSV_LVL_CD, MSS.CUST_LVL) ]'
        ||CHR(13)||CHR(10)||Q'[                   ) MSS ]'                
        ||CHR(13)||CHR(10)||Q'[            GROUP  BY MSS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MSS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MSS.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MSS.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[         ) MSS ]'                
        ||CHR(13)||CHR(10)||Q'[      ,  ( ]'                                              
        ||CHR(13)||CHR(10)||Q'[           SELECT  :PSV_COMP_CD  AS COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  JDS.BRAND_CD ]'                    
        ||CHR(13)||CHR(10)||Q'[                ,  JDS.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUBSTR(JDS.SALE_DT, 1, 6 )  AS SALE_YM ]'   
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(JDS.BILL_CNT)           AS TOT_BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(JDS.SALE_QTY)           AS TOT_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(JDS.GRD_AMT)            AS TOT_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[             FROM  SALE_JDS JDS ]'                                                          
        ||CHR(13)||CHR(10)||Q'[            WHERE  JDS.SALE_DT  >= :PSV_GFR_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              AND  JDS.SALE_DT  <= :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[            GROUP  BY JDS.BRAND_CD ]'                              
        ||CHR(13)||CHR(10)||Q'[                ,  JDS.STOR_CD ]'                                       
        ||CHR(13)||CHR(10)||Q'[                ,  SUBSTR(JDS.SALE_DT, 1, 6 ) ]'                
        ||CHR(13)||CHR(10)||Q'[         ) JDS ]'  
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.BRAND_CD = JDS.BRAND_CD ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  S.STOR_CD  = JDS.STOR_CD ]'                
        ||CHR(13)||CHR(10)||Q'[    AND  JDS.BRAND_CD = MSS.BRAND_CD(+) ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  JDS.STOR_CD  = MSS.STOR_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  JDS.SALE_YM  = MSS.SALE_YM (+) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY NVL(MSS.STOR_CD, JDS.STOR_CD), NVL(MSS.SALE_YM, JDS.SALE_YM) ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_LVL_CD,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

    PROCEDURE SP_TAB03
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03   회원
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-31         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-03-31
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);

    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM

    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  TOT.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TOT.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TOT.SALE_YM ]'                       
        ||CHR(13)||CHR(10)||Q'[      ,  TOT.CUST_ID ]'    
        ||CHR(13)||CHR(10)||Q'[      ,  decrypt(CUST.CUST_NM) as CUST_NM ]'                                
        ||CHR(13)||CHR(10)||Q'[      ,  TOT.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITM.ITEM_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TOT.CST_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TOT.CST_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TOT.CST_DC_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TOT.CST_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_STORE S ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM ITM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C_CUST  CUST ]'                                            
        ||CHR(13)||CHR(10)||Q'[      ,  ( ]'
        ||CHR(13)||CHR(10)||Q'[           SELECT  MMS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.SALE_YM ]'                     
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.ITEM_CD ]'                
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MMS.SALE_QTY)           AS CST_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MMS.SALE_AMT)           AS CST_SALE_AMT ]'          
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MMS.DC_AMT)             AS CST_DC_AMT ]'                                              
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(MMS.GRD_AMT)            AS CST_GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[             FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[                     SELECT  MS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MS.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MS.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MS.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MS.ITEM_CD ]'                                
        ||CHR(13)||CHR(10)||Q'[                          ,  MS.SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MS.SALE_AMT ]'      
        ||CHR(13)||CHR(10)||Q'[                          ,  MS.DC_AMT + MS.ENR_AMT as DC_AMT ]'                                                
        ||CHR(13)||CHR(10)||Q'[                          ,  MS.GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                       FROM  C_CUST_MMS MS ]'
        ||CHR(13)||CHR(10)||Q'[                      WHERE  MS.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  MS.SALE_YM >= SUBSTR(:PSV_GFR_DATE, 1, 6) ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  MS.SALE_YM <= SUBSTR(:PSV_GTO_DATE, 1, 6) ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  MS.CUST_LVL = NVL(:PSV_LVL_CD, MS.CUST_LVL) ]'
        ||CHR(13)||CHR(10)||Q'[                   ) MMS ]'
        ||CHR(13)||CHR(10)||Q'[            GROUP  BY MMS.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.SALE_YM ]'        
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.CUST_ID ]'                                
        ||CHR(13)||CHR(10)||Q'[                ,  MMS.ITEM_CD ]'          
        ||CHR(13)||CHR(10)||Q'[         ) TOT ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  TOT.BRAND_CD  = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  TOT.STOR_CD   = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  TOT.CUST_ID   = CUST.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[    AND  TOT.ITEM_CD   = ITM.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY TOT.COMP_CD, TOT.STOR_CD, TOT.SALE_YM,  TOT.CUST_ID, TOT.ITEM_CD ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

         OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, 
                         PSV_GFR_DATE, PSV_GTO_DATE, PSV_LVL_CD;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

END PKG_MEAN1010;

/
