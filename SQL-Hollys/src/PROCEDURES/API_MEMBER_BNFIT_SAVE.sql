--------------------------------------------------------
--  DDL for Procedure API_MEMBER_BNFIT_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_MEMBER_BNFIT_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	멤버십혜택 사용/취소
-- Test			:	exec API_MEMBER_BNFIT_SAVE '016', '101', '977', '1011010015', '101'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_CUST_ID       IN   VARCHAR2,
        N_ITEM_CD       IN   VARCHAR2,
        N_STOR_CD       IN   VARCHAR2,
        P_USE_DIV       IN   VARCHAR2,
        O_RTN_CD        OUT  VARCHAR2
) AS 
        v_result_cd     VARCHAR2(7) := '1'; --성공
        v_result_use_yn VARCHAR2(1);
        ALREADY_USED_MEMBER_BNFIT EXCEPTION;
BEGIN

        SELECT 
              DECODE(COUNT(*), 0, 'Y', 'N')
              INTO v_result_use_yn
        FROM  MEMBER_BNFIT 
        WHERE COMP_CD = P_COMP_CD 
        AND   BRAND_CD = P_BRAND_CD 
        AND   CUST_ID = P_CUST_ID 
        AND   USE_DT = TO_CHAR(SYSDATE, 'YYYYMMDD');
        
       IF P_USE_DIV = '101' THEN -- 적립
       
            IF v_result_use_yn = 'N' THEN
              RAISE ALREADY_USED_MEMBER_BNFIT;
            END IF;
       
            INSERT INTO MEMBER_BNFIT (
                  COMP_CD
                  ,BRAND_CD
                  ,CUST_ID
                  ,ITEM_CD
                  ,STOR_CD
                  ,USE_DT
            ) VALUES (
                  P_COMP_CD
                  ,P_BRAND_CD
                  ,P_CUST_ID
                  ,N_ITEM_CD
                  ,N_STOR_CD
                  ,TO_CHAR(SYSDATE, 'YYYYMMDD')
            );
        ELSE
            DELETE FROM MEMBER_BNFIT 
            WHERE  CUST_ID = P_CUST_ID
            AND    USE_DT = TO_CHAR(SYSDATE, 'YYYYMMDD');
        END IF;

        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN ALREADY_USED_MEMBER_BNFIT THEN
        O_RTN_CD  := '601'; -- 이미 멤버십혜택을 사용하신 고객입니다.
    WHEN OTHERS THEN
        O_RTN_CD  := '2';
        
END API_MEMBER_BNFIT_SAVE;

/
