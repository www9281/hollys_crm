--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SAV_POINT_USE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SAV_POINT_USE" (
      P_COMP_CD           IN  VARCHAR2,
      P_STOR_CD           IN  VARCHAR2,
      P_BRAND_CD          IN  VARCHAR2,
      P_POS_NO            IN  VARCHAR2,
      P_BILL_NO           IN  VARCHAR2,
      N_CARD_ID           IN  VARCHAR2,
      N_CUST_ID           IN  VARCHAR2,
      P_USER_ID           IN  VARCHAR2,
      P_USE_DT            IN  VARCHAR2,
      P_SAV_USE_DIV       IN  VARCHAR2,
      N_USE_PT            IN  NUMBER,
      N_ORG_USE_DT        IN  VARCHAR2,
      N_ORG_USE_SEQ       IN  VARCHAR2,
      O_USE_PT            OUT NUMBER,
      O_USE_DT            OUT VARCHAR2,
      O_USE_SEQ           OUT VARCHAR2,
      O_RTN_CD            OUT VARCHAR2
) IS   
      NOT_EXISTS_PARAMETER_CNT EXCEPTION;
      NOT_FOUND_CUST_CARD EXCEPTION;
      POINT_LESS_EXCEPTION EXCEPTION;
      REST_USER_USE_PT EXCEPTION;
--      CARD_STAT_ERROR EXCEPTION;
      v_result_cd    VARCHAR2(7) := '1';
      v_card_cnt     NUMBER;
      v_cust_card_id VARCHAR2(100);
      v_cust_id      VARCHAR2(30);
      v_use_seq      NUMBER;
      v_cust_lvl     VARCHAR2(10);
      v_card_stat    VARCHAR2(10);
      v_pos_cnt      NUMBER;
--      v_use_pt       NUMBER;
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-01
    -- API REQUEST   :   HLS_CRM_IF_0044
    -- Description   :   포인트 적립/취소
    -- ==========================================================================================
    
    -- CARD_ID, CUST_ID 둘중 하나는 필수입력	
    IF N_CARD_ID IS NULL AND N_CUST_ID IS NULL THEN
      RAISE NOT_EXISTS_PARAMETER_CNT;
    END IF;
    
    -- 회원 카드정보에 등록된 카드인지 체크
    SELECT 
      MAX(B.CARD_ID), MAX(A.CUST_ID), MAX(A.LVL_CD), MAX(B.CARD_STAT), COUNT(*) AS CNT INTO v_cust_card_id, v_cust_id, v_cust_lvl, v_card_stat, v_card_cnt
    FROM C_CUST A, C_CARD B
    WHERE A.COMP_CD = P_COMP_CD
      AND A.CUST_ID = B.CUST_ID
      AND (N_CUST_ID IS NULL OR A.CUST_ID = N_CUST_ID)
      AND (N_CARD_ID IS NULL OR B.CARD_ID = N_CARD_ID)
      AND B.REP_CARD_YN = 'Y'
      AND B.USE_YN = 'Y'
      AND ROWNUM = 1;
      
    IF v_card_cnt < 1 THEN
      RAISE NOT_FOUND_CUST_CARD;
    END IF;
   
    IF v_cust_lvl = '000' THEN
      RAISE REST_USER_USE_PT;
    END IF;
    
--    IF v_card_stat != '10' THEN
--      RAISE 
--    END IF;
    IF P_SAV_USE_DIV = '301' THEN
      IF  NVL(N_USE_PT, 0) != 0 THEN
        -- 포인트 사용처리
        -- 잔여포인트보다 사용하려는 포인트가 높은지 체크(속도문제로인해 제거)
--        SELECT  SUM(HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT_UNUSE) INTO v_use_pt
--        FROM    C_CUST                 CST
--              , C_CARD                 CRD
--              , C_CARD_SAV_USE_PT_HIS  HIS
--        WHERE   CST.COMP_CD  = CRD.COMP_CD
--        AND     CST.CUST_ID  = CRD.CUST_ID
--        AND     CRD.COMP_CD  = HIS.COMP_CD
--        AND     CRD.CARD_ID  = HIS.CARD_ID
--        AND     CRD.COMP_CD  = '016'
--        AND     CRD.CUST_ID  = v_cust_id
--        AND     HIS.LOS_PT_YN  = 'N';
--        
--        IF NVL(N_USE_PT, 0) > v_use_pt THEN
--          RAISE POINT_LESS_EXCEPTION;
--        END IF;
        
        -- 사용순번(적립코드) 생성
        SELECT
          SQ_PCRM_SEQ.NEXTVAL INTO v_use_seq
        FROM DUAL;
        
        -- 포인트사용
        INSERT INTO C_CARD_SAV_HIS (
          COMP_CD
          ,CARD_ID
          ,USE_DT
          ,USE_SEQ
          ,SAV_USE_FG
          ,SAV_USE_DIV
          ,REMARKS
          ,USE_PT
          ,BRAND_CD
          ,STOR_CD
          ,LOS_PT_DT
          ,POS_NO
          ,BILL_NO
          ,INST_DT
          ,INST_USER
        ) VALUES (
          P_COMP_CD
          ,v_cust_card_id
          ,P_USE_DT
          ,v_use_seq
          ,'4'
          ,P_SAV_USE_DIV
          ,'포인트 사용'
          ,NVL(N_USE_PT, 0)
          ,P_BRAND_CD
          ,P_STOR_CD
          ,TO_CHAR(ADD_MONTHS(TO_DATE(P_USE_DT)-1, 12), 'YYYYMMDD')
          ,P_POS_NO
          ,P_BILL_NO
          ,SYSDATE
          ,P_USER_ID
        );
        
        -- 포인트사용이력에 사용포인트 정보 추가
        C_CUST_POINT_USE_HIS_PROC(v_cust_id, P_SAV_USE_DIV, N_USE_PT);
        
        O_USE_SEQ := v_use_seq;
        O_USE_DT := P_USE_DT;
      END IF;
    ELSIF P_SAV_USE_DIV = '302' THEN
       -- 포인트 사용취소처리
       SELECT
          COUNT(1) INTO v_pos_cnt
        FROM C_CARD_SAV_HIS
        WHERE BRAND_CD = P_BRAND_CD
          AND STOR_CD  = P_STOR_CD
