--------------------------------------------------------
--  DDL for Procedure C_COUPON_GIFT_HIS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_COUPON_GIFT_HIS_SELECT" (
    P_COMP_CD     IN   VARCHAR2,
    P_COUPON_CD   IN   VARCHAR2,
    P_CERT_NO     IN   VARCHAR2,
    N_LANGUAGE_TP IN   VARCHAR2,
    O_CURSOR    OUT  SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [쿠폰발급내역]탭의 [쿠폰발송이력] 정보 조회
    -- Test          :   C_CUST_SELECT_ONE ('000', 'PBS0000001', 'C006315F0010K0532287', 'KOR')
    -- ==========================================================================================
      v_query :=
            'SELECT  
                  CCG.COMP_CD
                  , CCG.COUPON_CD
                  , CCG.CERT_NO
                  , TO_CHAR(TO_DATE(CCG.GIFT_SEND_DT, ''YYYYMMDDHH24MISS''), ''YYYY/MM/DD HH24:MI:SS'') AS GIFT_SEND_DT
                  , CCG.GIFT_SEND_STAT
                  , GET_COMMON_CODE_NM(''01900'', CCG.GIFT_SEND_STAT, ''' || N_LANGUAGE_TP ||''')                AS GIFT_SEND_STAT_NM
                  , CCG.GIFT_ERR_CD
                  , CCG.GIFT_ERR_MSG
                  , CCG.MSGKEY
                  , COUNT(*)     OVER()                               AS SEND_CNT
                  , ROW_NUMBER() OVER(ORDER BY CCG.GIFT_SEND_DT DESC) AS R_NUM
            FROM    C_COUPON_CUST_GIFT_HIS CCG
            WHERE   CCG.COMP_CD   = ''' || P_COMP_CD || '''
            AND     CCG.COUPON_CD = ''' || P_COUPON_CD || '''
            AND     CCG.CERT_NO   = ''' || P_CERT_NO ||'''';
             
      OPEN O_CURSOR FOR v_query;
END C_COUPON_GIFT_HIS_SELECT;

/
