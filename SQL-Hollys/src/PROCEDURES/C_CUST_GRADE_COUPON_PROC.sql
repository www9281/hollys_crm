--------------------------------------------------------
--  DDL for Procedure C_CUST_GRADE_COUPON_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_GRADE_COUPON_PROC" (
  P_CUST_ID IN VARCHAR2
) IS
    v_lvl_chg_dt VARCHAR(8);
    v_sav_mlg NUMBER;
    v_tot_sav_mlg NUMBER;
    v_lvl_cd VARCHAR2(10);
    v_aaa varchar(100);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-23
    -- Description   :   회원 왕관 적립에 따른 등급변경
    -- ==========================================================================================
    
    ----------------------- 회원쿠폰 적립 갯수 조회하여 12+1 쿠폰 발행 및 왕관사용처리 ---------------------------
--    BEGIN
--      SELECT   
--        NVL(SUM(CASE WHEN HIS.SAV_MLG != HIS.USE_MLG AND HIS.LOS_MLG_YN  = 'N' THEN HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE ELSE 0 END), 0)
--        ,NVL(SUM(HIS.SAV_MLG), 0)
--        INTO v_sav_mlg, v_tot_sav_mlg
--      FROM    C_CUST              CST
--            , C_CARD              CRD
--            , C_CARD_SAV_USE_HIS  HIS
--      WHERE   CST.COMP_CD  = CRD.COMP_CD
--        AND   CST.CUST_ID  = CRD.CUST_ID
--        AND   CRD.COMP_CD  = HIS.COMP_CD
--        AND   CRD.CARD_ID  = HIS.CARD_ID
--        AND   CRD.COMP_CD  = '016'
--        AND   CRD.CUST_ID  = P_CUST_ID
--        AND   TO_DATE(CST.LVL_CHG_DT) <= TO_DATE(HIS.USE_DT);
--      
--      -- 적립쿠폰 12개 넘어갈 경우 쿠폰 발급 및 사용처리 로직 시작
--      IF v_sav_mlg >= 12 THEN
--        FOR MYREC IN (
--                        SELECT  HIS.COMP_CD
--                              , HIS.CARD_ID
--                              , HIS.USE_DT
--                              , HIS.USE_SEQ
--                              , HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE AS REM_MLG
--                              , SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) OVER(ORDER BY HIS.INST_DT) AS REM_MLG_ACC
--                              , SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) OVER() AS REM_MLG_TOT
--                              , CRD.MEMB_DIV
--                        FROM    C_CUST              CST
--                              , C_CARD              CRD
--                              , C_CARD_SAV_USE_HIS  HIS
--                        WHERE   CST.COMP_CD  = CRD.COMP_CD
--                        AND     CST.CUST_ID  = CRD.CUST_ID
--                        AND     CRD.COMP_CD  = HIS.COMP_CD
--                        AND     CRD.CARD_ID  = HIS.CARD_ID
--                        AND     CRD.COMP_CD  = '016'
--                        AND     CRD.CUST_ID  = P_CUST_ID
--                        AND     HIS.SAV_MLG != HIS.USE_MLG
--                        AND     HIS.LOS_MLG_YN  = 'N'
--                        AND     TO_DATE(CST.LVL_CHG_DT) <= TO_DATE(HIS.USE_DT)
--                      )
--        LOOP
--            UPDATE  C_CARD_SAV_USE_HIS
--            SET     USE_MLG     = USE_MLG + CASE WHEN MYREC.REM_MLG_ACC > 12 THEN 12 - (MYREC.REM_MLG_ACC - MYREC.REM_MLG) ELSE MYREC.REM_MLG END
--                  , USE_DIV     = '1' -- 쿠폰
--                  , UPD_DT      = SYSDATE
--                  , UPD_USER    = 'SYSTEM'
--            WHERE   COMP_CD = MYREC.COMP_CD
--            AND     CARD_ID = MYREC.CARD_ID
--            AND     USE_DT  = MYREC.USE_DT
--            AND     USE_SEQ = MYREC.USE_SEQ;
--            
--            -- 12개 단위로 사용처리
--            EXIT WHEN MYREC.REM_MLG_ACC >= 12;
--        END LOOP;
--        
--        -- 쿠폰 발행 이력 추가
--        INSERT INTO C_CARD_SAV_COUPON_HIS (
--          COMP_CD, CUST_ID, COUPON_SEQ, CRE_DT, USE_MLG
--        ) VALUES (
--          '016', P_CUST_ID, SQ_CARD_COUPON.NEXTVAL, TO_CHAR(SYSDATE, 'YYYYMMDD'), 12
--        );
--        
--        -- TODO 쿠폰 발행 프로시저 태워야함
--        
--      END IF;
--    END;
--    
    ----------------------- 등급 변경일로부터 적립왕관 갯수 체크하여 등급 조정 ---------------------------
    BEGIN
      SELECT  
        NVL(SUM(CASE WHEN CST.LVL_CHG_DT < HIS.INST_DT THEN HIS.SAV_MLG ELSE 0 END), 0)
        INTO v_tot_sav_mlg
      FROM    C_CUST              CST
            , C_CARD              CRD
            , C_CARD_SAV_USE_HIS  HIS
      WHERE   CST.COMP_CD  = CRD.COMP_CD
        AND   CST.CUST_ID  = CRD.CUST_ID
        AND   CRD.COMP_CD  = HIS.COMP_CD
        AND   CRD.CARD_ID  = HIS.CARD_ID
        AND   CRD.COMP_CD  = '016'
        AND   CRD.CUST_ID  = P_CUST_ID;
      
      
      FOR CUST IN (
                    SELECT
                      A.LVL_CD
                      ,A.LVL_CHG_DT
                      ,A.DEGRADE_YN
                      ,A.LVL_CHG_DT_BACK
                      ,B.LVL_RANK
                      ,B.LVL_STD_STR
                      ,B.LVL_STD_END
                    FROM C_CUST A, C_CUST_LVL B
                    WHERE A.CUST_ID = P_CUST_ID
                      AND A.USE_YN = 'Y'
                      AND A.LVL_CD = B.LVL_CD
                      AND A.LVL_CD <> '000'
                  )
      LOOP
        -- 현재등급 범위가 아닌경우 등급변경 (강등대상의경우 왕관적립이 기준에 못미치더라도 적립취소시 등급하락되지않음)
