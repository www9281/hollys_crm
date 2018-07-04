--------------------------------------------------------
--  DDL for Procedure STORE_POINT_USE_PNC_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_POINT_USE_PNC_SELECT" (
-- ==========================================================================================
-- Author        :    임지훈
-- Create date    :    2018-03-30
-- Description    :    PNC 기준 포인트 사용내역 조회
-- Test            :    exec STORE_POINT_USE_PNC_SELECT 
-- ==========================================================================================      
-- P는 필수 : 필수값이 와야된다.
-- N은 선택 : 필수가 아닌 선택적 값이 와도됨.

        P_START_DT    IN   VARCHAR2,    
        P_END_DT      IN   VARCHAR2,
        P_CARD_ID     IN   VARCHAR2,    -- 카드아이디
        N_STOR_CD     IN   VARCHAR2,    -- 매장코드
        O_CURSOR      OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN O_CURSOR  FOR
        
        SELECT  DECRYPT(CARD_ID) CARD_ID 
             ,  USE_DT  
             ,  STOR_CD 
             ,  (SELECT STOR_NM FROM STORE WHERE STOR_CD = PNC.STOR_CD) AS STOR_NM 
             ,  REMARKS
--                   (CASE SAV_USE_FG WHEN '1' THEN '크라운적립' 
--                                    WHEN '2' THEN '크라운사용' 
--                                    WHEN '3' THEN '포인트적립' 
--                                    WHEN '4' THEN '포인트사용' 
--                                    ELSE '이상' END) AS SAV_USE_FG,,
             ,  SAV_PT  
             ,  USE_PT  
             ,  LOS_PT  
             ,  POS_NO  
             ,  BILL_NO
        FROM    C_CARD_SAV_HIS_PNC PNC
        WHERE   COMP_CD  = '016'
        AND     BRAND_CD = '100'
        AND     USE_DT >= P_START_DT
        AND     USE_DT <= P_END_DT
        AND     (N_STOR_CD IS NULL OR STOR_CD = N_STOR_CD)
        AND     (P_CARD_ID IS NULL OR CARD_ID = ENCRYPT(TRIM(P_CARD_ID)))
        ;
       
END STORE_POINT_USE_PNC_SELECT;

/
