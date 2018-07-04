--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SAVE_WEB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SAVE_WEB" (
      P_COMP_CD       IN  VARCHAR2,
      P_USER_ID       IN  VARCHAR2,
      P_BRAND_CD      IN  VARCHAR2,
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
      N_SMS_RCV_YN    IN  VARCHAR2, 
      N_EMAIL         IN  VARCHAR2,
      N_EMAIL_RCV_YN  IN  VARCHAR2,
      N_ZIP_CD        IN  VARCHAR2,
      N_ADDR1         IN  VARCHAR2,
      N_ADDR2         IN  VARCHAR2,
      N_LVL_CD        IN  VARCHAR2,
      N_OWN_CERTI_DIV IN  VARCHAR2,
      N_MOD_USER_ID   IN  VARCHAR2, 
      N_DI_STR        IN  VARCHAR2,
      N_CASH_BILL_DIV IN  VARCHAR2,
      N_ISSUE_MOBILE  IN  VARCHAR2,
      N_ISSUE_BUSI_NO IN  VARCHAR2,
      O_CUST_ID       OUT VARCHAR2,
      O_RTN_CD        OUT VARCHAR2
) IS 
      v_result_cd VARCHAR2(7) := '1';
      v_card_id_cnt NUMBER := 0;
      v_cust_stat VARCHAR(10);
      v_card_id VARCHAR2(100);
      v_lvl_cd  VARCHAR2(10);
      v_sav_cnt NUMBER;
      v_simple_cust_id  VARCHAR2(30);
      v_simple_cust_cnt NUMBER;
BEGIN  
      -- ==========================================================================================
      -- Author        :   박동수
      -- Create date   :   2017-12-26
      -- API REQUEST   :   HLS_CRM_IF_00
      -- Description   :   회원 가입 및 수정		
      -- ==========================================================================================
      IF P_COMMAND = 'N' THEN 
        -- 1. COMMAND = I : 신규회원 저장
        -- 홈페이지 신규저장 로직
        SELECT
          SQ_CUST_ID.NEXTVAL
          INTO O_CUST_ID
        FROM DUAL;
        
        -- 신규회원정보 저장
        INSERT INTO C_CUST (
          COMP_CD,BRAND_CD,STOR_CD,CUST_ID,CUST_WEB_ID,CUST_NM,CUST_PW
          ,SEX_DIV,LUNAR_DIV,BIRTH_DT,MOBILE,SMS_RCV_YN,EMAIL
          ,EMAIL_RCV_YN,ZIP_CD,ADDR1,ADDR2,OWN_CERTI_DIV,LVL_CD,INST_DT,INST_USER,DI_STR
          ,CASH_BILL_DIV,ISSUE_MOBILE,ISSUE_BUSI_NO,LVL_CHG_DT,CUST_STAT,LAST_CHG_PWD,JOIN_DT,LAST_LOGIN_DT,JOIN_ROUTE
        ) VALUES (
          P_COMP_CD,P_BRAND_CD,'106500',O_CUST_ID,TRIM(N_CUST_WEB_ID),ENCRYPT(N_CUST_NM),CASE WHEN N_CUST_PW IS NOT NULL THEN FN_SHAENCRYPTOR(N_CUST_PW) ELSE '' END
          ,N_SEX_DIV,N_LUNAR_DIV,NVL(N_BIRTH_DT, '99999999'),ENCRYPT(REPLACE(N_MOBILE, '-', '')),NVL(N_SMS_RCV_YN, 'N'),N_EMAIL
          ,NVL(N_EMAIL_RCV_YN, 'N'),N_ZIP_CD,N_ADDR1,N_ADDR2,N_OWN_CERTI_DIV,NVL(N_LVL_CD, '101'),SYSDATE,N_MOD_USER_ID,N_DI_STR
          ,N_CASH_BILL_DIV,ENCRYPT(REPLACE(N_ISSUE_MOBILE, '-', '')),N_ISSUE_BUSI_NO,SYSDATE,'2',SYSDATE,TO_CHAR(SYSDATE, 'YYYYMMDD'),SYSDATE,'W'
        );
        
        -- 신규 카드정보 생성
        INSERT INTO C_CARD
        (
          COMP_CD,CARD_ID,CUST_ID,REP_CARD_YN,CARD_STAT,BRAND_CD
          ,STOR_CD,INST_USER,CARD_TYPE,ISSUE_DT
        )VALUES(
          P_COMP_CD,ENCRYPT(FN_GET_CARD_ID()),O_CUST_ID,'Y','10',P_BRAND_CD
          ,'106500',N_MOD_USER_ID,'0',TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')
        );
        
      ELSIF P_COMMAND = 'U' THEN
        -- 2. P_COMMAND = U : 회원정보 수정
        SELECT
          A.CUST_STAT INTO v_cust_stat
        FROM C_CUST A
        WHERE A.CUST_ID = N_CUST_ID;
        
        -- 등급정보가 변경될수 있으므로 변수보관
        v_lvl_cd := N_LVL_CD;
        
        IF v_cust_stat = '1' THEN
          UPDATE C_CUST SET
            JOIN_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
            ,LVL_CHG_DT = SYSDATE
          WHERE COMP_CD = P_COMP_CD
            AND BRAND_CD = P_BRAND_CD
            AND CUST_ID = N_CUST_ID;
            
          -- 대기회원에서 정상회원으로 가입하는 가입자는 기존 왕관을 카운트하여 등급을 배정하고 모두 사용처리한다.
          IF N_CARD_ID IS NOT NULL AND N_CARD_ID LIKE '1998%' THEN
            v_card_id := N_CARD_ID;
          ELSE
            SELECT
              MAX(CARD_ID) INTO v_card_id
            FROM C_CARD
            WHERE CUST_ID = N_CUST_ID
              AND REP_CARD_YN = 'Y'
              AND USE_YN ='Y';
          END IF;
          
          -- 적립왕관 조회
          SELECT  NVL(SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE), 0) INTO v_sav_cnt
          FROM    C_CARD              CRD
                , C_CARD_SAV_USE_HIS  HIS
          WHERE   CRD.COMP_CD  = HIS.COMP_CD
          AND     CRD.CARD_ID  = HIS.CARD_ID
          AND     CRD.COMP_CD  = '016'
          AND     CRD.CARD_ID  = v_card_id
          AND     HIS.SAV_MLG != HIS.USE_MLG
          AND     HIS.LOS_MLG_YN  = 'N';
          
          IF v_sav_cnt >= 12 THEN
            FOR CUR IN 1..(TRUNC(v_sav_cnt/12))
            LOOP
              C_CUST_CREATE_MEM_COUPON(N_CUST_ID, O_RTN_CD);
            END LOOP;
            
          END IF;
