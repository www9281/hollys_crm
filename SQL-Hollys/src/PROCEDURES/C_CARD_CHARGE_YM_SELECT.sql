--------------------------------------------------------
--  DDL for Procedure C_CARD_CHARGE_YM_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_CHARGE_YM_SELECT" (
        P_COMP_CD      IN   VARCHAR2,
        P_SEARCH_YM    IN   VARCHAR2,
        O_CURSOR       OUT  SYS_REFCURSOR
) AS 
BEGIN   
        OPEN     O_CURSOR  FOR
        SELECT   COMP_CD
              ,  '00'                                    AS SORT_SEQ
              ,  FC_GET_WORDPACK('', 'KOR', 'BRING_FORWARD') AS CRG_YM
              ,  NULL                                    AS BEGIN_AMT
              ,  NULL                                    AS CRG_POS_AMT
              ,  NULL                                    AS CRG_POS_RATE
              ,  NULL                                    AS CRG_MOB_AMT
              ,  NULL                                    AS CRG_MOB_RATE
              ,  NULL                                    AS CRG_HOM_AMT
              ,  NULL                                    AS CRG_HOM_RATE
              ,  NULL                                    AS CRG_ADJ_AMT
              ,  NULL                                    AS CRG_ADJ_RATE
              ,  NULL                                    AS CRG_TOT_AMT
              ,  NULL                                    AS SWAP_USE_AMT
              ,  NULL                                    AS SWAP_USE_RATE
              ,  NULL                                    AS SCAN_USE_AMT
              ,  NULL                                    AS SCAN_USE_RATE
              ,  NULL                                    AS USE_USE_AMT
              ,  END_AMT                                 AS CRG_USE_AMT
              ,  NULL                                    AS CRG_USE_RATE
        FROM     C_CARD_CHARGE_YM
        --WHERE   COMP_CD    = ${SCH_COMP_CD}
        WHERE    COMP_CD    = P_COMP_CD
        --AND     CRG_YM     = TO_CHAR(ADD_MONTHS(TO_DATE(${SCH_CRG_YM}||'01', 'YYYYMM'), -1), 'YYYYMM')
        AND      CRG_YM     = TO_CHAR(ADD_MONTHS(TO_DATE(P_SEARCH_YM ||'01', 'YYYYMM'), -1), 'YYYYMM')
        UNION ALL 
        SELECT   COMP_CD
              ,  TO_CHAR(TO_DATE(CRG_YM, 'YYYYMM'), 'MM')    AS SORT_SEQ
              ,  TO_CHAR(TO_DATE(CRG_YM, 'YYYYMM'), 'MONTH') AS CRG_YM
              ,  BEGIN_AMT                               AS BEGIN_AMT
              ,  POS_AMT                                 AS CRG_POS_AMT
              ,  CASE WHEN CRG_AMT = 0 THEN 0 ELSE POS_AMT / CRG_AMT * 100 END AS CRG_POS_RATE
              ,  MOB_AMT                                 AS CRG_MOB_AMT
              ,  CASE WHEN CRG_AMT = 0 THEN 0 ELSE MOB_AMT / CRG_AMT * 100 END AS CRG_MOB_RATE
              ,  HOM_AMT                                 AS CRG_HOM_AMT
              ,  CASE WHEN CRG_AMT = 0 THEN 0 ELSE HOM_AMT / CRG_AMT * 100 END AS CRG_HOM_RATE
              ,  ADJ_AMT                                 AS CRG_ADJ_AMT
              ,  CASE WHEN CRG_AMT = 0 THEN 0 ELSE ADJ_AMT / CRG_AMT * 100 END AS CRG_ADJ_RATE
              ,  CRG_AMT                                 AS CRG_TOT_AMT
              ,  SWAP_USE_AMT                            AS SWAP_USE_AMT
              ,  CASE WHEN USE_AMT = 0 THEN 0 ELSE SWAP_USE_AMT / USE_AMT * 100 END AS SWAP_USE_RATE
              ,  SCAN_USE_AMT                            AS SCAN_USE_AMT
              ,  CASE WHEN USE_AMT = 0 THEN 0 ELSE SCAN_USE_AMT / USE_AMT * 100 END AS SCAN_USE_RATE
              ,  USE_AMT                                 AS USE_AMT
              ,  END_AMT                                 AS CRG_USE_AMT
              ,  CASE WHEN CRG_AMT = 0 THEN 0 ELSE USE_AMT / CRG_AMT * 100 END AS CRG_USE_RATE
        FROM     C_CARD_CHARGE_YM
        WHERE    COMP_CD    = P_COMP_CD
        AND      CRG_YM  LIKE P_SEARCH_YM ||'%'
        ORDER BY  
                 1, 2;
END C_CARD_CHARGE_YM_SELECT;

/
