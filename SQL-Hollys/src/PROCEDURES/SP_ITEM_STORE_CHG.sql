--------------------------------------------------------
--  DDL for Procedure SP_ITEM_STORE_CHG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ITEM_STORE_CHG" 
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER_ID     IN  VARCHAR2 ,                -- 사용자
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_BRAND_CD    IN  VARCHAR2 ,                -- 영업조직
        PSV_STOR_CD     IN  VARCHAR2 ,                -- 매장코드/거래처
        PSV_PRC_DIV     IN  VARCHAR2 ,                -- 단가구분[01:매입단가, 02:판매단가]
        PSV_ITEM_CD     IN  VARCHAR2 ,                -- 상품코드
        PSV_START_DT    IN  VARCHAR2 ,                -- 시작일자
        PSV_CLOSE_DT    IN  VARCHAR2 ,                -- 종료일자
        PSV_PRICE       IN  VARCHAR2 ,                -- 판매가격
        PSV_USE_YN      IN  VARCHAR2 ,                -- 사용유무
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       ITEM_STORE      아이템 STORE 이력 수정
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-05-06         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB03_ITEM_HIS_CHG
            SYSDATE     :   2016-05-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
        TYPE TPY_LAST_ITEM_HIS IS RECORD
        (
            COMP_CD         ITEM_STORE.COMP_CD%TYPE,
            BRAND_CD        ITEM_STORE.BRAND_CD%TYPE,
            STOR_CD         ITEM_STORE.STOR_CD%TYPE,
            PRC_DIV         ITEM_STORE.PRC_DIV%TYPE,
            ITEM_CD         ITEM_STORE.ITEM_CD%TYPE,
            OLD_START_DT    ITEM_STORE.START_DT%TYPE,
            NEW_START_DT    ITEM_STORE.START_DT%TYPE,
            CLOSE_DT        ITEM_STORE.CLOSE_DT%TYPE,
            PRICE           ITEM_STORE.PRICE%TYPE,
            USE_YN          ITEM_STORE.USE_YN%TYPE
        );

        CURSOR CUR_1 IS  -- 입력된 값 바로 이전값 취득
            SELECT  COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , PRC_DIV
                  , ITEM_CD
                  , START_DT
                  , CLOSE_DT
            FROM   (      
                    SELECT  COMP_CD
                          , BRAND_CD
                          , STOR_CD
                          , PRC_DIV
                          , ITEM_CD
                          , START_DT
                          , CLOSE_DT
                          , ROW_NUMBER() OVER(ORDER BY START_DT DESC) R_NUM
                    FROM    ITEM_STORE
                    WHERE   COMP_CD   = PSV_COMP_CD
                    AND     BRAND_CD  = PSV_BRAND_CD
                    AND     STOR_CD   = PSV_STOR_CD
                    AND     PRC_DIV   = PSV_PRC_DIV
                    AND     ITEM_CD   = PSV_ITEM_CD
                    AND     START_DT  < PSV_START_DT
                    AND     USE_YN    = 'Y'
                   )
            WHERE   R_NUM = 1;

        CURSOR CUR_2 IS  -- 입력된 값 바로 이후값 취득
            SELECT  COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , PRC_DIV
                  , ITEM_CD
                  , START_DT
                  , CLOSE_DT
            FROM   (      
                    SELECT  COMP_CD
                          , BRAND_CD
                          , STOR_CD
                          , PRC_DIV
                          , ITEM_CD
                          , START_DT
                          , CLOSE_DT
                          , ROW_NUMBER() OVER(ORDER BY START_DT) R_NUM
                    FROM    ITEM_STORE
                    WHERE   COMP_CD   = PSV_COMP_CD
                    AND     BRAND_CD  = PSV_BRAND_CD
                    AND     STOR_CD   = PSV_STOR_CD
                    AND     PRC_DIV   = PSV_PRC_DIV
                    AND     ITEM_CD   = PSV_ITEM_CD
                    AND     START_DT  > PSV_START_DT
                    AND     USE_YN    = 'Y'
                   )
            WHERE   R_NUM = 1;

        CURSOR CUR_3 IS  -- 입력된 레코드의 종료일 보다 큰 레코드 중 가장 작은 레코드
            SELECT  COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , PRC_DIV
                  , ITEM_CD
                  , START_DT                                                   AS OLD_START_DT
                  , TO_CHAR(TO_DATE(PSV_CLOSE_DT, 'YYYYMMDD') + 1, 'YYYYMMDD') AS NEW_START_DT
                  , CLOSE_DT
                  , PRICE
                  , USE_YN
            FROM   (      
                    SELECT  COMP_CD
                          , BRAND_CD
                          , STOR_CD
                          , PRC_DIV
                          , ITEM_CD
                          , START_DT
                          , CLOSE_DT
                          , PRICE
                          , USE_YN
                          , ROW_NUMBER() OVER(ORDER BY CLOSE_DT) R_NUM
                    FROM    ITEM_STORE
                    WHERE   COMP_CD   = PSV_COMP_CD
                    AND     BRAND_CD  = PSV_BRAND_CD
                    AND     STOR_CD   = PSV_STOR_CD
                    AND     PRC_DIV   = PSV_PRC_DIV
                    AND     ITEM_CD   = PSV_ITEM_CD
                    AND     CLOSE_DT  > PSV_CLOSE_DT
                    AND     USE_YN    = 'Y'
                   )
            WHERE   R_NUM = 1;

        ls_sql_main     VARCHAR2(30000) := '';

        ERR_HANDLER     EXCEPTION;

        tLAST_ITEM_HIS  TPY_LAST_ITEM_HIS;
        vMOD_CLOSE_DT   ITEM_STORE.CLOSE_DT%TYPE;
        vCMP_START_DT   ITEM_STORE.START_DT%TYPE;
        vCMP_CLOSE_DT   ITEM_STORE.CLOSE_DT%TYPE;
        vDUP_DATA_INFO  VARCHAR2(30) := NULL;

        nRECCNT         NUMBER(6) := 0;
        nMAXCNT         NUMBER(6) := 0;
    BEGIN
        SELECT  COUNT(*), MIN(START_DT)||'~'||MAX(CLOSE_DT) 
        INTO nRECCNT, vDUP_DATA_INFO 
        FROM    ITEM_STORE
        WHERE   COMP_CD   = PSV_COMP_CD
        AND     BRAND_CD  = PSV_BRAND_CD
        AND     STOR_CD   = PSV_STOR_CD
        AND     PRC_DIV   = PSV_PRC_DIV
        AND     ITEM_CD   = PSV_ITEM_CD
        AND     START_DT  > PSV_START_DT
        AND     CLOSE_DT  < PSV_CLOSE_DT
        AND     USE_YN    = 'Y';

        IF nRECCNT > 0 THEN
            PR_RTN_CD  := '1300';
            PR_RTN_MSG := '['||PSV_ITEM_CD||']['||vDUP_DATA_INFO||']'||FC_GET_WORDPACK_MSG(PSV_COMP_CD, LOWER(PSV_LANG_CD), '1010001483');

            RAISE ERR_HANDLER;
        END IF;

        -- 신규 레코드의 종료 일자보다 큰 레코드중 가장 작은 레코드 정보 저장
        IF PSV_USE_YN = '1' OR PSV_USE_YN = 'Y' THEN
            FOR MYREC3 IN CUR_3 LOOP
                nRECCNT := nRECCNT + 1;
                tLAST_ITEM_HIS.COMP_CD      := MYREC3.COMP_CD;
                tLAST_ITEM_HIS.BRAND_CD     := MYREC3.BRAND_CD;
                tLAST_ITEM_HIS.STOR_CD      := MYREC3.STOR_CD;
                tLAST_ITEM_HIS.PRC_DIV      := MYREC3.PRC_DIV;
                tLAST_ITEM_HIS.ITEM_CD      := MYREC3.ITEM_CD;
                tLAST_ITEM_HIS.OLD_START_DT := MYREC3.OLD_START_DT;
                tLAST_ITEM_HIS.NEW_START_DT := MYREC3.NEW_START_DT;
                tLAST_ITEM_HIS.CLOSE_DT     := MYREC3.CLOSE_DT;
                tLAST_ITEM_HIS.PRICE        := MYREC3.PRICE;
                tLAST_ITEM_HIS.USE_YN       := MYREC3.USE_YN;
            END LOOP;
        END IF;

        IF PSV_USE_YN = '1' OR PSV_USE_YN = 'Y' THEN
            IF PSV_START_DT > PSV_CLOSE_DT THEN
                PR_RTN_CD  := '1400';
                PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, LOWER(PSV_LANG_CD), '1001346021');

                RAISE ERR_HANDLER;
            END IF;

            -- 이전 레코드 시작일/종료일이 겹치는지 체크 
            FOR MYREC1 IN CUR_1 LOOP
                IF MYREC1.CLOSE_DT >= PSV_START_DT THEN
                    vCMP_START_DT := MYREC1.START_DT;
                    vCMP_CLOSE_DT := MYREC1.CLOSE_DT;

                    UPDATE  ITEM_STORE
                    SET     CLOSE_DT = TO_CHAR(TO_DATE(PSV_START_DT, 'YYYYMMDD') - 1, 'YYYYMMDD')
                          , UPD_DT   = SYSDATE
                          , UPD_USER = PSV_USER_ID
                    WHERE   COMP_CD   = MYREC1.COMP_CD
                    AND     BRAND_CD  = MYREC1.BRAND_CD
                    AND     STOR_CD   = MYREC1.STOR_CD
                    AND     PRC_DIV   = MYREC1.PRC_DIV
                    AND     ITEM_CD   = MYREC1.ITEM_CD
                    AND     START_DT  = MYREC1.START_DT;
                ELSE
                    vCMP_START_DT := PSV_START_DT;
                    vCMP_CLOSE_DT := PSV_CLOSE_DT;
                END IF;
            END LOOP;

            vMOD_CLOSE_DT := PSV_CLOSE_DT;

            -- 이후 레코드 시작일/종료일이 겹치는지 체크
            FOR MYREC2 IN CUR_2 LOOP
                IF MYREC2.START_DT < PSV_CLOSE_DT THEN
                    IF nRECCNT = 0 THEN
                        vMOD_CLOSE_DT := TO_CHAR(TO_DATE(MYREC2.START_DT, 'YYYYMMDD') - 1, 'YYYYMMDD');
                    ELSE
                        vMOD_CLOSE_DT := TO_CHAR(TO_DATE(tLAST_ITEM_HIS.NEW_START_DT, 'YYYYMMDD') - 1, 'YYYYMMDD');
                    END IF;
                END IF;
            END LOOP;
        ELSE
            vMOD_CLOSE_DT := PSV_CLOSE_DT;
        END IF;

        MERGE INTO ITEM_STORE
        USING DUAL
        ON (
                COMP_CD     = PSV_COMP_CD
            AND BRAND_CD    = PSV_BRAND_CD
            AND STOR_CD     = PSV_STOR_CD
            AND PRC_DIV     = PSV_PRC_DIV
            AND ITEM_CD     = PSV_ITEM_CD
            AND START_DT    = PSV_START_DT
           )
        WHEN MATCHED THEN
            UPDATE  
            SET CLOSE_DT    = vMOD_CLOSE_DT
              , PRICE       = TO_NUMBER(PSV_PRICE)
              , USE_YN      = PSV_USE_YN
              , UPD_DT      = SYSDATE
              , UPD_USER    = PSV_USER_ID
        WHEN NOT MATCHED THEN
            INSERT   
               (          
                COMP_CD
              , BRAND_CD
              , STOR_CD
              , PRC_DIV
              , ITEM_CD
              , START_DT
              , CLOSE_DT
              , PRICE
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
              , PSV_PRC_DIV
              , PSV_ITEM_CD
              , PSV_START_DT
              , vMOD_CLOSE_DT
              , TO_NUMBER(PSV_PRICE)
              , PSV_USE_YN
              , SYSDATE
              , PSV_USER_ID
              , SYSDATE
              , PSV_USER_ID
               );

        IF nRECCNT > 0 THEN
            -- 최종 자료중 겹치는 자료는 삭제
            UPDATE  ITEM_STORE
            SET     USE_YN    = 'N'
                  , UPD_DT    = SYSDATE
                  , UPD_USER  = PSV_USER_ID
            WHERE   COMP_CD   = tLAST_ITEM_HIS.COMP_CD
            AND     BRAND_CD  = tLAST_ITEM_HIS.BRAND_CD
            AND     STOR_CD   = tLAST_ITEM_HIS.STOR_CD
            AND     PRC_DIV   = tLAST_ITEM_HIS.PRC_DIV
            AND     ITEM_CD   = tLAST_ITEM_HIS.ITEM_CD
            AND     tLAST_ITEM_HIS.NEW_START_DT BETWEEN START_DT AND CLOSE_DT
            AND     tLAST_ITEM_HIS.OLD_START_DT != tLAST_ITEM_HIS.NEW_START_DT
            AND     USE_YN    = 'Y';

            /* 신규 등록 */
            MERGE INTO ITEM_STORE
            USING DUAL
            ON (
                    COMP_CD     = tLAST_ITEM_HIS.COMP_CD
                AND BRAND_CD    = tLAST_ITEM_HIS.BRAND_CD
                AND STOR_CD     = tLAST_ITEM_HIS.STOR_CD
                AND PRC_DIV     = tLAST_ITEM_HIS.PRC_DIV
                AND ITEM_CD     = tLAST_ITEM_HIS.ITEM_CD
                AND START_DT    = tLAST_ITEM_HIS.NEW_START_DT
               )
            WHEN MATCHED THEN
                UPDATE  
                SET CLOSE_DT    = tLAST_ITEM_HIS.CLOSE_DT
                  , PRICE       = tLAST_ITEM_HIS.PRICE
                  , USE_YN      = USE_YN
                  , UPD_DT      = SYSDATE
                  , UPD_USER    = PSV_USER_ID
            WHEN NOT MATCHED THEN
                INSERT   
                   (          
                    COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , PRC_DIV
                  , ITEM_CD
                  , START_DT
                  , CLOSE_DT
                  , PRICE
                  , USE_YN 
                  , INST_DT
                  , INST_USER
                  , UPD_DT
                  , UPD_USER
                   ) 
                VALUES 
                   (
                    tLAST_ITEM_HIS.COMP_CD
                  , tLAST_ITEM_HIS.BRAND_CD
                  , tLAST_ITEM_HIS.STOR_CD
                  , tLAST_ITEM_HIS.PRC_DIV
                  , tLAST_ITEM_HIS.ITEM_CD
                  , tLAST_ITEM_HIS.NEW_START_DT
                  , tLAST_ITEM_HIS.CLOSE_DT
                  , tLAST_ITEM_HIS.PRICE
                  , tLAST_ITEM_HIS.USE_YN
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
        WHEN ERR_HANDLER THEN
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;

            ROLLBACK;
            RETURN;
    END;

/
