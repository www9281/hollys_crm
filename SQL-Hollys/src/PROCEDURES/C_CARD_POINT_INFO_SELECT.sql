--------------------------------------------------------
--  DDL for Procedure C_CARD_POINT_INFO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_POINT_INFO_SELECT" (
        --N_BRAND_CD  IN    VARCHAR2,
        N_STOR_CD   IN    VARCHAR2,
        N_CARD_ID   IN    VARCHAR2,
        N_USE_YN    IN    VARCHAR2,
        N_CARD_STAT IN    VARCHAR2,
        P_LANG_TP   IN    VARCHAR2,
        O_CURSOR    OUT   SYS_REFCURSOR
) AS 
BEGIN   
        OPEN    O_CURSOR  FOR
        SELECT  CRD.COMP_CD
              , decrypt(CRD.CARD_ID)    AS CARD_ID
              , CST.CUST_ID
              , decrypt(CST.CUST_NM)    AS CUST_NM
              , FN_GET_FORMAT_HP_NO(REPLACE(decrypt(CST.MOBILE), '-', '')) AS MOBILE
              , CRD.ISSUE_STOR_CD
              , STO.STOR_NM
              , SUBSTR(CRD.ISSUE_DT, 1, 8) AS ISSUE_DT
              , CRD.CARD_STAT
              --, GET_COMMON_CODE_NM('01725', CRD.CARD_STAT, ${SCH_LANGUAGE}) AS CARD_STAT_NM
              , GET_COMMON_CODE_NM('01725', CRD.CARD_STAT, P_LANG_TP) AS CARD_STAT_NM
              , TO_CHAR(CRD.UPD_DT, 'YYYYMMDD') AS UPD_DT
              , CRD.SAV_PT
              , CRD.USE_PT
              , CRD.LOS_PT
              , CRD.SAV_PT - CRD.USE_PT - CRD.LOS_PT AS VAL_PT
        FROM    C_CARD  CRD
              , C_CUST  CST
              , STORE   STO
        WHERE   CRD.ISSUE_BRAND_CD= STO.BRAND_CD(+)
        AND     CRD.ISSUE_STOR_CD = STO.STOR_CD (+)
        AND     CRD.COMP_CD       = CST.COMP_CD (+)
        AND     CRD.CUST_ID       = CST.CUST_ID (+)
        --AND     CRD.COMP_CD       = ${SCH_COMP_CD}
        --AND     CRD.ISSUE_STOR_CD = NVL(${SCH_STOR_CD}   , CRD.ISSUE_STOR_CD  )
        --AND     CRD.CARD_ID       = NVL(encrypt(${SCH_CARD_ID}), CRD.CARD_ID  )
        --AND     CRD.CARD_STAT     = NVL(${SCH_CARD_STAT} , CRD.CARD_STAT      )
        --AND     CRD.USE_YN        = DECODE(${SCH_USE_YN}, 'Y', 'Y', CRD.USE_YN)
        AND     CRD.COMP_CD       = '016'
        AND     CRD.ISSUE_STOR_CD = NVL(N_STOR_CD   , CRD.ISSUE_STOR_CD  )
        AND     CRD.CARD_ID       = NVL(ENCRYPT(N_CARD_ID), CRD.CARD_ID  )
        AND     CRD.CARD_STAT     = NVL(N_CARD_STAT , CRD.CARD_STAT      )
        AND     CRD.USE_YN        = DECODE(N_USE_YN, 'Y', 'Y', CRD.USE_YN)
        ORDER BY 
                CRD.CARD_ID;
END C_CARD_POINT_INFO_SELECT;

/
