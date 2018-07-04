CREATE OR REPLACE PACKAGE       PKG_MAST4030 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_MAST4030
    --  Description      : 점포마스터 등록 
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_TAB02_SIDO_GUNGU
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_NATION_CD   IN  VARCHAR2 ,                -- 국가코드
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_CITY_NM     IN  VARCHAR2 ,                -- 시도명
        PSV_REGION_NM   IN  VARCHAR2 ,                -- 시군구명
        PSV_USER_ID     IN  VARCHAR2 ,                -- 사용자
        PR_RTN_CITY     OUT VARCHAR2 ,                -- 시도코드
        PR_RTN_REGI     OUT VARCHAR2 ,                -- 시군구코드
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_MAST4030;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MAST4030 AS

    PROCEDURE SP_TAB02_SIDO_GUNGU
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_NATION_CD   IN  VARCHAR2 ,                -- 국가코드
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_CITY_NM     IN  VARCHAR2 ,                -- 시도명
        PSV_REGION_NM   IN  VARCHAR2 ,                -- 시군구명
        PSV_USER_ID     IN  VARCHAR2 ,                -- 사용자
        PR_RTN_CITY     OUT VARCHAR2 ,                -- 시도코드
        PR_RTN_REGI     OUT VARCHAR2 ,                -- 시군구코드
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02_SIDO_GUNGU      시도/지역 등록
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-05-06         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB02_SIDO_GUNGU
            SYSDATE     :   2016-05-06
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql_main     VARCHAR2(30000) := '';
        
    ERR_HANDLER     EXCEPTION;
    
    vCITY_CD        REGION.CITY_CD%TYPE;
    vREGION_CD      REGION.REGION_CD%TYPE;
    vMAXREGION      REGION.REGION_CD%TYPE;
    
    nRECCNT         NUMBER(6) := 0;
    nMAXCNT         NUMBER(6) := 0;
    BEGIN
        PR_RTN_CD  := '0';
        PR_RTN_MSG := '';
        
        /* 시도명 존재 체크 후 입력 */
        SELECT  COUNT(*)
              , SUM(CASE WHEN REGION_NM = TRIM(PSV_CITY_NM) THEN 1         ELSE 0    END)
              , MAX(CASE WHEN REGION_NM = TRIM(PSV_CITY_NM) THEN REGION_CD ELSE NULL END)
        INTO    nMAXCNT, nRECCNT, vCITY_CD
        FROM    REGION REG
        WHERE   REG.COMP_CD   = PSV_COMP_CD
        AND     REG.NATION_CD = PSV_NATION_CD
        AND     REG.CITY_CD   = '000'
        AND     REG.REGION_NM = PSV_CITY_NM;
        
        IF nRECCNT = 0 THEN
            /* 시도 코드 생성 */
            vCITY_CD := CASE WHEN nMAXCNT = 0 THEN 'A00' ELSE CHR(ASCII(SUBSTR(vCITY_CD, 1, 1)+1))||'00' END;
            
            INSERT INTO REGION
               (
                COMP_CD
              , NATION_CD
              , CITY_CD
              , REGION_CD
              , REGION_NM
              , SERVER_DIFF_TM
              , P_REGION_CD
              , USE_YN
              , INST_DT
              , INST_USER
              , UPD_DT
              , UPD_USER
               )
            VALUES
               ( 
                PSV_COMP_CD
              , PSV_NATION_CD
              , '000'
              , vCITY_CD
              , TRIM(PSV_CITY_NM)
              , '0'
              , NULL
              , 'Y'
              , SYSDATE
              , PSV_USER_ID
              , SYSDATE
              , PSV_USER_ID
               );
        END IF;
        
        /* 지역(시군구) 존재 체크 후 입력 */
        SELECT  COUNT(*)
              , SUM(CASE WHEN REGION_NM = TRIM(PSV_CITY_NM ||' '|| PSV_REGION_NM) THEN 1         ELSE 0    END)
              , MAX(CASE WHEN REGION_NM = TRIM(PSV_CITY_NM ||' '|| PSV_REGION_NM) THEN REGION_CD ELSE NULL END)
              , MAX(REGION_CD)
        INTO    nMAXCNT, nRECCNT, vREGION_CD, vMAXREGION
        FROM    REGION REG
        WHERE   REG.COMP_CD   = PSV_COMP_CD
        AND     REG.NATION_CD = PSV_NATION_CD
        AND     REG.CITY_CD   = vCITY_CD;
        
        IF nRECCNT = 0 THEN
            /* 시군구 코드 생성 */
            vREGION_CD := CASE WHEN nMAXCNT = 0 THEN SUBSTR(vCITY_CD, 1, 1)||'01' ELSE SUBSTR(vMAXREGION, 1, 1)||TO_CHAR(TO_NUMBER(SUBSTR(vMAXREGION, 2, 2)) +1, 'FM00') END;
            
            /* 시군구 정보 입력 */
            INSERT INTO REGION
               (
                COMP_CD
              , NATION_CD
              , CITY_CD
              , REGION_CD
              , REGION_NM
              , SERVER_DIFF_TM
              , P_REGION_CD
              , USE_YN
              , INST_DT
              , INST_USER
              , UPD_DT
              , UPD_USER
               )
            VALUES
               ( 
                PSV_COMP_CD
              , PSV_NATION_CD
              , vCITY_CD
              , vREGION_CD
              , TRIM(PSV_CITY_NM ||' '|| PSV_REGION_NM)
              , '0'
              , NULL
              , 'Y'
              , SYSDATE
              , PSV_USER_ID
              , SYSDATE
              , PSV_USER_ID
               );
        END IF;    
        
        PR_RTN_CITY := vCITY_CD;
        PR_RTN_REGI := vREGION_CD;
        
        COMMIT;
        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
        
            ROLLBACK;
            RETURN;
    END;
   
END PKG_MAST4030;

/
