--------------------------------------------------------
--  DDL for Procedure C_CUST_CROWN_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CROWN_SAVE" 
IS
        CURSOR_USE_SEQ	        NUMBER;
        CURSOR_COMP_CD	        VARCHAR2(3);
        CURSOR_STOR_CD	        VARCHAR2(20);
        CURSOR_BRAND_CD	        VARCHAR2(10);
        CURSOR_POS_NO	          VARCHAR2(2);
        CURSOR_BILL_NO	        VARCHAR2(5);
        CURSOR_CARD_ID	        VARCHAR2(100);
        CURSOR_CUST_ID	        VARCHAR2(30);
        CURSOR_USE_DT	          VARCHAR2(8);
        CURSOR_SAV_USE_DIV	    VARCHAR2(10);
        CURSOR_SAV_MLG	        NUMBER;
        CURSOR_ADD_MLG	        NUMBER;
        CURSOR_LOS_MLG          NUMBER;
        CURSOR_ORG_USE_DT	      VARCHAR2(8);
        CURSOR_ORG_USE_SEQ	    NUMBER;
        CURSOR_ORG_PRMT_USE_SEQ	NUMBER;
        CURSOR_REG_DATE	        DATE;
        CURSOR_LOS_MLG_YN       VARCHAR2(10);
        CURSOR_LOS_MLG_DT       VARCHAR2(10);
        O_RTN_CD                VARCHAR2(10);
        v_dup_cust  VARCHAR2(10);
        v_card_id   VARCHAR2(100);
        v_cust_stat VARCHAR2(10);
