--------------------------------------------------------
--  DDL for Procedure BATCH_STAT_APP_INST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_STAT_APP_INST" (
  PI_YMD     IN   VARCHAR2,   --기준일자
  PI_MTFV    IN   BOOLEAN ,   --
  PO_RETC    OUT  VARCHAR2
)
IS
  V_COMP_CD     VARCHAR2(3  );   --회사코드
  V_YMD         VARCHAR2(8  );   --기준일자
  V_LAST_DT     VARCHAR2(8  );   --기준일자 월의 마지막 일자

  V_RETC        VARCHAR2(100);

BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-06-18        
  -- Modify date   :   2018-06-28 LCS *회원 가입 당시(일,월)의 등급 및 상태 변경이 없는 경우에 초기값으로 처리...
  -- Description   :   APP.설치 회원 집계
  --                    일별, 월별
  -- ==========================================================================================

  --초기값 셋팅...
  SELECT '016'
       , NVL(PI_YMD,TO_CHAR(SYSDATE,'YYYYMMDD'))
  INTO   V_COMP_CD
       , V_YMD
  FROM   DUAL
  ;
  SELECT TO_CHAR(LAST_DAY(TO_DATE(V_YMD,'YYYYMMDD')),'YYYYMMDD')
  INTO   V_LAST_DT
  FROM   DUAL
  ;

  PO_RETC := NULL;

  ---------------------------------------------------------------------------------------------------
  ---1-1.기준일자 당시 회원정보 생성...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_CUST_STAT2';
      INSERT INTO TEMP_CUST_STAT2
           ( COMP_CD    , CUST_ID    , SEX_DIV    , LUNAR_DIV    , BIRTH_DT                                                     -- 1, 2, 3, 4, 5
           , C_BIRTH_DT , AGE        , AGE_RANGE  , LVL_CD       , JOIN_DT                                                      -- 6, 7, 8, 9,10
           , LEAVE_DT   , CUST_STAT  , CASH_USE_DT, LAST_LOGIN_DT, BRAND_CD                                                     --11,12,13,14,15
           , STOR_CD    , APP_INST_DT, DEVICE_DIV , DEVICE_NM    , AUTH_TOKEN                                                   --16,17,18,19,20
           , COUP_END_YN, COUP_MAK_YN, PRMT_EVT_YN, STD_YMD      , MAK_YMD    )                                                 --21,22,23,24,25
      SELECT T1.COMP_CD                                                                                           COMP_CD       -- 1
           , T1.CUST_ID                                                                                           CUST_ID       -- 2
           , T1.SEX_DIV                                                                                           SEX_DIV       -- 3
           , T1.LUNAR_DIV                                                                                         LUNAR_DIV     -- 4
           , T1.BIRTH_DT                                                                                          BIRTH_DT      -- 5
           , T1.C_BIRTH_DT                                                                                        C_BIRTH_DT    -- 6
           , T1.CUST_AGE                                                                                          AGE           -- 7
           , X1.CODE_CD                                                                                           AGE_RANGE     -- 8
           , CASE WHEN T2.LVL_CD IS NULL
                  THEN DECODE(V_YMD,TO_CHAR(SYSDATE-1,'YYYYMMDD'),T1.LVL_CD,'000')
                  ELSE T2.LVL_CD
             END                                                                                                  LVL_CD        -- 9 *과거의 자료 집계시에는 변경이력이 있으면 대체 사용한다.
           , T1.JOIN_DT                                                                                           JOIN_DT       --10
           , T1.LEAVE_DT                                                                                          LEAVE_DT      --
           , CASE WHEN T3.CUST_STAT IS NULL
                  THEN DECODE(V_YMD,TO_CHAR(SYSDATE-1,'YYYYMMDD'),T1.CUST_STAT,'1')
                  ELSE T3.CUST_STAT
             END                                                                                                  CUST_STAT     --11 *과거의 자료 집계시에는 변경이력이 있으면 대체 사용한다. 그당시의
           , T1.CASH_USE_DT                                                                                       CASH_USE_DT   --
           , TO_CHAR(LAST_LOGIN_DT,'YYYYMMDD')                                                                    LAST_LOGIN_DT --
           , T1.BRAND_CD                                                                                          BRAND_CD      --12
           , T1.STOR_CD                                                                                           STOR_CD       --13
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_YMD THEN TO_CHAR(T4.INST_DT,'YYYYMMDD') ELSE NULL END  APP_INST_DT   --14
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_YMD THEN T4.DEVICE_DIV                  ELSE NULL END  DEVICE_DIV    --15
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_YMD THEN T4.DEVICE_NM                   ELSE NULL END  DEVICE_NM     --16
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_YMD THEN T4.AUTH_TOKEN                  ELSE NULL END  AUTH_TOKEN    --17
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_YMD THEN NVL(T5.DIV_YN,'N')             ELSE NULL END  COUP_END_YN   --18
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_YMD THEN NVL(T6.DIV_YN,'N')             ELSE NULL END  COUP_MAK_YN   --19
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_YMD THEN NVL(T7.DIV_YN,'N')             ELSE NULL END  PRMT_EVT_YN   --20
           , V_YMD                                                                                                STD_YMD       --21
           , TO_CHAR(SYSDATE,'YYYYMMDD')                                                                          MAK_YMD       --22
      FROM   (--고객 성별, 나이, 연령대, 등급 등을 구한다.
              SELECT COMP_CD                                                   COMP_CD
                   , CUST_ID                                                   CUST_ID
                   , NVL(SEX_DIV  ,'?')                                        SEX_DIV
                   , NVL(LUNAR_DIV,'S')                                        LUNAR_DIV
                   , BIRTH_DT                                                  BIRTH_DT
                   , DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT)  C_BIRTH_DT
                   , CASE WHEN BIRTH_DT = '99999999'
                          THEN 999
                          ELSE TRUNC((SUBSTR(V_YMD,1,6) - SUBSTR(DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT),1,6)) / 100 + 1)
                     END                                                       CUST_AGE
                   , LVL_CD                                                    LVL_CD
                   , JOIN_DT
                   , LEAVE_DT
                   , CUST_STAT
                   , CASH_USE_DT
                   , LAST_LOGIN_DT
                   , BRAND_CD
                   , STOR_CD
              FROM   (
                      SELECT COMP_CD
                           , CUST_ID
                           , SEX_DIV
                           , LUNAR_DIV
                           , BIRTH_DT
                           , LVL_CD
                           , JOIN_DT
                           , LEAVE_DT
                           , CUST_STAT  
                           , CASH_USE_DT
                           , LAST_LOGIN_DT
                           , BRAND_CD
                           , STOR_CD
                      FROM   C_CUST
                      WHERE  COMP_CD  = V_COMP_CD
                      AND    JOIN_DT <= V_YMD
                     UNION
                      SELECT COMP_CD
                           , CUST_ID
                           , SEX_DIV
                           , LUNAR_DIV
                           , BIRTH_DT
                           , LVL_CD
                           , JOIN_DT
                           , LEAVE_DT
                           , '8'        CUST_STAT
                           , CASH_USE_DT
                           , LAST_LOGIN_DT
                           , BRAND_CD
                           , STOR_CD
                      FROM   C_CUST_REST
                      WHERE  COMP_CD  = V_COMP_CD
                      AND    JOIN_DT <= V_YMD
                     )
             )                   T1
           , (--고객의 집계년월의 등급변경내역을 구한다.
              SELECT CUST_ID
                   , CHG_TO    LVL_CD
              FROM   C_CUST_HIS
              WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                  IN (SELECT CUST_ID
                           , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                      FROM   C_CUST_HIS
                      WHERE  COMP_CD = V_COMP_CD
                      AND    CHG_DT <= V_YMD
                      AND    CHG_DIV = '15'
                      GROUP BY CUST_ID
                     )
              AND    CHG_DIV = '15'
             )                   T2
           , (--고객의 집계년월의 상태변경내역을 구한다.
              SELECT CUST_ID
                   , CHG_TO    CUST_STAT
              FROM   C_CUST_HIS
              WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                  IN (SELECT CUST_ID
                           , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                      FROM   C_CUST_HIS
                      WHERE  COMP_CD = V_COMP_CD
                      AND    CHG_DT <= V_YMD
                      AND    CHG_DIV = '13'
                      GROUP BY CUST_ID
                     )
              AND    CHG_DIV = '13'
             )                   T3
           , C_CUST_DEVICE       T4
           , C_CUST_DEVICE_PUSH  T5
           , C_CUST_DEVICE_PUSH  T6
           , C_CUST_DEVICE_PUSH  T7
           , COMMON              X1
      WHERE  T1.CUST_ID         = T2.CUST_ID(+)
      AND    T1.CUST_ID         = T3.CUST_ID(+)
      AND    T1.CUST_ID         = T4.CUST_ID(+)
      AND    'Y'                = T4.USE_YN(+)
      AND    T1.CUST_ID         = T5.CUST_ID(+)
      AND    'couponEnd'        = T5.DIV_NM(+)
      AND    T1.CUST_ID         = T6.CUST_ID(+)
      AND    'membershipCoupon' = T6.DIV_NM(+)
      AND    T1.CUST_ID         = T7.CUST_ID(+)
      AND    'promotion'        = T7.DIV_NM(+)
      AND    X1.CODE_TP         = '01760'
      AND    T1.CUST_AGE BETWEEN X1.VAL_N1 AND X1.VAL_N2
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_APP_INST', 'APP.설치 회원 집계 생성', '1-1.기준일자 당시 회원정보 생성:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;
  

  ---------------------------------------------------------------------------------------------------
  --1-2.일자료 집계
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  STAT_APP_INST    TAR
      USING (SELECT 'D'            INFO_DIV1
                  , V_YMD          STD_YMD
                  , COMP_CD
                  , BRAND_CD
                  , ORD_NO         INFO_DIV2
                  , LVL_CD
                  , TOTL
                  , AAPP
                  , UAPP
                  , AAPP           TOKN_ALL
                  , TOKN_NOR
                  , AAPP-TOKN_NOR  TOKN_BAD
                  , COUP_END
                  , COUP_MAK
                  , PRMT_EVT
             FROM  (--전체회원
                    SELECT COMP_CD
                         , BRAND_CD
                         , 1                                                                                  ORD_NO
                         , LVL_CD                                                                             LVL_CD
                         , COUNT(*)                                                                           TOTL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,0,1                         )))  AAPP
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,1,0                         )))  UAPP
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,1                         )))  TOKN_ALL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',0,1))))  TOKN_NOR
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',1,0))))  TOKN_BAD
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_END_YN,'Y',1,0                          )))  COUP_END
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_MAK_YN,'Y',1,0                          )))  COUP_MAK
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(PRMT_EVT_YN,'Y',1,0                          )))  PRMT_EVT
                    FROM   TEMP_CUST_STAT2
                    WHERE  COMP_CD    = V_COMP_CD
                    AND    CUST_STAT IN ('2','3')
                    AND    JOIN_DT   <= V_YMD
                    GROUP BY COMP_CD,BRAND_CD,LVL_CD
                   UNION     
                    --휴면회원
                    SELECT COMP_CD
                         , BRAND_CD
                         , 2                                                                                  ORD_NO
                         , LVL_CD                                                                             LVL_CD
                         , COUNT(*)                                                                           TOTL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,0,1                         )))  AAPP
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,1,0                         )))  UAPP
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,1                         )))  TOKN_ALL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',0,1))))  TOKN_NOR
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',1,0))))  TOKN_BAD
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_END_YN,'Y',1,0                          )))  COUP_END
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_MAK_YN,'Y',1,0                          )))  COUP_MAK
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(PRMT_EVT_YN,'Y',1,0                          )))  PRMT_EVT
                    FROM   TEMP_CUST_STAT2
                    WHERE  COMP_CD    = V_COMP_CD
                    AND    CUST_STAT  = '8'
                    AND    (CASH_USE_DT < TO_CHAR(ADD_MONTHS(TO_DATE(V_YMD,'YYYYMMDD'),-12)-0,'YYYYMMDD') AND LAST_LOGIN_DT < TO_CHAR(ADD_MONTHS(TO_DATE(V_YMD,'YYYYMMDD'),-12)-0,'YYYYMMDD'))
                    AND    (CASH_USE_DT = TO_CHAR(ADD_MONTHS(TO_DATE(V_YMD,'YYYYMMDD'),-12)-1,'YYYYMMDD') OR  LAST_LOGIN_DT = TO_CHAR(ADD_MONTHS(TO_DATE(V_YMD,'YYYYMMDD'),-12)-1,'YYYYMMDD'))
                    GROUP BY COMP_CD,BRAND_CD,LVL_CD
                   UNION
                    --신규회원
                    SELECT COMP_CD
                         , BRAND_CD
                         , 3                                                                                  ORD_NO
                         , LVL_CD                                                                             LVL_CD
                         , COUNT(*)                                                                           TOTL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,0,1                         )))  AAPP
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,1,0                         )))  UAPP
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,1                         )))  TOKN_ALL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',0,1))))  TOKN_NOR
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',1,0))))  TOKN_BAD
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_END_YN,'Y',1,0                          )))  COUP_END
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_MAK_YN,'Y',1,0                          )))  COUP_MAK
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(PRMT_EVT_YN,'Y',1,0                          )))  PRMT_EVT
                    FROM   TEMP_CUST_STAT2
                    WHERE  COMP_CD    = V_COMP_CD
                    AND    JOIN_DT    = V_YMD
                    GROUP BY COMP_CD,BRAND_CD,LVL_CD
                   UNION    
                    --탈퇴회원
                    SELECT COMP_CD
                         , BRAND_CD
                         , 4                                                                                  ORD_NO
                         , LVL_CD                                                                             LVL_CD
                         , COUNT(*)                                                                           TOTL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,0,1                         )))  AAPP
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,1,0                         )))  UAPP
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,1                         )))  TOKN_ALL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',0,1))))  TOKN_NOR
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',1,0))))  TOKN_BAD
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_END_YN,'Y',1,0                          )))  COUP_END
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_MAK_YN,'Y',1,0                          )))  COUP_MAK
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(PRMT_EVT_YN,'Y',1,0                          )))  PRMT_EVT
                    FROM   TEMP_CUST_STAT2
                    WHERE  COMP_CD    = V_COMP_CD
                    AND    CUST_STAT  = '9'
                    AND    LEAVE_DT   = V_YMD
                    GROUP BY COMP_CD,BRAND_CD,LVL_CD
                   )
            )                SOC
      ON    (    TAR.INFO_DIV1 = SOC.INFO_DIV1
             AND TAR.STD_YMD   = SOC.STD_YMD  
             AND TAR.COMP_CD   = SOC.COMP_CD  
             AND TAR.BRAND_CD  = SOC.BRAND_CD 
             AND TAR.INFO_DIV2 = SOC.INFO_DIV2
             AND TAR.LVL_CD    = SOC.LVL_CD   
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      TAR.TOTL     = SOC.TOTL
                                    , TAR.AAPP     = SOC.AAPP
                                    , TAR.UAPP     = SOC.UAPP
                                    , TAR.TOKN_ALL = SOC.TOKN_ALL
                                    , TAR.TOKN_NOR = SOC.TOKN_NOR
                                    , TAR.TOKN_BAD = SOC.TOKN_BAD
                                    , TAR.COUP_END = SOC.COUP_END
                                    , TAR.COUP_MAK = SOC.COUP_MAK
                                    , TAR.PRMT_EVT = SOC.PRMT_EVT
                                    , TAR.UPD_DT   = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( INFO_DIV1    , STD_YMD     , COMP_CD     , BRAND_CD        -- 1, 2, 3, 4
                                    , INFO_DIV2    , LVL_CD      , TOTL        , AAPP            -- 5, 6, 7, 8
                                    , UAPP         , TOKN_ALL    , TOKN_NOR    , TOKN_BAD        -- 9,10,11,12
                                    , COUP_END     , COUP_MAK    , PRMT_EVT    , INST_DT      )  --13,14,15,16
                             VALUES ( SOC.INFO_DIV1, SOC.STD_YMD , SOC.COMP_CD , SOC.BRAND_CD    -- 1, 2, 3, 4
                                    , SOC.INFO_DIV2, SOC.LVL_CD  , SOC.TOTL    , SOC.AAPP        -- 5, 6, 7, 8
                                    , SOC.UAPP     , SOC.TOKN_ALL, SOC.TOKN_NOR, SOC.TOKN_BAD    -- 9,10,11,12
                                    , SOC.COUP_END , SOC.COUP_MAK, SOC.PRMT_EVT, SYSDATE      )  --13,14,15,16
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_APP_INST', 'APP.설치 회원 집계 생성', '1-2.일자료 집계:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;
  

  ---------------------------------------------------------------------------------------------------
  ---2-1.기준월 당시 회원정보 생성...
  ---------------------------------------------------------------------------------------------------
  IF (PO_RETC IS NULL) AND (PI_MTFV = TRUE) THEN
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_CUST_STAT2';
      INSERT INTO TEMP_CUST_STAT2
           ( COMP_CD    , CUST_ID    , SEX_DIV    , LUNAR_DIV    , BIRTH_DT                                                          -- 1, 2, 3, 4, 5
           , C_BIRTH_DT , AGE        , AGE_RANGE  , LVL_CD       , JOIN_DT                                                           -- 6, 7, 8, 9,10
           , LEAVE_DT   , CUST_STAT  , CASH_USE_DT, LAST_LOGIN_DT, BRAND_CD                                                          --11,12,13,14,15
           , STOR_CD    , APP_INST_DT, DEVICE_DIV , DEVICE_NM    , AUTH_TOKEN                                                        --16,17,18,19,20
           , COUP_END_YN, COUP_MAK_YN, PRMT_EVT_YN, STD_YMD      , MAK_YMD    )                                                      --21,22,23,24,25
      SELECT T1.COMP_CD                                                                                                COMP_CD       -- 1
           , T1.CUST_ID                                                                                                CUST_ID       -- 2
           , T1.SEX_DIV                                                                                                SEX_DIV       -- 3
           , T1.LUNAR_DIV                                                                                              LUNAR_DIV     -- 4
           , T1.BIRTH_DT                                                                                               BIRTH_DT      -- 5
           , T1.C_BIRTH_DT                                                                                             C_BIRTH_DT    -- 6
           , T1.CUST_AGE                                                                                               AGE           -- 7
           , X1.CODE_CD                                                                                                AGE_RANGE     -- 8
           , CASE WHEN T2.LVL_CD IS NULL
                  THEN DECODE(SUBSTR(V_YMD,1,6),TO_CHAR(SYSDATE,'YYYYMM'),T1.LVL_CD,'000')
                  ELSE T2.LVL_CD
             END                                                                                                       LVL_CD        -- 9 *과거의 자료 집계시에는 변경이력이 있으면 대체 사용한다.
           , T1.JOIN_DT                                                                                                JOIN_DT       --10
           , T1.LEAVE_DT                                                                                               LEAVE_DT      --
           , CASE WHEN T3.CUST_STAT IS NULL
                  THEN DECODE(SUBSTR(V_YMD,1,6),TO_CHAR(SYSDATE,'YYYYMM'),T1.CUST_STAT,'1')
                  ELSE T3.CUST_STAT                                            
             END                                                                                                       CUST_STAT     --11 *과거의 자료 집계시에는 변경이력이 있으면 대체 사용한다. 그당시의
           , T1.CASH_USE_DT                                                                                            CASH_USE_DT   --
           , TO_CHAR(LAST_LOGIN_DT,'YYYYMMDD')                                                                         LAST_LOGIN_DT --
           , T1.BRAND_CD                                                                                               BRAND_CD      --12
           , T1.STOR_CD                                                                                                STOR_CD       --13
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_DT THEN TO_CHAR(T4.INST_DT,'YYYYMMDD') ELSE NULL END   APP_INST_DT   --14
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_DT THEN T4.DEVICE_DIV                  ELSE NULL END   DEVICE_DIV    --15
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_DT THEN T4.DEVICE_NM                   ELSE NULL END   DEVICE_NM     --16
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_DT THEN T4.AUTH_TOKEN                  ELSE NULL END   AUTH_TOKEN    --17
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_DT THEN NVL(T5.DIV_YN,'N')             ELSE NULL END   COUP_END_YN   --18
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_DT THEN NVL(T6.DIV_YN,'N')             ELSE NULL END   COUP_MAK_YN   --19
           , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_DT THEN NVL(T7.DIV_YN,'N')             ELSE NULL END   PRMT_EVT_YN   --20
           , V_LAST_DT                                                                                                 STD_YMD       --21
           , TO_CHAR(SYSDATE,'YYYYMMDD')                                                                               MAK_YMD       --22
      FROM   (--고객 성별, 나이, 연령대, 등급 등을 구한다.
              SELECT COMP_CD                                                   COMP_CD
                   , CUST_ID                                                   CUST_ID
                   , NVL(SEX_DIV  ,'?')                                        SEX_DIV
                   , NVL(LUNAR_DIV,'S')                                        LUNAR_DIV
                   , BIRTH_DT                                                  BIRTH_DT
                   , DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT)  C_BIRTH_DT
                   , CASE WHEN BIRTH_DT = '99999999'
                          THEN 999
                          ELSE TRUNC((SUBSTR(V_YMD,1,6) - SUBSTR(DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT),1,6)) / 100 + 1)
                     END                                                       CUST_AGE
                   , LVL_CD                                                    LVL_CD
                   , JOIN_DT 
                   , LEAVE_DT
                   , CUST_STAT
                   , CASH_USE_DT
                   , LAST_LOGIN_DT
                   , BRAND_CD
                   , STOR_CD
              FROM   (
                      SELECT COMP_CD
                           , CUST_ID
                           , SEX_DIV
                           , LUNAR_DIV
                           , BIRTH_DT
                           , LVL_CD
                           , JOIN_DT  
                           , LEAVE_DT
                           , CUST_STAT
                           , CASH_USE_DT
                           , LAST_LOGIN_DT
                           , BRAND_CD
                           , STOR_CD
                      FROM   C_CUST
                      WHERE  COMP_CD  = V_COMP_CD
                      AND    JOIN_DT <= V_LAST_DT
                     UNION
                      SELECT COMP_CD
                           , CUST_ID
                           , SEX_DIV
                           , LUNAR_DIV
                           , BIRTH_DT
                           , LVL_CD
                           , JOIN_DT
                           , LEAVE_DT
                           , '8'        CUST_STAT
                           , CASH_USE_DT
                           , LAST_LOGIN_DT
                           , BRAND_CD
                           , STOR_CD
                      FROM   C_CUST_REST
                      WHERE  COMP_CD  = V_COMP_CD
                      AND    JOIN_DT <= V_LAST_DT
                     )
             )                   T1
           , (--고객의 집계년월의 등급변경내역을 구한다.
              SELECT CUST_ID
                   , CHG_TO    LVL_CD
              FROM   C_CUST_HIS
              WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                  IN (SELECT CUST_ID
                           , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                      FROM   C_CUST_HIS
                      WHERE  COMP_CD = V_COMP_CD
                      AND    CHG_DT <= V_LAST_DT
                      AND    CHG_DIV = '15'
                      GROUP BY CUST_ID
                     )
              AND    CHG_DIV = '15'
             )                   T2
           , (--고객의 집계년월의 상태변경내역을 구한다.
              SELECT CUST_ID
                   , CHG_TO    CUST_STAT
              FROM   C_CUST_HIS
              WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                  IN (SELECT CUST_ID
                           , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                      FROM   C_CUST_HIS
                      WHERE  COMP_CD = V_COMP_CD
                      AND    CHG_DT <= V_LAST_DT
                      AND    CHG_DIV = '13'
                      GROUP BY CUST_ID
                     )
              AND    CHG_DIV = '13'
             )                   T3
           , C_CUST_DEVICE       T4
           , C_CUST_DEVICE_PUSH  T5
           , C_CUST_DEVICE_PUSH  T6
           , C_CUST_DEVICE_PUSH  T7
           , COMMON              X1
      WHERE  T1.CUST_ID         = T2.CUST_ID(+)
      AND    T1.CUST_ID         = T3.CUST_ID(+)
      AND    T1.CUST_ID         = T4.CUST_ID(+)
      AND    'Y'                = T4.USE_YN(+)
      AND    T1.CUST_ID         = T5.CUST_ID(+)
      AND    'couponEnd'        = T5.DIV_NM(+)
      AND    T1.CUST_ID         = T6.CUST_ID(+)
      AND    'membershipCoupon' = T6.DIV_NM(+)
      AND    T1.CUST_ID         = T7.CUST_ID(+)
      AND    'promotion'        = T7.DIV_NM(+)
      AND    X1.CODE_TP         = '01760'
      AND    T1.CUST_AGE BETWEEN X1.VAL_N1 AND X1.VAL_N2
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_APP_INST', 'APP.설치 회원 집계 생성', '2-1.기준월 당시 회원정보 생성:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;

  ---------------------------------------------------------------------------------------------------
  --2-2.월자료 집계
  ---------------------------------------------------------------------------------------------------
  IF (PO_RETC IS NULL) AND (PI_MTFV = TRUE) THEN
    BEGIN
      MERGE
      INTO  STAT_APP_INST    TAR
      USING (SELECT 'M'                      INFO_DIV1
                  , SUBSTR(V_YMD,1,6)||'00'  STD_YMD
                  , COMP_CD
                  , BRAND_CD
                  , ORD_NO                   INFO_DIV2
                  , LVL_CD
                  , TOTL
                  , AAPP
                  , UAPP
                  , AAPP                     TOKN_ALL
                  , TOKN_NOR
                  , AAPP-TOKN_NOR            TOKN_BAD
                  , COUP_END
                  , COUP_MAK
                  , PRMT_EVT
             FROM  (--전체회원
                    SELECT COMP_CD
                         , BRAND_CD
                         , 1                                                                                  ORD_NO
                         , LVL_CD                                                                             LVL_CD
                         , COUNT(*)                                                                           TOTL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,0,1                         )))  AAPP
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,1,0                         )))  UAPP
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,1                         )))  TOKN_ALL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',0,1))))  TOKN_NOR
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',1,0))))  TOKN_BAD
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_END_YN,'Y',1,0                          )))  COUP_END
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_MAK_YN,'Y',1,0                          )))  COUP_MAK
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(PRMT_EVT_YN,'Y',1,0                          )))  PRMT_EVT
                    FROM   TEMP_CUST_STAT2
                    WHERE  COMP_CD    = V_COMP_CD
                    AND    CUST_STAT IN ('2','3')
                    AND    JOIN_DT   <= V_LAST_DT
                    GROUP BY COMP_CD,BRAND_CD,LVL_CD
                   UNION 
                    --휴면회원
                    SELECT COMP_CD
                         , BRAND_CD
                         , 2                                                                                  ORD_NO
                         , LVL_CD                                                                             LVL_CD
                         , COUNT(*)                                                                           TOTL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,0,1                         )))  AAPP
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,1,0                         )))  UAPP
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,1                         )))  TOKN_ALL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',0,1))))  TOKN_NOR
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',1,0))))  TOKN_BAD
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_END_YN,'Y',1,0                          )))  COUP_END
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_MAK_YN,'Y',1,0                          )))  COUP_MAK
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(PRMT_EVT_YN,'Y',1,0                          )))  PRMT_EVT
                    FROM   TEMP_CUST_STAT2
                    WHERE  COMP_CD    = V_COMP_CD
                    AND    CUST_STAT  = '8'
                    AND    (CASH_USE_DT < TO_CHAR(ADD_MONTHS(TO_DATE(V_LAST_DT,'YYYYMMDD'),-12),'YYYYMMDD') AND LAST_LOGIN_DT < TO_CHAR(ADD_MONTHS(TO_DATE(V_LAST_DT,'YYYYMMDD'),-12),'YYYYMMDD'))
                    AND    (CASH_USE_DT   BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(SUBSTR(V_YMD,1,6)||'01','YYYYMMDD'),-12),'YYYYMMDD') AND TO_CHAR(ADD_MONTHS(TO_DATE(V_LAST_DT,'YYYYMMDD'),-12),'YYYYMMDD')
                         OR LAST_LOGIN_DT BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(SUBSTR(V_YMD,1,6)||'01','YYYYMMDD'),-12),'YYYYMMDD') AND TO_CHAR(ADD_MONTHS(TO_DATE(V_LAST_DT,'YYYYMMDD'),-12),'YYYYMMDD'))
                    GROUP BY COMP_CD,BRAND_CD,LVL_CD
                   UNION    
                    --신규회원
                    SELECT COMP_CD
                         , BRAND_CD
                         , 3                                                                                  ORD_NO
                         , LVL_CD                                                                             LVL_CD
                         , COUNT(*)                                                                           TOTL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,0,1                         )))  AAPP
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,1,0                         )))  UAPP
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,1                         )))  TOKN_ALL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',0,1))))  TOKN_NOR
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',1,0))))  TOKN_BAD
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_END_YN,'Y',1,0                          )))  COUP_END
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_MAK_YN,'Y',1,0                          )))  COUP_MAK
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(PRMT_EVT_YN,'Y',1,0                          )))  PRMT_EVT
                    FROM   TEMP_CUST_STAT2
                    WHERE  COMP_CD    = V_COMP_CD
                    AND    JOIN_DT BETWEEN SUBSTR(V_YMD,1,6)||'01' AND V_LAST_DT
                    GROUP BY COMP_CD,BRAND_CD,LVL_CD
                   UNION    
                    --탈퇴회원
                    SELECT COMP_CD
                         , BRAND_CD
                         , 4                                                                                  ORD_NO
                         , LVL_CD                                                                             LVL_CD
                         , COUNT(*)                                                                           TOTL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,0,1                         )))  AAPP
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(APP_INST_DT,NULL,1,0                         )))  UAPP
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,1                         )))  TOKN_ALL
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',0,1))))  TOKN_NOR
--                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(AUTH_TOKEN ,NULL,0,DECODE(AUTH_TOKEN,'N',1,0))))  TOKN_BAD
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_END_YN,'Y',1,0                          )))  COUP_END
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(COUP_MAK_YN,'Y',1,0                          )))  COUP_MAK
                         , SUM(DECODE(CUST_ID,NULL,0,DECODE(PRMT_EVT_YN,'Y',1,0                          )))  PRMT_EVT
                    FROM   TEMP_CUST_STAT2
                    WHERE  COMP_CD    = V_COMP_CD
                    AND    CUST_STAT  = '9'
                    AND    LEAVE_DT BETWEEN SUBSTR(V_YMD,1,6)||'01' AND V_LAST_DT
                    GROUP BY COMP_CD,BRAND_CD,LVL_CD
                   )
            )                SOC
      ON    (    TAR.INFO_DIV1 = SOC.INFO_DIV1
             AND TAR.STD_YMD   = SOC.STD_YMD  
             AND TAR.COMP_CD   = SOC.COMP_CD  
             AND TAR.BRAND_CD  = SOC.BRAND_CD 
             AND TAR.INFO_DIV2 = SOC.INFO_DIV2
             AND TAR.LVL_CD    = SOC.LVL_CD   
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      TAR.TOTL     = SOC.TOTL
                                    , TAR.AAPP     = SOC.AAPP
                                    , TAR.UAPP     = SOC.UAPP
                                    , TAR.TOKN_ALL = SOC.TOKN_ALL
                                    , TAR.TOKN_NOR = SOC.TOKN_NOR
                                    , TAR.TOKN_BAD = SOC.TOKN_BAD
                                    , TAR.COUP_END = SOC.COUP_END
                                    , TAR.COUP_MAK = SOC.COUP_MAK
                                    , TAR.PRMT_EVT = SOC.PRMT_EVT
                                    , TAR.UPD_DT   = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( INFO_DIV1    , STD_YMD     , COMP_CD     , BRAND_CD        -- 1, 2, 3, 4
                                    , INFO_DIV2    , LVL_CD      , TOTL        , AAPP            -- 5, 6, 7, 8
                                    , UAPP         , TOKN_ALL    , TOKN_NOR    , TOKN_BAD        -- 9,10,11,12
                                    , COUP_END     , COUP_MAK    , PRMT_EVT    , INST_DT      )  --13,14,15,16
                             VALUES ( SOC.INFO_DIV1, SOC.STD_YMD , SOC.COMP_CD , SOC.BRAND_CD    -- 1, 2, 3, 4
                                    , SOC.INFO_DIV2, SOC.LVL_CD  , SOC.TOTL    , SOC.AAPP        -- 5, 6, 7, 8
                                    , SOC.UAPP     , SOC.TOKN_ALL, SOC.TOKN_NOR, SOC.TOKN_BAD    -- 9,10,11,12
                                    , SOC.COUP_END , SOC.COUP_MAK, SOC.PRMT_EVT, SYSDATE      )  --13,14,15,16
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_APP_INST', 'APP.설치 회원 집계 생성', '2-2.일자료 집계:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;

  IF PO_RETC IS NULL THEN
    PO_RETC := 'OK';
    STAT_LOG_SAVE('BATCH_STAT_APP_INST', 'APP.설치 회원 집계 생성', '전체:::'||V_YMD, PO_RETC, V_RETC);
  END IF;

END BATCH_STAT_APP_INST;

/
