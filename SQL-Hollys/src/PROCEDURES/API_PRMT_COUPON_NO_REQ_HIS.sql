--------------------------------------------------------
--  DDL for Procedure API_PRMT_COUPON_NO_REQ_HIS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_PRMT_COUPON_NO_REQ_HIS" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:   쿠폰 번호 요청(발급/취소) 히스토리 기록
-- Test			:	exec API_PRMT_COUPON_NO_REQ_HIS '016', '101', '163'
-- ==========================================================================================
        P_COMP_CD        IN   VARCHAR2,
        P_BRAND_CD       IN   VARCHAR2,
        P_STOR_CD        IN   VARCHAR2,
        N_CRE_COUPON_SEQ IN   VARCHAR2,
        N_CRE_COUPON_CD  IN   VARCHAR2,
        N_COUPON_SEQ     IN   VARCHAR2,
        N_COUPON_CD      IN   VARCHAR2,
        P_USE_DIV        IN   VARCHAR2,
        P_POS_NO         IN   VARCHAR2, 
        P_BILL_NO        IN   VARCHAR2,  
        P_POS_SEQ        IN   VARCHAR2,
        P_POS_SALE_DT    IN   VARCHAR2,
        P_ITEM_CD        IN   VARCHAR2, 
        P_GROUP_ID       IN   VARCHAR2,
        P_USER_ID        IN   VARCHAR2,
        O_COUPON_CD      OUT  VARCHAR2,
        O_COUPON_SEQ     OUT  VARCHAR2,
        O_START_DT       OUT  VARCHAR2,
        O_END_DT         OUT  VARCHAR2,
        O_GROUP_ID       OUT  VARCHAR2,
        O_RTN_CD         OUT  VARCHAR2
) AS 
        v_result_cd      VARCHAR2(7) := '1'; --성공
        v_coupon_his_seq NUMBER; -- 쿠폰 히스토리시퀀스
BEGIN   
        IF P_USE_DIV = '101' THEN -- 발급일때

            BEGIN
                -- 쿠폰히스토리 기록
                SELECT COUPON_HIS_SEQ.NEXTVAL
                INTO v_coupon_his_seq
                FROM DUAL;

                -- 쿠폰 발행 기록 히스토리 적용
                INSERT INTO PROMOTION_COUPON_HIS
                (       
                        COUPON_CD
                        ,COUPON_HIS_SEQ
                        ,PUBLISH_ID
                        ,COUPON_STATE
                        ,START_DT
                        ,END_DT
                        ,USE_DT
                        ,DESTROY_DT
                        ,GROUP_ID_HIS
                        ,CUST_ID
                        ,TO_CUST_ID
                        ,FROM_CUST_ID
                        ,MOBILE
                        ,RECEPTION_MOBILE
                        ,POS_NO
                        ,BILL_NO
                        ,POS_SEQ
                        ,POS_SALE_DT
                        ,STOR_CD
                        ,PUB_STOR_CD
                        ,ITEM_CD
                        ,COUPON_IMG
                        ,INST_USER
                        ,INST_DT
                ) 
                SELECT	A.COUPON_CD  
                        ,v_coupon_his_seq
                        ,A.PUBLISH_ID
                        ,A.COUPON_STATE
                        ,A.START_DT
                        ,A.END_DT
                        ,NULL
                        ,NULL
                        ,P_GROUP_ID
                        ,(CASE WHEN A.CUST_ID IS NOT NULL THEN A.CUST_ID
                               ELSE NULL
                         END
                        )
                        ,NULL
                        ,NULL
                        ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                               ELSE NULL
                          END
                        )
                        ,NULL
                        ,P_POS_NO
                        ,P_BILL_NO
                        ,P_POS_SEQ
                        ,P_POS_SALE_DT
                        ,NULL
                        ,P_STOR_CD
                        ,P_ITEM_CD
                        ,A.COUPON_IMG
                        ,P_USER_ID
                        ,SYSDATE
                 FROM	PROMOTION_COUPON A
                 JOIN   PROMOTION_COUPON_PUBLISH B
                 ON     A.PUBLISH_ID = B.PUBLISH_ID
                 WHERE	A.COUPON_CD = N_CRE_COUPON_CD;

                 EXCEPTION
                    WHEN OTHERS THEN 
                    O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
                    dbms_output.put_line(SQLERRM); 
            END;

            O_COUPON_CD := N_CRE_COUPON_CD;
            O_COUPON_SEQ := N_CRE_COUPON_SEQ;
            O_GROUP_ID := P_GROUP_ID;
            O_RTN_CD := v_result_cd;

        ELSE -- 발급취소일때

            BEGIN
                    -- 쿠폰히스토리 기록
                    SELECT COUPON_HIS_SEQ.NEXTVAL
                    INTO v_coupon_his_seq
                    FROM DUAL;

                    -- 쿠폰 발행 기록 히스토리 적용
                    INSERT INTO PROMOTION_COUPON_HIS
                    (       
                            COUPON_CD
                            ,COUPON_HIS_SEQ
                            ,PUBLISH_ID
                            ,COUPON_STATE
                            ,START_DT
                            ,END_DT
                            ,USE_DT
                            ,DESTROY_DT
                            ,GROUP_ID_HIS
                            ,CUST_ID
                            ,TO_CUST_ID
                            ,FROM_CUST_ID
                            ,MOBILE
                            ,RECEPTION_MOBILE
                            ,POS_NO
                            ,BILL_NO
                            ,POS_SEQ
                            ,POS_SALE_DT
                            ,STOR_CD
                            ,PUB_STOR_CD
                            ,ITEM_CD
                            ,COUPON_IMG
                            ,INST_USER
                            ,INST_DT
                    ) 
                    SELECT	N_COUPON_CD  
                            ,v_coupon_his_seq
                            ,A.PUBLISH_ID
                            ,A.COUPON_STATE
                            ,A.START_DT
                            ,A.END_DT
                            ,A.USE_DT
                            ,A.DESTROY_DT
                            ,P_GROUP_ID
                            ,(CASE WHEN A.CUST_ID IS NOT NULL THEN A.CUST_ID
                                  ELSE NULL
                             END
                            )
                            ,NULL
                            ,NULL
                            ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                                  ELSE NULL
                             END
                            )
                            ,NULL
                            ,P_POS_NO
                            ,P_BILL_NO
                            ,P_POS_SEQ
                            ,P_POS_SALE_DT
                            ,A.STOR_CD
                            ,NULL
                            ,P_ITEM_CD
                            ,A.COUPON_IMG
                            ,P_USER_ID
                            ,SYSDATE
                     FROM	 PROMOTION_COUPON A
                     JOIN    PROMOTION_COUPON_PUBLISH B
                     ON      A.PUBLISH_ID = B.PUBLISH_ID
                     WHERE	 A.COUPON_CD = N_COUPON_CD
                     AND     A.COUPON_SEQ = N_COUPON_SEQ;

                     EXCEPTION
                        WHEN OTHERS THEN 
                        O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
                        dbms_output.put_line(SQLERRM); 
            END;

            O_COUPON_CD := N_COUPON_CD;
            O_COUPON_SEQ := N_COUPON_SEQ;
            O_START_DT := '';
            O_END_DT := '';
            O_GROUP_ID := P_GROUP_ID;
            O_RTN_CD := v_result_cd;

        END IF;       

EXCEPTION

    WHEN OTHERS THEN
        O_RTN_CD  := '2';
        dbms_output.put_line(SQLERRM);

END API_PRMT_COUPON_NO_REQ_HIS;

/
