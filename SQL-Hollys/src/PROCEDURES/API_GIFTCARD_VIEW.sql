--------------------------------------------------------
--  DDL for Procedure API_GIFTCARD_VIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_GIFTCARD_VIEW" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	모바일전자상품권 목록조회
-- Test			:	exec API_GIFTCARD_VIEW '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_CUST_ID       IN   VARCHAR2,
        P_GIFTCARD_ID   IN   VARCHAR2,
        P_PIN_NO        IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR 
        SELECT     DECRYPT(A.CARD_ID) AS GIFTCARD_ID
                   ,A.PIN_NO
                   ,A.CUST_ID
                   ,A.CARD_IMG_NM AS CARD_IMG_NM
                   ,TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
                   ,TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
                   ,DECODE(A.USE_YN, 'Y', 'Y', 'N') AS USE_YN
        FROM       C_CARD A
        WHERE      A.CUST_ID = P_CUST_ID
        AND        A.REP_CARD_YN = 'N'
        AND        A.COMP_CD = P_COMP_CD  
        AND        A.CARD_ID = ENCRYPT(P_GIFTCARD_ID)
        AND        A.PIN_NO = P_PIN_NO;
        /*SELECT
                DECRYPT(HIS.GIFTCARD_ID) AS GIFTCARD_ID
               ,HIS.PIN_NO
               ,(
                    CASE WHEN (
                                SELECT CARD_ID
                                FROM   C_CARD
                                WHERE  CUST_ID = P_CUST_ID
                                AND    USE_YN = 'Y'
                                AND    REP_CARD_YN = 'Y'
                               ) IS NOT NULL THEN (
                                                    SELECT DECRYPT(CARD_ID)
                                                    FROM   C_CARD
                                                    WHERE  CUST_ID = P_CUST_ID
                                                    AND    USE_YN = 'Y'
                                                    AND    REP_CARD_YN = 'Y'
                                              )
                         ELSE ''
                    END
                ) AS CARD_ID
               ,HIS.CUST_ID
               ,(
                    CASE WHEN HIS.CUST_NM IS NOT NULL THEN DECRYPT(HIS.CUST_NM)
                         ELSE ''
                    END
               ) AS CUST_NM
               ,HIS.BUY_DT
               ,HIS.AMOUNT
               ,HIS.USE_PT
               ,(
                    CASE WHEN HIS.RECEPTION_MOBILE IS NOT NULL THEN DECRYPT(HIS.RECEPTION_MOBILE)
                         ELSE ''
                    END-- DECRYPT 확인
               ) AS RECEPTION_MOBILE
               ,HIS.CANCEL_DT AS CANCEL_DT
               ,DECODE(CARD.USE_YN, 'Y', 'Y', 'N') AS CARD_STAT
               ,HIS.SEND_DT
               ,HIS.SEND_MSG
               ,HIS.SEND_IMG
               ,HIS.SEND_COUNT
               ,(CASE WHEN HIS.IS_RECHARGE = '0' THEN '신규'
                      WHEN HIS.IS_RECHARGE = '1' THEN '재충전'
                      ELSE ''
                 END
               ) AS IS_RECHARGE
               ,TO_CHAR(CARD.INST_DT,'YYYY-MM-DD') AS INST_DT
               
               DECRYPT(A.CARD_ID) AS GIFTCARD_ID
               ,A.PIN_NO
               ,A.CUST_ID
               ,A.CARD_IMG_NM AS CARD_IMG_NM
               ,TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
               ,TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
               ,DECODE(A.USE_YN, 'Y', 'Y', 'N') AS USE_YN
        FROM C_CARD CARD
            ,(SELECT A.* FROM (SELECT * FROM GIFTCARD_HIS WHERE GIFTCARD_ID = ENCRYPT(P_GIFTCARD_ID) AND PIN_NO = P_PIN_NO ORDER BY INST_DT DESC)A WHERE ROWNUM = 1) HIS
        WHERE CARD.CARD_ID = ENCRYPT(P_GIFTCARD_ID)
        AND   CARD.PIN_NO = P_PIN_NO
        AND   CARD.REP_CARD_YN = 'N'
        AND   CARD.COMP_CD = P_COMP_CD
        AND   CARD.BRAND_CD = P_BRAND_CD
        AND   CARD.CUST_ID = P_CUST_ID;
        dbms_output.put_line(SQLERRM);*/
        
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
END API_GIFTCARD_VIEW;

/
