--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SAV_MLG_USE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SAV_MLG_USE" (
      P_COMP_CD          IN  VARCHAR2,
      P_STOR_CD          IN  VARCHAR2,
      P_BRAND_CD         IN  VARCHAR2,
      P_POS_NO           IN  VARCHAR2,
      P_BILL_NO          IN  VARCHAR2,
      N_CARD_ID          IN  VARCHAR2,
      N_CUST_ID          IN  VARCHAR2,
      P_USER_ID          IN  VARCHAR2,
      P_USE_DT           IN  VARCHAR2,
      P_SAV_USE_DIV      IN  VARCHAR2,
      N_SAV_MLG          IN  NUMBER,
      N_ADD_MLG          IN  NUMBER,
      N_ORG_USE_DT       IN  VARCHAR2,
      N_ORG_USE_SEQ      IN  VARCHAR2, 
      N_ORG_PRMT_USE_SEQ IN  VARCHAR2,
--      O_SAV_MLG          OUT NUMBER, 
--      O_ADD_MLG          OUT NUMBER,   
      O_TOT_SAV_MLG      OUT NUMBER,  
      O_USE_DT           OUT VARCHAR2, 
      O_USE_SEQ          OUT VARCHAR2,
      O_PRMT_USE_SEQ     OUT VARCHAR2,
      O_RTN_CD           OUT VARCHAR2
) IS   
--      NOT_EXISTS_PARAMETER_CNT EXCEPTION;
      NOT_FOUND_CUST_CARD EXCEPTION;
--      OVER_MLB_USE   EXCEPTION;
--      REFUND_ERROR_MLG EXCEPTION;
--      ERROR_CUST_INFO EXCEPTION;
--      BAN_MLG_CUST    EXCEPTION;
      v_result_cd    VARCHAR2(7) := '1';
--      v_card_cnt     NUMBER;
--      v_cust_card_id VARCHAR2(100);
      v_cust_id      VARCHAR2(30);
      v_card_id      VARCHAR2(100);
--      v_cust_lvl     VARCHAR2(10); 
--      v_cust_stat    VARCHAR2(1);
--      v_mlg_div      VARCHAR2(1);
--      v_sav_use_cnt  NUMBER;
      v_use_seq      NUMBER;
      v_prmt_use_seq NUMBER;
