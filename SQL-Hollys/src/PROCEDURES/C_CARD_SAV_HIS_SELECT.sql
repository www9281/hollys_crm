--------------------------------------------------------
--  DDL for Procedure C_CARD_SAV_HIS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_SAV_HIS_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CUST_ID      IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_START_DT     IN  VARCHAR2,
    N_END_DT       IN  VARCHAR2,
    N_USER_ID      IN  VARCHAR2,
    N_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수 
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [왕관적립이력]  조회
    -- Test          :   C_CARD_SAV_HIS_SELECT ('000', 'level_10', '', '', '', 'KOR')
    -- ==========================================================================================

--20180425 LCS
      v_query := '
                SELECT  USE_SEQ
                      , USE_DT
                      , STOR_CD
                      , MAX(CASE WHEN BILL_NO IS NULL THEN  FC_GET_WORDPACK(''' || N_LANGUAGE_TP || ''', ''ADMIN_YN'')||'' ''||FC_GET_WORDPACK(''' || N_LANGUAGE_TP || ''', ''SUB_TOUCH_08'')
                             ELSE GET_STOR_NM( BRAND_CD, STOR_CD, ''' || N_LANGUAGE_TP || ''' ) END)  STOR_NM
                      , POS_NO
                      , BILL_NO
                      , MAX(DECODE(SEQ, 1, ITEM_NM,''''))
                      ||CASE WHEN MAX(DECODE(SEQ,1, ITEM_NM,'''')) IS NOT NULL
                             THEN DECODE(COUNT(*),1,'''',''외 ''||COUNT(*)||''종'')
                        END              ITEM_NM
                      , SUM(SALE_QTY)    SALE_QTY
                      , SUM(SALE_AMT)    SALE_AMT
                      , MAX(GET_COMMON_CODE_NM(''12220'', SAV_USE_DIV, ''' || N_LANGUAGE_TP || ''' ))  SAV_USE_DIV
                      , MAX(NOTES)       NOTES
                      --, SUM(DECODE(SAV_USE_DIV, ''201'', 1, ''202'', -1))          SAV_MLG
                      , SAV_MLG
                      , MAX(LOS_MLG)     LOS_MLG
                      , MAX(LOS_MLG_DT)  LOS_MLG_DT
                FROM(      
                    SELECT
                            W.USE_SEQ
                         ,  W.USE_DT
                         ,  W.STOR_CD
                         ,  W.BRAND_CD
                         ,  W.POS_NO
                         ,  W.BILL_NO
                         ,  DT.SEQ
                         ,  IT.ITEM_NM
                         ,  DT.SALE_QTY
                         ,  DT.SALE_AMT
                         --,  DECODE(W.SAV_USE_DIV , ''204'',''201'',''205'',''202'',  W.SAV_USE_DIV) AS SAV_USE_DIV
                         ,  W.SAV_USE_DIV AS SAV_USE_DIV
                         ,  W.NOTES
                         ,  W.SAV_MLG
                         ,  W.LOS_MLG
                         ,  W.LOS_MLG_DT
                      FROM  C_CUST_CROWN W
                          , SALE_DT      DT
                          , ITEM         IT
                     WHERE  1 = 1 
                     AND W.COMP_CD   = ''016''
                     AND W.COMP_CD   = DT.COMP_CD (+)
                     AND W.BRAND_CD  = DT.BRAND_CD(+)
                     AND W.STOR_CD   = DT.STOR_CD (+) 
                     AND W.POS_NO    = DT.POS_NO  (+)
                     AND W.BILL_NO   = DT.BILL_NO (+)
                     AND W.CARD_ID   = DT.CARD_ID (+)
                     AND W.CUST_ID   = DT.CUST_ID (+)
                     AND W.USE_DT    = DT.SALE_DT (+)
                     AND W.CARD_ID IN(SELECT CARD_ID FROM C_CARD WHERE  CUST_ID = ''' || P_CUST_ID || ''' )
                     AND ( ''' || N_STOR_CD  || ''' IS NULL OR W.STOR_CD = ''' || N_STOR_CD || ''')
                     AND (W.BRAND_CD = ''' || N_BRAND_CD || ''' OR ( ''' || N_BRAND_CD  || ''' IS NULL  AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE  BRAND_CD = W.BRAND_CD AND USE_YN = ''Y'')))
                     AND ( ''' || N_START_DT  || ''' IS NULL OR W.USE_DT >= ''' || N_START_DT || ''')
                     AND ( ''' || N_END_DT    || ''' IS NULL OR W.USE_DT <= ''' || N_END_DT || ''')
                     AND (DT.T_SEQ(+) = ''0'' OR DT.SUB_TOUCH_DIV(+) = ''2'')
                     AND DT.COMP_CD  = IT.COMP_CD (+)
                     AND DT.ITEM_CD  = IT.ITEM_CD(+)
                 )
                 GROUP BY USE_SEQ
                        , USE_DT
                        , STOR_CD
                        , POS_NO
                        , BILL_NO
                        , SAV_MLG
                 ORDER BY USE_DT DESC, STOR_CD, POS_NO, BILL_NO, SAV_MLG';

    dbms_output.put_line(v_query);
    OPEN O_CURSOR FOR v_query;
    
END C_CARD_SAV_HIS_SELECT;

/
