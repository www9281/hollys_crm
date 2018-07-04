--------------------------------------------------------
--  DDL for Procedure SP_SET_PL_DO_0010
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_PL_DO_0010" ( PSV_COMP_CD  IN VARCHAR2,  -- 회사코드
                                                    PSV_BRAND_CD IN VARCHAR2,  -- 브랜드코드
                                                    PSV_STOR_CD  IN VARCHAR2,  -- 매장코드
                                                    PSV_STD_YM   IN VARCHAR2,  -- 기준년월
                                                    PSV_RTN_CD   OUT VARCHAR2, -- 처리결과코드
                                                    PSV_RTN_MSG  OUT VARCHAR2) -- 처리결과메시지
IS
    CURSOR CUR_1 IS
        WITH W_ITEM AS
       (
            SELECT  COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , STOR_TP
                  , ITEM_CD
                  , L_CLASS_CD      AS CLASS_CD
                  , ORD_SALE_DIV
                  , SALE_PRC
                  , CASE WHEN NVL(ORD_UNIT_QTY, 1) = 0 THEN COST 
                         ELSE COST / NVL(ORD_UNIT_QTY, 1)
                    END  AS COST
                  , SALE_VAT_YN
                  , SALE_VAT_IN_RATE
            FROM   (      
                    SELECT  /*+ LEADING(STO) INDEX(STO PK_STORE) */
                            STO.COMP_CD
                          , STO.BRAND_CD
                          , STO.STOR_CD
                          , STO.STOR_TP
                          , ITC.ITEM_CD
                          , ICL.L_CLASS_CD 
                          , ITC.ORD_SALE_DIV
                          , NVL(ICH.SALE_PRC, ITC.SALE_PRC)     AS SALE_PRC
                          , CASE WHEN ITC.COST_VAT_YN = 'Y' AND ITC.COST_VAT_RULE = '1' THEN ROUND(NVL(ICH.COST, NVL(ITC.COST, 0))/1.1, 2)
                                 ELSE ROUND(NVL(ICH.COST, NVL(ITC.COST, 0)), 2)
                            END             AS COST
                          , ITC.SALE_VAT_YN
                          , ITC.SALE_VAT_IN_RATE
                          , NVL(ITC.ORD_UNIT_QTY, 1)    ORD_UNIT_QTY
                          , NVL(ITC.WEIGHT_UNIT, 1)     WEIGHT_UNIT
                          , NVL(ITC.YIELD_RATE, 1)      YIELD_RATE
                    FROM    STORE                   STO
                          , ITEM_CHAIN              ITC
                          , ITEM_CLASS              ICL
                          , (
                                SELECT  COMP_CD
                                     ,  BRAND_CD
                                     ,  STOR_TP
                                     ,  ITEM_CD
                                     ,  COST
                                     ,  SALE_PRC
                                  FROM  ITEM_CHAIN_HIS  IC
                                 WHERE  COMP_CD     = PSV_COMP_CD
                                   AND  BRAND_CD    = PSV_BRAND_CD
                                   AND  STOR_TP     = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = PSV_COMP_CD AND BRAND_CD = PSV_BRAND_CD AND STOR_CD = PSV_STOR_CD)
                                   AND  PSV_STD_YM||'31' BETWEEN IC.START_DT AND NVL(IC.CLOSE_DT, '99991231')
                            )               ICH
                    WHERE   STO.COMP_CD  = ITC.COMP_CD
                    AND     STO.BRAND_CD = ITC.BRAND_CD
                    AND     STO.STOR_TP  = ITC.STOR_TP
                    AND     ITC.COMP_CD  = ICH.COMP_CD
                    AND     ITC.BRAND_CD = ICH.BRAND_CD
                    AND     ITC.STOR_TP  = ICH.STOR_TP
                    AND     ITC.ITEM_CD  = ICH.ITEM_CD
                    AND     ITC.COMP_CD  = ICL.COMP_CD
                    AND     ITC.ITEM_CD  = ICL.ITEM_CD
                    AND     '01'         = ICL.ORG_CLASS_CD
                    AND     STO.COMP_CD  = PSV_COMP_CD
                    AND     STO.BRAND_CD = PSV_BRAND_CD
                    AND     STO.STOR_CD  = PSV_STOR_CD
                   )
       )
        SELECT  PDC.COMP_CD
              , NVL(NBL.STD_YM  , PSV_STD_YM)   AS STD_YM
              , NVL(NBL.BRAND_CD, PSV_BRAND_CD) AS BRAND_CD
              , NVL(NBL.STOR_CD , PSV_STOR_CD)  AS STOR_CD
              , PDC.CLASS_CD
              , NVL(SUM(NBL.SAL_N_AMT), 0) AS SAL_N_AMT
              , NVL(SUM(NBL.LST_M_STK), 0) AS LST_M_STK_AMT
              , NVL(SUM(NBL.CUR_M_BUY), 0) AS CUR_M_BUY_AMT
              , NVL(SUM(NBL.CUR_M_STK), 0) AS CUR_M_STK_AMT
              , NVL(SUM(NBL.RCP_O_AMT), 0) AS RCP_O_AMT
        FROM    PL_DO_CLASS_003 PDC,
               (
                SELECT  ITM.COMP_CD
                      , PSV_STD_YM                  AS STD_YM
                      , ITM.BRAND_CD
                      , ITM.STOR_CD
                      , PDC.CLASS_CD
                      , CASE WHEN ITM.SALE_VAT_YN = 'Y' THEN (JDM.GRD_AMT - JDM.VAT_AMT) + CEIL((JDM.DC_AMT + JDM.ENR_AMT) / (1 + ITM.SALE_VAT_IN_RATE))
                             ELSE (JDM.GRD_AMT - JDM.VAT_AMT) + (JDM.DC_AMT + JDM.ENR_AMT) END AS SAL_N_AMT
                      , 0                           AS LST_M_STK
                      , 0                           AS CUR_M_BUY
                      , 0                           AS CUR_M_STK
                      , CEIL(JDM.SALE_QTY * NVL(RCP.ORG_COST, 0))
                                                    AS RCP_O_AMT
                FROM    W_ITEM               ITM,
                        PL_DO_CLASS_003      PDC,
                        SALE_JDM             JDM,
                       (
                        SELECT  RCP.COMP_CD,
                                RCP.BRAND_CD,
                                RCP.STOR_TP,
                                RCP.P_ITEM_CD,
                                SUM(RCP.DO_COST) ORG_COST
                        FROM    TABLE(FN_RCP_STD_0021(PSV_COMP_CD, PSV_BRAND_CD, PSV_STD_YM)) RCP
                        GROUP BY
                                RCP.COMP_CD,
                                RCP.BRAND_CD,
                                RCP.STOR_TP,
                                RCP.P_ITEM_CD
                        UNION ALL
                        SELECT  ITC.COMP_CD
                             ,  ITC.BRAND_CD
                             ,  ITC.STOR_TP
                             ,  ITC.ITEM_CD
                             ,  ITC.COST ORG_COST
                        FROM    W_ITEM ITC
                        WHERE   ITC.ORD_SALE_DIV IN ('2', '3')
                        AND     NOT EXISTS( SELECT  1
                                            FROM    RECIPE_BRAND RB
                                            WHERE   RB.COMP_CD  = ITC.COMP_CD
                                            AND     RB.BRAND_CD = ITC.BRAND_CD
                                            AND     RB.ITEM_CD  = ITC.ITEM_CD
                                            AND     RB.USE_YN   = 'Y')
                       ) RCP
                WHERE   ITM.COMP_CD    = PDC.COMP_CD
                AND     ITM.CLASS_CD   = PDC.CLASS_CD
                AND     ITM.COMP_CD    = JDM.COMP_CD
                AND     ITM.BRAND_CD   = JDM.BRAND_CD
                AND     ITM.STOR_CD    = JDM.STOR_CD
                AND     ITM.ITEM_CD    = JDM.ITEM_CD
                AND     ITM.COMP_CD    = RCP.COMP_CD  (+)
                AND     ITM.BRAND_CD   = RCP.BRAND_CD (+)
                AND     ITM.STOR_TP    = RCP.STOR_TP  (+) 
                AND     ITM.ITEM_CD    = RCP.P_ITEM_CD(+)
                AND     JDM.COMP_CD    = PSV_COMP_CD
                AND     JDM.BRAND_CD   = PSV_BRAND_CD
                AND     JDM.STOR_CD    = PSV_STOR_CD
                AND     JDM.SALE_DT LIKE PSV_STD_YM||'%'
                UNION ALL
                SELECT  ITM.COMP_CD
                      , PSV_STD_YM                              AS STD_YM
                      , ITM.BRAND_CD
                      , ITM.STOR_CD
                      , '110' CLASS_CD
                      , CASE WHEN ITM.SALE_VAT_YN = 'Y' THEN CEIL((JDM.DC_AMT + JDM.ENR_AMT) / (1 + ITM.SALE_VAT_IN_RATE))
                             ELSE JDM.DC_AMT + JDM.ENR_AMT END  AS DC_AMT
                      , 0                                       AS LST_M_STK
                      , 0                                       AS CUR_M_BUY
                      , 0                                       AS CUR_M_STK
                      , 0                                       AS RCP_O_AMT
                FROM    W_ITEM               ITM,
                        SALE_JDM             JDM
                WHERE   ITM.COMP_CD    = JDM.COMP_CD
                AND     ITM.BRAND_CD   = JDM.BRAND_CD
                AND     ITM.STOR_CD    = JDM.STOR_CD
                AND     ITM.ITEM_CD    = JDM.ITEM_CD
                AND     JDM.COMP_CD    = PSV_COMP_CD
                AND     JDM.BRAND_CD   = PSV_BRAND_CD
                AND     JDM.STOR_CD    = PSV_STOR_CD
                AND     JDM.SALE_DT LIKE PSV_STD_YM||'%'
                UNION ALL
                SELECT  ITM.COMP_CD
                      , PSV_STD_YM                  AS STD_YM
                      , ITM.BRAND_CD
                      , ITM.STOR_CD
                      , PDC.CLASS_CD
                      , 0                           AS SAL_N_AMT
                      , CASE WHEN MST.PRC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(PSV_STD_YM, 'YYYYMM'), -1), 'YYYYMM') THEN MST.SURV_QTY
                             ELSE 0 END * ITM.COST  AS LST_M_STK
                      , 0                           AS CUR_M_BUY
                      , CASE WHEN MST.PRC_YM = PSV_STD_YM THEN MST.SURV_QTY
                             ELSE 0 END * ITM.COST  AS CUR_M_STK
                      , 0                           AS RCP_O_AMT
                FROM    W_ITEM               ITM,
                        PL_DO_CLASS_003      PDC,
                        MSTOCK               MST
                WHERE   ITM.COMP_CD    = PDC.COMP_CD
                AND     ITM.CLASS_CD   = PDC.CLASS_CD
                AND     ITM.COMP_CD    = MST.COMP_CD
                AND     ITM.BRAND_CD   = MST.BRAND_CD
                AND     ITM.STOR_CD    = MST.STOR_CD
                AND     ITM.ITEM_CD    = MST.ITEM_CD
                AND     MST.COMP_CD    = PSV_COMP_CD
                AND     MST.BRAND_CD   = PSV_BRAND_CD
                AND     MST.STOR_CD    = PSV_STOR_CD
                AND     MST.PRC_YM    >= TO_CHAR(ADD_MONTHS(TO_DATE(PSV_STD_YM, 'YYYYMM'), -1), 'YYYYMM')
                AND     MST.PRC_YM    <= PSV_STD_YM
                UNION ALL
                SELECT  ITM.COMP_CD
                      , PSV_STD_YM                  AS STD_YM
                      , ITM.BRAND_CD
                      , ITM.STOR_CD
                      , PDC.CLASS_CD
                      , 0                           AS SAL_N_AMT
                      , 0                           AS LST_M_STK
                      ,(DST.ORD_QTY - DST.RTN_QTY + DST.MV_IN_QTY - DST.MV_OUT_QTY) * ITM.COST
                                                    AS CUR_M_BUY
                      , 0                           AS CUR_M_STK
                      , 0                           AS RCP_O_AMT
                FROM    W_ITEM               ITM,
                        PL_DO_CLASS_003      PDC,
                        DSTOCK               DST
                WHERE   ITM.COMP_CD    = PDC.COMP_CD
                AND     ITM.CLASS_CD   = PDC.CLASS_CD
                AND     ITM.COMP_CD    = DST.COMP_CD
                AND     ITM.BRAND_CD   = DST.BRAND_CD
                AND     ITM.STOR_CD    = DST.STOR_CD
                AND     ITM.ITEM_CD    = DST.ITEM_CD
                AND     DST.COMP_CD    = PSV_COMP_CD
                AND     DST.BRAND_CD   = PSV_BRAND_CD
                AND     DST.STOR_CD    = PSV_STOR_CD
                AND     DST.PRC_DT  LIKE PSV_STD_YM||'%'
               ) NBL
        WHERE   PDC.COMP_CD  = NBL.COMP_CD (+)
        AND     PDC.CLASS_CD = NBL.CLASS_CD(+)
        GROUP BY
                PDC.COMP_CD
              , NVL(NBL.STD_YM  , PSV_STD_YM)
              , NVL(NBL.BRAND_CD, PSV_BRAND_CD)
              , NVL(NBL.STOR_CD , PSV_STOR_CD)
              , PDC.CLASS_CD;

    MYREC       CUR_1%ROWTYPE;
    nCOLVAL     NUMBER(12, 2) := 0;
