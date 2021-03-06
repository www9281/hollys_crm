--------------------------------------------------------
--  DDL for Procedure STORE_POINT_USE_STATS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_POINT_USE_STATS_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_CUST_GRADE   IN  VARCHAR2,
    N_SEX_DIV      IN  VARCHAR2,
    N_AGE_DIV      IN  VARCHAR2,
    N_MARK_CD      IN  VARCHAR2,
    P_MY_USER_ID   IN  VARCHAR2,
    P_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) AS 
    v_query VARCHAR2(30000);
BEGIN
    
/*-----------------------------------------------------------------------------*
    v_query := '
      SELECT 
        A.STOR_CD
        ,A.STOR_NM
        ,A.USE_DT
        ,SUM(A.USE_PT) AS USE_PT
      FROM (
        SELECT
          C.STOR_CD
          ,(SELECT STOR_NM FROM STORE WHERE STOR_CD = C.STOR_CD AND ROWNUM = 1) AS STOR_NM
          ,SUBSTR(C.USE_DT, 0, 6) AS USE_DT
          ,C.POS_NO
          ,C.BILL_NO
          ,C.USE_PT
          ,GET_AGE_GROUP(CASE WHEN REGEXP_INSTR(CASE WHEN LUNAR_DIV = ''L'' THEN UF_LUN2SOL(BIRTH_DT, ''0'') ELSE BIRTH_DT END, ''^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])'') = 1 THEN
                             TRUNC((SUBSTR(TO_CHAR(SYSDATE, ''YYYYMMDD''), 1, 6) - SUBSTR(CASE WHEN LUNAR_DIV = ''L'' THEN UF_LUN2SOL(BIRTH_DT, ''0'') ELSE BIRTH_DT END, 1, 6)) / 100 + 1)
                         ELSE 999 
                         END) AS AGE_GROUP
        FROM C_CUST A, C_CARD B, C_CARD_SAV_HIS C
        WHERE A.COMP_CD = ''' || P_COMP_CD || '''
          AND A.COMP_CD = B.COMP_CD
          AND A.CUST_ID = B.CUST_ID
          AND A.COMP_CD = C.COMP_CD
          AND B.CARD_ID = C.CARD_ID
          AND C.USE_YN = ''Y''
          AND (A.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                                       AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || P_MY_USER_ID || ''' AND BRAND_CD = A.BRAND_CD AND USE_YN = ''Y'')))
      ';
      
      IF N_STOR_CD IS NOT NULL THEN
        v_query := v_query || 
            ' AND C.STOR_CD = ''' || N_STOR_CD || '''';
      END IF;
      
      IF N_MARK_CD IS NOT NULL THEN
        v_query := v_query || 
            ' AND A.CUST_ID IN (SELECT GB.CUST_ID FROM MARKETING_GP GA, MARKETING_GP_CUST GB
                                                  WHERE GA.CUST_GP_ID = ''' || N_MARK_CD || ''' AND GA.CUST_GP_ID = GB.CUST_GP_ID)';
      END IF;
      
      IF N_CUST_GRADE IS NOT NULL THEN
        v_query := v_query || 
            ' AND A.LVL_CD = ''' || N_CUST_GRADE || '''';
      END IF;
      
      IF N_SEX_DIV IS NOT NULL THEN
        v_query := v_query || 
            ' AND A.SEX_DIV = ''' || N_SEX_DIV || '''';
      END IF;
      
      v_query := v_query || '
          AND C.USE_DT >= ''' || P_START_DT || '''
          AND C.USE_DT <= ''' || P_END_DT || ''')A 
        WHERE 1=1
      ';
      
      IF N_AGE_DIV IS NOT NULL THEN
        v_query := v_query || 
            ' AND A.AGE_GROUP = ''' || N_AGE_DIV || '''';
      END IF;
      
      v_query := v_query || '
      GROUP BY A.STOR_CD, A.STOR_NM, A.USE_DT
      ORDER BY A.USE_DT DESC
      ';
 *-----------------------------------------------------------------------------*/
