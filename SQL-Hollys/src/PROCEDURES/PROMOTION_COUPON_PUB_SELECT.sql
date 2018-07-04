--------------------------------------------------------
--  DDL for Procedure PROMOTION_COUPON_PUB_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_COUPON_PUB_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 쿠폰발행정보 목록 조회
-- Test			:	exec PROMOTION_COUPON_PUB_SELECT '002'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.PUBLISH_ID AS PUBLISH_ID
                  ,A.PRMT_ID AS PRMT_ID
                  ,A.PUBLISH_TYPE AS PUBLISH_TYPE
                  ,GET_COMMON_CODE_NM('C6500',A.PUBLISH_TYPE,'KOR') AS PUBLISH_TYPE_NAME
                  ,DECODE(A.OWN_YN, 'Y', 'Y', 'N') AS OWN_YN
                  ,DECODE(A.OWN_YN, 'Y', '기명', '무기명') AS OWN_YN_NM   
                  ,(
                        SELECT COUNT(*)
                        FROM   PROMOTION_COUPON 
                        WHERE  PUBLISH_ID = A.PUBLISH_ID 
                  ) AS PUBLISH_COUNT
                  ,A.NOTES AS NOTES
                  ,A.INST_USER AS INST_USER 
                  ,TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
                  ,(
                        SELECT COUNT(*)
                        FROM   PROMOTION_COUPON
                        WHERE  PUBLISH_ID = A.PUBLISH_ID
                  ) AS TOT_PUBLISH_COUNT
                  ,(
                        SELECT COUNT(*)
                        FROM   PROMOTION_COUPON
                        WHERE  PUBLISH_ID = A.PUBLISH_ID
                        AND    USE_DT IS NOT NULL
                        AND    DESTROY_DT IS NULL
                  ) AS TOT_USE_COUNT
        FROM       PROMOTION_COUPON_PUBLISH A
        WHERE      A.PRMT_ID = P_PRMT_ID
        ORDER BY 
                   A.INST_DT DESC;
END PROMOTION_COUPON_PUB_SELECT;

/
