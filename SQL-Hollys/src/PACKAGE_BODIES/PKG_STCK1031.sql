--------------------------------------------------------
--  DDL for Package Body PKG_STCK1031
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_STCK1031" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD       IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER          IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID        IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD       IN  VARCHAR2 ,                  -- Language Code
        PSV_BRAND_CD      IN  VARCHAR2 ,                  -- 영업조직
        PSV_STOR_TP       IN  VARCHAR2 ,                  -- 직가맹
        PSV_STOR_CD       IN  VARCHAR2 ,                  -- 점포코드
        PSV_GFR_DATE      IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE      IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_ORG_CLASS     IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_L_CLASS_CD    IN  VARCHAR2 ,                  -- 대분류코드
        PSV_M_CLASS_CD    IN  VARCHAR2 ,                  -- 중분류코드
        PSV_S_CLASS_CD    IN  VARCHAR2 ,                  -- 소분류코드
        PSV_ITEM_TXT      IN  VARCHAR2 ,                  -- 제품코드/명
        PR_RESULT         IN  OUT PKG_CURSOR.REF_CUR ,    -- Result Set,
        PR_RTN_CD         OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG        OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN   기간별 수불현황 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-11-08         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2018-11-08
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/

    LS_STOR_TP      VARCHAR2(2);
    LS_BEGIN_YM     VARCHAR2(6);
    LS_COST_YM      VARCHAR2(6);
    LS_FR_DT        VARCHAR2(8);
    LS_TO_DT        VARCHAR2(8);
    LS_ERR_CD       VARCHAR2(7) ;
    LS_ERR_MSG      VARCHAR2(500) ;
    ERR_HANDLER     EXCEPTION;


    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        LS_ERR_CD   := '0' ;
        LS_BEGIN_YM := SUBSTR(PSV_GFR_DATE, 1, 6);
        LS_COST_YM  := SUBSTR(PSV_GTO_DATE, 1, 6);
        LS_FR_DT    := LS_BEGIN_YM || '01';
        LS_TO_DT    := PSV_GTO_DATE;

        IF PSV_STOR_TP IS NULL THEN
            LS_STOR_TP := '10';
        ELSE
            LS_STOR_TP := PSV_STOR_TP;
        END IF;

    OPEN PR_RESULT FOR
    SELECT  A.L_CLASS_NM
         ,  A.M_CLASS_NM
         ,  A.S_CLASS_NM
         ,  A.ITEM_CD
         ,  A.ITEM_NM
         ,  A.STANDARD
         ,  A.STOCK_UNIT
         ,  DECODE(PSV_STOR_CD, NULL, 0, A.COST)    AS COST
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
         ,  A.TOT_OUT_QTY
         ,  A.TOT_OUT_AMT
         ,  A.FREE_QTY
         ,  A.FREE_AMT
         ,  A.DSA_05_QTY
         ,  A.DSA_05_AMT
         ,  A.DSA_06_QTY
         ,  A.DSA_06_AMT
         ,  A.TOT_LOSS_QTY
         ,  A.TOT_LOSS_AMT
         ,  A.PRE_STOCK_QTY + A.TOT_IN_QTY - A.TOT_OUT_QTY - A.TOT_LOSS_QTY         AS STOCK_QTY    -- 장부재고
         ,  A.PRE_STOCK_AMT + A.TOT_IN_AMT - A.TOT_OUT_AMT - A.TOT_LOSS_AMT         AS STOCK_AMT
         ,  A.SURV_QTY
         ,  A.SURV_AMT
         ,  A.SURV_YN
         ,  CASE WHEN A.SURV_YN = 'N' THEN 0
                 ELSE A.SURV_QTY - (A.PRE_STOCK_QTY + A.TOT_IN_QTY - A.TOT_OUT_QTY - A.TOT_LOSS_QTY)
            END                                                                                     AS DIFF_QTY
         ,  CASE WHEN A.SURV_YN = 'N' THEN 0
                 ELSE A.SURV_AMT - (A.PRE_STOCK_AMT + A.TOT_IN_AMT - A.TOT_OUT_AMT - A.TOT_LOSS_AMT)
            END                                                                                     AS DIFF_AMT
         ,  CASE WHEN A.SURV_YN = 'Y' THEN (A.PRE_STOCK_QTY + A.TOT_IN_QTY) - A.RTN_QTY - A.MV_OUT_QTY - A.SURV_QTY
                 ELSE 0
            END                 AS USE_QTY
         ,  CASE WHEN A.SURV_YN = 'Y' THEN (A.PRE_STOCK_AMT + A.TOT_IN_AMT) - A.RTN_AMT - A.MV_OUT_AMT - A.SURV_AMT
                 ELSE 0
            END                 AS USE_AMT
      FROM  (
                SELECT  S.COMP_CD
                     ,  S.BRAND_CD
                     ,  S.ITEM_CD
                     ,  MAX(S.ITEM_NM)              AS ITEM_NM
                     ,  MAX(S.STANDARD)             AS STANDARD
                     ,  MAX(S.STOCK_UNIT)           AS STOCK_UNIT
                     ,  MAX(S.COST)                 AS COST
                     ,  MAX(S.L_CLASS_CD)           AS L_CLASS_CD
                     ,  MAX(LC.L_CLASS_NM)          AS L_CLASS_NM
                     ,  MAX(LC.SORT_ORDER)          AS L_SORT_ORDER
                     ,  MAX(S.M_CLASS_CD)           AS M_CLASS_CD
                     ,  MAX(MC.M_CLASS_NM)          AS M_CLASS_NM
                     ,  MAX(MC.SORT_ORDER)          AS M_SORT_ORDER
                     ,  MAX(S.S_CLASS_CD)           AS S_CLASS_CD
                     ,  MAX(SC.S_CLASS_NM)          AS S_CLASS_NM
                     ,  MAX(SC.SORT_ORDER)          AS S_SORT_ORDER
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
                     ,  SUM(S.SALE_QTY + S.PROD_OUT_QTY + S.MV_OUT_QTY + S.RTN_QTY)     AS TOT_OUT_QTY
                     ,  SUM(ROUND(S.SALE_QTY * S.COST) + ROUND(S.MV_OUT_QTY * S.COST) + S.RTN_AMT)  AS TOT_OUT_AMT
                     ,  SUM(S.FREE_QTY)                                                 AS FREE_QTY
                     ,  SUM(ROUND(S.FREE_QTY * S.COST))                                 AS FREE_AMT
                     ,  SUM(S.DSA_05_QTY)                                               AS DSA_05_QTY
                     ,  SUM(ROUND(S.DSA_05_QTY * S.COST))                               AS DSA_05_AMT
                     ,  SUM(S.DSA_06_QTY)                                               AS DSA_06_QTY
                     ,  SUM(ROUND(S.DSA_06_QTY * S.COST))                               AS DSA_06_AMT
                     ,  SUM(S.FREE_QTY + S.DSA_05_QTY + S.DSA_06_QTY)                   AS TOT_LOSS_QTY
                     ,  SUM(ROUND(S.FREE_QTY * S.COST))                                 AS TOT_LOSS_AMT
                     ,  SUM(S.SURV_QTY)                                                 AS SURV_QTY
                     ,  SUM(ROUND(S.SURV_QTY * S.COST))                                 AS SURV_AMT
                     ,  SUM(S.ADJ_QTY)                                                  AS ADJ_QTY
                     ,  CASE WHEN SUM(SUM(S.SURV_QTY)) OVER (PARTITION BY S.COMP_CD, S.BRAND_CD) > 0 THEN 'Y' ELSE 'N' END  AS SURV_YN
                  FROM  (
                            SELECT  D.COMP_CD
                                 ,  D.BRAND_CD
                                 ,  D.STOR_CD
                                 ,  D.ITEM_CD
                                 ,  MAX(I.ITEM_NM)                                              AS ITEM_NM
                                 ,  MAX(I.STANDARD)                                             AS STANDARD
                                 ,  MAX(I.STOCK_UNIT)                                           AS STOCK_UNIT
                                 ,  MAX(I.L_CLASS_CD)                                           AS L_CLASS_CD
                                 ,  MAX(I.M_CLASS_CD)                                           AS M_CLASS_CD
                                 ,  MAX(I.S_CLASS_CD)                                           AS S_CLASS_CD
                                 ,  MAX(ROUND(CASE WHEN I.ORD_UNIT_QTY > 0 THEN C.COST / I.ORD_UNIT_QTY ELSE 0 END, 3))    AS COST
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
                                 ,  SUM(D.PROD_IN_QTY)                                          AS PROD_IN_QTY
                                 ,  SUM(D.PROD_OUT_QTY)                                         AS PROD_OUT_QTY
                                 ,  SUM(D.FREE_QTY)                                             AS FREE_QTY
                                 ,  SUM(D.DSA_05_QTY)                                           AS DSA_05_QTY
                                 ,  SUM(D.DSA_06_QTY)                                           AS DSA_06_QTY
                                 ,  SUM(D.NOCHARGE_QTY)                                         AS NOCHARGE_QTY
                                 ,  SUM(D.SURV_QTY)                                             AS SURV_QTY
                                 ,  SUM(D.ADJ_QTY)                                              AS ADJ_QTY
                                 ,  SUM(D.TOT_ADJ_QTY)                                          AS TOT_ADJ_QTY
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
                                           AND  (PSV_L_CLASS_CD     IS NULL OR NVL(IC.L_CLASS_CD, I.L_CLASS_CD) = PSV_L_CLASS_CD)
                                           AND  (PSV_M_CLASS_CD     IS NULL OR NVL(IC.M_CLASS_CD, I.M_CLASS_CD) = PSV_M_CLASS_CD)
                                           AND  (PSV_S_CLASS_CD     IS NULL OR NVL(IC.S_CLASS_CD, I.S_CLASS_CD) = PSV_S_CLASS_CD)
                                           AND  (PSV_ITEM_TXT       IS NULL OR (I.ITEM_CD LIKE '%'||PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||PSV_ITEM_TXT||'%'))
                                           AND  I.STOCK_DIV <> 'N'
                                    )               I
                                 ,  (
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
                                              + SUM(CASE WHEN A.PRC_DT < PSV_GFR_DATE THEN  A.ADJ_QTY         ELSE 0 END)      AS PRE_INOUT_QTY
                                             ,  0                                                                           AS PRE_FREE_QTY
                                             ,  0                                                                           AS PRE_DSA_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.ORD_QTY         ELSE 0 END)      AS ORD_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  O.ORD_AMT         ELSE 0 END)      AS ORD_AMT  -- 주문금액 + 개별입고금액
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.PROD_IN_QTY     ELSE 0 END)      AS PROD_IN_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.MV_IN_QTY       ELSE 0 END)      AS MV_IN_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  M.MV_IN_AMT       ELSE 0 END)      AS MV_IN_AMT  -- 출고매장의 총평균단가로 산정한 점간이동입고금액
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.ETC_IN_QTY      ELSE 0 END)      AS ETC_IN_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.SALE_QTY        ELSE 0 END)      AS SALE_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.PROD_OUT_QTY    ELSE 0 END)      AS PROD_OUT_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.MV_OUT_QTY      ELSE 0 END)      AS MV_OUT_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.ETC_OUT_QTY     ELSE 0 END)      AS ETC_OUT_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.RTN_QTY         ELSE 0 END)      AS RTN_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  R.RTN_AMT         ELSE 0 END)      AS RTN_AMT
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.DISUSE_QTY      ELSE 0 END)      AS DISUSE_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND TO_CHAR(TO_DATE(PSV_GTO_DATE, 'YYYYMMDD')-1, 'YYYYMMDD') THEN  A.ADJ_QTY ELSE 0 END)  AS ADJ_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.ADJ_QTY         ELSE 0 END)      AS TOT_ADJ_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN  A.NOCHARGE_QTY    ELSE 0 END)      AS NOCHARGE_QTY
                                             ,  SUM(CASE WHEN A.PRC_DT = PSV_GTO_DATE                     THEN  A.SURV_QTY        ELSE 0 END)      AS SURV_QTY
                                             ,  0           AS FREE_QTY
                                             ,  0           AS DSA_05_QTY
                                             ,  0           AS DSA_06_QTY
                                          FROM  ITEM_CHAIN      I
                                             ,  DSTOCK          A
                                             ,  STORE           S
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
                                                       AND  OD.STK_DT      BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
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
                                                       AND  OD.STK_DT      BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                                                       AND  OD.BRAND_CD    = PSV_BRAND_CD
                                                       AND  (PSV_STOR_CD IS NULL OR OD.STOR_CD = PSV_STOR_CD)
                                                       AND  OD.ORD_FG      = '2'
                                                     GROUP  BY OD.COMP_CD, OD.STK_DT, OD.BRAND_CD, OD.STOR_CD, OD.ITEM_CD
                                                )               R   -- 반품
                                             ,  (
                                                    SELECT  M.COMP_CD
                                                         ,  M.IN_CONF_DT
                                                         ,  M.IN_BRAND_CD   AS  BRAND_CD
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
                                                       AND  M.IN_CONF_DT       BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                                                       AND  M.IN_BRAND_CD      = PSV_BRAND_CD
                                                       AND  (PSV_STOR_CD IS NULL OR M.IN_STOR_CD = PSV_STOR_CD)
                                                       AND  M.CONFIRM_DIV      IN ('3', '4')
                                                       AND  I.COMP_CD          = PSV_COMP_CD
                                                       AND  I.BRAND_CD         = PSV_BRAND_CD
                                                       AND  I.STOR_TP          = LS_STOR_TP
                                                       AND  C.PRC_YM(+)        = TO_CHAR(TO_DATE(M.IN_CONF_DT, 'YYYYMMDD'), 'YYYYMM')
                                                     GROUP  BY M.COMP_CD, M.IN_CONF_DT, M.IN_BRAND_CD, M.IN_STOR_CD, M.ITEM_CD
                                                )               M
                                         WHERE  I.COMP_CD           = A.COMP_CD
                                           AND  I.BRAND_CD          = A.BRAND_CD
                                           AND  I.ITEM_CD           = A.ITEM_CD
                                           AND  A.COMP_CD           = S.COMP_CD
                                           AND  A.BRAND_CD          = S.BRAND_CD
                                           AND  A.STOR_CD           = S.STOR_CD
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
                                           AND  (PSV_STOR_TP IS NULL OR S.STOR_TP = PSV_STOR_TP)
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
                                             ,  0           AS TOT_ADJ_QTY
                                             ,  0           AS NOCHARGE_QTY
                                             ,  0           AS SURV_QTY
                                             ,  0           AS FREE_QTY
                                             ,  0           AS DSA_05_QTY
                                             ,  0           AS DSA_06_QTY
                                          FROM  ITEM_CHAIN  I
                                             ,  MSTOCK      A
                                             ,  STORE       S
                                         WHERE  I.COMP_CD   = A.COMP_CD
                                           AND  I.BRAND_CD  = A.BRAND_CD
                                           AND  I.ITEM_CD   = A.ITEM_CD
                                           AND  A.COMP_CD   = S.COMP_CD
                                           AND  A.BRAND_CD  = S.BRAND_CD
                                           AND  A.STOR_CD   = S.STOR_CD
                                           AND  I.COMP_CD   = PSV_COMP_CD
                                           AND  I.BRAND_CD  = PSV_BRAND_CD
                                           AND  I.STOR_TP   = LS_STOR_TP
                                           AND  I.STOCK_DIV <> 'N'
                                           AND  A.COMP_CD   = PSV_COMP_CD
                                           AND  A.BRAND_CD  = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR A.STOR_CD = PSV_STOR_CD)
                                           AND  (PSV_STOR_TP IS NULL OR S.STOR_TP = PSV_STOR_TP)
                                           AND  A.PRC_YM    = LS_BEGIN_YM
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
                                             ,  0           AS TOT_ADJ_QTY
                                             ,  0           AS NOCHARGE_QTY
                                             ,  0           AS SURV_QTY
                                             ,  SUM ( CASE WHEN A.SALE_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN SALE_QTY ELSE 0 END )  AS FREE_QTY
                                             ,  0           AS DSA_05_QTY
                                             ,  0           AS DSA_06_QTY
                                          FROM  SALE_JDF    A
                                             ,  STORE       S
                                         WHERE  A.COMP_CD   = S.COMP_CD
                                           AND  A.BRAND_CD  = S.BRAND_CD
                                           AND  A.STOR_CD   = S.STOR_CD
                                           AND  A.COMP_CD   = PSV_COMP_CD
                                           AND  A.SALE_DT   BETWEEN LS_FR_DT AND LS_TO_DT
                                           AND  A.BRAND_CD  = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR A.STOR_CD = PSV_STOR_CD)
                                           AND  (PSV_STOR_TP IS NULL OR S.STOR_TP = PSV_STOR_TP)
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
                                             ,  SUM(CASE WHEN A.SALE_DT < PSV_GFR_DATE THEN  A.DO_QTY ELSE 0 END)   AS PRE_DSA_QTY
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
                                             ,  0           AS TOT_ADJ_QTY
                                             ,  0           AS NOCHARGE_QTY
                                             ,  0           AS SURV_QTY
                                             ,  0           AS FREE_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '05' AND A.SALE_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN DO_QTY ELSE 0 END )   AS DSA_05_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '06' AND A.SALE_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE THEN DO_QTY ELSE 0 END )   AS DSA_06_QTY
                                          FROM  SALE_CDR    A
                                             ,  STORE       S
                                         WHERE  A.COMP_CD   = S.COMP_CD
                                           AND  A.BRAND_CD  = S.BRAND_CD
                                           AND  A.STOR_CD   = S.STOR_CD
                                           AND  A.COMP_CD   = PSV_COMP_CD
                                           AND  A.SALE_DT   BETWEEN LS_FR_DT AND LS_TO_DT
                                           AND  A.BRAND_CD  = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR A.STOR_CD = PSV_STOR_CD)
                                           AND  (PSV_STOR_TP IS NULL OR S.STOR_TP = PSV_STOR_TP)
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
                                           AND  PRC_YM      = LS_COST_YM
                                           AND  BRAND_CD    = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR STOR_CD = PSV_STOR_CD)
                                    )   C
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

END PKG_STCK1031;

/
