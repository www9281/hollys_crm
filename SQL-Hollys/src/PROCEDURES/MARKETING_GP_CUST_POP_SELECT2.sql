--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_CUST_POP_SELECT2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_CUST_POP_SELECT2" (
-- ==========================================================================================
-- Author        :    권혁민
-- Create date    :    2017-10-31
-- Description    :    마켓팅 목록 내 고객 조회
-- Test            :    exec MARKETING_GP_CUST_POP_SELECT '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_CUST_GP_ID    IN   VARCHAR2,
        N_BRAND_CD      IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR 
) AS  
BEGIN   
        OPEN    O_CURSOR  FOR
        SELECT  B.BRAND_CD             AS BRAND_CD
              , (SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = B.BRAND_CD) AS BRAND_NM
              , DECRYPT(B.CUST_NM)    AS CUST_NM
              , B.CUST_ID             AS CUST_ID 
              , B.CUST_WEB_ID         AS CUST_WEB_ID
              , FN_GET_FORMAT_HP_NO(DECRYPT(B.MOBILE))     AS MOBILE 
              , DECRYPT(D.CARD_ID)    AS CARD_ID
              , B.BIRTH_DT AS BIRTH_DT
              , GET_COMMON_CODE_NM('00315', B.SEX_DIV, 'KOR') AS SEX_DIV
              , (SELECT LVL_NM FROM C_CUST_LVL WHERE LVL_CD = B.LVL_CD) AS CUST_LVL
              , B.LVL_CD AS LVL_CD
        FROM    MARKETING_GP_CUST A
        JOIN    C_CUST B
        ON      A.CUST_ID = B.CUST_ID
        LEFT OUTER JOIN C_CUST_LVL C
        ON      B.COMP_CD = C.COMP_CD 
        AND     B.LVL_CD = C.LVL_CD
        JOIN    C_CARD D
        ON      B.CUST_ID = D.CUST_ID
        WHERE   A.CUST_GP_ID = P_CUST_GP_ID
        AND     (TRIM(N_BRAND_CD) IS NULL OR B.BRAND_CD = N_BRAND_CD)
        ORDER BY 
                    B.CUST_NM ASC;
END MARKETING_GP_CUST_POP_SELECT2;

/
