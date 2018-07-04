--------------------------------------------------------
--  DDL for Procedure C_ACADEMY_ERL_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_ACADEMY_ERL_SELECT" (
   N_ERL_IDX      IN VARCHAR2,
   N_CAMPUS_DIV   IN VARCHAR2,
   N_PAY_METHOD   IN VARCHAR2,
   N_PAY_STATUS   IN VARCHAR2,
   N_CONN_DIV     IN VARCHAR2,
   N_CONN_TEXT    IN VARCHAR2,
   N_START_DT     IN VARCHAR2,
   N_END_DT       IN VARCHAR2,
   P_LANGUAGE_TP  IN VARCHAR2,
   O_CURSOR       OUT SYS_REFCURSOR
)IS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-22
    -- Description   :   아카데미 수강신청내역 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      ROWNUM AS RNUM
      ,A.ERL_IDX
      ,A.ERL_CLS_NM
      ,DECODE(A.CAMPUS_DIV, '01', '서울', '02', '부산') AS CAMPUS_DIV
      ,A.CUST_ID
      ,A.CUST_WEB_ID
      ,A.CUST_NM
      ,A.CUST_NM_ENG
      ,A.MOBILE
      ,A.EMAIL
      ,A.PRE_ERL_YN
      ,TO_CHAR(A.ERL_DT, 'YYYY-MM-DD HH24:MI:SS') AS ERL_DT
      ,TO_CHAR(NVL(A.LEC_AMT, 0), '999,999,999,999,999') AS LEC_AMT
      ,TO_CHAR(NVL(A.PAY_REQ_AMT, 0), '999,999,999,999,999') AS PAY_REQ_AMT
      ,TO_CHAR(NVL(A.PAY_USE_POINT, 0), '999,999,999,999,999') AS PAY_USE_POINT
      ,TO_CHAR(NVL(A.PAY_AMT, 0), '999,999,999,999,999') AS PAY_AMT
      ,A.PAY_METHOD
      ,GET_COMMON_CODE_NM('C9000', A.PAY_METHOD, P_LANGUAGE_TP) AS PAY_METHOD_NM
      ,PAY_STEP_METHOD
      ,A.PAY_STATUS
      ,GET_COMMON_CODE_NM('C10000', A.PAY_STATUS, P_LANGUAGE_TP) AS PAY_STATUS_NM
      ,TO_CHAR(A.PAY_DT, 'YYYY-MM-DD HH24:MI:SS') AS PAY_DT
    FROM C_ACADEMY_ERL A--, C_ACADEMY_CLS B
    WHERE (N_ERL_IDX IS NULL OR A.ERL_IDX = N_ERL_IDX)
      AND (N_CAMPUS_DIV IS NULL OR A.CAMPUS_DIV = N_CAMPUS_DIV)
      AND (N_PAY_METHOD IS NULL OR A.PAY_METHOD = N_PAY_METHOD)
      AND (N_PAY_STATUS IS NULL OR A.PAY_STATUS = N_PAY_STATUS)
      AND (N_CONN_DIV IS NULL
                OR  (N_CONN_DIV = '01' AND A.ERL_CLS_NM LIKE '%' || N_CONN_TEXT || '%')
                OR  (N_CONN_DIV = '02' AND A.CUST_NM LIKE '%' || N_CONN_TEXT || '%')
                OR  (N_CONN_DIV = '03' AND A.MOBILE LIKE '%' || N_CONN_TEXT || '%')
                OR  (N_CONN_DIV = '04' AND A.EMAIL LIKE '%' || N_CONN_TEXT || '%')
          )
      AND (N_START_DT IS NULL OR TO_CHAR(A.ERL_DT, 'YYYYMMDD') >= N_START_DT)
      AND (N_END_DT IS NULL OR TO_CHAR(A.ERL_DT, 'YYYYMMDD') <= N_END_DT)
      AND A.USE_YN = 'Y'
      --AND A.CLS_IDX = B.CLS_IDX
      --AND B.USE_YN = 'Y'
    ORDER BY INST_DT ASC
    ;
    
END C_ACADEMY_ERL_SELECT;

/