--      v_pos_cnt      NUMBER;
--      v_tot_sav_mlg  NUMBER;
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-01
    -- API REQUEST   :   HLS_CRM_IF_0043
    -- Description   :   왕관 적립/취소
    -- ==========================================================================================
    
    IF N_CUST_ID IS NOT NULL THEN
      SELECT 
        A.CUST_ID INTO v_cust_id
      FROM C_CUST A, C_CARD B
      WHERE A.COMP_CD = P_COMP_CD
        AND A.CUST_ID = B.CUST_ID
        AND A.CUST_ID = N_CUST_ID
        AND B.USE_YN = 'Y'
        AND ROWNUM = 1;
    ELSIF N_CARD_ID IS NOT NULL THEN
      SELECT
        NVL(MAX(A.CUST_ID), '') INTO v_cust_id
      FROM C_CARD A
      WHERE A.CARD_ID = N_CARD_ID
        AND A.USE_YN = 'Y'
        AND ROWNUM = 1;
    END IF;
    
    IF v_cust_id IS NULL THEN
      RAISE NOT_FOUND_CUST_CARD;
    END IF;
    
    IF N_CARD_ID IS NULL THEN
      SELECT MAX(CARD_ID) INTO v_card_id FROM C_CARD WHERE CUST_ID = v_cust_id AND REP_CARD_YN = 'Y' AND USE_YN = 'Y';
    ELSE
      v_card_id := N_CARD_ID;
    END IF;
    
    SELECT 
      SQ_CROWN_SEQ.NEXTVAL INTO v_use_seq
    FROM DUAL;
    
    INSERT INTO C_CUST_CROWN (
        USE_SEQ
        ,COMP_CD
        ,STOR_CD
        ,BRAND_CD
        ,POS_NO
        ,BILL_NO
        ,CARD_ID
        ,CUST_ID
        ,USE_DT
        ,SAV_USE_DIV
        ,SAV_MLG
        ,ADD_MLG
        ,ORG_USE_DT
        ,ORG_USE_SEQ
        ,ORG_PRMT_USE_SEQ
        ,LOS_MLG_YN
        ,LOS_MLG_DT
    ) VALUES (
        v_use_seq
        ,P_COMP_CD
        ,P_STOR_CD
        ,P_BRAND_CD
        ,P_POS_NO
        ,P_BILL_NO
        ,v_card_id
        ,N_CUST_ID
        ,P_USE_DT
        ,P_SAV_USE_DIV
        ,CASE WHEN P_SAV_USE_DIV = '201' OR P_SAV_USE_DIV = '204' THEN N_SAV_MLG
              WHEN P_SAV_USE_DIV = '202' OR P_SAV_USE_DIV = '205' THEN N_SAV_MLG*-1
              ELSE N_SAV_MLG END
        ,0
        ,N_ORG_USE_DT
        ,N_ORG_USE_SEQ
        ,N_ORG_PRMT_USE_SEQ
        ,'N'
        ,TO_CHAR(ADD_MONTHS(TO_DATE(P_USE_DT)-1, 12), 'YYYYMMDD')
    );
    
    
    IF NVL(N_ADD_MLG, 0) != 0 THEN
      SELECT
        SQ_CROWN_SEQ.NEXTVAL INTO v_prmt_use_seq
      FROM DUAL;
      
      INSERT INTO C_CUST_CROWN (
          USE_SEQ
          ,COMP_CD
          ,STOR_CD
          ,BRAND_CD
          ,POS_NO
          ,BILL_NO
          ,CARD_ID
          ,CUST_ID
          ,USE_DT
          ,SAV_USE_DIV
          ,SAV_MLG
          ,ADD_MLG
          ,ORG_USE_DT
          ,ORG_USE_SEQ
          ,ORG_PRMT_USE_SEQ
          ,LOS_MLG_YN
          ,LOS_MLG_DT
      ) VALUES (
          v_prmt_use_seq
          ,P_COMP_CD
          ,P_STOR_CD
          ,P_BRAND_CD
          ,P_POS_NO
          ,P_BILL_NO
          ,v_card_id
          ,N_CUST_ID
          ,P_USE_DT
          ,DECODE(P_SAV_USE_DIV, '201', '204', '202', '205')
          ,CASE WHEN P_SAV_USE_DIV = '201' OR P_SAV_USE_DIV = '204' THEN N_ADD_MLG
                WHEN P_SAV_USE_DIV = '202' OR P_SAV_USE_DIV = '205' THEN N_ADD_MLG*-1
                ELSE N_ADD_MLG END
          ,0
          ,N_ORG_USE_DT
          ,N_ORG_USE_SEQ
          ,N_ORG_PRMT_USE_SEQ
          ,'N'
          ,TO_CHAR(ADD_MONTHS(TO_DATE(P_USE_DT)-1, 12), 'YYYYMMDD')
      );
      
      O_PRMT_USE_SEQ := v_prmt_use_seq;
    END IF;
    
    SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) INTO O_TOT_SAV_MLG
    FROM    C_CUST              CST
          , C_CARD              CRD
          , C_CARD_SAV_USE_HIS  HIS
    WHERE   CST.COMP_CD  = CRD.COMP_CD
    AND     CST.CUST_ID  = CRD.CUST_ID
    AND     CRD.COMP_CD  = HIS.COMP_CD
    AND     CRD.CARD_ID  = HIS.CARD_ID
    AND     CRD.COMP_CD  = P_COMP_CD
    AND     CRD.CUST_ID  = v_cust_id
    AND     HIS.SAV_MLG != HIS.USE_MLG
    AND     HIS.LOS_MLG_YN  = 'N';
    
    IF P_SAV_USE_DIV = '201' OR P_SAV_USE_DIV = '204' THEN
      O_TOT_SAV_MLG := O_TOT_SAV_MLG + (N_SAV_MLG + N_ADD_MLG);
    ELSIF P_SAV_USE_DIV = '202' OR P_SAV_USE_DIV = '205' THEN
      O_TOT_SAV_MLG := O_TOT_SAV_MLG + ((N_SAV_MLG + N_ADD_MLG)*-1);
    END IF;
    
    O_USE_SEQ := v_use_seq;
    
EXCEPTION
    WHEN NOT_FOUND_CUST_CARD THEN
      O_RTN_CD := '280';
