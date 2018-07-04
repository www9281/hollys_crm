--------------------------------------------------------
--  DDL for Procedure SP_CROWN_COUPON_EVENT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_COUPON_EVENT" 
(
    PSV_COMP_CD       IN    VARCHAR2,       -- 회사코드
    PSV_LANG_TP       IN    VARCHAR2,       -- 언어타입
    PSV_STD_DT        IN    VARCHAR2,       -- 변경일자
    PSV_RTN_CD        OUT   NUMBER,         -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2        -- 처리Message
)
---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_CROWN_GRADE_CHG
--  Description      : C_CUST.LVL_CD 산정( 매일 AM:5시 실행)
--  Ref. Table       : C_CARD_SAV_HIS
---------------------------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 
--  Modify Date      : 
--  Modify Programer :
---------------------------------------------------------------------------------------------------
IS
    -- 생일쿠폰
    CURSOR CUR_1 IS
        SELECT  COMP_CD
              , CUST_ID
              , BIRTH_DT
        FROM    C_CUST CST
        WHERE   COMP_CD = PSV_COMP_CD
        AND     CUST_STAT IN ('2', '3')
        AND   (
               (
                        DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) >= TO_CHAR(SYSDATE - 7, 'YYYYMMDD') 
                AND     DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) <= TO_CHAR(SYSDATE + 7, 'YYYYMMDD')
               )
                OR
               (
                        DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) >= TO_CHAR(SYSDATE - 7, 'YYYYMMDD') 
                AND     DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) <= TO_CHAR(SYSDATE + 7, 'YYYYMMDD')
               ) 
                OR
               (
                        DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) >= TO_CHAR(SYSDATE - 7, 'YYYYMMDD') 
                AND     DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) <= TO_CHAR(SYSDATE + 7, 'YYYYMMDD')
               )
              )
        AND     EXISTS(SELECT   1
                       FROM     C_CARD CRD
                       WHERE    CRD.COMP_CD = CST.COMP_CD
                       AND      CRD.CUST_ID = CST.CUST_ID);
    
    -- 원두구매
    CURSOR CUR_2 IS
        SELECT  COMP_CD
             ,  SALE_DT
             ,  BRAND_CD
             ,  STOR_CD
             ,  POS_NO
             ,  BILL_NO
             ,  VOID_BEFORE_DT
             ,  VOID_BEFORE_NO
             ,  SALE_DIV
             ,  CUST_ID
             ,  ITEM_CD
             ,  ABS(SUM(SALE_QTY)) AS SALE_QTY
        FROM    C_CUST_BIT
        WHERE   COMP_CD    = PSV_COMP_CD
        AND     COUPON_PRT = 'N'
        GROUP BY
                COMP_CD
             ,  SALE_DT
             ,  BRAND_CD
             ,  STOR_CD
             ,  POS_NO
             ,  BILL_NO
             ,  VOID_BEFORE_DT
             ,  VOID_BEFORE_NO
             ,  SALE_DIV
             ,  CUST_ID
             ,  ITEM_CD;
    
    -- 첫구매
    CURSOR CUR_3 IS
        SELECT  COMP_CD
             ,  SALE_DT
             ,  BRAND_CD
             ,  STOR_CD
             ,  CUST_ID
             ,  SAV_MLG
             ,  CASE WHEN SALE_DIV = '201' THEN '1' ELSE '2' END SALE_DIV 
        FROM    C_CUST_FBD
        WHERE   COMP_CD    = PSV_COMP_CD
        AND     COUPON_PRT = 'N';
    
    -- 첫 3만원 충전
    CURSOR CUR_4 IS
        SELECT  /*+ NO_MERGE LEADING(CST) */
                GRP.COMP_CD
              , CST.CUST_ID
              , GRP.LVL_CD
              , GRP.COUPON_CD
              , GRP.GRP_SEQ
              , GRP.BRAND_CD
              , GRP.DC_DIV
              , MST.RESTRI_YN
              , MST.MAX_PROM_CNT
              , MST.CUST_CNT
              , CST.CARD_ID
              , CST.CRG_DT
              , CST.CRG_SEQ
              , CST.CRG_AMT
        FROM    C_COUPON_ITEM_GRP   GRP
              , C_COUPON_MST        MST
              ,(
                SELECT  /*+ NO_MERGE LEADING(HIS) 
                            INDEX(CRD PK_C_CARD) 
                            INDEX(CST PK_C_CUST) */
                        CST.COMP_CD 
                     ,  CST.CUST_ID
                     ,  CST.LVL_CD
                     ,  HIS.CARD_ID
                     ,  HIS.COUPON_CD
                     ,  HIS.CRG_DT
                     ,  HIS.CRG_SEQ
                     ,  HIS.CRG_AMT
                     ,  ROW_NUMBER() OVER(PARTITION BY CST.COMP_CD, CST.CUST_ID ORDER BY HIS.CRG_DT, HIS.CRG_AMT DESC) R_NUM
                FROM    C_CUST              CST
                     ,  C_CARD              CRD
                     , (
                        SELECT  /*+ NO_MERGE INDEX(HIS IDX03_C_CARD_CHARGE_HIS) */
                                HIS.COMP_CD
                              , HIS.CARD_ID
                              , MST.COUPON_CD
                              , HIS.CRG_DT
                              , HIS.CRG_SEQ
                              , HIS.CRG_AMT
                              , ROW_NUMBER() OVER(PARTITION BY HIS.COMP_CD, HIS.CARD_ID ORDER BY HIS.CRG_DT, HIS.CRG_AMT DESC) R_NUM
                        FROM    C_CARD_CHARGE_HIS HIS
                              ,(
                                SELECT  COMP_CD
                                     ,  COUPON_CD
                                     ,  START_DT
                                     ,  CLOSE_DT
                                     ,  ROW_NUMBER() OVER(PARTITION BY COMP_CD ORDER BY START_DT DESC) R_NUM
                                FROM    C_COUPON_MST CCM
                                WHERE   COMP_CD = PSV_COMP_CD
                                AND     USE_YN  = 'Y'
                                AND     TO_CHAR(SYSDATE  , 'YYYYMMDD') >= START_DT
                                AND     TO_CHAR(SYSDATE-7, 'YYYYMMDD') <= CLOSE_DT
                                AND     EXISTS (
                                                SELECT 1
                                                FROM   C_COUPON_ITEM_GRP CIG
                                                WHERE  CIG.COMP_CD   = CCM.COMP_CD
                                                AND    CIG.COUPON_CD = CCM.COUPON_CD
                                                AND    CIG.PRT_DIV   = '02'
                                               ) 
                               ) MST
                        WHERE   HIS.COMP_CD   = MST.COMP_CD
                        AND     HIS.CRG_DT    BETWEEN MST.START_DT AND MST.CLOSE_DT 
                        AND     HIS.COMP_CD   = PSV_COMP_CD
                        AND     HIS.CRG_FG    = '1'
                        AND     HIS.CRG_AMT  >=  30000  -- 3만원 이상(조건에 따라 수정)
                        AND     HIS.USE_YN    = 'Y'
                        AND     MST.R_NUM     = 1       -- 최종 프로모션 기준
                        AND     NOT EXISTS (
                                            SELECT  1
                                            FROM    C_CARD_CHARGE_HIS CMP
                                            WHERE   CMP.COMP_CD    = HIS.COMP_CD
                                            AND     CMP.CARD_ID    = HIS.CARD_ID
                                            AND     CMP.ORG_CRG_DT = HIS.CRG_DT
                                            AND     CMP.ORG_CRG_SEQ= HIS.CRG_SEQ
                                           ) 
                       ) HIS
                WHERE   CRD.COMP_CD   = HIS.COMP_CD
                AND     CRD.CARD_ID   = HIS.CARD_ID
                AND     CST.COMP_CD   = CRD.COMP_CD
                AND     CST.CUST_ID   = CRD.CUST_ID
                AND     CRD.COMP_CD   = PSV_COMP_CD
                AND     CST.JOIN_DT  >= '20150811'  -- 조건에 따라 수정
                AND     CRD.USE_YN    = 'Y'
                AND     CST.CUST_STAT IN ('2', '3')
                AND     CST.USE_YN    = 'Y'
                AND     HIS.R_NUM     = 1
                AND NOT EXISTS (
                                SELECT  /*+ NO_MERGE LEADING(CCC) 
                                            INDEX(CCC IDX02_C_COUPON_CUST) */
                                        1
                                FROM    C_COUPON_ITEM_GRP GRP
                                     ,  C_COUPON_CUST     CCC
                                WHERE   GRP.COMP_CD   = CCC.COMP_CD
                                AND     GRP.COUPON_CD = CCC.COUPON_CD
                                AND     CCC.COMP_CD   = CST.COMP_CD
                                AND     CCC.CUST_ID   = CST.CUST_ID
                                AND     CCC.COMP_CD   = PSV_COMP_CD
                                AND     GRP.PRT_DIV   = '02'
                                AND     GRP.USE_YN    = 'Y'
                                AND     CCC.USE_YN    = 'Y'
                               )               
               ) CST     
        WHERE   GRP.COMP_CD     = MST.COMP_CD
        AND     GRP.COUPON_CD   = MST.COUPON_CD
        AND     GRP.COMP_CD     = CST.COMP_CD
        AND     GRP.LVL_CD      = CST.LVL_CD
        AND     GRP.COUPON_CD   = CST.COUPON_CD
        AND     GRP.COMP_CD     = PSV_COMP_CD   -- 회사코드
        AND     GRP.PRT_DIV     = '02'          -- 발행구분(충전)
        AND     MST.COUPON_STAT = '2' 
        AND     MST.CERT_YN     = 'Y'
        AND     GRP.USE_YN      = 'Y'
        AND     CST.R_NUM       =  1
        ORDER BY 1, 2;
    
    -- 자동충전
    /*****************************************
    CURSOR CUR_5 IS
        SELECT  RES.COMP_CD
              , CRD.CUST_ID
              , RES.CRG_DT
              , CRD.BRAND_CD
              , RES.REF_CRG_SEQ
              , RES.CRG_AMT
              , RES.ROWID AS RID
        FROM    C_CARD_AUTO_RES RES
              , C_CARD          CRD
        WHERE   RES.COMP_CD    = CRD.COMP_CD
        AND     RES.CARD_ID    = CRD.CARD_ID
        AND     RES.COMP_CD    = PSV_COMP_CD
        AND     RES.RES_CODE   = '0000'
        AND     RES.COUPON_PRT = 'N'
        AND     CRD.CUST_ID IS NOT NULL
        AND     EXISTS (
                        SELECT  1
                        FROM    C_CARD_CHARGE_HIS HIS
                        WHERE   HIS.COMP_CD = RES.COMP_CD
                        AND     HIS.CARD_ID = RES.CARD_ID
                        AND     HIS.CRG_DT  = RES.CRG_DT
                        AND     HIS.CRG_SEQ = RES.REF_CRG_SEQ
                        AND     HIS.CRG_AUTO_DIV = '2'
                        AND     NOT EXISTS (
                                            SELECT  1
                                            FROM    C_CARD_CHARGE_HIS ORG
                                            WHERE   ORG.COMP_CD     = HIS.COMP_CD
                                            AND     ORG.CARD_ID     = HIS.CARD_ID
                                            AND     ORG.ORG_CRG_DT  = HIS.CRG_DT
                                            AND     ORG.ORG_CRG_SEQ = HIS.CRG_SEQ
                                           )
                       );
    *****************************************/                         
                         
    ERR_HANDLER     EXCEPTION;
    
    ARR_SALE_HD     PKG_TYPE.TRG_SALE_HD;
    
    nARG_RTN_CD     NUMBER;
    vARG_RTN_MSG    VARCHAR2(2000) := NULL;
