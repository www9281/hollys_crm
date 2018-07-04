--------------------------------------------------------
--  DDL for Procedure PROMOTION_VIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_VIEW" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	프로모션 상세보기 조회
-- Test			:	exec PROMOTION_VIEW '30', 'level_10'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.PRMT_ID  AS PRMT_ID
                 , A.SUB_PRMT_ID  AS SUB_PRMT_ID
                 , A.COMP_CD AS COMP_CD 
                 , A.BRAND_CD AS BRAND_CD
                 , A.PRMT_CLASS AS PRMT_CLASS
                 , A.PRMT_TYPE AS PRMT_TYPE
                 , A.PRMT_NM AS PRMT_NM
                 , TO_CHAR(TO_DATE(A.PRMT_DT_START,'YYYYMMDD'),'YYYY-MM-DD')  AS PRMT_DT_START
                 , TO_CHAR(TO_DATE(A.PRMT_DT_END,'YYYYMMDD'),'YYYY-MM-DD')  AS PRMT_DT_END
                 , A.PRMT_USE_DIV AS PRMT_USE_DIV
                 , A.PRMT_COUPON_YN AS PRMT_COUPON_YN
                 , A.PRMT_TIME_HH_START AS PRMT_TIME_HH_START
                 , A.PRMT_TIME_HH_END AS PRMT_TIME_HH_END
                 , A.PRMT_TIME_MM_START AS PRMT_TIME_MM_START
                 , A.PRMT_TIME_MM_END AS PRMT_TIME_MM_END
                 , A.PRMT_WEEK_1 AS PRMT_WEEK_1
                 , A.PRMT_WEEK_2 AS PRMT_WEEK_2
                 , A.PRMT_WEEK_3 AS PRMT_WEEK_3
                 , A.PRMT_WEEK_4 AS PRMT_WEEK_4
                 , A.PRMT_WEEK_5 AS PRMT_WEEK_5
                 , A.PRMT_WEEK_6 AS PRMT_WEEK_6
                 , A.PRMT_WEEK_7 AS PRMT_WEEK_7
                 , A.COUPON_DT_TYPE AS COUPON_DT_TYPE
                 , A.COUPON_EXPIRE AS COUPON_EXPIRE
                 , A.COUPON_IMG_TYPE AS COUPON_IMG_TYPE
                 , A.MODIFY_DIV_1  AS MODIFY_DIV_1
                 , A.REWARD_TERM AS REWARD_TERM
                 , A.LVL_CD_1  AS LVL_CD_1
                 , A.LVL_CD_2  AS LVL_CD_2
                 , A.LVL_CD_3  AS LVL_CD_3
                 , A.LVL_CD_4  AS LVL_CD_4
                 , A.PRINT_TARGET  AS PRINT_TARGET
                 , A.MODIFY_DIV_2  AS MODIFY_DIV_2
                 , A.CONDITION_QTY_REQ AS CONDITION_QTY_REQ
                 , A.CONDITION_QTY_NOR AS CONDITION_QTY_NOR
                 , A.CONDITION_AMT AS CONDITION_AMT
                 , A.GIVE_QTY AS GIVE_QTY
                 , A.SALE_RATE  AS SALE_RATE
                 , A.SALE_AMT AS SALE_AMT
                 , A.GIVE_REWARD AS GIVE_REWARD
                 , A.COUPON_NOTICE AS COUPON_NOTICE
                 , DECODE(A.COUPON_NOTICE_PRINT, 'Y', 'Y', 'N') AS COUPON_NOTICE_PRINT
                 , A.REMARKS AS REMARKS
                 , DECODE(A.REMARKS_PRINT, 'Y', 'Y', 'N') AS REMARKS_PRINT
                 , DECODE(A.AGREE_YN, 'Y', 'Y', 'N') AS AGREE_YN
                 , A.AGREE_ID AS AGREE_ID
                 , (CASE WHEN   A.AGREE_DT IS NULL THEN	NULL
                         ELSE	TO_CHAR(SYSDATE,'YYYY-MM-DD')
                   END) AS  AGREE_DT
                 , DECODE(A.STOR_LIMIT, '1', '1', '0')  AS STOR_LIMIT
                 , DECODE(A.USE_YN, 'Y', 'Y', 'N')  AS USE_YN
                 , A.INST_USER AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
                 , A.UPD_USER AS UPD_USER
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
                 , NVL(AFF_BAL_YN,'N') AS AFF_BAL_YN
                 , AFF_BAL_NUM
        FROM       PROMOTION A
        WHERE      A.PRMT_ID = P_PRMT_ID;
        
        dbms_output.put_line(SQLERRM);
        
END PROMOTION_VIEW;

/