--    O_RTN_CD  := '280';
--    
--    -- CARD_ID, CUST_ID 둘중 하나는 필수입력	
--    IF N_CARD_ID IS NULL AND N_CUST_ID IS NULL THEN
--      RAISE NOT_EXISTS_PARAMETER_CNT;
--    END IF;
--     
--    -- 회원 카드정보에 등록된 카드인지 체크
--    SELECT 
--      B.CARD_ID, A.CUST_ID, A.LVL_CD, A.CUST_STAT, a.MLG_DIV, COUNT(*) OVER() AS CNT INTO v_cust_card_id, v_cust_id, v_cust_lvl, v_cust_stat, v_mlg_div, v_card_cnt
--    FROM C_CUST A, C_CARD B
--    WHERE A.COMP_CD = P_COMP_CD
--      AND A.CUST_ID = B.CUST_ID
--      AND (N_CUST_ID IS NULL OR A.CUST_ID = N_CUST_ID)
--      AND (N_CARD_ID IS NULL OR B.CARD_ID = N_CARD_ID)
--      AND B.USE_YN = 'Y'
--      AND ROWNUM = 1;
--      
--    IF v_card_cnt < 1 THEN
--      RAISE NOT_FOUND_CUST_CARD;
--    END IF;
--    -- 회원 카드정보에 등록된 카드인지 체크 끝
--    
--    -- 간편회원의 경우 최대 5번까지 적립 가능 정책(3번적립부터 알림표시)
--    SELECT
--        COUNT(*) INTO v_sav_use_cnt
--      FROM C_CARD_SAV_HIS A, C_CARD B
--      WHERE A.COMP_CD = P_COMP_CD
--        AND A.CARD_ID = B.CARD_ID
--        AND B.CARD_TYPE = '0'    -- 모바일 카드
--        AND A.CARD_ID = v_cust_card_id
--        AND A.SAV_USE_DIV = '201';
--        
--    IF v_cust_lvl = '000' AND v_cust_stat = '1' AND v_sav_use_cnt >= 5 THEN
--      RAISE OVER_MLB_USE;
--    ELSIF v_cust_stat != '1' AND v_cust_stat != '2' THEN
--      -- 회원상태가 대기, 정상이 아닌경우 적립 불가
--      RAISE ERROR_CUST_INFO;
--    ELSIF P_SAV_USE_DIV = '201' AND v_mlg_div = 'Y' THEN
--      -- 마일리지 금지고객 오류처리
--      RAISE BAN_MLG_CUST;
--    END IF;
--    -- 간편회원의 경우 최대 5번까지 적립 가능 정책(3번적립부터 알림표시) 끝
--    
--    -- 적립  시작
--    IF P_SAV_USE_DIV = '201' THEN
--      IF  NVL(N_SAV_MLG, 0) != 0 THEN
--        -- 사용순번(적립코드) 생성
--        SELECT
--          SQ_PCRM_SEQ.NEXTVAL INTO v_use_seq
--        FROM DUAL;
--      
--        INSERT INTO C_CARD_SAV_HIS (
--          COMP_CD
--          ,CARD_ID
--          ,USE_DT
--          ,USE_SEQ
--          ,SAV_USE_FG
--          ,SAV_USE_DIV
--          ,REMARKS
--          ,SAV_MLG
--          ,BRAND_CD
--          ,STOR_CD
--          ,LOS_MLG_DT
--          ,POS_NO
--          ,BILL_NO
--          ,INST_DT
--          ,INST_USER
--        ) VALUES (
--          P_COMP_CD
--          ,v_cust_card_id
--          ,P_USE_DT
--          ,v_use_seq
--          ,'1'
--          ,P_SAV_USE_DIV
--          ,'왕관 적립'
--          ,N_SAV_MLG
--          ,P_BRAND_CD
--          ,P_STOR_CD
--          ,TO_CHAR(ADD_MONTHS(TO_DATE(P_USE_DT)-1, 12), 'YYYYMMDD')
--          ,P_POS_NO
--          ,P_BILL_NO
--          ,SYSDATE
--          ,P_USER_ID
--        );
--      END IF;
--      
--      -- 프로모션 추가 적립왕관이 있는 경우 별도 INSERT처리
--      IF  NVL(N_ADD_MLG, 0) != 0 THEN
--        SELECT
--          SQ_PCRM_SEQ.NEXTVAL INTO v_prmt_use_seq
--        FROM DUAL;
--      
--        INSERT INTO C_CARD_SAV_HIS (
--          COMP_CD
--          ,CARD_ID
--          ,USE_DT
--          ,USE_SEQ
--          ,SAV_USE_FG
--          ,SAV_USE_DIV
--          ,REMARKS
--          ,SAV_MLG
--          ,BRAND_CD
--          ,STOR_CD
--          ,LOS_MLG_DT
--          ,POS_NO
--          ,BILL_NO
--          ,INST_DT
--          ,INST_USER
--        ) VALUES (
--          P_COMP_CD
--          ,v_cust_card_id
--          ,P_USE_DT
--          ,v_prmt_use_seq
--          ,'1'
--          ,'204'
--          ,'프로모션 적립'
--          ,N_ADD_MLG
--          ,P_BRAND_CD
--          ,P_STOR_CD
--          ,TO_CHAR(ADD_MONTHS(TO_DATE(P_USE_DT)-1, 12), 'YYYYMMDD')
--          ,P_POS_NO
--          ,P_BILL_NO
--          ,SYSDATE
--          ,P_USER_ID
--        );
--      END IF;
--      
--      -- 회원 왕관 적립에 따른 등급변경 및 12+1쿠폰 발행(정상회원만)
--      IF v_cust_stat = '2' THEN
--        C_CUST_CREATE_MEM_COUPON(v_cust_id, O_RTN_CD);
--      END IF;
--      
--      O_USE_SEQ := v_use_seq;
--      O_PRMT_USE_SEQ := v_prmt_use_seq;
--      O_USE_DT := P_USE_DT;
--    ELSIF P_SAV_USE_DIV = '202' THEN
--      -- 적립취소  적립취소 시작
--      
--      SELECT
--        COUNT(1) INTO v_pos_cnt
--      FROM C_CARD_SAV_HIS
--      WHERE BRAND_CD = P_BRAND_CD
--        AND STOR_CD  = P_STOR_CD
--        AND POS_NO   = P_POS_NO
--        AND BILL_NO  = P_BILL_NO
--        AND (USE_SEQ = N_ORG_USE_SEQ OR USE_SEQ = N_ORG_PRMT_USE_SEQ)
--        AND (SAV_USE_DIV = '201' OR SAV_USE_DIV = '204');
--    
--      IF v_pos_cnt < 1 THEN
--        -- 영수증 번호에 해당하는 적립이력이 존재하지않음
--        v_result_cd := '600';
--      ELSE
--        FOR MLG IN (SELECT
--                      *
--                    FROM C_CARD_SAV_HIS
--                    WHERE BRAND_CD = P_BRAND_CD
--                      AND STOR_CD  = P_STOR_CD
--                      AND POS_NO   = P_POS_NO
--                      AND BILL_NO  = P_BILL_NO
--                      AND USE_DT = N_ORG_USE_DT
--                      AND (USE_SEQ = N_ORG_USE_SEQ OR USE_SEQ = N_ORG_PRMT_USE_SEQ)
--                      AND (SAV_USE_DIV = '201' OR SAV_USE_DIV = '204'))
--        LOOP
--          INSERT INTO C_CARD_SAV_HIS (
--            COMP_CD
--            ,CARD_ID
--            ,USE_DT
--            ,USE_SEQ
--            ,SAV_USE_FG
--            ,SAV_USE_DIV
--            ,REMARKS
--            ,SAV_MLG
--            ,BRAND_CD
--            ,STOR_CD
--            ,LOS_MLG_DT
--            ,POS_NO
--            ,BILL_NO
--            ,ORG_USE_DT
--            ,ORG_USE_SEQ
--            ,INST_DT
--            ,INST_USER
--          ) VALUES (
--            MLG.COMP_CD
--            ,MLG.CARD_ID
--            ,P_USE_DT
--            ,SQ_PCRM_SEQ.NEXTVAL
--            ,MLG.SAV_USE_FG
--            ,DECODE(MLG.SAV_USE_DIV, '201', '202', '204', '205')
--            ,DECODE(MLG.SAV_USE_DIV, '201', '적립취소', '204', '프로모션 적립취소')
--            ,(MLG.SAV_MLG*-1)
--            ,P_BRAND_CD
--            ,P_STOR_CD
--            ,TO_CHAR(ADD_MONTHS(TO_DATE(P_USE_DT)-1, 12), 'YYYYMMDD')
--            ,P_POS_NO
--            ,P_BILL_NO
--            ,MLG.USE_DT
--            ,MLG.USE_SEQ
--            ,SYSDATE
--            ,P_USER_ID
--          );
--            
--        END LOOP;
--        
--        -- 회원 왕관적립취소에 따른 등급변경 및 12+1쿠폰 취소
--        IF v_cust_stat = '2' THEN
--          C_CUST_CANCEL_MEM_COUPON(v_cust_id, N_ORG_USE_SEQ);
--        END IF;
--      END IF;
--    END IF;
--    
--    -- 적립 요청한 왕관  정보 RETURN
--    SELECT 
--      SUM(SAV_MLG) - SUM(LOS_MLG) INTO O_SAV_MLG
--    FROM C_CARD_SAV_HIS
--    WHERE CARD_ID = v_cust_card_id
--      AND (SAV_USE_DIV = '201' OR SAV_USE_DIV = '202');
--    
--    SELECT 
--      SUM(SAV_MLG) - SUM(LOS_MLG) INTO O_ADD_MLG
--    FROM C_CARD_SAV_HIS
--    WHERE CARD_ID = v_cust_card_id
--      AND (SAV_USE_DIV = '204' OR SAV_USE_DIV = '205');
--    
--    -- 왕관 적립 후 잔여 가용왕관 RETURN
--    SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) INTO O_TOT_SAV_MLG
--    FROM    C_CUST              CST
--          , C_CARD              CRD
--          , C_CARD_SAV_USE_HIS  HIS
--    WHERE   CST.COMP_CD  = CRD.COMP_CD
--    AND     CST.CUST_ID  = CRD.CUST_ID
--    AND     CRD.COMP_CD  = HIS.COMP_CD
--    AND     CRD.CARD_ID  = HIS.CARD_ID
--    AND     CRD.COMP_CD  = P_COMP_CD
--    AND     CRD.CUST_ID  = v_cust_id
--    AND     HIS.SAV_MLG != HIS.USE_MLG
--    AND     HIS.LOS_MLG_YN  = 'N';
--    
--    -- 간편회원은 3번적립부터 알림표시
--    SELECT
--      COUNT(*) INTO v_sav_use_cnt
--    FROM C_CARD_SAV_HIS A, C_CARD B
--    WHERE A.COMP_CD = P_COMP_CD
--      AND A.CARD_ID = B.CARD_ID
--      AND B.CARD_TYPE = '0'    -- 모바일 카드
--      AND A.CARD_ID = v_cust_card_id
--      AND A.SAV_USE_DIV = '201';
--        
--    IF v_cust_lvl = '000' AND v_cust_stat = '1' AND v_sav_use_cnt >= 3 AND P_SAV_USE_DIV = '201' THEN
--      IF v_sav_use_cnt = '3' THEN
--        v_result_cd := '371';
--      ELSIF v_sav_use_cnt = '4' THEN
--        v_result_cd := '372';
--      ELSIF v_sav_use_cnt = '5' THEN
--        v_result_cd := '373';
--      END IF;
--    END IF;
--    -- 간편회원은 3번적립부터 알림표시 끝
--    
--    O_RTN_CD := v_result_cd;
--EXCEPTION
--    WHEN OVER_MLB_USE THEN
--        O_RTN_CD  := '370';
--    WHEN NOT_EXISTS_PARAMETER_CNT THEN
--        O_RTN_CD  := '191';
--    WHEN NOT_FOUND_CUST_CARD THEN
--        O_RTN_CD  := '280';
--    WHEN ERROR_CUST_INFO THEN
--        O_RTN_CD  := '320';
--    WHEN REFUND_ERROR_MLG THEN
--        O_RTN_CD  := '380';
--        ROLLBACK;
--    WHEN BAN_MLG_CUST THEN
--        O_RTN_CD := '390';
--    WHEN OTHERS THEN
--        O_RTN_CD  := '0';
--        ROLLBACK;
--        dbms_output.put_line(SQLERRM) ;
END API_C_CUST_SAV_MLG_USE;

/
