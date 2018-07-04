--------------------------------------------------------
--  DDL for Procedure SP_START_JAVA_JOB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_START_JAVA_JOB" 
(
    PSV_COMP_CD     IN  VARCHAR2,                   -- 회사코드
    PSV_LANG_TP     IN  VARCHAR2,                   -- 언어코드
    PSV_SCHD_ID     IN  VARCHAR2,                   -- 스케쥴러ID
    PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
    PR_RTN_CD       OUT VARCHAR2,                   -- RETURN CODE
    PR_RTN_MSG      OUT VARCHAR2                    -- RETURN MESSAGE
) IS
        
    ERR_HANDLER         EXCEPTION;
    LS_SCHEDULE_STAT    JAVA_SCJ_M.SCHEDULE_STAT%TYPE;
    LS_START_TIME       VARCHAR(14 BYTE);
    BEGIN
        SELECT  SCHEDULE_STAT, NVL(LAST_DDL, TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS'))
          INTO  LS_SCHEDULE_STAT, LS_START_TIME
          FROM  JAVA_SCJ_M
         WHERE  COMP_CD     = PSV_COMP_CD
           AND  SCHEDULE_ID = PSV_SCHD_ID; 

        IF LS_SCHEDULE_STAT = '1' THEN
            PR_RTN_CD  := '1000';
            PR_RTN_MSG := '대상스케쥴러 실행중입니다.[ ' || PSV_SCHD_ID || ' ]';
            RAISE ERR_HANDLER;
        END IF;

        UPDATE  JAVA_SCJ_M
           SET  SCHEDULE_STAT   = '1'
             ,  LAST_DDL        = TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
             ,  UPD_DT          = SYSDATE
             ,  UPD_USER        = 'SYSTEM'
         WHERE  COMP_CD     = PSV_COMP_CD
           AND  SCHEDULE_ID = PSV_SCHD_ID;

        OPEN PR_RESULT FOR
            SELECT  LS_START_TIME   AS SCHD_FR_DT
              FROM  DUAL
        ;

        PR_RTN_CD   := '0000';
        PR_RTN_MSG  := 'Success';
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            PR_RTN_CD   := '9999';
            PR_RTN_MSG  := SQLERRM;

END SP_START_JAVA_JOB;

/
