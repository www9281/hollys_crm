--------------------------------------------------------
--  DDL for Procedure PROMOTION_CAN_STOR_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_CAN_STOR_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 적용매장 목록 조회
-- Test			:	exec PROMOTION_CAN_STOR_SELECT '002'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN   
        OPEN       O_CURSOR  FOR
        SELECT     A.PRMT_ID  AS PRMT_ID
                 , A.STOR_CD AS STOR_CD
                 , B.APP_DIV AS APP_DIV
                 , N.CODE_NM AS STOR_TP
                 , GET_STOR_NM(B.BRAND_CD, A.STOR_CD, 'KOR') AS STOR_NM
                 , DECODE(A.USE_YN, 'Y', 'Y', 'N')  AS USE_YN
                 , A.INST_USER AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
                 , A.UPD_USER AS UPD_USER 
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
        FROM       PROMOTION_CAN_STOR A
        JOIN       STORE B 
        ON         A.STOR_CD = B.STOR_CD
        LEFT OUTER JOIN COMMON N
        ON         B.STOR_TP = N.CODE_CD
        WHERE      A.PRMT_ID = P_PRMT_ID 
        AND        N.CODE_TP = '12040'   
        ORDER BY 
                   STOR_NM ASC;
END PROMOTION_CAN_STOR_SELECT;

/
