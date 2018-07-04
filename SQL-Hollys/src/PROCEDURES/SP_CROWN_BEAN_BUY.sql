--------------------------------------------------------
--  DDL for Procedure SP_CROWN_BEAN_BUY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_BEAN_BUY" 
   (
    PSV_COMP_CD       IN    VARCHAR2,       -- 회사코드
    PSV_LANG_TP       IN    VARCHAR2,       -- 언어타입
    PSV_SALE_DT       IN    VARCHAR2,       -- 매출일자
    PSV_RTN_CD        OUT   NUMBER,         -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2        -- 처리Message
   ) IS
    CURSOR CUR_1 IS
        SELECT  UNIQUE
                SALE_DT
              , BRAND_CD
              , STOR_CD
        FROM    SALE_HD
        WHERE   SALE_DT = NVL(PSV_SALE_DT, TO_CHAR(SYSDATE-1, 'YYYYMMDD'));
    
    CURSOR CUR_2(vSALE_DT IN VARCHAR2, vBRAND_CD IN VARCHAR2, vSTOR_CD IN VARCHAR2) IS
        SELECT  /*+ LEADING(HD) */
                HD.SALE_DT
              , HD.BRAND_CD
              , HD.STOR_CD
              , HD.POS_NO
              , HD.BILL_NO
              , HD.SALE_DIV
              , DT.SEQ
              , DT.ITEM_CD
              , DT.SALE_QTY
              , DT.SALE_AMT
              , DT.DC_AMT
              , DT.ENR_AMT
              , DT.GRD_AMT
              , DT.VAT_AMT
              , DT.GRD_AMT / DT.SALE_QTY AS PER_EA_AMT
              , SUM(DT.GRD_AMT) OVER(PARTITION BY HD.SALE_DT, HD.BRAND_CD, HD.STOR_CD, HD.POS_NO, HD.BILL_NO ORDER BY DT.GRD_AMT, DT.SEQ) ACC_GRD_AMT
              , SUM(DT.GRD_AMT) OVER(PARTITION BY HD.SALE_DT, HD.BRAND_CD, HD.STOR_CD, HD.POS_NO, HD.BILL_NO                            ) TOT_GRD_AMT
              , ROW_NUMBER()    OVER(PARTITION BY HD.SALE_DT, HD.BRAND_CD, HD.STOR_CD, HD.POS_NO, HD.BILL_NO ORDER BY DT.GRD_AMT, DT.SEQ) R_NUM
              , ST.APPR_AMT
              , CC.CUST_ID
              , CC.LVL_CD
              , HD.VOID_BEFORE_DT
              , HD.VOID_BEFORE_NO
        FROM    SALE_HD HD
              , SALE_DT DT
              , SALE_ST ST
              , C_CUST  CC
              ,(
                SELECT  UNIQUE
                        ITEM_CD
                FROM    DC_ITEM
                WHERE   BRAND_CD = vBRAND_CD
                AND     BEAN_YN  = 'Y'
                AND     USE_YN   = 'Y'
               ) DI
        WHERE   HD.SALE_DT  = DT.SALE_DT
        AND     HD.BRAND_CD = DT.BRAND_CD
        AND     HD.STOR_CD  = DT.STOR_CD
        AND     HD.POS_NO   = DT.POS_NO
        AND     HD.BILL_NO  = DT.BILL_NO
        AND     HD.SALE_DT  = ST.SALE_DT
        AND     HD.BRAND_CD = ST.BRAND_CD
        AND     HD.STOR_CD  = ST.STOR_CD
        AND     HD.POS_NO   = ST.POS_NO
        AND     HD.BILL_NO  = ST.BILL_NO
        AND     DT.ITEM_CD  = DI.ITEM_CD
        AND     HD.CUST_NO  = CC.CUST_ID
        AND     CC.COMP_CD  = PSV_COMP_CD
        AND     HD.SALE_DT  = vSALE_DT
        AND     HD.BRAND_CD = vBRAND_CD
        AND     HD.STOR_CD  = vSTOR_CD
        AND     DT.GRD_AMT != 0
        AND    (
                DT.T_SEQ = 0 
                OR  
                DT.SUB_TOUCH_DIV  = '2'
               )
        AND     ST.PAY_DIV   IN ('67', 'C2')
        AND     CC.CUST_STAT IN ('2', '3');
    
    /* LOCAL 변수 */    
    nREST_APPR_AMT      NUMBER(12, 2) := 0;
    nPRE_ACC_AMT        NUMBER(12, 2) := 0;
