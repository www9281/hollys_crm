--------------------------------------------------------
--  DDL for Function FC_GET_STOCK_EQTY_CD_MONTH
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_STOCK_EQTY_CD_MONTH" 
(
   PSV_COMP_CD   IN VARCHAR2,  -- Company
   PSV_LANG_CD   IN VARCHAR2,  -- 언어코드
   PSV_BRAND_CD  IN VARCHAR2,  -- 영업조직
   PSV_STOR_CD   IN VARCHAR2,  -- 점포코드
   PSV_FR_DT     IN VARCHAR2,  -- 검색일자(FROM)
   PSV_TO_DT     IN VARCHAR2   -- 검색일자(TO)
)
RETURN TBL_STOCK_EQTY_CD_DAY AS
    ls_fr_dt    VARCHAR2(8);
    ls_to_dt    VARCHAR2(8);
    ls_pre_dt   VARCHAR2(8);
    ls_ym       VARCHAR2(6);    
    ltb_stock   TBL_STOCK_EQTY_CD_DAY := TBL_STOCK_EQTY_CD_DAY();
    BEGIN
        ls_fr_dt  := PSV_FR_DT ;
        ls_to_dt  := PSV_TO_DT  ;


        SELECT  OT_STOCK_EQTY_CD_DAY
        (
                PSV_COMP_CD
             ,  PSV_BRAND_CD
             ,  PSV_STOR_CD
             ,  A.PRC_YM
             ,  A.ITEM_CD
             ,  I.L_CLASS_CD
             ,  I.M_CLASS_CD
             ,  I.S_CLASS_CD
             ,  ls_fr_dt || '01'
             ,  CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.BEGIN_QTY     END
             ,  CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.PRE_INOUT_QTY END
             ,  NULL
             ,  0
             ,  0
             ,    CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.PRE_INOUT_QTY END 
                + CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.ADJ_QTY END   
                + (A.ORD_QTY + A.ADD_SOUT_QTY + A.INS_SOUT_QTY + A.MV_IN_QTY + A.PROD_IN_QTY + A.ETC_IN_QTY ) 
                - (A.SALE_QTY + A.NOCHARGE_QTY  + A.ADD_MOUT_QTY + A.INS_MOUT_QTY + A.MV_OUT_QTY + A.PROD_OUT_QTY + A.ETC_OUT_QTY +  A.RTN_QTY) 
                -  CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.DISUSE_QTY END
             ,  A.ORD_QTY
             ,  A.ADD_SOUT_QTY
             ,  A.ADD_MOUT_QTY
             ,  A.INS_MOUT_QTY
             ,  A.INS_SOUT_QTY
             ,  A.MV_IN_QTY
             ,  A.MV_OUT_QTY
             ,  A.RTN_QTY
             ,  A.DISUSE_QTY
             ,  A.ADJ_QTY
             ,  A.SALE_QTY
             ,  A.PROD_IN_QTY
             ,  A.PROD_OUT_QTY
             ,  A.NOCHARGE_QTY
             ,  A.ETC_IN_QTY
             ,  A.ETC_OUT_QTY
             ,  A.FREE1
             ,  A.FREE2
             ,  A.FREE3
             ,  A.FREE4
             ,  A.FREE5
             ,  A.FREE6
             ,  A.FREE7
             ,  A.FREE8
             ,  A.FREE9
             ,  A.FREE10
             ,  A.FREE11
             ,  A.FREE12
             ,  A.FREE13
             ,  A.FREE14
             ,  A.ETC_ACC_01
             ,  A.ETC_ACC_02
             ,  A.ETC_ACC_03
             ,  A.ETC_ACC_04
             ,  A.ETC_ACC_05
             ,  A.ETC_ACC_06
             ,  A.ETC_ACC_99
        )   
        BULK COLLECT  INTO  ltb_stock 
          FROM  (
                    SELECT  A.PRC_YM
                         ,  A.ITEM_CD
                         ,  SUM(A.BEGIN_QTY)    AS BEGIN_QTY
                         ,  SUM(A.BEGIN_QTY)    AS PRE_INOUT_QTY
                         ,  SUM(A.ORD_QTY)      AS ORD_QTY
                         ,  SUM(A.ADD_SOUT_QTY) AS ADD_SOUT_QTY
                         ,  SUM(A.ADD_MOUT_QTY) AS ADD_MOUT_QTY
                         ,  SUM(A.INS_MOUT_QTY) AS INS_MOUT_QTY
                         ,  SUM(A.INS_SOUT_QTY) AS INS_SOUT_QTY
                         ,  SUM(A.MV_IN_QTY)    AS MV_IN_QTY
                         ,  SUM(A.MV_OUT_QTY)   AS MV_OUT_QTY
                         ,  SUM(A.RTN_QTY)      AS RTN_QTY
                         ,  SUM(A.DISUSE_QTY)   AS DISUSE_QTY
                         ,  SUM(A.ADJ_QTY)      AS ADJ_QTY
                         ,  SUM(A.SALE_QTY)     AS SALE_QTY
                         ,  SUM(A.PROD_IN_QTY)  AS PROD_IN_QTY
                         ,  SUM(A.PROD_OUT_QTY) AS PROD_OUT_QTY
                         ,  SUM(A.NOCHARGE_QTY) AS NOCHARGE_QTY
                         ,  SUM(A.ETC_IN_QTY)   AS ETC_IN_QTY
                         ,  SUM(A.ETC_OUT_QTY)  AS ETC_OUT_QTY
                         ,  SUM(A.FREE1)        AS FREE1
                         ,  SUM(A.FREE2)        AS FREE2
                         ,  SUM(A.FREE3)        AS FREE3
                         ,  SUM(A.FREE4)        AS FREE4
                         ,  SUM(A.FREE5)        AS FREE5
                         ,  SUM(A.FREE6)        AS FREE6
                         ,  SUM(A.FREE7)        AS FREE7
                         ,  SUM(A.FREE8)        AS FREE8
                         ,  SUM(A.FREE9)        AS FREE9
                         ,  SUM(A.FREE10)       AS FREE10
                         ,  SUM(A.FREE11)       AS FREE11
                         ,  SUM(A.FREE12)       AS FREE12
                         ,  SUM(A.FREE13)       AS FREE13
                         ,  SUM(A.FREE14)       AS FREE14
                         ,  SUM( A.ETC_ACC_01    )   ETC_ACC_01
                         ,  SUM( A.ETC_ACC_02    )   ETC_ACC_02
                         ,  SUM( A.ETC_ACC_03    )   ETC_ACC_03
                         ,  SUM( A.ETC_ACC_04    )   ETC_ACC_04
                         ,  SUM( A.ETC_ACC_05    )   ETC_ACC_05
                         ,  SUM( A.ETC_ACC_06    )   ETC_ACC_06
                         ,  SUM( A.ETC_ACC_99    )   ETC_ACC_99
                      FROM  (
                                SELECT  A.PRC_YM
                                     ,  A.ITEM_CD
                                     ,  A.BEGIN_QTY     AS BEGIN_QTY
                                     ,  A.BEGIN_QTY     AS PRE_INOUT_QTY
                                     ,  A.ORD_QTY       AS ORD_QTY
                                     ,  A.ADD_SOUT_QTY  AS ADD_SOUT_QTY
                                     ,  A.ADD_MOUT_QTY  AS ADD_MOUT_QTY
                                     ,  A.INS_MOUT_QTY  AS INS_MOUT_QTY
                                     ,  A.INS_SOUT_QTY  AS INS_SOUT_QTY
                                     ,  A.MV_IN_QTY     AS MV_IN_QTY
                                     ,  A.MV_OUT_QTY    AS MV_OUT_QTY
                                     ,  A.RTN_QTY       AS RTN_QTY
                                     ,  A.DISUSE_QTY    AS DISUSE_QTY
                                     ,  A.ADJ_QTY       AS ADJ_QTY
                                     ,  A.SALE_QTY      AS SALE_QTY
                                     ,  A.PROD_IN_QTY   AS PROD_IN_QTY
                                     ,  A.PROD_OUT_QTY  AS PROD_OUT_QTY
                                     ,  A.NOCHARGE_QTY  AS NOCHARGE_QTY
                                     ,  A.ETC_IN_QTY    AS ETC_IN_QTY
                                     ,  A.ETC_OUT_QTY   AS ETC_OUT_QTY
                                     ,  0               AS FREE1
                                     ,  0               AS FREE2
                                     ,  0               AS FREE3
                                     ,  0               AS FREE4
                                     ,  0               AS FREE5
                                     ,  0               AS FREE6
                                     ,  0               AS FREE7
                                     ,  0               AS FREE8
                                     ,  0               AS FREE9
                                     ,  0               AS FREE10
                                     ,  0               AS FREE11
                                     ,  0               AS FREE12
                                     ,  0               AS FREE13
                                     ,  0               AS FREE14
                                     ,  0               AS ETC_ACC_01
                                     ,  0               AS ETC_ACC_02
                                     ,  0               AS ETC_ACC_03
                                     ,  0               AS ETC_ACC_04
                                     ,  0               AS ETC_ACC_05
                                     ,  0               AS ETC_ACC_06
                                     ,  0               AS ETC_ACC_99
                                  FROM  MSTOCK A 
                                 WHERE  A.COMP_CD     = PSV_COMP_CD
                                   AND  A.BRAND_CD    = PSV_BRAND_CD
                                   AND  A.STOR_CD     = PSV_STOR_CD
                                   AND  A.PRC_YM BETWEEN ls_fr_dt AND ls_to_dt
                                UNION ALL
                                SELECT  SUBSTR(SALE_DT, 1, 6)   AS PRC_YM
                                     ,  A.ITEM_CD
                                     ,  0                   AS BEGIN_QTY
                                     ,  0                   AS PRE_INOUT_QTY
                                     ,  0                   AS ORD_QTY
                                     ,  0                   AS ADD_SOUT_QTY
                                     ,  0                   AS ADD_MOUT_QTY
                                     ,  0                   AS INS_MOUT_QTY
                                     ,  0                   AS INS_SOUT_QTY
                                     ,  0                   AS MV_IN_QTY
                                     ,  0                   AS MV_OUT_QTY
                                     ,  0                   AS RTN_QTY
                                     ,  0                   AS DISUSE_QTY
                                     ,  0                   AS ADJ_QTY
                                     ,  0                   AS SALE_QTY
                                     ,  0                   AS PROD_IN_QTY
                                     ,  0                   AS PROD_OUT_QTY
                                     ,  0                   AS NOCHARGE_QTY
                                     ,  0                   AS ETC_IN_QTY
                                     ,  0                   AS ETC_OUT_QTY
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '1'  THEN SALE_QTY ELSE 0 END )    AS FREE1
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '2'  THEN SALE_QTY ELSE 0 END )    AS FREE2
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '3'  THEN SALE_QTY ELSE 0 END )    AS FREE3
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '4'  THEN SALE_QTY ELSE 0 END )    AS FREE4
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '5'  THEN SALE_QTY ELSE 0 END )    AS FREE5
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '6'  THEN SALE_QTY ELSE 0 END )    AS FREE6
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '7'  THEN SALE_QTY ELSE 0 END )    AS FREE7
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '8'  THEN SALE_QTY ELSE 0 END )    AS FREE8
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '9'  THEN SALE_QTY ELSE 0 END )    AS FREE9
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '10' THEN SALE_QTY ELSE 0 END )    AS FREE10
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '11' THEN SALE_QTY ELSE 0 END )    AS FREE11
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '12' THEN SALE_QTY ELSE 0 END )    AS FREE12
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '13' THEN SALE_QTY ELSE 0 END )    AS FREE13
                                     ,  SUM ( CASE WHEN A.FREE_DIV = '14' THEN SALE_QTY ELSE 0 END )    AS FREE14
                                     ,  0                   AS ETC_ACC_01
                                     ,  0                   AS ETC_ACC_02
                                     ,  0                   AS ETC_ACC_03
                                     ,  0                   AS ETC_ACC_04
                                     ,  0                   AS ETC_ACC_05
                                     ,  0                   AS ETC_ACC_06
                                     ,  0                   AS ETC_ACC_99
                                  FROM  SALE_JDF A 
                                 WHERE  A.COMP_CD   = PSV_COMP_CD
                                   AND  A.BRAND_CD  = PSV_BRAND_CD
                                   AND  A.STOR_CD   = PSV_STOR_CD
                                   AND  A.SALE_DT  BETWEEN ls_fr_dt || '01'  AND ls_to_dt || '31'
                                 GROUP  BY SUBSTR(A.SALE_DT, 1, 6), A.ITEM_CD
                                UNION ALL
                                SELECT  SUBSTR(A.SALE_DT, 1, 6)   AS PRC_YM
                                     ,  A.C_ITEM_CD
                                     ,  0                   AS BEGIN_QTY
                                     ,  0                   AS PRE_INOUT_QTY
                                     ,  0                   AS ORD_QTY
                                     ,  0                   AS ADD_SOUT_QTY
                                     ,  0                   AS ADD_MOUT_QTY
                                     ,  0                   AS INS_MOUT_QTY
                                     ,  0                   AS INS_SOUT_QTY
                                     ,  0                   AS MV_IN_QTY
                                     ,  0                   AS MV_OUT_QTY
                                     ,  0                   AS RTN_QTY
                                     ,  0                   AS DISUSE_QTY
                                     ,  0                   AS ADJ_QTY
                                     ,  0                   AS SALE_QTY
                                     ,  0                   AS PROD_IN_QTY
                                     ,  0                   AS PROD_OUT_QTY
                                     ,  0                   AS NOCHARGE_QTY
                                     ,  0                   AS ETC_IN_QTY
                                     ,  0                   AS ETC_OUT_QTY
                                     ,  0                   AS FREE1
                                     ,  0                   AS FREE2
                                     ,  0                   AS FREE3
                                     ,  0                   AS FREE4
                                     ,  0                   AS FREE5
                                     ,  0                   AS FREE6
                                     ,  0                   AS FREE7
                                     ,  0                   AS FREE8
                                     ,  0                   AS FREE9
                                     ,  0                   AS FREE10
                                     ,  0                   AS FREE11
                                     ,  0                   AS FREE12
                                     ,  0                   AS FREE13
                                     ,  0                   AS FREE14
                                     ,  SUM ( CASE WHEN A.ADJ_DIV = '01' THEN DO_QTY ELSE 0 END )   AS ETC_ACC_01
                                     ,  SUM ( CASE WHEN A.ADJ_DIV = '02' THEN DO_QTY ELSE 0 END )   AS ETC_ACC_02
                                     ,  SUM ( CASE WHEN A.ADJ_DIV = '03' THEN DO_QTY ELSE 0 END )   AS ETC_ACC_03
                                     ,  SUM ( CASE WHEN A.ADJ_DIV = '04' THEN DO_QTY ELSE 0 END )   AS ETC_ACC_04
                                     ,  SUM ( CASE WHEN A.ADJ_DIV = '05' THEN DO_QTY ELSE 0 END )   AS ETC_ACC_05
                                     ,  SUM ( CASE WHEN A.ADJ_DIV = '06' THEN DO_QTY ELSE 0 END )   AS ETC_ACC_06
                                     ,  SUM ( CASE WHEN A.ADJ_DIV = '99' THEN DO_QTY ELSE 0 END )   AS ETC_ACC_99
                                  FROM  SALE_CDR A 
                                 WHERE  A.COMP_CD  = PSV_COMP_CD
                                   AND  A.SALE_DT  BETWEEN ls_fr_dt || '01'  AND ls_to_dt || '31'
                                   AND  A.BRAND_CD = PSV_BRAND_CD
                                   AND  A.STOR_CD  = PSV_STOR_CD
                                 GROUP  BY SUBSTR(A.SALE_DT, 1, 6), A.C_ITEM_CD
                            ) A
                     GROUP  BY A.PRC_YM, A.ITEM_CD 
                ) A
             ,  (
                    SELECT  I.ITEM_CD
                         ,  I.L_CLASS_CD
                         ,  I.M_CLASS_CD
                         ,  I.S_CLASS_CD
                         ,  'N' AUTO_DISUSE_YN
                      FROM  ITEM_CHAIN  I
                         ,  STORE       S
                     WHERE  S.COMP_CD   = I.COMP_CD
                       AND  S.BRAND_CD  = I.BRAND_CD
                       AND  S.STOR_TP   = I.STOR_TP 
                       AND  S.COMP_CD   = PSV_COMP_CD
                       AND  S.BRAND_CD  = PSV_BRAND_CD
                       AND  S.STOR_CD   = PSV_STOR_CD

                ) I 
         WHERE  A.ITEM_CD = I.ITEM_CD;  

RETURN ltb_stock;
END;

/
