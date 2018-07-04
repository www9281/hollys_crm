--------------------------------------------------------
--  DDL for Procedure HQ_USER_CONNHIS_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HQ_USER_CONNHIS_SAVE" (
    P_CONN_CD     IN VARCHAR2,
    P_CONN_ID     IN VARCHAR2,
    N_VIEW_ID     IN VARCHAR2,
    P_MY_USER_IP  IN VARCHAR2
) AS
    v_his_seq VARCHAR2(20);
    v_user_nm VARCHAR2(30 BYTE);
    v_cust_nm VARCHAR2(100) := '';
BEGIN
    -- 신규 키값 생성
    SELECT 
      TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || LPAD(SEQ_HQ_USER_CONNHIS.NEXTVAL, '11', '0') 
      INTO v_his_seq
    FROM DUAL;
    
    -- 접속자 정보 조회
    SELECT
      USER_NM
      INTO v_user_nm
    FROM HQ_USER
    WHERE USER_ID = P_CONN_ID
      AND ROWNUM = 1;
    
    -- 열람회원 정보 조회
    IF N_VIEW_ID IS NOT NULL THEN
      SELECT
        DECRYPT(CUST_NM)
        INTO v_cust_nm
      FROM C_CUST
      WHERE CUST_ID = N_VIEW_ID
        AND ROWNUM = 1;
    END IF;
    
    -- 이력 등록
    INSERT INTO HQ_USER_CONNHIS (
      HIST_NO
      ,CONN_CD
      ,CONN_NM
      ,CONN_ID
      ,VIEW_NM
      ,VIEW_ID
      ,CONN_DT
      ,CONN_IP
    ) VALUES (
      v_his_seq
      ,P_CONN_CD
      ,v_user_nm
      ,P_CONN_ID 
      ,v_cust_nm
      ,N_VIEW_ID
      ,SYSDATE
      ,P_MY_USER_IP
    );
END HQ_USER_CONNHIS_SAVE;

/
