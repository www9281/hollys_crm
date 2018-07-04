--------------------------------------------------------
--  DDL for Function FN_MLG_TO_PNT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_MLG_TO_PNT" (
                                          PSV_COMP_CD     IN VARCHAR2 -- 회사코드
                                         )
RETURN TBL_MLG_TO_PNT AS
    /****************************************************************/
    /*      ITEM_CHAIN_STD(메뉴표준/실단가) 기준 레시피 정보  취득  */
    /*      레시피 원자재 기준 DATA(원자재 -> 반재품 -> 상품 순)    */
    /****************************************************************/
    CURSOR CUR_1 IS
        WITH    W1
        AS (
            SELECT  CCH.COMP_CD
                  , CCH.CARD_ID
                  , CCH.CRG_DT
                  , CCH.CRG_SEQ
                  , CCH.CRG_FG
                  , CCH.CRG_AMT
                  , CRD.CUST_ID
                  , ROW_NUMBER() OVER(PARTITION BY CCH.COMP_CD, CRD.CUST_ID ORDER BY CCH.CARD_ID) R_NUM
            FROM    PCRM.C_CARD_CHARGE_HIS   CCH
                  , PCRM.C_CARD              CRD
            WHERE   CCH.COMP_CD     = CRD.COMP_CD
            AND     CCH.CARD_ID     = CRD.CARD_ID
            AND     CCH.COMP_CD     = PSV_COMP_CD
            AND     CCH.CRG_FG      = '6'   -- 매일DO 통합회원 이전
            AND     CCH.SAP_IF_YN   = 'Y'
            AND     CCH.CRG_SCOPE  IN ('1', '3')
            AND     CCH.CRG_DT      < TO_CHAR(SYSDATE, 'YYYYMMDD')
           )
            SELECT  V01.COMP_CD
                  , V01.CARD_ID
                  , V01.CRG_DT
                  , V01.CRG_SEQ
                  , V01.CRG_FG
                  , V01.CRG_AMT
                  , NVL(V02.EFF_MLG, 0) + NVL(V03.CNV_MLG, 0) AS EFF_MLG
                  , V01.CUST_ID
            FROM    W1  V01
                  ,(
                    SELECT  W01.COMP_CD
                          , W01.CARD_ID
                          , SUM(CSU.SAV_MLG - CSU.USE_MLG - CSU.LOS_MLG_UNUSE) AS EFF_MLG
                    FROM    W1   W01
                          , PCRM.C_CARD_SAV_USE_HIS  CSU
                    WHERE   W01.COMP_CD    = CSU.COMP_CD
                    AND     W01.CARD_ID    = CSU.CARD_ID
                    AND     CSU.LOS_MLG_YN = 'N' 
                    AND     CSU.MEMB_DIV   = '0'
                    GROUP BY
                            W01.COMP_CD
                          , W01.CARD_ID
                   ) V02
                  ,(
                    SELECT  W01.COMP_CD
                          , W01.CARD_ID
                          , NVL(SUM(CASE WHEN USE_FG = '1' THEN PNT.USE_MLG ELSE PNT.USE_MLG * (-1) END), 0) AS CNV_MLG
                    FROM    W1   W01
                          , PCRM.C_CARD_SAV_USE_PNT  PNT
                    WHERE   W01.COMP_CD = PNT.COMP_CD
                    AND     W01.CUST_ID = PNT.CUST_ID
                    AND     W01.CRG_DT  = PNT.USE_DT
                    AND     W01.R_NUM   = 1
                    AND     PNT.USE_YN  = 'Y'
                    GROUP BY
                            W01.COMP_CD
                          , W01.CARD_ID
                   ) V03
            WHERE   V01.COMP_CD = V02.COMP_CD(+)
            AND     V01.CARD_ID = V02.CARD_ID(+)
            AND     V01.COMP_CD = V03.COMP_CD(+)
            AND     V01.CARD_ID = V03.CARD_ID(+);

    RCP_RESULT_S        TBL_MLG_TO_PNT := TBL_MLG_TO_PNT();   -- SINGLE RECORD
    RCP_RESULT_M        TBL_MLG_TO_PNT := TBL_MLG_TO_PNT();   -- MULTI RECORD
BEGIN
    FOR MYREC IN CUR_1 LOOP
        /* 리턴 자료 생성 */
        SELECT  OT_MLG_TO_PNT
               (
                COMP_CD
              , CARD_ID
              , CRG_DT
              , CRG_SEQ
              , CRG_FG
              , CRG_AMT
              , CUST_ID
              , EFF_MLG
               )
        BULK COLLECT INTO RCP_RESULT_S
        FROM   (       
                SELECT  MYREC.COMP_CD
                      , MYREC.CARD_ID
                      , MYREC.CRG_DT
                      , MYREC.CRG_SEQ
                      , MYREC.CRG_FG
                      , MYREC.CRG_AMT
                      , MYREC.CUST_ID
                      , MYREC.EFF_MLG
                FROM    DUAL
               );
            
        RCP_RESULT_M.EXTEND;
        RCP_RESULT_M(RCP_RESULT_M.LAST) := RCP_RESULT_S(RCP_RESULT_S.LAST);
END LOOP;

    RETURN RCP_RESULT_M;
EXCEPTION
    WHEN OTHERS THEN
        --PSV_ERR_MSG := SQLERRM;
        
        RETURN RCP_RESULT_M; 
END FN_MLG_TO_PNT;

/
