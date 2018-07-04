--------------------------------------------------------
--  DDL for Procedure C_CUST_SIMPLE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_SIMPLE_SELECT" (
    P_COMP_CD   IN  VARCHAR2,
    N_BRAND_CD  IN  VARCHAR2, 
    N_STOR_CD   IN  VARCHAR2, 
    N_START_DT  IN  VARCHAR2,
    N_END_DT    IN  VARCHAR2,
    N_YYMM_DIV  IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS
BEGIN
    -- ==========================================================================================
    -- Author        :   최인태
    -- Create date   :   2018-03-23
    -- Description   :   매장별 간편가입 현황
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    
    
    SELECT B.STOR_CD                          STOR_CD
         , MAX(C.STOR_NM)                     STOR_NM
         , SUM(DECODE(B.CARD_TYPE,'1',1,0))   REAL_CARD
         , SUM(DECODE(B.CARD_TYPE,'1',0,1))   MOBILE_JOIN
    FROM   C_CUST A
         , C_CARD B
         , STORE  C
    WHERE  A.COMP_CD      = P_COMP_CD                                       
    AND    (N_BRAND_CD IS NULL OR A.BRAND_CD = N_BRAND_CD)
    AND    A.CUST_STAT   <= '2'
    AND    A.JOIN_DT BETWEEN N_START_DT||'01' AND N_END_DT||'31'
    AND    A.COMP_CD      = B.COMP_CD(+)
    AND    A.CUST_ID      = B.CUST_ID(+)
    AND    (N_STOR_CD  IS NULL OR B.STOR_CD  = N_STOR_CD )
    AND    B.COMP_CD      = C.COMP_CD(+)
    AND    B.STOR_CD      = C.STOR_CD(+)
    AND    B.CARD_STAT    < '91'
    AND    B.STOR_CD IS NOT NULL
    AND    B.CARD_TYPE   != '3'
    AND    B.REP_CARD_YN  = 'Y'
    AND    B.USE_YN       = 'Y'
    GROUP BY B.STOR_CD
    ORDER BY 2
    ;
    
END C_CUST_SIMPLE_SELECT;

/
