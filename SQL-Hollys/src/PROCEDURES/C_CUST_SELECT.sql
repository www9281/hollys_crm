--------------------------------------------------------
--  DDL for Procedure C_CUST_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_SELECT" (
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
    v_query varchar2(30000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [회원 조회] 탭 조회
    -- Test          :   C_CUST_SELECT ('000', '', '', '', '20170101', '20171231', 'KOR', 'admin')
    -- ==========================================================================================
    
    
    
    v_query := '
    SELECT  
            MAX(CUST_ID        )  AS CUST_ID,
            MAX(CUST_NM        )  AS CUST_NM,
            MAX(CUST_WEB_ID    )  AS CUST_WEB_ID,
            MAX(REP_CARD_ID    )  AS REP_CARD_ID,
            MAX(MOBILE         )  AS MOBILE,
            MAX(ADDR           )  AS ADDR,
            MAX(LUNAR_DIV_NM   )  AS LUNAR_DIV_NM,
            MAX(BIRTH_DT       )  AS BIRTH_DT,
            MAX(LVL_NM         )  AS LVL_NM,
            MAX(SAV_MLG        )  AS SAV_MLG,
            MAX(SAV_PT         )  AS SAV_PT,
            MAX(SAV_CASH       )  AS SAV_CASH,
            MAX(CUST_STAT_NM   )  AS CUST_STAT_NM,
            MAX(CUST_STAT      )  AS CUST_STAT,
            MAX(USE_YN         )  AS USE_YN,
            MAX(EMAIL          )  AS EMAIL,
            MAX(STOR_CD        )  AS STOR_CD,
            MAX(STOR_NM        )  AS STOR_NM,
            MAX(SEX_DIV_NM     )  AS SEX_DIV_NM,
            MAX(SUM_BILL_CNT   )  AS SUM_BILL_CNT,
            MAX(SUM_SALE_AMT   )  AS SUM_SALE_AMT,
            MAX(MAX_SALE_DT    )  AS MAX_SALE_DT,
            MAX(JOIN_DT        )  AS JOIN_DT,
            MAX(SMS_RCV_YN     )  AS SMS_RCV_YN,
            MAX(EMAIL_RCV_YN   )  AS EMAIL_RCV_YN,
            MAX(LEAVE_DT       )  AS LEAVE_DT,
            MAX(BAD_CUST_YN    )  AS BAD_CUST_YN,
            MAX(BRAND_CD       )  AS BRAND_CD,
            MAX(NEGATIVE_USER_YN)  AS NEGATIVE_USER_YN
    FROM 
    (
    SELECT  NULL  AS CUST_ID,
            NULL  AS CUST_NM,
            NULL  AS CUST_WEB_ID,
            NULL  AS REP_CARD_ID,
            NULL  AS MOBILE,
            NULL  AS ADDR,
            NULL  AS LUNAR_DIV_NM,
            NULL  AS BIRTH_DT,
            NULL  AS LVL_NM,
            NULL  AS SAV_MLG,
            NULL  AS SAV_PT,
            NULL  AS SAV_CASH,
            NULL  AS CUST_STAT_NM,
            NULL  AS CUST_STAT,
            NULL  AS USE_YN,
            NULL  AS EMAIL,
            NULL  AS STOR_CD,
            NULL  AS STOR_NM,
            NULL   AS SEX_DIV_NM,
            NVL(SUM(DECODE(SALE_DIV,1,1,2,-1)),0) AS SUM_BILL_CNT,
            SUM(GRD_I_AMT+GRD_O_AMT) AS SUM_SALE_AMT,
            NULL  AS MAX_SALE_DT,
            NULL  AS JOIN_DT,
            NULL  AS SMS_RCV_YN,
            NULL  AS EMAIL_RCV_YN,
            NULL  AS LEAVE_DT,
            NULL  AS BAD_CUST_YN,
            NULL  AS BRAND_CD,
            NULL  AS NEGATIVE_USER_YN
    FROM    SALE_HD
    WHERE   COMP_CD = '''|| P_COMP_CD ||'''
    AND     CUST_ID = '''|| N_CUST_ID ||'''    OR      CARD_ID IN (SELECT CARD_ID FROM C_CARD WHERE CUST_ID = '''|| N_CUST_ID ||''' )'
    ||
            CASE  WHEN  N_STOR_CD IS NULL OR N_STOR_CD = ''
                  THEN  ''
                  ELSE  'AND STOR_CD = '''|| N_STOR_CD ||''' '
            END ||
            CASE  WHEN  N_BRAND_CD IS NULL OR N_BRAND_CD = ''
                  THEN  ''
                  ELSE  'AND BRAND_CD = '''|| N_BRAND_CD ||''' '
            END ||
            CASE  WHEN  N_CUST_ID IS NULL OR N_CUST_ID = ''
                  THEN  ''
                  ELSE  'AND CUST_ID = '''|| N_CUST_ID ||''' '
            END ||
            CASE  WHEN  N_START_DT IS NULL OR N_START_DT = ''
                  THEN  ''
                  ELSE  'AND SALE_DT >= '''|| N_START_DT ||''' '
            END ||
            CASE  WHEN  N_END_DT IS NULL OR N_END_DT = ''
                  THEN  ''
                  ELSE  'AND SALE_DT <= '''|| N_END_DT ||''' '
            END ||
            CASE  WHEN  N_NEGATIVE_YN = 'Y'
                  THEN  'AND (
                                      SELECT  SUM(BILL_CNT)
                                      FROM    C_CUST_DSS
                                      WHERE   COMP_CD = A.COMP_CD
                                      AND     BRAND_CD = A.BRAND_CD
                                      AND     CUST_ID = A.CUST_ID
                                      AND     SALE_DT >= '''||N_NEG_START_DT||'''
                                      AND     SALE_DT <= '''||N_NEG_END_DT||'''
                              ) > 35'
                  ELSE  ''
            END
   || ' UNION ALL
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
                    SELECT  SUM(H.SAV_MLG - H.USE_MLG - H.LOS_MLG_UNUSE)
                    FROM    C_CARD C, C_CARD_SAV_USE_HIS H
                    WHERE   C.COMP_CD = A.COMP_CD
                    AND     C.CUST_ID = A.CUST_ID
                    AND     C.CARD_ID = H.CARD_ID
                    AND     H.SAV_MLG != H.USE_MLG
                    AND     LOS_MLG_YN = ''N''
            ) AS SAV_MLG,
            (
                    SELECT  SUM(H.SAV_PT - H.USE_PT - H.LOS_PT_UNUSE)
                    FROM    C_CARD C, C_CARD_SAV_USE_PT_HIS H
                    WHERE   C.COMP_CD = A.COMP_CD
                    AND     C.CUST_ID = A.CUST_ID
                    AND     C.CARD_ID = H.CARD_ID
                    AND     H.SAV_PT != H.USE_PT
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
            0 AS SUM_BILL_CNT,
            0 AS SUM_SALE_AMT,
            A.CASH_USE_DT  AS MAX_SALE_DT,
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
    WHERE   1 = 1 ' ||
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
                                      AND     SALE_DT >= '''||N_NEG_START_DT||'''
                                      AND     SALE_DT <= '''||N_NEG_END_DT||'''
                              ) > 35'
                  ELSE  ''
            END
      ||')';
    
    v_query := v_query || '
      UNION ALL
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
                      SELECT  SUM(H.SAV_MLG - H.USE_MLG - H.LOS_MLG_UNUSE)
                      FROM    C_CARD C, C_CARD_SAV_USE_HIS H
                      WHERE   C.COMP_CD = A.COMP_CD
                      AND     C.CUST_ID = A.CUST_ID
                      AND     C.CARD_ID = H.CARD_ID
                      AND     H.SAV_MLG != H.USE_MLG
                      AND     LOS_MLG_YN = ''N''
              ) AS SAV_MLG,
              (
                      SELECT  SUM(H.SAV_PT - H.USE_PT - H.LOS_PT_UNUSE)
                      FROM    C_CARD C, C_CARD_SAV_USE_PT_HIS H
                      WHERE   C.COMP_CD = A.COMP_CD
                      AND     C.CUST_ID = A.CUST_ID
                      AND     C.CARD_ID = H.CARD_ID
                      AND     H.SAV_PT != H.USE_PT
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
                      AND     CODE_CD =''8''
              ) AS CUST_STAT_NM,
              ''8'' AS CUST_STAT,
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
                      SELECT  NVL(SUM(DECODE(SALE_DIV,1,1,2,-1)),0)
                      FROM    SALE_HD
                      WHERE   COMP_CD = A.COMP_CD
                      AND     CUST_ID = A.CUST_ID
                      OR      CARD_ID IN (SELECT CARD_ID FROM C_CARD WHERE CUST_ID = A.CUST_ID)
              ) AS SUM_BILL_CNT,
              (
                      SELECT  SUM(GRD_I_AMT+GRD_O_AMT)
                      FROM    SALE_HD
                      WHERE   COMP_CD = A.COMP_CD
                      AND     CUST_ID = A.CUST_ID
                      OR      CARD_ID IN (SELECT CARD_ID FROM C_CARD WHERE CUST_ID = A.CUST_ID)
              ) AS SUM_SALE_AMT,
              A.CASH_USE_DT  AS MAX_SALE_DT,
              A.JOIN_DT,
              A.SMS_RCV_YN,
              A.EMAIL_RCV_YN,
              CASE WHEN A.LEAVE_DT IS NOT NULL AND LENGTH(A.LEAVE_DT) > 8  THEN SUBSTR(A.LEAVE_DT,1,8) ELSE A.LEAVE_DT END AS LEAVE_DT,
              A.BAD_CUST_YN,
              A.BRAND_CD,
              A.NEGATIVE_USER_YN
      FROM    C_CUST_REST A
      LEFT    OUTER JOIN C_CARD B
      ON      A.CUST_ID = B.CUST_ID
      AND     B.REP_CARD_YN = ''Y''
      AND     B.USE_YN = ''Y''
      LEFT    OUTER JOIN STORE C
      ON      A.BRAND_CD = C.BRAND_CD
      AND     A.STOR_CD = C.STOR_CD
      WHERE   1 = 1 ' ||
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
                                      AND     SALE_DT >= '''||N_NEG_START_DT||'''
                                      AND     SALE_DT <= '''||N_NEG_END_DT||'''
                              ) > 35'
                  ELSE  ''
            END;
    DBMS_OUTPUT.PUT_LINE(v_query);
    OPEN O_CURSOR FOR v_query;
    O_RTN_CD := '1';
END C_CUST_SELECT;

/
