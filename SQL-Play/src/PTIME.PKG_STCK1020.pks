CREATE OR REPLACE PACKAGE       PKG_STCK1020 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_STCK1020
    --  Description      : 년 수불 현황 
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD       IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER          IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID        IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD       IN  VARCHAR2 ,                  -- Language Code
        PSV_BRAND_CD      IN  VARCHAR2 ,                  -- 영업조직
        PSV_STOR_CD       IN  VARCHAR2 ,                  -- 점포코드
        PSV_YEAR          IN  VARCHAR2 ,                  -- 조회년도
        PSV_ORG_CLASS     IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_L_CLASS_CD    IN  VARCHAR2 ,                  -- 대분류코드
        PSV_M_CLASS_CD    IN  VARCHAR2 ,                  -- 중분류코드
        PSV_S_CLASS_CD    IN  VARCHAR2 ,                  -- 소분류코드
        PSV_ORD_SALE_DIV  IN  VARCHAR2 ,                  -- 주문/판매
        PSV_ITEM_DIV      IN  VARCHAR2 ,                  -- 제상품구분
        PR_RESULT         IN  OUT PKG_CURSOR.REF_CUR ,    -- Result Set,
        PR_RTN_CD         OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG        OUT VARCHAR2                    -- 처리Message
    );
    
END PKG_STCK1020;

/

