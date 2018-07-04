--------------------------------------------------------
--  DDL for Function FN_GET_FORMAT_HP_NO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_FORMAT_HP_NO" (
    arg_hp_no IN VARCHAR2
)
RETURN VARCHAR2 IS

   str_replace VARCHAR2(7)  := '-/()[] ';
   str_temp    VARCHAR2(40) := arg_hp_no;

BEGIN

   -- 특수문자 제거
   FOR i IN 1..LENGTH(str_replace) LOOP
      str_temp := replace(str_temp , SUBSTR( str_replace ,i ,1 ) );
   END LOOP;

   -- NULL 체크
   IF str_temp IS NULL THEN
      RETURN arg_hp_no;
   END IF;

   -- 01X 로 시작하는지 체크
   IF SUBSTR( str_temp ,1 ,2) <> '01' THEN
      RETURN arg_hp_no;
   END IF;

   -- 숫자가 아닌 문자가 있는지 체크
   FOR i IN 1..LENGTH(str_temp) LOOP
      IF (ASCII(SUBSTR( str_temp ,i ,1 )) < 48 ) THEN
         RETURN arg_hp_no;
      ELSIF (ASCII(SUBSTR( str_temp ,i ,1 )) > 57 ) THEN
         RETURN arg_hp_no;
      END IF;
   END LOOP;

   -- 10자리인 경우 ( 01X-XXX-XXXX)
   IF LENGTH(str_temp) =  10 THEN
      str_temp := SUBSTR(str_temp, 1,3 ) || '-' || SUBSTR(str_temp,4,3) || '-' || SUBSTR(str_temp,7,4)  ;
      RETURN str_temp;

   -- 11자리인 경우 ( 01X-XXXX-XXXX)
   ELSIF LENGTH(str_temp) = 11 THEN
      str_temp := SUBSTR(str_temp, 1,3 ) || '-' || SUBSTR(str_temp,4,4) || '-' || SUBSTR(str_temp,8,4)  ;
      RETURN str_temp;

   -- 잘못된 번호 쳬계
   ELSE
      RETURN arg_hp_no;
   END IF;


END FN_GET_FORMAT_HP_NO;

/
