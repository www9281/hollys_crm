--------------------------------------------------------
--  DDL for Function UF_LUN2SOL
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."UF_LUN2SOL" 
(
  ps_lun_dt     IN   STRING, --  Lunar date
  ps_yun_div    IN   STRING  --  윤달구분 0-평달, 1-윤달
) RETURN VARCHAR2 IS
  ls_sol_dt    VARCHAR2(8);
--------------------------------------------------------------------------------
--  Procedure Name   : UF_LUN2SOL
--  Description      : 음력을 양력으로 변환
--  Ref. Table       : LUN_SOL 양음 변환테이블[CRM]
--------------------------------------------------------------------------------
--  Create Date      : 2014-12-01
--  Modify Date      : 2014-12-01
--------------------------------------------------------------------------------
BEGIN
  BEGIN
    SELECT SOL_DT 
      INTO ls_sol_dt
      FROM LUN_SOL
     WHERE LUN_DT = ps_lun_dt
       AND YUN_DIV = ps_yun_div;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         ls_sol_dt := '00000000';
    WHEN OTHERS THEN 
         ls_sol_dt := '00000000'; --RAISE;
  END;

  RETURN ls_sol_dt;

EXCEPTION
  WHEN OTHERS THEN
       RETURN '00000000';
END UF_LUN2SOL;

/
