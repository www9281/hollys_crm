--------------------------------------------------------
--  DDL for Procedure C_CARD_SAV_HIS_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_SAV_HIS_INSERT" (
    P_COMP_CD      IN  VARCHAR2,    --회사코드
    P_CARD_ID      IN  VARCHAR2,    --카드번호
    P_USE_DT       IN  VARCHAR2,    --조정일자
    P_SAV_MLG      IN  VARCHAR2,    --조정크라운
    P_SAV_MLG_TYPE IN  VARCHAR2,
    P_SAV_USE_DIV  IN  VARCHAR2,    --조정구분
    P_REMARKS      IN  VARCHAR2,    --조정사유
    N_BRAND_CD     IN  VARCHAR2,    
    N_STOR_CD      IN  VARCHAR2,
    N_POS_NO       IN  VARCHAR2,
    N_BILL_NO      IN  VARCHAR2,
    P_MY_USER_ID 	 IN  VARCHAR2,
    O_RTN_CD       OUT VARCHAR2
) IS
  v_cust_id VARCHAR2(30);
  v_cust_stat VARCHAR2(10);
  v_tot_store_mlg  NUMBER;
  v_lvl_cd  VARCHAR2(10); 
  v_now_lvl VARCHAR2(10);
BEGIN 
      ----------------------- 왕관조정 저장 -----------------------
      INSERT INTO C_CUST_CROWN (
        USE_SEQ
        ,COMP_CD
        ,STOR_CD
        ,BRAND_CD
        ,POS_NO
        ,BILL_NO
        ,CARD_ID
        ,CUST_ID
        ,USE_DT
        ,SAV_USE_DIV
        ,SAV_MLG
        ,ADD_MLG
        ,LOS_MLG_YN
        ,LOS_MLG_DT
        ,NOTES
        ,RESULT
      ) VALUES (
        SQ_CROWN_SEQ.NEXTVAL
        ,P_COMP_CD
        ,'180250'
        ,N_BRAND_CD
        ,N_POS_NO
        ,N_BILL_NO
        ,encrypt(P_CARD_ID)
        ,(SELECT CUST_ID FROM C_CARD WHERE CARD_ID = encrypt(P_CARD_ID))
        ,REPLACE(P_USE_DT, '-', '')
        ,P_SAV_USE_DIV
        ,DECODE(P_SAV_MLG_TYPE, '2', (P_SAV_MLG*-1), P_SAV_MLG)
        ,0
        ,'N'
        ,TO_CHAR(ADD_MONTHS(TO_DATE(REPLACE(P_USE_DT, '-', ''), 'YYYYMMDD'), 12), 'YYYYMMDD') 
        ,P_REMARKS
        ,NULL
      );
--    
--      INSERT INTO C_CARD_SAV_HIS(
--                COMP_CD 
--              , CARD_ID
--              , USE_DT
--              , USE_SEQ
--              , SAV_MLG
--              , SAV_USE_DIV
--              , REMARKS
--              , BRAND_CD
--              , STOR_CD
--              , POS_NO
--              , BILL_NO
--              , USE_YN
--              , INST_DT
--              , INST_USER 
--              , LOS_MLG_DT 
--              , UPD_DT
--              , UPD_USER
--              , SAV_USE_FG
--              , MEMB_DIV)
--       VALUES ( P_COMP_CD
--              , encrypt(P_CARD_ID)
--              , REPLACE(P_USE_DT, '-', '')
--              , SQ_PCRM_SEQ.NEXTVAL
--              , DECODE(P_SAV_MLG_TYPE, '2', (P_SAV_MLG*-1), P_SAV_MLG)
--              , P_SAV_USE_DIV
--              , P_REMARKS
--              , N_BRAND_CD
--              , '106500'
--              , N_POS_NO
--              , N_BILL_NO
--              , 'Y'
--              , SYSDATE
--              , P_MY_USER_ID
--              , TO_CHAR(ADD_MONTHS(TO_DATE(REPLACE(P_USE_DT, '-', ''), 'YYYYMMDD'), 12), 'YYYYMMDD') 
--              , SYSDATE
--              , P_MY_USER_ID
--              , '1' 
--              ,(
--                SELECT  MEMB_DIV 
--                FROM    C_CARD
--                WHERE   COMP_CD = P_COMP_CD
--                AND     CARD_ID = encrypt(P_CARD_ID)
--               )
--      );
--      
--      SELECT
--        A.CUST_ID, (SELECT CUST_STAT FROM C_CUST WHERE CUST_ID = A.CUST_ID) INTO v_cust_id, v_cust_stat
--      FROM C_CARD A
--      WHERE A.CARD_ID = encrypt(P_CARD_ID);
--      
--      IF P_SAV_MLG_TYPE = '2' AND v_cust_stat = '2' THEN
--        SELECT  
--          NVL(SUM(HIS.SAV_MLG), 0), MAX(CST.LVL_CD)
--          INTO v_tot_store_mlg, v_now_lvl
--        FROM    C_CUST              CST
--              , C_CARD              CRD
--              , C_CARD_SAV_USE_HIS  HIS
--        WHERE   CST.COMP_CD  = CRD.COMP_CD
--          AND   CST.CUST_ID  = CRD.CUST_ID
--          AND   CRD.COMP_CD  = HIS.COMP_CD
--          AND   CRD.CARD_ID  = HIS.CARD_ID
--          AND   CRD.COMP_CD  = '016'
--          AND   CRD.CUST_ID  = v_cust_id
--          AND   HIS.LOS_MLG_YN  = 'N';
--        
--        IF v_tot_store_mlg < 0 THEN
--          v_tot_store_mlg := 0;
--        END IF;
--        
--        SELECT MAX(LVL_CD) INTO v_lvl_cd FROM C_CUST_LVL
--        WHERE LVL_STD_STR <= v_tot_store_mlg
--          AND LVL_STD_END > v_tot_store_mlg
--          AND LVL_CD <> '000'
--          AND LVL_CD <= v_now_lvl;
--      
--        IF v_lvl_cd IS NOT NULL AND v_lvl_cd <> v_now_lvl THEN
--          UPDATE C_CUST SET 
--            LVL_CD = v_lvl_cd
--            ,LVL_CHG_DT = SYSDATE
--            ,LVL_CHG_DT_BACK = ''
--          WHERE CUST_ID = v_cust_id;
--        END IF;
--      ELSIF v_cust_stat = '2' THEN
--        C_CUST_CREATE_MEM_COUPON(v_cust_id, O_RTN_CD);        
--      END IF;
END C_CARD_SAV_HIS_INSERT;

/
