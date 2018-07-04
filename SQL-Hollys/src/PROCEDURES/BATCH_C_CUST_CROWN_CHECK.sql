--------------------------------------------------------
--  DDL for Procedure BATCH_C_CUST_CROWN_CHECK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_C_CUST_CROWN_CHECK" 
IS
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-25
    -- Description   :   1. 승급일로부터 1년동안 적립갯수 못채울시 한단계 아래로 강등
    --                   2. 왕관 소멸일자체크 및 소멸작업
    -- ==========================================================================================
    ----------------------- 1. 승급일로부터 1년동안 적립갯수 못채울시 한단계 아래로 강등
    DECLARE
      v_tot_sav_mlg NUMBER;
    BEGIN
      FOR CUR IN ( 
                    SELECT
                      A.CUST_ID
                      ,A.LVL_CD
                      ,B.LVL_RANK
                      ,B.LVL_STD_STR
                      ,B.LVL_STD_END
                    FROM C_CUST A, C_CUST_LVL B
                    WHERE TO_CHAR(ADD_MONTHS(A.LVL_CHG_DT, 12), 'YYYYMMDD') <= TO_CHAR(SYSDATE, 'YYYYMMDD')
                      AND A.USE_YN = 'Y'
                      --AND A.LVL_CD NOT IN ('000', '101')
                      AND A.LVL_CD = B.LVL_CD
                 )
      LOOP
        IF CUR.LVL_CD IN ('000', '101') THEN
          UPDATE C_CUST SET
            LVL_CHG_DT = SYSDATE
          WHERE CUST_ID = CUR.CUST_ID;
        ELSE
          -- 등급변경일로부터 적립된 왕관 갯수 조회
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
            AND   CRD.CUST_ID  = CUR.CUST_ID
            AND   HIS.LOS_MLG_YN  = 'N';
          
          -- 왕관갯수가 현재 등급기준에 미치지 못할경우 등급 강등
          IF v_tot_sav_mlg < CUR.LVL_STD_STR THEN
            UPDATE C_CUST SET
              LVL_CD = (SELECT MAX(LVL_CD)  FROM C_CUST_LVL
                        WHERE LVL_STD_STR <= v_tot_sav_mlg
                          AND LVL_STD_END > v_tot_sav_mlg
                          AND LVL_CD <> '000')
              ,LVL_CHG_DT = SYSDATE
              ,LVL_CHG_DT_BACK = LVL_CHG_DT
              ,DEGRADE_YN = 'Y'
            WHERE CUST_ID = CUR.CUST_ID;
          ELSE
            UPDATE C_CUST SET
              LVL_CHG_DT = SYSDATE
              ,LVL_CHG_DT_BACK = LVL_CHG_DT
              ,DEGRADE_YN = 'Y'
            WHERE CUST_ID = CUR.CUST_ID;
          END IF;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
    END;
     
    
    ----------------------- 2. 왕관 소멸일자체크 및 소멸작업
    BEGIN
      -- 유효기간이 1년 된 정보를 조회하여 소멸처리
      FOR MLG IN (
                  SELECT
                    A.COMP_CD
                    ,A.CARD_ID
                    ,A.USE_DT
                    ,A.USE_SEQ
                  FROM C_CARD_SAV_HIS A
                  WHERE A.LOS_MLG_YN = 'N'
                    AND A.LOS_MLG_DT < TO_CHAR(SYSDATE, 'YYYYMMDD')
                    AND A.LOS_MLG_DT IS NOT NULL
                  )
      LOOP
        UPDATE C_CARD_SAV_HIS SET
          LOS_MLG_YN = 'Y'
          ,LOS_MLG = SAV_MLG
          ,UPD_DT = SYSDATE
          ,UPD_USER = 'CRM BATCH'
        WHERE COMP_CD = MLG.COMP_CD
          AND CARD_ID = MLG.CARD_ID
          AND USE_DT = MLG.USE_DT
          AND USE_SEQ = MLG.USE_SEQ;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
    END;
    
    ----------------------- 2-1. 왕관 소멸일자체크 및 소멸작업 C_CARD_SAV_USE_HIS    20180425 최인태 추가
    BEGIN
      -- 유효기간이 1년 된 정보를 조회하여 소멸처리
      FOR MLG_ IN (
                  SELECT
                    A.COMP_CD
                    ,A.CARD_ID
                    ,A.USE_DT
                    ,A.USE_SEQ
                  FROM C_CARD_SAV_USE_HIS A
                  WHERE A.LOS_MLG_YN = 'N'
                    AND A.LOS_MLG_DT < TO_CHAR(SYSDATE, 'YYYYMMDD')
                    AND A.LOS_MLG_DT IS NOT NULL
                  )
      LOOP
        UPDATE C_CARD_SAV_USE_HIS SET
          LOS_MLG_YN = 'Y'
          ,LOS_MLG = SAV_MLG
          ,UPD_DT = SYSDATE
          ,UPD_USER = 'CRM BATCH'
        WHERE COMP_CD = MLG_.COMP_CD
          AND CARD_ID = MLG_.CARD_ID
          AND USE_DT = MLG_.USE_DT
          AND USE_SEQ = MLG_.USE_SEQ;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
    END;
    
    ----------------------- 3. 포인트 소멸일자체크 및 소멸작업
    BEGIN
      -- 유효기간이 1년 된 정보를 조회하여 소멸처리
      FOR PT IN (
                  SELECT
                    A.COMP_CD
                    ,A.CARD_ID
                    ,A.USE_DT
                    ,A.USE_SEQ
                  FROM C_CARD_SAV_HIS A
                  WHERE A.LOS_PT_YN = 'N'
                    AND A.LOS_PT_DT < TO_CHAR(SYSDATE, 'YYYYMMDD')
                    AND A.LOS_PT_DT IS NOT NULL
                  )
      LOOP
        UPDATE C_CARD_SAV_HIS SET
          LOS_PT_YN = 'Y'
          ,LOS_PT = SAV_PT
          ,UPD_DT = SYSDATE
          ,UPD_USER = 'CRM BATCH'
        WHERE COMP_CD = PT.COMP_CD
          AND CARD_ID = PT.CARD_ID
          AND USE_DT = PT.USE_DT
          AND USE_SEQ = PT.USE_SEQ;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
    END;
END BATCH_C_CUST_CROWN_CHECK;

/
