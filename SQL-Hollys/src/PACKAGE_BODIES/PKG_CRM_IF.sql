--------------------------------------------------------
--  DDL for Package Body PKG_CRM_IF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_CRM_IF" AS
------------------------------------------------------------------------------
--  Package Name     : PKG_CRM_IF
--  Description      : CRM 인터페이스 
------------------------------------------------------------------------------
--  Create Date      : 2018-01-05
--  Create Programer :
--  Modify Date      :
--  Modify Programer :
------------------------------------------------------------------------------

    -- 프로모션 정보 취득
    PROCEDURE SP_GET_PROMOTION
    ( 
        PSV_COMP_CD     IN  VARCHAR2   -- 회사코드
    ) IS
        CURSOR CUR_1 IS
            SELECT  COMP_CD
                  , TBL_ID
                  , RMT_TBL_ID
                  , COMP_VAL1
            FROM    SYNC_TBL_LST
            WHERE   COMP_CD = PSV_COMP_CD
            AND     USE_YN  = 'Y'
            ORDER BY
                    SEQNO;

        --로컬변수 선언    
        vLANGUAGE       VARCHAR2(3)  := 'kor';
        vCUR_DT         VARCHAR2(14) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
        vPRMT_DIV       C_PROMOTION_MST.PRMT_DIV%TYPE;
        vCUST_DIV       C_PROMOTION_MST.CUST_DIV%TYPE;
        vAPPL_DIV       C_PROMOTION_MST.APPL_DIV%TYPE;
        vBNF_FG         C_PROMOTION_MST.BNF_FG%TYPE;
        vPAY_DIV        C_PROMOTION_MST.PAY_DIV%TYPE;

        nBILL_CUST_CNT  C_PROMOTION_MST.BILL_CUST_CNT%TYPE;
        nITEM_QTY1      C_PROMOTION_MST.ITEM_QTY1%TYPE;
        nITEM_QTY2      C_PROMOTION_MST.ITEM_QTY2%TYPE;
        nBNF_VALUE      C_PROMOTION_MST.BNF_VALUE%TYPE;

        vPRINT_TARGET   VARCHAR2(10) := NULL;
        vRECEIPT_TYPE   VARCHAR2(10) := NULL;
        vPAY_METHOD     VARCHAR2(10) := NULL;

        nMENU_COUNT     NUMBER      := 0;  
        nBILL_COUNT     NUMBER      := 0;
        nRECCNT         NUMBER      := 0;
        nLOOP           NUMBER      := 0;

        vRETURN_CD      VARCHAR2(2000) := NULL;
        vRETURN_MSG     VARCHAR2(2000) := NULL;

        ERR_HANDLER     EXCEPTION;
    BEGIN
        FOR MYREC IN CUR_1 LOOP
            -- 프로모션 마스터
            SP_GET_PROMOTION_01(PSV_COMP_CD, vLANGUAGE, MYREC.COMP_VAL1, vCUR_DT, vRETURN_CD, vRETURN_MSG);

            IF vRETURN_CD != '0000' THEN
                RAISE ERR_HANDLER;
            END IF;

            -- 프로모션 영수증
            SP_GET_PROMOTION_02(PSV_COMP_CD, vLANGUAGE, MYREC.COMP_VAL1, vCUR_DT, vRETURN_CD, vRETURN_MSG);

            IF vRETURN_CD != '0000' THEN
                RAISE ERR_HANDLER;
            END IF;

            -- 프로모션 매장
            SP_GET_PROMOTION_03(PSV_COMP_CD, vLANGUAGE, MYREC.COMP_VAL1, vCUR_DT, vRETURN_CD, vRETURN_MSG);

            IF vRETURN_CD != '0000' THEN
                RAISE ERR_HANDLER;
            END IF;

            -- 프로모션 아이템
            SP_GET_PROMOTION_04(PSV_COMP_CD, vLANGUAGE, MYREC.COMP_VAL1, vCUR_DT, vRETURN_CD, vRETURN_MSG);

            IF vRETURN_CD != '0000' THEN
                RAISE ERR_HANDLER;
            END IF;

            UPDATE  SYNC_TBL_LST
            SET     COMP_VAL1 = vCUR_DT
            WHERE   COMP_CD = MYREC.COMP_CD
            AND     TBL_ID  = MYREC.TBL_ID;
        END LOOP;

        COMMIT;

        RETURN;
    EXCEPTION 
        WHEN ERR_HANDLER THEN
            DBMS_OUTPUT.PUT_LINE(vRETURN_CD||':'||vRETURN_MSG);
            ROLLBACK;
            RETURN;
    END;

    -- 프로모션 정보 취득
    PROCEDURE SP_GET_PROMOTION_01
    ( 
        PSV_COMP_CD     IN  VARCHAR2,   -- 회사코드
        PSV_LANGUAGE    IN  VARCHAR2,   -- 언어코드
        PSV_UPD_DT      IN  VARCHAR2,   -- 직전갱신일자
        PSV_CUR_DT      IN  VARCHAR2,   -- 현재갱신일자
        PR_RETURN_CD    OUT VARCHAR2,   -- 메세지코드
        PR_RETURN_MSG   OUT VARCHAR2    -- 메세지
    ) IS
        -- 프로모션 마스터
        CURSOR CUR_1 IS
            SELECT  *
            FROM    PROMOTION@HCRM
            WHERE   UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS')
            AND     UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS')
            AND    (
                    PRMT_CLASS != 'C5002'
                    OR
                    PRMT_CLASS  = 'C5002' AND AGREE_YN = 'Y' -- LSM은 승인된 건만.
                   );

        --로컬변수 선언    
        vPRMT_DIV       C_PROMOTION_MST.PRMT_DIV%TYPE;
        vCUST_DIV       C_PROMOTION_MST.CUST_DIV%TYPE;
        vAPPL_DIV       C_PROMOTION_MST.APPL_DIV%TYPE;
        vBNF_FG         C_PROMOTION_MST.BNF_FG%TYPE;
        vPAY_DIV        C_PROMOTION_MST.PAY_DIV%TYPE;

        nBILL_CUST_CNT  C_PROMOTION_MST.BILL_CUST_CNT%TYPE;
        nITEM_QTY1      C_PROMOTION_MST.ITEM_QTY1%TYPE;
        nITEM_QTY2      C_PROMOTION_MST.ITEM_QTY2%TYPE;
        nBNF_VALUE      C_PROMOTION_MST.BNF_VALUE%TYPE;

        vPRINT_TARGET   VARCHAR2(10) := NULL;
        vRECEIPT_TYPE   VARCHAR2(10) := NULL;
        vPAY_METHOD     VARCHAR2(10) := NULL;

        nMENU_COUNT     NUMBER      := 0;  
        nBILL_COUNT     NUMBER      := 0;
        nRECCNT         NUMBER      := 0;
        nLOOP           NUMBER      := 0;
    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PR_RETURN_CD    := '0000';
        PR_RETURN_MSG   := 'OK';

        FOR MYREC IN CUR_1 LOOP
            -- 프로모션과 쿠폰 연결정보 COUNT(*)
            SELECT  COUNT(*) INTO nRECCNT
            FROM    PROMOTION_COUPON_PUBLISH@HCRM
            WHERE   PRMT_ID = MYREC.PRMT_ID;

            -- 프로모션 종류
            vPRMT_DIV := CASE WHEN nRECCNT > 0                      THEN '1'
                              WHEN MYREC.SUB_PRMT_ID IS NOT NULL    THEN '3'
                              ELSE                                       '2'
                         END;

            -- 프로모션과 영수증 연결정보
            SELECT  COUNT(*), MAX(PRINT_TARGET), MAX(RECEIPT_TYPE), MAX(BILL_COUNT), MAX(MENU_COUNT), MAX(PAY_METHOD)
            INTO    nRECCNT , vPRINT_TARGET    , vRECEIPT_TYPE    , nBILL_COUNT    , nMENU_COUNT    , vPAY_METHOD
            FROM    PROMOTION_PRINT@HCRM
            WHERE   PRMT_ID = MYREC.PRMT_ID;

            -- 대상고객
            vCUST_DIV := CASE WHEN nRECCNT = 0              THEN NULL
                              WHEN vPRINT_TARGET = 'C6101'  THEN '1'
                              WHEN vPRINT_TARGET = 'C6102'  THEN '2'
                              WHEN vPRINT_TARGET = 'C6103'  THEN '3'
                              ELSE                               NULL
                         END;

            -- 결제수단
            vPAY_DIV :=  CASE WHEN nRECCNT = 0              THEN NULL
                              ELSE                               vPAY_METHOD
                         END;

            -- 적용단위
            vAPPL_DIV := CASE WHEN MYREC.PRMT_TYPE = 'C6017'   THEN '3' 
                              WHEN nRECCNT = 0                 THEN NULL
                              WHEN vRECEIPT_TYPE = 'C6301'     THEN '1'
                              WHEN vRECEIPT_TYPE = 'C6302'     THEN '2'
                              WHEN vRECEIPT_TYPE = 'C6303'     THEN '2'
                              ELSE                                  NULL
                         END;

            -- 영수객수
            nBILL_CUST_CNT := CASE WHEN nRECCNT = 0 THEN 0
                                   ELSE NVL(nBILL_COUNT, 0)
                              END ; 

            -- 필수수량
            nITEM_QTY1 := CASE WHEN MYREC.PRMT_TYPE = 'C6017' THEN MYREC.CONDITION_QTY_REQ
                               WHEN nRECCNT > 0               THEN NVL(nMENU_COUNT, 0)
                               ELSE                                 0
                          END;

            -- 일반수량
            nITEM_QTY2 := CASE WHEN MYREC.PRMT_TYPE = 'C6017' THEN NVL(MYREC.CONDITION_QTY_NOR, 0)
                               ELSE                                0
                          END;

            -- 쿠폰혜택
            vBNF_FG := CASE WHEN MYREC.PRMT_TYPE IN ('C6012', 'C6013', 'C6014')                    THEN '6'    -- 추가왕관적립
                            WHEN MYREC.PRMT_TYPE IN ('C6020')                                      THEN '5'    -- 멤버십혜택
                            WHEN MYREC.PRMT_TYPE IN ('C6001', 'C6002')                             THEN '3'    -- 판매단가
                            WHEN MYREC.PRMT_TYPE IN ('C6004', 'C6006')                             THEN '1'    -- 할인율
                            WHEN MYREC.PRMT_TYPE IN ('C6003', 'C6005')                             THEN '2'    -- 할인금액
                            WHEN MYREC.PRMT_TYPE IN ('C6007', 'C6008', 'C6009', 'C6010', 'C6011')  THEN '4'    -- 증정수량
                            WHEN MYREC.PRMT_TYPE IN ('C6015', 'C6016', 'C6017', 'C6018', 'C6019')  THEN '9'    -- 2차프로모션
                       END;

            -- 혜택값
            nBNF_VALUE :=  CASE WHEN MYREC.PRMT_TYPE IN ('C6012', 'C6013', 'C6014')                    THEN MYREC.GIVE_REWARD   -- 추가왕관적립
                                WHEN MYREC.PRMT_TYPE IN ('C6001', 'C6002')                             THEN MYREC.CONDITION_AMT -- 판매단가
                                WHEN MYREC.PRMT_TYPE IN ('C6004', 'C6006')                             THEN MYREC.SALE_RATE     -- 할인율
                                WHEN MYREC.PRMT_TYPE IN ('C6003', 'C6005')                             THEN MYREC.SALE_AMT      -- 할인금액
                                WHEN MYREC.PRMT_TYPE IN ('C6007', 'C6008', 'C6009', 'C6010', 'C6011')  THEN MYREC.GIVE_QTY      -- 증정수량
                                ELSE                                                                         NULL
                       END;

            -- 프로모션 마스터
            MERGE INTO C_PROMOTION_MST
            USING DUAL
            ON (
                    COMP_CD = PSV_COMP_CD
                AND PRMT_ID = MYREC.PRMT_ID    
               )
            WHEN MATCHED THEN
                UPDATE
                SET PRMT_NM         = MYREC.PRMT_NM
                  , PRMT_CLASS      = MYREC.PRMT_CLASS
                  , PRMT_TYPE       = MYREC.PRMT_TYPE
                  , PRMT_DIV        = vPRMT_DIV
                  , CUST_DIV        = vCUST_DIV
                  , PAY_DIV         = vPAY_DIV
                  , APPL_DIV        = vAPPL_DIV
                  , START_DT        = MYREC.PRMT_DT_START
                  , CLOSE_DT        = MYREC.PRMT_DT_END
                  , BILL_AMT        = MYREC.CONDITION_AMT
                  , BILL_AMT_DIV    = MYREC.MODIFY_DIV_1
                  , BILL_CUST_CNT   = nBILL_CUST_CNT
                  , ITEM_QTY1       = nITEM_QTY1
                  , ITEM_QTY2       = nITEM_QTY2
                  , BNF_FG          = vBNF_FG
                  , BNF_VALUE       = nBNF_VALUE
                  , SUB_PRMT_ID     = MYREC.SUB_PRMT_ID
                  , BRAND_CD        = MYREC.BRAND_CD
                  , DC_DIV          = MYREC.PRMT_ID
                  , PRMT_STAT       = CASE WHEN MYREC.USE_YN = 'Y'                     THEN '2' 
                                           WHEN MYREC.USE_YN = 'N' AND PRMT_STAT = '2' THEN '3'
                                           ELSE                                              '1'
                                      END
                  , USE_YN          = MYREC.USE_YN
                  , UPD_DT          = SYSDATE
                  , UPD_USER        = 'SYS'
            WHEN NOT MATCHED THEN
                INSERT
                   (
                    COMP_CD         , PRMT_ID
                  , PRMT_NM         , PRMT_CLASS
                  , PRMT_TYPE       , PRMT_DIV
                  , CUST_DIV        , PAY_DIV
                  , APPL_DIV        , LVL_CD
                  , START_DT        , CLOSE_DT
                  , CUST_CNT        , STOR_CUST_CNT
                  , DAY_LIMIT_CNT
                  , BILL_AMT        
                  , BILL_AMT_DIV
                  , BILL_CUST_CNT
                  , ITEM_QTY1       , ITEM_QTY2       
                  , BNF_FG          , BNF_VALUE
                  , MEMB_YN         , SUB_PRMT_ID
                  , EXPIRE_DIV      , EXPIRE_VALUE
                  , BRAND_CD        , DC_DIV
                  , PRMT_STAT       
                  , USE_YN
                  , INST_DT         , INST_USER
                  , UPD_DT          , UPD_USER
                   )
                VALUES
                   (
                    PSV_COMP_CD         , MYREC.PRMT_ID
                  , MYREC.PRMT_NM       , MYREC.PRMT_CLASS
                  , MYREC.PRMT_TYPE     , vPRMT_DIV
                  , vCUST_DIV           , vPAY_DIV
                  , vAPPL_DIV           , NULL
                  , MYREC.PRMT_DT_START , MYREC.PRMT_DT_END
                  , 0                   , 0
                  , 0
                  , NVL(MYREC.CONDITION_AMT, 0)
                  , CASE WHEN MYREC.MODIFY_DIV_1 = 'C6901' THEN '1'
                         WHEN MYREC.MODIFY_DIV_1 = 'C6902' THEN '2'
                         ELSE NVL(MYREC.MODIFY_DIV_1, '0')
                    END
                  , nBILL_CUST_CNT      
                  , nITEM_QTY1          , nITEM_QTY2       
                  , vBNF_FG             , nBNF_VALUE
                  , 'Y'                 , MYREC.SUB_PRMT_ID
                  , NULL                , 0
                  , MYREC.BRAND_CD      , MYREC.PRMT_ID
                  , CASE WHEN MYREC.USE_YN = 'Y' THEN '2' ELSE '1' END           
                  , MYREC.USE_YN
                  , SYSDATE             , 'SYS'
                  , SYSDATE             , 'SYS'
                   );

            -- 프로모션 대상요일
            FOR nLOOP IN 1..7 LOOP
                MERGE INTO C_PROMOTION_WEEK
                USING DUAL
                ON (
                        COMP_CD  = PSV_COMP_CD
                    AND PRMT_ID  = MYREC.PRMT_ID
                    AND WEEK_DAY = TO_CHAR(nLOOP, 'FM0')   
                   )
                WHEN MATCHED THEN
                    UPDATE
                    SET START_TM = MYREC.PRMT_TIME_HH_START||MYREC.PRMT_TIME_MM_START
                      , CLOSE_TM = MYREC.PRMT_TIME_HH_END||MYREC.PRMT_TIME_MM_END
                      , USE_YN   = CASE WHEN MYREC.USE_YN = 'N'                                      THEN 'N'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '1' AND MYREC.PRMT_WEEK_1 = 'Y' THEN 'Y'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '1' AND MYREC.PRMT_WEEK_1 = 'N' THEN 'N'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '2' AND MYREC.PRMT_WEEK_2 = 'Y' THEN 'Y'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '2' AND MYREC.PRMT_WEEK_2 = 'N' THEN 'N' 
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '3' AND MYREC.PRMT_WEEK_3 = 'Y' THEN 'Y'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '3' AND MYREC.PRMT_WEEK_3 = 'N' THEN 'N'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '4' AND MYREC.PRMT_WEEK_4 = 'Y' THEN 'Y'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '4' AND MYREC.PRMT_WEEK_4 = 'N' THEN 'N'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '5' AND MYREC.PRMT_WEEK_5 = 'Y' THEN 'Y'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '5' AND MYREC.PRMT_WEEK_5 = 'N' THEN 'N'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '6' AND MYREC.PRMT_WEEK_6 = 'Y' THEN 'Y'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '6' AND MYREC.PRMT_WEEK_6 = 'N' THEN 'N'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '7' AND MYREC.PRMT_WEEK_7 = 'Y' THEN 'Y'
                                        WHEN TO_CHAR(nLOOP, 'FM0') = '7' AND MYREC.PRMT_WEEK_7 = 'N' THEN 'N'
                                        ELSE 'N' 
                                   END
                      , UPD_DT   = SYSDATE
                      , UPD_USER = 'SYS'
                WHEN NOT MATCHED THEN
                    INSERT
                       (
                        COMP_CD
                      , PRMT_ID
                      , WEEK_DAY
                      , START_TM
                      , CLOSE_TM
                      , USE_YN
                      , INST_DT
                      , INST_USER
                      , UPD_DT
                      , UPD_USER
                       )
                    VALUES
                       (    
                        PSV_COMP_CD
                      , MYREC.PRMT_ID
                      , TO_CHAR(nLOOP, 'FM0')
                      , MYREC.PRMT_TIME_HH_START||MYREC.PRMT_TIME_MM_START
                      , MYREC.PRMT_TIME_HH_END||MYREC.PRMT_TIME_MM_END
                      , CASE WHEN MYREC.USE_YN = 'N'                                      THEN 'N'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '1' AND MYREC.PRMT_WEEK_1 = 'Y' THEN 'Y'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '1' AND MYREC.PRMT_WEEK_1 = 'N' THEN 'N'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '2' AND MYREC.PRMT_WEEK_2 = 'Y' THEN 'Y'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '2' AND MYREC.PRMT_WEEK_2 = 'N' THEN 'N' 
                             WHEN TO_CHAR(nLOOP, 'FM0') = '3' AND MYREC.PRMT_WEEK_3 = 'Y' THEN 'Y'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '3' AND MYREC.PRMT_WEEK_3 = 'N' THEN 'N'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '4' AND MYREC.PRMT_WEEK_4 = 'Y' THEN 'Y'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '4' AND MYREC.PRMT_WEEK_4 = 'N' THEN 'N'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '5' AND MYREC.PRMT_WEEK_5 = 'Y' THEN 'Y'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '5' AND MYREC.PRMT_WEEK_5 = 'N' THEN 'N'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '6' AND MYREC.PRMT_WEEK_6 = 'Y' THEN 'Y'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '6' AND MYREC.PRMT_WEEK_6 = 'N' THEN 'N'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '7' AND MYREC.PRMT_WEEK_7 = 'Y' THEN 'Y'
                             WHEN TO_CHAR(nLOOP, 'FM0') = '7' AND MYREC.PRMT_WEEK_7 = 'N' THEN 'N'
                             ELSE 'N' 
                        END
                      , SYSDATE
                      , 'SYS'
                      , SYSDATE
                      , 'SYS'
                       );
            END LOOP;

            -- 영수증 메시지
            MERGE INTO C_PROMOTION_BILL
            USING DUAL
            ON (
                    COMP_CD = PSV_COMP_CD
                AND PRMT_ID = MYREC.PRMT_ID
               )
            WHEN MATCHED THEN
                UPDATE
                SET PRT_TYPE1 = CASE WHEN PRT_TYPE1 = '1' THEN '1'
                                     WHEN MYREC.COUPON_NOTICE_PRINT = 'Y' OR MYREC.COUPON_NOTICE_PRINT = 'Y' THEN '1'
                                     ELSE '0'
                                END
                  , UPD_DT    = SYSDATE 
                  , UPD_USER  = 'SYS'
            WHEN NOT MATCHED THEN
                INSERT
                   (
                    COMP_CD
                  , PRMT_ID
                  , PRT_TYPE1
                  , PRT_TYPE2
                  , PRT_TYPE3
                  , PRT_TYPE4
                  , PRT_TYPE5
                  , USE_YN
                  , INST_DT
                  , INST_USER
                  , UPD_DT
                  , UPD_USER
                   )
                VALUES
                   (   
                    PSV_COMP_CD
                  , MYREC.PRMT_ID
                  , CASE WHEN MYREC.COUPON_NOTICE_PRINT = 'Y' OR MYREC.COUPON_NOTICE_PRINT = 'Y' THEN '1' ELSE '0' END
                  , 'N'
                  , 'N'
                  , 'N'
                  , 'N'
                  , 'Y'
                  , SYSDATE
                  , 'SYS'
                  , SYSDATE
                  , 'SYS'
                   );

            -- 영수증 메시지       
            MERGE INTO C_PROMOTION_BILL_MSG
            USING DUAL
            ON (
                    COMP_CD      = PSV_COMP_CD
                AND PRMT_ID      = MYREC.PRMT_ID
                AND BILL_MSG_DIV = '4'  -- 유의사항
               )
            WHEN MATCHED THEN
                UPDATE
                SET BILL_MSG = MYREC.COUPON_NOTICE
                  , USE_YN   = CASE WHEN MYREC.COUPON_NOTICE_PRINT = 'Y' THEN 'Y' ELSE 'N' END
                  , UPD_DT   = SYSDATE 
                  , UPD_USER = 'SYS'
            WHEN NOT MATCHED THEN
                INSERT
                   (
                    COMP_CD
                  , PRMT_ID
                  , BILL_MSG_DIV
                  , BILL_MSG
                  , USE_YN
                  , INST_DT
                  , INST_USER
                  , UPD_DT
                  , UPD_USER
                   )
                VALUES
                   (   
                    PSV_COMP_CD
                  , MYREC.PRMT_ID
                  , '4'
                  , MYREC.COUPON_NOTICE
                  , CASE WHEN MYREC.COUPON_NOTICE_PRINT = 'Y' THEN 'Y' ELSE 'N' END
                  , SYSDATE
                  , 'SYS'
                  , SYSDATE
                  , 'SYS'
                   );

            -- 영수증 메시지       
            MERGE INTO C_PROMOTION_BILL_MSG
            USING DUAL
            ON (
                    COMP_CD      = PSV_COMP_CD
                AND PRMT_ID      = MYREC.PRMT_ID
                AND BILL_MSG_DIV = '5'  -- 비고
               )
            WHEN MATCHED THEN
                UPDATE
                SET BILL_MSG = MYREC.REMARKS
                  , USE_YN   = CASE WHEN MYREC.REMARKS_PRINT = 'Y' THEN 'Y' ELSE 'N' END
                  , UPD_DT   = SYSDATE 
                  , UPD_USER = 'SYS'
            WHEN NOT MATCHED THEN
                INSERT
                   (
                    COMP_CD
                  , PRMT_ID
                  , BILL_MSG_DIV
                  , BILL_MSG
                  , USE_YN
                  , INST_DT
                  , INST_USER
                  , UPD_DT
                  , UPD_USER
                   )
                VALUES
                   (   
                    PSV_COMP_CD
                  , MYREC.PRMT_ID
                  , '5'
                  , MYREC.REMARKS
                  , CASE WHEN MYREC.REMARKS_PRINT = 'Y' THEN 'Y' ELSE 'N' END
                  , SYSDATE
                  , 'SYS'
                  , SYSDATE
                  , 'SYS'
                   );
        END LOOP;

        PR_RETURN_MSG   := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001392'); -- 정상처리 되었습니다.

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            PR_RETURN_CD  := '9999';
            PR_RETURN_MSG := SQLERRM;

            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;

            RETURN;
    END;

            -- 프로모션 정보 취득 영수증
    PROCEDURE SP_GET_PROMOTION_02
    ( 
        PSV_COMP_CD     IN  VARCHAR2,   -- 회사코드
        PSV_LANGUAGE    IN  VARCHAR2,   -- 언어코드
        PSV_UPD_DT      IN  VARCHAR2,   -- 최종갱신일자
        PSV_CUR_DT      IN  VARCHAR2,   -- 현재일자
        PR_RETURN_CD    OUT VARCHAR2,   -- 메세지코드
        PR_RETURN_MSG   OUT VARCHAR2    -- 메세지
    ) IS
        -- 프로모션 영수증
        CURSOR CUR_1 IS
            SELECT  *
            FROM    PROMOTION_PRINT@HCRM
            WHERE   UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS')
            AND     UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS');

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PR_RETURN_CD    := '0000';
        PR_RETURN_MSG   := 'OK';

          --영수증 이벤트
          FOR MYREC IN CUR_1 LOOP
              -- 영수증 메시지
              MERGE INTO C_PROMOTION_BILL
              USING DUAL
              ON (
                      COMP_CD = PSV_COMP_CD
                  AND PRMT_ID = MYREC.PRMT_ID
                 )
              WHEN MATCHED THEN
                  UPDATE
                  SET PRT_TYPE1 = '1'
                    , PRT_TYPE2 = MYREC.REUSE_YN
                    , PRT_TYPE3 = MYREC.PRINT_TYPE_1
                    , PRT_TYPE4 = MYREC.PRINT_TYPE_2
                    , PRT_TYPE5 = MYREC.PRINT_TYPE_3
                    , UPD_DT    = SYSDATE 
                    , UPD_USER  = 'SYS'
              WHEN NOT MATCHED THEN
                  INSERT
                     (
                      COMP_CD
                    , PRMT_ID
                    , PRT_TYPE1
                    , PRT_TYPE2
                    , PRT_TYPE3
                    , PRT_TYPE4
                    , PRT_TYPE5
                    , USE_YN
                    , INST_DT
                    , INST_USER
                    , UPD_DT
                    , UPD_USER
                     )
                  VALUES
                     (   
                      PSV_COMP_CD
                    , MYREC.PRMT_ID
                    , '1'
                    , MYREC.REUSE_YN
                    , MYREC.PRINT_TYPE_1
                    , MYREC.PRINT_TYPE_2
                    , MYREC.PRINT_TYPE_3
                    , 'Y'
                    , SYSDATE
                    , 'SYS'
                    , SYSDATE
                    , 'SYS'
                     );

              -- 영수증 메시지(상단)
              MERGE INTO C_PROMOTION_BILL_MSG
              USING DUAL
              ON (
                      COMP_CD      = PSV_COMP_CD
                  AND PRMT_ID      = MYREC.PRMT_ID
                  AND BILL_MSG_DIV = '1'  -- 상단
                 )
              WHEN MATCHED THEN
                  UPDATE
                  SET BILL_MSG = MYREC.PREFACE
                    , USE_YN   = CASE WHEN MYREC.PREFACE IS NOT NULL THEN 'Y' ELSE 'N' END
                    , UPD_DT   = SYSDATE 
                    , UPD_USER = 'SYS'
              WHEN NOT MATCHED THEN
                  INSERT
                     (
                      COMP_CD
                    , PRMT_ID
                    , BILL_MSG_DIV
                    , BILL_MSG
                    , USE_YN
                    , INST_DT
                    , INST_USER
                    , UPD_DT
                    , UPD_USER
                     )
                  VALUES
                     (   
                      PSV_COMP_CD
                    , MYREC.PRMT_ID
                    , '1'
                    , MYREC.PREFACE
                    , CASE WHEN MYREC.PREFACE IS NOT NULL THEN 'Y' ELSE 'N' END
                    , SYSDATE
                    , 'SYS'
                    , SYSDATE
                    , 'SYS'
                     );

              -- 영수증 메시지(중단)    
              MERGE INTO C_PROMOTION_BILL_MSG
              USING DUAL
              ON (
                      COMP_CD      = PSV_COMP_CD
                  AND PRMT_ID      = MYREC.PRMT_ID
                  AND BILL_MSG_DIV = '2'  -- 중단
                 )
              WHEN MATCHED THEN
                  UPDATE
                  SET BILL_MSG = MYREC.MAIN_TEXT
                    , USE_YN   = CASE WHEN MYREC.MAIN_TEXT IS NOT NULL THEN 'Y' ELSE 'N' END
                    , UPD_DT   = SYSDATE 
                    , UPD_USER = 'SYS'
              WHEN NOT MATCHED THEN
                  INSERT
                     (
                      COMP_CD
                    , PRMT_ID
                    , BILL_MSG_DIV
                    , BILL_MSG
                    , USE_YN
                    , INST_DT
                    , INST_USER
                    , UPD_DT
                    , UPD_USER
                     )
                  VALUES
                     (   
                      PSV_COMP_CD
                    , MYREC.PRMT_ID
                    , '2'
                    , MYREC.MAIN_TEXT
                    , CASE WHEN MYREC.MAIN_TEXT IS NOT NULL THEN 'Y' ELSE 'N' END
                    , SYSDATE
                    , 'SYS'
                    , SYSDATE
                    , 'SYS'
                     );

              -- 영수증 메시지(하단)    
              MERGE INTO C_PROMOTION_BILL_MSG
              USING DUAL
              ON (
                      COMP_CD      = PSV_COMP_CD
                  AND PRMT_ID      = MYREC.PRMT_ID
                  AND BILL_MSG_DIV = '3'  -- 하단
                 )
              WHEN MATCHED THEN
                  UPDATE
                  SET BILL_MSG = MYREC.FOOTER
                    , USE_YN   = CASE WHEN MYREC.FOOTER IS NOT NULL THEN 'Y' ELSE 'N' END
                    , UPD_DT   = SYSDATE 
                    , UPD_USER = 'SYS'
              WHEN NOT MATCHED THEN
                  INSERT
                     (
                      COMP_CD
                    , PRMT_ID
                    , BILL_MSG_DIV
                    , BILL_MSG
                    , USE_YN
                    , INST_DT
                    , INST_USER
                    , UPD_DT
                    , UPD_USER
                     )
                  VALUES
                     (   
                      PSV_COMP_CD
                    , MYREC.PRMT_ID
                    , '3'
                    , MYREC.FOOTER
                    , CASE WHEN MYREC.FOOTER IS NOT NULL THEN 'Y' ELSE 'N' END
                    , SYSDATE
                    , 'SYS'
                    , SYSDATE
                    , 'SYS'
                     );

              -- 프로모션 마스터 갱신(프로모션과 영수증 연결정보)
              MERGE INTO C_PROMOTION_MST
              USING DUAL
              ON (    
                      COMP_CD = PSV_COMP_CD
                  AND PRMT_ID = MYREC.PRMT_ID
                 )
              WHEN MATCHED THEN
                  UPDATE
                  SET CUST_DIV      = CASE WHEN MYREC.PRINT_TARGET = 'C6101' THEN '1'
                                           WHEN MYREC.PRINT_TARGET = 'C6102' THEN '2'
                                           WHEN MYREC.PRINT_TARGET = 'C6103' THEN '3'
                                           ELSE CUST_DIV
                                      END
                    , PAY_DIV       = CASE WHEN MYREC.PAY_METHOD IS NOT NULL THEN MYREC.PAY_METHOD
                                           ELSE PAY_DIV
                                      END
                    , APPL_DIV      = CASE WHEN MYREC.RECEIPT_TYPE = 'C6301' THEN '1'
                                           WHEN MYREC.RECEIPT_TYPE = 'C6302' THEN '2'
                                           WHEN MYREC.RECEIPT_TYPE = 'C6303' THEN '2'
                                           ELSE APPL_DIV
                                      END
                    , BILL_CUST_CNT = CASE WHEN NVL(MYREC.BILL_COUNT, 0) != 0 THEN MYREC.BILL_COUNT
                                           ELSE BILL_CUST_CNT
                                      END
                    , ITEM_QTY1     = CASE WHEN NVL(MYREC.MENU_COUNT, 0) != 0 THEN MYREC.MENU_COUNT
                                           ELSE ITEM_QTY1
                                      END;
          END LOOP;

        PR_RETURN_MSG   := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001392'); -- 정상처리 되었습니다.

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            PR_RETURN_CD  := '9999';
            PR_RETURN_MSG := SQLERRM;

            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

            RETURN;
    END;

    -- 프로모션 정보 취득 매장
    PROCEDURE SP_GET_PROMOTION_03
    ( 
        PSV_COMP_CD     IN  VARCHAR2,   -- 회사코드
        PSV_LANGUAGE    IN  VARCHAR2,   -- 언어코드
        PSV_UPD_DT      IN  VARCHAR2,   -- 최종갱신일자
        PSV_CUR_DT      IN  VARCHAR2,   -- 현재일자
        PR_RETURN_CD    OUT VARCHAR2,   -- 메세지코드
        PR_RETURN_MSG   OUT VARCHAR2    -- 메세지
    ) IS
        -- 프로모션 매장
        CURSOR CUR_1 IS
            WITH W1 AS 
           (
            SELECT  PRMT_ID
                  , STOR_CD
            FROM    PROMOTION_STOR@HCRM
            WHERE   UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS')
            AND     UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS')
            UNION
            SELECT  PSG.PRMT_ID
                  , SGS.STOR_CD
            FROM    PROMOTION_STOR_GP@HCRM PSG
                 ,  STORE_GP_IN_STORE@HCRM SGS
            WHERE   PSG.STOR_GP_ID = SGS.STOR_GP_ID
            AND   (
                   (PSG.UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS') AND PSG.UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS'))
                    OR
                   (SGS.UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS') AND SGS.UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS'))
                  )
          )
            SELECT  *
            FROM   (
                    SELECT  PRMT_ID
                          , STOR_CD
                          , STOR_GP_ID
                          , USE_YN
                          , ROW_NUMBER() OVER(PARTITION BY PRMT_ID, STOR_CD ORDER BY DATA_DIV) R_NUM
                    FROM   (      
                            SELECT  PS.PRMT_ID
                                  , PS.STOR_CD
                                  , PS.STOR_GP_ID
                                  , PS.USE_YN
                                  , '1' DATA_DIV
                            FROM    PROMOTION_STOR@HCRM PS
                                  , W1                  W1
                            WHERE   W1.PRMT_ID = PS.PRMT_ID
                            AND     W1.STOR_CD = PS.STOR_CD
                            UNION ALL
                            SELECT  PS.PRMT_ID
                                  , SG.STOR_CD
                                  , PS.STOR_GP_ID
                                  , CASE WHEN PS.USE_YN = 'N' THEN PS.USE_YN ELSE SG.USE_YN END USE_YN
                                  , '2' DATA_DIV
                            FROM    PROMOTION_STOR_GP@HCRM PS
                                 ,  STORE_GP_IN_STORE@HCRM SG
                                 ,  W1                     W1
                            WHERE  W1.PRMT_ID    = PS.PRMT_ID
                            AND    W1.STOR_CD    = SG.STOR_CD
                            AND    PS.STOR_GP_ID = SG.STOR_GP_ID
                           )
                   )
           WHERE    R_NUM = 1;
    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PR_RETURN_CD    := '0000';
        PR_RETURN_MSG   := 'OK';

        FOR MYREC IN CUR_1 LOOP
            MERGE INTO C_PROMOTION_STORE CPS
            USING  (
                    SELECT  COMP_CD
                          , BRAND_CD
                          , PRMT_ID
                    FROM    C_PROMOTION_MST
                    WHERE   COMP_CD  = PSV_COMP_CD
                    AND     PRMT_ID  = MYREC.PRMT_ID
                   ) MST
            ON (    
                    CPS.COMP_CD  = MST.COMP_CD
                AND CPS.PRMT_ID  = MST.PRMT_ID
                AND CPS.BRAND_CD = MST.BRAND_CD
                AND CPS.STOR_CD  = MYREC.STOR_CD
               )
            WHEN MATCHED THEN
                UPDATE
                SET USE_YN   = MYREC.USE_YN
                  , UPD_DT   = SYSDATE 
                  , UPD_USER = 'SYS'
            WHEN NOT MATCHED THEN
                INSERT
               (
                COMP_CD
              , PRMT_ID
              , BRAND_CD
              , STOR_CD
              , USE_YN
              , INST_DT
              , INST_USER
              , UPD_DT
              , UPD_USER
               )
                VALUES
               (
                MST.COMP_CD
              , MST.PRMT_ID
              , MST.BRAND_CD
              , MYREC.STOR_CD
              , MYREC.USE_YN
              , SYSDATE
              , 'SYS'
              , SYSDATE
              , 'SYS'
               );
        END LOOP;

        PR_RETURN_MSG   := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001392'); -- 정상처리 되었습니다.

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            PR_RETURN_CD  := '9999';
            PR_RETURN_MSG := SQLERRM;

            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

            ROLLBACK;
            RETURN;
    END;

    -- 프로모션 정보 취득
    PROCEDURE SP_GET_PROMOTION_04
    ( 
        PSV_COMP_CD     IN  VARCHAR2,   -- 회사코드
        PSV_LANGUAGE    IN  VARCHAR2,   -- 언어코드
        PSV_UPD_DT      IN  VARCHAR2,   -- 최종갱신일자
        PSV_CUR_DT      IN  VARCHAR2,   -- 현재일자
        PR_RETURN_CD    OUT VARCHAR2,   -- 메세지코드
        PR_RETURN_MSG   OUT VARCHAR2    -- 메세지
    ) IS
        -- 프로모션 대상 아이템
        CURSOR CUR_1 IS
            WITH W1 AS 
           (
            SELECT  PRMT_ID
                  , ITEM_DIV
                  , ITEM_CD
            FROM    PROMOTION_TARGET_MN@HCRM
            WHERE   UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS')
            AND     UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS')
            UNION
            SELECT  PT.PRMT_ID
                  , PT.ITEM_DIV
                  , IT.ITEM_CD
            FROM    ITEM                        IT
                 ,  PROMOTION_TARGET_MN_GP@HCRM PT
            WHERE   IT.L_CLASS_CD = PT.L_CLASS_CD
            AND     IT.M_CLASS_CD = PT.M_CLASS_CD
            AND     IT.S_CLASS_CD = PT.S_CLASS_CD
            AND     IT.D_CLASS_CD = PT.D_CLASS_CD
            AND     IT.COMP_CD    = PSV_COMP_CD
            AND   (
                   (IT.UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS') AND IT.UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS'))
                    OR
                   (PT.UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS') AND PT.UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS'))
                  )
          )
            SELECT  *
            FROM   (
                    SELECT  PRMT_ID
                          , ITEM_DIV
                          , ITEM_CD
                          , QTY
                          , USE_YN
                          , ROW_NUMBER() OVER(PARTITION BY PRMT_ID, ITEM_DIV, ITEM_CD ORDER BY DATA_DIV) R_NUM
                    FROM   (      
                            SELECT  PT.PRMT_ID
                                  , PT.ITEM_DIV
                                  , PT.ITEM_CD
                                  , PT.QTY
                                  , PT.USE_YN
                                  , '1' DATA_DIV
                            FROM    PROMOTION_TARGET_MN@HCRM PT
                                  , W1                       W1
                            WHERE   W1.PRMT_ID  = PT.PRMT_ID
                            AND     W1.ITEM_DIV = PT.ITEM_DIV
                            AND     W1.ITEM_CD  = PT.ITEM_CD
                            UNION ALL
                            SELECT  PT.PRMT_ID
                                  , W1.ITEM_DIV
                                  , W1.ITEM_CD
                                  , PT.QTY
                                  , CASE WHEN PT.USE_YN = 'N' THEN PT.USE_YN ELSE IT.USE_YN END USE_YN
                                  , '2' DATA_DIV
                            FROM    ITEM                        IT
                                 ,  PROMOTION_TARGET_MN_GP@HCRM PT
                                 ,  W1                          W1
                            WHERE   W1.PRMT_ID    = PT.PRMT_ID
                            AND     W1.ITEM_DIV   = PT.ITEM_DIV
                            AND     W1.ITEM_CD    = IT.ITEM_CD
                            AND     IT.L_CLASS_CD = PT.L_CLASS_CD
                            AND     IT.M_CLASS_CD = PT.M_CLASS_CD
                            AND     IT.S_CLASS_CD = PT.S_CLASS_CD
                            AND     IT.D_CLASS_CD = PT.D_CLASS_CD
                            AND     IT.COMP_CD    = PSV_COMP_CD
                           )
                   )
           WHERE    R_NUM = 1;

            -- 프로모션 혜택 아이템
        CURSOR CUR_2 IS
            WITH W1 AS 
           (
            SELECT  PRMT_ID
                  , ITEM_CD
            FROM    PROMOTION_BNFIT_MN@HCRM
            WHERE   UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS')
            AND     UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS')
            UNION
            SELECT  PT.PRMT_ID
                  , IT.ITEM_CD
            FROM    ITEM                        IT
                 ,  PROMOTION_BNFIT_MN_GP@HCRM  PT
            WHERE   IT.L_CLASS_CD = PT.L_CLASS_CD
            AND     IT.M_CLASS_CD = PT.M_CLASS_CD
            AND     IT.S_CLASS_CD = PT.S_CLASS_CD
            AND     IT.D_CLASS_CD = PT.D_CLASS_CD
            AND     IT.COMP_CD    = PSV_COMP_CD
            AND   (
                   (IT.UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS') AND IT.UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS'))
                    OR
                   (PT.UPD_DT >= TO_DATE(PSV_UPD_DT, 'YYYYMMDDHH24MISS') AND PT.UPD_DT <  TO_DATE(PSV_CUR_DT, 'YYYYMMDDHH24MISS'))
                  )
          )
            SELECT  *
            FROM   (
                    SELECT  PRMT_ID
                          , ITEM_CD
                          , BNFIT_DIV
                          , QTY
                          , SALE_PRC
                          , GIVE_REWARD
                          , USE_YN
                          , ROW_NUMBER() OVER(PARTITION BY PRMT_ID, ITEM_CD ORDER BY DATA_DIV) R_NUM
                    FROM   (      
                            SELECT  PT.PRMT_ID
                                  , PT.ITEM_CD
                                  , PT.BNFIT_DIV
                                  , PT.QTY
                                  , PT.SALE_PRC
                                  , PT.GIVE_REWARD
                                  , PT.USE_YN
                                  , '1' DATA_DIV
                            FROM    PROMOTION_BNFIT_MN@HCRM PT
                                  , W1                       W1
                            WHERE   W1.PRMT_ID  = PT.PRMT_ID
                            AND     W1.ITEM_CD  = PT.ITEM_CD
                            UNION ALL
                            SELECT  PT.PRMT_ID
                                  , W1.ITEM_CD
                                  , PT.BNFIT_DIV
                                  , PT.QTY
                                  , PT.SALE_PRC
                                  , PT.GIVE_REWARD
                                  , CASE WHEN PT.USE_YN = 'N' THEN PT.USE_YN ELSE IT.USE_YN END USE_YN
                                  , '2' DATA_DIV
                            FROM    ITEM                       IT
                                 ,  PROMOTION_BNFIT_MN_GP@HCRM PT
                                 ,  W1                         W1
                            WHERE   W1.PRMT_ID    = PT.PRMT_ID
                            AND     W1.ITEM_CD    = IT.ITEM_CD
                            AND     IT.L_CLASS_CD = PT.L_CLASS_CD
                            AND     IT.M_CLASS_CD = PT.M_CLASS_CD
                            AND     IT.S_CLASS_CD = PT.S_CLASS_CD
                            AND     IT.D_CLASS_CD = PT.D_CLASS_CD
                            AND     IT.COMP_CD    = PSV_COMP_CD
                           )
                   )
           WHERE    R_NUM = 1;
    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PR_RETURN_CD    := '0000';
        PR_RETURN_MSG   := 'OK';

        -- 프로모션 조건 아이템
        FOR MYREC1 IN CUR_1 LOOP
            MERGE INTO C_PROMOTION_ITEM_COND CPI
            USING  (
                    SELECT  COMP_CD
                          , BRAND_CD
                          , PRMT_ID
                    FROM    C_PROMOTION_MST
                    WHERE   COMP_CD  = PSV_COMP_CD
                    AND     PRMT_ID  = MYREC1.PRMT_ID
                   ) MST
            ON (    
                    CPI.COMP_CD  = MST.COMP_CD
                AND CPI.PRMT_ID  = MST.PRMT_ID
                AND CPI.ITEM_COND= MYREC1.ITEM_DIV
                AND CPI.BRAND_CD = MST.BRAND_CD
                AND CPI.ITEM_CD  = MYREC1.ITEM_CD
               )
            WHEN MATCHED THEN
                UPDATE
                SET ITEM_QTY = NVL(MYREC1.QTY, 0)
                  , USE_YN   = MYREC1.USE_YN
                  , UPD_DT   = SYSDATE 
                  , UPD_USER = 'SYS'
            WHEN NOT MATCHED THEN
                INSERT
               (
                COMP_CD
              , PRMT_ID
              , ITEM_COND
              , BRAND_CD
              , ITEM_CD
              , ITEM_QTY
              , USE_YN
              , INST_DT
              , INST_USER
              , UPD_DT
              , UPD_USER
               )
                VALUES
               (
                MST.COMP_CD
              , MST.PRMT_ID
              , MYREC1.ITEM_DIV
              , MST.BRAND_CD
              , MYREC1.ITEM_CD
              , NVL(MYREC1.QTY, 0)
              , MYREC1.USE_YN
              , SYSDATE
              , 'SYS'
              , SYSDATE
              , 'SYS'
               );
        END LOOP;

        -- 프로모션 혜택 아이템
        FOR MYREC2 IN CUR_2 LOOP
            MERGE INTO C_PROMOTION_ITEM CPI
            USING  (
                    SELECT  COMP_CD
                          , BRAND_CD
                          , PRMT_ID
                    FROM    C_PROMOTION_MST
                    WHERE   COMP_CD  = PSV_COMP_CD
                    AND     PRMT_ID  = MYREC2.PRMT_ID
                   ) MST
            ON (    
                    CPI.COMP_CD  = MST.COMP_CD
                AND CPI.PRMT_ID  = MST.PRMT_ID
                AND CPI.BRAND_CD = MST.BRAND_CD
                AND CPI.ITEM_CD  = MYREC2.ITEM_CD
               )
            WHEN MATCHED THEN
                UPDATE
                SET BNF_FG      = CASE WHEN MYREC2.BNFIT_DIV = 'P0201' THEN '4'
                                       WHEN MYREC2.BNFIT_DIV = 'P0202' THEN '2'
                                       ELSE NULL
                                  END
                  , BNF_VALUE   = CASE WHEN MYREC2.BNFIT_DIV = 'P0201' THEN MYREC2.QTY
                                       WHEN MYREC2.BNFIT_DIV = 'P0202' THEN MYREC2.SALE_PRC
                                       ELSE NULL
                                  END
                  , GIVE_REWARD = MYREC2.GIVE_REWARD
                  , USE_YN      = MYREC2.USE_YN
                  , UPD_DT      = SYSDATE 
                  , UPD_USER    = 'SYS'
            WHEN NOT MATCHED THEN
                INSERT
               (
                COMP_CD
              , PRMT_ID
              , BRAND_CD
              , ITEM_CD
              , BNF_FG
              , BNF_VALUE
              , GIVE_REWARD
              , MEMB_YN
              , USE_YN
              , INST_DT
              , INST_USER
              , UPD_DT
              , UPD_USER
               )
                VALUES
               (
                MST.COMP_CD
              , MST.PRMT_ID
              , MST.BRAND_CD
              , MYREC2.ITEM_CD
              , CASE WHEN MYREC2.BNFIT_DIV = 'P0201' THEN '4'
                     WHEN MYREC2.BNFIT_DIV = 'P0202' THEN '2'
                     ELSE NULL
                END
              , CASE WHEN MYREC2.BNFIT_DIV = 'P0201' THEN MYREC2.QTY
                     WHEN MYREC2.BNFIT_DIV = 'P0202' THEN MYREC2.SALE_PRC
                     ELSE NULL
                END
              , MYREC2.GIVE_REWARD
              , 'Y'
              , MYREC2.USE_YN
              , SYSDATE
              , 'SYS'
              , SYSDATE
              , 'SYS'
               );
        END LOOP;

        PR_RETURN_MSG   := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001392'); -- 정상처리 되었습니다.

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            PR_RETURN_CD  := '9999';
            PR_RETURN_MSG := SQLERRM;

            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

            ROLLBACK;
            RETURN;
    END;
END PKG_CRM_IF;

/
