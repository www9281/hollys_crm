--------------------------------------------------------
--  DDL for Procedure API_SMS_REJECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_SMS_REJECT" (
    
    P_REJECTNUMBER IN  VARCHAR2,
    N_CID          IN  VARCHAR2, 
    P_REJECTDATE   IN  VARCHAR2,
    P_USER_ID      IN  VARCHAR2,
    O_RTN_CD       OUT VARCHAR2
) IS
      v_result  VARCHAR2(50);
      v_seq     NUMBER ;
      v_cnt     NUMBER ;
      v_cnt2    NUMBER ;
      
BEGIN
    v_seq := SQ_SMS_SEQ.NEXTVAL;
    v_result := 'SUCCESS';
    
     
    SELECT COUNT(*) INTO v_cnt
    FROM C_CUST
    WHERE MOBILE = ENCRYPT(P_REJECTNUMBER)
    ;
    
    SELECT COUNT(*) INTO v_cnt
    FROM C_CUST_REST
    WHERE MOBILE = ENCRYPT(P_REJECTNUMBER)
    ;
    
    IF v_cnt = 0 AND  v_cnt2 = 0  THEN
        v_result := 'NO DATA FOUND' ;
    
    ELSIF v_cnt = 0 AND  v_cnt2 <> 0  THEN
        v_result := 'CUST_REST SUCCESS';
    ELSE 
        v_result := 'SUCCESS';
    END IF;
 

    UPDATE C_CUST 
    SET 
        SMS_RCV_YN = 'N'
    WHERE MOBILE = ENCRYPT(P_REJECTNUMBER)
    ;
           
    INSERT INTO SMS_REJECT(
         SEQ
        ,REJECTNUMBER
        ,CID
        ,REJECTDATE
        ,RESULT
        ,USER_ID
        ,INST_DT
    )VALUES(
         v_seq
        ,P_REJECTNUMBER
        ,N_CID
        ,TO_DATE(P_REJECTDATE,'YYYY-MM-DD HH24:MI:SS')
        ,v_result
        ,P_USER_ID
        ,SYSDATE
    )
    ;
       
    O_RTN_CD := '1';
    
EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2';
        v_result  := SUBSTR(SQLERRM,0,49);
        
        MERGE INTO SMS_REJECT
        USING DUAL
        ON (SEQ = v_seq)
        WHEN MATCHED THEN
            UPDATE 
            SET 
                RESULT = v_result
        WHEN NOT MATCHED THEN
                       
            INSERT(
                 SEQ
                ,REJECTNUMBER
                ,CID
                ,REJECTDATE
                ,RESULT
                ,USER_ID
                ,INST_DT
            )VALUES(
                 v_seq
                ,SUBSTR(P_REJECTNUMBER,0,20)
                ,SUBSTR(N_CID,0,30)
                ,TO_DATE(P_REJECTDATE,'YYYY-MM-DD HH24:MI:SS')
                ,v_result
                ,SUBSTR(P_USER_ID,0,7)
                ,SYSDATE
            )
            ;
        
END API_SMS_REJECT;

/
