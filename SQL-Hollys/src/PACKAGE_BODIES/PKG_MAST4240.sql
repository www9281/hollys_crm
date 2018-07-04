--------------------------------------------------------
--  DDL for Package Body PKG_MAST4240
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MAST4240" AS

    PROCEDURE SP_ITEM_CHAIN_HIS_UPD
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 1.회사코드
        PSV_USER_ID     IN  VARCHAR2 ,                -- 2.사용자
        PSV_LANG_CD     IN  VARCHAR2 ,                -- 3.Language Code
        PSV_BRAND_CD    IN  VARCHAR2 ,                -- 4.영업조직
        PSV_STOR_TP     IN  VARCHAR2 ,                -- 5.직가맹
        PSV_ITEM_CD     IN  VARCHAR2 ,                -- 6.상품코드
        PSV_START_DT    IN  VARCHAR2 ,                -- 7.시작일자
        PSV_CLOSE_DT    IN  VARCHAR2 ,                -- 8.종료일자
        PSV_SALE_PRC    IN  VARCHAR2 ,                -- 9.판매단가
        PSV_USE_YN      IN  VARCHAR2 ,                -- 11.사용유무
        PR_RTN_CD       OUT VARCHAR2 ,                -- 12.처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 13.처리Message
    ) IS
    /******************************************************************************
        NAME:       SP_TAB03_ITEM_HIS_CHG      아이템 변경 이력 수정
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-11-02         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   PKG_MAST4240.SP_ITEM_CHAIN_HIS_UPD
            SYSDATE     :   2017-11-02
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
        nCOST           ITEM.COST%TYPE;
        vORD_SALE_DIV   ITEM.ORD_SALE_DIV%TYPE;
    BEGIN
        SELECT  ITM.ORD_SALE_DIV, HIS.COST 
        INTO    vORD_SALE_DIV   , nCOST
        FROM    ITEM_CHAIN_HIS HIS
              , ITEM           ITM
        WHERE   HIS.COMP_CD     = ITM.COMP_CD
        AND     HIS.ITEM_CD     = ITM.ITEM_CD
        AND     HIS.COMP_CD     = PSV_COMP_CD
        AND     HIS.BRAND_CD    = PSV_BRAND_CD
        AND     HIS.STOR_TP     = PSV_STOR_TP
        AND     HIS.ITEM_CD     = PSV_ITEM_CD
        AND     PSV_START_DT BETWEEN HIS.START_DT AND NVL(HIS.CLOSE_DT, '99991231')
        AND     HIS.USE_YN      = 'Y'
        AND     ROWNUM          = 1;

        -- 사용구분(3:판매용)만 가능 그외 SKIP
        IF vORD_SALE_DIV = '3' THEN         
            /* 현재 사용기간에 포함된 판매단가이력 사용 종료 처리 */
            UPDATE ITEM_CHAIN_HIS
            SET     CLOSE_DT  = TO_CHAR(TO_DATE(PSV_START_DT, 'YYYYMMDD') - 1, 'YYYYMMDD')
            WHERE   COMP_CD   = PSV_COMP_CD
            AND     BRAND_CD  = PSV_BRAND_CD
            AND     STOR_TP   = PSV_STOR_TP
            AND     ITEM_CD   = PSV_ITEM_CD
            AND     START_DT  < PSV_START_DT
            AND     CLOSE_DT >= PSV_START_DT
            AND     USE_YN    = 'Y';

            /* 미래일자 판매단가이력 미사용 처리 */
            UPDATE ITEM_CHAIN_HIS
            SET     USE_YN    = 'N'
            WHERE   COMP_CD   = PSV_COMP_CD
            AND     BRAND_CD  = PSV_BRAND_CD
            AND     STOR_TP   = PSV_STOR_TP
            AND     ITEM_CD   = PSV_ITEM_CD
            AND     START_DT  > PSV_START_DT
            AND     USE_YN    = 'Y';

            /* 기준일자 판매단가 이력 작성 */
            MERGE INTO ITEM_CHAIN_HIS HIS
            USING  DUAL
            ON (
                    HIS.COMP_CD     = PSV_COMP_CD
                AND HIS.BRAND_CD    = PSV_BRAND_CD
                AND HIS.STOR_TP     = PSV_STOR_TP
                AND HIS.ITEM_CD     = PSV_ITEM_CD
                AND HIS.START_DT    = PSV_START_DT
               )
            WHEN MATCHED THEN
                UPDATE  
                SET CLOSE_DT    = PSV_CLOSE_DT
                  , SALE_PRC    = TO_NUMBER(PSV_SALE_PRC)
                  , COST        = nCOST
                  , USE_YN      = PSV_USE_YN
                  , UPD_DT      = SYSDATE
                  , UPD_USER    = PSV_USER_ID
            WHEN NOT MATCHED THEN
                INSERT   
                   (          
                    COMP_CD
                  , BRAND_CD
                  , STOR_TP
                  , ITEM_CD
                  , START_DT
                  , CLOSE_DT
                  , SALE_PRC
                  , COST
                  , USE_YN 
                  , INST_DT
                  , INST_USER
                  , UPD_DT
                  , UPD_USER
                   ) 
                VALUES 
                   (
                    PSV_COMP_CD
                  , PSV_BRAND_CD
                  , PSV_STOR_TP
                  , PSV_ITEM_CD
                  , PSV_START_DT
                  , PSV_CLOSE_DT
                  , TO_NUMBER(PSV_SALE_PRC)
                  , nCOST
                  , 'Y'
                  , SYSDATE
                  , PSV_USER_ID
                  , SYSDATE
                  , PSV_USER_ID
                   );
        END IF;

        PR_RTN_CD  := '0';
        PR_RTN_MSG := '';

        COMMIT;

        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;

            ROLLBACK;
            RETURN;
    END;

    PROCEDURE SP_ITEM_STORE_UPD
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 1.회사코드
        PSV_USER_ID     IN  VARCHAR2 ,                -- 2.사용자
        PSV_LANG_CD     IN  VARCHAR2 ,                -- 3.Language Code
        PSV_BRAND_CD    IN  VARCHAR2 ,                -- 4.영업조직
        PSV_STOR_CD     IN  VARCHAR2 ,                -- 5.매장코드
        PSV_ITEM_CD     IN  VARCHAR2 ,                -- 6.상품코드
        PSV_START_DT    IN  VARCHAR2 ,                -- 7.시작일자
        PSV_CLOSE_DT    IN  VARCHAR2 ,                -- 8.종료일자
        PSV_SALE_PRC    IN  VARCHAR2 ,                -- 9.판매단가
        PSV_USE_YN      IN  VARCHAR2 ,                -- 11.사용유무
        PR_RTN_CD       OUT VARCHAR2 ,                -- 12.처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 13.처리Message
    ) IS
    /******************************************************************************
        NAME:       SP_TAB03_ITEM_HIS_CHG      아이템 변경 이력 수정
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-11-02         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   PKG_MAST4240.SP_ITEM_CHAIN_HIS_UPD
            SYSDATE     :   2017-11-02
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
        nCOST           ITEM.COST%TYPE;
        vORD_SALE_DIV   ITEM.ORD_SALE_DIV%TYPE;
    BEGIN
        SELECT  ITM.ORD_SALE_DIV INTO vORD_SALE_DIV
        FROM    ITEM           ITM
        WHERE   ITM.COMP_CD     = PSV_COMP_CD
        AND     ITM.ITEM_CD     = PSV_ITEM_CD
        AND     ITM.USE_YN      = 'Y';

        IF vORD_SALE_DIV ='3' THEN
            /* 현재 사용기간에 포함된 점포별 판매단가이력 사용 종료 처리 */
            UPDATE  ITEM_STORE
            SET     CLOSE_DT  = TO_CHAR(TO_DATE(PSV_START_DT, 'YYYYMMDD') - 1, 'YYYYMMDD')
            WHERE   COMP_CD   = PSV_COMP_CD
            AND     BRAND_CD  = PSV_BRAND_CD
            AND     STOR_CD   = PSV_STOR_CD
            AND     ITEM_CD   = PSV_ITEM_CD
            AND     PRC_DIV    ='02'
            AND     START_DT  < PSV_START_DT
            AND     CLOSE_DT >= PSV_START_DT
            AND     USE_YN    = 'Y';

            /* 미래일자 점포별 판매단가이력 미사용 처리 */
            UPDATE  ITEM_STORE
            SET     USE_YN    = 'N'
            WHERE   COMP_CD   = PSV_COMP_CD
            AND     BRAND_CD  = PSV_BRAND_CD
            AND     STOR_CD   = PSV_STOR_CD
            AND     ITEM_CD   = PSV_ITEM_CD
            AND     PRC_DIV    ='02'
            AND     START_DT  > PSV_START_DT
            AND     USE_YN    = 'Y';

            /* 기준일자 판매단가 이력 작성 */
            MERGE INTO ITEM_STORE
            USING DUAL
            ON (
                    COMP_CD     = PSV_COMP_CD
                AND BRAND_CD    = PSV_BRAND_CD
                AND STOR_CD     = PSV_STOR_CD
                AND ITEM_CD     = PSV_ITEM_CD
                AND PRC_DIV     = '02'
                AND START_DT    = PSV_START_DT
               )
            WHEN MATCHED THEN
                UPDATE  
                SET CLOSE_DT    = PSV_CLOSE_DT
                  , PRICE       = TO_NUMBER(PSV_SALE_PRC)
                  , USE_YN      = PSV_USE_YN
                  , UPD_DT      = SYSDATE
                  , UPD_USER    = PSV_USER_ID
            WHEN NOT MATCHED THEN
                INSERT   
                   (          
                    COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , ITEM_CD
                  , PRC_DIV
                  , START_DT
                  , CLOSE_DT
                  , PRICE
                  , VENDOR_CD
                  , USE_YN 
                  , INST_DT
                  , INST_USER
                  , UPD_DT
                  , UPD_USER
                   ) 
                VALUES 
                   (
                    PSV_COMP_CD
                  , PSV_BRAND_CD
                  , PSV_STOR_CD
                  , PSV_ITEM_CD
                  , '02'
                  , PSV_START_DT
                  , PSV_CLOSE_DT
                  , TO_NUMBER(PSV_SALE_PRC)
                  , NULL
                  , 'Y'
                  , SYSDATE
                  , PSV_USER_ID
                  , SYSDATE
                  , PSV_USER_ID
                   );
        END IF;

        PR_RTN_CD  := '0';
        PR_RTN_MSG := '';

        COMMIT;

        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;

            ROLLBACK;
            RETURN;
    END;
END PKG_MAST4240;

/