--        IF (v_tot_sav_mlg < CUST.LVL_STD_STR AND CUST.DEGRADE_YN != 'Y') AND v_tot_sav_mlg > 0 THEN
--          UPDATE C_CUST SET
--            LVL_CD = (SELECT
--                        LVL_CD
--                      FROM C_CUST_LVL
--                      WHERE v_tot_sav_mlg >= LVL_STD_STR
--                        AND v_tot_sav_mlg < LVL_STD_END
--                        AND LVL_CD <> '000')
--            ,LVL_CHG_DT = SYSDATE
--            ,DEGRADE_YN = 'N'
--            ,UPD_DT = SYSDATE
--            ,UPD_USER = 'SYSTEM'
--          WHERE CUST_ID = P_CUST_ID;
--        END IF;
        
        -- 취소시 이전등급으로 
        IF v_tot_sav_mlg < 0 AND CUST.DEGRADE_YN != 'Y' THEN
          UPDATE C_CUST SET
            LVL_CD = (SELECT
                        LVL_CD
                      FROM C_CUST_LVL
                      WHERE LVL_RANK = (CUST.LVL_RANK-1)
                        AND LVL_CD <> '000')
            ,LVL_CHG_DT = CUST.LVL_CHG_DT_BACK
            ,LVL_CHG_DT_BACK = ''
          WHERE CUST_ID = P_CUST_ID;
        END IF;
        
        IF (v_tot_sav_mlg + CUST.LVL_STD_STR ) >= CUST.LVL_STD_END THEN
          UPDATE C_CUST SET
            LVL_CD = (SELECT
                        LVL_CD
                      FROM C_CUST_LVL
                      WHERE (v_tot_sav_mlg + CUST.LVL_STD_STR ) >= LVL_STD_STR
                        AND (v_tot_sav_mlg + CUST.LVL_STD_STR ) < LVL_STD_END
                        AND LVL_CD <> '000')
            ,LVL_CHG_DT = SYSDATE
            ,LVL_CHG_DT_BACK = LVL_CHG_DT
            ,DEGRADE_YN = 'N'
            ,UPD_DT = SYSDATE
            ,UPD_USER = 'SYSTEM'
          WHERE CUST_ID = P_CUST_ID;
        END IF;
      END LOOP;
    END;
    
END C_CUST_GRADE_COUPON_PROC;

/