BEGIN
    /*** 원두 상품 정보 ***/
    FOR MYREC1 IN CUR_1 LOOP
        FOR MYREC2 IN CUR_2(MYREC1.SALE_DT, MYREC1.BRAND_CD, MYREC1.STOR_CD) LOOP
            -- 누적 순매출이 멤버십 카드 결제 금액이 보다 큰 경우 EXIT
            IF MYREC2.SALE_DIV = '1' THEN
                -- 전회 누적
                IF MYREC2.R_NUM = 1 THEN 
                    nREST_APPR_AMT := MYREC2.APPR_AMT;
                END IF;
                
                -- 누적 금액과 멤버십 카드 결제 금액 차액
                CONTINUE WHEN nREST_APPR_AMT < 0;
                
                IF nREST_APPR_AMT >= MYREC2.GRD_AMT THEN
                    MYREC2.SALE_QTY := MYREC2.SALE_QTY;
                ELSIF nREST_APPR_AMT >= MYREC2.PER_EA_AMT THEN
                    MYREC2.SALE_QTY := TRUNC(nREST_APPR_AMT / MYREC2.PER_EA_AMT, 0);
                ELSE
                     MYREC2.SALE_QTY := 0;
                END IF;
                
                CONTINUE WHEN MYREC2.SALE_QTY <= 0;
            END IF;
            
            BEGIN
                MERGE   INTO C_CUST_BIT CCB
                USING   DUAL 
                ON    (
                            COMP_CD   = PSV_COMP_CD
                        AND SALE_DT   = MYREC2.SALE_DT
                        AND BRAND_CD  = MYREC2.BRAND_CD
                        AND STOR_CD   = MYREC2.STOR_CD
                        AND POS_NO    = MYREC2.POS_NO
                        AND BILL_NO   = MYREC2.BILL_NO
                        AND SEQ       = MYREC2.SEQ    
                      )
                WHEN NOT MATCHED THEN
                    INSERT (
                            COMP_CD    ,
                            SALE_DT    ,
                            BRAND_CD    ,
                            STOR_CD    ,
                            POS_NO    ,
                            BILL_NO    ,
                            SEQ    ,
                            SALE_DIV    ,
                            CUST_ID    ,
                            CUST_LVL    ,
                            ITEM_CD    ,
                            SALE_QTY    ,
                            SALE_AMT    ,
                            DC_AMT    ,
                            ENR_AMT    ,
                            GRD_AMT    ,
                            VAT_AMT    ,
                            VOID_BEFORE_DT    ,
                            VOID_BEFORE_NO    ,
                            COUPON_PRT    
                           )
                    VALUES (
                            PSV_COMP_CD    ,
                            MYREC2.SALE_DT    ,
                            MYREC2.BRAND_CD    ,
                            MYREC2.STOR_CD    ,
                            MYREC2.POS_NO    ,
                            MYREC2.BILL_NO    ,
                            MYREC2.SEQ    ,
                            MYREC2.SALE_DIV    ,
                            MYREC2.CUST_ID    ,
                            MYREC2.LVL_CD    ,
                            MYREC2.ITEM_CD    ,
                            MYREC2.SALE_QTY    ,
                            MYREC2.SALE_AMT    ,
                            MYREC2.DC_AMT    ,
                            MYREC2.ENR_AMT    ,
                            MYREC2.GRD_AMT    ,
                            MYREC2.VAT_AMT    ,
                            MYREC2.VOID_BEFORE_DT    ,
                            MYREC2.VOID_BEFORE_NO    ,
                            'N'    
                           );
                           
                nREST_APPR_AMT := nREST_APPR_AMT - MYREC2.GRD_AMT;
            EXCEPTION
                WHEN OTHERS THEN
                PSV_RTN_CD := SQLCODE;
                PSV_RTN_MSG := 'CUST_BIT : ' || SQLERRM;
            END;
        END LOOP;
    END LOOP;
    
    COMMIT;
    
    PSV_RTN_CD := 0;
    PSV_RTN_MSG := '정상처리되었습니다.';    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        PSV_RTN_CD := SQLCODE;
        PSV_RTN_MSG := SQLERRM;
END SP_CROWN_BEAN_BUY;

/
