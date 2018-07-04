CREATE OR REPLACE PACKAGE       PKG_MAST5280 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_MAST5280
    --  Description      : 할인 인증번호 등록 
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_BRAND_CD    IN  VARCHAR2 ,                -- 영업조직
        PSV_DC_DIV      IN  VARCHAR2 ,                -- 할인코드
        PSV_CERT_CNT    IN  VARCHAR2 ,                -- 인증번호 등록건수
        PSV_USER_ID     IN  VARCHAR2 ,                -- 등록자
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_MAST5280;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MAST5280 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_BRAND_CD    IN  VARCHAR2 ,                -- 영업조직
        PSV_DC_DIV      IN  VARCHAR2 ,                -- 할인코드
        PSV_CERT_CNT    IN  VARCHAR2 ,                -- 인증번호 등록건수
        PSV_USER_ID     IN  VARCHAR2 ,                -- 등록자
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     할인 인증번호 생성
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-11-24         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-11-24
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    BEGIN
        PR_RTN_CD    := '0000';
        PR_RTN_MSG   := '성공';
    
        FOR IDX IN 1 .. TO_NUMBER(PSV_CERT_CNT) LOOP
            INSERT INTO DC_CERT
            (
                    COMP_CD
                 ,  BRAND_CD
                 ,  DC_DIV
                 ,  CERT_NO
                 ,  USE_STAT
            ) VALUES(
                    PSV_COMP_CD
                 ,  PSV_BRAND_CD
                 ,  PSV_DC_DIV
                 ,  FN_GET_CERTNO_CREATE(PSV_COMP_CD, 'D', TO_CHAR(SYSDATE, 'YYYYMMDD'))
                 ,  '00'
            );
        END LOOP;
    
        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM ;
            ROLLBACK;
            RETURN;
    END;
   
END PKG_MAST5280;

/
