--------------------------------------------------------
--  DDL for Procedure SP_MECD1060L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MECD1060L0" (
    PSV_COMP_CD     IN VARCHAR2,                -- 회사코드
    PSV_LANG_CD     IN VARCHAR2,                -- 언어코드
    PSV_PRC_YM      IN VARCHAR2,                -- 처리년월
    PR_RTN_CD       OUT VARCHAR2,               -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                -- 처리Message
   )
IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_MECD1060L0
--  Description      :
--  Ref. Table       :
--------------------------------------------------------------------------------
--  Create Date      : 2016-02-04 엠즈씨드 CRM PJT
--  Modify Date      :
--------------------------------------------------------------------------------
    CURSOR CUR_1(vSTR_YM IN VARCHAR2) IS
        SELECT  CC.COMP_CD
              , CC.CRG_YM
              , CC.CRG_POS_AMT
              , CC.CRG_WEB_AMT
              , CC.CRG_ADJ_AMT
              , CC.CRG_TOT_AMT
              , CC.CRG_HOM_AMT
              , CC.CRG_MOB_AMT
              , NVL(CU.USE_USE_AMT, 0)                  AS USE_USE_AMT
              , CC.CRG_TOT_AMT - NVL(CU.USE_USE_AMT, 0) AS CRG_USE_AMT
              , NVL(CU.SWAP_USE_AMT, 0)                 AS SWAP_USE_AMT
              , NVL(CU.SCAN_USE_AMT, 0)                 AS SCAN_USE_AMT
        FROM   (
                SELECT  /*+ INDEX(HIS IDX03_C_CARD_CHARGE_HIS) */
                        COMP_CD
                     ,  SUBSTR(CRG_DT, 1, 6)                                        AS CRG_YM
                     ,  SUM(CASE WHEN CHANNEL = '1'        THEN CRG_AMT ELSE 0 END) AS CRG_POS_AMT
                     ,  SUM(CASE WHEN CHANNEL IN ('2','3') THEN CRG_AMT ELSE 0 END) AS CRG_WEB_AMT
                     ,  SUM(CASE WHEN CHANNEL = '9'        THEN CRG_AMT ELSE 0 END) AS CRG_ADJ_AMT
                     ,  SUM(CRG_AMT)                                                AS CRG_TOT_AMT
                     ,  SUM(CASE WHEN CHANNEL = '2'        THEN CRG_AMT ELSE 0 END) AS CRG_HOM_AMT
                     ,  SUM(CASE WHEN CHANNEL = '3'        THEN CRG_AMT ELSE 0 END) AS CRG_MOB_AMT
                FROM    C_CARD_CHARGE_HIS HIS
                WHERE   COMP_CD = PSV_COMP_CD
                AND     CRG_DT >= vSTR_YM||'01'
                AND     CRG_DT <  TO_CHAR(SYSDATE - 1, 'YYYYMMDD')
                AND     CRG_SCOPE IN ('1', '3')
                AND     USE_YN  = 'Y'
                GROUP BY
                        COMP_CD
                      , SUBSTR(CRG_DT, 1, 6)
               ) CC
             , (
                SELECT  COMP_CD
                      , SUBSTR(USE_DT, 1, 6) AS USE_YM 
                      , SUM(USE_AMT)         AS USE_USE_AMT
                      , SUM(CASE WHEN NVL(LOG.SCAN_READ_DIV, '@') = 'S' THEN 0 ELSE HIS.USE_AMT END) AS SWAP_USE_AMT
                      , SUM(CASE WHEN NVL(LOG.SCAN_READ_DIV, '@') = 'S' THEN HIS.USE_AMT ELSE 0 END) AS SCAN_USE_AMT
                FROM    C_CARD_USE_HIS HIS
                      ,(
                        SELECT  BRAND_CD
                              , STOR_CD
                              , SALE_DT
                              , POS_NO
                              , BILL_NO
                              , MAX(SCAN_READ_DIV) AS SCAN_READ_DIV
                        FROM    POINT_LOG
                        WHERE   SALE_DT >= vSTR_YM||'01'
                        AND     SALE_DT <  TO_CHAR(SYSDATE - 1, 'YYYYMMDD')
                        AND     RSV_DIV  = '9'
                        AND     PAY_DIV  = '67'
                        AND     PAY_TP   = '2'
                        AND     USE_YN   = 'Y'
                        GROUP BY
                                BRAND_CD
                              , STOR_CD
                              , SALE_DT
                              , POS_NO
                              , BILL_NO
                       ) LOG
                WHERE   HIS.BRAND_CD = LOG.BRAND_CD(+)
                AND     HIS.STOR_CD  = LOG.STOR_CD (+)
                AND     HIS.USE_DT   = LOG.SALE_DT (+)
                AND     HIS.POS_NO   = LOG.POS_NO  (+)
                AND     HIS.BILL_NO  = LOG.BILL_NO (+)
                AND     HIS.COMP_CD = PSV_COMP_CD
                AND     HIS.USE_DT >= vSTR_YM||'01'
                AND     HIS.USE_DT <  TO_CHAR(SYSDATE - 1, 'YYYYMMDD')
                AND     HIS.USE_YN  = 'Y'
                GROUP BY
                        COMP_CD
                      , SUBSTR(USE_DT, 1, 6)
               ) CU
        WHERE   CC.COMP_CD = CU.COMP_CD(+)
        AND     CC.CRG_YM  = CU.USE_YM (+)
        ORDER BY
                1, 2;
        
    vSTD_YM         C_CARD_CHARGE_YM.CRG_YM%TYPE;
    nPRE_END_AMT    C_CARD_CHARGE_YM.END_AMT%TYPE;
    nNXT_END_AMT    C_CARD_CHARGE_YM.END_AMT%TYPE;
