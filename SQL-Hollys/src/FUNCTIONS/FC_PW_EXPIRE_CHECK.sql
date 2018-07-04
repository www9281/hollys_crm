--------------------------------------------------------
--  DDL for Function FC_PW_EXPIRE_CHECK
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_PW_EXPIRE_CHECK" 

/******************************************************************************
   NAME:       FC_PW_EXPIRE_CHECK
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2009-12-16   zinCorp      1. Created this function.

   NOTES: 웹 접근 비밀번호를 변경하기 위해 CHECK

   Automatically available Auto Replace Keywords:
      Object Name:     FC_PW_EXPIRE_CHECK
      Sysdate:         2009-12-16
      Date and Time:   2009-12-16, 오후 1:47:24, and 2009-12-16 오후 1:47:24
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
(
  PS_COMP_CD    IN  VARCHAR2,
  PS_USER_ID    IN  VARCHAR2
)

RETURN  VARCHAR2
IS
LS_PWD_CHG_TP VARCHAR2(1);

BEGIN

    SELECT  PWD_CHG_TP
    INTO LS_PWD_CHG_TP
    FROM (
            SELECT  CASE WHEN PWD_CHG_YN = 'N' OR CHG_TERM IS NULL THEN 'N'                                         -- 비밀번호 변경 안함 
                         WHEN PWD_CHG_DT IS NULL THEN 'F'                                                           -- 최초로그인
                         WHEN TO_CHAR(PWD_CHG_DT, 'YYYYMMDD') >= TO_CHAR(SYSDATE - CHG_TERM, 'YYYYMMDD') THEN 'N'   -- 비밀번호 변경 불필요
                         ELSE 'Y'                                                                                   -- 비밀번호 변경 필요 
                    END AS PWD_CHG_TP
              FROM  (
                        SELECT  PWD_CHG_YN
                             ,  PWD_CHG_DT
                             ,  (
                                    SELECT  VAL_N1
                                      FROM  COMMON
                                     WHERE  COMP_CD = PS_COMP_CD
                                       AND  CODE_TP = '01435'
                                       AND  CODE_CD = '130'
                                ) AS CHG_TERM
                          FROM  HQ_USER
                         WHERE  COMP_CD = PS_COMP_CD
                           AND  USER_ID = PS_USER_ID
                    )
            UNION ALL
            SELECT  CASE WHEN WEB_PWD_CHG_YN = 'N' OR CHG_TERM IS NULL THEN 'N'                                         -- 비밀번호 변경 안함 
                         WHEN WEB_PWD_CHG_DT IS NULL THEN 'F'                                                           -- 최초로그인
                         WHEN TO_CHAR(WEB_PWD_CHG_DT, 'YYYYMMDD') >= TO_CHAR(SYSDATE - CHG_TERM, 'YYYYMMDD') THEN 'N'   -- 비밀번호 변경 불필요
                         ELSE 'Y'                                                                                       -- 비밀번호 변경 필요 
                    END AS PWD_CHG_TP
              FROM  (
                        SELECT  WEB_PWD_CHG_YN
                             ,  WEB_PWD_CHG_DT
                             ,  (
                                    SELECT  VAL_N1
                                      FROM  COMMON
                                     WHERE  COMP_CD = PS_COMP_CD
                                       AND  CODE_TP = '01435'
                                       AND CODE_CD  = '130'
                                ) AS CHG_TERM
                          FROM  STORE_USER
                         WHERE  USER_ID = PS_USER_ID
                    )
        );

    RETURN LS_PWD_CHG_TP;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN LS_PWD_CHG_TP;

END FC_PW_EXPIRE_CHECK;

/
