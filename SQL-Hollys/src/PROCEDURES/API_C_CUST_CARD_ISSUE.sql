--------------------------------------------------------
--  DDL for Procedure API_C_CUST_CARD_ISSUE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_CARD_ISSUE" 
(
  P_USER_ID     IN  VARCHAR2,
  P_CUST_ID     IN  VARCHAR2,
  N_CARD_ID     IN  VARCHAR2,
  O_CARD_ID     OUT VARCHAR2,
  O_RTN_CD      OUT VARCHAR2
) IS
  v_card_cnt  NUMBER;
  v_card_cust_id  VARCHAR2(100) := '';
  v_card_id  VARCHAR2(100) := '';
  v_cust_stat VARCHAR2(1);
  v_lvl_cd VARCHAR2(10);
  v_lvl_cd2 VARCHAR2(10);
  v_tot_sav_mlg NUMBER;
  NOT_FOUND_CARD EXCEPTION;
  ALREADY_EXISTS_CARD EXCEPTION;
  ALREADY_USE_CARD EXCEPTION;
BEGIN  
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-22
    -- API REQUEST   :   HLS_CRM_IF_0072
    -- Description   :   멤버쉽 카드발급
    -- ==========================================================================================
    O_RTN_CD := '1';
    
    SELECT
      COUNT(B.CARD_ID) INTO v_card_cnt
    FROM C_CUST A, C_CARD B
    WHERE A.CUST_ID = B.CUST_ID
      AND A.CUST_ID = P_CUST_ID
      AND B.REP_CARD_YN = 'Y'
    ;
    
    -- 이미 해당회원에 할당된 카드가 있음
    IF v_card_cnt > 0 THEN
      RAISE ALREADY_USE_CARD;
    END IF;
    
    IF N_CARD_ID IS NOT NULL THEN
      -- 1.카드번호가 있는경우(기존 사용하던 실물카드가 있는경우)
      
      -- 1-1. 등록된 카드인지조회, 등록된카드에 지정된 회원이 있는지 조회
      SELECT
        COUNT(*), MAX(A.CUST_ID), MAX(B.CUST_STAT), MAX(B.LVL_CD) INTO v_card_cnt, v_card_cust_id, v_cust_stat, v_lvl_cd
      FROM C_CARD A, C_CUST B
      WHERE A.CARD_ID = ENCRYPT(N_CARD_ID)
        AND A.CUST_ID = B.CUST_ID
        AND A.REP_CARD_YN = 'Y';
      
      -- 1-2 등록되지 않은 카드
      IF v_card_cnt < 1 THEN
        RAISE NOT_FOUND_CARD;
      END IF;
      
      -- 1-3 이미 해당카드에 회원이 지정되어있는경우
      IF v_card_cust_id IS NOT NULL AND v_cust_stat != '1' THEN
        RAISE ALREADY_EXISTS_CARD;
      END IF;
      
      -- 1-4 실물카드 정보 이전
      UPDATE C_CARD SET
        CUST_ID = ''
      WHERE CARD_ID = ENCRYPT(N_CARD_ID);
      
      UPDATE C_CARD SET
        CUST_ID = P_CUST_ID
        ,UPD_DT = SYSDATE
        ,UPD_USER = P_USER_ID
      WHERE CARD_ID = ENCRYPT(N_CARD_ID);
      
      -- 1-5 통합이 완료되고 남은 계정은 탈퇴처리한다.
      DELETE FROM C_CUST
      WHERE CUST_ID = v_card_cust_id;
      
      -- 1-6 통합 후 왕관 정보를 조회하여 등급산정 후 실물카드왕관은 사용처리
      SELECT  
        NVL(SUM(HIS.SAV_MLG), 0)
        INTO v_tot_sav_mlg
      FROM    C_CUST              CST
            , C_CARD              CRD
            , C_CARD_SAV_USE_HIS  HIS
      WHERE   CST.COMP_CD  = CRD.COMP_CD
        AND   CST.CUST_ID  = CRD.CUST_ID
        AND   CRD.COMP_CD  = HIS.COMP_CD
        AND   CRD.CARD_ID  = HIS.CARD_ID
        AND   CRD.COMP_CD  = '016'
        AND   CRD.CUST_ID  = P_CUST_ID
        AND   HIS.LOS_MLG_YN  = 'N';
      
      SELECT MAX(LVL_CD) INTO v_lvl_cd2 FROM C_CUST_LVL
      WHERE LVL_STD_STR <= v_tot_sav_mlg
        AND LVL_STD_END > v_tot_sav_mlg
        AND LVL_CD <> '000'
        AND LVL_CD >= v_lvl_cd;
      
      -- 1-7 통합된 후 등급의 변화가 있는 경우 등급변경
      IF v_lvl_cd2 IS NOT NULL AND v_lvl_cd2 <> v_lvl_cd THEN
        UPDATE C_CUST SET
          LVL_CD = v_lvl_cd2
          ,LVL_CHG_DT = SYSDATE
          ,LVL_CHG_DT_BACK = LVL_CHG_DT
          ,DEGRADE_YN = 'Y'
          ,UPD_DT = SYSDATE
          ,UPD_USER = 'SYSTEM'
        WHERE CUST_ID = P_CUST_ID;
      END IF;
      
      UPDATE  C_CARD_SAV_USE_HIS
      SET     USE_MLG     = SAV_MLG
            , UPD_DT      = SYSDATE
            , UPD_USER    = 'SYSTEM'
      WHERE   COMP_CD = '016'
      AND     CARD_ID = ENCRYPT(N_CARD_ID);
      
--      UPDATE C_CUST SET
--        CUST_STAT = '9'
--        ,LEAVE_RMK = '계정통합으로 인한 탈퇴처리'
--        ,MOBILE=''          -- 통합되고난 후 휴대폰번호 NULL처리
--        ,DI_STR=''
--        ,USE_YN='N'
--        ,UPD_DT = SYSDATE
--        ,UPD_USER = P_USER_ID
--      WHERE COMP_CD = '016'
--        AND BRAND_CD = '100'
--        AND CUST_ID = v_card_cust_id;
        
      O_CARD_ID := N_CARD_ID;
    ELSE
      -- 2.카드번호가 없는경우(새로운 카드번호 채번)
      SELECT
        FN_GET_CARD_ID() INTO v_card_id
      FROM DUAL;
      
      -- 신규 카드정보 생성
      INSERT INTO C_CARD
      (
        COMP_CD
        ,CARD_ID
        ,CUST_ID
        ,REP_CARD_YN
        ,CARD_STAT
        ,BRAND_CD
        ,STOR_CD
        ,INST_USER
        ,CARD_TYPE
      )VALUES(
        '016'
        ,ENCRYPT(v_card_id)
        ,P_CUST_ID
        ,'Y'
        ,'10'
        ,'100'
        ,'106500' --할리스 STOR_CD 세팅필요
        ,P_USER_ID
        ,'1'
      );
      
      O_CARD_ID := v_card_id;
    END IF;
    
EXCEPTION
    WHEN ALREADY_USE_CARD THEN
      O_RTN_CD := '2';
    WHEN NOT_FOUND_CARD THEN
      O_RTN_CD := '210';  -- 카드정보가 없습니다
    WHEN ALREADY_EXISTS_CARD THEN
      O_RTN_CD := '130';  -- 이미 등록된 카드입니다.
END API_C_CUST_CARD_ISSUE;

/
