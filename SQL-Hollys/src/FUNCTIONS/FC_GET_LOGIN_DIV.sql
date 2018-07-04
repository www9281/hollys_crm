--------------------------------------------------------
--  DDL for Function FC_GET_LOGIN_DIV
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_LOGIN_DIV" (
                                                  PSV_COMP_CD IN VARCHAR2, -- Company Code
                                                  PSV_PARAM   IN VARCHAR2  -- Input Parameter
                                                 )
RETURN CHAR IS

lsUserDiv  VARCHAR2(1);   -- 로그인 유저 구분 [ 본사, 점포 ]
lsToDt     VARCHAR2(10);  -- 본사, 점포 로그인 유저에 따라 조회기간 MAX 설정 컬럼을 리턴한다.

BEGIN

    -- 로그인 사용자가 본사[H], 점포[S] 값이 들어오며 NULL일경우 [N] 값을 셋팅한다.
    SELECT NVL(SUBSTR(SUBSTRB(PSV_PARAM, INSTRB(PSV_PARAM, 'LOGIN'), LENGTHB(PSV_PARAM)), 14, 1), 'N') INTO lsUserDiv
      FROM DUAL;

    -- 로그인 사용자 구분 값이 NULL 일 경우 2년전까지 데이터를 읽을 수 있다.
    SELECT TO_CHAR(ADD_MONTHS(SYSDATE, DECODE(lsUserDiv, 'H', -VAL_N1, 'S', -VAL_N2, 'N', -24)), 'YYYYMMDD') INTO lsToDt
      FROM COMMON
     WHERE COMP_CD  = PSV_COMP_CD
       AND CODE_TP  = '01435'
       AND CODE_CD  = '210' ;

  RETURN lsToDt;

EXCEPTION  WHEN OTHERS THEN
   Null;

END FC_GET_LOGIN_DIV;

/
