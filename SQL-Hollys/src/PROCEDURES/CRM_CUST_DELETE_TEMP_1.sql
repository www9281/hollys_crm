--------------------------------------------------------
--  DDL for Procedure CRM_CUST_DELETE_TEMP_1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."CRM_CUST_DELETE_TEMP_1" 
IS
 CURSOR C_LIST IS
  select
      '016' AS COMP_CD
        ,ENCRYPT(A.CARD_ID) AS CARD_ID
        ,TO_CHAR(CAST(TO_TIMESTAMP(A.USE_DT, 'YYYY-MM-DD HH24:MI:SS.FF3') AS DATE), 'YYYYMMDD') AS USE_DT
        ,DECODE(A.SAV_USE_FG, '3', '3', '2', '4') AS SAV_USE_FG
        ,CASE WHEN A.SAV_USE_FG = '3' THEN '201'
              WHEN A.SAV_USE_FG = '2' AND A.USE_PT > 0 THEN '301'
              WHEN A.SAV_USE_FG = '2' AND A.USE_PT < 0 THEN '302'
              ELSE '' END AS SAV_USE_DIV
        ,CASE WHEN A.SAV_USE_FG = '3' THEN '포인트적립'
              WHEN A.SAV_USE_FG = '2' AND A.USE_PT > 0 THEN '포인트사용'
              WHEN A.SAV_USE_FG = '2' AND A.USE_PT < 0 THEN '포인트사용취소'
              ELSE '' END AS REMARKS
        ,A.SAV_PT AS SAV_PT
        ,A.USE_PT AS USE_PT
        ,'100' AS BRAND_CD
        ,NVL((SELECT STOR_CD FROM STORE_CD_MAP@HPOSDB WHERE ASIS_STOR_CD = A.STOR_CD), 'OLD_' || A.STOR_CD) AS STOR_CD
        ,A.POS_NO AS POS_NO
        ,A.BILL_NO AS BILL_NO
        ,TO_CHAR(CAST(TO_TIMESTAMP(A.USE_TM, 'YYYY-MM-DD HH24:MI:SS.FF3') AS DATE), 'HH24MISS') AS USE_TM
        ,'Y' AS USE_YN
        ,CAST(TO_TIMESTAMP(A.INST_DT, 'YYYY-MM-DD HH24:MI:SS.FF3') AS DATE) AS INST_DT
        ,'SYSTEM' AS INST_USER
        ,A.UPD_USER AS UPD_USER
        ,'N' AS LOS_PT_YN
        ,TO_CHAR(CAST(TO_TIMESTAMP(A.LOS_PT_DT, 'YYYY-MM-DD HH24:MI:SS.FF3') AS DATE), 'YYYYMMDD') AS LOS_PT_DT
    from C_CARD_SAV_HIS_TEMP_ACCDB A
    order by use_seq asc;
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-11
    -- API REQUEST   :   HLS_CRM_IF_0070
    -- Description   :   부정회원체크		
    -- ==========================================================================================
    FOR CUR IN C_LIST LOOP
      INSERT INTO C_CARD_SAV_HIS (
        COMP_CD
        ,CARD_ID
        ,USE_DT
        ,USE_SEQ
        ,SAV_USE_FG
        ,SAV_USE_DIV
        ,REMARKS
        ,SAV_PT
        ,USE_PT
        ,BRAND_CD
        ,STOR_CD
        ,POS_NO
        ,BILL_NO
        ,USE_TM
        ,USE_YN
        ,INST_DT
        ,INST_USER
        ,UPD_USER
        ,LOS_PT_YN
        ,LOS_PT_DT
      ) VALUES (
        CUR.COMP_CD
        ,CUR.CARD_ID
        ,CUR.USE_DT
        ,SQ_PCRM_SEQ.NEXTVAL
        ,CUR.SAV_USE_FG
        ,CUR.SAV_USE_DIV
        ,CUR.REMARKS
        ,CUR.SAV_PT
        ,CUR.USE_PT
        ,CUR.BRAND_CD
        ,CUR.STOR_CD
        ,CUR.POS_NO
        ,CUR.BILL_NO
        ,CUR.USE_TM
        ,CUR.USE_YN
        ,CUR.INST_DT
        ,CUR.INST_USER
        ,CUR.UPD_USER
        ,CUR.LOS_PT_YN
        ,CUR.LOS_PT_DT
      );
    END LOOP;
    
    
END CRM_CUST_DELETE_TEMP_1;

/
