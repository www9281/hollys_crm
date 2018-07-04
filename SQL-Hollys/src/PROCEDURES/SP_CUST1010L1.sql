--------------------------------------------------------
--  DDL for Procedure SP_CUST1010L1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CUST1010L1" /* 회원정보관리 MMS 전송이력 */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_LANG_TP     IN  VARCHAR2 ,                -- 언어코드
  PSV_PHONE       IN  VARCHAR2 ,                -- 휴대전화번호
  PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_CUST1010L1      회원정보관리 MMS 전송이력
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
    CURSOR CUR_1 IS
        SELECT  TO_CHAR(ADD_MONTHS(SYSDATE, (ROWNUM - 1) *(-1)), 'YYYYMM') AS STD_YM
        FROM    TAB
        WHERE   ROWNUM <= 12
        ORDER BY 1 DESC; 
        
    ls_sql          VARCHAR2(30000) ;
    ls_sms_tbl      VARCHAR2(2000) := NULL; -- SMS 테이블 이름
    ls_mms_tbl      VARCHAR2(2000) := NULL; -- MMS 테이블 이름
    ls_sms_send_dtm VARCHAR2(20)   := NULL;
    
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd       VARCHAR2(7) := '0' ;
    ls_err_msg      VARCHAR2(500) ;
    
    ll_msg_key      MMS_MSG.MSGKEY%TYPE;
    ll_sms_cnt      NUMBER := 0;
    ll_mms_cnt      NUMBER := 0;
    
