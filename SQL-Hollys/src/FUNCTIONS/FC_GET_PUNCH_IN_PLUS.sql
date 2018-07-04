--------------------------------------------------------
--  DDL for Function FC_GET_PUNCH_IN_PLUS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_PUNCH_IN_PLUS" 
(
          pYYYYMMDDHH24MI IN VARCHAR2 -- 출근일자사분
)
RETURN VARCHAR 
IS
---------------------------------------------------------------------------------------------------
--  Procedure Name   : FC_GET_PUNCH_IN_PLUS
--  Description           : 출근시간 이전은 (30분단위 후)로 조정
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

        -- 
        -- 출근시간 10:42 → 11:00
        IF nHH24 > 30 THEN 
            vDate := TO_CHAR(TO_DATE(SUBSTR(vDate, 0, length(vDate)-2) || '00', 'YYYYMMDDHH24MI')+1/24,'YYYYMMDDHH24MI'); -- 31분~59분 처리 
        ELSIF nHH24 >0 AND nHH24 < 30 THEN
            vDate := SUBSTR(vDate, 0, length(vDate)-2) || '30'; -- 1분~29분 처리
        END IF;        
   END IF;

  RETURN vDate;

 EXCEPTION  WHEN OTHERS THEN
  RETURN NULL;

END FC_GET_PUNCH_IN_PLUS;

/
