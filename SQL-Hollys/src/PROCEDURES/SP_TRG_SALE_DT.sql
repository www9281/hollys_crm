--------------------------------------------------------
--  DDL for Procedure SP_TRG_SALE_DT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_TRG_SALE_DT" 
(
  prv_sale_dt      IN  PKG_TYPE.TRG_SALE_DT ,
  psr_return_cd   OUT  NUMBER, -- 메세지코드
  psr_msg         OUT  STRING  -- 메세지
) IS 
--------------------------------------------------------------------------------
--  Procedure Name   : SP_TRG_SALE_DT
--  Description      : SALE_DT TRIGGER 프로시저
--  Ref. Table       : SALE_DT
--------------------------------------------------------------------------------
--  Create Date      : 2010-03-26
--  Modify Date      : 2013-09-17 엠즈씨드 TSMS PJT
--  Modify Date      : 2014-12-23 엠즈씨드 CRM PJT
--------------------------------------------------------------------------------
  liv_msg_code    NUMBER(9) := 0;
  lsv_msg_text    VARCHAR2(500);
  
  ls_stor_tp      STORE.STOR_TP%TYPE;
  
  ls_void_dt      SALE_HD.VOID_BEFORE_DT%TYPE;
  ls_void_no      SALE_HD.VOID_BEFORE_NO%TYPE;
  
  ll_cust_age     C_CUST_MAC.CUST_AGE%TYPE;  -- 회원 연령
  ls_cust_sex     C_CUST.SEX_DIV%TYPE;       -- 회원 성별
  ls_cust_lvl     C_CUST.LVL_CD%TYPE;        -- 회원 등급
  
  ls_skip         VARCHAR2(1);
  ll_reccnt       NUMBER(9) := 0;             -- 레코드 건수
  
  ERR_HANDLER     EXCEPTION;
  
FUNCTION IS_SETITEM
    RETURN BOOLEAN
IS
    L_SET_DIV      ITEM.SET_DIV%TYPE;
BEGIN
    BEGIN
        SELECT  T1.SET_DIV
        INTO    L_SET_DIV
        FROM    ITEM_CHAIN T1
             ,  STORE      T2
        WHERE   T1.BRAND_CD  = prv_sale_dt.BRAND_CD
        AND     T1.STOR_TP   = T2.STOR_TP
        AND     T1.ITEM_CD   = prv_sale_dt.ITEM_CD
        AND     T2.BRAND_CD  = T1.BRAND_CD
        AND     T2.STOR_CD   = prv_sale_dt.STOR_CD;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            BEGIN
                SELECT  SET_DIV
                INTO    L_SET_DIV
                FROM    ITEM
                WHERE   ITEM_CD   = prv_sale_dt.ITEM_CD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    L_SET_DIV := NULL;
            END;
    END IS_SETITEM;
    
    RETURN L_SET_DIV = '1';
END;
  
--FUNCTION IS_PARENTITEM
--    RETURN BOOLEAN
--IS
--    L_PARENT_ITEM_YN      ITEM.PARENT_ITEM_YN%TYPE;
--    
--    BEGIN 
--        BEGIN
--          SELECT T1.PARENT_ITEM_YN
--            INTO L_PARENT_ITEM_YN
--            FROM ITEM_CHAIN T1
--               , STORE      T2
--           WHERE T1.BRAND_CD  = prv_sale_dt.BRAND_CD
--             AND T1.STOR_TP   = T2.STOR_TP
--             AND T1.ITEM_CD   = prv_sale_dt.ITEM_CD
--             AND T2.BRAND_CD  = T1.BRAND_CD
--             AND T2.STOR_CD   = prv_sale_dt.STOR_CD;
--        EXCEPTION
--          WHEN NO_DATA_FOUND THEN
--               BEGIN
--                 SELECT PARENT_ITEM_YN
--                   INTO L_PARENT_ITEM_YN
--                   FROM ITEM
--                  WHERE ITEM_CD   = prv_sale_dt.ITEM_CD;
--               EXCEPTION
--                 WHEN NO_DATA_FOUND THEN
--                      L_PARENT_ITEM_YN := NULL;
--               END;
--        END;
--        
--        RETURN NVL(L_PARENT_ITEM_YN, 'N') = 'Y';
--    END IS_PARENTITEM;
  
    BEGIN
        liv_msg_code    := 0;
        lsv_msg_text    := ' ';
        
        SELECT  STOR_TP
        INTO    ls_stor_tp
        FROM    STORE
        WHERE   BRAND_CD = prv_sale_dt.brand_cd
        AND     STOR_CD  = prv_sale_dt.stor_cd;
         
        SELECT  VOID_BEFORE_DT, VOID_BEFORE_NO
        INTO    ls_void_dt, ls_void_no
        FROM    SALE_HD
        WHERE   SALE_DT  = prv_sale_dt.sale_dt
        AND     BRAND_CD = prv_sale_dt.brand_cd
        AND     STOR_CD  = prv_sale_dt.stor_cd
        AND     POS_NO   = prv_sale_dt.pos_no
        AND     BILL_NO  = prv_sale_dt.bill_no;
           
        IF prv_sale_dt.GIFT_DIV = '0' AND prv_sale_dt.FREE_DIV IN('0', '1') THEN -- GIFT_DIV 0:정상판매, FREE_DIV 0:정상판매, 1:무표쿠폰
        -- t_seq = 0 일때만 SALE_JTM, SALE_JDM, SALE_JMM 누적
        -- 위 요건을 아래와 같이 변경함
        -- (세트상품이 아니고 부모상품도 아닐때 또는 업차지 부가상품일때 집계)
        -- IF prv_sale_dt.t_seq = 0 or  prv_sale_dt.sub_touch_div  = '2' THEN
        -- IF (NOT IS_SETITEM AND NOT IS_PARENTITEM) OR (prv_sale_dt.SUB_TOUCH_DIV = '2') THEN
