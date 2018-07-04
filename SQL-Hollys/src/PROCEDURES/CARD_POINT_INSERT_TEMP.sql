--------------------------------------------------------
--  DDL for Procedure CARD_POINT_INSERT_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."CARD_POINT_INSERT_TEMP" 
IS
    v_result_cd VARCHAR2(7) := '1';
    v_cust_cnt NUMBER;
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-22
    -- Description   :   HOMEPAGE API용 고객 APP DEVICE정보 등록 및 수정
    -- ==========================================================================================
    
    
    FOR CUR IN (
                  SELECT * FROM (
                  SELECT A.*
                  FROM C_CARD_SAV_HIS_TEMP_ACCDB A
                  WHERE SAV_USE_FG = '3'
                    AND MIG_YN = 'N'
                  ORDER BY new_pk) WHERE ROWNUM <= 100
                )
    LOOP
      INSERT INTO C_CARD_SAV_HIS_PT (
        COMP_CD, CARD_ID, USE_DT,
        USE_SEQ, SAV_USE_FG, SAV_USE_DIV,
        REMARKS, SAV_PT, USE_PT,
        LOS_PT, LOS_PT_YN, LOS_PT_DT,
        BRAND_CD, STOR_CD, POS_NO,
        BILL_NO, USE_TM,
        USE_YN, INST_DT,
        INST_USER
      ) VALUES (
        '016', ENCRYPT(CUR.CARD_ID), TO_CHAR(TO_TIMESTAMP(CUR.USE_DT, 'YYYY-MM-DD HH24:MI:SS.FF3'), 'YYYYMMDD'),
        CUR.NEW_PK, CUR.SAV_USE_FG, '201',
        '포인트 적립', CUR.SAV_PT, CUR.USE_PT,
        CUR.LOS_PT, 'N', TO_CHAR(TO_TIMESTAMP(CUR.LOS_PT_DT, 'YYYY-MM-DD HH24:MI:SS.FF3'), 'YYYYMMDD'),
        '100', CUR.NEW_STOR_CD, CUR.POS_NO,
        CUR.BILL_NO, TO_CHAR(TO_TIMESTAMP(CUR.USE_TM, 'YYYY-MM-DD HH24:MI:SS.FF3'), 'HH24MISS'),
        'Y', CAST(TO_TIMESTAMP(CUR.INST_DT, 'YYYY-MM-DD HH24:MI:SS.FF3') AS DATE),
        'SYSTEM' 
      );
      
      UPDATE C_CARD_SAV_HIS_TEMP_ACCDB SET
        MIG_YN = 'Y'
      WHERE NEW_PK = CUR.NEW_PK;
    END LOOP;
END CARD_POINT_INSERT_TEMP;

/