/*-2018.04.02 LCS -------------------------------------------------------------*/
    v_query := '
                SELECT T1.STOR_CD        STOR_CD
                     , MAX(T2.STOR_NM)   STOR_NM
                     , T1.USE_DT         USE_DT 
                     , SUM(T1.USE_PT)    USE_PT
                FROM   (
                        SELECT C.COMP_CD               COMP_CD 
                             , C.BRAND_CD              BRAND_CD
                             , C.STOR_CD               STOR_CD 
                             , SUBSTR(C.USE_DT, 0, 6)  USE_DT
                             , C.USE_PT                USE_PT
                             , GET_AGE_GROUP(CASE WHEN REGEXP_INSTR(CASE WHEN LUNAR_DIV = ''L'' THEN UF_LUN2SOL(BIRTH_DT, ''0'') ELSE BIRTH_DT END, ''^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])'') = 1 THEN
                                                 TRUNC((SUBSTR(TO_CHAR(SYSDATE, ''YYYYMMDD''), 1, 6) - SUBSTR(CASE WHEN LUNAR_DIV = ''L'' THEN UF_LUN2SOL(BIRTH_DT, ''0'') ELSE BIRTH_DT END, 1, 6)) / 100 + 1)
                                             ELSE 999 
                                             END)      AGE_GROUP
                        FROM   C_CUST         A
                             , C_CARD         B
                             , C_CARD_SAV_HIS C
                        WHERE  A.COMP_CD    = ''' || P_COMP_CD || '''
                        AND    A.COMP_CD    = B.COMP_CD
                        AND    A.CUST_ID    = B.CUST_ID
                        AND    A.COMP_CD    = C.COMP_CD
                        AND    B.CARD_ID    = C.CARD_ID
                        AND    C.SAV_USE_FG = ''4''
                        AND    C.USE_YN     = ''Y''
                        AND    (A.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                                AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || P_MY_USER_ID || ''' AND BRAND_CD = A.BRAND_CD AND USE_YN = ''Y'')))
               ';
      
      IF N_STOR_CD IS NOT NULL THEN
        v_query := v_query || 
            ' AND C.STOR_CD = ''' || N_STOR_CD || '''';
      END IF;
      
      IF N_MARK_CD IS NOT NULL THEN
        v_query := v_query || 
            ' AND A.CUST_ID IN (SELECT GB.CUST_ID FROM MARKETING_GP GA, MARKETING_GP_CUST GB
                                                  WHERE GA.CUST_GP_ID = ''' || N_MARK_CD || ''' AND GA.CUST_GP_ID = GB.CUST_GP_ID)';
      END IF;
      
      IF N_CUST_GRADE IS NOT NULL THEN
        v_query := v_query || 
            ' AND A.LVL_CD = ''' || N_CUST_GRADE || '''';
      END IF;
      
      IF N_SEX_DIV IS NOT NULL THEN
        v_query := v_query || 
            ' AND A.SEX_DIV = ''' || N_SEX_DIV || '''';
      END IF;
      
      v_query := v_query 
              || '        AND    C.USE_DT >= ''' || P_START_DT || '''
                          AND    C.USE_DT <= ''' || P_END_DT || '''
                         )      T1 
                       , STORE   T2  
                  WHERE  T1.COMP_CD  = T2.COMP_CD(+)
                  AND    T1.BRAND_CD = T2.BRAND_CD(+)
                  AND    T1.STOR_CD  = T2.STOR_CD(+)';
      
      IF N_AGE_DIV IS NOT NULL THEN
        v_query := v_query 
                || ' AND   T1.AGE_GROUP = ''' || N_AGE_DIV || '''';
      END IF;
      
      v_query := v_query 
              || 'GROUP BY T1.STOR_CD, T1.USE_DT
                  ORDER BY T1.USE_DT DESC, T1.STOR_CD
                 ';

    
    DBMS_OUTPUT.PUT_LINE(v_query);
    OPEN O_CURSOR FOR v_query;
      
END STORE_POINT_USE_STATS_SELECT;

/
