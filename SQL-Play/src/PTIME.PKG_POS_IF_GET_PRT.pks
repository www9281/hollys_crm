CREATE OR REPLACE PACKAGE       PKG_POS_IF_GET_PRT AS

---------------------------------------------------------------------------------------------------
--  Procedure Name   : PKG_POS_IF_GET_PRT
--  Description      : POS 자료 조회 항목   (공통코드 01400 판매포스용 메뉴를 등록 해준다)
-- asWorkDiv         : 01
--                   : 02
---------------------------------------------------------------------------------------------------
--  Create Date      : 2010-03-25
--  Create Programer : 박인수
--  Modify Date      : 2010-03-25
--  Modify Programer :
---------------------------------------------------------------------------------------------------
/*                              BRNAD  STORE     STOR_TP   FR_DT    TO_DT        작업
exec PKG_POS_IF_GET_PRT.GET_PRT('002', '0008484', '20', '20100301', '20100331', '09', :anRetVal, :asRetVal, :asRetset);
*/
P_COMP_CD        VARCHAR2(3)  := '';
P_BRAND_CD       VARCHAR2(4)  := '';
P_STOR_CD        VARCHAR2(10) := '';
P_STOR_TP        VARCHAR2(2)  := '';
P_FR_DT          VARCHAR2(8)  := '';
P_TO_DT          VARCHAR2(8)  := '';

