--------------------------------------------------------
--  DDL for Procedure PROMOTION_TARGET_MN_GP_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_TARGET_MN_GP_UPDATE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 대상메뉴군 사용안함처리
-- Test			:	exec PROMOTION_TARGET_MN_GP_UPDATE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID         IN   VARCHAR2,
        P_ITEM_DATA       IN   VARCHAR2,
        P_USER_ID         IN   VARCHAR2,
        O_PRMT_ID         OUT  VARCHAR2
) AS 
        L_ROW               VARCHAR2(1)     := CHR(28);
        L_COLUMN            VARCHAR2(1)     := CHR(29); 
BEGIN   
        DELETE PROMOTION_TARGET_MN_GP
        WHERE  PRMT_ID = P_PRMT_ID;

        INSERT  INTO  PROMOTION_TARGET_MN_GP 
        (
                PRMT_ID
                ,L_CLASS_CD
                ,M_CLASS_CD
                ,S_CLASS_CD
                ,D_CLASS_CD
                ,ITEM_DIV
                ,QTY 
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
        )        
        SELECT  P_PRMT_ID,
                TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 1)) AS L_CLASS_CD,
                (CASE WHEN TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 2)) = '@' THEN NULL
                      ELSE TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 2))
                 END
                )AS M_CLASS_CD,
                (CASE WHEN TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 3)) = '@' THEN NULL
                      ELSE TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 3))
                 END
                )AS S_CLASS_CD,
                (CASE WHEN TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 4)) = '@' THEN NULL
                      ELSE TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 4))
                 END
                )AS D_CLASS_CD,
                TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 5)) AS ITEM_DIV,
                TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 6)) AS QTY,
                'N',
                TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 7)) AS INST_USER,
                (CASE WHEN TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 8)) = '@' THEN SYSDATE
                      ELSE TO_DATE(TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 8)),'YYYY-MM-DD') 
                 END
                )AS INST_DT,
                P_USER_ID,
                SYSDATE
        FROM    (
                    SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_ROW || ']+', 1, LEVEL)) AS D
                    FROM    (SELECT P_ITEM_DATA AS DATA FROM DUAL)
                    CONNECT BY  INSTR(DATA, L_ROW, 1, LEVEL - 1) > 0
                );
       
       O_PRMT_ID := P_PRMT_ID;

END PROMOTION_TARGET_MN_GP_UPDATE;

/
