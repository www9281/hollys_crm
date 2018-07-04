--------------------------------------------------------
--  DDL for Procedure C_CUST_CARD_CHARGE_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CARD_CHARGE_INSERT" (
    P_COMP_CD         IN  VARCHAR2,
    P_BRAND_CD        IN  VARCHAR2,
    P_T5_CARD_ID      IN  VARCHAR2,
    P_T5_CRG_DT       IN  VARCHAR2,
    P_T5_CRG_FG       IN  VARCHAR2,
    P_T5_CRG_DIV      IN  VARCHAR2,
    P_T5_CRG_SCOPE    IN  VARCHAR2,
    P_T5_CRG_AMT      IN  VARCHAR2,
    P_T5_ORG_CHANNEL  IN  VARCHAR2,
    P_T5_STOR_CD      IN  VARCHAR2,
    P_T5_CRG_REMARKS  IN  VARCHAR2,
    P_MY_USER_ID 	    IN  VARCHAR2
) IS
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [카드충전조정] 정보 저장
    -- Test          :   C_CUST_CARD_CHARGE_INSERT
    -- ==========================================================================================
      INSERT INTO C_CARD_CHARGE_HIS (
                COMP_CD
            ,   CARD_ID
            ,   CRG_DT
            ,   CRG_SEQ
            ,   CRG_FG
            ,   CRG_DIV
            ,   CRG_SCOPE
            ,   CRG_AUTO_DIV
            ,   CRG_AMT
            ,   CHANNEL
            ,   ORG_CHANNEL
            ,   BRAND_CD
            ,   STOR_CD
            ,   REMARKS
            ,   TRN_CARD_ID
            ,   APPR_DT
            ,   APPR_TM
            ,   SELF_CRG_YN
            ,   USE_YN 
            ,   INST_DT 
            ,   INST_USER 
            ,   UPD_DT 
            ,   UPD_USER
      ) VALUES (
                P_COMP_CD
            ,   encrypt(P_T5_CARD_ID)
            ,   P_T5_CRG_DT
            ,   SQ_PCRM_SEQ.NEXTVAL
            ,   P_T5_CRG_FG
            ,   P_T5_CRG_DIV
            ,   P_T5_CRG_SCOPE
            ,   '1'
            ,   CASE WHEN P_T5_CRG_FG IN ('2', '3') THEN TO_NUMBER(P_T5_CRG_AMT) * (-1) ELSE TO_NUMBER(P_T5_CRG_AMT) END
            ,   '9'
            ,   P_T5_ORG_CHANNEL
            ,   P_BRAND_CD
            ,   NVL(P_T5_STOR_CD, '106500')
            ,   P_T5_CRG_REMARKS
            ,   NULL
            ,   P_T5_CRG_DT
            ,   TO_CHAR(SYSDATE, 'HH24MISS')
            ,   'N'
            ,   'Y'
            ,   SYSDATE
            ,   P_MY_USER_ID
            ,   SYSDATE
            ,   P_MY_USER_ID
      );
      
END C_CUST_CARD_CHARGE_INSERT;

/
