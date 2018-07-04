--------------------------------------------------------
--  DDL for Procedure API_C_CARD_NO_DUP_CHECK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CARD_NO_DUP_CHECK" (
      P_CARD_ID       IN  VARCHAR2, 
      O_RTN_CD        OUT VARCHAR2
) IS
      v_result_cd VARCHAR2(7) := '1';
      v_result_cnt NUMBER;
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-15
    -- API REQUEST   :   HLS_CRM_IF_0011
    -- Description   :   카드번호 중복 체크		
    -- ==========================================================================================
      
      SELECT
        COUNT(1) AS CNT
        INTO v_result_cnt
      FROM C_CARD
      WHERE COMP_CD = '016'
        AND CARD_ID = ENCRYPT(P_CARD_ID)
      ;
      
      IF v_result_cnt > 0 THEN
        -- 이미 사용중인 카드번호입니다.
        v_result_cd := '700';
      END IF;
          
      O_RTN_CD := v_result_cd;
EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2';
END API_C_CARD_NO_DUP_CHECK;

/
