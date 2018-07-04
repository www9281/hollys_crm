--------------------------------------------------------
--  DDL for Procedure SP_ORDR4550
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ORDR4550" 
---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_ORDR4550           [ORDR4550L0.jsp]
--  Description      : 주문현황 [점포별 현황]
--                      점포별 주문,미출,선출집계, 차수에 따른 주문에 해당한 내용을 조회한다.
--
---------------------------------------------------------------------------------------------------
--  Create Date      : 2010-01-18
--  Create Programer : 최창록
--  Modify Date      : 2010-03-02
--  Modify Programer :
---------------------------------------------------------------------------------------------------
 ( 
   p_comp_cd     IN      VARCHAR2,            -- Company Code
   p_brand_cd    IN      VARCHAR2,            -- 사용자 ID
   p_language    IN      VARCHAR2,            -- 언어
   p_cursor        OUT     rec_set.m_refcur   -- Result Set


 ) IS

BEGIN

   OPEN p_cursor FOR
SELECT   STOR_CD
            ,  STOR_NM
            ,  SUM(ORD_QTY) AS ORD_QTY
            ,  SUM(ORD_AMT) AS ORD_AMT
            ,  SUM(ORD_CQTY) AS ORD_CQTY
            ,  SUM(ORD_CAMT) AS ORD_CAMT
            ,  SUM(DPLN_ORD_QTY) AS DPLN_ORD_QTY
            ,  SUM(DPLN_ORD_AMT) AS DPLN_ORD_AMT
            ,  SUM(DPLN_ORD_CQTY) AS DPLN_ORD_CQTY
            ,  SUM(DPLN_ORD_CAMT) AS DPLN_ORD_CAMT
            ,  SUM(ELTN_ORD_QTY) AS ELTN_ORD_QTY
            ,  SUM(ELTN_ORD_AMT) AS ELTN_ORD_AMT
            ,  SUM(ELTN_ORD_CQTY) AS ELTN_ORD_CQTY
            ,  SUM(ELTN_ORD_CAMT) AS ELTN_ORD_CAMT
            ,  MAX(ORD_QTY_1) AS ORD_QTY_1
            ,  MAX(ORD_AMT_1) AS ORD_AMT_1
            ,  MAX(ORD_CQTY_1) AS ORD_CQTY_1
            ,  MAX(ORD_CAMT_1) AS ORD_CAMT_1
            ,  MAX(ORD_QTY_2) AS ORD_QTY_2
            ,  MAX(ORD_AMT_2) AS ORD_AMT_2
            ,  MAX(ORD_CQTY_2) AS ORD_CQTY_2
            ,  MAX(ORD_CAMT_2) AS ORD_CAMT_2
        FROM   (
              SELECT   STOR_CD
                    ,  STOR_NM
                    ,  ORD_SEQ
                    ,  SUM(ORD_QTY) ORD_QTY
                    ,  SUM(ORD_AMT) ORD_AMT
                    ,  SUM(ORD_CQTY) ORD_CQTY
                    ,  SUM(ORD_CAMT) ORD_CAMT
                    ,  SUM(DPLN_ORD_QTY) DPLN_ORD_QTY
                    ,  SUM(DPLN_ORD_AMT) DPLN_ORD_AMT
                    ,  SUM(DPLN_ORD_CQTY) DPLN_ORD_CQTY
                    ,  SUM(DPLN_ORD_CAMT) DPLN_ORD_CAMT
                    ,  SUM(ELTN_ORD_QTY) ELTN_ORD_QTY
                    ,  SUM(ELTN_ORD_AMT) ELTN_ORD_AMT
                    ,  SUM(ELTN_ORD_CQTY) ELTN_ORD_CQTY
                    ,  SUM(ELTN_ORD_CAMT) ELTN_ORD_CAMT
                    ,  SUM(CASE WHEN (OH_STOR_CD = STOR_CD) and (ORD_SEQ = '1') THEN ORD_QTY  ELSE TO_NUMBER('0') END) AS ORD_QTY_1
                    ,  SUM(CASE WHEN (OH_STOR_CD = STOR_CD) and (ORD_SEQ = '1') THEN ORD_AMT  ELSE TO_NUMBER('0') END) AS ORD_AMT_1
                    ,  SUM(CASE WHEN (OH_STOR_CD = STOR_CD) and (ORD_SEQ = '1') THEN ORD_CQTY ELSE TO_NUMBER('0') END) AS ORD_CQTY_1
                    ,  SUM(CASE WHEN (OH_STOR_CD = STOR_CD) and (ORD_SEQ = '1') THEN ORD_CAMT ELSE TO_NUMBER('0') END) AS ORD_CAMT_1
                    ,  SUM(CASE WHEN (OH_STOR_CD = STOR_CD) and (ORD_SEQ = '2') THEN ORD_QTY  ELSE TO_NUMBER('0') END) AS ORD_QTY_2
                    ,  SUM(CASE WHEN (OH_STOR_CD = STOR_CD) and (ORD_SEQ = '2') THEN ORD_AMT  ELSE TO_NUMBER('0') END) AS ORD_AMT_2
                    ,  SUM(CASE WHEN (OH_STOR_CD = STOR_CD) and (ORD_SEQ = '2') THEN ORD_CQTY ELSE TO_NUMBER('0') END) AS ORD_CQTY_2
                    ,  SUM(CASE WHEN (OH_STOR_CD = STOR_CD) and (ORD_SEQ = '2') THEN ORD_CAMT ELSE TO_NUMBER('0') END) AS ORD_CAMT_2
                FROM   (
                    SELECT   OH.STOR_CD AS OH_STOR_CD
                          ,  OD.STOR_CD
                          ,  S.STOR_NM
                          ,  OD.ORD_SEQ
                          ,  OD.ORD_QTY
                          ,  OD.ORD_AMT
                          ,  OD.ORD_CQTY
                          ,  OD.ORD_CAMT
                          ,  I1.DLV_UNIT_QTY  AS DPLN_ORD_QTY
                          ,  I1.DLV_AMT  AS DPLN_ORD_AMT
                          ,  I1.UNDLV_CQTY AS DPLN_ORD_CQTY
                          ,  I1.DLV_CAMT AS DPLN_ORD_CAMT
                          ,  I2.DLV_UNIT_QTY  AS ELTN_ORD_QTY
                          ,  I2.DLV_AMT  AS ELTN_ORD_AMT
                          ,  I2.MISDLV_CQTY AS ELTN_ORD_CQTY
                          ,  I2.DLV_CAMT AS ELTN_ORD_CAMT
                      FROM   ORDER_HD OH
                          ,  ORDER_DT OD
                          ,  (SELECT * 
                                FROM INSPECT 
                               WHERE DLV_REASON_CD  = '1' 
                                 AND COMP_CD        = p_comp_cd
                                 AND BRAND_CD       = p_brand_cd ) I1
                          ,  (SELECT * 
                                FROM INSPECT 
                               WHERE DLV_REASON_CD  = '2' 
                                 AND COMP_CD        = p_comp_cd
                                 AND BRAND_CD       = p_brand_cd ) I2
                          ,  (SELECT  S.COMP_CD
                                   ,  S.STOR_CD
                                   ,  NVL(LS.STOR_NM, S.STOR_NM) STOR_NM
                                FROM  STORE S                               
                                   ,  (SELECT  COMP_CD
                                            ,  STOR_CD
                                            ,  STOR_NM
                                         FROM  LANG_STORE
                                        WHERE  COMP_CD     = p_comp_cd
                                          AND  BRAND_CD    = p_brand_cd
                                          AND  LANGUAGE_TP = DECODE(p_language, NULL, ' ', p_language )
                                          AND  USE_YN      = 'Y'
                                      ) LS
                               WHERE  S.COMP_CD  = p_comp_cd
                                 AND  S.BRAND_CD = p_brand_cd
                                 AND  S.COMP_CD  = LS.COMP_CD(+)
                                 AND  S.STOR_CD  = LS.STOR_CD(+)
                                 AND  S.USE_YN   = 'Y'
                             ) S
                     WHERE   OH.COMP_CD  = p_comp_cd
                      AND    OH.BRAND_CD = p_brand_cd
                      AND    OH.COMP_CD  = OD.COMP_CD
                      AND    OH.BRAND_CD = OD.BRAND_CD
                      AND    OH.STOR_CD  = OD.STOR_CD
                      AND    OH.SHIP_DT  = OD.SHIP_DT
                      AND    OH.ORD_SEQ  = OD.ORD_SEQ
                      AND    OH.ORD_FG   = OD.ORD_FG
                      AND    OD.COMP_CD  = I1.COMP_CD(+)
                      AND    OD.STOR_CD  = I1.STOR_CD(+)
                      AND    OD.SHIP_DT  = I1.SHIP_DT(+)
                      AND    OD.ORD_SEQ  = I1.ORD_SEQ(+)
                      AND    OD.ORD_FG   = I1.ORD_FG(+)
                      AND    OD.ITEM_CD  = I1.ITEM_CD(+)
                      AND    OD.COMP_CD  = I2.COMP_CD(+)
                      AND    OD.BRAND_CD = I2.BRAND_CD(+)
                      AND    OD.STOR_CD  = I2.STOR_CD(+)
                      AND    OD.SHIP_DT  = I2.SHIP_DT(+)
                      AND    OD.ORD_SEQ  = I2.ORD_SEQ(+)
                      AND    OD.ORD_FG   = I2.ORD_FG(+)
                      AND    OD.ITEM_CD  = I2.ITEM_CD(+)
                      AND    OH.STOR_CD  = S.STOR_CD(+)
                    ) ORDR
              GROUP BY STOR_CD, STOR_NM, ORD_SEQ
            )
      GROUP BY STOR_CD, STOR_NM
      ORDER BY STOR_CD DESC;

END  SP_ORDR4550;

/
