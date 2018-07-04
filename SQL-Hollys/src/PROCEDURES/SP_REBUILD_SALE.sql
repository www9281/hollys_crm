--------------------------------------------------------
--  DDL for Procedure SP_REBUILD_SALE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_REBUILD_SALE" 
                ( PSV_COMP_CD       IN  VARCHAR2, -- 회사코드
                  FR_YMD            IN  VARCHAR2, -- 
                  TO_YMD            IN  VARCHAR2  -- 
                ) IS

---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_REBUILD_SALE
--  Description      : 매출데이터 보정 프로시져
--  Ref. Table       : 
---------------------------------------------------------------------------------------------------
--  Create Date      : 2015-06-01
--  Create Programer : 최세원
--  Modify Date      : 2015-06-01
--  Modify Programer :
---------------------------------------------------------------------------------------------------

PR_RTN_CD VARCHAR2(10);

CURSOR C_CAL IS
    SELECT  C.YMD
      FROM  CALENDAR    C
     WHERE  C.YMD BETWEEN FR_YMD AND TO_YMD
     ORDER  BY C.YMD
     ;

BEGIN
    FOR C IN C_CAL LOOP
        BATCH_TRANS_SALE_DATA_FRPOS(C.YMD, PR_RTN_CD);
        COMMIT;        
    END LOOP;
    
    COMMIT;
    
Exception When OTHERS Then
   ROLLBACK;
END  ;

/
