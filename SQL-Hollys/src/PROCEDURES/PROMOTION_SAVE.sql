--------------------------------------------------------
--  DDL for Procedure PROMOTION_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 정보 등록/수정
-- Test			:	exec PROMOTION_SAVE '002', '', '', '' 
-- ==========================================================================================
        N_PRMT_ID              IN    VARCHAR2,
        P_PRMT_CLASS           IN    VARCHAR2,
        P_PRMT_TYPE            IN    VARCHAR2,
        P_PRMT_NM              IN    VARCHAR2,
        P_PRMT_DT_START        IN    VARCHAR2,
        P_PRMT_DT_END          IN    VARCHAR2,
        P_PRMT_USE_DIV         IN    VARCHAR2,
        N_PRMT_COUPON_YN       IN    VARCHAR2,
        P_PRMT_TIME_HH_START   IN    CHAR,
        P_PRMT_TIME_MM_START   IN    CHAR,
        P_PRMT_TIME_HH_END     IN    CHAR,
        P_PRMT_TIME_MM_END     IN    CHAR, 
        N_PRMT_WEEK_1          IN    CHAR,
        N_PRMT_WEEK_2          IN    CHAR,
        N_PRMT_WEEK_3          IN    CHAR,
        N_PRMT_WEEK_4          IN    CHAR,
        N_PRMT_WEEK_5          IN    CHAR,
        N_PRMT_WEEK_6          IN    CHAR, 
        N_PRMT_WEEK_7          IN    CHAR,
        P_CONDITION_QTY_REQ    IN    VARCHAR2,
        P_CONDITION_QTY_NOR    IN    VARCHAR2,
        P_CONDITION_AMT        IN    VARCHAR2,
        P_GIVE_QTY             IN    VARCHAR2,
        P_SALE_RATE            IN    VARCHAR2,
        P_SALE_AMT             IN    VARCHAR2,
        P_GIVE_REWARD          IN    VARCHAR2,
        N_COUPON_NOTICE        IN    VARCHAR2,
        P_COUPON_NOTICE_PRINT  IN    CHAR,
        N_REMARKS              IN    VARCHAR2,
        P_REMARKS_PRINT        IN    CHAR,
        N_AGREE_YN             IN    CHAR,
        N_AGREE_ID             IN    VARCHAR2,
        P_STOR_LIMIT           IN    VARCHAR2,
        P_USER_ID              IN    VARCHAR2,
        P_BRAND_CD             IN    VARCHAR2,
        N_COUPON_EXPIRE        IN    VARCHAR2,
        P_COUPON_DT_TYPE       IN    VARCHAR2,
        N_COUPON_IMG_TYPE      IN    VARCHAR2,
        P_USE_YN               IN    CHAR,
        N_SUB_PRMT_ID          IN    VARCHAR2,
        P_COMP_CD              IN    VARCHAR2,
        N_MODIFY_DIV_1         IN    VARCHAR2,
        N_REWARD_TERM          IN    VARCHAR2,
        N_LVL_CD_1             IN    VARCHAR2,
        N_LVL_CD_2             IN    VARCHAR2,
        N_LVL_CD_3             IN    VARCHAR2,
        N_LVL_CD_4             IN    VARCHAR2,
        P_PRINT_TARGET         IN    VARCHAR2,
        N_MODIFY_DIV_2         IN    VARCHAR2,
        O_PRMT_ID              OUT   VARCHAR2,
        O_PRMT_NM              OUT   VARCHAR2,
        O_PRMT_CLASS           OUT   VARCHAR2,
        O_PRMT_TYPE            OUT   VARCHAR2,
        O_BRAND_CD             OUT   VARCHAR2
) AS 
BEGIN
        IF  N_PRMT_ID IS NULL THEN
        
            SELECT SQ_PRMT_ID.NEXTVAL
            INTO O_PRMT_ID
            FROM DUAL;

            INSERT INTO PROMOTION
            (       PRMT_ID
                   ,PRMT_CLASS
                   ,PRMT_TYPE
                   ,PRMT_NM
                   ,PRMT_DT_START
                   ,PRMT_DT_END
                   ,PRMT_USE_DIV
                   ,PRMT_COUPON_YN
                   ,PRMT_TIME_HH_START
                   ,PRMT_TIME_MM_START
                   ,PRMT_TIME_HH_END
                   ,PRMT_TIME_MM_END
                   ,PRMT_WEEK_1
                   ,PRMT_WEEK_2
                   ,PRMT_WEEK_3
                   ,PRMT_WEEK_4
                   ,PRMT_WEEK_5
                   ,PRMT_WEEK_6
                   ,PRMT_WEEK_7
                   ,CONDITION_QTY_REQ
                   ,CONDITION_QTY_NOR
                   ,CONDITION_AMT
                   ,GIVE_QTY
                   ,SALE_RATE
                   ,SALE_AMT
                   ,GIVE_REWARD
                   ,COUPON_NOTICE
                   ,COUPON_NOTICE_PRINT
                   ,REMARKS
                   ,REMARKS_PRINT
                   ,AGREE_YN
                   ,AGREE_ID
                   ,AGREE_DT
                   ,STOR_LIMIT
                   ,INST_USER
                   ,INST_DT
                   ,UPD_USER
                   ,UPD_DT
                   ,BRAND_CD
                   ,USE_YN
                   ,SUB_PRMT_ID
                   ,COMP_CD
                   ,MODIFY_DIV_1
                   ,REWARD_TERM
                   ,LVL_CD_1
                   ,LVL_CD_2
                   ,LVL_CD_3
                   ,LVL_CD_4
                   ,PRINT_TARGET
                   ,MODIFY_DIV_2
                   ,COUPON_EXPIRE
                   ,COUPON_IMG_TYPE
                   ,COUPON_DT_TYPE 
           ) VALUES (   
                    SQ_PRMT_ID.NEXTVAL
                   ,P_PRMT_CLASS
                   ,P_PRMT_TYPE
                   ,P_PRMT_NM
                   ,P_PRMT_DT_START
                   ,P_PRMT_DT_END
                   ,P_PRMT_USE_DIV
                   ,DECODE(N_PRMT_COUPON_YN, 'Y', 'Y', 'N')
                   ,P_PRMT_TIME_HH_START
                   ,P_PRMT_TIME_MM_START
                   ,P_PRMT_TIME_HH_END
                   ,P_PRMT_TIME_MM_END
                   ,N_PRMT_WEEK_1
                   ,N_PRMT_WEEK_2
                   ,N_PRMT_WEEK_3
                   ,N_PRMT_WEEK_4
                   ,N_PRMT_WEEK_5
                   ,N_PRMT_WEEK_6
                   ,N_PRMT_WEEK_7
                   ,P_CONDITION_QTY_REQ
                   ,P_CONDITION_QTY_NOR
                   ,P_CONDITION_AMT
                   ,P_GIVE_QTY
                   ,P_SALE_RATE
                   ,P_SALE_AMT
                   ,P_GIVE_REWARD
                   ,N_COUPON_NOTICE
                   ,DECODE(P_COUPON_NOTICE_PRINT, 'Y', 'Y', 'N')
                   ,N_REMARKS
                   ,DECODE(P_REMARKS_PRINT, 'Y', 'Y', 'N')
                   ,DECODE(N_AGREE_YN, 'Y', 'Y', 'N')
                   ,N_AGREE_ID
                   ,CASE WHEN N_AGREE_YN IS NOT NULL AND N_AGREE_YN <> 'Y' THEN SYSDATE
                              ELSE NULL
                    END
                   ,DECODE(P_STOR_LIMIT, '1', '1', '0')
                   ,P_USER_ID
                   ,SYSDATE
                   ,P_USER_ID
                   ,SYSDATE
                   ,P_BRAND_CD
                   ,DECODE(P_USE_YN, 'Y', 'Y', 'N')
                   ,N_SUB_PRMT_ID
                   ,P_COMP_CD
                   ,N_MODIFY_DIV_1
                   ,N_REWARD_TERM
                   ,N_LVL_CD_1
                   ,N_LVL_CD_2
                   ,N_LVL_CD_3
                   ,N_LVL_CD_4
                   ,P_PRINT_TARGET
                   ,N_MODIFY_DIV_2
                   ,N_COUPON_EXPIRE
                   ,N_COUPON_IMG_TYPE
                   ,P_COUPON_DT_TYPE
           );

        ELSE

           UPDATE   PROMOTION
              SET   PRMT_CLASS          = P_PRMT_CLASS
                   ,PRMT_TYPE           = P_PRMT_TYPE
                   ,PRMT_NM             = P_PRMT_NM
                   ,PRMT_DT_START       = P_PRMT_DT_START
                   ,PRMT_DT_END         = P_PRMT_DT_END
                   ,PRMT_USE_DIV        = P_PRMT_USE_DIV
                   ,PRMT_COUPON_YN      = DECODE(N_PRMT_COUPON_YN, 'Y', 'Y', 'N')
                   ,PRMT_TIME_HH_START  = P_PRMT_TIME_HH_START
                   ,PRMT_TIME_MM_START  = P_PRMT_TIME_MM_START
                   ,PRMT_TIME_HH_END    = P_PRMT_TIME_HH_END
                   ,PRMT_TIME_MM_END    = P_PRMT_TIME_MM_END
                   ,PRMT_WEEK_1         = DECODE(N_PRMT_WEEK_1, 'Y', 'Y', 'N')
                   ,PRMT_WEEK_2         = DECODE(N_PRMT_WEEK_2, 'Y', 'Y', 'N')
                   ,PRMT_WEEK_3         = DECODE(N_PRMT_WEEK_3, 'Y', 'Y', 'N')
                   ,PRMT_WEEK_4         = DECODE(N_PRMT_WEEK_4, 'Y', 'Y', 'N')
                   ,PRMT_WEEK_5         = DECODE(N_PRMT_WEEK_5, 'Y', 'Y', 'N')
                   ,PRMT_WEEK_6         = DECODE(N_PRMT_WEEK_6, 'Y', 'Y', 'N')
                   ,PRMT_WEEK_7         = DECODE(N_PRMT_WEEK_7, 'Y', 'Y', 'N')
                   ,CONDITION_QTY_REQ   = P_CONDITION_QTY_REQ
                   ,CONDITION_QTY_NOR   = P_CONDITION_QTY_NOR
                   ,CONDITION_AMT       = P_CONDITION_AMT
                   ,GIVE_QTY            = P_GIVE_QTY
                   ,SALE_RATE           = P_SALE_RATE
                   ,SALE_AMT            = P_SALE_AMT
                   ,GIVE_REWARD         = P_GIVE_REWARD
                   ,COUPON_NOTICE       = N_COUPON_NOTICE
                   ,COUPON_NOTICE_PRINT = DECODE(P_COUPON_NOTICE_PRINT, 'Y', 'Y', 'N')
                   ,REMARKS             = N_REMARKS
                   ,REMARKS_PRINT       = DECODE(P_REMARKS_PRINT, 'Y', 'Y', 'N')
                   ,AGREE_YN            = DECODE(N_AGREE_YN, 'Y', 'Y', 'N')
                   ,AGREE_ID            = N_AGREE_ID
                   ,AGREE_DT            = CASE WHEN TRIM(N_AGREE_ID) IS NULL
                                                    THEN NULL
                                                    ELSE SYSDATE
                                          END
                   ,STOR_LIMIT          = DECODE(P_STOR_LIMIT, '1', '1', '0')
                   ,UPD_USER            = P_USER_ID
                   ,UPD_DT              = SYSDATE
                   ,BRAND_CD            = P_BRAND_CD
                   ,USE_YN              = DECODE(P_USE_YN, 'Y', 'Y', 'N')
                   ,SUB_PRMT_ID         = N_SUB_PRMT_ID
                   ,MODIFY_DIV_1        = N_MODIFY_DIV_1
                   ,REWARD_TERM         = N_REWARD_TERM
                   ,LVL_CD_1            = DECODE(N_LVL_CD_1, 'Y', 'Y', 'N')
                   ,LVL_CD_2            = DECODE(N_LVL_CD_2, 'Y', 'Y', 'N')
                   ,LVL_CD_3            = DECODE(N_LVL_CD_3, 'Y', 'Y', 'N')
                   ,LVL_CD_4            = DECODE(N_LVL_CD_4, 'Y', 'Y', 'N')
                   ,PRINT_TARGET        = P_PRINT_TARGET
                   ,MODIFY_DIV_2        = N_MODIFY_DIV_2
                   ,COUPON_EXPIRE       = N_COUPON_EXPIRE
                   ,COUPON_IMG_TYPE     = N_COUPON_IMG_TYPE
                   ,COUPON_DT_TYPE      = P_COUPON_DT_TYPE
            WHERE   PRMT_ID             = N_PRMT_ID
            AND     COMP_CD             = P_COMP_CD;
            
            O_PRMT_ID := N_PRMT_ID;
            
            END IF;    
            
            O_PRMT_NM := P_PRMT_NM;            
            O_PRMT_CLASS := P_PRMT_CLASS;  
            O_PRMT_TYPE := P_PRMT_TYPE;        
            O_BRAND_CD := P_BRAND_CD;

END PROMOTION_SAVE;

/
