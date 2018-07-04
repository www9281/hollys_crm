--------------------------------------------------------
--  DDL for Procedure PROMOTION_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	프로모션 목록 조회
-- Test			:	exec PROMOTION_SELECT '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2, 
        N_BRAND_CD      IN   VARCHAR2,
        N_USE_YN        IN   VARCHAR2,
        N_PRMT_CLASS    IN   VARCHAR2,
        N_PRMT_TYPE     IN   VARCHAR2,
        N_PRMT_NM       IN   VARCHAR2, 
        N_PRMT_DT_START IN   VARCHAR2,
        N_PRMT_DT_END   IN   VARCHAR2,  
        P_USER_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR 
) AS   
BEGIN    
        OPEN       O_CURSOR  FOR 
        SELECT     A.PRMT_ID  AS PRMT_ID
                 , GET_COMMON_CODE_NM('C5000', A.PRMT_CLASS, 'KOR') AS PRMT_CLASS_NM
                 , GET_COMMON_CODE_NM('C6000', A.PRMT_TYPE, 'KOR') AS PRMT_TYPE_NM
                 , A.PRMT_CLASS AS PRMT_CLASS 
                 , A.PRMT_TYPE AS PRMT_TYPE
                 , A.PRMT_NM  AS PRMT_NM
                 , A.BRAND_CD  AS BRAND_CD
                 , TO_CHAR(TO_DATE(A.PRMT_DT_START,'YYYYMMDD'),'YYYY-MM-DD') AS PRMT_DT_START
                 , TO_CHAR(TO_DATE(A.PRMT_DT_END,'YYYYMMDD'),'YYYY-MM-DD') AS PRMT_DT_END
                 ,(CASE WHEN EXISTS (
                                        SELECT PUBLISH_ID
                                        FROM   PROMOTION_COUPON_PUBLISH
                                        WHERE  PRMT_ID = A.PRMT_ID  
                                    )
                         THEN	'Y'
                         ELSE	'N'
                   END) AS  PUBLISH_YN  
                 , (CASE WHEN EXISTS (
                                        SELECT PUBLISH_ID
                                        FROM   PROMOTION_COUPON_PUBLISH
                                        WHERE  PRMT_ID = A.PRMT_ID  
                                     )
                         THEN	 CASE WHEN (SELECT COUNT(*) FROM PROMOTION_SMS WHERE PRMT_ID = A.PRMT_ID) > 0 THEN 'Y'
                                      ELSE 'N'
                                 END
                         ELSE	'N' 
                   END) AS SMS_SEND_YN
                 , (CASE WHEN EXISTS (
                                        SELECT PUBLISH_ID
                                        FROM   PROMOTION_COUPON_PUBLISH
                                        WHERE  PRMT_ID = A.PRMT_ID  
                                     )
                         THEN	 CASE WHEN (SELECT COUNT(*) FROM PROMOTION_PUSH WHERE PRMT_ID = A.PRMT_ID) > 0 THEN 'Y'
                                      ELSE 'N'
                                 END
                         ELSE	'N' 
                   END) AS PUSH_SEND_YN                 
                 , (CASE WHEN   A.PRMT_CLASS = 'C5002'
                         THEN	CASE WHEN   A.AGREE_DT IS NULL
                                     THEN	'N'
                                     ELSE	'Y'
                                END
                         ELSE	''
                   END)                                       AS AGREE_YN
                 , DECODE(A.USE_YN, 'Y', 'Y', 'N')            AS USE_YN
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD')             AS UPD_DT
                 , A.SUB_PRMT_ID                              AS SUB_PRMT_ID
                 , GET_PROMOTION_NM(A.SUB_PRMT_ID, A.COMP_CD) AS SUB_PRMT_NM
                 , NVL(AFF_BAL_YN,'N')                        AS AFF_BAL_YN
                 , AFF_BAL_NUM
        FROM       PROMOTION A
        WHERE      A.COMP_CD = P_COMP_CD      
        AND        (A.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                    AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_USER_ID AND BRAND_CD = A.BRAND_CD AND USE_YN = 'Y'))) 
        AND        (TRIM(N_PRMT_CLASS) IS NULL OR A.PRMT_CLASS = N_PRMT_CLASS)
        AND        (TRIM(N_PRMT_TYPE) IS NULL OR A.PRMT_TYPE = N_PRMT_TYPE)
        AND        ((TRIM(N_PRMT_DT_START) IS NULL OR A.PRMT_DT_END >= N_PRMT_DT_START) AND (TRIM(N_PRMT_DT_END) IS NULL OR A.PRMT_DT_START <= N_PRMT_DT_END))
        AND        (TRIM(N_PRMT_NM) IS NULL OR UPPER(A.PRMT_NM) LIKE '%'|| UPPER(N_PRMT_NM)||'%')
        AND        (TRIM(N_USE_YN) IS NULL OR A.USE_YN = N_USE_YN)
        ORDER BY 
                    A.PRMT_ID DESC;
END PROMOTION_SELECT;

/