--          -- 기존 적립한 왕관을 모두 사용처리
--          UPDATE  C_CARD_SAV_USE_HIS
--          SET     USE_MLG     = SAV_MLG
--                , UPD_DT      = SYSDATE
--                , UPD_USER    = 'SYSTEM'
--          WHERE   COMP_CD = '016'
--          AND     CARD_ID = v_card_id;
--          
--          -- 적립한 내역에 해당하는 등급 획득 및 설정
--          SELECT MAX(LVL_CD) INTO v_lvl_cd FROM C_CUST_LVL
--          WHERE LVL_STD_STR <= v_sav_cnt
--            AND LVL_STD_END > v_sav_cnt;
        END IF;
        
        IF N_CUST_PW IS NOT NULL THEN
          UPDATE C_CUST SET
            CUST_PW = FN_SHAENCRYPTOR(N_CUST_PW)
          WHERE COMP_CD = P_COMP_CD
            AND BRAND_CD = P_BRAND_CD
            AND CUST_ID = N_CUST_ID;
        END IF;
        
        UPDATE C_CUST SET
          CUST_WEB_ID = TRIM(N_CUST_WEB_ID)
          ,CUST_NM = ENCRYPT(N_CUST_NM)
          ,SEX_DIV = N_SEX_DIV
          ,LUNAR_DIV = N_LUNAR_DIV
          ,BIRTH_DT = NVL(N_BIRTH_DT, '99999999')
          ,MOBILE = ENCRYPT(REPLACE(N_MOBILE, '-', ''))
          ,SMS_RCV_YN = N_SMS_RCV_YN
          ,EMAIL = N_EMAIL
          ,EMAIL_RCV_YN = N_EMAIL_RCV_YN
          ,ZIP_CD = N_ZIP_CD
          ,ADDR1 = N_ADDR1
          ,ADDR2 = N_ADDR2
          ,OWN_CERTI_DIV = N_OWN_CERTI_DIV
          ,LVL_CD = DECODE(LVL_CD, '000', '101', LVL_CD)
          ,CUST_STAT = '2'
          ,CASH_BILL_DIV = N_CASH_BILL_DIV
          ,ISSUE_MOBILE = ENCRYPT(REPLACE(N_ISSUE_MOBILE, '-', ''))
          ,ISSUE_BUSI_NO = N_ISSUE_BUSI_NO
          ,DI_STR = N_DI_STR
          ,UPD_DT = SYSDATE
          ,UPD_USER = N_MOD_USER_ID
        WHERE COMP_CD = P_COMP_CD
          AND BRAND_CD = P_BRAND_CD
          AND CUST_ID = N_CUST_ID;
          
        -- 2-1 수정된 정보 없을 시 오류메시지 RETURN
        IF SQL%ROWCOUNT < 1 THEN
          Dbms_Output.Put_Line('수정하려는 대상을 찾을 수 없습니다.');
          v_result_cd := '170';
        END IF;
        
--        -- 2-1. 기존회원정보 조회 (상태가 : 1일 경우 오프라인회원의 통합으로 간주한다)
--        SELECT
--          A.CUST_STAT INTO v_cust_stat
--        FROM C_CUST A
--        WHERE A.CUST_ID = N_CUST_ID;
--        
--        IF v_cust_stat = '1' AND N_CARD_ID IS NOT NULL THEN
--          -- 2-2-1 대기회원 (실물카드가입)
--          DBMS_OUTPUT.PUT_LINE('2');
--          
--        ELSE
--          -- 2-2-2 일반회원정보 수정 
--          DBMS_OUTPUT.PUT_LINE('3');
--          
--        END IF;
--        
        O_CUST_ID := N_CUST_ID;
      ELSE
        -- P_COMMAND 정보가 N또는Y가 아닐경우 오류 RETURN
        v_result_cd := '110';
      END IF;
       
      O_RTN_CD := v_result_cd;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        O_RTN_CD  := '110';
        dbms_output.put_line(SQLERRM) ;
END API_C_CUST_SAVE_WEB;

/