BEGIN
    PSV_RTN_CD  := '0';
    PSV_RTN_MSG := NULL;

    /* 월 실적 작성 */
    BEGIN
        /* 상세 실적 작성 */
        FOR MYREC IN CUR_1 LOOP
            /* 재료비 공제 합계금액 */
            IF MYREC.CLASS_CD = '110' THEN
                SELECT  NVL(SUM(DO_VAL1), 0) INTO nCOLVAL
                FROM    PL_MCOST_003        PM3
                      , PL_MCOST_CLASS_003  PC3
                WHERE   PM3.COMP_CD  = PC3.COMP_CD
                AND     PM3.CLASS_CD = PC3.CLASS_CD
                AND     PM3.COMP_CD  = MYREC.COMP_CD
                AND     PM3.DO_YM    = MYREC.STD_YM
                AND     PM3.BRAND_CD = MYREC.BRAND_CD
                AND     PM3.STOR_CD  = MYREC.STOR_CD
                AND     PC3.CLASS_DIV='1';
            ELSE
                nCOLVAL := 0;
            END IF;

            MERGE INTO PL_DO_003 PD3
            USING DUAL
            ON  (       PD3.COMP_CD  = MYREC.COMP_CD
                    AND PD3.DO_YM    = MYREC.STD_YM
                    AND PD3.BRAND_CD = MYREC.BRAND_CD
                    AND PD3.STOR_CD  = MYREC.STOR_CD
                    AND PD3.CLASS_CD = MYREC.CLASS_CD
                )
            WHEN MATCHED THEN
                UPDATE  SET
                    PD3.DO_VAL1  = ROUND(MYREC.SAL_N_AMT, 0),
                    PD3.DO_VAL2  = ROUND(MYREC.LST_M_STK_AMT, 0),
                    PD3.DO_VAL3  = ROUND(MYREC.CUR_M_BUY_AMT, 0),
                    PD3.DO_VAL5  = ROUND(MYREC.CUR_M_STK_AMT, 0),
                    PD3.DO_VAL6  = ROUND(nCOLVAL, 0),
                    PD3.DO_VAL7  = ROUND(MYREC.RCP_O_AMT, 0),
                    PD3.UPD_DT   = SYSDATE,
                    PD3.UPD_USER = 'SYSADMIN'
            WHEN NOT MATCHED THEN
                INSERT(
                        COMP_CD, DO_YM, BRAND_CD, STOR_CD, CLASS_CD
                       ,DO_VAL1, DO_VAL2, DO_VAL3, DO_VAL4
                       ,DO_VAL5, DO_VAL6, DO_VAL7, DO_VAL8, DO_STAT
                       ,INST_DT, INST_USER, UPD_DT, UPD_USER
                      )
                VALUES(
                        MYREC.COMP_CD
                       ,MYREC.STD_YM
                       ,MYREC.BRAND_CD
                       ,MYREC.STOR_CD
                       ,MYREC.CLASS_CD
                       ,ROUND(MYREC.SAL_N_AMT, 0)
                       ,ROUND(MYREC.LST_M_STK_AMT, 0)
                       ,ROUND(MYREC.CUR_M_BUY_AMT, 0)
                       ,0
                       ,ROUND(MYREC.CUR_M_STK_AMT, 0)
                       ,ROUND(nCOLVAL, 0)
                       ,ROUND(MYREC.RCP_O_AMT, 0)
                       ,0 
                       ,'1'
                       ,SYSDATE
                       ,'SYSADMIN'
                       ,SYSDATE
                       ,'SYSADMIN'
                       );

            /* 소계, 실적 미존재 항목 작성 */
            MERGE INTO PL_DO_003 PD3
            USING  (
                    SELECT  COMP_CD
                           ,DO_YM
                           ,BRAND_CD
                           ,STOR_CD
                           ,CLASS_CD
                           ,SUM(DO_VAL1)    AS DO_VAL1
                           ,SUM(DO_VAL2)    AS DO_VAL2
                           ,SUM(DO_VAL3)    AS DO_VAL3
                           ,SUM(DO_VAL4)    AS DO_VAL4
                           ,SUM(DO_VAL5)    AS DO_VAL5
                           ,SUM(DO_VAL6)    AS DO_VAL6
                           ,SUM(DO_VAL7)    AS DO_VAL7
                           ,SUM(DO_VAL8)    AS DO_VAL8
                    FROM   (
                            SELECT  PC.COMP_CD                  AS COMP_CD,
                                    PSV_STD_YM                  AS DO_YM,
                                    PSV_BRAND_CD                AS BRAND_CD,
                                    PSV_STOR_CD                 AS STOR_CD,
                                    CASE WHEN PC.CLASS_CD LIKE '1%' THEN '120'
                                         ELSE PC.CLASS_CD END   AS CLASS_CD,
                                    CASE WHEN PC.CLASS_CD LIKE '110' THEN NVL(DO_VAL1, 0) * (-1)
                                         ELSE NVL(DO_VAL1, 0) END   AS DO_VAL1,
                                    NVL(DO_VAL2, 0) AS DO_VAL2,
                                    NVL(DO_VAL3, 0) AS DO_VAL3,
                                    NVL(DO_VAL4, 0) AS DO_VAL4,
                                    NVL(DO_VAL5, 0) AS DO_VAL5,
                                    CASE WHEN PC.CLASS_CD LIKE '110' THEN NVL(DO_VAL6, 0) * (-1)
                                         ELSE NVL(DO_VAL6, 0) END   AS DO_VAL6,
                                    NVL(DO_VAL7, 0) AS DO_VAL7,
                                    NVL(DO_VAL8, 0) AS DO_VAL8
                            FROM    PL_DO_003       PD,
                                    PL_DO_CLASS_003 PC
                            WHERE   PC.COMP_CD  = PD.COMP_CD (+)
                            AND     PC.CLASS_CD = PD.CLASS_CD(+)
                            AND     PD.COMP_CD (+) = MYREC.COMP_CD
                            AND     PD.DO_YM   (+) = MYREC.STD_YM
                            AND     PD.BRAND_CD(+) = MYREC.BRAND_CD
                            AND     PD.STOR_CD (+) = MYREC.STOR_CD
                            AND     PC.CLASS_CD IN ('100','110')
                           ) V02
                    GROUP BY
                            COMP_CD
                           ,DO_YM
                           ,BRAND_CD
                           ,STOR_CD
                           ,CLASS_CD
                   ) DTL
            ON     (    PD3.COMP_CD  = DTL.COMP_CD
                    AND PD3.DO_YM    = DTL.DO_YM
                    AND PD3.BRAND_CD = DTL.BRAND_CD
                    AND PD3.STOR_CD  = DTL.STOR_CD
                    AND PD3.CLASS_CD = DTL.CLASS_CD
                   )
            WHEN MATCHED THEN
                UPDATE  SET
                    PD3.DO_VAL1  = DTL.DO_VAL1,
                    PD3.DO_VAL2  = DTL.DO_VAL2,
                    PD3.DO_VAL3  = DTL.DO_VAL3,
                    PD3.DO_VAL4  = DTL.DO_VAL5,
                    PD3.DO_VAL5  = DTL.DO_VAL5,
                    PD3.DO_VAL6  = DTL.DO_VAL6,
                    PD3.DO_VAL7  = DTL.DO_VAL7,
                    PD3.DO_VAL8  = DTL.DO_VAL8,
                    PD3.UPD_DT   = SYSDATE,
                    PD3.UPD_USER = 'SYSADMIN'
            WHEN NOT MATCHED THEN
                INSERT (
                        COMP_CD, DO_YM, BRAND_CD, STOR_CD, CLASS_CD,
                        DO_VAL1, DO_VAL2, DO_VAL3, DO_VAL4,
                        DO_VAL5, DO_VAL6, DO_VAL7, DO_VAL8, DO_STAT,
                        INST_DT, INST_USER, UPD_DT, UPD_USER
                       )
                VALUES (
                        DTL.COMP_CD,
                        DTL.DO_YM,
                        DTL.BRAND_CD,
                        DTL.STOR_CD,
                        DTL.CLASS_CD,
                        DTL.DO_VAL1,
                        DTL.DO_VAL2,
                        DTL.DO_VAL3,
                        DTL.DO_VAL4,
                        DTL.DO_VAL5,
                        DTL.DO_VAL6,
                        DTL.DO_VAL7,
                        DTL.DO_VAL8,
                        '1',
                        SYSDATE,
                        'SYSADMIN',
                        SYSDATE,
                        'SYSADMIN'
                       );
        END LOOP;

        -- 판매촉진비 갱신
        MERGE INTO PL_MCOST_003
        USING DUAL
        ON  (
                    COMP_CD     = PSV_COMP_CD
                AND DO_YM       = PSV_STD_YM
                AND BRAND_CD    = PSV_BRAND_CD
                AND STOR_CD     = PSV_STOR_CD
                AND CLASS_CD    = '110'
            )
        WHEN MATCHED THEN
            UPDATE
               SET  DO_VAL1 = (
                                SELECT  ROUND(DC_AMT * (DECODE(DO_VAL1, 0, 0, ROUND(DO_VAL7/DO_VAL1*100, 2)))/100, 0)
                                  FROM  (
                                            SELECT  COMP_CD
                                                 ,  DO_YM
                                                 ,  BRAND_CD
                                                 ,  STOR_CD
                                                 ,  MAX(DECODE(CLASS_CD, '110', DO_VAL1))               AS DC_AMT
                                                 ,  SUM(DECODE(CLASS_CD, '110', -1*DO_VAL1, DO_VAL1))   AS DO_VAL1
                                                 ,  SUM(TRUNC(DO_VAL7))                                 AS DO_VAL7
                                              FROM  PL_DO_003
                                             WHERE  COMP_CD  = PSV_COMP_CD
                                               AND  DO_YM    = PSV_STD_YM
                                               AND  BRAND_CD = PSV_BRAND_CD
                                               AND  STOR_CD  = PSV_STOR_CD
                                               AND  CLASS_CD <> '120'
                                             GROUP  BY COMP_CD, DO_YM, BRAND_CD, STOR_CD
                                        )
                             )
                 ,  UPD_DT  = SYSDATE
                 ,  UPD_USER= 'SYSTEM'
        WHEN NOT MATCHED THEN
            INSERT 
            (  
                    COMP_CD
                ,   DO_YM
                ,   BRAND_CD
                ,   STOR_CD
                ,   CLASS_CD
                ,   DO_VAL1
                ,   INST_DT 
                ,   INST_USER 
                ,   UPD_DT 
                ,   UPD_USER
            ) VALUES (
                    PSV_COMP_CD
                ,   PSV_STD_YM
                ,   PSV_BRAND_CD
                ,   PSV_STOR_CD
                ,   '110'
                ,   (
                        SELECT  ROUND(DC_AMT * (DECODE(DO_VAL1, 0, 0, ROUND(DO_VAL7/DO_VAL1*100, 2)))/100, 0)
                          FROM  (
                                    SELECT  COMP_CD
                                         ,  DO_YM
                                         ,  BRAND_CD
                                         ,  STOR_CD
                                         ,  MAX(DECODE(CLASS_CD, '110', DO_VAL1))               AS DC_AMT
                                         ,  SUM(DECODE(CLASS_CD, '110', -1*DO_VAL1, DO_VAL1))   AS DO_VAL1
                                         ,  SUM(ROUND(DO_VAL7, 0))                              AS DO_VAL7
                                      FROM  PL_DO_003
                                     WHERE  COMP_CD  = PSV_COMP_CD
                                       AND  DO_YM    = PSV_STD_YM
                                       AND  BRAND_CD = PSV_BRAND_CD
                                       AND  STOR_CD  = PSV_STOR_CD
                                       AND  CLASS_CD <> '120'
                                     GROUP  BY COMP_CD, DO_YM, BRAND_CD, STOR_CD
                                )
                    )
                ,   SYSDATE
                ,   'SYSTEM'
                ,   SYSDATE
                ,   'SYSTEM'
            );

    EXCEPTION
        WHEN OTHERS THEN
            PSV_RTN_CD  := '-1000';
            PSV_RTN_MSG := SQLERRM;

            -- 취소 처리
            ROLLBACK;

            RETURN;
    END;

    PSV_RTN_CD  := '0';

    -- 정상처리 완료
    COMMIT;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD  := '-9999';
        PSV_RTN_MSG := SQLERRM;

        -- 취소 처리
        ROLLBACK;

        RETURN;
END;

/
