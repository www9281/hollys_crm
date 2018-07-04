--------------------------------------------------------
--  DDL for Function FC_GET_STOCK_QTY_CD_DAY
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_STOCK_QTY_CD_DAY" 
(
   PSV_COMP_CD   IN VARCHAR2,  -- Company Code
   PSV_LANG_CD   IN VARCHAR2,  -- 언어코드
   PSV_BRAND_CD  IN VARCHAR2,  -- 영업조직
   PSV_STOR_CD   IN VARCHAR2,  -- 점포코드
   PSV_YMD       IN VARCHAR2   -- 검색일자
)
RETURN TBL_STOCK_QTY_CD_DAY AS
    ls_fr_dt    VARCHAR2(8);
    ls_to_dt    VARCHAR2(8);
    ls_pre_dt   VARCHAR2(8);
    ls_ym       VARCHAR2(6);    
    ltb_stock   TBL_STOCK_QTY_CD_DAY := TBL_STOCK_QTY_CD_DAY();
BEGIN
  ls_ym     := SUBSTR(PSV_YMD,1,6) ;
  ls_fr_dt  := ls_ym || '01' ;
  ls_to_dt  := PSV_YMD  ;
  ls_pre_dt := TO_CHAR( TO_DATE(PSV_YMD, 'YYYYMMDD') - 1, 'YYYYMMDD')   ;

   SELECT OT_STOCK_QTY_CD_DAY
        (                  
        PSV_COMP_CD     ,
        PSV_BRAND_CD    ,
        PSV_STOR_CD     ,
        PSV_YMD         ,
        A.ITEM_CD          ,
        I.L_CLASS_CD       ,
        I.M_CLASS_CD       ,
        I.S_CLASS_CD       ,
        ls_fr_dt           ,
        CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.BEGIN_QTY  END     ,
        CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.PRE_INOUT_QTY END  ,
        A.LAST_SALE_DT   ,
        CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.PRE_INOUT_QTY END 
        + CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.ADJ_QTY END 
        + (A.ORD_QTY + A.ADD_SOUT_QTY + A.INS_SOUT_QTY + A.MV_IN_QTY + A.PROD_IN_QTY + A.ETC_IN_QTY ) 
        - (A.SALE_QTY + A.NOCHARGE_QTY  + A.ADD_MOUT_QTY + A.INS_MOUT_QTY + A.MV_OUT_QTY + A.PROD_OUT_QTY + A.ETC_OUT_QTY + A.RTN_QTY) 
        -  CASE WHEN I.AUTO_DISUSE_YN = 'Y' THEN 0 ELSE A.DISUSE_QTY END ,
        A.ORD_QTY          ,
        A.ADD_SOUT_QTY     ,
        A.ADD_MOUT_QTY     ,
        A.INS_MOUT_QTY     ,
        A.INS_SOUT_QTY     ,
        A.MV_IN_QTY        ,
        A.MV_OUT_QTY       ,
        A.RTN_QTY          ,
        A.DISUSE_QTY       ,
        A.ADJ_QTY          ,
        A.SALE_QTY         ,
        A.PROD_IN_QTY      ,
        A.PROD_OUT_QTY     ,
        A.NOCHARGE_QTY     ,
        A.ETC_IN_QTY       ,
        A.ETC_OUT_QTY             )   
    BULK COLLECT  INTO  ltb_stock 
    FROM    
        (
         SELECT A.ITEM_CD  , 
                MAX( A.LAST_SALE_DT  )   LAST_SALE_DT ,
                SUM( A.BEGIN_QTY     )   BEGIN_QTY , 
                SUM( A.PRE_INOUT_QTY )   PRE_INOUT_QTY ,
                SUM( A.ORD_QTY       )   ORD_QTY       ,
                SUM( A.ADD_SOUT_QTY  )   ADD_SOUT_QTY  ,
                SUM( A.ADD_MOUT_QTY  )   ADD_MOUT_QTY  ,
                SUM( A.INS_MOUT_QTY  )   INS_MOUT_QTY  ,
                SUM( A.INS_SOUT_QTY  )   INS_SOUT_QTY  ,
                SUM( A.MV_IN_QTY     )   MV_IN_QTY     ,
                SUM( A.MV_OUT_QTY    )   MV_OUT_QTY    ,
                SUM( A.RTN_QTY       )   RTN_QTY       ,
                SUM( A.DISUSE_QTY    )   DISUSE_QTY    ,
                SUM( A.ADJ_QTY       )   ADJ_QTY       ,
                SUM( A.SALE_QTY      )   SALE_QTY      ,
                SUM( A.PROD_IN_QTY   )   PROD_IN_QTY   ,
                SUM( A.PROD_OUT_QTY  )   PROD_OUT_QTY  ,
                SUM( A.NOCHARGE_QTY  )   NOCHARGE_QTY  ,
                SUM( A.ETC_IN_QTY    )   ETC_IN_QTY    ,
                SUM( A.ETC_OUT_QTY   )   ETC_OUT_QTY   
            FROM 
                 (
                  SELECT A.ITEM_CD  , 
                         0 BEGIN_QTY ,
                         MAX( CASE WHEN A.PRC_DT = ls_to_dt THEN  SUBSTR(A.LAST_SALE_DT,1,12) ELSE NULL END )  LAST_SALE_DT  , 
                         SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.ORD_QTY ELSE 0 END ) 
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
                         - SUM(CASE WHEN A.PRC_DT < ls_to_dt THEN  A.ETC_OUT_QTY ELSE 0 END) AS PRE_INOUT_QTY  ,
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ORD_QTY ELSE 0 END ) ORD_QTY ,
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ADD_SOUT_QTY ELSE 0 END ) ADD_SOUT_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ADD_MOUT_QTY ELSE 0 END ) ADD_MOUT_QTY, 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.INS_SOUT_QTY ELSE 0 END ) INS_SOUT_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.INS_MOUT_QTY ELSE 0 END ) INS_MOUT_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.MV_IN_QTY ELSE 0 END ) MV_IN_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.MV_OUT_QTY ELSE 0 END ) MV_OUT_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.RTN_QTY ELSE 0 END ) RTN_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.DISUSE_QTY ELSE 0 END ) DISUSE_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ADJ_QTY ELSE 0 END ) ADJ_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.SALE_QTY ELSE 0 END ) SALE_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.PROD_IN_QTY ELSE 0 END ) PROD_IN_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.PROD_OUT_QTY ELSE 0 END ) PROD_OUT_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.NOCHARGE_QTY ELSE 0 END ) NOCHARGE_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ETC_IN_QTY ELSE 0 END ) ETC_IN_QTY , 
                         SUM(CASE WHEN A.PRC_DT = ls_to_dt THEN  A.ETC_OUT_QTY ELSE 0 END ) ETC_OUT_QTY 
                    FROM DSTOCK A 
                   WHERE A.COMP_CD  = PSV_COMP_CD
                     AND A.BRAND_CD = PSV_BRAND_CD
                     AND A.STOR_CD  = PSV_STOR_CD
                     AND A.PRC_DT BETWEEN ls_fr_dt AND ls_to_dt
                   GROUP BY A.ITEM_CD
                  UNION ALL
                  SELECT A.ITEM_CD  , 
                         A.BEGIN_QTY ,
                         NULL  LAST_SALE_DT  , 
                         0  AS PRE_INOUT_QTY  ,
                         0 ORD_QTY ,
                         0 ADD_SOUT_QTY , 
                         0 ADD_MOUT_QTY, 
                         0 INS_SOUT_QTY , 
                         0 INS_MOUT_QTY , 
                         0 MV_IN_QTY , 
                         0 MV_OUT_QTY , 
                         0 RTN_QTY , 
                         0 DISUSE_QTY , 
                         0 ADJ_QTY , 
                         0 SALE_QTY , 
                         0 PROD_IN_QTY , 
                         0 PROD_OUT_QTY , 
                         0 NOCHARGE_QTY , 
                         0 ETC_IN_QTY , 
                         0 ETC_OUT_QTY 
                    FROM MSTOCK A
                   WHERE A.COMP_CD  = PSV_COMP_CD
                     AND A.BRAND_CD = PSV_BRAND_CD
                     AND A.STOR_CD  = PSV_STOR_CD
                     AND A.PRC_YM   = ls_ym 
                  ) A
              GROUP BY A.ITEM_CD
         ) A ,
         (SELECT I.ITEM_CD    , 
                 I.L_CLASS_CD ,
                 I.M_CLASS_CD ,
                 I.S_CLASS_CD ,
                 'N' AUTO_DISUSE_YN
            FROM ITEM_CHAIN I , STORE S
           WHERE S.COMP_CD    = I.COMP_CD
           AND   S.BRAND_CD   = I.BRAND_CD
           AND   S.STOR_TP    = I.STOR_TP
           AND   S.COMP_CD    = PSV_COMP_CD
           AND   S.BRAND_CD   = PSV_BRAND_CD
           AND   S.STOR_CD    = PSV_STOR_CD
        ) I 
        WHERE A.ITEM_CD = I.ITEM_CD ;

RETURN ltb_stock;
END;

/
