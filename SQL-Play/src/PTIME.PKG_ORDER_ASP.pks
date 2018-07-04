CREATE OR REPLACE PACKAGE      PKG_ORDER_ASP AS
--------------------------------------------------------------------------------
--  Package Name     : PKG_ORDER_ASP
--  Description      : 종합주문
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2016-01-27
--  Modify Date      : 2016-01-27
--------------------------------------------------------------------------------
  ERR_4000000   CONSTANT VARCHAR2(7) := '0' ;
  ERR_4000001   CONSTANT VARCHAR2(7) := '4000001' ;  -- 미등록 주문 그룹입니다.( OC_ORD_GRP Table)
  ERR_4000002   CONSTANT VARCHAR2(7) := '4000002' ;  -- 미등록 점포입니다.     ( STORE Table     )
  ERR_4000003   CONSTANT VARCHAR2(7) := '4000003' ;  -- 미등록 영업조직입니다. ( BRAND Table     )
  
  ERR_4000004   CONSTANT VARCHAR2(7) := '4000004' ;  -- 점포등록이 확정되지 않았습니다.
  ERR_4000005   CONSTANT VARCHAR2(7) := '4000005' ;  -- 미사용 점포입니다.
  ERR_4999999   CONSTANT VARCHAR2(7) := '4999999' ;  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
  
  ERR_4000201   CONSTANT VARCHAR2(7) := '4000201' ;  -- 주문 한정수량을 초과했습니다.
  ERR_4000202   CONSTANT VARCHAR2(7) := '4000202' ;  -- 주문가능한 한도행사 제품이 아닙니다.
  ERR_4999989   CONSTANT VARCHAR2(7) := '4999989' ;  -- 주문마감한 자료는 삭제할 수 없습니다.
  
  ERR_HANDLER   EXCEPTION;
  
  C_SEQ1        CONSTANT  OC_ORD_GRP_SEQ.ORD_SEQ%TYPE := '1' ; -- 1차 코드
  C_SEQ2        CONSTANT  OC_ORD_GRP_SEQ.ORD_SEQ%TYPE := '2' ; -- 2차 코드
  C_SEQ3        CONSTANT  OC_ORD_GRP_SEQ.ORD_SEQ%TYPE := '3' ; -- 3차 코드
  
  C_FDM         CONSTANT VARCHAR2(3) := '↙' ;
  C_RDM         CONSTANT VARCHAR2(2) := '#!' ;
  C_COMMA       CONSTANT VARCHAR2(2) := ','  ;
  C_N_FDM       CONSTANT NUMBER(1)   := LENGTHB(C_FDM) ;
  C_N_RDM       CONSTANT NUMBER(1)   := LENGTHB(C_RDM) ;
  
  C_SDATE_N1    CONSTANT  NUMBER(1)  :=  0;
  C_SDATE_N2    CONSTANT  NUMBER(1)  :=  0;
  C_SDATE_N3    CONSTANT  NUMBER(1)  :=  0;
  
  TYPE REC_ORD_SP_LIST IS RECORD
  (   ORD_NO          VARCHAR2(100),
      ITEM_CD         VARCHAR2(100),
      ITEM_CD_NM      VARCHAR2(100),
      ORD_1ST         VARCHAR2(100),
      ORD_COST1       VARCHAR2(100),
      ORD_CONTROL_1   VARCHAR2(100),
      ORD_B_CNT       VARCHAR2(100),
      MIN_ORD_QTY     VARCHAR2(100),
      ALERT_ORD_QTY   VARCHAR2(100),
      ORD_AMT1        VARCHAR2(100),
      ORD_UNIT        VARCHAR2(100),
      ORD_UNIT_QTY    VARCHAR2(100),
      ITEM_DIV        VARCHAR2(100)
  ) ;
  
  TYPE REC_ORD_CAKE_LIST IS RECORD
  (   ORD_NO          VARCHAR2(100),
      ITEM_CD_NM      VARCHAR2(100),
      ORD_COST1       VARCHAR2(100),
      ORD_1ST         VARCHAR2(100),
      ORD_UNIT        VARCHAR2(100),
      SEQ             VARCHAR2(100),
      C_MESSAGE       VARCHAR2(1000),
      ITEM_CD         VARCHAR2(100),
      ORD_CONTROL_1   VARCHAR2(100),
      ORD_B_CNT       VARCHAR2(100),
      MIN_ORD_QTY     VARCHAR2(100),
      ALERT_ORD_QTY   VARCHAR2(100),
      ORD_AMT1        VARCHAR2(100),
      ITEM_DIV        VARCHAR2(100)
  ) ;
  
  TYPE REC_ORD_LIST IS RECORD
  (   ORD_NO          VARCHAR2(100),
      ITEM_CD_NM      VARCHAR2(100),
      DIV             VARCHAR2(100),
      SALE_RANK       VARCHAR2(100),
      ORD_1ST         VARCHAR2(100),
      BASIC           VARCHAR2(100),
      ORD_2ND         VARCHAR2(100),
      ORD_3RD         VARCHAR2(100),
      ORD_UNIT        VARCHAR2(100),
      ORD_UNIT_QTY    VARCHAR2(100),
      STOCK_EXP_QTY   VARCHAR2(100),
      BD_ORD_1ST      VARCHAR2(100),
      BD_ORD_2ND      VARCHAR2(100),
      BD_ORD_3RD      VARCHAR2(100),
      LW_ORD_1ST      VARCHAR2(100),
      LW_ORD_2ND      VARCHAR2(100),
      LW_ORD_3RD      VARCHAR2(100),
      DAY_SALE_AMT    VARCHAR2(100),
      LW_SALE_AMT     VARCHAR2(100),
      ITEM_CD         VARCHAR2(100),
      ORD_CONTROL_1   VARCHAR2(100),
      ORD_CONTROL_2   VARCHAR2(100),
      ORD_CONTROL_3   VARCHAR2(100),
      ORD_B_CNT       VARCHAR2(100),
      MIN_ORD_QTY     VARCHAR2(100),
      ALERT_ORD_QTY   VARCHAR2(100),
      ORD_COST1       VARCHAR2(100),
      ORD_COST2       VARCHAR2(100),
      ORD_COST3       VARCHAR2(100),
      ORD_AMT1        VARCHAR2(100),
      ORD_AMT2        VARCHAR2(100),
      ORD_AMT3        VARCHAR2(100),
      ITEM_DIV        VARCHAR2(100),
      ORD_SGRP        VARCHAR2(100),
      ORD_SGRP_CD     VARCHAR2(100),
      ORD_TP          VARCHAR2(100),
      MERGE_DIV       VARCHAR2(100),
      SEARCH_TXT      VARCHAR2(100),
      BASIC_CHK       VARCHAR2(100),
      LIMIT_QTY       VARCHAR2(100),
      ORD_QTY         VARCHAR2(100),
      SORT_ORDER      VARCHAR2(100),
      DIV_CHK         VARCHAR2(100)
  );
  
  TYPE REF_CUR IS REF CURSOR ;
  
  TYPE    REC_PARA    IS RECORD
  (   ORD_SEQ         VARCHAR2(10),
      ITEM_CD         VARCHAR2(20),
      ORD_QTY         VARCHAR2(10),
      C_MESSAGE       VARCHAR2(4000)
  );
  
  TYPE TAB_PARA IS TABLE OF REC_PARA ;
  
  TYPE ITEM_TBL IS TABLE OF VARCHAR2(20) ;
  
  FUNCTION F_PARA_PARSING
  ( 
    PSV_PARA           IN  VARCHAR2
  ) RETURN TBL_ORD_PARA ;
  
  PROCEDURE SP_ORDER_LIST_MAIN
  ( 
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ITEM_DIV    IN  VARCHAR2    -- 주문그룹
  , PSV_ITEM_TP     IN  VARCHAR2    -- 제품타입
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RESULT       IN OUT PKG_REPORT.REF_CUR
  ) ;
  
  PROCEDURE SP_ORDER_LIST_LINK
  ( 
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ITEM_DIV    IN  VARCHAR2    -- 주문그룹
  , PSV_ITEM_TP     IN  VARCHAR2    -- 제품타입
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RESULT       IN OUT PKG_REPORT.REF_CUR
  ) ;
  
  PROCEDURE SP_ORDER_SAVE
  (
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PSV_IP_ADDR1    IN  VARCHAR2    -- 주문 PC IP ADDRESS (공인)
  , PSV_IP_ADDR2    IN  VARCHAR2    -- 주문 PC IP ADDRESS (사설)
  , PSV_USER_ID     IN  VARCHAR2    -- 주문구분
  , PSV_ORD_LIST    IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
  ) ;
  
  PROCEDURE SP_ORDER_SAVE_MAIN
  ( 
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PSV_IP_ADDR1    IN  VARCHAR2    -- 주문 PC IP ADDRESS (공인)
  , PSV_IP_ADDR2    IN  VARCHAR2    -- 주문 PC IP ADDRESS (사설)
  , PSV_USER_ID     IN  VARCHAR2    -- 주문구분
  , PTV_PARA        IN  TBL_ORD_PARA-- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
  ) ;
  
  PROCEDURE SP_ORDER_DELETE
  ( 
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PSV_IP_ADDR1    IN  VARCHAR2    -- 주문 PC IP ADDRESS (공인)
  , PSV_IP_ADDR2    IN  VARCHAR2    -- 주문 PC IP ADDRESS (사설)
  , PSV_USER_ID     IN  VARCHAR2    -- 사용자 ID
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
  ) ;
  
  PROCEDURE SP_ORDER_DELETE_MAIN
  ( 
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2  -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2  -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2  -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2  -- 배송일자
  , PSV_ORD_FG      IN  VARCHAR2  -- 주문구분
  , PSV_IP_ADDR1    IN  VARCHAR2  -- 주문 PC IP ADDRESS (공인)
  , PSV_IP_ADDR2    IN  VARCHAR2  -- 주문 PC IP ADDRESS (사설)
  , PSV_USER_ID     IN  VARCHAR2  -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2  -- 처리코드
  , PR_RTN_MSG      OUT VARCHAR2  -- 처리Message
  ) ;
  
  PROCEDURE SP_ORDER_LIST_CHK
  ( 
    PSV_LANG_CD     IN  VARCHAR2    -- 언어코드
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ITEM_DIV    IN  VARCHAR2    -- 제품그룹
  , PSV_ITEM_TP     IN  VARCHAR2    -- 제품타입
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RESULT       IN OUT PKG_REPORT.REF_CUR
  ) ;
  
  PROCEDURE SP_ORDER_LIST
  ( 
    PSV_LANG_CD     IN  VARCHAR2    -- 언어코드
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ITEM_DIV    IN  VARCHAR2    -- 제품그룹
  , PSV_ITEM_TP     IN  VARCHAR2    -- 제품타입
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RESULT       IN OUT PKG_REPORT.REF_CUR
  ) ;
END;

/

