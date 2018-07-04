--------------------------------------------------------
--  DDL for Procedure PROMOTION_ACT_COUPON_PAGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_ACT_COUPON_PAGE" (
    N_START_DT  IN  VARCHAR2,
    N_END_DT    IN  VARCHAR2,
    N_STOR_CD   IN  VARCHAR2,
    N_PRMT_TYPE IN  VARCHAR2,
    N_PRMT_ID   IN  VARCHAR2,         
    P_ROWS      IN  VARCHAR2,
    P_PAGE      IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) IS 
    
    v_total_rows NUMBER;
    
BEGIN  

    -- ==========================================================================================
    -- Author        :    박동수
    -- Create date    :    2018-02-21
    -- Description    :    프로모션 쿠폰별 할인액  조회
    -- ==========================================================================================
    
    SELECT 
    COUNT(*) INTO v_total_rows  
    FROM  SALE_DC D, PROMOTION_COUPON C,  PROMOTION_COUPON_PUBLISH U , PROMOTION P
    WHERE  1 = 1
    AND    D.STOR_CD      = C.STOR_CD
    AND    D.POS_NO       = C.POS_NO 
    AND    D.BILL_NO      = C.BILL_NO
    AND    D.ORG_AUTH_NO  = C.COUPON_CD
    AND    D.DC_DIV       = P.PRMT_ID
    AND    C.COUPON_STATE = 'P0301'
    AND    D.COMP_CD      = '016'
    AND    D.BRAND_CD     = '100'
    AND    U.PUBLISH_ID   = C.PUBLISH_ID 
    AND    U.PRMT_ID      = P.PRMT_ID 
    AND    P.PRMT_TYPE NOT IN ('C6015', 'C6018')
    AND    (N_START_DT IS NULL OR D.SALE_DT >= REPLACE(N_START_DT, '-', ''))
    AND    (N_END_DT   IS NULL OR D.SALE_DT <= REPLACE(N_END_DT  , '-', ''))
    AND    (N_STOR_CD  IS NULL OR D.STOR_CD = N_STOR_CD)
    AND    (N_PRMT_ID  IS NULL OR P.PRMT_ID = N_PRMT_ID)
    ;
    
    dbms_output.put_line('v_total_rows========' || v_total_rows );
    dbms_output.put_line('P_ROWS========' || P_ROWS );
    dbms_output.put_line('P_PAGE========' || P_PAGE );
    
    
    OPEN   O_CURSOR   FOR
    SELECT 
           RNUM AS NO
         , FLOOR((ROWNUM - 1)/ TO_NUMBER(P_ROWS) +1)       AS PAGE
         , FLOOR((v_total_rows - 1)/ TO_NUMBER(P_ROWS) +1) AS PAGECNT
         , v_total_rows                                    AS TOTAL   
         , STOR_CD
         , STOR_NM
         , GET_COMMON_CODE_NM('00565', STOR_TP)          AS STOR_TP
         , (SELECT H.USER_NM FROM HQ_USER H WHERE  H.USER_ID = ZZ.SV_USER_ID  ) AS STOR_SC
         , GET_COMMON_CODE_NM('00605', TEAM_CD)          AS TEAM_NM
         , DECRYPT(CARD_ID)                              AS CARD_ID
         , DECRYPT(CUST_NM)                              AS CUST_NM
         , TO_CHAR(ZZ.INST_DT, 'YYYY-MM-DD HH24:MI:SS')  AS INST_DT
         , PUBLISH_ID
         , PRMT_NM                                       AS COUPON_NM
         , COUPON_CD
         , ZZ.ITEM_CD
         , ITEM_NM
         , SALE_QTY
         , ZZ.SALE_PRC
         , SALE_AMT
         , DC_AMT
         , TOTAL_DC_AMT
         , GRD_AMT
         , DC_AMT_H
    FROM 
    ( 
        SELECT 
               ROWNUM AS RNUM
             , STOR_CD
             , STOR_NM
             , STOR_TP
             , SV_USER_ID
             , TEAM_CD
             , CUST_NM
             , ITEM_NM
             , CARD_ID
             , CUST_ID
             , INST_DT
             , PUBLISH_ID
             , PRMT_NM
             , COUPON_CD
             , ITEM_CD
             , SALE_QTY
             , SALE_PRC
             , SALE_AMT
             , DC_AMT
             , TOTAL_DC_AMT
             , GRD_AMT
             , DC_AMT_H
        FROM 
        (
           SELECT 
                   D.STOR_CD
                 , ST.STOR_NM
                 , ST.STOR_TP
                 , ST.SV_USER_ID
                 , ST.TEAM_CD
                 , CU.CUST_NM
                 , IT.ITEM_NM
                 , D.CARD_ID
                 , D.CUST_ID
                 , D.INST_DT
                 , C.PUBLISH_ID
                 , P.PRMT_NM
                 , D.ORG_AUTH_NO AS COUPON_CD
                 , D.ITEM_CD
                 , D.SALE_QTY
                 , D.SALE_PRC
                 , D.SALE_AMT
                 , D.DC_AMT
                 ,CASE WHEN D.DC_RATE > 0 THEN D.DC_AMT
                       ELSE D.ENR_AMT
                  END AS TOTAL_DC_AMT
                 , D.GRD_AMT
                 , D.DC_AMT_H
            FROM  SALE_DC D, PROMOTION_COUPON C,  PROMOTION_COUPON_PUBLISH U , PROMOTION P  , STORE ST, ITEM IT, C_CUST CU 
            WHERE  1 = 1
            AND    D.STOR_CD      = C.STOR_CD
            AND    D.POS_NO       = C.POS_NO 
            AND    D.BILL_NO      = C.BILL_NO
            AND    D.ORG_AUTH_NO  = C.COUPON_CD
            AND    D.DC_DIV       = P.PRMT_ID
            AND    C.COUPON_STATE = 'P0301'
            AND    D.COMP_CD      = P.COMP_CD
            AND    D.COMP_CD      = '016'
            AND    D.BRAND_CD     = '100'
            AND    U.PUBLISH_ID   = C.PUBLISH_ID 
            AND    U.PRMT_ID      = P.PRMT_ID 
            AND    P.PRMT_TYPE NOT IN ('C6015', 'C6018')
            AND    (N_START_DT IS NULL OR D.SALE_DT >= REPLACE(N_START_DT, '-', ''))
            AND    (N_END_DT   IS NULL OR D.SALE_DT <= REPLACE(N_END_DT  , '-', ''))
            AND    (N_STOR_CD  IS NULL OR D.STOR_CD = N_STOR_CD)
            AND    (N_PRMT_ID  IS NULL OR P.PRMT_ID = N_PRMT_ID)
            AND    D.STOR_CD = ST.STOR_CD(+)
            AND    D.ITEM_CD = IT.ITEM_CD(+)
            AND    D.CUST_ID = CU.CUST_ID(+)
            ORDER  BY ST.STOR_TP, ST.SV_USER_ID, D.STOR_CD ,D.CUST_ID,  D.INST_DT, C.COUPON_CD
         ) Z
         WHERE ROWNUM <= v_total_rows - ( TO_NUMBER(P_ROWS) * (TO_NUMBER(P_PAGE) - 1))
     )ZZ 
     WHERE RNUM >= v_total_rows - (TO_NUMBER(P_ROWS) * TO_NUMBER(P_PAGE)) + 1
     ORDER BY RNUM DESC
    ;
    
  /*  
     FOR REC2 in O_CURSOR
   LOOP
       dbms_output.put_line('COUPON_CD========' || REC2.COUPON_CD );
   END LOOP;
    */
   
EXCEPTION
   
    WHEN OTHERS THEN
   
        dbms_output.put_line(SQLERRM) ;
       
END PROMOTION_ACT_COUPON_PAGE;

/
