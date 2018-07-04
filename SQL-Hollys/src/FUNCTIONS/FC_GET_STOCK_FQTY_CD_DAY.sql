--------------------------------------------------------
--  DDL for Function FC_GET_STOCK_FQTY_CD_DAY
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_STOCK_FQTY_CD_DAY" 
(
   PSV_COMP_CD   IN VARCHAR2,  -- Company
   PSV_LANG_CD   IN VARCHAR2,  -- 언어코드
   PSV_BRAND_CD  IN VARCHAR2,  -- 영업조직
   PSV_STOR_CD   IN VARCHAR2,  -- 점포코드
   PSV_YMD       IN VARCHAR2   -- 검색일자
)
RETURN TBL_STOCK_FQTY_CD_DAY AS
    ls_fr_dt    VARCHAR2(8);
    ls_to_dt    VARCHAR2(8);
    ls_pre_dt   VARCHAR2(8);
    ls_ym       VARCHAR2(6);    
    ltb_stock   TBL_STOCK_FQTY_CD_DAY := TBL_STOCK_FQTY_CD_DAY();

    BEGIN
        ls_ym     := SUBSTR(PSV_YMD,1,6) ;
        ls_fr_dt  := ls_ym || '01' ;
        ls_to_dt  := PSV_YMD  ;
        ls_pre_dt := TO_CHAR( TO_DATE(PSV_YMD, 'YYYYMMDD') - 1, 'YYYYMMDD')   ;

        SELECT  OT_STOCK_FQTY_CD_DAY
        (                  
                PSV_COMP_CD
             ,  PSV_BRAND_CD
             ,  PSV_STOR_CD
             ,  PSV_YMD
             ,  A.ITEM_CD
             ,  I.L_CLASS_CD
             ,  I.M_CLASS_CD
             ,  I.S_CLASS_CD
             ,  ls_fr_dt
             ,  CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.BEGIN_QTY END
             ,  CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.PRE_INOUT_QTY END
             ,  A.LAST_SALE_DT
             ,  I.COST
             ,  I.SALE_PRC
             ,    CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.PRE_INOUT_QTY END 
                + CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.ADJ_QTY END 
                + (A.ORD_QTY + A.ADD_SOUT_QTY + A.INS_SOUT_QTY + A.MV_IN_QTY + A.PROD_IN_QTY + A.ETC_IN_QTY ) 
                - (A.SALE_QTY + A.NOCHARGE_QTY  + A.ADD_MOUT_QTY + A.INS_MOUT_QTY + A.MV_OUT_QTY + A.PROD_OUT_QTY + A.ETC_OUT_QTY + A.RTN_QTY) 
                - CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.DISUSE_QTY END
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
        )   
        BULK COLLECT  INTO  ltb_stock 
          FROM  (
                    SELECT  A.ITEM_CD
                         ,  MAX( A.LAST_SALE_DT  )   LAST_SALE_DT
                         ,  SUM( A.BEGIN_QTY     )   BEGIN_QTY
                         ,  SUM( A.PRE_INOUT_QTY )   PRE_INOUT_QTY
                         ,  SUM( A.COST          )   COST
                         ,  SUM( A.SALE_PRC      )   SALE_PRC
                         ,  SUM( A.ORD_QTY       )   ORD_QTY
                         ,  SUM( A.ADD_SOUT_QTY  )   ADD_SOUT_QTY
                         ,  SUM( A.ADD_MOUT_QTY  )   ADD_MOUT_QTY
                         ,  SUM( A.INS_MOUT_QTY  )   INS_MOUT_QTY
                         ,  SUM( A.INS_SOUT_QTY  )   INS_SOUT_QTY
                         ,  SUM( A.MV_IN_QTY     )   MV_IN_QTY
                         ,  SUM( A.MV_OUT_QTY    )   MV_OUT_QTY
                         ,  SUM( A.RTN_QTY       )   RTN_QTY
                         ,  SUM( A.DISUSE_QTY    )   DISUSE_QTY
                         ,  SUM( A.ADJ_QTY       )   ADJ_QTY
                         ,  SUM( A.SALE_QTY      )   SALE_QTY
                         ,  SUM( A.PROD_IN_QTY   )   PROD_IN_QTY
                         ,  SUM( A.PROD_OUT_QTY  )   PROD_OUT_QTY
                         ,  SUM( A.NOCHARGE_QTY  )   NOCHARGE_QTY
                         ,  SUM( A.ETC_IN_QTY    )   ETC_IN_QTY
                         ,  SUM( A.ETC_OUT_QTY   )   ETC_OUT_QTY   
                         ,  SUM( A.FREE1         )   FREE1
                         ,  SUM( A.FREE2         )   FREE2
                         ,  SUM( A.FREE3         )   FREE3
                         ,  SUM( A.FREE4         )   FREE4
                         ,  SUM( A.FREE5         )   FREE5
                         ,  SUM( A.FREE6         )   FREE6
                         ,  SUM( A.FREE7         )   FREE7
                         ,  SUM( A.FREE8         )   FREE8
                         ,  SUM( A.FREE9         )   FREE9
                         ,  SUM( A.FREE10        )   FREE10
                         ,  SUM( A.FREE11        )   FREE11
                         ,  SUM( A.FREE12        )   FREE12
                         ,  SUM( A.FREE13        )   FREE13
                         ,  SUM( A.FREE14        )   FREE14
                      FROM  (
                                SELECT  A.ITEM_CD
                                     ,  0 BEGIN_QTY
                                     ,  MAX( CASE WHEN A.PRC_DT = ls_to_dt THEN  COST ELSE NULL END )       AS COST
                                     ,  MAX( CASE WHEN A.PRC_DT = ls_to_dt THEN  SALE_PRC ELSE NULL END )   AS SALE_PRC
                                     ,  MAX( CASE WHEN A.PRC_DT = ls_to_dt THEN  SUBSTR(A.LAST_SALE_DT,1,12) ELSE NULL END )    AS LAST_SALE_DT
                                     ,    SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.ORD_QTY ELSE 0 END ) 
                                        + SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.ADD_SOUT_QTY ELSE 0 END )
                                        - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.ADD_MOUT_QTY ELSE 0 END)  
                                        + SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.INS_SOUT_QTY ELSE 0 END) 
                                        - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.INS_MOUT_QTY ELSE 0 END)  
                                        + SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.MV_IN_QTY ELSE 0 END)    
                                        - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.MV_OUT_QTY ELSE 0 END)  
                                        - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.RTN_QTY ELSE 0 END)      
                                        - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.DISUSE_QTY ELSE 0 END)
                                        + SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.ADJ_QTY ELSE 0 END)  
                                        - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.SALE_QTY ELSE 0 END)
                                        + SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.PROD_IN_QTY ELSE 0 END)  
                                        - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.PROD_OUT_QTY ELSE 0 END) 
                                        - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.NOCHARGE_QTY ELSE 0 END)  
                                        + SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.ETC_IN_QTY ELSE 0 END)   
                                        - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.ETC_OUT_QTY ELSE 0 END) AS PRE_INOUT_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ORD_QTY ELSE 0 END )      AS ORD_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ADD_SOUT_QTY ELSE 0 END ) AS ADD_SOUT_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ADD_MOUT_QTY ELSE 0 END ) AS ADD_MOUT_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.INS_SOUT_QTY ELSE 0 END ) AS INS_SOUT_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.INS_MOUT_QTY ELSE 0 END ) AS INS_MOUT_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.MV_IN_QTY ELSE 0 END )    AS MV_IN_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.MV_OUT_QTY ELSE 0 END )   AS MV_OUT_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.RTN_QTY ELSE 0 END )      AS RTN_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.DISUSE_QTY ELSE 0 END )   AS DISUSE_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ADJ_QTY ELSE 0 END )      AS ADJ_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.SALE_QTY ELSE 0 END )     AS SALE_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.PROD_IN_QTY ELSE 0 END )  AS PROD_IN_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.PROD_OUT_QTY ELSE 0 END ) AS PROD_OUT_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.NOCHARGE_QTY ELSE 0 END ) AS NOCHARGE_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ETC_IN_QTY ELSE 0 END )   AS ETC_IN_QTY
                                     ,  SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ETC_OUT_QTY ELSE 0 END )  AS ETC_OUT_QTY
                                     ,  0   AS FREE1
                                     ,  0   AS FREE2
                                     ,  0   AS FREE3
                                     ,  0   AS FREE4
                                     ,  0   AS FREE5
                                     ,  0   AS FREE6
                                     ,  0   AS FREE7
                                     ,  0   AS FREE8
                                     ,  0   AS FREE9
                                     ,  0   AS FREE10
                                     ,  0   AS FREE11
                                     ,  0   AS FREE12
                                     ,  0   AS FREE13
                                     ,  0   AS FREE14
                                  FROM  DSTOCK A 
                                 WHERE  A.COMP_CD  = PSV_COMP_CD
                                   AND  A.BRAND_CD = PSV_BRAND_CD
                                   AND  A.STOR_CD  = PSV_STOR_CD
                                   AND  A.PRC_DT BETWEEN ls_fr_dt AND ls_to_dt
                                 GROUP  BY A.ITEM_CD
                                UNION ALL
                                SELECT  A.ITEM_CD
                                     ,  A.BEGIN_QTY
                                     ,  NULL        AS COST
                                     ,  NULL        AS SALE_PRC
                                     ,  NULL        AS LAST_SALE_DT
                                     ,  0           AS PRE_INOUT_QTY
                                     ,  0           AS ORD_QTY
                                     ,  0           AS ADD_SOUT_QTY
                                     ,  0           AS ADD_MOUT_QTY
                                     ,  0           AS INS_SOUT_QTY
                                     ,  0           AS INS_MOUT_QTY
                                     ,  0           AS MV_IN_QTY
                                     ,  0           AS MV_OUT_QTY
                                     ,  0           AS RTN_QTY
                                     ,  0           AS DISUSE_QTY
                                     ,  0           AS ADJ_QTY
                                     ,  0           AS SALE_QTY
                                     ,  0           AS PROD_IN_QTY
                                     ,  0           AS PROD_OUT_QTY
                                     ,  0           AS NOCHARGE_QTY
                                     ,  0           AS ETC_IN_QTY
                                     ,  0           AS ETC_OUT_QTY
                                     ,  0           AS FREE1
                                     ,  0           AS FREE2
                                     ,  0           AS FREE3
                                     ,  0           AS FREE4
                                     ,  0           AS FREE5
                                     ,  0           AS FREE6
                                     ,  0           AS FREE7
                                     ,  0           AS FREE8
                                     ,  0           AS FREE9
                                     ,  0           AS FREE10
                                     ,  0           AS FREE11
                                     ,  0           AS FREE12
                                     ,  0           AS FREE13
                                     ,  0           AS FREE14 
                                  FROM  MSTOCK A
                                 WHERE  A.COMP_CD  = PSV_COMP_CD
                                   AND  A.BRAND_CD = PSV_BRAND_CD
                                   AND  A.STOR_CD  = PSV_STOR_CD
                                   AND  A.PRC_YM   = ls_ym
                                UNION ALL
                                SELECT  A.ITEM_CD
                                     ,  0           AS BEGIN_QTY
                                     ,  NULL        AS COST
                                     ,  NULL        AS SALE_PRC
                                     ,  NULL        AS LAST_SALE_DT
                                     ,  0           AS PRE_INOUT_QTY
                                     ,  0           AS ORD_QTY
                                     ,  0           AS ADD_SOUT_QTY
                                     ,  0           AS ADD_MOUT_QTY
                                     ,  0           AS INS_SOUT_QTY
                                     ,  0           AS INS_MOUT_QTY
                                     ,  0           AS MV_IN_QTY
                                     ,  0           AS MV_OUT_QTY
                                     ,  0           AS RTN_QTY
                                     ,  0           AS DISUSE_QTY
                                     ,  0           AS ADJ_QTY
                                     ,  0           AS SALE_QTY
                                     ,  0           AS PROD_IN_QTY
                                     ,  0           AS PROD_OUT_QTY
                                     ,  0           AS NOCHARGE_QTY
                                     ,  0           AS ETC_IN_QTY
                                     ,  0           AS ETC_OUT_QTY
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
                                  FROM  SALE_JDF A 
                                 WHERE  A.COMP_CD  = PSV_COMP_CD
                                   AND  A.BRAND_CD = PSV_BRAND_CD
                                   AND  A.STOR_CD  = PSV_STOR_CD
                                   AND  A.SALE_DT  = ls_to_dt
                                 GROUP  BY ITEM_CD
                            ) A
                     GROUP  BY A.ITEM_CD
                ) A
             ,  (
                    SELECT  I.ITEM_CD
                         ,  I.L_CLASS_CD
                         ,  I.M_CLASS_CD
                         ,  I.S_CLASS_CD
                         ,  'N' AUTO_DISUSE_YN
                         ,  I.COST
                         ,  I.SALE_PRC
                      FROM  ITEM_CHAIN  I 
                         ,  STORE       S
                     WHERE  S.COMP_CD    = I.COMP_CD
                       AND  S.BRAND_CD   = I.BRAND_CD
                       AND  S.STOR_TP    = I.STOR_TP
                       AND  S.COMP_CD    = PSV_COMP_CD
                       AND  S.BRAND_CD   = PSV_BRAND_CD
                       AND  S.STOR_CD    = PSV_STOR_CD
                ) I 
         WHERE  A.ITEM_CD = I.ITEM_CD;

RETURN ltb_stock;
END;

/
