--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SAV_POINT_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SAV_POINT_SELECT" (
      P_COMP_CD       IN  VARCHAR2,
      P_BRAND_CD      IN  VARCHAR2,
      P_USER_ID       IN  VARCHAR2,
      P_CUST_ID       IN  VARCHAR2,
      O_RTN_CD        OUT VARCHAR2,
      O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_result_cd VARCHAR2(7) := '1';
BEGIN
      -- ==========================================================================================
      -- Author        :   박동수
      -- Create date   :   2017-11-15
      -- API REQUEST   :   HLS_CRM_IF_0007
      -- Description   :   회원 포인트 정보		
      -- ==========================================================================================
      OPEN O_CURSOR FOR 
      SELECT  
        SUM(HIS.SAV_PT) AS SAV_PT
        , SUM(HIS.USE_PT) AS USE_PT
        , SUM(HIS.LOS_PT_UNUSE) AS LOS_PT
        , SUM(CASE WHEN LOS_PT_YN = 'N' THEN HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT_UNUSE ELSE 0 END) AS TOT_SAV_PT
      FROM    C_CUST                 CST
            , C_CARD                 CRD
            , C_CARD_SAV_USE_PT_HIS  HIS
      WHERE   CST.COMP_CD  = CRD.COMP_CD
      AND     CST.CUST_ID  = CRD.CUST_ID
      AND     CRD.COMP_CD  = HIS.COMP_CD
      AND     CRD.CARD_ID  = HIS.CARD_ID
      AND     CRD.COMP_CD  = P_COMP_CD
      AND     CRD.CUST_ID  = P_CUST_ID;
      
      O_RTN_CD := v_result_cd;
EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2';
END API_C_CUST_SAV_POINT_SELECT;

/
