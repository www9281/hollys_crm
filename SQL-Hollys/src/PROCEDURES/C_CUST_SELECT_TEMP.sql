--------------------------------------------------------
--  DDL for Procedure C_CUST_SELECT_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_SELECT_TEMP" (
    P_COMP_CD       IN  VARCHAR2,
    N_STOR_CD       IN  VARCHAR2,
    N_CUST_ID       IN  VARCHAR2,
    N_BRAND_CD      IN  VARCHAR2,
    N_START_DT      IN  VARCHAR2,
    N_END_DT        IN  VARCHAR2,
    N_NEGATIVE_YN   IN  VARCHAR2,
    N_NEG_START_DT  IN  VARCHAR2,
    N_NEG_END_DT    IN  VARCHAR2,
    N_LANGUAGE_TP   IN  VARCHAR2,
    P_MY_USER_ID    IN  VARCHAR2,
    O_RTN_CD        OUT VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
    v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [회원 조회] 탭 조회
    -- Test          :   C_CUST_SELECT ('000', '', '', '', '20170101', '20171231', 'KOR', 'admin')
    -- ==========================================================================================
    v_query := '
    SELECT  A.CUST_ID,
            DECRYPT(A.CUST_NM) AS CUST_NM,
            A.CUST_WEB_ID,
            DECRYPT(B.CARD_ID) AS REP_CARD_ID,
            FN_GET_FORMAT_HP_NO(DECRYPT(A.MOBILE)) AS MOBILE,
            A.ADDR1 || '' '' || A.ADDR2 AS ADDR,
            (
                    SELECT  CODE_NM
                    FROM    COMMON
                    WHERE   CODE_TP = ''01730''
                    AND     USE_YN = ''Y''
                    AND     CODE_CD = A.LUNAR_DIV
            ) AS LUNAR_DIV_NM,
            A.BIRTH_DT,
            (
                    SELECT  LVL_NM
                    FROM    C_CUST_LVL
                    WHERE   COMP_CD = A.COMP_CD
                    AND     LVL_CD = A.LVL_CD
            ) AS LVL_NM,
            (
                    SELECT  SUM(SAV_MLG - USE_MLG - LOS_MLG_UNUSE)
                    FROM    C_CARD_SAV_USE_HIS
                    WHERE   COMP_CD = A.COMP_CD
                    AND     CARD_ID = B.CARD_ID
                    AND     SAV_MLG <> USE_MLG
                    AND     LOS_MLG_YN = ''N''
            ) AS SAV_MLG,
            (
                    SELECT  SUM(SAV_PT - USE_PT - LOS_PT_UNUSE)
                    FROM    C_CARD_SAV_USE_PT_HIS
                    WHERE   COMP_CD = A.COMP_CD
                    AND     CARD_ID = B.CARD_ID
                    AND     SAV_PT <> USE_PT
                    AND     LOS_PT_YN = ''N''
            ) AS SAV_PT,
            (
                    SELECT  SUM(SAV_CASH-USE_CASH)
                    FROM    C_CARD
                    WHERE   CUST_ID = A.CUST_ID
                    AND     USE_YN = ''Y''
                    AND     CARD_STAT = ''10''
            ) AS SAV_CASH,
            (
                    SELECT  CODE_NM
                    FROM    COMMON
                    WHERE   CODE_TP = ''01720''
                    AND     USE_YN = ''Y''
                    AND     CODE_CD = A.CUST_STAT
            ) AS CUST_STAT_NM,
            A.CUST_STAT,
            A.USE_YN,
            A.EMAIL,
            C.STOR_CD,
            C.STOR_NM,
            (
                    SELECT  CODE_NM
                    FROM    COMMON
                    WHERE   CODE_TP = ''00315''
                    AND     USE_YN = ''Y''
                    AND     CODE_CD = A.SEX_DIV
            ) AS SEX_DIV_NM,
            (
                    SELECT  NVL(SUM(BILL_CNT),0) - NVL(SUM(RTN_BILL_CNT),0)
                    FROM    C_CUST_DSS
                    WHERE   COMP_CD = A.COMP_CD
                    AND     CUST_ID = A.CUST_ID
            ) AS SUM_BILL_CNT,
            (
                    SELECT  SUM(SALE_AMT)
                    FROM    C_CUST_DSS
                    WHERE   COMP_CD = A.COMP_CD
                    AND     CUST_ID = A.CUST_ID
            ) AS SUM_SALE_AMT,
            (
                    SELECT  MAX(SALE_DT)
                    FROM    C_CUST_DSS
                    WHERE   COMP_CD = A.COMP_CD
                    AND     CUST_ID = A.CUST_ID
            ) AS MAX_SALE_DT,
            A.JOIN_DT,
            A.SMS_RCV_YN,
            A.EMAIL_RCV_YN,
            CASE WHEN A.LEAVE_DT IS NOT NULL AND LENGTH(A.LEAVE_DT) > 8  THEN SUBSTR(A.LEAVE_DT,1,8) ELSE A.LEAVE_DT END AS LEAVE_DT,
            A.BAD_CUST_YN,
            A.BRAND_CD,
            A.NEGATIVE_USER_YN
    FROM    C_CUST A
    LEFT    OUTER JOIN C_CARD B
    ON      A.CUST_ID = B.CUST_ID
    AND     B.REP_CARD_YN = ''Y''
    AND     B.USE_YN = ''Y''
    LEFT    OUTER JOIN STORE C
    ON      A.BRAND_CD = C.BRAND_CD
    AND     A.STOR_CD = C.STOR_CD
    WHERE   1=1 ' ||
            CASE  WHEN  N_STOR_CD IS NULL OR N_STOR_CD = ''
                  THEN  ''
                  ELSE  'AND A.STOR_CD = '''|| N_STOR_CD ||''' '
            END ||
            CASE  WHEN  N_BRAND_CD IS NULL OR N_BRAND_CD = ''
                  THEN  ''
                  ELSE  'AND A.BRAND_CD = '''|| N_BRAND_CD ||''' '
            END ||
            CASE  WHEN  N_CUST_ID IS NULL OR N_CUST_ID = ''
                  THEN  ''
                  ELSE  'AND A.CUST_ID = '''|| N_CUST_ID ||''' '
            END ||
            CASE  WHEN  N_START_DT IS NULL OR N_START_DT = ''
                  THEN  ''
                  ELSE  'AND A.JOIN_DT >= '''|| N_START_DT ||''' '
            END ||
            CASE  WHEN  N_END_DT IS NULL OR N_END_DT = ''
                  THEN  ''
                  ELSE  'AND A.JOIN_DT <= '''|| N_END_DT ||''' '
            END ||
            CASE  WHEN  N_NEGATIVE_YN = 'Y'
                  THEN  'AND (
                                      SELECT  SUM(BILL_CNT)
                                      FROM    C_CUST_DSS
                                      WHERE   COMP_CD = A.COMP_CD
                                      AND     BRAND_CD = A.BRAND_CD
                                      AND     CUST_ID = A.CUST_ID
                                      AND     SALE_DT >= '''||N_START_DT||'''
                                      AND     SALE_DT <= '''||N_END_DT||'''
                              ) > 35'
                  ELSE  ''
            END;
            Dbms_Output.Put_Line(v_query);
    OPEN O_CURSOR FOR v_query;
    O_RTN_CD := '1';
END C_CUST_SELECT_TEMP;

/
