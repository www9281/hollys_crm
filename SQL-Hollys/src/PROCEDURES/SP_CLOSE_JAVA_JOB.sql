--------------------------------------------------------
--  DDL for Procedure SP_CLOSE_JAVA_JOB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CLOSE_JAVA_JOB" 
(
    PSV_COMP_CD     IN  VARCHAR2,                   -- 회사코드
    PSV_LANG_TP     IN  VARCHAR2,                   -- 언어코드
    PSV_SCHD_ID     IN  VARCHAR2,                   -- 스케쥴러ID
    PSV_FR_DT       IN  VARCHAR2,                   -- 실행시작시간[YYYYMMDDHH24MISS]
    PSV_ERR_CD      IN  VARCHAR2,                   -- 에러코드
    PSV_ERR_MSG     IN  VARCHAR2,                   -- 에러메세지
    PR_RTN_CD       OUT VARCHAR2,                   -- RETURN CODE
    PR_RTN_MSG      OUT VARCHAR2                    -- RETURN MESSAGE
) IS
        
    BEGIN
        UPDATE  JAVA_SCJ_M
           SET  SCHEDULE_STAT   = '0'
             ,  LAST_DDL        = (CASE WHEN PSV_ERR_CD <> '0000' THEN PSV_FR_DT ELSE LAST_DDL END)
             ,  UPD_DT          = SYSDATE
             ,  UPD_USER        = 'SYSTEM'
         WHERE  COMP_CD         = PSV_COMP_CD
           AND  SCHEDULE_ID     = PSV_SCHD_ID;

        IF PSV_ERR_CD <> '1000' THEN
            INSERT  INTO JAVA_SCJ_L
            (
                    COMP_CD
                 ,  SCHEDULE_ID
                 ,  SCHEDULE_FR_DATE
                 ,  SCHEDULE_TO_DATE
                 ,  RESULT_CD
                 ,  RESULT_MSG
                 ,  INST_DT
                 ,  INST_USER
            ) VALUES (
                    PSV_COMP_CD
                 ,  PSV_SCHD_ID
                 ,  PSV_FR_DT
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                 ,  PSV_ERR_CD
                 ,  PSV_ERR_MSG
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                 ,  'SYSTEM'
            );
        END IF;

        PR_RTN_CD   := '0000';
        PR_RTN_MSG  := 'Success';
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            PR_RTN_CD   := '9999';
            PR_RTN_MSG  := SQLERRM;

END SP_CLOSE_JAVA_JOB;

/