--          AND POS_NO   = P_POS_NO
--          AND BILL_NO  = P_BILL_NO
          AND USE_SEQ = N_ORG_USE_SEQ
          AND SAV_USE_DIV = '301';
      
        IF v_pos_cnt < 1 THEN
          -- 영수증 번호에 해당하는 적립이력이 존재하지않음
          v_result_cd := '600';
        ELSE
          FOR MLG IN (SELECT
                        *
                      FROM C_CARD_SAV_HIS
                      WHERE BRAND_CD = P_BRAND_CD
                        AND STOR_CD  = P_STOR_CD
--                        AND POS_NO   = P_POS_NO
--                        AND BILL_NO  = P_BILL_NO
                        AND USE_DT = N_ORG_USE_DT
                        AND USE_SEQ = N_ORG_USE_SEQ
                        AND SAV_USE_DIV = '301')
          LOOP
            INSERT INTO C_CARD_SAV_HIS (
              COMP_CD
              ,CARD_ID
              ,USE_DT
              ,USE_SEQ
              ,SAV_USE_FG
              ,SAV_USE_DIV
              ,REMARKS
              ,USE_PT
              ,BRAND_CD
              ,STOR_CD
              ,POS_NO
              ,BILL_NO
              ,ORG_USE_DT
              ,ORG_USE_SEQ
              ,INST_DT
              ,INST_USER
              ,LOS_PT_DT
            ) VALUES (
              MLG.COMP_CD
              ,MLG.CARD_ID
              ,P_USE_DT
              ,SQ_PCRM_SEQ.NEXTVAL
              ,'4'
              ,P_SAV_USE_DIV
              ,'포인트 사용취소'
              ,(MLG.USE_PT*-1)
              ,P_BRAND_CD
              ,P_STOR_CD
              ,P_POS_NO
              ,P_BILL_NO
              ,MLG.USE_DT
              ,MLG.USE_SEQ
              ,SYSDATE
              ,P_USER_ID
              ,TO_CHAR(ADD_MONTHS(TO_DATE(P_USE_DT)-1, 12), 'YYYYMMDD')
            );
            
            -- 포인트사용이력에 사용포인트 정보 추가
            C_CUST_POINT_USE_HIS_PROC(v_cust_id, P_SAV_USE_DIV, MLG.USE_PT);
          END LOOP;
       END IF;
    END IF;
    
    -- 왕관 적립&취소 후 잔여 가용왕관 RETURN
    SELECT  SUM(HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT_UNUSE) INTO O_USE_PT
    FROM    C_CUST                 CST
          , C_CARD                 CRD
          , C_CARD_SAV_USE_PT_HIS  HIS
    WHERE   CST.COMP_CD  = CRD.COMP_CD
    AND     CST.CUST_ID  = CRD.CUST_ID
    AND     CRD.COMP_CD  = HIS.COMP_CD
    AND     CRD.CARD_ID  = HIS.CARD_ID
    AND     CRD.COMP_CD  = '016'
    AND     CRD.CUST_ID  = v_cust_id
    AND     HIS.LOS_PT_YN  = 'N';
    
    O_RTN_CD := v_result_cd;
EXCEPTION
    WHEN POINT_LESS_EXCEPTION THEN
        O_RTN_CD  := '520';
    WHEN NOT_EXISTS_PARAMETER_CNT THEN
        O_RTN_CD  := '191';
    WHEN NOT_FOUND_CUST_CARD THEN
        O_RTN_CD  := '280';
    WHEN REST_USER_USE_PT THEN
        O_RTN_CD  := '374';
--    WHEN CARD_STAT_ERROR THEN
--        O_RTN_CD  := '';
    WHEN OTHERS THEN
        O_RTN_CD  := '0';
END API_C_CUST_SAV_POINT_USE;

/
