--------------------------------------------------------
--  DDL for Procedure C_CUST_CARD_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CARD_UPDATE" (
    P_COMP_CD     IN VARCHAR2,
    P_CARD_ID     IN VARCHAR2,
    P_PIN_NO      IN VARCHAR2,
    P_CARD_STAT   IN VARCHAR2,
    P_DISP_YN     IN VARCHAR2,
    P_REMARKS     IN VARCHAR2,
    P_MY_USER_ID 	    IN  VARCHAR2,
    O_PR_RTN_CD       OUT VARCHAR2,                -- 처리코드
    O_PR_RTN_MSG      OUT VARCHAR2                 -- 처리Message
   )
IS 
--------------------------------------------------------------------------------
--  Procedure Name   : C_CUST_CARD_UPDATE
--  Description      : 카드정보 수정
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2017-09-21 Hollys CRM
--  Modify Date      : 2017-09-21
--------------------------------------------------------------------- -----------
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
    WHERE   COMP_CD = P_COMP_CD
    AND     CARD_ID = encrypt (P_CARD_ID);
    
    IF vCUST_ID IS NOT NULL THEN
        SELECT  COUNT(*) INTO nREC_CNT
        FROM    C_CARD
        WHERE   COMP_CD  = P_COMP_CD
        AND     CUST_ID  = vCUST_ID
        AND     CARD_ID != encrypt (P_CARD_ID)
        AND     CARD_STAT IN ('00', '10')
        AND     USE_YN   = 'Y';
    END IF;
    
    -- 회원카드 상태 변경
    BEGIN
        UPDATE  C_CARD
        SET     PIN_NO    = P_PIN_NO
             ,  CARD_STAT = P_CARD_STAT
             ,  REMARKS   = P_REMARKS
             ,  LOST_DT   = CASE WHEN CARD_STAT != '90' AND P_CARD_STAT = '90' THEN TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                                 WHEN CARD_STAT = '90'                           THEN LOST_DT
                                 ELSE NULL
                            END
             ,  CLOSE_DT  = CASE WHEN CARD_STAT = '90' AND P_CARD_STAT IN ('00', '10') THEN TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                                 ELSE NULL
                            END
             ,  REP_CARD_YN = CASE WHEN P_CARD_STAT = '90'                           THEN 'N' 
                                   WHEN P_CARD_STAT IN ('00', '10') AND nREC_CNT = 0 THEN 'Y'
                                   ELSE REP_CARD_YN
                              END
             ,  DISP_YN   = P_DISP_YN                      
             ,  UPD_DT    = SYSDATE
             ,  UPD_USER  = P_MY_USER_ID
        WHERE   COMP_CD   = P_COMP_CD 
        AND     CARD_ID   = encrypt (P_CARD_ID);
    EXCEPTION
        WHEN OTHERS  THEN
            ROLLBACK;
    END;
    
--    IF P_CARD_STAT = '90' AND nREC_CNT > 0 AND vREP_CARD_YN = 'Y' THEN 
--        UPDATE  C_CARD
--        SET     REP_CARD_YN = 'Y'
--        WHERE   COMP_CD = P_COMP_CD
--        AND     CARD_ID = (
--                            SELECT  CARD_ID
--                            FROM   (
--                                    SELECT  CARD_ID
--                                         ,  ROW_NUMBER() OVER(PARTITION BY CUST_ID ORDER BY ISSUE_DT DESC) R_NUM
--                                    FROM    C_CARD
--                                    WHERE   COMP_CD = P_COMP_CD
--                                    AND     CARD_ID != encrypt (P_CARD_ID)
--                                    AND     CUST_ID = vCUST_ID
--                                    AND     CARD_STAT IN ('00', '10')
--                                    AND     USE_YN   = 'Y'
--                                   )
--                           WHERE    R_NUM = 1
--                          );
--    END IF;
    
   COMMIT;
   
   O_PR_RTN_CD  := '0';
   O_PR_RTN_MSG := FC_GET_WORDPACK_MSG('', 'KOR', '1001000416');
   
   RETURN;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        O_PR_RTN_CD  := TO_CHAR(SQLCODE);
        O_PR_RTN_MSG := SQLERRM;
        
        RETURN;
END C_CUST_CARD_UPDATE;

/
