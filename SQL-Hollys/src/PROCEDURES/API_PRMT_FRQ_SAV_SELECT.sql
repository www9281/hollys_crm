--------------------------------------------------------
--  DDL for Procedure API_PRMT_FRQ_SAV_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_PRMT_FRQ_SAV_SELECT" (
      P_CUST_ID       IN  VARCHAR2,
      P_PRMT_ID       IN  VARCHAR2,
      O_RTN_CD        OUT VARCHAR2,
      O_REQ_QTY       OUT VARCHAR2,  
      O_NOR_QTY       OUT VARCHAR2,
      O_REQ_STANDARD  OUT VARCHAR2,  
      O_NOR_STANDARD  OUT VARCHAR2
) AS 
      v_result_cd VARCHAR2(7) := '1'; --성공
      L_COUNT NUMBER;
BEGIN 
      -- ==========================================================================================
      -- Author        :   권혁민
      -- Create date   :   2017-12-18
      -- API REQUEST   :   HLS_CRM_IF_0022
      -- Description   :   회원 프리퀀시 적립 정보		
      -- ==========================================================================================
        
        -- 기준 잔수 조회
        SELECT  C.CONDITION_QTY_REQ,
                C.CONDITION_QTY_NOR
        INTO    O_REQ_STANDARD
               ,O_NOR_STANDARD    
        FROM    PROMOTION_FREQUENCY A
        JOIN    PROMOTION_TARGET_MN B
        ON      A.PRMT_ID   = B.PRMT_ID
        AND     A.ITEM_DIV  = B.ITEM_DIV
        AND     A.ITEM_CD   = B.ITEM_CD
        JOIN    PROMOTION C
        ON      A.PRMT_ID = C.PRMT_ID 
        WHERE   A.CUST_ID = P_CUST_ID
        AND     A.PUBLISH_YN = 'N'
        AND     A.PRMT_ID = P_PRMT_ID
        AND     C.PRMT_TYPE = 'C6017'
        AND     ROWNUM = 1;
        
        O_REQ_QTY := 0;
        O_NOR_QTY := 0;
        
        -- 잔여 잔수 조회
        SELECT  COUNT(*)
                INTO L_COUNT
        FROM    PROMOTION_FREQUENCY A
        JOIN    PROMOTION_TARGET_MN B
        ON      A.PRMT_ID   = B.PRMT_ID 
        AND     A.ITEM_DIV  = B.ITEM_DIV 
        AND     A.ITEM_CD   = B.ITEM_CD
        JOIN    PROMOTION C
        ON      A.PRMT_ID = C.PRMT_ID 
        WHERE   A.CUST_ID = P_CUST_ID
        AND     A.PUBLISH_YN = 'N'
        AND     A.PRMT_ID = P_PRMT_ID
        AND     C.PRMT_TYPE = 'C6017';
                
        IF      L_COUNT > 0 THEN
        
                SELECT  SUM(
                          CASE  WHEN A.ITEM_DIV = 'C6401' AND A.FRQ_DIV = '101' THEN A.QTY
                                WHEN A.ITEM_DIV = 'C6401' AND A.FRQ_DIV != '101' THEN -A.QTY
                                ELSE 0
                          END
                        ) AS REQ_QTY,
                        SUM(
                          CASE  WHEN A.ITEM_DIV = 'C6402' AND A.FRQ_DIV = '101' THEN A.QTY
                                WHEN A.ITEM_DIV = 'C6402' AND A.FRQ_DIV != '101' THEN -A.QTY
                                ELSE 0
                          END
                        ) AS NOR_QTY
                INTO    O_REQ_QTY,
                        O_NOR_QTY
                FROM    PROMOTION_FREQUENCY A
                JOIN    PROMOTION_TARGET_MN B
                ON      A.PRMT_ID   = B.PRMT_ID
                AND     A.ITEM_DIV  = B.ITEM_DIV
                AND     A.ITEM_CD   = B.ITEM_CD
                JOIN    PROMOTION C
                ON      A.PRMT_ID = C.PRMT_ID 
                WHERE   A.CUST_ID = P_CUST_ID
                AND     A.PUBLISH_YN = 'N'
                AND     A.PRMT_ID = P_PRMT_ID
                AND     C.PRMT_TYPE = 'C6017';
                
        END     IF;
         
        O_RTN_CD := v_result_cd;
      
EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2';
        dbms_output.put_line(SQLERRM);
END API_PRMT_FRQ_SAV_SELECT;

/
