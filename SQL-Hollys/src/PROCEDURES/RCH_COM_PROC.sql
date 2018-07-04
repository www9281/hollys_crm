--------------------------------------------------------
--  DDL for Procedure RCH_COM_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_COM_PROC" (
    P_RCH_NO     IN  VARCHAR2,
    P_STOR_CD    IN  VARCHAR2,
    P_QR_NO      IN  VARCHAR2,
    N_CUST_ID    IN  VARCHAR2,
    N_MOBILE     IN  VARCHAR2,
    N_COUPON_CD  IN  VARCHAR2,
    O_CURSOR     OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-08
    -- Description   :   API 홈페이지 고객설문 완료처리
    -- ==========================================================================================
    
    --------------------- 매장별 설문완료 건수 증가처리
    IF N_CUST_ID IS NOT NULL THEN
      -- 회원
      INSERT INTO RCH_QR_ISSUE (
        RCH_NO, RCH_QR_SEQ, ISSUE_DT, STOR_CD, MONTH_MEM_ISSUE, QR_NO, CUST_ID, COUPON_CD
      ) VALUES (
        P_RCH_NO, SQ_RCH_QR_SEQ.NEXTVAL, SYSDATE, P_STOR_CD, 1, P_QR_NO, N_CUST_ID, N_COUPON_CD
      );
    ELSE
      -- 일반
      INSERT INTO RCH_QR_ISSUE (
        RCH_NO, RCH_QR_SEQ, ISSUE_DT, STOR_CD, MONTH_STAND_ISSUE, QR_NO, COUPON_CD, MOBILE
      ) VALUES (
        P_RCH_NO, SQ_RCH_QR_SEQ.NEXTVAL, SYSDATE, P_STOR_CD, 1, P_QR_NO, N_COUPON_CD, N_MOBILE
      );
    END IF;
  
    
      
END RCH_COM_PROC;

/
