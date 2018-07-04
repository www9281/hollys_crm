--------------------------------------------------------
--  DDL for Procedure STORE_CROWN_MONTH_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_CROWN_MONTH_SELECT" (
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
    v_query := '
      SELECT 
        SUBSTR(A.USE_DT, 1, 6) AS USE_DT
        ,SUM(A.SAV_MLG) AS SAV_MLG
        ,SUM(A.USE_MLG) AS USE_MLG
        ,SUM(A.LOS_MLG_UNUSE) AS LOS_MLG
        ,SUM(A.SAV_MLG - A.USE_MLG - A.LOS_MLG_UNUSE) AS UNUSE_MLG
      FROM (
        SELECT
          C.USE_DT
          ,C.SAV_MLG
          ,C.USE_MLG
          ,C.LOS_MLG_UNUSE
          ,GET_AGE_GROUP(CASE WHEN REGEXP_INSTR(CASE WHEN LUNAR_DIV = ''L'' THEN UF_LUN2SOL(BIRTH_DT, ''0'') ELSE BIRTH_DT END, ''^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])'') = 1 THEN
                                   TRUNC((SUBSTR(TO_CHAR(SYSDATE, ''YYYYMMDD''), 1, 6) - SUBSTR(CASE WHEN LUNAR_DIV = ''L'' THEN UF_LUN2SOL(BIRTH_DT, ''0'') ELSE BIRTH_DT END, 1, 6)) / 100 + 1)
                              ELSE 999 
                         END) AS AGE_GROUP
        FROM C_CUST A, C_CARD B, C_CARD_SAV_USE_HIS C
        WHERE A.COMP_CD = ''' || P_COMP_CD || '''
          AND A.CUST_ID = B.CUST_ID
          AND B.CARD_ID = C.CARD_ID
      ';
      
      IF N_MARK_CD IS NOT NULL THEN
        v_query := v_query || 
            ' AND A.CUST_ID IN (SELECT GB.CUST_ID FROM MARKETING_GP GA, MARKETING_GP_CUST GB
                                                  WHERE GA.CUST_GP_ID = ''' || N_MARK_CD || ''' AND GA.CUST_GP_ID = GB.CUST_GP_ID)';
      END IF;
      
      IF N_STOR_CD IS NOT NULL THEN
        v_query := v_query || 
            ' AND C.STOR_CD = ''' || N_STOR_CD || '''';
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
            ' AND A.AGE_GROUP = ''' || N_AGE_DIV || ''' ';
      END IF;
      v_query := v_query || '
      GROUP BY SUBSTR(A.USE_DT, 1, 6)
      ';
    
    DBMS_OUTPUT.PUT_LINE(v_query);
    OPEN O_CURSOR FOR v_query;
      
END STORE_CROWN_MONTH_SELECT;

/
