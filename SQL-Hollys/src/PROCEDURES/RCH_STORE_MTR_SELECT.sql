--------------------------------------------------------
--  DDL for Procedure RCH_STORE_MTR_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_STORE_MTR_SELECT" (
    P_RCH_NO        IN  VARCHAR2,
    N_STOR_CD       IN  VARCHAR2,
    N_START_DT      IN  VARCHAR2,
    N_DATE_DIV      IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
    v_query VARCHAR2(30000);
    v_month VARCHAR2(10);
    v_start_month VARCHAR2(10);
    v_end_month VARCHAR2(10);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-17
    -- Description   :   설문조사 매장별 답변결과 모니터링 조회
    -- ==========================================================================================
    
    IF N_DATE_DIV < 4 THEN
      v_start_month := N_START_DT || '0' || (N_DATE_DIV*3)-2;
      v_end_month := N_START_DT || '0' || (N_DATE_DIV*3);
    ELSE
      v_start_month := N_START_DT || (N_DATE_DIV*3)-2;
      v_end_month := N_START_DT || (N_DATE_DIV*3);
    END IF;
    
    
    v_query := '
        SELECT ROWNUM AS RANK, A.* FROM (
          SELECT
            A.STOR_CD
            ,STO.STOR_NM
            ,STO.OPEN_DT
            ,GET_COMMON_CODE_NM(''00605'', STO.TEAM_CD) AS CENTER_NM
            ,GET_COMMON_CODE_NM(''00565'', STO.STOR_TP) AS STOR_TP
            ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = STO.SV_USER_ID) AS SC_USER_NM
            ,(SELECT REGION_NM FROM REGION WHERE CITY_CD = STO.SIDO_CD AND REGION_CD = STO.REGION_CD) AS REGION
      ';
      FOR CUR IN (N_DATE_DIV*3)-2..(N_DATE_DIV*3)
      LOOP
        v_month := CUR;
        IF v_month < 10 THEN
          v_month := '0' || v_month;
        END IF;
        
        v_query := v_query || '
          ,SUM(DECODE(A.INST_DT, ''' || N_START_DT || v_month || ''' , AVG_PT, 0)) AS MM_' || v_month || '
        ';
      END LOOP;
            
    v_query := v_query || '
            ,AVG(AVG_PT) AS TOTAL_AVG
            ,AVG(AVG_PT) - ((SELECT COUNT(*) FROM C_VOC WHERE STOR_CD = A.STOR_CD AND INQRY_TYPE = ''C2003'')*5) AS TOTAL_SCORE
            ,(SELECT COUNT(*) FROM C_VOC WHERE STOR_CD = A.STOR_CD AND INQRY_TYPE = ''C2003'') AS CLAIM_CNT
            ,(SELECT COUNT(*) FROM C_VOC WHERE STOR_CD = A.STOR_CD AND INQRY_TYPE = ''C2003'')*5 AS CLAIM_PT
          FROM (
            SELECT
              A.RCH_NO, A.STOR_CD, A.INST_DT
              , AVG(MM_PT) AS AVG_PT
            FROM (
              SELECT
                RCH_NO, STOR_CD, QR_NO
                ,TO_CHAR(INST_DT, ''YYYYMM'') AS INST_DT
                ,SUM(RCH_LV_RPLY_PT) AS MM_PT
              FROM RCH_LEVEL_REPLY A
              WHERE A.RCH_NO = ''' || P_RCH_NO || '''
                AND A.RCH_LV_RPLY_CHK_YN = ''Y''
                AND (''' || N_STOR_CD || ''' IS NULL OR A.STOR_CD = ''' || N_STOR_CD || ''')
                AND TO_CHAR(INST_DT, ''YYYYMM'') >= ''' || v_start_month || '''
                AND TO_CHAR(INST_DT, ''YYYYMM'') <= ''' || v_end_month || '''
              GROUP BY RCH_NO, STOR_CD, QR_NO, TO_CHAR(INST_DT, ''YYYYMM''))A
            GROUP BY A.RCH_NO,A.STOR_CD, A.INST_DT)A, STORE STO
          WHERE A.STOR_CD = STO.STOR_CD
          GROUP BY A.RCH_NO,A.STOR_CD,STO.STOR_NM,STO.OPEN_DT,STO.TEAM_CD, STO.STOR_TP,STO.SV_USER_ID,STO.SIDO_CD,STO.REGION_CD
          ORDER BY TOTAL_SCORE DESC, STO.STOR_NM ASC
        ) A'
      ;
    DBMS_OUTPUT.PUT_LINE('v_query' || v_query);
    OPEN O_CURSOR FOR v_query;
END RCH_STORE_MTR_SELECT;

/