PROCEDURE GET_PRT
                (
                   asCompCd        IN   VARCHAR2, -- 회사코드
                   asBrandCd       IN   VARCHAR2, -- 영업조직
                   asStorCd        IN   VARCHAR2, -- 점포코드
                   asStorTp        IN   VARCHAR2, -- 직가맹구분
                   asFrDt          IN   VARCHAR2, -- FROM 일자
                   asToDt          IN   VARCHAR2, -- TO   일자
                   asWorkDiv       IN   VARCHAR2, -- 다운로드 작업 구분
                   anRetVal        OUT  NUMBER  , -- 리턴 코드
                   asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_01 -- 고객클레임
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_02 -- 리더스승인내역
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_03 -- 리더스일자별실적
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_05 -- 상품별매출실적
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_06 -- 신규상품등록현황
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_07 -- 일자별기타매출실적
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_08 -- 일자별매출실적
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_09 -- 터치상품키현황
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_10 -- 판매유형별실적
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_11 -- 해피포인트사용내역
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_12 -- 해피포인트일자별실적
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_13 -- LG승인내역
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_14 -- LG일자별실적
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_15 -- 시간대별 실적
                (  anRetVal        OUT     NUMBER  , -- 결과코드
                   asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

END PKG_POS_IF_GET_PRT;

/

CREATE OR REPLACE PACKAGE BODY       PKG_POS_IF_GET_PRT AS


   PROCEDURE GET_PRT
                      (
                         asCompCd        IN   VARCHAR2, -- 회사코드
                         asBrandCd       IN   VARCHAR2, -- 영업조직
                         asStorCd        IN   VARCHAR2, -- 점포코드
                         asStorTp        IN   VARCHAR2, -- 직가맹구분
                         asFrDt          IN   VARCHAR2, -- FROM 일자
                         asToDt          IN   VARCHAR2, -- TO   일자
                         asWorkDiv       IN   VARCHAR2, -- 다운로드 작업 구분
                         anRetVal        OUT  NUMBER  , -- 리턴 코드
                         asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
                         p_cursor        OUT  rec_set.m_refcur
                      ) IS

   BEGIN
      anRetVal := 1;
      asRetMsg := '0K';
      
      P_COMP_CD   := asCompCd;
      P_BRAND_CD  := asBrandCd;
      P_STOR_CD   := asStorCd ;
      P_STOR_TP   := asStorTp ;
      P_FR_DT     := asFrDt ;
      P_TO_DT     := asToDt ;

      /*
      INSERT INTO ERR_LOG_IF_POS
                ( JOB_DATE, JOB_SEQ_NO, STOR_CD, JOB_TIME, JOB_NAME, JOB_MESSAGE )
           VALUES
                ( TO_CHAR(SYSDATE, 'YYYYMMDD'), SQ_ERR_LOG_IF_POS.NEXTVAL, asStorCd, TO_CHAR(SYSDATE, 'HH24MISS'), 'PRT_' || asWorkDiv, asRetMsg );

      Commit;
      */

      If ( asWorkDiv = '01' ) Then    -- 고객클레임
         GET_PRT_01(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '02' ) Then -- 리더스승인내역
         GET_PRT_02(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '03' ) Then -- 리더스일자별실적
         GET_PRT_03(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '05' ) Then -- 상품별매출실적
         GET_PRT_05(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '06' ) Then -- 신규상품등록현황
         GET_PRT_06(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '07' ) Then -- 일자별기타매출실적
         GET_PRT_07(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '08' ) Then -- 일자별매출실적
         GET_PRT_08(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '09' ) Then -- 판매유형별실적
         GET_PRT_09(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '10' ) Then -- 터치상품키현황
         GET_PRT_10(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '11' ) Then -- 해피포인트사용내역
         GET_PRT_11(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '12' ) Then -- 해피포인트일자별실적
         GET_PRT_12(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '13' ) Then -- LG승인내역
         GET_PRT_13(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '14' ) Then -- LG일자별실적
         GET_PRT_14(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '15' ) Then -- 시간대별 실적
         GET_PRT_15(anRetVal, asRetMsg, p_cursor  );

      Else
         anRetVal := -100;
         asRetMsg := '미 정의된 다운로드 작업 구분[' || asWorkDiv || '] 입니다.' ;
      End If;


   Exception When OTHERS Then
      anRetVal := SQLCODE ;
      asRetMsg := 'WorkDiv[' || asWorkDiv || ']' || SQLERRM(SQLCODE) ;
      INSERT INTO ERR_LOG_IF_POS
                ( JOB_DATE, JOB_SEQ_NO, STOR_CD, JOB_TIME, JOB_NAME, JOB_MESSAGE )
           VALUES
                ( TO_CHAR(SYSDATE, 'YYYYMMDD'), SQ_ERR_LOG_IF_POS.NEXTVAL, asStorCd, TO_CHAR(SYSDATE, 'HH24MISS'), asWorkDiv, asRetMsg );

      Commit;
   END GET_PRT;


   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_01
   --  Description      : 고객클레임
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_01
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  I.ITEM_POS_NM       -- 상품코드
               , R.RJT_CQTY          -- 반품확정수랼
               , R.RJT_CAMT          -- 반품확정금액 (부가세 별도)
           FROM REJECT_DT R,
                ITEM      I
          WHERE R.ITEM_CD        = I.ITEM_CD
            AND R.RJT_DT   BETWEEN P_FR_DT AND P_TO_DT
            AND R.COMP_CD        = P_COMP_CD
            AND R.BRAND_CD       = P_BRAND_CD
            AND R.STOR_CD        = P_STOR_CD
            AND R.RJT_DIV        = '6'  ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_01 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_02
   --  Description      : 리더스승인내역
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_02
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  APPR_DT || APPR_TM                       AS APPR_DTM -- 일시
               , CARD_NO                                  AS CARD_NO  -- 카드번호
               , APPR_NO                                  AS APPR_NO  -- 승인번호
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1)  AS APPR_AMT -- 승인금액
           FROM POINT_LOG
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
            AND PAY_DIV          = '63'     -- SK (리더스)
--            AND SALE_DIV         = '1'
            AND NVL(USE_YN, 'Y') = 'Y' ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_02 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_03
   --  Description      : 리더스일자별실적
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_03
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  MMDD                                      AS MMDD
               , APPR_CNT                                  AS APPR_CNT
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1)   AS APPR_AMT
               , APPR_DC  * DECODE(SALE_DIV, '1', 1, -1)   AS APPR_DC
           FROM (
                  SELECT  SUBSTR(APPR_DT, 5, 4) AS MMDD         -- 월일
                        , SALE_DIV              AS SALE_DIV   -- 판매구분 (1:정상, 2: 반품)
                        , COUNT(APPR_NO)        AS APPR_CNT   -- 건수(승인-취소)
                        , SUM(APPR_AMT)         AS APPR_AMT   -- 승인금액
                        , SUM(APPR_DC )         AS APPR_DC    -- 할인금액
                    FROM POINT_LOG
                   WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
                     AND COMP_CD          = P_COMP_CD
                     AND BRAND_CD         = P_BRAND_CD
                     AND STOR_CD          = P_STOR_CD
                     AND PAY_DIV          = '63'     -- SK (리더스)
                     AND NVL(USE_YN, 'Y') = 'Y'
                   GROUP BY  SUBSTR(APPR_DT, 5, 4)
                           , SALE_DIV
                )   ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_03 ;


   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_05
   --  Description      : 상품별매출실적
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_05
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         WITH IT AS
                   ( SELECT  I.COMP_CD, I.ITEM_CD, I.ITEM_POS_NM AS ITEM_NM
                           , I.L_CLASS_CD
                           , C.L_CLASS_NM
                       FROM (
                                SELECT  I.COMP_CD
                                     ,  I.ITEM_CD
                                     ,  I.ITEM_POS_NM
                                     ,  NVL(IC.L_CLASS_CD, I.L_CLASS_CD)    AS L_CLASS_CD
                                  FROM  ITEM_CHAIN I
                                     ,  ITEM_CLASS IC
                                 WHERE  I.COMP_CD   = IC.COMP_CD(+)
                                   AND  I.ITEM_CD   = IC.ITEM_CD(+)
                                   AND I.COMP_CD  = P_COMP_CD
                                   AND I.BRAND_CD = P_BRAND_CD
                                   AND I.STOR_TP  = P_STOR_TP
                            )           I
                          , ( SELECT * FROM ITEM_L_CLASS
                               WHERE COMP_CD      = P_COMP_CD
                                 AND ORG_CLASS_CD = '00'
                                 AND USE_YN       = 'Y'
                             )          C
                      WHERE I.COMP_CD    = C.COMP_CD
                        AND I.L_CLASS_CD = C.L_CLASS_CD
                   )
         SELECT  I.L_CLASS_CD     AS L_CLASS_CD
               , I.ITEM_CD        AS ITEM_CD
               , I.ITEM_NM        AS ITEM_NM
               , SUM(SALE_QTY)    AS SALE_QTY
               , SUM(DECODE(C.VAL_C1, 'G', T.GRD_AMT, 'T', T.SALE_AMT, T.GRD_AMT - T.VAT_AMT))    AS SALE_AMT
               , I.L_CLASS_NM     AS L_CLASS_NM
           FROM SALE_JDM   T,
                IT         I,
                (
                    SELECT  VAL_C1
                      FROM  COMMON
                     WHERE  COMP_CD = P_COMP_CD
                       AND  CODE_TP = '01435'
                       AND  CODE_CD = '200'
                ) C
          WHERE T.COMP_CD        = I.COMP_CD
            AND T.ITEM_CD        = I.ITEM_CD
            AND T.SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
            AND T.COMP_CD        = P_COMP_CD
            AND T.BRAND_CD       = P_BRAND_CD
            AND T.STOR_CD        = P_STOR_CD
          GROUP BY  I.L_CLASS_CD
                  , I.ITEM_CD
                  , I.ITEM_NM
                  , I.L_CLASS_NM
          ORDER BY I.L_CLASS_CD
                  , I.ITEM_CD    ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_05 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_06                      ============>>>>>>>>> 일자 체크
   --  Description      : 신규상품등록현황
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_06
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  I.ITEM_NM                       AS ITEM_NM  -- 상품명
               , I.SALE_PRC                      AS SALE_PRC -- 매가
               , TO_CHAR(I.INST_DT, 'YYYYMMDD')  AS INST_DT  -- 등록일
           FROM ITEM_CHAIN  I,
                ( SELECT * FROM ITEM_FLAG
                   WHERE COMP_CD = P_COMP_CD
                     AND ITEM_FG = '01'
                     AND (    P_FR_DT  BETWEEN START_DT AND END_DT
                           OR P_TO_DT  BETWEEN START_DT AND END_DT  )
                )  F
          WHERE I.COMP_CD  = F.COMP_CD
            AND I.ITEM_CD  = F.ITEM_CD
            AND I.COMP_CD  = P_COMP_CD
            AND I.BRAND_CD = P_BRAND_CD
            AND I.STOR_TP  = P_STOR_TP    ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_06 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_07
   --  Description      : 일자별기타매출실적
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_07
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SALE_DT
               , SUM(SALE_AMT)  AS SALE_AMT
               , SUM(GIFT_AMT)  AS GIFT_AMT
               , SUM(CARD_AMT)  AS CARD_AMT
           FROM (
                  SELECT  SALE_DT                                                AS SALE_DT  -- 판매일자
                        , SUM(GRD_AMT - VAT_AMT)                                 AS SALE_AMT -- 순매출액
                        , SUM(0)                                                 AS GIFT_AMT -- 상품권매출
                        , SUM(0)                                                 AS CARD_AMT -- 신용카드매출
                    FROM SALE_JDS
                   WHERE SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
                     AND COMP_CD        = P_COMP_CD
                     AND BRAND_CD       = P_BRAND_CD
                     AND STOR_CD        = P_STOR_CD
                     AND GIFT_DIV       = '0'                                                -- 상품판매
                   GROUP BY SALE_DT
                  UNION ALL
                  SELECT  SALE_DT                                                AS SALE_DT  -- 판매일자
                        , SUM(0)                                                 AS SALE_AMT -- 순매출액
                        , SUM(DECODE(PAY_DIV, '40', APPR_AMT - PAY_AMT, 0))      AS GIFT_AMT -- 상품권매출
                        , SUM(DECODE(PAY_DIV, '20', APPR_AMT - PAY_AMT, 0))      AS CARD_AMT -- 신용카드매출
                    FROM SALE_JDP
                   WHERE SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
                     AND COMP_CD        = P_COMP_CD
                     AND BRAND_CD       = P_BRAND_CD
                     AND STOR_CD        = P_STOR_CD
                     AND GIFT_DIV       = '0'                                                -- 상품판매
                   GROUP BY SALE_DT
                )
          GROUP BY SALE_DT    ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_07 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_08
   --  Description      : 일자별매출실적
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_08
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SALE_DT                    AS SALE_DT  -- 판매일자
               , SUM(SALE_AMT        )      AS SALE_AMT -- 총매출액
               , SUM(DC_AMT + ENR_AMT)      AS ENR_AMT  -- 에누리
               , SUM(GRD_AMT         )      AS GRD_AMT  -- 실매출액(부가세포함)
           FROM SALE_JDS
          WHERE SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD        = P_COMP_CD
            AND BRAND_CD       = P_BRAND_CD
            AND STOR_CD        = P_STOR_CD
          GROUP BY SALE_DT   ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_08 ;


   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_09
   --  Description      : 터치상품키현황
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_09
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         WITH IT AS
                   ( SELECT  COMP_CD
                           , ITEM_CD
                           , SALE_PRC
                       FROM ITEM_CHAIN
                      WHERE COMP_CD  = P_COMP_CD
                        AND BRAND_CD = P_BRAND_CD
                        AND STOR_TP  = P_STOR_TP
                        AND USE_YN   = 'Y'
                   )
         SELECT  T.TOUCH_DIV     -- 터치키구분 => 1:일반, 2:행사
               , T.POSITION      -- 위치
               , T.TOUCH_NM      -- 터치 상품명
               , I.SALE_PRC      -- 매가
           FROM TOUCH_STORE_UI T,
                IT             I
          WHERE T.COMP_CD   = I.COMP_CD
            AND T.TOUCH_CD  = I.ITEM_CD
            AND T.COMP_CD   = P_COMP_CD
            AND T.BRAND_CD  = P_BRAND_CD
            AND T.STOR_CD   = P_STOR_CD  ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_09 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_10
   --  Description      : 판매유형별실적
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_10
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         WITH S_IT AS
                   ( SELECT  I.COMP_CD, I.ITEM_CD, I.ITEM_POS_NM
                           , C.L_CLASS_CD || C.S_CLASS_CD AS S_CLASS_CD
                           , C.S_CLASS_NM AS S_CLASS_NM
                       FROM (
                                SELECT  I.COMP_CD
                                     ,  I.ITEM_CD
                                     ,  I.ITEM_POS_NM
                                     ,  NVL(IC.L_CLASS_CD, I.L_CLASS_CD)    AS L_CLASS_CD
                                     ,  NVL(IC.M_CLASS_CD, I.M_CLASS_CD)    AS M_CLASS_CD
                                     ,  NVL(IC.S_CLASS_CD, I.S_CLASS_CD)    AS S_CLASS_CD
                                  FROM  ITEM_CHAIN I
                                     ,  ITEM_CLASS IC
                                 WHERE  I.COMP_CD   = IC.COMP_CD(+)
                                   AND  I.ITEM_CD   = IC.ITEM_CD(+)
                                   AND I.COMP_CD  = P_COMP_CD
                                   AND I.BRAND_CD = P_BRAND_CD
                                   AND I.STOR_TP  = P_STOR_TP
                            )           I
                          , ( SELECT * FROM ITEM_S_CLASS
                               WHERE COMP_CD      = P_COMP_CD
                                 AND ORG_CLASS_CD = '00'
                                 AND USE_YN       = 'Y'
                             )          C
                      WHERE I.COMP_CD    = C.COMP_CD
                        AND I.L_CLASS_CD = C.L_CLASS_CD
                        AND I.M_CLASS_CD = C.M_CLASS_CD
                        AND I.S_CLASS_CD = C.S_CLASS_CD
                        
                   )
         SELECT  I.S_CLASS_CD      AS S_CLASS_CD  -- 소분류유형코드
               , I.S_CLASS_NM      AS S_CLASS_NM  -- 소분류유형명
               , SUM(SALE_QTY)     AS SALE_QTY    -- 수량
               , SUM(GRD_AMT)      AS GRD_AMT     -- 실매출액(부가세포함)
               , 0                 AS CUST_CNT    -- 객수
           FROM SALE_JDM   T,
                S_IT       I
          WHERE T.COMP_CD        = I.COMP_CD
            AND T.ITEM_CD        = I.ITEM_CD
            AND T.SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
            AND T.COMP_CD        = P_COMP_CD
            AND T.BRAND_CD       = P_BRAND_CD
            AND T.STOR_CD        = P_STOR_CD
          GROUP BY  I.S_CLASS_CD
                  , I.S_CLASS_NM
          ORDER BY I.S_CLASS_CD  ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_10 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_11
   --  Description      : 해피포인트사용내역
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_11
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SALE_DT                                 AS SALE_DT     -- 판매일자
               , CARD_NO                                 AS CARD_NO     -- 카드번호
               , APPR_NO                                 AS APPR_NO     -- 승인번호
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1) AS APPR_AMT    -- 승인금액
           FROM POINT_LOG
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
            AND PAY_DIV          = '60'
            AND NVL(USE_YN, 'Y') = 'Y'  ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_11 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_12
   --  Description      : 해피포인트일자별실적
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_12
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SUBSTR(SALE_DT, 5, 4)                                                 AS MMDD     -- 월일
               , SUM(DECODE(PAY_TP, '1', 1, 0))                                        AS CNT_1    -- 적립 건수
               , SUM(DECODE(PAY_TP, '1', APPR_AMT * DECODE(SALE_DIV, '1', 1, -1), 0))  AS AMT_1    -- 적립금액
               , SUM(DECODE(PAY_TP, '2', 1, 0))                                        AS CNT_2    -- 건수
               , SUM(DECODE(PAY_TP, '2', APPR_AMT * DECODE(SALE_DIV, '1', 1, -1), 0))  AS AMT_2    -- 사용금액
           FROM POINT_LOG
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
            AND PAY_DIV          = '60'
            AND NVL(USE_YN, 'Y') = 'Y'
          GROUP BY SUBSTR(SALE_DT, 5, 4) ;



      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_12 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_13
   --  Description      : LG승인내역
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_13
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  APPR_DT || APPR_TM                       AS APPR_DTM -- 일시
               , CARD_NO                                  AS CARD_NO  -- 카드번호
               , APPR_NO                                  AS APPR_NO  -- 승인번호
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1)  AS APPR_AMT -- 승인금액
           FROM POINT_LOG
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
            AND PAY_DIV          = '64'     -- SK (리더스)
