--------------------------------------------------------
--  DDL for Procedure SP_CREATE_PL_GOAL_006
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CREATE_PL_GOAL_006" 
/******************************************************************************
   NAME     : SP_CREATE_PL_GOAL_006
   PURPOSE  :손익실적 생성 프로시져(토리돌전용)

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_CREATE_PL_GOAL_006
      Sysdate:         
      Date and Time:   
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
(    
    PSV_COMP_CD     IN   VARCHAR2,
    PSV_GOAL_YM     IN   VARCHAR2
)
IS
    -- 실적대상 점포 조회
    CURSOR CUR_S IS
        SELECT  S.COMP_CD
             ,  S.BRAND_CD
             ,  S.STOR_CD
          FROM  STORE       S
             ,  COMMON      C
         WHERE  S.COMP_CD   = C.COMP_CD
           AND  S.STOR_TP   = C.CODE_CD
           AND  S.COMP_CD   = PSV_COMP_CD
           AND  S.USE_YN    = 'Y'
           AND  C.CODE_TP   = '00565'
           AND  C.USE_YN    = 'Y'
           AND  INSTR('S', C.VAL_C1, 1) > 0
         ;

    MYREC1           CUR_S%ROWTYPE;
    liv_rec_cnt     NUMBER(9) := 0;
    liv_msg_code    NUMBER(9) := 0;
    lsv_msg_text    VARCHAR2(200);

    ERR_HANDLER     EXCEPTION;
BEGIN
    liv_msg_code    := '0';
    lsv_msg_text    := '';

    -- 매출계정 실적 등록
    FOR MYREC1 IN CUR_S LOOP
        SP_ANAL1200M2(MYREC1.COMP_CD, MYREC1.BRAND_CD, MYREC1.STOR_CD, 'BATCHJOB', PSV_GOAL_YM, liv_msg_code, lsv_msg_text);
    END LOOP;

    COMMIT;

    RETURN;
EXCEPTION
    WHEN ERR_HANDLER THEN
        ROLLBACK;
    WHEN OTHERS THEN
        ROLLBACK;
END;

/
