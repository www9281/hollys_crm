--------------------------------------------------------
--  DDL for Procedure C_CARD_PLA_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_PLA_INSERT" 
AS
    v_card_cnt NUMBER;
    v_cust_id VARCHAR2(30);
BEGIN
  
  FOR CUR IN (SELECT * FROM C_CARD_PLA)
  LOOP
    SELECT COUNT(*) INTO v_card_cnt
    FROM C_CARD WHERE CARD_ID = CUR.ENC_CARD_ID;
    
    IF v_card_cnt < 1 THEN
      SELECT
        SQ_CUST_ID.NEXTVAL
        INTO v_cust_id
      FROM DUAL;
      
      -- 1.회원정보 생성
      INSERT INTO C_CUST
          (  COMP_CD                   -- PK.회사코드
           , BRAND_CD                  -- PK.영업조직
           , STOR_CD                   -- PK.점포코드
           , CUST_ID                   -- PK.회원번호[POS고객번호 숫자7자리 ex)3623609]
           , CUST_NM                   -- 회원명
           , LUNAR_DIV                 -- 음양구분[L:음력, S:양력]
           , BIRTH_DT                  -- 생일
           , MOBILE                    -- 핸드폰
           , PUSH_RCV_YN               -- PUSH 알림여부(이벤트, 쿠폰)[Y, N]
           , SMS_RCV_YN                -- SMS 수신동의[Y, N]
           , EMAIL                     -- 이메일
           , EMAIL_RCV_YN              -- 이메일 수신동의[Y, N]
           , LVL_CD                    -- 현재 회원등급[C_CUST_LVL]
           , CUST_STAT                 -- 회원상태[1:대기, 2:정상, 3:중지, 8:휴면(미사용), 9:탈퇴]
           , USE_YN                    -- 사용여부
           , INST_DT                   -- 등록일자
           , INST_USER                 -- 등록자
           , UPD_DT                    -- 수정일자
           , UPD_USER                  -- 수정자
           , JOIN_ROUTE
          )
        VALUES
          (  '016'                     -- 016:할리스에프엔비
           , '100' -- 100:할리스커피
           , '180250'
           , v_cust_id
           , ''     -- 암호화처리
           , 'L' -- 음양구분 0->L / 1->S 변환
           , '99999999' -- 생년월일 '-'제거
           , ''     -- 암호화처리 및 '-'제거
           , 'N'  -- PUSH 알림여부 차후처리 필요
           , 'N' -- SMS 수신동의 0->N / 1->Y 변환
           , '' -- 이메일
           , 'N' -- 이메일 수신동의 0->N / 1->Y 변환
           , '000'
           , '1' -- 회원상태
           , 'Y'
           , SYSDATE
           , 'SYSTEM'
           , SYSDATE
           , 'SYSTEM'
           , 'P'
          );
      
      -- 2.카드정보생성
      INSERT INTO C_CARD (
        COMP_CD
        ,CARD_ID
        ,CUST_ID
        ,CARD_STAT
        ,ISSUE_DIV
        ,ISSUE_DT
        ,BRAND_CD
        ,STOR_CD
        ,REP_CARD_YN
        ,USE_YN
        ,INST_DT
        ,INST_USER
        ,UPD_DT
        ,UPD_USER
        ,CARD_TYPE
      ) VALUES (
        '016'
        ,CUR.ENC_CARD_ID
        ,v_cust_id
        ,'10'
        ,'0'
        ,TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')
        ,'100'
        ,'180250'
        ,'Y'
        ,'Y'
        ,SYSDATE
        ,'SYSTEM'
        ,SYSDATE
        ,''
        ,'1'
      );
      
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;

/
