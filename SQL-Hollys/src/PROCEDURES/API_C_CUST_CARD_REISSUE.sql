--------------------------------------------------------
--  DDL for Procedure API_C_CUST_CARD_REISSUE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_CARD_REISSUE" 
(
  P_CUST_ID     IN  VARCHAR2,
  P_BE_CARD_ID  IN  VARCHAR2,
  N_AF_CARD_ID  IN  VARCHAR2,
  P_MOD_USER_ID IN  VARCHAR2,
  N_REISSUE_RSN IN  VARCHAR2,
  P_USER_ID     IN  VARCHAR2,
  O_CARD_ID     OUT VARCHAR2,
  O_RTN_CD      OUT VARCHAR2
) IS
  v_be_card_id  VARCHAR2(100) := '';
  v_af_card_id  VARCHAR2(100) := '';
  v_card_type VARCHAR2(1);
  v_card_cnt  NUMBER;
  v_card_cust_id  VARCHAR2(100) := '';
  v_be_cust_id  VARCHAR2(30);
  v_cust_stat VARCHAR2(1);
  v_be_lvl_cd VARCHAR2(10);
  v_af_lvl_cd VARCHAR2(10);
  v_s_lvl_cd  VARCHAR2(10);
  v_t_lvl_cd  VARCHAR2(10);
  v_tot_sav_mlg NUMBER;
  ALREADY_EXISTS_CARD EXCEPTION; 
  NOT_FOUND_CARD EXCEPTION;
BEGIN  
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-27
    -- API REQUEST   :   HLS_CRM_IF_0069
    -- Description   :   회원 카드재발급
    -- ==========================================================================================
    
    -- 구 카드번호 확인 
    SELECT
      MAX(A.CARD_ID) INTO v_be_card_id
    FROM C_CARD A
    WHERE A.COMP_CD = '016'
      AND A.CUST_ID = P_CUST_ID
      AND A.CARD_ID = ENCRYPT(P_BE_CARD_ID)
      AND A.REP_CARD_YN = 'Y'
      AND A.USE_YN = 'Y'
      AND ROWNUM = 1;
      
    IF v_be_card_id IS NULL THEN
      RAISE NOT_FOUND_CARD;
    END IF;
    
    -- 신규카드번호가 넘어오지 않으면 CRM에서 신규카드번호 채번
    IF N_AF_CARD_ID IS NULL THEN
      v_af_card_id := ENCRYPT(FN_GET_CARD_ID());
      v_card_type := '0';
      
      -- 기존카드 사용하지 않음으로 변경
      UPDATE C_CARD SET
        CARD_STAT = '99'
        , REF_CARD_ID = v_af_card_id
        , USE_YN = 'N'
        , UPD_DT = SYSDATE
        , UPD_USER = P_MOD_USER_ID
        , DISUSE_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
        , REISSUE_RSN = N_REISSUE_RSN
      WHERE COMP_CD = '016'
        AND CUST_ID = P_CUST_ID
        AND CARD_ID = v_be_card_id
      ;
      
      -- 신규 카드정보 입력
      INSERT INTO C_CARD (
        COMP_CD
        , CARD_ID
        , CUST_ID
        , CARD_STAT
        , ISSUE_DIV
        , BRAND_CD
        , STOR_CD
        , REP_CARD_YN
        , USE_YN
        , INST_DT
        , INST_USER
        , CARD_TYPE
      ) VALUES (
        '016'
        , v_af_card_id
        , P_CUST_ID
        , '10'
        , '1'
        , '100'
        , '106500'
        , 'Y'
        , 'Y'
        , SYSDATE
        , P_MOD_USER_ID
        , v_card_type
      );
    ELSE 
      v_af_card_id := ENCRYPT(N_AF_CARD_ID);
      v_card_type := '1';
      
      -- 1.카드번호가 있는경우(기존 사용하던 실물카드가 있는경우)
      
      -- 1-1. 등록된 카드인지조회, 등록된카드에 지정된 회원이 있는지 조회
      SELECT
        COUNT(*), MAX(A.CUST_ID), MAX(B.CUST_STAT) INTO v_card_cnt, v_card_cust_id, v_cust_stat
      FROM C_CARD A, C_CUST B
      WHERE A.CARD_ID = v_af_card_id
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
      
      -- 기존카드 사용하지 않음으로 변경
      UPDATE C_CARD SET
        CARD_STAT = '99'
        , REF_CARD_ID = v_af_card_id
        , USE_YN = 'N'
        , UPD_DT = SYSDATE
        , UPD_USER = P_MOD_USER_ID
        , DISUSE_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
        , REISSUE_RSN = N_REISSUE_RSN
      WHERE COMP_CD = '016'
        AND CUST_ID = P_CUST_ID
        AND CARD_ID = v_be_card_id
      ;
      
      -- 1-4 실물카드 정보 이전
      UPDATE C_CARD SET
        CUST_ID = ''
      WHERE CARD_ID = v_af_card_id;
      
      UPDATE C_CARD SET
        CUST_ID = P_CUST_ID
      WHERE CARD_ID = v_af_card_id;
      
      -- 1-5 통합이 완료되고 남은 계정은 탈퇴처리한다.
      -- 통합되는 두 카드중 더 높은 등급의 카드의 등급으로 변경
      SELECT LVL_CD INTO v_be_lvl_cd
      FROM C_CUST
      WHERE COMP_CD = '016'
        AND CUST_ID = v_card_cust_id;
      
      SELECT LVL_CD INTO v_af_lvl_cd
      FROM C_CUST
      WHERE COMP_CD = '016'
        AND CUST_ID = P_CUST_ID;
      
      IF v_be_lvl_cd > v_af_lvl_cd THEN
        v_s_lvl_cd := v_be_lvl_cd;
      ELSE 
        v_s_lvl_cd := v_af_lvl_cd;
      END IF;
      
