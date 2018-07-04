--------------------------------------------------------
--  DDL for Procedure C_CUST_PAY_HIST_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_PAY_HIST_SELECT" (
    P_COMP_CD      IN   VARCHAR2,
    N_CUST_ID      IN   VARCHAR2,
    N_STOR_CD      IN   VARCHAR2,
    N_BRAND_CD     IN   VARCHAR2,
    N_START_DT     IN   VARCHAR2,
    N_END_DT       IN   VARCHAR2,
    N_USER_ID      IN   VARCHAR2,
    N_LANGUAGE_TP  IN   VARCHAR2,
    O_CURSOR       OUT  SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [회원 구매이력] 정보 조회
    -- Test          :   C_CUST_SELECT_ONE ('000', 'level_10', '', '', '', '', 'level_10' 'KOR')
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
           A.SALE_DT
         , A.STOR_CD
         , (SELECT STOR_NM FROM STORE WHERE STOR_CD = A.STOR_CD AND ROWNUM = 1)   STOR_NM
         , A.POS_NO
         , A.BILL_NO
         , A.ITEM_CD
         , (SELECT ITEM_NM FROM ITEM WHERE ITEM_CD = A.ITEM_CD)                   ITEM_NM
         , SUM(CASE WHEN A.SALE_DIV = '1' THEN A.SALE_QTY END)                    SALE_QTY
         , SUM(CASE WHEN A.SALE_DIV = '1' THEN A.SALE_AMT END)                    SALE_AMT
         , SUM(CASE WHEN A.SALE_DIV = '1' THEN A.DC_AMT + A.ENR_AMT END)          DC_AMT
         , SUM(CASE WHEN A.SALE_DIV = '1' THEN A.GRD_AMT END)                     GRD_AMT
         , SUM(CASE WHEN A.SALE_DIV = '2' THEN A.SALE_QTY END)                    RTN_QTY
         , SUM(CASE WHEN A.SALE_DIV = '2' THEN A.GRD_AMT END)                     RTN_AMT
     FROM  SALE_DT A
    WHERE  A.COMP_CD = P_COMP_CD
      AND  A.CARD_ID IN (SELECT CARD_ID FROM C_CARD WHERE  CUST_ID = N_CUST_ID)
      AND (A.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
      AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = N_USER_ID AND BRAND_CD = A.BRAND_CD AND USE_YN = 'Y')))
      AND (N_STOR_CD  IS NULL OR A.STOR_CD  = N_STOR_CD)
      AND (N_START_DT IS NULL OR A.SALE_DT >= N_START_DT)
      AND (N_END_DT   IS NULL OR A.SALE_DT <= N_END_DT)
      AND (A.T_SEQ = '0' OR A.SUB_TOUCH_DIV = '2')
    GROUP BY A.SALE_DT, A.STOR_CD, A.POS_NO, A.BILL_NO, A.ITEM_CD
    ORDER BY A.SALE_DT DESC
    ;
END C_CUST_PAY_HIST_SELECT;

/
