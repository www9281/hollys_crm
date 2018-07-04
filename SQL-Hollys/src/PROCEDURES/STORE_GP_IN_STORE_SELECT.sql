--------------------------------------------------------
--  DDL for Procedure STORE_GP_IN_STORE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_GP_IN_STORE_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-23
-- Description	:	매장그룹 내 매장 목록 조회
-- Test			:	exec STORE_GP_IN_STORE_SELECT ''
-- ==========================================================================================
        P_STOR_GP_ID    IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.STOR_GP_ID  AS STOR_GP_ID
                 , A.STOR_CD AS STOR_CD
                 , B.STOR_GP_NM AS STOR_GP_NM
                 , C.STOR_TP AS STOR_TP
                 , GET_STOR_NM(C.BRAND_CD, A.STOR_CD, 'KOR') AS STOR_NM
                 , C.APP_DIV AS APP_DIV
                 , (CASE WHEN   C.APP_DIV = '02' OR C.APP_DIV = '06' --폐점,휴업
                         THEN	'N'
                         ELSE	'Y'
                   END) AS USE_YN 
        FROM       STORE_GP_IN_STORE A
        JOIN       STORE_GP B
        ON         A.STOR_GP_ID = B.STOR_GP_ID
        JOIN       STORE C
        ON         A.STOR_CD = C.STOR_CD
        WHERE      A.STOR_GP_ID = P_STOR_GP_ID 
        ORDER BY 
                   A.STOR_CD ASC;
END STORE_GP_IN_STORE_SELECT;

/