------D.20180502      DELETE FROM C_CUST
      UPDATE C_CUST
      SET    CUST_STAT = '3'
           , USE_YN    = 'N'
           , UPD_DT    = SYSDATE
           , UPD_USER  = P_MOD_USER_ID
      WHERE  COMP_CD   = '016'
      AND    BRAND_CD  = '100'
      AND    CUST_ID   = v_card_cust_id;
      
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
      
      SELECT MAX(LVL_CD) INTO v_t_lvl_cd FROM C_CUST_LVL
      WHERE LVL_STD_STR <= v_tot_sav_mlg
        AND LVL_STD_END > v_tot_sav_mlg
        AND LVL_CD <> '000'
        AND LVL_CD >= v_s_lvl_cd;
      
      -- 1-7 통합된 후 등급의 변화가 있는 경우 등급변경
      IF v_t_lvl_cd IS NOT NULL AND v_s_lvl_cd < v_t_lvl_cd THEN
        UPDATE C_CUST SET
          LVL_CD = v_t_lvl_cd
          ,LVL_CHG_DT = SYSDATE
          ,LVL_CHG_DT_BACK = LVL_CHG_DT
          ,DEGRADE_YN = 'Y'
          ,UPD_DT = SYSDATE
          ,UPD_USER = 'SYSTEM'
        WHERE CUST_ID = P_CUST_ID;
      END IF;
      
--------D.20180502      UPDATE  C_CARD_SAV_USE_HIS
--------D.20180502      SET     USE_MLG     = SAV_MLG
--------D.20180502            , UPD_DT      = SYSDATE
--------D.20180502            , UPD_USER    = 'SYSTEM'
--------D.20180502      WHERE   COMP_CD = '016'
--------D.20180502      AND     CARD_ID = v_af_card_id;  
--      UPDATE C_CUST SET
--        CUST_STAT = '9'
--        ,LEAVE_RMK = '카드재발급으로 인한 탈퇴처리'
--        ,MOBILE=''          -- 통합되고난 후 휴대폰번호 NULL처리
--        ,DI_STR=''
--        ,USE_YN='N'
--        ,UPD_DT = SYSDATE
--        ,UPD_USER = P_USER_ID
--      WHERE COMP_CD = '016'
--        AND BRAND_CD = '100'
--        AND CUST_ID = v_card_cust_id;
    END IF;
    
    O_CARD_ID := DECRYPT(v_af_card_id);
EXCEPTION
    WHEN NOT_FOUND_CARD THEN
        O_RTN_CD  := '280';
    WHEN ALREADY_EXISTS_CARD THEN
      O_RTN_CD := '130';  -- 이미 등록된 카드입니다.
END API_C_CUST_CARD_REISSUE;

/
