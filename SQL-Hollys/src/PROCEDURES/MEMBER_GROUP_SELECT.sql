--------------------------------------------------------
--  DDL for Procedure MEMBER_GROUP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MEMBER_GROUP_SELECT" (
    N_BRAND_CD    IN VARCHAR2,
    N_CUST_ID     IN VARCHAR2,
    N_STOR_CD     IN VARCHAR2,
    N_START_DT    IN VARCHAR2,
    N_END_DT      IN VARCHAR2,
    N_GROUP_NM    IN VARCHAR2,
    P_MY_USER_ID  IN VARCHAR2,
    O_CURSOR   OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-05
    -- Description   :   마켓팅 목록 조회
    -- ==========================================================================================
            
    OPEN O_CURSOR FOR
    SELECT
      COMP_CD
      ,BRAND_CD
      ,CUST_GP_ID
      ,CUST_GP_NM
      ,(SELECT COUNT(*) FROM MARKETING_GP_CUST WHERE CUST_GP_ID = A.CUST_GP_ID) AS CUST_CNT
      ,SMS_SEND_YN
      ,USE_YN
      ,NOTES
      ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = A.INST_USER) AS INST_USER
      ,TO_CHAR(INST_DT, 'YYYYMMDD') AS INST_DT
    FROM MARKETING_GP A
    WHERE (N_CUST_ID IS NULL OR EXISTS (SELECT 1 FROM MARKETING_GP_CUST B
                                        WHERE A.CUST_GP_ID = B.CUST_GP_ID
                                          AND B.CUST_ID = N_CUST_ID))
      AND (N_STOR_CD IS NULL OR EXISTS (SELECT 1 FROM MARKETING_GP_CUST B, C_CUST C
                                        WHERE A.CUST_GP_ID = B.CUST_GP_ID
                                          AND B.CUST_ID = C.CUST_ID
                                          AND C.STOR_CD = N_STOR_CD))
      AND (N_START_DT IS NULL OR TO_CHAR(A.INST_DT, 'YYYYMMDD') >= REPLACE(N_START_DT, '-', ''))
      AND (N_END_DT IS NULL OR TO_CHAR(A.INST_DT, 'YYYYMMDD') <= REPLACE(N_END_DT, '-', ''))
      AND (N_GROUP_NM IS NOT NULL OR A.CUST_GP_NM LIKE '%' || N_GROUP_NM || '%')
      AND (A.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
          AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = A.BRAND_CD AND USE_YN = 'Y')))
    ;
      
END MEMBER_GROUP_SELECT;

/
