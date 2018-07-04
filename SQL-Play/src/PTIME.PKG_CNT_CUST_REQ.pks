CREATE OR REPLACE PACKAGE      PKG_CNT_CUST_REQ AS
--------------------------------------------------------------------------------
--  Package Name     : PKG_CNT_CUST_REQ
--  Description      : CNT연동용 멤버십
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2015-01-13
--  Modify Date      : 2015-01-13 
--------------------------------------------------------------------------------
  
  P_COMP_CD        VARCHAR2(4)  := '012'; -- DEFAULT
  P_BRAND_CD       VARCHAR2(4)  := '101';
  P_STOR_CD        VARCHAR2(10) := '';  
  
  PROCEDURE GET_CUST_INFO_10
  (
    PSV_REQ_DIV           IN   VARCHAR2, -- 1. 조회구분[1:회원ID, 2:고객명, 3:휴대번호(뒤4자리), 4:카드번호]
    PSV_REQ_VAL           IN   VARCHAR2, -- 2. 조회값
    asRetVal              OUT  VARCHAR2, -- 3. 결과코드[1:정상  그외는 오류]
    asRetMsg              OUT  VARCHAR2, -- 4. 결과메시지
    asResult              OUT  REC_SET.M_REFCUR
  );
  
  PROCEDURE SET_MEMB_CHG_10
  (
    PSV_CARD_ID           IN   VARCHAR2, -- 1. 카드번호
    PSV_USE_DT            IN   VARCHAR2, -- 2. 사용일자
    PSV_MEMB_DIV          IN   VARCHAR2, -- 3. 멤버십구분[2: 포인트]
    PSV_SALE_DIV          IN   VARCHAR2, -- 4. 판매구분[201:적립, 202:적립반품]
    PSV_SAV_PT            IN   NUMBER,   -- 5. 적립포인트
    PSV_STOR_CD           IN   VARCHAR2, -- 6. 점포코드
    PSV_USE_TM            IN   VARCHAR2, -- 7. 사용시간
    PSV_ORG_USE_DT        IN   VARCHAR2, -- 8. 원거래일자
    PSV_ORG_USE_SEQ       IN   VARCHAR2, -- 9. 원거래일련번호
    asRetVal              OUT  VARCHAR2, -- 10. 결과코드[1:정상  그외는 오류]
    asRetMsg              OUT  VARCHAR2, -- 11. 결과메시지
    asResult              OUT  REC_SET.M_REFCUR
  );

END PKG_CNT_CUST_REQ;

/

