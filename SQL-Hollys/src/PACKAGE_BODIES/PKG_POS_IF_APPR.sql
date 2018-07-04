--------------------------------------------------------
--  DDL for Package Body PKG_POS_IF_APPR
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_POS_IF_APPR" AS
------------------------------------------------------------------------------
--  Package Name     : PKG_POS_IF_APPR
--  Description      : 포스인터페이스 인증 
------------------------------------------------------------------------------
--  Create Date      : 2017-11-03
--  Create Programer :
--  Modify Date      :
--  Modify Programer :
------------------------------------------------------------------------------

-- SC사원 정보 조회
PROCEDURE SP_SV_USER_REQ
( 
    PSV_COMP_CD     IN  VARCHAR2,   -- 회사코드
    PSV_BRAND_CD    IN  VARCHAR2,   -- Brand Code
    PSV_STOR_CD     IN  VARCHAR2,   -- Store Code
    PSV_LANGUAGE    IN  VARCHAR2,   -- 언어코드
    PSV_USER_ID     IN  VARCHAR2,   -- 사원번호
    PR_RETURN_CD    OUT VARCHAR2,   -- 메세지코드
    PR_RETURN_MSG   OUT VARCHAR2,   -- 메세지
    PR_RESULT       OUT REC_SET.M_REFCUR
) IS

vUSER_ID        HQ_USER.USER_ID%TYPE;
ERR_HANDLER     EXCEPTION;

BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

    PR_RETURN_CD    := '0000';
    PR_RETURN_MSG   := 'OK';

    BEGIN
        -- 사원 조회
        SELECT  USER_ID
          INTO  vUSER_ID
          FROM  HQ_USER
         WHERE  COMP_CD     = PSV_COMP_CD
           AND  USER_ID     = PSV_USER_ID
           AND  USE_YN      = 'Y'
        ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PR_RETURN_CD  := '1000';
            PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001113'); -- 등록되지 않은 사원입니다.
            RAISE ERR_HANDLER;
        WHEN OTHERS THEN
            PR_RETURN_CD  := '9999';
            PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            RAISE ERR_HANDLER;
    END;

    OPEN PR_RESULT FOR
        SELECT  USER_ID
             ,  USER_NM
             ,  PWD
          FROM  HQ_USER
         WHERE  COMP_CD     = PSV_COMP_CD
           AND  USER_ID     = PSV_USER_ID
           AND  USE_YN      = 'Y'
        ;

    PR_RETURN_MSG   := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001392'); -- 정상처리 되었습니다.

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    RETURN;

EXCEPTION
    WHEN ERR_HANDLER THEN
        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;

    WHEN OTHERS THEN
        PR_RETURN_CD  := '9999';
        PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
        --PR_RETURN_MSG := SQLERRM;

        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;

END;

-- 매장디바이스 정보 저장
PROCEDURE SP_SAVE_STORE_DEVICE
( 
    PSV_COMP_CD     IN  VARCHAR2,   -- 회사코드
    PSV_BRAND_CD    IN  VARCHAR2,   -- Brand Code
    PSV_STOR_CD     IN  VARCHAR2,   -- Store Code
    PSV_POS_NO      IN  VARCHAR2,   -- 포스번호
    PSV_LANGUAGE    IN  VARCHAR2,   -- 언어코드
    PSV_DEVICE_TXT  IN  VARCHAR2,   -- 디바이스설정 문자열
    PR_RETURN_CD    OUT VARCHAR2,   -- 메세지코드
    PR_RETURN_MSG   OUT VARCHAR2,   -- 메세지
    PR_RESULT       OUT REC_SET.M_REFCUR
) IS

-- 디바이스 구조체 선언
TYPE OT_DEVICE IS RECORD   
(   
    DEVICE_KEY      VARCHAR2(30), -- 디바이스키코드   
    DEVICE_VAL      VARCHAR2(50)  -- 디바이스값
);

TYPE TBL_DEVICE IS TABLE OF OT_DEVICE INDEX BY PLS_INTEGER;

ARR_DEVICE  TBL_DEVICE;

vDEVICE_DIV     STORE_DEVICE.DEVICE_DIV%TYPE;
vDEVICE_CD      STORE_DEVICE.DEVICE_CD%TYPE;
vCOL_POSITION   NUMBER(7) := 0;
vDATA_CNT       NUMBER(7) := 0;
vDEVICE         VARCHAR2(32000) := NULL;
ERR_HANDLER     EXCEPTION;

BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

    PR_RETURN_CD    := '0000';
    PR_RETURN_MSG   := 'OK';

    BEGIN
        IF PSV_DEVICE_TXT IS NOT NULL AND LENGTH(PSV_DEVICE_TXT) > 0 THEN
            vDEVICE := PSV_DEVICE_TXT;
            vDATA_CNT := 1;
            LOOP

                EXIT WHEN vDEVICE IS NULL OR vDEVICE = '' OR vDEVICE = CHR(29);

                vCOL_POSITION := INSTR(vDEVICE, CHR(29), 1, 1);
                IF vCOL_POSITION < 1 THEN
                    PR_RETURN_CD  := '1001';   
                    PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001668'); -- 디바이스 정보가 올바르지 않습니다.   
                    RAISE ERR_HANDLER;
                END IF;
                ARR_DEVICE(vDATA_CNT).DEVICE_KEY := TRIM(SUBSTR(vDEVICE, 1, vCOL_POSITION - 1));
                vDEVICE := SUBSTR(vDEVICE, vCOL_POSITION + 1, LENGTH(vDEVICE));

                vCOL_POSITION := INSTR(vDEVICE, CHR(29), 1, 1);
                IF vCOL_POSITION < 1 THEN
                    PR_RETURN_CD  := '1001';   
                    PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001668'); -- 디바이스 정보가 올바르지 않습니다.   
                    RAISE ERR_HANDLER;
                END IF;
                ARR_DEVICE(vDATA_CNT).DEVICE_VAL := TRIM(SUBSTR(vDEVICE, 1, vCOL_POSITION - 1));
                vDEVICE := SUBSTR(vDEVICE, vCOL_POSITION + 1, LENGTH(vDEVICE));

                vDATA_CNT := vDATA_CNT + 1;
            END LOOP;

            FOR i IN 1 .. vDATA_CNT - 1 LOOP
                SELECT  DEVICE_DIV, DEVICE_CD
                  INTO  vDEVICE_DIV, vDEVICE_CD
                  FROM  DEVICE_IF
                 WHERE  COMP_CD     = PSV_COMP_CD
                   AND  DEVICE_KEY  = ARR_DEVICE(i).DEVICE_KEY;

                DBMS_OUTPUT.PUT_LINE(ARR_DEVICE(i).DEVICE_KEY || ' = ' || ARR_DEVICE(i).DEVICE_VAL || ', '||vDEVICE_DIV|| ', '||vDEVICE_CD);

                MERGE INTO STORE_DEVICE
                USING DUAL
                ON (
                            COMP_CD     = PSV_COMP_CD
                       AND  BRAND_CD    = PSV_BRAND_CD
                       AND  STOR_CD     = PSV_STOR_CD
                       AND  POS_NO      = PSV_POS_NO
                       AND  DEVICE_DIV  = vDEVICE_DIV
                       AND  DEVICE_CD   = vDEVICE_CD
                       AND  DEVICE_KEY  = ARR_DEVICE(i).DEVICE_KEY
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  DEVICE_VAL  = ARR_DEVICE(i).DEVICE_VAL
                         ,  UPD_DT      = SYSDATE
                         ,  UPD_USER    = 'SYSTEM'
                WHEN NOT MATCHED THEN
                    INSERT
                    (
                            COMP_CD
                         ,  BRAND_CD
                         ,  STOR_CD
                         ,  POS_NO
                         ,  DEVICE_DIV
                         ,  DEVICE_CD
                         ,  DEVICE_KEY
                         ,  DEVICE_VAL
                         ,  USE_YN
                         ,  INST_DT
                         ,  INST_USER
                         ,  UPD_DT
                         ,  UPD_USER
                    ) VALUES (
                            PSV_COMP_CD
                         ,  PSV_BRAND_CD
                         ,  PSV_STOR_CD
                         ,  PSV_POS_NO
                         ,  vDEVICE_DIV
                         ,  vDEVICE_CD
                         ,  ARR_DEVICE(i).DEVICE_KEY
                         ,  ARR_DEVICE(i).DEVICE_VAL
                         ,  'Y'
                         ,  SYSDATE
                         ,  'SYSTEM'
                         ,  SYSDATE
                         ,  'SYSTEM'
                    );
            END LOOP;

        END IF;
    END;

    OPEN PR_RESULT FOR
        SELECT  'OK'
          FROM  DUAL
        ;

    PR_RETURN_MSG   := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001392'); -- 정상처리 되었습니다.

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    RETURN;

EXCEPTION
    WHEN ERR_HANDLER THEN
        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;

    WHEN OTHERS THEN
        PR_RETURN_CD  := '9999';
        PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
        --PR_RETURN_MSG := SQLERRM;

        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;

END;

-- 매장월마감 조회
PROCEDURE SP_STORE_CLM_REQ
( 
    PSV_COMP_CD     IN  VARCHAR2,   -- 회사코드
    PSV_BRAND_CD    IN  VARCHAR2,   -- Brand Code
    PSV_STOR_CD     IN  VARCHAR2,   -- Store Code
    PSV_SALE_DT     IN  VARCHAR2,   -- 판매일자
    PSV_LANGUAGE    IN  VARCHAR2,   -- 언어코드
    PR_RETURN_CD    OUT VARCHAR2,   -- 메세지코드
    PR_RETURN_MSG   OUT VARCHAR2,   -- 메세지
    PR_RESULT       OUT REC_SET.M_REFCUR
) IS

ERR_HANDLER     EXCEPTION;

BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

    PR_RETURN_CD    := '0000';
    PR_RETURN_MSG   := 'OK';

    OPEN PR_RESULT FOR
        SELECT  NVL(SC.CFM_YN, 'N')     AS CLOSE_YN
             ,  S.BRAND_CD
             ,  S.STOR_CD
             ,  PSV_SALE_DT             AS SALE_DT
          FROM  STORE       S
             ,  STORE_CLM   SC
         WHERE  S.COMP_CD   = SC.COMP_CD(+)
           AND  S.BRAND_CD  = SC.BRAND_CD(+)
           AND  S.STOR_CD   = SC.STOR_CD(+)
           AND  S.COMP_CD   = PSV_COMP_CD
           AND  S.BRAND_CD  = PSV_BRAND_CD
           AND  S.STOR_CD   = PSV_STOR_CD
           AND  SC.CLOSE_YM(+) = SUBSTR(PSV_SALE_DT, 0, 6)
        ;

    PR_RETURN_MSG   := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001392'); -- 정상처리 되었습니다.

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    RETURN;

EXCEPTION
    WHEN ERR_HANDLER THEN
        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;

    WHEN OTHERS THEN
        PR_RETURN_CD  := '9999';
        PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
        --PR_RETURN_MSG := SQLERRM;

        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        RETURN;

END;

END PKG_POS_IF_APPR;

/
