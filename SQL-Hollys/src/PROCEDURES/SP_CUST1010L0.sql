--------------------------------------------------------
--  DDL for Procedure SP_CUST1010L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CUST1010L0" /* 회원정보관리 MMS 재전송 */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_LANG_TP     IN  VARCHAR2 ,                -- 언어코드
  PSV_COUPON_CD   IN  VARCHAR2 ,                -- 쿠폰번호
  PSV_CERT_NO     IN  VARCHAR2 ,                -- 인증번호
  PSV_SEND_DT     IN  VARCHAR2 ,                -- 전송일시
  PSV_MSGKEY      IN  VARCHAR2 ,                -- MMS 키 값
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_CUST1010L0      회원정보관리 MMS 재전송
   PURPOSE: 

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_CUST1010L0
      SYSDATE:         2014-07-11
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_tbl_name     VARCHAR2(2000) := 'MMS_LOG_'||SUBSTR(REPLACE(PSV_SEND_DT, '/', ''), 1, 6);     -- 테이블 이름
    ls_sms_send_dtm VARCHAR2(20)   := NULL;
    
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd       VARCHAR2(7) := '0' ;
    ls_err_msg      VARCHAR2(500) ;
    
    ll_msg_key      MMS_MSG.MSGKEY%TYPE;
    ll_rec_cnt      NUMBER := 0;
    ll_prc_cnt      NUMBER := 0;
    
    TYPE TYP_MMS IS REF CURSOR;
    CUR_1   TYP_MMS;
    MYREC   MMS_MSG%ROWTYPE;
BEGIN
    /*** MMS KEY(일련번호) ***/
    ll_msg_key      := MMS_MSG_SEQ.NEXTVAL;
    ls_sms_send_dtm := TO_CHAR(SYSDATE+1/1440, 'YYYYMMDDHH24MISS');
    
    SELECT COUNT(*) INTO ll_rec_cnt
    FROM   TAB
    WHERE  TABTYPE = 'TABLE'
    AND    TNAME   = ls_tbl_name;

    /*** MMS 전송 테이블 조회 ***/
    ls_sql := ' 
                SELECT  MSGKEY, SUBJECT,  PHONE, CALLBACK, MSG, FILE_CNT, FILE_CNT_REAL, 
                        FILE_PATH1, FILE_PATH1_SIZ, FILE_PATH2, FILE_PATH2_SIZ, FILE_PATH3, FILE_PATH3_SIZ, 
                        FILE_PATH4, FILE_PATH4_SIZ, FILE_PATH5, FILE_PATH5_SIZ, TYPE,       ROUTE_ID
                FROM    MMS_MSG
                WHERE   MSGKEY = ' || PSV_MSGKEY;
    
    /*** MMS 전송 로그 테이블 조회 ***/
    IF ll_rec_cnt > 0 THEN
        ls_sql := ls_sql ||
              '             
                UNION ALL
                SELECT  MSGKEY, SUBJECT,  PHONE, CALLBACK, MSG, FILE_CNT, FILE_CNT_REAL, 
                        FILE_PATH1, FILE_PATH1_SIZ, FILE_PATH2, FILE_PATH2_SIZ, FILE_PATH3, FILE_PATH3_SIZ, 
                        FILE_PATH4, FILE_PATH4_SIZ, FILE_PATH5, FILE_PATH5_SIZ, TYPE,       ROUTE_ID
                FROM   '|| ls_tbl_name ||' 
                WHERE   MSGKEY = ' || PSV_MSGKEY;
    END IF;            
                        
    
    OPEN CUR_1 FOR ls_sql;
    
    /*** MMS 전송 테이블 작성 ***/
    LOOP 
        FETCH CUR_1 INTO MYREC.MSGKEY, MYREC.SUBJECT,  MYREC.PHONE, MYREC.CALLBACK, MYREC.MSG, MYREC.FILE_CNT, MYREC.FILE_CNT_REAL, 
                         MYREC.FILE_PATH1, MYREC.FILE_PATH1_SIZ, MYREC.FILE_PATH2, MYREC.FILE_PATH2_SIZ,
                         MYREC.FILE_PATH3, MYREC.FILE_PATH3_SIZ, MYREC.FILE_PATH4, MYREC.FILE_PATH4_SIZ,
                         MYREC.FILE_PATH5, MYREC.FILE_PATH5_SIZ,
                         MYREC.TYPE, MYREC.ROUTE_ID;
        
        EXIT WHEN CUR_1%NOTFOUND;
        
        INSERT INTO MMS_MSG(
                            MSGKEY,     SUBJECT,    PHONE,      CALLBACK,       STATUS, 
                            REQDATE,                            MSG,
                            FILE_CNT,   FILE_CNT_REAL,          FILE_PATH1,     FILE_PATH1_SIZ,
                            FILE_PATH2,     FILE_PATH2_SIZ,     FILE_PATH3,     FILE_PATH3_SIZ,
                            FILE_PATH4,     FILE_PATH4_SIZ,     FILE_PATH5,     FILE_PATH5_SIZ,
                            EXPIRETIME, SENTDATE,   RSLTDATE,   REPORTDATE,     TERMINATEDDATE, 
                            RSLT,       TYPE,       TELCOINFO,  ROUTE_ID
                           )
                    VALUES (
                            ll_msg_key,     MYREC.SUBJECT,  MYREC.PHONE,    MYREC.CALLBACK,         '0',
                            TO_DATE(ls_sms_send_dtm, 'YYYYMMDDHH24MISS'),   MYREC.MSG,
                            MYREC.FILE_CNT,                 MYREC.FILE_CNT_REAL, MYREC.FILE_PATH1, MYREC.FILE_PATH1_SIZ,
                            MYREC.FILE_PATH2, MYREC.FILE_PATH2_SIZ, MYREC.FILE_PATH3, MYREC.FILE_PATH3_SIZ,
                            MYREC.FILE_PATH4, MYREC.FILE_PATH4_SIZ, MYREC.FILE_PATH5, MYREC.FILE_PATH5_SIZ,
                            '43200',        NULL,           NULL,           NULL,                   NULL,  
                            NULL,           MYREC.TYPE,     NULL,           MYREC.ROUTE_ID
                           );
                           
        -- 처리된 레코드 건수 체크
        ll_prc_cnt := ll_prc_cnt + 1;
    END LOOP;
    
    /* 재전송 이력 작성 */
    IF ll_prc_cnt > 0 THEN
        UPDATE  C_COUPON_CUST_GIFT
        SET     GIFT_SEND_DT    = ls_sms_send_dtm,
                GIFT_SEND_STAT  = '2',
                GIFT_ERR_CD     = '0000',
                GIFT_ERR_MSG    = FC_GET_WORDPACK(PSV_LANG_TP, 'SMS_SENDING'),
                MSGKEY          = ll_msg_key
        WHERE   COMP_CD   = PSV_COMP_CD
        AND     COUPON_CD = PSV_COUPON_CD
        AND     CERT_NO   = PSV_CERT_NO;
    END IF;
    
    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;
    /*
    OPEN PR_RESULT FOR
        SELECT 0 FROM DUAL;
    */    
EXCEPTION
    WHEN ERR_HANDLER THEN
        PR_RTN_CD  := SQLCODE;
        PR_RTN_MSG := SQLERRM ;
       dbms_output.put_line( PR_RTN_MSG ) ;
    WHEN OTHERS THEN
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
        dbms_output.put_line( PR_RTN_MSG ) ;
END ;

/
