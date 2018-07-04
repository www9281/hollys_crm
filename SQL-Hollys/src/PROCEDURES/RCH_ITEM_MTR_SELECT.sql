--------------------------------------------------------
--  DDL for Procedure RCH_ITEM_MTR_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_ITEM_MTR_SELECT" (
    P_RCH_NO    IN  VARCHAR2,
    P_START_DT  IN  VARCHAR2,
    P_END_DT    IN  VARCHAR2,
    N_STOR_CD   IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
)IS
    v_query VARCHAR2(20000);
    
    CURSOR HEAD_LIST IS
    SELECT
      (SELECT DIV_NM FROM RCH_DIV_CODE WHERE DIV_CODE = A.RCH_LV_DIV) AS DIV_NM
      ,RCH_LV_DIV
    FROM RCH_LEVEL_INFO A
    WHERE A.RCH_LV_DIV IS NOT NULL
      AND A.RCH_NO = P_RCH_NO
    GROUP BY A.RCH_LV_DIV
    ORDER BY A.RCH_LV_DIV;
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-09
    -- Description   :   설문조사 항목별 모니터링 결과조회
    -- ==========================================================================================
    
    
    v_query := 
      '
        SELECT
          A.RCH_NO
          ,A.STOR_CD
          ,A.STOR_NM
          ,A.TEAM_NM
          ,A.SV_USER_NM
          ,ROUND(SUM(A.SUMTOTAL + A.RPLY_AVG),2) AS TOTAL_SUM
          ,(SELECT SUM(MONTH_STAND_ISSUE + MONTH_MEM_ISSUE)
            FROM RCH_QR_ISSUE
            WHERE RCH_NO = A.RCH_NO
              AND STOR_CD = A.STOR_CD
              AND ISSUE_DT >= ''' || P_START_DT || '''
              AND ISSUE_DT <= ''' || P_END_DT || ''') AS ENTER_CNT
      ';
      
        --,(SELECT RCH_TOT_POINT FROM RCH_MASTER WHERE RCH_NO = A.RCH_NO) AS RCH_TOT_POINT
          --,(RCH_TOT_POINT - SUM(DECODE(A.RCH_LV_DIV, ''' || CUR.RCH_LV_DIV || ''', A.RPLY_AVG, 0))) AS LV_TYPE_' || CUR.RCH_LV_DIV || '
      
    FOR CUR IN HEAD_LIST
    LOOP
      v_query := v_query || '
      
          , ROUND(SUM(DECODE(A.RCH_LV_DIV, ''' || CUR.RCH_LV_DIV || ''', A.SUMTOTAL + A.RPLY_AVG, 0)),2) AS LV_TYPE_' || CUR.RCH_LV_DIV || '
      ';
    END LOOP;
    
    v_query := v_query || '
        FROM (
          SELECT
            A.RCH_NO
            ,A.STOR_CD
            ,A.STOR_NM
            ,A.TEAM_NM
            ,A.SV_USER_NM
            ,A.RCH_LV_DIV
            ,(SELECT 
            XMLQUERY(replace(regexp_replace(NVL(substr(replace(replace((LISTAGG(RCH_LV_RPLY_PT, '''') WITHIN GROUP(ORDER BY RCH_LV_DIV)),''-'',''''),''0'',''''),2),0),''[|]'',''+''),'''','''') returning content).getNumberVal()
              FROM RCH_LEVEL_INFO WHERE RCH_NO = A.RCH_NO  AND RCH_LV_DIV = A.RCH_LV_DIV) AS SUMTOTAL
            ,AVG(A.RCH_LV_RPLY_PT) AS RPLY_AVG
          FROM (SELECT
                   A.RCH_NO
                  ,A.STOR_CD
                  ,STO.STOR_NM
                  ,B.RCH_LV_DIV
                  ,FN_GET_CODE_NM(''00605'', STO.TEAM_CD) AS TEAM_NM
                  ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = STO.SV_USER_ID) AS SV_USER_NM
                  ,SUM(A.RCH_LV_RPLY_PT) AS RCH_LV_RPLY_PT
                FROM RCH_LEVEL_REPLY A, RCH_LEVEL_INFO B, STORE STO
                WHERE A.STOR_CD = STO.STOR_CD
                  AND A.RCH_NO = B.RCH_NO
                  AND A.RCH_LV = B.RCH_LV
                  AND A.RCH_LV_CD = B.RCH_LV_CD
                  AND A.RCH_NO = ''' || P_RCH_NO || '''
                  AND (''' || N_STOR_CD || ''' IS NULL OR A.STOR_CD = ''' || N_STOR_CD || ''')
                  AND TO_CHAR(A.INST_DT, ''YYYYMMDD'') >= ''' || P_START_DT || '''
                  AND TO_CHAR(A.INST_DT, ''YYYYMMDD'') <= ''' || P_END_DT || '''
                  AND A.RCH_LV_RPLY_CHK_YN = ''Y''
                GROUP BY A.RCH_NO, A.STOR_CD, STO.STOR_NM, STO.TEAM_CD, STO.SV_USER_ID, A.QR_NO, B.RCH_LV_DIV) A
            GROUP BY A.RCH_NO,A.STOR_CD,A.STOR_NM,A.TEAM_NM,A.SV_USER_NM,A.RCH_LV_DIV) A
          GROUP BY A.RCH_NO,A.STOR_CD,A.STOR_NM,A.TEAM_NM,A.SV_USER_NM
      ';
      
    DBMS_OUTPUT.PUT_LINE('v_query ::' || v_query);
    OPEN O_CURSOR FOR v_query;
    
    
END RCH_ITEM_MTR_SELECT;

/
