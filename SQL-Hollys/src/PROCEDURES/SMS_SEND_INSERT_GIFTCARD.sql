--------------------------------------------------------
--  DDL for Procedure SMS_SEND_INSERT_GIFTCARD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SEND_INSERT_GIFTCARD" 
(
P_GIFTCARD_ID IN VARCHAR2
,P_PIN_NO IN VARCHAR2
, P_AMOUNT               IN    VARCHAR2
,P_IMAGE_PATH IN VARCHAR2
, N_CUST_ID IN VARCHAR2
, P_MOBILE IN VARCHAR2
, P_MY_USER_ID IN VARCHAR2 
, N_SEND_MSG IN VARCHAR2 
,O_SMS_SEND_ID OUT VARCHAR2 
) IS
        L_SMS_SENDER_ID   NUMBER := 1;
        L_SENDER_NUMBER   VARCHAR(20) := '15662795';
        L_MSGKEY          NUMBER(11, 0);
        L_SUBJECT         VARCHAR(200) := '할리스 모바일 기프트카드';
        L_MSG             VARCHAR(2000);
BEGIN
        SELECT  SQ_SMS_SEND_ID.NEXTVAL,
                MMS_MSG_SEQ.NEXTVAL,
                N_SEND_MSG || CHR(13) || CHR(10) ||
                '▶ 카드번호 : '|| SUBSTR(P_GIFTCARD_ID, 1, 4) || '-' || SUBSTR(P_GIFTCARD_ID, 5, 4) || '-' || SUBSTR(P_GIFTCARD_ID, 9, 4) || '-' || SUBSTR(P_GIFTCARD_ID, 13, 4) ||'
▶ 핀번호 : ' || P_PIN_NO || '
▶ 충전금액 : ' || TO_CHAR(P_AMOUNT, '999,999') || '
▶ 사용처 : 할리스커피 전 매장 (단, 일부매장 제외)

[사용시 주의사항]
. 할리스커피에서 판매하는 모든 제품/상품에 대해 구매가 가능합니다.
. 제품 구매 후 결제 시 MMS를 카운터 근무자에게 제시해 주세요.
. 선물을 보내신 분이 결제를 취소할 경우 본 MMS는 사용하실 수 없습니다.
. 기프트카드의 잔액은 할리스커피 홈페이지를 통해 확인 가능합니다.
(www.hollys.co.kr
. 사용 불가 매장 : 휴게소점, 리조트점, 코엑스점, 도심공항점

★ 할리스커피 고객센터 : 1566-2795
★ 할리스커피 App.에 MY카드로 등록하시어편하게 할리스를 이용하세요.
m.hollys.co.kr/app/down.html'
        INTO    O_SMS_SEND_ID,
                L_MSGKEY,
                L_MSG
        FROM    DUAL;
        
        INSERT  INTO  SMS_SEND  (
                SMS_SEND_ID,
                PRMT_ID,
                CUST_GP_ID,
                GIFTCARD_ID,
                SMS_SENDER_ID,
                STOR_CD,
                SMS_TYPE,
                SENDER_NUMBER,
                SUBJECT,
                CONTENT,
                IMAGE_URL,
                CUST_IMAGE_YN,
                RESERVATION_DATE,
                INST_USER,
                INST_DT
        )       VALUES          (
                O_SMS_SEND_ID,
                NULL,
                NULL,
                P_GIFTCARD_ID,
                L_SMS_SENDER_ID,
                NULL,
                'M',
                L_SENDER_NUMBER,
                L_SUBJECT,
                L_MSG,
                P_IMAGE_PATH,
                NULL,
                NULL,
                P_MY_USER_ID,
                SYSDATE
        );
        
        INSERT  INTO  MMS_MSG (
                MSGKEY, 
                SUBJECT, 
                PHONE, 
                CALLBACK, 
                STATUS, 
                REQDATE, 
                MSG, 
                FILE_CNT,
                FILE_PATH1, 
                TYPE
        )       VALUES        (
                L_MSGKEY,
                L_SUBJECT, 
                P_MOBILE, 
                L_SENDER_NUMBER, 
                '0', 
                SYSDATE, 
                L_MSG, 
                '1', 
                P_IMAGE_PATH, 
                '0'
        );
        
        INSERT  INTO  SMS_SEND_CUST (
                SMS_SEND_ID,
                CUST_ID,
                TR_NUM,
                MSGKEY
        )       VALUES              (
                O_SMS_SEND_ID,
                N_CUST_ID,
                NULL,
                L_MSGKEY
        );
        
END SMS_SEND_INSERT_GIFTCARD;

/
