--------------------------------------------------------
--  DDL for Function FN_GET_CARD_ID
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_CARD_ID" 
RETURN VARCHAR2 IS
  v_temp_card_id  VARCHAR(15);
  v_digit         VARCHAR(1);
  v_sum_val       NUMBER := 0;
  v_card_id       VARCHAR(16);
BEGIN
  -- DIGIT을 제외한 기본 카드번호 조회
  SELECT
    '2012' || (SELECT NVL(MAX(CARD_TYPE), '001') FROM C_CARD_TYPE WHERE CATEGORY_DIV = 'HC1' AND CATEGORY_CD = '001' AND USE_YN = 'Y') || LPAD(SEQ_CARD_ID.NEXTVAL, 8, '0') into v_temp_card_id
  FROM DUAL;
  
  -- Check Digit 생성로직 (멤버십 카드번호 체계 문서 참고) 위에서 조회한 기본 카드번호를 한글자씩 잘라서 계산 후 Check Digit 생성
  FOR card IN (SELECT
                SUBSTR(v_temp_card_id, LEVEL, 1) AS CARD_ID
                , DECODE(MOD(LEVEL, 2), 0, '1', '8') AS CALC
              FROM DUAL
              CONNECT BY LEVEL <= LENGTH(v_temp_card_id)) 
  LOOP
    FOR i IN 1..length(to_char(card.CARD_ID * card.CALC))
    LOOP
      v_sum_val := v_sum_val + TO_NUMBER(SUBSTR(TO_CHAR(card.CARD_ID * card.CALC), i, 1));
    END LOOP;
  END LOOP;
  
  -- 계산완료된 값을 가지고 Check Digit최종 생성
  IF SUBSTR(v_sum_val, LENGTH(v_sum_val), 1) = '0' THEN
    v_digit := '0';
  ELSE
    v_digit := TO_CHAR(10-TO_NUMBER(SUBSTR(v_sum_val, LENGTH(v_sum_val), 1)));
  END IF;
  
  -- DIGIT을 제외한 기본 카드번호와 Check Digit를 합하여 카드번호 완성
  v_card_id := v_temp_card_id || v_digit;
  dbms_output.put_line(v_card_id);
  RETURN v_card_id;
END FN_GET_CARD_ID;

/