BEGIN
    /* 처리 대상 년월 정보 취득 */
    SELECT  CASE WHEN PSV_PRC_YM IS NULL THEN NVL(MIN(CRG_YM), TO_CHAR(SYSDATE, 'YYYYMM')) ELSE PSV_PRC_YM END 
    INTO    vSTD_YM
    FROM    C_CARD_CHARGE_YM
    WHERE   COMP_CD = PSV_COMP_CD
    AND     CHG_DIV = '0';
    
    FOR MYREC IN CUR_1(vSTD_YM) LOOP
        -- 집계자료 작성 직전의 기말재고 취득
        IF MYREC.CRG_YM = vSTD_YM THEN
            SELECT  NVL(MIN(END_AMT), 0) 
            INTO    nPRE_END_AMT
            FROM    C_CARD_CHARGE_YM
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CRG_YM  = TO_CHAR(ADD_MONTHS(TO_DATE(vSTD_YM, 'YYYYMM'), -1), 'YYYYMM');
        END IF;
        
        MERGE INTO C_CARD_CHARGE_YM  CCY
        USING   DUAL
        ON     (
                    CCY.COMP_CD = MYREC.COMP_CD
                AND CCY.CRG_YM  = MYREC.CRG_YM
               )
        WHEN MATCHED THEN
            UPDATE
            SET     BEGIN_AMT = NVL(nPRE_END_AMT, 0)
                  , POS_AMT   = MYREC.CRG_POS_AMT
                  , WEB_AMT   = MYREC.CRG_WEB_AMT
                  , ADJ_AMT   = MYREC.CRG_ADJ_AMT
                  , CRG_AMT   = MYREC.CRG_TOT_AMT
                  , USE_AMT   = MYREC.USE_USE_AMT
                  , END_AMT   = nPRE_END_AMT + MYREC.CRG_USE_AMT
                  , HOM_AMT   = MYREC.CRG_HOM_AMT
                  , MOB_AMT   = MYREC.CRG_MOB_AMT
                  , SWAP_USE_AMT = MYREC.SWAP_USE_AMT
                  , SCAN_USE_AMT = MYREC.SCAN_USE_AMT
                  , CHG_DIV   = '1'
        WHEN NOT MATCHED THEN
            INSERT (
                    COMP_CD
                  , CRG_YM
                  , BEGIN_AMT
                  , POS_AMT
                  , WEB_AMT
                  , ADJ_AMT
                  , CRG_AMT
                  , USE_AMT
                  , END_AMT
                  , CHG_DIV
                  , HOM_AMT
                  , MOB_AMT
                  , SWAP_USE_AMT
                  , SCAN_USE_AMT
                   )
            VALUES (       
                    MYREC.COMP_CD
                  , MYREC.CRG_YM
                  , NVL(nPRE_END_AMT, 0)
                  , MYREC.CRG_POS_AMT
                  , MYREC.CRG_WEB_AMT
                  , MYREC.CRG_ADJ_AMT
                  , MYREC.CRG_TOT_AMT
                  , MYREC.USE_USE_AMT
                  , nPRE_END_AMT + MYREC.CRG_USE_AMT
                  , '1'
                  , MYREC.CRG_HOM_AMT
                  , MYREC.CRG_MOB_AMT
                  , MYREC.SWAP_USE_AMT
                  , MYREC.SCAN_USE_AMT
                   );
        
        /* 기말재고를 이월 기초재고로 전달 */            
        nPRE_END_AMT := nPRE_END_AMT + MYREC.CRG_USE_AMT;
    END LOOP;
    
   PR_RTN_CD  := '0';
   PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_LANG_CD, '1001000416');
   
   COMMIT;
   
   RETURN;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        PR_RTN_CD  := TO_CHAR(SQLCODE);
        PR_RTN_MSG := SQLERRM;
        
        RETURN;
END;

/
