--------------------------------------------------------
--  DDL for Function F_GET_MMS_SEND_RESULT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."F_GET_MMS_SEND_RESULT" /* MMS 전송결과 취득 */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_COUPON_CD   IN  VARCHAR2 ,                -- 쿠폰번호
  PSV_CERT_NO     IN  VARCHAR2                  -- 인증번호
) RETURN TBL_MMS_RSLT AS
/******************************************************************************
   NAME:       F_GET_MMS_SEND_RESULT      MMS 전송결과 취득
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     F_GET_MMS_SEND_RESULT
      SYSDATE:         2014-07-11
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_tbl_name     VARCHAR2(2000) := 'MMS_LOG_';     -- 테이블 이름
    ls_sms_send_dtm VARCHAR2(20)   := NULL;
    
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd       VARCHAR2(7) := '0' ;
    ls_err_msg      VARCHAR2(500) ;
    
    ll_msg_key      MMS_MSG.MSGKEY%TYPE;
    ll_rec_cnt      NUMBER := 0;
    ll_prc_cnt      NUMBER := 0;
    
    TYPE TYP_MMS IS REF CURSOR;
    CUR_1   TYP_MMS;
    nMSGKEY  MMS_MSG.MSGKEY%TYPE;
    vRSLT    MMS_MSG.RSLT%TYPE;
    vERRMSG  MMS_ERR_MSG.MSG%TYPE;
    vSENDDT  C_COUPON_CUST_GIFT.GIFT_SEND_DT%TYPE;
    
    MMS_RESULT_S        TBL_MMS_RSLT := TBL_MMS_RSLT();   -- SINGLE RECORD
    MMS_RESULT_M        TBL_MMS_RSLT := TBL_MMS_RSLT();   -- MULTI RECORD
BEGIN
    /*** MMS KEY(일련번호) ***/
    ll_msg_key      := MMS_MSG_SEQ.NEXTVAL;
    ls_sms_send_dtm := TO_CHAR(SYSDATE+1/1440, 'YYYYMMDDHH24MISS');
    
    /* 선물 내역 조회 */
    SELECT  MSGKEY,  GIFT_SEND_DT
    INTO    nMSGKEY, vSENDDT
    FROM    C_COUPON_CUST_GIFT
    WHERE   COMP_CD   = PSV_COMP_CD
    AND     COUPON_CD = PSV_COUPON_CD
    AND     CERT_NO   = PSV_CERT_NO;
    
    ls_tbl_name := ls_tbl_name||SUBSTR(REPLACE(vSENDDT, '/', ''), 1, 6);
    
    /* MMS 전송이력 테이블 조내 체크 */    
    SELECT COUNT(*) INTO ll_rec_cnt
    FROM   TAB
    WHERE  TABTYPE = 'TABLE'
    AND    TNAME   = ls_tbl_name;

    /*** MMS 전송 테이블 조회 ***/
    ls_sql := ' 
                SELECT  MM.MSGKEY, MM.RSLT, 
                        CASE WHEN MM.RSLT IS NULL THEN ''미전송'' ELSE NVL(ME.MSG, ''정의되지 않은 오류'') END AS ERR_MSG
                FROM    MMS_MSG     MM
                      , MMS_ERR_MSG ME
                WHERE   MM.RSLT   = ME.CODE(+)
                AND     MM.MSGKEY = ' || nMSGKEY;
    
    /*** MMS 전송 로그 테이블 조회 ***/
    IF ll_rec_cnt > 0 THEN
        ls_sql := ls_sql ||
              '             
                UNION ALL
                SELECT  MM.MSGKEY, MM.RSLT, 
                        CASE WHEN MM.RSLT IS NULL THEN ''미전송'' ELSE NVL(ME.MSG, ''정의되지 않은 오류'') END AS ERR_MSG
                FROM   '|| ls_tbl_name ||' MM
                      , MMS_ERR_MSG        ME 
                WHERE   MM.RSLT   = ME.CODE(+)
                AND     MM.MSGKEY = ' || nMSGKEY;
    END IF;            
                        
    DBMS_OUTPUT.PUT_LINE(ls_sql);
    
    OPEN CUR_1 FOR ls_sql;
    
    /*** MMS 전송 테이블 작성 ***/
    LOOP 
        FETCH CUR_1 INTO nMSGKEY, vRSLT, vERRMSG;
        
        EXIT WHEN CUR_1%NOTFOUND;
        
        SELECT  OT_MMS_RSLT
                   (
                    COMP_CD,
                    KEY_CODE1,
                    KEY_CODE2,
                    MSGKEY,
                    ERR_CODE,
                    ERR_MSG
                   )
            BULK COLLECT INTO MMS_RESULT_S
            FROM   (
                    SELECT  PSV_COMP_CD     COMP_CD,
                            PSV_COUPON_CD   KEY_CODE1,
                            PSV_CERT_NO     KEY_CODE2,
                            nMSGKEY         MSGKEY,
                            vRSLT           ERR_CODE,
                            vERRMSG         ERR_MSG
                    FROM    DUAL
                   );

            MMS_RESULT_M.EXTEND;
            MMS_RESULT_M(MMS_RESULT_M.LAST) := MMS_RESULT_S(MMS_RESULT_S.LAST);
    END LOOP;
    
RETURN MMS_RESULT_M;

EXCEPTION
    WHEN OTHERS THEN
        RETURN MMS_RESULT_M;
END ;

/
