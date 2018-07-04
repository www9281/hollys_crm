--------------------------------------------------------
--  DDL for Procedure RCH_RESULT_MTR_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_RESULT_MTR_SELECT" (
    P_RCH_NO       IN  VARCHAR2,
    N_QR_NO        IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_START_DT     IN  VARCHAR2,
    N_END_DT        IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
)IS

CURSOR_STOR_CD  VARCHAR2(30);
MODI_STOR_CD  VARCHAR2(20000);

BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-17
    -- Description   :   설문조사 매장별 답변결과 모니터링 조회
    -- ==========================================================================================
    
    
    -- 선택한 매장 정보 
    IF N_STOR_CD  IS NOT NULL THEN
          MODI_STOR_CD := '';
--          DECLARE CURSOR  CURSOR_STOR IS 
--             (SELECT REGEXP_SUBSTR(N_STOR_CD,'[^,]+', 1, LEVEL) AS STOR_CD
--             FROM DUAL
--             CONNECT BY REGEXP_SUBSTR (N_STOR_CD,'[^,]+', 1, LEVEL) IS NOT NULL);
--             
--          BEGIN
--              OPEN    CURSOR_STOR;
--              
--              LOOP
--                   FETCH   CURSOR_STOR
--                   INTO    CURSOR_STOR_CD;  
--                   EXIT    WHEN  CURSOR_STOR%NOTFOUND;
--                   
--                    IF MODI_STOR_CD IS NULL OR MODI_STOR_CD ='' THEN
--                          MODI_STOR_CD :=  '''' || CURSOR_STOR_CD || '''';
--                    ELSE
--                          MODI_STOR_CD := MODI_STOR_CD || ',''' || CURSOR_STOR_CD || '''';
--                    END IF;
--                    -- dbms_output.put_line(MODI_STOR_CD); 
--              END LOOP;
--          END;
    END IF; 

    IF N_QR_NO IS NOT NULL THEN
      -- QR번호가 있는경우 : 특정 응모번호를 선택하였을 경우
      OPEN O_CURSOR FOR
      SELECT
        A.*
        , A.RCH_LV || '-' || A.RCH_LV_CD AS SEQ
        , DECODE(B.RCH_LV_RPLY_CHK_YN, 'Y', 'V', '0') AS RCH_LV_RPLY_CHK_YN
        , DECODE(B.RCH_LV_RPLY_CHK_YN, 'Y', A.RCH_LV_RPLY_PT, '0') AS RCH_LV_RPLY_USE_PT
        , B.RCH_LV_RPLY_USER
      FROM
        (
          SELECT DISTINCT
            RCH_NO, RCH_LV_DIV, RCH_LV, RCH_LV_CD, RCH_LV_CONT
            ,TRIM(REGEXP_SUBSTR(T.RCH_LV_RPLY_TEXT, '[^|]+', 1, LEVELS.COLUMN_VALUE))  AS RCH_LV_RPLY_TEXT
            ,TRIM(REGEXP_SUBSTR(T.RCH_LV_RPLY_PT, '[^|]+', 1, LEVELS.COLUMN_VALUE))  AS RCH_LV_RPLY_PT
            , LEVELS.COLUMN_VALUE
          FROM 
            (SELECT A.RCH_NO, A.RCH_LV, A.RCH_LV_CD, A.RCH_LV_CONT, A.RCH_LV_RPLY_TEXT, A.RCH_LV_RPLY_PT
                   ,(SELECT DIV_NM FROM RCH_DIV_CODE WHERE DIV_CODE = A.RCH_LV_DIV) AS RCH_LV_DIV
             FROM RCH_LEVEL_INFO A
             WHERE A.RCH_NO = P_RCH_NO
               AND A.RCH_LV_CD != '0') T,
            TABLE(CAST(MULTISET(SELECT LEVEL FROM DUAL CONNECT BY  LEVEL <= LENGTH (REGEXP_REPLACE(T.RCH_LV_RPLY_TEXT, '[^|]+'))  + 1) AS SYS.ODCINUMBERLIST)) LEVELS
          ORDER BY RCH_LV, RCH_LV_CD, LEVELS.COLUMN_VALUE
        ) A, RCH_LEVEL_REPLY B
      WHERE A.RCH_NO = B.RCH_NO
        AND A.RCH_LV = B.RCH_LV
        AND A.RCH_LV_CD = B.RCH_LV_CD
        AND A.COLUMN_VALUE = B.RCH_LV_RPLY_SEQ
        AND B.QR_NO = N_QR_NO
        AND (N_STOR_CD IS NULL OR B.STOR_CD IN ( N_STOR_CD))
        AND (N_START_DT IS NULL OR TO_CHAR(B.INST_DT, 'YYYYMMDD') >= N_START_DT)
        AND (N_END_DT IS NULL OR TO_CHAR(B.INST_DT, 'YYYYMMDD') <= N_END_DT)
      ORDER BY A.RCH_LV, A.RCH_LV_CD, A.COLUMN_VALUE;
    ELSE 
      -- QR번호가 없는경우 : 특정 응모번호를 선택하지 않은경우(카운트필요)
      dbms_output.put_line(MODI_STOR_CD); 
      OPEN O_CURSOR FOR
      SELECT
        A.RCH_LV_DIV
        , A.RCH_LV || '-' || A.RCH_LV_CD AS SEQ
        ,A.RCH_LV_RPLY_TEXT
        ,A.RCH_LV_CONT
        ,NVL(B.RCH_LV_RPLY_CHK_YN,0)  AS RCH_LV_RPLY_CHK_YN
        , ROUND(B.SUMTOTAL +(SELECT AVG(RCH_LV_RPLY_PT)
          FROM RCH_LEVEL_REPLY
          WHERE RCH_NO = A.RCH_NO
            AND RCH_LV = A.RCH_LV
            AND RCH_LV_CD = A.RCH_LV_CD
            AND RCH_LV_RPLY_CHK_YN = 'Y'
          GROUP BY RCH_NO, RCH_LV, RCH_LV_CD),2) || '' AS RCH_LV_RPLY_AVG_PT
        , '' AS RCH_LV_RPLY_USER
      FROM
        (
          SELECT DISTINCT
            RCH_NO, RCH_LV_DIV, RCH_LV, RCH_LV_CD, RCH_LV_CONT
            ,TRIM(REGEXP_SUBSTR(T.RCH_LV_RPLY_TEXT, '[^|]+', 1, LEVELS.COLUMN_VALUE))  AS RCH_LV_RPLY_TEXT
            ,TRIM(REGEXP_SUBSTR(T.RCH_LV_RPLY_PT, '[^|]+', 1, LEVELS.COLUMN_VALUE))  AS RCH_LV_RPLY_PT
            , LEVELS.COLUMN_VALUE
          FROM 
            (SELECT A.RCH_NO, A.RCH_LV, A.RCH_LV_CD, A.RCH_LV_CONT, A.RCH_LV_RPLY_TEXT, A.RCH_LV_RPLY_PT
                   ,(SELECT DIV_NM FROM RCH_DIV_CODE WHERE DIV_CODE = A.RCH_LV_DIV) AS RCH_LV_DIV
             FROM RCH_LEVEL_INFO A
             WHERE A.RCH_NO = P_RCH_NO
               AND A.RCH_LV_CD != '0') T,
            TABLE(CAST(MULTISET(SELECT LEVEL FROM DUAL CONNECT BY  LEVEL <= LENGTH (REGEXP_REPLACE(T.RCH_LV_RPLY_TEXT, '[^|]+'))  + 1) AS SYS.ODCINUMBERLIST)) LEVELS
          ORDER BY RCH_LV, RCH_LV_CD, LEVELS.COLUMN_VALUE
        ) A, 
        (SELECT A.RCH_NO, A.RCH_LV, A.RCH_LV_CD, A.RCH_LV_RPLY_SEQ
              , NVL(SUM(DECODE(A.RCH_LV_RPLY_CHK_YN, 'Y', 1, 0)),0) || '' AS RCH_LV_RPLY_CHK_YN 
              , AVG(RCH_LV_RPLY_PT) AS RCH_LV_RPLY_AVG_PT
              ,(SELECT XMLQUERY(replace(regexp_replace(NVL(substr(replace(replace((LISTAGG(RCH_LV_RPLY_PT, '') WITHIN GROUP(ORDER BY RCH_LV_DIV)),'-',''),'0',''),2),0),'[|]','+'),'','') returning content).getNumberVal()
              FROM RCH_LEVEL_INFO WHERE RCH_NO = A.RCH_NO  AND RCH_LV = A.RCH_LV AND RCH_LV_CD = A.RCH_LV_CD) AS SUMTOTAL
        FROM RCH_LEVEL_REPLY A
        WHERE A.RCH_LV_RPLY_CHK_YN = 'Y'
          AND (N_STOR_CD IS NULL OR A.STOR_CD IN (
            SELECT REGEXP_SUBSTR(N_STOR_CD,'[^,]+', 1, LEVEL)
            FROM DUAL
            CONNECT BY REGEXP_SUBSTR (N_STOR_CD,'[^,]+', 1, LEVEL) IS NOT NULL))
          AND (N_START_DT IS NULL OR TO_CHAR(A.INST_DT, 'YYYYMMDD') >= N_START_DT)
          AND (N_END_DT IS NULL OR TO_CHAR(A.INST_DT, 'YYYYMMDD') <= N_END_DT)
        GROUP BY A.RCH_NO, A.RCH_LV, A.RCH_LV_CD, A.RCH_LV_RPLY_SEQ) B
      WHERE A.RCH_NO = B.RCH_NO(+)
        AND A.RCH_LV = B.RCH_LV(+)
        AND A.RCH_LV_CD = B.RCH_LV_CD(+)
        AND A.COLUMN_VALUE = B.RCH_LV_RPLY_SEQ(+)
      UNION ALL
      SELECT
        '설문 응시자 수' AS RCH_LV_DIV
        ,SUM(A.MONTH_STAND_ISSUE + A.MONTH_MEM_ISSUE) || '명' AS SEQ
        ,'' AS RCH_LV_RPLY_TEXT
        ,'' AS RCH_LV_CONT
        ,'0' AS RCH_LV_RPLY_CHK_YN
        ,'' AS RCH_LV_RPLY_AVG_PT
        ,'' AS RCH_LV_RPLY_USER
      FROM RCH_QR_ISSUE A
      WHERE A.RCH_NO = P_RCH_NO
        AND A.COUPON_CD IS NOT NULL
        AND (A.MONTH_STAND_ISSUE + A.MONTH_MEM_ISSUE) > 0
        AND (N_STOR_CD IS NULL OR A.STOR_CD IN (
            SELECT REGEXP_SUBSTR(N_STOR_CD,'[^,]+', 1, LEVEL)
            FROM DUAL
            CONNECT BY REGEXP_SUBSTR (N_STOR_CD,'[^,]+', 1, LEVEL) IS NOT NULL))
        AND (N_START_DT IS NULL OR TO_CHAR(A.ISSUE_DT, 'YYYYMMDD') >= N_START_DT)
         AND (N_END_DT IS NULL OR TO_CHAR(A.ISSUE_DT, 'YYYYMMDD') <= N_END_DT)
      ;
    END IF;
END RCH_RESULT_MTR_SELECT;

/
