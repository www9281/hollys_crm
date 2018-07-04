--------------------------------------------------------
--  DDL for Package Body PKG_POS_IF_GET
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_POS_IF_GET" AS
  PROCEDURE GET_MASTER
  (
    asCompCd        IN  VARCHAR2, -- 회사코드
    asBrandCd       IN  VARCHAR2, -- 영업조직
    asStorCd        IN  VARCHAR2, -- 점포코드
    asStorTp        IN  VARCHAR2, -- 직가맹구분
    asUserId        IN  VARCHAR2, -- 사용자 ID
    asWorkDiv       IN  VARCHAR2, -- 다운로드 작업 구분
    asDownDtm       IN  VARCHAR2, -- 최총다운로드 시간
    asUseYn         IN  VARCHAR2, -- Y:사용, A:전체
    anRetVal        OUT NUMBER ,  -- 리턴 코드
    asRetMsg        OUT VARCHAR2, -- 리턴 메시지
    p_cursor        OUT rec_set.m_refcur
  ) IS
  BEGIN
    anRetVal   := 1;
    asRetMsg   := '0K';
    P_COMP_CD  := asCompCd;
    P_BRAND_CD := asBrandCd;
    P_STOR_CD  := asStorCd ;
    P_STOR_TP  := asStorTp ;
    P_USER_ID  := asUserId ;

    P_DOWN_DTM := asDownDtm;
    If ( asUseYn = 'Y' ) Then
       P_USE_YN := asUseYn ;
    Else
       P_USE_YN := '%' ;
    End If;
    If    ( asWorkDiv = '00' ) Then -- ITEM_CHAIN       (프로시져 호출 테스트)
        GET_MASTER_00(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '01' ) Then -- ITEM_CHAIN       (상품마스터)
        GET_MASTER_01(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '04' ) Then --SET_GRP_RULE      (세트상품), SET_GRP_ITEM(세트조합마스터)
        GET_MASTER_04(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '05' ) Then -- BUNDLE_HD        (묶음상품 HD)
        GET_MASTER_05(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '06' ) Then -- BUNDLE_DT        (묶음상품 DT)
        GET_MASTER_06(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '07' ) Then -- STORE_ITEM_PRT   (주방오더 프린터 상품)
        GET_MASTER_07(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '08' ) Then -- BEST_ITEM        (인기상품)
        GET_MASTER_08(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '09' ) Then -- TOUCH_STORE_UI   (터치키점포)
        GET_MASTER_09(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '10' ) Then -- SUB_TOUCH_UI     (부가상품터치키그룹)
        GET_MASTER_10(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '11' ) Then -- ITEM_EXT_GRP     (상품별 부가상품 그룹)
        GET_MASTER_11(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '12' ) Then -- BUTTON_INFO      (버튼정보)
        GET_MASTER_12(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '13' ) Then -- OPTION_ITEM      (옵션상품)
        GET_MASTER_13(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '14' ) Then -- ITEM_OPTION_RULE (옵션상품 RULE)
        GET_MASTER_14(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '15' ) Then -- GIFT_CODE_MST    (상품권 권종 마스터)
        GET_MASTER_15(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '16' ) Then --  ACC_MST         (기타입출금)
        GET_MASTER_16(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '17' ) Then --  ACC_RMK         (기타입출금 적요)
        GET_MASTER_17(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '26' ) Then -- ITEM_L_CLASS           (대분류)
        GET_MASTER_26(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '27' ) Then -- ITEM_M_CLASS           (중분류)
        GET_MASTER_27(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '28' ) Then -- ITEM_S_CLASS          (소분류)
        GET_MASTER_28(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '29' ) Then -- ITEM_KITCHEN           (주방상품정보)
        GET_MASTER_29(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '31' ) Then -- SET_RULE               (세트 구성품 정보)
        GET_MASTER_31(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '32' ) Then -- STORE_ITEM_PRT_MULTI   (주방오더 프린터 상품(다중))
        GET_MASTER_32(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '33' ) Then -- ITEM_CLASS             (상품분류(공통제외))
        GET_MASTER_33(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '50' ) Then -- STORE_USER       (담당자 마스터)
        GET_MASTER_50(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '52' ) Then -- CARD             (카드사 마스터)
        GET_MASTER_52(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '53' ) Then -- CARDMB_PREFIX    (카드사 PREFIX)
        GET_MASTER_53(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '54' ) Then -- COMMON           (공통코드)
        GET_MASTER_54(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '57' ) Then -- COMMON           (VAN, 카드 정보)
        GET_MASTER_57(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '58' ) Then -- COMMON           (점포 정보)
        GET_MASTER_58(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '59' ) Then -- COMMON           (본사 명판)
        GET_MASTER_59(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '60' ) Then -- COMMON           (점포 명판)
        GET_MASTER_60(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '61' ) Then -- COMMON           (송신 URL)
        GET_MASTER_61(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '62' ) Then -- COMMON           (점별 매입처)
        GET_MASTER_62(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '63' ) Then -- COMMON           (사용자별 프로그램 권한)
        GET_MASTER_63(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '71' ) Then -- LANG_ITEM        (다국어 상품)
        GET_MASTER_71(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '72' ) Then -- LANG_COMMON      (다국어 공통)
        GET_MASTER_72(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '73' ) Then -- LANG_STORE       (다국어 점포)
        GET_MASTER_73(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '74' ) Then -- LANG_TABLE       (다국어 테이블)
        GET_MASTER_74(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '75' ) Then -- RECIPE_BRAND     (레시피)
        GET_MASTER_75(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '84' ) Then -- DC               (할인정보)
        GET_MASTER_84(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '85' ) Then -- DC_STORE         (점포별 할인정보)
        GET_MASTER_85(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '86' ) Then -- DC_ITEM          (할인 대상상품)
        GET_MASTER_86(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '87' ) Then -- DC_GIFT          (할인 사은품)
        GET_MASTER_87(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '88' ) Then -- STORE            (B2B)
        GET_MASTER_88(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '89' ) Then -- DC_WEEK          (할인대상요일)
        GET_MASTER_89(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '90' ) Then -- (SYSDATE 리턴 )
        GET_MASTER_90(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '91' ) Then -- DC_ITEM_GRP      (할인대상상품그룹)
        GET_MASTER_91(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '92' ) Then -- HQ_USER          (본사사용자)
        GET_MASTER_92(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'A0' ) Then -- ITEM_B2B_DC_HIS      (B2B ITEM DC)
        GET_MASTER_A0(anRetVal, asRetMsg, p_cursor );    
    ElsIf ( asWorkDiv = 'A1' ) Then -- ITEM_STOCK_PERIOD    (반제품 해동시간관리)
        GET_MASTER_A1(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'A2' ) Then -- ITEM_CHAIN           (반제품, 원부자재 상품리스트(KDS용))
        GET_MASTER_A2(anRetVal, asRetMsg, p_cursor );    
    ElsIf ( asWorkDiv = 'A3' ) Then -- RECIPE_BRAND_FOOD    (BOM형태의 레시피정보)
        GET_MASTER_A3(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B0' ) Then -- CS_PROGRAM           ([서비스]프로그램 마스터)
        GET_MASTER_B0(anRetVal, asRetMsg, p_cursor );    
    ElsIf ( asWorkDiv = 'B1' ) Then -- CS_PROGRAM_MATL      ([서비스]프로그램 대상 교구)
        GET_MASTER_B1(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B2' ) Then -- CS_PROGRAM_ORG       ([서비스]프로그램 단체고객수 구간 할인율)
        GET_MASTER_B2(anRetVal, asRetMsg, p_cursor );    
    ElsIf ( asWorkDiv = 'B3' ) Then -- CS_PROGRAM_STORE     ([서비스]프로그램 점포설정)
        GET_MASTER_B3(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B4' ) Then -- CS_PROGRAM_STORE_TM  ([서비스]프로그램 점포 운영시간)
        GET_MASTER_B4(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B5' ) Then -- CS_MEMBERSHIP        ([서비스]회원권 마스터)
        GET_MASTER_B5(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B6' ) Then -- CS_OPTION            ([서비스]입장옵션 마스터)
        GET_MASTER_B6(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B7' ) Then -- CS_OPTION_STORE      ([서비스]입장옵션 점포할당 마스터)
        GET_MASTER_B7(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B8' ) Then -- CS_MEMBERSHIP_ITEM   ([서비스]회원권 대상상품 마스터)
        GET_MASTER_B8(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B9' ) Then -- CS_CONTENT           ([서비스]SMS 컨텐츠)
        GET_MASTER_B9(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C0' ) Then -- M_COUPON_MST         ([서비스]쿠폰마스터)
        GET_MASTER_C0(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C1' ) Then -- M_COUPON_STORE       ([서비스]쿠폰대상매장)
        GET_MASTER_C1(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C2' ) Then -- M_COUPON_ITEM        ([서비스]쿠폰대상상품)
        GET_MASTER_C2(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C3' ) Then -- M_COUPON_STORE       ([특수매장]비용코드)
        GET_MASTER_C3(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C4' ) Then -- M_COUPON_ITEM        ([결제수단]결제수단코드)
        GET_MASTER_C4(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C5' ) Then -- STORE_DEVICE         (매장별디바이스정보)
        GET_MASTER_C5(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C6' ) Then -- C_PROMOTION_MST      (프로모션마스터)
        GET_MASTER_C6(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C7' ) Then -- C_PROMOTION_STORE    (프로모션마스터_적용매장)
        GET_MASTER_C7(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C8' ) Then -- C_PROMOTION_WEEK     (프로모션마스터_적용요일)
        GET_MASTER_C8(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C9' ) Then -- C_PROMOTION_ITEM_COND(프로모션마스터_조건 대상상품)
        GET_MASTER_C9(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'D0' ) Then -- C_PROMOTION_ITEM     (프로모션마스터_적용 대상상품)
        GET_MASTER_D0(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'D1' ) Then -- C_PROMOTION_BILL     (프로모션마스터_영수증 설정)
        GET_MASTER_D1(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'D2' ) Then -- C_PROMOTION_BILL_MSG     (프로모션마스터_출력 메시지)
        GET_MASTER_D2(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'D3' ) Then -- PAY_ADD_MST          (제휴사 결제 마스터)
        GET_MASTER_D3(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'D4' ) Then -- DC_ALLOT             (할인 분담율)
        GET_MASTER_D4(anRetVal, asRetMsg, p_cursor );
    Else
        anRetVal := -100;
        asRetMsg := '미 정의된 다운로드 작업 구분[' || asWorkDiv || '] 입니다.' ;
    End If;

    If ( anRetVal <> 1 ) Then
        INSERT INTO ERR_LOG_IF_POS
        (
                COMP_CD
            ,   JOB_DATE
            ,   JOB_SEQ_NO
            ,   STOR_CD
            ,   JOB_TIME
            ,   JOB_NAME
            ,   JOB_MESSAGE
        ) VALUES (
                asCompCd
            ,   TO_CHAR(SYSDATE, 'YYYYMMDD')
            ,   SQ_ERR_LOG_IF_POS.NEXTVAL
            ,   asStorCd
            ,   TO_CHAR(SYSDATE, 'HH24MISS')
            ,   asWorkDiv
            ,   asRetMsg
       );
       Commit;
    End If;
  EXCEPTION
    WHEN OTHERS THEN
         anRetVal := SQLCODE;
         asRetMsg := 'WorkDiv[' || asWorkDiv || ']' || SQLERRM(SQLCODE);

         INSERT INTO ERR_LOG_IF_POS
         (
                COMP_CD
            ,   JOB_DATE
            ,   JOB_SEQ_NO
            ,   STOR_CD
            ,   JOB_TIME
            ,   JOB_NAME
            ,   JOB_MESSAGE
         ) VALUES (
                asCompCd
            ,   TO_CHAR(SYSDATE, 'YYYYMMDD')
            ,   SQ_ERR_LOG_IF_POS.NEXTVAL
            ,   asStorCd
            ,   TO_CHAR(SYSDATE, 'HH24MISS')
            ,   asWorkDiv
            ,   asRetMsg
         );
         Commit;
  END GET_MASTER;

  --------------------------------------------------------------------------------
  --  Procedure Name   : GET_MASTER_00
  --  Description      : POS마스터 수신용 (SP컴파일후 최초 한번은 패캐지가 무효화 POS에서 마스터 수신 요청 프로시져 호출 테스트)
  -- Ref. Table        : ITEM_CHAIN
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_00 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT 'X'
      FROM DUAL;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_00;

  --------------------------------------------------------------------------------
  --  Procedure Name   : GET_MASTER_01
  --  Description      : POS마스터 수신용 (상품마스터)
  -- Ref. Table        : ITEM_CHAIN
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_01 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    WITH IT AS 
    (
        SELECT  COMP_CD
             ,  BRAND_CD
             ,  ITEM_CD
          FROM  ( 
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD
                      FROM  ITEM_CHAIN -- 직가맹별 상품 마스터
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_TP  = P_STOR_TP
                       AND  ORD_SALE_DIV IN ('2', '3') -- 주문/판매구분[00045>1:주문용, 2:주문판매용, 3:판매용]
                       AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD
                      FROM  STORE_ITEM_PRT -- 주방 오더 상품 마스터
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_CD = P_STOR_CD
                       AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD
                      FROM  ITEM_STORE
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_CD  = P_STOR_CD
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD
                      FROM  SUB_STORE_ITEM
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_CD = P_STOR_CD
                       AND  SUB_TOUCH_DIV IN ('2', '3')
                       AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  P_BRAND_CD      AS BRAND_CD
                         ,  ITEM_CD
                      FROM  BARCODE
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  TOUCH_CD        AS ITEM_CD
                      FROM  TOUCH_STORE_UI
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND STOR_CD   = P_STOR_CD
                       AND TOUCH_TP  = 'M'
                       AND USE_YN    = 'Y'
                       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  TOUCH_CD        AS ITEM_CD
                      FROM  TOUCH_UI
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  TOUCH_DIV = '2'
                       AND TOUCH_TP  = 'M'
                       AND USE_YN    = 'Y'
                       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD         AS ITEM_CD
                      FROM  SUB_STORE_ITEM
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_CD  = P_STOR_CD
                       AND  SUB_TOUCH_DIV IN ('2', '3')
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD         AS ITEM_CD
                      FROM  SET_RULE
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                     GROUP  BY COMP_CD, BRAND_CD, ITEM_CD
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  OPTN_ITEM_CD    AS ITEM_CD
                      FROM  SET_RULE
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  GRP_DIV  = '0'
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                     GROUP  BY COMP_CD, BRAND_CD, OPTN_ITEM_CD
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD         AS ITEM_CD
                      FROM  OPTION_ITEM
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                     GROUP  BY COMP_CD, BRAND_CD, ITEM_CD
                )
         GROUP  BY COMP_CD, BRAND_CD, ITEM_CD
    ), 
    S_TOUCH AS 
    (
        SELECT  COMP_CD
             ,  TOUCH_CD    AS ITEM_CD
          FROM  TOUCH_STORE_UI
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  STOR_CD  = P_STOR_CD
           AND  TOUCH_TP = 'M'
           AND  USE_YN   = 'Y'
        UNION
        SELECT  COMP_CD
             ,  TOUCH_CD    AS ITEM_CD
          FROM  TOUCH_UI
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  TOUCH_DIV= '2'
           AND  TOUCH_TP = 'M'
           AND  USE_YN   = 'Y'
        UNION
        SELECT  COMP_CD
             ,  ITEM_CD     AS ITEM_CD
          FROM  SUB_STORE_ITEM
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  STOR_CD  = P_STOR_CD
           AND  SUB_TOUCH_DIV IN ('2', '3')
           AND  USE_YN   = 'Y'
        UNION
        SELECT  COMP_CD
             ,  ITEM_CD     AS ITEM_CD
          FROM  SET_RULE
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  USE_YN   = 'Y'
         GROUP  BY COMP_CD, ITEM_CD
        UNION
        SELECT  COMP_CD
             ,  OPTN_ITEM_CD AS ITEM_CD
          FROM  SET_RULE
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  GRP_DIV  = '0'
           AND  USE_YN   = 'Y'
         GROUP  BY COMP_CD, OPTN_ITEM_CD
        UNION
        SELECT  COMP_CD
             ,  ITEM_CD     AS ITEM_CD
          FROM  OPTION_ITEM
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  USE_YN   = 'Y'
         GROUP  BY COMP_CD, ITEM_CD
    )
    SELECT I.BRAND_CD      AS BRAND_CD      -- 영업조직
         , I.ITEM_CD       AS ITEM_CD       -- 상품코드
         , I.ITEM_POS_NM   AS ITEM_POS_NM   -- POS 상품명
         , I.SALE_START_DT AS SALE_START_DT -- 판매개시일
         , I.SALE_CLOSE_DT AS SALE_CLOSE_DT -- 판매종료일
         , I.L_CLASS_CD    AS L_CLASS_CD    -- 대분류 코드
         , I.M_CLASS_CD    AS M_CLASS_CD    -- 중분류 코드
         , I.S_CLASS_CD    AS S_CLASS_CD    -- 소분류 코드
         , I.D_CLASS_CD    AS D_CLASS_CD    -- 세분류 코드
         , NVL(NVL(T.PRICE, I.SALE_PRC), 0)    AS SALE_AMT  -- 판매가
         , NVL(R.COST                  , 0)    AS SALE_COST -- 원가
         , NVL(I.DC_YN , 'Y') AS DC_YN      -- 할인 가능 여부 => Y : 할인가능,  N : 할인불가
         , '0' AS SALE_DC_DIV -- 할인 적용 구분 > 0:정상, 1:판매가 미정의, 2:점포변경
         , 0   AS SALE_DC_PRC -- 할인금액       > 세트조합 후 판매가 결정이 되면 할인금액 적용
         , NVL(I.SALE_VAT_YN, 'N')   AS SALE_VAT_YN   -- 판매 과세구분      => 공통(00055) [Y:과세, N:면세]
         , NVL(I.SALE_VAT_RULE, 'N') AS SALE_VAT_RULE -- 판매 VAT 관리 룰   => 공통(00850) [1:부가세포함, 2:부가세미포함] -> 계산방식
         , NVL(I.SALE_VAT_IN_RATE , 0) AS SALE_VAT_IN_RATE -- 테이크인 판매 VAT율
         , NVL(I.SALE_VAT_OUT_RATE, 0) AS SALE_VAT_OUT_RATE -- 테이크아웃 판매 VAT율
         , S.SALE_SVC_YN AS SALE_SVC_YN -- 판매 서비스 관리 구분
         , S.SALE_SVC_RULE AS SALE_SVC_RULE -- 판매 봉사료 설정
         , NVL(S.SALE_SVC_RATE , 0) AS SALE_SVC_RATE -- 판매 서비스 율
         , ''  AS SET_GRP         -- 세트 조합 그룹 > 사용안함
         , NVL(I.SET_DIV , '0') AS SET_DIV -- SET 조합 구분     => 공통(01100) [0:관계없음, 1:SET 상품 , 2:SET 투입상품]
         , 'N' AS TODAY_COFFEE_YN -- 오늘의 커피여부 > 사용안함
         , '0' AS SUB_ITEM_DIV    -- 부가/옵션관리 > 사용안함
         , 0   AS FLAVOR_QTY      -- 플레이버 총 중량
         , 0   AS STOCK_QTY       -- 플레이버 상품 선택수
         , 0   AS EVENT_AMT       -- [POS] 현재 쓰지 않으나 0으로 넣는다
         , 'N' AS EVENT_DIV       -- [POS] 현재 쓰지 않으나 'N'으로 넣는다
         , NVL(I.POINT_YN, 'N') AS POINT_YN -- 포인트 적립유무    => [Y:yes, N:no]
         , ''  AS O_ITEM_CD -- 인천공항메뉴
         , I.OPEN_ITEM_YN AS OPEN_ITEM_YN -- 오픈상품여부
         , '1' AS DISPOSABLE_DIV -- 일회용품구분 => 공통(01325) [1:상품, 2:일회용품(포장지)]
         , DECODE(P.USE_YN, 'Y', NVL(P.PRT_NO, ''), '') AS PRT_NO -- 프린터번호
         , I.USE_YN AS USE_YN -- 사용 여부
         , B.BAR_CODE AS BAR_CODE -- 바코드 (일단, 한상품에 대해서는 무조건 MAX(BAR_CODE)값을 넘겨준다)
         , NP.PRT_NO                 AS ALL_PRT_NO     -- 상품별 사용할 프린터 번호  => ex) 1^2^3^5
         , NVL(I.AUTO_POPUP_YN, 'N') AS AUTO_POPUP_YN  -- POS에서 상품선택시 팝업창 뛰우기 여부 (부가상품 일때)
         , NVL(I.EXT_YN, 'N')        AS EXT_YN         -- 부가상품 여부[YN]
         , 'N'                       AS PARENT_ITEM_YN -- 부모상품 여부 > 사용안함
         , I.ORD_SALE_DIV                              -- 사용구분[00045> 1:주문용, 2:주문/판매용, 3:판매용, 4:생산용]
         , I.ITEM_KDS_NM                               -- KDS 상품명
         , I.SAV_MLG_YN                                -- 마일리지 적립여부[YN]
         , I.CUST_STD_CNT                              -- 객수카운트 수
         , I.EXT_COMMENT                               -- 부가속성설명
      FROM ITEM_CHAIN I,
           (SELECT NVL(MAX(SALE_SVC_YN ), 'N')  AS SALE_SVC_YN
                 , NVL(MAX(SALE_SVC_RULE), '1') AS SALE_SVC_RULE -- 1:부가세 계산안함, 2:부가세 계산함
                 , NVL(MAX(SALE_SVC_RATE), 0 )  AS SALE_SVC_RATE
              FROM STORE_SETUP
             WHERE COMP_CD  = P_COMP_CD
               AND BRAND_CD = P_BRAND_CD
               AND STOR_CD  = P_STOR_CD
           )          S,
           (SELECT *
              FROM ITEM_STORE
             WHERE COMP_CD  = P_COMP_CD
               AND BRAND_CD = P_BRAND_CD
               AND STOR_CD  = P_STOR_CD
               AND USE_YN   = 'Y'
               AND TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN START_DT AND NVL(CLOSE_DT, '99991231')
           )          T,
           (SELECT *
              FROM STORE_ITEM_PRT
             WHERE COMP_CD  = P_COMP_CD
               AND BRAND_CD = P_BRAND_CD
               AND STOR_CD  = P_STOR_CD
           )          P,
           (SELECT COMP_CD,
                   ITEM_CD ,
                   MAX(CASE WHEN SEQ =  1 THEN        PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  2 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  3 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  4 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  5 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  6 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  7 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  8 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  9 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 10 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 11 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 12 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 13 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 14 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 15 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 16 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 17 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 18 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 19 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 20 THEN '^' || PRT_NO ELSE '' END) AS PRT_NO
              FROM (SELECT COMP_CD,
                           ITEM_CD ,
                           TO_CHAR(PRT_NO) PRT_NO ,
                           ROW_NUMBER() OVER(PARTITION BY ITEM_CD ORDER BY ITEM_CD, PRT_NO ) SEQ
                      FROM STORE_ITEM_PRT
                     WHERE COMP_CD  = P_COMP_CD
                       AND BRAND_CD = P_BRAND_CD
                       AND STOR_CD  = P_STOR_CD
                     GROUP BY COMP_CD, ITEM_CD, PRT_NO
                   )
             GROUP BY COMP_CD, ITEM_CD
           )          NP,
           (SELECT COMP_CD,
                   ITEM_CD,
                   MAX(BAR_CODE) BAR_CODE
              FROM BARCODE
             WHERE COMP_CD = P_COMP_CD
               AND USE_YN  = 'Y'
             GROUP BY COMP_CD, ITEM_CD
           )          B,
           (
            SELECT  COMP_CD
                  , BRAND_CD
                  , STOR_TP
                  , R_ITEM_CD    AS ITEM_CD
                  , SUM(DO_COST) AS  COST
            FROM    TABLE(FN_RCP_STD_0072(P_COMP_CD, P_BRAND_CD,TO_CHAR(SYSDATE, 'YYYYMMDD')))
            GROUP BY
                    COMP_CD
                  , BRAND_CD
                  , STOR_TP
                  , R_ITEM_CD
           )          R,      
           S_TOUCH    U,
           IT         A
     WHERE I.COMP_CD   = T.COMP_CD(+)
       AND I.ITEM_CD   = T.ITEM_CD(+)
       AND I.COMP_CD   = U.COMP_CD(+)
       AND I.ITEM_CD   = U.ITEM_CD(+)
       AND I.COMP_CD   = P_COMP_CD
       AND I.BRAND_CD  = P_BRAND_CD
       AND I.STOR_TP   = P_STOR_TP
       AND I.COMP_CD   = P.COMP_CD(+)
       AND I.BRAND_CD  = P.BRAND_CD(+)
       AND I.ITEM_CD   = P.ITEM_CD(+)
       AND I.COMP_CD   = NP.COMP_CD(+)
       AND I.ITEM_CD   = NP.ITEM_CD(+)
       AND I.COMP_CD   = B.COMP_CD(+)
       AND I.ITEM_CD   = B.ITEM_CD(+)
       AND I.COMP_CD   = A.COMP_CD
       AND I.BRAND_CD  = A.BRAND_CD
       AND I.ITEM_CD   = A.ITEM_CD
       AND I.COMP_CD   = R.COMP_CD (+)
       AND I.BRAND_CD  = R.BRAND_CD(+)
       AND I.STOR_TP   = R.STOR_TP (+)
       AND I.USE_YN LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_01;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (세트상품)
  -- Ref. Table        : SET_GRP_RULE(세트상품),  SET_GRP_ITEM (세트조합마스터)
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_04 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
      OPEN p_cursor FOR
      SELECT T.BRAND_CD      BRAND_CD
           , P_STOR_CD       STOR_CD
           , T.SALE_START_DT SALE_START_DT
           , T.SEQ           SEQ
           , T.SET_GRP       SET_GRP
           , CASE T.SET_TP
                  WHEN '1' THEN I.ITEM_CD
                  ELSE          T.SET_GRP
             END             ITEM_CD
           , T.SET_H_RANK    SET_RANK
           , T.SALE_END_DT   SALE_END_DT
           , T.SET_TP        SET_TP
           , T.SALE_DC_FG    DC_FG
           , T.SALE_DC_RATE  DC_RATE
           , T.SALE_DC_AMT   DC_AMT
           , T.SALE_QTY      QTY
           , T.USE_D_YN      USE_YN
           , T.DC_DIV
        FROM (SELECT B.COMP_CD,
                     B.BRAND_CD AS BRAND_CD ,
                     A.SALE_START_DT AS SALE_START_DT ,
                     A.SEQ AS SEQ ,
                     B.SET_GRP AS SET_GRP ,
                     B.SET_TP AS SET_TP ,
                     A.SET_RANK AS SET_H_RANK ,
                     NVL(A.SALE_END_DT,'99999999') AS SALE_END_DT ,
                     B.DC_FG AS SALE_DC_FG ,
                     NVL(B.DC_RATE,0) AS SALE_DC_RATE ,
                     NVL(B.DC_AMT,0) AS SALE_DC_AMT ,
                     NVL(B.QTY,1) AS SALE_QTY ,
                     NVL(A.USE_YN,'N') AS USE_H_YN ,
                     NVL(B.USE_YN,'N') AS USE_D_YN ,
                     DECODE(A.STORE_APP_DIV, '0' , P_STOR_CD , '1' , S.STOR_CD , '2' , DECODE(S.STOR_CD, P_STOR_CD, '', P_STOR_CD) , '' ) AS STOR_CD ,
                     A.STORE_APP_DIV AS STORE_APP_DIV ,
                     DECODE(A.STORE_APP_DIV, '0' , 'Y' , '1' , S.USE_YN , '2' , DECODE(S.USE_YN, 'Y', 'N', 'Y') , 'N' ) AS USE_S_YN,
                     A.DC_DIV
                FROM SET_GRP_RULE A ,
                     (SELECT NVL(B.COMP_CD, A.COMP_CD)  AS COMP_CD,
                             NVL(B.BRAND_CD,A.BRAND_CD) AS BRAND_CD ,
                             NVL(B.SALE_START_DT,A.SALE_START_DT) AS SALE_START_DT ,
                             NVL(B.SEQ,A.SEQ) AS SEQ ,
                             NVL(B.SET_GRP,A.SET_GRP) AS SET_GRP ,
                             NVL(B.SET_TP,A.SET_TP) AS SET_TP ,
                             NVL(B.DC_FG,A.DC_FG) AS DC_FG ,
                             NVL(B.DC_RATE,A.DC_RATE) AS DC_RATE ,
                             NVL(B.DC_AMT,A.DC_AMT) AS DC_AMT ,
                             NVL(B.QTY,A.QTY) AS QTY ,
                             NVL(A.USE_YN,'N') AS USE_YN ,
                             NVL(B.UPD_DT,A.UPD_DT) AS UPD_DT
                        FROM SET_GRP_ITEM A ,
                             SET_GRP_ITEM_STORE B
                       WHERE A.COMP_CD  = B.COMP_CD(+)
                         AND A.BRAND_CD = B.BRAND_CD(+)
                         AND A.SALE_START_DT = B.SALE_START_DT(+)
                         AND A.SEQ = B.SEQ(+)
                         AND A.SET_GRP = B.SET_GRP(+)
                         AND A.SET_TP = B.SET_TP(+)
                         AND A.COMP_CD     = P_COMP_CD
                         AND A.BRAND_CD    = P_BRAND_CD
                         AND B.STOR_CD (+) = P_STOR_CD
                     ) B ,
                     SET_GRP_RULE_STORE S
               WHERE A.COMP_CD  = P_COMP_CD
                 AND A.BRAND_CD = P_BRAND_CD
                 AND A.COMP_CD  = B.COMP_CD
                 AND A.BRAND_CD = B.BRAND_CD
                 AND A.SALE_START_DT = B.SALE_START_DT
                 AND A.SEQ      = B.SEQ
                 AND A.COMP_CD  = S.COMP_CD(+)
                 AND A.BRAND_CD = S.BRAND_CD(+)
                 AND A.SALE_START_DT = S.SALE_START_DT(+)
                 AND A.SEQ      = S.SEQ(+)
                 AND S.COMP_CD (+) = P_COMP_CD
                 AND S.BRAND_CD(+) = P_BRAND_CD
                 AND S.STOR_CD (+) = P_STOR_CD
          ) T ,
          ITEM_SET_GRP I
    WHERE T.COMP_CD  = I.COMP_CD (+)
      AND T.SET_GRP  = I.SET_GRP (+)
      AND I.COMP_CD(+) = P_COMP_CD
      AND T.USE_H_YN = 'Y'
      AND T.USE_S_YN = 'Y'
      AND T.USE_D_YN = 'Y'
      AND ( I.USE_YN = 'Y' OR T.SET_TP = '2' );

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_04;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (묶음상품 HD)
  -- Ref. Table        : BUNDLE_HD
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-16
  --  Modify Date      : 2009-12-16
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_05 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT H.BRAND_CD      BRAND_CD  -- 영업조직
         , H.STOR_CD       STOR_CD   -- 점포코드
         , H.BUNDLE_CD     BUNDLE_CD -- 묶음코드
         , H.BUNDLE_NM     BUNDLE_NM -- 묶음코드 명
         , NVL(D.SALE_AMT, 0)       SALE_AMT -- 묶음판매금액
         , NVL(H.DC_AMT , 0)        DC_AMT -- 묶음할인금액
         , NVL(D.SALE_AMT - H.DC_AMT, 0) GRD_AMT -- 묶음실판매금액
         , H.CONTINUE_YN   CONTINUE_YN -- 지속구분
         , H.USE_YN        USE_YN -- 사용유무
         , TO_CHAR(H.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM BUNDLE_HD H,
           (SELECT COMP_CD,
                   BUNDLE_CD,
                   NVL(SUM(SALE_PRC * BUNDLE_QTY), 0) SALE_AMT
             FROM BUNDLE_DT
            WHERE (COMP_CD, BRAND_CD, STOR_CD, BUNDLE_CD) IN
                  (SELECT COMP_CD,
                          BRAND_CD,
                          STOR_CD,
                          BUNDLE_CD
                     FROM BUNDLE_HD
                    WHERE COMP_CD  = P_COMP_CD
                      AND BRAND_CD = P_BRAND_CD
                      AND STOR_CD  = P_STOR_CD
                      AND UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                      AND USE_YN   = 'Y'
                  )
              AND USE_YN  = 'Y'
              AND COMP_CD = P_COMP_CD
            GROUP BY COMP_CD, BUNDLE_CD
           ) D
     WHERE H.COMP_CD   = D.COMP_CD(+)
       AND H.BUNDLE_CD = D.BUNDLE_CD(+)
       AND H.COMP_CD   = P_COMP_CD
       AND H.BRAND_CD  = P_BRAND_CD
       AND H.STOR_CD   = P_STOR_CD
       AND H.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND H.USE_YN LIKE P_USE_YN;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_05;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (묶음상품 DT)
  -- Ref. Table        : BUNDLE_DT
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-16
  --  Modify Date      : 2009-12-16
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_06 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT D.BRAND_CD      BRAND_CD    -- 영업조직
         , D.STOR_CD       STOR_CD     -- 점포코드
         , D.BUNDLE_CD     BUNDLE_CD   -- 묶음코드
         , D.ITEM_CD       ITEM_CD     -- 상품코드
         , NVL(D.SALE_PRC, 0)              SALE_PRC   -- 판매가
         , NVL(D.BUNDLE_QTY, 0)            BUNDLE_QTY -- 묵음수량
         , NVL(D.SALE_PRC * BUNDLE_QTY, 0) SALE_AMT   -- 판매금액
         , I.SALE_VAT_YN   SALE_VAT_YN   -- 과세 구분
         , I.SALE_VAT_RULE SALE_VAT_RULE -- 판매가 VAT 설정  [1:부가세포함, 2:부가세미포함]
         , NVL(I.SALE_VAT_IN_RATE , 0)     SALE_VAT_IN_RATE -- 판매 TAKE IN VAT율
         , NVL(I.SALE_VAT_OUT_RATE, 0)     SALE_VAT_OUT_RATE -- 판매 TAKE OUT VAT율
         , S.SALE_SVC_YN   SALE_SVC_DIV  -- 판매 서비스 관리 구분  =>[ Y/N ]
         , NVL(S.SALE_SVC_RATE , 0)        SALE_SVC_RATE -- 판매 서비스 율
         , 0               SALE_SVC_PRC  -- 판매 서비스 금액  => 무조건 0으로 주기로함
         , NVL(H.DC_RATE , 0)              DC_RATE -- 할인율
         , NVL(D.DC_AMT , 0)               DC_AMT  -- 할인금액
         , 0               FIXED_DC_AMT  -- 할인지정금액
         , 0               GRD_AMT       -- 실판매금액
         , D.USE_YN        USE_YN        -- 사용유무
         , TO_CHAR(D.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM BUNDLE_DT D
         , BUNDLE_HD H
         , ITEM_CHAIN I
         , (SELECT COMP_CD,
                   BRAND_CD,
                   STOR_CD,
                   SALE_SVC_YN,
                   SALE_SVC_RATE
              FROM STORE_SETUP
             WHERE COMP_CD  = P_COMP_CD
               AND BRAND_CD = P_BRAND_CD
               AND STOR_CD  = P_STOR_CD
           ) S
       WHERE D.COMP_CD   = I.COMP_CD
         AND D.BRAND_CD  = I.BRAND_CD
         AND D.ITEM_CD   = I.ITEM_CD
         AND P_STOR_TP   = I.STOR_TP
         AND D.COMP_CD   = H.COMP_CD
         AND D.BRAND_CD  = H.BRAND_CD
         AND D.STOR_CD   = H.STOR_CD
         AND D.BUNDLE_CD = H.BUNDLE_CD
         AND D.COMP_CD   = S.COMP_CD(+)
         AND D.BRAND_CD  = S.BRAND_CD(+)
         AND D.STOR_CD   = S.STOR_CD(+)
         AND D.COMP_CD   = P_COMP_CD
         AND D.BRAND_CD  = P_BRAND_CD
         AND D.STOR_CD   = P_STOR_CD
         AND D.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
         AND D.USE_YN LIKE P_USE_YN;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_06;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (주방오더 프린터 상품)
  -- Ref. Table        : STORE_ITEM_PRT
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-16
  --  Modify Date      : 2009-12-16
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_07 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD      BRAND_CD -- 영업조직
         , STOR_CD       STOR_CD -- 점포코드
         , PRT_NO        PRT_NO -- 프린터번호
         , ITEM_CD       ITEM_CD -- 상품코드
         , USE_YN        USE_YN -- 사용유무
         , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM STORE_ITEM_PRT_MULTI
     WHERE COMP_CD   = P_COMP_CD
       AND BRAND_CD  = P_BRAND_CD
       AND STOR_CD   = P_STOR_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN
     ORDER BY UPD_DT;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_07;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (인기상품)
  -- Ref. Table        : BEST_ITEM
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_08 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD      BRAND_CD -- 영업조직
         , STOR_CD       STOR_CD -- 점포코드
         , ITEM_CD       ITEM_CD -- 상품코드
         , USE_YN        USE_YN -- 사용여부
         , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM BEST_ITEM
     WHERE COMP_CD   = P_COMP_CD
       AND BRAND_CD  = P_BRAND_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_08;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (터치키점포)
  -- Ref. Table        : TOUCH_STORE_UI
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-17
  --  Modify Date      : 2009-12-17
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_09 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  P_TOUCH_CNT   NUMBER  := 0;
  BEGIN

    SELECT  COUNT(*)
      INTO  P_TOUCH_CNT
      FROM  TOUCH_STORE_UI
     WHERE  COMP_CD   = P_COMP_CD
       AND  BRAND_CD  = P_BRAND_CD
       AND  STOR_CD   = P_STOR_CD
       AND  USE_YN    = 'Y';

    IF P_TOUCH_CNT > 0 THEN
        -- 매장 터치키 수신
        OPEN p_cursor FOR
        SELECT  BRAND_CD      BRAND_CD    -- 영업조직
             ,  STOR_CD       STOR_CD     -- 점포코드
             ,  TOUCH_DIV     TOUCH_DIV   -- 터치키 구분
             ,  TOUCH_GR_CD   TOUCH_GR_CD -- 터치키 그룹 코드
             ,  TOUCH_CD      TOUCH_CD    -- 터치키 코드
             ,  TOUCH_TP      TOUCH_TP    -- 상품 UI 그룹 레벨 => [G:메뉴그룹, T:메뉴타입 ,M:메뉴]
             ,  TOUCH_NM      TOUCH_NM    -- POS 상품명
             ,  BTN_COLOR1    BTN_COLOR1  -- 버튼색상 1
             ,  BTN_COLOR2    BTN_COLOR2  -- 버튼색상 2
             ,  FONT_COLOR    FONT_COLOR  -- 폰트색상
             ,  NVL(FONT_SIZE, 0)                    FONT_SIZE -- 폰트크기
             ,  NVL(POSITION , 0)                    POSITION -- 상품 DISPLAY 위치
             ,  IMG_YN        IMG_YN -- 이미지 유무
             ,  IMG_PATH      IMG_PATH -- 이미지 명
             ,  USE_YN        USE_YN -- 사용여부
             ,  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS')  UPD_DT -- 수정일시
             ,  FONT_WEIGHT   FONT_WEIGHT -- 폰트굵기
          FROM  TOUCH_STORE_UI
         WHERE  COMP_CD   = P_COMP_CD
           AND  BRAND_CD  = P_BRAND_CD
           AND  STOR_CD   = P_STOR_CD
           AND  UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
           AND  USE_YN LIKE P_USE_YN;
    ELSE
        -- 직/가맹 터치키 마스터 수신
        OPEN p_cursor FOR
        SELECT  BRAND_CD      BRAND_CD    -- 영업조직
             ,  P_STOR_CD     STOR_CD     -- 점포코드
             ,  TOUCH_DIV     TOUCH_DIV   -- 터치키 구분
             ,  TOUCH_GR_CD   TOUCH_GR_CD -- 터치키 그룹 코드
             ,  TOUCH_CD      TOUCH_CD    -- 터치키 코드
             ,  TOUCH_TP      TOUCH_TP    -- 상품 UI 그룹 레벨 => [G:메뉴그룹, T:메뉴타입 ,M:메뉴]
             ,  TOUCH_NM      TOUCH_NM    -- POS 상품명
             ,  BTN_COLOR1    BTN_COLOR1  -- 버튼색상 1
             ,  BTN_COLOR2    BTN_COLOR2  -- 버튼색상 2
             ,  FONT_COLOR    FONT_COLOR  -- 폰트색상
             ,  NVL(FONT_SIZE, 0)                    FONT_SIZE -- 폰트크기
             ,  NVL(POSITION , 0)                    POSITION -- 상품 DISPLAY 위치
             ,  IMG_YN        IMG_YN -- 이미지 유무
             ,  IMG_PATH      IMG_PATH -- 이미지 명
             ,  USE_YN        USE_YN -- 사용여부
             ,  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS')  UPD_DT -- 수정일시
             ,  FONT_WEIGHT   FONT_WEIGHT -- 폰트굵기
          FROM  TOUCH_UI
         WHERE  COMP_CD   = P_COMP_CD
           AND  BRAND_CD  = P_BRAND_CD
           AND  STOR_TP   = P_STOR_TP
           AND  USE_YN    = 'Y';
    END IF;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_09;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (부가상품터치키그룹)
  -- Ref. Table        : SUB_TOUCH_UI
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_10 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    WITH GR AS (
      SELECT COMP_CD
           , BRAND_CD
           , STOR_CD
           , SUB_TOUCH_GR_CD
        FROM (
              SELECT COMP_CD,
                     BRAND_CD,
                     STOR_CD,
                     SUB_TOUCH_GR_CD
                FROM SUB_STORE_TOUCH_UI
               WHERE COMP_CD   = P_COMP_CD
                 AND BRAND_CD  = P_BRAND_CD
                 AND STOR_CD   = P_STOR_CD
                 AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                 AND USE_YN LIKE P_USE_YN
              UNION
              SELECT COMP_CD,
                     BRAND_CD,
                     STOR_CD,
                     SUB_TOUCH_GR_CD
                FROM SUB_STORE_ITEM
               WHERE COMP_CD   = P_COMP_CD
                 AND BRAND_CD  = P_BRAND_CD
                 AND STOR_CD   = P_STOR_CD
                 AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                 AND USE_YN LIKE P_USE_YN
               GROUP BY COMP_CD, BRAND_CD, STOR_CD, SUB_TOUCH_GR_CD
             )
    )
    SELECT U.BRAND_CD AS BRAND_CD -- 영업조직
         , P_STOR_CD  AS STOR_CD  -- 점포코드
         , U.SUB_TOUCH_GR_CD AS SUB_TOUCH_GR_CD -- 부가상품 터치키 그룹 코드
         , U.SUB_TOUCH_GR_CD AS SUB_TOUCH_CD    -- 부가상품코드
         , 'G' AS SUB_TOUCH_TP  -- 상품 UI 그룹 레벨  => ('G' :메뉴그룹, 'M':메뉴)수신시 임의로 넣어준다.임의로 만들어준다.
         , '0' AS SUB_TOUCH_DIV -- 부가상품구분
         , U.SUB_TOUCH_GR_CD AS ITEM_CD -- 부가상품코드
         , 0 AS SALE_PRC        -- 제품금액
         , U.SUB_TOUCH_NM AS SUB_ITEM_NM -- 제품명
         , U.BTN_COLOR1 AS BTN_COLOR1 -- 버튼색상 1
         , U.BTN_COLOR2 AS BTN_COLOR2 -- 버튼색상 2
         , U.FONT_COLOR AS FONT_COLOR -- 폰트색상
         , NVL(U.FONT_SIZE, 0) AS FONT_SIZE -- 폰트크기
         , NVL(U.POSITION , 1) AS SUB_POSITION -- 상품 DISPLAY 위치
         , U.IMG_YN AS IMG_YN -- 이미지 유무
         , U.IMG_PATH AS IMG_PATH -- 이미지 명
         , U.USE_YN AS USE_YN -- 사용 여부
         , TO_CHAR(U.UPD_DT, 'YYYYMMDDHH24MISS') AS UPD_DT -- 수정일시
      FROM SUB_STORE_TOUCH_UI U,
           GR                 G
     WHERE G.COMP_CD  = U.COMP_CD
       AND G.BRAND_CD = U.BRAND_CD
       AND G.STOR_CD = U.STOR_CD
       AND G.SUB_TOUCH_GR_CD = U.SUB_TOUCH_GR_CD
    UNION ALL
    SELECT U.BRAND_CD AS BRAND_CD -- 영업조직
         , P_STOR_CD AS STOR_CD -- 점포코드
         , I.SUB_TOUCH_GR_CD AS SUB_TOUCH_GR_CD -- 부가상품 터치키 그룹 코드
         , I.SUB_TOUCH_CD AS SUB_TOUCH_CD -- 부가상품코드
         , 'M' AS SUB_TOUCH_TP -- 상품 UI 그룹 레벨  => ('G' :메뉴그룹, 'M':메뉴)수신시 임의로 넣어준다.임의로 만들어준다.
         , I.SUB_TOUCH_DIV AS SUB_TOUCH_DIV -- 부가상품구분
         , I.ITEM_CD AS ITEM_CD -- 부가상품코드
         , NVL(I.SALE_PRC, 0) AS SALE_PRC -- 제품금액
         , NVL(I.SUB_ITEM_NM, C.ITEM_POS_NM) AS SUB_ITEM_NM -- 제품명 JSD
         , I.BTN_COLOR1 AS BTN_COLOR1 -- 버튼색상 1
         , I.BTN_COLOR2 AS BTN_COLOR2 -- 버튼색상 2
         , I.FONT_COLOR AS FONT_COLOR -- 폰트색상
         , NVL(I.FONT_SIZE, 0) AS FONT_SIZE -- 폰트크기
         , NVL(I.POSITION , 1) AS SUB_POSITION -- 상품 DISPLAY 위치
         , I.IMG_YN AS IMG_YN -- 이미지 유무
         , I.IMG_PATH AS IMG_PATH -- 이미지 명
         , I.USE_YN AS USE_YN -- 사용 여부
         , TO_CHAR( I.UPD_DT, 'YYYYMMDDHH24MISS' ) AS UPD_DT -- 수정일시
      FROM SUB_STORE_TOUCH_UI U
         , SUB_STORE_ITEM     I
         , ITEM_CHAIN         C
         , GR                 G
     WHERE G.COMP_CD  = U.COMP_CD
       AND G.BRAND_CD = U.BRAND_CD
       AND G.STOR_CD  = U.STOR_CD
       AND G.SUB_TOUCH_GR_CD = U.SUB_TOUCH_GR_CD
       AND G.COMP_CD  = I.COMP_CD
       AND G.BRAND_CD = I.BRAND_CD
       AND G.STOR_CD  = I.STOR_CD
       AND G.SUB_TOUCH_GR_CD = I.SUB_TOUCH_GR_CD
       AND I.COMP_CD  = C.COMP_CD(+)
       AND I.BRAND_CD = C.BRAND_CD(+)
       AND I.ITEM_CD  = C.ITEM_CD(+)
       AND P_STOR_TP  = C.STOR_TP(+);

    anRetVal := 1 ;
    asRetMsg := 'OK';
  Exception
  When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
  END GET_MASTER_10 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (상품별 부가상품 그룹)
  -- Ref. Table        : ITEM_EXT_GRP
  --------------------------------------------------------------------------------
  --  Create Date      : 2012-03-12
  --  Modify Date      : 2012-03-12
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_11 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD
         , STOR_CD
         , ITEM_CD
         , SUB_TOUCH_GR_CD
         , USE_YN
      FROM ITEM_EXT_GRP
     WHERE COMP_CD  = P_COMP_CD
       AND BRAND_CD = P_BRAND_CD
       AND STOR_CD  = P_STOR_CD
       AND UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_11;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (버튼정보)
  -- Ref. Table        : BUTTON_INFO
  --------------------------------------------------------------------------------
  --  Create Date      : 2012-04-09
  --  Modify Date      : 2012-04-09
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_12 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD
         , STOR_CD
         , POS_NO
         , STORE_GB
         , BTN_GRP_CD
         , BTN_GRP_NM
         , BTN_SEQ
         , BTN_PG_NM
         , BTN_CD
         , BTN_TEXT
         , BTN_EVENT
         , BTN_FCOLOR
         , BTN_ECOLOR
         , FONT_COLOR
         , SIZE_H
         , SIZE_W
         , BTN_USE
      FROM BUTTON_INFO
     WHERE COMP_CD  = P_COMP_CD
       AND BRAND_CD = P_BRAND_CD
       AND STOR_CD  = P_STOR_CD;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_12;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (옵션상품)
  -- Ref. Table        : OPTION_ITEM
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_13 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    WITH GR AS (
      SELECT COMP_CD,
             BRAND_CD,
             OPT_GRP
        FROM OPTION_GRP
       WHERE COMP_CD   = P_COMP_CD
         AND BRAND_CD  = P_BRAND_CD
         AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
         AND USE_YN LIKE P_USE_YN
      UNION
      SELECT COMP_CD,
             BRAND_CD,
             OPT_GRP
        FROM OPTION_ITEM
       WHERE COMP_CD   = P_COMP_CD
         AND BRAND_CD  = P_BRAND_CD
         AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
         AND USE_YN LIKE P_USE_YN
       GROUP BY COMP_CD, BRAND_CD,
             OPT_GRP
    )
    SELECT G.BRAND_CD   BRAND_CD    -- 영업조직
         , P_STOR_CD    STOR_CD     -- 점포코드
         , G.OPT_GRP    OPT_GRP     -- 옵션그룹
         , G.OPT_GRP    OPT_CD      -- 옵션코드
         , 0            OPT_SEQ     -- 옵션순서
         , G.OPT_GRP_NM OPT_NM      -- 옵션상품명
         , 'N'          REF_ITEM_YN -- 연계상품여부
         , NULL         ITEM_CD     -- 연계상품코드
         , 'N'          STOCK_YN    -- 재고관리여부
         , G.USE_YN     USE_YN      -- 사용 여부
         , 0            SET_PRC     -- 세트투입단가
      FROM OPTION_GRP G,
           GR         R
     WHERE G.COMP_CD  = R.COMP_CD
       AND G.BRAND_CD = R.BRAND_CD
       AND G.OPT_GRP  = R.OPT_GRP
    UNION ALL
    SELECT I.BRAND_CD    BRAND_CD    -- 영업조직
         , P_STOR_CD     STOR_CD     -- 점포코드
         , I.OPT_GRP     OPT_GRP     -- 옵션그룹
         , I.OPT_CD      OPT_CD      -- 옵션코드
         , I.OPT_SEQ     OPT_SEQ     -- 옵션순서
         , I.OPT_NM      OPT_NM      -- 옵션상품명
         , 'N'           REF_ITEM_YN -- 연계상품여부
         , I.ITEM_CD     ITEM_CD -- 연계상품코드
         , 'N'           STOCK_YN -- 재고관리여부
         , I.USE_YN      USE_YN -- 사용 여부
         , NVL(I.SET_PRC, 0)     SET_PRC  -- 세트투입단가
      FROM OPTION_ITEM I,
           GR          R
     WHERE I.COMP_CD  = R.COMP_CD
       AND I.BRAND_CD = R.BRAND_CD
       AND I.OPT_GRP  = R.OPT_GRP;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_MASTER_13;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (옵션상품 RULE)
  -- Ref. Table        : ITEM_OPTION_RULE
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_14 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT R.BRAND_CD   BRAND_CD -- 영업조직
         , P_STOR_CD    STOR_CD  -- 점포코드
         , R.ITEM_CD    ITEM_CD  -- 상품코드
         , R.OPT_GRP    OPT_GRP  -- 옵션그룹
         , TO_CHAR(R.OPT_SEQ)  OPT_SEQ -- 옵션순서
         , G.OPT_GRP_NM OPT_GRP_NM -- 옵션그룹명
         , TO_CHAR(R.MIN_CNT)  MIN_CNT -- 최소선택수
         , TO_CHAR(R.MAX_CNT)  MAX_CNT -- 최대선택수
         , R.USE_YN     USE_YN -- 사용여부
         , TO_CHAR(R.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM ITEM_OPTION_RULE R,
           OPTION_GRP       G
     WHERE R.COMP_CD   = G.COMP_CD
       AND R.BRAND_CD  = G.BRAND_CD
       AND R.OPT_GRP   = G.OPT_GRP
       AND R.COMP_CD   = P_COMP_CD
       AND R.BRAND_CD  = P_BRAND_CD
       AND R.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND R.USE_YN LIKE P_USE_YN;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_14 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (상품권 권종 마스터)
  -- Ref. Table        : GIFT_CODE_MST
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_15 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT G.GIFT_CD     GIFT_CD        -- 상품권 코드
         , G.GIFT_NM     GIFT_NM        -- 상품권 명칭
         , NVL(G.PRICE, 0) GIFT_AMT     -- 상품권 금액
         , G.APPR_YN     APP_YN         -- 승인 여부
         , NVL(G.MAND_YN, 'N') MAND_YN  -- 금액입력여부[YN]
         , G.BTN_BCL     BTN_BCL        -- 버튼 배경색
         , G.BTN_FCL     BTN_FCL        -- 버튼 글자색
         , NVL(G.POINT_YN, 'N') POINT_YN -- 포인트 적립여부[YN]
         , G.USE_YN      USE_YN         -- 사용 여부
         , TO_CHAR(G.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
         , G.CHANGE_STD_DIV
         , G.CHANGE_STD_VALUE
         , G.GIFT_PUB_DIV
         , G.GIFT_LCD
         , G.DC_DIV
         , G.ITEM_CD
      FROM GIFT_CODE_MST G
     WHERE COMP_CD   = P_COMP_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_15;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (기타입출금)
  -- Ref. Table        : ACC_MST
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_16 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT A.ETC_CD    ETC_CD  -- 입출금계정코드
         , A.ETC_NM    ETC_NM  -- 입출금계정명칭
         , A.ETC_DIV   ETC_DIV -- 입출금 구분   =>  [01:입금계정, 02:출금계정]
         , A.ACC_CD    ACC_CD  -- 계정코드
         , NVL(A.POS_USE_YN, 'N')   POS_USE_YN -- 포스사용여부  => Y:사용, N:미사용
         , NVL(A.PURCHASE_DIV, '0') PURCHASE_DIV -- 매입처입력구분 => 공통(01475) [0:미입력, 1:고객, 2:매입처]
         , A.USE_YN    USE_YN -- 사용 여부
         , TO_CHAR(A.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM ACC_MST A
     WHERE A.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND A.COMP_CD   = P_COMP_CD
       AND A.STOR_TP   = P_STOR_TP
       AND A.USE_YN LIKE P_USE_YN;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_16;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (기타입출금 적요)
  -- Ref. Table        : ACC_RMK
  --------------------------------------------------------------------------------
  --  Create Date      : 2016-07-13
  --  Modify Date      : 2016-07-13
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_17 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT  A.ETC_CD        -- 입출금계정코드
         ,  A.RMK_SEQ       -- 적요순번
         ,  A.RMK_NM        -- 적요명
         ,  A.RMK_DESC      -- 적요설명
         ,  A.SORT_SEQ      -- 정렬순서
         ,  A.USE_YN        -- 사용 여부
         ,  TO_CHAR(A.INST_DT, 'YYYYMMDDHH24MISS')  AS INST_DT  -- 등록일시
         ,  A.INST_USER                                         -- 등록자
         ,  TO_CHAR(A.UPD_DT, 'YYYYMMDDHH24MISS')   AS UPD_DT   -- 수정일시
         ,  A.UPD_USER                                          -- 수정자
      FROM  ACC_RMK A
     WHERE  A.COMP_CD   = P_COMP_CD
       AND  A.STOR_TP   = P_STOR_TP
       AND  A.USE_YN LIKE P_USE_YN
       AND  A.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_17;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (대분류)
  -- Ref. Table        : ITEM_L_CLASS
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-30
  --  Create Programer : 박인수
  --  Modify Date      : 2009-12-30
  --  Modify Programer :
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_26 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur 
  ) IS
    lnCnt Number(5) := 0 ;
  BEGIN
    OPEN p_cursor FOR
    SELECT I.L_CLASS_CD
         , I.L_CLASS_NM
         , I.USE_YN
         , TO_CHAR(I.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM ITEM_L_CLASS I
     WHERE I.COMP_CD      = P_COMP_CD
       AND I.ORG_CLASS_CD = '00'
       AND I.UPD_DT      >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND I.USE_YN    LIKE P_USE_YN;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_MASTER_26;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (중분류)
  -- Ref. Table        : ITEM_M_CLASS
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-30
  --  Modify Date      : 2009-12-30
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_27 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
    lnCnt Number(5) := 0 ;
  BEGIN
    OPEN p_cursor FOR
    SELECT I.L_CLASS_CD
         , I.M_CLASS_CD
         , I.M_CLASS_NM
         , I.USE_YN
         , TO_CHAR(I.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
         , C.BTN_COLOR
      FROM ITEM_M_CLASS        I
         , ITEM_M_CLASS_COLOR  C
     WHERE I.COMP_CD      = C.COMP_CD(+)
       AND I.ORG_CLASS_CD = C.ORG_CLASS_CD(+)
       AND I.L_CLASS_CD   = C.L_CLASS_CD(+)
       AND I.M_CLASS_CD   = C.M_CLASS_CD(+)
       AND I.COMP_CD      = P_COMP_CD
       AND I.ORG_CLASS_CD = '00'
       AND I.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND I.USE_YN LIKE P_USE_YN;

      anRetVal := 1;
      asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_27;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (소분류)
  -- Ref. Table        : ITEM_S_CLASS
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-30
  --  Modify Date      : 2009-12-30
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_28 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
    lnCnt Number(5) := 0 ;
  BEGIN
    OPEN p_cursor FOR
    SELECT I.L_CLASS_CD
         , I.M_CLASS_CD
         , I.S_CLASS_CD
         , I.S_CLASS_NM
         , I.USE_YN
         , TO_CHAR(I.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM ITEM_S_CLASS I
     WHERE I.COMP_CD      = P_COMP_CD
       AND I.ORG_CLASS_CD = '00'
       AND I.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND I.USE_YN LIKE P_USE_YN;

      anRetVal := 1 ;
      asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_28;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (주방상품정보)
  -- Ref. Table        : PLU_AMT_STORE
  --------------------------------------------------------------------------------
  --  Create Date      : 2010-12-07
  --  Modify Date      : 2010-12-07
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_29 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
    lnCnt Number(5) := 0 ;
  BEGIN
    OPEN p_cursor FOR
    SELECT ITEM_CD,
           REPLACE(REPLACE(KITCHEN_INFO, CHR(13), '@'), CHR(10), '$') KITCHEN_INFO,
           USE_YN,
           TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
     FROM ITEM_KITCHEN
    WHERE COMP_CD   = P_COMP_CD
      AND BRAND_CD  = P_BRAND_CD
      AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
      AND USE_YN LIKE P_USE_YN;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_29 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (세트 구성품 정보)
  -- Ref. Table        : SET_RULE, SET_RULE_STORE
  --------------------------------------------------------------------------------
  --  Create Date      : 2011-12-30
  --  Modify Date      : 2011-12-30
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_31 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
    lnCnt NUMBER(3) := 0;
  BEGIN

   OPEN p_cursor FOR
   SELECT BRAND_CD -- 영업조직
        , P_STOR_CD -- 점포코드
        , ITEM_CD -- 상품코드
        , SEQ -- 순번
        , GRP_DIV -- 그룹/단품 구분 => 0-상품, 1-그룹
        , OPTN_ITEM_CD -- 옵션그룹/상품코드
        , MIN_QTY -- 기준수량
        , SALE_PRC -- 기준단가
        , SALE_AMT -- 기준금액
        , ADJ_METHOD -- 금액차이조정방법
        , REPLACEABLE -- 품목대체허용여부 => [N-대체불가,Y-대체허용]
        , SORT_ORD -- 적용순서
        , MANDT_DIV -- 필수구분 => [0-옵션, 1-필수]
        , USE_YN -- 사용여부
        , START_DT
        , CLOSE_DT
     FROM SET_RULE
    WHERE COMP_CD = P_COMP_CD
      AND BRAND_CD = P_BRAND_CD
      AND UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
      AND USE_YN LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_31 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (주방오더 프린터 상품(다중))
  -- Ref. Table        : STORE_ITEM_PRT_MULTI
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-04-20
  --  Modify Date      : 2014-04-20
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_32 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT  BRAND_CD
         ,  STOR_CD
         ,  PRT_NO
         ,  ITEM_CD
         ,  USE_YN
         ,  UPD_DT
      FROM  (
                SELECT  BRAND_CD                -- 영업조직
                     ,  P_STOR_CD   AS STOR_CD  -- 점포코드
                     ,  PRT_NO                  -- 프린터번호
                     ,  ITEM_CD                 -- 상품코드
                     ,  USE_YN                  -- 사용유무
                     ,  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
                  FROM  ITEM_PRT_MULTI
                 WHERE  COMP_CD  = P_COMP_CD
                   AND  BRAND_CD = P_BRAND_CD
                   AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                   AND  USE_YN LIKE P_USE_YN
                /*   
                UNION
                SELECT  BRAND_CD      BRAND_CD  -- 영업조직
                     ,  STOR_CD       STOR_CD   -- 점포코드
                     ,  PRT_NO        PRT_NO    -- 프린터번호
                     ,  ITEM_CD       ITEM_CD   -- 상품코드
                     ,  USE_YN        USE_YN    -- 사용유무
                     ,  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
                  FROM  STORE_ITEM_PRT_MULTI MUL
                      , STORE_DEVICE         DIC
                 WHERE  MUL.COMP_CD  = DIC.COMP_CD
                 AND    MUL.BRAND_CD = DIC.BRAND_CD
                 AND    MUL.STOR_CD  = DIC.STOR_CD
                 AND    
                 AND    COMP_CD   = P_COMP_CD
                   AND  BRAND_CD  = P_BRAND_CD
                   AND  STOR_CD   = P_STOR_CD
                   AND  UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                   AND  USE_YN LIKE P_USE_YN
                */
            )
     ORDER  BY UPD_DT;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_32;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (상품분류(공통제외))
  -- Ref. Table        : ITEM_CLASS
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-08-18
  --  Modify Date      : 2014-08-18
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_33 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT  IC.ORG_CLASS_CD
         ,  IC.ITEM_CD
         ,  IC.L_CLASS_CD
         ,  IC.M_CLASS_CD
         ,  IC.S_CLASS_CD
         ,  IC.USE_YN
         ,  TO_CHAR(IC.UPD_DT, 'YYYYMMDDHH24MISS')  UPD_DT -- 수정일시
      FROM COMMON       C
         , ITEM_CLASS   IC
     WHERE C.COMP_CD    = IC.COMP_CD
       AND C.CODE_CD    = IC.ORG_CLASS_CD
       AND C.CODE_TP    = '01020'
       AND C.COMP_CD    = P_COMP_CD
       AND C.USE_YN     = 'Y'
       AND C.VAL_C1     IS NOT NULL
       AND IC.UPD_DT    >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND IC.USE_YN    LIKE P_USE_YN
     ORDER BY UPD_DT;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_33;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (담당자 마스터)
  -- Ref. Table        : STORE_USER
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-23
  --  Modify Date      : 2009-12-23
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_50 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN

  IF P_COMP_CD <> '012' THEN
        -- 점포사용자 수신(공통)
        OPEN p_cursor FOR
            SELECT  SU.BRAND_CD     BRAND_CD    -- 영업조직
                  , SU.STOR_CD      STOR_CD     -- 점포코드
                  , SU.USER_ID      USER_ID     -- 담당자 코드
                  , SU.ROLE_DIV     CASHIER_DIV -- 역할 (담당자 구분)
                  , SU.USER_NM      USER_NM     -- 사원명
                  , SU.EMP_DIV      CASHIER_AL  -- 직원구분 (담당자 직급)
                  , SU.POS_PWD      CASHIER_PD  -- POS 비밀번호
                  , SU.WEB_PWD      WEB_PWD     -- 웹비밀번호
                  , 'N'             NIGHT_YN    -- 야간근무유무
                  , '2'             AUTH_CD     -- 포스권한 (권한 level)
                  , SU.MNG_CARD_ID  MSR_NO      -- 관리 카드번호
                  , NULL            REJECT_PWD  -- 반품비밀번호
                  , CASE WHEN ST.STOR_TP IN ('10','20') THEN SU.USE_YN ELSE 'N' END AS USE_YN    -- 사용 여부
                  , TO_CHAR(SU.UPD_DT, 'YYYYMMDDHH24MISS')                          AS UPD_DT    -- 수정일시
                  , NVL(AP.BASIC_PAY, 0)                                            AS BASIC_PAY -- 기본급여
            FROM    STORE_USER SU
                  , STORE      ST
                  ,(
                    SELECT  COMP_CD
                          , BRAND_CD
                          , STOR_CD
                          , USER_ID
                          , BASIC_PAY
                          , ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, STOR_CD, USER_ID ORDER BY ATTD_PAY_DT DESC) R_NUM
                    FROM    STORE_PAY_MST
                    WHERE   COMP_CD      = P_COMP_CD
                    --AND     BRAND_CD     = P_BRAND_CD
                    --AND     STOR_CD      = P_STOR_CD
                    AND     ATTD_PAY_DIV = '1' -- 시급
                    AND     ATTD_PAY_DT <= SUBSTR(P_DOWN_DTM, 1, 8)
                   ) AP
            WHERE   SU.COMP_CD   = ST.COMP_CD
            AND     SU.BRAND_CD  = ST.BRAND_CD
            AND     SU.STOR_CD   = ST.STOR_CD
            AND     SU.COMP_CD   = AP.COMP_CD (+)
            AND     SU.BRAND_CD  = AP.BRAND_CD(+)
            AND     SU.STOR_CD   = AP.STOR_CD (+)
            AND     SU.USER_ID   = AP.USER_ID (+)
            AND     1            = AP.R_NUM   (+)
            AND     SU.COMP_CD   = P_COMP_CD
            --AND     SU.BRAND_CD  = P_BRAND_CD
            --AND     SU.STOR_CD   = P_STOR_CD
            AND     SU.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
            AND     SU.USE_YN LIKE P_USE_YN;
    ELSE
        -- 모스버거용
        OPEN p_cursor FOR
        SELECT BRAND_CD    BRAND_CD    -- 영업조직
             , STOR_CD     STOR_CD     -- 점포코드
             , USER_ID     USER_ID     -- 담당자 코드
             , ROLE_DIV    CASHIER_DIV -- 역할 (담당자 구분)
             , USER_NM     USER_NM     -- 사원명
             , EMP_DIV     CASHIER_AL  -- 직원구분 (담당자 직급)
             , POS_PWD     CASHIER_PD  -- POS 비밀번호
             , WEB_PWD     WEB_PWD     -- 웹비밀번호
             , 'N'         NIGHT_YN    -- 야간근무유무
             , '2'         AUTH_CD     -- 포스권한 (권한 level)
             , MNG_CARD_ID MSR_NO      -- 관리 카드번호
             , NULL        REJECT_PWD  -- 반품비밀번호
             , USE_YN      USE_YN      -- 사용 여부
             , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
          FROM STORE_USER
         WHERE COMP_CD   = P_COMP_CD
           AND BRAND_CD  = P_BRAND_CD
           AND STOR_CD   = P_STOR_CD
           AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
           AND USE_YN LIKE P_USE_YN
        UNION ALL
        SELECT P_BRAND_CD  BRAND_CD    -- 영업조직
             , P_STOR_CD   STOR_CD     -- 점포코드
             , USER_ID     USER_ID     -- 담당자 코드
             , '01'        CASHIER_DIV -- 역할 (담당자 구분)
             , USER_NM     USER_NM     -- 사원명
             , '0'         CASHIER_AL  -- 직원구분 (담당자 직급)
             , PWD         CASHIER_PD  -- POS 비밀번호
             , PWD         WEB_PWD     -- 웹 비밀번호
             , 'N'         NIGHT_YN    -- 야간근무유무
             , '2'         AUTH_CD     -- 포스권한 (권한 level)
             , NULL        MSR_NO      -- 관리 카드번호
             , PWD         REJECT_PWD  -- 반품비밀번호
             , USE_YN      USE_YN      -- 사용 여부
             , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
          FROM HQ_USER
         WHERE COMP_CD   = P_COMP_CD
           AND BRAND_CD  = P_BRAND_CD
           AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
           AND USE_YN LIKE P_USE_YN;
    END IF;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_50 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (카드사 마스터 )
  -- Ref. Table        : CARD
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_52 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT M.CARD_DIV CARD_DIV  -- 카드사 구분
         , M.CARD_CD  CARD_CD   -- 카드사 코드
         , M.CARD_NM  CARD_NM   -- 카드사 명칭
         , NVL(M.CARD_FEE, 0) CARD_FEE -- 수수료율
         , M.BUSI_NO  BUSI_NO   -- 사업자번호
         , M.TEL_NO   TEL_NO    -- 카드사 전화번호
         , ''         VAN_CD    -- VAN사 구분 코드 (현재 쓰지 안 음)
         , ''         V_CARD_CD -- 카드사 매칭코드 (현재 쓰지 안 음)
         , M.HOMEPAGE HOMEPAGE  -- 선택,입력그룹순서
         , M.USE_YN   USE_YN    -- 사용 여부
         , TO_CHAR(M.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM CARD M
     WHERE COMP_CD   = P_COMP_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_MASTER_52 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (카드사 PREFIX )
  -- Ref. Table        : CARDMB_PREFIX
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_53 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT PFX_CD      PFX_CD -- PK.PREFIX 코드
         , CARD_DIV    CARD_DIV -- 카드구분 => 공통(01095) [C:신용카드, L:LG, H:HP, S: SK]
         , PFX_NM      PFX_NM -- PREFIX명
         , NVL(POSITION, 0)      POSITION -- 위치
         , CHECK_VAL   CHECK_VAL -- 체크값
         , CARD_CD     CARD_CD -- 카드사코드 => CARD 테이블 참조
         , BANK_CD     BANK_CD -- 은행코드 => 공통(00615)
         , COOP_CARD   COOP_CARD -- 제휴카드구분 => 공통(00450) [CC:해피신한, CK:해피신한체크, KC: 해피국민,  KK:해피국민체크, LC:해피롯데, LK:해피롯데체크, HC:일반해피카드]
         , USE_YN      USE_YN -- 사용 여부
         , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
      FROM CARDMB_PREFIX
     WHERE COMP_CD   = P_COMP_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_53 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (공통코드 )
  -- Ref. Table        : COMMON
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_54 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
      OPEN p_cursor FOR
      WITH TP AS (
        SELECT CODE_CD AS CODE_TP
          FROM COMMON
         WHERE COMP_CD  = P_COMP_CD
           AND CODE_TP    = '00000'
           AND POS_IF_YN  = 'Y'
           AND USE_YN  LIKE P_USE_YN
      )
      SELECT C.CODE_TP AS CODE_TP   -- PK.공통코드타입
           , C.CODE_CD AS CODE_CD   -- PK.공통코드
           , C.CODE_NM AS CARD_NM   -- 공통명칭
           , C.BRAND_CD AS BRAND_CD -- 영업조직
           , C.VAL_D1 AS VAL_D1 -- 날짜1
           , C.VAL_D2 AS VAL_D2 -- 날짜2
           , C.VAL_C1 AS VAL_C1 -- 문자1
           , C.VAL_C2 AS VAL_C2 -- 문자2
           , C.VAL_N1 AS VAL_N1 -- 숫자1
           , C.VAL_N2 AS VAL_N2 -- 숫자2
           , C.REMARKS AS REMARKS -- 비고
           , C.USE_YN AS USE_YN -- 사용 여부
           , TO_CHAR(C.UPD_DT, 'YYYYMMDDHH24MISS') AS UPD_DT -- 수정일시
        FROM COMMON C,
             TP     G
       WHERE C.CODE_TP = G.CODE_TP
         AND C.UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
         AND C.COMP_CD = P_COMP_CD;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_54;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (VAN, 카드 정보 )
  -- Ref. Table        : CAT ID, VAN, COMMON
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_57 (
    anRetVal OUT NUMBER , -- 결과코드
    asRetMsg OUT                       VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  'INTERFACEINFO'
              , FLAG_NM
              , FLAG_VAL
        FROM   (
                WITH W1 AS 
                   (
                    SELECT  V1.KEY_ID||'_'||V1.VAN_PRI||'_TYPE'     AS KEY1
                          , CASE WHEN C1.USE_YN = 'N' THEN '0' ELSE TO_CHAR(TO_NUMBER(V1.VAN_CD)) END AS VAL1
                          , V1.KEY_ID||'_'||V1.VAN_PRI||'_IP'       AS KEY2
                          , V1.IP                                   AS VAL2
                          , V1.KEY_ID||'_'||V1.VAN_PRI||'_PORT'     AS KEY3
                          , V1.PORT                                 AS VAL3
                          , V1.KEY_ID||'_'||V1.VAN_PRI||'_TID'      AS KEY4
                          , C1.CAT_ID                               AS VAL4
                          , V1.KEY_ID||'_'||V1.VAN_PRI||'_RATE'     AS KEY5
                          , TO_CHAR(C1.VAN_RATE)                    AS VAL5
                    FROM    VAN     V1
                          , CATID   C1
                    WHERE   V1.COMP_CD  = C1.COMP_CD
                    AND     V1.VAN_CD   = C1.VAN_CD
                    AND     C1.COMP_CD  = P_COMP_CD
                    AND     C1.BRAND_CD = P_BRAND_CD
                    AND     C1.STOR_CD  = P_STOR_CD
                    AND     V1.VAN_DIV  = '01'   -- VAN사
                    UNION ALL
                    SELECT  V1.KEY_ID||'_'||'04_TYPE'       AS KEY1
                          , CASE WHEN C1.USE_YN = 'N' THEN '0' ELSE TO_CHAR(TO_NUMBER(V1.VAN_CD)) END AS VAL1
                          , V1.KEY_ID||'_'||'04_IP'         AS KEY2
                          , V1.IP                           AS VAL2
                          , V1.KEY_ID||'_'||'04_PORT'       AS KEY3
                          , V1.PORT                         AS VAL3
                          , V1.KEY_ID||'_'||'04_TID'        AS KEY4
                          , C1.CAT_ID_GIFT                  AS VAL4
                          , V1.KEY_ID||'_'||'04_RATE'       AS KEY5
                          , TO_CHAR(C1.VAN_RATE)            AS VAL5
                    FROM    VAN     V1
                          , CATID   C1
                    WHERE   V1.COMP_CD  = C1.COMP_CD
                    AND     V1.VAN_CD   = C1.VAN_CD
                    AND     C1.COMP_CD  = P_COMP_CD
                    AND     C1.BRAND_CD = P_BRAND_CD
                    AND     C1.STOR_CD  = P_STOR_CD
                    AND     V1.VAN_DIV  = '01'   -- 제휴사
                    AND     V1.VAN_PRI  = '01'
                   ) ,
                    W2 AS
                   (    
                    SELECT  V1.KEY_ID||'_DIV'           AS KEY1
                          , CASE WHEN C1.USE_YN = 'N' THEN '0' ELSE '1' END AS VAL1
                          , V1.KEY_ID||'_IP'            AS KEY2
                          , V1.IP                       AS VAL2
                          , V1.KEY_ID||'_PORT'          AS KEY3
                          , V1.PORT                     AS VAL3
                          , V1.KEY_ID||'_ID'            AS KEY4
                          , C1.CAT_ID                   AS VAL4
                        FROM    VAN     V1
                              , CATID   C1
                        WHERE   V1.COMP_CD  = C1.COMP_CD
                        AND     V1.VAN_CD   = C1.VAN_CD
                        AND     C1.COMP_CD  = P_COMP_CD
                        AND     C1.BRAND_CD = P_BRAND_CD
                        AND     C1.STOR_CD  = '0000000'
                        AND     V1.VAN_DIV  = '02'         -- 제휴사
                   )
                    SELECT  KEY1 FLAG_NM, VAL1 FLAG_VAL
                    FROM    W1
                    UNION ALL
                    SELECT  KEY2 FLAG_NM, VAL2 FLAG_VAL
                    FROM    W1
                    UNION ALL
                    SELECT  KEY3 FLAG_NM, VAL3 FLAG_VAL
                    FROM    W1
                    UNION ALL
                    SELECT  KEY4 FLAG_NM, VAL4 FLAG_VAL
                    FROM    W1
                    UNION ALL
                    SELECT  KEY5 FLAG_NM, VAL5 FLAG_VAL
                    FROM    W1
                    UNION ALL
                    SELECT  KEY1 FLAG_NM, VAL1 FLAG_VAL
                    FROM    W2
                    UNION ALL
                    SELECT  KEY2 FLAG_NM, VAL2 FLAG_VAL
                    FROM    W2
                    UNION ALL
                    SELECT  KEY3 FLAG_NM, VAL3 FLAG_VAL
                    FROM    W2
                    UNION ALL
                    SELECT  KEY4 FLAG_NM, VAL4 FLAG_VAL
                    FROM    W2
                   )
     ORDER BY FLAG_NM;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_57 ;

  ------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (점포 정보)
  -- Ref. Table        : STORE
  ------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  ------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_58 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT DECODE(LEVEL,  1, 'BRANDCD',             2, 'STORECD',         3, 'STORESNM',         4, 'STORELNM',           5, 'STORE_TP',
                          6, 'STOREAAA',
                          7, 'LICENSE',             8, 'AREP',            9, 'STORE_ADDR1',     10, 'STORE_ADDR2',       11, 'STORETELL',   12, 'ASTELL',
                         13, 'SHOPSERVICEGBPOS',
                         15, 'REGION_CD',           16, 'MULTI_LANGUAGE_YN',
                         17, 'LANGUAGE_TP',         18, 'BILL_ADDR',
                         19, 'SAV_PT_YN',           20, 'SAV_PT_RATE',    21, 'SAV_MLG_YN',
                         22, 'CALL_ORD_YN',         23, 'ONLINE_ORD_YN',  24, 'TAKE_OUT_ORD_YN', 25, 'DELIVERY_ORD_YN',   26, 'DELIVERY_HM', 27, 'RESERVE_HM',
                         28, 'SEAT'       ,         29, 'CURRENCY_CD',    30, 'LOCAL_DAYS',      31, 'FREE_ENTRY_DC_DIV',
                         32, 'SSG_PT_YN'  ,         33, 'SSG_PT_RATE',    34, 'USE_PT_MIN'  ,    35, 'USE_PT_UNIT',
                         36, 'DEF_MATL_ITEM_CD',    37, 'BRANDSNM'
                 ) FLAG_NM,
           DECODE(LEVEL,  1, BRAND_CD,              2, STOR_CD,           3, STOR_NM,            4, STOR_NM,              5, STOR_TP,
                          6, (CASE WHEN NVL(CLOSE_DT, '99991231') <= TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '1' ELSE '0' END),
                          7, REPLACE(BUSI_NO, '-', ''), 8, BUSI_NM,           9, ADDR1,          10, ADDR2,               11, TEL_NO,        12, '',
                         13, '0',
                         15, REGION_CD,             16, MULTI_LANGUAGE_YN,
                         17, LANGUAGE_TP,           18, BILL_ADDR,
                         19, SAV_PT_YN,             20, SAV_PT_RATE,      21, SAV_MLG_YN,
                         22, CALL_ORD_YN,           23, ONLINE_ORD_YN,    24, TAKE_OUT_ORD_YN,   25, DELIVERY_ORD_YN,     26, DELIVERY_HM,   27, RESERVE_HM,
                         28, SEAT,                  29, CURRENCY_CD,      30, LOCAL_DAYS,        31, FREE_ENTRY_DC_DIV,
                         32, SSG_PT_YN,             33, SSG_PT_RATE,      34, USE_PT_MIN,        35, USE_PT_UNIT,
                         36, DEF_MATL_ITEM_CD,      37, BRAND_SNM
                 ) FLAG_VAL
     FROM (SELECT A.* 
                , B.MULTI_LANGUAGE_YN 
                , B.LANGUAGE_TP
                , CASE WHEN C.MEMB_YN = 'Y' AND C.SAV_PT_YN  = 'Y' AND D.SAV_PT_YN  = 'Y' THEN 'Y'           ELSE 'N' END AS SAV_PT_YN
                , CASE WHEN C.MEMB_YN = 'Y' AND C.SAV_PT_YN  = 'Y' AND D.SAV_PT_YN  = 'Y' THEN C.SAV_PT_RATE ELSE 0   END AS SAV_PT_RATE
                , CASE WHEN C.MEMB_YN = 'Y' AND C.SAV_MLG_YN = 'Y' AND F.SAV_MLG_YN = 'Y' THEN 'Y'           ELSE 'N' END AS SAV_MLG_YN
                , NVL(E.CALL_ORD_YN,     'N')    CALL_ORD_YN
                , NVL(E.ONLINE_ORD_YN,   'N')    ONLINE_ORD_YN
                , NVL(E.TAKE_OUT_ORD_YN, 'N')    TAKE_OUT_ORD_YN
                , NVL(E.DELIVERY_ORD_YN, 'N')    DELIVERY_ORD_YN
                , NVL(E.DELIVERY_HM,     '0000') DELIVERY_HM
                , NVL(E.RESERVE_HM,      '0000') RESERVE_HM
                , NVL(G.LOCAL_DAYS,      '60')   LOCAL_DAYS
                , H.FREE_ENTRY_DC_DIV
                , CASE WHEN J.SSG_PT_YN    = 'Y' THEN 'Y' ELSE 'N' END AS SSG_PT_YN
                , NVL(K.SSG_PT_RATE, '0')                              AS SSG_PT_RATE
                , NVL(L.USE_PT_MIN ,  0 )     AS USE_PT_MIN
                , NVL(M.USE_PT_UNIT,  0 )     AS USE_PT_UNIT
                , N.DEF_MATL_ITEM_CD
                , Q.BRAND_SNM
             FROM STORE        A
                , COMPANY      B
                , BRAND_MEMB   C
                , BRAND        Q
                , (SELECT COMP_CD, BRAND_CD, STOR_CD, PARA_VAL SAV_PT_YN
                     FROM PARA_STORE
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND STOR_CD = P_STOR_CD
                      AND PARA_CD = '3001' -- 포인트 적립여부[Y:적립, N:적립안함]
                      AND USE_YN  = 'Y'
                  )            D
                , (SELECT COMP_CD, BRAND_CD, STOR_CD, PARA_VAL SAV_MLG_YN
                     FROM PARA_STORE
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND STOR_CD = P_STOR_CD
                      AND PARA_CD = '3002' -- 마일리지 적립여부[Y:적립, N:적립안함]
                      AND USE_YN  = 'Y'
                  )            F
               , (SELECT COMP_CD, BRAND_CD, STOR_CD, PARA_VAL SSG_PT_YN
                     FROM PARA_STORE
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND STOR_CD = P_STOR_CD
                      AND PARA_CD = '3003' -- 신세계 포인트 적립여부[Y:적립, N:적립안함]
                      AND USE_YN  = 'Y'
                  )            J
                , (SELECT COMP_CD, BRAND_CD, STOR_CD, PARA_VAL SSG_PT_RATE
                     FROM PARA_STORE
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND STOR_CD = P_STOR_CD
                      AND PARA_CD = '3004' -- 신세계 포인트 적립율
                      AND USE_YN  = 'Y'
                  )            K
                , (SELECT COMP_CD, BRAND_CD, PARA_VAL USE_PT_MIN
                     FROM PARA_BRAND
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND PARA_CD = '1017' -- 포인트 사용 하한
                  )            L
                , (SELECT COMP_CD, BRAND_CD, PARA_VAL USE_PT_UNIT
                     FROM PARA_BRAND
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND PARA_CD = '1018' -- 포인트 사용 단위
                      AND USE_YN  = 'Y'
                  )            M
                , (SELECT COMP_CD, BRAND_CD, PARA_VAL DEF_MATL_ITEM_CD
                     FROM PARA_BRAND
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND PARA_CD = '1020' -- 디폴트교구
                      AND USE_YN  = 'Y'
                  )            N
                , STORE_CNT    E
                , (
                    SELECT  COMP_CD
                         ,  MAX(CASE WHEN CODE_CD = '01' THEN VAL_C1 ELSE NULL END) AS LOCAL_DAYS
                      FROM  COMMON
                     WHERE  COMP_CD = P_COMP_CD
                       AND  CODE_TP = '90000'
                       AND  USE_YN  = 'Y'
                     GROUP  BY COMP_CD
                  ) G
                , (
                    SELECT  COMP_CD
                         ,  PARA_VAL AS FREE_ENTRY_DC_DIV
                      FROM  PARA_BRAND
                     WHERE  COMP_CD = P_COMP_CD
                       AND  BRAND_CD= P_BRAND_CD
                       AND  PARA_CD = '1019'
                       AND  USE_YN  = 'Y'
                  ) H
            WHERE A.COMP_CD  = E.COMP_CD(+)
              AND A.BRAND_CD = E.BRAND_CD(+)
              AND A.STOR_CD  = E.STOR_CD(+)
              AND A.COMP_CD  = D.COMP_CD(+)
              AND A.BRAND_CD = D.BRAND_CD(+)
              AND A.STOR_CD  = D.STOR_CD(+)
              AND A.COMP_CD  = F.COMP_CD(+)
              AND A.BRAND_CD = F.BRAND_CD(+)
              AND A.STOR_CD  = F.STOR_CD(+)
              AND A.COMP_CD  = J.COMP_CD(+)
              AND A.BRAND_CD = J.BRAND_CD(+)
              AND A.STOR_CD  = J.STOR_CD(+)
              AND A.COMP_CD  = K.COMP_CD(+)
              AND A.BRAND_CD = K.BRAND_CD(+)
              AND A.STOR_CD  = K.STOR_CD(+)
              AND A.COMP_CD  = L.COMP_CD(+)
              AND A.BRAND_CD = L.BRAND_CD(+)
              AND A.COMP_CD  = M.COMP_CD(+)
              AND A.BRAND_CD = M.BRAND_CD(+)
              AND A.COMP_CD  = N.COMP_CD(+)
              AND A.BRAND_CD = N.BRAND_CD(+)
              AND A.COMP_CD  = C.COMP_CD(+)
              AND A.BRAND_CD = C.BRAND_CD(+)
              AND A.COMP_CD  = Q.COMP_CD(+)
              AND A.BRAND_CD = Q.BRAND_CD(+)
              AND A.COMP_CD  = G.COMP_CD(+)
              AND A.COMP_CD  = H.COMP_CD(+)
              AND A.COMP_CD  = B.COMP_CD
              AND A.COMP_CD  = P_COMP_CD
              AND A.BRAND_CD = P_BRAND_CD
              AND A.STOR_CD  = P_STOR_CD
          ) CONNECT BY LEVEL <= 37
    UNION ALL
    SELECT 'COMP_CD' AS FLAG_NM ,
           COMP_CD   AS FLAG_VAL
      FROM COMPANY
     WHERE COMP_CD  = P_COMP_CD
       AND ROWNUM   = 1;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_58 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (본사 명판 -> 직영으로 고정함.)
  -- Ref. Table        : BILL_MSG_HQ
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_59 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BILL_MSG_DIV BILL_MSG_DIV -- PK.명판구분 => 공통(00655) [1:상단, 2:중단, 3:하단]
         , REPLACE(REPLACE(BILL_MSG, CHR(13), '@'), CHR(10), '$') BILL_MSG -- 명판메세지
         , USE_YN
      FROM BILL_MSG_HQ
     WHERE COMP_CD  = P_COMP_CD
       AND BRAND_CD = P_BRAND_CD
       AND STOR_TP  = '10'
       AND UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_59 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (점포 명판 )
  -- Ref. Table        : BILL_MSG_STOR
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_60 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BILL_MSG_DIV   BILL_MSG_DIV                                     -- PK.명판구분 => 공통(00655) [1:상단, 2:중단, 3:하단]
         , REPLACE(REPLACE(BILL_MSG, CHR(13), '@'), CHR(10), '$') BILL_MSG -- 명판메세지
         , USE_YN
      FROM BILL_MSG_STOR
     WHERE COMP_CD  = P_COMP_CD
       AND BRAND_CD = P_BRAND_CD
       AND STOR_CD  = P_STOR_CD
       AND UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_60;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       ( 송신 URL )
  -- Ref. Table        : COMMON
  --------------------------------------------------------------------------------
  --  Create Date      : 2010-04-16
  --  Modify Date      : 2010-04-16
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_61 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT VAL_C1  IF_FLAG,
           VAL_C2  IF_ID,
           REMARKS IF_PW
      FROM COMMON
     WHERE COMP_CD  = P_COMP_CD
       AND CODE_TP = '01440'
       AND USE_YN  = 'Y'
    UNION ALL
    SELECT DECODE(LEVEL, 1, 'FTPINFO', 'AIRINFO' )AS IF_FLAG ,
           DECODE(LEVEL, 1, 'FTP_PASSIVE' , 2, 'KORAIL_APPR_YN' , 3, 'ETC_IF_DIV' , 4, 'ETC_FTP_IP' , 5, 'ETC_FTP_PORT' , 6, 'ETC_FTP_ID' , 7, 'ETC_FTP_PW' , 8, 'ETC_FTP_PASSIVE' , 9, 'ETC_FTP_PATH' , 10, 'ETC_MAIN_CD' , 11, 'ETC_GUBUN_CD' , 12, 'ETC_STOR_CD' ) AS FLAG_NM ,
           DECODE(LEVEL, 1, ST.FTP_PASSIVE , 2, ST.KORAIL_APPR_YN , 3, ST.ETC_IF_DIV , 4, ST.ETC_FTP_IP , 5, ST.ETC_FTP_PORT , 6, ST.ETC_FTP_ID , 7, ST.ETC_FTP_PW , 8, ST.ETC_FTP_PASSIVE , 9, ST.ETC_FTP_PATH , 10, ST.ETC_MAIN_CD , 11, ST.ETC_GUBUN_CD , 12, ST.ETC_STOR_CD ) AS FLAG_VAL
      FROM (SELECT ST.FTP_PASSIVE ,
                   ST.KORAIL_APPR_YN ,
                   ST.ETC_IF_DIV ,
                   ST.ETC_FTP_IP ,
                   ST.ETC_FTP_PORT ,
                   ST.ETC_FTP_ID ,
                   ST.ETC_FTP_PW ,
                   ST.ETC_FTP_PASSIVE ,
                   ST.ETC_FTP_PATH ,
                   ST.ETC_MAIN_CD ,
                   ST.ETC_GUBUN_CD ,
                   ST.ETC_STOR_CD
              FROM STORE_SETUP ST,
                   STORE S
             WHERE S.COMP_CD  = P_COMP_CD
               AND S.BRAND_CD = P_BRAND_CD
               AND S.STOR_CD  = P_STOR_CD
               AND S.COMP_CD  = ST.COMP_CD(+)
               AND S.BRAND_CD = ST.BRAND_CD(+)
               AND S.STOR_CD  = ST.STOR_CD(+)
           ) ST CONNECT BY LEVEL < 13
          UNION ALL
      SELECT 'SHOPINFO' AS IF_FLAG ,
             'BRANDGB' AS IF_ID ,
             '' AS IF_PW
        FROM BRAND
       WHERE COMP_CD  = P_COMP_CD
         AND BRAND_CD = P_BRAND_CD ;
      anRetVal := 1 ;
      asRetMsg := 'OK';
  Exception
  When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
  END GET_MASTER_61 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (점별 매입처 )
  -- Ref. Table        : STORE_PURCHASE
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_62 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT STOR_CD      STOR_CD     -- 점포코드
         , PURCHASE_CD  PURCHASE_CD -- 매입처코드
         , PURCHASE_NM  PURCHASE_NM -- 매입처명
         , BUSI_NM      BUSI_NM -- 사업자명
         , TEL_NO       TEL_NO  -- 전화번호
         , ADDR         ADDR    -- 주소
         , ADDR2        ADDR2   -- 주소2
         , USE_YN       USE_YN
      FROM STORE_PURCHASE
     WHERE COMP_CD  = P_COMP_CD
       AND STOR_CD = P_STOR_CD
       AND UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_62 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (사용자별 프로그램 권한)
  -- Ref. Table        : POS_PGM_AUTH
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_63 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    WITH S_COMMON AS (
      SELECT CODE_CD PGM_ID,
             CODE_NM PGM_NM,
             VAL_C1  PGM_FG,
             VAL_C2  PWD_YN,
             REMARKS POS_PGM_ID,
             CODE_TP CODE_TP
        FROM COMMON
       WHERE COMP_CD  = P_COMP_CD
         AND CODE_TP  = '01402'
         AND USE_YN LIKE P_USE_YN
    )
    SELECT P.BRAND_CD
         , P.STOR_CD
         , P.USER_ID
         , P.PGM_ID
         , C.POS_PGM_ID
         , C.PGM_NM
         , C.PGM_FG
         , C.PWD_YN
         , P.USE_YN
         , P.UPD_DT
      FROM POS_PGM_AUTH P,
           S_COMMON     C
     WHERE P.PGM_ID   = C.PGM_ID
       AND P.COMP_CD  = P_COMP_CD
       AND P.BRAND_CD = P_BRAND_CD
       AND P.STOR_CD  = P_STOR_CD
       AND P.UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_63 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (다국어 상품)
  -- Ref. Table        : LANG_ITEM
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_71 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT ITEM_CD
         , LANGUAGE_TP
         , ITEM_NM
         , ITEM_POS_NM
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
         ,  ITEM_KDS_NM
      FROM LANG_ITEM
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_71;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (다국어 공통)
  -- Ref. Table        : LANG_COMMON
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_72 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT CODE_TP
         , CODE_CD
         , LANGUAGE_TP
         , CODE_NM
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
      FROM LANG_COMMON
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_72;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (다국어 점포)
  -- Ref. Table        : LANG_STORE
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_73 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD
         , STOR_CD
         , LANGUAGE_TP
         , STOR_NM
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
      FROM LANG_STORE
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_73;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (다국어 테이블)
  -- Ref. Table        : LANG_TABLE
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_74 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT TABLE_NM
         , COL_NM
         , LANGUAGE_TP
         , PK_COL
         , LANG_NM
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
      FROM LANG_TABLE
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_74;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (레시피)
  -- Ref. Table        : RECIPE_BRAND
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_75 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD
         , ITEM_CD
         , RCP_ITEM_CD
         , RCP_DIV
         , START_DT
         , CLOSE_DT
         , DO_YN
         , DO_UNIT
         , RCP_QTY
         , LOSS_RATE
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
      FROM RECIPE_BRAND
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_75;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (할인)
  -- Ref. Table        : DC
  --------------------------------------------------------------------------------
  --  Create Date      : 2011-07-07
  --  Modify Date      : 2011-07-07
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_84 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           DC_DIV,
           DC_NM,
           DC_POSNM,
           DC_GRPCD,
           DC_FG,
           DC_VALUE,
           INPUT_YN,
           DC_FDATE,
           DC_TDATE,
           DC_FTIME,
           DC_TTIME,
           ORD_RANK,
           POS_DISP_YN,
           STOR_DIV,
           MEMB_DC_FG,
           DC_REMARK,
           DML_FLAG,
           DC_PURC_LMT,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER,
           CERT_FG,
           DC_CLASS,
           DC_WD_FG
      FROM DC
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_84 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (점포별 할인)
  -- Ref. Table        : DC_STORE
  --------------------------------------------------------------------------------
  --  Create Date      : 2011-07-07
  --  Modify Date      : 2011-07-07
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_85 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           STOR_CD,
           DC_SEQ,
           DC_DIV,
           ORD_RANK,
           DML_FLAG,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER
      FROM DC_STORE
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND STOR_CD     = P_STOR_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS')
     ORDER BY UPD_DT DESC, DML_FLAG ASC;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_85 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (할인 대상상품)
  -- Ref. Table        : DC_ITEM
  --------------------------------------------------------------------------------
  --  Create Date      : 2013-09-25
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_86 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT DI.BRAND_CD,
           DI.DC_DIV,
           DI.GRP_SEQ,
           DI.ITEM_SEQ,
           DI.ITEM_CD,
           DI.PURC_QTY,
           DI.VAN_ITEM_CD,
           DI.VAN_SALE_PRC,
           DI.USE_YN,
           TO_CHAR(DI.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           DI.INST_USER,
           TO_CHAR(DI.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           DI.UPD_USER,
           DI.DC_FG,
           DI.DC_VALUE
      FROM DC_ITEM      DI
         , (
              SELECT COMP_CD
                   , ITEM_CD
                FROM ITEM_CHAIN
               WHERE COMP_CD    = P_COMP_CD
                 AND BRAND_CD   = P_BRAND_CD
                 AND STOR_TP    = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = P_COMP_CD AND BRAND_CD = P_BRAND_CD AND STOR_CD = P_STOR_CD )
               GROUP BY COMP_CD, ITEM_CD
           )            I 
     WHERE DI.COMP_CD  = I.COMP_CD
       AND DI.ITEM_CD  = I.ITEM_CD
       AND DI.COMP_CD  = P_COMP_CD
       AND DI.BRAND_CD IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(DI.UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_86 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (할인 사은품)
  -- Ref. Table        : DC_GIFT
  --------------------------------------------------------------------------------
  --  Create Date      : 2013-09-25
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_87 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           DC_DIV,
           GRP_SEQ,
           GIFT_SEQ,
           ITEM_CD,
           GIFT_QTY,
           USE_YN,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER
      FROM DC_GIFT
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_87 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (B2B)
  -- Ref. Table        : STORE(STOR_TP='50')
  --------------------------------------------------------------------------------
  --  Create Date      : 2013-09-25
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_88 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           STOR_CD,
           STOR_NM,
           BUSI_NO,
           USE_YN,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER,
           NVL((SELECT B2B_DC_RATE FROM STORE_SETUP B WHERE B.BRAND_CD = A.BRAND_CD AND B.STOR_CD = A.STOR_CD), 0) B2B_DC_RATE,
           TEL_NO
      FROM STORE A
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    = P_BRAND_CD
       AND STOR_TP     = '50' -- [50:B2B]
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_88 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (할인대상 요일)
  -- Ref. Table        : DC_WEEK
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-01-22
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_89 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           DC_DIV,
           WEEK_DAY,
           START_TM,
           CLOSE_TM,
           USE_YN,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER
      FROM DC_WEEK
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_89 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       ( SYSDATE 리턴 )
  -- Ref. Table        :
  --------------------------------------------------------------------------------
  --  Create Date      : 2011-02-21
  --  Modify Date      : 2011-02-21
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_90 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
    lsCurrDt VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
  BEGIN
    INSERT INTO ERR_LOG_IF_POS
           ( 
             COMP_CD,
             JOB_DATE,
             JOB_SEQ_NO,
             STOR_CD,
             JOB_TIME,
             JOB_NAME,
             JOB_MESSAGE
           ) 
    VALUES
           ( 
             P_COMP_CD,
             TO_CHAR(SYSDATE, 'YYYYMMDD'),
             SQ_ERR_LOG_IF_POS.NEXTVAL,
             P_STOR_CD,
             TO_CHAR(SYSDATE, 'HH24MISS'),
             '90',
             '일시 : [' || lsCurrDt || ']'
           );
    Commit;

    OPEN p_cursor FOR
    SELECT lsCurrDt
      FROM DUAL;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_90 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (할인대상상품그룹)
  -- Ref. Table        : DC_ITEM_GRP
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-01-22
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_91 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           DC_DIV,
           GRP_SEQ,
           GRP_NM,
           PURC_QTY,
           GIFT_QTY,
           USE_YN,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER,
           EMP_DIV
      FROM DC_ITEM_GRP
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_91 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용       (담당자 마스터)
  -- Ref. Table        : STORE_USER
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-23
  --  Modify Date      : 2009-12-23
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_92 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN

    OPEN p_cursor FOR
        SELECT  COMP_CD     -- 회사코드
              , USER_ID     -- 사용자id
              , USER_NM     -- 사용자aud
              , BRAND_CD    -- 브랜드코드
              , DEPT_CD     -- 부서코드
              , TEAM_CD     -- 팀코드
              , POSITION_CD -- 직급
              , USER_DIV    -- 직책
              , MNG_CARD_ID -- 출퇴근 카드번호
              , LANGUAGE_TP -- 언어코드
              , USE_YN      -- 사용유무
              , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- 수정일시
        FROM    HQ_USER
        WHERE   COMP_CD   = P_COMP_CD
        AND     UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
        AND     USE_YN LIKE P_USE_YN;

    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_92 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (B2B DC ITEM)
  -- Ref. Table        : ITEM_B2B_DC_HIS
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-09-16
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_A0 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  BRAND_CD
              , STOR_CD
              , ITEM_CD
              , START_DT
              , CLOSE_DT
              , DC_FG
              , DC_AMT
              , DC_RATE
              , USE_YN
              , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , INST_USER
              , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
              , UPD_USER
          FROM  ITEM_B2B_DC_HIS
         WHERE  BRAND_CD    = P_BRAND_CD
           AND  P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_A0;

  PROCEDURE GET_MASTER_A1 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  BRAND_CD
              , ITEM_CD
              , SEQ
              , PERIOD_DIV
              , PERIOD_DAY
              , PERIOD_HOUR
              , PERIOD_MIMUTE
              , SORT_ORDER
              , USE_YN
          FROM  ITEM_STOCK_PERIOD
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  USE_YN LIKE P_USE_YN
           AND  P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_A1;

  PROCEDURE GET_MASTER_A2 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
            SELECT  I1.BRAND_CD                         -- 영업조직
                 ,  I1.ITEM_CD                          -- 상품코드
                 ,  I1.ITEM_POS_NM                      -- 상품명(포스)
                 ,  NVL(I1.SALE_START_DT, TO_CHAR(SYSDATE, 'YYYYMMDD')) AS SALE_START_DT    -- 판매개시일
                 ,  NVL(I1.SALE_CLOSE_DT, '99991231')                   AS SALE_CLOSE_DT    -- 판매종료일
                 ,  I1.L_CLASS_CD                       -- 대분류 코드
                 ,  I1.M_CLASS_CD                       -- 중분류 코드
                 ,  I1.S_CLASS_CD                       -- 소분류 코드
                 ,  ''          AS FLAVOR_DIV           -- 플레이버관리구분 - 완성, 투입
                 ,  '0'         AS SALE_AMT             -- 판매가
                 ,  'Y'         AS DC_YN                -- 할인 가능 여부 => Y : 할인가능,  N : 할인불가
                 ,  '0'         AS SALE_DC_DIV          -- 할인 적용 구분     => 0:정상, 1:판매가 미정의, 2:점포변경
                 ,  '0'         AS SALE_DC_PRC          -- 할인금액           => 세트조합 후 판매가 결정이 되면 할인금액 적용
                 ,  'N'         AS SALE_VAT_YN          -- 판매 과세구분      => 공통(00055) [Y:과세, N:면세]
                 ,  'N'         AS SALE_VAT_RULE        -- 판매 VAT 관리 룰   => 공통(00850) [1:부가세포함, 2:부가세미포함] -> 계산방식
                 ,  0           AS SALE_VAT_IN_RATE     -- 테이크인 판매 VAT율
                 ,  0           AS SALE_VAT_OUT_RATE    -- 테이크아웃 판매 VAT율
                 ,  'N'         AS SALE_SVC_YN          -- 판매 서비스 관리 구분
                 ,  ''          AS SALE_SVC_RULE        -- 판매 봉사료 설정
                 ,  0           AS SALE_SVC_RATE        -- 판매 서비스 율
                 ,  ''          AS SET_GRP              -- 세트 조합 그룹    => 공통(00035)
                 ,  '0'         AS SET_DIV              -- SET 조합 구분     => 공통(01100) [0:관계없음, 1:SET 상품 , 2:SET 투입상품]
                 ,  'N'         AS TODAY_COFFEE_YN      -- 오늘의 커피여부(폴바셋)
                 ,  '0'         AS SUB_ITEM_DIV         -- 부가/옵션관리     => 공통(00050) [0:관리안함, 1:부가상품, 2:옵션상품, 3:부가/옵션상품]
                 ,  0           AS FLAVOR_QTY           -- 플레이버 총 중량
                 ,  0           AS STOCK_QTY            -- 플레이버상품 선택 수
                 ,  0           AS EVENT_AMT            -- [POS] 현재 쓰지 않으나 0으로 넣는다
                 ,  'N'         AS EVENT_DIV            -- [POS] 현재 쓰지 않으나 'N'으로 넣는다
                 ,  'N'         AS POINT_YN             -- 포인트 적립여부[YN]
                 ,  ''          AS O_ITEM_CD            -- 인천공항메뉴
                 ,  'N'         AS OPEN_ITEM_YN         -- 오픈상품여부
                 ,  '1'         AS DISPOSABLE_DIV       -- 일회용품구분 => 공통(01325) [1:상품, 2:일회용품(포장지)]
                 ,  ''          AS PRT_NO               -- 프린터번호
                 ,  I1.USE_YN   AS USE_YN               -- 사용 여부
                 ,  ''          AS BAR_CODE             -- 바코드 (일단, 한상품에 대해서는 무조건 MAX(BAR_CODE)값을 넘겨준다)
                 ,  ''          AS ALL_PRT_NO           -- 상품별 사용할 프린터 번호  => ex) 1^2^3^5
                 ,  'N'         AS AUTO_POPUP_YN        -- POS에서 상품선택시 팝업창 뛰우기 여부 (부가상품 일때)
                 ,  'N'         AS EXT_YN               -- 부가상품 여부 => [Y:부가상품선택, N:부상품아님]
                 ,  'N'         AS PARENT_ITEM_YN       -- 부모상품 여부
                 ,  I1.ORD_SALE_DIV                     -- 주문/판매구분
                 ,  I1.ITEM_KDS_NM
                 ,  I1.SAV_MLG_YN
              FROM  ITEM_CHAIN      I1
                 ,  (
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  C_ITEM_CD   AS ITEM_CD
                          FROM  RECIPE_BRAND_FOOD
                         WHERE  COMP_CD     = P_COMP_CD
                           AND  BRAND_CD    = P_BRAND_CD
                           AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                        UNION ALL
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  ITEM_CD
                          FROM  STORE_ITEM_PRT_MULTI
                         WHERE  COMP_CD     = P_COMP_CD
                           AND  BRAND_CD    = P_BRAND_CD
                           AND  STOR_CD     = P_STOR_CD
                           AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                        UNION ALL
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  ITEM_CD
                          FROM  ITEM_STOCK_PERIOD
                         WHERE  COMP_CD     = P_COMP_CD
                           AND  BRAND_CD    = P_BRAND_CD
                           AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                        UNION ALL
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  ITEM_CD
                          FROM  ITEM_CHAIN
                         WHERE  COMP_CD     = P_COMP_CD
                           AND  BRAND_CD    = P_BRAND_CD
                           AND  STOR_TP     = (
                                                SELECT  STOR_TP
                                                  FROM  STORE
                                                 WHERE  COMP_CD     = P_COMP_CD
                                                   AND  BRAND_CD    = P_BRAND_CD
                                                   AND  STOR_CD     = P_STOR_CD
                                               )
                           AND  ORD_SALE_DIV IN ('1', '4')
                           AND  USE_YN   LIKE P_USE_YN     
                           AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    )               I2
             WHERE  I1.COMP_CD  = I2.COMP_CD
               AND  I1.BRAND_CD = I2.BRAND_CD
               AND  I1.ITEM_CD  = I2.ITEM_CD
               AND  I1.COMP_CD  = P_COMP_CD
               AND  I1.BRAND_CD = P_BRAND_CD
               AND  I1.STOR_TP  = (
                                    SELECT  STOR_TP
                                      FROM  STORE
                                     WHERE  COMP_CD     = P_COMP_CD
                                       AND  BRAND_CD    = P_BRAND_CD
                                       AND  STOR_CD     = P_STOR_CD
                                  )
               AND  I1.ORD_SALE_DIV IN ('1', '4')
               AND  I1.USE_YN   LIKE P_USE_YN
               AND  P_DOWN_DTM <= TO_CHAR(I1.UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_A2;

  PROCEDURE GET_MASTER_A3 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  R.BRAND_CD
             ,  R.P_ITEM_CD
             ,  R.C_ITEM_CD
             ,  R.START_DT
             ,  R.CLOSE_DT
             ,  NVL(R.RCP_QTY, R.DO_QTY)  AS DO_QTY
             ,  R.SORT_SEQ
             ,  R.USE_YN
             ,  R.DISP_QTY
          FROM  RECIPE_BRAND_FOOD   R
             ,  ITEM_CHAIN          I
         WHERE  R.COMP_CD       = I.COMP_CD
           AND  R.BRAND_CD      = I.BRAND_CD
           AND  R.P_ITEM_CD     = I.ITEM_CD
           AND  I.STOR_TP       = (
                                    SELECT  STOR_TP
                                      FROM  STORE
                                     WHERE  COMP_CD     = P_COMP_CD
                                       AND  BRAND_CD    = P_BRAND_CD
                                       AND  STOR_CD     = P_STOR_CD
                                  )
           AND  R.COMP_CD       = P_COMP_CD
           AND  R.BRAND_CD      = P_BRAND_CD
           AND  I.RECIPE_DIV    = '1'
           AND  R.USE_YN        LIKE P_USE_YN
           AND  P_DOWN_DTM     <= TO_CHAR(R.UPD_DT, 'YYYYMMDDHH24MISS')
       CONNECT  BY R.P_ITEM_CD  = PRIOR R.C_ITEM_CD;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_A3;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]프로그램 마스터
  -- Ref. Table         : CS_PROGRAM
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B0 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  PROGRAM_NM
             ,  PROGRAM_DIV
             ,  PGM_ITEM_CD
             ,  BASE_USE_TM
             ,  ADD_AMT_YN
             ,  ADD_AMT_TM
             ,  ADD_EXC_TM
             ,  ADD_ITEM_CD
             ,  GDN_AMT_YN
             ,  GDN_CNT
             ,  GDN_ITEM_CD
             ,  ORG_PMN_YN
             ,  ORG_MIN_CNT
             ,  ORG_ITEM_CD
             ,  PGM_MATL_YN
             ,  DD_APP_YN
             ,  PGM_TM_YN
             ,  BRAND_CD
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
             ,  REF_PROGRAM_ID
             ,  MATL_POP_YN
          FROM  CS_PROGRAM
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B0;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]프로그램 대상 교구
  -- Ref. Table         : CS_PROGRAM_MATL
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B1 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  ITEM_CD
             ,  ENTRY_DIV
             ,  CHARGE_YN
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_PROGRAM_MATL
         WHERE  COMP_CD     = P_COMP_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B1;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]프로그램 단체고객수 구간 할인율
  -- Ref. Table         : CS_PROGRAM_ORG
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B2 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  BRAND_CD
             ,  STOR_CD
             ,  ORG_SEQ
             ,  START_CNT
             ,  CLOSE_CNT
             ,  DC_FG
             ,  DC_VALUE
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_PROGRAM_ORG
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  STOR_CD     = P_STOR_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B2;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]프로그램 점포설정
  -- Ref. Table         : CS_PROGRAM_STORE
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B3 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  BRAND_CD
             ,  STOR_CD
             ,  BASE_USE_TM
             ,  ADD_AMT_YN
             ,  ADD_AMT_TM
             ,  ADD_EXC_TM
             ,  GDN_AMT_YN
             ,  GDN_CNT
             ,  ORG_PMN_YN
             ,  DD_APP_YN
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
             ,  ENTRY_CNT
          FROM  CS_PROGRAM_STORE
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  STOR_CD     = P_STOR_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B3;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]프로그램 점포 운영시간
  -- Ref. Table         : CS_PROGRAM_STORE_TM
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B4 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  BRAND_CD
             ,  STOR_CD
             ,  TM_SEQ
             ,  START_TM
             ,  CLOSE_TM
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_PROGRAM_STORE_TM
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  STOR_CD     = P_STOR_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B4;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]회원권 마스터
  -- Ref. Table         : CS_MEMBERSHIP
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B5 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  M.PROGRAM_ID
             ,  M.MBS_NO
             ,  M.MBS_NM
             ,  M.MBS_DIV
             ,  M.USE_DIV
             ,  M.MBS_ITEM_CD
             ,  M.CHARGE_YN
             ,  M.CERT_MONTHS
             ,  M.START_DT
             ,  M.CLOSE_DT
             ,  M.BASE_CALC_TM
             ,  M.BASE_OFFER_TM
             ,  M.BASE_OFFER_CNT
             ,  M.BASE_OFFER_AMT
             ,  M.BASE_OFFER_MCNT
             ,  M.ITEM_DIV
             ,  M.BRAND_CD
             ,  CASE WHEN M.USE_YN = 'N' OR MS.USE_YN = 'N' THEN 'N'
                     ELSE 'Y'
                END                                         AS USE_YN
             ,  TO_CHAR(M.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  M.INST_USER
             ,  TO_CHAR(M.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  M.UPD_USER
          FROM  CS_MEMBERSHIP           M
             ,  CS_MEMBERSHIP_STORE     MS
         WHERE  M.COMP_CD       = MS.COMP_CD
           AND  M.PROGRAM_ID    = MS.PROGRAM_ID
           AND  M.MBS_NO        = MS.MBS_NO    
           AND  M.COMP_CD       = P_COMP_CD
           AND  M.BRAND_CD      = P_BRAND_CD
           AND  MS.USE_BRAND_CD = P_BRAND_CD
           AND  MS.USE_STOR_CD  = P_STOR_CD
           AND  (
                    TO_CHAR(M.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(MS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                )
           AND  MS.USE_YN       LIKE P_USE_YN;           

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B5;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]입장옵션 마스터
  -- Ref. Table         : CS_OPTION
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B6 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  OPTION_CD
             ,  OPTION_NM
             ,  OPT_ITEM_CD
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_OPTION
         WHERE  COMP_CD     = P_COMP_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B6;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]입장옵션 점포할당 마스터
  -- Ref. Table         : CS_OPTION_STORE
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B7 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  OPTION_CD
             ,  BRAND_CD
             ,  STOR_CD
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_OPTION_STORE
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  STOR_CD     = P_STOR_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B7;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]회원권 대상상품 마스터
  -- Ref. Table         : CS_MEMBERSHIP_ITEM
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B8 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  MI.PROGRAM_ID
             ,  MI.MBS_NO
             ,  MI.ITEM_CD
             ,  MI.USE_YN
             ,  TO_CHAR(MI.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  MI.INST_USER
             ,  TO_CHAR(MI.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  MI.UPD_USER
          FROM  CS_MEMBERSHIP_ITEM  MI
             ,  CS_MEMBERSHIP       M
         WHERE  MI.COMP_CD      = M.COMP_CD
           AND  MI.PROGRAM_ID   = M.PROGRAM_ID
           AND  MI.MBS_NO       = M.MBS_NO
           AND  MI.COMP_CD      = P_COMP_CD
           AND  M.BRAND_CD      = P_BRAND_CD
           AND  TO_CHAR(MI.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  MI.USE_YN       LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B8;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]SMS컨텐츠
  -- Ref. Table         : CS_CONTENT
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-07-01
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B9 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CONTENT_SEQ
             ,  SUBJECT
             ,  CONTENT
             ,  CONTENT_DIV
             ,  CONTENT_FG
             ,  USE_YN
          FROM  CS_CONTENT
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN
           AND  CONTENT_FG  IN ('10', '3');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B9;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]쿠폰마스터
  -- Ref. Table         : M_COUPON_MST
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-11-10
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C0 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CM.COUPON_CD
             ,  CM.COUPON_NM
             ,  CM.ISSUE_DT
             ,  CM.COUPON_DIV
             ,  CM.CERT_YN
             ,  CM.DEAL_ID
             ,  CM.COUPON_MSG
             ,  CM.COUPON_RMK
             ,  CM.START_DT
             ,  CM.CLOSE_DT
             ,  CM.CUST_CNT
             ,  CM.COUPON_STAT
             ,  CM.CONF_DT
             ,  CM.USE_YN
             ,  CM.UPD_DT
             ,  CM.INST_DT
          FROM  M_COUPON_MST    CM
             ,  M_COUPON_STORE  CS
         WHERE  CM.COMP_CD  = CS.COMP_CD
           AND  CM.COUPON_CD= CS.COUPON_CD
           AND  CM.COMP_CD  = P_COMP_CD
           AND  CM.COUPON_STAT = '2'
           AND  CS.BRAND_CD = P_BRAND_CD
           AND  CS.STOR_CD  = P_STOR_CD
           AND  (
                    TO_CHAR(CM.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(CS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                ) 
           AND  CM.USE_YN   LIKE P_USE_YN
           AND  CS.USE_YN   LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C0;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]쿠폰대상매장
  -- Ref. Table         : M_COUPON_STORE
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-11-10
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C1 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CS.COUPON_CD
             ,  CS.BRAND_CD
             ,  CS.STOR_CD
             ,  CS.STOR_ID
             ,  CS.USE_YN
             ,  CS.UPD_DT
             ,  CS.INST_DT
          FROM  M_COUPON_MST    CM
             ,  M_COUPON_STORE  CS
         WHERE  CM.COMP_CD  = CS.COMP_CD
           AND  CM.COUPON_CD= CS.COUPON_CD
           AND  CM.COMP_CD  = P_COMP_CD
           AND  CM.COUPON_STAT = '2'
           AND  CS.BRAND_CD = P_BRAND_CD
           AND  CS.STOR_CD  = P_STOR_CD
           AND  (
                    TO_CHAR(CM.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(CS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                )
           AND  CM.USE_YN   LIKE P_USE_YN
           AND  CS.USE_YN   LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C1;

  --------------------------------------------------------------------------------
  -- Description        : [서비스]쿠폰대상상품
  -- Ref. Table         : M_COUPON_ITEM
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-11-10
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C2 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CI.COUPON_CD
             ,  CI.ITEM_CD
             ,  CI.ITEM_ID
             ,  CI.SALE_AMT
             ,  CI.USE_AMT
             ,  CI.USE_YN
             ,  CI.UPD_DT
             ,  CI.INST_DT
          FROM  M_COUPON_MST    CM
             ,  M_COUPON_STORE  CS
             ,  M_COUPON_ITEM   CI
         WHERE  CM.COMP_CD  = CS.COMP_CD
           AND  CM.COUPON_CD= CS.COUPON_CD
           AND  CM.COMP_CD  = CI.COMP_CD
           AND  CM.COUPON_CD= CI.COUPON_CD
           AND  CM.COMP_CD  = P_COMP_CD
           AND  CM.COUPON_STAT = '2'
           AND  CS.BRAND_CD = P_BRAND_CD
           AND  CS.STOR_CD  = P_STOR_CD
           AND  (
                    TO_CHAR(CM.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(CS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(CI.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                ) 
           AND  CM.USE_YN   LIKE P_USE_YN
           AND  CS.USE_YN   LIKE P_USE_YN
           AND  CI.USE_YN   LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C2;

  --------------------------------------------------------------------------------
  -- Description        : [특수매장]비용코드마스터
  -- Ref. Table         : COST_GRP_DTL
  --------------------------------------------------------------------------------
  --  Create Date       :
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C3 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  GS.COST_GRP_CD
             ,  CG.COST_GRP_NM
             ,  GD.COST_DIV
             ,  CM.COST_NM
             ,  GS.USE_YN
             ,  GS.UPD_DT
             ,  GS.INST_DT
          FROM  COST_MST        CM
             ,  COST_GRP        CG
             ,  COST_GRP_STORE  GS
             ,  COST_GRP_DTL    GD
         WHERE  GS.COMP_CD     = CG.COMP_CD
           AND  GS.BRAND_CD    = CG.BRAND_CD
           AND  GS.COST_GRP_CD = CG.COST_GRP_CD
           AND  GS.COMP_CD     = GD.COMP_CD
           AND  GS.BRAND_CD    = GD.BRAND_CD
           AND  GS.COST_GRP_CD = GD.COST_GRP_CD
           AND  GD.COMP_CD     = CM.COMP_CD
           AND  GD.BRAND_CD    = CM.BRAND_CD
           AND  GD.COST_DIV    = CM.COST_DIV
           AND  GS.COMP_CD     = P_COMP_CD 
           AND  GS.BRAND_CD    = P_BRAND_CD
           AND  GS.STOR_CD     = P_STOR_CD
           AND (
                TO_CHAR(GD.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                OR
                TO_CHAR(GS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
               ) 
           AND  GD.USE_YN   LIKE P_USE_YN
           AND  GS.USE_YN   LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C3;

  --------------------------------------------------------------------------------
  -- Description        : [결제수단] 매장별 결제수단 정보
  -- Ref. Table         : PAY_GRP_DTL
  --------------------------------------------------------------------------------
  --  Create Date       :
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C4 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  GS.PAY_GRP_CD
             ,  PG.PAY_GRP_NM
             ,  GD.PAY_DIV
             ,  PM.PAY_NM
             ,  PM.POINT_ADD_YN
             ,  PM.CASH_BILL_YN
             ,  PM.CHANGE_YN
             ,  PM.DISPLAY_YN
             ,  PM.CONST_DIV
             ,  PM.CONST_VAL
             ,  GS.USE_YN
             ,  GS.UPD_DT
             ,  GS.INST_DT
          FROM  PAY_MST        PM
             ,  PAY_GRP        PG
             ,  PAY_GRP_STORE  GS
             ,  PAY_GRP_DTL    GD
         WHERE  GS.COMP_CD     = PG.COMP_CD
           AND  GS.BRAND_CD    = PG.BRAND_CD
           AND  GS.PAY_GRP_CD  = PG.PAY_GRP_CD
           AND  GS.COMP_CD     = GD.COMP_CD
           AND  GS.BRAND_CD    = GD.BRAND_CD
           AND  GS.PAY_GRP_CD  = GD.PAY_GRP_CD
           AND  GD.COMP_CD     = PM.COMP_CD
           AND  GD.BRAND_CD    = PM.BRAND_CD
           AND  GD.PAY_DIV     = PM.PAY_DIV
           AND  GS.COMP_CD     = P_COMP_CD 
           AND  GS.BRAND_CD    = P_BRAND_CD
           AND  GS.STOR_CD     = P_STOR_CD
           AND (
                TO_CHAR(GD.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                OR
                TO_CHAR(GS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
               ) 
           AND  GD.USE_YN   LIKE P_USE_YN
           AND  GS.USE_YN   LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C4;

  --------------------------------------------------------------------------------
  -- Description        : 매장별디바이스정보 
  -- Ref. Table         : STORE_DEVICE
  --------------------------------------------------------------------------------
  --  Create Date       :
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C5 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  *
          FROM  (
                    SELECT  SD.BRAND_CD
                         ,  SD.STOR_CD
                         ,  SD.POS_NO
                         ,  DM.DEVICE_DIV
                         ,  DM.SORT_ORDER
                         ,  DI.DEVICE_KEY
                         ,  CASE WHEN INSTR(DI.DEVICE_KEY, '_BAUD') > 0 THEN GET_COMMON_CODE_NM(P_COMP_CD, '02195', DEVICE_VAL, 'kor')
                                 ELSE SD.DEVICE_VAL
                            END         AS DEVICE_VAL
                      FROM  DEVICE_MST      DM
                         ,  DEVICE_IF       DI
                         ,  STORE_DEVICE    SD
                     WHERE  DM.COMP_CD      = DI.COMP_CD
                       AND  DM.DEVICE_DIV   = DI.DEVICE_DIV
                       AND  DM.DEVICE_CD    = DI.DEVICE_CD
                       AND  DI.COMP_CD      = SD.COMP_CD
                       AND  DI.DEVICE_DIV   = SD.DEVICE_DIV
                       AND  DI.DEVICE_CD    = SD.DEVICE_CD
                       AND  DI.DEVICE_KEY   = SD.DEVICE_KEY
                       AND  DI.COMP_CD      = P_COMP_CD
                       AND  SD.BRAND_CD     = P_BRAND_CD
                       AND  SD.STOR_CD      = P_STOR_CD
                       AND  DI.DEVICE_DIV   IN ('1', '2')
                       AND  DI.USE_YN       = 'Y'
                    UNION ALL
                    SELECT  BRAND_CD
                         ,  STOR_CD
                         ,  POS_NO
                         ,  '1'                 AS DEVICE_DIV
                         ,  2                   AS SORT_ORDER
                         ,  'PRINT_TOP_IMAGE'   AS DEVICE_KEY
                         ,  TOP_IMAGE_YN        AS DEVICE_VAL
                      FROM  STORE_POS_MST
                     WHERE  COMP_CD      = P_COMP_CD
                       AND  BRAND_CD     = P_BRAND_CD
                       AND  STOR_CD      = P_STOR_CD
                )       
         ORDER  BY POS_NO, DEVICE_DIV, SORT_ORDER, DEVICE_KEY DESC;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C5;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (프로모션 마스터)
  -- Ref. Table        : C_PROMOTION_MST
  --------------------------------------------------------------------------------
  --  Create Date      : 2017-12-11
  --  Modify Date      :
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C6 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  COMP_CD
              , PRMT_ID
              , PRMT_NM
--              , PRMT_CLASS
              , PRMT_TYPE
              , PRMT_DIV
              , CUST_DIV
              , PAY_DIV
              , APPL_DIV
              , LVL_CD
              , START_DT
              , CLOSE_DT
              , CUST_CNT
              , STOR_CUST_CNT
              , DAY_LIMIT_CNT
              , BILL_AMT
              , BILL_AMT_DIV
              , BILL_CUST_CNT
              , ITEM_QTY1
              , ITEM_QTY2
              , BNF_FG
              , BNF_VALUE
              , MEMB_YN
              , SUB_PRMT_ID
              , EXPIRE_DIV
              , EXPIRE_VALUE
              , BRAND_CD
              , DC_DIV
              , PRMT_STAT
              , USE_YN
              , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , INST_USER
              , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
        FROM    C_PROMOTION_MST
        WHERE   COMP_CD     = P_COMP_CD
        AND     BRAND_CD    = P_BRAND_CD
        AND     P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');

        anRetVal := 1;
        asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C6;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (프로모션마스터_매장)
  -- Ref. Table        : DC_STORE
  --------------------------------------------------------------------------------
  --  Create Date      : 2017-12-11
  --  Modify Date      :
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C7 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  COMP_CD
              , PRMT_ID
              , BRAND_CD
              , STOR_CD
              , USE_YN
              , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , INST_USER
              , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
              , UPD_USER
        FROM    C_PROMOTION_STORE
        WHERE   COMP_CD     = P_COMP_CD
        AND     P_BRAND_CD  = P_BRAND_CD
        AND     STOR_CD     = P_STOR_CD
        AND     P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS')
        ORDER BY 
                UPD_DT DESC;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C7 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (프로모션 요일)
  -- Ref. Table        : C_PROMOTION_WEEK
  --------------------------------------------------------------------------------
  --  Create Date      : 2017-12-11
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C8 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CPW.COMP_CD
              , CPW.PRMT_ID
              , CPW.WEEK_DAY
              , CPW.START_TM
              , CPW.CLOSE_TM
              , CPW.USE_YN
              , TO_CHAR(CPW.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , CPW.INST_USER
              , TO_CHAR(CPW.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
              , CPW.UPD_USER
        FROM    C_PROMOTION_WEEK    CPW
              , C_PROMOTION_MST     CPM
        WHERE   CPW.COMP_CD  = CPM.COMP_CD
        AND     CPW.PRMT_ID  = CPM.PRMT_ID
        AND     CPM.COMP_CD  = P_COMP_CD
        AND     CPM.BRAND_CD = P_BRAND_CD
        AND     P_DOWN_DTM  <= TO_CHAR(CPW.UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C8 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (프로모션 조건 대상상품)
  -- Ref. Table        : C_PROMOTION_ITEM_COND
  --------------------------------------------------------------------------------
  --  Create Date      : 2013-09-25
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C9 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CP.COMP_CD
              , CP.PRMT_ID
              , CP.ITEM_COND
              , CP.BRAND_CD
              , CP.ITEM_CD
              , CP.ITEM_QTY
              , CP.USE_YN
              , TO_CHAR(CP.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , CP.INST_USER
              , TO_CHAR(CP.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
        FROM    C_PROMOTION_ITEM_COND CP
              ,(
                SELECT  COMP_CD
                      , BRAND_CD
                      , ITEM_CD
                FROM    ITEM_CHAIN
                WHERE   COMP_CD    = P_COMP_CD
                AND     BRAND_CD   = P_BRAND_CD
                AND     STOR_TP    = (SELECT STOR_TP FROM STORE WHERE COMP_CD = P_COMP_CD AND BRAND_CD = P_BRAND_CD AND STOR_CD = P_STOR_CD)
               ) IC   
        WHERE   CP.COMP_CD  = IC.COMP_CD
        AND     CP.BRAND_CD = IC.BRAND_CD
        AND     CP.ITEM_CD  = IC.ITEM_CD
        AND     CP.COMP_CD  = P_COMP_CD
        AND     CP.BRAND_CD = P_BRAND_CD
        AND     P_DOWN_DTM <= TO_CHAR(CP.UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C9 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (프로모션 적용 상품)
  -- Ref. Table        : C_PROMOTION_ITEM
  --------------------------------------------------------------------------------
  --  Create Date      : 2017-12-11
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_D0 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CP.COMP_CD
              , CP.PRMT_ID
              , CP.BRAND_CD
              , CP.ITEM_CD
              , CP.BNF_FG
              , CP.BNF_VALUE
              , CP.GIVE_REWARD
              , CP.MEMB_YN
              , CP.USE_YN
              , TO_CHAR(CP.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , CP.INST_USER
              , TO_CHAR(CP.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
              , CP.UPD_USER
        FROM    C_PROMOTION_ITEM CP
              ,(
                SELECT  COMP_CD
                      , BRAND_CD
                      , ITEM_CD
                FROM    ITEM_CHAIN
                WHERE   COMP_CD    = P_COMP_CD
                AND     BRAND_CD   = P_BRAND_CD
                AND     STOR_TP    = (SELECT STOR_TP FROM STORE WHERE COMP_CD = P_COMP_CD AND BRAND_CD = P_BRAND_CD AND STOR_CD = P_STOR_CD)
               ) IC   
        WHERE   CP.COMP_CD  = IC.COMP_CD
        AND     CP.BRAND_CD = IC.BRAND_CD
        AND     CP.ITEM_CD  = IC.ITEM_CD
        AND     CP.COMP_CD  = P_COMP_CD
        AND     CP.BRAND_CD = P_BRAND_CD
        AND     P_DOWN_DTM <= TO_CHAR(CP.UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_D0 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (프로모션 영수증 설정)
  -- Ref. Table        : C_PROMOTION_BILL
  --------------------------------------------------------------------------------
  --  Create Date      : 2017-12-11
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_D1 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PB.COMP_CD
              , PB.PRMT_ID
              , PB.PRT_TYPE1
              , PB.PRT_TYPE2
              , PB.PRT_TYPE3
              , PB.PRT_TYPE4
              , PB.PRT_TYPE5
              , PB.USE_YN
              , TO_CHAR(PB.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , PB.INST_USER
              , TO_CHAR(PB.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
        FROM    C_PROMOTION_BILL PB
              , C_PROMOTION_MST  PM
        WHERE   PB.COMP_CD  = PM.COMP_CD
        AND     PB.PRMT_ID  = PM.PRMT_ID
        AND     PM.COMP_CD  = P_COMP_CD
        AND     PM.BRAND_CD = P_BRAND_CD
        AND     P_DOWN_DTM <= TO_CHAR(PB.UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_D1 ;

  --------------------------------------------------------------------------------
  --  Description      : POS마스터 수신용 (프로모션 영수증 메시지)
  -- Ref. Table        : C_PROMOTION_BILL_MSG
  --------------------------------------------------------------------------------
  --  Create Date      : 2017-12-11
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_D2 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PB.COMP_CD
              , PB.PRMT_ID
              , PB.BILL_MSG_DIV
              , PB.BILL_MSG
              , PB.USE_YN
              , TO_CHAR(PB.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , PB.INST_USER
              , TO_CHAR(PB.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
        FROM    C_PROMOTION_BILL_MSG PB
              , C_PROMOTION_MST      PM
        WHERE   PB.COMP_CD  = PM.COMP_CD
        AND     PB.PRMT_ID  = PM.PRMT_ID
        AND     PM.COMP_CD  = P_COMP_CD
        AND     PM.BRAND_CD = P_BRAND_CD
        AND     P_DOWN_DTM <= TO_CHAR(PB.UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_D2 ;

  --------------------------------------------------------------------------------
  -- Description        : [제휴사 결제] 제휴사 결제 정보(식권, 상품권)
  -- Ref. Table         : PAY_GRP_DTL
  --------------------------------------------------------------------------------
  --  Create Date       :
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_D3 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  GS.BRAND_CD
             ,  GS.STOR_CD
             ,  PM.PAY_DIV
             ,  GS.AFF_CD
             ,  PG.AFF_NM
             ,  GD.PAY_TP
             ,  PM.PAY_TP_NM
             ,  PM.PRICE
             ,  PM.CHANGE_YN
             ,  PM.CHANGE_STD
             ,  GS.USE_YN
             ,  GS.UPD_DT
             ,  GS.INST_DT
          FROM  PAY_ADD_MST        PM
             ,  PAY_ADD_AFF        PG
             ,  PAY_ADD_AFF_STORE  GS
             ,  PAY_ADD_AFF_DTL    GD
         WHERE  GS.COMP_CD     = PG.COMP_CD
           AND  GS.BRAND_CD    = PG.BRAND_CD
           AND  GS.PAY_DIV     = PG.PAY_DIV
           AND  GS.AFF_CD      = PG.AFF_CD
           AND  GS.COMP_CD     = GD.COMP_CD
           AND  GS.BRAND_CD    = GD.BRAND_CD
           AND  GS.PAY_DIV     = GD.PAY_DIV
           AND  GS.AFF_CD      = GD.AFF_CD
           AND  GD.COMP_CD     = PM.COMP_CD
           AND  GD.BRAND_CD    = PM.BRAND_CD
           AND  GD.PAY_DIV     = PM.PAY_DIV
           AND  GD.PAY_TP      = PM.PAY_TP
           AND  GS.COMP_CD     = P_COMP_CD 
           AND  GS.BRAND_CD    = P_BRAND_CD
           AND  GS.STOR_CD     = P_STOR_CD
           AND (
                TO_CHAR(GD.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                OR
                TO_CHAR(GS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
               ) 
           AND  GD.USE_YN   LIKE P_USE_YN
           AND  GS.USE_YN   LIKE P_USE_YN;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_D3;

    --------------------------------------------------------------------------------
  --  Description      : 할인 분담율
  -- Ref. Table        : DC_ALLOT
  --------------------------------------------------------------------------------
  --  Create Date      : 2017-12-11
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_D4 (
    anRetVal OUT NUMBER,   -- 결과코드
    asRetMsg OUT VARCHAR2, -- 리턴 메시지
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  T2.COMP_CD
              , T2.BRAND_CD
              , T2.DC_DIV
              , T2.ALLOT_DIV
              , T2.ALLOT_RATE
              , T2.CALC_PST
              , T2.CALC_DIV
              , T2.DC_AMT_S
              , T2.DC_AMT_H
              , T2.USE_YN
              , TO_CHAR(T2.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , T2.INST_USER
              , TO_CHAR(T2.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
        FROM    DC           T1
              , DC_ALLOT     T2
        WHERE   T1.COMP_CD  = T2.COMP_CD
        AND     T1.BRAND_CD = T2.BRAND_CD
        AND     T1.DC_DIV   = T2.DC_DIV
        AND     T2.COMP_CD  = P_COMP_CD
        AND     T2.BRAND_CD = P_BRAND_CD
        AND     P_DOWN_DTM <= TO_CHAR(T2.UPD_DT, 'YYYYMMDDHH24MISS');

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_D4 ;

END PKG_POS_IF_GET;

/
