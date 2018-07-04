--------------------------------------------------------
--  DDL for Procedure C_ACADEMY_LEC_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_ACADEMY_LEC_SAVE" (
    N_LEC_IDX     IN VARCHAR2,
    P_LEC_NM      IN VARCHAR2,
    P_LEC_AMT     IN VARCHAR2,
    P_LEC_CONTENT IN VARCHAR2,
    P_CAMPUS_DIV  IN VARCHAR2,
    P_VIEW_YN     IN VARCHAR2,
    P_MY_USER_ID  IN VARCHAR2,
    O_LEC_IDX     OUT VARCHAR2
)IS 
    v_lec_seq   NUMBER(12,0);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-21
    -- Description   :   아카데미 강좌 등록
    -- ==========================================================================================
  IF N_LEC_IDX IS NULL THEN
    SELECT
      LPAD(SEQ_LEC_IDX.NEXTVAL, 12, 0)
      INTO v_lec_seq
    FROM DUAL;
    
    INSERT INTO C_ACADEMY_LEC (
      LEC_IDX
      ,LEC_NM
      ,LEC_AMT
      ,LEC_CONTENT
      ,CAMPUS_DIV
      ,VIEW_YN
      ,USE_YN
      ,INST_DT
      ,INST_USER
    ) VALUES (
      v_lec_seq
      ,P_LEC_NM
      ,P_LEC_AMT
      ,P_LEC_CONTENT
      ,P_CAMPUS_DIV
      ,P_VIEW_YN
      ,'Y'
      ,SYSDATE
      ,P_MY_USER_ID
    );
    
    O_LEC_IDX := v_lec_seq;
  ELSE
    UPDATE C_ACADEMY_LEC SET
      LEC_NM = P_LEC_NM
      ,LEC_AMT = P_LEC_AMT
      ,LEC_CONTENT = P_LEC_CONTENT
      ,CAMPUS_DIV = P_CAMPUS_DIV
      ,VIEW_YN = P_VIEW_YN
      ,UPD_DT = SYSDATE
      ,UPD_USER = P_MY_USER_ID
    WHERE LEC_IDX = N_LEC_IDX;
    
    O_LEC_IDX := N_LEC_IDX;
  END IF;

END C_ACADEMY_LEC_SAVE;

/
