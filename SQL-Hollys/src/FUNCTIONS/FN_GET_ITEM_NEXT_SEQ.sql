--------------------------------------------------------
--  DDL for Function FN_GET_ITEM_NEXT_SEQ
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_ITEM_NEXT_SEQ" 
(
    PSV_COMP_CD       IN VARCHAR2,  -- 회사코드
    PSV_S_CLASS_CD    IN VARCHAR2   -- 소분류코드
)   RETURN  VARCHAR2 
IS
    nRECCNT     NUMBER(5) := 0;
    nNXTSEQ     NUMBER(5) := 0;
    vRTNVAL     ITEM.ITEM_CD%TYPE := NULL;

    ERR_HANDLER     EXCEPTION;  
BEGIN
    IF PSV_COMP_CD IS NULL OR PSV_S_CLASS_CD IS NULL THEN
        RAISE ERR_HANDLER;
    END IF; 

    SELECT  COUNT(*) INTO nRECCNT
    FROM    ITEM_SEQ_MST
    WHERE   COMP_CD    = PSV_COMP_CD
    AND     S_CLASS_CD = PSV_S_CLASS_CD;

    IF nRECCNT = 0 THEN
        INSERT INTO ITEM_SEQ_MST
        VALUES(PSV_COMP_CD, PSV_S_CLASS_CD, 1, SYSDATE, 'SYS', SYSDATE, 'SYS');

        COMMIT;
    END IF;

    SELECT  SEQ_NO INTO nNXTSEQ
    FROM    ITEM_SEQ_MST
    WHERE   COMP_CD    = PSV_COMP_CD
    AND     S_CLASS_CD = PSV_S_CLASS_CD
    FOR UPDATE NOWAIT;

    vRTNVAL := PSV_S_CLASS_CD||TO_CHAR(nNXTSEQ, 'FM0000');

    UPDATE  ITEM_SEQ_MST
    SET     SEQ_NO     = nNXTSEQ + 1
          , UPD_DT     = SYSDATE
          , UPD_USER   = 'SYS'
    WHERE   COMP_CD    = PSV_COMP_CD
    AND     S_CLASS_CD = PSV_S_CLASS_CD;

    COMMIT;

    RETURN vRTNVAL;
EXCEPTION 
    WHEN OTHERS THEN
        RETURN '-1';    
END FN_GET_ITEM_NEXT_SEQ;

/
