--------------------------------------------------------
--  DDL for Procedure C_CARD_POINT_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_POINT_INSERT" (
    P_COMP_CD      IN  VARCHAR2,    --회사코드
    P_CARD_ID      IN  VARCHAR2,    --카드번호
    P_USE_DT       IN  VARCHAR2,    --조정일자
    P_SAV_PT       IN  VARCHAR2,     --조정포인트
    P_SAV_USE_DIV  IN  VARCHAR2,    --조정구분
    P_SAV_PT_TYPE  IN  VARCHAR2,
    P_REMARKS      IN  VARCHAR2,    --조정사유
    N_BRAND_CD     IN  VARCHAR2,    
    N_STOR_CD      IN  VARCHAR2,
    N_POS_NO       IN  VARCHAR2,
    N_BILL_NO      IN  VARCHAR2,
    P_MY_USER_ID 	 IN  VARCHAR2,
    O_RTN_CD       OUT  VARCHAR2
) IS
    NOT_HAV_POINT EXCEPTION;
    v_cust_id VARCHAR2(30);
    v_use_pt NUMBER;
BEGIN
      --------------------------------- 포인트 조정 ---------------------------------- 
      IF P_SAV_PT_TYPE = '2' THEN
        SELECT CUST_ID INTO v_cust_id FROM C_CARD WHERE CARD_ID = ENCRYPT(P_CARD_ID);
        
        -- 적립취소 처리 시 현재 가용포인트보다 적으면 취소 처리 안됨
        SELECT  NVL(SUM(HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT_UNUSE), 0) INTO v_use_pt
        FROM    C_CUST                 CST
              , C_CARD                 CRD
              , C_CARD_SAV_USE_PT_HIS  HIS
        WHERE   CST.COMP_CD  = CRD.COMP_CD
        AND     CST.CUST_ID  = CRD.CUST_ID
        AND     CRD.COMP_CD  = HIS.COMP_CD
        AND     CRD.CARD_ID  = HIS.CARD_ID
        AND     CRD.COMP_CD  = '016'
        AND     CRD.CUST_ID  = v_cust_id
        AND     HIS.LOS_PT_YN  = 'N';
        
        IF v_use_pt < P_SAV_PT THEN
          RAISE NOT_HAV_POINT;
        END IF;
      END IF;
      
      INSERT INTO C_CARD_SAV_HIS( 
                COMP_CD
              , CARD_ID
              , USE_DT
              , USE_SEQ
              , SAV_PT
              , SAV_USE_DIV
              , REMARKS
              , BRAND_CD
              , STOR_CD
              , POS_NO
              , BILL_NO
              , USE_YN
              , INST_DT
              , INST_USER
              , LOS_PT_YN
              , LOS_PT_DT 
              , UPD_DT
              , UPD_USER  
              , SAV_USE_FG)
       VALUES ( 
              P_COMP_CD
              , encrypt(P_CARD_ID)
              , REPLACE(P_USE_DT, '-', '')
              , SQ_PCRM_SEQ.NEXTVAL
              , DECODE(P_SAV_PT_TYPE, '2', (P_SAV_PT*-1), P_SAV_PT)
              , P_SAV_USE_DIV
              , P_REMARKS
              , N_BRAND_CD
              , '106500'
              , N_POS_NO
              , N_BILL_NO
              , 'Y'
              , SYSDATE
              , P_MY_USER_ID
              , 'N'
              , TO_CHAR(ADD_MONTHS(TO_DATE(REPLACE(P_USE_DT, '-', ''), 'YYYYMMDD'), 12), 'YYYYMMDD') 
              , SYSDATE
              , P_MY_USER_ID
              , '3'
      );
      
      O_RTN_CD := '1';
EXCEPTION
  WHEN NOT_HAV_POINT THEN
    O_RTN_CD := '520';
END C_CARD_POINT_INSERT;

/
