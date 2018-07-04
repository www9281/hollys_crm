--------------------------------------------------------
--  DDL for Procedure BATCH_C_CUST_CREATE_COUPON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_C_CUST_CREATE_COUPON" (
    O_RTN_CD  OUT VARCHAR2
) IS
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-24
    -- Description   :   12+1 쿠폰 발급(매일 11시 30분)
    -- ==========================================================================================
    
    -- 쿠폰생성 건수가 있는 대상자를 추려 쿠폰발행
    FOR CUR IN (
                SELECT 
                  A.CUST_ID
                  ,TRUNC(A.C_CNT/12) AS ISSUE_CNT
                FROM (
                      SELECT  CRD.CUST_ID
                            , SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) AS C_CNT
                      FROM    C_CUST              CST
                            , C_CARD              CRD
                            , C_CARD_SAV_USE_HIS  HIS
                      WHERE   CST.COMP_CD  = CRD.COMP_CD
                      AND     CST.CUST_ID  = CRD.CUST_ID 
                      AND     CRD.COMP_CD  = HIS.COMP_CD
                      AND     CRD.CARD_ID  = HIS.CARD_ID 
                      AND     CRD.COMP_CD  = '016'
                      AND     HIS.SAV_MLG != HIS.USE_MLG
                      AND     HIS.LOS_MLG_YN  = 'N'
                      GROUP BY CRD.CUST_ID
                  )A WHERE C_CNT >= 12)
    LOOP
      -- 회원별 발행쿠폰 갯수만큼 쿠폰생성
      FOR i IN 1..CUR.ISSUE_CNT
      LOOP
         -- 왕관 12개당 1개씩 발행
         FOR MYREC IN (
                        SELECT  HIS.COMP_CD
                              , HIS.CARD_ID
                              , HIS.USE_DT
                              , HIS.USE_SEQ
                              , HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE AS REM_MLG
                              , SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) OVER(ORDER BY HIS.INST_DT, ROWNUM) AS REM_MLG_ACC
                              , SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) OVER() AS REM_MLG_TOT
                              , CRD.MEMB_DIV
                        FROM    C_CUST              CST
                              , C_CARD              CRD
                              , C_CARD_SAV_USE_HIS  HIS
                        WHERE   CST.COMP_CD  = CRD.COMP_CD
                        AND     CST.CUST_ID  = CRD.CUST_ID
                        AND     CRD.COMP_CD  = HIS.COMP_CD
                        AND     CRD.CARD_ID  = HIS.CARD_ID
                        AND     CRD.COMP_CD  = '016'
                        AND     CRD.CUST_ID  = CUR.CUST_ID
                        AND     HIS.SAV_MLG != HIS.USE_MLG
                        AND     HIS.LOS_MLG_YN  = 'N'
                      )
         LOOP
            UPDATE  C_CARD_SAV_USE_HIS
            SET     USE_MLG     = USE_MLG + CASE WHEN MYREC.REM_MLG_ACC > 12 THEN 12 - (MYREC.REM_MLG_ACC - MYREC.REM_MLG) ELSE MYREC.REM_MLG END
                  , UPD_DT      = SYSDATE
                  , UPD_USER    = 'CRM BATCH'
            WHERE   COMP_CD = MYREC.COMP_CD
            AND     CARD_ID = MYREC.CARD_ID
            AND     USE_DT  = MYREC.USE_DT
            AND     USE_SEQ = MYREC.USE_SEQ;
            
            -- 12개 단위로 사용처리
            EXIT WHEN MYREC.REM_MLG_ACC >= 12;
         END LOOP;
         
        -- 쿠폰 발행 이력 추가
        INSERT INTO C_CARD_SAV_COUPON_HIS (
          COMP_CD, CUST_ID, COUPON_SEQ, CRE_DT, USE_MLG
        ) VALUES (
          '016', CUR.CUST_ID, SQ_CARD_COUPON.NEXTVAL, TO_CHAR(SYSDATE, 'YYYYMMDD'), 12
        );
      END LOOP;
    END LOOP;
    O_RTN_CD := '1';
EXCEPTION
  WHEN OTHERS THEN
    O_RTN_CD := '2';
END BATCH_C_CUST_CREATE_COUPON;

/
