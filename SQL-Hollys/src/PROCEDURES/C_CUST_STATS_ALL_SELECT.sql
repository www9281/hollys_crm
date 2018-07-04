PROCEDURE        "C_CUST_STATS_ALL_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_MY_USER_ID   IN  VARCHAR2,
    P_INFO_DIV     IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_YYMM_DIV     IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    V_N_STOR_CD    VARCHAR2(10);
    V_START_DT     VARCHAR2(8);
    V_END_DT       VARCHAR2(8);
    
BEGIN
      V_START_DT := P_START_DT;
      V_END_DT   := P_END_DT;
      
      -- junwon testing 
      

      IF P_INFO_DIV <> '6' THEN 
        V_N_STOR_CD := NULL ;
      ELSE 
        V_N_STOR_CD := N_STOR_CD;
      END IF;
      
      -- ±â°£ ±¸ºÐ 
      IF N_YYMM_DIV = 'M'   THEN
      
          V_START_DT := SUBSTR(P_START_DT,0,6);
          V_END_DT   := SUBSTR(P_END_DT ,0,6);
        
      ELSIF N_YYMM_DIV = 'Q'   THEN
          IF     SUBSTR(P_START_DT, 5,8) IN('0100','0200','0300') THEN 
               V_START_DT := SUBSTR(P_START_DT, 0,4)||'-1';
               
               
          ELSIF  SUBSTR(P_START_DT, 5,8) IN('0400','0500','0600') THEN
               V_START_DT := SUBSTR(P_START_DT, 0,4)||'-2';
               
               
          ELSIF  SUBSTR(P_START_DT, 5,8) IN('0700','0800','0900') THEN
               V_START_DT := SUBSTR(P_START_DT, 0,4)||'-3';
               
               
          ELSIF  SUBSTR(P_START_DT, 5,8) IN('1000','1100','1200') THEN
               V_START_DT := SUBSTR(P_START_DT, 0,4)||'-4';
               
          END IF;
          
          IF     SUBSTR(P_END_DT, 5,8) IN('0199','0299','0399') THEN 
               
               V_END_DT   := SUBSTR(P_END_DT, 0,4)  ||'-1';
               
          ELSIF  SUBSTR(P_END_DT, 5,8) IN('0499','0599','0699') THEN
               
               V_END_DT   := SUBSTR(P_END_DT, 0,4)  ||'-2';
               
          ELSIF  SUBSTR(P_END_DT, 5,8) IN('0799','0899','0999') THEN
               
               V_END_DT   := SUBSTR(P_END_DT, 0,4)  ||'-3';
               
          ELSIF  SUBSTR(P_END_DT, 5,8) IN('1099','1199','1299') THEN
               
               V_END_DT   := SUBSTR(P_END_DT, 0,4)  ||'-4';
          END IF;
      
      ELSIF N_YYMM_DIV = 'Y'   THEN
        
          V_START_DT  := SUBSTR(P_START_DT, 0,4)||'00';
          V_END_DT    := SUBSTR(P_END_DT  , 0,4)||'00';
      END IF;
      

      OPEN O_CURSOR FOR
      SELECT * 
      FROM 
      (
          SELECT 
                  BRAND_CD
                 ,BRAND_NM
                 ,INFO_DIV2
                 ,CASE WHEN BRAND_NM IS  NULL AND INFO_DIV2 IS NULL AND SSS_DIV IS NULL THEN NULL
                  ELSE SSS_DIV
                  END AS SSS_DIV
                 ,STD_YYMM
                 ,STOR_CNT
                 ,MEMB_TOT       
                 ,MEM1           
                 ,MEM2           
                 ,MEM3           
                 ,MEM4           
                 ,MEM5           
                 ,MEM6           
                 ,TOT1           
                 ,TOT2           
                 ,TOT3           
                 ,TOT4           
                 ,TOT5           
                 ,TOT6           
                 ,AVG1           
                 ,AVG2           
                 ,AVG3           
                 ,AVG4           
                 ,AVG5           
                 ,AVG6           
                 ,TOT_CUST1      
                 ,TOT_CUST2                  
                 ,TOT_CUST3       
                 ,ACT1           
                 ,ACT2  
                 ,VISIT1
                 ,VISIT2
                 ,CUST_BILL1  --  Æò±Õ 
                 ,CUST_BILL2  --  ACT
                 ,CUST_BILL3  --  ºñÈ¸¿ø  
                 ,CUST_BILL4  --  Æò±Õ 
                 ,CUST_BILL5  --  ACT
                 ,CUST_BILL6  --  ºñÈ¸¿ø
                 ,AVG_CUST_BILL1
                 ,AVG_CUST_BILL2
                 ,AVG_CUST_BILL3 
                 ,AVG_CUST_BILL4
                 ,AVG_CUST_BILL5 
                 ,AVG_CUST_BILL6
                 ,TOT_AMT_1
                 ,TOT_AMT_2
                 ,TOT_AMT_3
          FROM 
          (
              SELECT               
                      BRAND_CD
                     ,BRAND_NM
                     ,INFO_DIV2
                     ,CASE 
                        WHEN  SSS_DIV = 'SSS'  THEN 'Y' 
                        WHEN  SSS_DIV = 'NOT'  THEN 'N'
                        ELSE NULL  
                      END AS SSS_DIV
                     --,DECODE( SSS_DIV , '' ,'ÇÕ°è', NVL(STD_YYMM,'¼Ò°è')) AS STD_YYMM
                     , STD_YYMM
                     ,SUM(STOR_CNT      ) AS STOR_CNT
                     ,SUM(MEMB_TOT      ) AS MEMB_TOT       
                     ,SUM(MEM1          ) AS MEM1           
                     ,SUM(MEM2          ) AS MEM2           
                     ,SUM(MEM3          ) AS MEM3           
                     ,SUM(MEM4          ) AS MEM4           
                     ,SUM(MEM5          ) AS MEM5           
                     ,SUM(MEM6          ) AS MEM6           
                     ,SUM(TOT1          ) AS TOT1           
                     ,SUM(TOT2          ) AS TOT2           
                     ,SUM(TOT3          ) AS TOT3           
                     ,SUM(TOT4          ) AS TOT4           
                     ,SUM(TOT5          ) AS TOT5           
                     ,SUM(TOT6          ) AS TOT6           
                     ,AVG(AVG1          ) AS AVG1           
                     ,AVG(AVG2          ) AS AVG2           
                     ,AVG(AVG3          ) AS AVG3           
                     ,AVG(AVG4          ) AS AVG4           
                     ,AVG(AVG5          ) AS AVG5           
                     ,AVG(AVG6          ) AS AVG6           
                     ,SUM(TOT_CUST1     ) AS TOT_CUST1      
                     ,SUM(TOT_CUST2     ) AS TOT_CUST2                  
                     ,SUM(TOT_CUST3     ) AS TOT_CUST3       
                     ,SUM(ACT1          )                                                                                             AS ACT1           
                     ,ROUND(SUM (TOT2) / NULLIF( SUM(MEM5 + MEM6),0), 2)                                                              AS ACT2  
                     ,ROUND(SUM (TOT5) / NULLIF( SUM(MEM5 + MEM6),0), 2)                                                              AS VISIT1
                     ,ROUND( (SUM(TOT2) / NULLIF(SUM(MEM5 + MEM6),0))  / NULLIF( (SUM(TOT5) / NULLIF( SUM( MEM5 + MEM6),0)),0), 2)    AS VISIT2
                     ,ROUND(SUM ( TOT_AMT_2  + TOT_AMT_3) / NULLIF(SUM(TOT2 + TOT3),0), 2)                                            AS CUST_BILL1  --  Æò±Õ 
                     ,ROUND(SUM ( TOT_AMT_2)              / NULLIF(SUM(TOT2       ),0), 2)                                            AS CUST_BILL2  --  ACT
                     ,ROUND(SUM ( TOT_AMT_3)              / NULLIF(SUM(TOT3       ),0), 2)                                            AS CUST_BILL3  --  ºñÈ¸¿ø  
                     ,ROUND(SUM ( TOT_AMT_2  + TOT_AMT_3) / NULLIF(SUM(TOT5 + TOT6),0), 2)                                            AS CUST_BILL4  --  Æò±Õ 
                     ,ROUND(SUM ( TOT_AMT_2)              / NULLIF(SUM(TOT5)       ,0), 2)                                            AS CUST_BILL5  --  ACT
                     ,ROUND(SUM ( TOT_AMT_3)              / NULLIF(SUM(TOT6)       ,0), 2)                                            AS CUST_BILL6  --  ºñÈ¸¿ø
                     ,ROUND(SUM ( MEMB_AVG_SALE_AMT  + PUBL_AVG_SALE_AMT)/ NULLIF(SUM(MEMB_AVG_CUST_CNT + PUBL_AVG_CUST_CNT),0), 2)   AS AVG_CUST_BILL1
                     ,ROUND(SUM ( MEMB_AVG_SALE_AMT)      / NULLIF(SUM(MEMB_AVG_CUST_CNT),0), 2)                                      AS AVG_CUST_BILL2
                     ,ROUND(SUM ( PUBL_AVG_SALE_AMT)      / NULLIF(SUM(PUBL_AVG_CUST_CNT),0), 2)                                      AS AVG_CUST_BILL3 
                     ,ROUND(SUM ( MEMB_AVG_SALE_AMT  + PUBL_AVG_SALE_AMT)/ NULLIF(SUM(AVG5 + AVG6),0), 2)                             AS AVG_CUST_BILL4
                     ,ROUND(SUM ( MEMB_AVG_SALE_AMT)      / NULLIF(SUM(AVG5),0), 2)                                                   AS AVG_CUST_BILL5 
                     ,ROUND(SUM ( PUBL_AVG_SALE_AMT)      / NULLIF(SUM(AVG6),0), 2)                                                   AS AVG_CUST_BILL6
                     ,SUM(TOT_AMT_1     )                                                                                             AS TOT_AMT_1
                     ,SUM(TOT_AMT_2     )                                                                                             AS TOT_AMT_2
                     ,SUM(TOT_AMT_3     )                                                                                             AS TOT_AMT_3
              FROM(              
                SELECT  
                        NVL((SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = A.BRAND_CD) ,'N/A') AS BRAND_NM
                     ,  A.BRAND_CD
                     ,   (CASE                          
                            WHEN INFO_DIV2 = '0' THEN NVL((SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = A.BRAND_CD) ,'N/A')                                                                          
                            WHEN INFO_DIV2 = '1' THEN NVL(GET_COMMON_CODE_NM('00565', A.STOR_TP,   'KOR') ,'N/A')                
                            WHEN INFO_DIV2 = '2' THEN NVL(GET_COMMON_CODE_NM('C9001', A.TRAD_AREA, 'KOR') ,'N/A')               
                            WHEN INFO_DIV2 = '3' THEN NVL(GET_COMMON_CODE_NM('00590', A.SIDO_CD,   'KOR') ,'N/A')              
                            WHEN INFO_DIV2 = '4' THEN NVL(GET_COMMON_CODE_NM('00605', (SELECT DISTINCT TEAM_CD FROM HQ_USER WHERE USER_ID = A.SC_CD),   'KOR') ,'N/A')         
                            WHEN INFO_DIV2 = '5' THEN NVL(GET_COMMON_CODE_NM('C9002', A.STOR_TG,   'KOR') ,'N/A')      
                            WHEN INFO_DIV2 = '6' THEN S.STOR_NM                                                     
                            ELSE                     'N/A'
                         END )                                     AS INFO_DIV2
                     , SSS_DIV                                     AS SSS_DIV
                     , CASE
                          WHEN   N_YYMM_DIV = 'Y' THEN SUBSTR(STD_YYMM,0,4)
                          WHEN   N_YYMM_DIV = 'M' THEN SUBSTR(STD_YYMM,0,4)||'-'||SUBSTR(STD_YYMM,5,6)
                          ELSE   STD_YYMM 
                       END                                         AS STD_YYMM
                     , ( STOR_CNT                               )  AS STOR_CNT
                     , ( MEMB_TOT                               )  AS MEMB_TOT  
                     , ( MEMB_NEW_AAPP+MEMB_NEW_UAPP            )  AS MEM1 -- È¸¿ø ¼ö
                     , ( MEMB_NEW_AAPP                          )  AS MEM2
                     , ( MEMB_NEW_UAPP                          )  AS MEM3
                     , ( MEMB_SALE_AAPP+MEMB_SALE_UAPP          )  AS MEM4
                     , ( MEMB_SALE_AAPP                         )  AS MEM5
                     , ( MEMB_SALE_UAPP                         )  AS MEM6
                     , ( MEMB_TOT_CUST_CNT+PUBL_TOT_CUST_CNT    )  AS TOT1 -- ÃÑ°´¼ö ¹× Á¶¼ö 
                     , ( MEMB_TOT_CUST_CNT                      )  AS TOT2
                     , ( PUBL_TOT_CUST_CNT                      )  AS TOT3
                     , ( MEMB_TOT_BILL_CNT+PUBL_TOT_BILL_CNT    )  AS TOT4
                     , ( MEMB_TOT_BILL_CNT                      )  AS TOT5
                     , ( PUBL_TOT_BILL_CNT                      )  AS TOT6
                     , ( MEMB_AVG_CUST_CNT+PUBL_AVG_CUST_CNT    )  AS AVG1 --  ¸ÅÀå´ç ÀÏ Æò±Õ °´¼ö ¹× Á¶¼ö
                     , ( MEMB_AVG_CUST_CNT                      )  AS AVG2
                     , ( PUBL_AVG_CUST_CNT                      )  AS AVG3
                     , ( MEMB_AVG_BILL_CNT+PUBL_AVG_BILL_CNT    )  AS AVG4
                     , ( MEMB_AVG_BILL_CNT                      )  AS AVG5
                     , ( PUBL_AVG_BILL_CNT                      )  AS AVG6 
                     , ( MEMB_TOT_CUST_CNT+PUBL_TOT_CUST_CNT    )  AS TOT_CUST1  -- ÃÑ°´¼ö ºÐ¼®
                     , ( PUBL_TOT_CUST_CNT                      )  AS TOT_CUST2                 
                     , ( MEMB_TOT_CUST_CNT                      )  AS TOT_CUST3                
                     , ( MEMB_SALE_AAPP+MEMB_SALE_UAPP          )  AS ACT1  -- Actvie È¸¿ø ÃÑ °´¼ö°Ç¼ö ºÐ¼®
                     , ( MEMB_TOT_SALE_AMT  + PUBL_TOT_SALE_AMT )  AS TOT_AMT_1 
                     , ( MEMB_TOT_SALE_AMT                      )  AS TOT_AMT_2
                     , ( PUBL_TOT_SALE_AMT                      )  AS TOT_AMT_3  
                     , MEMB_AVG_SALE_AMT                           AS MEMB_AVG_SALE_AMT  
                     , MEMB_AVG_CUST_CNT                           AS MEMB_AVG_CUST_CNT
                     , PUBL_AVG_SALE_AMT                           AS PUBL_AVG_SALE_AMT 
                     , PUBL_AVG_CUST_CNT                           AS PUBL_AVG_CUST_CNT
                FROM  STAT_MEMBER_TOT A , STORE S                                                                          
                WHERE  A.COMP_CD  =  P_COMP_CD
                AND    A.STOR_CD  = S.STOR_CD(+)
                AND   INFO_DIV1   = N_YYMM_DIV
                AND   INFO_DIV2   = P_INFO_DIV
                AND   STD_YYMM BETWEEN  V_START_DT AND V_END_DT
                AND   (N_BRAND_CD    IS NULL OR A.BRAND_CD = N_BRAND_CD  )  
                AND   (V_N_STOR_CD   IS NULL OR A.STOR_CD  = V_N_STOR_CD )
                AND   SSS_DIV <> 'TOT'
             )
             --GROUP BY    ROLLUP(BRAND_NM,BRAND_CD, INFO_DIV2, SSS_DIV, STD_YYMM)
             GROUP BY  BRAND_NM,BRAND_CD, INFO_DIV2, SSS_DIV, STD_YYMM
             ORDER BY  BRAND_CD , INFO_DIV2 , SSS_DIV DESC,STD_YYMM   
         )
     )
     WHERE (SSS_DIV IS NOT NULL OR BRAND_NM IS  NULL)
     
     ; 
 
  
END C_CUST_STATS_ALL_SELECT;