--------------------------------------------------------
--  DDL for Procedure BATCH_TRANS_POS_ALLSUM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_TRANS_POS_ALLSUM" 
IS
  V_YMD       VARCHAR2(8  );
  B_LASTDAY   BOOLEAN;
  
  V_DD        VARCHAR2(2  );
  V_YYMM      VARCHAR2(6  );
  V_RETC      VARCHAR2(512);

  RET_EXIT    EXCEPTION;
  
  --전일기준 30일 일자를 구한다.
  CURSOR CUR_YMD IS
    SELECT TO_CHAR(SYSDATE-LEVEL, 'YYYYMMDD')    YMD
         , DECODE(SYSDATE-1,SYSDATE-LEVEL,'T'
                                         ,DECODE(SYSDATE - LEVEL,LAST_DAY(SYSDATE-LEVEL),'T','F'))
                                                 LAST_DAY
    FROM   DUAL
    CONNECT BY (SYSDATE+(LEVEL-31)) < SYSDATE
    ORDER BY 1
    ;
  
BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-05-23
  -- Description   :   POS DB의 정보이관 프로시저(일/월집계)
  --                     일집계는 시스템일자 기준으로  30일전부터 이관한다.
  --                     월집계는 당월과 15일 이전이면 전월까지 이관한다.   
  --                   회원 상품별 일/월집계
  --                     일집계는 시스템일자 기준으로  30일전부터 생성한다.
  --                     월집계는 당월과 15일 이전이면 전월까지 생성한다.   
  -- ==========================================================================================
  
  V_RETC := NULL;                         
  
  ---------------------------------------------------------------------------------------------
  --일집계 이관...  
  ---------------------------------------------------------------------------------------------
  FOR REC_YMD IN CUR_YMD LOOP
    V_YMD := REC_YMD.YMD;
    IF REC_YMD.LAST_DAY = 'T' THEN 
      B_LASTDAY := TRUE;
    ELSE
      B_LASTDAY := FALSE;  
    END IF;  
 
    BEGIN      
      BATCH_TRANS_POS_DAYSUM(V_YMD, V_RETC);
      DBMS_OUTPUT.PUT_LINE('(일집계 이관-'||V_YMD||')RESULT=>'||V_RETC);
    EXCEPTION
      WHEN OTHERS THEN
        V_RETC := '일집계 이관-' || V_YMD
               || '('
               || SQLERRM
               || ')';
        RAISE RET_EXIT;
    END;    
 
    BEGIN      
      BATCH_CUST_ITEM_SUMMARY(V_YMD, B_LASTDAY, V_RETC);
      DBMS_OUTPUT.PUT_LINE('(회원 상품별 일집계-'||V_YMD||'-'||REC_YMD.LAST_DAY||')RESULT=>'||V_RETC);
    EXCEPTION
      WHEN OTHERS THEN
        V_RETC := '회원 상품별 일집계-' || V_YMD
               || '('
               || SQLERRM
               || ')';
        RAISE RET_EXIT;
    END;    
  END LOOP;

  
  ---------------------------------------------------------------------------------------------
  --월집계 이관...  
  ---------------------------------------------------------------------------------------------
  SELECT TO_CHAR(SYSDATE,'DD')
  INTO   V_DD 
  FROM   DUAL
  ;
  --15일 이전이면 전달집계를 수행한다.
  IF TO_NUMBER(V_DD) <= 15 THEN 
    --전월집계...
    SELECT TO_CHAR(ADD_MONTHS(SYSDATE,-1),'YYYYMM')
    INTO   V_YYMM 
    FROM   DUAL
    ;
  
    BEGIN      
      BATCH_TRANS_POS_MONSUM(V_YYMM, V_RETC);
      DBMS_OUTPUT.PUT_LINE('(월집계 이관-'||V_YYMM||')RESULT=>'||V_RETC);
    EXCEPTION
      WHEN OTHERS THEN
        V_RETC := '월집계 이관-' || V_YYMM
               || '('
               || SQLERRM
               || ')';
        RAISE RET_EXIT;
    END;
  END IF;
               
  --당월집계...
  SELECT TO_CHAR(SYSDATE,'YYYYMM')
  INTO   V_YYMM 
  FROM   DUAL
  ;
  
  BEGIN      
    BATCH_TRANS_POS_MONSUM(V_YYMM, V_RETC);
    DBMS_OUTPUT.PUT_LINE('(월집계 이관-'||V_YYMM||')RESULT=>'||V_RETC);
  EXCEPTION
    WHEN OTHERS THEN
      V_RETC := '월집계 이관-' || V_YYMM
             || '('
             || SQLERRM
             || ')';
      RAISE RET_EXIT;
  END;

EXCEPTION
  WHEN RET_EXIT THEN
       DBMS_OUTPUT.PUT_LINE(V_RETC);
  WHEN OTHERS   THEN
       DBMS_OUTPUT.PUT_LINE(V_RETC);
  
END BATCH_TRANS_POS_ALLSUM;

/
