--------------------------------------------------------
--  DDL for Procedure PROMOTION_SELECT_GROUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_SELECT_GROUP" (
        N_COMP_CD       IN   VARCHAR2,
        N_BRAND_CD      IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN
    OPEN    O_CURSOR  FOR 
    SELECT  A.PRMT_ID,
            A.PRMT_NM,
            CASE  WHEN  A.SUB_PRMT_ID IS NOT NULL
                  THEN  1
                  ELSE  0
            END AS IS_COUPON,
            CASE  WHEN  EXISTS (
                            SELECT  PRMT_ID 
                            FROM    PROMOTION
                            WHERE   PRMT_ID = A.SUB_PRMT_ID
                            AND     PRMT_TYPE = 'C6015'
                        )
                  THEN  1
                  ELSE  0 
            END AS IS_EVENT, 
            CASE  WHEN  EXISTS (
                            SELECT  PRMT_ID
                            FROM    PROMOTION
                            WHERE   PRMT_ID = A.SUB_PRMT_ID
                            AND     PRMT_TYPE = 'C5004'
                        )
                  THEN  1
                  ELSE  0
            END AS IS_CON,
            CASE  WHEN  PRMT_CLASS = 'C5005' AND MODIFY_DIV_2 IN ('P0101', 'P0102', 'P0103')
                  THEN  1
                  ELSE  0
            END AS IS_GIFT,
            CASE  WHEN  EXISTS (
                            SELECT  PRMT_ID
                            FROM    PROMOTION
                            WHERE   PRMT_ID = A.SUB_PRMT_ID
                            AND     PRMT_TYPE = 'C6020'
                        )
                  THEN  1
                  ELSE  0
            END AS IS_RCH,
            CASE  WHEN  EXISTS (
                            SELECT  PRMT_ID
                            FROM    PROMOTION
                            WHERE   PRMT_ID = A.SUB_PRMT_ID
                            AND     PRMT_TYPE = 'C6017'
                        )
                  THEN  1
                  ELSE  0
            END AS IS_FRQ,
            CASE  WHEN  A.SUB_PRMT_ID IS NULL
                  THEN  1
                  ELSE  0
            END AS IS_DC,
            CASE  WHEN  PRMT_CLASS = 'C5002'
                  THEN  1
                  ELSE  0
            END AS IS_LSM
    FROM    PROMOTION A
    WHERE   A.USE_YN = 'Y'
    AND     (N_COMP_CD IS NULL OR N_COMP_CD = '' OR A.COMP_CD = N_COMP_CD)
    AND     (N_BRAND_CD IS NULL OR N_BRAND_CD = '' OR A.BRAND_CD = N_BRAND_CD);
END PROMOTION_SELECT_GROUP;

/
