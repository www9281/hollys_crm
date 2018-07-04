--------------------------------------------------------
--  DDL for Procedure SP_CREATE_RANDOM_CARD2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CREATE_RANDOM_CARD2" 
(
  PSV_COMP_CD             IN    VARCHAR2,             -- 회사코드
  PSV_TYPE                IN    VARCHAR2,             -- 발행TYPE(A:101, B:102, C:103, D:501)
  PSV_SEQ                 IN    VARCHAR2,             -- 차수. 예) 001, 002
  PSV_CNT                 IN    NUMBER,               -- 발행개수
  asRetVal                OUT   NUMBER,               -- 처리코드
  asRetMsg                OUT   VARCHAR2              -- 처리Message
) IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_CREATE_RANDOM_CARD
--  Description      : 카드실물 발행을 위한 카드 ID 생성
--  Ref. Table       : C_RANDOM_CARD
--  최초 3자리(Type 구분) + 3자리(차수) + 9자리(카드번호 + 1자리(check digit)
--------------------------------------------------------------------------------
--  Create Date      :  2015-05-25 
--  Modify Date      : 
--------------------------------------------------------------------------------
  CURSOR CUR_1 IS
      SELECT CARD_TYPE
        FROM C_CARD_TYPE
       WHERE CARD_TYPE = PSV_TYPE;
   
  cnt         NUMBER := 0;
  cardCnt     NUMBER := 0;
  nRECCNT     NUMBER := 0;
  
  seq         VARCHAR(6)   := '';
  dupCheck    NUMBER       := 0;
  cardId      VARCHAR2(16) := ''; 
BEGIN
  SELECT COUNT(*) INTO nRECCNT 
  FROM   C_CARD_TYPE
  WHERE  CARD_TYPE = PSV_TYPE;
       
  IF nRECCNT != 0 THEN
     IF LENGTH(PSV_SEQ) = 3 THEN
        FOR MYREC IN CUR_1 LOOP
            BEGIN
              FOR cnt in 1..PSV_CNT LOOP
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
                            SELECT MYREC.CARD_TYPE || PSV_SEQ  SEQ
                                 , MYREC.CARD_TYPE || PSV_SEQ || ROUND(dbms_random.value(111111111, 999999999))  CARD_ID
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
              END LOOP;
            END;
        END LOOP;
        
        COMMIT;
        
        asRetVal := '000';
        asRetMsg := 'OK'; 
     ELSE 
        asRetVal := '111';
        asRetMsg := '차수는 3자리를 입력하셔야 합니다.';
     END IF;
  ELSE
     asRetVal := '101';
     asRetMsg := '올바른 카드 TYPE을 입력하세요!';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
       asRetVal := SQLCODE;
       asRetMsg := SQLERRM;
       
       ROLLBACK;
       RETURN;
END;

/
