--------------------------------------------------------
--  DDL for Function FN_GET_COUPON_VIST_RSLT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_COUPON_VIST_RSLT" 
(
   PSV_COMP_CD   IN VARCHAR2,   -- 회사코드
   PSV_LANG_CD   IN VARCHAR2,   -- 언어코드
   PSV_BRAND_CD  IN VARCHAR2,   -- 영업조직
   PSV_COUPON_CD IN VARCHAR2,   -- 쿠폰코드
   PSV_CERT_FDT  IN VARCHAR2,   -- 검색시작일자
   PSV_CERT_TDT  IN VARCHAR2    -- 검색시작일자
)
RETURN TBL_CPN_RSLT AS
    CURSOR CUR_1 IS
        SELECT  /*+ NO_MERGE INDEX(CST PK_C_COUPON_CUST) */
                MST.COMP_CD
              , MST.BRAND_CD
              , MST.COUPON_CD
              , MST.COUPON_NM
              , MST.DC_DIV
        FROM    C_COUPON_MST  MST
        WHERE   MST.COMP_CD   = PSV_COMP_CD
        AND     MST.BRAND_CD IN ('0000', PSV_BRAND_CD)
        AND    (PSV_COUPON_CD IS NULL OR MST.COUPON_CD = PSV_COUPON_CD)
        AND     MST.USE_YN    = 'Y'
        AND     EXISTS (
                        SELECT  1
                        FROM    C_COUPON_CUST CST  
                        WHERE   CST.COMP_CD   = MST.COMP_CD
                        AND     CST.COUPON_CD = MST.COUPON_CD
                        AND     CST.CERT_FDT BETWEEN PSV_CERT_FDT AND PSV_CERT_TDT
                        AND     CST.USE_YN   = 'Y'
                       );

    S_TBL_CPN_RSLT   TBL_CPN_RSLT := TBL_CPN_RSLT();
    M_TBL_CPN_RSLT   TBL_CPN_RSLT := TBL_CPN_RSLT();
BEGIN
    FOR MYREC IN CUR_1 LOOP
        WITH V1_CC AS
           (
                SELECT  /*+ NO_MERGE INDEX(CST PK_C_COUPON_CUST) */
                        MST.COMP_CD
                      , CCC.BRAND_CD
                      , MST.COUPON_CD
                      , MST.COUPON_NM
                      , MST.DC_DIV
                      , CCC.CUST_ID
                      , CST.MEMBER_NO
                      , CCC.USE_STAT
                      , CCC.STOR_CD
                      , CCC.POS_NO
                      , CCC.BILL_NO
                      , MIN(CERT_FDT) OVER(PARTITION BY CCC.CUST_ID, CCC.COUPON_CD ORDER BY CCC.CERT_FDT) AS MIN_CERT_FDT
                FROM    C_COUPON_MST  MST
                      , C_COUPON_CUST CCC
                      , C_CUST        CST
                WHERE   MST.COMP_CD   = CCC.COMP_CD
                AND     MST.BRAND_CD IN ('0000', CCC.BRAND_CD)                
                AND     MST.COUPON_CD = CCC.COUPON_CD
                AND     CCC.COMP_CD   = CST.COMP_CD
                AND     CCC.CUST_ID   = CST.CUST_ID                
                AND     MST.COMP_CD   = MYREC.COMP_CD
                AND     MST.COUPON_CD = MYREC.COUPON_CD
                AND     CCC.CERT_FDT BETWEEN PSV_CERT_FDT AND PSV_CERT_TDT
                AND     CCC.USE_YN   = 'Y'
            )
            SELECT  OT_CPN_RSLT
                   (
                    MYREC.COMP_CD
                  , MYREC.COUPON_CD
                  , NVL(SUM(CASE WHEN R_NUM = 1 THEN 1                     ELSE 0 END), 0)
                  , COUNT(*)
                  , NVL(SUM(CASE WHEN R_NUM = 1 THEN GRD_I_AMT + GRD_O_AMT ELSE 0 END), 0)
                   )
            BULK COLLECT  INTO  S_TBL_CPN_RSLT        
            FROM   (          
                    SELECT  /*+ INDEX(HD PK_SALE_HD) */
                            HD.COMP_CD
                          , HD.BRAND_CD
                          , HD.SALE_DT
                          , HD.STOR_CD
                          , HD.POS_NO
                          , HD.BILL_NO
                          , GRD_I_AMT
                          , GRD_O_AMT
                          , ROW_NUMBER() OVER(PARTITION BY HD.CUST_ID ORDER BY HD.COMP_CD, HD.SALE_DT, HD.STOR_CD, HD.POS_NO, HD.BILL_NO) AS R_NUM
                    FROM    SALE_HD   HD
                    WHERE   HD.COMP_CD   = MYREC.COMP_CD
                    AND     HD.SALE_DT  >= PSV_CERT_FDT
                    AND     HD.SALE_DT  <= PSV_CERT_TDT
                    AND     EXISTS (
                                    SELECT  1
                                    FROM    V1_CC CC
                                    WHERE   HD.CUST_ID = CC.CUST_ID
                                    AND     HD.SALE_DT  >= CC.MIN_CERT_FDT
                                   )
                   );

            M_TBL_CPN_RSLT.EXTEND;
            M_TBL_CPN_RSLT(M_TBL_CPN_RSLT.LAST) := S_TBL_CPN_RSLT(S_TBL_CPN_RSLT.LAST);
    END LOOP;


    RETURN M_TBL_CPN_RSLT;
END;

/
