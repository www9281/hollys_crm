--------------------------------------------------------
--  DDL for Procedure C_CUST_DUP_CHECK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_DUP_CHECK" (
    P_COMP_CD       IN  VARCHAR2,
    P_CUST_ID       IN  VARCHAR2,
    --P_CUST_NM       IN  VARCHAR2,
    P_MOBILE        IN  VARCHAR2,
    O_DUP_CNT       OUT NUMBER,
    O_REFUND_CNT    OUT NUMBER,
    O_CASH          OUT NUMBER
)IS
BEGIN
    ------------------------------- 회원정보 수정 ------------------------------
     
     ------ 아이디중복체크, 환불완료되지 않은 건, 잔액이 남아 있는 건 조회
     SELECT ( 
          SELECT COUNT(*)
            FROM C_CUST
           WHERE COMP_CD = P_COMP_CD 
             AND CUST_ID != P_CUST_ID
             --AND CUST_NM = encrypt(P_CUST_NM)
             AND MOBILE  = encrypt(REPLACE(P_MOBILE,'-'))
             AND CUST_STAT IN ('1','2','3','7','8')
        ) as DUP_CNT
       ,( 
          SELECT COUNT(*) 
            FROM C_CARD
           WHERE COMP_CD = P_COMP_CD
             AND CUST_ID = P_CUST_ID
             AND ( CARD_STAT = '92' AND REFUND_STAT != '02' )
        ) as REFUND_CNT
       ,(
          SELECT COUNT(*) 
            FROM C_CARD
           WHERE COMP_CD = P_COMP_CD
             AND CUST_ID = P_CUST_ID
             AND (SAV_CASH - USE_CASH ) > 0
        ) as CASH
     INTO O_DUP_CNT, O_REFUND_CNT, O_CASH
     FROM DUAL;
END C_CUST_DUP_CHECK;

/
