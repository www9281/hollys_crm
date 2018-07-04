--------------------------------------------------------
--  DDL for Function FC_GET_PUNCH_OUT_MINUS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_PUNCH_OUT_MINUS" 
(
          pYYYYMMDDHH24MI IN VARCHAR2 -- 퇴근일자시  
)
RETURN VARCHAR 
IS
---------------------------------------------------------------------------------------------------
--  Procedure Name   : FC_GET_PUNCH_OUT_MINUS
--  Description           : 출근시간 이후는 (30분단위 전)으로 조정(매일유업 근태 추가요청사항용)
---------------------------------------------------------------------------------------------------
--  Create Date          : 2014-08-28
--  Create Programer : 김영범
--  Modify Date      : 
--  Modify Programer :              
--  Ref. Table       :  
---------------------------------------------------------------------------------------------------   

    vDate         VARCHAR2(12) := '';   
    nHH24        NUMBER(2) := 0;   

BEGIN
    vDate := pYYYYMMDDHH24MI;

    IF  vDate IS NOT NULL THEN
        IF LENGTH(vDate) = 8 THEN
           vDate := vDate || '0000';
        END IF;   

        nHH24 :=  TO_NUMBER(SUBSTR(vDate, -2, 2));

        -- 출근시간 이후는 (30분단위 전)으로 조정
        -- 퇴근시간 21:12 → 21:00 
        IF nHH24 > 30 THEN 
            vDate := SUBSTR(vDate, 0, length(vDate)-2) || '30'; -- 1분~29분 처리        
        ELSIF nHH24 >0 AND nHH24 < 30 THEN
            vDate := SUBSTR(vDate, 0, length(vDate)-2) || '00'; -- 31분~59분 처리 
        END IF;        
   END IF;

  RETURN vDate;

 EXCEPTION  WHEN OTHERS THEN
  RETURN NULL;

END FC_GET_PUNCH_OUT_MINUS;

/
