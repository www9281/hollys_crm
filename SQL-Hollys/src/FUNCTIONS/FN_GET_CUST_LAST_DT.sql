--------------------------------------------------------
--  DDL for Function FN_GET_CUST_LAST_DT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_CUST_LAST_DT" 
   (
    PSV_COMP_CD IN VARCHAR2,
    PSV_CUST_ID IN VARCHAR2
   ) RETURN VARCHAR2 IS
/******************************************************************************
   NAME:       FN_GET_CUST_LAST_DT
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2016-05-18   XPMUser       1. Created this function.
******************************************************************************/
    vLAST_USE_DT    VARCHAR2(8) := NULL;
BEGIN
    BEGIN
        SELECT  MAX(NVL(V01.LAST_DT, CST.JOIN_DT)) INTO vLAST_USE_DT
        FROM    C_CUST CST
              ,(
                SELECT  CRD.COMP_CD
                      , CRD.CUST_ID
                      , MAX(HIS.CRG_DT) AS LAST_DT
                FROM    C_CARD_CHARGE_HIS HIS
                      , C_CARD            CRD
                WHERE   CRD.COMP_CD   = HIS.COMP_CD
                AND     CRD.CARD_ID   = HIS.CARD_ID
                AND     CRD.COMP_CD   = PSV_COMP_CD
                AND     CRD.CUST_ID   = PSV_CUST_ID
                AND     HIS.USE_YN    = 'Y'
                GROUP BY
                        CRD.COMP_CD
                      , CRD.CUST_ID
                UNION ALL
                SELECT  CRD.COMP_CD
                      , CRD.CUST_ID
                      , MAX(HIS.USE_DT) AS LAST_DT
                FROM    C_CARD_SAV_HIS    HIS
                      , C_CARD            CRD
                WHERE   CRD.COMP_CD   = HIS.COMP_CD
                AND     CRD.CARD_ID   = HIS.CARD_ID
                AND     CRD.COMP_CD   = PSV_COMP_CD
                AND     CRD.CUST_ID   = PSV_CUST_ID
                AND     HIS.USE_YN    = 'Y'
                GROUP BY
                        CRD.COMP_CD
                      , CRD.CUST_ID
                UNION ALL
                SELECT  CRD.COMP_CD
                      , CRD.CUST_ID
                      , MAX(HIS.USE_DT) AS LAST_DT
                FROM    C_CARD_USE_HIS    HIS
                      , C_CARD            CRD
                WHERE   CRD.COMP_CD   = HIS.COMP_CD
                AND     CRD.CARD_ID   = HIS.CARD_ID
                AND     CRD.COMP_CD   = PSV_COMP_CD
                AND     CRD.CUST_ID   = PSV_CUST_ID
                AND     HIS.USE_YN    = 'Y'
                GROUP BY
                        CRD.COMP_CD
                      , CRD.CUST_ID
                UNION ALL
                SELECT  CCC.COMP_CD
                      , CCC.CUST_ID
                      , MAX(CCC.USE_DT) AS LAST_DT
                FROM    C_COUPON_CUST     CCC
                WHERE   CCC.COMP_CD   = PSV_COMP_CD
                AND     CCC.CUST_ID   = PSV_CUST_ID
                AND     CCC.USE_STAT != '32'
                GROUP BY
                        CCC.COMP_CD
                      , CCC.CUST_ID
               ) V01
        WHERE   CST.COMP_CD = V01.COMP_CD
        AND     CST.CUST_ID = V01.CUST_ID
        AND     CST.COMP_CD = PSV_COMP_CD
        AND     CST.CUST_ID = PSV_CUST_ID;
    EXCEPTION 
        WHEN OTHERS THEN
            vLAST_USE_DT := '';
    END;

    -- 휴면 예정일
    IF vLAST_USE_DT IS NULL THEN 
        vLAST_USE_DT := TO_CHAR(SYSDATE + 1, 'YYYYMMDD');
    ELSE
        IF vLAST_USE_DT < TO_CHAR(SYSDATE - 365, 'YYYYMMDD') THEN
            vLAST_USE_DT := TO_CHAR(SYSDATE + 1, 'YYYYMMDD');
        ELSE
            vLAST_USE_DT := TO_CHAR(TO_DATE(vLAST_USE_DT, 'YYYYMMDD') + 365, 'YYYYMMDD');
        END IF;
    END IF;

    RETURN vLAST_USE_DT;
END FN_GET_CUST_LAST_DT;

/
