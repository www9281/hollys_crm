--------------------------------------------------------
--  DDL for Procedure SP_GET_C_CUST_MSG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_GET_C_CUST_MSG" 
   (
    PSV_COMP_CD       IN    VARCHAR2,               -- 회사코드
    PSV_LANG_TP       IN    VARCHAR2,               -- 언어타입
    PSV_CUST_ID       IN    VARCHAR2,               -- 고객번호
    PSV_PRT_DIV       IN    VARCHAR2,               -- 01:등업, 02:첫충전, 03:가입, 04:생일, 05:12+1, 06:구매, 07:첫충전
    PSV_RTN_CD        OUT   VARCHAR2,               -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2                -- 처리Message
   ) IS
/******************************************************************************
   NAME:       SP_GET_C_CUST_MSG
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/06/17   XPMUser       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_GET_C_CUST_MSG
      Sysdate:         2015/06/17
      Date and Time:   2015/06/17, 오후 1:02:09, and 2015/06/17 오후 1:02:09
      Username:        XPMUser (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
    nRECCNT     NUMBER(5) := NULL;
BEGIN
    IF PSV_PRT_DIV = '02' THEN
        IF PSV_CUST_ID IS NULL OR LENGTHB(PSV_CUST_ID) = 0 THEN
            BEGIN
                SELECT  'Y', CUST_MSG
                INTO    PSV_RTN_CD, PSV_RTN_MSG
                FROM    C_CUST_MSG
                WHERE   COMP_CD   = PSV_COMP_CD
                AND     PRT_DIV   = PSV_PRT_DIV
                AND     CUST_STAT = '1';
            EXCEPTION
                WHEN OTHERS THEN
                       PSV_RTN_CD  := 'N';
                       PSV_RTN_MSG := NULL;
            END;               
        ELSE
            SELECT  COUNT(*) INTO nRECCNT
            FROM    C_COUPON_CUST       CCC
                  , C_COUPON_ITEM_GRP   CCI
            WHERE   CCC.COMP_CD   = CCI.COMP_CD
            AND     CCC.COUPON_CD = CCI.COUPON_CD
            AND     CCC.GRP_SEQ   = CCI.GRP_SEQ
            AND     CCC.COMP_CD   = PSV_COMP_CD
            AND     CCC.CUST_ID   = PSV_CUST_ID
            AND    (
                    1 = (
                         CASE WHEN PSV_PRT_DIV = '02' THEN 1
                              WHEN PSV_PRT_DIV = '03' THEN 1
                              WHEN PSV_PRT_DIV = '07' THEN 1
                              WHEN PSV_PRT_DIV = '04' AND CCC.CERT_FDT BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + 1, - 12), 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN 1
                              ELSE 0
                         END
                        )
                   )    
            AND     CCI.PRT_DIV   = PSV_PRT_DIV
            AND     CCC.USE_STAT != '32';
            
            IF nRECCNT = 0 THEN
                BEGIN
                    SELECT  'Y', CUST_MSG
                    INTO    PSV_RTN_CD, PSV_RTN_MSG
                    FROM    C_CUST_MSG
                    WHERE   COMP_CD   = PSV_COMP_CD
                    AND     PRT_DIV   = PSV_PRT_DIV
                    AND     CUST_STAT = '2';
                EXCEPTION
                    WHEN OTHERS THEN
                           PSV_RTN_CD  := 'N';
                           PSV_RTN_MSG := NULL;
                END;
            ELSE
                PSV_RTN_CD  := 'N';
                PSV_RTN_MSG := NULL;    
            END IF;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD  := 'N';
        PSV_RTN_MSG := NULL;    
END SP_GET_C_CUST_MSG;

/
