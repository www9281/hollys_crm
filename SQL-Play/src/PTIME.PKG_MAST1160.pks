CREATE OR REPLACE PACKAGE       PKG_MAST1160 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_MAST1160
    --  Description      : 모바일쿠폰 인증번호 등록 
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_COUPON_CD   IN  VARCHAR2 ,                -- 쿠폰코드
        PSV_COUPON_DIV  IN  VARCHAR2 ,                -- 쿠폰구분[10:쿠팡, 11:위메프]
        PSV_CERT_FDT    IN  VARCHAR2 ,                -- 유효 시작일자
        PSV_CERT_TDT    IN  VARCHAR2 ,                -- 유효 종료일자
        PSV_CERT_CNT    IN  VARCHAR2 ,                -- 쿠폰 등록건수
        PSV_USER_ID     IN  VARCHAR2 ,                -- 등록자
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_MAST1160;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MAST1160 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_COUPON_CD   IN  VARCHAR2 ,                -- 쿠폰코드
        PSV_COUPON_DIV  IN  VARCHAR2 ,                -- 쿠폰구분[10:쿠팡, 11:위메프]
        PSV_CERT_FDT    IN  VARCHAR2 ,                -- 유효 시작일자
        PSV_CERT_TDT    IN  VARCHAR2 ,                -- 유효 종료일자
        PSV_CERT_CNT    IN  VARCHAR2 ,                -- 쿠폰 등록건수
        PSV_USER_ID     IN  VARCHAR2 ,                -- 등록자
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     모바일쿠폰 인증번호 생성
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
            INSERT INTO M_COUPON_CUST
            (
                    COMP_CD
                 ,  COUPON_CD
                 ,  CERT_NO
                 ,  CERT_FDT
                 ,  CERT_TDT
                 ,  USE_STAT
                 ,  USE_YN
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
            ) VALUES(
                    PSV_COMP_CD
                 ,  PSV_COUPON_CD
                 ,  FN_GET_CERTNO_CREATE(PSV_COMP_CD, DECODE(PSV_COUPON_DIV, '10', 'C', 'W'), TO_CHAR(SYSDATE, 'YYYYMMDD'))
                 ,  PSV_CERT_FDT     
                 ,  PSV_CERT_TDT
                 ,  '00'
                 ,  'Y'
                 ,  SYSDATE
                 ,  PSV_USER_ID
                 ,  SYSDATE
                 ,  PSV_USER_ID
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
   
END PKG_MAST1160;

/
