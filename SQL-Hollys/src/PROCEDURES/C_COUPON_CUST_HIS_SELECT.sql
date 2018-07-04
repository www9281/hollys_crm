--------------------------------------------------------
--  DDL for Procedure C_COUPON_CUST_HIS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_COUPON_CUST_HIS_SELECT" (
    P_COMP_CD     IN   VARCHAR2,
    P_CUST_ID     IN   VARCHAR2,
    P_COUPON_CD   IN   VARCHAR2,
    P_CERT_NO     IN   VARCHAR2,
    P_STOR_CD     IN   VARCHAR2,
    N_LANGUAGE_TP IN   VARCHAR2,
    O_CURSOR    OUT  SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [쿠폰발급내역]탭의 [쿠폰사용내역] 정보 조회
    -- Test          :   C_CUST_SELECT_ONE ('000', 'level_10', 'PBS0000001', 'C006315F0010K0532287', '', 'KOR')
    -- ==========================================================================================
      v_query :=
            'SELECT 
                 COUPON.SALE_DT
                 , COUPON.STOR_CD
                 , STO.STOR_NM
                 , COUPON.BILL_NO
                 , COUPON.ITEM_CD
                 , ITM.ITEM_NM 
                 , COUPON.SALE_QTY
                 , COUPON.SALE_AMT
                 , COUPON.DC_AMT
                 , COUPON.GRD_AMT
                 , COUPON.USE_STAT
                 , GET_COMMON_CODE_NM(''01615'', COUPON.USE_STAT, ''' || N_LANGUAGE_TP || ''') AS USE_STAT_NM      
                 , COUPON.POS_NO     
            FROM
            (        
                        SELECT DT.SALE_DT
                             , DT.STOR_CD
                             , DT.BILL_NO
                             , DT.ITEM_CD
                             , DT.SALE_QTY
                             , DT.SALE_AMT
                             , DT.DC_AMT + DT.ENR_AMT AS DC_AMT
                             , DT.GRD_AMT   
                             , CUST.USE_STAT
                             , CUST.BRAND_CD   
                             , CUST.UPD_DT AS SORT_DT
                             , CUST.POS_NO
                             , ''1'' ORD                               
                          FROM C_COUPON_CUST CUST
                             , SALE_DT DT
                         WHERE CUST.COMP_CD  = ''' || P_COMP_CD || '''
                           AND CUST.CUST_ID  = ''' || P_CUST_ID || '''
                           AND CUST.USE_YN   = ''Y''
                           AND CUST.COUPON_CD = ''' || P_COUPON_CD || '''
                           AND CUST.CERT_NO  = ''' || P_CERT_NO || '''
                           AND CUST.STOR_CD  = ''' || P_STOR_CD || '''
                           AND CUST.USE_DT   = DT.SALE_DT
                           AND CUST.STOR_CD  = DT.STOR_CD
                           AND CUST.POS_NO   = DT.POS_NO
                           AND CUST.BILL_NO  = DT.BILL_NO
                    UNION ALL
                        SELECT DT.SALE_DT
                             , DT.STOR_CD
                             , DT.BILL_NO
                             , DT.ITEM_CD
                             , DT.SALE_QTY
                             , DT.SALE_AMT
                             , DT.DC_AMT + DT.ENR_AMT AS DC_AMT
                             , DT.GRD_AMT
                             , HIS.USE_STAT
                             , HIS.BRAND_CD 
                             , HIS.INST_DT AS SORT_DT
                             , HIS.POS_NO
                             , ''2'' ORD                       
                          FROM C_COUPON_CUST_HIS HIS
                             , SALE_DT DT       
                         WHERE HIS.COMP_CD  = ''' || P_COMP_CD || '''
                           AND HIS.COUPON_CD = ''' || P_COUPON_CD || '''
                           AND HIS.CERT_NO  = ''' || P_CERT_NO || '''
                           AND HIS.STOR_CD  = ''' || P_STOR_CD || '''
                           AND HIS.USE_DT   = DT.SALE_DT
                           AND HIS.STOR_CD  = DT.STOR_CD
                           AND HIS.POS_NO   = DT.POS_NO
                           AND HIS.BILL_NO  = DT.BILL_NO
            ) COUPON          
            ,  (
                          SELECT  I.ITEM_CD
                               ,  NVL(I.ITEM_NM, I2.ITEM_NM)   AS ITEM_NM
                            FROM  ITEM           I
                               ,  LANG_ITEM      I2
                           WHERE  I.ITEM_CD       = I2.ITEM_CD(+)
                             AND  I2.LANGUAGE_TP(+)= ''' || N_LANGUAGE_TP || '''
                             AND  I2.USE_YN(+)     = ''Y''                    
                      ) ITM
                   ,  (
                          SELECT  S.BRAND_CD
                               ,  S.STOR_CD
                               ,  NVL(L.STOR_NM, S.STOR_NM)   AS STOR_NM
                            FROM  STORE           S
                               ,  LANG_STORE      L
                           WHERE  S.BRAND_CD      = L.BRAND_CD(+)
                             AND  S.STOR_CD       = L.STOR_CD(+)
                             AND  L.LANGUAGE_TP(+)= ''' || N_LANGUAGE_TP || '''
                             AND  L.USE_YN(+)     = ''Y''
                      )  STO               
             WHERE COUPON.BRAND_CD = STO.BRAND_CD(+)
               AND COUPON.STOR_CD  = STO.STOR_CD(+)
               AND COUPON.ITEM_CD  = ITM.ITEM_CD(+)
             ORDER BY COUPON.ORD 
                   , COUPON.SORT_DT DESC
                   , COUPON.SALE_DT DESC
                   , COUPON.STOR_CD
                   , STO.STOR_NM
                   , COUPON.BILL_NO DESC
                   , COUPON.ITEM_CD';
             
      OPEN O_CURSOR FOR v_query;
END C_COUPON_CUST_HIS_SELECT;

/