CREATE OR REPLACE PACKAGE BODY       PKG_STCK1020 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD       IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER          IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID        IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD       IN  VARCHAR2 ,                  -- Language Code
        PSV_BRAND_CD      IN  VARCHAR2 ,                  -- 영업조직
        PSV_STOR_CD       IN  VARCHAR2 ,                  -- 점포코드
        PSV_YEAR          IN  VARCHAR2 ,                  -- 조회년도
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
        NAME:       SP_MAIN         년 수불현황 
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
        
    LS_FR_YM        VARCHAR2(6);
    LS_TO_YM        VARCHAR2(6);
    LS_FR_DT        VARCHAR2(8);
    LS_TO_DT        VARCHAR2(8);
    LS_STOR_TP      STORE.STOR_TP%TYPE;
    LS_ERR_CD       VARCHAR2(7) ;
    LS_ERR_MSG      VARCHAR2(500) ;
    ERR_HANDLER     EXCEPTION;
    

    BEGIN
        LS_ERR_CD := '0' ;
        LS_FR_YM  := PSV_YEAR || '01';
        LS_TO_YM  := TO_CHAR(SYSDATE, 'YYYYMM');
        LS_FR_DT  := LS_FR_YM || '01' ;
        LS_TO_DT  := TO_CHAR(SYSDATE, 'YYYYMMDD');
    
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
         ,  A.MV_IN_QTY
         ,  A.MV_IN_AMT
         ,  A.OUT_QTY
         ,  A.OUT_AMT
         ,  A.RTN_QTY
         ,  A.RTN_AMT
         ,  A.MV_OUT_QTY
         ,  A.MV_OUT_AMT
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
         ,  A.STOCK_QTY
         ,  A.STOCK_AMT
         ,  A.SURV_QTY
         ,  A.SURV_AMT
         ,  CASE WHEN A.SURV_YN = 'N' THEN 0
                 ELSE A.SURV_QTY - A.STOCK_QTY
            END                                 AS DIFF_QTY
         ,  CASE WHEN A.SURV_YN = 'N' THEN 0
                 ELSE A.SURV_AMT - A.STOCK_AMT
            END                                 AS DIFF_AMT
      FROM  (
                SELECT  S.COMP_CD
                     ,  S.BRAND_CD
                     ,  S.ITEM_CD
                     ,  MAX(S.ITEM_NM)                      AS ITEM_NM
                     ,  MAX(S.STANDARD)                     AS STANDARD
                     ,  MAX(S.STOCK_UNIT)                   AS STOCK_UNIT
                     ,  MAX(S.COST)                         AS COST
                     ,  MAX(S.L_CLASS_CD)                   AS L_CLASS_CD
                     ,  MAX(LC.L_CLASS_NM)                  AS L_CLASS_NM
                     ,  MAX(LC.SORT_ORDER)                  AS L_SORT_ORDER
                     ,  MAX(S.M_CLASS_CD)                   AS M_CLASS_CD
                     ,  MAX(MC.M_CLASS_NM)                  AS M_CLASS_NM
                     ,  MAX(MC.SORT_ORDER)                  AS M_SORT_ORDER
                     ,  MAX(S.S_CLASS_CD)                   AS S_CLASS_CD
                     ,  MAX(SC.S_CLASS_NM)                  AS S_CLASS_NM
                     ,  MAX(SC.SORT_ORDER)                  AS S_SORT_ORDER
                     ,  SUM(S.PRE_STOCK_QTY)                AS PRE_STOCK_QTY
                     ,  SUM(S.PRE_STOCK_AMT)                AS PRE_STOCK_AMT
                     ,  SUM(S.ORD_QTY)                      AS ORD_QTY
                     ,  SUM(S.ORD_AMT)                      AS ORD_AMT
                     ,  SUM(S.MV_IN_QTY)                    AS MV_IN_QTY
                     ,  SUM(S.MV_IN_AMT)                    AS MV_IN_AMT
                     ,  SUM(S.SALE_QTY + S.FREE_1_QTY + S.FREE_2_QTY + S.FREE_3_QTY + S.FREE_4_QTY + S.FREE_5_QTY + S.FREE_6_QTY + S.FREE_7_QTY + S.FREE_8_QTY + S.FREE_9_QTY + S.FREE_10_QTY + S.FREE_11_QTY + S.FREE_12_QTY + S.FREE_13_QTY + S.FREE_14_QTY)  AS OUT_QTY
                     ,  SUM(ROUND(S.SALE_QTY * S.COST) + ROUND(S.FREE_1_QTY * S.COST) + ROUND(S.FREE_2_QTY * S.COST) + ROUND(S.FREE_3_QTY * S.COST) + ROUND(S.FREE_4_QTY * S.COST) + ROUND(S.FREE_5_QTY * S.COST) + ROUND(S.FREE_6_QTY * S.COST) + ROUND(S.FREE_7_QTY * S.COST) +
                        ROUND(S.FREE_8_QTY * S.COST) + ROUND(S.FREE_9_QTY * S.COST) + ROUND(S.FREE_10_QTY * S.COST) + ROUND(S.FREE_11_QTY * S.COST) + ROUND(S.FREE_12_QTY * S.COST) + ROUND(S.FREE_13_QTY * S.COST) + ROUND(S.FREE_14_QTY * S.COST))            AS OUT_AMT
                     ,  SUM(S.RTN_QTY)                      AS RTN_QTY
                     ,  SUM(S.RTN_AMT)                      AS RTN_AMT
                     ,  SUM(S.MV_OUT_QTY)                   AS MV_OUT_QTY
                     ,  SUM(S.MV_OUT_AMT)                   AS MV_OUT_AMT
                     ,  SUM(S.DSA_01_QTY)                   AS DSA_01_QTY
                     ,  SUM(ROUND(S.DSA_01_QTY * S.COST))   AS DSA_01_AMT
                     ,  SUM(S.DSA_02_QTY)                   AS DSA_02_QTY
                     ,  SUM(ROUND(S.DSA_02_QTY * S.COST))   AS DSA_02_AMT
                     ,  SUM(S.DSA_03_QTY)                   AS DSA_03_QTY
                     ,  SUM(ROUND(S.DSA_03_QTY * S.COST))   AS DSA_03_AMT
                     ,  SUM(S.DSA_04_QTY)                   AS DSA_04_QTY
                     ,  SUM(ROUND(S.DSA_04_QTY * S.COST))   AS DSA_04_AMT
                     ,  SUM(S.DSA_05_QTY)                   AS DSA_05_QTY
                     ,  SUM(ROUND(S.DSA_05_QTY * S.COST))   AS DSA_05_AMT
                     ,  SUM(S.DSA_06_QTY)                   AS DSA_06_QTY
                     ,  SUM(ROUND(S.DSA_06_QTY * S.COST))   AS DSA_06_AMT
                     ,  SUM(S.DSA_99_QTY)                   AS DSA_99_QTY
                     ,  SUM(ROUND(S.DSA_99_QTY * S.COST))   AS DSA_99_AMT
                     ,  SUM(S.END_QTY)                      AS STOCK_QTY
                     ,  SUM(S.END_AMT)                      AS STOCK_AMT
                     ,  SUM(S.SURV_QTY)                     AS SURV_QTY
                     ,  SUM(S.SURV_QTY * S.COST)            AS SURV_AMT
                     ,  CASE WHEN SUM(SUM(S.SURV_QTY)) OVER (PARTITION BY S.COMP_CD, S.BRAND_CD) > 0 THEN 'Y' ELSE 'N' END   AS SURV_YN
                  FROM  (
                            SELECT  /*+ ORDERED */
                                    D.COMP_CD
                                 ,  D.BRAND_CD
                                 ,  D.STOR_CD
                                 ,  D.ITEM_CD
                                 ,  MAX(I.ITEM_NM)          AS ITEM_NM
                                 ,  MAX(I.STANDARD)         AS STANDARD
                                 ,  MAX(I.STOCK_UNIT)       AS STOCK_UNIT
                                 ,  MAX(I.L_CLASS_CD)       AS L_CLASS_CD
                                 ,  MAX(I.M_CLASS_CD)       AS M_CLASS_CD
                                 ,  MAX(I.S_CLASS_CD)       AS S_CLASS_CD
                                 ,  MAX(ROUND(CASE WHEN I.ORD_UNIT_QTY > 0 THEN NVL(C.COST, 0) / I.ORD_UNIT_QTY ELSE 0 END, 3))    AS COST
                                 ,  SUM(D.PRE_STOCK_QTY)    AS PRE_STOCK_QTY
                                 ,  SUM(D.PRE_STOCK_AMT)    AS PRE_STOCK_AMT
                                 ,  SUM(D.ORD_QTY)          AS ORD_QTY
                                 ,  SUM(D.ORD_AMT)          AS ORD_AMT
                                 ,  SUM(D.MV_IN_QTY)        AS MV_IN_QTY
                                 ,  SUM(D.MV_IN_AMT)        AS MV_IN_AMT
                                 ,  SUM(D.SALE_QTY)         AS SALE_QTY
                                 ,  SUM(D.RTN_QTY)          AS RTN_QTY
                                 ,  SUM(D.RTN_AMT)          AS RTN_AMT
                                 ,  SUM(D.MV_OUT_QTY)       AS MV_OUT_QTY
                                 ,  SUM(D.MV_OUT_AMT)       AS MV_OUT_AMT
                                 ,  SUM(D.FREE_1_QTY)       AS FREE_1_QTY
                                 ,  SUM(D.FREE_2_QTY)       AS FREE_2_QTY
                                 ,  SUM(D.FREE_3_QTY)       AS FREE_3_QTY
                                 ,  SUM(D.FREE_4_QTY)       AS FREE_4_QTY
                                 ,  SUM(D.FREE_5_QTY)       AS FREE_5_QTY
                                 ,  SUM(D.FREE_6_QTY)       AS FREE_6_QTY
                                 ,  SUM(D.FREE_7_QTY)       AS FREE_7_QTY
                                 ,  SUM(D.FREE_8_QTY)       AS FREE_8_QTY
                                 ,  SUM(D.FREE_9_QTY)       AS FREE_9_QTY
                                 ,  SUM(D.FREE_10_QTY)      AS FREE_10_QTY
                                 ,  SUM(D.FREE_11_QTY)      AS FREE_11_QTY
                                 ,  SUM(D.FREE_12_QTY)      AS FREE_12_QTY
                                 ,  SUM(D.FREE_13_QTY)      AS FREE_13_QTY
                                 ,  SUM(D.FREE_14_QTY)      AS FREE_14_QTY
                                 ,  SUM(D.DSA_01_QTY)       AS DSA_01_QTY
                                 ,  SUM(D.DSA_02_QTY)       AS DSA_02_QTY
                                 ,  SUM(D.DSA_03_QTY)       AS DSA_03_QTY
                                 ,  SUM(D.DSA_04_QTY)       AS DSA_04_QTY
                                 ,  SUM(D.DSA_05_QTY)       AS DSA_05_QTY
                                 ,  SUM(D.DSA_06_QTY)       AS DSA_06_QTY
                                 ,  SUM(D.DSA_99_QTY)       AS DSA_99_QTY
                                 ,  SUM(D.SURV_QTY)         AS SURV_QTY
                                 ,  MAX(C.END_QTY)          AS END_QTY
                                 ,  MAX(C.END_AMT)          AS END_AMT
                              FROM  (
                                        SELECT  /*+ USE_NL(I, IC L) */
                                                I.COMP_CD
                                             ,  I.BRAND_CD
                                             ,  I.ITEM_CD
                                             ,  NVL(L.ITEM_NM, I.ITEM_NM)           AS ITEM_NM
                                             ,  I.COST
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
                                             ,  A.BEGIN_QTY                                     AS PRE_STOCK_QTY
                                             ,  A.BEGIN_AMT                                     AS PRE_STOCK_AMT
                                             ,  0                                               AS ORD_QTY
                                             ,  0                                               AS ORD_AMT
                                             ,  0                                               AS MV_IN_QTY
                                             ,  0                                               AS MV_IN_AMT
                                             ,  0                                               AS SALE_QTY
                                             ,  0                                               AS RTN_QTY
                                             ,  0                                               AS RTN_AMT
                                             ,  0                                               AS MV_OUT_QTY
                                             ,  0                                               AS MV_OUT_AMT
                                             ,  0                                               AS FREE_1_QTY
                                             ,  0                                               AS FREE_2_QTY
                                             ,  0                                               AS FREE_3_QTY
                                             ,  0                                               AS FREE_4_QTY
                                             ,  0                                               AS FREE_5_QTY
                                             ,  0                                               AS FREE_6_QTY
                                             ,  0                                               AS FREE_7_QTY
                                             ,  0                                               AS FREE_8_QTY
                                             ,  0                                               AS FREE_9_QTY
                                             ,  0                                               AS FREE_10_QTY
                                             ,  0                                               AS FREE_11_QTY
                                             ,  0                                               AS FREE_12_QTY
                                             ,  0                                               AS FREE_13_QTY
                                             ,  0                                               AS FREE_14_QTY
                                             ,  0                                               AS DSA_01_QTY
                                             ,  0                                               AS DSA_02_QTY
                                             ,  0                                               AS DSA_03_QTY
                                             ,  0                                               AS DSA_04_QTY
                                             ,  0                                               AS DSA_05_QTY
                                             ,  0                                               AS DSA_06_QTY
                                             ,  0                                               AS DSA_99_QTY
                                             ,  0                                               AS SURV_QTY
                                          FROM  ITEM_CHAIN  I
                                             ,  MSTOCK      A  
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
                                           AND  A.PRC_YM    = LS_FR_YM
                                        UNION ALL
                                        SELECT  A.COMP_CD
                                             ,  A.BRAND_CD
                                             ,  A.STOR_CD
                                             ,  A.ITEM_CD
                                             ,  0                                               AS PRE_STOCK_QTY
                                             ,  0                                               AS PRE_STOCK_AMT
                                             ,  A.ORD_QTY                                       AS ORD_QTY
                                             ,  A.ORD_AMT                                       AS ORD_AMT
                                             ,  0                                               AS MV_IN_QTY
                                             ,  0                                               AS MV_IN_AMT
                                             ,  A.SALE_QTY                                      AS SALE_QTY
                                             ,  A.RTN_QTY                                       AS RTN_QTY
                                             ,  A.RTN_AMT                                       AS RTN_AMT
                                             ,  0                                               AS MV_OUT_QTY
                                             ,  0                                               AS MV_OUT_AMT
                                             ,  0                                               AS FREE_1_QTY
                                             ,  0                                               AS FREE_2_QTY
                                             ,  0                                               AS FREE_3_QTY
                                             ,  0                                               AS FREE_4_QTY
                                             ,  0                                               AS FREE_5_QTY
                                             ,  0                                               AS FREE_6_QTY
                                             ,  0                                               AS FREE_7_QTY
                                             ,  0                                               AS FREE_8_QTY
                                             ,  0                                               AS FREE_9_QTY
                                             ,  0                                               AS FREE_10_QTY
                                             ,  0                                               AS FREE_11_QTY
                                             ,  0                                               AS FREE_12_QTY
                                             ,  0                                               AS FREE_13_QTY
                                             ,  0                                               AS FREE_14_QTY
                                             ,  0                                               AS DSA_01_QTY
                                             ,  0                                               AS DSA_02_QTY
                                             ,  0                                               AS DSA_03_QTY
                                             ,  0                                               AS DSA_04_QTY
                                             ,  0                                               AS DSA_05_QTY
                                             ,  0                                               AS DSA_06_QTY
                                             ,  0                                               AS DSA_99_QTY
                                             ,  A.SURV_QTY
                                          FROM  ITEM_CHAIN  I
                                             ,  MSTOCK      A  
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
                                           AND  A.PRC_YM    BETWEEN LS_FR_YM AND LS_TO_YM
                                        UNION ALL
                                        SELECT  A.COMP_CD
                                             ,  A.IN_BRAND_CD                               AS BRAND_CD
                                             ,  A.IN_STOR_CD                                AS STOR_CD
                                             ,  A.ITEM_CD
                                             ,  0                                           AS PRE_STOCK_QTY
                                             ,  0                                           AS PRE_STOCK_AMT
                                             ,  0                                           AS ORD_QTY
                                             ,  0                                           AS ORD_AMT
                                             ,  SUM(NVL(A.MV_CQTY, 0) * NVL(A.MV_UNIT_QTY, 1))  AS MV_IN_QTY
                                             ,  SUM(NVL(A.MV_CQTY, 0) * NVL(A.MV_UNIT_QTY, 1) * ROUND((CASE WHEN I.ORD_UNIT_QTY > 0 THEN NVL(B.END_COST, 0) / I.ORD_UNIT_QTY ELSE 0 END), 3))  AS MV_IN_AMT
                                             ,  0                                           AS SALE_QTY
                                             ,  0                                           AS RTN_QTY
                                             ,  0                                           AS RTN_AMT
                                             ,  0                                           AS MV_OUT_QTY
                                             ,  0                                           AS MV_OUT_AMT
                                             ,  0                                           AS FREE_1_QTY
                                             ,  0                                           AS FREE_2_QTY
                                             ,  0                                           AS FREE_3_QTY
                                             ,  0                                           AS FREE_4_QTY
                                             ,  0                                           AS FREE_5_QTY
                                             ,  0                                           AS FREE_6_QTY
                                             ,  0                                           AS FREE_7_QTY
                                             ,  0                                           AS FREE_8_QTY
                                             ,  0                                           AS FREE_9_QTY
                                             ,  0                                           AS FREE_10_QTY
                                             ,  0                                           AS FREE_11_QTY
                                             ,  0                                           AS FREE_12_QTY
                                             ,  0                                           AS FREE_13_QTY
                                             ,  0                                           AS FREE_14_QTY
                                             ,  0                                           AS DSA_01_QTY
                                             ,  0                                           AS DSA_02_QTY
                                             ,  0                                           AS DSA_03_QTY
                                             ,  0                                           AS DSA_04_QTY
                                             ,  0                                           AS DSA_05_QTY
                                             ,  0                                           AS DSA_06_QTY
                                             ,  0                                           AS DSA_99_QTY
                                             ,  0                                           AS SURV_QTY
                                          FROM  MOVE_STORE      A
                                             ,  MSTOCK          B
                                             ,  ITEM_CHAIN      I
                                         WHERE  A.COMP_CD       = B.COMP_CD(+)
                                           AND  SUBSTR(A.IN_CONF_DT, 1, 6) = B.PRC_YM(+)
                                           AND  A.OUT_BRAND_CD  = B.BRAND_CD(+)
                                           AND  A.OUT_STOR_CD   = B.STOR_CD(+)
                                           AND  A.ITEM_CD       = B.ITEM_CD(+)
                                           AND  A.COMP_CD       = I.COMP_CD(+)
                                           AND  A.IN_BRAND_CD   = I.BRAND_CD(+)
                                           AND  A.ITEM_CD       = I.ITEM_CD(+)
                                           AND  A.COMP_CD       = PSV_COMP_CD
                                           AND  A.IN_CONF_DT    BETWEEN LS_FR_DT AND LS_TO_DT
                                           AND  A.IN_BRAND_CD   = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR A.IN_STOR_CD = PSV_STOR_CD)
                                           AND  A.CONFIRM_DIV   IN ('3', '4')
                                           AND  I.COMP_CD       = PSV_COMP_CD
                                           AND  I.BRAND_CD      = PSV_BRAND_CD
                                           AND  I.STOR_TP       = LS_STOR_TP
                                         GROUP  BY A.COMP_CD, A.IN_BRAND_CD, A.IN_STOR_CD, A.ITEM_CD
                                        UNION ALL
                                        SELECT  A.COMP_CD
                                             ,  A.OUT_BRAND_CD                              AS BRAND_CD
                                             ,  A.OUT_STOR_CD                               AS STOR_CD
                                             ,  A.ITEM_CD
                                             ,  0                                           AS PRE_STOCK_QTY
                                             ,  0                                           AS PRE_STOCK_AMT
                                             ,  0                                           AS ORD_QTY
                                             ,  0                                           AS ORD_AMT
                                             ,  0                                           AS MV_IN_QTY
                                             ,  0                                           AS MV_IN_AMT
                                             ,  0                                           AS SALE_QTY
                                             ,  0                                           AS RTN_QTY
                                             ,  0                                           AS RTN_AMT
                                             ,  SUM(NVL(A.MV_CQTY, 0) * NVL(A.MV_UNIT_QTY, 1))  AS MV_OUT_QTY
                                             ,  SUM(NVL(A.MV_CQTY, 0) * NVL(A.MV_UNIT_QTY, 1) * ROUND((CASE WHEN I.ORD_UNIT_QTY > 0 THEN NVL(B.END_COST, 0) / I.ORD_UNIT_QTY ELSE 0 END), 2))  AS MV_OUT_AMT
                                             ,  0                                           AS FREE_1_QTY
                                             ,  0                                           AS FREE_2_QTY
                                             ,  0                                           AS FREE_3_QTY
                                             ,  0                                           AS FREE_4_QTY
                                             ,  0                                           AS FREE_5_QTY
                                             ,  0                                           AS FREE_6_QTY
                                             ,  0                                           AS FREE_7_QTY
                                             ,  0                                           AS FREE_8_QTY
                                             ,  0                                           AS FREE_9_QTY
                                             ,  0                                           AS FREE_10_QTY
                                             ,  0                                           AS FREE_11_QTY
                                             ,  0                                           AS FREE_12_QTY
                                             ,  0                                           AS FREE_13_QTY
                                             ,  0                                           AS FREE_14_QTY
                                             ,  0                                           AS DSA_01_QTY
                                             ,  0                                           AS DSA_02_QTY
                                             ,  0                                           AS DSA_03_QTY
                                             ,  0                                           AS DSA_04_QTY
                                             ,  0                                           AS DSA_05_QTY
                                             ,  0                                           AS DSA_06_QTY
                                             ,  0                                           AS DSA_99_QTY
                                             ,  0                                           AS SURV_QTY
                                          FROM  MOVE_STORE      A
                                             ,  MSTOCK          B
                                             ,  ITEM_CHAIN      I
                                         WHERE  A.COMP_CD       = B.COMP_CD(+)
                                           AND  SUBSTR(A.OUT_CONF_DT, 1, 6) = B.PRC_YM(+)
                                           AND  A.OUT_BRAND_CD  = B.BRAND_CD(+)
                                           AND  A.OUT_STOR_CD   = B.STOR_CD(+)
                                           AND  A.ITEM_CD       = B.ITEM_CD(+)
                                           AND  A.COMP_CD       = I.COMP_CD(+)
                                           AND  A.OUT_BRAND_CD  = I.BRAND_CD(+)
                                           AND  A.ITEM_CD       = I.ITEM_CD(+)
                                           AND  A.COMP_CD       = PSV_COMP_CD
                                           AND  A.OUT_CONF_DT    BETWEEN LS_FR_DT AND LS_TO_DT
                                           AND  A.OUT_BRAND_CD  = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR A.OUT_STOR_CD = PSV_STOR_CD)
                                           AND  A.CONFIRM_DIV   IN ('3', '4')
                                           AND  I.COMP_CD       = PSV_COMP_CD
                                           AND  I.BRAND_CD      = PSV_BRAND_CD
                                           AND  I.STOR_TP       = LS_STOR_TP
                                         GROUP  BY A.COMP_CD, A.OUT_BRAND_CD, A.OUT_STOR_CD, A.ITEM_CD
                                        UNION ALL
                                        SELECT  A.COMP_CD
                                             ,  A.BRAND_CD
                                             ,  A.STOR_CD
                                             ,  A.ITEM_CD
                                             ,  0                                           AS PRE_STOCK_QTY
                                             ,  0                                           AS PRE_STOCK_AMT
                                             ,  0                                           AS ORD_QTY
                                             ,  0                                           AS ORD_AMT
                                             ,  0                                           AS MV_IN_QTY
                                             ,  0                                           AS MV_IN_AMT
                                             ,  0                                           AS SALE_QTY
                                             ,  0                                           AS RTN_QTY
                                             ,  0                                           AS RTN_AMT
                                             ,  0                                           AS MV_OUT_QTY
                                             ,  0                                           AS MV_OUT_AMT
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '1'  THEN SALE_QTY ELSE 0 END )    AS FREE_1_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '2'  THEN SALE_QTY ELSE 0 END )    AS FREE_2_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '3'  THEN SALE_QTY ELSE 0 END )    AS FREE_3_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '4'  THEN SALE_QTY ELSE 0 END )    AS FREE_4_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '5'  THEN SALE_QTY ELSE 0 END )    AS FREE_5_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '6'  THEN SALE_QTY ELSE 0 END )    AS FREE_6_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '7'  THEN SALE_QTY ELSE 0 END )    AS FREE_7_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '8'  THEN SALE_QTY ELSE 0 END )    AS FREE_8_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '9'  THEN SALE_QTY ELSE 0 END )    AS FREE_9_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '10' THEN SALE_QTY ELSE 0 END )    AS FREE_10_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '11' THEN SALE_QTY ELSE 0 END )    AS FREE_11_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '12' THEN SALE_QTY ELSE 0 END )    AS FREE_12_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '13' THEN SALE_QTY ELSE 0 END )    AS FREE_13_QTY
                                             ,  SUM ( CASE WHEN A.FREE_DIV = '14' THEN SALE_QTY ELSE 0 END )    AS FREE_14_QTY
                                             ,  0                                           AS DSA_01_QTY
                                             ,  0                                           AS DSA_02_QTY
                                             ,  0                                           AS DSA_03_QTY
                                             ,  0                                           AS DSA_04_QTY
                                             ,  0                                           AS DSA_05_QTY
                                             ,  0                                           AS DSA_06_QTY
                                             ,  0                                           AS DSA_99_QTY
                                             ,  0                                           AS SURV_QTY
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
                                             ,  0                                           AS PRE_STOCK_QTY
                                             ,  0                                           AS PRE_STOCK_AMT
                                             ,  0                                           AS ORD_QTY
                                             ,  0                                           AS ORD_AMT
                                             ,  0                                           AS MV_IN_QTY
                                             ,  0                                           AS MV_IN_AMT
                                             ,  0                                           AS SALE_QTY
                                             ,  0                                           AS RTN_QTY
                                             ,  0                                           AS RTN_AMT
                                             ,  0                                           AS MV_OUT_QTY
                                             ,  0                                           AS MV_OUT_AMT
                                             ,  0                                           AS FREE_1_QTY
                                             ,  0                                           AS FREE_2_QTY
                                             ,  0                                           AS FREE_3_QTY
                                             ,  0                                           AS FREE_4_QTY
                                             ,  0                                           AS FREE_5_QTY
                                             ,  0                                           AS FREE_6_QTY
                                             ,  0                                           AS FREE_7_QTY
                                             ,  0                                           AS FREE_8_QTY
                                             ,  0                                           AS FREE_9_QTY
                                             ,  0                                           AS FREE_10_QTY
                                             ,  0                                           AS FREE_11_QTY
                                             ,  0                                           AS FREE_12_QTY
                                             ,  0                                           AS FREE_13_QTY
                                             ,  0                                           AS FREE_14_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '01' THEN A.DO_QTY ELSE 0 END )   AS DSA_01_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '02' THEN A.DO_QTY ELSE 0 END )   AS DSA_02_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '03' THEN A.DO_QTY ELSE 0 END )   AS DSA_03_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '04' THEN A.DO_QTY ELSE 0 END )   AS DSA_04_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '05' THEN A.DO_QTY ELSE 0 END )   AS DSA_05_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '06' THEN A.DO_QTY ELSE 0 END )   AS DSA_06_QTY
                                             ,  SUM ( CASE WHEN A.ADJ_DIV = '99' THEN A.DO_QTY ELSE 0 END )   AS DSA_99_QTY
                                             ,  0                                           AS SURV_QTY
                                          FROM  SALE_CDR    A
                                         WHERE  A.COMP_CD       = PSV_COMP_CD
                                           AND  A.SALE_DT       BETWEEN LS_FR_DT AND LS_TO_DT
                                           AND  A.BRAND_CD      = PSV_BRAND_CD
                                           AND  (PSV_STOR_CD IS NULL OR A.STOR_CD = PSV_STOR_CD)
                                         GROUP  BY A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.C_ITEM_CD  
                                    )               D
                                 ,  (
                                        SELECT  COMP_CD
                                             ,  BRAND_CD
                                             ,  STOR_CD
                                             ,  ITEM_CD
                                             ,  END_COST    AS COST
                                             ,  END_QTY
                                             ,  END_AMT
                                          FROM  MSTOCK
                                         WHERE  COMP_CD     = PSV_COMP_CD
                                           AND  PRC_YM      = LS_TO_YM
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

END PKG_STCK1020;

/