BEGIN
    FOR MYREC IN CUR_1 LOOP
        /*** MMS KEY(일련번호) ***/
        ll_msg_key      := MMS_MSG_SEQ.NEXTVAL;
        ls_sms_send_dtm := TO_CHAR(SYSDATE+1/1440, 'YYYYMMDDHH24MISS');
        ls_sms_tbl     := 'SC_LOG_'  ||MYREC.STD_YM;
        ls_mms_tbl     := 'MMS_LOG_' ||MYREC.STD_YM;
        
        /* SMS, MMS 로그 테이블 존재 체크 */
        SELECT COUNT(*) INTO ll_sms_cnt
        FROM   TAB
        WHERE  TABTYPE = 'TABLE'
        AND    TNAME   = ls_sms_tbl;
        
        SELECT COUNT(*) INTO ll_mms_cnt
        FROM   TAB
        WHERE  TABTYPE = 'TABLE'
        AND    TNAME   = ls_mms_tbl;
        
        /*** MMS 전송 테이블 조회 ***/
        IF TO_CHAR(SYSDATE, 'YYYYMM') = MYREC.STD_YM THEN
            ls_sql := ' SELECT  TO_CHAR(REQDATE, ''YYYYMMDD'') AS SEND_DATE 
                              , TO_CHAR(REQDATE, ''HH24MISS'') AS SEND_TIME
                              , RSLT                           AS SEND_RSLT_CD
                              , CASE WHEN RSLT IS NULL    THEN ''전송중''
                                     WHEN RSLT = ''1000'' THEN ''전송완료''
                                     ELSE                      ''전송오류''
                                END                            AS  SEND_RELT_MSG
                              , MSG                            AS  SEND_MSG
                        FROM    MMS_MSG
                        WHERE   PHONE = ''' || PSV_PHONE ||'''
                        UNION ALL
                        SELECT  TO_CHAR(TR_SENDDATE, ''YYYYMMDD'') AS SEND_DATE 
                              , TO_CHAR(TR_SENDDATE, ''HH24MISS'') AS SEND_TIME
                              , CASE WHEN TR_SENDSTAT  = ''0''                          THEN ''0000''
                                     WHEN TR_SENDSTAT != ''0'' AND TR_RSLTSTAT = ''06'' THEN ''1000''
                                     ELSE                                                    ''9999''
                                END                                AS SEND_RSLT_CD
                              , CASE WHEN TR_SENDSTAT  = ''0''                          THEN ''전송중''
                                     WHEN TR_SENDSTAT != ''0'' AND TR_RSLTSTAT = ''06'' THEN ''전송완료''
                                     ELSE                                                    ''전송오류''
                                END                            AS  SEND_RELT_MSG
                              , TR_MSG                         AS  SEND_MSG
                        FROM    SC_TRAN
                        WHERE   TR_PHONE = ''' || PSV_PHONE ||'''
                        ';
                        
            IF ll_mms_cnt > 0 THEN
                ls_sql := ls_sql ||
                          ' UNION ALL
                            SELECT  TO_CHAR(REQDATE, ''YYYYMMDD'') AS SEND_DATE 
                                  , TO_CHAR(REQDATE, ''HH24MISS'') AS SEND_TIME
                                  , RSLT                           AS  SEND_RSLT_CD
                                  , CASE WHEN RSLT IS NULL    THEN ''전송중''
                                         WHEN RSLT = ''1000'' THEN ''전송완료''
                                         ELSE                      ''전송오류''
                                    END                            AS  SEND_RELT_MSG
                                  , MSG                            AS  SEND_MSG
                            FROM   '|| ls_mms_tbl ||' 
                            WHERE   PHONE = ''' || PSV_PHONE||'''';
            END IF;
            
            IF ll_sms_cnt > 0 THEN
                ls_sql := ls_sql ||
                          ' UNION ALL
                            SELECT  TO_CHAR(TR_SENDDATE, ''YYYYMMDD'') AS SEND_DATE 
                              , TO_CHAR(TR_SENDDATE, ''HH24MISS'') AS SEND_TIME
                              , CASE WHEN TR_SENDSTAT  = ''0''                          THEN ''0000''
                                     WHEN TR_SENDSTAT != ''0'' AND TR_RSLTSTAT = ''06'' THEN ''1000''
                                     ELSE                                                    ''9999''
                                END                                AS SEND_RSLT_CD
                              , CASE WHEN TR_SENDSTAT  = ''0''                          THEN ''전송중''
                                     WHEN TR_SENDSTAT != ''0'' AND TR_RSLTSTAT = ''06'' THEN ''전송완료''
                                     ELSE                                                    ''전송오류''
                                END                            AS  SEND_RELT_MSG
                              , TR_MSG                         AS  SEND_MSG
                            FROM   '|| ls_sms_tbl ||' 
                            WHERE   TR_PHONE = ''' || PSV_PHONE||'''';
            END IF;                        
        ELSE
            IF ll_mms_cnt > 0 THEN
                ls_sql := ls_sql ||
                          ' UNION ALL
                            SELECT  TO_CHAR(REQDATE, ''YYYYMMDD'') AS SEND_DATE 
                                  , TO_CHAR(REQDATE, ''HH24MISS'') AS SEND_TIME
                                  , RSLT                           AS  SEND_RSLT_CD
                                  , CASE WHEN RSLT IS NULL    THEN ''전송중''
                                         WHEN RSLT = ''1000'' THEN ''전송완료''
                                         ELSE                      ''전송오류''
                                    END                            AS  SEND_RELT_MSG
                                  , MSG                            AS  SEND_MSG
                            FROM   '|| ls_mms_tbl ||' 
                            WHERE   PHONE = ''' || PSV_PHONE||'''';
            END IF;
            
            IF ll_sms_cnt > 0 THEN
                ls_sql := ls_sql ||
                          ' UNION ALL
                            SELECT  TO_CHAR(TR_SENDDATE, ''YYYYMMDD'') AS SEND_DATE 
                              , TO_CHAR(TR_SENDDATE, ''HH24MISS'') AS SEND_TIME
                              , CASE WHEN TR_SENDSTAT  = ''0''                          THEN ''0000''
                                     WHEN TR_SENDSTAT != ''0'' AND TR_RSLTSTAT = ''06'' THEN ''1000''
                                     ELSE                                                    ''9999''
                                END                                AS SEND_RSLT_CD
                              , CASE WHEN TR_SENDSTAT  = ''0''                          THEN ''전송중''
                                     WHEN TR_SENDSTAT != ''0'' AND TR_RSLTSTAT = ''06'' THEN ''전송완료''
                                     ELSE                                                    ''전송오류''
                                END                            AS  SEND_RELT_MSG
                              , TR_MSG                         AS  SEND_MSG
                            FROM   '|| ls_sms_tbl ||' 
                            WHERE   TR_PHONE = ''' || PSV_PHONE||'''';
            END IF;
        END IF;            
                        
    END LOOP;
    
    ls_sql := ls_sql ||' ORDER BY 1 DESC, 2 DESC ';
    
    dbms_output.put_line(ls_sql);
    
    OPEN PR_RESULT FOR ls_sql;
    
    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;
EXCEPTION
    WHEN ERR_HANDLER THEN
        OPEN PR_RESULT FOR
            SELECT 0 FROM DUAL;
        
        PR_RTN_CD  := SQLCODE;
        PR_RTN_MSG := SQLERRM ;
       dbms_output.put_line( PR_RTN_MSG ) ;
    WHEN OTHERS THEN
        OPEN PR_RESULT FOR
            SELECT 0 FROM DUAL;
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
        dbms_output.put_line( PR_RTN_MSG ) ;
END ;

/
