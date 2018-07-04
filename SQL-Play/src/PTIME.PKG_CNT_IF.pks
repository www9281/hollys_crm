CREATE OR REPLACE PACKAGE      PKG_CNT_IF AS

--------------------------------------------------------------------------------
--  Procedure Name   : PKG_CNT_IF
--  Description      : CNT연동
--                      SP_CNT_IF_01 => 배달정보 수신
--                      SP_CNT_IF_02 => 배달정보 수신 ACK
--                      SP_CNT_IF_03 => 점포운영정보 수신
--                      SP_CNT_IF_04 => 점포운영시간 수신
--                      SP_CNT_IF_05 => CNT주문 제조여부 수신
--------------------------------------------------------------------------------
--  Create Date      : 2015-07-01
--  Modify Date      : 2015-08-11
--------------------------------------------------------------------------------

PROCEDURE SP_CNT_IF_01
                (  asCompCd        IN   VARCHAR2, -- 회사코드
                   asSaleDt        IN   VARCHAR2, -- 판매일자
                   asBrandCd       IN   VARCHAR2, -- 영업조직
                   asStorCd        IN   VARCHAR2, -- 점포코드
                   anRetVal        OUT  NUMBER  , -- 결과코드
                   asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE SP_CNT_IF_02
                (  asCompCd        IN   VARCHAR2, -- 회사코드
                   asSaleDt        IN   VARCHAR2, -- 판매일자
                   asBrandCd       IN   VARCHAR2, -- 영업조직
                   asStorCd        IN   VARCHAR2, -- 점포코드
                   asReciveNo      IN   VARCHAR2, -- 수신번호
                   anRetVal        OUT  NUMBER  , -- 결과코드
                   asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE SP_CNT_IF_03
                (  asCompCd        IN   VARCHAR2, -- 회사코드
                   asSaleDt        IN   VARCHAR2, -- 판매일자
                   asBrandCd       IN   VARCHAR2, -- 영업조직
                   asStorCd        IN   VARCHAR2, -- 점포코드
                   anRetVal        OUT  NUMBER  , -- 결과코드
                   asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE SP_CNT_IF_04
                (  asCompCd        IN   VARCHAR2, -- 회사코드
                   asSaleDt        IN   VARCHAR2, -- 판매일자
                   asBrandCd       IN   VARCHAR2, -- 영업조직
                   asStorCd        IN   VARCHAR2, -- 점포코드
                   anRetVal        OUT  NUMBER  , -- 결과코드
                   asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE SP_CNT_IF_05
                (  asCompCd        IN   VARCHAR2, -- 회사코드
                   asSaleDt        IN   VARCHAR2, -- 판매일자
                   asBrandCd       IN   VARCHAR2, -- 영업조직
                   asStorCd        IN   VARCHAR2, -- 점포코드
                   asCntOrdNo      IN   VARCHAR2, -- CNT주문번호
                   asMakeYn        IN   VARCHAR2, -- 제조여부
                   anRetVal        OUT  NUMBER  , -- 결과코드
                   asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
                   p_cursor        OUT  rec_set.m_refcur
                ) ;
                
END PKG_CNT_IF;

/

CREATE OR REPLACE PACKAGE BODY      PKG_CNT_IF AS
 
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_01
  --  Description      : 배달정보 수신
  -- Ref. Table        : CNT_SALE_HD, CNT_SALE_DT, CNT_SALE_ST
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_01
  (  
    asCompCd        IN   VARCHAR2, -- 회사코드
    asSaleDt        IN   VARCHAR2, -- 판매일자
    asBrandCd       IN   VARCHAR2, -- 영업조직
    asStorCd        IN   VARCHAR2, -- 점포코드
    anRetVal        OUT  NUMBER  , -- 결과코드
    asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
    p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  LS_RECIVE_NO  NUMBER(10);
  
  BEGIN
    -- 배달 수신일련번호 조회
    SELECT  SQ_CNT_SALE_RECIVE_NO.NEXTVAL
      INTO  LS_RECIVE_NO
      FROM  DUAL;
    
    -- 헤더 미수신 데이터 상태 업데이트
    UPDATE  CNT_SALE_HD SH
       SET  RECIVE_YN = 'A'
         ,  RECIVE_NO = LS_RECIVE_NO
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  RECIVE_YN IN ('A', 'N')
       AND  EXISTS  (
                        SELECT  '1'
                          FROM  CNT_SALE_DT
                         WHERE  SALE_DT     = SH.SALE_DT
                           AND  STOR_CD     = SH.STOR_CD
                           AND  CNT_ORD_NO  = SH.CNT_ORD_NO
                    )
       AND  EXISTS  (
                        SELECT  '1'
                          FROM  CNT_SALE_ST
                         WHERE  SALE_DT     = SH.SALE_DT
                           AND  STOR_CD     = SH.STOR_CD
                           AND  CNT_ORD_NO  = SH.CNT_ORD_NO
                    )
       AND  ROWNUM   <= 50;
    
    UPDATE  CNT_SALE_DT
       SET  RECIVE_YN = 'A'
         ,  RECIVE_NO = LS_RECIVE_NO
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  CNT_ORD_NO IN   (
                                SELECT  CNT_ORD_NO
                                  FROM  CNT_SALE_HD
                                 WHERE  SALE_DT   = asSaleDt
                                   AND  STOR_CD   = asStorCd
                                   AND  RECIVE_NO = LS_RECIVE_NO
                            );
    UPDATE  CNT_SALE_ST
       SET  RECIVE_YN = 'A'
         ,  RECIVE_NO = LS_RECIVE_NO
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  CNT_ORD_NO IN   (
                                SELECT  CNT_ORD_NO
                                  FROM  CNT_SALE_HD
                                 WHERE  SALE_DT   = asSaleDt
                                   AND  STOR_CD   = asStorCd
                                   AND  RECIVE_NO = LS_RECIVE_NO
                            );
                            
    OPEN p_cursor FOR
    SELECT  *
      FROM  (
                SELECT  LS_RECIVE_NO    AS RECIVE_NO        -- 01 : 수신일련번호(공통)
                     ,  'H'             AS TABLE_DIV        -- 02 : 대상 테이블 구분(H : 헤더정보, D : 상품정보, S : 결제정보)
                     ,  (
                            SELECT  COUNT(*)
                              FROM  CNT_SALE_HD
                             WHERE  SALE_DT     = asSaleDt
                               AND  STOR_CD     = asStorCd
                               AND  RECIVE_YN   IN ('A', 'N')
                               AND  RECIVE_NO   = LS_RECIVE_NO
                        )               AS SALE_HD_CNT      -- 03 : 헤더 수신건수(헤더)
                     ,  SALE_DT                             -- 04 : 판매일자(공통)
                     ,  STOR_CD                             -- 05 : 점포코드(공통)
                     ,  CNT_ORD_NO                          -- 06 : CNT테크 주문번호(공통)
                     ,  SALE_DIV                            -- 07 : 판매구분[1:정상, 2:반품](공통)
                     ,  SORD_TM                             -- 08 : 주문시간(헤더)
                     ,  SALE_TM                             -- 09 : 결제시간(헤더)
                     ,  CUST_AGE                            -- 10 : 고객연령(헤더)
                     ,  CUST_M_CNT                          -- 11 : 남자고객수(헤더)
                     ,  CUST_F_CNT                          -- 12 : 여자고객수(헤더)
                     ,  CUST_NO                             -- 13 : 고객ID(헤더)
                     ,  VOID_BEFORE_DT                      -- 14 : 반품시 원 판매일자(헤더)
                     ,  VOID_BEFORE_NO                      -- 15 : 반품시 원 주문번호(헤더)
                     ,  RTN_MEMO                            -- 16 : 반품사유(헤더)
                     ,  SALE_QTY        AS HD_SALE_QTY      -- 17 : 판매수량(헤더)
                     ,  SALE_AMT        AS HD_SALE_AMT      -- 18 : 판매금액(헤더)
                     ,  GRD_AMT         AS HD_GRID_AMT      -- 19 : TAKE OUT 실판매금액(헤더)
                     ,  VAT_AMT         AS HD_VAT_AMT       -- 20 : TAKE OUT 부가세(헤더)
                     ,  SALE_TYPE                           -- 21 : 판매형태 [1:일반, 2:배달](헤더)
                     ,  CUST_CARD                           -- 22 : 멤버십 카드번호(헤더)
                     ,  APPR_NO         AS HD_APPR_NO       -- 23 : 포인트적립 승인번호(헤더)
                     ,  CPOINT                              -- 24 : 적립전 최종포인트(헤더)
                     ,  APOINT                              -- 25 : 발생포인트(헤더)
                     ,  TPOINT                              -- 26 : 최종 적립포인트(헤더)
                     ,  APPR_MSG1                           -- 27 : 반품시 원 승인번호(헤더)
                     ,  APPR_MSG2                           -- 28 : 승인 응답 코드(헤더)
                     ,  APPR_MSG3                           -- 29 : 승인 응답 메세지(헤더)
                     ,  CUST_NM                             -- 30 : 포인트 적립 대상 고객명(헤더)
                     ,  CUST_TEL                            -- 31 : 포인트 적립 고객 핸드폰 번호
                     ,  POINT_S                             -- 32 : 포인트 적립율(헤더)
                     ,  DLV_CUST_NM                         -- 33 : 주문고객명(헤더)
                     ,  DLV_CUST_TEL                        -- 34 : 주문고객 연락처(헤더)
                     ,  DLV_CUST_ADDR                       -- 35 : 주문고객 기본주소(헤더)
                     ,  DLV_CUST_ADDR2                      -- 36 : 주문고객 상세주소(헤더)
                     ,  DLV_MEMO                            -- 37 : 배달메모(헤더)
                     ,  RESV_YN                             -- 38 : 예약주문여부
                     ,  DLV_TM                              -- 39 : 배송받을 시간
                     ,  CHANNEL_TP                          -- 40 : 채널구분(1:CALL, 2:WEB, 3:APP)
                     ,  0               AS DT_SEQ           -- 41 : 상품순번(상품)
                     ,  ''              AS DT_SORD_TM       -- 42 : 주문시간(상품)
                     ,  ''              AS DT_SALE_TM       -- 43 : 판매시간(상품)
                     ,  0               AS T_SEQ            -- 44 : 주메뉴에 속한 순번(상품)
                     ,  ''              AS ITEM_CD          -- 45 : 메뉴코드(상품)
                     ,  ''              AS MAIN_ITEM_CD     -- 46 : 주메뉴코드(상품)
                     ,  ''              AS SUB_TOUCH_GR_CD  -- 47 : 옵션/부가 그룹코드(상품)
                     ,  ''              AS SUB_TOUCH_CD     -- 48 : 옵션/부가 코드(상품)
                     ,  ''              AS ITEM_SET_DIV     -- 49 : SET구분(상품)
                     ,  0               AS SALE_PRC         -- 50 : 판매단가(상품)
                     ,  0               AS DT_SALE_QTY      -- 51 : 판매수량(상품)
                     ,  0               AS DT_SALE_AMT      -- 52 : 판매금액(상품)
                     ,  0               AS DT_GRD_AMT       -- 53 : 순매출액[세폼함](상품)
                     ,  0               AS DT_NET_AMT       -- 54 : 순매출액[세제외](상품)
                     ,  0               AS VAT_RATE         -- 55 : 부가세율(상품)
                     ,  0               AS DT_VAT_AMT       -- 56 : 부가세(상품)
                     ,  0               AS TR_GR_NO         -- 57 : 판매그룹번호(상품)
                     ,  ''              AS SALE_VAT_YN      -- 58 : 판매과세구분[Y:과세, N:면세](상품)
                     ,  ''              AS SALE_VAT_RULE    -- 59 : 판매VAT관리룰[1:부가세포함, 2:부가세미포함](상품)
                     ,  ''              AS CUST_ID          -- 60 : 회원ID(상품)
                     ,  0               AS SAV_PT           -- 61 : 적립포인트(상품)
                     ,  0               AS ST_SEQ           -- 62 : 결제순번(결제)
                     ,  ''              AS PAY_DIV          -- 63 : 결제구분(결제)
                     ,  ''              AS APPR_MAEIP_CD    -- 64 : 매입사코드(결제)
                     ,  ''              AS APPR_MAEIP_NM    -- 65 : 매입사명(결제)
                     ,  ''              AS APPR_VAL_CD      -- 66 : 발급사코드(결제)
                     ,  ''              AS CARD_NO          -- 67 : 카드번호(결제)
                     ,  ''              AS CARD_NM          -- 68 : 카드명(결제)
                     ,  ''              AS ALLOT_LMT        -- 69 : 할부개월(결제)
                     ,  ''              AS ST_APPR_NO       -- 70 : 승인번호(결제)
                     ,  ''              AS APPR_DT          -- 71 : 승인일자(결제)
                     ,  ''              AS APPR_TM          -- 72 : 승인시간(결제)
                     ,  0               AS APPR_AMT         -- 73 : 승인금액(결제)
                     ,  0               AS PAY_AMT          -- 74 : 받은금액(결제)
                     ,  ''              AS SALER_DT         -- 75 : 결제시간(결제)
                  FROM  CNT_SALE_HD
                 WHERE  SALE_DT   = asSaleDt
                   AND  STOR_CD   = asStorCd
                   AND  RECIVE_YN IN ('A', 'N')
                   AND  RECIVE_NO   = LS_RECIVE_NO
                UNION ALL
                SELECT  LS_RECIVE_NO    AS RECIVE_NO        -- 01 : 수신일련번호(공통)
                     ,  'D'             AS TABLE_DIV        -- 02 : 대상 테이블 구분(H : 헤더정보, D : 상품정보, S : 결제정보)
                     ,  0               AS SALE_HD_CNT      -- 03 : 헤더 수신건수(헤더)
                     ,  SALE_DT                             -- 04 : 판매일자(공통)
                     ,  STOR_CD                             -- 05 : 점포코드(공통)
                     ,  CNT_ORD_NO                          -- 06 : CNT테크 주문번호(공통)
                     ,  SALE_DIV                            -- 07 : 판매구분[1:정상, 2:반품](공통)
                     ,  ''              AS SORD_TM          -- 08 : 주문시간(헤더)
                     ,  ''              AS SALE_TM          -- 09 : 결제시간(헤더)
                     ,  0               AS CUST_AGE         -- 10 : 고객연령(헤더)
                     ,  0               AS CUST_M_CNT       -- 11 : 남자고객수(헤더)
                     ,  0               AS CUST_F_CNT       -- 12 : 여자고객수(헤더)
                     ,  ''              AS CUST_NO          -- 13 : 고객ID(헤더)
                     ,  ''              AS VOID_BEFORE_DT   -- 14 : 반품시 원 판매일자(헤더)
                     ,  ''              AS VOID_BEFORE_NO   -- 15 : 반품시 원 주문번호(헤더)
                     ,  ''              AS RTN_MEMO         -- 16 : 반품사유(헤더)
                     ,  0               AS HD_SALE_QTY      -- 17 : 판매수량(헤더)
                     ,  0               AS HD_SALE_AMT      -- 18 : 판매금액(헤더)
                     ,  0               AS HD_GRD_AMT       -- 19 : TAKE OUT 실판매금액(헤더)
                     ,  0               AS HD_VAT_AMT       -- 20 : TAKE OUT 부가세(헤더)
                     ,  SALE_TYPE                           -- 21 : 판매형태 [1:일반, 2:배달](공통)
                     ,  ''              AS CUST_CARD        -- 22 : 멤버십 카드번호(헤더)
                     ,  ''              AS APPR_NO          -- 23 : 포인트적립 승인번호(헤더)
                     ,  0               AS CPOINT           -- 24 : 적립전 최종포인트(헤더)
                     ,  0               AS APOINT           -- 25 : 발생포인트(헤더)
                     ,  0               AS TPOINT           -- 26 : 최종 적립포인트(헤더)
                     ,  ''              AS APPR_MSG1        -- 27 : 반품시 원 승인번호(헤더)
                     ,  ''              AS APPR_MSG2        -- 28 : 승인 응답 코드(헤더)
                     ,  ''              AS APPR_MSG3        -- 29 : 승인 응답 메세지(헤더)
                     ,  ''              AS CUST_NM          -- 30 : 포인트 적립 대상 고객명(헤더)
                     ,  ''              AS CUST_TEL         -- 31 : 포인트 적립 고객 핸드폰 번호(헤더)
                     ,  0               AS POINT_S          -- 32 : 포인트 적립율(헤더)
                     ,  ''              AS DLV_CUST_NM      -- 33 : 주문고객명(헤더)
                     ,  ''              AS DLV_CUST_TEL     -- 34 : 주문고객 연락처(헤더)
                     ,  ''              AS DLV_CUST_ADDR    -- 35 : 주문고객 기본주소(헤더)
                     ,  ''              AS DLV_CUST_ADDR2   -- 36 : 주문고객 상세주소(헤더)
                     ,  ''              AS DLV_MEMO         -- 37 : 배달메모(헤더)
                     ,  ''              AS RESV_YN          -- 38 : 예약주문여부
                     ,  ''              AS DLV_TM           -- 39 : 배송받을 시간
                     ,  ''              AS CHANNEL_TP       -- 40 : 채널구분(1:CALL, 2:WEB, 3:APP)
                     ,  SEQ             AS DT_SEQ           -- 41 : 상품순번(상품)
                     ,  SORD_TM         AS DT_SORD_TM       -- 42 : 주문시간(상품)
                     ,  SALE_TM         AS DT_SALE_TM       -- 43 : 판매시간(상품)
                     ,  T_SEQ                               -- 44 : 주메뉴에 속한 순번(상품)
                     ,  ITEM_CD                             -- 45 : 메뉴코드(상품)
                     ,  MAIN_ITEM_CD                        -- 46 : 주메뉴코드(상품)
                     ,  SUB_TOUCH_GR_CD                     -- 47 : 옵션/부가 그룹코드(상품)
                     ,  SUB_TOUCH_CD                        -- 48 : 옵션/부가 코드(상품)
                     ,  ITEM_SET_DIV                        -- 49 : SET구분(상품)
                     ,  SALE_PRC                            -- 50 : 판매단가(상품)
                     ,  SALE_QTY        AS DT_SALE_QTY      -- 51 : 판매수량(상품)
                     ,  SALE_AMT        AS DT_SALE_AMT      -- 52 : 판매금액(상품)
                     ,  GRD_AMT         AS DT_GRD_AMT       -- 53 : 순매출액[세폼함](상품)
                     ,  NET_AMT         AS DT_NET_AMT       -- 54 : 순매출액[세제외](상품)
                     ,  VAT_RATE                            -- 55 : 부가세율(상품)
                     ,  VAT_AMT         AS DT_VAT_AMT       -- 56 : 부가세(상품)
                     ,  TR_GR_NO                            -- 57 : 판매그룹번호(상품)
                     ,  SALE_VAT_YN                         -- 58 : 판매과세구분[Y:과세, N:면세](상품)
                     ,  SALE_VAT_RULE                       -- 59 : 판매VAT관리룰[1:부가세포함, 2:부가세미포함](상품)
                     ,  CUST_ID                             -- 60 : 회원ID(상품)
                     ,  SAV_PT                              -- 61 : 적립포인트(상품)
                     ,  0               AS ST_SEQ           -- 62 : 결제순번(결제)
                     ,  ''              AS PAY_DIV          -- 63 : 결제구분(결제)
                     ,  ''              AS APPR_MAEIP_CD    -- 64 : 매입사코드(결제)
                     ,  ''              AS APPR_MAEIP_NM    -- 65 : 매입사명(결제)
                     ,  ''              AS APPR_VAL_CD      -- 66 : 발급사코드(결제)
                     ,  ''              AS CARD_NO          -- 67 : 카드번호(결제)
                     ,  ''              AS CARD_NM          -- 68 : 카드명(결제)
                     ,  ''              AS ALLOT_LMT        -- 69 : 할부개월(결제)
                     ,  ''              AS ST_APPR_NO       -- 70 : 승인번호(결제)
                     ,  ''              AS APPR_DT          -- 71 : 승인일자(결제)
                     ,  ''              AS APPR_TM          -- 72 : 승인시간(결제)
                     ,  0               AS APPR_AMT         -- 73 : 승인금액(결제)
                     ,  0               AS PAY_AMT          -- 74 : 받은금액(결제)
                     ,  ''              AS SALER_DT         -- 75 : 결제시간(결제)
                  FROM  CNT_SALE_DT
                 WHERE  SALE_DT   = asSaleDt
                   AND  STOR_CD   = asStorCd
                   AND  RECIVE_YN IN ('A', 'N')
                   AND  RECIVE_NO = LS_RECIVE_NO
                UNION ALL
                SELECT  LS_RECIVE_NO    AS RECIVE_NO        -- 01 : 수신일련번호(공통)
                     ,  'S'             AS TABLE_DIV        -- 02 : 대상 테이블 구분(H : 헤더정보, D : 상품정보, S : 결제정보)
                     ,  0               AS SALE_HD_CNT      -- 03 : 헤더 수신건수(헤더)
                     ,  SALE_DT                             -- 04 : 판매일자(공통)
                     ,  STOR_CD                             -- 05 : 점포코드(공통)
                     ,  CNT_ORD_NO                          -- 06 : CNT테크 주문번호(공통)
                     ,  SALE_DIV                            -- 07 : 판매구분[1:정상, 2:반품](공통)
                     ,  ''              AS SORD_TM          -- 08 : 주문시간(헤더)
                     ,  ''              AS SALE_TM          -- 09 : 결제시간(헤더)
                     ,  0               AS CUST_AGE         -- 10 : 고객연령(헤더)
                     ,  0               AS CUST_M_CNT       -- 11 : 남자고객수(헤더)
                     ,  0               AS CUST_F_CNT       -- 12 : 여자고객수(헤더)
                     ,  ''              AS CUST_NO          -- 13 : 고객ID(헤더)
                     ,  ''              AS VOID_BEFORE_DT   -- 14 : 반품시 원 판매일자(헤더)
                     ,  ''              AS VOID_BEFORE_NO   -- 15 : 반품시 원 주문번호(헤더)
                     ,  ''              AS RTN_MEMO         -- 16 : 반품사유(헤더)
                     ,  0               AS HD_SALE_QTY      -- 17 : 판매수량(헤더)
                     ,  0               AS HD_SALE_AMT      -- 18 : 판매금액(헤더)
                     ,  0               AS HD_GRD_AMT       -- 19 : TAKE OUT 실판매금액(헤더)
                     ,  0               AS HD_VAT_AMT       -- 20 : TAKE OUT 부가세(헤더)
                     ,  SALE_TYPE                           -- 21 : 판매형태 [1:일반, 2:배달](공통)
                     ,  ''              AS CUST_CARD        -- 22 : 멤버십 카드번호(헤더)
                     ,  ''              AS HD_APPR_NO       -- 23 : 포인트적립 승인번호(헤더)
                     ,  0               AS CPOINT           -- 24 : 적립전 최종포인트(헤더)
                     ,  0               AS APOINT           -- 25 : 발생포인트(헤더)
                     ,  0               AS TPOINT           -- 26 : 최종 적립포인트(헤더)
                     ,  ''              AS APPR_MSG1        -- 27 : 반품시 원 승인번호(헤더)
                     ,  ''              AS APPR_MSG2        -- 28 : 승인 응답 코드(헤더)
                     ,  ''              AS APPR_MSG3        -- 29 : 승인 응답 메세지(헤더)
                     ,  ''              AS CUST_NM          -- 30 : 포인트 적립 대상 고객명(헤더)
                     ,  ''              AS CUST_TEL         -- 31 : 포인트 적립 고객 핸드폰 번호(헤더)
                     ,  0               AS POINT_S          -- 32 : 포인트 적립율(헤더)
                     ,  ''              AS DLV_CUST_NM      -- 33 : 주문고객명(헤더)
                     ,  ''              AS DLV_CUST_TEL     -- 34 : 주문고객 연락처(헤더)
                     ,  ''              AS DLV_CUST_ADDR    -- 35 : 주문고객 기본주소(헤더)
                     ,  ''              AS DLV_CUST_ADDR2   -- 36 : 주문고객 상세주소(헤더)
                     ,  ''              AS DLV_MEMO         -- 37 : 배달메모(헤더)
                     ,  ''              AS RESV_YN          -- 38 : 예약주문여부
                     ,  ''              AS DLV_TM           -- 39 : 배송받을 시간
                     ,  ''              AS CHANNEL_TP       -- 40 : 채널구분(1:CALL, 2:WEB, 3:APP)
                     ,  0               AS DT_SEQ           -- 41 : 상품순번(상품)
                     ,  ''              AS DT_SORD_TM       -- 42 : 주문시간(상품)
                     ,  ''              AS DT_SALE_TM       -- 43 : 판매시간(상품)
                     ,  0               AS T_SEQ            -- 44 : 주메뉴에 속한 순번(상품)
                     ,  ''              AS ITEM_CD          -- 45 : 메뉴코드(상품)
                     ,  ''              AS MAIN_ITEM_CD     -- 46 : 주메뉴코드(상품)
                     ,  ''              AS SUB_TOUCH_GR_CD  -- 47 : 옵션/부가 그룹코드(상품)
                     ,  ''              AS SUB_TOUCH_CD     -- 48 : 옵션/부가 코드(상품)
                     ,  ''              AS ITEM_SET_DIV     -- 49 : SET구분(상품)
                     ,  0               AS SALE_PRC         -- 50 : 판매단가(상품)
                     ,  0               AS DT_SALE_QTY      -- 51 : 판매수량(상품)
                     ,  0               AS DT_SALE_AMT      -- 52 : 판매금액(상품)
                     ,  0               AS DT_GRD_AMT       -- 53 : 순매출액[세폼함](상품)
                     ,  0               AS DT_NET_AMT       -- 54 : 순매출액[세제외](상품)
                     ,  0               AS VAT_RATE         -- 55 : 부가세율(상품)
                     ,  0               AS DT_VAT_AMT       -- 56 : 부가세(상품)
                     ,  0               AS TR_GR_NO         -- 57 : 판매그룹번호(상품)
                     ,  ''              AS SALE_VAT_YN      -- 58 : 판매과세구분[Y:과세, N:면세](상품)
                     ,  ''              AS SALE_VAT_RULE    -- 59 : 판매VAT관리룰[1:부가세포함, 2:부가세미포함](상품)
                     ,  ''              AS CUST_ID          -- 60 : 회원ID(상품)
                     ,  0               AS SAV_PT           -- 61 : 적립포인트(상품)
                     ,  SEQ             AS ST_SEQ           -- 62 : 결제순번(결제)
                     ,  PAY_DIV                             -- 63 : 결제구분(결제)
                     ,  APPR_MAEIP_CD                       -- 64 : 매입사코드(결제)
                     ,  APPR_MAEIP_NM                       -- 65 : 매입사명(결제)
                     ,  APPR_VAL_CD                         -- 66 : 발급사코드(결제)
                     ,  CARD_NO                             -- 67 : 카드번호(결제)
                     ,  CARD_NM                             -- 68 : 카드명(결제)
                     ,  ALLOT_LMT                           -- 69 : 할부개월(결제)
                     ,  APPR_NO         AS ST_APPR_NO       -- 70 : 승인번호(결제)
                     ,  APPR_DT                             -- 71 : 승인일자(결제)
                     ,  APPR_TM                             -- 72 : 승인시간(결제)
                     ,  APPR_AMT                            -- 73 : 승인금액(결제)
                     ,  PAY_AMT                             -- 74 : 받은금액(결제)
                     ,  SALER_DT                            -- 75 : 결제시간(결제)
                  FROM  CNT_SALE_ST
                 WHERE  SALE_DT   = asSaleDt
                   AND  STOR_CD   = asStorCd
                   AND  RECIVE_YN IN ('A', 'N')
                   AND  RECIVE_NO = LS_RECIVE_NO
            )
     ORDER  BY CNT_ORD_NO, TABLE_DIV, DT_SEQ, ST_SEQ
    ;

    COMMIT;
    
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_01;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_02
  --  Description      : 배달정보 수신 ACK
  -- Ref. Table        : CNT_SALE_HD, CNT_SALE_DT, CNT_SALE_ST
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_02 
  (
    asCompCd        IN   VARCHAR2, -- 회사코드
    asSaleDt        IN   VARCHAR2, -- 판매일자
    asBrandCd       IN   VARCHAR2, -- 영업조직
    asStorCd        IN   VARCHAR2, -- 점포코드
    asReciveNo      IN   VARCHAR2, -- 수신번호
    anRetVal        OUT  NUMBER  , -- 결과코드
    asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
    p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  BEGIN
    UPDATE  CNT_SALE_HD
       SET  RECIVE_YN = 'Y'
         ,  RECIVE_TM = TO_CHAR(SYSDATE, 'HH24MISS')
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  RECIVE_NO = asReciveNo;
    
    UPDATE  CNT_SALE_DT
       SET  RECIVE_YN = 'Y'
         ,  RECIVE_TM = TO_CHAR(SYSDATE, 'HH24MISS')
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  RECIVE_NO = asReciveNo;
       
    UPDATE  CNT_SALE_ST
       SET  RECIVE_YN = 'Y'
         ,  RECIVE_TM = TO_CHAR(SYSDATE, 'HH24MISS')
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  RECIVE_NO = asReciveNo;
    
    COMMIT;
    
    anRetVal := 1;
    asRetMsg := 'OK';
    
    OPEN p_cursor FOR
    SELECT  'OK'
      FROM  DUAL;
      
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_02;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_03
  --  Description      : 점포운영정보 수신
  -- Ref. Table        : STORE_CNT
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_03
  (  
    asCompCd        IN   VARCHAR2, -- 회사코드
    asSaleDt        IN   VARCHAR2, -- 판매일자
    asBrandCd       IN   VARCHAR2, -- 영업조직
    asStorCd        IN   VARCHAR2, -- 점포코드
    anRetVal        OUT  NUMBER  , -- 결과코드
    asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
    p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  BEGIN
                                
    OPEN p_cursor FOR
    SELECT  SC.BRAND_CD
         ,  SC.STOR_CD
         ,  SC.CALL_ORD_YN
         ,  SC.ONLINE_ORD_YN
         ,  SC.TAKE_OUT_ORD_YN
         ,  SC.DELIVERY_ORD_YN
         ,  SC.DELIVERY_HM
         ,  SC.RESERVE_HM
         ,  CASE WHEN SH.START_DT IS NULL THEN 'N'
                 ELSE 'Y'
            END                 AS HOLIDAY_YN
      FROM  STORE_CNT       SC
         ,  STORE_HOLIDAY   SH
     WHERE  SC.COMP_CD  = SH.COMP_CD(+)
       AND  SC.BRAND_CD = SH.BRAND_CD(+)
       AND  SC.STOR_CD  = SH.STOR_CD(+)
       AND  SC.COMP_CD  = asCompCd
       AND  SC.BRAND_CD = asBrandCd
       AND  SC.STOR_CD  = asStorCd
       AND  SH.START_DT(+) = TO_CHAR(SYSDATE, 'YYYYMMDD')
    ;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_03;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_04
  --  Description      : 점포운영시간 수신
  -- Ref. Table        : STORE_WEEK
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_04
  (  
    asCompCd        IN   VARCHAR2, -- 회사코드
    asSaleDt        IN   VARCHAR2, -- 판매일자
    asBrandCd       IN   VARCHAR2, -- 영업조직
    asStorCd        IN   VARCHAR2, -- 점포코드
    anRetVal        OUT  NUMBER  , -- 결과코드
    asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
    p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  BEGIN
                                
    OPEN p_cursor FOR
    SELECT  BRAND_CD
         ,  STOR_CD
         ,  WEEK_DAY
         ,  START_HM
         ,  CLOSE_HM
      FROM  STORE_WEEK
     WHERE  COMP_CD     = asCompCd
       AND  BRAND_CD    = asBrandCd
       AND  STOR_CD     = asStorCd
    ;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_04;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_02
  --  Description      : 배달정보 수신 ACK
  -- Ref. Table        : CNT_SALE_HD, CNT_SALE_DT, CNT_SALE_ST
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_05
  (  asCompCd        IN   VARCHAR2, -- 회사코드
     asSaleDt        IN   VARCHAR2, -- 판매일자
     asBrandCd       IN   VARCHAR2, -- 영업조직
     asStorCd        IN   VARCHAR2, -- 점포코드
     asCntOrdNo      IN   VARCHAR2, -- CNT주문번호
     asMakeYn        IN   VARCHAR2, -- 제조여부
     anRetVal        OUT  NUMBER  , -- 결과코드
     asRetMsg        OUT  VARCHAR2, -- 리턴 메시지
     p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  BEGIN
    UPDATE  CNT_SALE_HD
       SET  MAKE_YN   = asMakeYn
         ,  MAKE_TM   = TO_CHAR(SYSDATE, 'HH24MISS')
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  CNT_ORD_NO= asCntOrdNo;
    
    COMMIT;
    
    anRetVal := 1;
    asRetMsg := 'OK';
    
    OPEN p_cursor FOR
    SELECT  'OK'
      FROM  DUAL;
      
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_05;
  
END PKG_CNT_IF;

/