--            IF (prv_sale_dt.T_SEQ = 0 OR  prv_sale_dt.SUB_TOUCH_DIV  = '2') AND NOT IS_PARENTITEM THEN -- [T_SEQ 0:SET 메뉴 구성품 제외, 부가메뉴 제외], [SUB_TOUCH_DIV 2:UPCHARGE], 부모메뉴가 아니면
            IF (prv_sale_dt.T_SEQ = 0 OR  prv_sale_dt.SUB_TOUCH_DIV  = '2') THEN -- [T_SEQ 0:SET 메뉴 구성품 제외, 부가메뉴 제외], [SUB_TOUCH_DIV 2:UPCHARGE], 부모메뉴가 아니면
                IF prv_sale_dt.CUST_ID IS NOT NULL THEN -- 회원 ID가 있을 경우
                    BEGIN
                        SELECT  CASE WHEN REGEXP_INSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, '^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])') = 1 THEN
                                        TRUNC((SUBSTR(prv_sale_dt.SALE_DT, 1, 6) - SUBSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, 1, 6)) / 100 + 1)
                                     ELSE 999 
                                END,
                                SEX_DIV, LVL_CD
                        INTO    ll_cust_age, ls_cust_sex, ls_cust_lvl
                        FROM    C_CUST
                        WHERE   COMP_CD   = '016'
                        AND     CUST_ID   = prv_sale_dt.CUST_ID
                        AND     CUST_STAT IN ('1', '2')
                        AND     USE_YN    = 'Y';
                        
                        ls_skip := '1';
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            ls_skip  := '0';
                        WHEN OTHERS THEN
                            ls_skip  := '0';
                    END;
                END IF;
              
                /****************** CRM ********************/
                IF ls_skip = '1' THEN
                    -- 회원 상품별 월집계
                    BEGIN
                        MERGE   INTO C_CUST_MMS
                        USING   DUAL
                        ON     (
                                    COMP_CD      = '016'
                                AND SALE_YM      = SUBSTR(prv_sale_dt.SALE_DT, 1, 6)
                                AND BRAND_CD     = prv_sale_dt.BRAND_CD
                                AND STOR_CD      = prv_sale_dt.STOR_CD
                                AND CUST_ID      = prv_sale_dt.CUST_ID
                                AND CUST_LVL     = ls_cust_lvl
                                AND ITEM_CD      = prv_sale_dt.ITEM_CD
                               )
                        WHEN MATCHED THEN
                            UPDATE     
                            SET     CUST_AGE     = ll_cust_age
                                  , CUST_SEX     = ls_cust_sex
                                  , SALE_QTY     = SALE_QTY     + prv_sale_dt.SALE_QTY
                                  , SALE_AMT     = SALE_AMT     + prv_sale_dt.SALE_AMT
                                  , DC_AMT       = DC_AMT       + prv_sale_dt.DC_AMT
                                  , ENR_AMT      = ENR_AMT      + prv_sale_dt.ENR_AMT
                                  , GRD_AMT      = GRD_AMT      + prv_sale_dt.GRD_AMT
                                  , GRD_I_AMT    = GRD_I_AMT    + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                                  , GRD_O_AMT    = GRD_O_AMT    + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                                  , VAT_AMT      = VAT_AMT      + prv_sale_dt.VAT_AMT
                                  , VAT_I_AMT    = VAT_I_AMT    + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                                  , VAT_O_AMT    = VAT_O_AMT    + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                                  , RTN_QTY      = RTN_QTY      + CASE WHEN prv_sale_dt.SALE_DIV = '2' THEN prv_sale_dt.SALE_QTY ELSE 0 END
                                  , RTN_AMT      = RTN_AMT      + CASE WHEN prv_sale_dt.SALE_DIV = '2' THEN prv_sale_dt.GRD_AMT  ELSE 0 END
                        WHEN NOT MATCHED THEN
                            INSERT 
                                  (  
                                    COMP_CD
                                 ,  SALE_YM
                                 ,  BRAND_CD
                                 ,  STOR_CD
                                 ,  CUST_ID
                                 ,  CUST_LVL
                                 ,  ITEM_CD
                                 ,  CUST_AGE
                                 ,  CUST_SEX
                                 ,  SALE_QTY
                                 ,  SALE_AMT
                                 ,  DC_AMT
                                 ,  ENR_AMT
                                 ,  GRD_AMT
                                 ,  GRD_I_AMT
                                 ,  GRD_O_AMT
                                 ,  VAT_AMT
                                 ,  VAT_I_AMT
                                 ,  VAT_O_AMT
                                 ,  RTN_QTY
                                 ,  RTN_AMT
                                  )
                            VALUES 
                                  ( 
                                    '016'
                                 ,  SUBSTR(prv_sale_dt.SALE_DT, 1, 6)
                                 ,  prv_sale_dt.BRAND_CD
                                 ,  prv_sale_dt.STOR_CD
                                 ,  prv_sale_dt.CUST_ID
                                 ,  ls_cust_lvl
                                 ,  prv_sale_dt.ITEM_CD
                                 ,  ll_cust_age
                                 ,  ls_cust_sex
                                 ,  prv_sale_dt.SALE_QTY
                                 ,  prv_sale_dt.SALE_AMT
                                 ,  prv_sale_dt.DC_AMT
                                 ,  prv_sale_dt.ENR_AMT
                                 ,  prv_sale_dt.GRD_AMT
                                 ,  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                                 ,  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                                 ,  prv_sale_dt.VAT_AMT
                                 ,  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                                 ,  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                                 ,  CASE WHEN prv_sale_dt.SALE_DIV = '2' THEN prv_sale_dt.SALE_QTY ELSE 0 END
                                 ,  CASE WHEN prv_sale_dt.SALE_DIV = '2' THEN prv_sale_dt.GRD_AMT  ELSE 0 END
                                  );
                    EXCEPTION
                        WHEN OTHERS THEN
                            liv_msg_code := SQLCODE;
                            lsv_msg_text := 'CUST_MMS: ' || SQLERRM;
                            RAISE ERR_HANDLER;
                    END;
                  
                    BEGIN
                        -- 회원 상품별 일집계
                        MERGE   INTO C_CUST_DMS
                        USING   DUAL
                        ON     (
                                    COMP_CD   = '016'
                                AND SALE_DT   = prv_sale_dt.SALE_DT
                                AND BRAND_CD  = prv_sale_dt.BRAND_CD
                                AND STOR_CD   = prv_sale_dt.STOR_CD
                                AND CUST_ID   = prv_sale_dt.CUST_ID
                                AND ITEM_CD   = prv_sale_dt.ITEM_CD
                               )
                        WHEN MATCHED THEN      
                            UPDATE 
                            SET     CUST_AGE     = ll_cust_age
                                 ,  CUST_SEX     = ls_cust_sex
                                 ,  CUST_LVL     = ls_cust_lvl
                                 ,  SALE_QTY     = SALE_QTY     + prv_sale_dt.SALE_QTY
                                 ,  SALE_AMT     = SALE_AMT     + prv_sale_dt.SALE_AMT
                                 ,  DC_AMT       = DC_AMT       + prv_sale_dt.DC_AMT
                                 ,  ENR_AMT      = ENR_AMT      + prv_sale_dt.ENR_AMT
                                 ,  GRD_AMT      = GRD_AMT      + prv_sale_dt.GRD_AMT
                                 ,  GRD_I_AMT    = GRD_I_AMT    + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                                 ,  GRD_O_AMT    = GRD_O_AMT    + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                                 ,  VAT_AMT      = VAT_AMT      + prv_sale_dt.VAT_AMT
                                 ,  VAT_I_AMT    = VAT_I_AMT    + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                                 ,  VAT_O_AMT    = VAT_O_AMT    + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                                 ,  RTN_QTY      = RTN_QTY      + CASE WHEN prv_sale_dt.SALE_DIV = '2' THEN prv_sale_dt.SALE_QTY ELSE 0 END
                                 ,  RTN_AMT      = RTN_AMT      + CASE WHEN prv_sale_dt.SALE_DIV = '2' THEN prv_sale_dt.GRD_AMT  ELSE 0 END
                        WHEN NOT MATCHED THEN        
                            INSERT 
                                   ( 
                                    COMP_CD
                                 ,  SALE_DT
                                 ,  BRAND_CD
                                 ,  STOR_CD
                                 ,  CUST_ID
                                 ,  ITEM_CD
                                 ,  CUST_AGE
                                 ,  CUST_SEX
                                 ,  CUST_LVL
                                 ,  SALE_QTY
                                 ,  SALE_AMT
                                 ,  DC_AMT
                                 ,  ENR_AMT
                                 ,  GRD_AMT
                                 ,  GRD_I_AMT
                                 ,  GRD_O_AMT
                                 ,  VAT_AMT
                                 ,  VAT_I_AMT
                                 ,  VAT_O_AMT
                                 ,  RTN_QTY
                                 ,  RTN_AMT
                                   )
                             VALUES
                                   (  
                                    '016'
                                 ,  prv_sale_dt.SALE_DT
                                 ,  prv_sale_dt.BRAND_CD
                                 ,  prv_sale_dt.STOR_CD
                                 ,  prv_sale_dt.CUST_ID
                                 ,  prv_sale_dt.ITEM_CD
                                 ,  ll_cust_age
                                 ,  ls_cust_sex
                                 ,  ls_cust_lvl
                                 ,  prv_sale_dt.SALE_QTY
                                 ,  prv_sale_dt.SALE_AMT
                                 ,  prv_sale_dt.DC_AMT
                                 ,  prv_sale_dt.ENR_AMT
                                 ,  prv_sale_dt.GRD_AMT
                                 ,  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                                 ,  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                                 ,  prv_sale_dt.VAT_AMT
                                 ,  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                                 ,  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                                 ,  CASE WHEN prv_sale_dt.SALE_DIV = '2' THEN prv_sale_dt.SALE_QTY ELSE 0 END
                                 ,  CASE WHEN prv_sale_dt.SALE_DIV = '2' THEN prv_sale_dt.GRD_AMT  ELSE 0 END
                                   );
                    EXCEPTION
                        WHEN OTHERS THEN
                            liv_msg_code := SQLCODE;
                            lsv_msg_text := 'CUST_DMS: ' || SQLERRM;
                            RAISE ERR_HANDLER;
                    END;
                END IF;
                 
                /****************** TSMS ********************/    
                -- 매장별 일 시간대별 매출 집계
                BEGIN
                    MERGE   INTO SALE_JTM
                    USING   DUAL
                    ON     (    SALE_DT  = prv_sale_dt.SALE_DT
                            AND BRAND_CD = prv_sale_dt.BRAND_CD
                            AND STOR_CD  = prv_sale_dt.STOR_CD
                            AND SEC_DIV  = SUBSTR(prv_sale_dt.SORD_TM, 1, 2)
                            AND ITEM_CD  = prv_sale_dt.ITEM_CD
                           )
                    WHEN MATCHED THEN
                        UPDATE 
                        SET     SALE_QTY    = SALE_QTY + prv_sale_dt.SALE_QTY
                              , SALE_AMT    = SALE_AMT + prv_sale_dt.SALE_AMT
                              , DC_AMT      = DC_AMT   + prv_sale_dt.DC_AMT
                              , ENR_AMT     = ENR_AMT  + prv_sale_dt.ENR_AMT
                              , GRD_AMT     = GRD_AMT  + prv_sale_dt.GRD_AMT
                              , VAT_AMT     = VAT_AMT  + prv_sale_dt.VAT_AMT
                              , SVC_AMT     = SVC_AMT  + prv_sale_dt.SVC_AMT
                              , SVC_VAT_AMT = SVC_VAT_AMT  + prv_sale_dt.SVC_VAT_AMT
                              , GRD_I_AMT   = GRD_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , GRD_O_AMT   = GRD_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , VAT_I_AMT   = VAT_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , VAT_O_AMT   = VAT_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                    WHEN NOT MATCHED THEN
                        INSERT (
                                SALE_DT
                              , BRAND_CD
                              , STOR_CD
                              , SEC_DIV
                              , ITEM_CD
                              , SALE_QTY
                              , SALE_AMT
                              , DC_AMT
                              , ENR_AMT
                              , GRD_AMT
                              , GRD_I_AMT
                              , GRD_O_AMT
                              , VAT_AMT
                              , VAT_I_AMT
                              , VAT_O_AMT
                              , SVC_AMT
                              , SVC_VAT_AMT
                               )
                        VALUES
                               (  
                                prv_sale_dt.SALE_DT
                              , prv_sale_dt.BRAND_CD
                              , prv_sale_dt.STOR_CD
                              , SUBSTR(prv_sale_dt.SORD_TM, 1, 2)
                              , prv_sale_dt.ITEM_CD
                              , prv_sale_dt.SALE_QTY
                              , prv_sale_dt.SALE_AMT
                              , prv_sale_dt.DC_AMT
                              , prv_sale_dt.ENR_AMT
                              , prv_sale_dt.GRD_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , prv_sale_dt.VAT_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                              , prv_sale_dt.SVC_AMT
                              , prv_sale_dt.SVC_VAT_AMT
                               );
                EXCEPTION
                    WHEN OTHERS THEN
                       liv_msg_code := SQLCODE;
                       lsv_msg_text := 'SALE_JTM: ' || SQLERRM;
                       RAISE ERR_HANDLER;
                END;
                
                -- 상품별 매출 일집계
                BEGIN
                    MERGE INTO SALE_JDM
                    USING DUAL
                    ON (
                            SALE_DT  = prv_sale_dt.sale_dt
                        AND BRAND_CD = prv_sale_dt.brand_cd
                        AND STOR_CD  = prv_sale_dt.stor_cd
                        AND ITEM_CD  = prv_sale_dt.item_cd
                       )
                    WHEN MATCHED THEN
                        UPDATE 
                        SET     SALE_QTY    = SALE_QTY + prv_sale_dt.sale_qty
                              , SALE_AMT    = SALE_AMT + prv_sale_dt.sale_amt
                              , DC_AMT      = DC_AMT   + prv_sale_dt.dc_amt
                              , ENR_AMT     = ENR_AMT  + prv_sale_dt.enr_amt
                              , GRD_AMT     = GRD_AMT  + prv_sale_dt.grd_amt
                              , VAT_AMT     = VAT_AMT  + prv_sale_dt.vat_amt
                              , SVC_AMT     = SVC_AMT  + prv_sale_dt.svc_amt
                              , SVC_VAT_AMT = SVC_VAT_AMT  + prv_sale_dt.svc_vat_amt
                              , GRD_I_AMT   = GRD_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , GRD_O_AMT   = GRD_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , VAT_I_AMT   = VAT_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , VAT_O_AMT   = VAT_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                    WHEN NOT MATCHED THEN
                        INSERT
                               (  
                                SALE_DT
                              , BRAND_CD
                              , STOR_CD
                              , ITEM_CD
                              , SALE_QTY
                              , SALE_AMT
                              , DC_AMT
                              , ENR_AMT
                              , GRD_AMT
                              , GRD_I_AMT
                              , GRD_O_AMT
                              , VAT_AMT
                              , VAT_I_AMT
                              , VAT_O_AMT
                              , SVC_AMT
                              , SVC_VAT_AMT
                               )
                        VALUES
                               (  
                                prv_sale_dt.SALE_DT
                              , prv_sale_dt.BRAND_CD
                              , prv_sale_dt.STOR_CD
                              , prv_sale_dt.ITEM_CD
                              , prv_sale_dt.SALE_QTY
                              , prv_sale_dt.SALE_AMT
                              , prv_sale_dt.DC_AMT
                              , prv_sale_dt.ENR_AMT
                              , prv_sale_dt.GRD_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , prv_sale_dt.VAT_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                              , prv_sale_dt.SVC_AMT
                              , prv_sale_dt.SVC_VAT_AMT
                               );
                EXCEPTION
                    WHEN OTHERS THEN
                        liv_msg_code := SQLCODE;
                        lsv_msg_text := 'SALE_JDM: ' || SQLERRM;
                        RAISE ERR_HANDLER;
                END;
            
                -- 상품별 매출 월집계
                BEGIN
                    MERGE   INTO SALE_JMM
                    USING   DUAL
                    ON     (
                                SALE_YM  = substr(prv_sale_dt.sale_dt,1,6)
                            AND BRAND_CD = prv_sale_dt.brand_cd
                            AND STOR_CD  = prv_sale_dt.stor_cd
                            AND ITEM_CD  = prv_sale_dt.item_cd
                           )
                    WHEN MATCHED THEN
                         UPDATE
                         SET    SALE_QTY    = SALE_QTY + prv_sale_dt.sale_qty,
                                SALE_AMT    = SALE_AMT + prv_sale_dt.sale_amt,
                                DC_AMT      = DC_AMT   + prv_sale_dt.dc_amt,
                                ENR_AMT     = ENR_AMT  + prv_sale_dt.enr_amt,
                                GRD_AMT     = GRD_AMT  + prv_sale_dt.grd_amt,
                                VAT_AMT     = VAT_AMT  + prv_sale_dt.vat_amt,
                                SVC_AMT     = SVC_AMT  + prv_sale_dt.svc_amt,
                                SVC_VAT_AMT = SVC_VAT_AMT  + prv_sale_dt.svc_vat_amt,
                                GRD_I_AMT   = GRD_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END,
                                GRD_O_AMT   = GRD_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END,
                                VAT_I_AMT   = VAT_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END,
                                VAT_O_AMT   = VAT_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                    WHEN NOT MATCHED THEN
                        INSERT (  
                                SALE_YM
                              , BRAND_CD
                              , STOR_CD
                              , ITEM_CD
                              , SALE_QTY
                              , SALE_AMT
                              , DC_AMT
                              , ENR_AMT
                              , GRD_AMT
                              , GRD_I_AMT
                              , GRD_O_AMT
                              , VAT_AMT
                              , VAT_I_AMT
                              , VAT_O_AMT
                              , SVC_AMT
                              , SVC_VAT_AMT
                               )
                        VALUES
                               (  
                                substr(prv_sale_dt.SALE_DT, 1, 6)
                              , prv_sale_dt.BRAND_CD
                              , prv_sale_dt.STOR_CD
                              , prv_sale_dt.ITEM_CD
                              , prv_sale_dt.SALE_QTY
                              , prv_sale_dt.SALE_AMT
                              , prv_sale_dt.DC_AMT
                              , prv_sale_dt.ENR_AMT
                              , prv_sale_dt.GRD_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , prv_sale_dt.VAT_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                              , prv_sale_dt.SVC_AMT
                              , prv_sale_dt.SVC_VAT_AMT
                               );
                EXCEPTION
                    WHEN OTHERS THEN
                        liv_msg_code := SQLCODE;
                        lsv_msg_text := 'SALE_JMM: ' || SQLERRM;
                        RAISE ERR_HANDLER;
                END;
            END IF;
         
            IF prv_sale_dt.SUB_TOUCH_DIV  IN('2', '3') THEN -- SUB_TOUCH_DIV 2:UPCHARGE, 3:선택메뉴
                BEGIN
                  -- 메뉴/제품별 매출 일집계
                  MERGE INTO SALE_JDI
                  USING DUAL
                  ON (
                          SALE_DT     = prv_sale_dt.SALE_DT
                      AND BRAND_CD    = prv_sale_dt.BRAND_CD
                      AND STOR_CD     = prv_sale_dt.STOR_CD
                      AND ITEM_CD     = prv_sale_dt.MAIN_ITEM_CD
                      AND SUB_FG      = prv_sale_dt.SUB_TOUCH_DIV
                      AND SUB_ITEM_CD = prv_sale_dt.ITEM_CD
                     )
                  WHEN MATCHED THEN
                       UPDATE
                          SET SALE_QTY    = SALE_QTY + prv_sale_dt.SALE_QTY
                            , SALE_AMT    = SALE_AMT + prv_sale_dt.SALE_AMT
                            , DC_AMT      = DC_AMT   + prv_sale_dt.DC_AMT
                            , ENR_AMT     = ENR_AMT  + prv_sale_dt.ENR_AMT
                            , GRD_AMT     = GRD_AMT  + prv_sale_dt.GRD_AMT
                            , VAT_AMT     = VAT_AMT  + prv_sale_dt.VAT_AMT
                            , SVC_AMT     = SVC_AMT  + prv_sale_dt.SVC_AMT
                            , SVC_VAT_AMT = SVC_VAT_AMT  + prv_sale_dt.svc_vat_amt
                            , GRD_I_AMT   = GRD_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                            , GRD_O_AMT   = GRD_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                            , VAT_I_AMT   = VAT_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                            , VAT_O_AMT   = VAT_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                  WHEN NOT MATCHED THEN
                       INSERT
                         (  SALE_DT
                          , BRAND_CD
                          , STOR_CD
                          , ITEM_CD
                          , SUB_FG
                          , SUB_ITEM_CD
                          , SALE_QTY
                          , SALE_AMT
                          , DC_AMT
                          , ENR_AMT
                          , GRD_AMT
                          , GRD_I_AMT
                          , GRD_O_AMT
                          , VAT_AMT
                          , VAT_I_AMT
                          , VAT_O_AMT
                          , SVC_AMT
                          , SVC_VAT_AMT
                         )
                       VALUES
                         (  prv_sale_dt.SALE_DT
                          , prv_sale_dt.BRAND_CD
                          , prv_sale_dt.STOR_CD
                          , prv_sale_dt.MAIN_ITEM_CD
                          , prv_sale_dt.SUB_TOUCH_DIV
                          , prv_sale_dt.ITEM_CD
                          , prv_sale_dt.SALE_QTY
                          , prv_sale_dt.SALE_AMT
                          , prv_sale_dt.DC_AMT
                          , prv_sale_dt.ENR_AMT
                          , prv_sale_dt.GRD_AMT
                          , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                          , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                          , prv_sale_dt.VAT_AMT
                          , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                          , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                          , prv_sale_dt.SVC_AMT
                          , prv_sale_dt.SVC_VAT_AMT
                         );
                EXCEPTION
                    WHEN OTHERS THEN
                        liv_msg_code := SQLCODE;
                        lsv_msg_text := 'SALE_JDI: ' || SQLERRM;
                        RAISE ERR_HANDLER;
                END;
                
                -- 부가상품 월 매출 집계
                BEGIN
                    MERGE   INTO SALE_JMI
                    USING   DUAL
                     ON    (
                                SALE_YM     = SUBSTR(prv_sale_dt.SALE_DT, 1, 6)
                            AND BRAND_CD    = prv_sale_dt.BRAND_CD
                            AND STOR_CD     = prv_sale_dt.STOR_CD
                            AND ITEM_CD     = prv_sale_dt.MAIN_ITEM_CD
                            AND SUB_FG      = prv_sale_dt.SUB_TOUCH_DIV
                            AND SUB_ITEM_CD = prv_sale_dt.ITEM_CD
                           )
                    WHEN MATCHED THEN
                        UPDATE
                        SET     SALE_QTY    = SALE_QTY + prv_sale_dt.SALE_QTY
                              , SALE_AMT    = SALE_AMT + prv_sale_dt.SALE_AMT
                              , DC_AMT      = DC_AMT   + prv_sale_dt.DC_AMT
                              , ENR_AMT     = ENR_AMT  + prv_sale_dt.ENR_AMT
                              , GRD_AMT     = GRD_AMT  + prv_sale_dt.GRD_AMT
                              , VAT_AMT     = VAT_AMT  + prv_sale_dt.VAT_AMT
                              , SVC_AMT     = SVC_AMT  + prv_sale_dt.SVC_AMT
                              , SVC_VAT_AMT = SVC_VAT_AMT  + prv_sale_dt.SVC_VAT_AMT
                              , GRD_I_AMT   = GRD_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , GRD_O_AMT   = GRD_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , VAT_I_AMT   = VAT_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , VAT_O_AMT   = VAT_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                    WHEN NOT MATCHED THEN
                        INSERT (  
                                SALE_YM
                              , BRAND_CD
                              , STOR_CD
                              , ITEM_CD
                              , SUB_FG
                              , SUB_ITEM_CD
                              , SALE_QTY
                              , SALE_AMT
                              , DC_AMT
                              , ENR_AMT
                              , GRD_AMT
                              , GRD_I_AMT
                              , GRD_O_AMT
                              , VAT_AMT
                              , VAT_I_AMT
                              , VAT_O_AMT
                              , SVC_AMT
                              , SVC_VAT_AMT
                               )
                        VALUES
                               (  
                                SUBSTR(prv_sale_dt.SALE_DT, 1, 6)
                              , prv_sale_dt.BRAND_CD
                              , prv_sale_dt.STOR_CD
                              , prv_sale_dt.MAIN_ITEM_CD
                              , prv_sale_dt.SUB_TOUCH_DIV
                              , prv_sale_dt.ITEM_CD
                              , prv_sale_dt.SALE_QTY
                              , prv_sale_dt.SALE_AMT
                              , prv_sale_dt.DC_AMT
                              , prv_sale_dt.ENR_AMT
                              , prv_sale_dt.GRD_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , prv_sale_dt.VAT_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                              , prv_sale_dt.SVC_AMT
                              , prv_sale_dt.SVC_VAT_AMT
                               );
                EXCEPTION
                    WHEN OTHERS THEN
                        liv_msg_code := SQLCODE;
                        lsv_msg_text := 'SALE_JMI: ' || SQLERRM;
                        RAISE ERR_HANDLER;
                END;
            
                BEGIN
                -- 부가상품 일별 시간대별 매출 집계
                    MERGE INTO SALE_JIM
                    USING DUAL
                    ON (
                            SALE_DT      = prv_sale_dt.SALE_DT
                        AND BRAND_CD     = prv_sale_dt.BRAND_CD
                        AND STOR_CD      = prv_sale_dt.STOR_CD
                        AND STOR_CD      = prv_sale_dt.STOR_CD
                        AND SEC_DIV      = SUBSTR(prv_sale_dt.SORD_TM, 1, 2)
                        AND ITEM_CD      = prv_sale_dt.MAIN_ITEM_CD
                        AND SUB_FG       = prv_sale_dt.SUB_TOUCH_DIV
                        AND SUB_ITEM_CD  = prv_sale_dt.ITEM_CD
                       )
                    WHEN MATCHED THEN
                        UPDATE 
                        SET     SALE_QTY     = SALE_QTY + prv_sale_dt.SALE_QTY
                              , SALE_AMT     = SALE_AMT + prv_sale_dt.SALE_AMT
                              , DC_AMT       = DC_AMT   + prv_sale_dt.DC_AMT
                              , ENR_AMT      = ENR_AMT  + prv_sale_dt.ENR_AMT
                              , GRD_AMT      = GRD_AMT  + prv_sale_dt.GRD_AMT
                              , VAT_AMT      = VAT_AMT  + prv_sale_dt.VAT_AMT
                              , SVC_AMT      = SVC_AMT  + prv_sale_dt.SVC_AMT
                              , SVC_VAT_AMT  = SVC_VAT_AMT + prv_sale_dt.SVC_VAT_AMT
                              , GRD_I_AMT    = GRD_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , GRD_O_AMT    = GRD_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , VAT_I_AMT    = VAT_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , VAT_O_AMT    = VAT_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                    WHEN NOT MATCHED THEN
                        INSERT (  
                                SALE_DT
                              , BRAND_CD
                              , STOR_CD
                              , SEC_DIV
                              , ITEM_CD
                              , SUB_FG
                              , SUB_ITEM_CD
                              , SALE_QTY
                              , SALE_AMT
                              , DC_AMT
                              , ENR_AMT
                              , GRD_AMT
                              , GRD_I_AMT
                              , GRD_O_AMT
                              , VAT_AMT
                              , VAT_I_AMT
                              , VAT_O_AMT
                              , SVC_AMT
                              , SVC_VAT_AMT
                               )
                        VALUES
                               (  
                                prv_sale_dt.SALE_DT
                              , prv_sale_dt.BRAND_CD
                              , prv_sale_dt.STOR_CD
                              , SUBSTR(prv_sale_dt.SORD_TM, 1, 2)
                              , prv_sale_dt.MAIN_ITEM_CD
                              , prv_sale_dt.SUB_TOUCH_DIV
                              , prv_sale_dt.ITEM_CD
                              , prv_sale_dt.SALE_QTY
                              , prv_sale_dt.SALE_AMT
                              , prv_sale_dt.DC_AMT
                              , prv_sale_dt.ENR_AMT
                              , prv_sale_dt.GRD_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , prv_sale_dt.VAT_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                              , prv_sale_dt.SVC_AMT
                              , prv_sale_dt.SVC_VAT_AMT
                               );
                EXCEPTION
                    WHEN OTHERS THEN
                        liv_msg_code := SQLCODE;
                        lsv_msg_text := 'SALE_JIM: ' || SQLERRM;
                        RAISE ERR_HANDLER;
                END;
            END IF;
        END IF;
      
        IF ((prv_sale_dt.FREE_DIV = '0' AND prv_sale_dt.DC_DIV <> '0')  OR prv_sale_dt.FREE_DIV <> '0')  AND -- [FREE_DIV 0:정상판매], [DC_DIV 0:정상]
           ( prv_sale_dt.T_SEQ    = 0   OR  prv_sale_dt.SUB_TOUCH_DIV  = '2')                           THEN -- [T_SEQ 0:SET 메뉴 구성품 제외, 부가메뉴 제외], [SUB_TOUCH_DIV 2:UPCHARGE]
            -- 2013.12.03 제휴할인 처리방안 변경
            BEGIN
                IF (prv_sale_dt.DC_AMT + prv_sale_dt.ENR_AMT) <> 0 THEN -- 할인금액이 발생한 건만 처리
                    BEGIN
                        -- 점별 상품별 할인 집계
                        MERGE   INTO SALE_JDD
                        USING   DUAL
                        ON     (    
                                    SALE_DT   = prv_sale_dt.SALE_DT
                                AND BRAND_CD  = prv_sale_dt.BRAND_CD
                                AND STOR_CD   = prv_sale_dt.STOR_CD
                                AND ITEM_CD   = prv_sale_dt.ITEM_CD
                                AND FREE_DIV  = prv_sale_dt.FREE_DIV
                                AND DC_DIV    = NVL(prv_sale_dt.DC_DIV, '0')
                                AND DC_RATE   = NVL(prv_sale_dt.DC_RATE, 0)
                               )
                        WHEN MATCHED THEN
                            UPDATE
                            SET     SALE_QTY = SALE_QTY + ((prv_sale_dt.DC_AMT + prv_sale_dt.ENR_AMT)/prv_sale_dt.SALE_PRC)
                                  , SALE_AMT = SALE_AMT + ((prv_sale_dt.DC_AMT + prv_sale_dt.ENR_AMT)/prv_sale_dt.SALE_PRC) * prv_sale_dt.SALE_PRC
                                  , DC_AMT   = DC_AMT   + prv_sale_dt.DC_AMT
                                  , ENR_AMT  = ENR_AMT  + prv_sale_dt.ENR_AMT
                                  , GRD_AMT  = GRD_AMT  + 0
                                  , VAT_AMT  = VAT_AMT  + 0
                                  , SVC_AMT  = SVC_AMT  + 0
                                  , SVC_VAT_AMT = SVC_VAT_AMT  + 0
                                  , GRD_I_AMT = GRD_I_AMT + 0
                                  , GRD_O_AMT = GRD_O_AMT + 0
                                  , VAT_I_AMT = VAT_I_AMT + 0
                                  , VAT_O_AMT = VAT_O_AMT + 0
                                  , DC_QTY    = DC_QTY    +  DECODE(prv_sale_dt.SALE_DIV, '1', 1, -1)
                        WHEN NOT MATCHED THEN
                            INSERT (  
                                    SALE_DT
                                  , BRAND_CD
                                  , STOR_CD
                                  , ITEM_CD
                                  , FREE_DIV
                                  , DC_DIV
                                  , DC_RATE
                                  , SALE_QTY
                                  , SALE_AMT
                                  , DC_AMT
                                  , ENR_AMT
                                  , GRD_AMT
                                  , GRD_I_AMT
                                  , GRD_O_AMT
                                  , VAT_AMT
                                  , VAT_I_AMT
                                  , VAT_O_AMT
                                  , SVC_AMT
                                  , SVC_VAT_AMT
                                  , DC_QTY
                                   )
                            VALUES
                                   (  
                                    prv_sale_dt.SALE_DT
                                  , prv_sale_dt.BRAND_CD
                                  , prv_sale_dt.STOR_CD
                                  , prv_sale_dt.ITEM_CD
                                  , NVL(prv_sale_dt.FREE_DIV, '0')
                                  , NVL(prv_sale_dt.DC_DIV, '0')
                                  , NVL(prv_sale_dt.DC_RATE, 0)
                                  , ((prv_sale_dt.DC_AMT + prv_sale_dt.ENR_AMT)/prv_sale_dt.SALE_PRC)
                                  , ((prv_sale_dt.DC_AMT + prv_sale_dt.ENR_AMT)/prv_sale_dt.SALE_PRC) *  prv_sale_dt.SALE_PRC
                                  , prv_sale_dt.DC_AMT
                                  , prv_sale_dt.ENR_AMT
                                  , 0
                                  , 0
                                  , 0
                                  , 0
                                  , 0
                                  , 0
                                  , 0
                                  , 0
                                  , DECODE(prv_sale_dt.SALE_DIV, '1', 1, -1)
                                   );
                    EXCEPTION
                        WHEN OTHERS THEN
                            liv_msg_code := SQLCODE;
                            lsv_msg_text := 'SALE_JDD: ' || SQLERRM;
                            RAISE ERR_HANDLER;
                    END;
                 END IF;
            EXCEPTION
                WHEN OTHERS THEN -- DC_GIFT가 없는 할인 처리
                    BEGIN
                        -- 점별 상품별 할인 집계
                        MERGE   INTO SALE_JDD
                        USING   DUAL
                        ON     (
                                    SALE_DT   = prv_sale_dt.SALE_DT
                                AND BRAND_CD  = prv_sale_dt.BRAND_CD
                                AND STOR_CD   = prv_sale_dt.STOR_CD
                                AND ITEM_CD   = prv_sale_dt.ITEM_CD
                                AND FREE_DIV  = prv_sale_dt.FREE_DIV
                                AND DC_DIV    = NVL(prv_sale_dt.DC_DIV, '0')
                                AND DC_RATE   = NVL(prv_sale_dt.DC_RATE, 0)
                               )
                        WHEN MATCHED THEN
                            UPDATE
                            SET     SALE_QTY    = SALE_QTY + prv_sale_dt.SALE_QTY
                                  , SALE_AMT    = SALE_AMT + CASE WHEN prv_sale_dt.FREE_DIV IN('0', '1') THEN prv_sale_dt.SALE_AMT
                                                                  ELSE prv_sale_dt.SALE_QTY *  prv_sale_dt.SALE_PRC END
                                  , DC_AMT      = DC_AMT   + prv_sale_dt.DC_AMT
                                  , ENR_AMT     = ENR_AMT  + prv_sale_dt.ENR_AMT
                                  , GRD_AMT     = GRD_AMT  + CASE WHEN prv_sale_dt.FREE_DIV IN('0', '1') THEN prv_sale_dt.GRD_AMT
                                                                  ELSE prv_sale_dt.SALE_QTY *  prv_sale_dt.SALE_PRC END
                                  , VAT_AMT     = VAT_AMT  + prv_sale_dt.VAT_AMT
                                  , SVC_AMT     = SVC_AMT  + prv_sale_dt.SVC_AMT
                                  , SVC_VAT_AMT = SVC_VAT_AMT  + prv_sale_dt.SVC_VAT_AMT
                                  , GRD_I_AMT   = GRD_I_AMT + CASE WHEN prv_sale_dt.FREE_DIV IN('0', '1') THEN  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                                                                   ELSE prv_sale_dt.SALE_QTY *  prv_sale_dt.SALE_PRC END
                                  , GRD_O_AMT   = GRD_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                                  , VAT_I_AMT   = VAT_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                                  , VAT_O_AMT   = VAT_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                                  , DC_QTY      = DC_QTY    +  DECODE(prv_sale_dt.SALE_DIV, '1', 1, -1)
                        WHEN NOT MATCHED THEN
                            INSERT (  
                                    SALE_DT
                                  , BRAND_CD
                                  , STOR_CD
                                  , ITEM_CD
                                  , FREE_DIV
                                  , DC_DIV
                                  , DC_RATE
                                  , SALE_QTY
                                  , SALE_AMT
                                  , DC_AMT
                                  , ENR_AMT
                                  , GRD_AMT
                                  , GRD_I_AMT
                                  , GRD_O_AMT
                                  , VAT_AMT
                                  , VAT_I_AMT
                                  , VAT_O_AMT
                                  , SVC_AMT
                                  , SVC_VAT_AMT
                                  , DC_QTY
                                   )
                            VALUES
                                   (  
                                    prv_sale_dt.SALE_DT
                                  , prv_sale_dt.BRAND_CD
                                  , prv_sale_dt.STOR_CD
                                  , prv_sale_dt.ITEM_CD
                                  , NVL(prv_sale_dt.FREE_DIV, '0')
                                  , NVL(prv_sale_dt.DC_DIV, '0')
                                  , NVL(prv_sale_dt.DC_RATE, 0)
                                  , prv_sale_dt.SALE_QTY
                                  , CASE WHEN prv_sale_dt.FREE_DIV IN('0', '1') THEN prv_sale_dt.SALE_AMT
                                         ELSE prv_sale_dt.SALE_QTY *  prv_sale_dt.SALE_PRC END
                                  , prv_sale_dt.DC_AMT
                                  , prv_sale_dt.ENR_AMT
                                  , CASE WHEN prv_sale_dt.FREE_DIV IN('0', '1') THEN prv_sale_dt.GRD_AMT
                                         ELSE prv_sale_dt.SALE_QTY *  prv_sale_dt.SALE_PRC END
                                  , CASE WHEN prv_sale_dt.FREE_DIV IN('0', '1') THEN  CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                                         ELSE prv_sale_dt.SALE_QTY *  prv_sale_dt.SALE_PRC END
                                  , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                                  , prv_sale_dt.VAT_AMT
                                  , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                                  , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                                  , prv_sale_dt.SVC_AMT
                                  , prv_sale_dt.SVC_VAT_AMT
                                  , DECODE(prv_sale_dt.SALE_DIV, '1', 1, -1)
                                   );
                    EXCEPTION
                        WHEN OTHERS THEN
                             liv_msg_code := SQLCODE;
                             lsv_msg_text := 'SALE_JDD: ' || SQLERRM;
                             RAISE ERR_HANDLER;
                    END;
            END;
         
            IF prv_sale_dt.FREE_DIV IN('0', '1')  THEN -- FREE_DIV 0:정상판매, 1:무료쿠폰
                BEGIN
                    MERGE INTO SALE_SDC
                    USING DUAL
                    ON (
                            SALE_DT   = prv_sale_dt.SALE_DT
                        AND BRAND_CD  = prv_sale_dt.BRAND_CD
                        AND STOR_CD   = prv_sale_dt.STOR_CD
                        AND DC_DIV    = NVL(prv_sale_dt.DC_DIV, '0')
                        AND DC_RATE   = NVL(prv_sale_dt.DC_RATE, 0)
                       )
                    WHEN MATCHED THEN
                        UPDATE
                        SET     SALE_QTY    = SALE_QTY + prv_sale_dt.SALE_QTY
                              , SALE_AMT    = SALE_AMT + prv_sale_dt.SALE_AMT
                              , DC_AMT      = DC_AMT   + prv_sale_dt.DC_AMT
                              , ENR_AMT     = ENR_AMT  + prv_sale_dt.ENR_AMT
                              , GRD_AMT     = GRD_AMT  + prv_sale_dt.GRD_AMT
                              , VAT_AMT     = VAT_AMT  + prv_sale_dt.VAT_AMT
                              , SVC_AMT     = SVC_AMT  + prv_sale_dt.SVC_AMT
                              , SVC_VAT_AMT = SVC_VAT_AMT  + prv_sale_dt.SVC_VAT_AMT
                              , GRD_I_AMT   = GRD_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , GRD_O_AMT   = GRD_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , VAT_I_AMT   = VAT_I_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , VAT_O_AMT   = VAT_O_AMT + CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                              , DC_QTY      =  DC_QTY  +  DECODE(prv_sale_dt.SALE_DIV, '1', 1, -1)
                    WHEN NOT MATCHED THEN
                        INSERT (  
                                SALE_DT
                              , BRAND_CD
                              , STOR_CD
                              , DC_DIV
                              , DC_RATE
                              , SALE_QTY
                              , SALE_AMT
                              , DC_AMT
                              , ENR_AMT
                              , GRD_AMT
                              , GRD_I_AMT
                              , GRD_O_AMT
                              , VAT_AMT
                              , VAT_I_AMT
                              , VAT_O_AMT
                              , SVC_AMT
                              , SVC_VAT_AMT
                              , DC_QTY
                             )
                           VALUES
                             (  prv_sale_dt.SALE_DT
                              , prv_sale_dt.BRAND_CD
                              , prv_sale_dt.STOR_CD
                              , NVL(prv_sale_dt.DC_DIV, '0')
                              , NVL(prv_sale_dt.DC_RATE, 0)
                              , prv_sale_dt.SALE_QTY
                              , prv_sale_dt.SALE_AMT
                              , prv_sale_dt.DC_AMT
                              , prv_sale_dt.ENR_AMT
                              , prv_sale_dt.GRD_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.GRD_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.GRD_AMT END
                              , prv_sale_dt.VAT_AMT
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN prv_sale_dt.VAT_AMT ELSE 0 END
                              , CASE WHEN prv_sale_dt.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dt.VAT_AMT END
                              , prv_sale_dt.SVC_AMT
                              , prv_sale_dt.SVC_VAT_AMT
                              , DECODE(prv_sale_dt.SALE_DIV, '1', 1, -1)
                             );
                EXCEPTION
                    WHEN OTHERS THEN
                        liv_msg_code := SQLCODE;
                        lsv_msg_text := 'SALE_SDC: ' || SQLERRM;
                        RAISE ERR_HANDLER;
                END;
            END IF;
        END IF;
      
        psr_return_cd  := liv_msg_code;
        psr_msg        := lsv_msg_text;
    EXCEPTION
        WHEN ERR_HANDLER THEN
            psr_return_cd := liv_msg_code;
            psr_msg       := lsv_msg_text;
        WHEN OTHERS THEN
            psr_return_cd := SQLCODE;
            psr_msg       := SQLERRM;
    END;

/
