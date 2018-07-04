--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_GRADE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_GRADE_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_INFO_DIV     IN  VARCHAR2,
    P_MY_USER_ID   IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_CUST_LVL     IN  VARCHAR2,
    N_CUST_AGE     IN  VARCHAR2,
    N_YYMM_DIV     IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS

    V_N_CUST_AGE VARCHAR2(10);
    V_N_STOR_CD  VARCHAR2(10);
    
    V_START_DT   VARCHAR2(8);
    V_END_DT     VARCHAR2(8);
BEGIN


    V_START_DT := SUBSTR(P_START_DT,0,6);
    V_END_DT   := SUBSTR(P_END_DT ,0,6);    

    IF N_YYMM_DIV = 'Q' THEN 
        IF    INSTR(P_END_DT,'0199') > 0  THEN
            V_END_DT := SUBSTR(P_END_DT,0,4)||'03' ;
        ELSIF INSTR(P_END_DT,'0499') > 0  THEN 
            V_END_DT := SUBSTR(P_END_DT,0,4)||'06' ;
        ELSIF INSTR(P_END_DT,'0799') > 0  THEN
            V_END_DT := SUBSTR(P_END_DT,0,4)||'07' ;
        ELSIF INSTR(P_END_DT,'1099') > 0  THEN
            V_END_DT := SUBSTR(P_END_DT,0,4)||'12' ;
        END IF;
    ELSE
        V_START_DT := SUBSTR(P_START_DT,0,6);
        V_END_DT   := SUBSTR(P_END_DT ,0,6);
    END IF;
    

    IF P_INFO_DIV <> '0' THEN 
        V_N_CUST_AGE :=  NULL ;
    ELSE 
        V_N_CUST_AGE := N_CUST_AGE ;
    END IF;
    
    
    IF P_INFO_DIV <> '6' THEN 
        V_N_STOR_CD :=  NULL ;
    ELSE 
        V_N_STOR_CD := N_STOR_CD ;
    END IF;
   
    OPEN O_CURSOR FOR
    
      SELECT
              BRAND_NM
           ,  BRAND_CD
           ,  INFO_DIV
           ,  LVL_CD
           ,  STD_YYMM
           ,  MEMB_TOT             
           ,  MEMB_NEW             
           ,  MEMB_SALE            
           ,  MEMB_SALE_RATE       
           ,  MEMB_SALE_ADD        
           ,  MEMB_SALE_ADD_PER    
           ,  TOT_SALE_AMT_MEMB_PER
           ,  DRK_SALE_AMT_MEMB_PER
           ,  TOT_SALE_QTY_MEMB    
           ,  AGV_SALE_QTY_MEMB    
           ,  TOT_SALE_AMT_MEMB    
           ,  AGV_SALE_AMT_MEMB    
      FROM
      (
            SELECT 
                   BRAND_NM
                 , BRAND_CD
                 , INFO_DIV
                 , LVL_CD
                 , DECODE( INFO_DIV , '' ,'합계', NVL(STD_YYMM,'소계')) AS STD_YYMM
                 , SUM(MEMB_TOT             )     AS MEMB_TOT             
                 , SUM(MEMB_NEW             )     AS MEMB_NEW             
                 , SUM(MEMB_SALE            )     AS MEMB_SALE            
                 , ROUND(  SUM(MEMB_SALE)         / NULLIF( SUM(MEMB_TOT) * 100,0), 2)   AS MEMB_SALE_RATE       
                 , SUM(MEMB_SALE_ADD        )     AS MEMB_SALE_ADD
                 , ROUND(  SUM( MEMB_SALE_ADD)    / NULLIF( SUM(MEMB_SALE)    ,0) , 2)   AS MEMB_SALE_ADD_PER    
                 , ROUND(  SUM(TOT_SALE_AMT_MEMB) / NULLIF( SUM(MEMB_SALE_ADD),0) , 2)   AS TOT_SALE_AMT_MEMB_PER  
                 , ROUND(  SUM(DRK_SALE_AMT_MEMB) / NULLIF( SUM(MEMB_SALE_ADD),0) , 2)   AS DRK_SALE_AMT_MEMB_PER
                 , SUM(TOT_SALE_QTY_MEMB    )     AS TOT_SALE_QTY_MEMB    
                 , SUM(AGV_SALE_QTY_MEMB    )     AS AGV_SALE_QTY_MEMB    
                 , SUM(TOT_SALE_AMT_MEMB    )     AS TOT_SALE_AMT_MEMB    
                 , SUM(AGV_SALE_AMT_MEMB    )     AS AGV_SALE_AMT_MEMB    
            FROM
            (
                  SELECT
                           NVL((SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = A.BRAND_CD) ,'N/A') AS BRAND_NM
                       ,   A.BRAND_CD
                       ,   (CASE                          
                              WHEN INFO_DIV = '0' THEN NVL(GET_COMMON_CODE_NM('01760', A.AGE_RANGE, 'KOR') ,'N/A')
                              WHEN INFO_DIV = '1' THEN NVL(GET_COMMON_CODE_NM('00565', A.STOR_TP,   'KOR') ,'N/A')                
                              WHEN INFO_DIV = '2' THEN NVL(GET_COMMON_CODE_NM('C9001', A.TRAD_AREA, 'KOR') ,'N/A')               
                              WHEN INFO_DIV = '3' THEN NVL(GET_COMMON_CODE_NM('00590', A.SIDO_CD,   'KOR') ,'N/A')              
                              WHEN INFO_DIV = '4' THEN NVL(GET_COMMON_CODE_NM('00605', (SELECT DISTINCT TEAM_CD FROM HQ_USER WHERE USER_ID = A.SC_CD),   'KOR')    ,'N/A')         
                              WHEN INFO_DIV = '5' THEN NVL(GET_COMMON_CODE_NM('C9002', A.STOR_TG,   'KOR') ,'N/A')      
                              WHEN INFO_DIV = '6' THEN NVL((SELECT  STOR_NM FROM STORE X WHERE X.USE_YN = 'Y' AND X.COMP_CD = '016' AND X.STOR_CD = A.STOR_CD  )   ,'N/A')                                                     
                              ELSE                     'N/A'
                           END )                                                           AS INFO_DIV
                       ,   NVL((SELECT MAX(LVL_NM) FROM C_CUST_LVL WHERE USE_YN = 'Y' AND LVL_CD = A.LVL_CD AND COMP_CD = A.COMP_CD ) ,'N/A') AS  LVL_CD
                       , CASE
                            WHEN   N_YYMM_DIV = 'M' THEN SUBSTR(STD_YYMM,0,4)||'-'||SUBSTR(STD_YYMM,5,6)
                            WHEN   N_YYMM_DIV = 'Y' THEN SUBSTR(STD_YYMM,0,4)
                            WHEN   N_YYMM_DIV = 'Q' AND SUBSTR(STD_YYMM,5,6) IN('01','02','03') THEN  SUBSTR(STD_YYMM,0,4)||'-1'  
                            WHEN   N_YYMM_DIV = 'Q' AND SUBSTR(STD_YYMM,5,6) IN('04','05','06') THEN  SUBSTR(STD_YYMM,0,4)||'-2'
                            WHEN   N_YYMM_DIV = 'Q' AND SUBSTR(STD_YYMM,5,6) IN('07','08','09') THEN  SUBSTR(STD_YYMM,0,4)||'-3'
                            WHEN   N_YYMM_DIV = 'Q' AND SUBSTR(STD_YYMM,5,6) IN('10','11','12') THEN  SUBSTR(STD_YYMM,0,4)||'-4'
                            ELSE   STD_YYMM 
                         END                                                                AS  STD_YYMM
                       ,  MEMB_TOT               
                       ,  MEMB_NEW               
                       ,  MEMB_SALE
                       ,  MEMB_SALE_ADD
                       ,  TOT_SALE_AMT_MEMB
                       ,  DRK_SALE_AMT_MEMB
                       ,  TOT_SALE_QTY_MEMB
                       ,  AGV_SALE_QTY_MEMB
                       ,  AGV_SALE_AMT_MEMB                                       
                  FROM    STAT_AGE_MEMBER A                                                                           
                  WHERE   A.COMP_CD    =  P_COMP_CD
                  AND     A.INFO_DIV   =  P_INFO_DIV
                  AND     STD_YYMM BETWEEN  V_START_DT  AND  V_END_DT
                  AND     (N_BRAND_CD    IS NULL OR A.BRAND_CD  = N_BRAND_CD   )  
                  AND     (V_N_STOR_CD   IS NULL OR A.STOR_CD   = V_N_STOR_CD  )
                  AND     (N_CUST_LVL    IS NULL OR A.LVL_CD    = N_CUST_LVL   )
                  AND     (V_N_CUST_AGE  IS NULL OR A.AGE_RANGE = V_N_CUST_AGE )
             )            GROUP BY       ROLLUP ( BRAND_NM, BRAND_CD, LVL_CD, INFO_DIV, STD_YYMM)
             ORDER BY     BRAND_CD, LVL_CD, CASE WHEN INFO_DIV LIKE '%미만' THEN -1 ELSE 0 END , INFO_DIV , STD_YYMM 
        )
        WHERE (BRAND_NM IS  NULL OR INFO_DIV IS NOT NULL)
        ;
END C_CUST_STATS_GRADE_SELECT;

/
