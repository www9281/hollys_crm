--------------------------------------------------------
--  DDL for Procedure C_CUST_NEW_JOIN_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_NEW_JOIN_SELECT" (
-- ==========================================================================================
-- Author		:	임지훈
-- Create date	:	2018-03-21
-- Description	:	회원상태별 가입현황
-- Test			:	exec C_CUST_NEW_JOIN_SELECT 
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
        
            SELECT 
                    (CASE WHEN CA.CARD_TYPE = '0' THEN '모바일카드' WHEN CA.CARD_TYPE = '1' THEN '실물카드' END) AS STAT,
                    COUNT(CASE WHEN CU.CUST_STAT IN('1','2') THEN '전체' END) AS ALL_MEMB,
                    COUNT(CASE WHEN CU.CUST_STAT='1' THEN '간편가입' END) AS QUICK_JOIN,
                    COUNT(CASE WHEN CU.CUST_STAT='2' THEN '멤버십' END) AS MEMBERSHIP
            FROM    C_CUST CU 
            JOIN    C_CARD CA 
            ON      CU.COMP_CD = CA.COMP_CD 
            AND     CU.CUST_ID = CA.CUST_ID
            
            WHERE   CA.CARD_TYPE != '3' -- 모바일(0),실물(1)이 아닌것제외
            AND     CA.REP_CARD_YN = 'Y' -- Y는 멤버쉽, N는 기프트(무기명)
           --AND  (N_START_DT IS NULL OR N_START_DT = '' OR TO_CHAR(CU.JOIN_DT, 'YYYYMM') >= N_START_DT) 
           --AND  (N_END_DT IS NULL OR N_END_DT = '' OR TO_CHAR(CU.JOIN_DT, 'YYYYMM') <= N_END_DT)
            AND     CU.JOIN_DT >= N_START_DT || '01'
            AND     CU.JOIN_DT <= N_END_DT || '31'
            AND     CU.COMP_CD  = P_COMP_CD
            AND    (N_BRAND_CD IS NULL OR CU.BRAND_CD = N_BRAND_CD)
            GROUP BY CA.CARD_TYPE
            ORDER BY CA.CARD_TYPE;
*/                                  



      OPEN O_CURSOR  FOR
      SELECT
             /*+ INDEX (A IDX_C_CUST_CUST_STAT)
                 INDEX (C IDX01_C_CARD        ) */
             DECODE(C.CARD_TYPE,'0','모바일카드'
                               ,'1','실물카드'
                               ,''         )                                            STAT
           , COUNT(CASE WHEN NVL(B.CUST_STAT,A.CUST_STAT) IN('1','2') THEN '전체'   END)  ALL_MEMB
           , COUNT(CASE WHEN NVL(B.CUST_STAT,A.CUST_STAT) = '1'       THEN '간편가입' END)  QUICK_JOIN
           , COUNT(CASE WHEN NVL(B.CUST_STAT,A.CUST_STAT) = '2'       THEN '멤버십'  END)  MEMBERSHIP

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
      GROUP BY C.CARD_TYPE
      ORDER BY C.CARD_TYPE
      ;

             
END C_CUST_NEW_JOIN_SELECT;

/
