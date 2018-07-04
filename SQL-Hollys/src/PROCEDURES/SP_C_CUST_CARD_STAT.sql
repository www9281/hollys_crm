--------------------------------------------------------
--  DDL for Procedure SP_C_CUST_CARD_STAT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_C_CUST_CARD_STAT" (
   PSV_COMP_CD     IN VARCHAR2,
   PSV_CARD_ID     IN VARCHAR2,
   PSV_PIN_NO      IN VARCHAR2,
   PSV_CARD_STAT   IN VARCHAR2,
   PSV_REMARKS     IN VARCHAR2,
   PSV_USER_ID     IN VARCHAR2)
IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_C_CUST_CARD_STAT
--  Description      :
--  Ref. Table       :
--------------------------------------------------------------------------------
--  Create Date      : 2015-04-16 엠즈씨드 CRM PJT
--  Modify Date      : 2015-04-16
--------------------------------------------------------------------------------
    vCUST_ID        C_CARD.CUST_ID%TYPE     := NULL;
    vREP_CARD_YN    C_CARD.REP_CARD_YN%TYPE := NULL;
    vCARD_STAT      C_CARD.CARD_STAT%TYPE   := NULL;
    nREC_CNT        NUMBER(5)               := 0;     
BEGIN
    SELECT  CUST_ID    , 
            CARD_STAT  , 
            REP_CARD_YN 
    INTO    vCUST_ID, vCARD_STAT, vREP_CARD_YN
    FROM    C_CARD
    WHERE   COMP_CD = PSV_COMP_CD
    AND     CARD_ID = encrypt (PSV_COMP_CD);
    
    IF vCUST_ID IS NOT NULL THEN
        SELECT  COUNT(*) INTO nREC_CNT
        FROM    C_CARD
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     CUST_ID  = vCUST_ID
        AND     CARD_ID != encrypt (PSV_COMP_CD)
        AND     CARD_STAT IN ('00',' 10')
        AND     USE_YN   = 'Y';
    END IF;
    
    -- 회원카드 상태 변경
    BEGIN
        UPDATE  C_CARD
        SET     PIN_NO    = PSV_PIN_NO
             ,  CARD_STAT = PSV_CARD_STAT
             ,  REMARKS   = PSV_REMARKS
             ,  LOST_DT   = CASE WHEN CARD_STAT != '90' AND PSV_CARD_STAT = '90' THEN TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                                 WHEN CARD_STAT = '90'                           THEN LOST_DT
                                 ELSE NULL
                            END
             ,  CLOSE_DT  = CASE WHEN CARD_STAT = '90' AND PSV_CARD_STAT IN ('00', '10') THEN TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                                 ELSE NULL
                            END
             ,  REP_CARD_YN = CASE WHEN PSV_CARD_STAT = '90'                           THEN 'N' 
                                   WHEN PSV_CARD_STAT IN ('00', '10') AND nREC_CNT = 0 THEN 'Y'
                                   ELSE REP_CARD_YN
                              END     
             ,  UPD_DT    = SYSDATE
             ,  UPD_USER  = PSV_USER_ID
        WHERE   COMP_CD   = PSV_COMP_CD 
        AND     CARD_ID   = encrypt (PSV_CARD_ID);
    EXCEPTION
        WHEN OTHERS  THEN
            ROLLBACK;
    END;
    
    IF PSV_CARD_STAT = '90' AND nREC_CNT > 0 THEN 
        UPDATE  C_CARD
        SET     REP_CARD_YN = 'Y'
        WHERE   COMP_CD = PSV_COMP_CD
        AND     CARD_ID = (
                            SELECT  CARD_ID
                            FROM   (
                                    SELECT  CARD_ID
                                         ,  ROW_NUMBER() OVER(PARTITION BY CUST_ID ORDER BY ISSUE_DT DESC) R_NUM
                                    FROM    C_CARD
                                    WHERE   COMP_CD = PSV_COMP_CD
                                    AND     CUST_ID = vCUST_ID
                                    AND     CARD_STAT IN ('00',' 10')
                                    AND     USE_YN   = 'Y'
                                   )
                           WHERE    R_NUM = 1        
                          );          
    END IF;
    
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
END;

/
