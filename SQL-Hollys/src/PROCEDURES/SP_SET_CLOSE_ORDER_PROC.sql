--------------------------------------------------------
--  DDL for Procedure SP_SET_CLOSE_ORDER_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_CLOSE_ORDER_PROC" 
(
    vCOMP_CD        IN VARCHAR2,
    vORD_DT         IN VARCHAR2,
    vORD_CLOSE_TM   IN VARCHAR2
) IS
    /* 주문정보 마감 처리 */ 
    nRECCNT         NUMBER(3) := 0;
BEGIN

    /* 0:미처리, 1:발주마감, 2:반품마감 */               
    UPDATE  /*+ INDEX(ORDER_HDV, IX01_ORDER_HDV) */
            ORDER_HDV
    SET     CFM_FG    = ORD_FG
    WHERE   COMP_CD   = vCOMP_CD
    AND     CFM_FG    = '0'
    AND     ORD_DIV   = '0'
    AND     (ORD_DT = NVL(vORD_DT, TO_CHAR(SYSDATE, 'YYYYMMDD')) OR TO_CHAR(INST_DT, 'YYYYMMDD') = NVL(vORD_DT, TO_CHAR(SYSDATE, 'YYYYMMDD')));               

    DBMS_OUTPUT.PUT_LINE('PROCESS NORMAL END');

    /* 정상처리 */
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    ROLLBACK;
END SP_SET_CLOSE_ORDER_PROC;

/
