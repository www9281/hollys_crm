--------------------------------------------------------
--  DDL for Procedure STAT_LOG_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STAT_LOG_SAVE" (
  PI_PROC_NM  IN   VARCHAR2,
  PI_PROC_NO  IN   VARCHAR2,
  PI_LOG_MSG  IN   VARCHAR2,
  PI_LOG_TFV  IN   VARCHAR2,
  PO_RETC     OUT  VARCHAR2
)
IS
BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-06-11
  -- Description   :   배치작업 LOGGING
  -- ==========================================================================================
    BEGIN

      INSERT INTO STAT_LOG
           ( LOG_DT, LOG_SEQ, PROC_NM, PROC_NO, LOG_MSG, LOG_TFV )  --1, 2, 3, 4, 5, 6
      SELECT TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')                    --1
           , NVL(MAX(LOG_SEQ),0)+1                                  --2
           , NVL(PI_PROC_NM,'.')                                     --3
           , NVL(PI_PROC_NO,'.')                                     --4
           , NVL(PI_LOG_MSG,'.')                                     --5               
           , NVL(PI_LOG_TFV,'.')                                     --6
      FROM   STAT_LOG
      WHERE  LOG_DT = TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')
      ;
      COMMIT;
      PO_RETC := 'OK';     
      
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '배치로그저장 실패'
                || '('
                || SQLERRM
                || ')';
    END;

END STAT_LOG_SAVE;

/