CREATE OR REPLACE PACKAGE BODY      PKG_ORDER_ASP AS
--------------------------------------------------------------------------------
--  Package Name     : PKG_ORDER_ASP
--  Description      : 종합주문
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2016-01-27
--  Modify Date      : 2016-01-27
--------------------------------------------------------------------------------
  FUNCTION F_PARA_PARSING
  ( 
    PSV_PARA        IN  VARCHAR2
  ) RETURN TBL_ORD_PARA IS
    li_pos        PLS_INTEGER;
    li_pre        PLS_INTEGER;
    li_next       PLS_INTEGER;
    li_idx        PLS_INTEGER := 0 ;
    ltb_para      TBL_ORD_PARA :=  TBL_ORD_PARA();
    ls_ord_seq    VARCHAR2(10);
    ls_item_cd    VARCHAR2(20);
    ls_ord_qty    VARCHAR2(10);
    ls_seq        VARCHAR2(5);
    ls_c_message  VARCHAR2(200);
    
    ls_para       VARCHAR2(32767) ;
    
  BEGIN
    ls_para  :=  PSV_PARA ;
    LOOP
      li_pos := INSTRB(ls_para, C_RDM);
      EXIT WHEN li_pos IS NULL OR li_pos < 1;
      li_pre       := 1;
      li_next      := INSTRB( ls_para, C_FDM , li_pre );
      ls_ord_seq   := SUBSTRB(ls_para, li_pre, li_next - li_pre);
      
      li_pre       := li_next + C_N_FDM;
      li_next      := INSTRB( ls_para, C_FDM , li_pre );
      ls_item_cd   := substrb(ls_para, li_pre, li_next - li_pre);
      
      li_pre       := li_next + C_N_FDM;
      li_next      := INSTRB( ls_para, C_FDM , li_pre );
      ls_ord_qty   := SUBSTRB(ls_para, li_pre, li_next - li_pre);
      
      li_pre       := li_next + C_N_FDM;
      li_next      := INSTRB( ls_para, C_FDM , li_pre );
      ls_seq       := SUBSTRB(ls_para, li_pre, li_next - li_pre);
      
      li_pre       := li_next + C_N_FDM;
      li_next      := INSTRB( ls_para, C_FDM , li_pre );
      ls_c_message := SUBSTRB(ls_para, li_pre, li_next - li_pre);
      
      ltb_para.EXTEND;
      li_idx := ltb_para.LAST;
      
      ls_ord_qty := NVL( TRIM( ls_ord_qty ) ,'0');
      
      ltb_para(li_idx) := OT_ORD_PARA(ls_ord_seq, ls_item_cd, ls_ord_qty, ls_seq , ls_c_message);
      
      EXIT WHEN  li_pos < 1;
      
      ls_para := substrb( ls_para , li_pos + C_N_RDM);
    END LOOP;
    
    RETURN ltb_para;
  END;
  
  PROCEDURE SP_ORDER_LIST_MAIN
  (
    PSV_LANG_CD     IN  VARCHAR2    -- LANG_CD
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ITEM_DIV    IN  VARCHAR2    -- 주문그룹
  , PSV_ITEM_TP     IN  VARCHAR2    -- 제품타입
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RESULT       IN OUT PKG_REPORT.REF_CUR
  ) IS
  
    C_SDATE_N1    CONSTANT  NUMBER(1)  :=  0;
    C_SDATE_N2    CONSTANT  NUMBER(1)  :=  0;
    C_SDATE_N3    CONSTANT  NUMBER(1)  :=  0;
    
    C_ODATE       VARCHAR2(8)  := TO_CHAR( SYSDATE     , 'YYYYMMDD') ;   -- 주문 일자
    C_NDATE       VARCHAR2(8)  := TO_CHAR( SYSDATE +1  , 'YYYYMMDD') ;   -- 주문 일자 + 1일 (입고예정수량)
    C_PW_ODATE    VARCHAR2(8)  := TO_CHAR( SYSDATE -7  , 'YYYYMMDD') ;   -- 전주 주문 일자
    C_MY_ODATE    VARCHAR2(8)  := TO_CHAR( SYSDATE -14 , 'YYYYMMDD') ;   --  MY 주문 Chechk 일자(15일간)
    
    C_SDATE1      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'YYYYMMDD') ; --1차 배송일자
    C_SDATE2      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'YYYYMMDD') ; --2차 배송일자
    C_SDATE3      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'YYYYMMDD') ; --3차 배송일자
    
    C_PD_SDATE1   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 -1 , 'YYYYMMDD') ; --전일 1차 배송일자
    C_PD_SDATE2   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 -1 , 'YYYYMMDD') ; --전일 2차 배송일자
    C_PD_SDATE3   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 -1 , 'YYYYMMDD') ; --전일 3차 배송일자
    
    C_PW_SDATE1   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 -7 , 'YYYYMMDD') ; --전주 1차 배송일자
    C_PW_SDATE2   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 -7 , 'YYYYMMDD') ; --전주 2차 배송일자
    C_PW_SDATE3   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 -7 , 'YYYYMMDD') ; --전주 3차 배송일자
    
    C_SDAY1       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'D') ; --1차 배송요일
    C_SDAY2       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'D') ; --2차 배송요일
    C_SDAY3       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'D') ; --3차 배송요일
    
    ls_err_cd     VARCHAR2(7) ;
    
    ls_stor_tp      STORE.STOR_TP%TYPE;
    ls_ord_tp       VARCHAR2(1); -- PARA_BRAND로 전환[20160126 표준화]
    ls_confirm_div  VARCHAR2(1); -- TABLE 정리[20160126 표준화]
    ls_use_yn       STORE.USE_YN%TYPE;
    ls_center_cd    STORE.CENTER_CD%TYPE;
    
    ln_week_new     PLS_INTEGER;
    
  BEGIN
    
    ls_err_cd := ERR_4000000  ;
    
    -- 주문 분류 항목 결정
    BEGIN
      SELECT PARA_VAL
        INTO ls_ord_tp
        FROM PARA_BRAND
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND PARA_CD  = '1003'; -- 주문분류
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_err_cd := ERR_4000003 ;
           RAISE ERR_HANDLER ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    BEGIN
      SELECT VAL_N1
        INTO ln_week_new
        FROM COMMON
       WHERE COMP_CD = PSV_COMP_CD
         AND CODE_TP = '01330' -- 금주 신규 기간
         AND CODE_CD = '1' ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ln_week_new := 7 ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    BEGIN
      SELECT  STOR_TP, '9', CENTER_CD, USE_YN
      INTO    ls_stor_tp, ls_confirm_div, ls_center_cd, ls_use_yn
      FROM    STORE
      WHERE   COMP_CD  = PSV_COMP_CD
        AND   BRAND_CD = PSV_BRAND_CD
        AND   STOR_CD  = PSV_STOR_CD ;
        
      -- 매장: 확정상태 체크 - 확정구분 => 공통(00105) [0:요청, 1:임시저장, 9:확정]
      IF ls_confirm_div <> '9' THEN
         ls_err_cd :=  4000004;
         RAISE  ERR_HANDLER;
      ELSIF ls_use_yn IS NULL OR ls_use_yn <> 'Y' THEN
         ls_err_cd :=  4000005;
         RAISE  ERR_HANDLER;
      END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ls_err_cd := ERR_4000002 ;
            RAISE ERR_HANDLER ;
        WHEN ERR_HANDLER THEN
            RAISE ERR_HANDLER ;
        WHEN OTHERS THEN
            ls_err_cd := ERR_4999999 ;
            RAISE ERR_HANDLER ;
    END;
    
    -- OS : 주문그룹/차수 통제 (OC_ORD_GRP_SEQ)
    -- OI : 주문그룹/상품 통제 (OC_ORD_GRP_ITEM)
    OPEN PR_RESULT FOR
    SELECT ROW_NO,
           ITEM_CD_NM,
           DIV,
           SALE_RANK,
           ORD_1ST,
           BASIC,
           ORD_2ND,
           ORD_3RD,
           ORD_UNIT,
           ORD_UNIT_QTY,
           STOCK_EXP_QTY,
           BD_ORD_1ST,
           BD_ORD_2ND,
           BD_ORD_3RD,
           LW_ORD_1ST,
           LW_ORD_2ND,
           LW_ORD_3RD,
           DAY_SALE_AMT,
           LW_SALE_AMT,
           ITEM_CD,
           ORD_CONTROL_1,
           ORD_CONTROL_2,
           ORD_CONTROL_3,
           ORD_B_CNT,
           MIN_ORD_QTY,
           ALERT_ORD_QTY,
           ORD_COST_1,
           ORD_COST_2,
           ORD_COST_3,
           ORD_AMT_1,
           ORD_AMT_2,
           ORD_AMT_3,
           ITEM_DIV,
           ORD_GRP,
           ORD_GRP_CD,
           MERGE_DIV,
           SEARCH_TXT,
           BASIC_CHK,
           DIV_CHK,
           RTN_CHK,
           SORT_ORDER,
           ORD_J_CNT
      FROM (
            WITH O_GRP AS
            (SELECT ORD_GRP, CONTROL_DIV
               FROM OC_ORD_GRP A
              WHERE COMP_CD = PSV_COMP_CD
                AND USE_YN  = 'Y'
                AND (PSV_ITEM_DIV IN ( 'NEW', 'MY' ) OR (PSV_ITEM_DIV NOT IN ( 'NEW', 'MY' ) AND ORD_GRP = PSV_ITEM_DIV))
                AND EXISTS (SELECT '1'
                              FROM OC_ORD_GRP_STORE B
                             WHERE A.ORD_GRP  = B.ORD_GRP
                               AND B.BRAND_CD =  PSV_BRAND_CD
                               AND B.STOR_CD  =  PSV_STOR_CD
                               AND B.USE_YN   = 'Y'
                           )
            ) ,
            O_CLASS AS
            (
             SELECT B1.L_CLASS_CD CLASS_CD ,
                    NVL(B2.LANG_NM , B1.L_CLASS_NM) CLASS_NM ,
                    '▶  ' ||  NVL(B2.LANG_NM , B1.L_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                    B1.SORT_ORDER,
                    B1.L_CLASS_CD CLASS_CD2
               FROM ITEM_L_CLASS B1,
                    LANG_TABLE B2
              WHERE B2.COMP_CD(+)   = PSV_COMP_CD
                AND B2.TABLE_NM (+) = 'ITEM_L_CLASS'
                AND B2.COL_NM   (+) = 'L_CLASS_NM'
                AND B2.LANGUAGE_TP (+)= PSV_LANG_CD
                AND B1.ORG_CLASS_CD || B1.L_CLASS_CD = B2.PK_COL (+)
                AND B1.COMP_CD      = PSV_COMP_CD
                AND B1.ORG_CLASS_CD = '00'
                AND ls_ord_tp = 'L'
             UNION ALL
             SELECT B1.L_CLASS_CD || B1.M_CLASS_CD CLASS_CD ,
                    NVL(B2.LANG_NM , B1.M_CLASS_NM) CLASS_NM ,
                     '▶  ' ||  NVL(B2.LANG_NM , B1.M_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                    B1.SORT_ORDER ,
                    B1.M_CLASS_CD CLASS_CD2
               FROM ITEM_M_CLASS B1,
                    LANG_TABLE B2
              WHERE B2.COMP_CD(+)   = PSV_COMP_CD
                AND B2.TABLE_NM (+) = 'ITEM_M_CLASS'
                AND B2.COL_NM   (+) = 'M_CLASS_NM'
                AND B2.LANGUAGE_TP (+)= PSV_LANG_CD
                AND B1.ORG_CLASS_CD || B1.L_CLASS_CD || B1.M_CLASS_CD = B2.PK_COL (+)
                AND B1.COMP_CD      = PSV_COMP_CD
                AND B1.ORG_CLASS_CD = '00'
                AND ls_ord_tp = 'M'
             UNION ALL
             SELECT B1.L_CLASS_CD || B1.M_CLASS_CD || B1.S_CLASS_CD CLASS_CD ,
                    NVL(B2.LANG_NM , B1.S_CLASS_NM) CLASS_NM ,
                     '▶  ' ||  NVL(B2.LANG_NM , B1.S_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                    B1.SORT_ORDER,
                    B1.S_CLASS_CD CLASS_CD2
               FROM ITEM_S_CLASS B1,
                    LANG_TABLE B2
              WHERE B2.COMP_CD(+)   = PSV_COMP_CD
                AND B2.TABLE_NM (+) = 'ITEM_S_CLASS'
                AND B2.COL_NM   (+) = 'S_CLASS_NM'
                AND B2.LANGUAGE_TP (+)= PSV_LANG_CD
                AND B1.ORG_CLASS_CD || B1.L_CLASS_CD || B1.M_CLASS_CD || B1.S_CLASS_CD = B2.PK_COL (+)
                AND B1.COMP_CD      = PSV_COMP_CD
                AND B1.ORG_CLASS_CD = '00'
                AND ls_ord_tp = 'S'
            ) ,
            O_TR AS
            (
             SELECT COMP_CD, ITEM_CD ,
                    SUM(CASE WHEN SHIP_DT = C_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_QTY ELSE 0 END) ORD_QTY1,
                    SUM(CASE WHEN SHIP_DT = C_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_QTY ELSE 0 END) ORD_QTY2,
                    SUM(CASE WHEN SHIP_DT = C_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_QTY ELSE 0 END) ORD_QTY3,
                    SUM(CASE WHEN SHIP_DT = C_PD_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_QTY ELSE 0 END) ORD_PD_QTY1,
                    SUM(CASE WHEN SHIP_DT = C_PD_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_QTY ELSE 0 END) ORD_PD_QTY2,
                    SUM(CASE WHEN SHIP_DT = C_PD_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_QTY ELSE 0 END) ORD_PD_QTY3,
                    SUM(CASE WHEN SHIP_DT = C_PW_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY1,
                    SUM(CASE WHEN SHIP_DT = C_PW_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY2,
                    SUM(CASE WHEN SHIP_DT = C_PW_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY3,
                    SUM(CASE WHEN SHIP_DT = C_NDATE AND ORD_SEQ = C_SEQ1 THEN ORD_CQTY ELSE 0 END) ORD_OD_QTY
               FROM ORDER_DT
              WHERE ( SHIP_DT, ORD_SEQ )  IN ( (C_SDATE1,    C_SEQ1) , (C_SDATE2,    C_SEQ2) , (C_SDATE3,    C_SEQ3) ,
                                               (C_PD_SDATE1, C_SEQ1) , (C_PD_SDATE2, C_SEQ2) , (C_PD_SDATE3, C_SEQ3) ,
                                               (C_PW_SDATE1, C_SEQ1) , (C_PW_SDATE2, C_SEQ2) , (C_PW_SDATE3, C_SEQ3) ,
                                               (C_ODATE,     C_SEQ1) , (C_NDATE,     C_SEQ1)  )
                AND COMP_CD  =  PSV_COMP_CD
                AND BRAND_CD =  PSV_BRAND_CD
                AND STOR_CD  =  PSV_STOR_CD
                AND ORD_FG   =  PSV_ORD_FG
              GROUP BY COMP_CD, ITEM_CD
            )
            SELECT ROW_NO,
                   ITEM_CD_NM,
                   DIV,
                   SALE_RANK,
                   ORD_1ST,
                   BASIC,
                   ORD_2ND,
                   ORD_3RD,
                   ORD_UNIT,
                   ORD_UNIT_QTY,
                   STOCK_EXP_QTY,
                   BD_ORD_1ST,
                   BD_ORD_2ND,
                   BD_ORD_3RD,
                   LW_ORD_1ST,
                   LW_ORD_2ND,
                   LW_ORD_3RD,
                   DAY_SALE_AMT,
                   LW_SALE_AMT,
                   LIMIT_QTY,
                   ORD_QTY,
                   STCK_QTY,
                   ORD_ADD_1ST,
                   ORD_COLLECT_MSG,
                   ITEM_CD,
                   ORD_CONTROL_1,
                   ORD_CONTROL_2,
                   ORD_CONTROL_3,
                   ORD_B_CNT,
                   MIN_ORD_QTY,
                   ALERT_ORD_QTY,
                   ORD_COST_1,
                   ORD_COST_2,
                   ORD_COST_3,
                   '0' ORD_AMT_1,
                   '0' ORD_AMT_2,
                   '0' ORD_AMT_3,
                   ITEM_DIV,
                   ORD_GRP,
                   ORD_GRP_CD,
                   ORD_TP,
                   MERGE_DIV,
                   SEARCH_TXT,
                   BASIC_CHK ,
                   SORT_ORDER ,
                   GRP_SORT,
                   CLASS_NM,
                   DIV_CHK ,
                   RTN_CHK,
                   COUNT(1) OVER ( PARTITION BY GRP_SORT, CLASS_NM, ORD_GRP ) CNT,
                   ' ' ORD_J_CNT
              FROM (
                    SELECT OC.GRP_CLASS_NM  ROW_NO,
                           OC.GRP_CLASS_NM  ITEM_CD_NM,
                           OC.GRP_CLASS_NM  DIV,
                           OC.GRP_CLASS_NM  SALE_RANK,
                           OC.GRP_CLASS_NM  ORD_1ST,
                           OC.GRP_CLASS_NM  BASIC,
                           OC.GRP_CLASS_NM  ORD_2ND,
                           OC.GRP_CLASS_NM  ORD_3RD,
                           OC.GRP_CLASS_NM  ORD_UNIT,
                           OC.GRP_CLASS_NM  ORD_UNIT_QTY,
                           OC.GRP_CLASS_NM  STOCK_EXP_QTY,
                           OC.GRP_CLASS_NM  BD_ORD_1ST,
                           OC.GRP_CLASS_NM  BD_ORD_2ND,
                           OC.GRP_CLASS_NM  BD_ORD_3RD,
                           OC.GRP_CLASS_NM  LW_ORD_1ST,
                           OC.GRP_CLASS_NM  LW_ORD_2ND,
                           OC.GRP_CLASS_NM  LW_ORD_3RD,
                           OC.GRP_CLASS_NM  DAY_SALE_AMT,
                           OC.GRP_CLASS_NM  LW_SALE_AMT,
                           OC.GRP_CLASS_NM  LIMIT_QTY,
                           OC.GRP_CLASS_NM  ORD_QTY,
                           OC.GRP_CLASS_NM  STCK_QTY,
                           OC.GRP_CLASS_NM  ORD_ADD_1ST,
                           OC.GRP_CLASS_NM  ORD_COLLECT_MSG,
                           ' '              ITEM_CD,
                           ' '              ORD_CONTROL_1,
                           ' '              ORD_CONTROL_2,
                           ' '              ORD_CONTROL_3,
                           ' '              ORD_B_CNT,
                           ' '              MIN_ORD_QTY,
                           ' '              ALERT_ORD_QTY,
                           ' '              ORD_COST_1,
                           ' '              ORD_COST_2,
                           ' '              ORD_COST_3,
                           ' '              ORD_AMT_1,
                           ' '              ORD_AMT_2,
                           ' '              ORD_AMT_3,
                           ' '              ITEM_DIV,
                           OC.CLASS_CD      ORD_GRP,
                           OC.CLASS_CD2     ORD_GRP_CD,
                           ls_ord_tp        ORD_TP,
                           'T'              MERGE_DIV,
                           'T' || OC.CLASS_CD SEARCH_TXT,
                           ' '              BASIC_CHK,
                           '0'              SORT_ORDER ,
                           OC.SORT_ORDER    GRP_SORT,
                           OC.CLASS_NM      CLASS_NM,
                           ' '              DIV_CHK,
                           ' '              RTN_CHK,
                           ' '              ORD_J_CNT
                      FROM OC_ORD_GRP_ITEM OI,
                           ITEM_CHAIN I,
                           O_CLASS OC
                     WHERE I.COMP_CD   =  PSV_COMP_CD
                       AND I.BRAND_CD  =  PSV_BRAND_CD
                       AND OI.ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                       AND OI.COMP_CD  = I.COMP_CD
                       AND OI.ITEM_CD  = I.ITEM_CD
                       AND OI.USE_YN   = 'Y'
                       AND I.STOR_TP   = ls_stor_tp
                       AND OC.CLASS_CD = DECODE(ls_ord_tp, 'L', I.L_CLASS_CD, 'M', I.L_CLASS_CD||I.M_CLASS_CD, 'S', I.L_CLASS_CD||I.M_CLASS_CD||I.S_CLASS_CD, '')
                     GROUP BY OC.CLASS_CD, OC.CLASS_CD2, OC.CLASS_NM, OC.GRP_CLASS_NM, OC.SORT_ORDER
                    UNION ALL
                    SELECT TO_CHAR( ROW_NUMBER() OVER ( PARTITION BY OI.CLASS_NM, OI.ORD_SGRP ORDER BY OI.ITEM_NM ) ) ROW_NO,
                           OI.ITEM_NM ITEM_CD_NM,
                           ' '  DIV,
                           TO_CHAR(OI.SALE_RANK) SALE_RANK,
                           NVL( DECODE(TO_CHAR( OQ.ORD_QTY1 ), '0', '',  TO_CHAR( OQ.ORD_QTY1 )) , '' )  ORD_1ST,
                           ' ' BASIC,
                           NVL( DECODE(TO_CHAR( OQ.ORD_QTY2 ), '0', '',  TO_CHAR( OQ.ORD_QTY2 )) , '' )  ORD_2ND,
                           NVL( DECODE(TO_CHAR( OQ.ORD_QTY3 ), '0', '',  TO_CHAR( OQ.ORD_QTY3 )) , '' )  ORD_3RD,
                           C_00095.CODE_NM ORD_UNIT,
                           TO_CHAR(OI.ORD_UNIT_QTY) ORD_UNIT_QTY ,
                           NVL( TO_CHAR( OQ.ORD_OD_QTY  ) , '0' )  STOCK_EXP_QTY,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY1 ) , '0' )  BD_ORD_1ST,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY2 ) , '0' )  BD_ORD_2ND,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY3 ) , '0' )  BD_ORD_3RD,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY1 ) , '0' )  LW_ORD_1ST,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY2 ) , '0' )  LW_ORD_2ND,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY3 ) , '0' )  LW_ORD_3RD,
                           NVL( TO_CHAR( SQ.GRD_AMT )     , '0' )  DAY_SALE_AMT ,
                           NVL( TO_CHAR( SQ.GRD_PW_AMT )  , '0' )  LW_SALE_AMT,
                           NVL( TO_CHAR( OI.LIMIT_QTY )   , '0' )  LIMIT_QTY,
                           NVL( TO_CHAR( OI.ORD_QTY )     , '0' )  ORD_QTY,
                           NVL( TO_CHAR( OI.LIMIT_QTY - OI.ORD_QTY)   , '0' )  STCK_QTY,
                           '0'  ORD_ADD_1ST,
                           OI.ORD_COLLECT_MSG ,
                           OI.ITEM_CD,
                           OI.ORD_CONTROL_1,
                           OI.ORD_CONTROL_2,
                           OI.ORD_CONTROL_3,
                           TO_CHAR(OI.ORD_B_CNT) ORD_B_CNT,
                           TO_CHAR(OI.MIN_ORD_QTY) MIN_ORD_QTY,
                           TO_CHAR(OI.ALERT_ORD_QTY) ALERT_ORD_QTY,
                           TO_CHAR(OI.COST1) ORD_COST_1,
                           TO_CHAR(OI.COST2) ORD_COST_2,
                           TO_CHAR(OI.COST3) ORD_COST_3,
                           NVL( TO_CHAR(OQ.ORD_QTY1 * OI.COST1) , '0' ) ORD_AMT_1,
                           NVL( TO_CHAR(OQ.ORD_QTY2 * OI.COST2) , '0' ) ORD_AMT_2,
                           NVL( TO_CHAR(OQ.ORD_QTY3 * OI.COST3) , '0' ) ORD_AMT_3,
                           OI.ITEM_DIV,
                           OI.ORD_SGRP,
                           OI.ORD_SGRP_CD,
                           ls_ord_tp    ORD_TP,
                           'I' MERGE_DIV,
                           'I' || OI.ORD_SGRP SEARCH_TXT,
                           OI.BASIC_CHK ,
                           '1' SORT_ORDER ,
                           OI.SORT_ORDER GRP_SORT,
                           OI.CLASS_NM ,
                           OI.DIV DIV_CHK ,
                           CASE WHEN RS.ITEM_CD IS NULL THEN '0' ELSE '1' END RTN_CHK ,
                           ' '  ORD_J_CNT
                      FROM (
                            WITH  NEW_ITEM AS
                            (
                             SELECT ITEM_CD,
                                    CASE WHEN START_DT + ln_week_new >=  C_ODATE THEN '2' ELSE '1' END NEW_TP
                               FROM ITEM_FLAG
                              WHERE COMP_CD = PSV_COMP_CD
                                AND ITEM_FG = '01'
                                AND USE_YN  = 'Y'
                                AND C_ODATE BETWEEN START_DT AND END_DT
                            ),
                            ITEM_FLAG_ALL AS
                            (
                             SELECT ITEM_CD,
                                    CASE MIN ( NEW_TP )
                                         WHEN 1  THEN '4'
                                         WHEN 2  THEN '5'
                                         WHEN 3  THEN '3'
                                         WHEN 4  THEN '2'
                                         WHEN 5  THEN '1'
                                         ELSE         '0'
                                    END NEW_TP
                               FROM (
                                     SELECT ITEM_CD,
                                            CASE A.ITEM_FG
                                                 WHEN  '04' THEN 1
                                                 WHEN  '01' THEN CASE WHEN START_DT + ln_week_new >=  C_ODATE THEN 4 ELSE 5 END
                                            END NEW_TP
                                       FROM ITEM_FLAG A, COMMON B
                                      WHERE A.COMP_CD  = PSV_COMP_CD
                                        AND A.ITEM_FG IN  ( '01' , '04' )
                                        AND A.USE_YN   = 'Y'
                                        AND C_ODATE BETWEEN CASE WHEN B.VAL_C1 = 'Y' THEN START_DT ELSE '00000000' END
                                                        AND CASE WHEN B.VAL_C1 = 'Y' THEN END_DT   ELSE '99999999' END
                                        AND B.CODE_TP  = '01090' -- 작업구분[01:신상품, 02:집중상품, 03:행사상품, 04:중단]
                                        AND B.COMP_CD  = A.COMP_CD
                                        AND B.CODE_CD  = A.ITEM_FG
                                     UNION ALL
                                     /*
                                     SELECT C.ITEM_CD, 3 NEW_TP
                                       FROM CAMPAIGN_MST A, CAMPAIGN_ITEM C
                                      WHERE A.CAMPAIGN_STAT = 'C'
                                        AND C_ODATE   BETWEEN A.START_DT AND A.END_DT
                                        AND A.COMP_CD       = PSV_COMP_CD
                                        AND A.BRAND_CD      = PSV_BRAND_CD
                                        AND A.COMP_CD       = C.COMP_CD
                                        AND A.BRAND_CD      = C.BRAND_CD
                                        AND A.CAMPAIGN_CD   = C.CAMPAIGN_CD
                                        AND A.STOR_CD       = C.STOR_CD
                                        AND ( A.STOR_CD     =  PSV_STOR_CD  OR
                                              EXISTS (SELECT '1'
                                                        FROM CAMPAIGN_STORE  S
                                                       WHERE S.COMP_CD     = A.COMP_CD
                                                         AND S.BRAND_CD    = A.BRAND_CD
                                                         AND S.CAMPAIGN_CD = A.CAMPAIGN_CD
                                                         AND S.STOR_CD     =  PSV_STOR_CD
                                                         AND S.USE_YN      = 'Y'
                                                     )
                                            )
                                        AND A.USE_YN        = 'Y'
                                        AND C.USE_YN        = 'Y'
                                     UNION ALL */
                                     SELECT ITEM_CD, 2
                                       FROM REJECT_SYSTEM A, REJECT_SYSTEM_ITEM B
                                      WHERE A.COMP_CD   = B.COMP_CD
                                        AND A.BRAND_CD  = B.BRAND_CD
                                        AND A.STOR_CD   = B.STOR_CD
                                        AND A.START_DT  = B.START_DT
                                        AND A.USE_YN    = 'Y'
                                        AND B.USE_YN    = 'Y'
                                        AND A.COMP_CD   =  PSV_COMP_CD
                                        AND A.BRAND_CD  =  PSV_BRAND_CD
                                        AND A.STOR_CD   =  PSV_STOR_CD
                                        AND A.START_DT <= C_ODATE
                                    ) A
                              GROUP BY ITEM_CD
                            ),
                            O_CTL_TM AS
                            (
                             SELECT ORD_GRP,
                                    ORD_SEQ ,
                                    ORD_START_TM,
                                    ORD_END_TM,
                                    ORD_END_DDAY
                               FROM OC_STORE_TM
                              WHERE USE_YN    = 'Y'
                                AND ORD_GRP  IN ( SELECT ORD_GRP FROM O_GRP )
                                AND COMP_CD   = PSV_COMP_CD
                                AND BRAND_CD  = PSV_BRAND_CD
                                AND STOR_CD   = PSV_STOR_CD
                                AND ( SHIP_DT, ORD_SEQ )   IN  ( ( C_SDATE1, C_SEQ1 ), ( C_SDATE2, C_SEQ2 ), ( C_SDATE3, C_SEQ3) )
                             UNION ALL
                             SELECT OTM.ORD_GRP ,
                                    OTM.ORD_SEQ ,
                                    OTM.ORD_START_TM,
                                    OTM.ORD_END_TM,
                                    OTM.ORD_END_DDAY
                               FROM (
                                     SELECT ORD_GRP,
                                            ORD_SEQ ,
                                            ORD_START_TM,
                                            ORD_END_TM,
                                            ORD_END_DDAY
                                       FROM OC_ORD_GRP_TM OGT
                                      WHERE COMP_CD    = PSV_COMP_CD
                                        AND USE_YN     = 'Y'
                                        AND ORD_GRP   IN ( SELECT ORD_GRP FROM O_GRP )
                                        AND OC_WRK_DIV = '1'
                                        AND NOT EXISTS (SELECT '1'
                                                          FROM OC_CENTER_TM OCT
                                                         WHERE OCT.CENTER_CD  = ls_center_cd
                                                           AND OCT.USE_YN     = 'Y'
                                                           AND OCT.OC_WRK_DIV = '1'
                                                           AND OCT.COMP_CD    = OGT.COMP_CD
                                                           AND OCT.ORD_GRP    = OGT.ORD_GRP
                                                       )
                                     UNION ALL
                                     SELECT ORD_GRP ,
                                            ORD_SEQ ,
                                            ORD_START_TM,
                                            ORD_END_TM,
                                            ORD_END_DDAY
                                       FROM OC_CENTER_TM
                                      WHERE COMP_CD    = PSV_COMP_CD
                                        AND USE_YN     = 'Y'
                                        AND ORD_GRP   IN ( SELECT ORD_GRP FROM O_GRP )
                                        AND OC_WRK_DIV = '1'
                                        AND CENTER_CD  = ls_center_cd
                                    ) OTM
                              WHERE NOT EXISTS (SELECT '1'
                                                  FROM OC_STORE_TM OCT
                                                 WHERE OCT.COMP_CD  =  PSV_COMP_CD
                                                   AND OCT.BRAND_CD =  PSV_BRAND_CD
                                                   AND OCT.STOR_CD  =  PSV_STOR_CD
                                                   AND OCT.USE_YN   = 'Y'
                                                   AND OCT.ORD_GRP  = OTM.ORD_GRP
                                                   AND OCT.ORD_SEQ  = OTM.ORD_SEQ
                                                   AND OCT.SHIP_DT  =  CASE OTM.ORD_SEQ 
                                                                            WHEN C_SEQ1 THEN C_SDATE1
                                                                            WHEN C_SEQ2 THEN C_SDATE2
                                                                            WHEN C_SEQ3 THEN C_SDATE3
                                                                            ELSE NULL END
                                               )
                            ),
                            O_DDAY AS
                            (
                             SELECT ORD_GRP,
                                    CHK1, CHK2, CHK3,
                                    D_DAY1, D_DAY2, D_DAY3,
                                    TO_CHAR( TO_DATE(C_SDATE1, 'YYYYMMDD') - NVL(D_DAY1,-1) , 'YYYYMMDD') CHK_DT1,
                                    TO_CHAR( TO_DATE(C_SDATE2, 'YYYYMMDD') - NVL(D_DAY2,-1) , 'YYYYMMDD') CHK_DT2,
                                    TO_CHAR( TO_DATE(C_SDATE3, 'YYYYMMDD') - NVL(D_DAY3,-1) , 'YYYYMMDD') CHK_DT3
                               FROM (
                                     /*
                                     SELECT ORD_GRP,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN ORD_DDAY ELSE NULL END ) D_DAY3
                                       FROM OC_ORD_GRP_DDAY
                                      WHERE ORD_GRP IN (SELECT ORD_GRP FROM O_GRP )
                                        AND ( ORD_SEQ, DLV_WK ) IN ( ( C_SEQ1, C_SDAY1 ), ( C_SEQ2, C_SDAY2 ), ( C_SEQ3, C_SDAY3 ) )
                                      GROUP BY ORD_GRP
                                     UNION ALL
                                     */
                                     SELECT ORD_GRP,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY3
                                       FROM OC_STORE_DDAY
                                      WHERE ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                        AND COMP_CD  =  PSV_COMP_CD
                                        AND BRAND_CD =  PSV_BRAND_CD
                                        AND STOR_CD  =  PSV_STOR_CD
                                        AND DLV_WK    IN ( C_SDAY1, C_SDAY2, C_SDAY3 )
                                      GROUP BY ORD_GRP
                                    ) OD
                              WHERE ORD_GRP IS NOT NULL
                            ) ,
                            O_CHK_TM AS
                            (
                             SELECT ORD_GRP,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT1 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT1
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT1 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT1, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ1
                                                             AND ORD_GRP = O_DDAY.ORD_GRP
                                                         )
                                              THEN 1
                                         ELSE 0 END CHK1,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT2 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT2
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT2 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT2, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ2
                                                             AND ORD_GRP = O_DDAY.ORD_GRP
                                                         )
                                              THEN 1
                                         ELSE 0 END CHK2,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT3 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT3
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT3 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT3, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ3
                                                             AND ORD_GRP = O_DDAY.ORD_GRP
                                                         )
                                              THEN 1
                                         ELSE 0 END CHK3
                               FROM O_DDAY
                            ),
                            O_COLLECT AS
                            (
                             SELECT A.EVT_FG,
                                    B.ITEM_CD,
                                    B.ORD_COLLECT_MSG,
                                    B.LIMIT_QTY,
                                    B.ORD_QTY
                               FROM ORDER_COLLECT_INFO A, ORDER_COLLECT_ITEM B
                              WHERE A.USE_YN   = 'Y'
                                AND B.USE_YN   = 'Y'
                                AND C_SDATE1 BETWEEN A.START_DT AND A.CLOSE_DT
                                AND A.COMP_CD  = PSV_COMP_CD
                                AND A.BRAND_CD = PSV_BRAND_CD
                                AND A.COMP_CD  = B.COMP_CD
                                AND A.BRAND_CD = B.BRAND_CD
                                AND A.ORD_COLLECT_NO = B.ORD_COLLECT_NO
                                AND EXISTS (SELECT '1'
                                              FROM ORDER_COLLECT_STORE C
                                             WHERE A.ORD_COLLECT_NO = C.ORD_COLLECT_NO
                                               AND A.COMP_CD        = C.COMP_CD
                                               AND A.BRAND_CD       = C.BRAND_CD
                                               AND C.STOR_CD        =  PSV_STOR_CD
                                               AND C.USE_YN         = 'Y'
                                           )
                            )
                            SELECT I.ITEM_CD,
                                   CASE WHEN IL.ITEM_NM IS NULL THEN I.ITEM_NM ELSE IL.ITEM_NM END ITEM_NM,
                                   IG.CLASS_NM,
                                   IG.SORT_ORDER,
                                   I.DIV,
                                   I.SALE_RANK,
                                   I.NEW_TP,
                                   I.ORD_UNIT,
                                   I.ORD_UNIT_QTY,
                                   I.ORD_B_CNT,
                                   ' ' ORD_J_CNT,
                                   I.MIN_ORD_QTY,
                                   I.ALERT_ORD_QTY,
                                   I.ITEM_DIV,
                                   I.BASIC_CHK ,
                                   I.ORD_SGRP,
                                   I.ORD_SGRP_CD,
                                   I.COST1,
                                   I.COST2,
                                   I.COST3,
                                   CASE WHEN OS.CHK1   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK1   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK1  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK1  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK1   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK1 = 0 OR OCI.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK1 = 0 OR OEI.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK1 = 0 OR OEA.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK1 = 0 OR OEG.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OEI2_CHK.CHK1 IS NULL OR ( OEI2_CHK.CHK1 = 1 AND ( OEI2.CHK1 = 1 OR OEG2.CHK1 = 1 OR OEA2.CHK1 = 1) )
                                        THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN ( ( OEI3.CHK1 = 1 OR OEA3.CHK1 = 1 OR OEG3.CHK1 = 1 )  OR ( OEI3.CHK1 IS NULL AND  OEA3.CHK1 IS NULL AND OEG3.CHK1 IS NULL ) )   THEN 'Y' ELSE 'N' END
                                        AS ORD_CONTROL_1,
                                   CASE WHEN OS.CHK2   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK2   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK2  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK2  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK2   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK2 = 0 OR OCI.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK2 = 0 OR OEI.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK2 = 0 OR OEA.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK2 = 0 OR OEG.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OEI2_CHK.CHK2 IS NULL OR ( OEI2_CHK.CHK2 = 1 AND ( OEI2.CHK2 = 1 OR OEG2.CHK2 = 1 OR OEA2.CHK2 = 1) )
                                        THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN ( ( OEI3.CHK2 = 1 OR OEA3.CHK2 = 1 OR OEG3.CHK2 = 1 )  OR ( OEI3.CHK2 IS NULL AND  OEA3.CHK2 IS NULL AND OEG3.CHK2 IS NULL ) )   THEN 'Y' ELSE 'N' END
                                        AS ORD_CONTROL_2,
                                   CASE WHEN OS.CHK3   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK3   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK3  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK3  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK3   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK3 = 0 OR OCI.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK3 = 0 OR OEI.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK3 = 0 OR OEA.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK3 = 0 OR OEG.CHK3 IS NULL) THEN 'Y' ELSE 'N' END  ||
                                   CASE WHEN OEI2_CHK.CHK3 IS NULL OR ( OEI2_CHK.CHK3 = 1 AND ( OEI2.CHK3 = 1 OR OEG2.CHK3 = 1 OR OEA2.CHK3 = 1) )
                                        THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN ( ( OEI3.CHK3 = 1 OR OEA3.CHK3 = 1 OR OEG3.CHK3 = 1 )  OR ( OEI3.CHK3 IS NULL AND  OEA3.CHK3 IS NULL AND OEG3.CHK3 IS NULL ) )   THEN 'Y' ELSE 'N' END
                                        AS ORD_CONTROL_3,
                                   OLM.LIMIT_QTY,
                                   OLM.ORD_QTY  ,
                                   OLM.ORD_COLLECT_MSG
                              FROM (
                                    SELECT /* USE_HASH(@MY) */
                                           I.ITEM_CD ,
                                           CASE WHEN F.NEW_TP IS NULL THEN '0' ELSE F.NEW_TP END DIV,
                                           CASE WHEN C_SDATE1 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK1,
                                           CASE WHEN C_SDATE2 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK2,
                                           CASE WHEN C_SDATE3 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK3,
                                           IC.COST1,
                                           IC.COST2,
                                           IC.COST3,
                                           I.L_CLASS_CD,
                                           I.M_CLASS_CD,
                                           I.S_CLASS_CD,
                                           I.ITEM_NM ,
                                           CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                                WHEN ls_ord_tp= 'M' THEN I.L_CLASS_CD || I.M_CLASS_CD
                                                WHEN ls_ord_tp= 'S' THEN I.L_CLASS_CD || I.M_CLASS_CD || I.S_CLASS_CD
                                                ELSE NULL
                                           END ORD_SGRP,
                                           CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                                WHEN ls_ord_tp= 'M' THEN I.M_CLASS_CD
                                                WHEN ls_ord_tp= 'S' THEN I.S_CLASS_CD
                                                ELSE NULL
                                           END ORD_SGRP_CD,
                                           I.ITEM_DIV,
                                           I.ORD_UNIT,
                                           I.ORD_UNIT_QTY,
                                           I.ORD_B_CNT,
                                           ' ' ORD_J_CNT,
                                           I.ORD_START_DT,
                                           I.ORD_CLOSE_DT,
                                           I.MIN_ORD_QTY,
                                           I.ALERT_ORD_QTY,
                                           F.NEW_TP,
                                           0 SALE_RANK,
                                           CASE WHEN RI.ITEM_CD IS NULL THEN '0' ELSE '1' END BASIC_CHK
                                      FROM (
                                            SELECT *
                                              FROM ITEM_CHAIN
                                             WHERE COMP_CD  = PSV_COMP_CD 
                                               AND BRAND_CD = PSV_BRAND_CD
                                               AND STOR_TP  = ls_stor_tp
                                           ) I,
                                           ITEM_FLAG_ALL F,
                                           (
                                            SELECT COMP_CD, ITEM_CD, MAX(COST1) COST1 , MAX(COST2) COST2, MAX(COST3) COST3
                                              FROM (
                                                    SELECT COMP_CD,
                                                           ITEM_CD,
                                                           MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST1,
                                                           NULL COST2,
                                                           NULL COST3
                                                      FROM ITEM_CHAIN_HIS H
                                                     WHERE COMP_CD   = PSV_COMP_CD
                                                       AND BRAND_CD  = PSV_BRAND_CD
                                                       AND STOR_TP   = ls_stor_tp
                                                       AND START_DT <= C_SDATE1
                                                     GROUP BY COMP_CD, ITEM_CD
                                                    UNION ALL
                                                    SELECT COMP_CD,
                                                           ITEM_CD,
                                                           NULL COST1,
                                                           MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST2,
                                                           NULL COST3
                                                      FROM ITEM_CHAIN_HIS H
                                                     WHERE COMP_CD   = PSV_COMP_CD
                                                       AND BRAND_CD  = PSV_BRAND_CD
                                                       AND STOR_TP   = ls_stor_tp
                                                       AND START_DT <= C_SDATE2
                                                     GROUP BY COMP_CD, ITEM_CD
                                                    UNION ALL
                                                    SELECT COMP_CD,
                                                           ITEM_CD,
                                                           NULL COST1,
                                                           NULL COST2,
                                                           MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST3
                                                      FROM ITEM_CHAIN_HIS H
                                                     WHERE COMP_CD   = PSV_COMP_CD
                                                       AND BRAND_CD  = PSV_BRAND_CD
                                                       AND STOR_TP   = ls_stor_tp
                                                       AND START_DT <= C_SDATE3
                                                     GROUP BY COMP_CD, ITEM_CD
                                                   ) ICG
                                             GROUP BY COMP_CD, ITEM_CD
                                           ) IC,
                                           (
                                            SELECT DISTINCT ITEM_CD
                                              FROM REF_ITEM
                                             WHERE COMP_CD = PSV_COMP_CD
                                               AND USE_YN  ='Y'
                                           ) RI
                                     WHERE I.USE_YN      = 'Y'
                                       AND I.STOR_TP     = ls_stor_tp
                                       AND I.ORD_SALE_DIV IN ( '1', '2' )
                                       AND I.ORD_MNG_DIV = '0'
                                       AND I.COMP_CD     =  PSV_COMP_CD
                                       AND I.BRAND_CD    =  PSV_BRAND_CD
                                       AND ( C_SDATE1 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT, '9') OR
                                             C_SDATE2 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT, '9') OR
                                             C_SDATE3 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT, '9')
                                           )
                                       AND I.COMP_CD     = IC.COMP_CD
                                       AND I.ITEM_CD     = IC.ITEM_CD
                                       AND I.ITEM_CD     = F.ITEM_CD (+)
                                       AND I.ITEM_CD     = RI.ITEM_CD (+)
                                       AND ( ( PSV_ITEM_DIV NOT IN ( 'NEW', 'MY' ) AND
                                               I.ITEM_CD IN (SELECT B.ITEM_CD
                                                               FROM OC_ORD_GRP A
                                                                  , OC_ORD_GRP_ITEM B
                                                                  , ITEM_CHAIN C
                                                              WHERE A.COMP_CD    = B.COMP_CD
                                                                AND A.ORD_GRP    = B.ORD_GRP
                                                                AND B.COMP_CD    = C.COMP_CD
                                                                AND B.ITEM_CD    = C.ITEM_CD
                                                                AND A.COMP_CD    = PSV_COMP_CD
                                                                AND A.ORD_GRP    = PSV_ITEM_DIV
                                                                AND A.USE_YN     = 'Y'
                                                                AND B.USE_YN     = 'Y'
                                                                AND C.BRAND_CD   = PSV_BRAND_CD
                                                                AND C.STOR_TP    = (SELECT STOR_TP
                                                                                      FROM STORE
                                                                                     WHERE COMP_CD  = PSV_COMP_CD
                                                                                       AND BRAND_CD = PSV_BRAND_CD
                                                                                       AND STOR_CD  = PSV_STOR_CD
                                                                                   )
                                                                AND C.ORD_SALE_DIV IN ('1', '2')
                                                                AND C.ORD_MNG_DIV = '0'
                                                                AND TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN C.ORD_START_DT AND NVL(C.SALE_CLOSE_DT, '99991231')
                                                                AND C.USE_YN = 'Y'
                                                              GROUP BY B.ITEM_CD
                                                            )
                                                                                       AND I.ITEM_CD NOT IN  ( SELECT ITEM_CD FROM O_COLLECT WHERE EVT_FG = '3')
                                             ) OR
                                             (  PSV_ITEM_DIV = 'NEW' AND I.ITEM_CD IN      ( SELECT ITEM_CD FROM NEW_ITEM )
                                                                     AND I.ITEM_CD NOT IN  ( SELECT ITEM_CD FROM O_COLLECT WHERE EVT_FG = '3' ) ) OR
                                             (  PSV_ITEM_DIV = 'MY'  AND I.ITEM_CD IN      ( SELECT ITEM_CD
                                                                                               FROM ORDER_DT
                                                                                              WHERE STOR_CD       =  PSV_STOR_CD
                                                                                                AND SHIP_DT BETWEEN C_MY_ODATE AND C_ODATE
                                                                                              GROUP BY ITEM_CD
                                                                                           )
                                                                     AND I.ITEM_CD NOT IN  ( SELECT ITEM_CD FROM O_COLLECT WHERE EVT_FG = '3' ) )
                                           )
                                   ) I,
                                   (
                                    SELECT ORD_GRP,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_SEQ
                                     WHERE COMP_CD = PSV_COMP_CD
                                       AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                     GROUP BY ORD_GRP
                                   ) OS,
                                   O_CHK_TM  OT,
                                   (
                                    SELECT ORD_GRP,
                                           ITEM_CD ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_ITEM
                                     WHERE COMP_CD  = PSV_COMP_CD
                                       AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                       AND USE_YN   = 'Y'
                                     GROUP BY ORD_GRP, ITEM_CD
                                   ) OI,
                                   (
                                    SELECT ITEM_CD,
                                           MAX( CASE WHEN DLV_WK = C_SDAY1 AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY2 AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY3 AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_CENTER_ITEM
                                     WHERE COMP_CD   = PSV_COMP_CD
                                       AND USE_YN    = 'Y'
                                       AND CENTER_CD = ls_center_cd
                                     GROUP BY ITEM_CD
                                   ) OCI,
                                   (
                                    SELECT ORD_GRP,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_STORE
                                     WHERE ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                       AND COMP_CD  =  PSV_COMP_CD
                                       AND BRAND_CD =  PSV_BRAND_CD
                                       AND STOR_CD  =  PSV_STOR_CD
                                       AND USE_YN   = 'Y'
                                     GROUP BY ORD_GRP
                                   ) OST,
                                   (
                                    SELECT ITEM_CD,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '1'
                                       AND OE1.ITEM_DIV  = 'I'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE1.COMP_CD   = OE3.COMP_CD
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ITEM_CD
                                   ) OEI,
                                   (
                                    SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OC.ACC_CD     = '1'
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEA,
                                   (
                                    SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '1'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ORD_GRP
                                   ) OEG ,
                                   (
                                    SELECT ITEM_CD,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.ITEM_DIV  = 'I'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ITEM_CD
                                   ) OEI2,
                                   (
                                    SELECT '1' SEQ ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE NULL END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE NULL END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE NULL END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEI2_CHK,
                                   (
                                    SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD =  PSV_BRAND_CD
                                                                                AND OES.STOR_CD  =  PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD =  PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEA2,
                                   (
                                    SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1' FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD =  PSV_BRAND_CD
                                                                                AND OES.STOR_CD  =  PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1' FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD =  PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ORD_GRP
                                   ) OEG2 ,
                                   (
                                    SELECT ITEM_CD,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3,
                                           (
                                            SELECT 'S' STOR_DIV, SEQ, BRAND_CD, STOR_CD, USE_YN
                                              FROM OC_EXC_STORE  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                            UNION ALL
                                            SELECT 'B' STOR_DIV, SEQ, BRAND_CD, STOR_TP, USE_YN
                                              FROM OC_EXC_BRAND  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                           ) OE4,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '3'
                                       AND OE1.ITEM_DIV  = 'I'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND OE1.SEQ = OE4.SEQ (+)
                                       AND ( OE1.STOR_DIV    = OE4.STOR_DIV (+) AND  OE4.BRAND_CD (+) =  PSV_BRAND_CD AND
                                             OE4.STOR_CD (+) = CASE WHEN OE1.STOR_DIV = 'S' THEN  PSV_STOR_CD ELSE ls_stor_tp END
                                             AND OE4.USE_YN (+) = 'Y'
                                           )
                                      GROUP BY ITEM_CD
                                   ) OEI3,
                                   (
                                    SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           (
                                            SELECT 'S' STOR_DIV, SEQ, BRAND_CD, STOR_CD, USE_YN
                                              FROM OC_EXC_STORE  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                            UNION ALL
                                            SELECT 'B' STOR_DIV, SEQ, BRAND_CD, STOR_TP, USE_YN
                                              FROM OC_EXC_BRAND  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                           ) OE4,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '3'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( OE1.STOR_DIV = OE4.STOR_DIV (+) AND OE4.BRAND_CD (+) =  PSV_BRAND_CD AND
                                             OE4.STOR_CD (+) = CASE WHEN OE1.STOR_DIV = 'S' THEN  PSV_STOR_CD ELSE ls_stor_tp END
                                             AND OE4.USE_YN (+) = 'Y'
                                           )
                                   ) OEA3,
                                   (
                                    SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL ) THEN 0 ELSE NULL  END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3,
                                           (
                                            SELECT 'S' STOR_DIV, SEQ, BRAND_CD, STOR_CD, USE_YN
                                              FROM OC_EXC_STORE  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                            UNION ALL
                                            SELECT 'B' STOR_DIV, SEQ, BRAND_CD, STOR_TP, USE_YN
                                              FROM OC_EXC_BRAND  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                           ) OE4,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '3'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ    = OE3.SEQ (+)
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ     = OE2.SEQ
                                       AND OE2.USE_YN  = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( OE1.STOR_DIV = OE4.STOR_DIV (+) AND  OE4.BRAND_CD (+) =  PSV_BRAND_CD AND
                                             OE4.STOR_CD (+) = CASE WHEN OE1.STOR_DIV = 'S' THEN  PSV_STOR_CD ELSE ls_stor_tp END
                                             AND OE4.USE_YN (+) = 'Y'
                                           )
                                     GROUP BY ORD_GRP
                                   ) OEG3 ,
                                   O_COLLECT OLM,
                                   O_DDAY  OSD ,
                                   O_CLASS IG  ,
                                   LANG_ITEM IL
                             WHERE I.ITEM_CD   = OI.ITEM_CD
                               AND OI.ORD_GRP  = OS.ORD_GRP
                               AND OI.ORD_GRP  = OT.ORD_GRP
                               AND I.ITEM_CD   = OCI.ITEM_CD (+)
                               AND OI.ORD_GRP  = OST.ORD_GRP
                               AND I.ITEM_CD   = OEI.ITEM_CD (+)
                               AND OI.ORD_GRP  = OEG.ORD_GRP (+)
                               AND I.ITEM_CD   = OEI2.ITEM_CD(+)
                               AND OI.ORD_GRP  = OEG2.ORD_GRP(+)
                               AND I.ITEM_CD   = OEI3.ITEM_CD(+)
                               AND OI.ORD_GRP  = OEG3.ORD_GRP(+)
                               AND '1'         = OEI2_CHK.SEQ(+)
                               AND I.ITEM_CD   = OLM.ITEM_CD (+)
                               AND '3'         = OLM.EVT_FG  (+)
                               AND OI.ORD_GRP  = OSD.ORD_GRP
                               AND I.ORD_SGRP  = IG.CLASS_CD (+)
                               AND I.ITEM_CD   = IL.ITEM_CD  (+)
                               AND IL.LANGUAGE_TP (+)=  PSV_LANG_CD
                           ) OI,
                           O_TR OQ,
                           (
                            SELECT ITEM_CD,
                                   SUM(CASE WHEN SALE_DT = C_ODATE    THEN SALE_QTY ELSE 0 END) GRD_AMT,
                                   SUM(CASE WHEN SALE_DT = C_PW_ODATE THEN SALE_QTY ELSE 0 END) GRD_PW_AMT
                              FROM SALE_JDM
                             WHERE SALE_DT IN ( C_ODATE, C_PW_ODATE )
                               AND COMP_CD  =  PSV_COMP_CD
                               AND BRAND_CD =  PSV_BRAND_CD
                               AND STOR_CD  =  PSV_STOR_CD
                             GROUP BY ITEM_CD
                           ) SQ,
                           (
                            SELECT B.ITEM_CD
                              FROM (
                                    SELECT MAX(START_DT) START_DT
                                      FROM REJECT_SYSTEM
                                     WHERE USE_YN    = 'Y'
                                       AND COMP_CD   = PSV_COMP_CD
                                       AND BRAND_CD  = PSV_BRAND_CD
                                       AND STOR_CD   = PSV_STOR_CD
                                       AND START_DT <= C_SDATE1
                                   )  A,
                                   REJECT_SYSTEM_ITEM B
                             WHERE B.COMP_CD  = PSV_COMP_CD
                               AND B.BRAND_CD = PSV_BRAND_CD
                               AND B.STOR_CD  = PSV_STOR_CD
                               AND A.START_DT = B.START_DT
                               AND B.USE_YN   = 'Y'
                           ) RS,
                           (
                            SELECT C.CODE_CD, NVL(L.CODE_NM, C.CODE_NM) CODE_NM
                              FROM COMMON C, LANG_COMMON L
                             WHERE C.COMP_CD = L.COMP_CD(+)
                               AND C.CODE_CD = L.CODE_CD(+)
                               AND C.COMP_CD = PSV_COMP_CD
                               AND C.CODE_TP = '00095' -- 미선출단위
                               AND C.CODE_TP = L.CODE_TP(+)
                               AND L.LANGUAGE_TP (+) =  PSV_LANG_CD
                           ) C_00095
                     WHERE OI.ITEM_CD = OQ.ITEM_CD (+)
                       AND OI.ITEM_CD = SQ.ITEM_CD (+)
                       AND OI.ITEM_CD = RS.ITEM_CD (+)
                       AND OI.ORD_UNIT = C_00095.CODE_CD (+)
                       AND ( SUBSTR(ORD_CONTROL_1,7,5) = 'YYYYY' OR
                             SUBSTR(ORD_CONTROL_2,7,5) = 'YYYYY' OR
                             SUBSTR(ORD_CONTROL_3,7,5) = 'YYYYY' OR
                             OQ.ORD_QTY1 <> 0 OR
                             OQ.ORD_QTY2 <> 0 OR
                             OQ.ORD_QTY3 <> 0
                           )
                   ) A1
           ) A
     WHERE ( CNT >= 2 OR  ( CNT = 1 AND SORT_ORDER  = '1' ) )
     ORDER BY GRP_SORT, CLASS_NM, ORD_GRP, SORT_ORDER, TO_NUMBER( CASE WHEN SORT_ORDER  = '0' THEN '0' ELSE ROW_NO END );
     
    PR_RTN_CD := ls_err_cd ;
    
    -- dbms_output.enable( 1000000 ) ;
    -- dbms_output.put_line( ls_sql ) ;
    
  EXCEPTION
    WHEN ERR_HANDLER THEN
         PR_RTN_CD := ls_err_cd ;
    WHEN OTHERS THEN
      -- dbms_output.put_line( sqlerrM ) ;
         PR_RTN_CD := ERR_4999999 ;
  END;
  
  PROCEDURE SP_ORDER_LIST_DB
  (
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ITEM_DIV    IN  VARCHAR2    -- 주문그룹
  , PSV_ITEM_TP     IN  VARCHAR2    -- 제품타입
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RESULT       IN OUT PKG_REPORT.REF_CUR
  ) IS
    
    C_SDATE_N1    CONSTANT  NUMBER(1)  :=  0;
    C_SDATE_N2    CONSTANT  NUMBER(1)  :=  0;
    C_SDATE_N3    CONSTANT  NUMBER(1)  :=  0;
    
    C_ODATE       VARCHAR2(8)  := TO_CHAR( SYSDATE    , 'YYYYMMDD') ;   -- 주문 일자
    C_NDATE       VARCHAR2(8)  := TO_CHAR( SYSDATE +1 , 'YYYYMMDD') ;   -- 주문 일자 + 1일 (입고예정수량)
    C_PW_ODATE    VARCHAR2(8)  := TO_CHAR( SYSDATE -7 , 'YYYYMMDD') ;   -- 전주 주문 일자
    
    C_SDATE1      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'YYYYMMDD') ; --1차 배송일자
    C_SDATE2      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'YYYYMMDD') ; --2차 배송일자
    C_SDATE3      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'YYYYMMDD') ; --3차 배송일자
    
    C_PD_SDATE1   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 -1 , 'YYYYMMDD') ; --전일 1차 배송일자
    C_PD_SDATE2   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 -1 , 'YYYYMMDD') ; --전일 2차 배송일자
    C_PD_SDATE3   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 -1 , 'YYYYMMDD') ; --전일 3차 배송일자
    
    C_PW_SDATE1   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 -7 , 'YYYYMMDD') ; --전주 1차 배송일자
    C_PW_SDATE2   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 -7 , 'YYYYMMDD') ; --전주 2차 배송일자
    C_PW_SDATE3   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 -7 , 'YYYYMMDD') ; --전주 3차 배송일자
    
    C_SDAY1       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'D') ; --1차 배송요일
    C_SDAY2       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'D') ; --2차 배송요일
    C_SDAY3       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'D') ; --3차 배송요일
    
    ls_err_cd     VARCHAR2(7) ;
    
    ls_stor_tp      STORE.STOR_TP%TYPE;
    ls_ord_tp       VARCHAR2(1); -- PARA_BRAND로 전환[20160126 표준화]
    ls_confirm_div  VARCHAR2(1); -- TABLE 정리[20160126 표준화]
    ls_use_yn       STORE.USE_YN%TYPE;
    ls_center_cd    STORE.CENTER_CD%TYPE;
    
    ln_week_new     PLS_INTEGER;
  BEGIN
    
    ls_err_cd := ERR_4000000  ;
    
    -- 주문 분류 항목 결정
    BEGIN
      SELECT PARA_VAL
        INTO ls_ord_tp
        FROM PARA_BRAND
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND PARA_CD  = '1003'; -- 주문분류
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_err_cd := ERR_4000003 ;
           RAISE ERR_HANDLER ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    BEGIN
      SELECT VAL_N1
        INTO ln_week_new
        FROM COMMON
       WHERE COMP_CD  = PSV_COMP_CD
         AND CODE_TP = '01330' -- 금주 신규 기간
         AND CODE_CD = '1' ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ln_week_new := 7 ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    BEGIN
      SELECT STOR_TP, '9', CENTER_CD, USE_YN
        INTO ls_stor_tp, ls_confirm_div, ls_center_cd, ls_use_yn
        FROM STORE
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND STOR_CD  = PSV_STOR_CD ;
         
      IF ls_confirm_div <> '9' THEN
         ls_err_cd :=  4000004;
         RAISE  ERR_HANDLER;
      ELSIF ls_use_yn IS NULL OR ls_use_yn <> 'Y' THEN
         ls_err_cd :=  4000005;
         RAISE  ERR_HANDLER;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_err_cd := ERR_4000002 ;
           RAISE ERR_HANDLER ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    OPEN PR_RESULT FOR
    SELECT ROW_NO,
           ITEM_CD_NM,
           DIV,
           SALE_RANK,
           ORD_1ST,
           BASIC,
           ORD_2ND,
           ORD_3RD,
           ORD_UNIT,
           ORD_UNIT_QTY,
           STOCK_EXP_QTY,
           BD_ORD_1ST,
           BD_ORD_2ND,
           BD_ORD_3RD,
           LW_ORD_1ST,
           LW_ORD_2ND,
           LW_ORD_3RD,
           DAY_SALE_AMT,
           LW_SALE_AMT,
           ITEM_CD,
           ORD_CONTROL_1,
           ORD_CONTROL_2,
           ORD_CONTROL_3,
           ORD_B_CNT,
           MIN_ORD_QTY,
           ALERT_ORD_QTY,
           ORD_COST_1,
           ORD_COST_2,
           ORD_COST_3,
           ORD_AMT_1,
           ORD_AMT_2,
           ORD_AMT_3,
           ITEM_DIV,
           ORD_GRP,
           ORD_GRP_CD,
           MERGE_DIV,
           SEARCH_TXT,
           BASIC_CHK ,
           DIV_CHK ,
           RTN_CHK ,
           SORT_ORDER
      FROM (
            WITH O_GRP AS
            (SELECT ORD_GRP , CONTROL_DIV
               FROM OC_ORD_GRP A
              WHERE COMP_CD = PSV_COMP_CD
                AND USE_YN  = 'Y'
                AND EXISTS (SELECT '1'
                              FROM OC_ORD_GRP_STORE B
                             WHERE A.COMP_CD  = B.COMP_CD
                               AND A.ORD_GRP  = B.ORD_GRP
                               AND B.COMP_CD  = PSV_COMP_CD
                               AND B.BRAND_CD = PSV_BRAND_CD
                               AND B.STOR_CD  = PSV_STOR_CD
                           )
            ) ,
            O_CLASS AS
            (
             SELECT B1.L_CLASS_CD CLASS_CD ,
                    NVL(B2.LANG_NM , B1.L_CLASS_NM) CLASS_NM ,
                    '▶  ' ||  NVL(B2.LANG_NM , B1.L_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                    B1.SORT_ORDER,
                    B1.L_CLASS_CD CLASS_CD2
               FROM ITEM_L_CLASS B1,
                    LANG_TABLE B2
              WHERE B2.COMP_CD  (+) = PSV_COMP_CD
                AND B2.TABLE_NM (+) = 'ITEM_L_CLASS'
                AND B2.COL_NM   (+) = 'L_CLASS_NM'
                AND B2.LANGUAGE_TP(+)= PSV_LANG_CD
                AND B1.ORG_CLASS_CD || B1.L_CLASS_CD = B2.PK_COL (+)
                AND B1.COMP_CD      = PSV_COMP_CD
                AND B1.ORG_CLASS_CD = '00'
                AND ls_ord_tp       = 'L'
             UNION ALL
             SELECT B1.L_CLASS_CD || B1.M_CLASS_CD CLASS_CD ,
                    NVL(B2.LANG_NM , B1.M_CLASS_NM) CLASS_NM ,
                     '▶  ' ||  NVL(B2.LANG_NM , B1.M_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                    B1.SORT_ORDER ,
                    B1.M_CLASS_CD CLASS_CD2
               FROM ITEM_M_CLASS B1,
                    LANG_TABLE B2
              WHERE B2.COMP_CD  (+) = PSV_COMP_CD
                AND B2.TABLE_NM (+) = 'ITEM_M_CLASS'
                AND B2.COL_NM   (+) = 'M_CLASS_NM'
                AND B2.LANGUAGE_TP(+)= PSV_LANG_CD
                AND B1.ORG_CLASS_CD || B1.L_CLASS_CD || B1.M_CLASS_CD = B2.PK_COL (+)
                AND B1.COMP_CD      = PSV_COMP_CD
                AND B1.ORG_CLASS_CD = '00'
                AND ls_ord_tp       = 'M'
             UNION ALL
             SELECT B1.L_CLASS_CD || B1.M_CLASS_CD || B1.S_CLASS_CD CLASS_CD ,
                    NVL(B2.LANG_NM , B1.S_CLASS_NM) CLASS_NM ,
                     '▶  ' ||  NVL(B2.LANG_NM , B1.S_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                    B1.SORT_ORDER,
                    B1.S_CLASS_CD CLASS_CD2
               FROM ITEM_S_CLASS B1,
                    LANG_TABLE B2
              WHERE B2.COMP_CD  (+) = PSV_COMP_CD
                AND B2.TABLE_NM (+) = 'ITEM_S_CLASS'
                AND B2.COL_NM   (+) = 'S_CLASS_NM'
                AND B2.LANGUAGE_TP(+)= PSV_LANG_CD
                AND B1.ORG_CLASS_CD || B1.L_CLASS_CD || B1.M_CLASS_CD || B1.S_CLASS_CD = B2.PK_COL (+)
                AND B1.COMP_CD      = PSV_COMP_CD
                AND B1.ORG_CLASS_CD = '00'
                AND ls_ord_tp       = 'S'
            ) ,
            O_TR AS
            (SELECT COMP_CD, ORD_GRP, ITEM_CD,
                    SUM(CASE WHEN SHIP_DT = C_SDATE1    AND ORD_SEQ = C_SEQ1 THEN ORD_QTY  ELSE 0 END) ORD_QTY1,
                    SUM(CASE WHEN SHIP_DT = C_SDATE2    AND ORD_SEQ = C_SEQ2 THEN ORD_QTY  ELSE 0 END) ORD_QTY2,
                    SUM(CASE WHEN SHIP_DT = C_SDATE3    AND ORD_SEQ = C_SEQ3 THEN ORD_QTY  ELSE 0 END) ORD_QTY3,
                    SUM(CASE WHEN SHIP_DT = C_PD_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_QTY  ELSE 0 END) ORD_PD_QTY1,
                    SUM(CASE WHEN SHIP_DT = C_PD_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_QTY  ELSE 0 END) ORD_PD_QTY2,
                    SUM(CASE WHEN SHIP_DT = C_PD_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_QTY  ELSE 0 END) ORD_PD_QTY3,
                    SUM(CASE WHEN SHIP_DT = C_PW_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY1,
                    SUM(CASE WHEN SHIP_DT = C_PW_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY2,
                    SUM(CASE WHEN SHIP_DT = C_PW_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY3,
                    SUM(CASE WHEN SHIP_DT = C_NDATE     AND ORD_SEQ = C_SEQ1 THEN ORD_CQTY ELSE 0 END) ORD_OD_QTY
               FROM ORDER_DT
              WHERE ( SHIP_DT, ORD_SEQ ) IN ( (C_SDATE1,    C_SEQ1) , (C_SDATE2,    C_SEQ2) , (C_SDATE3,    C_SEQ3) ,
                                              (C_PD_SDATE1, C_SEQ1) , (C_PD_SDATE2, C_SEQ2) , (C_PD_SDATE3, C_SEQ3) ,
                                              (C_PW_SDATE1, C_SEQ1) , (C_PW_SDATE2, C_SEQ2) , (C_PW_SDATE3, C_SEQ3) ,
                                              (C_ODATE,     C_SEQ1) , (C_NDATE,     C_SEQ1) )
                AND COMP_CD  = PSV_COMP_CD
                AND BRAND_CD = PSV_BRAND_CD
                AND STOR_CD  = PSV_STOR_CD
                AND ORD_FG   = PSV_ORD_FG
              GROUP BY COMP_CD, ORD_GRP, ITEM_CD
            )
            SELECT ROW_NO,
                   ITEM_CD_NM,
                   DIV,
                   SALE_RANK,
                   ORD_1ST,
                   BASIC,
                   ORD_2ND,
                   ORD_3RD,
                   ORD_UNIT,
                   ORD_UNIT_QTY,
                   STOCK_EXP_QTY,
                   BD_ORD_1ST,
                   BD_ORD_2ND,
                   BD_ORD_3RD,
                   LW_ORD_1ST,
                   LW_ORD_2ND,
                   LW_ORD_3RD,
                   DAY_SALE_AMT,
                   LW_SALE_AMT,
                   LIMIT_QTY,
                   ORD_QTY,
                   STCK_QTY,
                   ORD_ADD_1ST,
                   ORD_COLLECT_MSG,
                   ITEM_CD,
                   ORD_CONTROL_1,
                   ORD_CONTROL_2,
                   ORD_CONTROL_3,
                   ORD_B_CNT,
                   MIN_ORD_QTY,
                   ALERT_ORD_QTY,
                   ORD_COST_1,
                   ORD_COST_2,
                   ORD_COST_3,
                   '0' ORD_AMT_1,
                   '0' ORD_AMT_2,
                   '0' ORD_AMT_3,
                   ITEM_DIV,
                   ORD_GRP,
                   ORD_GRP_CD,
                   ORD_TP,
                   MERGE_DIV,
                   SEARCH_TXT,
                   BASIC_CHK ,
                   SORT_ORDER ,
                   GRP_SORT,
                   CLASS_NM,
                   DIV_CHK ,
                   RTN_CHK,
                   COUNT(1) OVER ( PARTITION BY GRP_SORT, CLASS_NM, ORD_GRP ) CNT
              FROM (
                    SELECT ' '              ROW_NO,
                           OC.GRP_CLASS_NM  ITEM_CD_NM,
                           OC.GRP_CLASS_NM  DIV,
                           OC.GRP_CLASS_NM  SALE_RANK,
                           OC.GRP_CLASS_NM  ORD_1ST,
                           OC.GRP_CLASS_NM  BASIC,
                           OC.GRP_CLASS_NM  ORD_2ND,
                           OC.GRP_CLASS_NM  ORD_3RD,
                           OC.GRP_CLASS_NM  ORD_UNIT,
                           OC.GRP_CLASS_NM  ORD_UNIT_QTY,
                           OC.GRP_CLASS_NM  STOCK_EXP_QTY,
                           OC.GRP_CLASS_NM  BD_ORD_1ST,
                           OC.GRP_CLASS_NM  BD_ORD_2ND,
                           OC.GRP_CLASS_NM  BD_ORD_3RD,
                           OC.GRP_CLASS_NM  LW_ORD_1ST,
                           OC.GRP_CLASS_NM  LW_ORD_2ND,
                           OC.GRP_CLASS_NM  LW_ORD_3RD,
                           OC.GRP_CLASS_NM  DAY_SALE_AMT,
                           OC.GRP_CLASS_NM  LW_SALE_AMT,
                           OC.GRP_CLASS_NM  LIMIT_QTY,
                           OC.GRP_CLASS_NM  ORD_QTY,
                           OC.GRP_CLASS_NM  STCK_QTY,
                           OC.GRP_CLASS_NM  ORD_ADD_1ST,
                           OC.GRP_CLASS_NM  ORD_COLLECT_MSG,
                           ' '              ITEM_CD,
                           ' '              ORD_CONTROL_1,
                           ' '              ORD_CONTROL_2,
                           ' '              ORD_CONTROL_3,
                           ' '              ORD_B_CNT,
                           ' '              MIN_ORD_QTY,
                           ' '              ALERT_ORD_QTY,
                           ' '              ORD_COST_1,
                           ' '              ORD_COST_2,
                           ' '              ORD_COST_3,
                           ' '              ORD_AMT_1,
                           ' '              ORD_AMT_2,
                           ' '              ORD_AMT_3,
                           ' '              ITEM_DIV,
                           OC.CLASS_CD      ORD_GRP,
                           OC.CLASS_CD2     ORD_GRP_CD,
                           ls_ord_tp        ORD_TP,
                           'T'              MERGE_DIV,
                           'T' || OC.CLASS_CD SEARCH_TXT,
                           ' '              BASIC_CHK,
                           '0'              SORT_ORDER,
                           OC.SORT_ORDER    GRP_SORT,
                           OC.CLASS_NM      CLASS_NM,
                           ' '              DIV_CHK,
                           ' '              RTN_CHK
                      FROM OC_ORD_GRP_ITEM OI,
                           ITEM_CHAIN      I,
                           O_CLASS         OC
                     WHERE I.COMP_CD   = PSV_COMP_CD
                       AND I.BRAND_CD  = PSV_BRAND_CD
                       AND I.STOR_TP   = ls_stor_tp
                       AND OI.ORD_GRP  IN ( SELECT ORD_GRP FROM O_GRP )
                       AND OI.COMP_CD  = I.COMP_CD
                       AND OI.ITEM_CD  = I.ITEM_CD
                       AND OC.CLASS_CD = CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                              WHEN ls_ord_tp= 'M' THEN I.L_CLASS_CD || I.M_CLASS_CD
                                              WHEN ls_ord_tp= 'S' THEN I.L_CLASS_CD || I.M_CLASS_CD || I.S_CLASS_CD
                                              ELSE NULL
                                         END
                     GROUP BY OC.CLASS_CD, OC.CLASS_CD2, OC.CLASS_NM, OC.GRP_CLASS_NM, OC.SORT_ORDER
                    UNION ALL
                    SELECT TO_CHAR( ROW_NUMBER() OVER ( PARTITION BY OI.CLASS_NM, OI.ORD_SGRP ORDER BY OI.ITEM_NM ) ) ROW_NO,
                           OI.ITEM_NM ITEM_CD_NM,
                           ' '  DIV,
                           TO_CHAR(OI.SALE_RANK) SALE_RANK  ,
                           NVL( DECODE(TO_CHAR( OQ.ORD_QTY1 ), '0', '',  TO_CHAR( OQ.ORD_QTY1 )) , '' )  ORD_1ST,
                           ' ' BASIC,
                           NVL( DECODE(TO_CHAR( OQ.ORD_QTY2 ), '0', '',  TO_CHAR( OQ.ORD_QTY2 )) , '' )  ORD_2ND,
                           NVL( DECODE(TO_CHAR( OQ.ORD_QTY3 ), '0', '',  TO_CHAR( OQ.ORD_QTY3 )) , '' )  ORD_3RD,
                           C_00095.CODE_NM ORD_UNIT  ,
                           TO_CHAR(OI.ORD_UNIT_QTY) ORD_UNIT_QTY ,
                           NVL( TO_CHAR( OQ.ORD_OD_QTY  ) , '0' )  STOCK_EXP_QTY,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY1 ) , '0' )  BD_ORD_1ST,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY2 ) , '0' )  BD_ORD_2ND,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY3 ) , '0' )  BD_ORD_3RD,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY1 ) , '0' )  LW_ORD_1ST,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY2 ) , '0' )  LW_ORD_2ND,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY3 ) , '0' )  LW_ORD_3RD,
                           NVL( TO_CHAR( SQ.GRD_AMT )     , '0' )  DAY_SALE_AMT ,
                           NVL( TO_CHAR( SQ.GRD_PW_AMT )  , '0' )  LW_SALE_AMT,
                           NVL( TO_CHAR( OI.LIMIT_QTY )   , '0' )  LIMIT_QTY,
                           NVL( TO_CHAR( OI.ORD_QTY )     , '0' )  ORD_QTY,
                           NVL( TO_CHAR( OI.LIMIT_QTY - OI.ORD_QTY)   , '0' )  STCK_QTY,
                           '0'  ORD_ADD_1ST,
                           OI.ORD_COLLECT_MSG ,
                           OI.ITEM_CD,
                           CASE WHEN IB.ITEM_CD IS NULL THEN SUBSTR(OI.ORD_CONTROL_1,1,1) || 'N' || SUBSTR(OI.ORD_CONTROL_1,3) ELSE  OI.ORD_CONTROL_1 END ORD_CONTROL_1,
                           CASE WHEN IB.ITEM_CD IS NULL THEN SUBSTR(OI.ORD_CONTROL_2,1,1) || 'N' || SUBSTR(OI.ORD_CONTROL_2,3) ELSE  OI.ORD_CONTROL_2 END ORD_CONTROL_2,
                           CASE WHEN IB.ITEM_CD IS NULL THEN SUBSTR(OI.ORD_CONTROL_3,1,1) || 'N' || SUBSTR(OI.ORD_CONTROL_3,3) ELSE  OI.ORD_CONTROL_3 END ORD_CONTROL_3,
                           TO_CHAR(OI.ORD_B_CNT) ORD_B_CNT,
                           TO_CHAR(OI.MIN_ORD_QTY) MIN_ORD_QTY,
                           TO_CHAR(OI.ALERT_ORD_QTY) ALERT_ORD_QTY,
                           TO_CHAR(OI.COST1) ORD_COST_1,
                           TO_CHAR(OI.COST2) ORD_COST_2,
                           TO_CHAR(OI.COST3) ORD_COST_3,
                           NVL( TO_CHAR(OQ.ORD_QTY1 * OI.COST1) , '0' ) ORD_AMT_1,
                           NVL( TO_CHAR(OQ.ORD_QTY2 * OI.COST2) , '0' ) ORD_AMT_2,
                           NVL( TO_CHAR(OQ.ORD_QTY3 * OI.COST3) , '0' ) ORD_AMT_3,
                           OI.ITEM_DIV,
                           OI.ORD_SGRP,
                           OI.ORD_SGRP_CD,
                           ls_ord_tp    ORD_TP,
                           'I' MERGE_DIV,
                           'I' || OI.ORD_SGRP SEARCH_TXT,
                           OI.BASIC_CHK ,
                           '1' SORT_ORDER ,
                           OI.SORT_ORDER GRP_SORT,
                           OI.CLASS_NM ,
                           OI.DIV DIV_CHK ,
                           CASE WHEN RS.ITEM_CD IS NULL THEN '0' ELSE '1' END RTN_CHK
                      FROM (WITH ITEM_FLAG_ALL AS
                            (
                             SELECT ITEM_CD ,
                                    CASE MIN ( NEW_TP )
                                         WHEN 1  THEN '4'
                                         WHEN 2  THEN '5'
                                         WHEN 3  THEN '3'
                                         WHEN 4  THEN '2'
                                         WHEN 5  THEN '1'
                                         ELSE         '0'
                                    END NEW_TP
                               FROM (
                                     SELECT ITEM_CD,
                                            CASE A.ITEM_FG
                                                 WHEN  '04' THEN 1
                                                 WHEN  '01' THEN CASE WHEN START_DT + ln_week_new >=  C_ODATE THEN 4 ELSE 5 END
                                             END NEW_TP
                                       FROM ITEM_FLAG A  , COMMON B
                                      WHERE A.COMP_CD = PSV_COMP_CD
                                        AND A.ITEM_FG IN ( '01' , '04' )
                                        AND A.USE_YN  = 'Y'
                                        AND C_ODATE BETWEEN CASE WHEN B.VAL_C1 = 'Y' THEN START_DT ELSE '00000000' END
                                                        AND CASE WHEN B.VAL_C1 = 'Y' THEN END_DT   ELSE '99999999' END
                                        AND B.CODE_TP = '01090' -- 작업구분[01:신상품, 02:집중상품, 03:행사상품, 04:중단]
                                        AND B.COMP_CD = A.COMP_CD
                                        AND B.CODE_CD = A.ITEM_FG
                                     UNION ALL /*
                                     SELECT C.ITEM_CD, 3 NEW_TP
                                       FROM CAMPAIGN_MST A, CAMPAIGN_ITEM C
                                      WHERE A.CAMPAIGN_STAT = 'C'
                                        AND C_ODATE BETWEEN A.START_DT AND A.END_DT
                                        AND A.COMP_CD     = PSV_COMP_CD
                                        AND A.BRAND_CD    = PSV_BRAND_CD
                                        AND A.COMP_CD     = C.COMP_CD
                                        AND A.BRAND_CD    = C.BRAND_CD
                                        AND A.CAMPAIGN_CD = C.CAMPAIGN_CD
                                        AND A.STOR_CD     = C.STOR_CD
                                        AND ( A.STOR_CD   = PSV_STOR_CD  OR
                                              EXISTS (SELECT '1'
                                                        FROM CAMPAIGN_STORE  S
                                                       WHERE S.COMP_CD  = A.COMP_CD
                                                         AND S.BRAND_CD = A.BRAND_CD
                                                         AND S.CAMPAIGN_CD = A.CAMPAIGN_CD
                                                         AND S.COMP_CD  = PSV_COMP_CD
                                                         AND S.STOR_CD  = PSV_STOR_CD
                                                         AND S.USE_YN   = 'Y'
                                                     )
                                            )
                                        AND A.USE_YN = 'Y'
                                        AND C.USE_YN = 'Y'
                                     UNION ALL */
                                     SELECT ITEM_CD,  2
                                       FROM REJECT_SYSTEM A, REJECT_SYSTEM_ITEM B
                                      WHERE A.COMP_CD  = B.COMP_CD
                                        AND A.BRAND_CD = B.BRAND_CD
                                        AND A.STOR_CD  = B.STOR_CD
                                        AND A.START_DT = B.START_DT
                                        AND A.USE_YN   = 'Y'
                                        AND B.USE_YN   = 'Y'
                                        AND A.COMP_CD  = PSV_COMP_CD
                                        AND A.BRAND_CD = PSV_BRAND_CD
                                        AND A.STOR_CD  = PSV_STOR_CD
                                        AND A.START_DT <= C_ODATE
                                    ) A
                              GROUP BY ITEM_CD
                            ),
                            O_CTL_TM AS
                            (
                             SELECT ORD_GRP,
                                    ORD_SEQ ,
                                    ORD_START_TM,
                                    ORD_END_TM,
                                    ORD_END_DDAY
                               FROM OC_STORE_TM
                              WHERE USE_YN   = 'Y'
                                AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                AND COMP_CD  = PSV_COMP_CD
                                AND BRAND_CD = PSV_BRAND_CD
                                AND STOR_CD  = PSV_STOR_CD
                                AND ( SHIP_DT, ORD_SEQ ) IN ( ( C_SDATE1, C_SEQ1 ), ( C_SDATE2, C_SEQ2 ), ( C_SDATE3, C_SEQ3 ) )
                             UNION ALL
                             SELECT OTM.ORD_GRP ,
                                    OTM.ORD_SEQ ,
                                    OTM.ORD_START_TM,
                                    OTM.ORD_END_TM,
                                    OTM.ORD_END_DDAY
                               FROM (
                                     SELECT ORD_GRP,
                                            ORD_SEQ ,
                                            ORD_START_TM,
                                            ORD_END_TM,
                                            ORD_END_DDAY
                                       FROM OC_ORD_GRP_TM OGT
                                      WHERE USE_YN     = 'Y'
                                        AND COMP_CD    = PSV_COMP_CD
                                        AND ORD_GRP   IN ( SELECT ORD_GRP FROM O_GRP )
                                        AND OC_WRK_DIV = '1'
                                        AND NOT EXISTS (SELECT '1'
                                                          FROM OC_CENTER_TM OCT
                                                         WHERE OCT.CENTER_CD  = ls_center_cd
                                                           AND OCT.USE_YN     = 'Y'
                                                           AND OCT.OC_WRK_DIV = '1'
                                                           AND OCT.COMP_CD    = OGT.COMP_CD
                                                           AND OCT.ORD_GRP    = OGT.ORD_GRP
                                                       )
                                     UNION ALL
                                     SELECT ORD_GRP ,
                                            ORD_SEQ ,
                                            ORD_START_TM,
                                            ORD_END_TM,
                                            ORD_END_DDAY
                                       FROM OC_CENTER_TM
                                      WHERE USE_YN     = 'Y'
                                        AND COMP_CD    = PSV_COMP_CD
                                        AND ORD_GRP   IN ( SELECT ORD_GRP FROM O_GRP )
                                        AND OC_WRK_DIV = '1'
                                        AND CENTER_CD  = ls_center_cd
                                    ) OTM
                              WHERE NOT EXISTS (SELECT '1' FROM OC_STORE_TM OCT
                                                 WHERE OCT.COMP_CD  = PSV_COMP_CD
                                                   AND OCT.BRAND_CD = PSV_BRAND_CD
                                                   AND OCT.STOR_CD  = PSV_STOR_CD
                                                   AND OCT.USE_YN   = 'Y'
                                                   AND OCT.ORD_GRP  = OTM.ORD_GRP
                                                   AND OCT.ORD_SEQ  = OTM.ORD_SEQ
                                                   AND OCT.SHIP_DT  = CASE OTM.ORD_SEQ WHEN C_SEQ1 THEN C_SDATE1
                                                                                       WHEN C_SEQ2 THEN C_SDATE2
                                                                                       WHEN C_SEQ3 THEN C_SDATE3
                                                                                       ELSE NULL END
                                               )
                            ),
                            O_DDAY AS
                            (
                             SELECT ORD_GRP,
                                    CHK1, CHK2, CHK3,
                                    D_DAY1, D_DAY2, D_DAY3,
                                    TO_CHAR( TO_DATE(C_SDATE1, 'YYYYMMDD') - NVL(D_DAY1,-1) , 'YYYYMMDD') CHK_DT1,
                                    TO_CHAR( TO_DATE(C_SDATE2, 'YYYYMMDD') - NVL(D_DAY2,-1) , 'YYYYMMDD') CHK_DT2,
                                    TO_CHAR( TO_DATE(C_SDATE3, 'YYYYMMDD') - NVL(D_DAY3,-1) , 'YYYYMMDD') CHK_DT3
                               FROM (
                                     SELECT ORD_GRP,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN ORD_DDAY ELSE NULL END ) D_DAY3
                                       FROM OC_ORD_GRP_DDAY
                                      WHERE COMP_CD  = PSV_COMP_CD
                                        AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP WHERE CONTROL_DIV = 'Q' )
                                        AND ( ORD_SEQ, DLV_WK ) IN ( ( C_SEQ1, C_SDAY1 ), ( C_SEQ2, C_SDAY2 ), ( C_SEQ3, C_SDAY3 ) )
                                      GROUP BY ORD_GRP
                                     UNION ALL
                                     SELECT ORD_GRP,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY3
                                       FROM OC_STORE_DDAY
                                      WHERE ORD_GRP IN (SELECT ORD_GRP FROM O_GRP WHERE CONTROL_DIV = 'S' )
                                        AND COMP_CD  =  PSV_COMP_CD
                                        AND BRAND_CD =  PSV_BRAND_CD
                                        AND STOR_CD  =  PSV_STOR_CD
                                        AND DLV_WK  IN ( C_SDAY1, C_SDAY2, C_SDAY3 )
                                      GROUP BY ORD_GRP
                                    ) OD
                              WHERE ORD_GRP IS NOT NULL
                            ) ,
                            O_CHK_TM AS
                            (
                             SELECT ORD_GRP,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT1 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT1
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT1 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT1, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ1
                                                             AND ORD_GRP = O_DDAY.ORD_GRP
                                                         )                            THEN 1
                                         ELSE 0 END CHK1,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT2 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT2
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT2 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT2, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ2
                                                             AND ORD_GRP = O_DDAY.ORD_GRP
                                                         )                            THEN 1
                                         ELSE 0 END CHK2,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT3 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT3
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT3 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT3, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ3
                                                             AND ORD_GRP = O_DDAY.ORD_GRP
                                                         )
                                              THEN 1
                                         ELSE 0 END CHK3
                               FROM O_DDAY
                            ),
                            O_COLLECT AS
                            (SELECT A.EVT_FG   ,
                                    B.ITEM_CD  ,
                                    B.ORD_COLLECT_MSG  ,
                                    B.LIMIT_QTY,
                                    B.ORD_QTY
                               FROM ORDER_COLLECT_INFO A , ORDER_COLLECT_ITEM B
                              WHERE A.USE_YN = 'Y'
                                AND B.USE_YN = 'Y'
                                AND C_SDATE1 BETWEEN A.START_DT AND A.CLOSE_DT
                                AND A.COMP_CD  = PSV_COMP_CD
                                AND A.BRAND_CD = PSV_BRAND_CD
                                AND A.COMP_CD  = B.COMP_CD
                                AND A.BRAND_CD = B.BRAND_CD
                                AND A.ORD_COLLECT_NO = B.ORD_COLLECT_NO
                                AND EXISTS (SELECT '1' FROM ORDER_COLLECT_STORE C
                                             WHERE A.COMP_CD  = C.COMP_CD
                                               AND A.ORD_COLLECT_NO = C.ORD_COLLECT_NO
                                               AND A.BRAND_CD = C.BRAND_CD
                                               AND C.COMP_CD  = PSV_COMP_CD
                                               AND C.STOR_CD  = PSV_STOR_CD
                                               AND C.USE_YN   = 'Y'
                                           )
                            )
                            SELECT I.ITEM_CD,
                                   CASE WHEN IL.ITEM_NM IS NULL THEN I.ITEM_NM ELSE IL.ITEM_NM END ITEM_NM,
                                   OI.ORD_GRP,
                                   IG.CLASS_NM,
                                   IG.SORT_ORDER,
                                   I.DIV,
                                   I.SALE_RANK,
                                   I.NEW_TP,
                                   I.ORD_UNIT,
                                   I.ORD_UNIT_QTY,
                                   I.ORD_B_CNT,
                                   I.MIN_ORD_QTY,
                                   I.ALERT_ORD_QTY,
                                   I.ITEM_DIV,
                                   I.BASIC_CHK ,
                                   I.ORD_SGRP,
                                   I.ORD_SGRP_CD,
                                   I.COST1,
                                   I.COST2,
                                   I.COST3,
                                   CASE WHEN OS.CHK1   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK1   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK1  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK1  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK1   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK1 = 0 OR OCI.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK1 = 0 OR OEI.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK1 = 0 OR OEA.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK1 = 0 OR OEG.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OEI2_CHK.CHK1 IS NULL OR ( OEI2_CHK.CHK1 = 1 AND ( OEI2.CHK1 = 1 OR OEG2.CHK1 = 1 OR OEA2.CHK1 = 1) )
                                        THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN ( ( OEI3.CHK1 = 1 OR OEA3.CHK1 = 1 OR OEG3.CHK1 = 1 )  OR ( OEI3.CHK1 IS NULL AND  OEA3.CHK1 IS NULL AND OEG3.CHK1 IS NULL ) )   THEN 'Y' ELSE 'N' END
                                        AS ORD_CONTROL_1,
                                   CASE WHEN OS.CHK2   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK2   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK2  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK2  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK2   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK2 = 0 OR OCI.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK2 = 0 OR OEI.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK2 = 0 OR OEA.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK2 = 0 OR OEG.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OEI2_CHK.CHK2 IS NULL OR ( OEI2_CHK.CHK2 = 1 AND ( OEI2.CHK2 = 1 OR OEG2.CHK2 = 1 OR OEA2.CHK2 = 1) )
                                        THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN ( ( OEI3.CHK2 = 1 OR OEA3.CHK2 = 1 OR OEG3.CHK2 = 1 )  OR ( OEI3.CHK2 IS NULL AND  OEA3.CHK2 IS NULL AND OEG3.CHK2 IS NULL ) )   THEN 'Y' ELSE 'N' END
                                        AS ORD_CONTROL_2,
                                   CASE WHEN OS.CHK3   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK3   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK3  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK3  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK3   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK3 = 0 OR OCI.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK3 = 0 OR OEI.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK3 = 0 OR OEA.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK3 = 0 OR OEG.CHK3 IS NULL) THEN 'Y' ELSE 'N' END  ||
                                   CASE WHEN OEI2_CHK.CHK3 IS NULL OR ( OEI2_CHK.CHK3 = 1 AND ( OEI2.CHK3 = 1 OR OEG2.CHK3 = 1 OR OEA2.CHK3 = 1) )
                                        THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN ( ( OEI3.CHK3 = 1 OR OEA3.CHK3 = 1 OR OEG3.CHK3 = 1 )  OR ( OEI3.CHK3 IS NULL AND  OEA3.CHK3 IS NULL AND OEG3.CHK3 IS NULL ) )   THEN 'Y' ELSE 'N' END
                                        AS ORD_CONTROL_3,
                                   OLM.LIMIT_QTY,
                                   OLM.ORD_QTY  ,
                                   OLM.ORD_COLLECT_MSG
                              FROM (
                                    SELECT I.ITEM_CD ,
                                           CASE WHEN F.NEW_TP IS NULL THEN '0' ELSE F.NEW_TP END DIV,
                                           CASE WHEN C_SDATE1 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK1,
                                           CASE WHEN C_SDATE2 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK2,
                                           CASE WHEN C_SDATE3 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK3,
                                           IC.COST1,
                                           IC.COST2,
                                           IC.COST3,
                                           I.L_CLASS_CD,
                                           I.M_CLASS_CD,
                                           I.S_CLASS_CD,
                                           I.ITEM_NM ,
                                           CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                                WHEN ls_ord_tp= 'M' THEN I.L_CLASS_CD || I.M_CLASS_CD
                                                WHEN ls_ord_tp= 'S' THEN I.L_CLASS_CD || I.M_CLASS_CD || I.S_CLASS_CD
                                                ELSE NULL
                                           END ORD_SGRP,
                                           CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                                WHEN ls_ord_tp= 'M' THEN I.M_CLASS_CD
                                                WHEN ls_ord_tp= 'S' THEN I.S_CLASS_CD
                                                ELSE NULL
                                           END ORD_SGRP_CD,
                                           I.ITEM_DIV,
                                           I.ORD_UNIT,
                                           I.ORD_UNIT_QTY,
                                           I.ORD_B_CNT,
                                           I.ORD_START_DT,
                                           I.ORD_CLOSE_DT,
                                           I.MIN_ORD_QTY,
                                           I.ALERT_ORD_QTY,
                                           F.NEW_TP,
                                           0 SALE_RANK,
                                           CASE WHEN RI.ITEM_CD IS NULL THEN '0' ELSE '1' END BASIC_CHK
                                      FROM ITEM_CHAIN     I,
                                           ITEM_FLAG_ALL  F,
                                           (
                                            SELECT ITEM_CD, MAX(COST1) COST1 , MAX(COST2) COST2, MAX(COST3) COST3
                                              FROM (
                                                    SELECT ITEM_CD,
                                                           MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST1,
                                                           NULL COST2,
                                                           NULL COST3
                                                      FROM ITEM_CHAIN_HIS H
                                                     WHERE COMP_CD  = PSV_COMP_CD
                                                       AND BRAND_CD = PSV_BRAND_CD
                                                       AND STOR_TP  = ls_stor_tp
                                                       AND START_DT <= C_SDATE1
                                                     GROUP BY ITEM_CD
                                                    UNION ALL
                                                    SELECT ITEM_CD,
                                                           NULL COST1,
                                                           MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST2,
                                                           NULL COST3
                                                      FROM ITEM_CHAIN_HIS H
                                                     WHERE COMP_CD  = PSV_COMP_CD
                                                       AND BRAND_CD = PSV_BRAND_CD
                                                       AND STOR_TP = ls_stor_tp
                                                       AND START_DT <= C_SDATE2
                                                     GROUP BY ITEM_CD
                                                    UNION ALL
                                                    SELECT ITEM_CD,
                                                           NULL COST1,
                                                           NULL COST2,
                                                           MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST3
                                                      FROM ITEM_CHAIN_HIS H
                                                     WHERE COMP_CD  = PSV_COMP_CD
                                                       AND BRAND_CD = PSV_BRAND_CD
                                                       AND STOR_TP = ls_stor_tp
                                                       AND START_DT <= C_SDATE3
                                                     GROUP BY ITEM_CD
                                                   ) ICG
                                             GROUP BY ITEM_CD
                                           ) IC,
                                           (
                                            SELECT DISTINCT ITEM_CD
                                              FROM REF_ITEM
                                             WHERE COMP_CD = PSV_COMP_CD
                                               AND USE_YN  ='Y'
                                           ) RI
                                     WHERE I.STOR_TP = ls_stor_tp
                                       AND I.COMP_CD = PSV_COMP_CD
                                       AND I.BRAND_CD= PSV_BRAND_CD
                                       AND I.ITEM_CD = IC.ITEM_CD
                                       AND I.ITEM_CD = F.ITEM_CD (+)
                                       AND I.ITEM_CD = RI.ITEM_CD (+)
                                   ) I,
                                   (
                                    SELECT ORD_GRP ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_SEQ
                                     WHERE COMP_CD  = PSV_COMP_CD
                                       AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                     GROUP BY ORD_GRP
                                   ) OS,
                                   O_CHK_TM  OT,
                                   (
                                    SELECT ORD_GRP,
                                           ITEM_CD,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_ITEM
                                     WHERE COMP_CD  = PSV_COMP_CD
                                       AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                     GROUP BY ORD_GRP, ITEM_CD
                                   ) OI,
                                   (SELECT ITEM_CD ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY1  AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY2  AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY3  AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_CENTER_ITEM
                                     WHERE COMP_CD   = PSV_COMP_CD
                                       AND USE_YN    = 'Y'
                                       AND CENTER_CD = ls_center_cd
                                     GROUP BY ITEM_CD
                                   ) OCI,
                                   (
                                    SELECT ORD_GRP,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_STORE
                                     WHERE ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                       AND COMP_CD  = PSV_COMP_CD
                                       AND BRAND_CD = PSV_BRAND_CD
                                       AND STOR_CD  = PSV_STOR_CD
                                      GROUP BY ORD_GRP
                                   ) OST,
                                   (SELECT ITEM_CD ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '1'
                                       AND OE1.ITEM_DIV  = 'I'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ITEM_CD
                                   ) OEI,
                                   (
                                    SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OC.ACC_CD     = '1'
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEA,
                                   (
                                    SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '1'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1' FROM OC_EXC_STORE OES WHERE OE1.SEQ = OES.SEQ
                                                                             AND OES.COMP_CD  = PSV_COMP_CD
                                                                             AND OES.BRAND_CD = PSV_BRAND_CD
                                                                             AND OES.STOR_CD  = PSV_STOR_CD
                                                                             AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1' FROM OC_EXC_BRAND OES WHERE OE1.SEQ = OES.SEQ
                                                                             AND OES.COMP_CD  = PSV_COMP_CD
                                                                             AND OES.BRAND_CD = PSV_BRAND_CD
                                                                             AND OES.STOR_TP  = ls_stor_tp
                                                                             AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ORD_GRP
                                   ) OEG ,
                                   (
                                    SELECT ITEM_CD ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.ITEM_DIV  = 'I'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ITEM_CD
                                   ) OEI2,
                                   (
                                    SELECT '1' SEQ ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE NULL END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE NULL END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE NULL END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEI2_CHK,
                                   (
                                    SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEA2,
                                   (
                                    SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ORD_GRP
                                   ) OEG2 ,
                                   (
                                    SELECT ITEM_CD ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3,
                                           (SELECT 'S' STOR_DIV, SEQ, BRAND_CD, STOR_CD, USE_YN
                                              FROM OC_EXC_STORE  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                            UNION ALL
                                            SELECT 'B' STOR_DIV, SEQ, BRAND_CD, STOR_TP, USE_YN
                                              FROM OC_EXC_BRAND  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                           ) OE4,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '3'
                                       AND OE1.ITEM_DIV  = 'I'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND OE1.SEQ = OE4.SEQ (+)
                                       AND ( OE1.STOR_DIV = OE4.STOR_DIV (+) AND  OE4.BRAND_CD (+) = PSV_BRAND_CD AND
                                             OE4.STOR_CD (+) = CASE WHEN OE1.STOR_DIV = 'S' THEN PSV_STOR_CD ELSE ls_stor_tp END
                                             AND OE4.USE_YN (+) = 'Y'
                                           )
                                     GROUP BY ITEM_CD
                                   ) OEI3,
                                   (
                                    SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           (SELECT 'S' STOR_DIV, SEQ, BRAND_CD, STOR_CD, USE_YN
                                              FROM OC_EXC_STORE  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                            UNION ALL
                                            SELECT 'B' STOR_DIV, SEQ, BRAND_CD, STOR_TP, USE_YN
                                              FROM OC_EXC_BRAND  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                           ) OE4,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '3'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( OE1.STOR_DIV = OE4.STOR_DIV (+) AND OE4.BRAND_CD (+) = PSV_BRAND_CD AND
                                             OE4.STOR_CD (+) = CASE WHEN OE1.STOR_DIV = 'S' THEN PSV_STOR_CD ELSE ls_stor_tp END
                                             AND OE4.USE_YN (+) = 'Y'
                                           )
                                   ) OEA3,
                                   (SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL ) THEN 0 ELSE NULL  END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3,
                                           (SELECT 'S' STOR_DIV, SEQ, BRAND_CD, STOR_CD, USE_YN
                                              FROM OC_EXC_STORE  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                            UNION ALL
                                            SELECT 'B' STOR_DIV, SEQ, BRAND_CD, STOR_TP, USE_YN
                                              FROM OC_EXC_BRAND  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                           ) OE4,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '3'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( OE1.STOR_DIV = OE4.STOR_DIV (+) AND  OE4.BRAND_CD (+) = PSV_BRAND_CD AND
                                             OE4.STOR_CD (+) = CASE WHEN OE1.STOR_DIV = 'S' THEN PSV_STOR_CD ELSE ls_stor_tp END
                                             AND OE4.USE_YN (+) = 'Y'
                                           )
                                     GROUP BY ORD_GRP
                                   )         OEG3,
                                   O_COLLECT OLM,
                                   O_DDAY    OSD,
                                   O_CLASS   IG,
                                   LANG_ITEM IL
                             WHERE I.ITEM_CD   = OI.ITEM_CD (+)
                               AND OI.ORD_GRP  = OS.ORD_GRP (+)
                               AND OI.ORD_GRP  = OT.ORD_GRP (+)
                               AND I.ITEM_CD   = OCI.ITEM_CD (+)
                               AND OI.ORD_GRP  = OST.ORD_GRP (+)
                               AND I.ITEM_CD   = OEI.ITEM_CD (+)
                               AND OI.ORD_GRP  = OEG.ORD_GRP (+)
                               AND I.ITEM_CD   = OLM.ITEM_CD (+)
                               AND I.ITEM_CD   = OEI2.ITEM_CD (+)
                               AND OI.ORD_GRP  = OEG2.ORD_GRP (+)
                               AND I.ITEM_CD   = OEI3.ITEM_CD (+)
                               AND OI.ORD_GRP  = OEG3.ORD_GRP (+)
                               AND '1'         = OEI2_CHK.SEQ (+)
                               AND '3'         = OLM.EVT_FG  (+)
                               AND OI.ORD_GRP  = OSD.ORD_GRP(+)
                               AND I.ORD_SGRP  = IG.CLASS_CD (+)
                               AND I.ITEM_CD   = IL.ITEM_CD  (+)
                               AND IL.LANGUAGE_TP(+)= PSV_LANG_CD
                               AND IL.COMP_CD(+)    = PSV_COMP_CD
                           ) OI,
                           O_TR OQ,
                           (
                            SELECT ITEM_CD ,
                                   SUM(CASE WHEN SALE_DT = C_ODATE    THEN SALE_QTY ELSE 0 END) GRD_AMT,
                                   SUM(CASE WHEN SALE_DT = C_PW_ODATE THEN SALE_QTY ELSE 0 END) GRD_PW_AMT
                              FROM SALE_JDM
                             WHERE SALE_DT  IN ( C_ODATE, C_PW_ODATE )
                               AND COMP_CD  = PSV_COMP_CD
                               AND BRAND_CD = PSV_BRAND_CD
                               AND STOR_CD  = PSV_STOR_CD
                             GROUP BY ITEM_CD
                           ) SQ    ,
                           (
                            SELECT B.ITEM_CD
                              FROM (SELECT MAX(START_DT) START_DT
                                      FROM REJECT_SYSTEM
                                     WHERE USE_YN    = 'Y'
                                       AND BRAND_CD  = PSV_BRAND_CD
                                       AND STOR_CD   = PSV_STOR_CD
                                       AND START_DT <= C_SDATE1
                                   )  A,
                                   REJECT_SYSTEM_ITEM B
                             WHERE B.COMP_CD  = PSV_COMP_CD
                               AND B.BRAND_CD = PSV_BRAND_CD
                               AND B.STOR_CD  = PSV_STOR_CD
                               AND A.START_DT = B.START_DT
                               AND B.USE_YN   = 'Y'
                           ) RS,
                           (
                            SELECT C.CODE_CD, NVL(L.CODE_NM, C.CODE_NM) CODE_NM
                              FROM COMMON C, LANG_COMMON L
                             WHERE C.COMP_CD = L.COMP_CD(+)
                               AND C.CODE_CD = L.CODE_CD(+)
                               AND C.COMP_CD = PSV_COMP_CD
                               AND C.CODE_TP = '00095' -- 미선출단위
                               AND C.CODE_TP = L.CODE_TP(+)
                               AND L.LANGUAGE_TP(+) = PSV_LANG_CD
                           ) C_00095,
                           (
                            SELECT /*+ ORDERED */ 
                                   I.ITEM_CD
                              FROM ITEM_CHAIN I,
                                   (
                                    SELECT ITEM_CD, MAX(COST1) COST1 , MAX(COST2) COST2, MAX(COST3) COST3
                                      FROM (
                                            SELECT ITEM_CD,
                                                   MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST1,
                                                   NULL COST2,
                                                   NULL COST3
                                              FROM ITEM_CHAIN_HIS H
                                             WHERE COMP_CD   = PSV_COMP_CD
                                               AND BRAND_CD  = PSV_BRAND_CD
                                               AND STOR_TP   = ls_stor_tp
                                               AND START_DT <= C_SDATE1
                                             GROUP BY ITEM_CD
                                            UNION ALL
                                            SELECT ITEM_CD,
                                                   NULL COST1,
                                                   MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST2,
                                                   NULL COST3
                                              FROM ITEM_CHAIN_HIS H
                                             WHERE COMP_CD   = PSV_COMP_CD
                                               AND BRAND_CD  = PSV_BRAND_CD
                                               AND STOR_TP   = ls_stor_tp
                                               AND START_DT <= C_SDATE2
                                             GROUP BY ITEM_CD
                                            UNION ALL
                                            SELECT ITEM_CD,
                                                   NULL COST1,
                                                   NULL COST2,
                                                   MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST3
                                              FROM ITEM_CHAIN_HIS H
                                             WHERE COMP_CD   = PSV_COMP_CD
                                               AND BRAND_CD  = PSV_BRAND_CD
                                               AND STOR_TP   = ls_stor_tp
                                               AND START_DT <= C_SDATE3
                                            GROUP BY ITEM_CD
                                           ) ICG
                                     GROUP BY ITEM_CD
                                   ) IC
                             WHERE I.USE_YN        = 'Y'
                               AND I.STOR_TP       = ls_stor_tp
                               AND I.ORD_SALE_DIV IN('1', '2')
                               AND I.ORD_MNG_DIV   = '0'
                               AND I.COMP_CD       = PSV_COMP_CD
                               AND I.BRAND_CD      = PSV_BRAND_CD
                               AND (     C_SDATE1 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT, '9')
                                     OR  C_SDATE2 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT, '9')
                                     OR  C_SDATE3 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT, '9')
                                   )
                               AND I.ITEM_CD = IC.ITEM_CD
                           ) IB
                     WHERE OI.ORD_GRP (+) = OQ.ORD_GRP
                       AND OI.ITEM_CD (+) = OQ.ITEM_CD
                       AND OQ.ITEM_CD     = SQ.ITEM_CD (+)
                       AND OQ.ITEM_CD = RS.ITEM_CD (+)
                       AND OI.ORD_UNIT = C_00095.CODE_CD (+)
                       AND OQ.ITEM_CD  = IB.ITEM_CD (+)
                       AND ( OQ.ORD_QTY1 > 0 OR  OQ.ORD_QTY2 > 0 OR OQ.ORD_QTY3 > 0 )
                   ) A1
           ) A
     WHERE ( CNT >= 2 OR  ( CNT = 1 AND SORT_ORDER  = '1' ) )
     ORDER BY GRP_SORT, CLASS_NM, ORD_GRP, SORT_ORDER, TO_NUMBER( CASE WHEN SORT_ORDER  = '0' THEN '0' ELSE ROW_NO END );
    
    PR_RTN_CD := ls_err_cd ;
    
    -- dbms_output.enable( 1000000 ) ;
    -- dbms_output.put_line( ls_sql ) ;
    
  EXCEPTION
    WHEN ERR_HANDLER THEN
         PR_RTN_CD := ls_err_cd ;
    WHEN OTHERS THEN
         dbms_output.put_line( sqlerrM ) ;
         PR_RTN_CD := ERR_4999999 ;
  END;
  
  PROCEDURE SP_ORDER_LIST_LINK
  (
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ITEM_DIV    IN  VARCHAR2    -- 주문그룹
  , PSV_ITEM_TP     IN  VARCHAR2    -- 제품타입
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RESULT       IN OUT PKG_REPORT.REF_CUR
  ) IS
    
    C_ODATE       VARCHAR2(8)  := TO_CHAR( SYSDATE    , 'YYYYMMDD') ;   -- 주문 일자
    C_NDATE       VARCHAR2(8)  := TO_CHAR( SYSDATE +1 , 'YYYYMMDD') ;   -- 주문 일자 + 1일 (입고예정수량)
    C_PW_ODATE    VARCHAR2(8)  := TO_CHAR( SYSDATE -7 , 'YYYYMMDD') ;   -- 전주 주문 일자
    
    C_SDATE1      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'YYYYMMDD') ; --1차 배송일자
    C_SDATE2      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'YYYYMMDD') ; --2차 배송일자
    C_SDATE3      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'YYYYMMDD') ; --3차 배송일자
    
    C_PD_SDATE1   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 -1 , 'YYYYMMDD') ; --전일 1차 배송일자
    C_PD_SDATE2   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 -1 , 'YYYYMMDD') ; --전일 2차 배송일자
    C_PD_SDATE3   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 -1 , 'YYYYMMDD') ; --전일 3차 배송일자
    
    C_PW_SDATE1   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 -7 , 'YYYYMMDD') ; --전주 1차 배송일자
    C_PW_SDATE2   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 -7 , 'YYYYMMDD') ; --전주 2차 배송일자
    C_PW_SDATE3   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 -7 , 'YYYYMMDD') ; --전주 3차 배송일자
    
    C_SDAY1       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'D') ; --1차 배송요일
    C_SDAY2       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'D') ; --2차 배송요일
    C_SDAY3       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'D') ; --3차 배송요일
    
    ls_err_cd     VARCHAR2(7) ;
    
    ls_stor_tp      STORE.STOR_TP%TYPE;
    ls_ord_tp       VARCHAR2(1); -- PARA_BRAND로 전환[20160126 표준화]
    ls_confirm_div  VARCHAR2(1); -- TABLE 정리[20160126 표준화]
    ls_use_yn       STORE.USE_YN%TYPE;
    ls_center_cd    STORE.CENTER_CD%TYPE;
    
    ln_week_new     PLS_INTEGER  ;
  BEGIN
    
    ls_err_cd := ERR_4000000  ;
    
    -- 주문 분류 항목 결정
    BEGIN
      SELECT PARA_VAL
        INTO ls_ord_tp
        FROM PARA_BRAND
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND PARA_CD  = '1003'; -- 주문분류
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_err_cd := ERR_4000003 ;
           RAISE ERR_HANDLER ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    BEGIN
      SELECT VAL_N1
        INTO ln_week_new
        FROM COMMON
       WHERE COMP_CD = PSV_COMP_CD
         AND CODE_TP = '01330' -- 금주 신규 기간
         AND CODE_CD = '1' ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ln_week_new := 7 ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    BEGIN
      SELECT STOR_TP, '9', CENTER_CD, USE_YN
        INTO ls_stor_tp, ls_confirm_div, ls_center_cd, ls_use_yn
        FROM STORE
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND STOR_CD  = PSV_STOR_CD ;
         
      IF ls_confirm_div <> '9' THEN
         ls_err_cd :=  4000004;
         RAISE  ERR_HANDLER;
      ELSIF ls_use_yn IS NULL OR ls_use_yn <> 'Y' THEN
         ls_err_cd :=  4000005;
         RAISE  ERR_HANDLER;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_err_cd := ERR_4000002 ;
           RAISE ERR_HANDLER ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    -- OS : 주문그룹/차수 통제 (OC_ORD_GRP_SEQ)
    -- OI : 주문그룹/상품 통제 (OC_ORD_GRP_ITEM)
    OPEN PR_RESULT FOR
    SELECT ROW_NO ,
           ITEM_CD_NM,
           ORD_1ST,
           ORD_ADD_1ST,
           BD_ORD_1ST,
           ' ' APP_ITEM_VIEW,
           ITEM_CD,
           ORD_CONTROL_1,
           ORD_B_CNT,
           MIN_ORD_QTY,
           ALERT_ORD_QTY,
           ORD_COST_1,
           ORD_AMT_1,
           LW_ORD_1ST,
           DAY_SALE_AMT ,
           LW_SALE_AMT,
           SALE_RANK ,
           ORD_UNIT_QTY ,
           ORD_UNIT  ,
           STOCK_EXP_QTY ,
           ITEM_DIV,
           ORD_GRP,
           ORD_GRP_CD,
           MERGE_DIV,
           SEARCH_TXT,
           BASIC,
           BASIC_CHK ,
           DIV,
           DIV_CHK ,
           '0' APP_ITEM_VIEW_CHK,
           SORT_ORDER
      FROM (
            WITH O_GRP AS
            (
             SELECT ORD_GRP , CONTROL_DIV
               FROM OC_ORD_GRP A
              WHERE COMP_CD    = PSV_COMP_CD
                AND ORD_GRP    = '10'
                AND USE_YN     = 'Y'
                AND EXISTS (SELECT '1'
                              FROM OC_ORD_GRP_STORE B
                             WHERE A.COMP_CD  = B.COMP_CD
                               AND A.ORD_GRP  = B.ORD_GRP
                               AND B.COMP_CD  = PSV_COMP_CD
                               AND B.BRAND_CD = PSV_BRAND_CD
                               AND B.STOR_CD  = PSV_STOR_CD
                           )
            ) ,
            O_CLASS AS
            (
             SELECT B1.L_CLASS_CD CLASS_CD ,
                     NVL(B2.LANG_NM , B1.L_CLASS_NM) CLASS_NM ,
                     '▶  ' ||  NVL(B2.LANG_NM , B1.L_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                     B1.SORT_ORDER,
                     B1.L_CLASS_CD CLASS_CD2
                FROM ITEM_L_CLASS B1,
                     LANG_TABLE B2
               WHERE B2.COMP_CD  (+) = PSV_COMP_CD
                 AND B2.TABLE_NM (+) = 'ITEM_L_CLASS'
                 AND B2.COL_NM   (+) = 'L_CLASS_NM'
                 AND B2.LANGUAGE_TP(+)= PSV_LANG_CD
                 AND B1.ORG_CLASS_CD || B1.L_CLASS_CD = B2.PK_COL (+)
                 AND B1.ORG_CLASS_CD = '00'
                 AND B1.COMP_CD      = PSV_COMP_CD
                 AND ls_ord_tp       = 'L'
              UNION ALL
              SELECT B1.L_CLASS_CD || B1.M_CLASS_CD CLASS_CD ,
                     NVL(B2.LANG_NM , B1.M_CLASS_NM) CLASS_NM ,
                      '▶  ' ||  NVL(B2.LANG_NM , B1.M_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                     B1.SORT_ORDER ,
                     B1.M_CLASS_CD CLASS_CD2
                FROM ITEM_M_CLASS B1,
                     LANG_TABLE B2
               WHERE B2.COMP_CD  (+) = PSV_COMP_CD
                 AND B2.TABLE_NM (+) = 'ITEM_M_CLASS'
                 AND B2.COL_NM   (+) = 'M_CLASS_NM'
                 AND B2.LANGUAGE_TP(+)= PSV_LANG_CD
                 AND B1.ORG_CLASS_CD || B1.L_CLASS_CD || B1.M_CLASS_CD = B2.PK_COL (+)
                 AND B1.COMP_CD      = PSV_COMP_CD
                 AND B1.ORG_CLASS_CD = '00'
                 AND ls_ord_tp       = 'M'
              UNION ALL
              SELECT B1.L_CLASS_CD || B1.M_CLASS_CD || B1.S_CLASS_CD CLASS_CD ,
                     NVL(B2.LANG_NM , B1.S_CLASS_NM) CLASS_NM ,
                      '▶  ' ||  NVL(B2.LANG_NM , B1.S_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                     B1.SORT_ORDER,
                     B1.S_CLASS_CD CLASS_CD2
                FROM ITEM_S_CLASS B1,
                     LANG_TABLE B2
               WHERE B2.COMP_CD  (+) = PSV_COMP_CD
                 AND B2.TABLE_NM (+) = 'ITEM_S_CLASS'
                 AND B2.COL_NM   (+) = 'S_CLASS_NM'
                 AND B2.LANGUAGE_TP(+)= PSV_LANG_CD
                 AND B1.ORG_CLASS_CD || B1.L_CLASS_CD || B1.M_CLASS_CD || B1.S_CLASS_CD = B2.PK_COL (+)
                 AND B1.COMP_CD      = PSV_COMP_CD
                 AND B1.ORG_CLASS_CD = '00'
                 AND ls_ord_tp       = 'S'
            ) ,
            O_TR AS
            (
             SELECT ITEM_CD,
                    SUM(CASE WHEN SHIP_DT = C_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_QTY ELSE 0 END) ORD_QTY1,
                    SUM(CASE WHEN SHIP_DT = C_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_QTY ELSE 0 END) ORD_QTY2,
                    SUM(CASE WHEN SHIP_DT = C_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_QTY ELSE 0 END) ORD_QTY3,
                    SUM(CASE WHEN SHIP_DT = C_PD_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_QTY ELSE 0 END) ORD_PD_QTY1,
                    SUM(CASE WHEN SHIP_DT = C_PD_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_QTY ELSE 0 END) ORD_PD_QTY2,
                    SUM(CASE WHEN SHIP_DT = C_PD_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_QTY ELSE 0 END) ORD_PD_QTY3,
                    SUM(CASE WHEN SHIP_DT = C_PW_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY1,
                    SUM(CASE WHEN SHIP_DT = C_PW_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY2,
                    SUM(CASE WHEN SHIP_DT = C_PW_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY3,
                    SUM(CASE WHEN SHIP_DT = C_NDATE AND ORD_SEQ = C_SEQ1 THEN ORD_CQTY ELSE 0 END) ORD_OD_QTY
               FROM ORDER_DT
              WHERE ( SHIP_DT, ORD_SEQ ) IN ( (C_SDATE1,    C_SEQ1) , (C_SDATE2,    C_SEQ2) , (C_SDATE3,    C_SEQ3) ,
                                              (C_PD_SDATE1, C_SEQ1) , (C_PD_SDATE2, C_SEQ2) , (C_PD_SDATE3, C_SEQ3) ,
                                              (C_PW_SDATE1, C_SEQ1) , (C_PW_SDATE2, C_SEQ2) , (C_PW_SDATE3, C_SEQ3) ,
                                              (C_ODATE,     C_SEQ1) , (C_NDATE,     C_SEQ1) )
                AND COMP_CD  = PSV_COMP_CD
                AND BRAND_CD = PSV_BRAND_CD
                AND STOR_CD  = PSV_STOR_CD
                AND ORD_FG   = PSV_ORD_FG
              GROUP BY ITEM_CD
            )
            SELECT ROW_NO,
                   ITEM_CD_NM,
                   ORD_UNIT_QTY,
                   ORD_1ST,
                   ORD_ADD_1ST,
                   ORD_COST_1,
                   ORD_AMT_1,
                   BD_ORD_1ST,
                   ITEM_CD,
                   ORD_CONTROL_1,
                   ORD_CONTROL_2,
                   ORD_CONTROL_3,
                   ORD_B_CNT,
                   MIN_ORD_QTY,
                   ALERT_ORD_QTY,
                   BD_ORD_2ND,
                   BD_ORD_3RD,
                   LW_ORD_1ST,
                   LW_ORD_2ND,
                   LW_ORD_3RD,
                   DAY_SALE_AMT,
                   LW_SALE_AMT,
                   SALE_RANK,
                   ORD_UNIT,
                   STOCK_EXP_QTY,
                   ITEM_DIV,
                   ORD_GRP,
                   ORD_GRP_CD,
                   MERGE_DIV,
                   SEARCH_TXT,
                   BASIC,
                   BASIC_CHK,
                   DIV,
                   DIV_CHK,
                   SORT_ORDER,
                   CLASS_NM ,
                   GRP_SORT,
                   COUNT(1) OVER ( PARTITION BY GRP_SORT, CLASS_NM , ORD_GRP ) CNT
              FROM (
                    SELECT ' '              ROW_NO,
                           OC.GRP_CLASS_NM  ITEM_CD_NM,
                           OC.GRP_CLASS_NM  ORD_UNIT_QTY,
                           OC.GRP_CLASS_NM  ORD_1ST,
                           OC.GRP_CLASS_NM  ORD_ADD_1ST,
                           OC.GRP_CLASS_NM  ORD_COST_1,
                           OC.GRP_CLASS_NM  ORD_AMT_1,
                           OC.GRP_CLASS_NM  BD_ORD_1ST,
                           ' '              ITEM_CD,
                           ' '              ORD_CONTROL_1,
                           ' '              ORD_CONTROL_2,
                           ' '              ORD_CONTROL_3,
                           ' '              ORD_B_CNT,
                           ' '              MIN_ORD_QTY,
                           ' '              ALERT_ORD_QTY,
                           ' '              BD_ORD_2ND,
                           ' '              BD_ORD_3RD,
                           ' '              LW_ORD_1ST,
                           ' '              LW_ORD_2ND,
                           ' '              LW_ORD_3RD,
                           ' '              DAY_SALE_AMT,
                           ' '              LW_SALE_AMT,
                           ' '              SALE_RANK,
                           ' '              ORD_UNIT,
                           ' '              STOCK_EXP_QTY,
                           ' '              ITEM_DIV,
                           OC.CLASS_CD      ORD_GRP,
                           OC.CLASS_CD2     ORD_GRP_CD,
                           'T'              MERGE_DIV,
                           'T' || OC.CLASS_CD SEARCH_TXT,
                           ' '              BASIC,
                           ' '              BASIC_CHK,
                           ' '              DIV,
                           ' '              DIV_CHK,
                           '0'              SORT_ORDER,
                           OC.CLASS_NM,
                           OC.SORT_ORDER    GRP_SORT
                      FROM OC_ORD_GRP_ITEM OI,
                           ITEM_CHAIN      I,
                           O_CLASS         OC
                     WHERE I.COMP_CD   = PSV_COMP_CD
                       AND I.BRAND_CD  = PSV_BRAND_CD
                       AND OI.ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                       AND OI.COMP_CD  = I.COMP_CD
                       AND OI.ITEM_CD  = I.ITEM_CD
                       AND I.STOR_TP = ls_stor_tp
                       AND OC.CLASS_CD = CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                              WHEN ls_ord_tp= 'M' THEN I.L_CLASS_CD || I.M_CLASS_CD
                                              WHEN ls_ord_tp= 'S' THEN I.L_CLASS_CD || I.M_CLASS_CD || I.S_CLASS_CD
                                              ELSE NULL
                                         END
                     GROUP BY OC.CLASS_CD, OC.CLASS_CD2, OC.CLASS_NM, OC.GRP_CLASS_NM, OC.SORT_ORDER
                    UNION ALL
                    SELECT TO_CHAR( ROW_NUMBER() OVER (  PARTITION BY OI.CLASS_NM , OI.ORD_SGRP ORDER BY OI.ITEM_NM ) ) ROW_NO ,
                           OI.ITEM_NM ITEM_CD_NM,
                           TO_CHAR(OI.ORD_UNIT_QTY) ORD_UNIT_QTY ,
                           NVL( TO_CHAR( OQ.ORD_QTY1 ) , '0' )  ORD_1ST,
                           '0' ORD_ADD_1ST,
                           TO_CHAR(OI.COST1) ORD_COST_1,
                           NVL( TO_CHAR( OQ.ORD_QTY1 * OI.COST1 ) , '0' )  ORD_AMT_1,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY1 ) , '0' )  BD_ORD_1ST,
                           OI.ITEM_CD,
                           OI.ORD_CONTROL_1,
                           OI.ORD_CONTROL_2,
                           OI.ORD_CONTROL_3,
                           TO_CHAR(OI.ORD_B_CNT) ORD_B_CNT,
                           TO_CHAR(OI.MIN_ORD_QTY) MIN_ORD_QTY,
                           TO_CHAR(OI.ALERT_ORD_QTY) ALERT_ORD_QTY,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY2 ) , '0' )  BD_ORD_2ND,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY3 ) , '0' )  BD_ORD_3RD,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY1 ) , '0' )  LW_ORD_1ST,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY2 ) , '0' )  LW_ORD_2ND,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY3 ) , '0' )  LW_ORD_3RD,
                           NVL( TO_CHAR( SQ.GRD_AMT )     , '0' )  DAY_SALE_AMT ,
                           NVL( TO_CHAR( SQ.GRD_PW_AMT )  , '0' )  LW_SALE_AMT,
                           TO_CHAR(OI.SALE_RANK) SALE_RANK  ,
                           C_00095.CODE_NM ORD_UNIT  ,
                           NVL( TO_CHAR( OQ.ORD_OD_QTY  ) , '0' )  STOCK_EXP_QTY,
                           OI.ITEM_DIV,
                           OI.ORD_SGRP,
                           OI.ORD_SGRP_CD,
                           'I' MERGE_DIV,
                           'I' || OI.ORD_SGRP SEARCH_TXT,
                           ' ' BASIC,
                           OI.BASIC_CHK ,
                           ' ' DIV,
                           OI.DIV DIV_CHK ,
                           '1' SORT_ORDER ,
                           OI.CLASS_NM ,
                           OI.SORT_ORDER GRP_SORT
                      FROM (
                            WITH ITEM_FLAG_ALL AS
                            (SELECT ITEM_CD ,
                                    CASE MIN ( NEW_TP )
                                         WHEN 1  THEN '4'
                                         WHEN 2  THEN '5'
                                         WHEN 3  THEN '3'
                                         WHEN 4  THEN '2'
                                         WHEN 5  THEN '1'
                                         ELSE         '0'
                                    END NEW_TP
                               FROM (
                                     SELECT ITEM_CD,
                                            CASE A.ITEM_FG
                                                 WHEN  '04' THEN 1
                                                 WHEN  '01' THEN CASE WHEN START_DT + ln_week_new >=  C_ODATE THEN 4 ELSE 5 END
                                            END NEW_TP
                                       FROM ITEM_FLAG A  , COMMON B
                                      WHERE A.COMP_CD = PSV_COMP_CD
                                        AND A.ITEM_FG IN  ( '01' , '04' )
                                        AND A.USE_YN  = 'Y'
                                        AND C_ODATE BETWEEN CASE WHEN B.VAL_C1 = 'Y' THEN START_DT ELSE '00000000' END
                                                        AND CASE WHEN B.VAL_C1 = 'Y' THEN END_DT   ELSE '99999999' END
                                        AND B.CODE_TP = '01090' -- 작업구분[01:신상품, 02:집중상품, 03:행사상품, 04:중단]
                                        AND B.COMP_CD = A.COMP_CD
                                        AND B.CODE_CD = A.ITEM_FG
                                     UNION ALL /*
                                     SELECT C.ITEM_CD , 3 NEW_TP
                                       FROM CAMPAIGN_MST A, CAMPAIGN_ITEM C
                                      WHERE A.CAMPAIGN_STAT = 'C'
                                        AND C_ODATE BETWEEN A.START_DT AND A.END_DT
                                        AND A.COMP_CD     = PSV_COMP_CD
                                        AND A.BRAND_CD    = PSV_BRAND_CD
                                        AND A.COMP_CD     = C.COMP_CD
                                        AND A.BRAND_CD    = C.BRAND_CD
                                        AND A.CAMPAIGN_CD = C.CAMPAIGN_CD
                                        AND A.STOR_CD     = C.STOR_CD
                                        AND ( A.STOR_CD   = PSV_STOR_CD  OR
                                              EXISTS (SELECT '1' FROM CAMPAIGN_STORE  S
                                                       WHERE S.COMP_CD     = A.COMP_CD
                                                         AND S.BRAND_CD    = A.BRAND_CD
                                                         AND S.CAMPAIGN_CD = A.CAMPAIGN_CD
                                                         AND S.COMP_CD     = PSV_COMP_CD
                                                         AND S.STOR_CD     = PSV_STOR_CD
                                                         AND S.USE_YN      = 'Y'
                                                     )
                                            )
                                        AND A.USE_YN      = 'Y'
                                        AND C.USE_YN      = 'Y'
                                     UNION ALL */
                                     SELECT ITEM_CD,  2
                                       FROM REJECT_SYSTEM A, REJECT_SYSTEM_ITEM B
                                      WHERE A.COMP_CD  = B.COMP_CD
                                        AND A.BRAND_CD = B.BRAND_CD
                                        AND A.STOR_CD  = B.STOR_CD
                                        AND A.START_DT = B.START_DT
                                        AND A.USE_YN   = 'Y'
                                        AND B.USE_YN   = 'Y'
                                        AND A.COMP_CD  = PSV_COMP_CD
                                        AND A.BRAND_CD = PSV_BRAND_CD
                                        AND A.STOR_CD  = PSV_STOR_CD
                                        AND A.START_DT <= C_ODATE
                                    ) A
                              GROUP BY ITEM_CD
                            ),
                            O_CTL_TM AS
                            (
                              SELECT ORD_GRP,
                                     ORD_SEQ ,
                                     ORD_START_TM,
                                     ORD_END_TM,
                                     ORD_END_DDAY
                                FROM OC_STORE_TM
                               WHERE USE_YN   = 'Y'
                                 AND ORD_GRP  IN ( SELECT ORD_GRP FROM O_GRP )
                                 AND COMP_CD  = PSV_COMP_CD
                                 AND BRAND_CD = PSV_BRAND_CD
                                 AND STOR_CD  = PSV_STOR_CD
                                 AND (SHIP_DT, ORD_SEQ) IN ( ( C_SDATE1, C_SEQ1 ), ( C_SDATE2, C_SEQ2 ), ( C_SDATE3, C_SEQ3 ) )
                              UNION ALL
                              SELECT OTM.ORD_GRP ,
                                     OTM.ORD_SEQ ,
                                     OTM.ORD_START_TM,
                                     OTM.ORD_END_TM,
                                     OTM.ORD_END_DDAY
                                FROM (
                                      SELECT ORD_GRP,
                                             ORD_SEQ ,
                                             ORD_START_TM,
                                             ORD_END_TM,
                                             ORD_END_DDAY
                                        FROM OC_ORD_GRP_TM OGT
                                       WHERE COMP_CD    = PSV_COMP_CD
                                         AND USE_YN     = 'Y'
                                         AND ORD_GRP   IN (SELECT ORD_GRP FROM O_GRP)
                                         AND OC_WRK_DIV = '1'
                                         AND NOT EXISTS (SELECT '1'
                                                           FROM OC_CENTER_TM OCT
                                                          WHERE OCT.COMP_CD    = PSV_COMP_CD
                                                            AND OCT.CENTER_CD  = ls_center_cd
                                                            AND OCT.USE_YN     = 'Y'
                                                            AND OCT.OC_WRK_DIV = '1'
                                                            AND OCT.COMP_CD    = OGT.COMP_CD
                                                            AND OCT.ORD_GRP    = OGT.ORD_GRP
                                                        )
                                      UNION ALL
                                      SELECT ORD_GRP ,
                                             ORD_SEQ ,
                                             ORD_START_TM,
                                             ORD_END_TM,
                                             ORD_END_DDAY
                                        FROM OC_CENTER_TM
                                       WHERE COMP_CD    = PSV_COMP_CD
                                         AND USE_YN     = 'Y'
                                         AND ORD_GRP   IN ( SELECT ORD_GRP FROM O_GRP )
                                         AND OC_WRK_DIV = '1'
                                         AND CENTER_CD  = ls_center_cd
                                     ) OTM
                               WHERE NOT EXISTS (SELECT '1'
                                                   FROM OC_STORE_TM OCT
                                                  WHERE OCT.COMP_CD  = PSV_COMP_CD
                                                    AND OCT.BRAND_CD = PSV_BRAND_CD
                                                    AND OCT.STOR_CD  = PSV_STOR_CD
                                                    AND OCT.USE_YN   = 'Y'
                                                    AND OCT.ORD_GRP  = OTM.ORD_GRP
                                                    AND OCT.ORD_SEQ  = OTM.ORD_SEQ
                                                    AND OCT.SHIP_DT  = CASE OTM.ORD_SEQ WHEN C_SEQ1 THEN C_SDATE1
                                                                                        WHEN C_SEQ2 THEN C_SDATE2
                                                                                        WHEN C_SEQ3 THEN C_SDATE3
                                                                                        ELSE NULL END
                                                )
                            ),
                            O_DDAY AS
                            (
                             SELECT ORD_GRP,
                                    CHK1, CHK2, CHK3,
                                    D_DAY1, D_DAY2, D_DAY3,
                                    TO_CHAR( TO_DATE(C_SDATE1, 'YYYYMMDD') - NVL(D_DAY1,-1) , 'YYYYMMDD') CHK_DT1,
                                    TO_CHAR( TO_DATE(C_SDATE2, 'YYYYMMDD') - NVL(D_DAY2,-1) , 'YYYYMMDD') CHK_DT2,
                                    TO_CHAR( TO_DATE(C_SDATE3, 'YYYYMMDD') - NVL(D_DAY3,-1) , 'YYYYMMDD') CHK_DT3
                               FROM (
                                     SELECT ORD_GRP,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN ORD_DDAY ELSE NULL END ) D_DAY3
                                       FROM OC_ORD_GRP_DDAY
                                      WHERE COMP_CD  = PSV_COMP_CD
                                        AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP WHERE CONTROL_DIV = 'Q' )
                                        AND ( ORD_SEQ, DLV_WK )  IN ( ( C_SEQ1, C_SDAY1 ), ( C_SEQ2, C_SDAY2 ), ( C_SEQ3, C_SDAY3 ) )
                                      GROUP BY ORD_GRP
                                      UNION ALL
                                     SELECT ORD_GRP,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY3
                                       FROM OC_STORE_DDAY
                                      WHERE ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP WHERE CONTROL_DIV = 'S' )
                                        AND COMP_CD  = PSV_COMP_CD
                                        AND BRAND_CD = PSV_BRAND_CD
                                        AND STOR_CD  = PSV_STOR_CD
                                        AND DLV_WK  IN ( C_SDAY1, C_SDAY2, C_SDAY3 )
                                      GROUP BY ORD_GRP
                                    ) OD
                              WHERE ORD_GRP IS NOT NULL
                            ) ,
                            O_CHK_TM AS
                            (
                             SELECT ORD_GRP ,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT1 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT1
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT1 || ORD_START_TM AND TO_CHAR(TO_DATE (CHK_DT1, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ1
                                                         )
                                              THEN 1
                                         ELSE 0 END CHK1,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT2 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT2
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT2 || ORD_START_TM AND TO_CHAR(TO_DATE (CHK_DT2, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ2
                                                         )
                                              THEN 1
                                         ELSE 0 END CHK2,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT3 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT3
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT3 || ORD_START_TM AND TO_CHAR(TO_DATE (CHK_DT3, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ3
                                                         )
                                              THEN 1
                                         ELSE 0 END CHK3
                               FROM O_DDAY
                            ),
                            O_COLLECT AS
                            (
                             SELECT A.EVT_FG,
                                    B.ITEM_CD,
                                    B.ORD_COLLECT_MSG,
                                    B.LIMIT_QTY,
                                    B.ORD_QTY
                               FROM ORDER_COLLECT_INFO A, ORDER_COLLECT_ITEM B
                              WHERE A.USE_YN   = 'Y'
                                AND B.USE_YN   = 'Y'
                                AND C_SDATE1 BETWEEN A.START_DT AND A.CLOSE_DT
                                AND A.COMP_CD  = PSV_COMP_CD
                                AND A.BRAND_CD = PSV_BRAND_CD
                                AND A.COMP_CD  = B.COMP_CD
                                AND A.BRAND_CD = B.BRAND_CD
                                AND A.ORD_COLLECT_NO = B.ORD_COLLECT_NO
                                AND EXISTS (SELECT '1' FROM ORDER_COLLECT_STORE C
                                             WHERE A.COMP_CD  = C.COMP_CD
                                               AND A.ORD_COLLECT_NO = C.ORD_COLLECT_NO
                                               AND A.BRAND_CD = C.BRAND_CD
                                               AND C.COMP_CD  = PSV_COMP_CD
                                               AND C.STOR_CD  = PSV_STOR_CD
                                               AND C.USE_YN   = 'Y'
                                           )
                            )
                            SELECT I.ITEM_CD ,
                                   CASE WHEN IL.ITEM_NM IS NULL THEN I.ITEM_NM ELSE IL.ITEM_NM END ITEM_NM,
                                   IG.CLASS_NM,
                                   IG.SORT_ORDER,
                                   I.DIV,
                                   I.SALE_RANK,
                                   I.NEW_TP,
                                   I.ORD_UNIT,
                                   I.ORD_UNIT_QTY,
                                   I.ORD_B_CNT,
                                   I.MIN_ORD_QTY,
                                   I.ALERT_ORD_QTY,
                                   I.ITEM_DIV,
                                   I.BASIC_CHK ,
                                   I.ORD_SGRP,
                                   I.ORD_SGRP_CD,
                                   I.COST1,
                                   I.COST2,
                                   I.COST3,
                                   CASE WHEN OS.CHK1 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK1 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK1 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK1 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK1 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK1 = 0 OR OCI.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK1 = 0 OR OEI.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK1 = 0 OR OEA.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK1 = 0 OR OEG.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OEI2_CHK.CHK1 IS NULL OR ( OEI2_CHK.CHK1 = 1 AND ( OEI2.CHK1 = 1 OR OEG2.CHK1 = 1 OR OEA2.CHK1 = 1) )
                                        THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN ( ( OEI3.CHK1 = 1 OR OEA3.CHK1 = 1 OR OEG3.CHK1 = 1 )  OR ( OEI3.CHK1 IS NULL AND  OEA3.CHK1 IS NULL AND OEG3.CHK1 IS NULL ) )   THEN 'Y' ELSE 'N' END
                                        AS ORD_CONTROL_1,
                                   CASE WHEN OS.CHK2 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK2 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK2 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK2 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK2 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK2 = 0 OR OCI.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK2 = 0 OR OEI.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK2 = 0 OR OEA.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK2 = 0 OR OEG.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OEI2_CHK.CHK2 IS NULL OR ( OEI2_CHK.CHK2 = 1 AND ( OEI2.CHK2 = 1 OR OEG2.CHK2 = 1 OR OEA2.CHK2 = 1) )
                                        THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN ( ( OEI3.CHK2 = 1 OR OEA3.CHK2 = 1 OR OEG3.CHK2 = 1 )  OR ( OEI3.CHK2 IS NULL AND  OEA3.CHK2 IS NULL AND OEG3.CHK2 IS NULL ) )   THEN 'Y' ELSE 'N' END
                                        AS ORD_CONTROL_2,
                                   CASE WHEN OS.CHK3 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK3 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK3 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK3 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK3 = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK3 = 0 OR OCI.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK3 = 0 OR OEI.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK3 = 0 OR OEA.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK3 = 0 OR OEG.CHK3 IS NULL) THEN 'Y' ELSE 'N' END  ||
                                   CASE WHEN OEI2_CHK.CHK3 IS NULL OR ( OEI2_CHK.CHK3 = 1 AND ( OEI2.CHK3 = 1 OR OEG2.CHK3 = 1 OR OEA2.CHK3 = 1) )
                                        THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN ( ( OEI3.CHK3 = 1 OR OEA3.CHK3 = 1 OR OEG3.CHK3 = 1 )  OR ( OEI3.CHK3 IS NULL AND  OEA3.CHK3 IS NULL AND OEG3.CHK3 IS NULL ) )   THEN 'Y' ELSE 'N' END
                                        AS ORD_CONTROL_3
                              FROM (
                                    SELECT I.ITEM_CD ,
                                           CASE WHEN F.NEW_TP IS NULL THEN '0' ELSE F.NEW_TP END DIV,
                                           CASE WHEN C_SDATE1 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK1,
                                           CASE WHEN C_SDATE2 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK2,
                                           CASE WHEN C_SDATE3 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK3,
                                           IC.COST1,
                                           IC.COST2,
                                           IC.COST3,
                                           I.L_CLASS_CD,
                                           I.M_CLASS_CD,
                                           I.S_CLASS_CD,
                                           I.ITEM_NM ,
                                           CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                                WHEN ls_ord_tp= 'M' THEN I.L_CLASS_CD || I.M_CLASS_CD
                                                WHEN ls_ord_tp= 'S' THEN I.L_CLASS_CD || I.M_CLASS_CD || I.S_CLASS_CD
                                                ELSE NULL
                                           END ORD_SGRP,
                                           CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                                WHEN ls_ord_tp= 'M' THEN I.M_CLASS_CD
                                                WHEN ls_ord_tp= 'S' THEN I.S_CLASS_CD
                                                ELSE NULL
                                           END ORD_SGRP_CD,
                                           I.ITEM_DIV,
                                           I.ORD_UNIT,
                                           I.ORD_UNIT_QTY,
                                           I.ORD_B_CNT,
                                           I.ORD_START_DT,
                                           I.ORD_CLOSE_DT,
                                           I.MIN_ORD_QTY,
                                           I.ALERT_ORD_QTY,
                                           F.NEW_TP,
                                           0   SALE_RANK,
                                           '0' BASIC_CHK
                                      FROM ITEM_CHAIN I,
                                            ITEM_FLAG_ALL F,
                                            (
                                             SELECT ITEM_CD, MAX(COST1) COST1 , MAX(COST2) COST2, MAX(COST3) COST3
                                               FROM (
                                                     SELECT ITEM_CD,
                                                            MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST1,
                                                            NULL COST2,
                                                            NULL COST3
                                                       FROM ITEM_CHAIN_HIS H
                                                      WHERE COMP_CD  = PSV_COMP_CD
                                                        AND BRAND_CD = PSV_BRAND_CD
                                                        AND STOR_TP = ls_stor_tp
                                                        AND START_DT <= C_SDATE1
                                                      GROUP BY ITEM_CD
                                                     UNION ALL
                                                     SELECT ITEM_CD,
                                                            NULL COST1,
                                                            MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST2,
                                                            NULL COST3
                                                       FROM ITEM_CHAIN_HIS H
                                                      WHERE COMP_CD  = PSV_COMP_CD
                                                        AND BRAND_CD = PSV_BRAND_CD
                                                        AND STOR_TP = ls_stor_tp
                                                        AND START_DT <= C_SDATE2
                                                      GROUP BY ITEM_CD
                                                     UNION ALL
                                                     SELECT ITEM_CD,
                                                            NULL COST1,
                                                            NULL COST2,
                                                            MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST3
                                                       FROM ITEM_CHAIN_HIS H
                                                      WHERE COMP_CD  = PSV_COMP_CD
                                                        AND BRAND_CD = PSV_BRAND_CD
                                                        AND STOR_TP = ls_stor_tp
                                                        AND START_DT <= C_SDATE3
                                                      GROUP BY ITEM_CD
                                                    ) ICG
                                              GROUP BY ITEM_CD
                                            ) IC,
                                            (
                                             SELECT SUB_ITEM_CD
                                               FROM REF_ITEM
                                              WHERE COMP_CD = PSV_COMP_CD
                                                AND USE_YN  = 'Y'
                                                AND ITEM_CD = PSV_ORD_GRP
                                            ) RI
                                      WHERE I.USE_YN  = 'Y'
                                        AND I.STOR_TP = ls_stor_tp
                                        AND I.ORD_SALE_DIV IN  ( '1' , '2')
                                        AND I.ORD_MNG_DIV = '0'
                                        AND I.COMP_CD     = PSV_COMP_CD
                                        AND I.BRAND_CD    = PSV_BRAND_CD
                                        AND ( C_SDATE1 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT,'9')
                                              OR  C_SDATE2 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT,'9')
                                              OR  C_SDATE3 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT,'9')
                                            )
                                        AND I.ITEM_CD = IC.ITEM_CD
                                        AND I.ITEM_CD = RI.SUB_ITEM_CD
                                        AND I.ITEM_CD = F.ITEM_CD (+)
                                        AND I.ITEM_CD NOT IN ( SELECT ITEM_CD FROM O_COLLECT WHERE EVT_FG = '3' )
                                   ) I,
                                   (
                                    SELECT ORD_GRP ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_SEQ
                                     WHERE COMP_CD  = PSV_COMP_CD
                                       AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                     GROUP BY ORD_GRP
                                   ) OS,
                                   O_CHK_TM  OT,
                                   (
                                    SELECT ORD_GRP,
                                           ITEM_CD ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_ITEM
                                     WHERE COMP_CD  = PSV_COMP_CD
                                       AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                     GROUP BY ORD_GRP, ITEM_CD
                                   ) OI,
                                   (
                                    SELECT ITEM_CD ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY1  AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY2  AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY3  AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_CENTER_ITEM
                                     WHERE COMP_CD   = PSV_COMP_CD
                                       AND USE_YN    = 'Y'
                                       AND CENTER_CD = ls_center_cd
                                     GROUP BY ITEM_CD
                                   ) OCI,
                                   (
                                    SELECT ORD_GRP,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_STORE
                                     WHERE ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                       AND COMP_CD  = PSV_COMP_CD
                                       AND BRAND_CD = PSV_BRAND_CD
                                       AND STOR_CD  = PSV_STOR_CD
                                      GROUP BY ORD_GRP
                                   ) OST,
                                   (
                                    SELECT ITEM_CD ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '1'
                                       AND OE1.ITEM_DIV  = 'I'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE1.COMP_CD   = OE3.COMP_CD (+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ITEM_CD
                                   ) OEI,
                                   (
                                    SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OE1.COMP_CD   = OE3.COMP_CD (+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OC.ACC_CD     = '1'
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEA,
                                   (
                                    SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '1'
                                       AND OE1.COMP_CD   = OE3.COMP_CD (+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ORD_GRP
                                   ) OEG ,
                                   (
                                    SELECT ITEM_CD ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.ITEM_DIV  = 'I'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE1.COMP_CD   = OE3.COMP_CD (+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ITEM_CD
                                   ) OEI2,
                                   (
                                    SELECT '1' SEQ ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE NULL END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE NULL END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE NULL END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.COMP_CD   = OE3.COMP_CD (+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEI2_CHK,
                                   (
                                    SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.COMP_CD   = OE3.COMP_CD (+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEA2,
                                   (
                                    SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '2'
                                       AND OE1.COMP_CD   = OE3.COMP_CD (+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ORD_GRP
                                   ) OEG2 ,
                                   (
                                    SELECT ITEM_CD ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3,
                                           (
                                            SELECT 'S' STOR_DIV, SEQ, BRAND_CD, STOR_CD, USE_YN
                                              FROM OC_EXC_STORE  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                            UNION ALL
                                            SELECT 'B' STOR_DIV, SEQ, BRAND_CD, STOR_TP, USE_YN
                                              FROM OC_EXC_BRAND  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                           ) OE4,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '3'
                                       AND OE1.ITEM_DIV  = 'I'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND OE1.SEQ = OE4.SEQ (+)
                                       AND ( OE1.STOR_DIV = OE4.STOR_DIV (+) AND  OE4.BRAND_CD (+) = PSV_BRAND_CD AND
                                             OE4.STOR_CD (+) = CASE WHEN OE1.STOR_DIV = 'S' THEN PSV_STOR_CD ELSE ls_stor_tp END
                                             AND OE4.USE_YN (+) = 'Y'
                                           )
                                      GROUP BY ITEM_CD
                                   ) OEI3,
                                   (
                                    SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3,
                                           (SELECT 'S' STOR_DIV, SEQ, BRAND_CD, STOR_CD, USE_YN
                                              FROM OC_EXC_STORE  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                            UNION ALL
                                            SELECT 'B' STOR_DIV, SEQ, BRAND_CD, STOR_TP, USE_YN
                                              FROM OC_EXC_BRAND  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                           ) OE4,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '3'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( OE1.STOR_DIV = OE4.STOR_DIV (+) AND OE4.BRAND_CD (+) = PSV_BRAND_CD AND
                                             OE4.STOR_CD (+) = CASE WHEN OE1.STOR_DIV = 'S' THEN PSV_STOR_CD ELSE ls_stor_tp END
                                             AND OE4.USE_YN (+) = 'Y'
                                           )
                                   ) OEA3,
                                   (
                                    SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL  ) THEN 0 ELSE NULL  END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NOT NULL  ) THEN 1
                                                     WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') AND (OE4.BRAND_CD IS NULL ) THEN 0 ELSE NULL  END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3,
                                           (SELECT 'S' STOR_DIV, SEQ, BRAND_CD, STOR_CD, USE_YN
                                              FROM OC_EXC_STORE  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                            UNION ALL
                                            SELECT 'B' STOR_DIV, SEQ, BRAND_CD, STOR_TP, USE_YN
                                              FROM OC_EXC_BRAND  OE4
                                             WHERE COMP_CD = PSV_COMP_CD
                                           ) OE4,
                                           COMMON        OC
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OC.COMP_CD
                                       AND OE1.EXC_TYPE  = OC.CODE_CD
                                       AND OC.CODE_TP    = '00080' -- 예외타입
                                       AND OC.ACC_CD     = '3'
                                       AND OE1.COMP_CD = OE3.COMP_CD(+)
                                       AND OE1.SEQ    = OE3.SEQ (+)
                                       AND OE3.USE_YN (+) = 'Y'
                                       AND OE1.COMP_CD = OE2.COMP_CD
                                       AND OE1.SEQ     = OE2.SEQ
                                       AND OE2.USE_YN  = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( OE1.STOR_DIV = OE4.STOR_DIV (+) AND  OE4.BRAND_CD (+) = PSV_BRAND_CD AND
                                             OE4.STOR_CD (+) = CASE WHEN OE1.STOR_DIV = 'S' THEN PSV_STOR_CD ELSE ls_stor_tp END
                                             AND OE4.USE_YN (+) = 'Y'
                                           )
                                     GROUP BY ORD_GRP
                                   ) OEG3 ,
                                   O_DDAY    OSD,
                                   O_CLASS   IG,
                                   LANG_ITEM IL
                             WHERE I.ITEM_CD   = OI.ITEM_CD
                               AND OI.ORD_GRP  = OS.ORD_GRP
                               AND OI.ORD_GRP  = OT.ORD_GRP
                               AND I.ITEM_CD   = OCI.ITEM_CD (+)
                               AND OI.ORD_GRP  = OST.ORD_GRP
                               AND I.ITEM_CD   = OEI.ITEM_CD (+)
                               AND OI.ORD_GRP  = OEG.ORD_GRP (+)
                               AND I.ITEM_CD   = OEI2.ITEM_CD (+)
                               AND OI.ORD_GRP  = OEG2.ORD_GRP (+)
                               AND I.ITEM_CD   = OEI3.ITEM_CD (+)
                               AND OI.ORD_GRP  = OEG3.ORD_GRP (+)
                               AND OI.ORD_GRP  = OSD.ORD_GRP
                               AND I.ORD_SGRP  = IG.CLASS_CD (+)
                               AND I.ITEM_CD   = IL.ITEM_CD  (+)
                               AND IL.LANGUAGE_TP(+)= PSV_LANG_CD
                           ) OI,
                           O_TR OQ,
                           (
                            SELECT ITEM_CD,
                                   SUM(CASE WHEN SALE_DT = C_ODATE    THEN SALE_QTY ELSE 0 END) GRD_AMT,
                                   SUM(CASE WHEN SALE_DT = C_PW_ODATE THEN SALE_QTY ELSE 0 END) GRD_PW_AMT
                              FROM SALE_JDM
                             WHERE SALE_DT IN ( C_ODATE, C_PW_ODATE )
                               AND COMP_CD  = PSV_COMP_CD
                               AND BRAND_CD = PSV_BRAND_CD
                               AND STOR_CD  = PSV_STOR_CD
                             GROUP BY ITEM_CD
                           ) SQ   ,
                           (
                            SELECT C.CODE_CD, NVL(L.CODE_NM, C.CODE_NM) CODE_NM
                              FROM COMMON C, LANG_COMMON L
                             WHERE C.COMP_CD = L.COMP_CD(+)
                               AND C.CODE_CD = L.CODE_CD(+)
                               AND C.CODE_TP = '00095' -- 미선출단위
                               AND C.COMP_CD = PSV_COMP_CD
                               AND C.CODE_TP = L.CODE_TP(+)
                               AND L.LANGUAGE_TP (+) = PSV_LANG_CD
                           ) C_00095
                     WHERE OI.ITEM_CD = OQ.ITEM_CD (+)
                       AND OI.ITEM_CD = SQ.ITEM_CD (+)
                       AND OI.ORD_UNIT = C_00095.CODE_CD (+)
                       AND ( SUBSTR(ORD_CONTROL_1,7,5) = 'YYYYY' OR
                             SUBSTR(ORD_CONTROL_2,7,5) = 'YYYYY' OR
                             SUBSTR(ORD_CONTROL_3,7,5) = 'YYYYY' OR
                             OQ.ORD_QTY1              <> 0 OR
                             OQ.ORD_QTY2              <> 0 OR
                             OQ.ORD_QTY3              <> 0
                           )
                   ) A1
           ) A
     WHERE ( CNT >= 2 OR  ( CNT = 1 AND SORT_ORDER  = '1' ) )
     ORDER BY GRP_SORT, CLASS_NM, ORD_GRP, SORT_ORDER, TO_NUMBER( CASE WHEN SORT_ORDER  = '0' THEN '0' ELSE ROW_NO END );
    
    PR_RTN_CD := ls_err_cd ;
    
    -- dbms_output.enable( 1000000 ) ;
    -- dbms_output.put_line( ls_sql ) ;
    
  EXCEPTION
    WHEN ERR_HANDLER THEN
         PR_RTN_CD := ls_err_cd ;
    WHEN OTHERS THEN
         dbms_output.put_line( sqlerrM ) ;
         PR_RTN_CD := ERR_4999999 ;
  END;
  
  PROCEDURE SP_ORDER_SAVE
  ( 
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PSV_IP_ADDR1    IN  VARCHAR2    -- 주문 PC IP ADDRESS (공인)
  , PSV_IP_ADDR2    IN  VARCHAR2    -- 주문 PC IP ADDRESS (사설)
  , PSV_USER_ID     IN  VARCHAR2    -- 사용자 ID
  , PSV_ORD_LIST    IN  VARCHAR2    -- 주문TR PARAMETER
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
  ) IS
    ltb_para        TBL_ORD_PARA :=  TBL_ORD_PARA();
    ls_rtn_cd       VARCHAR2(10) ;
    ls_rtn_msg      VARCHAR2(500) ;
    
    lsLine          VARCHAR2(3);
  BEGIN
    lsLine   := '000';
    ltb_para := f_para_parsing(PSV_ORD_LIST);
    BEGIN
      lsLine := '020'; -- jsd
      SP_ORDER_SAVE_MAIN ( PSV_LANG_CD, PSV_COMP_CD, PSV_BRAND_CD, PSV_STOR_CD,
                           PSV_SHIP_DT, PSV_ORD_GRP, PSV_ORD_FG,   PSV_IP_ADDR1, PSV_IP_ADDR2,
                           PSV_USER_ID, ltb_para,    ls_rtn_cd,    ls_rtn_msg) ;
      lsLine := '022';
      
      IF ls_rtn_cd <> '0' THEN
         ROLLBACK;
         RAISE ERR_HANDLER ;
      END IF;
      
      COMMIT;
      
    EXCEPTION
      WHEN OTHERS THEN
           ls_rtn_cd   := 'EE' || ERR_4999999;
        -- ls_rtn_msg  := '[' || lsLine || ']' || SQLERRM ;
        
           ROLLBACK;
           RAISE ERR_HANDLER ;
    END;
    
    PR_RTN_CD := '0' ;
    PR_RTN_MSG := '' ;
    
  EXCEPTION
    WHEN ERR_HANDLER THEN
         PR_RTN_CD  := ls_rtn_cd;
         PR_RTN_MSG := ls_rtn_msg;
    WHEN OTHERS THEN
         PR_RTN_CD  := 'rr' || ERR_4999999;
         PR_RTN_MSG := '[OTHERS]' || SQLERRM;
         RAISE  ;
  END ;
  
  PROCEDURE SP_ORDER_SAVE_MAIN
  (
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PSV_IP_ADDR1    IN  VARCHAR2    -- 주문 PC IP ADDRESS (공인)
  , PSV_IP_ADDR2    IN  VARCHAR2    -- 주문 PC IP ADDRESS (사설)
  , PSV_USER_ID     IN  VARCHAR2    -- 사용자 ID
  , PTV_PARA        IN  TBL_ORD_PARA-- 주문TR PARAMETER
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
  ) IS
    
    C_SDATE_N1    CONSTANT  NUMBER(1)  :=  0;
    C_SDATE_N2    CONSTANT  NUMBER(1)  :=  0;
    C_SDATE_N3    CONSTANT  NUMBER(1)  :=  0;
    
    C_SDATE1      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'YYYYMMDD') ; --1차 배송일자
    C_SDATE2      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'YYYYMMDD') ; --2차 배송일자
    C_SDATE3      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'YYYYMMDD') ; --3차 배송일자
    
    C_SDAY1       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'D') ; --1차 배송요일
    C_SDAY2       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'D') ; --2차 배송요일
    C_SDAY3       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'D') ; --3차 배송요일
    
    ls_err_cd       VARCHAR2(10) ;
    ls_err_msg      VARCHAR2(500) ;
    ls_tm_chk_msg   VARCHAR2(500) ;
    
    ls_stor_tp      STORE.STOR_TP%TYPE;
    ls_confirm_div  VARCHAR2(1); -- TABLE 정리[20160126 표준화]
    ls_use_yn       STORE.USE_YN%TYPE;
    ls_center_cd    STORE.CENTER_CD%TYPE;
    ls_auto_cf_yn   PARA_BRAND.PARA_VAL%TYPE; -- TABLE 정리[20160311 표준화]
    
    ls_sq_ord_log   VARCHAR2(15) ;
    ltb_para        TBL_ORD_PARA :=  TBL_ORD_PARA();
    
    ln_vat_pos      PLS_INTEGER;
    
    ls_vat_tp       VARCHAR2(1) ;
    ls_seq01_chk    VARCHAR2(2) := '1';
    ls_seq02_chk    VARCHAR2(2) := '2';
    ls_seq03_chk    VARCHAR2(2) := '3';
    lsLine          VARCHAR2(3);
    
  BEGIN
    BEGIN
      lsLine := '100';
      
      SELECT STOR_TP,    '9',            CENTER_CD,    USE_YN
        INTO ls_stor_tp, ls_confirm_div, ls_center_cd, ls_use_yn
        FROM STORE
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND STOR_CD  = PSV_STOR_CD ;
         
      IF ls_confirm_div <> '9' THEN
         ls_err_cd :=  4000004;
         RAISE  ERR_HANDLER;
      ELSIF ls_use_yn IS NULL OR ls_use_yn <> 'Y' THEN
         ls_err_cd :=  4000005;
         RAISE  ERR_HANDLER;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_err_cd := ERR_4000002 ;
           RAISE ERR_HANDLER ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd := 'D' || ERR_4999999 ;
           ls_err_msg := SQLERRM ;
           ls_err_msg := 'D [' || SQLERRM || ']' ;
           RAISE ERR_HANDLER ;
    END;
    
    lsLine := '110';
    BEGIN
      SELECT MAX( CASE WHEN CODE_CD = '1' THEN VAL_C1 ELSE NULL END ) VAT_TP,
             TO_NUMBER( NVL( MAX( CASE WHEN CODE_CD = '2' THEN VAL_C1 ELSE NULL END ), '0' ) ) VAT_POS
        INTO ls_vat_tp , ln_vat_pos
        FROM COMMON
       WHERE COMP_CD = PSV_COMP_CD
         AND CODE_TP = '01200'; -- 소수점 처리방법
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_vat_tp  := '1' ;
           ln_vat_pos := 0   ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd  := ERR_4999999 ;
           ls_err_msg := SQLERRM ;
           RAISE ERR_HANDLER ;
    END;
    
    lsLine    := '130';
    ls_err_cd := '0' ;
    
    ltb_para := PTV_PARA ;
    
    BEGIN
      WITH O_GRP AS
      (SELECT ORD_GRP , CONTROL_DIV
         FROM OC_ORD_GRP A
        WHERE COMP_CD = PSV_COMP_CD
          AND USE_YN  = 'Y'
          AND EXISTS  (SELECT '1'
                         FROM OC_ORD_GRP_STORE B
                        WHERE A.COMP_CD  = B.COMP_CD
                          AND A.ORD_GRP  = B.ORD_GRP
                          AND B.COMP_CD  = PSV_COMP_CD
                          AND B.BRAND_CD = PSV_BRAND_CD
                          AND B.STOR_CD  = PSV_STOR_CD
                      )
      ),
      O_CTL_TM AS
      (
       SELECT ORD_GRP,
              ORD_SEQ ,
              ORD_START_TM,
              ORD_END_TM,
              ORD_END_DDAY
         FROM OC_STORE_TM
        WHERE USE_YN    = 'Y'
          AND ORD_GRP  IN ( SELECT ORD_GRP FROM O_GRP )
          AND COMP_CD   = PSV_COMP_CD
          AND BRAND_CD  = PSV_BRAND_CD
          AND STOR_CD   = PSV_STOR_CD
          AND (SHIP_DT, ORD_SEQ) IN ( ( C_SDATE1, C_SEQ1 ), ( C_SDATE2, C_SEQ2 ), ( C_SDATE3, C_SEQ3 ) )
       UNION ALL
       SELECT OTM.ORD_GRP ,
              OTM.ORD_SEQ ,
              OTM.ORD_START_TM,
              OTM.ORD_END_TM,
              OTM.ORD_END_DDAY
         FROM (
               SELECT ORD_GRP,
                      ORD_SEQ ,
                      ORD_START_TM,
                      ORD_END_TM,
                      ORD_END_DDAY
                 FROM OC_ORD_GRP_TM OGT
                WHERE USE_YN     = 'Y'
                  AND COMP_CD    =  PSV_COMP_CD
                  AND ORD_GRP   IN ( SELECT ORD_GRP FROM O_GRP )
                  AND OC_WRK_DIV = '1'
                  AND NOT EXISTS (SELECT '1'
                                    FROM OC_CENTER_TM OCT
                                   WHERE OCT.CENTER_CD  = ls_center_cd
                                     AND OCT.USE_YN     = 'Y'
                                     AND OCT.OC_WRK_DIV = '1'
                                     AND OCT.ORD_GRP    = OGT.ORD_GRP
                                 )
               UNION ALL
               SELECT ORD_GRP ,
                      ORD_SEQ ,
                      ORD_START_TM,
                      ORD_END_TM,
                      ORD_END_DDAY
                 FROM OC_CENTER_TM
                WHERE USE_YN     = 'Y'
                  AND COMP_CD    =  PSV_COMP_CD
                  AND ORD_GRP   IN ( SELECT ORD_GRP FROM O_GRP )
                  AND OC_WRK_DIV = '1'
                  AND CENTER_CD  = ls_center_cd
              ) OTM
        WHERE NOT EXISTS (SELECT '1' FROM OC_STORE_TM OCT
                           WHERE OCT.COMP_CD  =  PSV_COMP_CD
                             AND OCT.BRAND_CD =  PSV_BRAND_CD
                             AND OCT.STOR_CD  =  PSV_STOR_CD
                             AND OCT.USE_YN   = 'Y'
                             AND OCT.ORD_GRP  = OTM.ORD_GRP
                             AND OCT.ORD_SEQ  = OTM.ORD_SEQ
                             AND OCT.SHIP_DT  =  CASE OTM.ORD_SEQ
                                                      WHEN C_SEQ1 THEN C_SDATE1
                                                      WHEN C_SEQ2 THEN C_SDATE2
                                                      WHEN C_SEQ3 THEN C_SDATE3
                                                      ELSE             NULL
                                                 END
                         )
      ),
      O_DDAY AS
      (SELECT ORD_GRP,
              CHK1, CHK2, CHK3,
              D_DAY1, D_DAY2, D_DAY3,
              TO_CHAR( TO_DATE(C_SDATE1, 'YYYYMMDD') - NVL(D_DAY1,-1) , 'YYYYMMDD') CHK_DT1,
              TO_CHAR( TO_DATE(C_SDATE2, 'YYYYMMDD') - NVL(D_DAY2,-1) , 'YYYYMMDD') CHK_DT2,
              TO_CHAR( TO_DATE(C_SDATE3, 'YYYYMMDD') - NVL(D_DAY3,-1) , 'YYYYMMDD') CHK_DT3
         FROM (
               SELECT ORD_GRP,
                      MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN ORD_DDAY ELSE NULL END ) D_DAY3
                 FROM OC_ORD_GRP_DDAY
                WHERE COMP_CD = PSV_COMP_CD
                  AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP WHERE CONTROL_DIV = 'Q' )
                  AND ( ORD_SEQ, DLV_WK ) IN ( ( C_SEQ1, C_SDAY1 ), ( C_SEQ2, C_SDAY2 ), ( C_SEQ3, C_SDAY3 ) )
                GROUP BY ORD_GRP
               UNION ALL
               SELECT ORD_GRP,
                      MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                      MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY3
                 FROM OC_STORE_DDAY
                WHERE COMP_CD  = PSV_COMP_CD
                  AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP WHERE CONTROL_DIV = 'S' )
                  AND BRAND_CD = PSV_BRAND_CD
                  AND STOR_CD  = PSV_STOR_CD
                  AND DLV_WK  IN ( C_SDAY1, C_SDAY2, C_SDAY3 )
                GROUP BY ORD_GRP
              ) OD
        WHERE ORD_GRP IS NOT NULL
      ),
      O_CHK_TM AS
      (SELECT ORD_GRP ,
              CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT1 THEN 1
                   WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT1
                        AND EXISTS (SELECT '1'
                                      FROM O_CTL_TM
                                     WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT1 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT1, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                       AND ORD_SEQ = C_SEQ1
                                   )                            THEN 1
                   ELSE 0 END CHK1,
              CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT2 THEN 1
                   WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT2
                        AND EXISTS (SELECT '1'
                                      FROM O_CTL_TM
                                     WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT2 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT2, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                       AND ORD_SEQ = C_SEQ2
                                   )                            THEN 1
                   ELSE 0 END CHK2,
              CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT3 THEN 1
                   WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT3
                        AND EXISTS (SELECT '1'
                                      FROM O_CTL_TM
                                     WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT3 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT3, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                       AND ORD_SEQ = C_SEQ3
                                   )                            THEN 1
                   ELSE 0 END CHK3
         FROM O_DDAY
      ) ,
      ORD_GRP_ITEM  AS
      (
       SELECT ORD_GRP,
              ITEM_CD ,
              MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
              MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
              MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
         FROM OC_ORD_GRP_ITEM
        WHERE COMP_CD  = PSV_COMP_CD
          AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
        GROUP BY ORD_GRP, ITEM_CD
      ) ,
      ORD_ITEM AS
      (
       SELECT A.ITEM_CD,  A.ORD_SEQ , B.ITEM_NM
         FROM TABLE ( CAST(ltb_para AS TBL_ORD_PARA) ) A,
              ITEM_CHAIN B
        WHERE B.COMP_CD  = PSV_COMP_CD
          AND B.BRAND_CD = PSV_BRAND_CD
          AND B.STOR_TP  = ls_stor_tp
          AND A.ITEM_CD  = B.ITEM_CD
      )
      SELECT I.ITEM_NM || ': ' || '주문 등록 가능한 시간이 아닙니다.'
        INTO ls_tm_chk_msg
        FROM ORD_ITEM     I,
             ORD_GRP_ITEM OI,
             O_CHK_TM     OT
       WHERE I.ITEM_CD   = OI.ITEM_CD
         AND OI.ORD_GRP  = OT.ORD_GRP
         AND ( OT.CHK1  IS NULL OR OT.CHK1 = 0 )
         AND ROWNUM      < 2 ;
         
      ls_err_cd  := ERR_4999999 ;
      ls_err_msg := ls_tm_chk_msg;
      RAISE ERR_HANDLER ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd  := ERR_4999999 ;
           ls_err_msg := SQLERRM;
           RAISE ERR_HANDLER ;
    END;
    
    BEGIN
      lsLine := '140';
      
      SELECT PARA_VAL
        INTO ls_auto_cf_yn
        FROM PARA_BRAND
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND PARA_CD  = '1006'; -- 주문자동확정여부
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_err_cd := ERR_4000002 ;
           RAISE ERR_HANDLER ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd := 'D' || ERR_4999999 ;
           ls_err_msg := SQLERRM ;
           ls_err_msg := 'D [' || SQLERRM || ']' ;
           
           RAISE ERR_HANDLER ;
    END;
    
    lsLine := '150';
    
    FOR C_ORD_ERP IN (
                      SELECT DISTINCT NVL(C.ORD_GRP, PSV_ORD_GRP) ORD_GRP , A.ORD_SEQ
                        FROM TABLE ( CAST ( ltb_para as TBL_ORD_PARA) )  A,
                             ITEM_CHAIN B,
                             ORDER_DT C
                       WHERE B.COMP_CD  = PSV_COMP_CD
                         AND B.BRAND_CD = PSV_BRAND_CD
                         AND B.STOR_TP  = ls_stor_tp
                         AND A.ITEM_CD  = B.ITEM_CD
                         AND A.ITEM_CD  = C.ITEM_CD(+)
                         AND C.SHIP_DT(+) = PSV_SHIP_DT
                         AND C.BRAND_CD(+)= PSV_BRAND_CD
                         AND C.STOR_CD(+) = PSV_STOR_CD
                     ) LOOP
      BEGIN
        MERGE INTO ORDER_DT OD
        USING (SELECT COMP_CD, ORD_SEQ,ITEM_CD, ORD_QTY,
                      SHIP_DT, ORD_UNIT, ORD_UNIT_QTY, ITEM_WGRP, ORD_COST, COST_VAT_YN, COST_VAT_RULE,
                      CASE WHEN COST_VAT_YN  = 'Y' AND COST_VAT_RULE  = '2' THEN
                                CASE ls_vat_tp
                                     WHEN '1' THEN CEIL(ORD_COST * COST_VAT_RATE * POWER(10,ln_vat_pos)) / POWER(10,ln_vat_pos)
                                     WHEN '2' THEN ROUND (ORD_COST * COST_VAT_RATE ,ln_vat_pos )
                                     WHEN '3' THEN TRUNC (ORD_COST * COST_VAT_RATE ,ln_vat_pos )
                                     ELSE 0
                                END
                           WHEN COST_VAT_YN  = 'Y' AND COST_VAT_RULE  = '1' THEN
                                CASE ls_vat_tp
                                     WHEN '1' THEN CEIL(ORD_COST * COST_VAT_RATE / (1+COST_VAT_RATE) * POWER(10,ln_vat_pos)  ) / POWER(10,ln_vat_pos)
                                     WHEN '2' THEN ROUND (ORD_COST * COST_VAT_RATE / (1+COST_VAT_RATE) ,ln_vat_pos )
                                     WHEN '3' THEN TRUNC (ORD_COST * COST_VAT_RATE / (1+COST_VAT_RATE) ,ln_vat_pos )
                                     ELSE 0
                                END
                           ELSE 0
                      END COST_VAT
                 FROM (
                       SELECT B.COMP_CD, A.ORD_SEQ,A.ITEM_CD,  TO_NUMBER(A.ORD_QTY)  ORD_QTY,
                              CASE ORD_SEQ WHEN '1' THEN IC.COST1 WHEN '2' THEN IC.COST2 WHEN '3' THEN IC.COST3 ELSE IC.COST1 END ORD_COST,
                              CASE ORD_SEQ WHEN '1' THEN C_SDATE1 WHEN '2' THEN C_SDATE2 WHEN '3' THEN C_SDATE3 ELSE C_SDATE1 END SHIP_DT,
                              B.ORD_UNIT, B.ORD_UNIT_QTY, PSV_ORD_GRP AS ITEM_WGRP,
                              IC.COST_VAT_YN, IC.COST_VAT_RULE, IC.COST_VAT_RATE
                         FROM (
                               SELECT ORD_SEQ, ITEM_CD, ORD_QTY, C_MESSAGE
                                 FROM TABLE ( CAST(ltb_para AS TBL_ORD_PARA) )
                                WHERE ORD_SEQ IN ( ls_seq01_chk, ls_seq02_chk, ls_seq03_chk )   -- 저장 시 마감시간이 지난 차수는 저장 안되게 처리함
                              ) A,
                              ITEM_CHAIN  B,
                              (
                               SELECT ITEM_CD, MAX(COST1) COST1 , MAX(COST2) COST2, MAX(COST3) COST3, MAX(COST_VAT_YN)    AS COST_VAT_YN,
                                              MAX(COST_VAT_RULE)  AS COST_VAT_RULE,
                                              MAX(COST_VAT_RATE)  AS COST_VAT_RATE
                                 FROM (
                                       SELECT H.ITEM_CD,
                                              MAX(H.COST) KEEP (DENSE_RANK LAST ORDER BY H.START_DT) COST1,
                                              NULL COST2,
                                              NULL COST3,
                                              MAX(I.COST_VAT_YN)    AS COST_VAT_YN,
                                              MAX(I.COST_VAT_RULE)  AS COST_VAT_RULE,
                                              MAX(I.COST_VAT_RATE)  AS COST_VAT_RATE
                                         FROM ITEM_CHAIN_HIS H
                                            , ITEM_CHAIN     I
                                        WHERE H.COMP_CD   = PSV_COMP_CD
                                          AND H.BRAND_CD  = PSV_BRAND_CD
                                          AND H.STOR_TP   = ls_stor_tp
                                          AND H.START_DT <= C_SDATE1
                                          AND H.COMP_CD   = I.COMP_CD
                                          AND H.BRAND_CD  = I.BRAND_CD
                                          AND H.STOR_TP   = I.STOR_TP
                                          AND H.ITEM_CD   = I.ITEM_CD
                                        GROUP BY H.ITEM_CD
                                       UNION ALL
                                       SELECT H.ITEM_CD,
                                              NULL COST1,
                                              MAX(H.COST) KEEP (DENSE_RANK LAST ORDER BY H.START_DT) COST2,
                                              NULL COST3,
                                              MAX(I.COST_VAT_YN)    AS COST_VAT_YN,
                                              MAX(I.COST_VAT_RULE)  AS COST_VAT_RULE,
                                              MAX(I.COST_VAT_RATE)  AS COST_VAT_RATE
                                         FROM ITEM_CHAIN_HIS H
                                            , ITEM_CHAIN     I
                                        WHERE H.COMP_CD   = PSV_COMP_CD
                                          AND H.BRAND_CD  = PSV_BRAND_CD
                                          AND H.STOR_TP   = ls_stor_tp
                                          AND H.START_DT <= C_SDATE2
                                          AND H.COMP_CD   = I.COMP_CD
                                          AND H.BRAND_CD  = I.BRAND_CD
                                          AND H.STOR_TP   = I.STOR_TP
                                          AND H.ITEM_CD   = I.ITEM_CD
                                        GROUP BY H.ITEM_CD
                                       UNION ALL
                                       SELECT H.ITEM_CD,
                                              NULL COST1,
                                              NULL COST2,
                                              MAX(H.COST) KEEP (DENSE_RANK LAST ORDER BY H.START_DT) COST3,
                                              MAX(I.COST_VAT_YN)    AS COST_VAT_YN,
                                              MAX(I.COST_VAT_RULE)  AS COST_VAT_RULE,
                                              MAX(I.COST_VAT_RATE)  AS COST_VAT_RATE
                                         FROM ITEM_CHAIN_HIS H
                                            , ITEM_CHAIN     I
                                        WHERE H.COMP_CD   = PSV_COMP_CD
                                          AND H.BRAND_CD  = PSV_BRAND_CD
                                          AND H.STOR_TP   = ls_stor_tp
                                          AND H.START_DT <= C_SDATE3
                                          AND H.COMP_CD   = I.COMP_CD
                                          AND H.BRAND_CD  = I.BRAND_CD
                                          AND H.STOR_TP   = I.STOR_TP
                                          AND H.ITEM_CD   = I.ITEM_CD
                                       GROUP BY H.ITEM_CD
                                      ) ICG
                                GROUP BY ITEM_CD
                              ) IC
                        WHERE B.COMP_CD     = PSV_COMP_CD
                          AND B.BRAND_CD    = PSV_BRAND_CD
                          AND B.STOR_TP     = ls_stor_tp
                          AND A.ITEM_CD     = B.ITEM_CD
                          AND IC.ITEM_CD(+) = B.ITEM_CD
                      ) A
              ) OT
        ON (OD.COMP_CD  = PSV_COMP_CD       AND
            OD.BRAND_CD = PSV_BRAND_CD      AND
            OD.STOR_CD  = PSV_STOR_CD       AND
            OD.SHIP_DT  = OT.SHIP_DT        AND
            OD.ORD_GRP  = C_ORD_ERP.ORD_GRP AND
            OD.ORD_SEQ  = OT.ORD_SEQ        AND
            OD.ITEM_CD  = OT.ITEM_CD        AND
            OD.ORD_FG   = PSV_ORD_FG
           )
        WHEN MATCHED THEN
             UPDATE 
                SET ERP_INF_DT   = C_SDATE1,
                    ORD_UNIT     = OT.ORD_UNIT,
                    ITEM_WGRP    = OT.ITEM_WGRP,
                    ORD_UNIT_QTY = OT.ORD_UNIT_QTY,
                    ORD_COST     = OT.ORD_COST,
                    ORD_QTY      = OT.ORD_QTY,
                    ORD_AMT      = CASE WHEN OT.COST_VAT_YN  = 'Y' AND OT.COST_VAT_RULE  = '1' THEN OT.ORD_QTY * OT.ORD_COST - OT.ORD_QTY * OT.COST_VAT
                                        ELSE OT.ORD_QTY * OT.ORD_COST
                                   END,
                    ORD_VAT      = COST_VAT * OT.ORD_QTY,
                    ORD_CQTY     = DECODE(ls_auto_cf_yn, 'Y', OT.ORD_QTY, 0),
                    ORD_CAMT     = DECODE(ls_auto_cf_yn, 'Y', (CASE WHEN OT.COST_VAT_YN  = 'Y' AND OT.COST_VAT_RULE  = '1' THEN OT.ORD_QTY * OT.ORD_COST - OT.ORD_QTY * OT.COST_VAT
                                                                    ELSE OT.ORD_QTY * OT.ORD_COST
                                                               END
                                                              ), 0),
                    ORD_CVAT     = DECODE(ls_auto_cf_yn, 'Y', COST_VAT * OT.ORD_QTY, 0),
                    UPD_DT       = SYSDATE,
                    UPD_USER     = PSV_USER_ID
        WHEN NOT MATCHED THEN
             INSERT (COMP_CD, SHIP_DT, BRAND_CD, STOR_CD, ORD_GRP, ORD_SEQ, ORD_FG, ITEM_CD, ERP_INF_DT,
                     ITEM_WGRP, ORD_UNIT, ORD_UNIT_QTY, ORD_COST, ORD_QTY, ORD_AMT,
                     ORD_VAT, AUTO_ORD_YN, ORD_CQTY, ORD_CAMT, ORD_CVAT,
                     INST_DT, INST_USER, UPD_DT, UPD_USER)
             VALUES (OT.COMP_CD, OT.SHIP_DT, PSV_BRAND_CD, PSV_STOR_CD,  C_ORD_ERP.ORD_GRP, OT.ORD_SEQ, PSV_ORD_FG, OT.ITEM_CD, C_SDATE1 ,
                     OT.ITEM_WGRP, OT.ORD_UNIT, OT.ORD_UNIT_QTY, OT.ORD_COST, OT.ORD_QTY, (CASE WHEN OT.COST_VAT_YN  = 'Y' AND OT.COST_VAT_RULE  = '1' THEN OT.ORD_QTY * OT.ORD_COST - OT.ORD_QTY * OT.COST_VAT
                                                                                                ELSE OT.ORD_QTY * OT.ORD_COST
                                                                                           END),
                     COST_VAT * OT.ORD_QTY , 'N' , DECODE(ls_auto_cf_yn, 'Y', OT.ORD_QTY, 0),
                     DECODE(ls_auto_cf_yn, 'Y', (CASE WHEN OT.COST_VAT_YN  = 'Y' AND OT.COST_VAT_RULE  = '1' THEN OT.ORD_QTY * OT.ORD_COST - OT.ORD_QTY * OT.COST_VAT
                                                      ELSE OT.ORD_QTY * OT.ORD_COST
                                                 END), 0),
                     DECODE(ls_auto_cf_yn, 'Y', COST_VAT * OT.ORD_QTY, 0), SYSDATE, PSV_USER_ID, SYSDATE, PSV_USER_ID) ;
                     
        lsLine := '160';
        
        MERGE INTO ORDER_HD OH
        USING (SELECT COMP_CD, SHIP_DT, ORD_GRP, ORD_SEQ, SUM(ORD_AMT) ORD_AMT, SUM(ORD_VAT) ORD_VAT
                 FROM ORDER_DT
                WHERE COMP_CD  = PSV_COMP_CD
                  AND BRAND_CD = PSV_BRAND_CD
                  AND STOR_CD  = PSV_STOR_CD
                  AND ( SHIP_DT , ORD_SEQ ) IN ( ( C_SDATE1, C_SEQ1 ), ( C_SDATE2, C_SEQ2 ), ( C_SDATE3, C_SEQ3 ) )
                  AND ORD_FG   = PSV_ORD_FG
                  AND ORD_GRP  = C_ORD_ERP.ORD_GRP
                GROUP BY COMP_CD, SHIP_DT, ORD_GRP, ORD_SEQ
              ) OT
        ON (OH.COMP_CD  = PSV_COMP_CD       AND
            OH.BRAND_CD = PSV_BRAND_CD      AND
            OH.STOR_CD  = PSV_STOR_CD       AND
            OH.SHIP_DT  = OT.SHIP_DT        AND
            OH.ORD_SEQ  = OT.ORD_SEQ        AND
            OH.ORD_GRP  = C_ORD_ERP.ORD_GRP AND
            OH.ORD_FG   = PSV_ORD_FG
           )
        WHEN MATCHED THEN
             UPDATE 
                SET ERP_INF_DT = C_SDATE1 ,
                    ORD_AMT    = OT.ORD_AMT ,
                    ORD_VAT    = OT.ORD_VAT ,
                    ORD_CAMT   = DECODE(ls_auto_cf_yn, 'Y', OT.ORD_AMT, 0),
                    ORD_CVAT   = DECODE(ls_auto_cf_yn, 'Y', OT.ORD_VAT, 0),
                    UPD_DT     = SYSDATE,
                    UPD_USER   = PSV_USER_ID
        WHEN NOT MATCHED THEN
             INSERT (COMP_CD, SHIP_DT, BRAND_CD, STOR_CD, ORD_GRP, ORD_SEQ, ORD_FG, ERP_INF_DT,
                     ORD_AMT, ORD_VAT, ORD_CAMT, ORD_CVAT, WRK_DIV,
                     INST_DT, INST_USER, UPD_DT, UPD_USER)
             VALUES (OT.COMP_CD, OT.SHIP_DT, PSV_BRAND_CD, PSV_STOR_CD, C_ORD_ERP.ORD_GRP, OT.ORD_SEQ, PSV_ORD_FG, C_SDATE1,
                     OT.ORD_AMT, OT.ORD_VAT , DECODE(ls_auto_cf_yn, 'Y', OT.ORD_AMT, 0), DECODE(ls_auto_cf_yn, 'Y', OT.ORD_VAT, 0), '0',
                    SYSDATE, PSV_USER_ID, SYSDATE, PSV_USER_ID) ;
                    
        ls_sq_ord_log  := TO_CHAR(SQ_ORDER_LOG.NEXTVAL, 'FM0999999') ;
        
        lsLine := '170';
        
        INSERT INTO ORDER_LOG
            ( COMP_CD, SHIP_DT, BRAND_CD, STOR_CD, ORD_SEQ, ORD_FG, ITEM_CD,
              ORD_LOG_SEQ, ERP_INF_DT, ITEM_WGRP, ORD_UNIT, ORD_UNIT_QTY,
              ORD_COST, ORD_QTY, ORD_AMT, ORD_VAT, AUTO_ORD_YN, ORD_CQTY,
              ORD_CAMT, ORD_CVAT, OUTSIDE_IP, INSIDE_IP,
              INST_DT, INST_USER, UPD_DT, UPD_USER
            )
        SELECT COMP_CD, SHIP_DT, BRAND_CD, STOR_CD, ORD_SEQ, ORD_FG, ITEM_CD,
               ls_sq_ord_log, ERP_INF_DT, ITEM_WGRP, ORD_UNIT, ORD_UNIT_QTY,
               ORD_COST, ORD_QTY, ORD_AMT, ORD_VAT, AUTO_ORD_YN, ORD_CQTY,
               ORD_CAMT, ORD_CVAT, PSV_IP_ADDR1,PSV_IP_ADDR2,
               INST_DT, INST_USER, UPD_DT, UPD_USER
          FROM ORDER_DT OD
         WHERE COMP_CD  = PSV_COMP_CD
           AND BRAND_CD = PSV_BRAND_CD
           AND STOR_CD  = PSV_STOR_CD
           AND ( SHIP_DT, ORD_SEQ ) IN ( ( C_SDATE1, C_SEQ1 ), ( C_SDATE2, C_SEQ2 ), ( C_SDATE3, C_SEQ3 ) )
           AND ORD_FG   = PSV_ORD_FG
           AND ORD_GRP  = C_ORD_ERP.ORD_GRP;
      END ;
    END LOOP;
    
  EXCEPTION
    WHEN ERR_HANDLER THEN
         PR_RTN_CD  := ls_err_cd;
         PR_RTN_MSG := 'R[' || lsLine || ']' || substrb(ls_err_msg, 1, 100);
    WHEN OTHERS THEN
         dbms_output.put_line( sqlerrM );
         PR_RTN_CD  := ERR_4999999;
         PR_RTN_MSG := 'O[' || lsLine || ']' || substrb( SQLERRM, 1, 100);
  END;
  
  PROCEDURE SP_ORDER_DELETE
  ( 
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PSV_IP_ADDR1    IN  VARCHAR2    -- 주문 PC IP ADDRESS (공인)
  , PSV_IP_ADDR2    IN  VARCHAR2    -- 주문 PC IP ADDRESS (사설)
  , PSV_USER_ID     IN  VARCHAR2    -- 사용자 ID
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
  ) IS
    ltb_para        TBL_ORD_PARA :=  TBL_ORD_PARA();
    ls_rtn_cd       VARCHAR2(7) ;
    ls_rtn_msg      VARCHAR2(500) ;
  BEGIN
    IF ( TO_CHAR(TO_DATE(PSV_SHIP_DT, 'YYYYMMDD'), 'YYYYMMDD') <= TO_CHAR( SYSDATE, 'YYYYMMDD') ) THEN
       ls_rtn_cd   := ERR_4999989;  -- 주문마감한 자료는 삭제할 수 없습니다.
       ls_rtn_msg  := SQLERRM ;
       RAISE ERR_HANDLER ;
    END IF;
    
    BEGIN
      SP_ORDER_DELETE_MAIN ( PSV_LANG_CD, PSV_COMP_CD, PSV_BRAND_CD, PSV_STOR_CD ,
                             PSV_SHIP_DT, PSV_ORD_FG , PSV_IP_ADDR1, PSV_IP_ADDR2,
                             PSV_USER_ID, ls_rtn_cd  , ls_rtn_msg) ;
      IF ls_rtn_cd <> '0' THEN
         ROLLBACK;
         RAISE ERR_HANDLER ;
      END IF  ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           ls_rtn_cd   := ERR_4999999;
           ls_rtn_msg  := SQLERRM ;
           RAISE ERR_HANDLER ;
    END ;
    
    PR_RTN_CD := '0' ;
    PR_RTN_MSG := '' ;
  EXCEPTION
    WHEN ERR_HANDLER THEN
         PR_RTN_CD  := ls_rtn_cd;
         PR_RTN_MSG := ls_rtn_msg;
    WHEN OTHERS THEN
         PR_RTN_CD  := ERR_4999999;
         PR_RTN_MSG := SQLERRM;
         RAISE;
  END;
  
  PROCEDURE SP_ORDER_DELETE_MAIN
  (
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PSV_IP_ADDR1    IN  VARCHAR2    -- 주문 PC IP ADDRESS (공인)
  , PSV_IP_ADDR2    IN  VARCHAR2    -- 주문 PC IP ADDRESS (사설)
  , PSV_USER_ID     IN  VARCHAR2    -- 사용자 ID
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
  ) IS
    
    C_SDATE_N1    CONSTANT  NUMBER(1)  :=  0;
    C_SDATE_N2    CONSTANT  NUMBER(1)  :=  0;
    C_SDATE_N3    CONSTANT  NUMBER(1)  :=  0;
    
    C_SDATE1      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'YYYYMMDD') ; --1차 배송일자
    C_SDATE2      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'YYYYMMDD') ; --2차 배송일자
    C_SDATE3      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'YYYYMMDD') ; --3차 배송일자
    
    ls_err_cd       VARCHAR2(7) ;
    
    ls_sq_ord_log VARCHAR2(15) ;
  BEGIN
    
    ls_err_cd := '0' ;
    
    UPDATE ORDER_DT
       SET ORD_QTY   = 0 ,
           ORD_AMT   = 0 ,
           ORD_VAT   = 0 ,
           UPD_DT    = SYSDATE,
           UPD_USER  = PSV_USER_ID
     WHERE COMP_CD   = PSV_COMP_CD
       AND BRAND_CD  = PSV_BRAND_CD
       AND STOR_CD   = PSV_STOR_CD
       AND ( SHIP_DT, ORD_SEQ ) IN ( ( C_SDATE1, C_SEQ1 ), ( C_SDATE2, C_SEQ2 ), ( C_SDATE3, C_SEQ3 ) )
       AND ORD_FG    = PSV_ORD_FG ;
       
    UPDATE ORDER_HD
       SET ORD_AMT   = 0 ,
           ORD_VAT   = 0 ,
           UPD_DT    = SYSDATE,
           UPD_USER  = PSV_USER_ID
     WHERE COMP_CD  = PSV_COMP_CD
       AND BRAND_CD = PSV_BRAND_CD
       AND STOR_CD  = PSV_STOR_CD
       AND ( SHIP_DT, ORD_SEQ ) IN ( ( C_SDATE1, C_SEQ1 ) ,( C_SDATE2, C_SEQ2 ) ,( C_SDATE3, C_SEQ3) )
       AND ORD_FG   = PSV_ORD_FG ;
       
    ls_err_cd := '0' ;
    ls_sq_ord_log  := TO_CHAR(SQ_ORDER_LOG.NEXTVAL, 'FM0999999') ;
    
    INSERT INTO ORDER_LOG
        ( COMP_CD, SHIP_DT, BRAND_CD, STOR_CD, ORD_SEQ, ORD_FG, ITEM_CD,
          ORD_LOG_SEQ, ERP_INF_DT, ITEM_WGRP, ORD_UNIT, ORD_UNIT_QTY,
          ORD_COST, ORD_QTY, ORD_AMT, ORD_VAT, AUTO_ORD_YN, ORD_CQTY,
          ORD_CAMT, ORD_CVAT, OUTSIDE_IP, INSIDE_IP,
          INST_DT, INST_USER, UPD_DT, UPD_USER
        )
    SELECT COMP_CD, SHIP_DT, BRAND_CD, STOR_CD, ORD_SEQ, ORD_FG, ITEM_CD,
           ls_sq_ord_log, ERP_INF_DT, ITEM_WGRP, ORD_UNIT, ORD_UNIT_QTY,
           ORD_COST, ORD_QTY, ORD_AMT, ORD_VAT, AUTO_ORD_YN, ORD_CQTY,
           ORD_CAMT, ORD_CVAT, PSV_IP_ADDR1,PSV_IP_ADDR2 ,
           INST_DT, INST_USER, UPD_DT, UPD_USER
      FROM ORDER_DT OD
     WHERE COMP_CD  = PSV_COMP_CD
       AND BRAND_CD = PSV_BRAND_CD
       AND STOR_CD  = PSV_STOR_CD
       AND ( SHIP_DT, ORD_SEQ ) IN ( ( C_SDATE1, C_SEQ1 ), ( C_SDATE2, C_SEQ2 ), ( C_SDATE3, C_SEQ3 ) )
       AND ORD_FG   = PSV_ORD_FG;
  EXCEPTION
    WHEN ERR_HANDLER THEN
         PR_RTN_CD := ls_err_cd ;
    WHEN OTHERS THEN
         dbms_output.put_line( sqlerrM ) ;
         PR_RTN_CD := SQLERRM ;
         PR_RTN_CD := ERR_4999999 ;
  END;
  
  PROCEDURE SP_ORDER_LIST_CHK
  ( 
    PSV_LANG_CD     IN  VARCHAR2
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ITEM_DIV    IN  VARCHAR2    -- 주문그룹
  , PSV_ITEM_TP     IN  VARCHAR2    -- 제품타입
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2 -- 처리코드
  , PR_RESULT       IN OUT PKG_REPORT.REF_CUR
  ) IS
    
    C_ODATE       VARCHAR2(8)  := TO_CHAR( SYSDATE , 'YYYYMMDD') ;     -- 주문 일자
    C_NDATE       VARCHAR2(8)  := TO_CHAR( SYSDATE +1, 'YYYYMMDD') ;   -- 주문 일자 + 1일 (입고예정수량)
    C_PW_ODATE    VARCHAR2(8)  := TO_CHAR( SYSDATE -7 , 'YYYYMMDD') ;  -- 전주 주문 일자
    C_MY_ODATE    VARCHAR2(8)  := TO_CHAR( SYSDATE -14 , 'YYYYMMDD') ; --  MY 주문 Chechk 일자(15일간)
    
    C_SDATE1      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'YYYYMMDD') ; --1차 배송일자
    C_SDATE2      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'YYYYMMDD') ; --2차 배송일자
    C_SDATE3      CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'YYYYMMDD') ; --3차 배송일자
    
    C_PD_SDATE1   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 -1 , 'YYYYMMDD') ; --전일 1차 배송일자
    C_PD_SDATE2   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 -1 , 'YYYYMMDD') ; --전일 2차 배송일자
    C_PD_SDATE3   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 -1 , 'YYYYMMDD') ; --전일 3차 배송일자
    
    C_PW_SDATE1   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 -7 , 'YYYYMMDD') ; --전주 1차 배송일자
    C_PW_SDATE2   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 -7 , 'YYYYMMDD') ; --전주 2차 배송일자
    C_PW_SDATE3   CONSTANT  VARCHAR2(8)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 -7 , 'YYYYMMDD') ; --전주 3차 배송일자
    
    C_SDAY1       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N1 , 'D') ; --1차 배송요일
    C_SDAY2       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N2 , 'D') ; --2차 배송요일
    C_SDAY3       CONSTANT  VARCHAR2(1)  := TO_CHAR( TO_DATE(PSV_SHIP_DT, 'YYYYMMDD') + C_SDATE_N3 , 'D') ; --3차 배송요일
    
    ls_err_cd     VARCHAR2(7) ;
    
    ls_stor_tp      STORE.STOR_TP%TYPE;
    ls_ord_tp       VARCHAR2(1); -- PARA_BRAND로 전환[20160126 표준화]
    ls_confirm_div  VARCHAR2(1); -- TABLE 정리[20160126 표준화]
    ls_use_yn       STORE.USE_YN%TYPE;
    ls_center_cd    STORE.CENTER_CD%TYPE;
    
    ln_week_new     PLS_INTEGER;
  BEGIN
    ls_err_cd := ERR_4000000  ;
    
    -- 주문 분류 항목 결정
    BEGIN
      SELECT PARA_VAL
        INTO ls_ord_tp
        FROM PARA_BRAND
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND PARA_CD  = '1003'; -- 주문분류
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_err_cd := ERR_4000003 ;
           RAISE ERR_HANDLER ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    BEGIN
      SELECT VAL_N1
        INTO ln_week_new
        FROM COMMON
       WHERE COMP_CD = PSV_COMP_CD
         AND CODE_TP = '01330' -- 금주 신규 기간
         AND CODE_CD = '1' ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ln_week_new := 7 ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    BEGIN
      SELECT STOR_TP, '9', CENTER_CD, USE_YN
        INTO ls_stor_tp, ls_confirm_div, ls_center_cd, ls_use_yn
        FROM STORE
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND STOR_CD  = PSV_STOR_CD ;
         
      IF ls_confirm_div <> '9' THEN
         ls_err_cd :=  4000004;
         RAISE  ERR_HANDLER;
      ELSIF ls_use_yn IS NULL OR ls_use_yn <> 'Y' THEN
         ls_err_cd :=  4000005;
         RAISE  ERR_HANDLER;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_err_cd := ERR_4000002 ;
           RAISE ERR_HANDLER ;
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER ;
      WHEN OTHERS THEN
           ls_err_cd := ERR_4999999 ;
           RAISE ERR_HANDLER ;
    END;
    
    -- OS : 주문그룹/차수 통제 (OC_ORD_GRP_SEQ)
    -- OI : 주문그룹/상품 통제 (OC_ORD_GRP_ITEM)
    OPEN PR_RESULT FOR
    SELECT ITEM_CD_NM,
           ITEM_CD,
           CASE WHEN ORD_CONTROL_1 = 'YYYYYYYYY' THEN 'Y' ELSE 'N' END  ORD_CONTROL_1,
           CASE WHEN ORD_CONTROL_2 = 'YYYYYYYYY' THEN 'Y' ELSE 'N' END  ORD_CONTROL_2,
           CASE WHEN ORD_CONTROL_3 = 'YYYYYYYYY' THEN 'Y' ELSE 'N' END  ORD_CONTROL_3
      FROM (
            WITH O_GRP AS
            (SELECT ORD_GRP, CONTROL_DIV
               FROM OC_ORD_GRP A
              WHERE COMP_CD = PSV_COMP_CD
                AND USE_YN  = 'Y'
                AND EXISTS  ( SELECT '1' 
                                FROM OC_ORD_GRP_STORE B
                               WHERE A.COMP_CD  = B.COMP_CD
                                 AND A.ORD_GRP  = B.ORD_GRP
                                 AND B.COMP_CD  = PSV_COMP_CD
                                 AND B.BRAND_CD = PSV_BRAND_CD
                                 AND B.STOR_CD  = PSV_STOR_CD
                            )
            ) ,
            O_CLASS AS
            (SELECT B1.L_CLASS_CD CLASS_CD ,
                    NVL(B2.LANG_NM , B1.L_CLASS_NM) CLASS_NM ,
                    '▶  ' ||  NVL(B2.LANG_NM , B1.L_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                    B1.SORT_ORDER,
                    B1.L_CLASS_CD CLASS_CD2
               FROM ITEM_L_CLASS B1,
                    LANG_TABLE   B2
              WHERE B2.COMP_CD  (+) = PSV_COMP_CD
                AND B2.TABLE_NM (+) = 'ITEM_L_CLASS'
                AND B2.COL_NM   (+) = 'L_CLASS_NM'
                AND B2.LANGUAGE_TP (+)= PSV_LANG_CD
                AND B1.ORG_CLASS_CD || B1.L_CLASS_CD = B2.PK_COL (+)
                AND B1.COMP_CD      = PSV_COMP_CD
                AND B1.ORG_CLASS_CD = '00'
                AND ls_ord_tp = 'L'
             UNION ALL
             SELECT B1.L_CLASS_CD || B1.M_CLASS_CD CLASS_CD ,
                    NVL(B2.LANG_NM , B1.M_CLASS_NM) CLASS_NM ,
                     '▶  ' ||  NVL(B2.LANG_NM , B1.M_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                    B1.SORT_ORDER ,
                    B1.M_CLASS_CD CLASS_CD2
               FROM ITEM_M_CLASS B1,
                    LANG_TABLE B2
              WHERE B2.COMP_CD  (+) = PSV_COMP_CD
                AND B2.TABLE_NM (+) = 'ITEM_M_CLASS'
                AND B2.COL_NM   (+) = 'M_CLASS_NM'
                AND B2.LANGUAGE_TP (+)= PSV_LANG_CD
                AND B1.ORG_CLASS_CD || B1.L_CLASS_CD || B1.M_CLASS_CD = B2.PK_COL (+)
                AND B1.COMP_CD      = PSV_COMP_CD
                AND B1.ORG_CLASS_CD = '00'
                AND ls_ord_tp = 'M'
             UNION ALL
             SELECT B1.L_CLASS_CD || B1.M_CLASS_CD || B1.S_CLASS_CD CLASS_CD ,
                    NVL(B2.LANG_NM , B1.S_CLASS_NM) CLASS_NM ,
                     '▶  ' ||  NVL(B2.LANG_NM , B1.S_CLASS_NM) || '  ◀' GRP_CLASS_NM ,
                    B1.SORT_ORDER,
                    B1.S_CLASS_CD CLASS_CD2
               FROM ITEM_S_CLASS B1,
                    LANG_TABLE B2
              WHERE B2.COMP_CD  (+) = PSV_COMP_CD
                AND B2.TABLE_NM (+) = 'ITEM_S_CLASS'
                AND B2.COL_NM   (+) = 'S_CLASS_NM'
                AND B2.LANGUAGE_TP (+)= PSV_LANG_CD
                AND B1.ORG_CLASS_CD || B1.L_CLASS_CD || B1.M_CLASS_CD || B1.S_CLASS_CD = B2.PK_COL (+)
                AND B1.COMP_CD      = PSV_COMP_CD
                AND B1.ORG_CLASS_CD = '00'
                AND ls_ord_tp = 'S'
            ) ,
            O_TR AS
            ( SELECT ITEM_CD ,
                   SUM(CASE WHEN SHIP_DT = C_SDATE1    AND ORD_SEQ = C_SEQ1 THEN ORD_QTY  ELSE 0 END) ORD_QTY1,
                   SUM(CASE WHEN SHIP_DT = C_SDATE2    AND ORD_SEQ = C_SEQ2 THEN ORD_QTY  ELSE 0 END) ORD_QTY2,
                   SUM(CASE WHEN SHIP_DT = C_SDATE3    AND ORD_SEQ = C_SEQ3 THEN ORD_QTY  ELSE 0 END) ORD_QTY3,
                   SUM(CASE WHEN SHIP_DT = C_PD_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_QTY  ELSE 0 END) ORD_PD_QTY1,
                   SUM(CASE WHEN SHIP_DT = C_PD_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_QTY  ELSE 0 END) ORD_PD_QTY2,
                   SUM(CASE WHEN SHIP_DT = C_PD_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_QTY  ELSE 0 END) ORD_PD_QTY3,
                   SUM(CASE WHEN SHIP_DT = C_PW_SDATE1 AND ORD_SEQ = C_SEQ1 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY1,
                   SUM(CASE WHEN SHIP_DT = C_PW_SDATE2 AND ORD_SEQ = C_SEQ2 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY2,
                   SUM(CASE WHEN SHIP_DT = C_PW_SDATE3 AND ORD_SEQ = C_SEQ3 THEN ORD_CQTY ELSE 0 END) ORD_PW_QTY3,
                   SUM(CASE WHEN SHIP_DT = C_NDATE     AND ORD_SEQ = C_SEQ1 THEN ORD_CQTY ELSE 0 END) ORD_OD_QTY
              FROM ORDER_DT
             WHERE ( SHIP_DT, ORD_SEQ )  IN ( (C_SDATE1,    C_SEQ1) , (C_SDATE2,    C_SEQ2) , (C_SDATE3,    C_SEQ3) ,
                                              (C_PD_SDATE1, C_SEQ1) , (C_PD_SDATE2, C_SEQ2) , (C_PD_SDATE3, C_SEQ3) ,
                                              (C_PW_SDATE1, C_SEQ1) , (C_PW_SDATE2, C_SEQ2) , (C_PW_SDATE3, C_SEQ3) ,
                                              (C_ODATE,     C_SEQ1) , (C_NDATE,     C_SEQ1) 
                                            )
               AND COMP_CD  = PSV_COMP_CD
               AND BRAND_CD = PSV_BRAND_CD
               AND STOR_CD  = PSV_STOR_CD
               AND ORD_FG   = PSV_ORD_FG
             GROUP BY ITEM_CD
            )
            SELECT ROW_NO ,
                   ITEM_CD_NM,
                   DIV ,
                   SALE_RANK ,
                   ORD_1ST,
                   BASIC,
                   ORD_2ND,
                   ORD_3RD,
                   ORD_UNIT  ,
                   ORD_UNIT_QTY ,
                   STOCK_EXP_QTY ,
                   BD_ORD_1ST,
                   BD_ORD_2ND,
                   BD_ORD_3RD,
                   LW_ORD_1ST,
                   LW_ORD_2ND,
                   LW_ORD_3RD,
                   DAY_SALE_AMT ,
                   LW_SALE_AMT,
                   LIMIT_QTY,
                   ORD_QTY,
                   STCK_QTY,
                   ORD_ADD_1ST,
                   ORD_COLLECT_MSG ,
                   ITEM_CD,
                   ORD_CONTROL_1,
                   ORD_CONTROL_2,
                   ORD_CONTROL_3,
                   ORD_B_CNT,
                   MIN_ORD_QTY,
                   ALERT_ORD_QTY,
                   ORD_COST_1,
                   ORD_COST_2,
                   ORD_COST_3,
                   '0' ORD_AMT_1,
                   '0' ORD_AMT_2,
                   '0' ORD_AMT_3,
                   ITEM_DIV,
                   ORD_GRP,
                   ORD_GRP_CD,
                   ORD_TP,
                   MERGE_DIV,
                   SEARCH_TXT,
                   BASIC_CHK ,
                   SORT_ORDER ,
                   GRP_SORT,
                   CLASS_NM,
                   DIV_CHK ,
                   RTN_CHK,
                   COUNT(1) OVER ( PARTITION BY GRP_SORT, CLASS_NM, ORD_GRP ) CNT
              FROM (
                    SELECT OC.GRP_CLASS_NM  ROW_NO ,
                           OC.GRP_CLASS_NM  ITEM_CD_NM,
                           OC.GRP_CLASS_NM  DIV,
                           OC.GRP_CLASS_NM  SALE_RANK ,
                           OC.GRP_CLASS_NM  ORD_1ST,
                           OC.GRP_CLASS_NM  BASIC,
                           OC.GRP_CLASS_NM  ORD_2ND,
                           OC.GRP_CLASS_NM  ORD_3RD,
                           OC.GRP_CLASS_NM  ORD_UNIT  ,
                           OC.GRP_CLASS_NM  ORD_UNIT_QTY ,
                           OC.GRP_CLASS_NM  STOCK_EXP_QTY ,
                           OC.GRP_CLASS_NM  BD_ORD_1ST,
                           OC.GRP_CLASS_NM  BD_ORD_2ND,
                           OC.GRP_CLASS_NM  BD_ORD_3RD,
                           OC.GRP_CLASS_NM  LW_ORD_1ST,
                           OC.GRP_CLASS_NM  LW_ORD_2ND,
                           OC.GRP_CLASS_NM  LW_ORD_3RD,
                           OC.GRP_CLASS_NM  DAY_SALE_AMT ,
                           OC.GRP_CLASS_NM  LW_SALE_AMT,
                           OC.GRP_CLASS_NM  LIMIT_QTY,
                           OC.GRP_CLASS_NM  ORD_QTY,
                           OC.GRP_CLASS_NM  STCK_QTY,
                           OC.GRP_CLASS_NM  ORD_ADD_1ST,
                           OC.GRP_CLASS_NM  ORD_COLLECT_MSG ,
                           ' '              ITEM_CD,
                           ' '              ORD_CONTROL_1,
                           ' '              ORD_CONTROL_2,
                           ' '              ORD_CONTROL_3,
                           ' '              ORD_B_CNT,
                           ' '              MIN_ORD_QTY,
                           ' '              ALERT_ORD_QTY,
                           ' '              ORD_COST_1,
                           ' '              ORD_COST_2,
                           ' '              ORD_COST_3,
                           ' '              ORD_AMT_1,
                           ' '              ORD_AMT_2,
                           ' '              ORD_AMT_3,
                           ' '              ITEM_DIV,
                           OC.CLASS_CD      ORD_GRP,
                           OC.CLASS_CD2     ORD_GRP_CD,
                           ls_ord_tp        ORD_TP,
                           'T'              MERGE_DIV,
                           'T' || OC.CLASS_CD SEARCH_TXT,
                           ' '              BASIC_CHK ,
                           '0'              SORT_ORDER ,
                           OC.SORT_ORDER    GRP_SORT,
                           OC.CLASS_NM      CLASS_NM,
                           ' '              DIV_CHK ,
                           ' '              RTN_CHK
                      FROM OC_ORD_GRP_ITEM OI,
                           ITEM_CHAIN      I,
                           O_CLASS         OC
                     WHERE I.COMP_CD   = PSV_COMP_CD
                       AND I.BRAND_CD  = PSV_BRAND_CD
                       AND OI.ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                       AND OI.COMP_CD  = I.COMP_CD
                       AND OI.ITEM_CD  = I.ITEM_CD
                       AND I.STOR_TP   = ls_stor_tp
                       AND OC.CLASS_CD = CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                              WHEN ls_ord_tp= 'M' THEN I.L_CLASS_CD || I.M_CLASS_CD
                                              WHEN ls_ord_tp= 'S' THEN I.L_CLASS_CD || I.M_CLASS_CD || I.S_CLASS_CD
                                              ELSE NULL
                                         END
                     GROUP BY OC.CLASS_CD, OC.CLASS_CD2, OC.CLASS_NM, OC.GRP_CLASS_NM, OC.SORT_ORDER
                    UNION ALL
                    SELECT TO_CHAR( ROW_NUMBER() OVER ( PARTITION BY OI.CLASS_NM, OI.ORD_SGRP ORDER BY OI.ITEM_NM ) ) ROW_NO ,
                           OI.ITEM_NM ITEM_CD_NM,
                           ' '  DIV,
                           TO_CHAR(OI.SALE_RANK) SALE_RANK  ,
                           NVL( TO_CHAR( OQ.ORD_QTY1 ) , '0' )  ORD_1ST,
                           ' ' BASIC,
                           NVL( TO_CHAR( OQ.ORD_QTY2 ) , '0' )  ORD_2ND,
                           NVL( TO_CHAR( OQ.ORD_QTY3 ) , '0' )  ORD_3RD,
                           C_00095.CODE_NM ORD_UNIT  ,
                           TO_CHAR(OI.ORD_UNIT_QTY) ORD_UNIT_QTY ,
                           NVL( TO_CHAR( OQ.ORD_OD_QTY  ) , '0' )  STOCK_EXP_QTY,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY1 ) , '0' )  BD_ORD_1ST,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY2 ) , '0' )  BD_ORD_2ND,
                           NVL( TO_CHAR( OQ.ORD_PD_QTY3 ) , '0' )  BD_ORD_3RD,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY1 ) , '0' )  LW_ORD_1ST,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY2 ) , '0' )  LW_ORD_2ND,
                           NVL( TO_CHAR( OQ.ORD_PW_QTY3 ) , '0' )  LW_ORD_3RD,
                           NVL( TO_CHAR( SQ.GRD_AMT )     , '0' )  DAY_SALE_AMT ,
                           NVL( TO_CHAR( SQ.GRD_PW_AMT )  , '0' )  LW_SALE_AMT,
                           NVL( TO_CHAR( OI.LIMIT_QTY )   , '0' )  LIMIT_QTY,
                           NVL( TO_CHAR( OI.ORD_QTY )     , '0' )  ORD_QTY,
                           NVL( TO_CHAR( OI.LIMIT_QTY - OI.ORD_QTY)   , '0' )  STCK_QTY,
                           '0'  ORD_ADD_1ST,
                           OI.ORD_COLLECT_MSG ,
                           OI.ITEM_CD,
                           OI.ORD_CONTROL_1,
                           OI.ORD_CONTROL_2,
                           OI.ORD_CONTROL_3,
                           TO_CHAR(OI.ORD_B_CNT) ORD_B_CNT,
                           TO_CHAR(OI.MIN_ORD_QTY) MIN_ORD_QTY,
                           TO_CHAR(OI.ALERT_ORD_QTY) ALERT_ORD_QTY,
                           TO_CHAR(OI.COST1) ORD_COST_1,
                           TO_CHAR(OI.COST2) ORD_COST_2,
                           TO_CHAR(OI.COST3) ORD_COST_3,
                           NVL( TO_CHAR(OQ.ORD_QTY1 * OI.COST1) , '0' ) ORD_AMT_1,
                           NVL( TO_CHAR(OQ.ORD_QTY2 * OI.COST2) , '0' ) ORD_AMT_2,
                           NVL( TO_CHAR(OQ.ORD_QTY3 * OI.COST3) , '0' ) ORD_AMT_3,
                           OI.ITEM_DIV,
                           OI.ORD_SGRP,
                           OI.ORD_SGRP_CD,
                           ls_ord_tp    ORD_TP,
                           'I' MERGE_DIV,
                           'I' || OI.ORD_SGRP SEARCH_TXT,
                           OI.BASIC_CHK ,
                           '1' SORT_ORDER ,
                           OI.SORT_ORDER GRP_SORT,
                           OI.CLASS_NM ,
                           OI.DIV DIV_CHK ,
                           CASE WHEN RS.ITEM_CD IS NULL THEN '0' ELSE '1' END RTN_CHK
                      FROM (
                            WITH NEW_ITEM AS
                            (SELECT ITEM_CD,
                                    CASE WHEN START_DT + ln_week_new >=  C_ODATE THEN '2' ELSE '1' END NEW_TP
                               FROM ITEM_FLAG
                              WHERE COMP_CD = PSV_COMP_CD
                                AND ITEM_FG = '01'
                                AND USE_YN  = 'Y'
                                AND C_ODATE BETWEEN START_DT AND END_DT
                            ),
                            ITEM_FLAG_ALL AS
                            (SELECT ITEM_CD ,
                                    CASE MIN ( NEW_TP )
                                         WHEN 1  THEN '4'
                                         WHEN 2  THEN '5'
                                         WHEN 3  THEN '3'
                                         WHEN 4  THEN '2'
                                         WHEN 5  THEN '1'
                                         ELSE         '0'
                                    END NEW_TP
                               FROM (
                                     SELECT ITEM_CD,
                                            CASE A.ITEM_FG
                                                 WHEN  '04' THEN 1
                                                 WHEN  '01' THEN CASE WHEN START_DT + ln_week_new >=  C_ODATE THEN 4 ELSE 5 END
                                            END NEW_TP
                                       FROM ITEM_FLAG A, COMMON B
                                      WHERE A.COMP_CD = PSV_COMP_CD
                                        AND A.ITEM_FG IN  ( '01' , '04' )
                                        AND A.USE_YN  = 'Y'
                                        AND C_ODATE BETWEEN CASE WHEN B.VAL_C1 = 'Y' THEN START_DT ELSE '00000000' END
                                                        AND CASE WHEN B.VAL_C1 = 'Y' THEN END_DT   ELSE '99999999' END
                                        AND B.CODE_TP = '01090' -- 작업구분[01:신상품, 02:집중상품, 03:행사상품, 04:중단]
                                        AND B.COMP_CD = A.COMP_CD
                                        AND B.CODE_CD = A.ITEM_FG
                                     UNION ALL /*
                                     SELECT C.ITEM_CD , 3 NEW_TP
                                       FROM CAMPAIGN_MST A, CAMPAIGN_ITEM C
                                      WHERE A.CAMPAIGN_STAT = 'C'
                                        AND C_ODATE BETWEEN A.START_DT AND A.END_DT
                                        AND A.COMP_CD     = PSV_COMP_CD
                                        AND A.BRAND_CD    = PSV_BRAND_CD
                                        AND A.COMP_CD     = C.COMP_CD
                                        AND A.BRAND_CD    = C.BRAND_CD
                                        AND A.CAMPAIGN_CD = C.CAMPAIGN_CD
                                        AND A.STOR_CD     = C.STOR_CD
                                        AND ( A.STOR_CD = PSV_STOR_CD  OR
                                              EXISTS (SELECT '1'
                                                        FROM CAMPAIGN_STORE  S
                                                       WHERE S.COMP_CD  = A.COMP_CD
                                                         AND S.BRAND_CD = A.BRAND_CD
                                                         AND S.CAMPAIGN_CD = A.CAMPAIGN_CD
                                                         AND S.COMP_CD  = PSV_COMP_CD
                                                         AND S.STOR_CD  = PSV_STOR_CD
                                                         AND S.USE_YN   = 'Y'
                                                     )
                                            )
                                        AND A.USE_YN = 'Y'
                                        AND C.USE_YN = 'Y'
                                     UNION ALL */
                                     SELECT ITEM_CD,  2
                                       FROM REJECT_SYSTEM A, REJECT_SYSTEM_ITEM B
                                      WHERE A.COMP_CD  = B.COMP_CD
                                        AND A.BRAND_CD = B.BRAND_CD
                                        AND A.STOR_CD  = B.STOR_CD
                                        AND A.START_DT = B.START_DT
                                        AND A.USE_YN   = 'Y'
                                        AND B.USE_YN   = 'Y'
                                        AND A.COMP_CD  = PSV_COMP_CD
                                        AND A.BRAND_CD = PSV_BRAND_CD
                                        AND A.STOR_CD  = PSV_STOR_CD
                                        AND A.START_DT <= C_ODATE
                                    ) A
                              GROUP BY ITEM_CD
                            ),
                            O_CTL_TM AS
                            (
                             SELECT ORD_GRP,
                                    ORD_SEQ ,
                                    ORD_START_TM,
                                    ORD_END_TM,
                                    ORD_END_DDAY
                               FROM OC_STORE_TM
                              WHERE USE_YN   = 'Y'
                                AND ORD_GRP  IN ( SELECT ORD_GRP FROM O_GRP )
                                AND COMP_CD  = PSV_COMP_CD
                                AND BRAND_CD = PSV_BRAND_CD
                                AND STOR_CD  = PSV_STOR_CD
                                AND (SHIP_DT, ORD_SEQ) IN ( ( C_SDATE1, C_SEQ1 ), ( C_SDATE2, C_SEQ2 ), ( C_SDATE3, C_SEQ3 ) )
                             UNION ALL
                             SELECT OTM.ORD_GRP,
                                    OTM.ORD_SEQ,
                                    OTM.ORD_START_TM,
                                    OTM.ORD_END_TM,
                                    OTM.ORD_END_DDAY
                               FROM (
                                     SELECT ORD_GRP,
                                            ORD_SEQ ,
                                            ORD_START_TM,
                                            ORD_END_TM,
                                            ORD_END_DDAY
                                       FROM OC_ORD_GRP_TM OGT
                                      WHERE USE_YN     = 'Y'
                                        AND COMP_CD    = PSV_COMP_CD
                                        AND ORD_GRP   IN (SELECT ORD_GRP FROM O_GRP)
                                        AND OC_WRK_DIV = '1'
                                        AND NOT EXISTS (SELECT '1'
                                                          FROM OC_CENTER_TM OCT
                                                         WHERE OCT.CENTER_CD  = ls_center_cd
                                                           AND OCT.USE_YN     = 'Y'
                                                           AND OCT.OC_WRK_DIV = '1'
                                                           AND OCT.ORD_GRP    = OGT.ORD_GRP
                                                       )
                                     UNION ALL
                                     SELECT ORD_GRP ,
                                            ORD_SEQ ,
                                            ORD_START_TM,
                                            ORD_END_TM,
                                            ORD_END_DDAY
                                       FROM OC_CENTER_TM
                                      WHERE USE_YN     = 'Y'
                                        AND COMP_CD    = PSV_COMP_CD
                                        AND ORD_GRP   IN ( SELECT ORD_GRP FROM O_GRP )
                                        AND OC_WRK_DIV = '1'
                                        AND CENTER_CD  = ls_center_cd
                                    ) OTM
                              WHERE NOT EXISTS (SELECT '1'
                                                  FROM OC_STORE_TM OCT
                                                 WHERE OCT.COMP_CD  = PSV_COMP_CD
                                                   AND OCT.BRAND_CD = PSV_BRAND_CD
                                                   AND OCT.STOR_CD  = PSV_STOR_CD
                                                   AND OCT.USE_YN   = 'Y'
                                                   AND OCT.ORD_GRP  = OTM.ORD_GRP
                                                   AND OCT.ORD_SEQ  = OTM.ORD_SEQ
                                                   AND OCT.SHIP_DT  = CASE OTM.ORD_SEQ 
                                                                           WHEN C_SEQ1 THEN C_SDATE1
                                                                           WHEN C_SEQ2 THEN C_SDATE2
                                                                           WHEN C_SEQ3 THEN C_SDATE3
                                                                           ELSE             NULL
                                                                      END
                                               )
                            ),
                            O_DDAY AS
                            (SELECT ORD_GRP,
                                    CHK1, CHK2, CHK3,
                                    D_DAY1, D_DAY2, D_DAY3,
                                    TO_CHAR( TO_DATE(C_SDATE1, 'YYYYMMDD') - NVL(D_DAY1,-1), 'YYYYMMDD') CHK_DT1,
                                    TO_CHAR( TO_DATE(C_SDATE2, 'YYYYMMDD') - NVL(D_DAY2,-1), 'YYYYMMDD') CHK_DT2,
                                    TO_CHAR( TO_DATE(C_SDATE3, 'YYYYMMDD') - NVL(D_DAY3,-1), 'YYYYMMDD') CHK_DT3
                               FROM (
                                     SELECT ORD_GRP,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN ORD_DDAY ELSE NULL END ) D_DAY3
                                       FROM OC_ORD_GRP_DDAY
                                      WHERE COMP_CD  = PSV_COMP_CD
                                        AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP WHERE CONTROL_DIV = 'Q' )
                                        AND (ORD_SEQ, DLV_WK) IN ( (C_SEQ1, C_SDAY1), (C_SEQ2, C_SDAY2), (C_SEQ3, C_SDAY3) )
                                      GROUP BY ORD_GRP
                                     UNION ALL
                                     SELECT ORD_GRP,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK AND ORD_DDAY >= 0  THEN 1 ELSE 0 END ) CHK3 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY1 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY1 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY2 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY2 ,
                                            MAX( CASE WHEN USE_YN = 'Y' AND C_SDAY3 = DLV_WK THEN ORD_DDAY ELSE NULL END ) D_DAY3
                                       FROM OC_STORE_DDAY
                                      WHERE ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP WHERE CONTROL_DIV = 'S' )
                                        AND COMP_CD  = PSV_COMP_CD
                                        AND BRAND_CD = PSV_BRAND_CD
                                        AND STOR_CD  = PSV_STOR_CD
                                        AND DLV_WK  IN ( C_SDAY1, C_SDAY2, C_SDAY3 )
                                      GROUP BY ORD_GRP
                                    ) OD
                              WHERE ORD_GRP IS NOT NULL
                            ) ,
                            O_CHK_TM AS
                            (SELECT ORD_GRP,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT1 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT1
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT1 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT1, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ1
                                                         )                            THEN 1
                                         ELSE 0
                                    END CHK1,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT2 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT2
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT2 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT2, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ2
                                                         )                            THEN 1
                                         ELSE 0
                                    END CHK2,
                                    CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD')  < CHK_DT3 THEN 1
                                         WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= CHK_DT3
                                              AND EXISTS (SELECT '1'
                                                            FROM O_CTL_TM
                                                           WHERE TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') BETWEEN CHK_DT3 || ORD_START_TM AND TO_CHAR(TO_DATE(CHK_DT3, 'YYYYMMDD') + ORD_END_DDAY, 'YYYYMMDD') || ORD_END_TM
                                                             AND ORD_SEQ = C_SEQ3
                                                         )
                                              THEN 1
                                         ELSE 0
                                    END CHK3
                               FROM O_DDAY
                            ),
                            O_COLLECT AS
                            (SELECT A.EVT_FG,
                                    B.ITEM_CD,
                                    B.ORD_COLLECT_MSG,
                                    B.LIMIT_QTY,
                                    B.ORD_QTY
                              FROM ORDER_COLLECT_INFO A, ORDER_COLLECT_ITEM B
                             WHERE A.USE_YN   = 'Y'
                               AND B.USE_YN   = 'Y'
                               AND C_SDATE1 BETWEEN A.START_DT AND A.CLOSE_DT
                               AND A.COMP_CD  = PSV_COMP_CD
                               AND A.BRAND_CD = PSV_BRAND_CD
                               AND A.COMP_CD  = B.COMP_CD
                               AND A.BRAND_CD = B.BRAND_CD
                               AND A.ORD_COLLECT_NO = B.ORD_COLLECT_NO
                               AND EXISTS (SELECT '1' FROM ORDER_COLLECT_STORE C
                                            WHERE A.COMP_CD  = C.COMP_CD
                                              AND A.ORD_COLLECT_NO = C.ORD_COLLECT_NO
                                              AND A.BRAND_CD = C.BRAND_CD
                                              AND C.COMP_CD  = PSV_COMP_CD
                                              AND C.STOR_CD  = PSV_STOR_CD
                                              AND C.USE_YN   = 'Y'
                                          )
                            )
                            SELECT I.ITEM_CD ,
                                   CASE WHEN IL.ITEM_NM IS NULL THEN I.ITEM_NM ELSE IL.ITEM_NM END ITEM_NM,
                                   IG.CLASS_NM,
                                   IG.SORT_ORDER,
                                   I.DIV,
                                   I.SALE_RANK,
                                   I.NEW_TP,
                                   I.ORD_UNIT,
                                   I.ORD_UNIT_QTY,
                                   I.ORD_B_CNT,
                                   I.MIN_ORD_QTY,
                                   I.ALERT_ORD_QTY,
                                   I.ITEM_DIV,
                                   I.BASIC_CHK ,
                                   I.ORD_SGRP,
                                   I.ORD_SGRP_CD,
                                   I.COST1,
                                   I.COST2,
                                   I.COST3,
                                   CASE WHEN OS.CHK1   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK1   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK1  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK1  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK1   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK1 = 0 OR OCI.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK1 = 0 OR OEI.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK1 = 0 OR OEA.CHK1 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK1 = 0 OR OEG.CHK1 IS NULL) THEN 'Y' ELSE 'N' END  AS ORD_CONTROL_1,
                                   CASE WHEN OS.CHK2   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK2   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK2  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK2  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK2   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK2 = 0 OR OCI.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK2 = 0 OR OEI.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK2 = 0 OR OEA.CHK2 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK2 = 0 OR OEG.CHK2 IS NULL) THEN 'Y' ELSE 'N' END  AS ORD_CONTROL_2,
                                   CASE WHEN OS.CHK3   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OI.CHK3   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OST.CHK3  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OSD.CHK3  = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN OT.CHK3   = 1 THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OCI.CHK3 = 0 OR OCI.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEI.CHK3 = 0 OR OEI.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEA.CHK3 = 0 OR OEA.CHK3 IS NULL) THEN 'Y' ELSE 'N' END ||
                                   CASE WHEN (OEG.CHK3 = 0 OR OEG.CHK3 IS NULL) THEN 'Y' ELSE 'N' END  AS ORD_CONTROL_3,
                                   OLM.LIMIT_QTY,
                                   OLM.ORD_QTY  ,
                                   OLM.ORD_COLLECT_MSG
                              FROM (
                                    SELECT I.ITEM_CD ,
                                           CASE WHEN F.NEW_TP IS NULL THEN '0' ELSE F.NEW_TP END DIV,
                                           CASE WHEN C_SDATE1 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK1,
                                           CASE WHEN C_SDATE2 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK2,
                                           CASE WHEN C_SDATE3 BETWEEN I.ORD_START_DT AND I.ORD_CLOSE_DT THEN 1 ELSE 0 END I_CHK3,
                                           IC.COST1,
                                           IC.COST2,
                                           IC.COST3,
                                           I.L_CLASS_CD,
                                           I.M_CLASS_CD,
                                           I.S_CLASS_CD,
                                           I.ITEM_NM ,
                                           CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                                WHEN ls_ord_tp= 'M' THEN I.L_CLASS_CD || I.M_CLASS_CD
                                                WHEN ls_ord_tp= 'S' THEN I.L_CLASS_CD || I.M_CLASS_CD || I.S_CLASS_CD
                                                ELSE NULL
                                           END ORD_SGRP,
                                           CASE WHEN ls_ord_tp= 'L' THEN I.L_CLASS_CD
                                                WHEN ls_ord_tp= 'M' THEN I.M_CLASS_CD
                                                WHEN ls_ord_tp= 'S' THEN I.S_CLASS_CD
                                                ELSE NULL
                                           END ORD_SGRP_CD,
                                           I.ITEM_DIV,
                                           I.ORD_UNIT,
                                           I.ORD_UNIT_QTY,
                                           I.ORD_B_CNT,
                                           I.ORD_START_DT,
                                           I.ORD_CLOSE_DT,
                                           I.MIN_ORD_QTY,
                                           I.ALERT_ORD_QTY,
                                           F.NEW_TP,
                                           0 SALE_RANK,
                                           CASE WHEN RI.ITEM_CD IS NULL THEN '0' ELSE '1' END BASIC_CHK
                                      FROM ITEM_CHAIN     I,
                                           ITEM_FLAG_ALL  F,
                                           (
                                            SELECT ITEM_CD, MAX(COST1) COST1, MAX(COST2) COST2, MAX(COST3) COST3
                                              FROM (
                                                    SELECT ITEM_CD,
                                                           MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST1,
                                                           NULL COST2,
                                                           NULL COST3
                                                      FROM ITEM_CHAIN_HIS H
                                                     WHERE COMP_CD   = PSV_COMP_CD
                                                       AND BRAND_CD  = PSV_BRAND_CD
                                                       AND STOR_TP   = ls_stor_tp
                                                       AND START_DT <= C_SDATE1
                                                     GROUP BY ITEM_CD
                                                    UNION ALL
                                                    SELECT ITEM_CD,
                                                           NULL COST1,
                                                           MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST2,
                                                           NULL COST3
                                                      FROM ITEM_CHAIN_HIS H
                                                     WHERE COMP_CD   = PSV_COMP_CD
                                                       AND BRAND_CD  = PSV_BRAND_CD
                                                       AND STOR_TP   = ls_stor_tp
                                                       AND START_DT <= C_SDATE2
                                                    GROUP BY ITEM_CD
                                                    UNION ALL
                                                    SELECT ITEM_CD,
                                                           NULL COST1,
                                                           NULL COST2,
                                                           MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST3
                                                      FROM ITEM_CHAIN_HIS H
                                                     WHERE COMP_CD   = PSV_COMP_CD
                                                       AND BRAND_CD  = PSV_BRAND_CD
                                                       AND STOR_TP   = ls_stor_tp
                                                       AND START_DT <= C_SDATE3
                                                     GROUP BY ITEM_CD
                                                 ) ICG
                                             GROUP BY ITEM_CD
                                           ) IC,
                                           (
                                            SELECT DISTINCT ITEM_CD
                                              FROM REF_ITEM
                                             WHERE USE_YN ='Y'
                                           ) RI
                                     WHERE I.USE_YN       = 'Y'
                                       AND I.STOR_TP      = ls_stor_tp
                                       AND I.ORD_SALE_DIV IN  ( '1' , '2')
                                       AND I.ORD_MNG_DIV = '0'
                                       AND I.COMP_CD     = PSV_COMP_CD
                                       AND I.BRAND_CD    = PSV_BRAND_CD
                                       AND (    C_SDATE1 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT,'9')
                                            OR  C_SDATE2 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT,'9')
                                            OR  C_SDATE3 BETWEEN I.ORD_START_DT AND NVL(I.ORD_CLOSE_DT,'9')
                                           )
                                       AND I.ITEM_CD = IC.ITEM_CD
                                       AND I.ITEM_CD = F.ITEM_CD (+)
                                       AND I.ITEM_CD = RI.ITEM_CD (+)
                                       AND (( PSV_ITEM_DIV NOT IN ( 'NEW', 'MY', 'LIMITORD' ) AND I.ITEM_DIV = PSV_ITEM_DIV ) OR
                                            ( PSV_ITEM_DIV = 'NEW'      AND I.ITEM_CD IN     ( SELECT ITEM_CD FROM NEW_ITEM )
                                                                        AND I.ITEM_CD NOT IN ( SELECT ITEM_CD FROM O_COLLECT WHERE EVT_FG = '3' ) ) OR
                                            ( PSV_ITEM_DIV = 'MY'       AND I.ITEM_CD IN     ( SELECT ITEM_CD FROM ORDER_DT
                                                                                                WHERE SHIP_DT BETWEEN C_MY_ODATE AND C_ODATE
                                                                                                  AND COMP_CD       = PSV_COMP_CD
                                                                                                  AND BRAND_CD      = PSV_BRAND_CD
                                                                                                  AND STOR_CD       = PSV_STOR_CD
                                                                                                GROUP BY ITEM_CD
                                                                                             )
                                                                        AND I.ITEM_CD NOT IN ( SELECT ITEM_CD FROM O_COLLECT WHERE EVT_FG = '3' ) ) OR
                                            ( PSV_ITEM_DIV = 'LIMITORD' AND I.ITEM_CD     IN ( SELECT ITEM_CD FROM O_COLLECT WHERE EVT_FG = '3' ) )
                                           )
                                   ) I,
                                   (
                                    SELECT ORD_GRP ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_SEQ
                                     WHERE COMP_CD  = PSV_COMP_CD
                                       AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                     GROUP BY ORD_GRP
                                   ) OS,
                                   O_CHK_TM  OT,
                                   (
                                    SELECT ORD_GRP,
                                           ITEM_CD ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_ITEM
                                     WHERE COMP_CD  = PSV_COMP_CD
                                       AND ORD_GRP IN ( SELECT ORD_GRP FROM O_GRP )
                                     GROUP BY ORD_GRP, ITEM_CD
                                   ) OI,
                                   (
                                    SELECT ITEM_CD ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY1  AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY2  AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN DLV_WK = C_SDAY3  AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_CENTER_ITEM
                                     WHERE COMP_CD   = PSV_COMP_CD
                                       AND USE_YN    = 'Y'
                                       AND CENTER_CD = ls_center_cd
                                     GROUP BY ITEM_CD
                                   ) OCI,
                                   (SELECT ORD_GRP,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ1 THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ2 THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN USE_YN = 'Y' AND ORD_SEQ = C_SEQ3 THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_ORD_GRP_STORE
                                     WHERE ORD_GRP IN (SELECT ORD_GRP FROM O_GRP)
                                       AND COMP_CD  = PSV_COMP_CD
                                       AND BRAND_CD = PSV_BRAND_CD
                                       AND STOR_CD  = PSV_STOR_CD
                                     GROUP BY ORD_GRP
                                   ) OST,
                                   (SELECT ITEM_CD ,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_ITEM   OE2,
                                           OC_EXC_SEQ    OE3
                                     WHERE OE1.COMP_CD     = PSV_COMP_CD
                                       AND OE1.USE_YN      = 'Y'
                                       AND OE1.ITEM_DIV    = 'I'
                                       AND OE1.COMP_CD     = OE2.COMP_CD
                                       AND OE1.SEQ         = OE2.SEQ
                                       AND OE1.COMP_CD     = OE3.COMP_CD(+)
                                       AND OE1.SEQ         = OE3.SEQ (+)
                                       AND OE2.USE_YN      = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND OE3.USE_YN (+)  = 'Y'
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                      GROUP BY ITEM_CD
                                   ) OEI,
                                   (SELECT MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_SEQ    OE3
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'A'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_TP  = ls_stor_tp
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                   ) OEA,
                                   (SELECT OE2.ORD_GRP,
                                           MAX( CASE WHEN ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ1 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK1 ,
                                           MAX( CASE WHEN ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ2 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK2 ,
                                           MAX( CASE WHEN ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) AND ( OE3.ORD_SEQ = C_SEQ3 OR OE1.ORD_SEQ_DIV = '1') THEN 1 ELSE 0 END ) CHK3
                                      FROM OC_EXC_PERIOD OE1,
                                           OC_EXC_GRP    OE2,
                                           OC_EXC_SEQ    OE3
                                     WHERE OE1.COMP_CD   = PSV_COMP_CD
                                       AND OE1.USE_YN    = 'Y'
                                       AND OE1.ITEM_DIV  = 'G'
                                       AND OE1.COMP_CD   = OE3.COMP_CD(+)
                                       AND OE1.SEQ       = OE3.SEQ (+)
                                       AND OE3.USE_YN(+) = 'Y'
                                       AND OE1.COMP_CD   = OE2.COMP_CD
                                       AND OE1.SEQ       = OE2.SEQ
                                       AND OE2.USE_YN    = 'Y'
                                       AND ( ( C_SDATE1 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE2 BETWEEN OE1.START_DT AND OE1.END_DT ) OR
                                             ( C_SDATE3 BETWEEN OE1.START_DT AND OE1.END_DT ) )
                                       AND ( (OE1.STOR_DIV = 'S' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_STORE OES
                                                                              WHERE OE1.SEQ      = OES.SEQ
                                                                                AND OES.COMP_CD  = PSV_COMP_CD
                                                                                AND OES.BRAND_CD = PSV_BRAND_CD
                                                                                AND OES.STOR_CD  = PSV_STOR_CD
                                                                                AND OES.USE_YN   = 'Y'
                                                                            )
                                             ) OR
                                             (OE1.STOR_DIV = 'B' AND EXISTS (SELECT '1'
                                                                               FROM OC_EXC_BRAND OES
                                                                              WHERE OE1.SEQ   = OES.SEQ
                                                                             AND OES.COMP_CD  = PSV_COMP_CD
                                                                             AND OES.BRAND_CD = PSV_BRAND_CD
                                                                             AND OES.STOR_TP  = ls_stor_tp
                                                                             AND OES.USE_YN   = 'Y'
                                                                            )
                                             )
                                           )
                                     GROUP BY ORD_GRP
                                   ) OEG ,
                                   O_COLLECT OLM,
                                   O_DDAY    OSD,
                                   O_CLASS   IG,
                                   LANG_ITEM IL
                             WHERE I.ITEM_CD   = OI.ITEM_CD
                               AND OI.ORD_GRP  = OS.ORD_GRP
                               AND OI.ORD_GRP  = OT.ORD_GRP
                               AND I.ITEM_CD   = OCI.ITEM_CD (+)
                               AND OI.ORD_GRP  = OST.ORD_GRP
                               AND I.ITEM_CD   = OEI.ITEM_CD (+)
                               AND OI.ORD_GRP  = OEG.ORD_GRP (+)
                               AND I.ITEM_CD   = OLM.ITEM_CD (+)
                               AND '3'         = OLM.EVT_FG  (+)
                               AND OI.ORD_GRP  = OSD.ORD_GRP
                               AND I.ORD_SGRP  = IG.CLASS_CD (+)
                               AND I.ITEM_CD   = IL.ITEM_CD  (+)
                               AND IL.LANGUAGE_TP(+) = PSV_LANG_CD
                               AND IL.COMP_CD(+)     = PSV_COMP_CD
                           ) OI,
                           O_TR OQ,
                           (
                            SELECT ITEM_CD ,
                                    SUM(CASE WHEN SALE_DT = C_ODATE    THEN SALE_QTY ELSE 0 END) GRD_AMT,
                                    SUM(CASE WHEN SALE_DT = C_PW_ODATE THEN SALE_QTY ELSE 0 END) GRD_PW_AMT
                               FROM SALE_JDM
                              WHERE SALE_DT  IN ( C_ODATE, C_PW_ODATE )
                                AND COMP_CD  = PSV_COMP_CD
                                AND BRAND_CD = PSV_BRAND_CD
                                AND STOR_CD  = PSV_STOR_CD
                              GROUP BY ITEM_CD
                           ) SQ,
                           (
                            SELECT B.ITEM_CD
                              FROM (SELECT MAX(START_DT) START_DT
                                      FROM REJECT_SYSTEM
                                     WHERE USE_YN    = 'Y'
                                       AND COMP_CD   = PSV_COMP_CD
                                       AND BRAND_CD  = PSV_BRAND_CD
                                       AND STOR_CD   = PSV_STOR_CD
                                       AND START_DT <= C_SDATE1
                                   )  A,
                                   REJECT_SYSTEM_ITEM B
                             WHERE B.COMP_CD  = PSV_COMP_CD
                               AND B.BRAND_CD = PSV_BRAND_CD
                               AND B.STOR_CD  = PSV_STOR_CD
                               AND A.START_DT = B.START_DT
                               AND B.USE_YN   = 'Y'
                           ) RS,
                           (SELECT C.CODE_CD, NVL(L.CODE_NM, C.CODE_NM) CODE_NM
                              FROM COMMON C, LANG_COMMON L
                             WHERE C.COMP_CD = L.COMP_CD(+) 
                               AND C.CODE_CD = L.CODE_CD(+)
                               AND C.COMP_CD = PSV_COMP_CD
                               AND C.CODE_TP = '00095' -- 단위
                               AND C.CODE_TP = L.CODE_TP(+)
                               AND L.LANGUAGE_TP (+) = PSV_LANG_CD
                           ) C_00095
                     WHERE OI.ITEM_CD = OQ.ITEM_CD (+)
                       AND OI.ITEM_CD = SQ.ITEM_CD (+)
                       AND OI.ITEM_CD = RS.ITEM_CD (+)
                       AND OI.ORD_UNIT = C_00095.CODE_CD (+)
                   ) A1
           ) A
     WHERE (  SORT_ORDER  = '1' )
     ORDER BY GRP_SORT, CLASS_NM, ORD_GRP, SORT_ORDER, TO_NUMBER(CASE WHEN SORT_ORDER = '0' THEN '0' ELSE ROW_NO END);
     
    PR_RTN_CD := ls_err_cd ;
    
    -- dbms_output.enable( 1000000 ) ;
    -- dbms_output.put_line( ls_sql ) ;
    
  EXCEPTION
    WHEN ERR_HANDLER THEN
         PR_RTN_CD := ls_err_cd ;
    WHEN OTHERS THEN
         dbms_output.put_line( sqlerrM ) ;
         PR_RTN_CD := ERR_4999999 ;
  END;
  
  PROCEDURE SP_ORDER_LIST
  (
    PSV_LANG_CD     IN  VARCHAR2    -- 언어 코드
  , PSV_COMP_CD     IN  VARCHAR2    -- 회사코드
  , PSV_BRAND_CD    IN  VARCHAR2    -- 영업조직
  , PSV_STOR_CD     IN  VARCHAR2    -- 점포코드
  , PSV_SHIP_DT     IN  VARCHAR2    -- 배송일자
  , PSV_ITEM_DIV    IN  VARCHAR2    -- 주문그룹
  , PSV_ITEM_TP     IN  VARCHAR2    -- 제품타입
  , PSV_ORD_GRP     IN  VARCHAR2    -- 주문등록그룹
  , PSV_ORD_FG      IN  VARCHAR2    -- 주문구분
  , PR_RTN_CD       OUT VARCHAR2    -- 처리코드
  , PR_RESULT       IN OUT PKG_REPORT.REF_CUR
  ) IS
  BEGIN
    CASE WHEN PSV_ITEM_DIV = 'ORDLIST' THEN
              SP_ORDER_LIST_DB   ( PSV_LANG_CD, PSV_COMP_CD, PSV_BRAND_CD,PSV_STOR_CD,PSV_SHIP_DT,PSV_ITEM_DIV,PSV_ITEM_TP,PSV_ORD_GRP ,PSV_ORD_FG,PR_RTN_CD,PR_RESULT ) ;
         WHEN PSV_ORD_FG = '01' AND PSV_ITEM_DIV = 'LINK' THEN
              SP_ORDER_LIST_LINK ( PSV_LANG_CD, PSV_COMP_CD, PSV_BRAND_CD,PSV_STOR_CD,PSV_SHIP_DT,PSV_ITEM_DIV,PSV_ITEM_TP,PSV_ORD_GRP ,PSV_ORD_FG,PR_RTN_CD,PR_RESULT ) ;
         ELSE
              SP_ORDER_LIST_MAIN ( PSV_LANG_CD, PSV_COMP_CD, PSV_BRAND_CD,PSV_STOR_CD,PSV_SHIP_DT,PSV_ITEM_DIV,PSV_ITEM_TP,PSV_ORD_GRP ,PSV_ORD_FG,PR_RTN_CD,PR_RESULT ) ;
    END CASE ;
  EXCEPTION
    WHEN OTHERS THEN
         PR_RTN_CD := ERR_4999999 ;
         RAISE ERR_HANDLER ;
  END;
END ;

/
