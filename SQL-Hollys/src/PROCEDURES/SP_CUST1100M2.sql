--------------------------------------------------------
--  DDL for Procedure SP_CUST1100M2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CUST1100M2" (
    PSV_COMP_CD     IN VARCHAR2,
    PSV_LANG_CD     IN VARCHAR2,
    PSV_CUST_ID     IN VARCHAR2,
    PR_RTN_CD       OUT VARCHAR2,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   )
IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_C_CUST_CARD_STAT
--  Description      : 쿠폰 선물하기 내역 삭제
--  Ref. Table       :
--------------------------------------------------------------------------------
--  Create Date      : 2015-04-16 엠즈씨드 CRM PJT
--  Modify Date      : 2015-04-16
--------------------------------------------------------------------------------
    CURSOR CUR_1 IS
        SELECT  CST.CUST_ID
              , decrypt(CST.CUST_NM) AS CUST_NM
              , CST.CUST_STAT
              , GET_COMMON_CODE_NM('01720', CST.CUST_STAT, PSV_LANG_CD) AS CUST_STAT_NM
              , CST.LVL_CD
              , LVL.LVL_NM
              , NVL(MLG.ACC_CROWN  , 0) AS ACC_CROWN
              , NVL(MLG.VALID_CROWN, 0) AS VALID_CROWN
              , NVL(CPN.VALID_CPN  , 0) AS VALID_CPN
              , CASE WHEN CST.CUST_STAT IN ('3', '9') AND NVL(CCH.RTN_POSS_YN, 'N') = 'Y' THEN 'Y'   ELSE 'N'  END AS RTN_POSS_YN
              , CASE WHEN CST.CUST_STAT IN ('3', '9') AND NVL(CCH.RTN_POSS_YN, 'N') = 'Y' THEN 'YES' ELSE 'NO' END AS RTN_POSS_YN_NM
        FROM    C_CUST        CST
              , C_CUST_LVL    LVL
              ,(
                SELECT  COMP_CD
                      , CUST_ID
                      , COUNT(*) VALID_CPN
                FROM    C_COUPON_CUST
                WHERE   COMP_CD = PSV_COMP_CD
                AND     CUST_ID = PSV_CUST_ID
                AND     USE_STAT IN ('01','11','34')
                AND     TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN CERT_FDT AND CERT_TDT
                GROUP BY
                        COMP_CD
                      , CUST_ID
               ) CPN
              ,(
                SELECT  CRD.COMP_CD
                      , CRD.CUST_ID
                      , SUM(HIS.SAV_MLG) AS ACC_CROWN
                      , SUM(HIS.SAV_MLG - HIS.USE_MLG) AS VALID_CROWN
                FROM    C_CARD_SAV_USE_HIS HIS
                      , C_CARD             CRD
                WHERE   CRD.COMP_CD = HIS.COMP_CD
                AND     CRD.CARD_ID = HIS.CARD_ID
                AND     CRD.COMP_CD = PSV_COMP_CD
                AND     CRD.CUST_ID = PSV_CUST_ID
                AND     TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN HIS.USE_DT AND TO_CHAR(TO_DATE(HIS.USE_DT, 'YYYYMMDD') + 364, 'YYYYMMDD')
                GROUP BY
                        CRD.COMP_CD
                      , CRD.CUST_ID
               ) MLG
              ,(
                SELECT  COMP_CD
                      , CUST_ID
                      , MAX(CASE WHEN CHG_FR = '2' AND CHG_TO = '3' THEN 'Y' ELSE 'N' END) RTN_POSS_YN
                FROM    C_CUST_HIS
                WHERE   COMP_CD = PSV_COMP_CD
                AND     CUST_ID = PSV_CUST_ID
                AND     CHG_DIV = '13'
                GROUP BY
                        COMP_CD
                      , CUST_ID
               ) CCH
        WHERE   CST.COMP_CD = LVL.COMP_CD
        AND     CST.LVL_CD  = LVL.LVL_CD
        AND     CST.COMP_CD = CPN.COMP_CD  (+)
        AND     CST.CUST_ID = CPN.CUST_ID  (+)
        AND     CST.COMP_CD = MLG.COMP_CD  (+)
        AND     CST.CUST_ID = MLG.CUST_ID  (+)
        AND     CST.COMP_CD = CCH.COMP_CD  (+)
        AND     CST.CUST_ID = CCH.CUST_ID  (+)
        AND     CST.COMP_CD = PSV_COMP_CD
        AND     CST.CUST_ID = PSV_CUST_ID;
    
    CURSOR CUR_2 IS
        SELECT  COMP_CD
              , CARD_ID
        FROM    C_CARD
        WHERE   COMP_CD = PSV_COMP_CD
        AND     CUST_ID = PSV_CUST_ID;
    
    vRTN_POSS_YN    VARCHAR2(1) := 'N';
    nREC_CNT        NUMBER         := 0;
BEGIN
    FOR MYREC1 IN CUR_1 LOOP
        vRTN_POSS_YN := MYREC1.RTN_POSS_YN;
        
        IF vRTN_POSS_YN = 'Y' THEN
            UPDATE  C_CUST
            SET     CUST_STAT   = '2'
                  , UNFY_MMB_NO = NULL
            WHERE   COMP_CD     = PSV_COMP_CD
            AND     CUST_ID     = PSV_CUST_ID;
                
            UPDATE  C_CARD
            SET     CARD_STAT   = CASE WHEN CARD_STAT = '91' THEN '10' ELSE CARD_STAT END
                  , MEMB_DIV    = '0'
            WHERE   COMP_CD     = PSV_COMP_CD
            AND     CUST_ID     = PSV_CUST_ID;
            
            UPDATE  C_COUPON_CUST
            SET     USE_STAT    = CASE WHEN USE_STAT = '34' THEN '01' ELSE USE_STAT END
                  , MEMB_DIV    = '0'
                  , USE_YN      = 'Y'
            WHERE   COMP_CD     = PSV_COMP_CD
            AND     CUST_ID     = PSV_CUST_ID;
        END IF;
    END LOOP;
    
    FOR MYREC2 IN CUR_2 LOOP
        IF vRTN_POSS_YN = 'Y' THEN
            UPDATE  C_CARD_SAV_HIS
            SET     LOS_MLG     = 0
                  , LOS_MLG_YN  = 'N'
                  , LOS_MLG_DT  = TO_CHAR(TO_DATE(USE_DT, 'YYYYMMDD') + 364, 'YYYYMMDD')
                  , MEMB_DIV    = '0'
            WHERE   COMP_CD     = MYREC2.COMP_CD
            AND     CARD_ID     = MYREC2.CARD_ID
            AND     TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN USE_DT AND TO_CHAR(TO_DATE(USE_DT, 'YYYYMMDD') + 364, 'YYYYMMDD');
        END IF;
    END LOOP;
    
    COMMIT;
   
    PR_RTN_CD  := '0';
    PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_LANG_CD, '1001000416');
   
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        PR_RTN_CD  := TO_CHAR(SQLCODE);
        PR_RTN_MSG := SQLERRM;
        
        RETURN;
END;

/
