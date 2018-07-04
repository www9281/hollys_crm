--------------------------------------------------------
--  DDL for Procedure C_CUST_MENU_DAYLY_ANALYZE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_MENU_DAYLY_ANALYZE" (

    P_COMP_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    N_STORE_CD     IN  VARCHAR2,
    N_ITEM_L_CLASS      IN  VARCHAR2,
    N_ITEM_M_CLASS      IN  VARCHAR2,
    N_ITEM_S_CLASS      IN  VARCHAR2,
    N_ITEM_D_CLASS      IN  VARCHAR2,
    
    O_CURSOR       OUT SYS_REFCURSOR
) IS
   
BEGIN
--------------------------------- 회원등급 상품분류별 구매분석 ----------------------------------
  
    OPEN O_CURSOR FOR
    
        SELECT  
                BR.BRAND_NM
              , C1.CODE_NM AS   STOR_TP
              , C2.CODE_NM AS   TEAM_NM
              , ST.TEAM_CD          
              , ST.BUSI_NM       
              , D1.STOR_CD          
              , ST.STOR_NM
              , L.L_CLASS_NM
              , M.M_CLASS_NM
              , S.S_CLASS_NM
              , D.D_CLASS_NM   
              , IT.SEASON_DIV    
              , D1.ITEM_CD          
              , IT.ITEM_NM          
              , D1.SALE_DT          
              ,'('||TO_CHAR(TO_DATE(D1.SALE_DT, 'YYYYMMDD'), 'DY')||')' AS DAY_NAME 
              , D1.SALE_QTY         
              , D1.FREE_QTY         
              , D1.SALE_AMT         
              , D1.DC_AMT           
              , D1.GRD_AMT          
              , D1.NET_AMT          
              , D1.VAT_AMT          
              , D1.DC_QTY  
              , MAX(D1.STOR_CNT) OVER(PARTITION BY  D1.BRAND_CD, D1.ITEM_CD) AS STOR_CNT         
        FROM    STORE ST  
              , ITEM  IT  ,  ITEM_L_CLASS L , ITEM_M_CLASS M , ITEM_S_CLASS S, ITEM_D_CLASS D, BRAND BR, COMMON C1, COMMON C2  
              ,(            
                SELECT                                
                        SJ.BRAND_CD                             
                     ,  SJ.STOR_CD                              
                     ,  SJ.ITEM_CD                              
                     ,  SJ.SALE_DT                              
                     ,  SUM(SJ.SALE_QTY)             AS SALE_QTY
                     ,  SUM(SJ.FREE_QTY)             AS FREE_QTY
                     ,  SUM(SJ.SALE_AMT)             AS SALE_AMT
                     ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)  AS DC_AMT  
                     ,  SUM(SJ.GRD_AMT)              AS GRD_AMT 
                     ,  SUM(SJ.VAT_AMT)              AS VAT_AMT 
                     ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT) AS NET_AMT 
                     ,  SUM(SJ.DC_QTY)               AS DC_QTY
                     ,  COUNT(DISTINCT SJ.STOR_CD)   AS STOR_CNT
                FROM    SALE_JDM   SJ                           
                     ,  STORE    SS                           
                WHERE   1 = 1                 
                AND     SJ.BRAND_CD = SS.BRAND_CD               
                AND     SJ.STOR_CD  = SS.STOR_CD
                AND     (N_BRAND_CD IS NULL OR SJ.BRAND_CD   = N_BRAND_CD)
                AND     SJ.SALE_DT  BETWEEN P_START_DT||'01' AND P_END_DT||'31'
                AND     (N_STORE_CD IS NULL OR SS.STOR_CD   = N_STORE_CD)
                AND     SJ.GIFT_DIV = '0'
                GROUP  BY                                   
                        SJ.BRAND_CD                             
                     ,  SJ.STOR_CD                              
                     ,  SJ.ITEM_CD                              
                     ,  SJ.SALE_DT                              
                )   D1                                          
        WHERE   ST.COMP_CD  = P_COMP_CD    
        AND     (N_BRAND_CD IS NULL OR ST.BRAND_CD   = N_BRAND_CD)
        AND     ST.STOR_CD  = D1.STOR_CD    
        AND     D1.ITEM_CD  = IT.ITEM_CD
        AND (N_ITEM_L_CLASS  IS NULL OR IT.L_CLASS_CD = N_ITEM_L_CLASS )
        AND (N_ITEM_M_CLASS  IS NULL OR IT.M_CLASS_CD = N_ITEM_M_CLASS )
        AND (N_ITEM_S_CLASS  IS NULL OR IT.S_CLASS_CD = N_ITEM_S_CLASS )
        AND (N_ITEM_D_CLASS  IS NULL OR IT.D_CLASS_CD = N_ITEM_D_CLASS )
        AND     IT.L_CLASS_CD = L.L_CLASS_CD(+)
        AND     IT.M_CLASS_CD = M.M_CLASS_CD(+)
        AND     IT.S_CLASS_CD = S.S_CLASS_CD(+)
        AND     IT.D_CLASS_CD = D.D_CLASS_CD(+)
        AND     ST.BRAND_CD   = BR.BRAND_CD
        AND     C1.CODE_TP = '00565'
        AND     C1.CODE_CD = ST.STOR_TP
        AND     C2.CODE_TP = '00605'
        AND     C1.BRAND_CD = C2.BRAND_CD
        AND     C2.CODE_CD = ST.TEAM_CD
        ORDER  BY          
                D1.BRAND_CD
              , D1.ITEM_CD
    ;
    
END C_CUST_MENU_DAYLY_ANALYZE;

/
