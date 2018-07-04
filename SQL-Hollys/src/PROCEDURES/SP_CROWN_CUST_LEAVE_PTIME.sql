--------------------------------------------------------
--  DDL for Procedure SP_CROWN_CUST_LEAVE_PTIME
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_CUST_LEAVE_PTIME" 
(
    PSV_COMP_CD       IN    VARCHAR2,       -- 회사코드
    PSV_STD_DT        IN    VARCHAR2        -- 탈퇴일자
)
--------------------------------------------------------------------------------
--  Procedure Name   : SP_CROWN_CUST_LEAVE_PTIME
--  Description      : 회원탈퇴 포인트 초기화
--  Ref. Table       : C_CARD_SAV_HIS
--------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 
--  Modify Date      : 
--  Modify Programer : 
--------------------------------------------------------------------------------
IS
    CURSOR CUR_1 IS
        SELECT  CU.COMP_CD
             ,  CU.CUST_ID
             ,  CA.CARD_ID
             ,  CU.LEAVE_DT
             ,  NVL(CU.SAV_PT, CA.SAV_PT) - NVL(CU.USE_PT, CA.USE_PT) - NVL(CU.LOS_PT, CA.LOS_PT)   AS POINT
          FROM  C_CUST  CU
             ,  C_CARD  CA
         WHERE  CU.COMP_CD  = CA.COMP_CD(+)
           AND  CU.CUST_ID  = CA.CUST_ID(+)
           AND  CU.COMP_CD  = PSV_COMP_CD
           AND  CU.CUST_STAT= '9'
           AND  TO_CHAR(TO_DATE(CU.LEAVE_DT, 'YYYYMMDDHH24MISS'), 'YYYYMMDD') = NVL(PSV_STD_DT, TO_CHAR(SYSDATE, 'YYYYMMDD'));

    ERR_HANDLER     EXCEPTION;
BEGIN

    FOR MYREC IN CUR_1 LOOP
        IF MYREC.CARD_ID IS NOT NULL THEN
            -- 멤버십 회원인 경우
            -- 1. 포인트 소멸처리
            INSERT  INTO C_CARD_SAV_HIS
            (
                    COMP_CD
                ,   CARD_ID
                ,   USE_DT
                ,   USE_SEQ
                ,   SAV_USE_FG
                ,   SAV_USE_DIV
                ,   REMARKS
                ,   LOS_MLG_YN
                ,   LOS_MLG_DT
                ,   LOS_PT
                ,   LOS_PT_YN
                ,   LOS_PT_DT
                ,   USE_YN
                ,   INST_DT
                ,   INST_USER
                ,   UPD_DT
                ,   UPD_USER
            ) VALUES (
                    MYREC.COMP_CD
                ,   MYREC.CARD_ID
                ,   MYREC.LEAVE_DT
                ,   SQ_PCRM_SEQ.NEXTVAL
                ,   '2'
                ,   '102'
                ,   '회원탈퇴 소멸'
                ,   'Y'
                ,   MYREC.LEAVE_DT
                ,   MYREC.POINT
                ,   'Y'
                ,   MYREC.LEAVE_DT
                ,   'Y'
                ,   SYSDATE
                ,   'SYSTEM'
                ,   SYSDATE
                ,   'SYSTEM'
            );

            -- 2.카드 해지
            UPDATE  C_CARD
               SET  CARD_STAT   = '91'
                 ,  CANCEL_DT   = MYREC.LEAVE_DT
                 ,  REMARKS     = '회원탈퇴 해지'
                 ,  UPD_DT      = SYSDATE
                 ,  UPD_USER    = 'SYSTEM'
             WHERE  COMP_CD     = MYREC.COMP_CD
               AND  CARD_ID     = MYREC.CARD_ID;
        ELSE
            -- 일반회원인 경우
            -- 고객테이블의 포인트 초기화
            UPDATE  C_CUST
               SET  LOS_PT      = MYREC.POINT
             WHERE  COMP_CD     = MYREC.COMP_CD
               AND  CUST_ID     = MYREC.CUST_ID;

        END IF;

    END LOOP;

    COMMIT;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN;
END;

/
