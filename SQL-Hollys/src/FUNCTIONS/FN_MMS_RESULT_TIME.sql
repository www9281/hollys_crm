--------------------------------------------------------
--  DDL for Function FN_MMS_RESULT_TIME
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_MMS_RESULT_TIME" /* MMS 전송결과 시간 취득 */          
(          
    IMSGKEY     IN  VARCHAR2 ,               -- 메세지키          
    YYYYMM     IN  VARCHAR2                  -- 발송년월          
) RETURN DATE IS      
    vRSLT           MMS_MSG.RSLTDATE%TYPE;         
    ls_tbl_name     VARCHAR2(2000) := 'MMS_LOG_';     -- 테이블 이름      
    v_sql           VARCHAR2(1000);      
    ll_rec_cnt      NUMBER := 0;         
BEGIN 
    IF IMSGKEY IS NULL THEN 
        vRSLT := ''; 
    END IF; 
     
    IF YYYYMM IS NULL THEN 
        vRSLT := ''; 
    END IF; 
         
     
    ls_tbl_name := ls_tbl_name||YYYYMM;    
        
    /* MMS 전송이력 테이블 존재 체크 */        
    SELECT COUNT(*) INTO ll_rec_cnt    
    FROM   TAB    
    WHERE  TABTYPE = 'TABLE'    
    AND    TNAME   = ls_tbl_name;    
        
    v_sql := 'SELECT RSLTDATE FROM MMS_MSG WHERE MSGKEY = '||IMSGKEY;    
        
    IF ll_rec_cnt > 0 THEN    
        v_sql := v_sql||' UNION ALL SELECT RSLTDATE FROM '||ls_tbl_name||' WHERE MSGKEY = '||IMSGKEY;      
    END IF;    
        
    EXECUTE IMMEDIATE v_sql INTO vRSLT;  
        
                                     
    RETURN vRSLT;          
END ;

/