BEGIN
    PSV_RTN_CD := 0;
    PSV_RTN_MSG := 'OK';
    
    -- 생일쿠폰 발생
    FOR MYREC1 IN CUR_1 LOOP
        -- 생일쿠폰 발생 오류는 체크 없음.
        SP_CROWN_COUPON_BLD(MYREC1.COMP_CD, PSV_LANG_TP, MYREC1.CUST_ID, '04', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
    END LOOP;
    
    -- 원두구매 대상 상품 작성
    SP_CROWN_BEAN_BUY(PSV_COMP_CD, PSV_LANG_TP, PSV_STD_DT, nARG_RTN_CD, vARG_RTN_MSG);
    
    -- 원두 할인
    FOR MYREC2 IN CUR_2 LOOP
        -- 생일쿠폰 발생 오류는 체크 없음.
        ARR_SALE_HD.SALE_DT  := MYREC2.SALE_DT;
        ARR_SALE_HD.BRAND_CD := MYREC2.BRAND_CD;
        ARR_SALE_HD.STOR_CD  := MYREC2.STOR_CD;
        ARR_SALE_HD.POS_NO   := MYREC2.POS_NO;
        ARR_SALE_HD.BILL_NO  := MYREC2.BILL_NO;
        ARR_SALE_HD.SALE_DIV := MYREC2.SALE_DIV;
        ARR_SALE_HD.VOID_BEFORE_DT := MYREC2.VOID_BEFORE_DT;
        ARR_SALE_HD.VOID_BEFORE_NO := MYREC2.VOID_BEFORE_NO;
         
        IF MYREC2.SALE_QTY != 0 THEN
            FOR i IN 1..MYREC2.SALE_QTY LOOP
                SP_CROWN_COUPON_BLD(MYREC2.COMP_CD, PSV_LANG_TP, MYREC2.CUST_ID, '06', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
                
                EXIT WHEN nARG_RTN_CD != 0;
            END LOOP;
            
            IF nARG_RTN_CD = 0 THEN
                UPDATE  C_CUST_BIT
                SET     COUPON_PRT = 'Y'
                WHERE   COMP_CD    = MYREC2.COMP_CD
                AND     BRAND_CD   = MYREC2.BRAND_CD
                AND     STOR_CD    = MYREC2.STOR_CD
                AND     POS_NO     = MYREC2.POS_NO
                AND     BILL_NO    = MYREC2.BILL_NO
                AND     ITEM_CD    = MYREC2.ITEM_CD;
            END IF;
        END IF; 
    END LOOP;
    
    ARR_SALE_HD := NULL;
    
    -- 첫 구매
    FOR MYREC3 IN CUR_3 LOOP
        -- 매장당 일일 50개만 지급 하기 위해 정보 SET.
        ARR_SALE_HD.SALE_DT  := MYREC3.SALE_DT;
        ARR_SALE_HD.BRAND_CD := MYREC3.BRAND_CD;
        ARR_SALE_HD.STOR_CD  := MYREC3.STOR_CD;
        ARR_SALE_HD.SALE_DIV := MYREC3.SALE_DIV;
        
        -- 첫 구매 
        SP_CROWN_COUPON_BLD(MYREC3.COMP_CD, PSV_LANG_TP, MYREC3.CUST_ID, '07', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
        
        IF nARG_RTN_CD = 0 THEN
            UPDATE  C_CUST_FBD
            SET     COUPON_PRT = 'Y'
            WHERE   COMP_CD    = MYREC3.COMP_CD
            AND     CUST_ID    = MYREC3.CUST_ID;
        END IF;
    END LOOP;
    
    -- 3만원 이상 충전
    FOR MYREC4 IN CUR_4 LOOP
        ARR_SALE_HD.SALE_DT   := MYREC4.CRG_DT;
        ARR_SALE_HD.BRAND_CD  := MYREC4.BRAND_CD;
        ARR_SALE_HD.SALE_DIV  := '1';
        ARR_SALE_HD.STOR_CD   := TO_CHAR(MYREC4.CRG_SEQ, 'FM999999');
        ARR_SALE_HD.GRD_I_AMT := MYREC4.CRG_AMT;
        
        -- 3만원 이상 충전
        SP_CROWN_COUPON_BLD(MYREC4.COMP_CD, PSV_LANG_TP, MYREC4.CUST_ID, '02', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
    END LOOP;
    
    ARR_SALE_HD := NULL;
    
    /*************************************
    -- 자동충전
    FOR MYREC5 IN CUR_5 LOOP
        IF MYREC5.CRG_AMT >= 50000 THEN
            ARR_SALE_HD.SALE_DT   := MYREC5.CRG_DT;
            ARR_SALE_HD.BRAND_CD  := MYREC5.BRAND_CD;
            ARR_SALE_HD.SALE_DIV  := '1';
            ARR_SALE_HD.STOR_CD   := TO_CHAR(MYREC5.REF_CRG_SEQ, 'FM999999');
            ARR_SALE_HD.POS_NO    := '01';
            ARR_SALE_HD.BILL_NO   := '001';
            
            ARR_SALE_HD.GRD_I_AMT := MYREC5.CRG_AMT;
            
            -- 자동충전 
            SP_CROWN_COUPON_BLD(MYREC5.COMP_CD, PSV_LANG_TP, MYREC5.CUST_ID, '08', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
        END IF;
        
        UPDATE  C_CARD_AUTO_RES
        SET     COUPON_PRT = CASE WHEN MYREC5.CRG_AMT >= 50000 THEN 'Y' ELSE 'X' END
        WHERE   ROWID = MYREC5.RID;
    END LOOP;
    ************************************/
    
    COMMIT;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD  := SQLCODE;
        PSV_RTN_MSG := SQLERRM;
                        
        ROLLBACK;
        RETURN;
END;

/
