--------------------------------------------------------
--  DDL for Procedure PROMOTION_FRQ_SEQ_CREATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_FRQ_SEQ_CREATE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	프리퀀시 시퀀스 생성 
-- Test			:	exec PROMOTION_FRQ_SEQ_CREATE '016', '102', '13'
-- ==========================================================================================
        O_RTN_CD            OUT  VARCHAR2,
        O_FRQ_SEQ           OUT  VARCHAR2
) AS
        v_result_cd VARCHAR2(7) := '1'; --성공 
BEGIN  

        SELECT FRQ_SEQ.NEXTVAL
        INTO O_FRQ_SEQ
        FROM DUAL;
 
        O_RTN_CD := v_result_cd; 
        dbms_output.put_line(SQLERRM);

EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);
END PROMOTION_FRQ_SEQ_CREATE;

/
