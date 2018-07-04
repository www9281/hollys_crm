--------------------------------------------------------
--  DDL for Procedure C_CUST_CARD_AUTO_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CARD_AUTO_UPDATE" (
    P_COMP_CD      IN  VARCHAR2,
    P_CARD_ID      IN  VARCHAR2,
    P_CRG_FRDT     IN  VARCHAR2,
    P_CRG_TODT     IN  VARCHAR2,
    P_CRG_AMT      IN  VARCHAR2,
    N_TERM_DIV     IN  VARCHAR2,
    P_MIN_AMT      IN  VARCHAR2,
    N_REPEAT_DT    IN  VARCHAR2,
    P_MY_USER_ID 	 IN  VARCHAR2
) IS
BEGIN
--------------------------------- 카드수정탭 자동충전정보 저장 ----------------------------------
    MERGE INTO C_CARD_AUTO
    USING DUAL
    ON      (
                    COMP_CD = P_COMP_CD
                AND CARD_ID = encrypt(P_CARD_ID) 
            ) 
    WHEN MATCHED THEN 
        UPDATE
        SET     CRG_FRDT = P_CRG_FRDT
             ,  CRG_TODT = P_CRG_TODT
             ,  CRG_AMT  = P_CRG_AMT
             ,  TERM_DIV = N_TERM_DIV
             ,  MIN_AMT  = P_MIN_AMT
             ,  REPEAT_DT= N_REPEAT_DT
    WHEN NOT MATCHED THEN
    INSERT (
            COMP_CD,CARD_ID,CRG_FRDT,CRG_TODT,CRG_AMT,TERM_DIV,MIN_AMT,REPEAT_DT,INST_DT,INST_USER,UPD_DT,UPD_USER
           )
    VALUES (
                P_COMP_CD
             ,  encrypt(P_CARD_ID)
             ,  P_CRG_FRDT
             ,  P_CRG_TODT
             ,  P_CRG_AMT
             ,  N_TERM_DIV
             ,  P_MIN_AMT
             ,  N_REPEAT_DT
             ,  SYSDATE
             ,  P_MY_USER_ID
             ,  SYSDATE
             ,  P_MY_USER_ID
           );
    
END C_CUST_CARD_AUTO_UPDATE;

/