BEGIN
        DECLARE   CURSOR  CURSOR_CROWN IS
        SELECT    USE_SEQ,
                  COMP_CD,
                  STOR_CD,
                  BRAND_CD,
                  POS_NO,
                  BILL_NO,
                  CARD_ID,
                  CUST_ID,
                  USE_DT,
                  SAV_USE_DIV,
                  SAV_MLG,
                  ADD_MLG,
                  ORG_USE_DT,
                  ORG_USE_SEQ,
                  ORG_PRMT_USE_SEQ,
                  REG_DATE,
                  LOS_MLG_YN,
                  LOS_MLG_DT,
                  LOS_MLG
        FROM      C_CUST_CROWN 
        WHERE     RESULT IS NULL
        ORDER BY USE_SEQ ASC;
                  
        BEGIN     OPEN    CURSOR_CROWN;
                  LOOP
                          FETCH CURSOR_CROWN
                          INTO  CURSOR_USE_SEQ,
                                CURSOR_COMP_CD,
                                CURSOR_STOR_CD,
                                CURSOR_BRAND_CD,
                                CURSOR_POS_NO,
                                CURSOR_BILL_NO,
                                CURSOR_CARD_ID,
                                CURSOR_CUST_ID,
                                CURSOR_USE_DT,
                                CURSOR_SAV_USE_DIV,
                                CURSOR_SAV_MLG,
                                CURSOR_ADD_MLG,
                                CURSOR_ORG_USE_DT,
                                CURSOR_ORG_USE_SEQ,
                                CURSOR_ORG_PRMT_USE_SEQ,
                                CURSOR_REG_DATE,
                                CURSOR_LOS_MLG_YN,
                                CURSOR_LOS_MLG_DT,
                                CURSOR_LOS_MLG;
                          
                          EXIT  WHEN  CURSOR_CROWN%NOTFOUND;
                          IF CURSOR_CARD_ID IS NULL THEN
                            SELECT MAX(CARD_ID) INTO v_card_id
                            FROM C_CARD 
                            WHERE CUST_ID = CURSOR_CUST_ID
                              AND REP_CARD_YN = 'Y'
                              AND USE_YN = 'Y';
                            CONTINUE WHEN v_card_id IS NULL;
                          ELSE 
                            v_card_id := CURSOR_CARD_ID;
                          END IF;
                          
                          -- 정상회원만 등급업 및 12+1쿠폰 증정을 위해 고객 등급확인
                          SELECT MAX(CUST_STAT) INTO v_cust_stat 
                          FROM C_CUST A, C_CARD B
                          WHERE B.CARD_ID = v_card_id
                            AND A.CUST_ID = B.CUST_ID;
                          
                          MERGE INTO C_CARD_SAV_USE_HIS
                          USING DUAL
                          ON (
                                  COMP_CD     = CURSOR_COMP_CD
                              AND CARD_ID     = v_card_id
                              AND USE_DT      = CURSOR_USE_DT
                              AND USE_SEQ     = CURSOR_USE_SEQ
                             )
                          WHEN MATCHED THEN
                              UPDATE  
                              SET SAV_USE_FG    = '1'
                                , SAV_USE_DIV   = CURSOR_SAV_USE_DIV
                                , SAV_MLG       = (NVL(CURSOR_SAV_MLG, 0) + NVL(CURSOR_ADD_MLG, 0))
                                , LOS_MLG_UNUSE = CASE WHEN CURSOR_LOS_MLG_YN = 'Y' THEN NVL(CURSOR_SAV_MLG, 0) - NVL(USE_MLG, 0) ELSE 0 END
                                , LOS_MLG       = NVL(CURSOR_LOS_MLG, 0)
                                , LOS_MLG_YN    = CURSOR_LOS_MLG_YN
                                , LOS_MLG_DT    = CURSOR_LOS_MLG_DT
                                , USE_YN        = 'Y'
                                , UPD_DT        = SYSDATE
                                , UPD_USER      = 'SYSTEM'
                                , USE_DIV       = '0'       
                                , ORG_USE_DT    = CURSOR_ORG_USE_DT
                                , ORG_USE_SEQ   = CURSOR_ORG_USE_SEQ
                                , STOR_CD       = CURSOR_STOR_CD
                          WHEN NOT MATCHED THEN
                              INSERT 
                                 (
                                  COMP_CD      ,      CARD_ID
                                , USE_DT       ,      USE_SEQ
                                , SAV_USE_FG   ,      SAV_USE_DIV
                                , SAV_MLG      ,      USE_MLG
                                , LOS_MLG_UNUSE
                                , LOS_MLG      ,      LOS_MLG_YN   
                                , LOS_MLG_DT   ,      USE_YN       
                                , INST_DT      ,      INST_USER
                                , UPD_DT       ,      UPD_USER
                                , MEMB_DIV
                                , ORG_USE_DT   ,      ORG_USE_SEQ
                                , STOR_CD
                                 )
                             VALUES
                                 (
                                  CURSOR_COMP_CD      ,     v_card_id
                                , CURSOR_USE_DT       ,     CURSOR_USE_SEQ
                                , '1'   ,     CURSOR_SAV_USE_DIV
                                , (NVL(CURSOR_SAV_MLG, 0) + NVL(CURSOR_ADD_MLG, 0)),     0
                                , CASE WHEN CURSOR_LOS_MLG_YN = 'Y' THEN (NVL(CURSOR_SAV_MLG, 0) + NVL(CURSOR_ADD_MLG, 0)) ELSE 0 END
                                , NVL(CURSOR_LOS_MLG, 0)    ,     CURSOR_LOS_MLG_YN
                                , CURSOR_LOS_MLG_DT ,     'Y'
                                , SYSDATE      ,     'SYSTEM'
                                , SYSDATE       ,    'SYSTEM'
                                , '0'
                                , CURSOR_ORG_USE_DT   ,     CURSOR_ORG_USE_SEQ
                                , CURSOR_STOR_CD 
                                );
                          
                          IF v_cust_stat != '1' AND v_cust_stat IS NOT NULL THEN
                            IF (NVL(CURSOR_SAV_MLG, 0) + NVL(CURSOR_ADD_MLG, 0)) > 0 THEN
                              C_CUST_CREATE_MEM_COUPON(CURSOR_CUST_ID, O_RTN_CD);
                            ELSE
                              C_CUST_CANCEL_MEM_COUPON(CURSOR_CUST_ID, CURSOR_ORG_USE_SEQ);
                            END IF;
                          END IF;
                          
                          UPDATE  C_CUST_CROWN
                          SET     RESULT = 1
                          WHERE   USE_SEQ = CURSOR_USE_SEQ;
                          
                  END LOOP;
        END;
END C_CUST_CROWN_SAVE;

/
