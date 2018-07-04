--------------------------------------------------------
--  DDL for Function FC_GET_UTC_DATE_USER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_UTC_DATE_USER" 
(
   PSV_COMP_CD   IN VARCHAR2,  -- Company Code
   PSV_USER_ID   IN VARCHAR2,  -- 로그인 아이디
   PSV_DATE      IN DATE       -- 일자
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

    IF PSV_COMP_CD IS NULL OR PSV_USER_ID IS NULL THEN
        SELECT  NVL(PSV_DATE, SYSDATE)
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
            SELECT  NVL(PSV_DATE, SYSDATE)
              INTO  ls_return_date
              FROM  DUAL;
            RETURN   ls_return_date;
    END;

    -- 사용자 표준시간대/서머타임 정보 조회
    BEGIN
        SELECT  LU.UTC_SIGN, SUBSTRB(LU.UTC_VAL, 1, 2), SUBSTRB(LU.UTC_VAL, 3, 2), LS.SMT_TM
          INTO  ls_user_utc_sign, ls_user_utc_hh, ls_user_utc_mm, ls_smt_tm
          FROM  (
                    SELECT  LR.UTC_CD, LR.SMT_NO
                      FROM  (
                                SELECT  NATION_CD
                                     ,  REGION_NO
                                  FROM  HQ_USER     HU
                                 WHERE  HU.COMP_CD  = PSV_COMP_CD
                                   AND  HU.USER_ID  = PSV_USER_ID
                                   AND  HU.USE_YN   = 'Y'
                                UNION ALL
                                SELECT  NATION_CD
                                     ,  REGION_NO
                                  FROM  STORE_USER  SU
                                 WHERE  SU.COMP_CD  = PSV_COMP_CD
                                   AND  SU.USER_ID  = PSV_USER_ID
                                   AND  SU.USE_YN   = 'Y'
                            )           U
                         ,  L_REGION    LR
                     WHERE  U.NATION_CD = LR.NATION_CD(+)
                       AND  U.REGION_NO = LR.REGION_NO(+)
                       AND  LR.USE_YN(+)= 'Y'
                       AND  ROWNUM      = 1
                )   U
             ,  (
                    SELECT  LU.UTC_CD, LU.UTC_SIGN, LU.UTC_VAL
                      FROM  L_UTC       LU
                     WHERE  LU.USE_YN   = 'Y'
                )   LU
             ,  (
                    SELECT  LS.SMT_NO, LS.SMT_TM
                      FROM  L_SMT       LS
                     WHERE  TO_CHAR(NVL(PSV_DATE, SYSDATE), 'YYYYMMDDHH24') BETWEEN SMT_FR_DT AND SMT_TO_DT
                       AND  LS.USE_YN   = 'Y'
                )   LS
         WHERE  U.UTC_CD    = LU.UTC_CD(+)
           AND  U.SMT_NO    = LS.SMT_NO(+);

        EXCEPTION WHEN NO_DATA_FOUND THEN
            SELECT  NVL(PSV_DATE, SYSDATE)
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
                SELECT  NVL(PSV_DATE, SYSDATE)
                INTO  ls_return_date
                FROM  DUAL;
                RETURN   ls_return_date;
        END;
    ELSE
        SELECT  NVL(PSV_DATE, SYSDATE)
          INTO  ls_return_date
          FROM  DUAL;
    END IF;

    RETURN ls_return_date;
END;

/
