--------------------------------------------------------
--  DDL for Procedure C_CARD_SAV_HIS_POINT_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_SAV_HIS_POINT_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CUST_ID      IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_SAV_USE_FG   IN  VARCHAR2,
    N_START_DT     IN  VARCHAR2,
    N_END_DT       IN  VARCHAR2,
    N_USER_ID      IN  VARCHAR2,
    N_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
      v_query_back varchar2(20000); -- POINT_LOG 유지
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [포인트적립이력 조회] 정보 조회
    -- Test          :   C_CUST_SELECT_ONE ('000', 'level_10', '', '', '', 'level_10' 'KOR')
    -- ==========================================================================================
    v_query := 
                'SELECT A.* FROM (
                  SELECT  
                     V02.CARD_ID
                     ,  V02.USE_DT
                     ,  V02.STOR_CD
                     ,  CASE WHEN V02.BILL_NO IS NULL THEN FC_GET_WORDPACK(''' || N_LANGUAGE_TP || ''', ''ADMIN_YN'')||'' ''||FC_GET_WORDPACK(''' || N_LANGUAGE_TP || ''', ''SUB_TOUCH_08'')
                        ELSE V02.STOR_NM
                        END  AS STOR_NM
                     ,  V02.POS_NO
                     ,  V02.BILL_NO
                     ,  V02.ITEM_CD
                     , (
                        SELECT  ITEM_NM
                        FROM    ITEM ITM
                        WHERE   ITM.BRAND_CD = V02.BRAND_CD
                        AND     ITM.ITEM_CD  = V02.ITEM_CD
                       ) ITEM_NM
                     ,  V02.SALE_QTY
                     ,  V02.GRD_AMT
                     ,  V02.SAV_USE_DIV
                     ,  V02.REMARKS
                     ,  V02.LOS_PT_DT
                     ,  GET_COMMON_CODE_NM(''12220'', V02.SAV_USE_DIV, ''' || N_LANGUAGE_TP || ''') AS SAV_USE_DIV_NM         
                     ,  V02.SAV_PT AS SAV_PT
                     ,  V02.USE_PT AS USE_PT
                     ,  V02.LOS_PT AS LOS_PT
                     ,  V02.INST_DT
                FROM   (
                        SELECT  decrypt(V01.CARD_ID) AS CARD_ID
                             ,  V01.USE_DT
                             ,  SDT.BRAND_CD
                             ,  V01.STOR_CD
                             ,  V01.STOR_NM
                             ,  V01.POS_NO
                             ,  V01.BILL_NO
                             ,  SDT.SEQ
                             ,  SDT.ITEM_CD
                             ,  SDT.SALE_QTY
                             ,  SDT.GRD_AMT
                             ,  V01.SAV_USE_DIV
                             ,  V01.REMARKS
                             ,  V01.SAV_PT
                             ,  V01.USE_PT
                             ,  V01.LOS_PT
                             ,  V01.LOS_PT_DT
                             ,  V01.INST_DT
                             --,  ROW_NUMBER() OVER(PARTITION BY V01.CARD_ID,  V01.USE_DT, V01.STOR_CD, V01.POS_NO, V01.BILL_NO ORDER BY SDT.SEQ) R_NUM
                        FROM    SALE_DT           SDT
                             , (
                                SELECT  CSH.COMP_CD
                                      , CSH.BRAND_CD
                                      , CSH.STOR_CD
                                      , STO.STOR_NM
                                      , CSH.POS_NO
                                      , CSH.BILL_NO
                                      , CSH.CARD_ID
                                      , CSH.USE_DT
                                      , CSH.SAV_USE_DIV AS SAV_USE_DIV
                                      , CSH.REMARKS AS REMARKS
                                      , CSH.SAV_PT AS SAV_PT
                                      , CSH.USE_PT AS USE_PT
                                      , CSH.LOS_PT AS LOS_PT
                                      , CSH.LOS_PT_DT AS LOS_PT_DT
                                      , CSH.INST_DT
                                FROM    C_CARD_SAV_HIS    CSH
                                      , STORE             STO
                                WHERE   CSH.BRAND_CD = STO.BRAND_CD(+)
                                AND     CSH.STOR_CD  = STO.STOR_CD (+)
                                AND     CSH.COMP_CD  = ''' || P_COMP_CD || '''
                                AND     (''' || N_STOR_CD || ''' IS NULL OR CSH.STOR_CD = ''' || N_STOR_CD || ''')
                                AND     CSH.SAV_USE_FG = ''4''
                                AND     CSH.CARD_ID IN (
                                                         SELECT card.CARD_ID
                                                           FROM C_CUST cust, C_CARD card
                                                          WHERE cust.COMP_CD = ''' || P_COMP_CD || '''
                                                            AND cust.CUST_ID = ''' || P_CUST_ID || '''
                                                            AND cust.CUST_ID = card.CUST_ID 
                                                            AND cust.CUST_STAT IN (''2'',''3'',''7'',''8'')
                                                       )
                               ) V01
                        WHERE   V01.USE_DT   = SDT.SALE_DT (+)
                          AND   V01.BRAND_CD = SDT.BRAND_CD(+)
                          AND   V01.STOR_CD  = SDT.STOR_CD (+)
                          AND   V01.POS_NO   = SDT.POS_NO  (+)
                          AND   V01.BILL_NO  = SDT.BILL_NO (+)
                          AND   0           != SDT.SAV_PT  (+)
                        --AND   (0            = SDT.T_SEQ   (+) OR ''2'' = SDT.SUB_TOUCH_DIV(+))
                          AND   (V01.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                                AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || N_USER_ID || ''' AND BRAND_CD = V01.BRAND_CD AND USE_YN = ''Y'')))
                          AND  (''' || N_START_DT || ''' IS NULL OR V01.USE_DT >= ''' || N_START_DT || ''')
                          AND  (''' || N_END_DT || ''' IS NULL OR V01.USE_DT <= ''' || N_END_DT || ''')
                ) V02
                ';
                       
      v_query := v_query || '
            UNION ALL
            SELECT  
               DECRYPT(A.CARD_ID) AS CARD_ID
               , A.USE_DT
               , A.STOR_CD
               , ''할리스'' AS STOR_NM
               , '''' AS POS_NO
               , '''' AS BILL_NO
               , '''' AS ITEM_CD
               , '''' AS ITEM_NM
               , 0 AS SALE_QTY
               , 0 AS GRD_AMT
               , ''999'' AS SAV_USE_DIV
               , ( SELECT REMARKS
                   FROM C_CARD_SAV_HIS
                   WHERE COMP_CD = A.COMP_CD
                   AND   CARD_ID = A.CARD_ID
                   AND   USE_DT  = A.USE_DT
                   AND   USE_SEQ = A.USE_SEQ) AS REMARKS
               , A.LOS_PT_DT
               , CASE WHEN EXISTS (SELECT 1 FROM C_CARD_SAV_HIS WHERE USE_SEQ = A.USE_SEQ AND CARD_ID = A.CARD_ID) THEN (SELECT GET_COMMON_CODE_NM(''12220'', SAV_USE_DIV, ''' || N_LANGUAGE_TP || ''') FROM C_CARD_SAV_HIS WHERE USE_SEQ = A.USE_SEQ AND CARD_ID = A.CARD_ID)
                 ELSE GET_COMMON_CODE_NM(''12220'', ''999'', ''' || N_LANGUAGE_TP || ''')
                 END AS SAV_USE_DIV_NM
               , A.SAV_PT AS SAV_PT
               , 0 AS USE_PT
               , 0 AS LOS_PT
               , A.INST_DT
          from C_CARD_SAV_USE_PT_HIS A
          WHERE A.CARD_ID IN (SELECT CARD.CARD_ID FROM C_CUST CUST, C_CARD CARD
                        WHERE CUST.COMP_CD = ''' || P_COMP_CD || '''
                          AND CUST.CUST_ID = ''' || P_CUST_ID || '''
                          AND CUST.CUST_ID = CARD.CUST_ID 
                          AND CUST.CUST_STAT IN (''2'',''3'',''7'',''8''))
          ) A
          ORDER BY USE_DT DESC, INST_DT DESC
      ';
      
      DBMS_OUTPUT.PUT_LINE('v_query : ' || v_query);
            
      v_query_back := 
                'SELECT  
                     V02.CARD_ID
                     ,  V02.USE_DT
                     ,  V02.STOR_CD
                     ,  CASE WHEN V02.BILL_NO IS NULL THEN FC_GET_WORDPACK(''' || N_LANGUAGE_TP || ''', ''ADMIN_YN'')||'' ''||FC_GET_WORDPACK(''' || N_LANGUAGE_TP || ''', ''SUB_TOUCH_08'')
                        ELSE V02.STOR_NM
                        END  AS STOR_NM
                     ,  V02.POS_NO
                     ,  V02.BILL_NO
                     ,  V02.ITEM_CD
                     , (
                        SELECT  ITEM_NM
                        FROM    ITEM ITM
                        WHERE   ITM.BRAND_CD = V02.BRAND_CD
                        AND     ITM.ITEM_CD  = V02.ITEM_CD
                       ) ITEM_NM
                     ,  V02.SALE_QTY
                     ,  V02.GRD_AMT
                     ,  V02.SAV_USE_DIV
                     ,  V02.REMARKS
                     ,  V02.LOS_PT_DT
                     ,  GET_COMMON_CODE_NM(''12220'', V02.SAV_USE_DIV, ''' || N_LANGUAGE_TP || ''') AS SAV_USE_DIV_NM         
                     ,  CASE WHEN V02.R_NUM = 1 THEN V02.TOT_SALV_PT - (V02.CMP_SAV_PT - V02.SAV_PT) ELSE V02.SAV_PT END AS SAV_PT
                     ,  CASE WHEN V02.R_NUM = 1 THEN V02.USE_PT                                      ELSE NULL       END AS USE_PT
                     ,  CASE WHEN V02.R_NUM = 1 THEN V02.LOS_PT                                      ELSE NULL       END As LOS_PT
                FROM   (
                        SELECT  decrypt(V01.CARD_ID) AS CARD_ID
                             ,  V01.USE_DT
                             ,  SDT.BRAND_CD
                             ,  V01.STOR_CD
                             ,  V01.STOR_NM
                             ,  V01.POS_NO
                             ,  V01.BILL_NO
                             ,  SDT.SEQ
                             ,  SDT.ITEM_CD
                             ,  SDT.SALE_QTY
                             ,  SDT.GRD_AMT
                             ,  V01.SAV_USE_DIV
                             ,  V01.REMARKS
                             ,  TRUNC(CASE WHEN SDT.ITEM_CD IS NULL THEN V01.SAV_PT ELSE SDT.SAV_PT * V01.POINT_S / 100 END) AS SAV_PT
                             ,  SUM (TRUNC(CASE WHEN SDT.ITEM_CD IS NULL THEN V01.SAV_PT ELSE SDT.SAV_PT * V01.POINT_S / 100 END))
                                OVER(PARTITION BY V01.CARD_ID,  V01.USE_DT, V01.STOR_CD, V01.POS_NO, V01.BILL_NO) AS CMP_SAV_PT
                             ,  TRUNC(
                                        SUM (CASE WHEN SDT.ITEM_CD IS NULL THEN V01.SAV_PT ELSE SDT.SAV_PT * V01.POINT_S / 100 END)  
                                        OVER(PARTITION BY V01.CARD_ID,  V01.USE_DT, V01.STOR_CD, V01.POS_NO, V01.BILL_NO)
                                     ) AS TOT_SALV_PT
                             ,  V01.USE_PT
                             ,  V01.LOS_PT
                             ,  V01.POINT_S
                             ,  V01.LOS_PT_DT
                             ,  ROW_NUMBER() OVER(PARTITION BY V01.CARD_ID,  V01.USE_DT, V01.STOR_CD, V01.POS_NO, V01.BILL_NO ORDER BY SDT.SEQ) R_NUM
                        FROM    SALE_DT           SDT
                             , (
                                SELECT  CSH.COMP_CD
                                      , CSH.BRAND_CD
                                      , CSH.STOR_CD
                                      , STO.STOR_NM
                                      , CSH.POS_NO
                                      , CSH.BILL_NO
                                      , CSH.CARD_ID
                                      , CSH.USE_DT
                                      , CSH.SAV_USE_DIV AS SAV_USE_DIV
                                      , CSH.REMARKS AS REMARKS
                                      , CSH.SAV_PT AS SAV_PT
                                      , CSH.USE_PT AS USE_PT
                                      , CSH.LOS_PT AS LOS_PT
                                      , PLG.POINT_S AS POINT_S
                                      , CSH.LOS_PT_DT AS LOS_PT_DT
                                FROM    C_CARD_SAV_HIS    CSH
                                      , POINT_LOG         PLG
                                      , STORE             STO
                                WHERE   CSH.USE_DT   = PLG.SALE_DT (+)
                                AND     CSH.BRAND_CD = PLG.BRAND_CD(+)
                                AND     CSH.STOR_CD  = PLG.STOR_CD (+)
                                AND     CSH.POS_NO   = PLG.POS_NO  (+)
                                AND     CSH.BILL_NO  = PLG.BILL_NO (+)
                                AND     CSH.USE_SEQ  = PLG.APPR_NO (+)
                                AND     CSH.BRAND_CD = STO.BRAND_CD(+)
                                AND     CSH.STOR_CD  = STO.STOR_CD (+)
                                AND     CSH.COMP_CD  = ''' || P_COMP_CD || '''
                                AND     (''' || N_STOR_CD || ''' IS NULL OR CSH.STOR_CD = ''' || N_STOR_CD || ''')
                                AND     CSH.SAV_USE_FG = ''3''
                                AND     CSH.CARD_ID IN (
                                                         SELECT CARD_ID
                                                           FROM C_CUST cust, C_CARD card
                                                          WHERE cust.COMP_CD = ''' || P_COMP_CD || '''
                                                            AND cust.CUST_ID = ''' || P_CUST_ID || '''
                                                            AND cust.USE_YN=''Y''
                                                            AND cust.CUST_STAT IN (''2'',''3'',''7'',''8'')
                                                            AND cust.COMP_CD = card.COMP_CD 
                                                            AND cust.CUST_ID = card.CUST_ID 
                                                            AND card.USE_YN = ''Y''
                                                       )
                                AND     ''68''         = PLG.PAY_DIV (+)
                                AND     ''Y''          = PLG.USE_YN  (+) 
                                AND     CSH.SAV_PT  != 0
                               ) V01
                        WHERE   V01.USE_DT   = SDT.SALE_DT (+)
                          AND   V01.BRAND_CD = SDT.BRAND_CD(+)
                          AND   V01.STOR_CD  = SDT.STOR_CD (+)
                          AND   V01.POS_NO   = SDT.POS_NO  (+)
                          AND   V01.BILL_NO  = SDT.BILL_NO (+)
                          AND   0           != SDT.SAV_PT  (+)
                        --AND   (0            = SDT.T_SEQ   (+) OR ''2'' = SDT.SUB_TOUCH_DIV(+))
                          AND   (V01.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                                AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || N_USER_ID || ''' AND BRAND_CD = V01.BRAND_CD AND USE_YN = ''Y'')))
                          AND  (''' || N_START_DT || ''' IS NULL OR V01.USE_DT >= ''' || N_START_DT || ''')
                          AND  (''' || N_END_DT || ''' IS NULL OR V01.USE_DT <= ''' || N_END_DT || ''')
                ) V02
                ORDER BY V02.USE_DT  DESC
                       , V02.POS_NO
                       , V02.BILL_NO DESC
                       , V02.STOR_CD
                       , V02.ITEM_CD';
    OPEN O_CURSOR FOR v_query;
    
END C_CARD_SAV_HIS_POINT_SELECT;

/
