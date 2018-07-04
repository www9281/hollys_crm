--------------------------------------------------------
--  DDL for Procedure C_CUST_NEW_DATE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_NEW_DATE_SELECT" (
-- ==========================================================================================
-- Author		:	임지훈
-- Create date	:	2018-03-21
-- Description	:	일자별 신규회원 가입현황
-- Test			:	exec C_CUST_NEW_DATE_SELECT 
-- ==========================================================================================
        P_COMP_CD     IN   VARCHAR2,
        N_BRAND_CD    IN   VARCHAR2,    --P는 필수 : 필수값이 와야된다.
        N_START_DT    IN   VARCHAR2,    --N은 선택 : 필수가 아닌 선택적 값이 와도됨.
        N_END_DT      IN   VARCHAR2, 
        O_CURSOR      OUT  SYS_REFCURSOR
) AS 
BEGIN  
/*
        OPEN O_CURSOR  FOR
        
        SELECT  CU.JOIN_DT AS JOIN_DT ,
                COUNT(CASE WHEN CU.CUST_STAT IN('1','2') THEN 'ALL_MEMB' END) AS ALL_MEMB ,
                COUNT(CASE WHEN CU.CUST_STAT='1' THEN 'QUICK_JOIN' END) AS QUICK_JOIN ,
                COUNT(CASE WHEN CU.CUST_STAT='2' THEN 'MEMBERSHIP' END) AS MEMBERSHIP
        FROM    C_CUST CU,
                C_CARD CA
        WHERE   CU.COMP_CD = CA.COMP_CD
        AND     CU.CUST_ID = CA.CUST_ID
        AND     CU.COMP_CD = P_COMP_CD
        AND    (N_BRAND_CD IS NULL OR CU.BRAND_CD = N_BRAND_CD)
        AND     CA.CARD_TYPE  != '3' -- 모바일(0),실물(1)이 아닌것제외
        AND     CA.REP_CARD_YN = 'Y' -- Y는 멤버쉽, N는 기프트(무기명?)  
        AND     JOIN_DT BETWEEN N_START_DT || '01'
        AND                     N_END_DT   || '31'
        GROUP BY CU.JOIN_DT
        ORDER BY CU.JOIN_DT;
*/


      OPEN O_CURSOR  FOR
      SELECT
            /*+ INDEX (A IDX_C_CUST_CUST_STAT)
                 INDEX (C IDX01_C_CARD        ) */
             A.JOIN_DT                                                                         JOIN_DT
           , COUNT(CASE WHEN NVL(B.CUST_STAT,A.CUST_STAT) IN ('1','2') THEN 'ALL_MEMB'   END)  ALL_MEMB
           , COUNT(CASE WHEN NVL(B.CUST_STAT,A.CUST_STAT) = '1'        THEN 'QUICK_JOIN' END)  QUICK_JOIN
           , COUNT(CASE WHEN NVL(B.CUST_STAT,A.CUST_STAT) = '2'        THEN 'MEMBERSHIP' END)  MEMBERSHIP
      FROM   C_CUST  A
           , (--고객의 집계년월의 등급변경내역을 구한다.
              SELECT CUST_ID
                   , CHG_FR    CUST_STAT
              FROM   C_CUST_HIS
              WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                  IN (SELECT CUST_ID
                           , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                      FROM   C_CUST_HIS
                      WHERE  COMP_CD = P_COMP_CD
                      AND    CHG_DT BETWEEN N_START_DT||'01' AND N_END_DT||'31'
                      AND    CHG_DIV = '13'
                      AND    CHG_FR  = '1'
                      GROUP BY CUST_ID
                     )
              AND    CHG_DIV = '13'
             )       B
           , C_CARD  C
      WHERE  A.COMP_CD      = P_COMP_CD
      AND    A.CUST_STAT   <= '2'
      AND    (N_BRAND_CD IS NULL OR A.BRAND_CD = N_BRAND_CD)
      AND    A.JOIN_DT BETWEEN N_START_DT||'01' AND N_END_DT||'31'
      AND    A.CUST_ID      = B.CUST_ID(+)
      AND    A.COMP_CD      = C.COMP_CD(+)
      AND    A.CUST_ID      = C.CUST_ID(+)
      AND    C.CARD_STAT    < '91'
      AND    C.CARD_TYPE   != '3' -- 모바일(0),실물(1)이 아닌것제외
      AND    C.REP_CARD_YN  = 'Y' -- Y는 멤버쉽, N는 기프트(무기명)
      AND    C.USE_YN       = 'Y'
      GROUP BY A.JOIN_DT
      ORDER BY A.JOIN_DT
      ;
                    
END C_CUST_NEW_DATE_SELECT;

/
