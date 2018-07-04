--------------------------------------------------------
--  DDL for Function FN_CREATE_RANDOM_ECARD
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_CREATE_RANDOM_ECARD" 
( 
  PSV_COMP_CD             IN    VARCHAR2,            -- 회사코드
  PSV_TYPE                IN    VARCHAR2,            -- 발행TYPE(E-A:201, E-B:202, E-C:203)
  PSV_SEQ                 IN    VARCHAR2             -- 차수. 예) 001, 002
      
) RETURN VARCHAR2 IS
--------------------------------------------------------------------------------
--  FUNCTION Name   : FN_CREATE_RANDOM_ECARD
--  Description      : e-gift카드발행을 위한 카드번호 채번
--  Ref. Table       : C_RANDOM_CARD
--  최초 3자리(Type 구분) + 3자리(차수) + 9자리(카드번호 + 1자리(check digit)
--------------------------------------------------------------------------------
--  Create Date      :  2015-11-09
--  Modify Date      :  
--------------------------------------------------------------------------------
  seq         VARCHAR(6)   := '';
  dupCheck    NUMBER       := 0;
  cardId      VARCHAR2(16) := '';

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  BEGIN
    LOOP
      seq      := '';
      cardId   := '';
      dupCheck := 0;

      -- Type별 차수 카드 생성
      SELECT X.SEQ, X.CARD_ID || MOD( SUBSTR(X.CARD_ID, 1, 1)*1 + SUBSTR(X.CARD_ID, 2, 1)*3 + SUBSTR(X.CARD_ID, 3, 1)*1 + SUBSTR(X.CARD_ID, 4, 1)*3 + SUBSTR(X.CARD_ID, 5, 1)*1 + SUBSTR(X.CARD_ID, 6, 1)*3
                                    + SUBSTR(X.CARD_ID, 7, 1)*1 + SUBSTR(X.CARD_ID, 8, 1)*3 + SUBSTR(X.CARD_ID, 9, 1)*1 + SUBSTR(X.CARD_ID,10, 1)*3 + SUBSTR(X.CARD_ID,11, 1)*1 + SUBSTR(X.CARD_ID,12, 1)*3
                                    + SUBSTR(X.CARD_ID,13, 1)*1 + SUBSTR(X.CARD_ID,14, 1)*3 + SUBSTR(X.CARD_ID,15, 1)*1, 10)
        INTO seq, cardId
        FROM (
              SELECT PSV_TYPE || PSV_SEQ  SEQ
                   , PSV_TYPE || PSV_SEQ || ROUND(dbms_random.value(111111111, 999999999))  CARD_ID
                FROM DUAL
             ) X;

      SELECT COUNT(*)
        INTO dupCheck
        FROM C_RANDOM_CARD
       WHERE SEQ     = seq
         AND CARD_ID = cardId;

      EXIT WHEN dupCheck = 0;
    END LOOP;

    INSERT INTO C_RANDOM_CARD
    VALUES (seq,  cardId, SYSDATE, 'ADMIN');
  END;

  COMMIT;

  -- EXCEPTION WHEN OTHERS THEN ROLLBACK;

  RETURN cardId;

END;

/