--            AND SALE_DIV         = '1'
            AND NVL(USE_YN, 'Y') = 'Y' ;

      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_13 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_14
   --  Description      : LG일자별실적
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : 박인수
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_14
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  MMDD                                      AS MMDD
               , APPR_CNT                                  AS APPR_CNT
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1)   AS APPR_AMT
               , APPR_DC  * DECODE(SALE_DIV, '1', 1, -1)   AS APPR_DC
           FROM (
                  SELECT  SUBSTR(APPR_DT, 5, 4) AS MMDD       -- 월일
                        , SALE_DIV              AS SALE_DIV   -- 판매구분 (1:정상, 2: 반품)
                        , COUNT(APPR_NO)        AS APPR_CNT   -- 건수(승인-취소)
                        , SUM(APPR_AMT)         AS APPR_AMT   -- 승인금액
                        , SUM(APPR_DC )         AS APPR_DC    -- 할인금액
                    FROM POINT_LOG
                   WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
                     AND COMP_CD          = P_COMP_CD
                     AND BRAND_CD         = P_BRAND_CD
                     AND STOR_CD          = P_STOR_CD
                     AND PAY_DIV          = '66'     -- LG
                     AND NVL(USE_YN, 'Y') = 'Y'
                   GROUP BY  SUBSTR(APPR_DT, 5, 4)
                           , SALE_DIV
                )   ;



      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_14 ;


   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_15
   --  Description      : 시간대별 실적
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2011-01-17
   --  Create Programer : 박인수
   --  Modify Date      : 2011-01-17
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_15
                   ( anRetVal        OUT     NUMBER  , -- 결과코드
                     asRetMsg        OUT     VARCHAR2, -- 리턴 메시지
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SEC_DIV
               , SALE_QTY
               , DECODE(C.VAL_C1, 'G', GRD_AMT, 'T', SALE_AMT, GRD_AMT - VAT_AMT) AS SALE_AMT
           FROM SALE_JTS S
              , (
                    SELECT  VAL_C1
                      FROM  COMMON
                     WHERE  COMP_CD = P_COMP_CD
                       AND  CODE_TP = '01435'
                       AND  CODE_CD = '200'
                ) C 
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
          ORDER BY SEC_DIV ;

      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_15 ;

END PKG_POS_IF_GET_PRT;

/
