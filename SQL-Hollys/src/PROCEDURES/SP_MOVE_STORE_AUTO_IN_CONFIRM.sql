--------------------------------------------------------
--  DDL for Procedure SP_MOVE_STORE_AUTO_IN_CONFIRM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MOVE_STORE_AUTO_IN_CONFIRM" 
(
  PSV_COMP_CD     IN  VARCHAR2 ,  -- Company Code
  PSV_BRAND_CD    IN  VARCHAR2 ,  -- 영업조직
  PSV_EXEC_YM     IN  VARCHAR2 ,  -- 실행년월
  PSV_EXEC_DIV    IN  VARCHAR2    -- 실행구분(1 : 1 ~ 15일 마감, 2 : 16 ~ 말일 마감)
)
IS
/******************************************************************************
   NAME:       SP_MOVE_STORE_AUTO_IN_CONFIRM  점간이동 자동입고확정 처리 프로시져
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2013-02-04         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MOVE_STORE_AUTO_IN_CONFIRM
      SYSDATE:         2013-02-04
      USERNAME:
      TABLE NAME:
******************************************************************************/

    ls_fr_dt      VARCHAR2(8);  -- 조회일자 (시작)
    ls_to_dt      VARCHAR2(8);  -- 조회일자 (종료)
    ls_in_dt      VARCHAR2(8);  -- 입고확정일자
    ls_remark     VARCHAR2(100) ;
    ls_err_msg    VARCHAR2(500) ;


    ERR_HANDLER   EXCEPTION;

BEGIN

    dbms_output.enable( 1000000 );

    IF LENGTH(PSV_EXEC_YM) != 6 THEN

        ls_err_msg := '파라미터 값이 부정확합니다. (PSV_EXEC_YM : ' || PSV_EXEC_YM || ')';
        dbms_output.put_line( ls_err_msg ) ;
        RAISE ERR_HANDLER;

    END IF;

    IF PSV_EXEC_DIV = '1' THEN

        ls_fr_dt  := PSV_EXEC_YM || '01';
        ls_to_dt  := PSV_EXEC_YM || '15';
        ls_in_dt  := PSV_EXEC_YM || '15';
        ls_remark := '자동확정_' || PSV_EXEC_YM || '15';

    ELSIF PSV_EXEC_DIV = '2' THEN

        ls_fr_dt  := PSV_EXEC_YM || '16';
        ls_to_dt  := TO_CHAR(LAST_DAY(TO_DATE(PSV_EXEC_YM, 'YYYYMM')));
        ls_in_dt  := TO_CHAR(LAST_DAY(TO_DATE(PSV_EXEC_YM, 'YYYYMM')));
        ls_remark := '자동확정_' || TO_CHAR(LAST_DAY(TO_DATE(PSV_EXEC_YM, 'YYYYMM')));
    ELSE

        ls_err_msg := '파라미터 값이 부정확합니다. (PSV_EXEC_DIV : ' || PSV_EXEC_DIV || ')';
        dbms_output.put_line( ls_err_msg ) ;
        RAISE ERR_HANDLER;

    END IF;

    UPDATE  MOVE_STORE
       SET  IN_CONF_DT  = ls_in_dt
         ,  HQ_CONF_DT  = ls_in_dt
         ,  CONFIRM_DIV = '4'
         ,  REMARKS     = ls_remark
         ,  UPD_DT      = SYSDATE
         ,  UPD_USER    = 'SYSTEM'
     WHERE  COMP_CD     = PSV_COMP_CD 
       --AND (PSV_BRAND_CD IS NULL OR IN_BRAND_CD = PSV_BRAND_CD)
       AND  CONFIRM_DIV = '2'
       AND  OUT_CONF_DT BETWEEN ls_fr_dt AND ls_to_dt;

    COMMIT;

EXCEPTION
    WHEN ERR_HANDLER THEN
        ROLLBACK;

    WHEN OTHERS THEN
        dbms_output.put_line( SQLERRM ) ;
        ROLLBACK;
END ;

/
