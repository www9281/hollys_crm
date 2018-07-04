--------------------------------------------------------
--  DDL for Procedure BATCH_CUST_ITEM_SUMMARY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_CUST_ITEM_SUMMARY" (
  PI_YMD   IN   VARCHAR2,
  PI_MMS   IN   BOOLEAN ,
  PO_RETC  OUT  VARCHAR2
)
IS
  V_COMP_CD     VARCHAR2(3);
  V_YMD         VARCHAR2(8);
  V_YYMM        VARCHAR2(6);
BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-05-21
  -- Description   :   회원 상품별 일집계
  -- ==========================================================================================

  PO_RETC := NULL;

  SELECT '016'
       , DECODE(PI_YMD,NULL,TO_CHAR(SYSDATE,'YYYYMMDD'),PI_YMD            )
       , DECODE(PI_YMD,NULL,TO_CHAR(SYSDATE,'YYYYMM')  ,SUBSTR(PI_YMD,1,6))
  INTO   V_COMP_CD
       , V_YMD 
       , V_YYMM
  FROM   DUAL
  ;

  ---------------------------------------------------------------------------------------------------
  --회원 상품별 일집계
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  C_CUST_DMS         TAR
      USING (SELECT MAX(T1.COMP_CD)                             COMP_CD                                          -- 1
                  , T1.SALE_DT                                  SALE_DT                                          -- 2
                  , T1.BRAND_CD                                 BRAND_CD                                         -- 3
                  , T1.STOR_CD                                  STOR_CD                                          -- 4
                  , T1.CUST_ID                                  CUST_ID                                          -- 5
                  , T1.ITEM_CD                                  ITEM_CD                                          -- 6
                  , MAX(CASE WHEN T2.CUST_AGE > 100 
                             THEN 999 
                             ELSE T2.CUST_AGE 
                        END                                  )  CUST_AGE                                         -- 7
                  , MAX(T2.CUST_SEX                          )  CUST_SEX                                         -- 8
                  , MAX(NVL(T3.CUST_LVL,T2.CUST_LVL)         )  CUST_LVL                                         -- 9
                  , SUM(T1.SALE_QTY                          )  SALE_QTY                                         --10
                  , SUM(T1.SALE_AMT                          )  SALE_AMT                                         --11
                  , SUM(T1.DC_AMT                            )  DC_AMT                                           --12
                  , SUM(T1.ENR_AMT                           )  ENR_AMT                                          --13
                  , SUM(T1.GRD_AMT                           )  GRD_AMT                                          --14
                  , SUM(DECODE(T1.TAKE_DIV,'0',T1.GRD_AMT ,0))  GRD_I_AMT                                        --15
                  , SUM(DECODE(T1.TAKE_DIV,'1',T1.GRD_AMT ,0))  GRD_O_AMT                                        --16
                  , SUM(T1.VAT_AMT                           )  VAT_AMT                                          --17
                  , SUM(DECODE(T1.TAKE_DIV,'0',T1.VAT_AMT ,0))  VAT_I_AMT                                        --18
                  , SUM(DECODE(T1.TAKE_DIV,'1',T1.VAT_AMT ,0))  VAT_O_AMT                                        --19
                  , SUM(DECODE(T1.SALE_DIV,'2',T1.SALE_QTY,0))  RTN_QTY                                          --20
                  , SUM(DECODE(T1.SALE_DIV,'2',T1.GRD_AMT ,0))  RTN_AMT                                          --21
             FROM   SALE_DT  T1
                  , (--고객 성별, 나이, 등급 등을 구한다.
                     SELECT CUST_ID
                          , CASE WHEN BIRTH_DT = '99999999'
                                 THEN 999
                                 ELSE TRUNC((V_YYMM - SUBSTR(DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT),1,6)) / 100 + 1)
                            END       CUST_AGE
                          , SEX_DIV   CUST_SEX
                          , LVL_CD    CUST_LVL
                     FROM   C_CUST
                     WHERE  COMP_CD = V_COMP_CD
                     AND    CUST_ID IN (SELECT DISTINCT CUST_ID
                                        FROM   SALE_HD
                                        WHERE  COMP_CD = V_COMP_CD
                                        AND    SALE_DT = V_YMD
                                        AND    CUST_ID IS NOT NULL
                                       )
                    )        T2
                  , (--고객의 집계년월의 등급변경내역을 구한다.
                     SELECT CUST_ID
                          , CHG_FR    CUST_LVL
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
                    )        T3
             WHERE  T1.COMP_CD  = V_COMP_CD
             AND    T1.SALE_DT  = V_YMD
             AND    T1.CUST_ID IS NOT NULL
             AND    T1.GIFT_DIV = '0'
             AND    T1.T_SEQ    = '0'
             AND    T1.CUST_ID  = T2.CUST_ID
             AND    T2.CUST_ID  = T3.CUST_ID(+)
             GROUP BY T1.SALE_DT,T1.BRAND_CD,T1.STOR_CD,T1.CUST_ID,T1.ITEM_CD
            )                  SOC
      ON    (    TAR.COMP_CD  = SOC.COMP_CD
             AND TAR.SALE_DT  = SOC.SALE_DT
             AND TAR.BRAND_CD = SOC.BRAND_CD
             AND TAR.STOR_CD  = SOC.STOR_CD
             AND TAR.CUST_ID  = SOC.CUST_ID
             AND TAR.ITEM_CD  = SOC.ITEM_CD
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      TAR.CUST_AGE  = SOC.CUST_AGE
                                    , TAR.CUST_SEX  = SOC.CUST_SEX
                                    , TAR.CUST_LVL  = SOC.CUST_LVL
                                    , TAR.SALE_QTY  = SOC.SALE_QTY
                                    , TAR.SALE_AMT  = SOC.SALE_AMT
                                    , TAR.DC_AMT    = SOC.DC_AMT
                                    , TAR.ENR_AMT   = SOC.ENR_AMT
                                    , TAR.GRD_AMT   = SOC.GRD_AMT
                                    , TAR.GRD_I_AMT = SOC.GRD_I_AMT
                                    , TAR.GRD_O_AMT = SOC.GRD_O_AMT
                                    , TAR.VAT_AMT   = SOC.VAT_AMT
                                    , TAR.VAT_I_AMT = SOC.VAT_I_AMT
                                    , TAR.VAT_O_AMT = SOC.VAT_O_AMT
                                    , TAR.RTN_QTY   = SOC.RTN_QTY
                                    , TAR.RTN_AMT   = SOC.RTN_AMT
      WHEN  NOT MATCHED THEN INSERT ( COMP_CD  , SALE_DT  , BRAND_CD, STOR_CD  , CUST_ID  , ITEM_CD, CUST_AGE    -- 1, 2, 3, 4, 5, 6, 7
                                    , CUST_SEX , CUST_LVL , SALE_QTY, SALE_AMT , DC_AMT   , ENR_AMT, GRD_AMT     -- 8, 9,10,11,12,13,14
                                    , GRD_I_AMT, GRD_O_AMT, VAT_AMT , VAT_I_AMT, VAT_O_AMT, RTN_QTY, RTN_AMT  )  --15,16,17,18,19,20,21
                             VALUES ( SOC.COMP_CD                                                                -- 1.COMP_CD
                                    , SOC.SALE_DT                                                                -- 2.SALE_DT
                                    , SOC.BRAND_CD                                                               -- 3.BRAND_CD
                                    , SOC.STOR_CD                                                                -- 4.STOR_CD
                                    , SOC.CUST_ID                                                                -- 5.CUST_ID
                                    , SOC.ITEM_CD                                                                -- 6.ITEM_CD
                                    , SOC.CUST_AGE                                                               -- 7.CUST_AGE
                                    , SOC.CUST_SEX                                                               -- 8.CUST_SEX
                                    , SOC.CUST_LVL                                                               -- 9.CUST_LVL
                                    , SOC.SALE_QTY                                                               --10.SALE_QTY
                                    , SOC.SALE_AMT                                                               --11.SALE_AMT
                                    , SOC.DC_AMT                                                                 --12.DC_AMT
                                    , SOC.ENR_AMT                                                                --13.ENR_AMT
                                    , SOC.GRD_AMT                                                                --14.GRD_AMT
                                    , SOC.GRD_I_AMT                                                              --15.GRD_I_AMT
                                    , SOC.GRD_O_AMT                                                              --16.GRD_O_AMT
                                    , SOC.VAT_AMT                                                                --17.VAT_AMT
                                    , SOC.VAT_I_AMT                                                              --18.VAT_I_AMT
                                    , SOC.VAT_O_AMT                                                              --19.VAT_O_AMT
                                    , SOC.RTN_QTY                                                                --20.RTN_QTY
                                    , SOC.RTN_AMT                                                                --21.RTN_AMT
                                    )
      ;
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '1.회원 상품별 일집계-' || V_YMD
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;
  
  ---------------------------------------------------------------------------------------------------
  --회원 상품별 월집계
  ---------------------------------------------------------------------------------------------------
  IF PI_MMS THEN 
    IF PO_RETC IS NULL THEN
      BEGIN
        MERGE
        INTO  C_CUST_MMS         TAR
        USING (SELECT MAX(COMP_CD)              COMP_CD                                                            -- 1
                    , V_YYMM                    SALE_YM                                                            -- 2
                    , BRAND_CD                  BRAND_CD                                                           -- 3
                    , STOR_CD                   STOR_CD                                                            -- 4
                    , CUST_ID                   CUST_ID                                                            -- 5
                    , CUST_LVL                  CUST_LVL                                                           -- 6
                    , ITEM_CD                   ITEM_CD                                                            -- 7
                    , MAX(CUST_AGE )            CUST_AGE                                                           -- 8
                    , MAX(CUST_SEX )            CUST_SEX                                                           -- 9
                    , SUM(SALE_QTY )            SALE_QTY                                                           --10
                    , SUM(SALE_AMT )            SALE_AMT                                                           --11
                    , SUM(DC_AMT   )            DC_AMT                                                             --12
                    , SUM(ENR_AMT  )            ENR_AMT                                                            --13
                    , SUM(GRD_AMT  )            GRD_AMT                                                            --14
                    , SUM(GRD_I_AMT)            GRD_I_AMT                                                          --15
                    , SUM(GRD_O_AMT)            GRD_O_AMT                                                          --16
                    , SUM(VAT_AMT  )            VAT_AMT                                                            --17
                    , SUM(VAT_I_AMT)            VAT_I_AMT                                                          --18
                    , SUM(VAT_O_AMT)            VAT_O_AMT                                                          --19
                    , SUM(RTN_QTY  )            RTN_QTY                                                            --20
                    , SUM(RTN_AMT  )            RTN_AMT                                                            --21
               FROM   C_CUST_DMS
               WHERE  COMP_CD  = V_COMP_CD
               AND    SALE_DT BETWEEN V_YYMM||'01' AND V_YYMM||'31'
               GROUP BY BRAND_CD,STOR_CD,CUST_ID,CUST_LVL,ITEM_CD
              )                  SOC
        ON    (    TAR.COMP_CD  = SOC.COMP_CD
               AND TAR.SALE_YM  = SOC.SALE_YM
               AND TAR.BRAND_CD = SOC.BRAND_CD
               AND TAR.STOR_CD  = SOC.STOR_CD
               AND TAR.CUST_ID  = SOC.CUST_ID
               AND TAR.CUST_LVL = SOC.CUST_LVL
               AND TAR.ITEM_CD  = SOC.ITEM_CD
              )
        WHEN  MATCHED     THEN UPDATE
                               SET      TAR.CUST_AGE  = SOC.CUST_AGE
                                      , TAR.CUST_SEX  = SOC.CUST_SEX
                                      , TAR.SALE_QTY  = SOC.SALE_QTY
                                      , TAR.SALE_AMT  = SOC.SALE_AMT
                                      , TAR.DC_AMT    = SOC.DC_AMT
                                      , TAR.ENR_AMT   = SOC.ENR_AMT
                                      , TAR.GRD_AMT   = SOC.GRD_AMT
                                      , TAR.GRD_I_AMT = SOC.GRD_I_AMT
                                      , TAR.GRD_O_AMT = SOC.GRD_O_AMT
                                      , TAR.VAT_AMT   = SOC.VAT_AMT
                                      , TAR.VAT_I_AMT = SOC.VAT_I_AMT
                                      , TAR.VAT_O_AMT = SOC.VAT_O_AMT
                                      , TAR.RTN_QTY   = SOC.RTN_QTY
                                      , TAR.RTN_AMT   = SOC.RTN_AMT
        WHEN  NOT MATCHED THEN INSERT ( COMP_CD  , SALE_YM  , BRAND_CD, STOR_CD  , CUST_ID  , CUST_LVL, ITEM_CD    -- 1, 2, 3, 4, 5, 6, 7
                                      , CUST_AGE , CUST_SEX , SALE_QTY, SALE_AMT , DC_AMT   , ENR_AMT , GRD_AMT    -- 8, 9,10,11,12,13,14
                                      , GRD_I_AMT, GRD_O_AMT, VAT_AMT , VAT_I_AMT, VAT_O_AMT, RTN_QTY , RTN_AMT    --15,16,17,18,19,20,21
                                      , DAY                                                                     )  --22
                               VALUES ( SOC.COMP_CD                                                                -- 1.COMP_CD
                                      , SOC.SALE_YM                                                                -- 2.SALE_DT
                                      , SOC.BRAND_CD                                                               -- 3.BRAND_CD
                                      , SOC.STOR_CD                                                                -- 4.STOR_CD
                                      , SOC.CUST_ID                                                                -- 5.CUST_ID
                                      , SOC.CUST_LVL                                                               -- 6.CUST_LVL
                                      , SOC.ITEM_CD                                                                -- 7.ITEM_CD
                                      , SOC.CUST_AGE                                                               -- 8.CUST_AGE
                                      , SOC.CUST_SEX                                                               -- 9.CUST_SEX
                                      , SOC.SALE_QTY                                                               --10.SALE_QTY
                                      , SOC.SALE_AMT                                                               --11.SALE_AMT
                                      , SOC.DC_AMT                                                                 --12.DC_AMT
                                      , SOC.ENR_AMT                                                                --13.ENR_AMT
                                      , SOC.GRD_AMT                                                                --14.GRD_AMT
                                      , SOC.GRD_I_AMT                                                              --15.GRD_I_AMT
                                      , SOC.GRD_O_AMT                                                              --16.GRD_O_AMT
                                      , SOC.VAT_AMT                                                                --17.VAT_AMT
                                      , SOC.VAT_I_AMT                                                              --18.VAT_I_AMT
                                      , SOC.VAT_O_AMT                                                              --19.VAT_O_AMT
                                      , SOC.RTN_QTY                                                                --20.RTN_QTY
                                      , SOC.RTN_AMT                                                                --21.RTN_AMT
                                      , ''                                                                         --22.DAY
                                      )
        ;
        COMMIT;

        PO_RETC := 'ALL OK-' || V_YMD;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          PO_RETC := '2.회원 상품별 월집계-' || V_YYMM
                  || '('
                  || SQLERRM
                  || ')';
      END;
    END IF;
  ELSE  
    PO_RETC := 'ALL OK-' || V_YMD;
  END IF;

END BATCH_CUST_ITEM_SUMMARY;

/