CREATE OR REPLACE PACKAGE BODY      PKG_CNT_CUST_REQ AS
  ------------------------------------------------------------------------------
  --  Package Name     : SET_MEMB_CHG_10
  --  Description      : POS 멤버십 적립 > CNT연동
  ------------------------------------------------------------------------------
  --  Create Date      : 2015-01-13
  --  Modify Date      : 
  ------------------------------------------------------------------------------
  PROCEDURE GET_CUST_INFO_10
  (
    PSV_REQ_DIV           IN   VARCHAR2, -- 1. 조회구분[1:회원ID, 2:고객명, 3:휴대번호(뒤4자리), 4:카드번호, 5:휴대번호FULL]
    PSV_REQ_VAL           IN   VARCHAR2, -- 2. 조회값
    asRetVal              OUT  VARCHAR2, -- 3. 결과코드[1:정상  그외는 오류]
    asRetMsg              OUT  VARCHAR2, -- 4. 결과메시지
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
   
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- 카드 ID
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- 회원 ID
    ls_Sql_Main     VARCHAR2(32000) := NULL;
    nRecCnt         NUMBER(7) := 0;
    
    ERR_HANDLER     EXCEPTION;
    
  BEGIN
    asRetVal    := '0000';
    asRetMsg    := 'OK';
    
    -- 회원: 회원 ID, 회원명, 핸드폰, 회원등급, 최종포인트, 고객상태, 포인트 적립율
    ls_Sql_Main :=          '    SELECT CRD.CUST_ID                     '
        ||chr(13)||chr(10)||'         , CST.CUST_NM     AS CUST_NM        '
        ||chr(13)||chr(10)||'         , CST.MOBILE      AS MOBILE         '
        ||chr(13)||chr(10)||'         , LVL.LVL_NM      AS CUST_LVL       '
        ||chr(13)||chr(10)||'         , CST.SAV_PT - CST.USE_PT - CST.LOS_PT    AS POINT   '
        ||chr(13)||chr(10)||'         , CST.CUST_STAT   AS CUST_STAT      '
        ||chr(13)||chr(10)||'         , GET_COMMON_CODE_NM(''01720'', CST.CUST_STAT, ''KOR'') AS CUST_STAT_NM  '
        ||chr(13)||chr(10)||'         , LVL.SAV_PT_RATE                 '
        ||chr(13)||chr(10)||'         , SUBSTR(CRD.ISSUE_DT, 1, 6)              AS ISSUE_DT '
        ||chr(13)||chr(10)||'      FROM C_CUST     CST             '   -- 회원 마스터
        ||chr(13)||chr(10)||'         , C_CARD     CRD             '   -- 멤버십카드 마스터
        ||chr(13)||chr(10)||'         , C_CUST_LVL LVL             '
        ||chr(13)||chr(10)||'     WHERE CST.COMP_CD     = LVL.COMP_CD   '
        ||chr(13)||chr(10)||'       AND CST.LVL_CD      = LVL.LVL_CD    '
        ||chr(13)||chr(10)||'       AND CRD.COMP_CD     = CST.COMP_CD   '
        ||chr(13)||chr(10)||'       AND CRD.CUST_ID     = CST.CUST_ID   '
        ||chr(13)||chr(10)||'       AND CRD.COMP_CD     = ''012'''
        ||chr(13)||chr(10)||'       AND CRD.USE_YN      = ''Y'''            -- 사용여부[Y:사용, N:사용안함]
        ||chr(13)||chr(10)||'       AND CST.CUST_STAT   = ''2'''            -- 회원상태[1:가입, 2:멤버십, 9:탈퇴]
        ||chr(13)||chr(10)||'       AND CST.USE_YN      = ''Y'''            -- 사용여부[Y:사용, N:사용안함]
        ;
        
    -- 조건절
    CASE WHEN PSV_REQ_DIV = '1' THEN 
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CRD.CUST_ID     =  '''||PSV_REQ_VAL||''' AND CRD.REP_CARD_YN = ''Y''';
         WHEN PSV_REQ_DIV = '2' THEN    
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.CUST_NM     =  '''||PSV_REQ_VAL||''' AND CRD.REP_CARD_YN = ''Y''';
         WHEN PSV_REQ_DIV = '3' THEN    
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.MOBILE_N3   =  '''||PSV_REQ_VAL||''' AND CRD.REP_CARD_YN = ''Y''';
         WHEN PSV_REQ_DIV = '4' THEN    
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CRD.CARD_ID     =  '''||PSV_REQ_VAL||'''';
         WHEN PSV_REQ_DIV = '5' THEN    
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.MOBILE      =  '''||PSV_REQ_VAL||''' AND CRD.REP_CARD_YN = ''Y''';
         ELSE
              ls_Sql_Main := ls_Sql_Main;
    END CASE;
    
    DBMS_OUTPUT.PUT_LINE(ls_Sql_Main);
    
    OPEN asResult FOR   ls_Sql_Main;
    
    asRetMsg := FC_GET_WORDPACK_MSG('012', 'KOR', '1010001392'); -- 정상처리 되었습니다.
    
    RETURN;
  EXCEPTION
    WHEN ERR_HANDLER THEN
         RETURN;
    WHEN OTHERS THEN
         asRetVal := 1003;
         IF PSV_REQ_DIV = '4' THEN
            asRetMsg := FC_GET_WORDPACK_MSG('012', 'KOR', '1010001393');  -- 카드번호를 확인 하세요.
         ELSE
            asRetMsg := FC_GET_WORDPACK_MSG('012', 'KOR', '1010001385');  -- 회원정보를 확인 하세요.
         END IF;
         
         RETURN;
  END GET_CUST_INFO_10;
  
  PROCEDURE SET_MEMB_CHG_10
  (
    PSV_CARD_ID           IN   VARCHAR2, -- 1. 카드번호
    PSV_USE_DT            IN   VARCHAR2, -- 2. 사용일자
    PSV_MEMB_DIV          IN   VARCHAR2, -- 3. 멤버십구분[2: 포인트]
    PSV_SALE_DIV          IN   VARCHAR2, -- 4. 판매구분[201:적립, 202:적립반품]
    PSV_SAV_PT            IN   NUMBER,   -- 5. 적립포인트
    PSV_STOR_CD           IN   VARCHAR2, -- 6. 점포코드
    PSV_USE_TM            IN   VARCHAR2, -- 7. 사용시간
    PSV_ORG_USE_DT        IN   VARCHAR2, -- 8. 원거래일자
    PSV_ORG_USE_SEQ       IN   VARCHAR2, -- 9. 원거래일련번호
    asRetVal              OUT  VARCHAR2, -- 10. 결과코드[1:정상  그외는 오류]
    asRetMsg              OUT  VARCHAR2, -- 11. 결과메시지
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
  
    lsCardId        C_CARD.CARD_ID%TYPE;               -- 카드 ID
    lsCustId        C_CARD.CUST_ID%TYPE;               -- 회원 ID
    nRecSeq         VARCHAR2(7);                       -- 일련번호
    nRecCnt         NUMBER(7) := 0;                    -- 레코드 수
    nCurPoint       C_CARD.SAV_PT%TYPE   := 0;         -- 현재 포인트
    
    ERR_HANDLER     EXCEPTION;
    
  BEGIN
  
    asRetVal    := '0000';
    asRetMsg    := 'OK'  ;
    
    BEGIN
      SELECT COUNT(*), MAX(SAV_PT - USE_PT - LOS_PT), MAX(CUST_ID)
        INTO nRecCnt,  nCurPoint,                     lsCustId
        FROM C_CARD
       WHERE COMP_CD   = '012'
         AND CARD_ID   = PSV_CARD_ID
         AND CARD_STAT = '10' -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기]
         AND USE_YN    = 'Y'; -- 사용여부[Y:사용, N:사용안함]
         
      IF nRecCnt = 0 THEN
         asRetVal := '1001';
         asRetMsg := FC_GET_WORDPACK_MSG('012', 'KOR', '1010001394'); -- 등록하지 않은 카드번호 입니다.
         
         RETURN;
      END IF;
    END;
    
    -- 원거래 존재여부 / 기 취소여부 체크
    IF PSV_SALE_DIV IN ('202') THEN
        -- 원거래 존재여부
        IF PSV_SALE_DIV IN ('202') THEN
            SELECT COUNT(*)
              INTO nRecCnt
              FROM C_CARD_SAV_HIS
             WHERE COMP_CD = '012'
               AND CARD_ID = PSV_CARD_ID
               AND USE_DT  = PSV_ORG_USE_DT
               AND USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ);
        END IF;
            
        IF nRecCnt = 0 THEN
            asRetVal := '1020';
            asRetMsg := FC_GET_WORDPACK_MSG('012', 'KOR', '1010001389'); -- 원거래 내역이 존재하지 않습니다.
            
            RETURN;
        END IF;
        
        -- 기 취소여부 체크
        IF PSV_SALE_DIV IN ('202') THEN
            SELECT COUNT(*)
              INTO nRecCnt
              FROM C_CARD_SAV_HIS
             WHERE COMP_CD     = '012'
               AND CARD_ID     = PSV_CARD_ID
               AND ORG_USE_DT  = PSV_ORG_USE_DT
               AND ORG_USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ);
        END IF;
       
        IF nRecCnt > 0 THEN
            asRetVal := '1030';
            asRetMsg := FC_GET_WORDPACK_MSG('012', 'KOR', '1001343008'); -- 이미 반품 확정된 DATA입니다.
          
            RETURN;
        END IF;
    END IF;
    
   -- 일련번호 취득
   SELECT SQ_PCRM_SEQ.NEXTVAL
     INTO nRecSeq
     FROM DUAL;
           
   INSERT INTO C_CARD_SAV_HIS
   (
       COMP_CD     ,       CARD_ID     ,
       USE_DT      ,       USE_SEQ     ,
       SAV_USE_FG  ,
       SAV_USE_DIV ,
       REMARKS     ,
       SAV_PT      ,
       USE_PT      ,       LOS_PT      ,
       POS_NO      ,
       ORG_USE_DT  ,       ORG_USE_SEQ ,
       USE_TM      ,       USE_YN      ,
       INST_DT     ,       INST_USER   ,
       UPD_DT      ,       UPD_USER
   )
   VALUES
   (
       '012' ,       PSV_CARD_ID ,
       PSV_USE_DT  ,       nRecSeq     ,
       CASE WHEN PSV_SALE_DIV LIKE '2%' THEN '1'             ELSE '2'             END,
       PSV_SALE_DIV ,
       CASE WHEN PSV_SALE_DIV LIKE '2%' THEN '포인트 적립' ELSE '포인트 사용' END ||
       CASE WHEN PSV_SALE_DIV LIKE '%2' THEN '취소'          ELSE NULL            END,
       CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN PSV_SAV_PT  ELSE PSV_SAV_PT END,
       0,                  0,
       '98',
       PSV_ORG_USE_DT,     CASE WHEN PSV_ORG_USE_SEQ = '0' THEN NULL ELSE TO_NUMBER(PSV_ORG_USE_SEQ) END,
       PSV_USE_TM  ,       'Y'         ,
       SYSDATE    ,        'SYS'       ,
       SYSDATE    ,        'SYS'
   );
    
    COMMIT;
    
    OPEN asResult FOR
    SELECT  REC_SEQ, CUR_SAV_PNT
      FROM (-- 포인트(멤버십) 적립/취소
            SELECT nRecSeq AS REC_SEQ, SAV_PT - USE_PT - LOS_PT  AS CUR_SAV_PNT
              FROM C_CUST CST
             WHERE CUST_STAT = '2'  -- 회원상태[1:가입, 2:멤버십, 9:탈퇴]
               AND USE_YN    = 'Y'  -- 사용여부[Y:사용, N:사용안함]
               AND CUST_ID   = (SELECT CUST_ID
                                  FROM C_CARD
                                 WHERE COMP_CD   = '012'
                                   AND CARD_ID   = PSV_CARD_ID
                                   AND CARD_STAT = '10' -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기]
                                   AND USE_YN    = 'Y' -- 사용여부[Y:사용, N:사용안함]
                               )
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('201', '202') AND lsCustId IS NOT NULL THEN 1 ELSE 0 END)
            UNION ALL  -- 포인트(가발급) 카드 적립/취소
            SELECT nRecSeq AS REC_SEQ, SAV_PT - USE_PT - LOS_PT  AS CUR_SAV_PNT
              FROM C_CARD
             WHERE COMP_CD   = '012'
               AND CARD_ID   = PSV_CARD_ID
               AND CARD_STAT = '10' -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기]
               AND USE_YN    = 'Y' -- 사용여부[Y:사용, N:사용안함]
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('201', '202') AND lsCustId IS NULL THEN 1 ELSE 0 END)   
           );
           
    asRetMsg := FC_GET_WORDPACK_MSG('012', 'KOR', '1010001392'); -- 정상 처리되었습니다.
    
    RETURN;
  EXCEPTION
    WHEN ERR_HANDLER THEN
         OPEN asResult FOR
            SELECT 0
            FROM   DUAL;
             
         ROLLBACK;
         RETURN;
    WHEN OTHERS THEN
         OPEN asResult FOR
            SELECT 0
            FROM   DUAL;
             
         asRetVal := '1003';
         asRetMsg := FC_GET_WORDPACK_MSG('012', 'KOR', '1010001187')||'['||SQLERRM||']'; -- 오류가 발생하였습니다.
         
         ROLLBACK;
         RETURN;
  END SET_MEMB_CHG_10;

END PKG_CNT_CUST_REQ;

/
