--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SAVE" (
      P_COMP_CD       IN  VARCHAR2,
      P_USER_ID       IN  VARCHAR2,
      P_BRAND_CD      IN  VARCHAR2,
      N_STOR_CD       IN  VARCHAR2,
      P_COMMAND       IN  VARCHAR2,
      N_CUST_ID       IN  VARCHAR2,
      N_CUST_WEB_ID   IN  VARCHAR2,
      N_CUST_NM       IN  VARCHAR2,
      N_CUST_PW       IN  VARCHAR2,
      N_SEX_DIV       IN  VARCHAR2,
      N_LUNAR_DIV     IN  VARCHAR2,
      N_BIRTH_DT      IN  VARCHAR2,
      N_MOBILE        IN  VARCHAR2,
      N_CARD_ID       IN  VARCHAR2,
      N_PUSH_RCV_YN   IN  VARCHAR2,
      N_SMS_RCV_YN    IN  VARCHAR2,
      N_EMAIL         IN  VARCHAR2, 
      N_EMAIL_RCV_YN  IN  VARCHAR2,
      N_ADDR_DIV      IN  VARCHAR2,
      N_ZIP_CD        IN  VARCHAR2,
      N_ADDR1         IN  VARCHAR2,
      N_ADDR2         IN  VARCHAR2, 
      N_OWN_CERTI_DIV IN  VARCHAR2,
      N_REMARKS       IN  VARCHAR2,
      N_LVL_CD        IN  VARCHAR2,
      N_MOD_USER_ID   IN  VARCHAR2,
      N_DI_STR        IN  VARCHAR2,
      O_CUST_ID       OUT VARCHAR2,
      O_RTN_CD        OUT VARCHAR2,
      O_CURSOR        OUT SYS_REFCURSOR
) IS
      EXISTS_CUST EXCEPTION;
      EXISTS_CARD EXCEPTION;
      EXISTS_WEB_ID EXCEPTION;
      v_cust_cnt  NUMBER := 0;
      v_cust_web_cnt  NUMBER := 0;
      v_result_cd VARCHAR2(7) := '1';
      v_card_id_cnt NUMBER := 0;
