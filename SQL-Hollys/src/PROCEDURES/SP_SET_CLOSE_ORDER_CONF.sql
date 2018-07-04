--------------------------------------------------------
--  DDL for Procedure SP_SET_CLOSE_ORDER_CONF
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_CLOSE_ORDER_CONF" 
(
    PSV_COMP_CD     IN VARCHAR2,
    PSV_BRAND_CD    IN VARCHAR2,
    PSV_ORD_DT      IN VARCHAR2
) IS
    
    vORD_COLSE_TM VARCHAR(4) := '0000';

BEGIN

    -- 주문마감시간 변경처리
    -- 모스버거 평일/토요일 오후 5시 마감, 일요일 오후3시 마감
    IF PSV_COMP_CD = '012' AND PSV_BRAND_CD = '101' THEN
        IF TO_CHAR(TRUNC(SYSDATE, 'D'), 'YYYYMMDD') = PSV_ORD_DT THEN
            vORD_COLSE_TM := '1500';
        ELSE
            vORD_COLSE_TM := '1700';
        END IF;
    ELSE
        RETURN;
    END IF;

    UPDATE  COMMON
       SET  VAL_C1    = vORD_COLSE_TM
         ,  VAL_C2    = vORD_COLSE_TM
         ,  UPD_DT    = SYSDATE
     WHERE  COMP_CD   = PSV_COMP_CD
       AND  CODE_CD   = PSV_BRAND_CD
       AND  CODE_TP   = '60005'
       AND  USE_YN    = 'Y'                  
    ;

    /* 정상처리 */
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    ROLLBACK;
END SP_SET_CLOSE_ORDER_CONF;

/
