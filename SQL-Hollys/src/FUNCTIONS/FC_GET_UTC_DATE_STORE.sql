--------------------------------------------------------
--  DDL for Function FC_GET_UTC_DATE_STORE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_UTC_DATE_STORE" 
(
   PSV_COMP_CD   IN VARCHAR2,  -- Company Code
   PSV_BRAND_CD  IN VARCHAR2,  -- 영업조직
   PSV_STOR_CD   IN VARCHAR2   -- 점포코드
)
RETURN DATE AS
    ls_svr_utc_sign     VARCHAR2(1);
    ls_svr_utc_hh       VARCHAR2(2);
    ls_svr_utc_mm       VARCHAR2(2);
    ls_user_utc_sign    VARCHAR2(1);
    ls_user_utc_hh      VARCHAR2(2);
    ls_user_utc_mm      VARCHAR2(2);
    ls_smt_tm           NUMBER(2);
    ls_return_date      DATE;
BEGIN

    IF PSV_COMP_CD IS NULL OR PSV_BRAND_CD IS NULL OR PSV_STOR_CD IS NULL THEN
        SELECT  SYSDATE
          INTO  ls_return_date
          FROM  DUAL;
    END IF;

    -- 서버의 표준시간대 정보 조회
    BEGIN
        SELECT  LU.UTC_SIGN, SUBSTRB(LU.UTC_VAL, 1, 2), SUBSTRB(LU.UTC_VAL, 3, 2)
          INTO  ls_svr_utc_sign, ls_svr_utc_hh, ls_svr_utc_mm
          FROM  COMPANY     C
             ,  L_NATION    LN
             ,  L_UTC       LU
         WHERE  C.NATION_CD = LN.NATION_CD
           AND  LN.UTC_CD   = LU.UTC_CD
           AND  C.COMP_CD   = PSV_COMP_CD;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            SELECT  SYSDATE
              INTO  ls_return_date
              FROM  DUAL;
            RETURN   ls_return_date;
    END;

    -- 점포 표준시간대/서머타임 정보 조회
    BEGIN
        SELECT  LU.UTC_SIGN, SUBSTRB(LU.UTC_VAL, 1, 2), SUBSTRB(LU.UTC_VAL, 3, 2), LS.SMT_TM
          INTO  ls_user_utc_sign, ls_user_utc_hh, ls_user_utc_mm, ls_smt_tm
          FROM  (
                    SELECT  LR.UTC_CD, LR.SMT_NO
                      FROM  (
                                SELECT  S.NATION_CD
                                     ,  S.REGION_NO
                                  FROM  STORE     S
                                 WHERE  S.COMP_CD   = PSV_COMP_CD
                                   AND  S.BRAND_CD  = PSV_BRAND_CD
                                   AND  S.STOR_CD   = PSV_STOR_CD
                                   AND  S.USE_YN    = 'Y'
                            )           S
                         ,  L_REGION    LR
                     WHERE  S.NATION_CD = LR.NATION_CD(+)
                       AND  S.REGION_NO = LR.REGION_NO(+)
                       AND  LR.USE_YN(+)= 'Y'
                )   U
             ,  (
                    SELECT  LU.UTC_CD, LU.UTC_SIGN, LU.UTC_VAL
                      FROM  L_UTC       LU
                     WHERE  LU.USE_YN   = 'Y'
                )   LU
             ,  (
                    SELECT  LS.SMT_NO, LS.SMT_TM
                      FROM  L_SMT       LS
                     WHERE  TO_CHAR(SYSDATE, 'YYYYMMDDHH24') BETWEEN SMT_FR_DT AND SMT_TO_DT
                       AND  LS.USE_YN   = 'Y'
                )   LS
         WHERE  U.UTC_CD    = LU.UTC_CD(+)
           AND  U.SMT_NO    = LS.SMT_NO(+);

        EXCEPTION WHEN NO_DATA_FOUND THEN
            SELECT  SYSDATE
              INTO  ls_return_date
              FROM  DUAL;
            RETURN   ls_return_date;
    END;

    IF ls_user_utc_sign IS NOT NULL AND ls_user_utc_hh IS NOT NULL AND ls_user_utc_mm IS NOT NULL THEN
        -- 시차계산
        BEGIN
            SELECT     SYSDATE 
                    + ((CASE WHEN ls_user_utc_sign = '-' THEN -1 * TO_NUMBER(ls_user_utc_hh) ELSE TO_NUMBER(ls_user_utc_hh) END - CASE WHEN ls_svr_utc_sign = '-' THEN -1 * TO_NUMBER(ls_svr_utc_hh) ELSE TO_NUMBER(ls_svr_utc_hh) END) / 24)           -- 시간
                    + ((CASE WHEN ls_user_utc_sign = '-' THEN -1 * TO_NUMBER(ls_user_utc_mm) ELSE TO_NUMBER(ls_user_utc_mm) END - CASE WHEN ls_svr_utc_sign = '-' THEN -1 * TO_NUMBER(ls_svr_utc_mm) ELSE TO_NUMBER(ls_svr_utc_mm) END) / (24 * 60))    -- 분
                    + (NVL(ls_smt_tm, 0) / (24 * 60))
              INTO  ls_return_date
              FROM  DUAL;

            EXCEPTION WHEN NO_DATA_FOUND THEN
                SELECT  SYSDATE
                INTO  ls_return_date
                FROM  DUAL;
                RETURN   ls_return_date;
        END;
    ELSE
        SELECT  SYSDATE
          INTO  ls_return_date
          FROM  DUAL;
    END IF;

    RETURN ls_return_date;
END;

/