BEGIN  
      -- ==========================================================================================
      -- Author        :   박동수
      -- Create date   :   2017-11-14
      -- API REQUEST   :   HLS_CRM_IF_0003
      -- Description   :   회원 가입 및 수정		
      -- ==========================================================================================
      IF N_MOBILE IS NULL AND N_CARD_ID IS NULL THEN
        -- N_MOBILE만 있을경우 휴대폰번호로 간편가입하는 대상자
        -- N_CARD_ID만 있을경우 매장 멤버쉽카드(실물카드)로 매장에서 임시가입하는 대상자
        -- 두가지 전부 없으면 오류
        v_result_cd := '190';
      ELSIF P_COMMAND = 'N' THEN 
        -- 1. COMMAND = I : 신규회원 저장
        
        
        -- 같은 휴대폰번호로 신규 회원 등록 불가능 정책 추가
        IF N_MOBILE IS NOT NULL THEN 
          SELECT
            COUNT(*) INTO v_cust_cnt
          FROM C_CUST A
          WHERE A.MOBILE = N_MOBILE;
          
          IF v_cust_cnt > 0 THEN
            OPEN O_CURSOR FOR
            SELECT
              A.CUST_NM, A.CUST_ID, A.MOBILE, A.INST_DT, B.CARD_ID
            FROM C_CUST A, C_CARD B
            WHERE (N_MOBILE IS NULL OR A.MOBILE = N_MOBILE)
              AND A.CUST_ID = B.CUST_ID (+)
              AND (N_CARD_ID IS NULL OR B.CARD_ID = N_CARD_ID);
              
            -- 중복 EXCEPTION 처리  
            RAISE EXISTS_CUST;
          END IF;
        END IF;
        
        -- 같은 휴대폰번호로 신규 회원 등록 불가능 정책 추가 끝
        
        --====추가 수정<손영재 대리>===========================20180628
        -- 사유 : 어플에서 신규 회원등록 할 때 웹 아이디가 중복되는 현상 발생(중복 체크 후 다시 아이디를 수정하고 저장하면 다시 중복체크를 하라는 메세지가 아니라 그대로 저장됨)
        -- 요청 : 김수련과장 (어플도 수정하지만 crm도 수정하도록)
        -- 내용 : 웹 아이디 중복 체크
        IF N_CUST_WEB_ID IS NOT NULL THEN
          SELECT
            COUNT(*) INTO v_cust_web_cnt
          FROM C_CUST A
          WHERE A.CUST_WEB_ID = N_CUST_WEB_ID;
          
          IF v_cust_web_cnt > 0 THEN
            OPEN O_CURSOR FOR
            SELECT
              A.CUST_NM, A.CUST_ID, A.MOBILE, A.INST_DT, B.CARD_ID
            FROM C_CUST A, C_CARD B
            WHERE (N_CUST_WEB_ID IS NULL OR A.CUST_WEB_ID = N_CUST_WEB_ID)
              AND A.CUST_ID = B.CUST_ID (+)
              AND (N_CARD_ID IS NULL OR B.CARD_ID = N_CARD_ID);
              
            -- 중복 EXCEPTION 처리  
            RAISE EXISTS_WEB_ID;
          END IF;
        END IF;        
        --=========================================================
        
        -- POS시스템 신규저장 로직 시작
        SELECT
          --MAX(CUST_ID) + 1
          SQ_CUST_ID.NEXTVAL
          INTO O_CUST_ID
        FROM DUAL;
        
        IF N_CUST_ID IS NOT NULL THEN
          O_CUST_ID := N_CUST_ID;
        END IF;
        
        -- 1-1. 회원정보 생성
        INSERT INTO C_CUST (
          COMP_CD
          ,BRAND_CD
          ,STOR_CD
          ,CUST_ID
          ,CUST_WEB_ID
          ,CUST_NM
          ,SEX_DIV
          ,LUNAR_DIV
          ,BIRTH_DT
          ,MOBILE
          ,PUSH_RCV_YN
          ,SMS_RCV_YN
          ,EMAIL
          ,EMAIL_RCV_YN
          ,ADDR_DIV
          ,ZIP_CD
          ,ADDR1
          ,ADDR2
          ,OWN_CERTI_DIV
          ,REMARKS
          ,LVL_CD
          ,INST_DT
          ,INST_USER
          ,LVL_CHG_DT
          ,JOIN_ROUTE
        ) VALUES (
          P_COMP_CD
          ,P_BRAND_CD
          ,N_STOR_CD
          ,O_CUST_ID
          ,N_CUST_WEB_ID
          ,N_CUST_NM
          ,N_SEX_DIV
          ,N_LUNAR_DIV
          ,NVL(N_BIRTH_DT, '99999999')
          ,N_MOBILE
          ,NVL(N_PUSH_RCV_YN, 'N')
          ,NVL(N_SMS_RCV_YN, 'N')
          ,N_EMAIL
          ,NVL(N_EMAIL_RCV_YN, 'N')
          ,N_ADDR_DIV
          ,N_ZIP_CD
          ,N_ADDR1
          ,N_ADDR2
          ,N_OWN_CERTI_DIV
          ,N_REMARKS
          ,NVL(N_LVL_CD, '000')
          ,SYSDATE
          ,P_USER_ID
          ,SYSDATE
          ,'P'
        );
        
        -- 1-2. 카드번호가 있으면 생성
        IF N_CARD_ID IS NOT NULL THEN
          -- 카드번호가 넘어오면 멤버쉽카드[실물]번호로 해당 멤버의 카드를 생성
          SELECT
            COUNT(1) INTO v_card_id_cnt
          FROM C_CARD
          WHERE COMP_CD = P_COMP_CD
            AND CARD_ID = N_CARD_ID;
          
          IF v_card_id_cnt > 0 THEN
            RAISE EXISTS_CARD;
          END IF;
          
          INSERT INTO C_CARD
          (
            COMP_CD
            ,CARD_ID
            ,CUST_ID
            ,REP_CARD_YN
            ,CARD_STAT
            ,BRAND_CD
            ,STOR_CD
            ,CARD_TYPE
            ,ISSUE_DT
          )VALUES(
            P_COMP_CD
            ,N_CARD_ID
            ,O_CUST_ID
            ,'Y'
            ,'10'
            ,P_BRAND_CD
            ,N_STOR_CD
            ,'1'
            ,TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')
          );
        ELSE
          -- 카드번호가 넘어지않으면 신규카드번호를 채번하여 해당 멤버의 카드를 생성
          INSERT INTO C_CARD
          (
            COMP_CD
            ,CARD_ID
            ,CUST_ID
            ,REP_CARD_YN
            ,CARD_STAT
            ,BRAND_CD
            ,STOR_CD
            ,CARD_TYPE
            ,ISSUE_DT
          )VALUES(
            P_COMP_CD
            ,ENCRYPT(FN_GET_CARD_ID())
            ,O_CUST_ID
            ,'Y'
            ,'10'
            ,P_BRAND_CD
            ,N_STOR_CD
            ,'0'
            ,TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')
          );
        END IF;
      ELSIF P_COMMAND = 'U' THEN
        -- 2. P_COMMAND = U : 회원정보 수정
        UPDATE C_CUST SET
          CUST_WEB_ID = N_CUST_WEB_ID
          ,CUST_NM = N_CUST_NM
          ,SEX_DIV = N_SEX_DIV
          ,LUNAR_DIV = N_LUNAR_DIV
          ,BIRTH_DT = NVL(N_BIRTH_DT, '99999999')
          ,MOBILE = N_MOBILE
          ,PUSH_RCV_YN = N_PUSH_RCV_YN
          ,SMS_RCV_YN = N_SMS_RCV_YN
          ,EMAIL = N_EMAIL
          ,EMAIL_RCV_YN = N_EMAIL_RCV_YN
          ,ADDR_DIV = N_ADDR_DIV
          ,ZIP_CD = N_ZIP_CD
          ,ADDR1 = N_ADDR1
          ,ADDR2 = N_ADDR2
          ,OWN_CERTI_DIV = N_OWN_CERTI_DIV
          ,REMARKS = N_REMARKS
          ,LVL_CD = NVL(N_LVL_CD, '000')
          ,UPD_DT = SYSDATE
          ,UPD_USER = P_USER_ID
        WHERE COMP_CD = P_COMP_CD
          AND BRAND_CD = P_BRAND_CD
          --AND STOR_CD = N_STOR_CD
          AND CUST_ID = N_CUST_ID;
          
        -- 2-1 수정된 정보 없을 시 오류메시지 RETURN
        IF SQL%ROWCOUNT < 1 THEN
          Dbms_Output.Put_Line('수정하려는 대상을 찾을 수 없습니다.');
          v_result_cd := '170';
        END IF;
      
        O_CUST_ID := N_CUST_ID;
      ELSE
        -- P_COMMAND 정보가 N또는Y가 아닐경우 오류 RETURN
        v_result_cd := '110';
      END IF;
       
      O_RTN_CD := v_result_cd;
EXCEPTION
    WHEN EXISTS_CUST THEN
        ROLLBACK;
        O_RTN_CD  := '160';
        dbms_output.put_line(SQLERRM) ;
    WHEN EXISTS_WEB_ID THEN
        ROLLBACK;
        O_RTN_CD  := '160';
        dbms_output.put_line(SQLERRM) ;
    WHEN EXISTS_CARD THEN
        ROLLBACK;
        O_RTN_CD  := '240';
        dbms_output.put_line(SQLERRM) ;
    WHEN OTHERS THEN
        ROLLBACK;
        O_RTN_CD  := '110';
        dbms_output.put_line(SQLERRM) ;
END API_C_CUST_SAVE;

/
