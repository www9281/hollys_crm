--------------------------------------------------------
--  DDL for Procedure PRMT_PUBLISH_NOTES_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PRMT_PUBLISH_NOTES_UPDATE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 쿠폰 발행 비고수정
-- Test			:	exec PRMT_PUBLISH_NOTES_UPDATE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID              IN    VARCHAR2,
        P_PUBLISH_ID           IN    VARCHAR2,
        P_NOTES                IN    VARCHAR2,
        P_USER_ID              IN    VARCHAR2,
        O_PUBLISH_ID           OUT   VARCHAR2,
        O_PUBLISH_TYPE         OUT   VARCHAR2,
        O_RTN_CD               OUT   VARCHAR2
) AS 
        
        v_result_cd VARCHAR2(7) := '1'; -- 성공(전체결과)

BEGIN

        SELECT PUBLISH_ID
               ,PUBLISH_TYPE
               INTO O_PUBLISH_ID, O_PUBLISH_TYPE
        FROM   PROMOTION_COUPON_PUBLISH
        WHERE  PRMT_ID = P_PRMT_ID
        AND    PUBLISH_ID = P_PUBLISH_ID;

        -- 비고 수정
        UPDATE PROMOTION_COUPON_PUBLISH
        SET    NOTES = P_NOTES
               ,UPD_USER = P_USER_ID
               ,UPD_DT = SYSDATE
        WHERE  PRMT_ID = P_PRMT_ID
        AND    PUBLISH_ID = P_PUBLISH_ID;

        O_RTN_CD := v_result_cd;

EXCEPTION

    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);

END PRMT_PUBLISH_NOTES_UPDATE;

/
