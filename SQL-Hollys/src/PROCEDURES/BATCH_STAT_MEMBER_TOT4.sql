--------------------------------------------------------
--  DDL for Procedure BATCH_STAT_MEMBER_TOT4
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_STAT_MEMBER_TOT4" (
  PI_YYMM    IN   VARCHAR2,   --기준년월
  PI_QUARTER IN   VARCHAR2,   --분기
  PI_FR_MON  IN   VARCHAR2,   --분기 시작년월
  PI_TO_MON  IN   VARCHAR2,   --분기 종료년월
  PI_QTFV    IN   BOOLEAN ,   --
  PI_YTFV    IN   BOOLEAN ,   --
  PO_RETC    OUT  VARCHAR2
)
IS
  V_INFO_DIV2   VARCHAR2(1  );   --정보종류
  V_COMP_CD     VARCHAR2(3  );   --회사코드
  V_YYMM        VARCHAR2(6  );   --기준년월
  V_QUARTER     VARCHAR2(6  );   --분기
  V_FR_MON      VARCHAR2(6  );   --분기 시작년월
  V_TO_MON      VARCHAR2(6  );   --분기 종료년월

  V_RETC        VARCHAR2(100);

BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-05-30
  -- Description   :   전체 회원 현황 자료 생성...지역별
  --                    월별, 분기별, 년도별
  -- ==========================================================================================

  --파라메터 확인
  IF PI_YYMM    IS NULL OR
     PI_QUARTER IS NULL OR
     PI_FR_MON  IS NULL OR
     PI_TO_MON  IS NULL THEN 
    PO_RETC := 'NG';
    STAT_LOG_SAVE('BATCH_STAT_MEMBER_TOT4', '전체 회원 현황 자료 생성', '4.지역별:::파라메터 오류', PO_RETC, V_RETC);
    RETURN;
  END IF;

  --초기값 셋팅...
  SELECT '3'
       , '016'
       , PI_YYMM
       , PI_QUARTER
       , PI_FR_MON
       , PI_TO_MON
  INTO   V_INFO_DIV2
       , V_COMP_CD
       , V_YYMM
       , V_QUARTER
       , V_FR_MON
       , V_TO_MON
  FROM   DUAL
  ;

  V_RETC := NULL;


  ---------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------
  --1-1.월별_SSS구분별
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  STAT_MEMBER_TOT    TAR
      USING (SELECT 'M'                            INFO_DIV1
                  , V_INFO_DIV2                    INFO_DIV2
                  , V_YYMM                         STD_YYMM
                  , T0.COMP_CD                     COMP_CD
                  , T0.BRAND_CD                    BRAND_CD
                  , T0.SSS_DIV                     SSS_DIV
                  , '-'                            STOR_TP
                  , '-'                            TRAD_AREA
                  , T0.SIDO_CD                     SIDO_CD
                  , '-'                            SC_CD
                  , '-'                            STOR_TG
                  , '-'                            STOR_CD
                  , NVL(T1.MEMB_TOT         ,0)    MEMB_TOT
                  , NVL(T1.MEMB_NEW_AAPP    ,0)    MEMB_NEW_AAPP
                  , NVL(T1.MEMB_NEW_UAPP    ,0)    MEMB_NEW_UAPP
                  , NVL(T2.MEMB_SALE_AAPP   ,0)    MEMB_SALE_AAPP
                  , NVL(T2.MEMB_SALE_UAPP   ,0)    MEMB_SALE_UAPP
                  , NVL(T2.MEMB_CUST_CNT    ,0)    MEMB_TOT_CUST_CNT
                  , NVL(T2.PUBL_CUST_CNT    ,0)    PUBL_TOT_CUST_CNT
                  , NVL(T2.MEMB_BILL_CNT    ,0)    MEMB_TOT_BILL_CNT
                  , NVL(T2.PUBL_BILL_CNT    ,0)    PUBL_TOT_BILL_CNT
                  , NVL(T2.MEMB_TOT_SALE_QTY,0)    MEMB_TOT_SALE_QTY
                  , NVL(T2.PUBL_TOT_SALE_QTY,0)    PUBL_TOT_SALE_QTY
                  , NVL(T2.MEMB_TOT_SALE_AMT,0)    MEMB_TOT_SALE_AMT
                  , NVL(T2.PUBL_TOT_SALE_AMT,0)    PUBL_TOT_SALE_AMT
                  , NVL(T3.MEMB_CUST_CNT    ,0)    MEMB_AVG_CUST_CNT
                  , NVL(T3.PUBL_CUST_CNT    ,0)    PUBL_AVG_CUST_CNT
                  , NVL(T3.MEMB_BILL_CNT    ,0)    MEMB_AVG_BILL_CNT
                  , NVL(T3.PUBL_BILL_CNT    ,0)    PUBL_AVG_BILL_CNT
                  , NVL(T3.MEMB_SALE_AMT    ,0)    MEMB_AVG_SALE_AMT
                  , NVL(T3.PUBL_SALE_AMT    ,0)    PUBL_AVG_SALE_AMT
                  , NVL(T4.STOR_CNT         ,0)    STOR_CNT
             FROM   (
                     SELECT A.COMP_CD            COMP_CD
                          , A.BRAND_CD           BRAND_CD
                          , C.SSS_DIV            SSS_DIV
                          , NVL(B.SIDO_CD,'?')   SIDO_CD
                     FROM   BRAND       A
                          , TEMP_STORE  B
                          , (SELECT 'SSS' SSS_DIV FROM DUAL
                            UNION
                             SELECT 'NOT' SSS_DIV FROM DUAL
                            )           C
                     WHERE  A.COMP_CD  = V_COMP_CD
                     AND    A.USE_YN   = 'Y'
                     AND    A.COMP_CD  = B.COMP_CD
                     AND    A.BRAND_CD = B.BRAND_CD
                     GROUP BY A.COMP_CD,A.BRAND_CD,C.SSS_DIV,B.SIDO_CD
                    )       T0
                  , (--전체회원,신규회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SSS_DIV
                          , SIDO_CD
                          , COUNT(*)               MEMB_TOT
                          , SUM(CASE WHEN JOIN_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                     THEN CASE WHEN INST_DT <= V_YYMM||'31'
                                               THEN 1
                                               ELSE 0
                                          END
                                     ELSE 0
                                END
                               )                   MEMB_NEW_AAPP
                          , SUM(CASE WHEN JOIN_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                     THEN CASE WHEN INST_DT <= V_YYMM||'31'
                                               THEN 0
                                               ELSE 1
                                          END
                                     ELSE 0
                                END
                               )                   MEMB_NEW_UAPP
                      FROM  (SELECT A.COMP_CD               COMP_CD
                                  , A.BRAND_CD              BRAND_CD
                                  , NVL(B.SSS_DIV_M,'NOT')  SSS_DIV
                                  , NVL(B.SIDO_CD  ,'?'  )  SIDO_CD
                                  , A.JOIN_DT               JOIN_DT
                                  , A.APP_INST_DT_M         INST_DT
                             FROM   TEMP_CUST_STAT1 A
                                  , TEMP_STORE      B
                             WHERE  A.COMP_CD  = V_COMP_CD
                             AND    A.CUST_STAT_M IN ('1','2','3')
                             AND    A.JOIN_DT <= V_YYMM||'31'
                             AND    A.COMP_CD  = B.COMP_CD(+)
                             AND    A.BRAND_CD = B.BRAND_CD(+)
                             AND    A.STOR_CD  = B.STOR_CD(+)
                            )
                      GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                    )       T1
                  , (--구매회원,객수,조수,총구매수량,총구매금액-회원/비회원
                     SELECT A.COMP_CD                                                       COMP_CD
                          , A.BRAND_CD                                                      BRAND_CD
                          , A.SSS_DIV                                                       SSS_DIV
                          , A.SIDO_CD                                                       SIDO_CD
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_M,NULL,0,1)))  MEMB_SALE_AAPP
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_M,NULL,1,0)))  MEMB_SALE_UAPP
                          , SUM(A.MEMB_CUST_CNT                                          )  MEMB_CUST_CNT
                          , SUM(A.PUBL_CUST_CNT                                          )  PUBL_CUST_CNT
                          , SUM(A.MEMB_BILL_CNT                                          )  MEMB_BILL_CNT
                          , SUM(A.PUBL_BILL_CNT                                          )  PUBL_BILL_CNT
                          , SUM(A.MEMB_TOT_SALE_QTY                                      )  MEMB_TOT_SALE_QTY
                          , SUM(A.PUBL_TOT_SALE_QTY                                      )  PUBL_TOT_SALE_QTY
                          , SUM(A.MEMB_TOT_SALE_AMT                                      )  MEMB_TOT_SALE_AMT
                          , SUM(A.PUBL_TOT_SALE_AMT                                      )  PUBL_TOT_SALE_AMT
                     FROM   (
                             SELECT AA.COMP_CD
                                  , AA.BRAND_CD
                                  , NVL(BB.SSS_DIV_M,'NOT')  SSS_DIV
                                  , NVL(BB.SIDO_CD  ,'?'  )  SIDO_CD
                                  , AA.CUST_ID
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN AA.CUST_M_CNT+AA.CUST_F_CNT
                                             ELSE 0
                                        END
                                       )                     MEMB_CUST_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN AA.CUST_M_CNT+AA.CUST_F_CNT
                                             ELSE 0
                                        END
                                       )                     PUBL_CUST_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN DECODE(AA.SALE_DIV,1,1,2,-1,0)
                                             ELSE 0
                                        END
                                       )                     MEMB_BILL_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN DECODE(AA.SALE_DIV,1,1,2,-1,0)
                                             ELSE 0
                                        END
                                       )                     PUBL_BILL_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN AA.SALE_QTY
                                             ELSE 0
                                        END
                                       )                     MEMB_TOT_SALE_QTY
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN AA.SALE_QTY
                                             ELSE 0
                                        END
                                       )                     PUBL_TOT_SALE_QTY
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN AA.GRD_I_AMT+AA.GRD_O_AMT-AA.VAT_I_AMT-AA.VAT_O_AMT
                                             ELSE 0
                                        END
                                       )                     MEMB_TOT_SALE_AMT
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN AA.GRD_I_AMT+AA.GRD_O_AMT-AA.VAT_I_AMT-AA.VAT_O_AMT
                                             ELSE 0
                                        END
                                       )                     PUBL_TOT_SALE_AMT
                             FROM   SALE_HD     AA
                                  , TEMP_STORE  BB
                             WHERE  AA.COMP_CD  = V_COMP_CD
                             AND    AA.SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                             AND    AA.GIFT_DIV = '0'
                             AND    AA.COMP_CD  = BB.COMP_CD(+)
                             AND    AA.BRAND_CD = BB.BRAND_CD(+)
                             AND    AA.STOR_CD  = BB.STOR_CD(+)
                             GROUP BY AA.COMP_CD,AA.BRAND_CD,AA.CUST_ID,BB.SSS_DIV_M,BB.SIDO_CD
                            )               A
                          , TEMP_CUST_STAT1 B
                     WHERE  A.CUST_ID = B.CUST_ID(+)
                     GROUP BY A.COMP_CD,A.BRAND_CD,A.SSS_DIV,A.SIDO_CD
                    )       T2
                  , (--매장당 일평균 객수,조수,판매금액-회원/비회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SSS_DIV
                          , SIDO_CD
                          , SUM(MEMB_CUST_CNT)   MEMB_CUST_CNT
                          , SUM(MEMB_BILL_CNT)   MEMB_BILL_CNT
                          , SUM(MEMB_SALE_AMT)   MEMB_SALE_AMT
                          , SUM(PUBL_CUST_CNT)   PUBL_CUST_CNT
                          , SUM(PUBL_BILL_CNT)   PUBL_BILL_CNT
                          , SUM(PUBL_SALE_AMT)   PUBL_SALE_AMT
                     FROM   (--회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SSS_DIV
                                  , SIDO_CD
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  MEMB_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  MEMB_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  MEMB_SALE_AMT
                                  , 0                               PUBL_CUST_CNT
                                  , 0                               PUBL_BILL_CNT
                                  , 0                               PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD                COMP_CD
                                          , A.BRAND_CD               BRAND_CD
                                          , NVL(C.SSS_DIV_M, 'NOT')  SSS_DIV
                                          , NVL(C.SIDO_CD  , '?'  )  SIDO_CD
                                          , A.STOR_CD                STOR_CD
                                          , A.DAY_CNT                DAY_CNT
                                          , NVL(B.CUST_CNT, 0)       CUST_CNT
                                          , NVL(B.BILL_CNT, 0)       BILL_CNT
                                          , NVL(B.SALE_AMT, 0)       SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NOT NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                            UNION
                             --비회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SSS_DIV
                                  , SIDO_CD
                                  , 0                               MEMB_CUST_CNT
                                  , 0                               MEMB_BILL_CNT
                                  , 0                               MEMB_SALE_AMT
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  PUBL_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  PUBL_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD                COMP_CD
                                          , A.BRAND_CD               BRAND_CD
                                          , NVL(C.SSS_DIV_M, 'NOT')  SSS_DIV
                                          , NVL(C.SIDO_CD  , '?'  )  SIDO_CD
                                          , A.STOR_CD                STOR_CD
                                          , A.DAY_CNT                DAY_CNT
                                          , NVL(B.CUST_CNT, 0)       CUST_CNT
                                          , NVL(B.BILL_CNT, 0)       BILL_CNT
                                          , NVL(B.SALE_AMT, 0)       SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                            )
                     GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                    )       T3
                  , (
                     SELECT COMP_CD
                          , BRAND_CD
                          , SSS_DIV_M  SSS_DIV           
                          , SIDO_CD   
                          , COUNT(*)   STOR_CNT
                     FROM   TEMP_STORE
                     WHERE  COMP_CD = V_COMP_CD
                     GROUP BY COMP_CD,BRAND_CD,SSS_DIV_M,SIDO_CD
                    )       T4
             WHERE  T0.COMP_CD  = T1.COMP_CD(+)
             AND    T0.BRAND_CD = T1.BRAND_CD(+)
             AND    T0.SSS_DIV  = T1.SSS_DIV(+)
             AND    T0.SIDO_CD  = T1.SIDO_CD(+)
             AND    T0.COMP_CD  = T2.COMP_CD(+)
             AND    T0.BRAND_CD = T2.BRAND_CD(+)
             AND    T0.SSS_DIV  = T2.SSS_DIV(+)
             AND    T0.SIDO_CD  = T2.SIDO_CD(+)
             AND    T0.COMP_CD  = T3.COMP_CD(+)
             AND    T0.BRAND_CD = T3.BRAND_CD(+)
             AND    T0.SSS_DIV  = T3.SSS_DIV(+)
             AND    T0.SIDO_CD  = T3.SIDO_CD(+)
             AND    T0.COMP_CD  = T4.COMP_CD(+)
             AND    T0.BRAND_CD = T4.BRAND_CD(+)
             AND    T0.SSS_DIV  = T4.SSS_DIV(+)
             AND    T0.SIDO_CD  = T4.SIDO_CD(+)
            )                  SOC
      ON    (    TAR.INFO_DIV1 = SOC.INFO_DIV1
             AND TAR.INFO_DIV2 = SOC.INFO_DIV2
             AND TAR.STD_YYMM  = SOC.STD_YYMM
             AND TAR.COMP_CD   = SOC.COMP_CD
             AND TAR.BRAND_CD  = SOC.BRAND_CD
             AND TAR.SSS_DIV   = SOC.SSS_DIV
             AND TAR.STOR_TP   = SOC.STOR_TP
             AND TAR.TRAD_AREA = SOC.TRAD_AREA
             AND TAR.SIDO_CD   = SOC.SIDO_CD
             AND TAR.SC_CD     = SOC.SC_CD
             AND TAR.STOR_TG   = SOC.STOR_TG
             AND TAR.STOR_CD   = SOC.STOR_CD
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      TAR.MEMB_TOT          = SOC.MEMB_TOT
                                    , TAR.MEMB_NEW_AAPP     = SOC.MEMB_NEW_AAPP
                                    , TAR.MEMB_NEW_UAPP     = SOC.MEMB_NEW_UAPP
                                    , TAR.MEMB_SALE_AAPP    = SOC.MEMB_SALE_AAPP
                                    , TAR.MEMB_SALE_UAPP    = SOC.MEMB_SALE_UAPP
                                    , TAR.MEMB_TOT_CUST_CNT = SOC.MEMB_TOT_CUST_CNT
                                    , TAR.PUBL_TOT_CUST_CNT = SOC.PUBL_TOT_CUST_CNT
                                    , TAR.MEMB_TOT_BILL_CNT = SOC.MEMB_TOT_BILL_CNT
                                    , TAR.PUBL_TOT_BILL_CNT = SOC.PUBL_TOT_BILL_CNT
                                    , TAR.MEMB_TOT_SALE_QTY = SOC.MEMB_TOT_SALE_QTY
                                    , TAR.PUBL_TOT_SALE_QTY = SOC.PUBL_TOT_SALE_QTY
                                    , TAR.MEMB_TOT_SALE_AMT = SOC.MEMB_TOT_SALE_AMT
                                    , TAR.PUBL_TOT_SALE_AMT = SOC.PUBL_TOT_SALE_AMT
                                    , TAR.MEMB_AVG_CUST_CNT = SOC.MEMB_AVG_CUST_CNT
                                    , TAR.PUBL_AVG_CUST_CNT = SOC.PUBL_AVG_CUST_CNT
                                    , TAR.MEMB_AVG_BILL_CNT = SOC.MEMB_AVG_BILL_CNT
                                    , TAR.PUBL_AVG_BILL_CNT = SOC.PUBL_AVG_BILL_CNT
                                    , TAR.MEMB_AVG_SALE_AMT = SOC.MEMB_AVG_SALE_AMT
                                    , TAR.PUBL_AVG_SALE_AMT = SOC.PUBL_AVG_SALE_AMT
                                    , TAR.UPD_DT            = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( INFO_DIV1            , INFO_DIV2            , STD_YYMM             , COMP_CD              , BRAND_CD                 -- 1, 2, 3, 4, 5
                                    , SSS_DIV              , STOR_TP              , TRAD_AREA            , SIDO_CD              , SC_CD                    -- 6, 7, 8, 9,10
                                    , STOR_TG              , STOR_CD              , MEMB_TOT             , MEMB_NEW_AAPP        , MEMB_NEW_UAPP            --11,12,13,14,15
                                    , MEMB_SALE_AAPP       , MEMB_SALE_UAPP       , MEMB_TOT_CUST_CNT    , PUBL_TOT_CUST_CNT    , MEMB_TOT_BILL_CNT        --16,17,18,19,20
                                    , PUBL_TOT_BILL_CNT    , MEMB_TOT_SALE_QTY    , PUBL_TOT_SALE_QTY    , MEMB_TOT_SALE_AMT    , PUBL_TOT_SALE_AMT        --21,22,23,24,25
                                    , MEMB_AVG_CUST_CNT    , PUBL_AVG_CUST_CNT    , MEMB_AVG_BILL_CNT    , PUBL_AVG_BILL_CNT    , MEMB_AVG_SALE_AMT        --26,27,28,29,30
                                    , PUBL_AVG_SALE_AMT    , INST_DT                                                                                    )  --31,32
                             VALUES ( SOC.INFO_DIV1        , SOC.INFO_DIV2        , SOC.STD_YYMM         , SOC.COMP_CD          , SOC.BRAND_CD             -- 1, 2, 3, 4, 5
                                    , SOC.SSS_DIV          , SOC.STOR_TP          , SOC.TRAD_AREA        , SOC.SIDO_CD          , SOC.SC_CD                -- 6, 7, 8, 9,10
                                    , SOC.STOR_TG          , SOC.STOR_CD          , SOC.MEMB_TOT         , SOC.MEMB_NEW_AAPP    , SOC.MEMB_NEW_UAPP        --11,12,13,14,15
                                    , SOC.MEMB_SALE_AAPP   , SOC.MEMB_SALE_UAPP   , SOC.MEMB_TOT_CUST_CNT, SOC.PUBL_TOT_CUST_CNT, SOC.MEMB_TOT_BILL_CNT    --16,17,18,19,20
                                    , SOC.PUBL_TOT_BILL_CNT, SOC.MEMB_TOT_SALE_QTY, SOC.PUBL_TOT_SALE_QTY, SOC.MEMB_TOT_SALE_AMT, SOC.PUBL_TOT_SALE_AMT    --21,22,23,24,25
                                    , SOC.MEMB_AVG_CUST_CNT, SOC.PUBL_AVG_CUST_CNT, SOC.MEMB_AVG_BILL_CNT, SOC.PUBL_AVG_BILL_CNT, SOC.MEMB_AVG_SALE_AMT    --26,27,28,29,30
                                    , SOC.PUBL_AVG_SALE_AMT, SYSDATE                                                                                    )  --31,32
      ;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_MEMBER_TOT4', '전체 회원 현황 자료 생성', '4-1-1.지역별-월별_SSS구분별:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;
  ---------------------------------------------------------------------------------------------------
  --1-2.월별_합
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  STAT_MEMBER_TOT    TAR
      USING (SELECT 'M'                            INFO_DIV1
                  , V_INFO_DIV2                    INFO_DIV2
                  , V_YYMM                         STD_YYMM
                  , T0.COMP_CD                     COMP_CD
                  , T0.BRAND_CD                    BRAND_CD
                  , 'TOT'                          SSS_DIV
                  , '-'                            STOR_TP
                  , '-'                            TRAD_AREA
                  , T0.SIDO_CD                     SIDO_CD
                  , '-'                            SC_CD
                  , '-'                            STOR_TG
                  , '-'                            STOR_CD
                  , NVL(T1.MEMB_TOT         ,0)    MEMB_TOT
                  , NVL(T1.MEMB_NEW_AAPP    ,0)    MEMB_NEW_AAPP
                  , NVL(T1.MEMB_NEW_UAPP    ,0)    MEMB_NEW_UAPP
                  , NVL(T2.MEMB_SALE_AAPP   ,0)    MEMB_SALE_AAPP
                  , NVL(T2.MEMB_SALE_UAPP   ,0)    MEMB_SALE_UAPP
                  , NVL(T1.MEMB_TOT_CUST_CNT,0)    MEMB_TOT_CUST_CNT
                  , NVL(T1.PUBL_TOT_CUST_CNT,0)    PUBL_TOT_CUST_CNT
                  , NVL(T1.MEMB_TOT_BILL_CNT,0)    MEMB_TOT_BILL_CNT
                  , NVL(T1.PUBL_TOT_BILL_CNT,0)    PUBL_TOT_BILL_CNT
                  , NVL(T1.MEMB_TOT_SALE_QTY,0)    MEMB_TOT_SALE_QTY
                  , NVL(T1.PUBL_TOT_SALE_QTY,0)    PUBL_TOT_SALE_QTY
                  , NVL(T1.MEMB_TOT_SALE_AMT,0)    MEMB_TOT_SALE_AMT
                  , NVL(T1.PUBL_TOT_SALE_AMT,0)    PUBL_TOT_SALE_AMT
                  , NVL(T3.MEMB_CUST_CNT    ,0)    MEMB_AVG_CUST_CNT
                  , NVL(T3.PUBL_CUST_CNT    ,0)    PUBL_AVG_CUST_CNT
                  , NVL(T3.MEMB_BILL_CNT    ,0)    MEMB_AVG_BILL_CNT
                  , NVL(T3.PUBL_BILL_CNT    ,0)    PUBL_AVG_BILL_CNT
                  , NVL(T3.MEMB_SALE_AMT    ,0)    MEMB_AVG_SALE_AMT
                  , NVL(T3.PUBL_SALE_AMT    ,0)    PUBL_AVG_SALE_AMT
                  , NVL(T1.STOR_CNT         ,0)    STOR_CNT
             FROM   (
                     SELECT A.COMP_CD            COMP_CD
                          , A.BRAND_CD           BRAND_CD
                          , NVL(B.SIDO_CD,'?')   SIDO_CD
                     FROM   BRAND       A
                          , TEMP_STORE  B
                     WHERE  A.COMP_CD  = V_COMP_CD
                     AND    A.USE_YN   = 'Y'
                     AND    A.COMP_CD  = B.COMP_CD
                     AND    A.BRAND_CD = B.BRAND_CD
                     GROUP BY A.COMP_CD,A.BRAND_CD,B.SIDO_CD
                    )       T0
                  , (--전체회원,신규회원,객수,조수,총구매수량,총구매금액-회원/비회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SIDO_CD
                          , SUM(MEMB_TOT         )  MEMB_TOT
                          , SUM(MEMB_NEW_AAPP    )  MEMB_NEW_AAPP
                          , SUM(MEMB_NEW_UAPP    )  MEMB_NEW_UAPP
                          , SUM(MEMB_TOT_CUST_CNT)  MEMB_TOT_CUST_CNT
                          , SUM(PUBL_TOT_CUST_CNT)  PUBL_TOT_CUST_CNT
                          , SUM(MEMB_TOT_BILL_CNT)  MEMB_TOT_BILL_CNT
                          , SUM(PUBL_TOT_BILL_CNT)  PUBL_TOT_BILL_CNT
                          , SUM(MEMB_TOT_SALE_QTY)  MEMB_TOT_SALE_QTY
                          , SUM(PUBL_TOT_SALE_QTY)  PUBL_TOT_SALE_QTY
                          , SUM(MEMB_TOT_SALE_AMT)  MEMB_TOT_SALE_AMT
                          , SUM(PUBL_TOT_SALE_AMT)  PUBL_TOT_SALE_AMT
                          , SUM(STOR_CNT         )  STOR_CNT
                     FROM   STAT_MEMBER_TOT
                     WHERE  INFO_DIV1  = 'M'
                     AND    INFO_DIV2  = V_INFO_DIV2
                     AND    COMP_CD    = V_COMP_CD
                     AND    STD_YYMM   = V_YYMM
                     AND    SSS_DIV   <> 'TOT'
                     AND    STOR_TP    = '-'
                     AND    TRAD_AREA  = '-'
                     AND    SIDO_CD   <> '-'
                     AND    SC_CD      = '-'
                     AND    STOR_TG    = '-'
                     AND    STOR_CD    = '-'
                     GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                    )       T1
                  , (--구매회원
                     SELECT A.COMP_CD                                                       COMP_CD
                          , A.BRAND_CD                                                      BRAND_CD
                          , A.SIDO_CD                                                       SIDO_CD
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_M,NULL,0,1)))  MEMB_SALE_AAPP
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_M,NULL,1,0)))  MEMB_SALE_UAPP
                     FROM   (
                             SELECT AA.COMP_CD
                                  , AA.BRAND_CD
                                  , NVL(BB.SIDO_CD,'?')  SIDO_CD
                                  , AA.CUST_ID
                             FROM   SALE_HD     AA
                                  , TEMP_STORE  BB
                             WHERE  AA.COMP_CD  = V_COMP_CD
                             AND    AA.SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                             AND    AA.GIFT_DIV = '0'
                             AND    AA.COMP_CD  = BB.COMP_CD(+)
                             AND    AA.BRAND_CD = BB.BRAND_CD(+)
                             AND    AA.STOR_CD  = BB.STOR_CD(+)
                             GROUP BY AA.COMP_CD,AA.BRAND_CD,AA.CUST_ID,BB.SIDO_CD
                            )               A
                          , TEMP_CUST_STAT1 B
                     WHERE  A.CUST_ID = B.CUST_ID(+)
                     GROUP BY A.COMP_CD,A.BRAND_CD,A.SIDO_CD
                    )       T2
                  , (--매장당 일평균 객수,조수,판매금액-회원/비회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SIDO_CD
                          , SUM(MEMB_CUST_CNT)   MEMB_CUST_CNT
                          , SUM(MEMB_BILL_CNT)   MEMB_BILL_CNT
                          , SUM(MEMB_SALE_AMT)   MEMB_SALE_AMT
                          , SUM(PUBL_CUST_CNT)   PUBL_CUST_CNT
                          , SUM(PUBL_BILL_CNT)   PUBL_BILL_CNT
                          , SUM(PUBL_SALE_AMT)   PUBL_SALE_AMT
                     FROM   (--회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SIDO_CD
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  MEMB_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  MEMB_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  MEMB_SALE_AMT
                                  , 0                               PUBL_CUST_CNT
                                  , 0                               PUBL_BILL_CNT
                                  , 0                               PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD              COMP_CD
                                          , A.BRAND_CD             BRAND_CD
                                          , NVL(C.SIDO_CD, '?')    SIDO_CD
                                          , A.STOR_CD              STOR_CD
                                          , A.DAY_CNT              DAY_CNT
                                          , NVL(B.CUST_CNT, 0)     CUST_CNT
                                          , NVL(B.BILL_CNT, 0)     BILL_CNT
                                          , NVL(B.SALE_AMT, 0)     SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NOT NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                            UNION
                             --비회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SIDO_CD
                                  , 0                               MEMB_CUST_CNT
                                  , 0                               MEMB_BILL_CNT
                                  , 0                               MEMB_SALE_AMT
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  PUBL_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  PUBL_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD              COMP_CD
                                          , A.BRAND_CD             BRAND_CD
                                          , NVL(C.SIDO_CD, '?')    SIDO_CD
                                          , A.STOR_CD              STOR_CD
                                          , A.DAY_CNT              DAY_CNT
                                          , NVL(B.CUST_CNT, 0)     CUST_CNT
                                          , NVL(B.BILL_CNT, 0)     BILL_CNT
                                          , NVL(B.SALE_AMT, 0)     SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                            )
                     GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                    )       T3
             WHERE  T0.COMP_CD  = T1.COMP_CD(+)
             AND    T0.BRAND_CD = T1.BRAND_CD(+)
             AND    T0.SIDO_CD  = T1.SIDO_CD(+)
             AND    T0.COMP_CD  = T2.COMP_CD(+)
             AND    T0.BRAND_CD = T2.BRAND_CD(+)
             AND    T0.SIDO_CD  = T2.SIDO_CD(+)
             AND    T0.COMP_CD  = T3.COMP_CD(+)
             AND    T0.BRAND_CD = T3.BRAND_CD(+)
             AND    T0.SIDO_CD  = T3.SIDO_CD(+)
            )                  SOC
      ON    (    TAR.INFO_DIV1 = SOC.INFO_DIV1
             AND TAR.INFO_DIV2 = SOC.INFO_DIV2
             AND TAR.STD_YYMM  = SOC.STD_YYMM
             AND TAR.COMP_CD   = SOC.COMP_CD
             AND TAR.BRAND_CD  = SOC.BRAND_CD
             AND TAR.SSS_DIV   = SOC.SSS_DIV
             AND TAR.STOR_TP   = SOC.STOR_TP
             AND TAR.TRAD_AREA = SOC.TRAD_AREA
             AND TAR.SIDO_CD   = SOC.SIDO_CD
             AND TAR.SC_CD     = SOC.SC_CD
             AND TAR.STOR_TG   = SOC.STOR_TG
             AND TAR.STOR_CD   = SOC.STOR_CD
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      TAR.MEMB_TOT          = SOC.MEMB_TOT
                                    , TAR.MEMB_NEW_AAPP     = SOC.MEMB_NEW_AAPP
                                    , TAR.MEMB_NEW_UAPP     = SOC.MEMB_NEW_UAPP
                                    , TAR.MEMB_SALE_AAPP    = SOC.MEMB_SALE_AAPP
                                    , TAR.MEMB_SALE_UAPP    = SOC.MEMB_SALE_UAPP
                                    , TAR.MEMB_TOT_CUST_CNT = SOC.MEMB_TOT_CUST_CNT
                                    , TAR.PUBL_TOT_CUST_CNT = SOC.PUBL_TOT_CUST_CNT
                                    , TAR.MEMB_TOT_BILL_CNT = SOC.MEMB_TOT_BILL_CNT
                                    , TAR.PUBL_TOT_BILL_CNT = SOC.PUBL_TOT_BILL_CNT
                                    , TAR.MEMB_TOT_SALE_QTY = SOC.MEMB_TOT_SALE_QTY
                                    , TAR.PUBL_TOT_SALE_QTY = SOC.PUBL_TOT_SALE_QTY
                                    , TAR.MEMB_TOT_SALE_AMT = SOC.MEMB_TOT_SALE_AMT
                                    , TAR.PUBL_TOT_SALE_AMT = SOC.PUBL_TOT_SALE_AMT
                                    , TAR.MEMB_AVG_CUST_CNT = SOC.MEMB_AVG_CUST_CNT
                                    , TAR.PUBL_AVG_CUST_CNT = SOC.PUBL_AVG_CUST_CNT
                                    , TAR.MEMB_AVG_BILL_CNT = SOC.MEMB_AVG_BILL_CNT
                                    , TAR.PUBL_AVG_BILL_CNT = SOC.PUBL_AVG_BILL_CNT
                                    , TAR.MEMB_AVG_SALE_AMT = SOC.MEMB_AVG_SALE_AMT
                                    , TAR.PUBL_AVG_SALE_AMT = SOC.PUBL_AVG_SALE_AMT
                                    , TAR.UPD_DT            = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( INFO_DIV1            , INFO_DIV2            , STD_YYMM             , COMP_CD              , BRAND_CD                 -- 1, 2, 3, 4, 5
                                    , SSS_DIV              , STOR_TP              , TRAD_AREA            , SIDO_CD              , SC_CD                    -- 6, 7, 8, 9,10
                                    , STOR_TG              , STOR_CD              , MEMB_TOT             , MEMB_NEW_AAPP        , MEMB_NEW_UAPP            --11,12,13,14,15
                                    , MEMB_SALE_AAPP       , MEMB_SALE_UAPP       , MEMB_TOT_CUST_CNT    , PUBL_TOT_CUST_CNT    , MEMB_TOT_BILL_CNT        --16,17,18,19,20
                                    , PUBL_TOT_BILL_CNT    , MEMB_TOT_SALE_QTY    , PUBL_TOT_SALE_QTY    , MEMB_TOT_SALE_AMT    , PUBL_TOT_SALE_AMT        --21,22,23,24,25
                                    , MEMB_AVG_CUST_CNT    , PUBL_AVG_CUST_CNT    , MEMB_AVG_BILL_CNT    , PUBL_AVG_BILL_CNT    , MEMB_AVG_SALE_AMT        --26,27,28,29,30
                                    , PUBL_AVG_SALE_AMT    , INST_DT                                                                                    )  --31,32
                             VALUES ( SOC.INFO_DIV1        , SOC.INFO_DIV2        , SOC.STD_YYMM         , SOC.COMP_CD          , SOC.BRAND_CD             -- 1, 2, 3, 4, 5
                                    , SOC.SSS_DIV          , SOC.STOR_TP          , SOC.TRAD_AREA        , SOC.SIDO_CD          , SOC.SC_CD                -- 6, 7, 8, 9,10
                                    , SOC.STOR_TG          , SOC.STOR_CD          , SOC.MEMB_TOT         , SOC.MEMB_NEW_AAPP    , SOC.MEMB_NEW_UAPP        --11,12,13,14,15
                                    , SOC.MEMB_SALE_AAPP   , SOC.MEMB_SALE_UAPP   , SOC.MEMB_TOT_CUST_CNT, SOC.PUBL_TOT_CUST_CNT, SOC.MEMB_TOT_BILL_CNT    --16,17,18,19,20
                                    , SOC.PUBL_TOT_BILL_CNT, SOC.MEMB_TOT_SALE_QTY, SOC.PUBL_TOT_SALE_QTY, SOC.MEMB_TOT_SALE_AMT, SOC.PUBL_TOT_SALE_AMT    --21,22,23,24,25
                                    , SOC.MEMB_AVG_CUST_CNT, SOC.PUBL_AVG_CUST_CNT, SOC.MEMB_AVG_BILL_CNT, SOC.PUBL_AVG_BILL_CNT, SOC.MEMB_AVG_SALE_AMT    --26,27,28,29,30
                                    , SOC.PUBL_AVG_SALE_AMT, SYSDATE                                                                                    )  --31,32
      ;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_MEMBER_TOT4', '전체 회원 현황 자료 생성', '4-1-2.지역별-월별_합:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;


  ---------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------
  --2-1.분기별_SSS구분별
  ---------------------------------------------------------------------------------------------------
  IF (PO_RETC IS NULL) AND (PI_QTFV = TRUE) THEN
    BEGIN
      MERGE
      INTO  STAT_MEMBER_TOT    TAR
      USING (SELECT 'Q'                            INFO_DIV1
                  , V_INFO_DIV2                    INFO_DIV2
                  , V_QUARTER                      STD_YYMM
                  , T0.COMP_CD                     COMP_CD
                  , T0.BRAND_CD                    BRAND_CD
                  , T0.SSS_DIV                     SSS_DIV
                  , '-'                            STOR_TP
                  , '-'                            TRAD_AREA
                  , T0.SIDO_CD                     SIDO_CD
                  , '-'                            SC_CD
                  , '-'                            STOR_TG
                  , '-'                            STOR_CD
                  , NVL(T1.MEMB_TOT         ,0)    MEMB_TOT
                  , NVL(T1.MEMB_NEW_AAPP    ,0)    MEMB_NEW_AAPP
                  , NVL(T1.MEMB_NEW_UAPP    ,0)    MEMB_NEW_UAPP
                  , NVL(T2.MEMB_SALE_AAPP   ,0)    MEMB_SALE_AAPP
                  , NVL(T2.MEMB_SALE_UAPP   ,0)    MEMB_SALE_UAPP
                  , NVL(T2.MEMB_CUST_CNT    ,0)    MEMB_TOT_CUST_CNT
                  , NVL(T2.PUBL_CUST_CNT    ,0)    PUBL_TOT_CUST_CNT
                  , NVL(T2.MEMB_BILL_CNT    ,0)    MEMB_TOT_BILL_CNT
                  , NVL(T2.PUBL_BILL_CNT    ,0)    PUBL_TOT_BILL_CNT
                  , NVL(T2.MEMB_TOT_SALE_QTY,0)    MEMB_TOT_SALE_QTY
                  , NVL(T2.PUBL_TOT_SALE_QTY,0)    PUBL_TOT_SALE_QTY
                  , NVL(T2.MEMB_TOT_SALE_AMT,0)    MEMB_TOT_SALE_AMT
                  , NVL(T2.PUBL_TOT_SALE_AMT,0)    PUBL_TOT_SALE_AMT
                  , NVL(T3.MEMB_CUST_CNT    ,0)    MEMB_AVG_CUST_CNT
                  , NVL(T3.PUBL_CUST_CNT    ,0)    PUBL_AVG_CUST_CNT
                  , NVL(T3.MEMB_BILL_CNT    ,0)    MEMB_AVG_BILL_CNT
                  , NVL(T3.PUBL_BILL_CNT    ,0)    PUBL_AVG_BILL_CNT
                  , NVL(T3.MEMB_SALE_AMT    ,0)    MEMB_AVG_SALE_AMT
                  , NVL(T3.PUBL_SALE_AMT    ,0)    PUBL_AVG_SALE_AMT
                  , NVL(T4.STOR_CNT         ,0)    STOR_CNT
             FROM   (
                     SELECT A.COMP_CD            COMP_CD
                          , A.BRAND_CD           BRAND_CD
                          , C.SSS_DIV            SSS_DIV
                          , NVL(B.SIDO_CD,'?')   SIDO_CD
                     FROM   BRAND       A
                          , TEMP_STORE  B
                          , (SELECT 'SSS' SSS_DIV FROM DUAL
                            UNION
                             SELECT 'NOT' SSS_DIV FROM DUAL
                            )           C
                     WHERE  A.COMP_CD  = V_COMP_CD
                     AND    A.USE_YN   = 'Y'
                     AND    A.COMP_CD  = B.COMP_CD
                     AND    A.BRAND_CD = B.BRAND_CD
                     GROUP BY A.COMP_CD,A.BRAND_CD,C.SSS_DIV,B.SIDO_CD
                    )       T0
                  , (--전체회원,신규회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SSS_DIV
                          , SIDO_CD
                          , COUNT(*)               MEMB_TOT
                          , SUM(CASE WHEN JOIN_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                     THEN CASE WHEN INST_DT <= V_TO_MON||'31'
                                               THEN 1
                                               ELSE 0
                                          END
                                     ELSE 0
                                END
                               )                   MEMB_NEW_AAPP
                          , SUM(CASE WHEN JOIN_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                     THEN CASE WHEN INST_DT <= V_TO_MON||'31'
                                               THEN 0
                                               ELSE 1
                                          END
                                     ELSE 0
                                END
                               )                   MEMB_NEW_UAPP
                      FROM  (SELECT A.COMP_CD               COMP_CD
                                  , A.BRAND_CD              BRAND_CD
                                  , NVL(B.SSS_DIV_Q,'NOT')  SSS_DIV
                                  , NVL(B.SIDO_CD  ,'?'  )  SIDO_CD
                                  , A.JOIN_DT               JOIN_DT
                                  , A.APP_INST_DT_Q         INST_DT
                             FROM   TEMP_CUST_STAT1 A
                                  , TEMP_STORE      B
                             WHERE  A.COMP_CD  = V_COMP_CD
                             AND    A.CUST_STAT_Q IN ('1','2','3')
                             AND    A.JOIN_DT <= V_TO_MON||'31'
                             AND    A.COMP_CD  = B.COMP_CD(+)
                             AND    A.BRAND_CD = B.BRAND_CD(+)
                             AND    A.STOR_CD  = B.STOR_CD(+)
                            )
                      GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                    )       T1
                  , (--구매회원,객수,조수,총구매수량,총구매금액-회원/비회원
                     SELECT A.COMP_CD                                                       COMP_CD
                          , A.BRAND_CD                                                      BRAND_CD
                          , A.SSS_DIV                                                       SSS_DIV
                          , A.SIDO_CD                                                       SIDO_CD  
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_Q,NULL,0,1)))  MEMB_SALE_AAPP
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_Q,NULL,1,0)))  MEMB_SALE_UAPP
                          , SUM(A.MEMB_CUST_CNT                                          )  MEMB_CUST_CNT
                          , SUM(A.PUBL_CUST_CNT                                          )  PUBL_CUST_CNT
                          , SUM(A.MEMB_BILL_CNT                                          )  MEMB_BILL_CNT
                          , SUM(A.PUBL_BILL_CNT                                          )  PUBL_BILL_CNT
                          , SUM(A.MEMB_TOT_SALE_QTY                                      )  MEMB_TOT_SALE_QTY
                          , SUM(A.PUBL_TOT_SALE_QTY                                      )  PUBL_TOT_SALE_QTY
                          , SUM(A.MEMB_TOT_SALE_AMT                                      )  MEMB_TOT_SALE_AMT
                          , SUM(A.PUBL_TOT_SALE_AMT                                      )  PUBL_TOT_SALE_AMT
                     FROM   (
                             SELECT AA.COMP_CD
                                  , AA.BRAND_CD
                                  , NVL(BB.SSS_DIV_Q,'NOT')  SSS_DIV
                                  , NVL(BB.SIDO_CD  ,'?'  )  SIDO_CD
                                  , AA.CUST_ID
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN AA.CUST_M_CNT+AA.CUST_F_CNT
                                             ELSE 0
                                        END
                                       )                     MEMB_CUST_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN AA.CUST_M_CNT+AA.CUST_F_CNT
                                             ELSE 0
                                        END
                                       )                     PUBL_CUST_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN DECODE(AA.SALE_DIV,1,1,2,-1,0)
                                             ELSE 0
                                        END
                                       )                     MEMB_BILL_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN DECODE(AA.SALE_DIV,1,1,2,-1,0)
                                             ELSE 0
                                        END
                                       )                     PUBL_BILL_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN AA.SALE_QTY
                                             ELSE 0
                                        END
                                       )                     MEMB_TOT_SALE_QTY
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN AA.SALE_QTY
                                             ELSE 0
                                        END
                                       )                     PUBL_TOT_SALE_QTY
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN AA.GRD_I_AMT+AA.GRD_O_AMT-AA.VAT_I_AMT-AA.VAT_O_AMT
                                             ELSE 0
                                        END
                                       )                     MEMB_TOT_SALE_AMT
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN AA.GRD_I_AMT+AA.GRD_O_AMT-AA.VAT_I_AMT-AA.VAT_O_AMT
                                             ELSE 0
                                        END
                                       )                     PUBL_TOT_SALE_AMT
                             FROM   SALE_HD     AA
                                  , TEMP_STORE  BB
                             WHERE  AA.COMP_CD  = V_COMP_CD
                             AND    AA.SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                             AND    AA.GIFT_DIV = '0'
                             AND    AA.COMP_CD  = BB.COMP_CD(+)
                             AND    AA.BRAND_CD = BB.BRAND_CD(+)
                             AND    AA.STOR_CD  = BB.STOR_CD(+)
                             GROUP BY AA.COMP_CD,AA.BRAND_CD,AA.CUST_ID,BB.SSS_DIV_Q,BB.SIDO_CD
                            )               A
                          , TEMP_CUST_STAT1 B
                     WHERE  A.CUST_ID = B.CUST_ID(+)
                     GROUP BY A.COMP_CD,A.BRAND_CD,A.SSS_DIV,A.SIDO_CD
                    )       T2
                  , (--매장당 일평균 객수,조수,판매금액-회원/비회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SSS_DIV
                          , SIDO_CD
                          , SUM(MEMB_CUST_CNT)   MEMB_CUST_CNT
                          , SUM(MEMB_BILL_CNT)   MEMB_BILL_CNT
                          , SUM(MEMB_SALE_AMT)   MEMB_SALE_AMT
                          , SUM(PUBL_CUST_CNT)   PUBL_CUST_CNT
                          , SUM(PUBL_BILL_CNT)   PUBL_BILL_CNT
                          , SUM(PUBL_SALE_AMT)   PUBL_SALE_AMT
                     FROM   (--회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SSS_DIV
                                  , SIDO_CD
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  MEMB_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  MEMB_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  MEMB_SALE_AMT
                                  , 0                               PUBL_CUST_CNT
                                  , 0                               PUBL_BILL_CNT
                                  , 0                               PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD                COMP_CD
                                          , A.BRAND_CD               BRAND_CD
                                          , NVL(C.SSS_DIV_Q, 'NOT')  SSS_DIV
                                          , NVL(C.SIDO_CD  , '?'  )  SIDO_CD
                                          , A.STOR_CD                STOR_CD
                                          , A.DAY_CNT                DAY_CNT
                                          , NVL(B.CUST_CNT, 0)       CUST_CNT
                                          , NVL(B.BILL_CNT, 0)       BILL_CNT
                                          , NVL(B.SALE_AMT, 0)       SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NOT NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                            UNION
                             --비회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SSS_DIV
                                  , SIDO_CD
                                  , 0                               MEMB_CUST_CNT
                                  , 0                               MEMB_BILL_CNT
                                  , 0                               MEMB_SALE_AMT
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  PUBL_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  PUBL_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD                COMP_CD
                                          , A.BRAND_CD               BRAND_CD
                                          , NVL(C.SSS_DIV_Q, 'NOT')  SSS_DIV
                                          , NVL(C.SIDO_CD  , '?'  )  SIDO_CD
                                          , A.STOR_CD                STOR_CD
                                          , A.DAY_CNT                DAY_CNT
                                          , NVL(B.CUST_CNT, 0)       CUST_CNT
                                          , NVL(B.BILL_CNT, 0)       BILL_CNT
                                          , NVL(B.SALE_AMT, 0)       SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                            )
                     GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                    )       T3
                  , (
                     SELECT COMP_CD
                          , BRAND_CD
                          , SSS_DIV_Q  SSS_DIV           
                          , SIDO_CD   
                          , COUNT(*)   STOR_CNT
                     FROM   TEMP_STORE
                     WHERE  COMP_CD = V_COMP_CD
                     GROUP BY COMP_CD,BRAND_CD,SSS_DIV_Q,SIDO_CD
                    )       T4
             WHERE  T0.COMP_CD  = T1.COMP_CD(+)
             AND    T0.BRAND_CD = T1.BRAND_CD(+)
             AND    T0.SSS_DIV  = T1.SSS_DIV(+)
             AND    T0.SIDO_CD  = T1.SIDO_CD(+)
             AND    T0.COMP_CD  = T2.COMP_CD(+)
             AND    T0.BRAND_CD = T2.BRAND_CD(+)
             AND    T0.SSS_DIV  = T2.SSS_DIV(+)
             AND    T0.SIDO_CD  = T2.SIDO_CD(+)
             AND    T0.COMP_CD  = T3.COMP_CD(+)
             AND    T0.BRAND_CD = T3.BRAND_CD(+)
             AND    T0.SSS_DIV  = T3.SSS_DIV(+)
             AND    T0.SIDO_CD  = T3.SIDO_CD(+)
             AND    T0.COMP_CD  = T4.COMP_CD(+)
             AND    T0.BRAND_CD = T4.BRAND_CD(+)
             AND    T0.SSS_DIV  = T4.SSS_DIV(+)
             AND    T0.SIDO_CD  = T4.SIDO_CD(+)
            )                  SOC
      ON    (    TAR.INFO_DIV1 = SOC.INFO_DIV1
             AND TAR.INFO_DIV2 = SOC.INFO_DIV2
             AND TAR.STD_YYMM  = SOC.STD_YYMM
             AND TAR.COMP_CD   = SOC.COMP_CD
             AND TAR.BRAND_CD  = SOC.BRAND_CD
             AND TAR.SSS_DIV   = SOC.SSS_DIV
             AND TAR.STOR_TP   = SOC.STOR_TP
             AND TAR.TRAD_AREA = SOC.TRAD_AREA
             AND TAR.SIDO_CD   = SOC.SIDO_CD
             AND TAR.SC_CD     = SOC.SC_CD
             AND TAR.STOR_TG   = SOC.STOR_TG
             AND TAR.STOR_CD   = SOC.STOR_CD
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      TAR.MEMB_TOT          = SOC.MEMB_TOT
                                    , TAR.MEMB_NEW_AAPP     = SOC.MEMB_NEW_AAPP
                                    , TAR.MEMB_NEW_UAPP     = SOC.MEMB_NEW_UAPP
                                    , TAR.MEMB_SALE_AAPP    = SOC.MEMB_SALE_AAPP
                                    , TAR.MEMB_SALE_UAPP    = SOC.MEMB_SALE_UAPP
                                    , TAR.MEMB_TOT_CUST_CNT = SOC.MEMB_TOT_CUST_CNT
                                    , TAR.PUBL_TOT_CUST_CNT = SOC.PUBL_TOT_CUST_CNT
                                    , TAR.MEMB_TOT_BILL_CNT = SOC.MEMB_TOT_BILL_CNT
                                    , TAR.PUBL_TOT_BILL_CNT = SOC.PUBL_TOT_BILL_CNT
                                    , TAR.MEMB_TOT_SALE_QTY = SOC.MEMB_TOT_SALE_QTY
                                    , TAR.PUBL_TOT_SALE_QTY = SOC.PUBL_TOT_SALE_QTY
                                    , TAR.MEMB_TOT_SALE_AMT = SOC.MEMB_TOT_SALE_AMT
                                    , TAR.PUBL_TOT_SALE_AMT = SOC.PUBL_TOT_SALE_AMT
                                    , TAR.MEMB_AVG_CUST_CNT = SOC.MEMB_AVG_CUST_CNT
                                    , TAR.PUBL_AVG_CUST_CNT = SOC.PUBL_AVG_CUST_CNT
                                    , TAR.MEMB_AVG_BILL_CNT = SOC.MEMB_AVG_BILL_CNT
                                    , TAR.PUBL_AVG_BILL_CNT = SOC.PUBL_AVG_BILL_CNT
                                    , TAR.MEMB_AVG_SALE_AMT = SOC.MEMB_AVG_SALE_AMT
                                    , TAR.PUBL_AVG_SALE_AMT = SOC.PUBL_AVG_SALE_AMT
                                    , TAR.UPD_DT            = SYSDATE
                                    , TAR.STOR_CNT          = SOC.STOR_CNT
      WHEN  NOT MATCHED THEN INSERT ( INFO_DIV1            , INFO_DIV2            , STD_YYMM             , COMP_CD              , BRAND_CD                 -- 1, 2, 3, 4, 5
                                    , SSS_DIV              , STOR_TP              , TRAD_AREA            , SIDO_CD              , SC_CD                    -- 6, 7, 8, 9,10
                                    , STOR_TG              , STOR_CD              , MEMB_TOT             , MEMB_NEW_AAPP        , MEMB_NEW_UAPP            --11,12,13,14,15
                                    , MEMB_SALE_AAPP       , MEMB_SALE_UAPP       , MEMB_TOT_CUST_CNT    , PUBL_TOT_CUST_CNT    , MEMB_TOT_BILL_CNT        --16,17,18,19,20
                                    , PUBL_TOT_BILL_CNT    , MEMB_TOT_SALE_QTY    , PUBL_TOT_SALE_QTY    , MEMB_TOT_SALE_AMT    , PUBL_TOT_SALE_AMT        --21,22,23,24,25
                                    , MEMB_AVG_CUST_CNT    , PUBL_AVG_CUST_CNT    , MEMB_AVG_BILL_CNT    , PUBL_AVG_BILL_CNT    , MEMB_AVG_SALE_AMT        --26,27,28,29,30
                                    , PUBL_AVG_SALE_AMT    , INST_DT              , STOR_CNT                                                            )  --31,32,33
                             VALUES ( SOC.INFO_DIV1        , SOC.INFO_DIV2        , SOC.STD_YYMM         , SOC.COMP_CD          , SOC.BRAND_CD             -- 1, 2, 3, 4, 5
                                    , SOC.SSS_DIV          , SOC.STOR_TP          , SOC.TRAD_AREA        , SOC.SIDO_CD          , SOC.SC_CD                -- 6, 7, 8, 9,10
                                    , SOC.STOR_TG          , SOC.STOR_CD          , SOC.MEMB_TOT         , SOC.MEMB_NEW_AAPP    , SOC.MEMB_NEW_UAPP        --11,12,13,14,15
                                    , SOC.MEMB_SALE_AAPP   , SOC.MEMB_SALE_UAPP   , SOC.MEMB_TOT_CUST_CNT, SOC.PUBL_TOT_CUST_CNT, SOC.MEMB_TOT_BILL_CNT    --16,17,18,19,20
                                    , SOC.PUBL_TOT_BILL_CNT, SOC.MEMB_TOT_SALE_QTY, SOC.PUBL_TOT_SALE_QTY, SOC.MEMB_TOT_SALE_AMT, SOC.PUBL_TOT_SALE_AMT    --21,22,23,24,25
                                    , SOC.MEMB_AVG_CUST_CNT, SOC.PUBL_AVG_CUST_CNT, SOC.MEMB_AVG_BILL_CNT, SOC.PUBL_AVG_BILL_CNT, SOC.MEMB_AVG_SALE_AMT    --26,27,28,29,30
                                    , SOC.PUBL_AVG_SALE_AMT, SYSDATE              , SOC.STOR_CNT                                                        )  --31,32,33
      ;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_MEMBER_TOT4', '전체 회원 현황 자료 생성', '4-2-1.지역별-분기별_SSS구분별:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;
  ---------------------------------------------------------------------------------------------------
  --2-2.분기별_합
  ---------------------------------------------------------------------------------------------------
  IF (PO_RETC IS NULL) AND (PI_QTFV = TRUE) THEN
    BEGIN
      MERGE
      INTO  STAT_MEMBER_TOT    TAR
      USING (SELECT 'Q'                            INFO_DIV1
                  , V_INFO_DIV2                    INFO_DIV2
                  , V_YYMM                         STD_YYMM
                  , T0.COMP_CD                     COMP_CD
                  , T0.BRAND_CD                    BRAND_CD
                  , 'TOT'                          SSS_DIV
                  , '-'                            STOR_TP
                  , '-'                            TRAD_AREA
                  , T0.SIDO_CD                     SIDO_CD
                  , '-'                            SC_CD
                  , '-'                            STOR_TG
                  , '-'                            STOR_CD
                  , NVL(T1.MEMB_TOT         ,0)    MEMB_TOT
                  , NVL(T1.MEMB_NEW_AAPP    ,0)    MEMB_NEW_AAPP
                  , NVL(T1.MEMB_NEW_UAPP    ,0)    MEMB_NEW_UAPP
                  , NVL(T2.MEMB_SALE_AAPP   ,0)    MEMB_SALE_AAPP
                  , NVL(T2.MEMB_SALE_UAPP   ,0)    MEMB_SALE_UAPP
                  , NVL(T1.MEMB_TOT_CUST_CNT,0)    MEMB_TOT_CUST_CNT
                  , NVL(T1.PUBL_TOT_CUST_CNT,0)    PUBL_TOT_CUST_CNT
                  , NVL(T1.MEMB_TOT_BILL_CNT,0)    MEMB_TOT_BILL_CNT
                  , NVL(T1.PUBL_TOT_BILL_CNT,0)    PUBL_TOT_BILL_CNT
                  , NVL(T1.MEMB_TOT_SALE_QTY,0)    MEMB_TOT_SALE_QTY
                  , NVL(T1.PUBL_TOT_SALE_QTY,0)    PUBL_TOT_SALE_QTY
                  , NVL(T1.MEMB_TOT_SALE_AMT,0)    MEMB_TOT_SALE_AMT
                  , NVL(T1.PUBL_TOT_SALE_AMT,0)    PUBL_TOT_SALE_AMT
                  , NVL(T3.MEMB_CUST_CNT    ,0)    MEMB_AVG_CUST_CNT
                  , NVL(T3.PUBL_CUST_CNT    ,0)    PUBL_AVG_CUST_CNT
                  , NVL(T3.MEMB_BILL_CNT    ,0)    MEMB_AVG_BILL_CNT
                  , NVL(T3.PUBL_BILL_CNT    ,0)    PUBL_AVG_BILL_CNT
                  , NVL(T3.MEMB_SALE_AMT    ,0)    MEMB_AVG_SALE_AMT
                  , NVL(T3.PUBL_SALE_AMT    ,0)    PUBL_AVG_SALE_AMT
                  , NVL(T1.STOR_CNT         ,0)    STOR_CNT
             FROM   (
                     SELECT A.COMP_CD            COMP_CD
                          , A.BRAND_CD           BRAND_CD
                          , NVL(B.SIDO_CD,'?')   SIDO_CD
                     FROM   BRAND       A
                          , TEMP_STORE  B
                     WHERE  A.COMP_CD  = V_COMP_CD
                     AND    A.USE_YN   = 'Y'
                     AND    A.COMP_CD  = B.COMP_CD
                     AND    A.BRAND_CD = B.BRAND_CD
                     GROUP BY A.COMP_CD,A.BRAND_CD,B.SIDO_CD
                    )       T0
                  , (--전체회원,신규회원,객수,조수,총구매수량,총구매금액-회원/비회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SIDO_CD
                          , SUM(MEMB_TOT         )  MEMB_TOT
                          , SUM(MEMB_NEW_AAPP    )  MEMB_NEW_AAPP
                          , SUM(MEMB_NEW_UAPP    )  MEMB_NEW_UAPP
                          , SUM(MEMB_TOT_CUST_CNT)  MEMB_TOT_CUST_CNT
                          , SUM(PUBL_TOT_CUST_CNT)  PUBL_TOT_CUST_CNT
                          , SUM(MEMB_TOT_BILL_CNT)  MEMB_TOT_BILL_CNT
                          , SUM(PUBL_TOT_BILL_CNT)  PUBL_TOT_BILL_CNT
                          , SUM(MEMB_TOT_SALE_QTY)  MEMB_TOT_SALE_QTY
                          , SUM(PUBL_TOT_SALE_QTY)  PUBL_TOT_SALE_QTY
                          , SUM(MEMB_TOT_SALE_AMT)  MEMB_TOT_SALE_AMT
                          , SUM(PUBL_TOT_SALE_AMT)  PUBL_TOT_SALE_AMT
                          , SUM(STOR_CNT         )  STOR_CNT
                     FROM   STAT_MEMBER_TOT
                     WHERE  INFO_DIV1  = 'M'
                     AND    INFO_DIV2  = V_INFO_DIV2
                     AND    COMP_CD    = V_COMP_CD
                     AND    STD_YYMM   = V_QUARTER
                     AND    SSS_DIV   <> 'TOT'
                     AND    STOR_TP    = '-'
                     AND    TRAD_AREA  = '-'
                     AND    SIDO_CD   <> '-'
                     AND    SC_CD      = '-'
                     AND    STOR_TG    = '-'
                     AND    STOR_CD    = '-'
                     GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                    )       T1
                  , (--구매회원
                     SELECT A.COMP_CD                                                       COMP_CD
                          , A.BRAND_CD                                                      BRAND_CD
                          , A.SIDO_CD                                                       SIDO_CD
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_Q,NULL,0,1)))  MEMB_SALE_AAPP
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_Q,NULL,1,0)))  MEMB_SALE_UAPP
                     FROM   (
                             SELECT AA.COMP_CD
                                  , AA.BRAND_CD
                                  , NVL(BB.SIDO_CD,'?')  SIDO_CD
                                  , AA.CUST_ID
                             FROM   SALE_HD     AA
                                  , TEMP_STORE  BB
                             WHERE  AA.COMP_CD  = V_COMP_CD
                             AND    AA.SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                             AND    AA.GIFT_DIV = '0'
                             AND    AA.COMP_CD  = BB.COMP_CD(+)
                             AND    AA.BRAND_CD = BB.BRAND_CD(+)
                             AND    AA.STOR_CD  = BB.STOR_CD(+)
                             GROUP BY AA.COMP_CD,AA.BRAND_CD,AA.CUST_ID,BB.SIDO_CD
                            )               A
                          , TEMP_CUST_STAT1 B
                     WHERE  A.CUST_ID = B.CUST_ID(+)
                     GROUP BY A.COMP_CD,A.BRAND_CD,A.SIDO_CD
                    )       T2
                  , (--매장당 일평균 객수,조수,판매금액-회원/비회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SIDO_CD
                          , SUM(MEMB_CUST_CNT)   MEMB_CUST_CNT
                          , SUM(MEMB_BILL_CNT)   MEMB_BILL_CNT
                          , SUM(MEMB_SALE_AMT)   MEMB_SALE_AMT
                          , SUM(PUBL_CUST_CNT)   PUBL_CUST_CNT
                          , SUM(PUBL_BILL_CNT)   PUBL_BILL_CNT
                          , SUM(PUBL_SALE_AMT)   PUBL_SALE_AMT
                     FROM   (--회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SIDO_CD
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  MEMB_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  MEMB_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  MEMB_SALE_AMT
                                  , 0                               PUBL_CUST_CNT
                                  , 0                               PUBL_BILL_CNT
                                  , 0                               PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD              COMP_CD
                                          , A.BRAND_CD             BRAND_CD
                                          , NVL(C.SIDO_CD, '?')    SIDO_CD
                                          , A.STOR_CD              STOR_CD
                                          , A.DAY_CNT              DAY_CNT
                                          , NVL(B.CUST_CNT, 0)     CUST_CNT
                                          , NVL(B.BILL_CNT, 0)     BILL_CNT
                                          , NVL(B.SALE_AMT, 0)     SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NOT NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                            UNION
                             --비회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SIDO_CD
                                  , 0                               MEMB_CUST_CNT
                                  , 0                               MEMB_BILL_CNT
                                  , 0                               MEMB_SALE_AMT
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  PUBL_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  PUBL_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD              COMP_CD
                                          , A.BRAND_CD             BRAND_CD
                                          , NVL(C.SIDO_CD, '?')    SIDO_CD
                                          , A.STOR_CD              STOR_CD
                                          , A.DAY_CNT              DAY_CNT
                                          , NVL(B.CUST_CNT, 0)     CUST_CNT
                                          , NVL(B.BILL_CNT, 0)     BILL_CNT
                                          , NVL(B.SALE_AMT, 0)     SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                            )
                     GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                    )       T3
             WHERE  T0.COMP_CD  = T1.COMP_CD(+)
             AND    T0.BRAND_CD = T1.BRAND_CD(+)
             AND    T0.SIDO_CD  = T1.SIDO_CD(+)
             AND    T0.COMP_CD  = T2.COMP_CD(+)
             AND    T0.BRAND_CD = T2.BRAND_CD(+)
             AND    T0.SIDO_CD  = T2.SIDO_CD(+)
             AND    T0.COMP_CD  = T3.COMP_CD(+)
             AND    T0.BRAND_CD = T3.BRAND_CD(+)
             AND    T0.SIDO_CD  = T3.SIDO_CD(+)
            )                  SOC
      ON    (    TAR.INFO_DIV1 = SOC.INFO_DIV1
             AND TAR.INFO_DIV2 = SOC.INFO_DIV2
             AND TAR.STD_YYMM  = SOC.STD_YYMM
             AND TAR.COMP_CD   = SOC.COMP_CD
             AND TAR.BRAND_CD  = SOC.BRAND_CD
             AND TAR.SSS_DIV   = SOC.SSS_DIV
             AND TAR.STOR_TP   = SOC.STOR_TP
             AND TAR.TRAD_AREA = SOC.TRAD_AREA
             AND TAR.SIDO_CD   = SOC.SIDO_CD
             AND TAR.SC_CD     = SOC.SC_CD
             AND TAR.STOR_TG   = SOC.STOR_TG
             AND TAR.STOR_CD   = SOC.STOR_CD
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      TAR.MEMB_TOT          = SOC.MEMB_TOT
                                    , TAR.MEMB_NEW_AAPP     = SOC.MEMB_NEW_AAPP
                                    , TAR.MEMB_NEW_UAPP     = SOC.MEMB_NEW_UAPP
                                    , TAR.MEMB_SALE_AAPP    = SOC.MEMB_SALE_AAPP
                                    , TAR.MEMB_SALE_UAPP    = SOC.MEMB_SALE_UAPP
                                    , TAR.MEMB_TOT_CUST_CNT = SOC.MEMB_TOT_CUST_CNT
                                    , TAR.PUBL_TOT_CUST_CNT = SOC.PUBL_TOT_CUST_CNT
                                    , TAR.MEMB_TOT_BILL_CNT = SOC.MEMB_TOT_BILL_CNT
                                    , TAR.PUBL_TOT_BILL_CNT = SOC.PUBL_TOT_BILL_CNT
                                    , TAR.MEMB_TOT_SALE_QTY = SOC.MEMB_TOT_SALE_QTY
                                    , TAR.PUBL_TOT_SALE_QTY = SOC.PUBL_TOT_SALE_QTY
                                    , TAR.MEMB_TOT_SALE_AMT = SOC.MEMB_TOT_SALE_AMT
                                    , TAR.PUBL_TOT_SALE_AMT = SOC.PUBL_TOT_SALE_AMT
                                    , TAR.MEMB_AVG_CUST_CNT = SOC.MEMB_AVG_CUST_CNT
                                    , TAR.PUBL_AVG_CUST_CNT = SOC.PUBL_AVG_CUST_CNT
                                    , TAR.MEMB_AVG_BILL_CNT = SOC.MEMB_AVG_BILL_CNT
                                    , TAR.PUBL_AVG_BILL_CNT = SOC.PUBL_AVG_BILL_CNT
                                    , TAR.MEMB_AVG_SALE_AMT = SOC.MEMB_AVG_SALE_AMT
                                    , TAR.PUBL_AVG_SALE_AMT = SOC.PUBL_AVG_SALE_AMT
                                    , TAR.UPD_DT            = SYSDATE
                                    , TAR.STOR_CNT          = SOC.STOR_CNT
      WHEN  NOT MATCHED THEN INSERT ( INFO_DIV1            , INFO_DIV2            , STD_YYMM             , COMP_CD              , BRAND_CD                 -- 1, 2, 3, 4, 5
                                    , SSS_DIV              , STOR_TP              , TRAD_AREA            , SIDO_CD              , SC_CD                    -- 6, 7, 8, 9,10
                                    , STOR_TG              , STOR_CD              , MEMB_TOT             , MEMB_NEW_AAPP        , MEMB_NEW_UAPP            --11,12,13,14,15
                                    , MEMB_SALE_AAPP       , MEMB_SALE_UAPP       , MEMB_TOT_CUST_CNT    , PUBL_TOT_CUST_CNT    , MEMB_TOT_BILL_CNT        --16,17,18,19,20
                                    , PUBL_TOT_BILL_CNT    , MEMB_TOT_SALE_QTY    , PUBL_TOT_SALE_QTY    , MEMB_TOT_SALE_AMT    , PUBL_TOT_SALE_AMT        --21,22,23,24,25
                                    , MEMB_AVG_CUST_CNT    , PUBL_AVG_CUST_CNT    , MEMB_AVG_BILL_CNT    , PUBL_AVG_BILL_CNT    , MEMB_AVG_SALE_AMT        --26,27,28,29,30
                                    , PUBL_AVG_SALE_AMT    , INST_DT              , STOR_CNT                                                            )  --31,32,33
                             VALUES ( SOC.INFO_DIV1        , SOC.INFO_DIV2        , SOC.STD_YYMM         , SOC.COMP_CD          , SOC.BRAND_CD             -- 1, 2, 3, 4, 5
                                    , SOC.SSS_DIV          , SOC.STOR_TP          , SOC.TRAD_AREA        , SOC.SIDO_CD          , SOC.SC_CD                -- 6, 7, 8, 9,10
                                    , SOC.STOR_TG          , SOC.STOR_CD          , SOC.MEMB_TOT         , SOC.MEMB_NEW_AAPP    , SOC.MEMB_NEW_UAPP        --11,12,13,14,15
                                    , SOC.MEMB_SALE_AAPP   , SOC.MEMB_SALE_UAPP   , SOC.MEMB_TOT_CUST_CNT, SOC.PUBL_TOT_CUST_CNT, SOC.MEMB_TOT_BILL_CNT    --16,17,18,19,20
                                    , SOC.PUBL_TOT_BILL_CNT, SOC.MEMB_TOT_SALE_QTY, SOC.PUBL_TOT_SALE_QTY, SOC.MEMB_TOT_SALE_AMT, SOC.PUBL_TOT_SALE_AMT    --21,22,23,24,25
                                    , SOC.MEMB_AVG_CUST_CNT, SOC.PUBL_AVG_CUST_CNT, SOC.MEMB_AVG_BILL_CNT, SOC.PUBL_AVG_BILL_CNT, SOC.MEMB_AVG_SALE_AMT    --26,27,28,29,30
                                    , SOC.PUBL_AVG_SALE_AMT, SYSDATE              , SOC.STOR_CNT                                                        )  --31,32,33
      ;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_MEMBER_TOT4', '전체 회원 현황 자료 생성', '4-2-2.지역별-분기별_합:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;


  ---------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------
  --3-1.년도별_SSS구분별
  ---------------------------------------------------------------------------------------------------
  V_FR_MON := SUBSTR(V_YYMM,1,4) || '01';
  V_TO_MON := SUBSTR(V_YYMM,1,4) || '12';

  IF (PO_RETC IS NULL) AND (PI_YTFV = TRUE) THEN
    BEGIN
      MERGE
      INTO  STAT_MEMBER_TOT    TAR
      USING (SELECT 'Y'                            INFO_DIV1
                  , V_INFO_DIV2                    INFO_DIV2
                  , SUBSTR(V_YYMM,1,4)||'00'       STD_YYMM
                  , T0.COMP_CD                     COMP_CD
                  , T0.BRAND_CD                    BRAND_CD
                  , T0.SSS_DIV                     SSS_DIV
                  , '-'                            STOR_TP
                  , '-'                            TRAD_AREA
                  , T0.SIDO_CD                     SIDO_CD
                  , '-'                            SC_CD
                  , '-'                            STOR_TG
                  , '-'                            STOR_CD
                  , NVL(T1.MEMB_TOT         ,0)    MEMB_TOT
                  , NVL(T1.MEMB_NEW_AAPP    ,0)    MEMB_NEW_AAPP
                  , NVL(T1.MEMB_NEW_UAPP    ,0)    MEMB_NEW_UAPP
                  , NVL(T2.MEMB_SALE_AAPP   ,0)    MEMB_SALE_AAPP
                  , NVL(T2.MEMB_SALE_UAPP   ,0)    MEMB_SALE_UAPP
                  , NVL(T2.MEMB_CUST_CNT    ,0)    MEMB_TOT_CUST_CNT
                  , NVL(T2.PUBL_CUST_CNT    ,0)    PUBL_TOT_CUST_CNT
                  , NVL(T2.MEMB_BILL_CNT    ,0)    MEMB_TOT_BILL_CNT
                  , NVL(T2.PUBL_BILL_CNT    ,0)    PUBL_TOT_BILL_CNT
                  , NVL(T2.MEMB_TOT_SALE_QTY,0)    MEMB_TOT_SALE_QTY
                  , NVL(T2.PUBL_TOT_SALE_QTY,0)    PUBL_TOT_SALE_QTY
                  , NVL(T2.MEMB_TOT_SALE_AMT,0)    MEMB_TOT_SALE_AMT
                  , NVL(T2.PUBL_TOT_SALE_AMT,0)    PUBL_TOT_SALE_AMT
                  , NVL(T3.MEMB_CUST_CNT    ,0)    MEMB_AVG_CUST_CNT
                  , NVL(T3.PUBL_CUST_CNT    ,0)    PUBL_AVG_CUST_CNT
                  , NVL(T3.MEMB_BILL_CNT    ,0)    MEMB_AVG_BILL_CNT
                  , NVL(T3.PUBL_BILL_CNT    ,0)    PUBL_AVG_BILL_CNT
                  , NVL(T3.MEMB_SALE_AMT    ,0)    MEMB_AVG_SALE_AMT
                  , NVL(T3.PUBL_SALE_AMT    ,0)    PUBL_AVG_SALE_AMT
                  , NVL(T4.STOR_CNT         ,0)    STOR_CNT
             FROM   (
                     SELECT A.COMP_CD            COMP_CD
                          , A.BRAND_CD           BRAND_CD
                          , C.SSS_DIV            SSS_DIV
                          , NVL(B.SIDO_CD,'?')   SIDO_CD
                     FROM   BRAND       A
                          , TEMP_STORE  B
                          , (SELECT 'SSS' SSS_DIV FROM DUAL
                            UNION
                             SELECT 'NOT' SSS_DIV FROM DUAL
                            )           C
                     WHERE  A.COMP_CD  = V_COMP_CD
                     AND    A.USE_YN   = 'Y'
                     AND    A.COMP_CD  = B.COMP_CD
                     AND    A.BRAND_CD = B.BRAND_CD
                     GROUP BY A.COMP_CD,A.BRAND_CD,C.SSS_DIV,B.SIDO_CD
                    )       T0
                  , (--전체회원,신규회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SSS_DIV
                          , SIDO_CD
                          , COUNT(*)               MEMB_TOT
                          , SUM(CASE WHEN JOIN_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                     THEN CASE WHEN INST_DT <= V_TO_MON||'31'
                                               THEN 1
                                               ELSE 0
                                          END
                                     ELSE 0
                                END
                               )                   MEMB_NEW_AAPP
                          , SUM(CASE WHEN JOIN_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                     THEN CASE WHEN INST_DT <= V_TO_MON||'31'
                                               THEN 0
                                               ELSE 1
                                          END
                                     ELSE 0
                                END
                               )                   MEMB_NEW_UAPP
                      FROM  (SELECT A.COMP_CD               COMP_CD
                                  , A.BRAND_CD              BRAND_CD
                                  , NVL(B.SSS_DIV_Y,'NOT')  SSS_DIV
                                  , NVL(B.SIDO_CD  ,'?'  )  SIDO_CD
                                  , A.JOIN_DT               JOIN_DT
                                  , A.APP_INST_DT_Y         INST_DT
                             FROM   TEMP_CUST_STAT1 A
                                  , TEMP_STORE      B
                             WHERE  A.COMP_CD  = V_COMP_CD
                             AND    A.CUST_STAT_Y IN ('1','2','3')
                             AND    A.JOIN_DT <= V_TO_MON||'31'
                             AND    A.COMP_CD  = B.COMP_CD(+)
                             AND    A.BRAND_CD = B.BRAND_CD(+)
                             AND    A.STOR_CD  = B.STOR_CD(+)
                            )
                      GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                    )       T1
                  , (--구매회원,객수,조수,총구매수량,총구매금액-회원/비회원
                     SELECT A.COMP_CD                                                       COMP_CD
                          , A.BRAND_CD                                                      BRAND_CD
                          , A.SSS_DIV                                                       SSS_DIV
                          , A.SIDO_CD                                                       SIDO_CD
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_Y,NULL,0,1)))  MEMB_SALE_AAPP
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_Y,NULL,1,0)))  MEMB_SALE_UAPP
                          , SUM(A.MEMB_CUST_CNT                                          )  MEMB_CUST_CNT
                          , SUM(A.PUBL_CUST_CNT                                          )  PUBL_CUST_CNT
                          , SUM(A.MEMB_BILL_CNT                                          )  MEMB_BILL_CNT
                          , SUM(A.PUBL_BILL_CNT                                          )  PUBL_BILL_CNT
                          , SUM(A.MEMB_TOT_SALE_QTY                                      )  MEMB_TOT_SALE_QTY
                          , SUM(A.PUBL_TOT_SALE_QTY                                      )  PUBL_TOT_SALE_QTY
                          , SUM(A.MEMB_TOT_SALE_AMT                                      )  MEMB_TOT_SALE_AMT
                          , SUM(A.PUBL_TOT_SALE_AMT                                      )  PUBL_TOT_SALE_AMT
                     FROM   (
                             SELECT AA.COMP_CD
                                  , AA.BRAND_CD
                                  , NVL(BB.SSS_DIV_Y,'NOT')  SSS_DIV
                                  , NVL(BB.SIDO_CD  ,'?'  )  SIDO_CD
                                  , AA.CUST_ID
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN AA.CUST_M_CNT+AA.CUST_F_CNT
                                             ELSE 0
                                        END
                                       )                     MEMB_CUST_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN AA.CUST_M_CNT+AA.CUST_F_CNT
                                             ELSE 0
                                        END
                                       )                     PUBL_CUST_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN DECODE(AA.SALE_DIV,1,1,2,-1,0)
                                             ELSE 0
                                        END
                                       )                     MEMB_BILL_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN DECODE(AA.SALE_DIV,1,1,2,-1,0)
                                             ELSE 0
                                        END
                                       )                     PUBL_BILL_CNT
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN AA.SALE_QTY
                                             ELSE 0
                                        END
                                       )                     MEMB_TOT_SALE_QTY
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN AA.SALE_QTY
                                             ELSE 0
                                        END
                                       )                     PUBL_TOT_SALE_QTY
                                  , SUM(CASE WHEN AA.CUST_ID IS NOT NULL
                                             THEN AA.GRD_I_AMT+AA.GRD_O_AMT-AA.VAT_I_AMT-AA.VAT_O_AMT
                                             ELSE 0
                                        END
                                       )                     MEMB_TOT_SALE_AMT
                                  , SUM(CASE WHEN AA.CUST_ID IS NULL
                                             THEN AA.GRD_I_AMT+AA.GRD_O_AMT-AA.VAT_I_AMT-AA.VAT_O_AMT
                                             ELSE 0
                                        END
                                       )                     PUBL_TOT_SALE_AMT
                             FROM   SALE_HD     AA
                                  , TEMP_STORE  BB
                             WHERE  AA.COMP_CD  = V_COMP_CD
                             AND    AA.SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                             AND    AA.GIFT_DIV = '0'
                             AND    AA.COMP_CD  = BB.COMP_CD(+)
                             AND    AA.BRAND_CD = BB.BRAND_CD(+)
                             AND    AA.STOR_CD  = BB.STOR_CD(+)
                             GROUP BY AA.COMP_CD,AA.BRAND_CD,AA.CUST_ID,BB.SSS_DIV_Y,BB.SIDO_CD
                            )               A
                          , TEMP_CUST_STAT1 B
                     WHERE  A.CUST_ID = B.CUST_ID(+)
                     GROUP BY A.COMP_CD,A.BRAND_CD,A.SSS_DIV,A.SIDO_CD
                    )       T2
                  , (--매장당 일평균 객수,조수,판매금액-회원/비회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SSS_DIV
                          , SIDO_CD
                          , SUM(MEMB_CUST_CNT)   MEMB_CUST_CNT
                          , SUM(MEMB_BILL_CNT)   MEMB_BILL_CNT
                          , SUM(MEMB_SALE_AMT)   MEMB_SALE_AMT
                          , SUM(PUBL_CUST_CNT)   PUBL_CUST_CNT
                          , SUM(PUBL_BILL_CNT)   PUBL_BILL_CNT
                          , SUM(PUBL_SALE_AMT)   PUBL_SALE_AMT
                     FROM   (--회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SSS_DIV
                                  , SIDO_CD
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  MEMB_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  MEMB_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  MEMB_SALE_AMT
                                  , 0                               PUBL_CUST_CNT
                                  , 0                               PUBL_BILL_CNT
                                  , 0                               PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD                COMP_CD
                                          , A.BRAND_CD               BRAND_CD
                                          , NVL(C.SSS_DIV_Y, 'NOT')  SSS_DIV
                                          , NVL(C.SIDO_CD  , '?'  )  SIDO_CD
                                          , A.STOR_CD                STOR_CD
                                          , A.DAY_CNT                DAY_CNT
                                          , NVL(B.CUST_CNT, 0)       CUST_CNT
                                          , NVL(B.BILL_CNT, 0)       BILL_CNT
                                          , NVL(B.SALE_AMT, 0)       SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NOT NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                            UNION
                             --비회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SSS_DIV
                                  , SIDO_CD
                                  , 0                               MEMB_CUST_CNT
                                  , 0                               MEMB_BILL_CNT
                                  , 0                               MEMB_SALE_AMT
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  PUBL_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  PUBL_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD                COMP_CD
                                          , A.BRAND_CD               BRAND_CD
                                          , NVL(C.SSS_DIV_Y, 'NOT')  SSS_DIV
                                          , NVL(C.SIDO_CD  , '?'  )  SIDO_CD
                                          , A.STOR_CD                STOR_CD
                                          , A.DAY_CNT                DAY_CNT
                                          , NVL(B.CUST_CNT, 0)       CUST_CNT
                                          , NVL(B.BILL_CNT, 0)       BILL_CNT
                                          , NVL(B.SALE_AMT, 0)       SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                            )
                     GROUP BY COMP_CD,BRAND_CD,SSS_DIV,SIDO_CD
                    )       T3
                  , (
                     SELECT COMP_CD
                          , BRAND_CD
                          , SSS_DIV_Y  SSS_DIV           
                          , SIDO_CD   
                          , COUNT(*)   STOR_CNT
                     FROM   TEMP_STORE
                     WHERE  COMP_CD = V_COMP_CD
                     GROUP BY COMP_CD,BRAND_CD,SSS_DIV_Y,SIDO_CD
                    )       T4
             WHERE  T0.COMP_CD  = T1.COMP_CD(+)
             AND    T0.BRAND_CD = T1.BRAND_CD(+)
             AND    T0.SSS_DIV  = T1.SSS_DIV(+)
             AND    T0.SIDO_CD  = T1.SIDO_CD(+)
             AND    T0.COMP_CD  = T2.COMP_CD(+)
             AND    T0.BRAND_CD = T2.BRAND_CD(+)
             AND    T0.SSS_DIV  = T2.SSS_DIV(+)
             AND    T0.SIDO_CD  = T2.SIDO_CD(+)
             AND    T0.COMP_CD  = T3.COMP_CD(+)
             AND    T0.BRAND_CD = T3.BRAND_CD(+)
             AND    T0.SSS_DIV  = T3.SSS_DIV(+)
             AND    T0.SIDO_CD  = T3.SIDO_CD(+)
             AND    T0.COMP_CD  = T4.COMP_CD(+)
             AND    T0.BRAND_CD = T4.BRAND_CD(+)
             AND    T0.SSS_DIV  = T4.SSS_DIV(+)
             AND    T0.SIDO_CD  = T4.SIDO_CD(+)
            )                  SOC
      ON    (    TAR.INFO_DIV1 = SOC.INFO_DIV1
             AND TAR.INFO_DIV2 = SOC.INFO_DIV2
             AND TAR.STD_YYMM  = SOC.STD_YYMM
             AND TAR.COMP_CD   = SOC.COMP_CD
             AND TAR.BRAND_CD  = SOC.BRAND_CD
             AND TAR.SSS_DIV   = SOC.SSS_DIV
             AND TAR.STOR_TP   = SOC.STOR_TP
             AND TAR.TRAD_AREA = SOC.TRAD_AREA
             AND TAR.SIDO_CD   = SOC.SIDO_CD
             AND TAR.SC_CD     = SOC.SC_CD
             AND TAR.STOR_TG   = SOC.STOR_TG
             AND TAR.STOR_CD   = SOC.STOR_CD
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      TAR.MEMB_TOT          = SOC.MEMB_TOT
                                    , TAR.MEMB_NEW_AAPP     = SOC.MEMB_NEW_AAPP
                                    , TAR.MEMB_NEW_UAPP     = SOC.MEMB_NEW_UAPP
                                    , TAR.MEMB_SALE_AAPP    = SOC.MEMB_SALE_AAPP
                                    , TAR.MEMB_SALE_UAPP    = SOC.MEMB_SALE_UAPP
                                    , TAR.MEMB_TOT_CUST_CNT = SOC.MEMB_TOT_CUST_CNT
                                    , TAR.PUBL_TOT_CUST_CNT = SOC.PUBL_TOT_CUST_CNT
                                    , TAR.MEMB_TOT_BILL_CNT = SOC.MEMB_TOT_BILL_CNT
                                    , TAR.PUBL_TOT_BILL_CNT = SOC.PUBL_TOT_BILL_CNT
                                    , TAR.MEMB_TOT_SALE_QTY = SOC.MEMB_TOT_SALE_QTY
                                    , TAR.PUBL_TOT_SALE_QTY = SOC.PUBL_TOT_SALE_QTY
                                    , TAR.MEMB_TOT_SALE_AMT = SOC.MEMB_TOT_SALE_AMT
                                    , TAR.PUBL_TOT_SALE_AMT = SOC.PUBL_TOT_SALE_AMT
                                    , TAR.MEMB_AVG_CUST_CNT = SOC.MEMB_AVG_CUST_CNT
                                    , TAR.PUBL_AVG_CUST_CNT = SOC.PUBL_AVG_CUST_CNT
                                    , TAR.MEMB_AVG_BILL_CNT = SOC.MEMB_AVG_BILL_CNT
                                    , TAR.PUBL_AVG_BILL_CNT = SOC.PUBL_AVG_BILL_CNT
                                    , TAR.MEMB_AVG_SALE_AMT = SOC.MEMB_AVG_SALE_AMT
                                    , TAR.PUBL_AVG_SALE_AMT = SOC.PUBL_AVG_SALE_AMT
                                    , TAR.UPD_DT            = SYSDATE
                                    , TAR.STOR_CNT          = SOC.STOR_CNT
      WHEN  NOT MATCHED THEN INSERT ( INFO_DIV1            , INFO_DIV2            , STD_YYMM             , COMP_CD              , BRAND_CD                 -- 1, 2, 3, 4, 5
                                    , SSS_DIV              , STOR_TP              , TRAD_AREA            , SIDO_CD              , SC_CD                    -- 6, 7, 8, 9,10
                                    , STOR_TG              , STOR_CD              , MEMB_TOT             , MEMB_NEW_AAPP        , MEMB_NEW_UAPP            --11,12,13,14,15
                                    , MEMB_SALE_AAPP       , MEMB_SALE_UAPP       , MEMB_TOT_CUST_CNT    , PUBL_TOT_CUST_CNT    , MEMB_TOT_BILL_CNT        --16,17,18,19,20
                                    , PUBL_TOT_BILL_CNT    , MEMB_TOT_SALE_QTY    , PUBL_TOT_SALE_QTY    , MEMB_TOT_SALE_AMT    , PUBL_TOT_SALE_AMT        --21,22,23,24,25
                                    , MEMB_AVG_CUST_CNT    , PUBL_AVG_CUST_CNT    , MEMB_AVG_BILL_CNT    , PUBL_AVG_BILL_CNT    , MEMB_AVG_SALE_AMT        --26,27,28,29,30
                                    , PUBL_AVG_SALE_AMT    , INST_DT              , STOR_CNT                                                            )  --31,32,33
                             VALUES ( SOC.INFO_DIV1        , SOC.INFO_DIV2        , SOC.STD_YYMM         , SOC.COMP_CD          , SOC.BRAND_CD             -- 1, 2, 3, 4, 5
                                    , SOC.SSS_DIV          , SOC.STOR_TP          , SOC.TRAD_AREA        , SOC.SIDO_CD          , SOC.SC_CD                -- 6, 7, 8, 9,10
                                    , SOC.STOR_TG          , SOC.STOR_CD          , SOC.MEMB_TOT         , SOC.MEMB_NEW_AAPP    , SOC.MEMB_NEW_UAPP        --11,12,13,14,15
                                    , SOC.MEMB_SALE_AAPP   , SOC.MEMB_SALE_UAPP   , SOC.MEMB_TOT_CUST_CNT, SOC.PUBL_TOT_CUST_CNT, SOC.MEMB_TOT_BILL_CNT    --16,17,18,19,20
                                    , SOC.PUBL_TOT_BILL_CNT, SOC.MEMB_TOT_SALE_QTY, SOC.PUBL_TOT_SALE_QTY, SOC.MEMB_TOT_SALE_AMT, SOC.PUBL_TOT_SALE_AMT    --21,22,23,24,25
                                    , SOC.MEMB_AVG_CUST_CNT, SOC.PUBL_AVG_CUST_CNT, SOC.MEMB_AVG_BILL_CNT, SOC.PUBL_AVG_BILL_CNT, SOC.MEMB_AVG_SALE_AMT    --26,27,28,29,30
                                    , SOC.PUBL_AVG_SALE_AMT, SYSDATE              , SOC.STOR_CNT                                                        )  --31,32,33
      ;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_MEMBER_TOT4', '전체 회원 현황 자료 생성', '4-3-1.년도별_SSS구분별-분기별_합:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;
  ---------------------------------------------------------------------------------------------------
  --3-2.년도별_합
  ---------------------------------------------------------------------------------------------------
  IF (PO_RETC IS NULL) AND (PI_YTFV = TRUE) THEN
    BEGIN
        MERGE
      INTO  STAT_MEMBER_TOT    TAR
      USING (SELECT 'Y'                            INFO_DIV1
                  , V_INFO_DIV2                    INFO_DIV2
                  , SUBSTR(V_YYMM,1,4)||'00'       STD_YYMM
                  , T0.COMP_CD                     COMP_CD
                  , T0.BRAND_CD                    BRAND_CD
                  , 'TOT'                          SSS_DIV
                  , '-'                            STOR_TP
                  , '-'                            TRAD_AREA
                  , T0.SIDO_CD                     SIDO_CD
                  , '-'                            SC_CD
                  , '-'                            STOR_TG
                  , '-'                            STOR_CD
                  , NVL(T1.MEMB_TOT         ,0)    MEMB_TOT
                  , NVL(T1.MEMB_NEW_AAPP    ,0)    MEMB_NEW_AAPP
                  , NVL(T1.MEMB_NEW_UAPP    ,0)    MEMB_NEW_UAPP
                  , NVL(T2.MEMB_SALE_AAPP   ,0)    MEMB_SALE_AAPP
                  , NVL(T2.MEMB_SALE_UAPP   ,0)    MEMB_SALE_UAPP
                  , NVL(T1.MEMB_TOT_CUST_CNT,0)    MEMB_TOT_CUST_CNT
                  , NVL(T1.PUBL_TOT_CUST_CNT,0)    PUBL_TOT_CUST_CNT
                  , NVL(T1.MEMB_TOT_BILL_CNT,0)    MEMB_TOT_BILL_CNT
                  , NVL(T1.PUBL_TOT_BILL_CNT,0)    PUBL_TOT_BILL_CNT
                  , NVL(T1.MEMB_TOT_SALE_QTY,0)    MEMB_TOT_SALE_QTY
                  , NVL(T1.PUBL_TOT_SALE_QTY,0)    PUBL_TOT_SALE_QTY
                  , NVL(T1.MEMB_TOT_SALE_AMT,0)    MEMB_TOT_SALE_AMT
                  , NVL(T1.PUBL_TOT_SALE_AMT,0)    PUBL_TOT_SALE_AMT
                  , NVL(T3.MEMB_CUST_CNT    ,0)    MEMB_AVG_CUST_CNT
                  , NVL(T3.PUBL_CUST_CNT    ,0)    PUBL_AVG_CUST_CNT
                  , NVL(T3.MEMB_BILL_CNT    ,0)    MEMB_AVG_BILL_CNT
                  , NVL(T3.PUBL_BILL_CNT    ,0)    PUBL_AVG_BILL_CNT
                  , NVL(T3.MEMB_SALE_AMT    ,0)    MEMB_AVG_SALE_AMT
                  , NVL(T3.PUBL_SALE_AMT    ,0)    PUBL_AVG_SALE_AMT
                  , NVL(T1.STOR_CNT         ,0)    STOR_CNT
             FROM   (
                     SELECT A.COMP_CD            COMP_CD
                          , A.BRAND_CD           BRAND_CD
                          , NVL(B.SIDO_CD,'?')   SIDO_CD
                     FROM   BRAND       A
                          , TEMP_STORE  B
                     WHERE  A.COMP_CD  = V_COMP_CD
                     AND    A.USE_YN   = 'Y'
                     AND    A.COMP_CD  = B.COMP_CD
                     AND    A.BRAND_CD = B.BRAND_CD
                     GROUP BY A.COMP_CD,A.BRAND_CD,B.SIDO_CD
                    )       T0
                  , (--전체회원,신규회원,객수,조수,총구매수량,총구매금액-회원/비회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SIDO_CD
                          , SUM(MEMB_TOT         )  MEMB_TOT
                          , SUM(MEMB_NEW_AAPP    )  MEMB_NEW_AAPP
                          , SUM(MEMB_NEW_UAPP    )  MEMB_NEW_UAPP
                          , SUM(MEMB_TOT_CUST_CNT)  MEMB_TOT_CUST_CNT
                          , SUM(PUBL_TOT_CUST_CNT)  PUBL_TOT_CUST_CNT
                          , SUM(MEMB_TOT_BILL_CNT)  MEMB_TOT_BILL_CNT
                          , SUM(PUBL_TOT_BILL_CNT)  PUBL_TOT_BILL_CNT
                          , SUM(MEMB_TOT_SALE_QTY)  MEMB_TOT_SALE_QTY
                          , SUM(PUBL_TOT_SALE_QTY)  PUBL_TOT_SALE_QTY
                          , SUM(MEMB_TOT_SALE_AMT)  MEMB_TOT_SALE_AMT
                          , SUM(PUBL_TOT_SALE_AMT)  PUBL_TOT_SALE_AMT
                          , SUM(STOR_CNT         )  STOR_CNT
                     FROM   STAT_MEMBER_TOT
                     WHERE  INFO_DIV1  = 'Y'
                     AND    INFO_DIV2  = V_INFO_DIV2
                     AND    COMP_CD    = V_COMP_CD
                     AND    STD_YYMM   = SUBSTR(V_YYMM,1,4)||'00'
                     AND    SSS_DIV   <> 'TOT'
                     AND    STOR_TP    = '-'
                     AND    TRAD_AREA  = '-'
                     AND    SIDO_CD   <> '-'
                     AND    SC_CD      = '-'
                     AND    STOR_TG    = '-'
                     AND    STOR_CD    = '-'
                     GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                    )       T1
                  , (--구매회원
                     SELECT A.COMP_CD                                                       COMP_CD
                          , A.BRAND_CD                                                      BRAND_CD
                          , A.SIDO_CD                                                       SIDO_CD
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_Y,NULL,0,1)))  MEMB_SALE_AAPP
                          , SUM(DECODE(A.CUST_ID,NULL,0,DECODE(B.APP_INST_DT_Y,NULL,1,0)))  MEMB_SALE_UAPP
                     FROM   (
                             SELECT AA.COMP_CD
                                  , AA.BRAND_CD
                                  , NVL(BB.SIDO_CD,'?')  SIDO_CD
                                  , AA.CUST_ID
                             FROM   SALE_HD     AA
                                  , TEMP_STORE  BB
                             WHERE  AA.COMP_CD  = V_COMP_CD
                             AND    AA.SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                             AND    AA.GIFT_DIV = '0'
                             AND    AA.COMP_CD  = BB.COMP_CD(+)
                             AND    AA.BRAND_CD = BB.BRAND_CD(+)
                             AND    AA.STOR_CD  = BB.STOR_CD(+)
                             GROUP BY AA.COMP_CD,AA.BRAND_CD,AA.CUST_ID,BB.SIDO_CD
                            )               A
                          , TEMP_CUST_STAT1 B
                     WHERE  A.CUST_ID = B.CUST_ID(+)
                     GROUP BY A.COMP_CD,A.BRAND_CD,A.SIDO_CD
                    )       T2
                  , (--매장당 일평균 객수,조수,판매금액-회원/비회원
                     SELECT COMP_CD
                          , BRAND_CD
                          , SIDO_CD
                          , SUM(MEMB_CUST_CNT)   MEMB_CUST_CNT
                          , SUM(MEMB_BILL_CNT)   MEMB_BILL_CNT
                          , SUM(MEMB_SALE_AMT)   MEMB_SALE_AMT
                          , SUM(PUBL_CUST_CNT)   PUBL_CUST_CNT
                          , SUM(PUBL_BILL_CNT)   PUBL_BILL_CNT
                          , SUM(PUBL_SALE_AMT)   PUBL_SALE_AMT
                     FROM   (--회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SIDO_CD
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  MEMB_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  MEMB_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  MEMB_SALE_AMT
                                  , 0                               PUBL_CUST_CNT
                                  , 0                               PUBL_BILL_CNT
                                  , 0                               PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD              COMP_CD
                                          , A.BRAND_CD             BRAND_CD
                                          , NVL(C.SIDO_CD, '?')    SIDO_CD
                                          , A.STOR_CD              STOR_CD
                                          , A.DAY_CNT              DAY_CNT
                                          , NVL(B.CUST_CNT, 0)     CUST_CNT
                                          , NVL(B.BILL_CNT, 0)     BILL_CNT
                                          , NVL(B.SALE_AMT, 0)     SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NOT NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                            UNION
                             --비회원...
                             SELECT COMP_CD
                                  , BRAND_CD
                                  , SIDO_CD
                                  , 0                               MEMB_CUST_CNT
                                  , 0                               MEMB_BILL_CNT
                                  , 0                               MEMB_SALE_AMT
                                  , ROUND(AVG(CUST_CNT/DAY_CNT),0)  PUBL_CUST_CNT
                                  , ROUND(AVG(BILL_CNT/DAY_CNT),0)  PUBL_BILL_CNT
                                  , ROUND(AVG(SALE_AMT/DAY_CNT),0)  PUBL_SALE_AMT
                             FROM   (
                                     SELECT /*+ ORDERED */
                                            A.COMP_CD              COMP_CD
                                          , A.BRAND_CD             BRAND_CD
                                          , NVL(C.SIDO_CD, '?')    SIDO_CD
                                          , A.STOR_CD              STOR_CD
                                          , A.DAY_CNT              DAY_CNT
                                          , NVL(B.CUST_CNT, 0)     CUST_CNT
                                          , NVL(B.BILL_CNT, 0)     BILL_CNT
                                          , NVL(B.SALE_AMT, 0)     SALE_AMT
                                     FROM   (
                                             SELECT V_COMP_CD  COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , COUNT(*)   DAY_CNT
                                             FROM   SALE_JDS
                                             WHERE  SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             GROUP BY BRAND_CD,STOR_CD
                                            )          A
                                          , (
                                             SELECT COMP_CD
                                                  , BRAND_CD
                                                  , STOR_CD
                                                  , SUM(CUST_M_CNT+CUST_F_CNT)                    CUST_CNT
                                                  , COUNT(*)                                      BILL_CNT
                                                  , SUM(GRD_I_AMT+GRD_O_AMT-VAT_I_AMT-VAT_O_AMT)  SALE_AMT
                                             FROM   SALE_HD
                                             WHERE  COMP_CD  = V_COMP_CD
                                             AND    SALE_DT BETWEEN V_FR_MON||'01' AND V_TO_MON||'31'
                                             AND    GIFT_DIV = '0'
                                             AND    CUST_ID IS NULL
                                             GROUP BY COMP_CD,BRAND_CD,STOR_CD
                                            )          B
                                          , TEMP_STORE C
                                     WHERE  A.COMP_CD  = B.COMP_CD(+)
                                     AND    A.BRAND_CD = B.BRAND_CD(+)
                                     AND    A.STOR_CD  = B.STOR_CD(+)
                                     AND    A.COMP_CD  = C.COMP_CD(+)
                                     AND    A.BRAND_CD = C.BRAND_CD(+)
                                     AND    A.STOR_CD  = C.STOR_CD(+)
                                    )
                             GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                            )
                     GROUP BY COMP_CD,BRAND_CD,SIDO_CD
                    )       T3
             WHERE  T0.COMP_CD  = T1.COMP_CD(+)
             AND    T0.BRAND_CD = T1.BRAND_CD(+)
             AND    T0.SIDO_CD  = T1.SIDO_CD(+)
             AND    T0.COMP_CD  = T2.COMP_CD(+)
             AND    T0.BRAND_CD = T2.BRAND_CD(+)
             AND    T0.SIDO_CD  = T2.SIDO_CD(+)
             AND    T0.COMP_CD  = T3.COMP_CD(+)
             AND    T0.BRAND_CD = T3.BRAND_CD(+)
             AND    T0.SIDO_CD  = T3.SIDO_CD(+)
            )                  SOC
    ON    (    TAR.INFO_DIV1 = SOC.INFO_DIV1
             AND TAR.INFO_DIV2 = SOC.INFO_DIV2
             AND TAR.STD_YYMM  = SOC.STD_YYMM
             AND TAR.COMP_CD   = SOC.COMP_CD
             AND TAR.BRAND_CD  = SOC.BRAND_CD
             AND TAR.SSS_DIV   = SOC.SSS_DIV
             AND TAR.STOR_TP   = SOC.STOR_TP
             AND TAR.TRAD_AREA = SOC.TRAD_AREA
             AND TAR.SIDO_CD   = SOC.SIDO_CD
             AND TAR.SC_CD     = SOC.SC_CD
             AND TAR.STOR_TG   = SOC.STOR_TG
             AND TAR.STOR_CD   = SOC.STOR_CD
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      TAR.MEMB_TOT          = SOC.MEMB_TOT
                                    , TAR.MEMB_NEW_AAPP     = SOC.MEMB_NEW_AAPP
                                    , TAR.MEMB_NEW_UAPP     = SOC.MEMB_NEW_UAPP
                                    , TAR.MEMB_SALE_AAPP    = SOC.MEMB_SALE_AAPP
                                    , TAR.MEMB_SALE_UAPP    = SOC.MEMB_SALE_UAPP
                                    , TAR.MEMB_TOT_CUST_CNT = SOC.MEMB_TOT_CUST_CNT
                                    , TAR.PUBL_TOT_CUST_CNT = SOC.PUBL_TOT_CUST_CNT
                                    , TAR.MEMB_TOT_BILL_CNT = SOC.MEMB_TOT_BILL_CNT
                                    , TAR.PUBL_TOT_BILL_CNT = SOC.PUBL_TOT_BILL_CNT
                                    , TAR.MEMB_TOT_SALE_QTY = SOC.MEMB_TOT_SALE_QTY
                                    , TAR.PUBL_TOT_SALE_QTY = SOC.PUBL_TOT_SALE_QTY
                                    , TAR.MEMB_TOT_SALE_AMT = SOC.MEMB_TOT_SALE_AMT
                                    , TAR.PUBL_TOT_SALE_AMT = SOC.PUBL_TOT_SALE_AMT
                                    , TAR.MEMB_AVG_CUST_CNT = SOC.MEMB_AVG_CUST_CNT
                                    , TAR.PUBL_AVG_CUST_CNT = SOC.PUBL_AVG_CUST_CNT
                                    , TAR.MEMB_AVG_BILL_CNT = SOC.MEMB_AVG_BILL_CNT
                                    , TAR.PUBL_AVG_BILL_CNT = SOC.PUBL_AVG_BILL_CNT
                                    , TAR.MEMB_AVG_SALE_AMT = SOC.MEMB_AVG_SALE_AMT
                                    , TAR.PUBL_AVG_SALE_AMT = SOC.PUBL_AVG_SALE_AMT
                                    , TAR.UPD_DT            = SYSDATE
                                    , TAR.STOR_CNT          = SOC.STOR_CNT
      WHEN  NOT MATCHED THEN INSERT ( INFO_DIV1            , INFO_DIV2            , STD_YYMM             , COMP_CD              , BRAND_CD                 -- 1, 2, 3, 4, 5
                                    , SSS_DIV              , STOR_TP              , TRAD_AREA            , SIDO_CD              , SC_CD                    -- 6, 7, 8, 9,10
                                    , STOR_TG              , STOR_CD              , MEMB_TOT             , MEMB_NEW_AAPP        , MEMB_NEW_UAPP            --11,12,13,14,15
                                    , MEMB_SALE_AAPP       , MEMB_SALE_UAPP       , MEMB_TOT_CUST_CNT    , PUBL_TOT_CUST_CNT    , MEMB_TOT_BILL_CNT        --16,17,18,19,20
                                    , PUBL_TOT_BILL_CNT    , MEMB_TOT_SALE_QTY    , PUBL_TOT_SALE_QTY    , MEMB_TOT_SALE_AMT    , PUBL_TOT_SALE_AMT        --21,22,23,24,25
                                    , MEMB_AVG_CUST_CNT    , PUBL_AVG_CUST_CNT    , MEMB_AVG_BILL_CNT    , PUBL_AVG_BILL_CNT    , MEMB_AVG_SALE_AMT        --26,27,28,29,30
                                    , PUBL_AVG_SALE_AMT    , INST_DT              , STOR_CNT                                                            )  --31,32,33
                             VALUES ( SOC.INFO_DIV1        , SOC.INFO_DIV2        , SOC.STD_YYMM         , SOC.COMP_CD          , SOC.BRAND_CD             -- 1, 2, 3, 4, 5
                                    , SOC.SSS_DIV          , SOC.STOR_TP          , SOC.TRAD_AREA        , SOC.SIDO_CD          , SOC.SC_CD                -- 6, 7, 8, 9,10
                                    , SOC.STOR_TG          , SOC.STOR_CD          , SOC.MEMB_TOT         , SOC.MEMB_NEW_AAPP    , SOC.MEMB_NEW_UAPP        --11,12,13,14,15
                                    , SOC.MEMB_SALE_AAPP   , SOC.MEMB_SALE_UAPP   , SOC.MEMB_TOT_CUST_CNT, SOC.PUBL_TOT_CUST_CNT, SOC.MEMB_TOT_BILL_CNT    --16,17,18,19,20
                                    , SOC.PUBL_TOT_BILL_CNT, SOC.MEMB_TOT_SALE_QTY, SOC.PUBL_TOT_SALE_QTY, SOC.MEMB_TOT_SALE_AMT, SOC.PUBL_TOT_SALE_AMT    --21,22,23,24,25
                                    , SOC.MEMB_AVG_CUST_CNT, SOC.PUBL_AVG_CUST_CNT, SOC.MEMB_AVG_BILL_CNT, SOC.PUBL_AVG_BILL_CNT, SOC.MEMB_AVG_SALE_AMT    --26,27,28,29,30
                                    , SOC.PUBL_AVG_SALE_AMT, SYSDATE              , SOC.STOR_CNT                                                        )  --31,32,33
      ;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := 'NG';
        STAT_LOG_SAVE('BATCH_STAT_MEMBER_TOT4', '전체 회원 현황 자료 생성', '4-3-2.년도별_SSS구분별-년도별_합:::'||SQLERRM, PO_RETC, V_RETC);
    END;
  END IF;


  IF PO_RETC IS NULL THEN
    COMMIT;
    PO_RETC := 'OK';
    STAT_LOG_SAVE('BATCH_STAT_MEMBER_TOT4', '전체 회원 현황 자료 생성', '4.지역별:::'||V_YYMM, PO_RETC, V_RETC);
  END IF;

END BATCH_STAT_MEMBER_TOT4;

/
