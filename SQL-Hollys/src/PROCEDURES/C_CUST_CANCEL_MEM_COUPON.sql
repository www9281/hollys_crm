--------------------------------------------------------
--  DDL for Procedure C_CUST_CANCEL_MEM_COUPON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CANCEL_MEM_COUPON" (
  P_CUST_ID IN VARCHAR2,
  P_ORG_USE_SEQ IN  NUMBER
) IS
    v_org_coupon_cd VARCHAR2(20);
    v_tot_sav_mlg NUMBER;
    v_tot_store_mlg NUMBER;
    v_sav_use_mlg NUMBER;
    v_coupon_cd VARCHAR2(20);
    v_lvl_cd VARCHAR2(10);     
    v_check_cd VARCHAR2(10);
    v_coupon_his_seq NUMBER; -- 쿠폰 히스토리시퀀스
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수 
    -- Create date   :   2018-01-23
    -- Description   :   회원 왕관 적립취소에 따른 등급 및 쿠폰발행취소 
    -- ==========================================================================================
    ------------------------------ 1. 등급변경일로부터 취소시 왕관이 0개 미만(등급업 되자마자 취소하는 대상) 등급강등처리
    SELECT   
      NVL(SUM(CASE WHEN CST.LVL_CHG_DT < HIS.INST_DT THEN HIS.SAV_MLG ELSE 0 END), 0)
      INTO v_tot_sav_mlg 
    FROM    C_CUST              CST 
          , C_CARD              CRD 
          , C_CARD_SAV_USE_HIS  HIS 
    WHERE   CST.COMP_CD  = CRD.COMP_CD
      AND   CST.CUST_ID  = CRD.CUST_ID
      AND   CRD.COMP_CD  = HIS.COMP_CD
      AND   CRD.CARD_ID  = HIS.CARD_ID
      AND   CRD.COMP_CD  = '016'
      AND   CRD.CUST_ID  = P_CUST_ID;
    
    FOR CUST IN (
                  SELECT
                    A.LVL_CD
                    ,A.LVL_CHG_DT
                    ,A.DEGRADE_YN
                    ,A.LVL_CHG_DT_BACK
                    ,B.LVL_RANK
                    ,B.LVL_STD_STR
                    ,B.LVL_STD_END
                  FROM C_CUST A, C_CUST_LVL B
                  WHERE A.CUST_ID = P_CUST_ID
                    AND A.USE_YN = 'Y'
                    AND A.LVL_CD = B.LVL_CD
                    AND A.LVL_CD <> '000'
                )
    LOOP
      -- 취소시 이전등급으로 
      IF v_tot_sav_mlg < 0 AND CUST.DEGRADE_YN != 'Y' THEN
        SELECT  
          NVL(SUM(HIS.SAV_MLG), 0)
          INTO v_tot_store_mlg
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
        
        SELECT MAX(LVL_CD) INTO v_lvl_cd FROM C_CUST_LVL
        WHERE LVL_STD_STR <= v_tot_store_mlg
          AND LVL_STD_END > v_tot_store_mlg
          AND LVL_CD <> '000'
          AND LVL_CD <= CUST.LVL_CD;
        
        IF v_lvl_cd IS NOT NULL AND v_lvl_cd <> CUST.LVL_CD THEN
          UPDATE C_CUST SET
            LVL_CD = v_lvl_cd
            ,LVL_CHG_DT = NVL(CUST.LVL_CHG_DT_BACK, LVL_CHG_DT)
            ,LVL_CHG_DT_BACK = ''
          WHERE CUST_ID = P_CUST_ID;
        END IF;
        
      END IF;
    END LOOP;
    
    ------------------------------ 2. 쿠폰발행취소
    -- 2-1. 취소요청된 적립건의 SEQ로 쿠폰발급여부를 체크한다.
    SELECT
      MAX(COUPON_CD) INTO v_org_coupon_cd
    FROM C_CARD_SAV_USE_HIS A
    WHERE USE_SEQ = P_ORG_USE_SEQ
      AND EXISTS (SELECT 1 FROM C_CARD WHERE CARD_ID = A.CARD_ID AND CUST_ID = P_CUST_ID);
    DBMS_OUTPUT.PUT_LINE('v_org_coupon_cd :: ' || v_org_coupon_cd);
    DBMS_OUTPUT.PUT_LINE('v_tot_sav_mlg :: ' || v_tot_sav_mlg);
    
    IF v_org_coupon_cd IS NOT NULL THEN
      -- 2-2-2. 쿠폰번호가 있을경우 해당 쿠폰번호로 쿠폰취소를 실행
      v_coupon_cd := v_org_coupon_cd;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('v_coupon_cd :: ' || v_coupon_cd);
     
    -- 2-3 쿠폰 취소작업 시작
    -- 왕관 적립을 취소하여도 왕관 갯수가 마이너스가 되지않으면 발급된 쿠폰을 건들 필요가없음
    SELECT  NVL(SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE), 0) INTO v_sav_use_mlg
    FROM    C_CUST              CST
          , C_CARD              CRD
          , C_CARD_SAV_USE_HIS  HIS
    WHERE   CST.COMP_CD  = CRD.COMP_CD
    AND     CST.CUST_ID  = CRD.CUST_ID
    AND     CRD.COMP_CD  = HIS.COMP_CD
    AND     CRD.CARD_ID  = HIS.CARD_ID
    AND     CRD.COMP_CD  = '016'
    AND     CRD.CUST_ID  = P_CUST_ID
    AND     HIS.SAV_MLG != HIS.USE_MLG
    AND     HIS.LOS_MLG_YN  = 'N';
    
    IF v_coupon_cd IS NOT NULL AND v_sav_use_mlg < 0 THEN
      DBMS_OUTPUT.PUT_LINE('쿠폰취소로직 진입 :: ');
      -- 2-3-1. 해당 쿠폰이 사용되었는지 사용되지않았는지 체크
      SELECT
          MAX(CASE WHEN A.USE_DT IS NOT NULL THEN '501' -- 이미 사용된 쿠폰입니다.
                   WHEN A.DESTROY_DT IS NOT NULL THEN '502' -- 사용 종료된 쿠폰입니다.
                   WHEN A.START_DT > TO_CHAR(SYSDATE, 'YYYYMMDD') AND A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN'503' -- 쿠폰 사용기간이 아닙니다.
                   WHEN A.COUPON_STATE = 'P0302' THEN '507' -- 취소처리된 쿠폰입니다.
                   ELSE '1'
              END)
              INTO v_check_cd
      FROM    PROMOTION_COUPON A
      JOIN    PROMOTION_COUPON_PUBLISH B
      ON      A.PUBLISH_ID = B.PUBLISH_ID
      JOIN    PROMOTION C
      ON      C.COMP_CD = '016'
      AND     C.PRMT_ID = B.PRMT_ID
      WHERE   A.COUPON_CD = v_coupon_cd;
      
      IF v_check_cd = '1' THEN
        DBMS_OUTPUT.PUT_LINE('사용하지않은 쿠폰 진입 :: ');
        -- 2-3-2. 사용되지 않은 쿠폰의 경우 사용처리된 왕관 리셋 및 취소
        FOR CUR IN (
                      SELECT
                        SAV_MLG
                        ,USE_SEQ
                        ,SUM(USE_MLG) OVER(ORDER BY USE_SEQ DESC) AS USE_MLG
                      FROM C_CARD_SAV_USE_HIS
                      WHERE COUPON_CD = v_coupon_cd
                      ORDER BY USE_SEQ DESC
                    )
        LOOP
          UPDATE C_CARD_SAV_USE_HIS SET
            USE_MLG = CASE WHEN CUR.USE_MLG > 12 THEN  USE_MLG - (CUR.USE_MLG - 12) ELSE 0 END
            ,COUPON_CD = ''
          WHERE USE_SEQ = CUR.USE_SEQ
            AND COUPON_CD = v_coupon_cd;
          
          -- 12개 단위로 사용처리
            EXIT WHEN CUR.USE_MLG >= 12;
        END LOOP;
        
        -- 2-3-3. 쿠폰발급이력 제거
        UPDATE C_CARD_SAV_COUPON_HIS SET
          USE_YN = 'N'
        WHERE COUPON_SEQ = v_coupon_cd;
        
        -- TODO
        -- 2-3-4. 쿠폰발급 취소 프로시저 호출!! (포스에서 쿠폰취소를 하고넘오는 경우가 아닌경우이므로 자체적인 취소로직호출이 필요함)
        UPDATE PROMOTION_COUPON
        SET    DESTROY_DT    = TO_CHAR(SYSDATE,'YYYYMMDD')
               ,COUPON_STATE = 'P0304' 
               ,UPD_USER     = 'CRM'
               ,UPD_DT       = SYSDATE
        WHERE  COUPON_CD     = v_coupon_cd;
        
        -- 쿠폰히스토리 기록
        SELECT COUPON_HIS_SEQ.NEXTVAL
        INTO v_coupon_his_seq
        FROM DUAL;

        -- 쿠폰 발행 기록 히스토리 적용
        INSERT INTO PROMOTION_COUPON_HIS
        (       
                COUPON_CD
                ,COUPON_HIS_SEQ
                ,PUBLISH_ID
                ,COUPON_STATE
                ,START_DT
                ,END_DT
                ,USE_DT
                ,DESTROY_DT
                ,GROUP_ID_HIS
                ,CUST_ID
                ,TO_CUST_ID
                ,FROM_CUST_ID
                ,MOBILE
                ,RECEPTION_MOBILE
                ,POS_NO
                ,BILL_NO
                ,POS_SEQ
                ,POS_SALE_DT
                ,STOR_CD
                ,PUB_STOR_CD
                ,ITEM_CD
                ,COUPON_IMG
                ,INST_USER
                ,INST_DT
        ) 
        SELECT	v_coupon_cd  
                ,v_coupon_his_seq
                ,A.PUBLISH_ID
                ,A.COUPON_STATE
                ,A.START_DT
                ,A.END_DT
                ,A.USE_DT
                ,A.DESTROY_DT
                ,NULL
                ,(CASE WHEN A.CUST_ID IS NOT NULL THEN A.CUST_ID
                      ELSE NULL
                 END
                )
                ,NULL
                ,NULL
                ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                      ELSE NULL
                 END
                )
                ,NULL
                ,NULL
                ,NULL
                ,NULL
                ,NULL
                ,A.STOR_CD
                ,NULL
                ,NULL
                ,NULL
                ,'CRM'
                ,SYSDATE
         FROM	 PROMOTION_COUPON A
         JOIN    PROMOTION_COUPON_PUBLISH B
         ON      A.PUBLISH_ID = B.PUBLISH_ID
         WHERE	 A.COUPON_CD = v_coupon_cd;
      
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('SQLERRM ::::: ' || SQLERRM);
END C_CUST_CANCEL_MEM_COUPON;

/
