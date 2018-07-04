--------------------------------------------------------
--  DDL for Function GET_MEMBERSHIP_COUPON_CD
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_MEMBERSHIP_COUPON_CD" 
(
    A_PRMT_ID       VARCHAR2
)   RETURN          VARCHAR2
IS
  COUPON_CD     VARCHAR2(20);
  V_RANDOM_CD   VARCHAR2(20);
  V_TEMP_COUPON_CD VARCHAR2(20);
BEGIN

    -- 난수쿠폰번호 생성(Prefix(3)+랜덤번호(4자리)+년도(2자리)+월(2자리)+일(2자리)+랜덤번호(3자리)+발행번호(6자리))
    V_RANDOM_CD := '3' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*1000)) || TO_CHAR(SYSDATE,'YY') || TO_CHAR(SYSDATE,'MM') || TO_CHAR(SYSDATE,'DD') || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100));

    -- 쿠폰번호 중복 조회 
    SELECT MAX(A.COUPON_CD)
           INTO V_TEMP_COUPON_CD
    FROM   PROMOTION_COUPON A
    JOIN   PROMOTION_COUPON_PUBLISH B
    ON     A.PUBLISH_ID = B.PUBLISH_ID
    WHERE  B.PRMT_ID = A_PRMT_ID
    AND    A.COUPON_CD LIKE V_RANDOM_CD || '%';

    V_TEMP_COUPON_CD := SUBSTR(V_TEMP_COUPON_CD, 1, 14);

    -- 생성한 난수가 이미 있을 경우 
    IF V_TEMP_COUPON_CD IS NOT NULL THEN
       COUPON_CD := TO_NUMBER(V_TEMP_COUPON_CD);
    ELSE -- 없을경우
       COUPON_CD := V_RANDOM_CD;
    END IF;

    RETURN COUPON_CD;

END GET_MEMBERSHIP_COUPON_CD;

/
