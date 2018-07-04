--------------------------------------------------------
--  DDL for Procedure C_ACADEMY_LEC_CLS_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_ACADEMY_LEC_CLS_SAVE" (
    P_LEC_IDX       IN VARCHAR2,
    N_CLS_IDX       IN VARCHAR2,
    P_CLS_DIV      IN VARCHAR2,
    P_CLS_TERM      IN VARCHAR2,
    P_CLS_NM        IN VARCHAR2,
    P_CLS_OPEN_DT   IN VARCHAR2,
    P_CLS_PROC_DIV  IN VARCHAR2,
    P_MY_USER_ID    IN VARCHAR2
)IS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-21
    -- Description   :   아카데미 강좌 클래스 내용 등록
    -- ==========================================================================================
    
    MERGE INTO C_ACADEMY_CLS A
    USING DUAL
    ON (A.LEC_IDX = P_LEC_IDX
        AND A.CLS_IDX = N_CLS_IDX)
    WHEN MATCHED THEN
      UPDATE SET
        CLS_DIV = P_CLS_DIV
        ,CLS_TERM = P_CLS_TERM
        ,CLS_NM = P_CLS_NM
        ,CLS_OPEN_DT = P_CLS_OPEN_DT
        ,CLS_PROC_DIV = P_CLS_PROC_DIV
        ,UPD_DT = SYSDATE
        ,UPD_USER = P_MY_USER_ID
    WHEN NOT MATCHED THEN
      INSERT (
        CLS_IDX
        ,LEC_IDX
        ,CLS_DIV
        ,CLS_TERM
        ,CLS_NM
        ,CLS_OPEN_DT
        ,CLS_PROC_DIV
        ,USE_YN
        ,INST_DT
        ,INST_USER
      ) VALUES (
        LPAD(SEQ_CLS_IDX.NEXTVAL, 12, 0)
        ,P_LEC_IDX
        ,P_CLS_DIV
        ,P_CLS_TERM
        ,P_CLS_NM
        ,P_CLS_OPEN_DT
        ,P_CLS_PROC_DIV
        ,'Y'
        ,SYSDATE
        ,P_MY_USER_ID
      );

END C_ACADEMY_LEC_CLS_SAVE;

/
