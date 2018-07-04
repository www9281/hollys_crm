--------------------------------------------------------
--  DDL for Procedure BATCH_STAT_ALL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_STAT_ALL" 
IS
  V_DD       VARCHAR2(2  );
  V_CUR_YM   VARCHAR2(6  );   --기준년월
  V_LST_YM   VARCHAR2(6  );   --기준년월-12개월

  V_QUARTER  VARCHAR2(6  );   --분기
  V_CFR_YM   VARCHAR2(6  );   --기준년월        분기 시작년월
  V_CTO_YM   VARCHAR2(6  );   --기준년월        분기 종료년월
  V_LFR_YM   VARCHAR2(6  );   --기준년월-12개월 분기 시작년월
  V_LTO_YM   VARCHAR2(6  );   --기준년월-12개월 분기 종료년월
  
  B_QTFV     BOOLEAN;
  B_YTFV     BOOLEAN;
                           
  V_MSG      VARCHAR2(100);
  V_RETC     VARCHAR2(100);
BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-05-10
  --                   2018-06-05
  -- Description   :   고객현황 & APP.설치 회원 집계
  -- ==========================================================================================

  V_RETC := NULL;

  -- ==========================================================================================
  -- ==========================================================================================
  -- 전월집계...
  -- ==========================================================================================
  -- ==========================================================================================
  --시스템일자가 15일 이전이면 전월집계를 수행한다.
  SELECT TO_CHAR(SYSDATE,'DD')
  INTO   V_DD
  FROM   DUAL
  ;

  IF TO_NUMBER(V_DD) <= 15 THEN
    SELECT TO_CHAR(ADD_MONTHS(SYSDATE,-1 ),'YYYYMM')
         , TO_CHAR(ADD_MONTHS(SYSDATE,-13),'YYYYMM')
    INTO   V_CUR_YM
         , V_LST_YM
    FROM   DUAL
    ;

    --분기 및 시작/종료월 구하기...
    SELECT SUBSTR(V_CUR_YM,1,4)
         ||'-'
         ||TO_CHAR(CEIL(TO_NUMBER(SUBSTR(V_CUR_YM,5,2))/3))
         , SUBSTR(V_CUR_YM,1,4)
         ||LPAD(((CEIL(TO_NUMBER(SUBSTR(V_CUR_YM,5,2))/3)-1)*3)+1,2,'0')
         , SUBSTR(V_CUR_YM,1,4)
         ||LPAD(((CEIL(TO_NUMBER(SUBSTR(V_CUR_YM,5,2))/3)-1)*3)+3,2,'0')

         , SUBSTR(V_LST_YM,1,4)
         ||LPAD(((CEIL(TO_NUMBER(SUBSTR(V_LST_YM,5,2))/3)-1)*3)+1,2,'0')
         , SUBSTR(V_LST_YM,1,4)
         ||LPAD(((CEIL(TO_NUMBER(SUBSTR(V_LST_YM,5,2))/3)-1)*3)+3,2,'0')
    INTO   V_QUARTER
         , V_CFR_YM
         , V_CTO_YM
         , V_LFR_YM
         , V_LTO_YM
    FROM   DUAL
    ;

    -------------------------------------------------------------------------------------------
    --SSS매장구분 생성
    -------------------------------------------------------------------------------------------
    BEGIN
      STAT_LOG_SAVE('BATCH_STAT_ALL', '0.SSS매장구분 생성(사전작업1)', V_CUR_YM, 'OK', V_RETC);
      BATCH_STAT_STOR(V_CUR_YM, V_CFR_YM, V_CTO_YM, V_LST_YM, V_LFR_YM, V_LTO_YM, V_RETC);
      V_RETC := NULL;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        STAT_LOG_SAVE('BATCH_STAT_ALL', '0.SSS매장구분 생성(사전작업1)', V_CUR_YM||'('||SQLERRM||')', 'NG', V_RETC);
        V_RETC := 'NG';
    END;
    -------------------------------------------------------------------------------------------
    --고객 연령 및 관련 정보 생성하기...
    -------------------------------------------------------------------------------------------
    BEGIN
      STAT_LOG_SAVE('BATCH_STAT_ALL', '0.고객연령 구하기(사전작업2)', V_CUR_YM, 'OK', V_RETC);
      BATCH_STAT_CUST(V_CUR_YM, V_CFR_YM, V_CTO_YM, V_RETC);
      V_RETC := NULL;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        STAT_LOG_SAVE('BATCH_STAT_ALL', '0.고객연령 구하기(사전작업2)', V_CUR_YM||'('||SQLERRM||')', 'NG', V_RETC);
        V_RETC := 'NG';
    END;

    IF V_RETC IS NULL THEN                                                    
      --처리 월이 시스템 일자와 동일 분기이면 전월 집계 작업시 분기 집계작업을 SKIP한다.
      V_MSG := V_CUR_YM || ', ' || V_QUARTER || ', ' || V_CFR_YM || ', ' || V_CTO_YM || ', ';
      IF TO_CHAR(SYSDATE,'MM') >= SUBSTR(V_CFR_YM,5,2) AND TO_CHAR(SYSDATE,'MM') <= SUBSTR(V_CTO_YM,5,2) THEN 
        V_MSG := V_MSG || 'FALSE';
        B_QTFV := FALSE;
      ELSE
        V_MSG := V_MSG || 'TRUE';
        B_QTFV := TRUE;
      END IF;      
      --처리 년도가 시스템 일자와 동일 년도이면 전월 집계 작업시 년도 집계작업을 SKIP한다.
      V_MSG := V_MSG || ', ';
      IF TO_CHAR(SYSDATE,'YYYY') = SUBSTR(V_CUR_YM,1,4) THEN 
        V_MSG := V_MSG || 'FALSE';
        B_YTFV := FALSE;
      ELSE
        V_MSG := V_MSG || 'TRUE';
        B_YTFV := TRUE;
      END IF;  
      
      -------------------------------------------------------------------------------------------
      -------------------------------------------------------------------------------------------
      --전체 회원 현황 자료 생성
      -------------------------------------------------------------------------------------------         
      STAT_LOG_SAVE('BATCH_STAT_ALL', '전체 회원 현황 자료 생성 파라메터', V_MSG, '--', V_RETC);
      
      --전체
      BATCH_STAT_MEMBER_TOT1(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
      --가맹유형별
      BATCH_STAT_MEMBER_TOT2(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
      --상권별
      BATCH_STAT_MEMBER_TOT3(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
      --지역별
      BATCH_STAT_MEMBER_TOT4(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
      --SC별
      BATCH_STAT_MEMBER_TOT5(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
      --매장유형별
      BATCH_STAT_MEMBER_TOT6(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
      --매장별
      BATCH_STAT_MEMBER_TOT7(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);

      
      -------------------------------------------------------------------------------------------
      -------------------------------------------------------------------------------------------
      --연령대/등급별 회원 현황 자료 생성
      -------------------------------------------------------------------------------------------
      STAT_LOG_SAVE('BATCH_STAT_ALL', '연령대/등급별 회원 현황 자료 생성 파라메터', V_MSG, '--', V_RETC);
      
      --전체
      BATCH_STAT_MEMBER_AGE1(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
      --가맹유형별
--      BATCH_STAT_MEMBER_AGE2(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--      --상권별
--      BATCH_STAT_MEMBER_AGE3(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--      --지역별
--      BATCH_STAT_MEMBER_AGE4(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--      --SC별
--      BATCH_STAT_MEMBER_AGE5(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--      --매장유형별
--      BATCH_STAT_MEMBER_AGE6(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--      --매장별
--      BATCH_STAT_MEMBER_AGE7(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
    END IF;      
  END IF;


  -- ==========================================================================================
  -- ==========================================================================================
  -- 당월집계...
  -- ==========================================================================================
  -- ==========================================================================================
  V_RETC := NULL;

  SELECT TO_CHAR(ADD_MONTHS(SYSDATE,0  ),'YYYYMM')
       , TO_CHAR(ADD_MONTHS(SYSDATE,-12),'YYYYMM')
  INTO   V_CUR_YM
       , V_LST_YM
  FROM   DUAL
  ;

  --분기 및 시작/종료월 구하기...
  SELECT SUBSTR(V_CUR_YM,1,4)
       ||'-'
       ||TO_CHAR(CEIL(TO_NUMBER(SUBSTR(V_CUR_YM,5,2))/3))
       , SUBSTR(V_CUR_YM,1,4)
       ||LPAD(((CEIL(TO_NUMBER(SUBSTR(V_CUR_YM,5,2))/3)-1)*3)+1,2,'0')
       , SUBSTR(V_CUR_YM,1,4)
       ||LPAD(((CEIL(TO_NUMBER(SUBSTR(V_CUR_YM,5,2))/3)-1)*3)+3,2,'0')

       , SUBSTR(V_LST_YM,1,4)
       ||LPAD(((CEIL(TO_NUMBER(SUBSTR(V_LST_YM,5,2))/3)-1)*3)+1,2,'0')
       , SUBSTR(V_LST_YM,1,4)
       ||LPAD(((CEIL(TO_NUMBER(SUBSTR(V_LST_YM,5,2))/3)-1)*3)+3,2,'0')
  INTO   V_QUARTER
       , V_CFR_YM
       , V_CTO_YM
       , V_LFR_YM
       , V_LTO_YM
  FROM   DUAL
  ;

  -------------------------------------------------------------------------------------------
  --SSS매장구분 생성
  -------------------------------------------------------------------------------------------
  BEGIN
    STAT_LOG_SAVE('BATCH_STAT_ALL', '0.SSS매장구분 생성(사전작업1)', V_CUR_YM, 'OK', V_RETC);
    BATCH_STAT_STOR(V_CUR_YM, V_CFR_YM, V_CTO_YM, V_LST_YM, V_LFR_YM, V_LTO_YM, V_RETC);
    V_RETC := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      STAT_LOG_SAVE('BATCH_STAT_ALL', '0.SSS매장구분 생성(사전작업1)', V_CUR_YM||'('||SQLERRM||')', 'NG', V_RETC);
      V_RETC := 'NG';
  END;
  -------------------------------------------------------------------------------------------
  --고객 연령 및 관련 정보 생성하기...
  -------------------------------------------------------------------------------------------
  BEGIN
    STAT_LOG_SAVE('BATCH_STAT_ALL', '0.고객연령 구하기(사전작업2)', V_CUR_YM, 'OK', V_RETC);
    BATCH_STAT_CUST(V_CUR_YM, V_CFR_YM, V_CTO_YM, V_RETC);
    V_RETC := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      STAT_LOG_SAVE('BATCH_STAT_ALL', '0.고객연령 구하기(사전작업2)', V_CUR_YM||'('||SQLERRM||')', 'NG', V_RETC);
      V_RETC := 'NG';
  END;


  IF V_RETC IS NULL THEN 
    --당월집계시에는 무조건 분기/년도 집계를 수행한다.
    B_QTFV := TRUE;
    B_YTFV := TRUE;
    V_MSG := V_CUR_YM || ', ' || V_QUARTER || ', ' || V_CFR_YM || ', ' || V_CTO_YM || ', TRUE, TRUE';
    
    -------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------
    --전체 회원 현황 자료 생성
    -------------------------------------------------------------------------------------------
    STAT_LOG_SAVE('BATCH_STAT_ALL', '전체 회원 현황 자료 생성 파라메터', V_MSG, '--', V_RETC);
    
    --전체
    BATCH_STAT_MEMBER_TOT1(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
    --가맹유형별
    BATCH_STAT_MEMBER_TOT2(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
    --상권별
    BATCH_STAT_MEMBER_TOT3(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
    --지역별
    BATCH_STAT_MEMBER_TOT4(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
    --SC별
    BATCH_STAT_MEMBER_TOT5(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
    --매장유형별
    BATCH_STAT_MEMBER_TOT6(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
    --매장별
    BATCH_STAT_MEMBER_TOT7(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);

    
    -------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------
    --연령대/등급별 회원 현황 자료 생성
    -------------------------------------------------------------------------------------------
    STAT_LOG_SAVE('BATCH_STAT_ALL', '연령대/등급별 회원 현황 자료 생성 파라메터', V_MSG, '--', V_RETC);
    
    --전체
    BATCH_STAT_MEMBER_AGE1(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
    --가맹유형별
--    BATCH_STAT_MEMBER_AGE2(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--    --상권별
--    BATCH_STAT_MEMBER_AGE3(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--    --지역별
--    BATCH_STAT_MEMBER_AGE4(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--    --SC별
--    BATCH_STAT_MEMBER_AGE5(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--    --매장유형별
--    BATCH_STAT_MEMBER_AGE6(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
--    --매장별
--    BATCH_STAT_MEMBER_AGE7(V_CUR_YM, V_QUARTER, V_CFR_YM, V_CTO_YM, B_QTFV, B_YTFV, V_RETC);
  END IF;
  

  -- ==========================================================================================
  -- ==========================================================================================
  -- APP.설치 회원 집계 생성
  -- ==========================================================================================
  -- ==========================================================================================
  SELECT TO_CHAR(SYSDATE-1,'YYYYMMDD')
  INTO   V_CUR_YM
  FROM   DUAL
  ;

  STAT_LOG_SAVE('BATCH_STAT_ALL', 'APP.설치 회원 집계 생성', V_CUR_YM, '--', V_RETC);
  BATCH_STAT_APP_INST (V_CUR_YM, TRUE, V_RETC); 

END BATCH_STAT_ALL;

/
