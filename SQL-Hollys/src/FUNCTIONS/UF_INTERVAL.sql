--------------------------------------------------------
--  DDL for Function UF_INTERVAL
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."UF_INTERVAL" 
(
  psv_fr_dt    IN   STRING, -- Date
  psv_to_dt    IN   STRING  -- Date
 )
  RETURN  VARCHAR2
  IS
  li_intv        NUMBER(14,9);
  li_tm        NUMBER(5);
  li_min        NUMBER(2);
  ls_intv      VARCHAR2(20);
BEGIN
    IF psv_fr_dt is null or  psv_to_dt is null or length(psv_fr_dt) <> 12 OR  length(psv_to_dt) <> 12 THEN 
       RETURN '';
    END IF;

    li_intv := (to_date (psv_to_dt, 'yyyymmddhh24mi' ) -  to_date (psv_fr_dt , 'yyyymmddhh24mi' )) * 24;

    CASE 
      WHEN li_intv = 0 THEN
         ls_intv := '';
         return ls_intv;
      WHEN li_intv < 0 THEN
           li_intv :=  li_intv * - 1;
         ls_intv := '-';
      ELSE
           ls_intv := '';
     END CASE;



    li_tm     := trunc(li_intv);
    li_min  := round( (li_intv - li_tm) * 60 )  ;

    ls_intv := ls_intv || case when  li_tm =  0 then '' else  to_char(li_tm) || '시간' end    || ' ' ||
               case when  li_min =  0 then '' else  to_char(li_min) || '분' end ;

    return ls_intv;


EXCEPTION
  WHEN OTHERS THEN
      RETURN '';
END ;

/
