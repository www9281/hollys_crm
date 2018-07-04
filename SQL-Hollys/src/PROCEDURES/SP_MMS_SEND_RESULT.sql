--------------------------------------------------------
--  DDL for Procedure SP_MMS_SEND_RESULT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MMS_SEND_RESULT" /* MMS 전송 결과 처리 */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_LANG_TP     IN  VARCHAR2 ,                -- Language Code
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_MMS_SEND_RESULT      MMS 전송 결과 처리
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_CUST1090M1
      SYSDATE:         2017-11-30
      USERNAME:
      TABLE NAME:
******************************************************************************/
    /* e-Gift 카드 주문 MMS 전송 리스트 */ 
    CURSOR  CUR_1 IS
        SELECT  /*+ INDEX(COC IDX02_C_ORDER_CARD) 
                    INDEX(CHD PK_C_ORDER_HD)      */
                COC.COMP_CD
             ,  COC.ORD_DT
             ,  COC.ORD_SEQ
             ,  COC.ITEM_SEQ
             ,  COC.GIFT_SEQ
             ,  COC.GIFT_SEND_DT
             ,  COC.GIFT_SEND_STAT
             ,  COC.MSGKEY
             , (
                SELECT  COUNT(*)
                FROM    C_ORDER_CARD ORG
                WHERE   ORG.COMP_CD      = COC.COMP_CD
                AND     ORG.ORG_ORD_DT   = COC.ORD_DT
                AND     ORG.ORG_ORD_SEQ  = COC.ORD_SEQ
                AND     ORG.ORG_ITEM_SEQ = COC.ITEM_SEQ
                AND     ORG.ORG_GIFT_SEQ = COC.GIFT_SEQ
               ) CNCL_DIV  -- 0:주문, 1:주문취소 
        FROM    C_ORDER_HD      CHD
              , C_ORDER_CARD    COC
        WHERE   CHD.COMP_CD        = COC.COMP_CD
        AND     CHD.ORD_DT         = COC.ORD_DT
        AND     CHD.ORD_SEQ        = COC.ORD_SEQ
        AND     COC.COMP_CD        = PSV_COMP_CD
        AND     CHD.ORD_FG         = '1' 
        AND     COC.GIFT_SEND_STAT IN ('0', '1', '2')
        AND     COC.GIFT_ERR_CD    IN ('0000', '0002')
        AND     COC.MSGKEY IS NOT NULL;
    
    /* 쿠폰선물하기 MMS 전송 리스트 */
    CURSOR  CUR_2 IS
        SELECT  /*+ INDEX(GIF IDX01_C_COUPON_CUST_GIFT) */
                GIF.COMP_CD
             ,  GIF.COUPON_CD
             ,  GIF.CERT_NO
             ,  GIF.GIFT_RESV_DT
             ,  GIF.MSGKEY
        FROM    C_COUPON_CUST_GIFT GIF
        WHERE   GIF.COMP_CD        = PSV_COMP_CD
        AND     GIF.GIFT_SEND_STAT IN ('0', '1', '2')
        AND     GIF.GIFT_ERR_CD    IN ('0000', '0002')
        AND     GIF.MSGKEY IS NOT NULL;
        
    ls_sql          VARCHAR2(30000) ;
    
    ERR_HANDLER     EXCEPTION;
    TYPE TYP_MMS IS REF CURSOR;
    
    CUR_9       TYP_MMS;
    nMSGKEY     MMS_MSG.MSGKEY%TYPE;
    vRSLT       MMS_MSG.RSLT%TYPE;
    vSEND_DT    C_ORDER_CARD.GIFT_SEND_DT%TYPE;
    vMSG        MMS_ERR_MSG.MSG%TYPE;
    
    ls_tbl_name     VARCHAR2(2000) := NULL;     -- 테이블 이름
    ll_rec_cnt1     NUMBER := 0;
    ll_rec_cnt2     NUMBER := 0;
    
    ls_err_cd       VARCHAR2(7) := '0000' ;
    ls_err_msg      VARCHAR2(500) ;
    
    
