--------------------------------------------------------
--  DDL for Package Body PKG_STCK1040
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_STCK1040" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD       IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER          IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID        IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD       IN  VARCHAR2 ,                  -- Language Code
        PSV_BRAND_CD      IN  VARCHAR2 ,                  -- 영업조직
        PSV_STOR_CD       IN  VARCHAR2 ,                  -- 점포코드
        PSV_GFR_DATE      IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE      IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_ORG_CLASS     IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_ITEM_CD       IN  VARCHAR2 ,                  -- 대분류코드
        PR_RESULT         IN  OUT PKG_CURSOR.REF_CUR ,    -- Result Set,
        PR_RTN_CD         OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG        OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN   재고 수불 원장
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/

    LS_PRE_YMD      VARCHAR2(8);
    LS_BEGIN_YM     VARCHAR2(6);
    LS_COST_YM      VARCHAR2(6);
    LS_FR_DT        VARCHAR2(8);
    LS_TO_DT        VARCHAR2(8);
    LS_STOR_TP      STORE.STOR_TP%TYPE;
    LS_ERR_CD       VARCHAR2(7) ;
    LS_ERR_MSG      VARCHAR2(500) ;
    ERR_HANDLER     EXCEPTION;


    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        LS_ERR_CD   := '0' ;
        LS_PRE_YMD  := TO_CHAR(TO_DATE(PSV_GFR_DATE, 'YYYYMMDD') - 1, 'YYYYMMDD');
        LS_BEGIN_YM := SUBSTR(PSV_GFR_DATE, 1, 6);
        LS_COST_YM  := SUBSTR(PSV_GTO_DATE, 1, 6);
        LS_FR_DT    := LS_BEGIN_YM || '01';
        LS_TO_DT    := PSV_GTO_DATE;

        IF PSV_STOR_CD IS NOT NULL THEN
            BEGIN
                SELECT  S.STOR_TP
                  INTO  LS_STOR_TP
                  FROM  STORE S
                 WHERE  S.COMP_CD  = PSV_COMP_CD
                   AND  S.BRAND_CD = PSV_BRAND_CD
                   AND  S.STOR_CD  = PSV_STOR_CD;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        LS_ERR_CD  := '4000002' ;
                        LS_ERR_MSG := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , LS_ERR_CD) ;
                        RAISE ERR_HANDLER ;

                    WHEN OTHERS THEN
                        LS_ERR_CD := '4999999' ;
                        LS_ERR_MSG := SQLERRM ;
                        RAISE ERR_HANDLER ;
            END;
        ELSE
            LS_STOR_TP := '10';
        END IF;

    OPEN PR_RESULT FOR
        SELECT  V01.COMP_CD
             ,  V01.BRAND_CD
             ,  V01.ITEM_CD
             ,  V01.ITEM_NM
             ,  V01.ANAL_SLIP_CD
             ,  V01.ANAL_SLIP_NM
             ,  V01.SLIP_DIV_CD
             ,  V01.SLIP_DIV_NM
             ,  V01.SLIP_DT
             ,  V01.SLIP_NO
             ,  V01.CUR_STOCK_QTY
             ,  V01.CUR_STOCK_AMT
             ,  V01.END_STOCK_QTY
             ,  V01.END_STOCK_AMT
             ,  V01.VENDOR_CD
             ,  V01.VENDOR_NM
        FROM   (
                SELECT  Z.COMP_CD
                     ,  Z.BRAND_CD
                     ,  Z.ITEM_CD
                     ,  Z.ITEM_NM
                     ,  Z.ANAL_SLIP_CD
                     ,  Z.ANAL_SLIP_NM
                     ,  Z.SLIP_DIV_CD
                     ,  Z.SLIP_DIV_NM
                     ,  Z.SLIP_DT
                     ,  Z.SLIP_NO
                     ,  Z.CUR_STOCK_QTY
                     ,  Z.CUR_STOCK_AMT
                     ,  SUM(Z.CUR_STOCK_QTY) OVER(ORDER BY Z.SLIP_DT, Z.ANAL_SLIP_CD, Z.SLIP_DIV_CD, Z.SLIP_NO) AS END_STOCK_QTY
                     ,  SUM(Z.CUR_STOCK_AMT) OVER(ORDER BY Z.SLIP_DT, Z.ANAL_SLIP_CD, Z.SLIP_DIV_CD, Z.SLIP_NO) AS END_STOCK_AMT
                     ,  Z.VENDOR_CD
                     ,  Z.VENDOR_NM
                FROM   (
                        SELECT  S.COMP_CD
                             ,  S.BRAND_CD
                             ,  S.ITEM_CD
                             ,  S.ITEM_NM              AS ITEM_NM
                             ,  '01'                                                    AS ANAL_SLIP_CD
                             ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01915', '01', PSV_LANG_CD)  AS ANAL_SLIP_NM
                             ,  '01'                                                    AS SLIP_DIV_CD
                             ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01900', '01', PSV_LANG_CD)  AS SLIP_DIV_NM
                             ,  LS_PRE_YMD                                              AS SLIP_DT
                             ,  ''                                                      AS SLIP_NO
                             ,  S.BEGIN_QTY + S.PRE_STOCK_QTY                           AS CUR_STOCK_QTY
                             ,  S.BEGIN_AMT + S.PRE_STOCK_AMT                           AS CUR_STOCK_AMT
                             ,  '' AS VENDOR_CD
                             ,  '' AS VENDOR_NM
                        FROM   (
                                SELECT  D.COMP_CD
                                     ,  D.BRAND_CD
                                     ,  D.STOR_CD
                                     ,  D.ITEM_CD
                                     ,  MAX(I.ITEM_NM)                                              AS ITEM_NM
                                     ,  SUM(D.BEGIN_QTY)                                            AS BEGIN_QTY
                                     ,  SUM(D.BEGIN_QTY * I.SALE_PRC)                               AS BEGIN_AMT
                                     ,  SUM(D.PRE_INOUT_QTY - D.PRE_FREE_QTY - D.PRE_DSA_QTY)       AS PRE_STOCK_QTY
                                     ,  SUM((D.PRE_INOUT_QTY - D.PRE_FREE_QTY - D.PRE_DSA_QTY) * I.SALE_PRC)
                                                                                                    AS PRE_STOCK_AMT
                                FROM   (
                                        SELECT  /*+ USE_NL(I, IC L) */
                                                I.COMP_CD
                                             ,  I.BRAND_CD
                                             ,  I.ITEM_CD
                                             ,  NVL(L.ITEM_NM , I.ITEM_NM)      AS ITEM_NM
                                             ,  NVL(H.SALE_PRC, I.SALE_PRC)     AS SALE_PRC
                                             ,  I.ORD_UNIT_QTY
                                        FROM    ITEM_CHAIN      I
                                             ,  LANG_ITEM       L
                                             , (SELECT  COMP_CD
                                                      , BRAND_CD
                                                      , STOR_TP
                                                      , ITEM_CD
                                                      , SALE_PRC
                                                FROM    ITEM_CHAIN_HIS
                                                WHERE   COMP_CD    = PSV_COMP_CD
                                                AND     BRAND_CD   = PSV_BRAND_CD
                                                AND     ITEM_CD    = PSV_ITEM_CD
                                                AND     STOR_TP    = LS_STOR_TP
                                                AND     LS_PRE_YMD BETWEEN START_DT AND CLOSE_DT
                                                AND     ROWNUM     = 1
                                               ) H
                                        WHERE   I.COMP_CD           = L.COMP_CD (+)
                                        AND     I.ITEM_CD           = L.ITEM_CD (+)
                                        AND     I.COMP_CD           = H.COMP_CD (+)
                                        AND     I.BRAND_CD          = H.BRAND_CD(+)
                                        AND     I.STOR_TP           = H.STOR_TP (+)
                                        AND     I.ITEM_CD           = H.ITEM_CD (+)
                                        AND     I.COMP_CD           = PSV_COMP_CD
                                        AND     I.BRAND_CD          = PSV_BRAND_CD
                                        AND     I.ITEM_CD           = PSV_ITEM_CD
                                        AND     I.STOR_TP           = LS_STOR_TP
                                        AND     L.LANGUAGE_TP  (+)  = PSV_LANG_CD
                                        AND     L.USE_YN       (+)  = 'Y'
                                       )               I
                                     , (
                                        SELECT  A.COMP_CD
                                             ,  A.BRAND_CD
                                             ,  A.STOR_CD
                                             ,  A.ITEM_CD
                                             ,  0                                                                           AS BEGIN_QTY
                                             ,  0                                                                           AS BEGIN_AMT
                                             ,  SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.ORD_QTY         ELSE 0 END) 
                                              + SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.PROD_IN_QTY     ELSE 0 END)
                                              + SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.MV_IN_QTY       ELSE 0 END)
                                              + SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.ETC_IN_QTY      ELSE 0 END)
                                              - SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.SALE_QTY        ELSE 0 END)
                                              - SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.PROD_OUT_QTY    ELSE 0 END)
                                              - SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.MV_OUT_QTY      ELSE 0 END)
                                              - SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.ETC_OUT_QTY     ELSE 0 END)  
                                              - SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.RTN_QTY         ELSE 0 END)      
                                              - SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.DISUSE_QTY      ELSE 0 END)
                                              + SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.ADJ_QTY         ELSE 0 END)   AS PRE_INOUT_QTY
                                             ,  0                                                                           AS PRE_FREE_QTY
                                             ,  0                                                                           AS PRE_DSA_QTY
                                        FROM    ITEM_CHAIN      I
                                             ,  DSTOCK          A
                                        WHERE   I.COMP_CD       = A.COMP_CD
                                        AND     I.BRAND_CD      = A.BRAND_CD
                                        AND     I.ITEM_CD       = A.ITEM_CD
                                        AND     I.STOR_TP       = LS_STOR_TP
                                        AND     A.COMP_CD      = PSV_COMP_CD
                                        AND     A.BRAND_CD     = PSV_BRAND_CD
                                        AND     A.STOR_CD      = PSV_STOR_CD
                                        AND     A.PRC_DT       < PSV_GFR_DATE
                                        AND     A.PRC_DT    LIKE LS_BEGIN_YM||'%' 
                                        GROUP  BY 
                                                A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.ITEM_CD
                                        UNION ALL
                                        SELECT  A.COMP_CD
                                             ,  A.BRAND_CD
                                             ,  A.STOR_CD
                                             ,  A.ITEM_CD
                                             ,  A.BEGIN_QTY
                                             ,  A.BEGIN_AMT
                                             ,  0           AS PRE_INOUT_QTY
                                             ,  0           AS PRE_FREE_QTY
                                             ,  0           AS PRE_DSA_QTY
                                        FROM    ITEM_CHAIN  I
                                             ,  MSTOCK      A  
                                        WHERE   I.COMP_CD   = A.COMP_CD
                                        AND     I.BRAND_CD  = A.BRAND_CD
                                        AND     I.ITEM_CD   = A.ITEM_CD
                                        AND     I.STOR_TP   = LS_STOR_TP
                                        AND     A.COMP_CD   = PSV_COMP_CD
                                        AND     A.BRAND_CD  = PSV_BRAND_CD
                                        AND     A.STOR_CD   = PSV_STOR_CD
                                        AND     A.PRC_YM    = LS_BEGIN_YM
                                        UNION ALL
                                        SELECT  A.COMP_CD
                                             ,  A.BRAND_CD
                                             ,  A.STOR_CD
                                             ,  A.ITEM_CD
                                             ,  0           AS BEGIN_QTY
                                             ,  0           AS BEGIN_AMT
                                             ,  0           AS PRE_INOUT_QTY
                                             ,  SUM(CASE WHEN A.SALE_DT < PSV_GFR_DATE THEN  A.SALE_QTY ELSE 0 END)   AS PRE_FREE_QTY
                                             ,  0           AS PRE_DSA_QTY
                                        FROM    SALE_JDF    A
                                        WHERE   A.COMP_CD    = PSV_COMP_CD
                                        AND     A.SALE_DT    < PSV_GFR_DATE
                                        AND     A.SALE_DT LIKE LS_BEGIN_YM||'%' 
                                        AND     A.BRAND_CD   = PSV_BRAND_CD
                                        AND     A.STOR_CD    = PSV_STOR_CD
                                        AND     A.ITEM_CD    = PSV_ITEM_CD
                                        GROUP  BY 
                                                A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.ITEM_CD
                                        UNION ALL
                                        SELECT  A.COMP_CD
                                             ,  A.BRAND_CD
                                             ,  A.STOR_CD
                                             ,  A.ITEM_CD   AS ITEM_CD
                                             ,  0           AS BEGIN_QTY
                                             ,  0           AS BEGIN_AMT
                                             ,  0           AS PRE_INOUT_QTY
                                             ,  0           AS PRE_FREE_QTY
                                             ,  SUM(CASE WHEN A.ADJ_DT < PSV_GFR_DATE THEN  A.ADJ_QTY ELSE 0 END)   AS PRE_DSA_QTY
                                        FROM    DSTOCK_ADJ    A
                                        WHERE   A.COMP_CD    = PSV_COMP_CD
                                        AND     A.ADJ_DT    < PSV_GFR_DATE
                                        AND     A.ADJ_DT LIKE LS_BEGIN_YM||'%' 
                                        AND     A.BRAND_CD   = PSV_BRAND_CD
                                        AND     A.STOR_CD    = PSV_STOR_CD
                                        AND     A.ITEM_CD    = PSV_ITEM_CD
                                        GROUP  BY 
                                                A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.ITEM_CD
                                        )               D
                                WHERE   D.COMP_CD   = I.COMP_CD
                                AND     D.ITEM_CD   = I.ITEM_CD
                                GROUP  BY 
                                        D.COMP_CD
                                     ,  D.BRAND_CD
                                     ,  D.STOR_CD
                                     ,  D.ITEM_CD
                               ) S
                        UNION ALL       -- ▼ 주문반품 주문/반품 순▼
                        SELECT  D.COMP_CD
                             ,  D.BRAND_CD
                             ,  D.ITEM_CD
                             ,  I.ITEM_NM                                              AS ITEM_NM
                             ,  D.ANAL_SLIP_CD
                             ,  D.ANAL_SLIP_NM
                             ,  D.SLIP_DIV_CD
                             ,  D.SLIP_DIV_NM
                             ,  D.SLIP_DT
                             ,  D.SLIP_NO
                             ,  D.CUR_STOCK_QTY
                             ,  D.CUR_STOCK_AMT
                             ,  D.VENDOR_CD
                             ,  D.VENDOR_NM
                         FROM  (
                                SELECT  /*+ USE_NL(I, IC L) */
                                        I.COMP_CD
                                     ,  I.BRAND_CD
                                     ,  I.ITEM_CD
                                     ,  NVL(L.ITEM_NM, I.ITEM_NM)           AS ITEM_NM
                                     ,  I.STANDARD
                                     ,  I.STOCK_UNIT
                                     ,  I.ORD_UNIT_QTY
                                FROM    ITEM_CHAIN      I
                                     ,  LANG_ITEM       L
                                WHERE   I.COMP_CD           = L.COMP_CD(+)
                                AND     I.ITEM_CD           = L.ITEM_CD(+)
                                AND     I.COMP_CD           = PSV_COMP_CD
                                AND     I.BRAND_CD          = PSV_BRAND_CD
                                AND     I.ITEM_CD           = PSV_ITEM_CD
                                AND     I.STOR_TP           = LS_STOR_TP
                                AND     L.LANGUAGE_TP(+)    = PSV_LANG_CD
                                AND     L.USE_YN(+)         = 'Y'
                               )               I
                            ,  (
                                SELECT  A.COMP_CD
                                     ,  A.BRAND_CD
                                     ,  A.STOR_CD
                                     ,  A.ITEM_CD
                                     ,  '02'                                                    AS ANAL_SLIP_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01915', '02', PSV_LANG_CD)  AS ANAL_SLIP_NM
                                     ,  '02'                                                    AS SLIP_DIV_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01900', '02', PSV_LANG_CD)  AS SLIP_DIV_NM
                                     ,  A.STK_DT                                                AS SLIP_DT
                                     ,  A.ORD_NO                                                AS SLIP_NO 
                                     ,  A.ORD_UNIT_QTY * A.ORD_CQTY                             AS CUR_STOCK_QTY
                                     ,  CASE WHEN NVL(B.PARA_VAL, '1') = '1' THEN NVL(A.ORD_CAMT, 0) + NVL(A.ORD_CVAT, 0) 
                                             ELSE NVL(A.ORD_CAMT, 0) END                        AS CUR_STOCK_AMT
                                     ,  A.VENDOR_CD                                             AS VENDOR_CD
                                     ,  S.STOR_NM                                               AS VENDOR_NM
                                FROM    ORDER_DTV       A
                                     ,  STORE           S
                                     ,  PARA_BRAND      B
                                WHERE   A.COMP_CD    = S.COMP_CD (+)
                                AND     A.BRAND_CD   = S.BRAND_CD(+)
                                AND     A.VENDOR_CD  = S.STOR_CD (+)
                                AND     A.COMP_CD    = B.COMP_CD (+)
                                AND     A.BRAND_CD   = B.BRAND_CD(+)
                                AND     '0017'       = B.PARA_CD (+) -- 매입 부가세설정[1:부가세포함, 2:부가세미포함]
                                AND     A.COMP_CD    = PSV_COMP_CD
                                AND     A.BRAND_CD   = PSV_BRAND_CD
                                AND     A.STOR_CD    = PSV_STOR_CD
                                AND     A.ITEM_CD    = PSV_ITEM_CD
                                AND     A.ORD_FG     = '1' -- 주문
                                AND     A.STK_DT     BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                                UNION ALL
                                SELECT  A.COMP_CD
                                     ,  A.BRAND_CD
                                     ,  A.STOR_CD
                                     ,  A.ITEM_CD
                                     ,  '02'                                                    AS ANAL_SLIP_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01915', '02', PSV_LANG_CD)  AS ANAL_SLIP_NM
                                     ,  '03'                                                    AS SLIP_DIV_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01900', '03', PSV_LANG_CD)  AS SLIP_DIV_NM
                                     ,  A.STK_DT                                                AS SLIP_DT
                                     ,  A.ORD_NO                                                AS SLIP_NO 
                                     ,  A.ORD_UNIT_QTY * A.ORD_CQTY * (-1)                      AS CUR_STOCK_QTY
                                     ,  CASE WHEN NVL(B.PARA_VAL, '1') = '1' THEN NVL(A.ORD_CAMT, 0) + NVL(A.ORD_CVAT, 0) 
                                             ELSE NVL(A.ORD_CAMT, 0) END * (-1)                 AS CUR_STOCK_AMT
                                     ,  A.VENDOR_CD                                             AS VENDOR_CD
                                     ,  S.STOR_NM                                               AS VENDOR_NM
                                FROM    ORDER_DTV       A
                                     ,  STORE           S
                                     ,  PARA_BRAND      B
                                WHERE   A.COMP_CD    = S.COMP_CD (+)
                                AND     A.BRAND_CD   = S.BRAND_CD(+)
                                AND     A.VENDOR_CD  = S.STOR_CD (+)
                                AND     A.COMP_CD    = B.COMP_CD (+)
                                AND     A.BRAND_CD   = B.BRAND_CD(+)
                                AND     '0017'       = B.PARA_CD (+) -- 매입 부가세설정[1:부가세포함, 2:부가세미포함]
                                AND     A.COMP_CD    = PSV_COMP_CD
                                AND     A.BRAND_CD   = PSV_BRAND_CD
                                AND     A.STOR_CD    = PSV_STOR_CD
                                AND     A.ITEM_CD    = PSV_ITEM_CD
                                AND     A.ORD_FG     = '2' -- 주문
                                AND     A.STK_DT     BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                               ) D
                        WHERE   I.COMP_CD  = D.COMP_CD
                        AND     I.BRAND_CD = D.BRAND_CD
                        AND     I.ITEM_CD  = D.ITEM_CD 
                        UNION ALL       -- ▼ 점간이동 입고/출고 순▼
                        SELECT  D.COMP_CD
                             ,  D.BRAND_CD
                             ,  D.ITEM_CD
                             ,  I.ITEM_NM                                              AS ITEM_NM
                             ,  D.ANAL_SLIP_CD
                             ,  D.ANAL_SLIP_NM
                             ,  D.SLIP_DIV_CD
                             ,  D.SLIP_DIV_NM
                             ,  D.SLIP_DT
                             ,  D.SLIP_NO
                             ,  D.CUR_STOCK_QTY
                             ,  D.CUR_STOCK_AMT
                             ,  D.VENDOR_CD
                             ,  D.VENDOR_NM
                         FROM  (
                                SELECT  /*+ USE_NL(I, IC L) */
                                        I.COMP_CD
                                     ,  I.BRAND_CD
                                     ,  I.ITEM_CD
                                     ,  NVL(L.ITEM_NM, I.ITEM_NM)           AS ITEM_NM
                                     ,  I.STANDARD
                                     ,  I.STOCK_UNIT
                                     ,  I.ORD_UNIT_QTY
                                FROM    ITEM_CHAIN      I
                                     ,  LANG_ITEM       L
                                WHERE   I.COMP_CD           = L.COMP_CD(+)
                                AND     I.ITEM_CD           = L.ITEM_CD(+)
                                AND     I.COMP_CD           = PSV_COMP_CD
                                AND     I.BRAND_CD          = PSV_BRAND_CD
                                AND     I.ITEM_CD           = PSV_ITEM_CD
                                AND     I.STOR_TP           = LS_STOR_TP
                                AND     L.LANGUAGE_TP(+)    = PSV_LANG_CD
                                AND     L.USE_YN(+)         = 'Y'
                               )               I
                            ,  (
                                SELECT  A.COMP_CD
                                     ,  A.OUT_BRAND_CD                                          AS BRAND_CD
                                     ,  A.OUT_STOR_CD                                           AS STOR_CD
                                     ,  A.ITEM_CD
                                     ,  '03'                                                    AS ANAL_SLIP_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01915', '03', PSV_LANG_CD)  
                                                                                                AS ANAL_SLIP_NM
                                     ,  '04'                                                    AS SLIP_DIV_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01900', '04', PSV_LANG_CD)  
                                                                                                AS SLIP_DIV_NM
                                     ,  A.IN_CONF_DT                                            AS SLIP_DT
                                     ,  A.SEQ                                                   AS SLIP_NO 
                                     ,  A.MV_UNIT_QTY * A.MV_CQTY                               AS CUR_STOCK_QTY
                                     ,  CASE WHEN NVL(B.PARA_VAL, '1') = '1' THEN NVL(A.IN_COST_AMT, 0) + NVL(A.IN_COST_VAT, 0) 
                                             ELSE NVL(A.IN_COST_AMT, 0) END                     AS CUR_STOCK_AMT
                                     ,  A.OUT_STOR_CD                                           AS VENDOR_CD
                                     ,  S.STOR_NM                                               AS VENDOR_NM
                                FROM    MOVE_STORE      A
                                     ,  STORE           S
                                     ,  PARA_BRAND      B
                                WHERE   A.COMP_CD     = S.COMP_CD (+)
                                AND     A.OUT_BRAND_CD= S.BRAND_CD(+)
                                AND     A.OUT_STOR_CD = S.STOR_CD (+)
                                AND     A.COMP_CD     = B.COMP_CD (+)
                                AND     A.IN_BRAND_CD = B.BRAND_CD(+)
                                AND     '0017'        = B.PARA_CD (+) -- 매입 부가세설정[1:부가세포함, 2:부가세미포함]
                                AND     A.COMP_CD     = PSV_COMP_CD
                                AND     A.IN_BRAND_CD = PSV_BRAND_CD
                                AND     A.IN_STOR_CD  = PSV_STOR_CD
                                AND     A.ITEM_CD     = PSV_ITEM_CD
                                AND     A.CONFIRM_DIV IN ('3', '4') -- 입고확정
                                AND     A.IN_CONF_DT  BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                                UNION ALL
                                SELECT  A.COMP_CD
                                     ,  A.OUT_BRAND_CD                                          AS BRNAD_CD
                                     ,  A.OUT_STOR_CD                                           AS STOR_CD
                                     ,  A.ITEM_CD
                                     ,  '03'                                                    AS ANAL_SLIP_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01915', '03', PSV_LANG_CD)  
                                                                                                AS ANAL_SLIP_NM
                                     ,  '05'                                                    AS SLIP_DIV_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01900', '05', PSV_LANG_CD)  
                                                                                                AS SLIP_DIV_NM
                                     ,  A.OUT_CONF_DT                                           AS SLIP_DT
                                     ,  A.SEQ                                                   AS SLIP_NO 
                                     ,  A.MV_UNIT_QTY * A.MV_QTY * (-1)                         AS CUR_STOCK_QTY
                                     ,  CASE WHEN NVL(B.PARA_VAL, '1') = '1' THEN NVL(A.OUT_COST_AMT, 0) + NVL(A.OUT_COST_VAT, 0) 
                                             ELSE NVL(A.OUT_COST_AMT, 0) END * (-1)             AS CUR_STOCK_AMT
                                     ,  A.IN_STOR_CD                                            AS VENDOR_CD
                                     ,  S.STOR_NM                                               AS VENDOR_NM
                                FROM    MOVE_STORE      A
                                     ,  STORE           S
                                     ,  PARA_BRAND      B
                                WHERE   A.COMP_CD     = S.COMP_CD (+)
                                AND     A.IN_BRAND_CD = S.BRAND_CD(+)
                                AND     A.IN_STOR_CD  = S.STOR_CD (+)
                                AND     A.COMP_CD     = B.COMP_CD (+)
                                AND     A.OUT_BRAND_CD= B.BRAND_CD(+)
                                AND     '0017'        = B.PARA_CD (+) -- 매입 부가세설정[1:부가세포함, 2:부가세미포함]
                                AND     A.COMP_CD     = PSV_COMP_CD
                                AND     A.OUT_BRAND_CD= PSV_BRAND_CD
                                AND     A.OUT_STOR_CD = PSV_STOR_CD
                                AND     A.ITEM_CD     = PSV_ITEM_CD
                                AND     A.CONFIRM_DIV IN ('2', '4') -- 출고확정
                                AND     A.OUT_CONF_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                               ) D
                        WHERE   I.COMP_CD  = D.COMP_CD
                        AND     I.BRAND_CD = D.BRAND_CD
                        AND     I.ITEM_CD  = D.ITEM_CD
                        UNION ALL       -- ▼ 상품판매 ▼
                        SELECT  D.COMP_CD
                             ,  D.BRAND_CD
                             ,  D.ITEM_CD
                             ,  I.ITEM_NM
                             ,  D.ANAL_SLIP_CD
                             ,  D.ANAL_SLIP_NM
                             ,  D.SLIP_DIV_CD
                             ,  D.SLIP_DIV_NM
                             ,  D.SLIP_DT
                             ,  D.SLIP_NO
                             ,  D.CUR_STOCK_QTY
                             ,  D.CUR_STOCK_AMT
                             ,  '' AS VENDOR_CD
                             ,  '' AS VENDOR_NM
                         FROM  (
                                SELECT  /*+ USE_NL(I, IC L) */
                                        I.COMP_CD
                                     ,  I.BRAND_CD
                                     ,  I.ITEM_CD
                                     ,  NVL(L.ITEM_NM, I.ITEM_NM)           AS ITEM_NM
                                     ,  I.STANDARD
                                     ,  I.STOCK_UNIT
                                     ,  I.ORD_UNIT_QTY
                                FROM    ITEM_CHAIN      I
                                     ,  LANG_ITEM       L
                                WHERE   I.COMP_CD           = L.COMP_CD(+)
                                AND     I.ITEM_CD           = L.ITEM_CD(+)
                                AND     I.COMP_CD           = PSV_COMP_CD
                                AND     I.BRAND_CD          = PSV_BRAND_CD
                                AND     I.ITEM_CD           = PSV_ITEM_CD
                                AND     I.STOR_TP           = LS_STOR_TP
                                AND     L.LANGUAGE_TP(+)    = PSV_LANG_CD
                                AND     L.USE_YN(+)         = 'Y'
                               )               I
                            ,  (
                                SELECT  A.COMP_CD
                                     ,  A.BRAND_CD
                                     ,  A.STOR_CD
                                     ,  A.ITEM_CD
                                     ,  '04'                                                    AS ANAL_SLIP_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01915', '04', PSV_LANG_CD)  
                                                                                                AS ANAL_SLIP_NM
                                     ,  DECODE(A.SALE_DIV, '1', '06', '07')                     AS SLIP_DIV_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01900', DECODE(A.SALE_DIV, '1', '06', '07'), PSV_LANG_CD)  
                                                                                                AS SLIP_DIV_NM
                                     ,  A.SALE_DT                                               AS SLIP_DT
                                     ,  A.POS_NO||'-'||A.BILL_NO                                AS SLIP_NO
                                     ,  A.SALE_QTY * (-1)                                       AS CUR_STOCK_QTY
                                     ,  A.GRD_AMT  * (-1)                                       AS CUR_STOCK_AMT
                                FROM    ITEM_CHAIN      I
                                     ,  SALE_DT         A
                                WHERE   I.COMP_CD     = A.COMP_CD
                                AND     I.BRAND_CD    = A.BRAND_CD
                                AND     I.ITEM_CD     = A.ITEM_CD
                                AND     I.STOR_TP     = LS_STOR_TP
                                AND     A.COMP_CD     = PSV_COMP_CD
                                AND     A.BRAND_CD    = PSV_BRAND_CD
                                AND     A.STOR_CD     = PSV_STOR_CD
                                AND     A.ITEM_CD     = PSV_ITEM_CD
                                AND     A.SALE_DT     BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                               ) D
                        WHERE   I.COMP_CD  = D.COMP_CD
                        AND     I.BRAND_CD = D.BRAND_CD
                        AND     I.ITEM_CD  = D.ITEM_CD
                        UNION ALL       -- ▼ 비용 출고 ▼
                        SELECT  D.COMP_CD
                             ,  D.BRAND_CD
                             ,  D.ITEM_CD
                             ,  I.ITEM_NM
                             ,  D.ANAL_SLIP_CD
                             ,  D.ANAL_SLIP_NM
                             ,  D.SLIP_DIV_CD
                             ,  D.SLIP_DIV_NM
                             ,  D.SLIP_DT
                             ,  D.SLIP_NO
                             ,  D.CUR_STOCK_QTY
                             ,  D.CUR_STOCK_AMT
                             ,  '' AS VENDOR_CD
                             ,  '' AS VENDOR_NM
                         FROM  (
                                SELECT  /*+ USE_NL(I, IC L) */
                                        I.COMP_CD
                                     ,  I.BRAND_CD
                                     ,  I.ITEM_CD
                                     ,  NVL(L.ITEM_NM, I.ITEM_NM)           AS ITEM_NM
                                     ,  I.ORD_UNIT_QTY
                                FROM    ITEM_CHAIN      I
                                     ,  LANG_ITEM       L
                                WHERE   I.COMP_CD           = L.COMP_CD(+)
                                AND     I.ITEM_CD           = L.ITEM_CD(+)
                                AND     I.COMP_CD           = PSV_COMP_CD
                                AND     I.BRAND_CD          = PSV_BRAND_CD
                                AND     I.ITEM_CD           = PSV_ITEM_CD
                                AND     I.STOR_TP           = LS_STOR_TP
                                AND     L.LANGUAGE_TP(+)    = PSV_LANG_CD
                                AND     L.USE_YN(+)         = 'Y'
                               )               I
                            ,  (
                                SELECT  A.COMP_CD
                                     ,  A.BRAND_CD
                                     ,  A.STOR_CD
                                     ,  A.ITEM_CD
                                     ,  '05'                                                    AS ANAL_SLIP_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01915', '05', PSV_LANG_CD)  
                                                                                                AS ANAL_SLIP_NM
                                     ,  '08'                                                    AS SLIP_DIV_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01900', '08', PSV_LANG_CD)  
                                                                                                AS SLIP_DIV_NM
                                     ,  A.SALE_DT                                               AS SLIP_DT
                                     ,  ''                                                      AS SLIP_NO 
                                     ,  A.SALE_QTY * (-1)                                       AS CUR_STOCK_QTY
                                     ,  NVL(H.SALE_PRC, I.SALE_PRC) * A.SALE_QTY  * (-1)        AS CUR_STOCK_AMT
                                     ,  A.FREE_DIV                                              AS VENDOR_CD
                                     ,  FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'FREE_DIV')||
                                        '['||GET_COMMON_CODE_NM(PSV_COMP_CD, '00460', A.FREE_DIV, PSV_LANG_CD)||']' 
                                                                                                AS VENDOR_NM
                                FROM    ITEM_CHAIN      I
                                     ,  SALE_JDF        A
                                     , (
                                        SELECT  COMP_CD
                                              , BRAND_CD
                                              , STOR_TP
                                              , ITEM_CD
                                              , SALE_PRC
                                        FROM    ITEM_CHAIN_HIS
                                        WHERE   COMP_CD    = PSV_COMP_CD
                                        AND     BRAND_CD   = PSV_BRAND_CD
                                        AND     ITEM_CD    = PSV_ITEM_CD
                                        AND     STOR_TP    = LS_STOR_TP
                                        AND     LS_PRE_YMD BETWEEN START_DT AND CLOSE_DT
                                        AND     ROWNUM     = 1
                                       ) H
                                WHERE   I.COMP_CD     = A.COMP_CD
                                AND     I.BRAND_CD    = A.BRAND_CD
                                AND     I.ITEM_CD     = A.ITEM_CD
                                AND     A.COMP_CD     = H.COMP_CD (+)
                                AND     A.BRAND_CD    = H.BRAND_CD(+)
                                AND     LS_STOR_TP    = H.STOR_TP (+)
                                AND     A.ITEM_CD     = H.ITEM_CD (+)
                                AND     I.STOR_TP     = LS_STOR_TP
                                AND     A.COMP_CD     = PSV_COMP_CD
                                AND     A.BRAND_CD    = PSV_BRAND_CD
                                AND     A.STOR_CD     = PSV_STOR_CD
                                AND     A.ITEM_CD     = PSV_ITEM_CD
                                AND     A.SALE_DT     BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                               ) D
                        WHERE   I.COMP_CD  = D.COMP_CD
                        AND     I.BRAND_CD = D.BRAND_CD
                        AND     I.ITEM_CD  = D.ITEM_CD
                        UNION ALL       -- ▼ 원자재 비용 출고 ▼
                        SELECT  D.COMP_CD
                             ,  D.BRAND_CD
                             ,  D.ITEM_CD
                             ,  I.ITEM_NM
                             ,  D.ANAL_SLIP_CD
                             ,  D.ANAL_SLIP_NM
                             ,  D.SLIP_DIV_CD
                             ,  D.SLIP_DIV_NM
                             ,  D.SLIP_DT
                             ,  D.SLIP_NO
                             ,  D.CUR_STOCK_QTY
                             ,  D.CUR_STOCK_AMT
                             ,  D.VENDOR_CD
                             ,  D.VENDOR_NM
                         FROM  (
                                SELECT  /*+ USE_NL(I, IC L) */
                                        I.COMP_CD
                                     ,  I.BRAND_CD
                                     ,  I.ITEM_CD
                                     ,  NVL(L.ITEM_NM, I.ITEM_NM)           AS ITEM_NM
                                     ,  I.STANDARD
                                     ,  I.STOCK_UNIT
                                     ,  I.ORD_UNIT_QTY
                                FROM    ITEM_CHAIN      I
                                     ,  LANG_ITEM       L
                                WHERE   I.COMP_CD           = L.COMP_CD(+)
                                AND     I.ITEM_CD           = L.ITEM_CD(+)
                                AND     I.COMP_CD           = PSV_COMP_CD
                                AND     I.BRAND_CD          = PSV_BRAND_CD
                                AND     I.ITEM_CD           = PSV_ITEM_CD
                                AND     I.STOR_TP           = LS_STOR_TP
                                AND     L.LANGUAGE_TP(+)    = PSV_LANG_CD
                                AND     L.USE_YN(+)         = 'Y'
                               )               I
                            ,  (
                                SELECT  A.COMP_CD
                                     ,  A.BRAND_CD
                                     ,  A.STOR_CD
                                     ,  A.ITEM_CD
                                     ,  '06'                                                    AS ANAL_SLIP_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01915', '06', PSV_LANG_CD)  
                                                                                                AS ANAL_SLIP_NM
                                     ,  '09'                                                    AS SLIP_DIV_CD
                                     ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01900', '09', PSV_LANG_CD)  
                                                                                                AS SLIP_DIV_NM
                                     ,  A.ADJ_DT                                                AS SLIP_DT
                                     ,  ''                                                      AS SLIP_NO
                                     ,  A.ADJ_QTY * (-1)                                        AS CUR_STOCK_QTY
                                     ,  A.ADJ_AMT * (-1)                                        AS CUR_STOCK_AMT
                                     ,  A.ADJ_DIV                                               AS VENDOR_CD
                                     ,  FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'USE_TYPE')||
                                        '['||GET_COMMON_CODE_NM(PSV_COMP_CD, '01245', A.ADJ_DIV, PSV_LANG_CD)||']' 
                                                                                                AS VENDOR_NM
                                FROM    ITEM_CHAIN      I
                                     , (
                                        SELECT  COMP_CD
                                              , BRAND_CD
                                              , STOR_CD
                                              , ITEM_CD
                                              , ADJ_DT
                                              , ADJ_DIV
                                              , SUM(ADJ_QTY) AS ADJ_QTY
                                              , SUM(ADJ_AMT) AS ADJ_AMT
                                        FROM    DSTOCK_ADJ
                                        WHERE   COMP_CD     = PSV_COMP_CD
                                        AND     ADJ_DT      BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                                        AND     BRAND_CD    = PSV_BRAND_CD
                                        AND     STOR_CD     = PSV_STOR_CD
                                        AND     ITEM_CD     = PSV_ITEM_CD
                                        GROUP BY
                                                COMP_CD
                                              , BRAND_CD
                                              , STOR_CD
                                              , ITEM_CD
                                              , ADJ_DT
                                              , ADJ_DIV
                                       ) A
                                WHERE   I.COMP_CD     = A.COMP_CD
                                AND     I.BRAND_CD    = A.BRAND_CD
                                AND     I.ITEM_CD     = A.ITEM_CD
                                ) D
                        WHERE   I.COMP_CD  = D.COMP_CD
                        AND     I.BRAND_CD = D.BRAND_CD
                        AND     I.ITEM_CD  = D.ITEM_CD                       
                       ) Z
               ) V01
        ORDER BY
                V01.COMP_CD
             ,  V01.BRAND_CD
             ,  V01.ITEM_CD
             ,  V01.SLIP_DT
             ,  V01.ANAL_SLIP_CD
             ,  V01.SLIP_DIV_CD
             ,  V01.SLIP_NO;

    PR_RTN_CD  := LS_ERR_CD;
    PR_RTN_MSG := LS_ERR_MSG ;
    dbms_output.put_line( 'SUCCESS') ;

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := LS_ERR_CD;
            PR_RTN_MSG := LS_ERR_MSG ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    END;

END PKG_STCK1040;

/
