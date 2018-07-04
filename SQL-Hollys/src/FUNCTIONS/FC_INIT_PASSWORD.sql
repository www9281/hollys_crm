--------------------------------------------------------
--  DDL for Function FC_INIT_PASSWORD
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_INIT_PASSWORD" 
(  
  v_comp_cd    IN   STRING  --  회사코드  
, v_cust_id    IN   STRING  --  회원 ID  
) RETURN VARCHAR2 IS  
--------------------------------------------------------------------------------  
--  Procedure Name   : FC_INIT_PASSWORD  
--  Description      : 임시 비밀번호를 생성하여 회원 마스터에 저장하고 리턴  
--  Ref. Table       : C_CUST 회원 마스터  
--------------------------------------------------------------------------------  
--  Create Date      : 2015-01-20 엠즈씨드 CRM PJT  
--  Modify Date      : 2015-01-20  
--------------------------------------------------------------------------------  
  ls_cust_pw      C_CUST.CUST_PW%TYPE;  -- 회원 비밀번호  
    
  PRAGMA AUTONOMOUS_TRANSACTION;  
BEGIN  
  ls_cust_pw := DBMS_RANDOM.STRING('U', 4)|| CHR(64)|| CHR(ROUND(dbms_random.value(49,57))) || DBMS_RANDOM.STRING('U', 4) ;   
    
  BEGIN  
    UPDATE C_CUST  
       SET CUST_PW  = GET_SHA1_STR(ls_cust_pw)  
         , PW_DIV   = 'Y'  
         , UPD_DT   = SYSDATE  
         , UPD_USER = v_cust_id  
     WHERE COMP_CD  = v_comp_cd  
       AND CUST_ID  = v_cust_id;  

    UPDATE C_CUST_REST
       SET CUST_PW  = GET_SHA1_STR(ls_cust_pw)  
         , PW_DIV   = 'Y'  
         , UPD_DT   = SYSDATE  
         , UPD_USER = v_cust_id  
     WHERE COMP_CD  = v_comp_cd  
       AND CUST_ID  = v_cust_id;  
         
    COMMIT;  
      
  EXCEPTION  
    WHEN OTHERS THEN  
         ROLLBACK;  
         RAISE_APPLICATION_ERROR(-20001, SQLERRM);  
  END;  
    
  RETURN ls_cust_pw;  
    
EXCEPTION  
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR(-20001, SQLERRM);  
END FC_INIT_PASSWORD;

/