BEGIN
    FOR MYREC1 IN CUR_1 LOOP
        IF MYREC1.CNCL_DIV = 1 THEN
            /*** 주문취소의 경우 처리 ***/
            UPDATE  C_ORDER_CARD
            SET     GIFT_SEND_STAT = '8'
                  , GIFT_ERR_CD    = '8501'
                  , GIFT_ERR_MSG   = '주문취소'
            WHERE   COMP_CD        = MYREC1.COMP_CD
            AND     ORD_DT         = MYREC1.ORD_DT
            AND     ORD_SEQ        = MYREC1.ORD_SEQ
            AND     ITEM_SEQ       = MYREC1.ITEM_SEQ
            AND     GIFT_SEQ       = MYREC1.GIFT_SEQ;
        ELSE 
            ll_rec_cnt1 := 0;
            ll_rec_cnt2 := 0;
            
            /*** 전송 로그 테이블 ***/
            ls_tbl_name := 'MMS_LOG_'||SUBSTR(REPLACE(MYREC1.GIFT_SEND_DT, '/', ''), 1, 6);
            
            SELECT COUNT(*) INTO ll_rec_cnt1
            FROM   TAB
            WHERE  TABTYPE = 'TABLE'
            AND    TNAME   = ls_tbl_name;
            
            /*** MMS 전송 테이블 조회 ***/
            ls_sql := ' 
                        SELECT  MST.MSGKEY, MST.RSLT, TO_CHAR(SENTDATE, ''YYYYMMDDHH24MISS'') AS SEND_DT, MSG.MSG 
                        FROM    MMS_MSG     MST
                              , MMS_ERR_MSG MSG
                        WHERE   MST.RSLT   = MSG.CODE(+)
                        AND     MST.MSGKEY = ' || MYREC1.MSGKEY;
            
            /*** MMS 전송 로그 테이블 조회 ***/
            IF ll_rec_cnt1 > 0 THEN
                ls_sql := ls_sql ||
                      '             
                        UNION ALL
                        SELECT  MST.MSGKEY, MST.RSLT, TO_CHAR(SENTDATE, ''YYYYMMDDHH24MISS'') AS SEND_DT, MSG.MSG 
                        FROM    '|| ls_tbl_name ||' MST
                              , MMS_ERR_MSG         MSG
                        WHERE   MST.RSLT   = MSG.CODE(+)
                        AND     MST.MSGKEY = ' || MYREC1.MSGKEY;
            END IF;
            
            DBMS_OUTPUT.PUT_LINE(ls_sql);
            
            OPEN CUR_9 FOR ls_sql;
            
            LOOP 
                FETCH CUR_9 INTO nMSGKEY, vRSLT, vSEND_DT, vMSG;
                
                EXIT WHEN CUR_9%NOTFOUND;
                
                ll_rec_cnt2 := ll_rec_cnt2 + 1;
                
                IF vRSLT IS NOT NULL THEN
                    /*** 주문취소의 경우 처리 ***/
                    UPDATE  C_ORDER_CARD
                    SET     GIFT_SEND_STAT = DECODE(vRSLT, '1000', '1', '9')
                          , GIFT_SEND_DT   = DECODE(vRSLT, '1000', vSEND_DT, GIFT_SEND_DT)
                          , GIFT_ERR_CD    = vRSLT
                          , GIFT_ERR_MSG   = vMSG
                    WHERE   COMP_CD        = MYREC1.COMP_CD
                    AND     ORD_DT         = MYREC1.ORD_DT
                    AND     ORD_SEQ        = MYREC1.ORD_SEQ
                    AND     ITEM_SEQ       = MYREC1.ITEM_SEQ
                    AND     GIFT_SEQ       = MYREC1.GIFT_SEQ;
                END IF; 
            END LOOP;
            
            CLOSE CUR_9;
            
            IF ll_rec_cnt2 = 0 THEN
                /*** 주문취소의 경우 처리 ***/
                UPDATE  C_ORDER_CARD
                SET     GIFT_SEND_STAT = '9'
                      , GIFT_ERR_CD    = '8502'
                      , GIFT_ERR_MSG   = 'MSEEAGE KEY가 존재하지 않음'
                WHERE   COMP_CD        = MYREC1.COMP_CD
                AND     ORD_DT         = MYREC1.ORD_DT
                AND     ORD_SEQ        = MYREC1.ORD_SEQ
                AND     ITEM_SEQ       = MYREC1.ITEM_SEQ
                AND     GIFT_SEQ       = MYREC1.GIFT_SEQ;
            END IF;
        END IF;
    END LOOP;
    
    FOR MYREC2 IN CUR_2 LOOP
        ll_rec_cnt1 := 0;
        ll_rec_cnt2 := 0;
            
        /*** 전송 로그 테이블 ***/
        ls_tbl_name := 'MMS_LOG_'||SUBSTR(REPLACE(MYREC2.GIFT_RESV_DT, '/', ''), 1, 6);
            
        SELECT COUNT(*) INTO ll_rec_cnt1
        FROM   TAB
        WHERE  TABTYPE = 'TABLE'
        AND    TNAME   = ls_tbl_name;
            
        /*** MMS 전송 테이블 조회 ***/
        ls_sql := ' 
                    SELECT  MST.MSGKEY, MST.RSLT, TO_CHAR(SENTDATE, ''YYYYMMDDHH24MISS'') AS SEND_DT, MSG.MSG 
                    FROM    MMS_MSG     MST
                          , MMS_ERR_MSG MSG
                    WHERE   MST.RSLT   = MSG.CODE(+)
                    AND     MST.MSGKEY = ' || MYREC2.MSGKEY;
            
        /*** MMS 전송 로그 테이블 조회 ***/
        IF ll_rec_cnt1 > 0 THEN
            ls_sql := ls_sql ||
                  '             
                    UNION ALL
                    SELECT  MST.MSGKEY, MST.RSLT, TO_CHAR(SENTDATE, ''YYYYMMDDHH24MISS'') AS SEND_DT, MSG.MSG 
                    FROM    '|| ls_tbl_name ||' MST
                          , MMS_ERR_MSG         MSG
                    WHERE   MST.RSLT   = MSG.CODE(+)
                    AND     MST.MSGKEY = ' || MYREC2.MSGKEY;
        END IF;
            
        DBMS_OUTPUT.PUT_LINE(ls_sql);
            
        OPEN CUR_9 FOR ls_sql;
            
        LOOP 
            FETCH CUR_9 INTO nMSGKEY, vRSLT, vSEND_DT, vMSG;
                
            EXIT WHEN CUR_9%NOTFOUND;
                
            ll_rec_cnt2 := ll_rec_cnt2 + 1;
                
            IF vRSLT IS NOT NULL THEN
                /*** 주문취소의 경우 처리 ***/
                UPDATE  C_COUPON_CUST_GIFT
                SET     GIFT_SEND_STAT = DECODE(vRSLT, '1000', '1', '9')
                      , GIFT_SEND_DT   = DECODE(vRSLT, '1000', vSEND_DT, GIFT_SEND_DT)
                      , GIFT_ERR_CD    = vRSLT
                      , GIFT_ERR_MSG   = vMSG
                WHERE   COMP_CD        = MYREC2.COMP_CD
                AND     COUPON_CD      = MYREC2.COUPON_CD
                AND     CERT_NO        = MYREC2.CERT_NO;
            END IF; 
        END LOOP;
            
        CLOSE CUR_9;
            
        IF ll_rec_cnt2 = 0 THEN
            /*** 주문취소의 경우 처리 ***/
            UPDATE  C_COUPON_CUST_GIFT
            SET     GIFT_SEND_STAT = '9'
                  , GIFT_ERR_CD    = '8502'
                  , GIFT_ERR_MSG   = 'MSEEAGE KEY가 존재하지 않음'
            WHERE   COMP_CD        = MYREC2.COMP_CD
            AND     COUPON_CD      = MYREC2.COUPON_CD
            AND     CERT_NO        = MYREC2.CERT_NO;
        END IF;
    END LOOP;
    
    COMMIT;
    
    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := CASE WHEN ls_err_cd = '0000' THEN NULL ELSE ls_err_msg END;

EXCEPTION
    WHEN ERR_HANDLER THEN
        ROLLBACK;
        
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
       dbms_output.put_line( PR_RTN_MSG ) ;
    WHEN OTHERS THEN
        ROLLBACK;
        
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
        dbms_output.put_line( PR_RTN_MSG ) ;
END ;

/
