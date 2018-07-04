--------------------------------------------------------
--  DDL for Procedure C_CUST_POINT_USE_HIS_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_POINT_USE_HIS_PROC" (
  P_CUST_ID IN VARCHAR2,
  P_SAV_USE_DIV IN  VARCHAR2,
  P_USE_PT IN  NUMBER
) IS
  v_use_pt NUMBER := P_USE_PT;
  v_sum_use_pt NUMBER;
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-29
    -- Description   :   회원 포인트 사용  따른 처리 프로세스
    -- ==========================================================================================
    ------------------------------ 1. 포인트 사용
    IF P_SAV_USE_DIV = '301' THEN
      FOR PT IN ( 
                  SELECT  HIS.COMP_CD
                        , HIS.CARD_ID
                        , HIS.USE_DT
                        , HIS.USE_SEQ
                        , HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT_UNUSE AS REM_MLG
                  FROM    C_CUST CST
                        , C_CARD                 CRD
                        , C_CARD_SAV_USE_PT_HIS  HIS
                  WHERE   CST.COMP_CD  = CRD.COMP_CD
                  AND     CST.CUST_ID  = CRD.CUST_ID
                  AND     CRD.COMP_CD  = HIS.COMP_CD
                  AND     CRD.CARD_ID  = HIS.CARD_ID
                  AND     CRD.COMP_CD  = '016'
                  AND     CRD.CUST_ID  = P_CUST_ID
                  AND     HIS.SAV_PT != HIS.USE_PT
                  AND     HIS.LOS_PT_YN  = 'N'
                  ORDER BY HIS.USE_SEQ ASC
                )
      LOOP
        IF v_use_pt - PT.REM_MLG >= 0 THEN
          v_sum_use_pt := PT.REM_MLG;
        ELSE
          v_sum_use_pt := v_use_pt;
        END IF;
        
        UPDATE C_CARD_SAV_USE_PT_HIS SET
          USE_PT = USE_PT + v_sum_use_pt
          ,UPD_DT = SYSDATE
          ,UPD_USER = 'SYSTEM'
        WHERE COMP_CD = PT.COMP_CD
          AND CARD_ID = PT.CARD_ID
          AND USE_DT = PT.USE_DT
          AND USE_SEQ = PT.USE_SEQ;
          
        v_use_pt := v_use_pt - PT.REM_MLG;
        
        EXIT WHEN v_use_pt <= 0;
      END LOOP;
    END IF;
    
    ------------------------------ 2. 포인트 사용취소
    IF P_SAV_USE_DIV = '302' THEN
      FOR PT IN (
                  SELECT  HIS.COMP_CD
                        , HIS.CARD_ID
                        , HIS.USE_DT
                        , HIS.USE_SEQ
                        , HIS.SAV_PT
                        , HIS.USE_PT
                        , HIS.LOS_PT_UNUSE
                  FROM    C_CUST                 CST
                        , C_CARD                 CRD
                        , C_CARD_SAV_USE_PT_HIS  HIS
                  WHERE   CST.COMP_CD  = CRD.COMP_CD
                  AND     CST.CUST_ID  = CRD.CUST_ID
                  AND     CRD.COMP_CD  = HIS.COMP_CD
                  AND     CRD.CARD_ID  = HIS.CARD_ID
                  AND     CRD.COMP_CD  = '016'
                  AND     CRD.CUST_ID  = P_CUST_ID
                  AND     HIS.USE_PT != '0'
                  AND     HIS.LOS_PT_YN  = 'N'
                  ORDER BY HIS.USE_SEQ DESC
                )
      LOOP
        UPDATE C_CARD_SAV_USE_PT_HIS SET
          USE_PT = (CASE WHEN v_use_pt - PT.USE_PT > 0 THEN 0 ELSE USE_PT - v_use_pt END)
          ,UPD_DT = SYSDATE
          ,UPD_USER = 'SYSTEM'
        WHERE COMP_CD = PT.COMP_CD
          AND CARD_ID = PT.CARD_ID
          AND USE_DT = PT.USE_DT
          AND USE_SEQ = PT.USE_SEQ;
         
        v_use_pt := v_use_pt - PT.USE_PT;
        
        EXIT WHEN v_use_pt <= 0;
      END LOOP;
    
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('SQLERRM ::::: ' || SQLERRM);
END C_CUST_POINT_USE_HIS_PROC;

/
