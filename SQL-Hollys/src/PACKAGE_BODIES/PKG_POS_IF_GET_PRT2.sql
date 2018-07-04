--------------------------------------------------------
--  DDL for Package Body PKG_POS_IF_GET_PRT2
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_POS_IF_GET_PRT2" AS
--------------------------------------------------------------------------------
--  Package Name     : GET_CREDIT_BALANCE
--  Description      : 외상 잔액 현황
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-05-31 생성
--  Modify Date      : 2016-02-25 표준화 작업
--------------------------------------------------------------------------------
  PROCEDURE GET_CREDIT_BALANCE
  ( 
    asCompCd        IN      VARCHAR2, -- 회사코드
    asBrandCd       IN      VARCHAR2, -- 영업조직
    asStorCd        IN      VARCHAR2, -- 점포코드
    asCustId        IN      VARCHAR2, -- 회원 ID
    anRetVal        OUT     NUMBER  , -- 리턴 코드
    asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    anRetVal := 1;
    asRetMsg := '0K';

    OPEN p_cursor FOR
    SELECT DECODE( LEVEL, 1, '고   객   명 : ' || CUST_NM
                        , 2, '고   객   ID : ' || CUST_ID
                        , 3, '연   락   처 : ' || MOBILE
                        , 4, '총 외상 금액 : ' || LPAD(TRIM(TO_CHAR(CREDIT_OCCUR_AMT  , '999,999,990')), 11, ' ')
                        , 5, '입 금  금 액 : ' || LPAD(TRIM(TO_CHAR(CREDIT_RCV_AMT    , '999,999,990')), 11, ' ')
                        , 6, '외 상  잔 액 : ' || LPAD(TRIM(TO_CHAR(CREDIT_BALANCE_AMT, '999,999,990')), 11, ' ')
                 ) CREDIT_INFO
      FROM (
            SELECT DECRYPT(A.CUST_NM)   CUST_NM
                 , A.CUST_ID            CUST_ID
                 , DECRYPT(A.MOBILE)    MOBILE
                 , B.CREDIT_OCCUR_AMT   CREDIT_OCCUR_AMT
                 , B.CREDIT_RCV_AMT     CREDIT_RCV_AMT
                 , B.CREDIT_BALANCE_AMT CREDIT_BALANCE_AMT
              FROM C_CUST     A
                 , C_CUST_EXT B
             WHERE A.COMP_CD  = B.COMP_CD
               AND A.CUST_ID  = B.CUST_ID
               AND A.CUST_DIV = '3'       -- 회원관리범위[01820> 1:회사, 2:영업조직, 3:점포]
               AND A.COMP_CD  = asCompCd
               AND A.BRAND_CD = asBrandCd
               AND A.STOR_CD  = asStorCd
               AND A.CUST_ID  = asCustId
           )
     CONNECT BY LEVEL < 7
    UNION ALL
    SELECT DECODE( LEVEL, 1, '최종입금일자 : ' || SUBSTR(PRC_DT, 1, 4) || '년 ' ||  SUBSTR(PRC_DT, 5, 2) || '월 ' ||  SUBSTR(PRC_DT, 7, 2) || '일'
                        , 2, '최종입금금액 : ' || LPAD(TRIM(TO_CHAR(ETC_AMT, '999,999,990')), 11, ' ')
                 ) AS CREDIT_INFO
      FROM (SELECT *
              FROM STORE_ETC_AMT
             WHERE COMP_CD  = asCompCd
               AND BRAND_CD = asBrandCd
               AND STOR_CD  = asStorCd
               AND CUST_ID  = asCustId
               AND ETC_DIV  = '01'      -- 입출금구분[00820> 01:입금계정, 02:출금계정]
               AND PRC_DT   = (SELECT MAX(PRC_DT)
                                 FROM STORE_ETC_AMT
                                WHERE COMP_CD  = asCompCd
                                  AND BRAND_CD = asBrandCd
                                  AND STOR_CD  = asStorCd
                                  AND CUST_ID  = asCustId
                                  AND ETC_DIV  = '01'      -- 입출금구분[00820> 01:입금계정, 02:출금계정]
                              )
           )
    CONNECT BY LEVEL < 3;
  EXCEPTION
    WHEN OTHERS THEN
         anRetVal := SQLCODE ;
         asRetMsg := 'WorkDiv[CR]' || SQLERRM(SQLCODE) ;
         INSERT INTO ERR_LOG_IF_POS
                ( JOB_DATE, JOB_SEQ_NO, STOR_CD, JOB_TIME, JOB_NAME, JOB_MESSAGE )
         VALUES
                ( TO_CHAR(SYSDATE, 'YYYYMMDD'), SQ_ERR_LOG_IF_POS.NEXTVAL, asStorCd, TO_CHAR(SYSDATE, 'HH24MISS'), 'CR', asRetMsg );

         COMMIT;
  END GET_CREDIT_BALANCE ;

--------------------------------------------------------------------------------
--  Package Name     : GET_PRT
--  Description      : 
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-05-31 생성
--  Modify Date      : 2016-02-25 표준화 작업
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT
  (
    asBrandCd       IN      VARCHAR2, -- 영업조직
    asStorCd        IN      VARCHAR2, -- 점포코드
    asStorTp        IN      VARCHAR2, -- 직가맹구분
    asFrDt          IN      VARCHAR2, -- FROM 일자
    asToDt          IN      VARCHAR2, -- TO   일자
    asWorkDiv       IN      VARCHAR2, -- 다운로드 작업 구분
    anRetVal        OUT     NUMBER  , -- 리턴 코드
    asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    anRetVal := 1;
    asRetMsg := '0K';

    P_BRAND_CD  := asBrandCd;
    P_STOR_CD   := asStorCd ;
    P_STOR_TP   := asStorTp ;
    P_FR_DT     := asFrDt   ;
    P_TO_DT     := asToDt   ;

    IF    ( asWorkDiv = '01' ) THEN -- 생산등록 내역
       GET_PRT_01(anRetVal, asRetMsg, p_cursor );
    ELSIF ( asWorkDiv = '02' ) THEN -- 재고조정 내역
       GET_PRT_02(anRetVal, asRetMsg, p_cursor );
    ELSIF ( asWorkDiv = '03' ) THEN -- 주문 내역
       GET_PRT_03(anRetVal, asRetMsg, p_cursor );
    ELSIF ( asWorkDiv = '04' ) THEN -- 반품 내역
       GET_PRT_04(anRetVal, asRetMsg, p_cursor );
    ELSE
       anRetVal := -100;
       asRetMsg := '미 정의된 다운로드 작업 구분[' || asWorkDiv || '] 입니다.';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         anRetVal := SQLCODE ;
         asRetMsg := 'WorkDiv[' || asWorkDiv || ']' || SQLERRM(SQLCODE) ;
         INSERT INTO ERR_LOG_IF_POS
                ( JOB_DATE, JOB_SEQ_NO, STOR_CD, JOB_TIME, JOB_NAME, JOB_MESSAGE )
         VALUES
                ( TO_CHAR(SYSDATE, 'YYYYMMDD'), SQ_ERR_LOG_IF_POS.NEXTVAL, asStorCd, TO_CHAR(SYSDATE, 'HH24MISS'), asWorkDiv, asRetMsg );

         COMMIT;
  END GET_PRT;

--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_01
--  Description      : 생산등록 내역
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 생성
--  Modify Date      : 2016-02-25 표준화 작업
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_01
  ( 
    anRetVal        OUT     NUMBER  , -- 결과코드
    asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']'    AS ITEM_NM  -- 상품명
         , SUM(D.PROD_QTY)                                             AS PROD_QTY -- 생산수량
         , SUM(D.PROD_QTY * D.SALE_PRC)                                AS PROD_AMT -- 생산금액
      FROM PRODUCT_DT D, -- 생산 DT
           ITEM       I
     WHERE D.ITEM_CD        = I.ITEM_CD
       AND D.PRD_DT   BETWEEN P_FR_DT AND P_TO_DT
       AND D.BRAND_CD       = P_BRAND_CD
       AND D.STOR_CD        = P_STOR_CD
     GROUP BY SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']' ;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_01 ;

--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_02
--  Description      : 재고조정 내역
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 생성
--  Modify Date      : 2016-02-25 표준화 작업
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_02
  ( 
    anRetVal        OUT     NUMBER  , -- 결과코드
    asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']'    AS ITEM_NM  -- 상품명
         , SUM(D.ADJ_QTY)                                              AS PROD_QTY -- 조정수량
         , SUM(D.ADJ_QTY * D.SALE_PRC)                                 AS PROD_AMT -- 조정금액
      FROM DSTOCK D, -- 일 수불
           ITEM   I
     WHERE D.ITEM_CD         = I.ITEM_CD
       AND D.PRC_DT    BETWEEN P_FR_DT AND P_TO_DT
       AND D.BRAND_CD        = P_BRAND_CD
       AND D.STOR_CD         = P_STOR_CD
     GROUP BY SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']' ;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_02 ;

--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_03
--  Description      : 주문 내역(01:원주문, 02:특납, 03:특별케익, 04:프로모션)
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 생성
--  Modify Date      : 2016-02-25 표준화 작업
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_03
  ( 
    anRetVal        OUT     NUMBER  , -- 결과코드
    asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']'           AS ITEM_NM   -- 상품명
         , NVL(SUM(CASE WHEN D.ORD_SEQ = '1' THEN D.ORD_QTY ELSE 0 END ), 0)  AS ORD_QTY_1 -- 1차주주문수량
         , NVL(SUM(CASE WHEN D.ORD_SEQ = '2' THEN D.ORD_QTY ELSE 0 END ), 0)  AS ORD_QTY_2 -- 2차주문수량
         , NVL(SUM(CASE WHEN D.ORD_SEQ = '3' THEN D.ORD_QTY ELSE 0 END ), 0)  AS ORD_QTY_3 -- 3차주문수량
         , SUM(D.ORD_AMT)                                                     AS ORD_AMT   -- 주문금액
      FROM ORDER_HD H, -- 종합 주문 HD
           ORDER_DT D, -- 종합 주문 DT
           ITEM     I
     WHERE D.ITEM_CD         = I.ITEM_CD
       AND H.SHIP_DT         = D.SHIP_DT
       AND H.BRAND_CD        = D.BRAND_CD
       AND H.STOR_CD         = D.STOR_CD
       AND H.ORD_SEQ         = D.ORD_SEQ
       AND H.ORD_FG          = D.ORD_FG
       AND H.SHIP_DT   BETWEEN P_FR_DT AND P_TO_DT
       AND H.BRAND_CD        = P_BRAND_CD
       AND H.STOR_CD         = P_STOR_CD
       AND H.ORD_FG         IN ( '01', '02', '03', '04' )
     GROUP BY SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']' ;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_03 ;

--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_04
--  Description      : 반품 내역
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 생성
--  Modify Date      : 2016-02-25 표준화 작업
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_04
  ( 
    anRetVal        OUT     NUMBER  , -- 결과코드
    asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT R.RJT_DIV               AS RJT_DIV
         , C.CODE_NM               AS RJT_DIV_NM
         , SUM(RJT_AMT + RJT_VAT)  AS RJT_AMT
      FROM REJECT_HD  R, -- 반품 HD
           ( SELECT * FROM COMMON WHERE CODE_TP = '01165' AND USE_YN = 'Y' ) C -- 반품구분[01165> 1:정기, 2:행사, 3:이벤트, 4:제도, 5:클레임, 6:고객클레임]
     WHERE R.RJT_DIV             = C.CODE_CD
       AND R.RJT_DT        BETWEEN P_FR_DT AND P_TO_DT
       AND R.BRAND_CD            = P_BRAND_CD
       AND R.STOR_CD             = P_STOR_CD
       AND R.PRC_STAT_DIV       >= '2'
     GROUP BY R.RJT_DIV, C.CODE_NM;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_04 ;

--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_04_DT
--  Description      : 반품 내역서 상세
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 생성
--  Modify Date      : 2016-02-25 표준화 작업
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_04_DT
  ( 
    asBrandCd       IN      VARCHAR2, -- 영업조직
    asStorCd        IN      VARCHAR2, -- 점포코드
    asStorTp        IN      VARCHAR2, -- 직가맹구분
    asFrDt          IN      VARCHAR2, -- FROM 일자
    asToDt          IN      VARCHAR2, -- TO   일자
    asRjtDiv        IN      VARCHAR2, -- 반품구분[01165> 1:정기, 2:행사, 3:이벤트, 4:제도, 5:클레임, 6:고객클레임]
    anRetVal        OUT     NUMBER  , -- 리턴 코드
    asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT I.ITEM_NM               AS ITEM_NM
         , D.RJT_QTY               AS RJT_QTY
         , D.RJT_AMT + D.RJT_VAT   AS RJT_AMT
         , C.CODE_NM               AS CLAIM_NM
      FROM REJECT_HD  H, -- 반품 HD
           REJECT_DT  D, -- 반품 DT
           ITEM       I,
           ( SELECT * FROM COMMON WHERE CODE_TP = '00380' AND USE_YN = 'Y' ) C  -- 클레임사유
     WHERE D.ITEM_CD             = I.ITEM_CD
       AND D.CLAIM_CD            = C.CODE_CD(+)
       AND H.RJT_DT              = D.RJT_DT
       AND H.BRAND_CD            = D.BRAND_CD
       AND H.STOR_CD             = D.STOR_CD
       AND H.RJT_DIV             = D.RJT_DIV
       AND H.SLIP_NO             = D.SLIP_NO
       AND H.RJT_DT        BETWEEN asFrDt AND asToDt
       AND H.BRAND_CD            = asBrandCd
       AND H.STOR_CD             = asStorCd
       AND H.RJT_DIV             = asRjtDiv
       AND H.PRC_STAT_DIV       >= '2';

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_04_DT ;
END PKG_POS_IF_GET_PRT2;

/
