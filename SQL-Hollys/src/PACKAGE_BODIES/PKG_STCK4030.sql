--------------------------------------------------------
--  DDL for Package Body PKG_STCK4030
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_STCK4030" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD       IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER          IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID        IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD       IN  VARCHAR2 ,                  -- Language Code
        PSV_BRAND_CD      IN  VARCHAR2 ,                  -- 영업조직
        PSV_STOR_CD       IN  VARCHAR2 ,                  -- 점포코드
        PSV_YMD           IN  VARCHAR2 ,                  -- 조회일자
        PSV_ORG_CLASS     IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_L_CLASS_CD    IN  VARCHAR2 ,                  -- 대분류코드
        PSV_M_CLASS_CD    IN  VARCHAR2 ,                  -- 중분류코드
        PSV_S_CLASS_CD    IN  VARCHAR2 ,                  -- 소분류코드
        PSV_ORD_SALE_DIV  IN  VARCHAR2 ,                  -- 주문/판매
        PSV_ITEM_DIV      IN  VARCHAR2 ,                  -- 제상품구분
        PR_RESULT         IN  OUT PKG_CURSOR.REF_CUR ,    -- Result Set,
        PR_RTN_CD         OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG        OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN   일 수불현황 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-08         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-03-08
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/

    LS_YM           VARCHAR2(6);
    LS_FR_DT        VARCHAR2(8);
    LS_TO_DT        VARCHAR2(8);
    LS_STOR_TP      STORE.STOR_TP%TYPE;
    LS_ERR_CD       VARCHAR2(7) ;
    LS_ERR_MSG      VARCHAR2(500) ;
    ERR_HANDLER     EXCEPTION;


    BEGIN
        LS_ERR_CD := '0' ;
        LS_YM     := SUBSTR(PSV_YMD,1,6) ;
        LS_FR_DT  := LS_YM || '01' ;
        LS_TO_DT  := PSV_YMD  ;

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
    SELECT  A.L_CLASS_NM
         ,  A.M_CLASS_NM
         ,  A.S_CLASS_NM
         ,  A.ITEM_CD
         ,  A.ITEM_NM
         ,  A.STANDARD
         ,  A.STOCK_UNIT
         ,  CASE WHEN PSV_STOR_CD IS NULL THEN 0 ELSE A.COST END    AS  COST
         ,  A.PRE_STOCK_QTY
         ,  A.PRE_STOCK_AMT
         ,  A.ORD_QTY
         ,  A.ORD_AMT
         ,  A.RTN_QTY
         ,  A.RTN_AMT
         ,  A.MV_IN_QTY
         ,  A.MV_IN_AMT
         ,  A.ETC_IN_QTY
         ,  A.ETC_IN_AMT
         ,  A.TOT_IN_QTY
         ,  A.TOT_IN_AMT
         ,  A.SALE_QTY
         ,  A.SALE_AMT
         ,  A.MV_OUT_QTY
         ,  A.MV_OUT_AMT
         ,  A.FREE_1_QTY
         ,  A.FREE_1_AMT         
         ,  A.FREE_2_QTY
         ,  A.FREE_2_AMT
         ,  A.FREE_3_QTY
         ,  A.FREE_3_AMT
         ,  A.FREE_4_QTY
         ,  A.FREE_4_AMT
         ,  A.FREE_5_QTY
         ,  A.FREE_5_AMT
         ,  A.FREE_6_QTY
         ,  A.FREE_6_AMT
         ,  A.FREE_7_QTY
         ,  A.FREE_7_AMT
         ,  A.FREE_8_QTY
         ,  A.FREE_8_AMT
         ,  A.FREE_9_QTY
         ,  A.FREE_9_AMT
         ,  A.FREE_10_QTY
         ,  A.FREE_10_AMT
         ,  A.FREE_11_QTY
         ,  A.FREE_11_AMT
         ,  A.FREE_12_QTY
         ,  A.FREE_12_AMT
         ,  A.FREE_13_QTY
         ,  A.FREE_13_AMT
         ,  A.FREE_14_QTY
         ,  A.FREE_14_AMT
         ,  A.TOT_OUT_QTY
         ,  A.TOT_OUT_AMT
         ,  A.DSA_01_QTY
         ,  A.DSA_01_AMT
         ,  A.DSA_02_QTY
         ,  A.DSA_02_AMT
         ,  A.DSA_03_QTY
         ,  A.DSA_03_AMT
         ,  A.DSA_04_QTY
         ,  A.DSA_04_AMT
         ,  A.DSA_05_QTY
         ,  A.DSA_05_AMT
         ,  A.DSA_06_QTY
         ,  A.DSA_06_AMT
         ,  A.DSA_99_QTY
         ,  A.DSA_99_AMT
         ,  A.TOT_DSA_QTY
         ,  A.TOT_DSA_AMT
         ,  A.PRE_STOCK_QTY + A.TOT_IN_QTY - A.TOT_OUT_QTY - A.TOT_DSA_QTY              AS STOCK_QTY    -- 장부재고
         ,  A.PRE_STOCK_AMT + A.TOT_IN_AMT - A.TOT_OUT_AMT - A.TOT_DSA_AMT              AS STOCK_AMT
         ,  A.SURV_QTY
         ,  A.SURV_AMT
         ,  A.SURV_YN
         ,  CASE WHEN A.SURV_YN = 'N' THEN 0
                 ELSE A.SURV_QTY - (A.PRE_STOCK_QTY + A.TOT_IN_QTY - A.TOT_OUT_QTY - A.TOT_DSA_QTY)
            END                                                                                     AS DIFF_QTY
         ,  CASE WHEN A.SURV_YN = 'N' THEN 0
                 ELSE A.SURV_AMT - (A.PRE_STOCK_AMT + A.TOT_IN_AMT - A.TOT_OUT_AMT - A.TOT_DSA_AMT)
            END                                                                                     AS DIFF_AMT
         ,  A.PRE_STOCK_QTY + A.TOT_IN_QTY - A.TOT_OUT_QTY - A.TOT_DSA_QTY + A.ADJ_QTY                      AS TOT_STOCK_QTY    -- 최종재고수량
         ,  ROUND((A.PRE_STOCK_QTY + A.TOT_IN_QTY - A.TOT_OUT_QTY - A.TOT_DSA_QTY + A.ADJ_QTY) * A.COST)    AS TOT_STOCK_AMT    -- 최종재고금액
         ,  CASE WHEN A.SURV_YN = 'Y' THEN (A.PRE_STOCK_QTY + A.TOT_IN_QTY) - A.RTN_QTY - A.MV_OUT_QTY - A.SURV_QTY                
                 ELSE 0
            END         AS USE_QTY
         ,  CASE WHEN A.SURV_YN = 'Y' THEN (A.PRE_STOCK_AMT + A.TOT_IN_AMT) - A.RTN_AMT - A.MV_OUT_AMT - A.SURV_AMT                
                 ELSE 0
            END         AS USE_AMT
      FROM  (
                SELECT  S.COMP_CD
                     ,  S.BRAND_CD
                     ,  S.ITEM_CD
                     ,  MAX(S.ITEM_NM)                                                  AS ITEM_NM
                     ,  MAX(S.STANDARD)                                                 AS STANDARD
                     ,  MAX(S.STOCK_UNIT)                                               AS STOCK_UNIT
                     ,  MAX(S.COST)                                                     AS COST
                     ,  MAX(S.L_CLASS_CD)                                               AS L_CLASS_CD
                     ,  MAX(LC.L_CLASS_NM)                                              AS L_CLASS_NM
                     ,  MAX(LC.SORT_ORDER)                                              AS L_SORT_ORDER
                     ,  MAX(S.M_CLASS_CD)                                               AS M_CLASS_CD
                     ,  MAX(MC.M_CLASS_NM)                                              AS M_CLASS_NM
                     ,  MAX(MC.SORT_ORDER)                                              AS M_SORT_ORDER
                     ,  MAX(S.S_CLASS_CD)                                               AS S_CLASS_CD
                     ,  MAX(SC.S_CLASS_NM)                                              AS S_CLASS_NM
                     ,  MAX(SC.SORT_ORDER)                                              AS S_SORT_ORDER
                     ,  SUM(S.BEGIN_QTY + S.PRE_STOCK_QTY)                              AS PRE_STOCK_QTY
                     ,  SUM(S.BEGIN_AMT + ROUND((S.PRE_STOCK_QTY * S.COST)))            AS PRE_STOCK_AMT
                     ,  SUM(S.ORD_QTY)                                                  AS ORD_QTY
                     ,  SUM(S.ORD_AMT)                                                  AS ORD_AMT
                     ,  SUM(S.RTN_QTY)                                                  AS RTN_QTY
                     ,  SUM(S.RTN_AMT)                                                  AS RTN_AMT
                     ,  SUM(S.MV_IN_QTY)                                                AS MV_IN_QTY
                     ,  SUM(S.MV_IN_AMT)                                                AS MV_IN_AMT
                     ,  SUM(S.ETC_IN_QTY)                                               AS ETC_IN_QTY
                     ,  0                                                               AS ETC_IN_AMT
                     ,  SUM(S.ORD_QTY + S.MV_IN_QTY + S.ETC_IN_QTY)                     AS TOT_IN_QTY
                     ,  SUM(S.ORD_AMT + S.MV_IN_AMT)                                    AS TOT_IN_AMT
                     ,  SUM(S.SALE_QTY)                                                 AS SALE_QTY
                     ,  SUM(ROUND(S.SALE_QTY * S.COST))                                 AS SALE_AMT
                     ,  SUM(S.MV_OUT_QTY)                                               AS MV_OUT_QTY
                     ,  SUM(ROUND(S.MV_OUT_QTY * S.COST))                               AS MV_OUT_AMT
                     ,  SUM(S.FREE_1_QTY)                                               AS FREE_1_QTY
                     ,  SUM(ROUND(S.FREE_1_QTY * S.COST))                               AS FREE_1_AMT
                     ,  SUM(S.FREE_2_QTY)                                               AS FREE_2_QTY
                     ,  SUM(ROUND(S.FREE_2_QTY * S.COST))                               AS FREE_2_AMT
                     ,  SUM(S.FREE_3_QTY)                                               AS FREE_3_QTY
                     ,  SUM(ROUND(S.FREE_3_QTY * S.COST))                               AS FREE_3_AMT
                     ,  SUM(S.FREE_4_QTY)                                               AS FREE_4_QTY
                     ,  SUM(ROUND(S.FREE_4_QTY * S.COST))                               AS FREE_4_AMT
                     ,  SUM(S.FREE_5_QTY)                                               AS FREE_5_QTY
                     ,  SUM(ROUND(S.FREE_5_QTY * S.COST))                               AS FREE_5_AMT
                     ,  SUM(S.FREE_6_QTY)                                               AS FREE_6_QTY
                     ,  SUM(ROUND(S.FREE_6_QTY * S.COST))                               AS FREE_6_AMT
                     ,  SUM(S.FREE_7_QTY)                                               AS FREE_7_QTY
                     ,  SUM(ROUND(S.FREE_7_QTY * S.COST))                               AS FREE_7_AMT
                     ,  SUM(S.FREE_8_QTY)                                               AS FREE_8_QTY
                     ,  SUM(ROUND(S.FREE_8_QTY * S.COST))                               AS FREE_8_AMT
                     ,  SUM(S.FREE_9_QTY)                                               AS FREE_9_QTY
                     ,  SUM(ROUND(S.FREE_9_QTY * S.COST))                               AS FREE_9_AMT
                     ,  SUM(S.FREE_10_QTY)                                              AS FREE_10_QTY
                     ,  SUM(ROUND(S.FREE_10_QTY * S.COST))                              AS FREE_10_AMT
                     ,  SUM(S.FREE_11_QTY)                                              AS FREE_11_QTY
                     ,  SUM(ROUND(S.FREE_11_QTY * S.COST))                              AS FREE_11_AMT
                     ,  SUM(S.FREE_12_QTY)                                              AS FREE_12_QTY
                     ,  SUM(ROUND(S.FREE_12_QTY * S.COST))                              AS FREE_12_AMT
                     ,  SUM(S.FREE_13_QTY)                                              AS FREE_13_QTY
                     ,  SUM(ROUND(S.FREE_13_QTY * S.COST))                              AS FREE_13_AMT
                     ,  SUM(S.FREE_14_QTY)                                              AS FREE_14_QTY
                     ,  SUM(ROUND(S.FREE_14_QTY * S.COST))                              AS FREE_14_AMT
                     ,  SUM(S.SALE_QTY + S.MV_OUT_QTY + S.RTN_QTY + S.FREE_1_QTY + S.FREE_2_QTY + S.FREE_3_QTY + S.FREE_4_QTY + S.FREE_5_QTY + S.FREE_6_QTY + S.FREE_7_QTY + S.FREE_8_QTY  + S.FREE_9_QTY + S.FREE_10_QTY + S.FREE_11_QTY + S.FREE_12_QTY + S.FREE_13_QTY + S.FREE_14_QTY)  AS TOT_OUT_QTY
                     ,  SUM(ROUND(S.SALE_QTY * S.COST) + ROUND(S.MV_OUT_QTY * S.COST) + S.RTN_AMT + ROUND(S.FREE_1_QTY * S.COST) + ROUND(S.FREE_2_QTY * S.COST) + ROUND(S.FREE_3_QTY * S.COST) + ROUND(S.FREE_4_QTY * S.COST) + ROUND(S.FREE_5_QTY * S.COST) + ROUND(S.FREE_6_QTY * S.COST) + ROUND(S.FREE_7_QTY * S.COST) +
                        ROUND(S.FREE_8_QTY * S.COST) + ROUND(S.FREE_9_QTY * S.COST) + ROUND(S.FREE_10_QTY * S.COST) + ROUND(S.FREE_11_QTY * S.COST) + ROUND(S.FREE_12_QTY * S.COST) + ROUND(S.FREE_13_QTY * S.COST) + ROUND(S.FREE_14_QTY * S.COST))    AS TOT_OUT_AMT
                     ,  SUM(S.DSA_01_QTY)                                               AS DSA_01_QTY
                     ,  SUM(ROUND(S.DSA_01_QTY * S.COST))                               AS DSA_01_AMT
                     ,  SUM(S.DSA_02_QTY)                                               AS DSA_02_QTY
                     ,  SUM(ROUND(S.DSA_02_QTY * S.COST))                               AS DSA_02_AMT
                     ,  SUM(S.DSA_03_QTY)                                               AS DSA_03_QTY
                     ,  SUM(ROUND(S.DSA_03_QTY * S.COST))                               AS DSA_03_AMT
                     ,  SUM(S.DSA_04_QTY)                                               AS DSA_04_QTY
                     ,  SUM(ROUND(S.DSA_04_QTY * S.COST))                               AS DSA_04_AMT
                     ,  SUM(S.DSA_05_QTY)                                               AS DSA_05_QTY
                     ,  SUM(ROUND(S.DSA_05_QTY * S.COST))                               AS DSA_05_AMT
                     ,  SUM(S.DSA_06_QTY)                                               AS DSA_06_QTY
                     ,  SUM(ROUND(S.DSA_06_QTY * S.COST))                               AS DSA_06_AMT
                     ,  SUM(S.DSA_99_QTY)                                               AS DSA_99_QTY
                     ,  SUM(ROUND(S.DSA_99_QTY * S.COST))                               AS DSA_99_AMT
                     ,  SUM(S.DSA_01_QTY + S.DSA_02_QTY + S.DSA_03_QTY + S.DSA_04_QTY + S.DSA_05_QTY + S.DSA_06_QTY + S.DSA_99_QTY)     AS TOT_DSA_QTY
                     ,  SUM(ROUND(S.DSA_01_QTY * S.COST) + ROUND(S.DSA_02_QTY * S.COST) + ROUND(S.DSA_03_QTY * S.COST) + ROUND(S.DSA_04_QTY * S.COST) + ROUND(S.DSA_05_QTY * S.COST) + ROUND(S.DSA_06_QTY * S.COST) + ROUND(S.DSA_99_QTY * S.COST)) AS TOT_DSA_AMT
                     ,  SUM(S.SURV_QTY)                                                 AS SURV_QTY
                     ,  SUM(ROUND(S.SURV_QTY * S.COST))                                 AS SURV_AMT
                     ,  SUM(S.ADJ_QTY)                                                  AS ADJ_QTY
                     ,  CASE WHEN SUM(SUM(S.SURV_QTY)) OVER (PARTITION BY S.COMP_CD, S.BRAND_CD) > 0 THEN 'Y' ELSE 'N' END   AS SURV_YN
                  FROM  (
                            SELECT  /*+ ORDERED */
                                    D.COMP_CD
                                 ,  D.BRAND_CD
                                 ,  D.STOR_CD
                                 ,  D.ITEM_CD
                                 ,  MAX(I.ITEM_NM)                                              AS ITEM_NM
                                 ,  MAX(I.STANDARD)                                             AS STANDARD
                                 ,  MAX(I.STOCK_UNIT)                                           AS STOCK_UNIT
                                 ,  MAX(I.L_CLASS_CD)                                           AS L_CLASS_CD
                                 ,  MAX(I.M_CLASS_CD)                                           AS M_CLASS_CD
                                 ,  MAX(I.S_CLASS_CD)                                           AS S_CLASS_CD
                                 ,  MAX(ROUND(CASE WHEN I.ORD_UNIT_QTY > 0 THEN NVL(C.COST, 0) / I.ORD_UNIT_QTY ELSE 0 END, 3))    AS COST
                                 ,  SUM(D.BEGIN_QTY)                                            AS BEGIN_QTY
                                 ,  SUM(D.BEGIN_AMT)                                            AS BEGIN_AMT
                                 ,  SUM(D.PRE_INOUT_QTY - D.PRE_FREE_QTY - D.PRE_DSA_QTY)       AS PRE_STOCK_QTY
                                 ,  SUM(D.ORD_QTY)                                              AS ORD_QTY
                                 ,  SUM(D.ORD_AMT)                                              AS ORD_AMT
                                 ,  SUM(D.MV_IN_QTY)                                            AS MV_IN_QTY
                                 ,  SUM(D.MV_IN_AMT)                                            AS MV_IN_AMT
                                 ,  SUM(D.ETC_IN_QTY)                                           AS ETC_IN_QTY
                                 ,  SUM(D.SALE_QTY)                                             AS SALE_QTY
                                 ,  SUM(D.MV_OUT_QTY)                                           AS MV_OUT_QTY
                                 ,  SUM(D.RTN_QTY)                                              AS RTN_QTY
                                 ,  SUM(D.RTN_AMT)                                              AS RTN_AMT
                                 ,  SUM(D.DISUSE_QTY)                                           AS DISUSE_QTY
                                 ,  SUM(D.FREE_1_QTY)                                           AS FREE_1_QTY
                                 ,  SUM(D.FREE_2_QTY)                                           AS FREE_2_QTY
                                 ,  SUM(D.FREE_3_QTY)                                           AS FREE_3_QTY
                                 ,  SUM(D.FREE_4_QTY)                                           AS FREE_4_QTY
                                 ,  SUM(D.FREE_5_QTY)                                           AS FREE_5_QTY
                                 ,  SUM(D.FREE_6_QTY)                                           AS FREE_6_QTY
                                 ,  SUM(D.FREE_7_QTY)                                           AS FREE_7_QTY
                                 ,  SUM(D.FREE_8_QTY)                                           AS FREE_8_QTY
                                 ,  SUM(D.FREE_9_QTY)                                           AS FREE_9_QTY
                                 ,  SUM(D.FREE_10_QTY)                                          AS FREE_10_QTY
                                 ,  SUM(D.FREE_11_QTY)                                          AS FREE_11_QTY
                                 ,  SUM(D.FREE_12_QTY)                                          AS FREE_12_QTY
                                 ,  SUM(D.FREE_13_QTY)                                          AS FREE_13_QTY
                                 ,  SUM(D.FREE_14_QTY)                                          AS FREE_14_QTY
                                 ,  SUM(D.DSA_01_QTY)                                           AS DSA_01_QTY
                                 ,  SUM(D.DSA_02_QTY)                                           AS DSA_02_QTY
                                 ,  SUM(D.DSA_03_QTY)                                           AS DSA_03_QTY
                                 ,  SUM(D.DSA_04_QTY)                                           AS DSA_04_QTY
                                 ,  SUM(D.DSA_05_QTY)                                           AS DSA_05_QTY
                                 ,  SUM(D.DSA_06_QTY)                                           AS DSA_06_QTY
                                 ,  SUM(D.DSA_99_QTY)                                           AS DSA_99_QTY
                                 ,  SUM(D.NOCHARGE_QTY)                                         AS NOCHARGE_QTY
                                 ,  SUM(D.SURV_QTY)                                             AS SURV_QTY
                                 ,  SUM(D.ADJ_QTY)                                              AS ADJ_QTY
                              FROM  (
                                        SELECT  /*+ USE_NL(I, IC L) */
                                                I.COMP_CD
                                             ,  I.BRAND_CD
                                             ,  I.ITEM_CD
                                             ,  NVL(L.ITEM_NM, I.ITEM_NM)           AS ITEM_NM
                                             ,  I.STANDARD
                                             ,  I.STOCK_UNIT
                                             ,  NVL(IC.L_CLASS_CD, I.L_CLASS_CD)    AS L_CLASS_CD
                                             ,  NVL(IC.M_CLASS_CD, I.M_CLASS_CD)    AS M_CLASS_CD
                                             ,  NVL(IC.S_CLASS_CD, I.S_CLASS_CD)    AS S_CLASS_CD
                                             ,  I.ORD_UNIT_QTY
                                          FROM  ITEM_CHAIN      I
                                             ,  ITEM_CLASS      IC
                                             ,  LANG_ITEM       L
                                         WHERE  I.COMP_CD   = IC.COMP_CD(+)
                                           AND  I.ITEM_CD   = IC.ITEM_CD(+)
                                           AND  I.COMP_CD   = L.COMP_CD(+)
                                           AND  I.ITEM_CD   = L.ITEM_CD(+)
                                           AND  I.COMP_CD   = PSV_COMP_CD
                                           AND  I.BRAND_CD          = PSV_BRAND_CD
                                           AND  I.STOR_TP           = LS_STOR_TP
                                           AND  IC.ORG_CLASS_CD(+)  = PSV_ORG_CLASS
                                           AND  L.LANGUAGE_TP(+)    = PSV_LANG_CD
                                           AND  L.USE_YN(+)         = 'Y'
                                           AND  (PSV_ORD_SALE_DIV   IS NULL OR I.ORD_SALE_DIV                   = PSV_ORD_SALE_DIV)
                                           AND  (PSV_ITEM_DIV       IS NULL OR I.ITEM_DIV                       = PSV_ITEM_DIV)
                                           AND  (PSV_L_CLASS_CD     IS NULL OR NVL(IC.L_CLASS_CD, I.L_CLASS_CD) = PSV_L_CLASS_CD)
                                           AND  (PSV_M_CLASS_CD     IS NULL OR NVL(IC.M_CLASS_CD, I.M_CLASS_CD) = PSV_M_CLASS_CD)
                                           AND  (PSV_S_CLASS_CD     IS NULL OR NVL(IC.S_CLASS_CD, I.S_CLASS_CD) = PSV_S_CLASS_CD)
                                           AND  I.STOCK_DIV <> 'N'
                                    )               I
                                 ,  (
                                        SELECT  A.COMP_CD
                                             ,  A.BRAND_CD
                                             ,  A.STOR_CD
                                             ,  A.ITEM_CD
                                             ,  0                                                                           AS BEGIN_QTY
                                             ,  0                                                                           AS BEGIN_AMT
                                             ,  SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.ORD_QTY         ELSE 0 END) 
                                              + SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.PROD_IN_QTY     ELSE 0 END)
                                              + SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.MV_IN_QTY       ELSE 0 END)
                                              + SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.ETC_IN_QTY      ELSE 0 END)
                                              - SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.SALE_QTY        ELSE 0 END)
                                              - SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.PROD_OUT_QTY    ELSE 0 END)
                                              - SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.MV_OUT_QTY      ELSE 0 END)
                                              - SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.ETC_OUT_QTY     ELSE 0 END)  
                                              - SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.RTN_QTY         ELSE 0 END)      
                                              - SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.DISUSE_QTY      ELSE 0 END)
                                              + SUM(CASE WHEN A.PRC_DT < LS_TO_DT THEN  A.ADJ_QTY         ELSE 0 END)     AS PRE_INOUT_QTY
                                             ,  0                                                                         AS PRE_FREE_QTY
                                             ,  0                                                                         AS PRE_DSA_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.ORD_QTY         ELSE 0 END)     AS ORD_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  O.ORD_AMT         ELSE 0 END)     AS ORD_AMT  -- 주문금액 + 개별입고금액
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.PROD_IN_QTY     ELSE 0 END)     AS PROD_IN_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.MV_IN_QTY       ELSE 0 END)     AS MV_IN_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  M.MV_IN_AMT       ELSE 0 END)     AS MV_IN_AMT  -- 출고매장의 총평균단가로 산정한 점간이동입고금액
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.ETC_IN_QTY      ELSE 0 END)     AS ETC_IN_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.SALE_QTY        ELSE 0 END)     AS SALE_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.PROD_OUT_QTY    ELSE 0 END)     AS PROD_OUT_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.MV_OUT_QTY      ELSE 0 END)     AS MV_OUT_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.ETC_OUT_QTY     ELSE 0 END)     AS ETC_OUT_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.RTN_QTY         ELSE 0 END)     AS RTN_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  R.RTN_AMT         ELSE 0 END)     AS RTN_AMT
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.DISUSE_QTY      ELSE 0 END)     AS DISUSE_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.ADJ_QTY         ELSE 0 END)     AS ADJ_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.NOCHARGE_QTY    ELSE 0 END)     AS NOCHARGE_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = LS_TO_DT THEN  A.SURV_QTY        ELSE 0 END)     AS SURV_QTY
                                             ,  0           AS FREE_1_QTY
                                             ,  0           AS FREE_2_QTY
                                             ,  0           AS FREE_3_QTY
                                             ,  0           AS FREE_4_QTY
                                             ,  0           AS FREE_5_QTY
                                             ,  0           AS FREE_6_QTY
                                             ,  0           AS FREE_7_QTY
                                             ,  0           AS FREE_8_QTY
                                             ,  0           AS FREE_9_QTY
                                             ,  0           AS FREE_10_QTY
                                             ,  0           AS FREE_11_QTY
                                             ,  0           AS FREE_12_QTY
                                             ,  0           AS FREE_13_QTY
                                             ,  0           AS FREE_14_QTY
                                             ,  0           AS DSA_01_QTY
                                             ,  0           AS DSA_02_QTY
                                             ,  0           AS DSA_03_QTY
                                             ,  0           AS DSA_04_QTY
                                             ,  0           AS DSA_05_QTY
                                             ,  0           AS DSA_06_QTY
                                             ,  0           AS DSA_99_QTY
                                          FROM  ITEM_CHAIN      I
                                             ,  DSTOCK          A
                                             ,  (
                                                    SELECT  OD.COMP_CD
                                                         ,  OD.STK_DT
                                                         ,  OD.BRAND_CD
                                                         ,  OD.STOR_CD
                                                         ,  OD.ITEM_CD
                                                         ,  SUM(CASE WHEN NVL(BP.PARA_VAL, '1') = '1' THEN NVL(OD.ORD_CAMT, 0) + NVL(OD.ORD_CVAT, 0) ELSE NVL(OD.ORD_CAMT, 0) END)    AS ORD_AMT
                                                      FROM  ORDER_DTV   OD
                                                         ,  PARA_BRAND  BP
                                                     WHERE  OD.COMP_CD     = BP.COMP_CD(+)
                                                       AND  OD.BRAND_CD    = BP.BRAND_CD(+)
                                                       AND  BP.PARA_CD(+)  = '1007' -- 매입 부가세설정[1:부가세포함, 2:부가세미포함]
                                                       AND  OD.COMP_CD     = PSV_COMP_CD
                                                       AND  OD.STK_DT      = PSV_YMD
                                                       AND  OD.BRAND_CD    = PSV_BRAND_CD
                                                       AND  (PSV_STOR_CD IS NULL OR OD.STOR_CD = PSV_STOR_CD)
                                                       AND  OD.ORD_FG      = '1'
                                                     GROUP  BY OD.COMP_CD, OD.STK_DT, OD.BRAND_CD, OD.STOR_CD, OD.ITEM_CD
                                                )               O   -- 주문
                                             ,  (
                                                    SELECT  OD.COMP_CD
                                                         ,  OD.STK_DT
                                                         ,  OD.BRAND_CD
                                                         ,  OD.STOR_CD
                                                         ,  OD.ITEM_CD
                                                         ,  SUM(CASE WHEN NVL(BP.PARA_VAL, '1') = '1' THEN NVL(OD.ORD_CAMT, 0) + NVL(OD.ORD_CVAT, 0) ELSE NVL(OD.ORD_CAMT, 0) END)    AS RTN_AMT
                                                      FROM  ORDER_DTV   OD
                                                         ,  PARA_BRAND  BP
                                                     WHERE  OD.COMP_CD     = BP.COMP_CD(+)
                                                       AND  OD.BRAND_CD    = BP.BRAND_CD(+)
                                                       AND  BP.PARA_CD(+)  = '1007' -- 매입 부가세설정[1:부가세포함, 2:부가세미포함]
                                                       AND  OD.COMP_CD     = PSV_COMP_CD
                                                       AND  OD.STK_DT      = PSV_YMD
                                                       AND  OD.BRAND_CD    = PSV_BRAND_CD
                                                       AND  (PSV_STOR_CD IS NULL OR OD.STOR_CD = PSV_STOR_CD)
                                                       AND  OD.ORD_FG      = '2'
                                                     GROUP  BY OD.COMP_CD, OD.STK_DT, OD.BRAND_CD, OD.STOR_CD, OD.ITEM_CD
                                                )               R   -- 반품
                                             ,  (
                                                    SELECT  M.COMP_CD
                                                         ,  M.IN_CONF_DT
                                                         ,  M.IN_BRAND_CD   AS BRAND_CD
                                                         ,  M.IN_STOR_CD
                                                         ,  M.ITEM_CD
                                                         ,  SUM(NVL(M.MV_CQTY, 0) * NVL(M.MV_UNIT_QTY, 1))  AS MV_IN_QTY
                                                         ,  SUM(NVL(M.MV_CQTY, 0) * NVL(M.MV_UNIT_QTY, 1) * ROUND((CASE WHEN I.ORD_UNIT_QTY > 0 THEN NVL(C.END_COST, 0) / I.ORD_UNIT_QTY ELSE 0 END), 3))  AS MV_IN_AMT
                                                      FROM  MOVE_STORE      M
                                                         ,  ITEM_CHAIN      I
                                                         ,  MSTOCK          C
                                                     WHERE  M.COMP_CD          = I.COMP_CD
                                                       AND  M.IN_BRAND_CD      = I.BRAND_CD
                                                       AND  M.ITEM_CD          = I.ITEM_CD
                                                       AND  M.COMP_CD          = C.COMP_CD(+)
                                                       AND  M.OUT_BRAND_CD     = C.BRAND_CD(+)
                                                       AND  M.OUT_STOR_CD      = C.STOR_CD(+)
                                                       AND  M.ITEM_CD          = C.ITEM_CD(+)
                                                       AND  M.COMP_CD          = PSV_COMP_CD
                                                       AND  M.IN_CONF_DT       = PSV_YMD
                                                       AND  M.IN_BRAND_CD      = PSV_BRAND_CD
                                                       AND  (PSV_STOR_CD IS NULL OR M.IN_STOR_CD = PSV_STOR_CD)
                                                       AND  M.CONFIRM_DIV      IN ('3', '4')
                                                       AND  I.COMP_CD          = PSV_COMP_CD
                                                       AND  I.BRAND_CD         = PSV_BRAND_CD
                                                       AND  I.STOR_TP          = LS_STOR_TP
                                                       AND  C.PRC_YM(+)         = TO_CHAR(TO_DATE(M.IN_CONF_DT, 'YYYYMMDD'), 'YYYYMM')
                                                     GROUP  BY M.COMP_CD, M.IN_CONF_DT, M.IN_BRAND_CD, M.IN_STOR_CD, M.ITEM_CD
                                                )               M
                                         WHERE  I.COMP_CD           = A.COMP_CD
                                           AND  I.BRAND_CD          = A.BRAND_CD
                                           AND  I.ITEM_CD           = A.ITEM_CD
                                           AND  A.COMP_CD           = O.COMP_CD(+)
                                           AND  A.PRC_DT            = O.STK_DT(+)
                                           AND  A.BRAND_CD          = O.BRAND_CD(+)
                                           AND  A.STOR_CD           = O.STOR_CD(+)
                                           AND  A.ITEM_CD           = O.ITEM_CD(+)
                                           AND  A.COMP_CD           = R.COMP_CD(+)
                                           AND  A.PRC_DT            = R.STK_DT(+)
                                           AND  A.BRAND_CD          = R.BRAND_CD(+)
                                           AND  A.STOR_CD           = R.STOR_CD(+)
                                           AND  A.ITEM_CD           = R.ITEM_CD(+)
                                           AND  A.COMP_CD           = M.COMP_CD(+)
                                           AND  A.PRC_DT            = M.IN_CONF_DT(+)
                                           AND  A.BRAND_CD          = M.BRAND_CD(+)
                                           AND  A.STOR_CD           = M.IN_STOR_CD(+)
                                           AND  A.ITEM_CD           = M.ITEM_CD(+)
                                           AND  I.COMP_CD           = PSV_COMP_CD
                                           AND  I.BRAND_CD          = PSV_BRAND_CD
                                           AND  I.STOR_TP           = LS_STOR_TP
                                           AND  I.STOCK_DIV         <> 'N'
                                           AND  A.COMP_CD           = PSV_COMP_CD
                                           AND  A.BRAND_CD          = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR A.STOR_CD = PSV_STOR_CD)
                                           AND  A.PRC_DT            BETWEEN LS_FR_DT AND LS_TO_DT
                                         GROUP  BY A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.ITEM_CD
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
                                             ,  0           AS ORD_QTY
                                             ,  0           AS ORD_AMT
                                             ,  0           AS PROD_IN_QTY
                                             ,  0           AS MV_IN_QTY
                                             ,  0           AS MV_IN_AMT
                                             ,  0           AS ETC_IN_QTY
                                             ,  0           AS SALE_QTY
                                             ,  0           AS PROD_OUT_QTY
                                             ,  0           AS MV_OUT_QTY
                                             ,  0           AS ETC_OUT_QTY
                                             ,  0           AS RTN_QTY
                                             ,  0           AS RTN_AMT
                                             ,  0           AS DISUSE_QTY
                                             ,  0           AS ADJ_QTY
                                             ,  0           AS NOCHARGE_QTY
                                             ,  0           AS SURV_QTY
                                             ,  0           AS FREE_1_QTY
                                             ,  0           AS FREE_2_QTY
                                             ,  0           AS FREE_3_QTY
                                             ,  0           AS FREE_4_QTY
                                             ,  0           AS FREE_5_QTY
                                             ,  0           AS FREE_6_QTY
                                             ,  0           AS FREE_7_QTY
                                             ,  0           AS FREE_8_QTY
                                             ,  0           AS FREE_9_QTY
                                             ,  0           AS FREE_10_QTY
                                             ,  0           AS FREE_11_QTY
                                             ,  0           AS FREE_12_QTY
                                             ,  0           AS FREE_13_QTY
                                             ,  0           AS FREE_14_QTY
                                             ,  0           AS DSA_01_QTY
                                             ,  0           AS DSA_02_QTY
                                             ,  0           AS DSA_03_QTY
                                             ,  0           AS DSA_04_QTY
                                             ,  0           AS DSA_05_QTY
                                             ,  0           AS DSA_06_QTY
                                             ,  0           AS DSA_99_QTY
                                          FROM  ITEM_CHAIN  I
                                             ,  MSTOCK A
                                         WHERE  I.COMP_CD   = A.COMP_CD
                                           AND  I.BRAND_CD  = A.BRAND_CD
                                           AND  I.ITEM_CD   = A.ITEM_CD
                                           AND  I.COMP_CD   = PSV_COMP_CD
                                           AND  I.BRAND_CD  = PSV_BRAND_CD
                                           AND  I.STOR_TP   = LS_STOR_TP
                                           AND  I.STOCK_DIV <> 'N'
                                           AND  A.COMP_CD   = PSV_COMP_CD
                                           AND  A.BRAND_CD  = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR A.STOR_CD = PSV_STOR_CD)
                                           AND  A.PRC_YM    = LS_YM
                                        UNION ALL
                                        SELECT  A.COMP_CD
                                             ,  A.BRAND_CD
                                             ,  A.STOR_CD
                                             ,  A.ITEM_CD
                                             ,  0           AS BEGIN_QTY
                                             ,  0           AS BEGIN_AMT
                                             ,  0           AS PRE_INOUT_QTY
                                             ,  SUM(CASE WHEN A.SALE_DT < LS_TO_DT THEN  A.SALE_QTY ELSE 0 END)   AS PRE_FREE_QTY
                                             ,  0           AS PRE_DSA_QTY
                                             ,  0           AS ORD_QTY
                                             ,  0           AS ORD_AMT
                                             ,  0           AS PROD_IN_QTY
                                             ,  0           AS MV_IN_QTY
                                             ,  0           AS MV_IN_AMT
                                             ,  0           AS ETC_IN_QTY
                                             ,  0           AS SALE_QTY
                                             ,  0           AS PROD_OUT_QTY                            
                                             ,  0           AS MV_OUT_QTY
                                             ,  0           AS ETC_OUT_QTY                            
                                             ,  0           AS RTN_QTY
                                             ,  0           AS RTN_AMT
                                             ,  0           AS DISUSE_QTY
                                             ,  0           AS ADJ_QTY
                                             ,  0           AS NOCHARGE_QTY
                                             ,  0           AS SURV_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '1'  AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_1_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '2'  AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_2_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '3'  AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_3_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '4'  AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_4_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '5'  AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_5_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '6'  AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_6_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '7'  AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_7_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '8'  AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_8_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '9'  AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_9_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '10' AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_10_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '11' AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_11_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '12' AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_12_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '13' AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_13_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '14' AND A.SALE_DT = LS_TO_DT THEN SALE_QTY ELSE 0 END )    AS FREE_14_QTY
                                             ,  0           AS DSA_01_QTY
                                             ,  0           AS DSA_02_QTY
                                             ,  0           AS DSA_03_QTY
                                             ,  0           AS DSA_04_QTY
                                             ,  0           AS DSA_05_QTY
                                             ,  0           AS DSA_06_QTY
                                             ,  0           AS DSA_99_QTY
                                          FROM  SALE_JDF A 
                                         WHERE  A.COMP_CD   = PSV_COMP_CD
                                           AND  A.BRAND_CD  = PSV_BRAND_CD
                                           AND  A.SALE_DT   BETWEEN LS_FR_DT AND LS_TO_DT
                                           AND  (PSV_STOR_CD IS NULL OR A.STOR_CD = PSV_STOR_CD)
                                         GROUP  BY A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.ITEM_CD
                                        UNION ALL
                                        SELECT  A.COMP_CD
                                             ,  A.BRAND_CD
                                             ,  A.STOR_CD
                                             ,  A.C_ITEM_CD AS ITEM_CD
                                             ,  0           AS BEGIN_QTY
                                             ,  0           AS BEGIN_AMT
                                             ,  0           AS PRE_INOUT_QTY
                                             ,  0           AS PRE_FREE_QTY
                                             ,  SUM(CASE WHEN A.SALE_DT < LS_TO_DT THEN  A.DO_QTY ELSE 0 END)   AS PRE_DSA_QTY
                                             ,  0           AS ORD_QTY
                                             ,  0           AS ORD_AMT
                                             ,  0           AS PROD_IN_QTY
                                             ,  0           AS MV_IN_QTY
                                             ,  0           AS MV_IN_AMT
                                             ,  0           AS ETC_IN_QTY
                                             ,  0           AS SALE_QTY
                                             ,  0           AS PROD_OUT_QTY                            
                                             ,  0           AS MV_OUT_QTY
                                             ,  0           AS ETC_OUT_QTY                            
                                             ,  0           AS RTN_QTY
                                             ,  0           AS RTN_AMT
                                             ,  0           AS DISUSE_QTY
                                             ,  0           AS ADJ_QTY
                                             ,  0           AS NOCHARGE_QTY
                                             ,  0           AS SURV_QTY
                                             ,  0           AS FREE_1_QTY
                                             ,  0           AS FREE_2_QTY
                                             ,  0           AS FREE_3_QTY
                                             ,  0           AS FREE_4_QTY
                                             ,  0           AS FREE_5_QTY
                                             ,  0           AS FREE_6_QTY
                                             ,  0           AS FREE_7_QTY
                                             ,  0           AS FREE_8_QTY
                                             ,  0           AS FREE_9_QTY
                                             ,  0           AS FREE_10_QTY
                                             ,  0           AS FREE_11_QTY
                                             ,  0           AS FREE_12_QTY
                                             ,  0           AS FREE_13_QTY
                                             ,  0           AS FREE_14_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '01' AND A.SALE_DT = LS_TO_DT THEN DO_QTY ELSE 0 END )   AS DSA_01_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '02' AND A.SALE_DT = LS_TO_DT THEN DO_QTY ELSE 0 END )   AS DSA_02_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '03' AND A.SALE_DT = LS_TO_DT THEN DO_QTY ELSE 0 END )   AS DSA_03_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '04' AND A.SALE_DT = LS_TO_DT THEN DO_QTY ELSE 0 END )   AS DSA_04_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '05' AND A.SALE_DT = LS_TO_DT THEN DO_QTY ELSE 0 END )   AS DSA_05_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '06' AND A.SALE_DT = LS_TO_DT THEN DO_QTY ELSE 0 END )   AS DSA_06_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '99' AND A.SALE_DT = LS_TO_DT THEN DO_QTY ELSE 0 END )   AS DSA_07_QTY
                                          FROM  SALE_CDR A 
                                         WHERE  A.COMP_CD   = PSV_COMP_CD
                                           AND  A.SALE_DT   BETWEEN LS_FR_DT AND LS_TO_DT
                                           AND  A.BRAND_CD  = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR A.STOR_CD = PSV_STOR_CD)
                                         GROUP  BY A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.C_ITEM_CD
                                    )               D
                                 ,  (
                                        SELECT  COMP_CD
                                             ,  BRAND_CD
                                             ,  STOR_CD
                                             ,  ITEM_CD
                                             ,  END_COST    AS COST
                                          FROM  MSTOCK
                                         WHERE  COMP_CD     = PSV_COMP_CD
                                           AND  PRC_YM      = LS_YM
                                           AND  BRAND_CD    = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR STOR_CD = PSV_STOR_CD)
                                    ) C
                             WHERE  D.COMP_CD   = I.COMP_CD
                               AND  D.ITEM_CD   = I.ITEM_CD
                               AND  D.COMP_CD   = C.COMP_CD(+)
                               AND  D.BRAND_CD  = C.BRAND_CD(+)
                               AND  D.STOR_CD   = C.STOR_CD(+)
                               AND  D.ITEM_CD   = C.ITEM_CD(+)
                             GROUP  BY D.COMP_CD
                                 ,  D.BRAND_CD
                                 ,  D.STOR_CD
                                 ,  D.ITEM_CD
                        )       S
                     ,  (
                            SELECT  C.COMP_CD
                                 ,  C.L_CLASS_CD
                                 ,  NVL(L.LANG_NM, C.L_CLASS_NM)    AS L_CLASS_NM
                                 ,  C.SORT_ORDER
                              FROM  ITEM_L_CLASS    C
                                 ,  (
                                        SELECT  COMP_CD
                                             ,  PK_COL
                                             ,  LANG_NM
                                          FROM  LANG_TABLE
                                         WHERE  COMP_CD     = PSV_COMP_CD
                                           AND  TABLE_NM    = 'ITEM_L_CLASS'
                                           AND  COL_NM      = 'L_CLASS_NM'
                                           AND  LANGUAGE_TP = PSV_LANG_CD
                                           AND  USE_YN      = 'Y'
                                    )               L
                             WHERE  L.COMP_CD(+)    = C.COMP_CD  
                               AND  L.PK_COL (+)    = C.COMP_CD||C.ORG_CLASS_CD||C.L_CLASS_CD 
                               AND  C.COMP_CD       = PSV_COMP_CD
                               AND  C.ORG_CLASS_CD  = PSV_ORG_CLASS
                               AND  (PSV_L_CLASS_CD IS NULL OR C.L_CLASS_CD = PSV_L_CLASS_CD)
                               AND  C.USE_YN        = 'Y'
                        )       LC
                     ,  (
                            SELECT  C.COMP_CD
                                 ,  C.L_CLASS_CD
                                 ,  C.M_CLASS_CD
                                 ,  NVL(L.LANG_NM, C.M_CLASS_NM)    AS M_CLASS_NM
                                 ,  C.SORT_ORDER
                              FROM  ITEM_M_CLASS    C
                                 ,  (
                                        SELECT  COMP_CD
                                             ,  PK_COL
                                             ,  LANG_NM
                                          FROM  LANG_TABLE
                                         WHERE  COMP_CD     = PSV_COMP_CD
                                           AND  TABLE_NM    = 'ITEM_M_CLASS'
                                           AND  COL_NM      = 'M_CLASS_NM'
                                           AND  LANGUAGE_TP = PSV_LANG_CD
                                           AND  USE_YN      = 'Y'
                                    )               L
                             WHERE  L.COMP_CD(+)    = C.COMP_CD  
                               AND  L.PK_COL (+)    = C.COMP_CD||C.ORG_CLASS_CD||C.L_CLASS_CD||C.M_CLASS_CD 
                               AND  C.COMP_CD       = PSV_COMP_CD
                               AND  C.ORG_CLASS_CD  = PSV_ORG_CLASS
                               AND  (PSV_L_CLASS_CD IS NULL OR C.L_CLASS_CD = PSV_L_CLASS_CD)
                               AND  (PSV_M_CLASS_CD IS NULL OR C.M_CLASS_CD = PSV_M_CLASS_CD)
                               AND  C.USE_YN        = 'Y'
                        )       MC
                    ,  (
                            SELECT  C.COMP_CD
                                 ,  C.L_CLASS_CD
                                 ,  C.M_CLASS_CD
                                 ,  C.S_CLASS_CD
                                 ,  NVL(L.LANG_NM, C.S_CLASS_NM)    AS S_CLASS_NM
                                 ,  C.SORT_ORDER
                              FROM  ITEM_S_CLASS    C
                                 ,  (
                                        SELECT  COMP_CD
                                             ,  PK_COL
                                             ,  LANG_NM
                                          FROM  LANG_TABLE
                                         WHERE  COMP_CD     = PSV_COMP_CD
                                           AND  TABLE_NM    = 'ITEM_S_CLASS'
                                           AND  COL_NM      = 'S_CLASS_NM'
                                           AND  LANGUAGE_TP = PSV_LANG_CD
                                           AND  USE_YN      = 'Y'
                                    )               L
                             WHERE  L.COMP_CD(+)    = C.COMP_CD  
                               AND  L.PK_COL (+)    = C.COMP_CD||C.ORG_CLASS_CD||C.L_CLASS_CD||C.M_CLASS_CD||C.S_CLASS_CD 
                               AND  C.COMP_CD       = PSV_COMP_CD
                               AND  C.ORG_CLASS_CD  = PSV_ORG_CLASS
                               AND  (PSV_L_CLASS_CD IS NULL OR C.L_CLASS_CD = PSV_L_CLASS_CD)
                               AND  (PSV_M_CLASS_CD IS NULL OR C.M_CLASS_CD = PSV_M_CLASS_CD)
                               AND  (PSV_S_CLASS_CD IS NULL OR C.S_CLASS_CD = PSV_S_CLASS_CD)
                               AND  C.USE_YN        = 'Y'
                        )       SC
                 WHERE  S.COMP_CD       = LC.COMP_CD(+)
                   AND  S.L_CLASS_CD    = LC.L_CLASS_CD(+)
                   AND  S.COMP_CD       = MC.COMP_CD(+)
                   AND  S.L_CLASS_CD    = MC.L_CLASS_CD(+)
                   AND  S.M_CLASS_CD    = MC.M_CLASS_CD(+)
                   AND  S.COMP_CD       = SC.COMP_CD(+)
                   AND  S.L_CLASS_CD    = SC.L_CLASS_CD(+)
                   AND  S.M_CLASS_CD    = SC.M_CLASS_CD(+)
                   AND  S.S_CLASS_CD    = SC.S_CLASS_CD(+)
                 GROUP  BY S.COMP_CD, S.BRAND_CD, S.ITEM_CD
            ) A
     ORDER  BY A.L_SORT_ORDER, A.M_SORT_ORDER, A.S_SORT_ORDER, A.ITEM_CD;

    PR_RTN_CD  := LS_ERR_CD;
    PR_RTN_MSG := LS_ERR_MSG ;
    --dbms_output.put_line( 'SUCCESS') ;

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := LS_ERR_CD;
            PR_RTN_MSG := LS_ERR_MSG ;
            --dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            --dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    END;

END PKG_STCK4030;

/
