--------------------------------------------------------
--  DDL for Package Body PKG_POS_CUST_POS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_POS_CUST_POS" AS 
-------------------------------------------------------------------------------- 
--  Procedure Name   : GET_CUST_INFO_10 
--  Description      : POS에서 회원/카드정보 조회 
--  Ref. Table       : C_CUST 회원 마스터 
--                     C_CARD 멤버십카드 마스터 
-------------------------------------------------------------------------------- 
--  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
--  Modify Date      : 2015-01-13  
-------------------------------------------------------------------------------- 
  PROCEDURE GET_CUST_INFO_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_REQ_DIV           IN   VARCHAR2, -- 3. 조회구분[1:회원ID, 2:고객명, 3:휴대번호(뒤4자리), 4:카드번호, 5:휴대번호FULL] 
    PSV_REQ_VAL           IN   VARCHAR2, -- 4. 조회값 
    asRetVal              OUT  VARCHAR2, -- 5. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 6. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
   
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- 카드 ID 
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- 회원 ID
    lsCustStat      C_CUST.CUST_STAT%TYPE;                  -- 회원 ID
    
    ls_Sql_Main     VARCHAR2(32000) := NULL; -- 메인쿼리
    ls_Sql_Check    VARCHAR2(32000) := NULL; -- 존재체크쿼리
    ls_Sql_Rest     VARCHAR2(32000) := NULL; -- 휴면고객 조회
    
    nRecCnt         NUMBER(7) := 0;  
    
    ERR_HANDLER     EXCEPTION;  
     
  BEGIN
    asRetVal    := '0000'; 
    asRetMsg    := ''; 
     
    -- 회원: 회원 ID, 회원명, 핸드폰, 회원등급, 적립 마일리지, 소멸 마일리지, 적립 포인트, 사용 포인트, 소멸 포인트, 충전금액, 사용금액, 마일리지 금지고객여부, 회원상태, 첫구매여부 
    -- 카드: 카드번호, 충전금액, 사용금액, 카드상태, 발급구분 
    ls_Sql_Main :=          '    SELECT CRD.CUST_ID                     ' 
        ||chr(13)||chr(10)||'         , CST.CUST_NM   AS CUST_NM        ' 
        ||chr(13)||chr(10)||'         , CST.MOBILE    AS MOBILE         ' 
        ||chr(13)||chr(10)||'         , CST.LVL_CD                      ' 
        ||chr(13)||chr(10)||'         , LVL.LVL_NM                      ' 
        ||chr(13)||chr(10)||'         , CST.SAV_MLG                     ' 
        ||chr(13)||chr(10)||'         , CST.LOS_MLG                     ' 
        ||chr(13)||chr(10)||'         , CST.SAV_PT                      ' 
        ||chr(13)||chr(10)||'         , CST.USE_PT                      ' 
        ||chr(13)||chr(10)||'         , CST.LOS_PT                      ' 
        ||chr(13)||chr(10)||'         , CST.SAV_CASH                    ' 
        ||chr(13)||chr(10)||'         , CST.USE_CASH                    ' 
        ||chr(13)||chr(10)||'         , CST.MLG_DIV                     ' 
        ||chr(13)||chr(10)||'         , CST.CUST_STAT                   ' 
        ||chr(13)||chr(10)||'         , CRD.CARD_ID     AS CARD_ID      ' 
        ||chr(13)||chr(10)||'         , CRD.SAV_CASH    AS CARD_SAV_CASH' 
        ||chr(13)||chr(10)||'         , CRD.USE_CASH    AS CARD_USE_CASH' 
        ||chr(13)||chr(10)||'         , CRD.CARD_STAT   AS CARD_STAT    ' 
        ||chr(13)||chr(10)||'         , GET_COMMON_CODE_NM(''01725'', CRD.CARD_STAT, '''||PSV_LANG_TP||''') AS CARD_STAT_NM   ' 
        ||chr(13)||chr(10)||'         , CRD.ISSUE_DIV   AS ISSUE_DIV    ' 
        ||chr(13)||chr(10)||'         , CRD.SAV_PT      AS CARD_SAV_PT  ' 
        ||chr(13)||chr(10)||'         , CRD.USE_PT      AS CARD_USE_PT  ' 
        ||chr(13)||chr(10)||'         , CRD.LOS_PT      AS CARD_LOS_PT  ' 
        ||chr(13)||chr(10)||'         , LVL.SAV_PT_RATE                 ' 
        ||chr(13)||chr(10)||'         , NVL(CST.CASH_BILL_DIV, ''4'') AS CASH_BILL_DIV ' 
        ||chr(13)||chr(10)||'         , CASE WHEN NVL(CST.CASH_BILL_DIV, ''4'') = ''1'' THEN ISSUE_MOBILE  ' 
        ||chr(13)||chr(10)||'                WHEN NVL(CST.CASH_BILL_DIV, ''4'') = ''2'' THEN ISSUE_BUSI_NO ' 
        ||chr(13)||chr(10)||'                ELSE NULL ' 
        ||chr(13)||chr(10)||'           END AS ISSUE_MOB_BUSI '
        ||chr(13)||chr(10)||'         , CRD.MEMB_DIV    AS MEMB_DIV     ' 
        ||chr(13)||chr(10)||'      FROM C_CUST     CST             '   -- 회원 마스터 
        ||chr(13)||chr(10)||'         , C_CARD     CRD             '   -- 멤버십카드 마스터 
        ||chr(13)||chr(10)||'         , C_CUST_LVL LVL             ' 
        ||chr(13)||chr(10)||'     WHERE CST.COMP_CD     = LVL.COMP_CD   ' 
        ||chr(13)||chr(10)||'       AND CST.LVL_CD      = LVL.LVL_CD    ' 
        ||chr(13)||chr(10)||'       AND CRD.COMP_CD     = CST.COMP_CD   ' 
        ||chr(13)||chr(10)||'       AND CRD.CUST_ID     = CST.CUST_ID   ' 
        ||chr(13)||chr(10)||'       AND CRD.COMP_CD     = ''' || PSV_COMP_CD ||'''' 
        ||chr(13)||chr(10)||'       AND CRD.USE_YN      = ''Y'''            -- 사용여부[Y:사용, N:사용안함] 
      --||chr(13)||chr(10)||'       AND CST.CUST_STAT   = ''2'''            -- 회원상태[1:가입, 2:멤버십, 9:탈퇴] 
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
     
    ls_Sql_Main := ls_Sql_Main 
        ||chr(13)||chr(10)||'    UNION ALL                          ' 
        ||chr(13)||chr(10)||'    SELECT CST.CUST_ID                 ' 
        ||chr(13)||chr(10)||'         , CST.CUST_NM  AS CUST_NM     ' 
        ||chr(13)||chr(10)||'         , CST.MOBILE   AS MOBILE      ' 
        ||chr(13)||chr(10)||'         , CST.LVL_CD                  ' 
        ||chr(13)||chr(10)||'         , LVL.LVL_NM                  ' 
        ||chr(13)||chr(10)||'         , CST.SAV_MLG                 ' 
        ||chr(13)||chr(10)||'         , CST.LOS_MLG                 ' 
        ||chr(13)||chr(10)||'         , CST.SAV_PT                  ' 
        ||chr(13)||chr(10)||'         , CST.USE_PT                  ' 
        ||chr(13)||chr(10)||'         , CST.LOS_PT                  ' 
        ||chr(13)||chr(10)||'         , CST.SAV_CASH                ' 
        ||chr(13)||chr(10)||'         , CST.USE_CASH                ' 
        ||chr(13)||chr(10)||'         , CST.MLG_DIV                 ' 
        ||chr(13)||chr(10)||'         , CST.CUST_STAT               ' 
        ||chr(13)||chr(10)||'         , NULL AS CARD_ID             ' 
        ||chr(13)||chr(10)||'         , NULL AS CARD_SAV_CASH       ' 
        ||chr(13)||chr(10)||'         , NULL AS CARD_USE_CASH       ' 
        ||chr(13)||chr(10)||'         , NULL AS CARD_STAT           ' 
        ||chr(13)||chr(10)||'         , NULL AS CARD_STAT_NM        ' 
        ||chr(13)||chr(10)||'         , NULL AS ISSUE_DIV           ' 
        ||chr(13)||chr(10)||'         , NULL AS CARD_SAV_PT         ' 
        ||chr(13)||chr(10)||'         , NULL AS CARD_USE_PT         ' 
        ||chr(13)||chr(10)||'         , NULL AS CARD_LOS_PT         ' 
        ||chr(13)||chr(10)||'         , LVL.SAV_PT_RATE             ' 
        ||chr(13)||chr(10)||'         , NVL(CST.CASH_BILL_DIV, ''4'') AS CASH_BILL_DIV ' 
        ||chr(13)||chr(10)||'         , CASE WHEN NVL(CST.CASH_BILL_DIV, ''4'') = ''1'' THEN ISSUE_MOBILE  ' 
        ||chr(13)||chr(10)||'                WHEN NVL(CST.CASH_BILL_DIV, ''4'') = ''2'' THEN ISSUE_BUSI_NO ' 
        ||chr(13)||chr(10)||'                ELSE NULL ' 
        ||chr(13)||chr(10)||'           END AS ISSUE_MOB_BUSI '
        ||chr(13)||chr(10)||'         , CASE WHEN CST.CUST_STAT IN (''3'',''7'') THEN ''1'' ELSE ''0'' END AS MEMB_DIV ' 
        ||chr(13)||chr(10)||'      FROM C_CUST     CST         '   -- 회원 마스터 
        ||chr(13)||chr(10)||'         , C_CUST_LVL LVL         ' 
        ||chr(13)||chr(10)||'     WHERE CST.COMP_CD   = LVL.COMP_CD ' 
        ||chr(13)||chr(10)||'       AND CST.LVL_CD    = LVL.LVL_CD  ' 
        ||chr(13)||chr(10)||'       AND CST.COMP_CD   = ''' || PSV_COMP_CD ||'''' 
      --||chr(13)||chr(10)||'       AND CST.CUST_STAT = ''2'''          -- 회원상태[1:가입, 2:멤버십, 9:탈퇴] 
        ||chr(13)||chr(10)||'       AND CST.USE_YN    = ''Y'''          -- 사용여부[Y:사용, N:사용안함] 
        ||chr(13)||chr(10)||'       AND NOT EXISTS(SELECT 1         ' 
        ||chr(13)||chr(10)||'                        FROM C_CARD CRD           ' 
        ||chr(13)||chr(10)||'                       WHERE CRD.COMP_CD = CST.COMP_CD ' 
        ||chr(13)||chr(10)||'                         AND CRD.CUST_ID = CST.CUST_ID ' 
        ||chr(13)||chr(10)||'                         AND CRD.USE_YN  = ''Y'''      -- 사용여부[Y:사용, N:사용안함] 
        ||chr(13)||chr(10)||'                      )                ' 
        ; 
         
    --조건절 
    CASE  
        WHEN PSV_REQ_DIV = '1' THEN  
            ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.CUST_ID     =  '''||PSV_REQ_VAL||''''; 
        WHEN PSV_REQ_DIV = '2' THEN     
            ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.CUST_NM     =  '''||PSV_REQ_VAL||''''; 
        WHEN PSV_REQ_DIV = '3' THEN     
            ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.MOBILE_N3   =  '''||PSV_REQ_VAL||''''; 
        WHEN PSV_REQ_DIV = '5' THEN     
            ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.MOBILE      =  '''||PSV_REQ_VAL||'''';     
        ELSE 
            ls_Sql_Main := ls_Sql_Main||chr(13)||chr(10)||'   AND 1 = 2 '; 
    END CASE; 
     
    ls_Sql_Main := ls_Sql_Main 
        ||chr(13)||chr(10)||'    UNION ALL                          ' 
        ||chr(13)||chr(10)||'    SELECT NULL AS CUST_ID             ' 
        ||chr(13)||chr(10)||'         , NULL AS CUST_NM             ' 
        ||chr(13)||chr(10)||'         , NULL AS MOBILE              ' 
        ||chr(13)||chr(10)||'         , NULL AS LVL_CD              ' 
        ||chr(13)||chr(10)||'         , NULL AS LVL_NM              ' 
        ||chr(13)||chr(10)||'         , NULL AS SAV_MLG             ' 
        ||chr(13)||chr(10)||'         , NULL AS LOS_MLG             ' 
        ||chr(13)||chr(10)||'         , NULL AS SAV_PT              ' 
        ||chr(13)||chr(10)||'         , NULL AS USE_PT              ' 
        ||chr(13)||chr(10)||'         , NULL AS LOS_PT              ' 
        ||chr(13)||chr(10)||'         , NULL AS SAV_CASH            ' 
        ||chr(13)||chr(10)||'         , NULL AS USE_CASH            ' 
        ||chr(13)||chr(10)||'         , NULL AS MLG_DIV             ' 
        ||chr(13)||chr(10)||'         , NULL AS CUST_STAT           ' 
        ||chr(13)||chr(10)||'         , CRD.CARD_ID   AS CARD_ID    ' 
        ||chr(13)||chr(10)||'         , CRD.SAV_CASH  AS CARD_SAV_CASH  ' 
        ||chr(13)||chr(10)||'         , CRD.USE_CASH  AS CARD_USE_CASH  ' 
        ||chr(13)||chr(10)||'         , CRD.CARD_STAT AS CARD_STAT  ' 
        ||chr(13)||chr(10)||'         , GET_COMMON_CODE_NM(''01725'', CRD.CARD_STAT, '''||PSV_LANG_TP||''') AS CARD_STAT_NM   ' 
        ||chr(13)||chr(10)||'         , CRD.ISSUE_DIV AS ISSUE_DIV  ' 
        ||chr(13)||chr(10)||'         , CRD.SAV_PT    AS CARD_SAV_PT' 
        ||chr(13)||chr(10)||'         , CRD.USE_PT    AS CARD_USE_PT' 
        ||chr(13)||chr(10)||'         , CRD.LOS_PT    AS CARD_LOS_PT' 
        ||chr(13)||chr(10)||'         ,(                            ' 
        ||chr(13)||chr(10)||'           SELECT  LVL.SAV_PT_RATE     ' 
        ||chr(13)||chr(10)||'           FROM    C_CUST_LVL LVL ' 
        ||chr(13)||chr(10)||'           WHERE   LVL.COMP_CD  = CRD.COMP_CD              ' 
        ||chr(13)||chr(10)||'           AND     LVL.LVL_RANK = (                        ' 
        ||chr(13)||chr(10)||'                                   SELECT  MIN(LVL_RANK)   ' 
        ||chr(13)||chr(10)||'                                   FROM    C_CUST_LVL ' 
        ||chr(13)||chr(10)||'                                   WHERE   USE_YN = ''Y''  ' 
        ||chr(13)||chr(10)||'                                  )                        ' 
        ||chr(13)||chr(10)||'           AND     ROWNUM = 1                              ' 
        ||chr(13)||chr(10)||'          ) SAV_PT_RATE                ' 
        ||chr(13)||chr(10)||'         , NULL AS CASH_BILL_DIV   ' 
        ||chr(13)||chr(10)||'         , NULL AS ISSUE_MOB_BUSI  '
        ||chr(13)||chr(10)||'         , CRD.MEMB_DIV AS MEMB_DIV    '
        ||chr(13)||chr(10)||'      FROM C_CARD CRD             '   -- 멥버십카드 마스터 
        ||chr(13)||chr(10)||'     WHERE CRD.COMP_CD = ''' || PSV_COMP_CD ||'''' 
        ||chr(13)||chr(10)||'       AND CRD.USE_YN  = ''Y'''            -- 사용여부[Y:사용, N:사용안함] 
        ||chr(13)||chr(10)||'       AND NOT EXISTS(SELECT 1         ' 
        ||chr(13)||chr(10)||'                        FROM C_CUST CST '             -- 회원 마스터 
        ||chr(13)||chr(10)||'                       WHERE CST.COMP_CD   = CRD.COMP_CD '   
        ||chr(13)||chr(10)||'                         AND CST.CUST_ID   = CRD.CUST_ID ' 
      --||chr(13)||chr(10)||'                         AND CST.CUST_STAT = ''2'''        -- 회원상태[1:가입, 2:멤버십, 9:탈퇴] 
        ||chr(13)||chr(10)||'                         AND CST.USE_YN    = ''Y'''        -- 사용여부[Y:사용, N:사용안함] 
        ||chr(13)||chr(10)||'                    )                  ' 
        ; 
    -- 조건절 
    CASE WHEN PSV_REQ_DIV = '1' THEN  
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CRD.CUST_ID     =  '''||PSV_REQ_VAL||''''; 
         WHEN PSV_REQ_DIV = '4' THEN     
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CRD.CARD_ID     =  '''||PSV_REQ_VAL||''''; 
         ELSE  
              ls_Sql_Main := ls_Sql_Main||chr(13)||chr(10)||'   AND 1 = 2 '; 
    END CASE; 
    
    -- 체크쿼리 작성
    CASE  
        WHEN PSV_REQ_DIV = '1' THEN  
            ls_Sql_Check := 'SELECT COUNT(*) FROM C_CUST ';
            ls_Sql_Check := ls_Sql_Check ||'WHERE COMP_CD = '||PSV_COMP_CD||' AND USE_YN = ''Y'' AND CUST_ID     =  '''||PSV_REQ_VAL||''''; 
        WHEN PSV_REQ_DIV = '2' THEN     
            ls_Sql_Check := 'SELECT COUNT(*) FROM C_CUST ';
            ls_Sql_Check := ls_Sql_Check ||'WHERE COMP_CD = '||PSV_COMP_CD||' AND USE_YN = ''Y'' AND CUST_NM     =  '''||PSV_REQ_VAL||''''; 
        WHEN PSV_REQ_DIV = '3' THEN     
            ls_Sql_Check := 'SELECT COUNT(*) FROM C_CUST ';
            ls_Sql_Check := ls_Sql_Check ||'WHERE COMP_CD = '||PSV_COMP_CD||' AND USE_YN = ''Y'' AND MOBILE_N3   =  '''||PSV_REQ_VAL||''''; 
        WHEN PSV_REQ_DIV = '5' THEN     
            ls_Sql_Check := 'SELECT COUNT(*) FROM C_CUST ';
            ls_Sql_Check := ls_Sql_Check ||'WHERE COMP_CD = '||PSV_COMP_CD||' AND USE_YN = ''Y'' AND MOBILE      =  '''||PSV_REQ_VAL||'''';
        ELSE 
            ls_Sql_Check := 'SELECT COUNT(*) FROM C_CARD ';
            ls_Sql_Check := ls_Sql_Check ||'WHERE COMP_CD = '||PSV_COMP_CD||' AND USE_YN = ''Y'' AND CARD_ID     =  '''||PSV_REQ_VAL||'''';
    END CASE;
    
    -- 체크 쿼리
    EXECUTE IMMEDIATE ls_Sql_Check INTO nRECCNT;
    
    IF nRECCNT = 0 THEN
        asRetVal := '1004'; 
         IF PSV_REQ_DIV = '4' THEN 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001393');  -- 카드번호를 확인 하세요. 
         ELSE 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001385');  -- 회원정보를 확인 하세요. 
         END IF; 
         
         OPEN asResult FOR SELECT '1024' FROM DUAL;
         
         RAISE ERR_HANDLER;
    END IF;
    
    -- 메인 쿼리 
    DBMS_OUTPUT.PUT_LINE(ls_Sql_Main); 
    OPEN asResult FOR   ls_Sql_Main;

    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN ERR_HANDLER THEN 
         RETURN;
    WHEN OTHERS THEN 
         asRetVal := '1003'; 
         IF PSV_REQ_DIV = '4' THEN 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001393');  -- 카드번호를 확인 하세요. 
         ELSE 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001385');  -- 회원정보를 확인 하세요. 
         END IF; 
         
         OPEN asResult FOR SELECT '1024' FROM DUAL;
          
         RETURN; 
  END GET_CUST_INFO_10; 
   
  ------------------------------------------------------------------------------ 
  --  Package Name     : GET_CUST_INFO_20 
  --  Description      : POS에서 충전이력 중 취소 가능여부 조회(POS용) 
  --  Ref. Table       : C_CARD            멤버십카드 마스터 
  --                     C_CARD_CHARGE_HIS 멤버십카드 충전이력 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE GET_CUST_INFO_20 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_CARD_ID           IN   VARCHAR2, -- 3. 카드번호 
    PSV_CHANNEL           IN   VARCHAR2, -- 4. 입력경로 
    PSV_PAGE_NO           IN   VARCHAR2, -- 5. 페이지수(A:전체, n:페이지) 
    PSV_STD_ROW           IN   VARCHAR2, -- 6. 페이지당 레코드 수 
    asRetVal              OUT  VARCHAR2, -- 7. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 8. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
   
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- 카드 ID 
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- 회원 ID 
    nRecCnt         NUMBER(7) := 0; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000'; 
    asRetMsg    := ''; 
     
    OPEN asResult FOR 
        SELECT  CRG_DT 
             ,  CRG_SEQ 
             ,  CRG_FG 
             ,  CRG_DIV 
             ,  CRG_AMT 
             ,  APPR_DT 
             ,  APPR_TM 
             ,  APPR_NO 
             ,  CHANNEL 
             ,  STOR_CD 
             ,  STOR_NM 
             ,  POS_NO 
             ,  CNC_DIV 
             ,  ORG_CNC_DIV 
             ,  CASE WHEN MOD(ROW_CNT, TO_NUMBER(PSV_STD_ROW)) = 0 THEN TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)) 
                     ELSE TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)) + 1  
                END CUR_PAGE 
             ,  CASE WHEN MOD(MAX_CNT, TO_NUMBER(PSV_STD_ROW)) = 0 THEN TRUNC(MAX_CNT / TO_NUMBER(PSV_STD_ROW)) 
                     ELSE TRUNC(MAX_CNT / TO_NUMBER(PSV_STD_ROW)) + 1  
                END MAX_PAGE 
             ,  DST_CRG_SEQ 
             ,  NVL(( 
                SELECT  CRG_AMT - DC_AMT - ADD_AMT
                FROM    C_CARD_CHARGE_HIS CCH 
                WHERE   CCH.COMP_CD = PSV_COMP_CD 
              --AND     CCH.CARD_ID = PSV_CARD_ID 
                AND     CCH.CRG_DT  = NVL.CRG_DT 
                AND     CCH.CRG_SEQ = NVL.DST_CRG_SEQ 
               ), CRG_AMT) AS DST_CRG_AMT  
        FROM   (      
                SELECT  CRG.CRG_DT 
                     ,  CRG.CRG_SEQ 
                     ,  CRG.CRG_FG 
                     ,  CRG.CRG_DIV 
                     ,  CRG.CRG_AMT 
                     ,  CRG.APPR_DT 
                     ,  CRG.APPR_TM 
                     ,  CRG.APPR_NO 
                     ,  CRG.CHANNEL 
                     ,  CRG.STOR_CD 
                     ,  CRG.STOR_NM 
                     ,  CRG.POS_NO 
                     ,  CASE WHEN CRG.CRG_FG = '1' AND CRG.CRG_DIV IN('1', '2', '3') AND PSV_CHANNEL = '1' AND CRG_DT BETWEEN TO_CHAR(SYSDATE - 13, 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN -- POS 최근 14일 이내 자료만 취소 가능  
                               CASE WHEN CRG.CANCEL_DIV = 'N' AND CRG.CHARGE_DIV = 'N' AND CRG.CHANNEL_DIV = 'Y' AND CRG.CPN_USE_DIV = 'N' AND -- 취소 DATA 존재안함, 환불/이전/조정 DATA 존재안함, 경로구분 
                                         CRG.RES_CASH - SUM(CRG.CRG_AMT) OVER (PARTITION BY CRG.CARD_ID ORDER BY CRG.CRG_DT DESC, CRG.INST_DT DESC) >= 0  AND
                                         CARD_STAT = '10' THEN 'Y' 
                                     ELSE 'N' 
                               END 
                            WHEN CRG.CRG_FG = '1' AND CRG.CRG_DIV IN('1', '2', '3') AND PSV_CHANNEL IN ('2', '3') AND CRG.CRG_DT BETWEEN TO_CHAR(SYSDATE - 6, 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN -- WEB, APP 최근 7일 이내 자료만 취소 가능  
                               CASE WHEN CRG.CANCEL_DIV = 'N' AND CRG.CHARGE_DIV = 'N' AND CRG.CHANNEL_DIV = 'Y' AND CRG.CPN_USE_DIV = 'N' AND -- 취소 DATA 존재안함, 환불/이전/조정 DATA 존재안함, 경로구분 
                                         CRG.RES_CASH - SUM(CRG.CRG_AMT) OVER (PARTITION BY CRG.CARD_ID ORDER BY CRG.CRG_DT DESC, CRG.INST_DT DESC) >= 0 AND  
                                         CARD_STAT = '10' THEN 'Y'
                                     ELSE 'N' 
                               END     
                            ELSE 'N'   
                        END AS CNC_DIV 
                     ,  CRG.CANCEL_DIV AS ORG_CNC_DIV                      
                     ,  ROW_NUMBER() OVER(PARTITION BY CRG.CARD_ID ORDER BY CRG.CRG_DT DESC, CRG.CRG_SEQ DESC, CRG.CANCEL_DIV) AS ROW_CNT 
                     ,  COUNT    (*) OVER()                                                                    AS MAX_CNT 
                     ,  CRG.DST_CRG_SEQ 
                  FROM ( 
                        SELECT  CRG.COMP_CD 
                             ,  CC.CUST_ID 
                             ,  CRG.CARD_ID 
                             ,  CRG.CRG_DT 
                             ,  CRG.CRG_SEQ 
                             ,  CRG.CRG_FG 
                             ,  CRG.CRG_DIV 
                             ,  CRG.APPR_DT 
                             ,  CRG.APPR_TM 
                             ,  CRG.APPR_NO 
                             ,  CRG.CRG_AMT 
                             ,  CRG.CHANNEL 
                             ,  CRG.STOR_CD 
                             ,  STR.STOR_NM 
                             ,  CRG.POS_NO 
                             ,  CRG.INST_DT
                             ,  CC.CARD_STAT 
                             ,  CC.SAV_CASH - CC.USE_CASH RES_CASH 
                             ,  CASE WHEN CRG.CHANNEL = '1'        AND CRG.CHANNEL = PSV_CHANNEL THEN 'Y'
                                     WHEN CRG.CHANNEL IN ('2','3') AND PSV_CHANNEL IN ('2', '3') THEN 'Y' 
                                     ELSE 'N'  
                                END AS CHANNEL_DIV
                             ,  NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CHARGE_DIV 
                                      FROM C_CARD_CHARGE_HIS CCH 
                                     WHERE CCH.COMP_CD     = CRG.COMP_CD 
                                       AND CCH.CARD_ID     = CRG.CARD_ID 
                                       AND CCH.CRG_FG      IN('3', '4', '9') -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정] 
                                       AND CCH.USE_YN      = 'Y'             -- 사용여부[Y:사용, N:사용안함] 
                                       AND CCH.INST_DT > CRG.INST_DT 
                                   ), 'N')  CHARGE_DIV  -- 충전된 이후 환불 DATA 존재여부 
                             ,  NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CANCEL_DIV 
                                      FROM C_CARD_CHARGE_HIS CCH 
                                     WHERE CCH.COMP_CD     = CRG.COMP_CD 
                                       AND CCH.CARD_ID     = CRG.CARD_ID 
                                       AND CCH.ORG_CRG_DT  = CRG.CRG_DT  
                                       AND CCH.ORG_CRG_SEQ = CRG.CRG_SEQ 
                                       AND CCH.USE_YN      = 'Y'  -- 사용여부[Y:사용, N:사용안함] 
                                   ), 'N')  CANCEL_DIV  -- 원거래 취소 여부 
                             ,  NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CPN_USE_DIV  
                                      FROM C_COUPON_CUST CCH 
                                     WHERE CCH.COMP_CD     = CRG.COMP_CD 
                                       AND CCH.PRT_SALE_DT = CRG.CRG_DT                      -- 충전일자  
                                       AND CCH.PRT_BRAND_CD= CRG.BRAND_CD                    -- 브랜드 
                                       AND CCH.PRT_STOR_CD = TO_CHAR(CRG.CRG_SEQ, 'FM999999')-- 일련번호  
                                       AND CCH.CUST_ID     = ( 
                                                              SELECT CUST_ID  
                                                              FROM   C_CARD  
                                                              WHERE  COMP_CD = CRG.COMP_CD 
                                                              AND    CARD_ID = CRG.CARD_ID 
                                                             ) 
                                       AND CCH.USE_STAT    = '10'                       
                                       AND CCH.USE_YN      = 'Y'  -- 사용여부[Y:사용, N:사용안함] 
                                   ), 'N')  CPN_USE_DIV           -- 쿠폰 사용 유무 
                             ,  CRG.DST_CRG_SEQ 
                          FROM  C_CARD_CHARGE_HIS CRG 
                             ,  C_CARD            CC 
                             ,  STORE             STR 
                         WHERE  CRG.COMP_CD  = PSV_COMP_CD 
                           AND  CRG.CARD_ID  = PSV_CARD_ID 
                           AND  CRG.COMP_CD  = CC.COMP_CD 
                           AND  CRG.CARD_ID  = CC.CARD_ID 
                           AND  CRG.BRAND_CD = STR.BRAND_CD(+) 
                           AND  CRG.STOR_CD  = STR.STOR_CD (+) 
                           AND  CC.CARD_STAT = '10'       -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기] 
                           AND  CC.USE_YN    = 'Y'        -- 사용여부[Y:사용, N:사용안함] 
                           AND  CRG.CRG_FG   = '1'        -- 결제구분[1:충전] 
                           AND  CRG.CRG_DIV IN ('1', '2') -- 결제방법[1:현금, 2:신용카드] 
                           AND  CRG.USE_YN   = 'Y'        -- 사용여부[Y:사용, N:사용안함] 
                       ) CRG 
               ) NVL 
        WHERE   PSV_PAGE_NO = ( 
                                CASE WHEN PSV_PAGE_NO = 'A' THEN 'A'  
                                     ELSE ( 
                                           CASE WHEN MOD(ROW_CNT, TO_NUMBER(PSV_STD_ROW)) = 0 THEN TO_CHAR(TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)), 'FM999999') 
                                                ELSE TO_CHAR(TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)) + 1, 'FM999999') 
                                           END 
                                          )  
                                END 
                               ); 
      
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN ERR_HANDLER THEN 
         RETURN; 
    WHEN OTHERS THEN 
         asRetVal := '1003'; 
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001393');  -- 카드번호를 확인 하세요. 
          
         RETURN; 
  END GET_CUST_INFO_20; 
 
  ------------------------------------------------------------------------------ 
  --  Package Name     : GET_CUST_INFO_30 
  --  Description      : POS에서 충전이력 중 취소 가능여부 조회(WEB/APP용) 
  --  Ref. Table       : C_CARD            멤버십카드 마스터 
  --                     C_CARD_CHARGE_HIS 멤버십카드 충전이력   
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE GET_CUST_INFO_30 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_CARD_ID           IN   VARCHAR2, -- 3. 카드번호 
    PSV_CHANNEL           IN   VARCHAR2, -- 4. 입력경로 
    PSV_PAGE_NO           IN   VARCHAR2, -- 5. 페이지수(A:전체, n:페이지) 
    PSV_STD_ROW           IN   VARCHAR2, -- 6. 페이지당 레코드 수 
    asRetVal              OUT  VARCHAR2, -- 7. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 8. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
   
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- 카드 ID 
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- 회원 ID 
    nRecCnt         NUMBER(7) := 0; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000'; 
    asRetMsg    := ''; 
     
    OPEN asResult FOR 
        SELECT  CRG_DT 
             ,  CRG_SEQ 
             ,  CRG_FG 
             ,  CRG_DIV 
             ,  CRG_AMT 
             ,  APPR_DT 
             ,  APPR_TM 
             ,  APPR_NO 
             ,  CHANNEL 
             ,  STOR_CD 
             ,  STOR_NM 
             ,  POS_NO 
             ,  CNC_DIV 
             ,  ORG_CNC_DIV 
             ,  CASE WHEN MOD(ROW_CNT, TO_NUMBER(PSV_STD_ROW)) = 0 THEN TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)) 
                     ELSE TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)) + 1  
                END CUR_PAGE 
             ,  CASE WHEN MOD(MAX_CNT, TO_NUMBER(PSV_STD_ROW)) = 0 THEN TRUNC(MAX_CNT / TO_NUMBER(PSV_STD_ROW)) 
                     ELSE TRUNC(MAX_CNT / TO_NUMBER(PSV_STD_ROW)) + 1  
                END MAX_PAGE 
             ,  DST_CRG_SEQ 
             ,  NVL(( 
                SELECT  CRG_AMT - DC_AMT - ADD_AMT 
                FROM    C_CARD_CHARGE_HIS CCH 
                WHERE   CCH.COMP_CD = PSV_COMP_CD 
              --AND     CCH.CARD_ID = PSV_CARD_ID 
                AND     CCH.CRG_DT  = NVL.CRG_DT 
                AND     CCH.CRG_SEQ = NVL.DST_CRG_SEQ 
               ), CRG_AMT)  AS DST_CRG_AMT 
        FROM   (      
                SELECT  CRG.CRG_DT 
                     ,  CRG.CRG_SEQ 
                     ,  CRG.CRG_FG 
                     ,  CRG.CRG_DIV 
                     ,  CRG.CRG_AMT 
                     ,  CRG.APPR_DT 
                     ,  CRG.APPR_TM 
                     ,  CRG.APPR_NO 
                     ,  CRG.CHANNEL 
                     ,  CRG.STOR_CD 
                     ,  CRG.STOR_NM 
                     ,  CRG.POS_NO 
                     ,  CASE WHEN CRG.CRG_FG = '1' AND CRG.CRG_DIV IN('1', '2', '3') AND PSV_CHANNEL = '1' AND CRG_DT BETWEEN TO_CHAR(SYSDATE - 13, 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN -- POS 최근 14일 이내 자료만 취소 가능  
                               CASE WHEN CRG.CANCEL_DIV = 'N' AND CRG.CHARGE_DIV = 'N' AND CRG.CHANNEL_DIV = 'Y' AND CRG.CPN_USE_DIV = 'N' AND -- 취소 DATA 존재안함, 환불/이전/조정 DATA 존재안함, 경로구분 
                                         CRG.RES_CASH - SUM(CRG.CRG_AMT) OVER (PARTITION BY CRG.CARD_ID ORDER BY CRG.CRG_DT DESC, CRG.INST_DT DESC) >= 0  AND
                                         CARD_STAT = '10' THEN 'Y' 
                                     ELSE 'N' 
                               END 
                            WHEN CRG.CRG_FG = '1' AND CRG.CRG_DIV IN('1', '2', '3') AND PSV_CHANNEL IN ('2', '3') AND CRG.CRG_DT BETWEEN TO_CHAR(SYSDATE - 6, 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN -- WEB, APP 최근 7일 이내 자료만 취소 가능  
                               CASE WHEN CRG.CANCEL_DIV = 'N' AND CRG.CHARGE_DIV = 'N' AND CRG.CHANNEL_DIV = 'Y' AND CRG.CPN_USE_DIV = 'N' AND -- 취소 DATA 존재안함, 환불/이전/조정 DATA 존재안함, 경로구분 
                                         CRG.RES_CASH - SUM(CRG.CRG_AMT) OVER (PARTITION BY CRG.CARD_ID ORDER BY CRG.CRG_DT DESC, CRG.INST_DT DESC) >= 0 AND  
                                         CARD_STAT = '10' THEN 'Y'
                                     ELSE 'N' 
                               END     
                            ELSE 'N'   
                        END AS CNC_DIV 
                     ,  CRG.CANCEL_DIV AS ORG_CNC_DIV 
                     ,  ROW_NUMBER() OVER(PARTITION BY CRG.CARD_ID ORDER BY CRG.CRG_DT DESC, CRG.CRG_SEQ DESC, CRG.CANCEL_DIV) AS ROW_CNT 
                     ,  COUNT    (*) OVER()                                                                    AS MAX_CNT 
                     ,  CRG.DST_CRG_SEQ  
                  FROM ( 
                        SELECT  CRG.COMP_CD 
                             ,  CC.CUST_ID 
                             ,  CRG.CARD_ID 
                             ,  CRG.CRG_DT 
                             ,  CRG.CRG_SEQ 
                             ,  CRG.CRG_FG 
                             ,  CRG.CRG_DIV 
                             ,  CRG.APPR_DT 
                             ,  CRG.APPR_TM 
                             ,  CRG.APPR_NO 
                             ,  CRG.CRG_AMT 
                             ,  CRG.CHANNEL 
                             ,  CRG.STOR_CD 
                             ,  STR.STOR_NM 
                             ,  CRG.POS_NO 
                             ,  CRG.INST_DT
                             ,  CC.CARD_STAT 
                             ,  CC.SAV_CASH - CC.USE_CASH RES_CASH 
                             ,  CASE WHEN CRG.CHANNEL = '1'        AND CRG.CHANNEL = PSV_CHANNEL THEN 'Y'
                                     WHEN CRG.CHANNEL IN ('2','3') AND PSV_CHANNEL IN ('2', '3') THEN 'Y' 
                                     ELSE 'N'  
                                END AS CHANNEL_DIV 
                             ,  NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CHARGE_DIV 
                                      FROM C_CARD_CHARGE_HIS CCH 
                                     WHERE CCH.COMP_CD     = CRG.COMP_CD 
                                       AND CCH.CARD_ID     = CRG.CARD_ID 
                                       AND CCH.CRG_FG      IN('3', '4', '9') -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정] 
                                       AND CCH.USE_YN      = 'Y'             -- 사용여부[Y:사용, N:사용안함] 
                                       AND CCH.INST_DT > CRG.INST_DT 
                                   ), 'N')  CHARGE_DIV  -- 충전된 이후 환불 DATA 존재여부 
                             ,  NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CANCEL_DIV 
                                      FROM C_CARD_CHARGE_HIS CCH 
                                     WHERE CCH.COMP_CD     = CRG.COMP_CD 
                                       AND CCH.CARD_ID     = CRG.CARD_ID 
                                       AND CCH.ORG_CRG_DT  = CRG.CRG_DT  
                                       AND CCH.ORG_CRG_SEQ = CRG.CRG_SEQ 
                                       AND CCH.USE_YN      = 'Y'  -- 사용여부[Y:사용, N:사용안함] 
                                   ), 'N')  CANCEL_DIV  -- 원거래 취소 여부 
                             ,  NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CPN_USE_DIV  
                                      FROM C_COUPON_CUST CCH 
                                     WHERE CCH.COMP_CD     = CRG.COMP_CD 
                                       AND CCH.PRT_SALE_DT = CRG.CRG_DT                      -- 충전일자  
                                       AND CCH.PRT_BRAND_CD= CRG.BRAND_CD                    -- 브랜드 
                                       AND CCH.PRT_STOR_CD = TO_CHAR(CRG.CRG_SEQ, 'FM999999')-- 일련번호  
                                       AND CCH.CUST_ID     = ( 
                                                              SELECT CUST_ID  
                                                              FROM   C_CARD  
                                                              WHERE  COMP_CD = CRG.COMP_CD 
                                                              AND    CARD_ID = CRG.CARD_ID 
                                                             ) 
                                       AND CCH.USE_STAT    = '10'                       
                                       AND CCH.USE_YN      = 'Y'  -- 사용여부[Y:사용, N:사용안함] 
                                   ), 'N')  CPN_USE_DIV  -- 쿠폰 사용 유무   
                             ,  CRG.DST_CRG_SEQ        
                          FROM  C_CARD_CHARGE_HIS CRG 
                             ,  C_CARD            CC 
                             ,  C_STORE           STR 
                         WHERE  CRG.COMP_CD  = PSV_COMP_CD 
                           AND  CRG.CARD_ID  = PSV_CARD_ID 
                           AND  CRG.COMP_CD  = CC.COMP_CD 
                           AND  CRG.CARD_ID  = CC.CARD_ID 
                           AND  CRG.COMP_CD  = STR.COMP_CD(+)  
                           AND  CRG.BRAND_CD = STR.BRAND_CD(+) 
                           AND  CRG.STOR_CD  = STR.STOR_CD (+) 
                           AND  CC.CARD_STAT IN ('10', '90', '92')   -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기] 
                           AND  CC.USE_YN    = 'Y'                   -- 사용여부[Y:사용, N:사용안함] 
                        -- AND CRG.CRG_FG   = '1'                   -- 결제구분[1:충전] MODIFY 20150516 
                        -- AND CRG.CRG_DIV IN ('1', '2')            -- 결제방법[1:현금, 2:신용카드] MODIFY 20150516 
                           AND  CRG.USE_YN   = 'Y'                   -- 사용여부[Y:사용, N:사용안함] 
                       ) CRG 
               ) NVL 
        WHERE   PSV_PAGE_NO = ( 
                                CASE WHEN PSV_PAGE_NO = 'A' THEN 'A'  
                                     ELSE ( 
                                           CASE WHEN MOD(ROW_CNT, TO_NUMBER(PSV_STD_ROW)) = 0 THEN TO_CHAR(TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)), 'FM999999') 
                                                ELSE TO_CHAR(TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)) + 1, 'FM999999') 
                                           END 
                                          )  
                                END 
                               ); 
      
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN ERR_HANDLER THEN 
         RETURN; 
    WHEN OTHERS THEN 
         asRetVal := '1003'; 
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001393');  -- 카드번호를 확인 하세요. 
          
         RETURN; 
  END GET_CUST_INFO_30; 
 
  ------------------------------------------------------------------------------ 
  --  Package Name     : GET_CUST_INFO_40 
  --  Description      : POS에서 충전이력 중 취소 가능여부 조회(그룹충전) 
  --  Ref. Table       : C_CARD            멤버십카드 마스터 
  --                     C_CARD_CHARGE_HIS 멤버십카드 충전이력   
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  FUNCTION GET_CUST_INFO_40 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_CRG_DT            IN   VARCHAR2, -- 3. 카드번호 
    PSV_CRG_SEQ           IN   VARCHAR2, -- 4. 일련번호 
    PSV_CHANNEL           IN   VARCHAR2  -- 5. 충전채널 
  ) RETURN VARCHAR2 IS 
    CURSOR CUR_1 IS 
        SELECT  CARD_ID 
              , CRG_DT 
              , CRG_SEQ 
              , CRG_AMT 
              , CRG_SCOPE AS CRG_SCP 
        FROM    C_CARD_CHARGE_HIS 
        WHERE   COMP_CD    = PSV_COMP_CD 
        AND     CRG_DT     = PSV_CRG_DT 
        AND     CRG_FG     = '1' 
        AND     CRG_SCOPE IN ('1', '3') 
        AND    ( 
                CRG_SEQ     = TO_NUMBER(PSV_CRG_SEQ) 
                OR 
                DST_CRG_SEQ = TO_NUMBER(PSV_CRG_SEQ) 
               ) 
        ORDER BY CRG_SCOPE; 
     
    -- 여러장 충전 취소 가능여부 
    vCUR_CARD_YN    VARCHAR2(1) := 'X';  
          
    nRecCnt         NUMBER(7) := 0; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    FOR MYREC IN CUR_1 LOOP 
        IF MYREC.CRG_SCP = '1' THEN 
            vCUR_CARD_YN := 'Y'; 
        ELSE     
            SELECT  NVL(MIN(CNC_DIV) ,'N') INTO vCUR_CARD_YN 
            FROM   (     
                    SELECT  CRG.CARD_ID 
                          , CRG.CRG_DT 
                          , CRG.CRG_SEQ 
                          , CRG.INST_DT 
                          , MAX(CASE WHEN CRG.DST_CRG_SEQ = PSV_CRG_SEQ THEN INST_DT ELSE NULL END) OVER() AS STD_INST_DT 
                          , CASE WHEN PSV_CHANNEL = '1' AND CRG_DT BETWEEN TO_CHAR(SYSDATE - 13, 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN -- POS 최근 14일 이내 자료만 취소 가능  
                                   CASE WHEN CARD_STAT = 'Y' AND CANCEL_DIV = 'N' AND CHARGE_DIV = 'N' AND CHANNEL_DIV = 'Y' AND CPN_USE_DIV = 'N' AND -- 취소 DATA 존재안함, 환불/이전/조정 DATA 존재안함, 경로구분 
                                             RES_CASH - SUM(CRG_AMT) OVER (PARTITION BY CARD_ID ORDER BY CANCEL_DIV, CHARGE_DIV, CRG_DT DESC, INST_DT DESC) >= 0 THEN 'Y' 
                                         ELSE 'N' 
                                   END 
                                WHEN PSV_CHANNEL IN ('2', '3') AND CRG_DT BETWEEN TO_CHAR(SYSDATE - 6, 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN -- WEB, APP 최근 7일 이내 자료만 취소 가능  
                                   CASE WHEN CARD_STAT = 'Y' AND CANCEL_DIV = 'N' AND CHARGE_DIV = 'N' AND CHANNEL_DIV = 'Y' AND CPN_USE_DIV = 'N' AND -- 취소 DATA 존재안함, 환불/이전/조정 DATA 존재안함, 경로구분 
                                             RES_CASH - SUM(CRG_AMT) OVER (PARTITION BY CARD_ID ORDER BY CANCEL_DIV, CHARGE_DIV, CRG_DT DESC, INST_DT DESC) >= 0 THEN 'Y' 
                                         ELSE 'N' 
                                   END     
                                ELSE 'N'   
                            END AS CNC_DIV 
                    FROM   ( 
                            SELECT CRG.CARD_ID 
                                 , CRG.CRG_DT 
                                 , CRG.CRG_SEQ 
                                 , CRG.CRG_AMT 
                                 , CRG.INST_DT 
                                 , CRG.DST_CRG_SEQ 
                                 , CASE WHEN CC.CARD_STAT = '10' AND CC.USE_YN = 'Y' THEN 'Y' ELSE 'N' END AS CARD_STAT 
                                 , CC.SAV_CASH - CC.USE_CASH RES_CASH 
                                 , CASE WHEN CRG.CHANNEL = '1' THEN (CASE WHEN CRG.CHANNEL = PSV_CHANNEL THEN 'Y' ELSE 'N' END) 
                                        ELSE (CASE WHEN PSV_CHANNEL IN ('2', '3') THEN 'Y' ELSE 'N' END)  
                                   END AS CHANNEL_DIV 
                                 , NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CHARGE_DIV 
                                          FROM C_CARD_CHARGE_HIS CCH 
                                         WHERE CCH.COMP_CD     = CRG.COMP_CD 
                                           AND CCH.CARD_ID     = CRG.CARD_ID 
                                           AND CCH.CRG_FG      IN('3', '4', '9') -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정] 
                                           AND CCH.USE_YN      = 'Y'             -- 사용여부[Y:사용, N:사용안함] 
                                           AND CCH.INST_DT > CRG.INST_DT 
                                       ), 'N')  CHARGE_DIV  -- 충전된 이후 환불 DATA 존재여부 
                                 , NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CANCEL_DIV 
                                          FROM C_CARD_CHARGE_HIS CCH 
                                         WHERE CCH.COMP_CD     = CRG.COMP_CD 
                                           AND CCH.CARD_ID     = CRG.CARD_ID 
                                           AND CCH.ORG_CRG_DT  = CRG.CRG_DT  
                                           AND CCH.ORG_CRG_SEQ = CRG.CRG_SEQ 
                                           AND CCH.USE_YN      = 'Y'  -- 사용여부[Y:사용, N:사용안함] 
                                       ), 'N')  CANCEL_DIV  -- 원거래 취소 여부 
                                 , NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CPN_USE_DIV  
                                          FROM C_COUPON_CUST CCH 
                                         WHERE CCH.COMP_CD     = CRG.COMP_CD 
                                           AND CCH.PRT_SALE_DT = CRG.CRG_DT                      -- 충전일자  
                                           AND CCH.PRT_BRAND_CD= CRG.BRAND_CD                    -- 브랜드 
                                           AND CCH.PRT_STOR_CD = TO_CHAR(CRG.CRG_SEQ, 'FM999999')-- 일련번호  
                                           AND CCH.CUST_ID     = ( 
                                                                  SELECT CUST_ID  
                                                                  FROM   C_CARD  
                                                                  WHERE  COMP_CD = CRG.COMP_CD 
                                                                  AND    CARD_ID = CRG.CARD_ID 
                                                                 ) 
                                           AND CCH.USE_STAT    = '10'                       
                                           AND CCH.USE_YN      = 'Y'  -- 사용여부[Y:사용, N:사용안함] 
                                       ), 'N')  CPN_USE_DIV           -- 쿠폰 사용 유무 
                              FROM C_CARD_CHARGE_HIS CRG 
                                 , C_CARD            CC 
                             WHERE CRG.COMP_CD  = PSV_COMP_CD 
                               AND CRG.CARD_ID  = MYREC.CARD_ID 
                               AND CRG.COMP_CD  = CC.COMP_CD 
                               AND CRG.CARD_ID  = CC.CARD_ID 
                               AND CRG.CRG_FG   = '1'        -- 결제구분[1:충전] 
                               AND CRG.CRG_DIV IN ('1', '2') -- 결제방법[1:현금, 2:신용카드] 
                               AND CRG.USE_YN   = 'Y'        -- 사용여부[Y:사용, N:사용안함] 
                           ) CRG 
                    ) 
            WHERE INST_DT >= NVL(STD_INST_DT, TO_DATE('20150101 000000','YYYYMMDD HH24MISS')); 
        END IF; 
         
        EXIT WHEN vCUR_CARD_YN = 'N'; 
    END LOOP; 
      
    RETURN vCUR_CARD_YN; 
  EXCEPTION 
    WHEN ERR_HANDLER THEN 
         RETURN vCUR_CARD_YN; 
    WHEN OTHERS THEN 
         RETURN vCUR_CARD_YN; 
  END GET_CUST_INFO_40; 
     
  ------------------------------------------------------------------------------ 
  --  Package Name     : GET_CARD_INFO_10 
  --  Description      : POS 반품 시 원거래 카드 번호 취득 
  --  Ref. Table       : C_CARD_USE_HIS  모바일쿠폰 마스터 
  --                     C_CARD        멤버십카드 마스터 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE GET_CARD_INFO_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_USE_DT            IN   VARCHAR2, -- 3. 원거래일자 
    PSV_USE_SEQ           IN   VARCHAR2, -- 4. 원거래일련번호 
    asRetVal              OUT  VARCHAR2, -- 8. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 9. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
   
    lsCardId        C_CARD_USE_HIS.CARD_ID%TYPE  := NULL; 
    nRecCnt         NUMBER(7)       := 0; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000'; 
    asRetMsg    := ''; 
     
    SELECT COUNT(*) INTO nRecCnt 
      FROM C_CARD_USE_HIS  CUH 
     WHERE CUH.COMP_CD     = PSV_COMP_CD 
       AND CUH.USE_DT      = PSV_USE_DT 
       AND CUH.USE_SEQ     = TO_NUMBER(PSV_USE_SEQ); 
 
    IF nRecCnt = 0 THEN 
        asRetVal    :=  '1001'; 
        asRetMsg    :=  FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001389'); 
     
        OPEN asResult FOR 
            SELECT '' CARD_ID, '' MEMB_DIV 
              FROM DUAL;
    ELSE
        -- 인증번호 
        OPEN asResult FOR 
            SELECT CUH.CARD_ID, CRD.MEMB_DIV
              FROM C_CARD_USE_HIS  CUH
                 , C_CARD          CRD
             WHERE CUH.COMP_CD     = CRD.COMP_CD
               AND CUH.CARD_ID     = CRD.CARD_ID  
               AND CUH.COMP_CD     = PSV_COMP_CD 
               AND CUH.USE_DT      = PSV_USE_DT 
               AND CUH.USE_SEQ     = TO_NUMBER(PSV_USE_SEQ); 
    END IF; 
         
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상 처리되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN OTHERS THEN 
         asRetVal := '3001'; 
         asRetMsg := SQLERRM; 
          
         OPEN asResult FOR 
         SELECT '' AS RTNCODE 
           FROM DUAL; 
            
        RETURN; 
  END GET_CARD_INFO_10; 
   
-------------------------------------------------------------------------------- 
--  Package Name     : SET_CUST_INFO_10 
--  Description      : POS에서 카드 발급(가발급)/재발급 
--  Ref. Table       : C_CUST 회원 마스터 
--                     C_CARD 멤버십카드 마스터 
-------------------------------------------------------------------------------- 
--  Create Date      : 2015-02-25 모스버거 PJT 
--  Modify Date      : 2015-02-25  
-------------------------------------------------------------------------------- 
  PROCEDURE SET_CUST_INFO_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_ISSUE_DIV         IN   VARCHAR2, -- 3. 발급구분[0:신규, 1:재발급] 
    PSV_CARD_ID           IN   VARCHAR2, -- 4. 신규 카드번호, 재발급 카드번호 
    PSV_CARD_ID_R         IN   VARCHAR2, -- 5. 이전 카드번호 > 재발급일 경우 
    PSV_ISSUE_DT          IN   VARCHAR2, -- 6. 발급일자 
    PSV_BRAND_CD          IN   VARCHAR2, -- 7. 영업조직 
    PSV_STOR_CD           IN   VARCHAR2, -- 8. 점포코드 
    asRetVal              OUT  VARCHAR2, -- 9. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 10. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
   
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- 회원 ID 
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- 카드 ID 
    lscard_div      C_CARD.CARD_DIV%TYPE;                   -- 카드관리범위[1:회사, 2:영업조직, 3:점포] 
    lsbrand_cd      C_CARD.BRAND_CD%TYPE;                   -- 영업조직 
    lsstor_cd       C_CARD.STOR_CD%TYPE;                    -- 점포코드 
    lsrep_card_yn   C_CARD.REP_CARD_YN%TYPE;                -- 대표카드여부 
    nCurPoint       C_CARD.SAV_PT%TYPE   := 0;              -- 현재 포인트 
    nRecCnt         NUMBER(7) := 0; 
    nCheckDigit     NUMBER(7) := 0;                              -- 체크디지트 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000'; 
    asRetMsg    := ''; 
     
    SELECT COUNT(*) 
      INTO nRecCnt 
      FROM C_CARD -- 멤버십카드 마스터 
     WHERE COMP_CD    = PSV_COMP_CD 
       AND CARD_ID    = PSV_CARD_ID; 
        
    IF nRecCnt > 0 THEN 
       asRetVal := '1000'; 
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001428'); -- 이미 등록된 카드번호 입니다. 
        
       RAISE ERR_HANDLER; 
    ELSE 
       IF PSV_ISSUE_DIV = '1' THEN -- 발급구분[1:재발급] 
          SELECT COUNT(*), MAX(CUST_ID),  MAX(SAV_PT - USE_PT - LOS_PT), MAX(REP_CARD_YN) 
            INTO nRecCnt,  lsCustId, nCurPoint, lsrep_card_yn 
            FROM C_CARD -- 멤버십카드 마스터 
           WHERE COMP_CD    = PSV_COMP_CD 
             AND CARD_ID    = PSV_CARD_ID_R; 
              
          IF nRecCnt = 0 THEN 
             asRetVal := '1001'; 
             asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001393');  -- 카드번호를 확인 하세요. 
              
             RAISE ERR_HANDLER; 
          ELSE 
             -- 이전 카드 해지 처리 
             UPDATE C_CARD 
                SET CARD_STAT   = '91'           -- 카드상태[91:해지] 
                  , CANCEL_DT   = PSV_ISSUE_DT 
                  , REF_CARD_ID = PSV_CARD_ID 
                  , USE_PT      = USE_PT + nCurPoint 
                  , REP_CARD_YN = 'N' 
                  , UPD_DT      = SYSDATE 
                  , UPD_USER    = 'SYSTEM' 
              WHERE COMP_CD     = PSV_COMP_CD 
                AND CARD_ID     = PSV_CARD_ID_R; 
          END IF; 
       END IF; 
        
       BEGIN 
         SELECT CP.CARD_DIV, BM.BRAND_CD, '0000000'  
           INTO lscard_div , lsbrand_cd , lsstor_cd 
           FROM COMPANY_PARA CP 
              , BRAND_MEMB   BM 
          WHERE CP.COMP_CD  = BM.COMP_CD 
            AND BM.COMP_CD  = PSV_COMP_CD 
            AND BM.BRAND_CD = ( 
                                SELECT CCT.TSMS_BRAND_CD 
                                  FROM C_CARD_TYPE     CCT 
                                     , C_CARD_TYPE_REP CTR  
                                 WHERE CCT.COMP_CD   = CTR.COMP_CD 
                                   AND CCT.CARD_TYPE = CTR.CARD_TYPE 
                                   AND CTR.COMP_CD   = PSV_COMP_CD 
                                   AND decrypt(PSV_CARD_ID) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD) 
                                   AND ROWNUM        = 1 
                              ) 
            AND USE_YN      = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
       EXCEPTION 
         WHEN OTHERS THEN  
              asRetVal := '1002'; 
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다. 
               
              RAISE ERR_HANDLER; 
       END; 
        
       CASE WHEN lscard_div = '1' THEN -- 회사 
                 lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd); 
                 lsstor_cd  := '0000000'; 
            WHEN lscard_div = '2' THEN -- 영업조직 
                 lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd); 
                 lsstor_cd  := '0000000'; 
            WHEN lscard_div = '3' THEN -- 점포 
                 lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd); 
                 lsstor_cd  := NVL(PSV_STOR_CD , lsstor_cd ); 
       END CASE; 
        
       -- 체크 디지트 체크 
       lsCardId    := decrypt(PSV_CARD_ID); 
       nCheckDigit := MOD(TO_NUMBER(SUBSTR(lsCardId,1,1))*1  + TO_NUMBER(SUBSTR(lsCardId,2,1))*3  +  
                          TO_NUMBER(SUBSTR(lsCardId,3,1))*1  + TO_NUMBER(SUBSTR(lsCardId,4,1))*3  +  
                          TO_NUMBER(SUBSTR(lsCardId,5,1))*1  + TO_NUMBER(SUBSTR(lsCardId,6,1))*3  + 
                          TO_NUMBER(SUBSTR(lsCardId,7,1))*1  + TO_NUMBER(SUBSTR(lsCardId,8,1))*3  +  
                          TO_NUMBER(SUBSTR(lsCardId,9,1))*1  + TO_NUMBER(SUBSTR(lsCardId,10,1))*3 +  
                          TO_NUMBER(SUBSTR(lsCardId,11,1))*1 + TO_NUMBER(SUBSTR(lsCardId,12,1))*3 + 
                          TO_NUMBER(SUBSTR(lsCardId,13,1))*1 + TO_NUMBER(SUBSTR(lsCardId,14,1))*3 +  
                          TO_NUMBER(SUBSTR(lsCardId,15,1))*1,10); 
           
       IF SUBSTR(lsCardId, 16, 1) != TO_CHAR(nCheckDigit, 'FM0') OR LENGTH(lsCardId) != 16 THEN 
         asRetVal := '1001'; 
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001436'); -- 카드 등록에 실패하였습니다. 
                  
         ROLLBACK; 
         RAISE ERR_HANDLER; 
       END IF; 
           
       -- 멤버십 카드 등록 
       BEGIN 
         EXECUTE IMMEDIATE 'ALTER TRIGGER TG_C_CARD_02 DISABLE'; 
          
         INSERT INTO C_CARD 
         ( 
             COMP_CD, CARD_ID, CUST_ID, CARD_STAT, ISSUE_DIV, ISSUE_DT, ISSUE_BRAND_CD, ISSUE_STOR_CD, 
             SAV_PT, CARD_DIV, BRAND_CD, STOR_CD, REP_CARD_YN, INST_USER, UPD_USER 
         ) 
         VALUES 
         ( 
             PSV_COMP_CD, PSV_CARD_ID, lsCustId, '10', '0', PSV_ISSUE_DT||TO_CHAR(SYSDATE, 'HH24MISS'), PSV_BRAND_CD, PSV_STOR_CD, 
             nCurPoint, lscard_div, lsbrand_cd, lsstor_cd, NVL(lsrep_card_yn, 'N'), 'SYSTEM', 'SYSTEM' 
         ); 
          
         EXECUTE IMMEDIATE 'ALTER TRIGGER TG_C_CARD_02 ENABLE'; 
       EXCEPTION 
         WHEN OTHERS THEN  
              asRetVal := '1003'; 
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001401'); -- 카드 등록에 실패하였습니다. 
               
              ROLLBACK; 
              EXECUTE IMMEDIATE 'ALTER TRIGGER TG_C_CARD_02 ENABLE'; 
              RAISE ERR_HANDLER; 
       END; 
    END IF; 
     
    OPEN asResult FOR 
    SELECT PSV_CARD_ID, nCurPoint 
      FROM DUAL; 
       
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN ERR_HANDLER THEN 
        ROLLBACK; 
         
        RETURN; 
    WHEN OTHERS THEN 
        asRetVal := '2001'; 
        asRetMsg := SUBSTRB(SQLERRM(SQLCODE), 1, 60); 
         
        ROLLBACK; 
          
        RETURN; 
  END SET_CUST_INFO_10; 
   
  ------------------------------------------------------------------------------ 
  --  Package Name     : SET_MEMB_CHG_10 
  --  Description      : 멤버십 충전/취소/환불/이전/조정 
  --  Ref. Table       : C_CARD            멤버십카드 마스터 
  --                     C_CUST            회원 마스터 
  --                     C_CARD_CHARGE_HIS 멤버십카드 충전이력 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE SET_MEMB_CHG_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_CARD_ID           IN   VARCHAR2, -- 3. 카드번호 
    PSV_CRG_DT            IN   VARCHAR2, -- 4. 결제일자 
    PSV_BRAND_CD          IN   VARCHAR2, -- 5. 영업조직 
    PSV_STOR_CD           IN   VARCHAR2, -- 6. 점포코드 
    PSV_POS_NO            IN   VARCHAR2, -- 7. 포스번호 
    PSV_CARD_NO           IN   VARCHAR2, -- 8. 카드번호 
    PSV_CARD_NM           IN   VARCHAR2, -- 9. 카드명 
    PSV_APPR_DT           IN   VARCHAR2, -- 10. 승인일자 
    PSV_APPR_TM           IN   VARCHAR2, -- 11. 승인시각 
    PSV_APPR_VD_CD        IN   VARCHAR2, -- 12. 매입사코드 
    PSV_APPR_VD_NM        IN   VARCHAR2, -- 13. 매입사명 
    PSV_APPR_IS_CD        IN   VARCHAR2, -- 14. 발급사코드 
    PSV_APPR_COM          IN   VARCHAR2, -- 15. 가맹점번호 
    PSV_ALLOT_LMT         IN   VARCHAR2, -- 16. 할부개월 
    PSV_READ_DIV          IN   VARCHAR2, -- 17. 리딩구분 
    PSV_APPR_DIV          IN   VARCHAR2, -- 18. 승인구분 
    PSV_APPR_NO           IN   VARCHAR2, -- 19. 승인번호 
    PSV_CRG_FG            IN   VARCHAR2, -- 20. 결제구분[1:충전, 2:취소]==>O, [3:환불, 4:이전, 9:조정] ==> X 
    PSV_CRG_DIV           IN   VARCHAR2, -- 21. 결제방법[1:현금, 2:신용카드, 9:조정] 
    PSV_CRG_AMT           IN   VARCHAR2, -- 22. 결제금액 
    PSV_ORG_CRG_DT        IN   VARCHAR2, -- 23. 원거래일자 
    PSV_ORG_CRG_SEQ       IN   VARCHAR2, -- 24. 원거래일련번호 
    PSV_CHANNEL           IN   VARCHAR2, -- 25. 경로구분[1:POS, 2:WEB, 3:MOBILE, 9:관리자] 
    PSV_CRG_SCOPE         IN   VARCHAR2, -- 26. 충전범위[1:한장충전, 2:여러장충전, 3:카드단위배부] 2단계 
    PSV_DC_AMT            IN   VARCHAR2, -- 27. 할인금액 2단계
    PSV_ADD_AMT           IN   VARCHAR2, -- 28. 할증금액 2단계
    PSV_SELF_CRG_YN       IN   VARCHAR2, -- 29. SELF 충전여부[YN] 2단계 
    PSV_CARD_CNT          IN   VARCHAR2, -- 30. 카드건수 2단계 
    PSV_C_CARD_ID         IN   VARCHAR2, -- 31. 카드번호(1...n) 2단계 
    PSV_C_CRG_AMT         IN   VARCHAR2, -- 32. 충전금액(1...n) 2단계 
    asRetVal              OUT  VARCHAR2, -- 33. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 34. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
    -- 2단계 카드  
    TYPE  TYPE_CARD_REC IS RECORD 
       (  
        CARD_ID     VARCHAR2(100), -- 카드번호(암호화) 
        CRG_DT      VARCHAR2(008), -- 충전 일자 
        CRG_SEQ     NUMBER  (006), -- 충전 일련번호 
        CRG_AMT     NUMBER  (009), -- 충전금액 
        DC_AMT      NUMBER  (009), -- 할인금액 
        ADD_AMT     NUMBER  (009), -- 할증금액
        CRG_SCP     VARCHAR2(001)  -- 충전범위(1:한장충전, 2:여러장충전, 3:카드단위배부) 
       ); 
        
    TYPE TP_CARD_REC IS TABLE OF TYPE_CARD_REC INDEX BY PLS_INTEGER; 
 
    ARR_CARD_REC     TP_CARD_REC; 
       
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- 카드 ID 
    lsissue_div     C_CARD.ISSUE_DIV%TYPE;                  -- 발급구분[0:신규, 1:재발급] 
    lscard_div      C_CARD.CARD_DIV%TYPE;                   -- 카드관리범위[1:회사, 2:영업조직, 3:점포] 
    lsbrand_cd      C_CARD.BRAND_CD%TYPE;                   -- 영업조직 
    lsstor_cd       C_CARD.STOR_CD%TYPE;                    -- 점포코드 
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- 회원 ID 
    lscard_stat     C_CARD.CARD_STAT%TYPE;                  -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 92:환불, 99:폐기] 
    llCrgAmt        C_CARD_CHARGE_HIS.CRG_AMT%TYPE := 0;    -- 충전금액 
    llstamp_tax     C_CARD_CHARGE_HIS.STAMP_TAX%TYPE := 0;  -- 인지세 
    llsav_cash      C_CARD.SAV_CASH%TYPE;                   -- 충전금액 
    lluse_cash      C_CARD.USE_CASH%TYPE;                   -- 사용금액 
    llCrgSeq        C_CARD_CHARGE_HIS.CRG_SEQ%TYPE :=0;     -- 일련번호 
    llMainCrgSeq    C_CARD_CHARGE_HIS.CRG_SEQ%TYPE :=0;     -- 일련번호(Main) 
     
    nRecCnt         NUMBER(7) := 0; 
    nCheckDigit     NUMBER(7) := 0;                              -- 체크디지트 
    nLoopCnt        NUMBER(7) := 0;                              -- LOOP COUNT 
    nPosSepCard     NUMBER(7) := 0;                              -- 구분자 위치(카드) 
    nPosSepAmt      NUMBER(7) := 0;                              -- 구분자 위치(충전금액) 
     
    vRETVAL         NUMBER(7)      := 0; 
    vRETMSG         VARCHAR2(2000) := NULL; 
     
    vC_CARD_ID      VARCHAR2(32000):= NULL; 
    vC_CRG_AMT      VARCHAR2(32000):= NULL; 
     
    vMULTI_CRG_YN   VARCHAR2(1)    := NULL; 
     
    cREFCUR         REC_SET.M_REFCUR; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000' ; 
    asRetMsg    := ''   ; 
     
    IF PSV_CRG_SCOPE = '1' THEN 
        nLoopCnt := TO_NUMBER(NVL(PSV_CARD_CNT, '1')); 
    ELSE 
        nLoopCnt := TO_NUMBER(NVL(PSV_CARD_CNT, '1')) + 1; 
    END IF;     
     
    vC_CARD_ID := NVL(PSV_C_CARD_ID, PSV_CARD_ID); 
    vC_CRG_AMT := NVL(PSV_C_CRG_AMT, PSV_CRG_AMT); 
     
    IF PSV_CRG_FG = '1' THEN         
        FOR i IN 1 .. nLoopCnt LOOP 
            IF NVL(PSV_CRG_SCOPE, '1') = '1' THEN 
                ARR_CARD_REC(i).CARD_ID     := vC_CARD_ID; 
                ARR_CARD_REC(i).CRG_DT      := NULL; 
                ARR_CARD_REC(i).CRG_SEQ     := 0; 
                ARR_CARD_REC(i).CRG_AMT     := TO_NUMBER(PSV_CRG_AMT); 
                ARR_CARD_REC(i).DC_AMT      := TO_NUMBER(PSV_DC_AMT);
                ARR_CARD_REC(i).ADD_AMT     := TO_NUMBER(PSV_ADD_AMT); 
                ARR_CARD_REC(i).CRG_SCP    := '1'; 
            ELSIF NVL(PSV_CRG_SCOPE, '1') = '2' AND i = 1 THEN 
                ARR_CARD_REC(i).CARD_ID     := encrypt('0000000000000000'); 
                ARR_CARD_REC(i).CRG_DT      := NULL; 
                ARR_CARD_REC(i).CRG_SEQ     := 0; 
                ARR_CARD_REC(i).CRG_AMT     := TO_NUMBER(PSV_CRG_AMT); 
                ARR_CARD_REC(i).DC_AMT      := TO_NUMBER(PSV_DC_AMT);
                ARR_CARD_REC(i).ADD_AMT     := TO_NUMBER(PSV_ADD_AMT); 
                ARR_CARD_REC(i).CRG_SCP     := '2'; 
            ELSE 
                nPosSepCard := INSTR(vC_CARD_ID, '^', 1, 1); 
                nPosSepAmt := INSTR(vC_CRG_AMT, '^', 1, 1); 
                 
                IF (nPosSepCard = 0 AND nPosSepAmt != 0) OR (nPosSepCard != 0 AND nPosSepAmt = 0) THEN 
                    asRetVal := '1001'; 
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001436'); -- 카드 등록에 실패하였습니다. 
                      
                     ROLLBACK; 
                     RAISE ERR_HANDLER; 
                END IF; 
                 
                IF nPosSepCard = 0 THEN 
                    ARR_CARD_REC(i).CARD_ID     := vC_CARD_ID; 
                    ARR_CARD_REC(i).CRG_DT      := NULL; 
                    ARR_CARD_REC(i).CRG_SEQ     := 0; 
                    ARR_CARD_REC(i).CRG_AMT     := TO_NUMBER(vC_CRG_AMT); 
                    ARR_CARD_REC(i).DC_AMT      := 0;
                    ARR_CARD_REC(i).ADD_AMT     := 0; 
                    ARR_CARD_REC(i).CRG_SCP     := '3'; 
                ELSE 
                    ARR_CARD_REC(i).CARD_ID     := SUBSTR(vC_CARD_ID, 1, nPosSepCard - 1); 
                    ARR_CARD_REC(i).CRG_DT      := NULL; 
                    ARR_CARD_REC(i).CRG_SEQ     := 0; 
                    ARR_CARD_REC(i).CRG_AMT     := TO_NUMBER(SUBSTR(vC_CRG_AMT, 1, nPosSepAmt - 1)); 
                    ARR_CARD_REC(i).DC_AMT      := 0;
                    ARR_CARD_REC(i).ADD_AMT     := 0; 
                    ARR_CARD_REC(i).CRG_SCP     := '3'; 
                END IF; 
                 
                vC_CARD_ID := SUBSTR(vC_CARD_ID, nPosSepCard + 1, LENGTH(vC_CARD_ID) - nPosSepCard); 
                vC_CRG_AMT := SUBSTR(vC_CRG_AMT, nPosSepAmt  + 1, LENGTH(vC_CRG_AMT) - nPosSepAmt ); 
            END IF; 
        END LOOP; 
    ELSE         
        -- 여러장 충전 취소 가능여부 체크 
        vMULTI_CRG_YN := PKG_POS_CUST_POS.GET_CUST_INFO_40(PSV_COMP_CD, PSV_LANG_TP, PSV_ORG_CRG_DT, PSV_ORG_CRG_SEQ, PSV_CHANNEL); 
         
        IF  vMULTI_CRG_YN = 'N' THEN 
            asRetVal := '0091'; 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001511'); -- 여러장 충전된 카드 중 충전취소 불가 카드가 존재합니다.  
                          
             ROLLBACK; 
             RAISE ERR_HANDLER; 
        END IF; 
         
        -- 여러장 충전 정보 취득 
        SELECT  CARD_ID 
              , CRG_DT 
              , CRG_SEQ 
              , CRG_AMT * (-1) AS CRG_AMT 
              , DC_AMT  * (-1) AS DC_AMT
              , ADD_AMT * (-1) AS ADD_AMT 
              , CRG_SCOPE      AS CRG_SCP 
        BULK COLLECT INTO ARR_CARD_REC 
        FROM    C_CARD_CHARGE_HIS 
        WHERE   COMP_CD = PSV_COMP_CD 
        AND     CRG_DT  = PSV_ORG_CRG_DT 
        AND     CRG_FG  = '1' 
        AND    ( 
                CRG_SEQ     = TO_NUMBER(PSV_ORG_CRG_SEQ) 
                OR 
                DST_CRG_SEQ = TO_NUMBER(PSV_ORG_CRG_SEQ) 
               ) 
        ORDER BY CRG_SCOPE; 
    END IF; 
     
    FOR i IN 1..ARR_CARD_REC.COUNT LOOP 
        SELECT COUNT(*), MAX(CARD_STAT), MAX(CUST_ID), MAX(SAV_CASH), MAX(USE_CASH), MAX(ISSUE_DIV) 
          INTO nRecCnt,  lscard_stat,    lsCustId,     llsav_cash,    lluse_cash,    lsissue_div 
          FROM C_CARD -- 멤버십카드 마스터 
         WHERE COMP_CD    = PSV_COMP_CD 
           AND CARD_ID    = ARR_CARD_REC(i).CARD_ID 
           AND USE_YN     = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
            
        IF nRecCnt = 0 THEN 
           -- 결제구분[1:충전] 
           IF PSV_CRG_FG = '1' THEN  
              IF ARR_CARD_REC(i).CRG_SCP IN ('1','3') THEN 
                  BEGIN 
                    SELECT CP.CARD_DIV, BM.BRAND_CD, '0000000'  
                      INTO lscard_div , lsbrand_cd , lsstor_cd 
                      FROM COMPANY_PARA CP 
                         , BRAND_MEMB   BM 
                     WHERE CP.COMP_CD  = BM.COMP_CD 
                       AND BM.COMP_CD  = PSV_COMP_CD 
                       AND BM.BRAND_CD = ( 
                                           SELECT CCT.TSMS_BRAND_CD 
                                             FROM C_CARD_TYPE     CCT 
                                                , C_CARD_TYPE_REP CTR  
                                            WHERE CCT.COMP_CD   = CTR.COMP_CD 
                                              AND CCT.CARD_TYPE = CTR.CARD_TYPE 
                                              AND CTR.COMP_CD   = PSV_COMP_CD 
                                              AND decrypt(ARR_CARD_REC(i).CARD_ID) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD) 
                                              AND ROWNUM        = 1 
                                         ) 
                       AND USE_YN      = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
                  EXCEPTION 
                    WHEN OTHERS THEN  
                         asRetVal := '1000'; 
                         asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다. 
                          
                         RAISE ERR_HANDLER; 
                  END; 
              ELSE 
                  -- 여러장 충전인 경우 카드 번호 관리 안함(영업조직 셋트) 
                  lscard_div := '2'; 
              END IF; 
               
              CASE WHEN lscard_div = '1' THEN -- 회사 
                        lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd); 
                        lsstor_cd  := '0000000'; 
                   WHEN lscard_div = '2' THEN -- 영업조직 
                        lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd); 
                        lsstor_cd  := '0000000'; 
                   WHEN lscard_div = '3' THEN -- 점포 
                        lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd); 
                        lsstor_cd  := NVL(PSV_STOR_CD , lsstor_cd ); 
              END CASE; 
               
              -- 체크 디지트 체크(여러장충전의 제외) 
              IF ARR_CARD_REC(i).CRG_SCP IN ('1','3') THEN 
                  lsCardId := decrypt(ARR_CARD_REC(i).CARD_ID); 
                  nCheckDigit := MOD(TO_NUMBER(SUBSTR(lsCardId,1,1))*1  + TO_NUMBER(SUBSTR(lsCardId,2,1))*3  +  
                                     TO_NUMBER(SUBSTR(lsCardId,3,1))*1  + TO_NUMBER(SUBSTR(lsCardId,4,1))*3  +  
                                     TO_NUMBER(SUBSTR(lsCardId,5,1))*1  + TO_NUMBER(SUBSTR(lsCardId,6,1))*3  + 
                                     TO_NUMBER(SUBSTR(lsCardId,7,1))*1  + TO_NUMBER(SUBSTR(lsCardId,8,1))*3  +  
                                     TO_NUMBER(SUBSTR(lsCardId,9,1))*1  + TO_NUMBER(SUBSTR(lsCardId,10,1))*3 +  
                                     TO_NUMBER(SUBSTR(lsCardId,11,1))*1 + TO_NUMBER(SUBSTR(lsCardId,12,1))*3 + 
                                     TO_NUMBER(SUBSTR(lsCardId,13,1))*1 + TO_NUMBER(SUBSTR(lsCardId,14,1))*3 +  
                                     TO_NUMBER(SUBSTR(lsCardId,15,1))*1,10); 
                   
                  IF SUBSTR(lsCardId, 16, 1) != TO_CHAR(nCheckDigit, 'FM0') OR LENGTH(lsCardId) != 16 THEN 
                        asRetVal := '1001'; 
                        asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001436'); -- 카드 등록에 실패하였습니다. 
                          
                         ROLLBACK; 
                         RAISE ERR_HANDLER; 
                  END IF; 
                                                             
                  -- 충전 또는 이전 시 멤버십 카드가 없을 경우 등록 처리 
                  BEGIN 
                    INSERT INTO C_CARD 
                    ( 
                        COMP_CD, CARD_ID, CARD_STAT, ISSUE_DIV, ISSUE_DT, ISSUE_BRAND_CD, ISSUE_STOR_CD, 
                        CARD_DIV, BRAND_CD, STOR_CD, INST_USER, UPD_USER 
                    ) 
                    VALUES 
                    ( 
                        PSV_COMP_CD, ARR_CARD_REC(i).CARD_ID, '10', '0', PSV_CRG_DT||PSV_APPR_TM, PSV_BRAND_CD, PSV_STOR_CD, 
                        lscard_div, lsbrand_cd, lsstor_cd, 'SYSTEM', 'SYSTEM' 
                    ); 
                     
                  EXCEPTION 
                    WHEN OTHERS THEN  
                         asRetVal := '1001'; 
                         asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001401'); -- 카드 등록에 실패하였습니다. 
                          
                         ROLLBACK; 
                         RAISE ERR_HANDLER; 
                  END; 
              END IF; 
               
              nRecCnt     := 1; 
              lscard_stat := '10'; -- 카드상태[00:대기, 10:정상, 20:선물하기, 90:분실신고, 91:해지, 92:환불,99:폐기] 
              lsCustId    := ''; 
              llsav_cash  := 0; 
              lluse_cash  := 0; 
              lsissue_div := '0'; -- 발급구분[0:신규, 1:재발급] 
           ELSE 
              IF ARR_CARD_REC(i).CRG_SCP IN ('1', '3') THEN  
                  asRetVal := '1002'; 
                  asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다. 
                   
                  RAISE ERR_HANDLER; 
              ELSE 
                  lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd); 
                  lsstor_cd  := NVL(PSV_STOR_CD , lsstor_cd );       
              END IF; 
           END IF; 
        ELSE 
           BEGIN 
             SELECT CP.CARD_DIV, BM.BRAND_CD, NVL(PSV_STOR_CD, '0000000')  
               INTO lscard_div , lsbrand_cd , lsstor_cd 
               FROM COMPANY_PARA CP 
                  , BRAND_MEMB   BM 
              WHERE CP.COMP_CD  = BM.COMP_CD 
                AND BM.COMP_CD  = PSV_COMP_CD 
                AND BM.BRAND_CD = ( 
                                    SELECT CCT.TSMS_BRAND_CD 
                                      FROM C_CARD_TYPE     CCT 
                                         , C_CARD_TYPE_REP CTR  
                                     WHERE CCT.COMP_CD   = CTR.COMP_CD 
                                       AND CCT.CARD_TYPE = CTR.CARD_TYPE 
                                       AND CTR.COMP_CD   = PSV_COMP_CD 
                                       AND decrypt(ARR_CARD_REC(i).CARD_ID) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD) 
                                       AND ROWNUM        = 1 
                                  ) 
                AND USE_YN      = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
           EXCEPTION 
             WHEN OTHERS THEN  
                  asRetVal := '1000'; 
                  asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다. 
                   
                  RAISE ERR_HANDLER; 
           END; 
        END IF; 
         
        -- 2015/02/10 분실된 카드는 충전, 취소, 조정 불가 
        CASE WHEN PSV_CRG_FG IN ('1', '2', '9') AND lscard_stat = '90' THEN -- 분실신고 
                  asRetVal := '1003'; 
                  asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001396'); -- 분실신고된 카드번호 입니다. 
                   
                  RAISE ERR_HANDLER; 
             WHEN lscard_stat = '81' THEN -- 해지신청
                  asRetVal := '1004'; 
                  asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001558'); -- 해지 신청된 카드번호 입니다. 
                   
                  RAISE ERR_HANDLER; 
             WHEN lscard_stat = '91' THEN -- 해지 
                  asRetVal := '1004'; 
                  asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001397'); -- 해지된 카드번호 입니다. 
                   
                  RAISE ERR_HANDLER; 
             WHEN lscard_stat = '92' THEN -- 환불 
                  asRetVal := '1004'; 
                  asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001414'); -- 환불된 카드번호 입니다. 
                   
                  RAISE ERR_HANDLER;      
             WHEN lscard_stat = '99' THEN -- 폐기 
                  asRetVal := '1005'; 
                  asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001398'); -- 폐기된 카드번호 입니다. 
                   
                  RAISE ERR_HANDLER; 
             ELSE 
                  asRetVal := '0000'; 
        END CASE; 
         
        IF PSV_CRG_FG IN('1', '4', '9') THEN -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정] 
           -- 충전잔액이 50만원을 넘으면(여러장충전은 제외)  
           IF ARR_CARD_REC(i).CRG_SCP IN ('1', '3') AND (500000 < (ARR_CARD_REC(i).CRG_AMT + llsav_cash - lluse_cash)) THEN 
              asRetVal := '1006'; 
              asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001399'); -- 충전가능 한도를 초과하였습니다. 
               
              RAISE ERR_HANDLER; 
           END IF; 
            
           IF llsav_cash = 0 AND lluse_cash = 0 THEN -- 충전금액과 사용금액이 0이면 
              SELECT COUNT(*) 
                  INTO nRecCnt 
                  FROM C_CARD_CHARGE_HIS A -- 멤버십카드 충전이력 
                 WHERE COMP_CD      = PSV_COMP_CD 
                   AND CARD_ID      = ARR_CARD_REC(i).CARD_ID 
                   AND CRG_FG       IN('1', '4', '9')  -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정] 
                   AND USE_YN       = 'Y'              -- 사용여부[Y:사용, N:사용안함] 
                   AND NOT EXISTS ( 
                                   SELECT CARD_ID   -- 취소내역이 있을 경우 제외 
                                     FROM C_CARD_CHARGE_HIS B 
                                    WHERE B.COMP_CD     = A.COMP_CD 
                                      AND B.CARD_ID     = A.CARD_ID 
                                      AND B.ORG_CRG_DT  = A.CRG_DT 
                                      AND B.ORG_CRG_SEQ = A.CRG_SEQ 
                                      AND B.CRG_FG      = '2' -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정] 
                                      AND B.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
                                   ); 
                                    
              IF ARR_CARD_REC(i).CRG_SCP IN ('1', '3') AND nRecCnt = 0 THEN -- 카드단위로 최초충전 시 
                 /* 최초 충전은 아무 경로에서나 가능. (매장에서 ALL로 변경) 
                 IF PSV_CRG_FG = '1' AND PSV_CHANNEL = '9' THEN -- 결제구분[1:충전], 경로구분[1:POS, 2:WEB, 3:MOBILE, 9:관리자] 
                    asRetVal := '1007'; 
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001400'); -- 최초 충전은 매장에서만 가능합니다. 
                     
                    RAISE ERR_HANDLER; 
                 END IF; 
                 */ 
                 BEGIN 
                   SELECT TO_NUMBER(VAL_C1) 
                     INTO llstamp_tax 
                     FROM COMMON 
                    WHERE CODE_TP     = '01711' -- 선불카드 인지세 금액구간 
                      AND TO_NUMBER(ARR_CARD_REC(i).CRG_AMT) BETWEEN VAL_N1 AND VAL_N2 
                      AND USE_YN      = 'Y';    -- 사용여부[Y:사용, N:사용안함] 
                 EXCEPTION 
                   WHEN OTHERS THEN  
                        llstamp_tax := 0; 
                 END; 
              ELSE 
                  llstamp_tax := 0; 
              END IF; 
           END IF; 
            
           /*** 고객별 한도체크 CUT MODIFY 2015/05/27 *** 
           IF NVL(lsCustId, ' ') <> ' ' THEN -- 회원 ID 존재 시 
              SELECT COUNT(*), MAX(SAV_CASH), MAX(USE_CASH) 
                INTO nRecCnt,  llsav_cash,    lluse_cash 
                FROM C_CUST -- 회원 마스터 
               WHERE COMP_CD   = PSV_COMP_CD 
                 AND CUST_ID   = lsCustId 
                 AND CUST_STAT = '2'  -- 회원상태[1:가입, 2:멤버십, 9:탈퇴] 
                 AND USE_YN    = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
                    
              IF nRecCnt > 0 THEN 
                 IF 500000 < PSV_CRG_AMT + llsav_cash - lluse_cash THEN -- 충전잔액이 50만원을 넘으면 
                    asRetVal := '1008'; 
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001399'); -- 충전가능 한도를 초과하였습니다. 
                     
                    RAISE ERR_HANDLER; 
                 END IF; 
              END IF; 
           END IF; 
           **********************************************/ 
        END IF; 
         
        IF PSV_CRG_FG = '1' AND MOD(TO_NUMBER(ARR_CARD_REC(i).CRG_AMT), 10000) <> 0 THEN -- 결제구분[1:충전] 
           asRetVal := '1009'; 
           asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001409'); -- 결제금액은 만원 단위로 가능합니다 
            
           RAISE ERR_HANDLER; 
        END IF; 
         
        IF PSV_CRG_FG = '2' THEN -- 결제구분 2:취소 
           IF TO_NUMBER(ARR_CARD_REC(i).CRG_AMT) = 0 THEN  
              asRetVal := '1019'; 
              asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001450'); -- 충전금액이 NULL입니다. 
               
              RAISE ERR_HANDLER; 
           END IF;    
            
           IF ARR_CARD_REC(i).CRG_SCP IN ('1', '3') AND (TO_NUMBER(ARR_CARD_REC(i).CRG_AMT) > (llsav_cash - lluse_cash)) THEN 
              asRetVal := '1201'; 
              asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001432'); -- 고객카드 잔액이 부족합니다. 
               
              RAISE ERR_HANDLER; 
           END IF; 
            
           -- 원거래 취소 여부  
           SELECT COUNT(*) INTO nRecCnt 
             FROM C_CARD_CHARGE_HIS -- 멤버십카드 충전이력 
            WHERE COMP_CD     = PSV_COMP_CD 
              AND CARD_ID     = ARR_CARD_REC(i).CARD_ID 
              AND ORG_CRG_DT  = PSV_ORG_CRG_DT 
              AND ORG_CRG_SEQ = ARR_CARD_REC(i).CRG_SEQ 
              AND USE_YN      = 'Y';     -- 사용여부[Y:사용, N:사용안함] 
              
           IF nRecCnt > 0 THEN 
              asRetVal := '1020'; 
              asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1001343008'); -- 이미 반품 확정된 DATA입니다. 
               
              RAISE ERR_HANDLER; 
           END IF; 
            
           -- 충전에 의해 발행된 쿠폰 사용여부 체크 
           SELECT COUNT(*) INTO nRecCnt  
             FROM C_COUPON_CUST CCH 
            WHERE CCH.COMP_CD     = PSV_COMP_CD 
              AND CCH.CUST_ID     = lsCustId  
              AND CCH.PRT_SALE_DT = PSV_ORG_CRG_DT                      -- 충전일자  
              AND CCH.PRT_BRAND_CD= PSV_BRAND_CD                        -- 브랜드 
              AND CCH.PRT_STOR_CD = TO_CHAR(ARR_CARD_REC(i).CRG_SEQ, 'FM999999')-- 일련번호(일련번호 항목이 없어 점포코드 항목 사용)  
              AND CCH.USE_STAT    = '10'                       
              AND CCH.USE_YN      = 'Y';  -- 사용여부[Y:사용, N:사용안함] 
            
           IF nRecCnt > 0 THEN 
              asRetVal := '1020'; 
              asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001481'); -- 멤버십 혜택을 받은 경우 충전 취소가 불가능 합니다. 
               
              RAISE ERR_HANDLER; 
           END IF; 
                                        
           -- 원거래 인지세 취득 
           SELECT COUNT(*), NVL(MAX(CASE WHEN SUBSTR(CRG_DT, 1, 6) = SUBSTR(PSV_CRG_DT, 1, 6) THEN STAMP_TAX ELSE 0 END), 0) * (-1), NVL(MAX(CRG_AMT), 0) * (-1) 
             INTO nRecCnt, llstamp_tax, llCrgAmt 
             FROM C_CARD_CHARGE_HIS -- 멤버십카드 충전이력 
            WHERE COMP_CD     = PSV_COMP_CD 
              AND CARD_ID     = ARR_CARD_REC(i).CARD_ID 
              AND CRG_DT      = PSV_ORG_CRG_DT 
              AND CRG_SEQ     = ARR_CARD_REC(i).CRG_SEQ 
              AND USE_YN      = 'Y';     -- 사용여부[Y:사용, N:사용안함] 
               
           IF nRecCnt = 0 THEN 
              asRetVal := '1101'; 
              asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001389'); -- 원거래 내역이 존재하지 읺습니다. 
               
              RAISE ERR_HANDLER; 
           END IF; 
            
           IF ARR_CARD_REC(i).CRG_SCP = '1' AND llCrgAmt !=  TO_NUMBER(ARR_CARD_REC(i).CRG_AMT) THEN 
              asRetVal := '1102'; 
              asRetMsg := '['||FN_GET_FORMAT_CRAD(decrypt(ARR_CARD_REC(i).CARD_ID))||']@$'||FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001451'); -- 충전금액과 충전취소 금액이 일치하지 않습니다. 
               
              RAISE ERR_HANDLER; 
           END IF; 
        END IF; 
         
        -- 충전이력 작성(카드등록은 제외) 
        IF TO_NUMBER(ARR_CARD_REC(i).CRG_AMT) != 0 THEN  
            IF PSV_CRG_FG = '2' THEN -- 결제구분 2:취소인 경우 충전에 의한 쿠폰 폐기 
                PKG_POS_CUST_REQ.SET_MEMB_CUPN_20(PSV_COMP_CD, PSV_LANG_TP, PSV_ORG_CRG_DT, PSV_BRAND_CD, TO_CHAR(ARR_CARD_REC(i).CRG_SEQ, 'FM999999'), '', '', vRETVAL, vRETMSG, cREFCUR); 
                 
                IF vRETVAL != 1 THEN 
                    asRetVal := '1103'; 
                    asRetMsg := vRETMSG; 
                     
                    RAISE ERR_HANDLER; 
                END IF; 
            END IF;    
             
            llCrgSeq := SQ_PCRM_SEQ.NEXTVAL; 
             
            IF ARR_CARD_REC(i).CRG_SCP IN ('1', '2') THEN 
                llMainCrgSeq := llCrgSeq; 
            END IF; 
             
            -- 충전이력 작성 
            INSERT INTO C_CARD_CHARGE_HIS 
            ( 
                COMP_CD     ,       CARD_ID     , 
                CRG_DT      ,       CRG_SEQ     , 
                CRG_FG      ,       CRG_DIV     , 
                CRG_AMT     ,       CHANNEL     , 
                BRAND_CD    ,       STOR_CD     , 
                REMARKS     , 
                TRN_CARD_ID , 
                POS_NO      , 
                CARD_NO     ,       CARD_NM     , 
                APPR_DT     ,       APPR_TM     , 
                APPR_VD_CD  ,       APPR_VD_NM  , 
                APPR_IS_CD  ,       APPR_COM    , 
                ALLOT_LMT   , 
                READ_DIV    ,       APPR_DIV    , 
                APPR_NO     , 
                ORG_CRG_DT  ,       ORG_CRG_SEQ , 
                STAMP_TAX   ,       USE_YN      , 
                SAP_IF_YN   ,       SAP_IF_DT   , 
                CRG_SCOPE   ,       CRG_AUTO_DIV, 
                DC_AMT      ,       ADD_AMT     ,
                SELF_CRG_YN , 
                DST_CRG_DT  ,       DST_CRG_SEQ , 
                ORG_CHANNEL , 
                INST_DT     ,       INST_USER   , 
                UPD_DT      ,       UPD_USER 
            ) 
            VALUES 
            ( 
                PSV_COMP_CD ,       ARR_CARD_REC(i).CARD_ID, 
                PSV_CRG_DT  ,       llCrgSeq, 
                PSV_CRG_FG  ,       PSV_CRG_DIV , 
                ARR_CARD_REC(i).CRG_AMT,       PSV_CHANNEL , 
                lsbrand_cd  ,       NVL(PSV_STOR_CD, lsstor_cd), 
                GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP), 
                NULL            , 
                PSV_POS_NO      , 
                PSV_CARD_NO     ,     PSV_CARD_NM , 
                NVL(PSV_APPR_DT, TO_CHAR(SYSDATE, 'YYYYMMDD')),     NVL(PSV_APPR_TM, TO_CHAR(SYSDATE, 'HH24MISS')) , 
                PSV_APPR_VD_CD  ,     PSV_APPR_VD_NM, 
                PSV_APPR_IS_CD  ,     PSV_APPR_COM, 
                PSV_ALLOT_LMT   , 
                PSV_READ_DIV    ,     PSV_APPR_DIV, 
                PSV_APPR_NO     , 
                PSV_ORG_CRG_DT  ,     CASE WHEN ARR_CARD_REC(i).CRG_SEQ = 0 THEN NULL ELSE ARR_CARD_REC(i).CRG_SEQ END, 
                llstamp_tax     ,     'Y'         , 
                'N'             ,     NULL        , 
                ARR_CARD_REC(i).CRG_SCP,    '1'   , 
                ARR_CARD_REC(i).DC_AMT ,    ARR_CARD_REC(i).ADD_AMT,
                NVL(PSV_SELF_CRG_YN, 'N'), 
                PSV_CRG_DT      ,     llMainCrgSeq, 
                PSV_CHANNEL     , 
                SYSDATE         ,     'SYS'       , 
                SYSDATE         ,     'SYS' 
            ); 
        END IF; 
    END LOOP; 
     
    OPEN asResult FOR  -- 멤버십 카드 충전 결과 
        SELECT SAV_CASH - USE_CASH AS CUR_CASH_PNT, llMainCrgSeq AS CRG_SEQ 
          FROM C_CARD 
         WHERE COMP_CD = PSV_COMP_CD 
           AND CARD_ID = PSV_CARD_ID 
           AND USE_YN  = 'Y'            -- 사용여부[Y:사용, N:사용안함] 
           AND '1'     = NVL(PSV_CRG_SCOPE, '1') 
        UNION ALL 
        SELECT TO_NUMBER(PSV_CRG_AMT) AS CUR_CASH_PNT, llMainCrgSeq AS CRG_SEQ 
          FROM DUAL 
         WHERE '2'     = NVL(PSV_CRG_SCOPE, '1');  
      
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다. 
     
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
          
         asRetVal := '2001'; 
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- 오류가 발생하였습니다. 
          
         ROLLBACK; 
         RETURN; 
  END SET_MEMB_CHG_10; 
   
  ------------------------------------------------------------------------------ 
  --  Package Name     : SET_MEMB_CHG_20 
  --  Description      : POS 멤버십 사용/적립 > POS에서만 가능 
  --  Ref. Table       : C_CARD            멤버십카드 마스터 
  --                     C_CUST            회원 마스터 
  --                     C_CARD_USE_HIS    멤버십카드 사용이력 
  --                     C_CARD_SAV_HIS    멤버십카드 적립이력 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE SET_MEMB_CHG_20 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_CARD_ID           IN   VARCHAR2, -- 3. 카드번호 
    PSV_USE_DT            IN   VARCHAR2, -- 4. 사용일자 
    PSV_MEMB_DIV          IN   VARCHAR2, -- 5. 멤버십구분[1: 충전금액, 2: 포인트] 
    PSV_SALE_DIV          IN   VARCHAR2, -- 6. 판매구분 
    PSV_USE_AMT           IN   VARCHAR2, -- 7. 사용금액 
    PSV_SAV_MLG           IN   VARCHAR2, -- 8. 적립마일리지 
    PSV_SAV_PT            IN   VARCHAR2, -- 9. 적립포인트 
    PSV_USE_PT            IN   VARCHAR2, -- 10. 사용포인트 
    PSV_BRAND_CD          IN   VARCHAR2, -- 11. 영업조직 
    PSV_STOR_CD           IN   VARCHAR2, -- 12. 점포코드 
    PSV_POS_NO            IN   VARCHAR2, -- 13. 포스번호 
    PSV_BILL_NO           IN   VARCHAR2, -- 14. 영수증번호 
    PSV_USE_TM            IN   VARCHAR2, -- 15. 사용시간 
    PSV_ORG_USE_DT        IN   VARCHAR2, -- 16. 원거래일자 
    PSV_ORG_USE_SEQ       IN   VARCHAR2, -- 17. 원거래일련번호 
    asRetVal              OUT  VARCHAR2, -- 18. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 19. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
    -- PACKAGE ARRAY 
    ARR_SALE_HD     PKG_TYPE.TRG_SALE_HD; 
    -- LOCAL Variable 
    lsCardId        C_CARD.CARD_ID%TYPE;               -- 카드 ID 
    lsCustId        C_CARD.CUST_ID%TYPE;               -- 회원 ID
    lsMembDiv       C_CARD.MEMB_DIV%TYPE;              -- 회원구분[0:엠즈씨드, 1:통합멤버십]
    lsMlgSavDt      C_CUST.MLG_SAV_DT%TYPE;            -- 마일리지 적립 일자 
    lsCouponCd      C_COUPON_MST.COUPON_CD%TYPE;       -- 쿠폰번호  
    nCurSavMlg      C_CUST.SAV_MLG%TYPE := 0;          -- 현재마일리지 
    nRecSeq         VARCHAR2(7);                            -- 일련번호 
    nRecCnt         NUMBER(7) := 0;                         -- 레코드 건수 
    nUniCpnCnt      NUMBER(7) := 0;                         -- 유일 쿠폰 건수 
    nDayCpnCnt      NUMBER(7) := 0;                         -- 하루 쿠폰 건수 
    nPsnCpnCnt      NUMBER(7) := 0;                         -- 개인 쿠폰 건수 
    nCurCash        C_CARD.SAV_CASH%TYPE := 0;         -- 현재 잔액 
    nCurPoint       C_CARD.SAV_PT%TYPE   := 0;         -- 현재 포인트 
    
    vPRM_STR_DT     VARCHAR2(8)    := NULL;                 -- 프로모션 시작일자
    vPRM_END_DT     VARCHAR2(8)    := NULL;                 -- 프로모션 종료일자
    nPRM_STD_VAL    NUMBER         :=    0;                 -- 프로모션 기준 크라운 수
    vPRM_MSG        VARCHAR2(2000) := NULL;                 -- 프로모션 메시지
    vCPN_PRT_YN     VARCHAR2(1)    := 'N';                  -- 쿠폰 발행 여부
    
    -- 프로시저 호출 결과 
    nARG_RTN_CD     NUMBER; 
    vARG_RTN_MSG    VARCHAR2(2000) := NULL;
    
    -- 쿠폰 폐기 호출 결과
    nCPN_RTN_CD     NUMBER; 
    vCPN_RTN_MSG    VARCHAR2(2000) := NULL;
    cRESULT         REC_SET.M_REFCUR;
    
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
   
    asRetVal    := '0000'; 
    asRetMsg    := ''  ; 
     
    BEGIN 
      SELECT COUNT(*), MAX(SAV_CASH - USE_CASH), MAX(SAV_PT - USE_PT - LOS_PT), MAX(CUST_ID), MAX(MEMB_DIV) 
        INTO nRecCnt,  nCurCash,                 nCurPoint,                     lsCustId,     lsMembDiv
        FROM C_CARD 
       WHERE COMP_CD   = PSV_COMP_CD 
         AND CARD_ID   = PSV_CARD_ID 
         AND CARD_STAT = '10' -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기] 
         AND USE_YN    = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
          
      IF nRecCnt = 0 THEN 
         asRetVal := '1001'; 
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다. 
          
         RETURN; 
      END IF; 
       
      IF    PSV_MEMB_DIV = '1' AND PSV_SALE_DIV = '1' THEN   -- 충전금액, 사용 
         IF nCurCash < TO_NUMBER(PSV_USE_AMT) THEN 
            asRetVal := '1010'; 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001395'); -- 충전잔액이 부족합니다. 
             
            RETURN; 
         END IF; 
      ELSIF PSV_MEMB_DIV = '2' AND PSV_SALE_DIV = '301' THEN -- 포인트, 사용 
         IF nCurPoint < TO_NUMBER(PSV_USE_PT) THEN 
            asRetVal := '1010'; 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001386'); -- 고객 포인트 잔액이 부족합니다. 
             
            RETURN; 
         END IF; 
      END IF; 
    END; 
     
    -- 원거래 존재여부 / 기 취소여부 체크 
    IF PSV_SALE_DIV IN ('2', '202', '302') THEN -- 2: 반품, 202: 적립반품, 302: 사용반품 
        -- 원거래 존재여부 
        IF PSV_SALE_DIV =  '2' THEN 
            SELECT COUNT(*) 
              INTO nRecCnt 
              FROM C_CARD_USE_HIS 
             WHERE COMP_CD = PSV_COMP_CD 
               AND CARD_ID = PSV_CARD_ID 
               AND USE_DT  = PSV_ORG_USE_DT 
               AND USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ) 
               AND USE_YN  = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
        ELSIF PSV_SALE_DIV IN ('202', '302') THEN 
            SELECT COUNT(*) 
              INTO nRecCnt 
              FROM C_CARD_SAV_HIS 
             WHERE COMP_CD = PSV_COMP_CD 
               AND CARD_ID = PSV_CARD_ID 
               AND USE_DT  = PSV_ORG_USE_DT 
               AND USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ); 
        END IF; 
             
        IF nRecCnt = 0 THEN 
            asRetVal := '1020'; 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001389'); -- 원거래 내역이 존재하지 않습니다. 
             
            RETURN; 
        END IF; 
         
        -- 기 취소여부 체크 
        IF    PSV_SALE_DIV = '2' THEN  
            SELECT COUNT(*) 
              INTO nRecCnt 
              FROM C_CARD_USE_HIS 
             WHERE COMP_CD     = PSV_COMP_CD 
               AND CARD_ID     = PSV_CARD_ID 
               AND ORG_USE_DT  = PSV_ORG_USE_DT 
               AND ORG_USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ) 
               AND USE_YN      = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
        ELSIF PSV_SALE_DIV IN ('202', '302') THEN 
            SELECT COUNT(*) 
              INTO nRecCnt 
              FROM C_CARD_SAV_HIS 
             WHERE COMP_CD     = PSV_COMP_CD 
               AND CARD_ID     = PSV_CARD_ID 
               AND ORG_USE_DT  = PSV_ORG_USE_DT 
               AND ORG_USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ); 
        END IF; 
        
        IF nRecCnt > 0 THEN 
            asRetVal := '1030'; 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1001343008'); -- 이미 반품 확정된 DATA입니다. 
           
            RETURN; 
        END IF; 
    END IF; 
     
    IF PSV_MEMB_DIV = '1' THEN -- 멤버십 사용 
       -- 일련번호 취득 
       SELECT SQ_PCRM_SEQ.NEXTVAL 
         INTO nRecSeq 
         FROM DUAL; 
           
       INSERT INTO C_CARD_USE_HIS 
       ( 
           COMP_CD     ,       CARD_ID     , 
           USE_DT      ,       USE_SEQ     , 
           USE_AMT     ,       SALE_DIV    , 
           USE_DIV     , 
           REMARKS     , 
           BRAND_CD    ,       STOR_CD     , 
           POS_NO      ,       BILL_NO     , 
           USE_TM      ,        
           ORG_USE_DT  ,       ORG_USE_SEQ , 
           USE_YN      , 
           INST_DT     ,       INST_USER   , 
           UPD_DT      ,       UPD_USER
       ) 
       VALUES 
       ( 
           PSV_COMP_CD ,       PSV_CARD_ID , 
           PSV_USE_DT  ,       nRecSeq     , 
           TO_NUMBER(PSV_USE_AMT) ,       PSV_SALE_DIV, 
           CASE WHEN PSV_SALE_DIV = '1' THEN '301'             ELSE '302'             END , 
           CASE WHEN PSV_SALE_DIV = '1' THEN '멤버십카드 사용' ELSE '멤버십카드 취소' END , 
           PSV_BRAND_CD,       PSV_STOR_CD , 
           PSV_POS_NO  ,       PSV_BILL_NO , 
           PSV_USE_TM  , 
           PSV_ORG_USE_DT,     CASE WHEN PSV_ORG_USE_SEQ = '0' THEN NULL ELSE TO_NUMBER(PSV_ORG_USE_SEQ) END, 
           'Y'         , 
           SYSDATE     ,       'SYS'       , 
           SYSDATE     ,       'SYS'
       ); 
        
       IF NVL(lsCustId, ' ') <> ' ' THEN -- 회원 ID 존재 시 
          IF PSV_SALE_DIV IN('301', '303', '901') AND TO_NUMBER(PSV_USE_AMT) > 0 THEN -- 적립사용종류[301:사용, 302:사용반품, 303:사용누락, 901:조정] 
             UPDATE C_CUST 
                SET CASH_USE_DT = PSV_USE_DT 
              WHERE COMP_CD     = PSV_COMP_CD 
                AND CUST_ID     = lsCustId; 
          END IF; 
       END IF; 
    ELSE -- 멤버십 적립 
       -- 현재 마일리지  
       SELECT SAV_MLG INTO nCurSavMlg 
       FROM   C_CUST 
       WHERE  COMP_CD = PSV_COMP_CD 
       AND    CUST_ID = lsCustId; 
        
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
           SAV_MLG     , 
           LOS_MLG     ,       LOS_MLG_YN  , 
           LOS_MLG_DT  ,       SAV_PT      , 
           USE_PT      ,       LOS_PT      , 
           BRAND_CD    ,       STOR_CD     , 
           POS_NO      ,       BILL_NO     , 
           ORG_USE_DT  ,       ORG_USE_SEQ , 
           USE_TM      ,       USE_YN      , 
           INST_DT     ,       INST_USER   , 
           UPD_DT      ,       UPD_USER    ,
           MEMB_DIV
       ) 
       VALUES 
       ( 
           PSV_COMP_CD ,       PSV_CARD_ID , 
           PSV_USE_DT  ,       nRecSeq     , 
           CASE WHEN PSV_SALE_DIV LIKE '2%' THEN '1'             ELSE '2'             END, 
           PSV_SALE_DIV , 
           CASE WHEN PSV_SALE_DIV LIKE '2%' THEN '마일리지 적립' ELSE '마일리지 사용' END || 
           CASE WHEN PSV_SALE_DIV LIKE '%2' THEN '취소'          ELSE NULL            END, 
           CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN TO_NUMBER(PSV_SAV_MLG) ELSE TO_NUMBER(PSV_SAV_MLG) END, 
           0           ,       'N'         , 
           TO_CHAR(ADD_MONTHS(TO_DATE(PSV_USE_DT, 'YYYYMMDD'), 12) - 1, 'YYYYMMDD') , 
           CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN TO_NUMBER(PSV_SAV_PT)  ELSE TO_NUMBER(PSV_SAV_PT) END, 
           CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN TO_NUMBER(PSV_USE_PT)  ELSE TO_NUMBER(PSV_USE_PT) END, 
           0           , 
           PSV_BRAND_CD,       PSV_STOR_CD , 
           PSV_POS_NO  ,       PSV_BILL_NO , 
           PSV_ORG_USE_DT,     CASE WHEN PSV_ORG_USE_SEQ = '0' THEN NULL ELSE TO_NUMBER(PSV_ORG_USE_SEQ) END, 
           PSV_USE_TM  ,       'Y'         , 
           SYSDATE    ,        'SYS'       , 
           SYSDATE    ,        'SYS'       ,
           lsMembDiv
       ); 
        
       IF NVL(lsCustId, ' ') <> ' ' THEN -- 회원 ID 존재 시 
          IF (PSV_SALE_DIV IN(       '201', '203', '901', '902', '903') AND TO_NUMBER(PSV_SAV_MLG) > 0) OR 
             (PSV_SALE_DIV IN('101', '201', '203', '901', '902', '903') AND TO_NUMBER(PSV_SAV_PT)  > 0) THEN -- 적립사용종류[101:회원가입, 102:회원탈퇴 소멸, 201:적립, 202:적립반품, 203:적립누락, 301:사용, 302:사용반품, 303:사용누락, 901:조정, 902:이전, 903:기타] 
              
             -- 최초 적립 DATA 생성 
             IF PSV_SALE_DIV IN('201', '203') AND TO_NUMBER(PSV_SAV_MLG) > 0 THEN 
                 -- 최초구매 쿠폰 발행 존재 여부  
                 SELECT COUNT(*), MAX(MST.COUPON_CD)  
                 INTO   nRecCnt,  lsCouponCd    
                 FROM   C_COUPON_MST      MST 
                      , C_COUPON_ITEM_GRP GRP 
                 WHERE  MST.COMP_CD   = GRP.COMP_CD 
                 AND    MST.COUPON_CD = GRP.COUPON_CD 
                 AND    MST.START_DT <= TO_CHAR(SYSDATE, 'YYYYMMDD') 
                 AND    MST.CLOSE_DT >= TO_CHAR(SYSDATE, 'YYYYMMDD') 
                 AND    GRP.PRT_DIV   = '07';  -- 쿠폰 발행구분[07:첫구매] 
                  
                 IF nRecCnt > 0 AND nCurSavMlg = 0 THEN 
                     -- 최초 마일리지 적립 여부 
                    SELECT /*+ INDEX(CST PK_C_COUPON_CUST) */ 
                           NVL(SUM(CASE WHEN CST.CERT_FDT = PSV_USE_DT AND CST.PRT_BRAND_CD = PSV_BRAND_CD AND CST.PRT_STOR_CD = PSV_STOR_CD THEN 1 ELSE 0 END), 0) DAY_CPN_CNT 
                         , NVL(SUM(CASE WHEN CST.CUST_ID  = lsCustId                                                                         THEN 1 ELSE 0 END), 0) PSN_CPN_CNT  
                         , COUNT(*)  
                    INTO   nDayCpnCnt, nPsnCpnCnt, nUniCpnCnt 
                    FROM   C_COUPON_CUST CST 
                    WHERE  CST.COMP_CD   = PSV_COMP_CD 
                    AND    CST.COUPON_CD = lsCouponCd 
                    AND    CST.CUST_ID   = lsCustId  
                    AND    CST.USE_STAT NOT IN ('32', '34'); 
                  
                    IF nPsnCpnCnt = 0 THEN 
                        /**** 최초 구매는 매장정보만 함 **/ 
                        ARR_SALE_HD.SALE_DT  := PSV_USE_DT; 
                        ARR_SALE_HD.BRAND_CD := PSV_BRAND_CD; 
                        ARR_SALE_HD.STOR_CD  := PSV_STOR_CD; 
                        ARR_SALE_HD.POS_NO   := PSV_POS_NO; 
                        ARR_SALE_HD.BILL_NO  := PSV_BILL_NO; 
                        ARR_SALE_HD.SALE_DIV := '1'; 
                         
                        --쿠폰 발행 
                        SP_CROWN_COUPON_BLD(PSV_COMP_CD, PSV_LANG_TP, lsCustId, '07', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG); 
                         
                        -- 최초 적립 이력 작성 
                        MERGE   INTO C_CUST_FBD 
                        USING   DUAL 
                        ON     ( 
                                    COMP_CD = PSV_COMP_CD 
                                AND CUST_ID = lsCustId 
                               ) 
                        WHEN NOT MATCHED THEN 
                            INSERT ( 
                                    COMP_CD    ,    CUST_ID     , 
                                    SALE_DT    ,    BRAND_CD    , 
                                    STOR_CD    ,    POS_NO      , 
                                    BILL_NO    ,    SALE_DIV    , 
                                    SAV_MLG    ,    COUPON_PRT  , 
                                    INST_DT    ,    INST_USER   , 
                                    UPD_DT     ,    UPD_USER 
                                   ) 
                            VALUES ( 
                                    PSV_COMP_CD ,   lsCustId    , 
                                    PSV_USE_DT  ,   PSV_BRAND_CD, 
                                    PSV_STOR_CD ,   PSV_POS_NO  , 
                                    PSV_BILL_NO ,   PSV_SALE_DIV, 
                                    TO_NUMBER(PSV_SAV_MLG) ,   CASE WHEN nARG_RTN_CD = 0 THEN 'Y' ELSE 'N' END, 
                                    SYSDATE     ,   'PKG'       , 
                                    SYSDATE     ,   'PKG'        
                                   ); 
                    END IF; 
                END IF; 
             END IF; 
              
             -- 최근 마일리지 적립일자  
             UPDATE C_CUST 
                SET MLG_SAV_DT  = PSV_USE_DT 
              WHERE COMP_CD     = PSV_COMP_CD 
                AND CUST_ID     = lsCustId; 
          END IF; 
       END IF; 
    END IF; 
    
    /***********************************/
    /* 소사이어티 머그컵 증정 프로모션 */
    IF lsCustId IS NOT NULL THEN
        IF PSV_SALE_DIV IN ('201', '203') THEN
            BEGIN
                SELECT  VAL_D1     , VAL_D2     , VAL_N1
                INTO    vPRM_STR_DT, vPRM_END_DT, nPRM_STD_VAL
                FROM   (
                        SELECT  VAL_D1     , VAL_D2     , VAL_N1
                              , ROW_NUMBER() OVER(PARTITION BY CODE_TP ORDER BY VAL_D1) R_NUM
                        FROM    COMMON
                        WHERE   CODE_TP = '02015'
                        AND     USE_YN  = 'Y'
                        AND     VAL_D1 <= PSV_USE_DT
                        AND     VAL_D2 >= PSV_USE_DT
                       )
                WHERE   R_NUM = 1;
            EXCEPTION 
                WHEN OTHERS THEN
                    vPRM_STR_DT  := NULL; 
                    vPRM_END_DT  := NULL;
                    nPRM_STD_VAL := 0;
            END;
            
            IF PSV_USE_DT >= vPRM_STR_DT AND PSV_USE_DT <= vPRM_END_DT THEN
                SELECT  CASE WHEN PSV_SALE_DIV IN ('201', '203') AND TERM_SAV_MLG > 0 AND CPN_CNT = 0 THEN
                                CASE WHEN TERM_SAV_MLG >= 5                   THEN FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001578')
                                     WHEN MOD(TERM_SAV_MLG, nPRM_STD_VAL) > 0 THEN REPLACE(FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001577'), '{NN}', nPRM_STD_VAL - MOD(TERM_SAV_MLG, nPRM_STD_VAL)) 
                                     ELSE ''
                                END
                            ELSE ''
                        END PRM_MSG
                      , CASE WHEN PSV_SALE_DIV IN ('201', '203') AND TERM_SAV_MLG >= 5 AND CPN_CNT = 0 THEN 'Y'
                             ELSE 'N'
                        END  CPN_PRT_YN 
                INTO    vPRM_MSG, vCPN_PRT_YN
                FROM   (
                        SELECT  MAX(USE_DT)              AS USE_DT
                              , NVL(SUM(HIS.SAV_MLG), 0) AS TERM_SAV_MLG
                              , NVL(MAX(CPN_CNT)    , 0) AS CPN_CNT
                        FROM    C_CARD_SAV_HIS HIS
                              , C_CARD         CRD
                              ,(
                                SELECT CST.COMP_CD
                                     , CST.CUST_ID
                                     , COUNT(DISTINCT CST.COUPON_CD) AS CPN_CNT  
                                FROM   C_COUPON_ITEM_GRP  GRP
                                     , C_COUPON_CUST      CST
                                WHERE  CST.COMP_CD   = GRP.COMP_CD
                                AND    CST.COUPON_CD = GRP.COUPON_CD
                                AND    CST.COMP_CD   = PSV_COMP_CD
                                AND    CST.CUST_ID   = lsCustId
                                AND    GRP.PRT_DIV   = '11'
                                AND    CST.USE_STAT NOT IN ('32', '34') 
                                GROUP BY
                                       CST.COMP_CD
                                     , CST.CUST_ID 
                               ) CCC
                        WHERE   CRD.COMP_CD = HIS.COMP_CD
                        AND     CRD.CARD_ID = HIS.CARD_ID
                        AND     CRD.COMP_CD = CCC.COMP_CD(+)
                        AND     CRD.CUST_ID = CCC.CUST_ID(+)
                        AND     CRD.COMP_CD = PSV_COMP_CD
                        AND     CRD.CUST_ID = lsCustId
                        AND     HIS.USE_DT >= vPRM_STR_DT
                        AND     HIS.USE_DT <= vPRM_END_DT
                       );
                       
                IF vCPN_PRT_YN = 'Y' THEN 
                    /**** 최초 구매는 매장정보만 함 **/ 
                    ARR_SALE_HD.SALE_DT  := PSV_USE_DT; 
                    ARR_SALE_HD.BRAND_CD := PSV_BRAND_CD; 
                    ARR_SALE_HD.STOR_CD  := TO_CHAR(nRecSeq); 
                    ARR_SALE_HD.SALE_DIV := '1'; 
                                 
                    --쿠폰 발행 
                    SP_CROWN_COUPON_BLD(PSV_COMP_CD, PSV_LANG_TP, lsCustId, '11', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG); 
                    
                    vARG_RTN_MSG := NULL;
                END IF;
            END IF;
        ELSIF PSV_SALE_DIV = '202' THEN
            -- 쿠폰 발급 취소
            PKG_POS_CUST_REQ.SET_MEMB_CUPN_20(PSV_COMP_CD, PSV_LANG_TP, PSV_ORG_USE_DT, PSV_BRAND_CD, PSV_ORG_USE_SEQ, '', '', nCPN_RTN_CD, vCPN_RTN_MSG, cRESULT);
        END IF;
    END IF;
    /***********************************/
     
    OPEN asResult FOR 
    SELECT  REC_SEQ, CUR_SAV_CASH, CUR_SAV_MLG, CUR_SAV_PNT,  
            CASE WHEN LVL_CD = '101' AND CUR_SAV_MLG >= 5  THEN 9999 
                 WHEN LVL_CD = '102' AND CUR_SAV_MLG >= 30 THEN 9999 
                 WHEN LVL_CD = '103'                       THEN 0 
                 ELSE REM_MLG_CNT  
            END AS REM_MLG_CNT, CERT_NO, vPRM_MSG AS PRM_MSG 
      FROM (-- 마일리지 
            SELECT nRecSeq AS REC_SEQ, SAV_CASH - USE_CASH AS CUR_SAV_CASH 
                 , 0 AS CUR_SAV_MLG, 0  AS CUR_SAV_PNT 
                 , 0 AS REM_MLG_CNT, vARG_RTN_MSG AS CERT_NO, 'X' AS LVL_CD 
              FROM C_CARD 
             WHERE COMP_CD   = PSV_COMP_CD 
               AND CARD_ID   = PSV_CARD_ID 
               AND CARD_STAT = '10' -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기] 
               AND USE_YN    = 'Y' -- 사용여부[Y:사용, N:사용안함] 
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('1', '2') THEN 1 ELSE 0 END) 
            UNION ALL -- 포인트(멤버십) 적립/취소 
            SELECT nRecSeq AS RECSEQ, 0 AS CUR_SAV_CASH, SAV_MLG - LOS_MLG  AS CUR_SAV_MLG 
                 , SAV_PT - USE_PT - LOS_PT  AS CUR_SAV_PNT 
                 ,( 
                   SELECT CASE WHEN MIN(LVL.LVL_STD_STR) IS NULL THEN 0 ELSE MIN(LVL.LVL_STD_STR) - (CST.SAV_MLG - CST.LOS_MLG) END  
                   FROM   C_CUST_LVL LVL 
                   WHERE  LVL.COMP_CD     = CST.COMP_CD 
                   AND    LVL.LVL_STD_STR > (CST.SAV_MLG - CST.LOS_MLG)  
                   AND    LVL.USE_YN      = 'Y' 
                  ) AS REM_MLG_CNT 
                 , vARG_RTN_MSG AS CERT_NO, LVL_CD 
              FROM C_CUST CST 
             WHERE CUST_STAT IN ('2', '3')  -- 회원상태[1:가입, 2:멤버십, 3:통합멤버십, 7:통합멤버십 휴면, 8:휴면, 9:탈퇴] 
               AND USE_YN    = 'Y'  -- 사용여부[Y:사용, N:사용안함] 
               AND CUST_ID   = (SELECT CUST_ID 
                                  FROM C_CARD 
                                 WHERE COMP_CD   = PSV_COMP_CD 
                                   AND CARD_ID   = PSV_CARD_ID 
                                   AND CARD_STAT = '10' -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기] 
                                   AND USE_YN    = 'Y' -- 사용여부[Y:사용, N:사용안함] 
                               ) 
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('201', '202') AND lsCustId IS NOT NULL THEN 1 ELSE 0 END) 
            UNION ALL  -- 포인트(가발급) 카드 적립/취소 
            SELECT nRecSeq AS RECSEQ, 0 AS CUR_SAV_CASH 
                 , SAV_MLG - LOS_MLG  AS CUR_SAV_MLG, SAV_PT - USE_PT - LOS_PT  AS CUR_SAV_PNT 
                 , 0 AS REM_MLG_CNT, vARG_RTN_MSG AS CERT_NO, 'X' AS LVL_CD 
              FROM C_CARD 
             WHERE COMP_CD   = PSV_COMP_CD 
               AND CARD_ID   = PSV_CARD_ID 
               AND CARD_STAT = '10' -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기] 
               AND USE_YN    = 'Y' -- 사용여부[Y:사용, N:사용안함] 
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('201', '202') AND lsCustId IS NULL THEN 1 ELSE 0 END)    
            UNION ALL 
            SELECT nRecSeq AS RECSEQ, 0 AS CUR_SAV_CASH 
                 , 0 AS CUR_SAV_MLG, SAV_PT - USE_PT - LOS_PT AS CUR_SAV_PNT 
                 , 0 AS REM_MLG_CNT, vARG_RTN_MSG AS CERT_NO, 'X' AS LVL_CD 
              FROM C_CARD 
             WHERE COMP_CD   = PSV_COMP_CD 
               AND CARD_ID   = PSV_CARD_ID 
               AND CARD_STAT = '10' -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기] 
               AND USE_YN    = 'Y' -- 사용여부[Y:사용, N:사용안함] 
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('301', '302') THEN 1 ELSE 0 END) 
           ); 
            
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상 처리되었습니다. 
     
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
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- 오류가 발생하였습니다. 
          
         ROLLBACK; 
         RETURN; 
  END SET_MEMB_CHG_20; 
 
  ------------------------------------------------------------------------------ 
  --  Package Name     : SET_MEMB_CHG_30 
  --  Description      : 멤버십 환불/이전 
  --  Ref. Table       : C_CARD            멤버십카드 마스터 
  --                     C_CUST            회원 마스터 
  --                     C_CARD_CHARGE_HIS 멤버십카드 충전이력 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE SET_MEMB_CHG_30 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_CARD_ID_SEND      IN   VARCHAR2, -- 3. 카드번호(양도) 
    PSV_CARD_ID_RECV      IN   VARCHAR2, -- 4. 카드번호(양수) 
    PSV_CRG_DT            IN   VARCHAR2, -- 5. 결제일자 
    PSV_CRG_FG            IN   VARCHAR2, -- 6. 결제구분[3:환불, 4:이전] 
    PSV_CRG_DIV           IN   VARCHAR2, -- 7. 결제방법[9:조정] 
    PSV_CRG_AMT           IN   VARCHAR2, -- 8. 결제금액 
    PSV_ACC_USER_NM       IN   VARCHAR2, -- 9. 예금주명 
    PSV_ACC_BANK          IN   VARCHAR2, -- 10.은행코드 
    PSV_ACC_NUM           IN   VARCHAR2, -- 11.계좌번호 
    PSV_CHANNEL           IN   VARCHAR2, -- 12.경로구분[2:WEB, 3:MOBILE] 
    asRetVal              OUT  VARCHAR2, -- 13.결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 14.결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
       
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- 카드 ID 
    lsissue_div     C_CARD.ISSUE_DIV%TYPE;                  -- 발급구분[0:신규, 1:재발급] 
    lscard_div      C_CARD.CARD_DIV%TYPE;                   -- 카드관리범위[1:회사, 2:영업조직, 3:점포] 
    lsbrand_cd      C_CARD.BRAND_CD%TYPE;                   -- 영업조직 
    lsstor_cd       C_CARD.STOR_CD%TYPE;                    -- 점포코드 
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- 회원 ID 
    lsCard_stat     C_CARD.CARD_STAT%TYPE;                  -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기] 
    lsRefundStat    C_CARD.REFUND_STAT%TYPE;                -- 환불 상태 
    lsRepCardYn     C_CARD.REP_CARD_YN%TYPE;                -- 회원 ID 
    llstamp_tax     C_CARD_CHARGE_HIS.STAMP_TAX%TYPE := 0;  -- 인지세 
    llsav_cash      C_CARD.SAV_CASH%TYPE;                   -- 충전금액 
    lluse_cash      C_CARD.USE_CASH%TYPE;                   -- 사용금액 
    nRecCnt         NUMBER(7) := 0; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000' ; 
    asRetMsg    := ''   ; 
     
    IF PSV_CRG_FG NOT IN ('3', '4') THEN -- 결제구분[3:환불, 4:이전] 
       asRetVal := '1000'; 
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001411'); -- 결제구분 입력 오류 입니다. 
        
       RAISE ERR_HANDLER; 
    END IF; 
     
    IF PSV_CRG_FG =  '3' THEN -- 결제구분[3:환불] 
       IF PSV_ACC_USER_NM IS NULL OR PSV_ACC_BANK IS NULL OR PSV_ACC_NUM IS NULL THEN 
          asRetVal := '1001'; 
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001413'); -- 환불시 은행코드. 예금주, 계좌번호는 필수 입력항목입니다. 
           
          RAISE ERR_HANDLER; 
       END IF; 
    ELSE 
       SELECT COUNT(DISTINCT CRD.CUST_ID) 
         INTO nRecCnt 
         FROM C_CARD CRD 
        WHERE CRD.COMP_CD  = PSV_COMP_CD 
          AND CRD.CARD_ID IN (PSV_CARD_ID_SEND, PSV_CARD_ID_RECV); 
           
       IF nRecCnt != 1 THEN 
          asRetVal := '1002'; 
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001417'); -- 양수, 양도자의 고객번호가 일치하지 않습니다. 
           
          RAISE ERR_HANDLER; 
       END IF; 
    END IF; 
      
    -- 양도카드 체크 
    SELECT COUNT(*), MAX(CARD_STAT), MAX(CUST_ID), MAX(SAV_CASH), MAX(USE_CASH), MAX(ISSUE_DIV), MAX(REFUND_STAT) 
      INTO nRecCnt,  lscard_stat,    lsCustId,     llsav_cash,    lluse_cash,    lsissue_div,    lsRefundStat 
      FROM C_CARD -- 멤버십카드 마스터 
     WHERE COMP_CD    = PSV_COMP_CD 
       AND CARD_ID    = PSV_CARD_ID_SEND 
       AND USE_YN     = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
        
    IF nRecCnt = 0 THEN 
       asRetVal := '1003'; 
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다. 
        
       RAISE ERR_HANDLER; 
    ELSE 
        IF PSV_CRG_FG =  '3' THEN 
            IF (ABS(TO_NUMBER(PSV_CRG_AMT)) != (llsav_cash - lluse_cash)) THEN 
                asRetVal := '1004'; 
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001426'); -- 환불금액이 잔액과 일치하지 않습니다. 
                 
                RAISE ERR_HANDLER; 
            END IF; 
             
            IF ((lluse_cash / llsav_cash * 100) < 60 ) THEN 
                asRetVal := '1005'; 
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001427'); -- 충전금액의 60%이상 사용 시 환불이 가능합니다. 
                 
                RAISE ERR_HANDLER; 
            END IF; 
        ELSE 
            IF MOD(TO_NUMBER(PSV_CRG_AMT), 1) != 0 THEN 
                asRetVal := '1006'; 
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1001149105'); -- 금액 입력형식이 올바르지 않습니다. 
                 
                RAISE ERR_HANDLER; 
            END IF; 
             
            IF (TO_NUMBER(PSV_CRG_AMT) > (llsav_cash - lluse_cash)) THEN 
                asRetVal := '1006'; 
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001416'); -- 잔액이 이전금액보다 작습니다. 
                 
                RAISE ERR_HANDLER; 
            END IF; 
       END IF; 
        
       -- 2015/02/10 해지, 폐기된 카드는 환불 불가(환불된 카드는 재 환부 신청이 가능하여 환불 체크 CUT) 
       CASE WHEN lscard_stat = '92' AND lsRefundStat != '99' THEN -- 환불(환불 오류는 제외) 
                 asRetVal := '1007'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001414'); -- 환불된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            WHEN lscard_stat = '81' THEN -- 해지신청
                  asRetVal := '1008'; 
                  asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001558'); -- 해지 신청된 카드번호 입니다. 
                   
                  RAISE ERR_HANDLER; 
             WHEN lscard_stat = '91' THEN -- 해지 
                 asRetVal := '1008'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001397'); -- 해지된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            WHEN lscard_stat = '99' THEN -- 폐기 
                 asRetVal := '1009'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001398'); -- 폐기된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            ELSE 
                 asRetVal := '0000'; 
       END CASE; 
        
       BEGIN 
         SELECT CP.CARD_DIV, BM.BRAND_CD, '0000000'  
           INTO lscard_div , lsbrand_cd , lsstor_cd 
           FROM COMPANY_PARA CP 
              , BRAND_MEMB   BM 
          WHERE CP.COMP_CD  = BM.COMP_CD 
            AND BM.COMP_CD  = PSV_COMP_CD 
            AND BM.BRAND_CD = ( 
                                SELECT TSMS_BRAND_CD 
                                  FROM C_CARD_TYPE     CCT 
                                     , C_CARD_TYPE_REP CTR  
                                 WHERE CCT.COMP_CD   = CTR.COMP_CD 
                                   AND CCT.CARD_TYPE = CTR.CARD_TYPE 
                                   AND CTR.COMP_CD   = PSV_COMP_CD 
                                   AND decrypt(PSV_CARD_ID_SEND) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD) 
                                   AND ROWNUM        = 1 
                              ) 
            AND USE_YN      = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
       EXCEPTION 
         WHEN OTHERS THEN  
              lscard_div := '1'; 
              lsbrand_cd := '0000'; 
              lsstor_cd  := '0000000'; 
       END; 
    END IF; 
     
    -- 양수카드 체크 
    IF PSV_CRG_FG = '4' THEN 
       SELECT COUNT(*), MAX(CARD_STAT), MAX(CUST_ID), MAX(SAV_CASH), MAX(USE_CASH), MAX(ISSUE_DIV) 
         INTO nRecCnt,  lscard_stat,    lsCustId,     llsav_cash,    lluse_cash,    lsissue_div 
         FROM C_CARD -- 멤버십카드 마스터 
        WHERE COMP_CD    = PSV_COMP_CD 
          AND CARD_ID    = PSV_CARD_ID_RECV 
          AND USE_YN     = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
           
       IF nRecCnt = 0 THEN 
          asRetVal := '1020'; 
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다. 
           
          RAISE ERR_HANDLER; 
       END IF; 
        
       -- 2015/02/10 분신된 카드는 충전, 취소, 조정 불가 
       CASE WHEN lscard_stat = '90' THEN -- 분실신고 
                 asRetVal := '1021'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001396'); -- 분실신고된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            WHEN lscard_stat = '81' THEN -- 해지신청
                  asRetVal := '1022'; 
                  asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001558'); -- 해지 신청된 카드번호 입니다. 
                   
                  RAISE ERR_HANDLER; 
             WHEN lscard_stat = '91' THEN -- 해지 
                 asRetVal := '1022'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001397'); -- 해지된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            WHEN lscard_stat = '92' THEN -- 환불 
                 asRetVal := '1023'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001414'); -- 환불된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            WHEN lscard_stat = '99' THEN -- 폐기 
                 asRetVal := '1024'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001398'); -- 폐기된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            ELSE 
                 asRetVal := '0000'; 
       END CASE; 
        
       IF llsav_cash = 0 AND lluse_cash = 0 THEN       -- 충전금액과 사용금액이 0이면 
          SELECT COUNT(*) 
            INTO nRecCnt 
            FROM C_CARD_CHARGE_HIS A           -- 멤버십카드 충전이력 
           WHERE COMP_CD      = PSV_COMP_CD 
             AND CARD_ID      = PSV_CARD_ID_RECV 
             AND CRG_FG       IN('1', '4', '9')     -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정] 
             AND USE_YN       = 'Y'                 -- 사용여부[Y:사용, N:사용안함] 
             AND NOT EXISTS (                       -- 취소내역이 있을 경우 제외 
                             SELECT 1    
                               FROM C_CARD_CHARGE_HIS B 
                              WHERE B.COMP_CD     = A.COMP_CD 
                                AND B.CARD_ID     = A.CARD_ID 
                                AND B.ORG_CRG_DT  = A.CRG_DT 
                                AND B.ORG_CRG_SEQ = A.ORG_CRG_SEQ 
                                AND B.CRG_FG      = '2' -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정] 
                                AND B.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
                             ); 
                                      
          IF nRecCnt = 0 THEN -- 카드단위로 최초충전 시 
             BEGIN 
               SELECT TO_NUMBER(VAL_C1) 
                 INTO llstamp_tax 
                 FROM COMMON 
                WHERE CODE_TP     = '01711' -- 선불카드 인지세 금액구간 
                  AND TO_NUMBER(PSV_CRG_AMT) BETWEEN VAL_N1 AND VAL_N2 
                  AND USE_YN      = 'Y';    -- 사용여부[Y:사용, N:사용안함] 
             EXCEPTION 
               WHEN OTHERS THEN  
                    llstamp_tax := 0; 
             END; 
          END IF; 
       END IF; 
    END IF; 
     
    -- 양도/환불 이력 작성 
    INSERT INTO C_CARD_CHARGE_HIS 
    ( 
        COMP_CD     ,       CARD_ID     , 
        CRG_DT      , 
        CRG_SEQ     , 
        CRG_FG      ,       CRG_DIV     , 
        CRG_AMT     ,        
        CHANNEL     , 
        BRAND_CD    ,       STOR_CD     , 
        REMARKS     , 
        TRN_CARD_ID , 
        POS_NO      , 
        CARD_NO     ,       CARD_NM     , 
        APPR_DT     ,       APPR_TM     , 
        APPR_VD_CD  ,       APPR_VD_NM  , 
        APPR_IS_CD  ,       APPR_COM    , 
        ALLOT_LMT   , 
        READ_DIV    ,       APPR_DIV    , 
        APPR_NO     , 
        ORG_CRG_DT  ,       ORG_CRG_SEQ , 
        STAMP_TAX   ,       USE_YN      , 
        SAP_IF_YN   ,       SAP_IF_DT   , 
        CRG_SCOPE   ,       CRG_AUTO_DIV, 
        DC_AMT      ,       SELF_CRG_YN , 
        DST_CRG_DT  ,       DST_CRG_SEQ , 
        ORG_CHANNEL ,    
        INST_DT     ,       INST_USER   , 
        UPD_DT      ,       UPD_USER 
    ) 
    VALUES 
    ( 
        PSV_COMP_CD ,       PSV_CARD_ID_SEND, 
        PSV_CRG_DT  , 
        SQ_PCRM_SEQ.NEXTVAL             , 
        PSV_CRG_FG  ,       PSV_CRG_DIV , 
        CASE WHEN PSV_CRG_FG = '3' THEN TO_NUMBER(PSV_CRG_AMT) ELSE TO_NUMBER(PSV_CRG_AMT) * (-1) END,  
        PSV_CHANNEL , 
        lsbrand_cd  ,       lsstor_cd   , 
        GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP), 
        PSV_CARD_ID_RECV, 
        NULL        , 
        NULL        ,     NULL  , 
        TO_CHAR(SYSDATE, 'YYYYMMDD'), TO_CHAR(SYSDATE, 'HH24MISS'), 
        NULL        ,     NULL  , 
        NULL        ,     NULL  , 
        NULL        , 
        NULL        ,     NULL  , 
        NULL        , 
        NULL        ,     NULL  , 
        0           ,     'Y'   ,  -- 양수자 인지세 NG 
        'N'         ,     NULL  , 
        '1'         ,     '1'   , -- 개별충전, 자동충전여부 
        0           ,     'N'   , -- 할인금액, 셀프충전여부 
        NULL        ,     0     , -- 멀티충전일, 멀티충전일련번호   
        PSV_CHANNEL , 
        SYSDATE     ,     'SYS' , 
        SYSDATE     ,     'SYS' 
    ); 
     
    -- 양수이력 작성(결제구분[3:환불, 4:이전]이 4:이전 일때만) 
    IF PSV_CRG_FG = '4' THEN 
       INSERT INTO C_CARD_CHARGE_HIS 
       ( 
           COMP_CD     ,       CARD_ID     , 
           CRG_DT      , 
           CRG_SEQ     , 
           CRG_FG      ,       CRG_DIV     , 
           CRG_AMT     ,        
           CHANNEL     , 
           BRAND_CD    ,       STOR_CD     , 
           REMARKS     , 
           TRN_CARD_ID , 
           POS_NO      , 
           CARD_NO     ,       CARD_NM     , 
           APPR_DT     ,       APPR_TM     , 
           APPR_VD_CD  ,       APPR_VD_NM  , 
           APPR_IS_CD  ,       APPR_COM    , 
           ALLOT_LMT   , 
           READ_DIV    ,       APPR_DIV    , 
           APPR_NO     , 
           ORG_CRG_DT  ,       ORG_CRG_SEQ , 
           STAMP_TAX   ,       USE_YN      , 
           SAP_IF_YN   ,       SAP_IF_DT   , 
           CRG_SCOPE   ,       CRG_AUTO_DIV, 
           DC_AMT      ,       SELF_CRG_YN , 
           DST_CRG_DT  ,       DST_CRG_SEQ , 
           ORG_CHANNEL , 
           INST_DT     ,       INST_USER   , 
           UPD_DT      ,       UPD_USER 
       ) 
       VALUES 
       ( 
           PSV_COMP_CD ,       PSV_CARD_ID_RECV, 
           PSV_CRG_DT  , 
           SQ_PCRM_SEQ.NEXTVAL             , 
           PSV_CRG_FG  ,       PSV_CRG_DIV , 
           TO_NUMBER(PSV_CRG_AMT) ,        
           PSV_CHANNEL , 
           lsbrand_cd  ,       lsstor_cd   , 
           GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP), 
           PSV_CARD_ID_SEND, 
           NULL        , 
           NULL        ,     NULL  , 
           TO_CHAR(SYSDATE, 'YYYYMMDD'), TO_CHAR(SYSDATE, 'HH24MISS'), 
           NULL        ,     NULL  , 
           NULL        ,     NULL  , 
           NULL        , 
           NULL        ,     NULL  , 
           NULL        , 
           NULL        ,     NULL  , 
           llstamp_tax ,     'Y'   ,         -- 양수자 최초 중전이 경우 인지세 OK 
           'N'         ,     NULL  , 
           '1'         ,     '1'         , -- 개별충전, 자동충전여부 
           0           ,     'N'         , -- 할인금액, 셀프충전여부 
           NULL        ,     0           , -- 멀티충전일, 멀티충전일련번호 
           PSV_CHANNEL ,  
           SYSDATE     ,     'SYS' , 
           SYSDATE     ,     'SYS' 
       ); 
    END IF; 
     
    -- 환불 시 카드번호 은행정보 SET 
    IF PSV_CRG_FG = '3' THEN 
        -- 회원 현재 정보 취득  
        SELECT  CUST_ID    ,  
                CARD_STAT  ,  
                REP_CARD_YN  
        INTO    lsCustId, lsCard_stat, lsRepCardYn 
        FROM    C_CARD 
        WHERE   COMP_CD = PSV_COMP_CD 
        AND     CARD_ID = PSV_CARD_ID_SEND; 
         
        IF lsCustId IS NOT NULL THEN 
            SELECT  COUNT(*) INTO nRecCnt 
            FROM    C_CARD 
            WHERE   COMP_CD  = PSV_COMP_CD 
            AND     CUST_ID  = lsCustId 
            AND     CARD_ID != PSV_CARD_ID_SEND 
            AND     CARD_STAT IN ('00', '10') 
            AND     USE_YN   = 'Y'; 
        END IF; 
     
        UPDATE C_CARD 
           SET CARD_STAT     = '92' 
            ,  REFUND_REQ_DT = PSV_CRG_DT||TO_CHAR(SYSDATE, 'HH24MISS') 
            ,  BANK_CD       = PSV_ACC_BANK 
            ,  ACC_NO        = PSV_ACC_NUM 
            ,  BANK_USER_NM  = PSV_ACC_USER_NM 
            ,  REFUND_STAT   = '01' 
            ,  REFUND_CASH   = TO_NUMBER(PSV_CRG_AMT) 
            ,  REFUND_CD     = NULL 
            ,  REFUND_MSG    = NULL 
            ,  REP_CARD_YN   = CASE WHEN lsRepCardYn = 'Y' THEN 'N' ELSE 'N' END 
            ,  UPD_DT        = SYSDATE 
            ,  UPD_USER      = CASE WHEN PSV_CHANNEL = '1' THEN 'POS USER' 
                                    WHEN PSV_CHANNEL = '2' THEN 'WEB USER' 
                                    WHEN PSV_CHANNEL = '3' THEN 'APP USER' 
                                    ELSE                        'ADMIN' 
                               END      
       WHERE   COMP_CD       = PSV_COMP_CD 
         AND   CARD_ID       = PSV_CARD_ID_SEND; 
          
        
       IF nRecCnt > 0 AND lsRepCardYn = 'Y' THEN  
            UPDATE  C_CARD 
            SET     REP_CARD_YN = 'Y' 
            WHERE   COMP_CD = PSV_COMP_CD 
            AND     CARD_ID = ( 
                                SELECT  CARD_ID 
                                FROM   ( 
                                        SELECT  CARD_ID 
                                             ,  ROW_NUMBER() OVER(PARTITION BY CUST_ID ORDER BY ISSUE_DT DESC) R_NUM 
                                        FROM    C_CARD 
                                        WHERE   COMP_CD  = PSV_COMP_CD 
                                        AND     CUST_ID  = lsCustId 
                                        AND     CARD_ID != PSV_CARD_ID_SEND 
                                        AND     CARD_STAT IN ('00', '10') 
                                        AND     USE_YN   = 'Y' 
                                       ) 
                               WHERE    R_NUM = 1 
                              ); 
        END IF;  
    END IF; 
     
    OPEN asResult FOR  -- 멤버십 카드 충전 결과 
    SELECT SAV_CASH - USE_CASH AS CUR_CASH_PNT 
      FROM C_CARD 
     WHERE COMP_CD = PSV_COMP_CD 
       AND CARD_ID = CASE WHEN PSV_CRG_FG = '3' THEN PSV_CARD_ID_SEND ELSE PSV_CARD_ID_RECV END 
       AND USE_YN  = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
        
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN ERR_HANDLER THEN 
        OPEN asResult FOR 
            SELECT  0  
            FROM    DUAL; 
             
        ROLLBACK; 
        RETURN; 
    WHEN OTHERS THEN 
        OPEN asResult FOR 
            SELECT 0 
            FROM   DUAL; 
              
        asRetVal := '2001'; 
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- 오류가 발생하였습니다. 
         
        ROLLBACK;  
        RETURN; 
  END SET_MEMB_CHG_30; 
 
  ------------------------------------------------------------------------------ 
  --  Package Name     : SET_MEMB_CHG_40 
  --  Description      : 멤버십 환불 - 전체 
  --  Ref. Table       : C_CARD            멤버십카드 마스터 
  --                     C_CUST            회원 마스터 
  --                     C_CARD_CHARGE_HIS 멤버십카드 충전이력 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE SET_MEMB_CHG_40 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_CUST_ID           IN   VARCHAR2, -- 3. 고객번호 
    PSV_CRG_DT            IN   VARCHAR2, -- 4. 결제일자 
    PSV_CRG_FG            IN   VARCHAR2, -- 5. 결제구분[3:환불] 
    PSV_CRG_DIV           IN   VARCHAR2, -- 6. 결제방법[9:조정] 
    PSV_CRG_AMT           IN   VARCHAR2, -- 7. 결제금액 
    PSV_ACC_USER_NM       IN   VARCHAR2, -- 8. 예금주명 
    PSV_ACC_BANK          IN   VARCHAR2, -- 9.은행코드 
    PSV_ACC_NUM           IN   VARCHAR2, -- 10.계좌번호 
    PSV_CHANNEL           IN   VARCHAR2, -- 11.경로구분[1:POS, 2:WEB, 3:MOBILE, 9:관리자] 
    asRetVal              OUT  VARCHAR2, -- 12.결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 13.결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
    CURSOR CUR_1 IS 
        SELECT  CST.COMP_CD 
              , CST.CUST_ID 
              , CST.CUST_STAT 
              , CST.SAV_CASH AS CUST_SAV_CASH 
              , CST.USE_CASH AS CUST_USE_CASH 
              , CRD.CARD_ID 
              , CRD.CARD_STAT 
              , CRD.SAV_CASH AS CARD_SAV_CASH 
              , CRD.USE_CASH AS CARD_USE_CASH 
              , CRD.ISSUE_DIV 
          FROM  C_CARD CRD-- 멤버십카드 마스터 
              , C_CUST CST-- 멤버십고객 마스터 
         WHERE  CRD.COMP_CD = CST.COMP_CD 
           AND  CRD.CUST_ID = CST.CUST_ID 
           AND  CST.COMP_CD = PSV_COMP_CD 
           AND  CST.CUST_ID = PSV_CUST_ID 
           AND  CST.USE_YN  = 'Y'    -- 고객사용여부[Y:사용, N:사용안함] 
           AND  CRD.USE_YN  = 'Y'    -- 카드사용여부[Y:사용, N:사용안함] 
           AND  CRD.CARD_STAT NOT IN ('81', '91', '92', '99');   
     
    lscard_div      C_CARD.CARD_DIV%TYPE;                   -- 카드관리범위[1:회사, 2:영업조직, 3:점포] 
    lsbrand_cd      C_CARD.BRAND_CD%TYPE;                   -- 영업조직 
    lsstor_cd       C_CARD.STOR_CD%TYPE;                    -- 점포코드 
    nRecCnt         NUMBER(7) := 0; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000' ; 
    asRetMsg    := ''   ; 
     
    IF PSV_CRG_FG != '3' THEN -- 결제구분[3:환불, 4:이전] 
       asRetVal := '1000'; 
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001411'); -- 결제구분 입력 오류 입니다. 
        
       RAISE ERR_HANDLER; 
    END IF; 
     
    IF PSV_CRG_FG =  '3' THEN -- 결제구분[3:환불] 
       IF PSV_ACC_USER_NM IS NULL OR PSV_ACC_BANK IS NULL OR PSV_ACC_NUM IS NULL THEN 
          asRetVal := '1001'; 
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001413'); -- 환불시 은행코드. 예금주, 계좌번호는 필수 입력항목입니다. 
           
          RAISE ERR_HANDLER; 
       END IF; 
    END IF; 
      
    -- 카드별 체크 체크 
    FOR MYREC IN CUR_1 LOOP 
        -- 처리건수 체크 
        nRecCnt := nRecCnt + 1; 
         
        --환불 금액 체크 
        IF ((MYREC.CUST_USE_CASH / MYREC.CUST_SAV_CASH * 100) < 60 ) THEN 
            asRetVal := '1004'; 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001427'); -- 충전금액의 60%이상 사용 시 환불이 가능합니다. 
                 
            RAISE ERR_HANDLER; 
        END IF; 
         
        -- 잔액 체크 
        IF (ABS(TO_NUMBER(PSV_CRG_AMT)) != (MYREC.CUST_SAV_CASH - MYREC.CUST_USE_CASH)) THEN 
            asRetVal := '1005'; 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001426'); -- 환불금액이 잔액과 일치하지 않습니다. 
               
            RAISE ERR_HANDLER; 
        END IF; 
        
        -- 2015/02/10 분신된 카드는 충전, 취소, 조정 불가 
        CASE WHEN MYREC.CARD_STAT = '92' THEN -- 환불 
                 asRetVal := '1006'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001414'); -- 환불된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            WHEN MYREC.CARD_STAT = '81' THEN -- 해지신청 
                 asRetVal := '1007'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001558'); -- 해지 신청된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            WHEN MYREC.CARD_STAT = '91' THEN -- 해지 
                 asRetVal := '1007'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001397'); -- 해지된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            WHEN MYREC.CARD_STAT = '99' THEN -- 폐기 
                 asRetVal := '1008'; 
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001398'); -- 폐기된 카드번호 입니다. 
                  
                 RAISE ERR_HANDLER; 
            ELSE 
                 asRetVal := '0000'; 
        END CASE; 
        
        BEGIN 
            SELECT CP.CARD_DIV, BM.BRAND_CD, '0000000'  
              INTO lscard_div , lsbrand_cd , lsstor_cd 
              FROM COMPANY_PARA CP 
                 , BRAND_MEMB   BM 
             WHERE CP.COMP_CD  = BM.COMP_CD 
               AND BM.COMP_CD  = PSV_COMP_CD 
               AND BM.BRAND_CD = ( 
                                  SELECT TSMS_BRAND_CD 
                                    FROM C_CARD_TYPE     CCT 
                                       , C_CARD_TYPE_REP CTR  
                                   WHERE CCT.COMP_CD   = CTR.COMP_CD 
                                     AND CCT.CARD_TYPE = CTR.CARD_TYPE 
                                     AND CTR.COMP_CD   = PSV_COMP_CD 
                                     AND decrypt(MYREC.CARD_ID) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD) 
                                     AND ROWNUM        = 1 
                                 ) 
               AND USE_YN      = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
        EXCEPTION 
            WHEN OTHERS THEN  
                lscard_div := '1'; 
                lsbrand_cd := '0000'; 
                lsstor_cd  := '0000000'; 
        END; 
        
        -- 환불 이력 작성 
        INSERT INTO C_CARD_CHARGE_HIS 
        ( 
            COMP_CD     ,       CARD_ID     , 
            CRG_DT      , 
            CRG_SEQ     , 
            CRG_FG      ,       CRG_DIV     , 
            CRG_AMT     ,        
            CHANNEL     , 
            BRAND_CD    ,       STOR_CD     , 
            REMARKS     , 
            TRN_CARD_ID , 
            POS_NO      , 
            CARD_NO     ,       CARD_NM     , 
            APPR_DT     ,       APPR_TM     , 
            APPR_VD_CD  ,       APPR_VD_NM  , 
            APPR_IS_CD  ,       APPR_COM    , 
            ALLOT_LMT   , 
            READ_DIV    ,       APPR_DIV    , 
            APPR_NO     , 
            ORG_CRG_DT  ,       ORG_CRG_SEQ , 
            STAMP_TAX   ,       USE_YN      , 
            SAP_IF_YN   ,       SAP_IF_DT   , 
            CRG_SCOPE   ,       CRG_AUTO_DIV, 
            DC_AMT      ,       SELF_CRG_YN , 
            DST_CRG_DT  ,       DST_CRG_SEQ , 
            ORG_CHANNEL , 
            INST_DT     ,       INST_USER   , 
            UPD_DT      ,       UPD_USER 
        ) 
        VALUES 
        ( 
            PSV_COMP_CD ,       MYREC.CARD_ID, 
            PSV_CRG_DT  , 
            SQ_PCRM_SEQ.NEXTVAL             , 
            PSV_CRG_FG  ,       PSV_CRG_DIV , 
            (MYREC.CARD_SAV_CASH - MYREC.CARD_USE_CASH) * (-1),  
            PSV_CHANNEL , 
            lsbrand_cd  ,       lsstor_cd   , 
            GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP), 
            NULL        , 
            NULL        , 
            NULL        ,     NULL  , 
            NULL        ,     NULL  , 
            NULL        ,     NULL  , 
            NULL        ,     NULL  , 
            NULL        , 
            NULL        ,     NULL  , 
            NULL        , 
            NULL        ,     NULL  , 
            0           ,     'Y'   , 
            'N'         ,     NULL  , 
            '1'         ,     '1'   , -- 개별충전, 자동충전여부 
            0           ,     'N'   , -- 할인금액, 셀프충전여부 
            NULL        ,     0     , -- 멀티충전일, 멀티충전일련번호 
            PSV_CHANNEL ,   
            SYSDATE     ,     'SYS' , 
            SYSDATE     ,     'SYS' 
        ); 
         
        -- 은행정보 SET 
        UPDATE C_CARD 
           SET CARD_STAT     = '92' 
             , REFUND_REQ_DT = PSV_CRG_DT 
             , BANK_CD       = PSV_ACC_BANK 
             , ACC_NO        = PSV_ACC_NUM 
             , BANK_USER_NM  = PSV_ACC_USER_NM 
             , REFUND_STAT   = '01' 
             , REFUND_CASH   = TO_NUMBER(PSV_CRG_AMT) 
             , REFUND_CD     = NULL 
             , REFUND_MSG    = NULL   
        WHERE COMP_CD        = PSV_COMP_CD 
          AND CARD_ID        = MYREC.CARD_ID; 
    END LOOP; 
     
    --처리건수 체크 
    IF nRecCnt = 0 THEN 
       asRetVal := '1020'; 
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1001000269'); -- 처리할 데이타가 없습니다. 
         
       RAISE ERR_HANDLER; 
    END IF; 
     
    OPEN asResult FOR  -- 멤버십 카드 환불 결과 
    SELECT SAV_CASH - USE_CASH AS CUR_CASH_PNT 
      FROM C_CUST 
     WHERE COMP_CD = PSV_COMP_CD 
       AND CUST_ID = PSV_CUST_ID 
       AND USE_YN  = 'Y'; -- 사용여부[Y:사용, N:사용안함] 
        
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다. 
     
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
             
        asRetVal := '2001'; 
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- 오류가 발생하였습니다. 
         
        ROLLBACK;  
        RETURN; 
  END SET_MEMB_CHG_40; 
       
  ------------------------------------------------------------------------------ 
  --  Package Name     : GET_MEMB_CUPN_10 
  --  Description      : POS 멤버십 쿠폰인증 조회 > POS에서만 가능 
  --  Ref. Table       : C_COUPON_MST  모바일쿠폰 마스터 
  --                     C_COUPON_CUST 모바일쿠폰 대상회원 
  --                     C_CARD        멤버십카드 마스터 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE GET_MEMB_CUPN_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_CERT_DIV          IN   VARCHAR2, -- 3. 인증구분[1:카드번호, 2: 인증번호] 
    PSV_CERT_VAL          IN   VARCHAR2, -- 4. 인증값 
    asRetVal              OUT  VARCHAR2, -- 5. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 6. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
   
    lsCouponCd      C_COUPON_CUST.COUPON_CD%TYPE := NULL;   -- 쿠폰번호 
    lsStat          VARCHAR2(  1)   := NULL; 
    lsUseStat       C_COUPON_CUST.USE_STAT%TYPE  := NULL;   -- 사용상태[00:대기, 01:요청, 10:판매, 11:반품, 30:분실, 31:도난, 32:일반폐기, 33:유효기간만료, 34:탈퇴폐기, 99:에러] 
    lsUseStatNm     VARCHAR2(200)   := NULL; 
    lsCertYn        VARCHAR2(  1)   := NULL; 
    lsCertFdt       VARCHAR2(  8)   := NULL; 
    lsCertTdt       VARCHAR2(  8)   := NULL; 
     
    nRecCnt         NUMBER(7)       := 0; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000'; 
    asRetMsg    := ''; 
     
    IF PSV_CERT_DIV = '2' THEN -- 인증번호 
       BEGIN 
         SELECT CCM.COUPON_CD 
              , CCM.COUPON_STAT 
              , CCC.USE_STAT 
              , CCM.CERT_YN 
              , CCC.CERT_FDT 
              , CCC.CERT_TDT 
              , GET_COMMON_CODE_NM('01615', CCC.USE_STAT, PSV_LANG_TP) USE_STAT_NM 
           INTO lsCouponCd, lsStat, lsUseStat, lsCertYn, lsCertFdt, lsCertTdt, lsUseStatNm 
           FROM C_COUPON_MST   CCM -- 모바일쿠폰 마스터 
              , C_COUPON_CUST  CCC -- 모바일쿠폰 대상회원 
          WHERE CCM.COMP_CD     = CCC.COMP_CD 
            AND CCM.COUPON_CD   = CCC.COUPON_CD 
            AND CCC.COMP_CD     = PSV_COMP_CD 
            AND CCM.COUPON_STAT = '2'    -- 쿠폰상태[1:계획, 2:확정, 3:확정취소] 
            AND CCM.USE_YN      = 'Y'    -- 사용여부[Y:사용, N:사용안함] 
            AND CCC.USE_YN      = 'Y'    -- 사용여부[Y:사용, N:사용안함] 
            AND CCC.CERT_NO     = PSV_CERT_VAL; 
             
         IF lsCertYn = 'N' THEN -- 인증여부[Y:인증, N:인증안함] 
            asRetVal := '1001'; 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001372'); -- 인증대상 할인이 아닙니다. 
             
            OPEN asResult FOR 
            SELECT 1024 AS RTNCODE 
              FROM DUAL; 
               
            RETURN; 
         ELSE 
            IF lsUseStat IN ('10','30','31','32','33','34','99') THEN -- 10:판매, 30:분실, 31:도난, 32:일반폐기, 33:유효기간 만료, 32:탈퇴폐기, 99:에러 
               asRetVal := '10'||lsUseStat; 
               asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001361')||' ['||lsUseStatNm||']'; -- 사용 가능한 상태의 인증번호가 아닙니다. 
                
               OPEN asResult FOR 
               SELECT 1024 AS RTNCODE 
                 FROM DUAL; 
                  
               RETURN; 
            END IF; 
             
            IF (TO_CHAR(SYSDATE, 'YYYYMMDD') >= lsCertFdt AND TO_CHAR(SYSDATE, 'YYYYMMDD') <= lsCertTdt) THEN -- 유효기간 체크 
               asRetVal := '0000'; 
            ELSE 
               asRetVal := '1033'; 
               asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001364')||'[ '||TO_CHAR(TO_DATE(lsCertTdt, 'YYYYMMDD'), 'YYYY-MM-DD')||' ]'; -- 사용기간이 지난 인증번호입니다. 
                
               -- 유효기간이 만료된 쿠폰 상태변경 
               BEGIN 
                 UPDATE C_COUPON_CUST 
                    SET USE_STAT  = '33' -- 유효기간만료 
                  WHERE COMP_CD   = PSV_COMP_CD 
                    AND CERT_NO   = PSV_CERT_VAL; 
               EXCEPTION 
                 WHEN OTHERS THEN  
                      ROLLBACK; 
               END; 
                
               OPEN asResult FOR 
               SELECT 1024 AS RTNCODE 
                 FROM DUAL; 
                  
               RETURN; 
            END IF; 
         END IF; 
       EXCEPTION 
         WHEN OTHERS THEN 
              asRetVal := '2000'; 
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001359'); -- 존재하지 않는 인증번호입니다. 
               
              OPEN asResult FOR 
              SELECT 1024 AS RTNCODE 
                FROM DUAL;  
                 
              RETURN; 
       END; 
        
       OPEN asResult FOR 
       SELECT CCC.CUST_ID 
            , CCM.COUPON_CD  
            , CCM.COUPON_NM 
            , CCC.CERT_NO 
            , CCM.DC_DIV 
            , CCC.GRP_SEQ 
            , CCC.PRT_LVL_CD 
            , CCM.CERT_YN 
            , CCM.START_DT 
            , CCM.CLOSE_DT 
            , CCM.COUPON_MSG 
            , CCC.CERT_TDT
            , CASE WHEN CST.CUST_STAT IN ('3','7') THEN '1' ELSE '0' END MEMB_DIV
         FROM C_COUPON_MST   CCM -- 모바일쿠폰 마스터 
            , C_COUPON_CUST  CCC -- 모바일쿠폰 대상회원
            , C_CUST         CST 
        WHERE CST.COMP_CD     = CCC.COMP_CD
          AND CST.CUST_ID     = CCC.CUST_ID  
          AND CCM.COMP_CD     = CCC.COMP_CD 
          AND CCM.COUPON_CD   = CCC.COUPON_CD 
          AND CCC.COMP_CD     = PSV_COMP_CD 
          AND CCM.COUPON_STAT = '2'   -- 쿠폰상태[1:계획, 2:확정, 3:확정취소] 
          AND CCM.USE_YN      = 'Y'   -- 사용여부[Y:사용, N:사용안함] 
          AND CCC.USE_YN      = 'Y'    -- 사용여부[Y:사용, N:사용안함] 
          AND CCC.CERT_NO     = PSV_CERT_VAL; 
    ELSE -- 카드번호 
       BEGIN 
         SELECT COUNT(*) 
           INTO nRecCnt 
           FROM ( 
                 SELECT CCC.CUST_ID 
                      , CCM.COUPON_CD  
                      , CCM.COUPON_NM 
                      , CCC.CERT_NO 
                      , CCM.DC_DIV 
                      , CCC.GRP_SEQ 
                      , CCC.PRT_LVL_CD 
                      , CCM.CERT_YN 
                      , CCM.START_DT 
                      , CCM.CLOSE_DT 
                      , CCM.COUPON_MSG
                      , CRD.MEMB_DIV
                   FROM C_COUPON_MST   CCM 
                      , C_COUPON_CUST  CCC 
                      , C_CARD         CRD 
                  WHERE CCM.COMP_CD     = CCC.COMP_CD 
                    AND CCM.COUPON_CD   = CCC.COUPON_CD 
                    AND CRD.COMP_CD     = CCC.COMP_CD 
                    AND CRD.CUST_ID     = CCC.CUST_ID 
                    AND CRD.COMP_CD     = PSV_COMP_CD 
                    AND CRD.CARD_ID     = PSV_CERT_VAL 
                    AND CRD.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
                    AND CCM.COUPON_STAT = '2' -- 쿠폰상태[1:계획, 2:확정, 3:확정취소] 
                    AND CCM.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
                    AND CCC.USE_YN      = 'Y'    -- 사용여부[Y:사용, N:사용안함] 
                    AND CCC.USE_STAT NOT IN ('10','30','31','32','33','34','99') -- 10:판매, 30:분실, 31:도난, 32:일반폐기, 33:유효기간 만료, 34:탈퇴폐기,99:에러 
                    AND TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN CCC.CERT_FDT AND CCC.CERT_TDT
                    AND NOT EXISTS (
                                    SELECT  1
                                    FROM    C_COUPON_CUST_GIFT GIF
                                    WHERE   GIF.COMP_CD   = CCC.COMP_CD
                                    AND     GIF.COUPON_CD = CCC.COUPON_CD
                                    AND     GIF.CERT_NO   = CCC.CERT_NO
                                   )
                 UNION ALL 
                 SELECT CST.CUST_ID 
                      , CCM.COUPON_CD  
                      , CCM.COUPON_NM 
                      , NULL CERT_NO 
                      , CCM.DC_DIV 
                      , CCI.GRP_SEQ 
                      , CCI.LVL_CD 
                      , CCM.CERT_YN 
                      , CCM.START_DT 
                      , CCM.CLOSE_DT 
                      , CCM.COUPON_MSG 
                      , CASE WHEN CST.CUST_STAT IN ('3','7') THEN '1' ELSE '0' END MEMB_DIV
                   FROM C_COUPON_MST       CCM 
                      , C_COUPON_ITEM_GRP  CCI 
                      , C_CARD             CRD 
                      , C_CUST             CST 
                  WHERE CRD.COMP_CD     = CST.COMP_CD 
                    AND CRD.CUST_ID     = CST.CUST_ID 
                    AND CST.COMP_CD     = CCI.COMP_CD 
                    AND CST.LVL_CD      = CCI.LVL_CD 
                    AND CCI.COMP_CD     = CCM.COMP_CD 
                    AND CCI.COUPON_CD   = CCM.COUPON_CD 
                    AND CRD.COMP_CD     = PSV_COMP_CD 
                    AND CRD.CARD_ID     = PSV_CERT_VAL 
                    AND CRD.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
                    AND CCM.COUPON_STAT = '2' -- 쿠폰상태[1:계획, 2:확정, 3:확정취소] 
                    AND CCM.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
                    AND CCM.CERT_YN     = 'N' 
                    AND TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN CCM.START_DT AND CCM.CLOSE_DT 
                ); 
             
         IF nRecCnt = 0 THEN 
            asRetVal := '3001'; 
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001359'); -- 사용 가능한 인증번호가 존재하지 않습니다. 
             
            OPEN asResult FOR 
            SELECT 1024 AS RTNCODE 
              FROM DUAL;  
               
            RETURN; 
         END IF; 
          
         OPEN asResult FOR 
         SELECT CCC.CUST_ID 
              , CCM.COUPON_CD  
              , CCM.COUPON_NM 
              , CCC.CERT_NO 
              , CCM.DC_DIV 
              , CCC.GRP_SEQ 
              , CCC.PRT_LVL_CD 
              , CCM.CERT_YN 
              , CCM.START_DT 
              , CCM.CLOSE_DT 
              , CCM.COUPON_MSG 
              , CCC.CERT_TDT
              , CRD.MEMB_DIV 
           FROM C_COUPON_MST   CCM 
              , C_COUPON_CUST  CCC 
              , C_CARD         CRD 
          WHERE CCM.COMP_CD     = CCC.COMP_CD 
            AND CCM.COUPON_CD   = CCC.COUPON_CD 
            AND CRD.COMP_CD     = CCC.COMP_CD 
            AND CRD.CUST_ID     = CCC.CUST_ID 
            AND CRD.COMP_CD     = PSV_COMP_CD 
            AND CRD.CARD_ID     = PSV_CERT_VAL 
            AND CRD.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
            AND CCM.COUPON_STAT = '2' -- 쿠폰상태[1:계획, 2:확정, 3:확정취소] 
            AND CCM.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
            AND CCC.USE_YN      = 'Y'    -- 사용여부[Y:사용, N:사용안함] 
            AND CCC.USE_STAT NOT IN ('10','30','31','32','33','34','99') -- 10:판매, 30:분실, 31:도난, 32:폐기, 33:유효기간 만료, 99:에러 
            AND TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN CCC.CERT_FDT AND CCC.CERT_TDT
            AND NOT EXISTS (
                            SELECT  1
                            FROM    C_COUPON_CUST_GIFT GIF
                            WHERE   GIF.COMP_CD   = CCC.COMP_CD
                            AND     GIF.COUPON_CD = CCC.COUPON_CD
                            AND     GIF.CERT_NO   = CCC.CERT_NO
                           ) 
         UNION ALL 
         SELECT CST.CUST_ID 
              , CCM.COUPON_CD  
              , CCM.COUPON_NM 
              , NULL CERT_NO 
              , CCM.DC_DIV 
              , CCI.GRP_SEQ 
              , CCI.LVL_CD 
              , CCM.CERT_YN 
              , CCM.START_DT 
              , CCM.CLOSE_DT 
              , CCM.COUPON_MSG 
              , CCM.CLOSE_DT 
              , CASE WHEN CST.CUST_STAT IN ('3','7') THEN '1' ELSE '0' END MEMB_DIV
           FROM C_COUPON_MST       CCM 
              , C_COUPON_ITEM_GRP  CCI 
              , C_CARD             CRD 
              , C_CUST             CST 
          WHERE CRD.COMP_CD     = CST.COMP_CD 
            AND CRD.CUST_ID     = CST.CUST_ID 
            AND CST.COMP_CD     = CCI.COMP_CD 
            AND CST.LVL_CD      = CCI.LVL_CD 
            AND CCI.COMP_CD     = CCM.COMP_CD 
            AND CCI.COUPON_CD   = CCM.COUPON_CD 
            AND CRD.COMP_CD     = PSV_COMP_CD 
            AND CRD.CARD_ID     = PSV_CERT_VAL 
            AND CRD.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
            AND CCM.COUPON_STAT = '2' -- 쿠폰상태[1:계획, 2:확정, 3:확정취소] 
            AND CCM.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함] 
            AND CCM.CERT_YN     = 'N' 
            AND TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN CCM.START_DT AND CCM.CLOSE_DT; 
       EXCEPTION 
         WHEN OTHERS THEN 
              asRetVal := '4000'; 
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001359'); -- 사용 가능한 인증번호가 존재하지 않습니다. 
               
              OPEN asResult FOR 
              SELECT 1024 AS RTNCODE 
                FROM DUAL;  
                 
              RETURN; 
       END; 
    END IF; 
     
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상 처리되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN OTHERS THEN 
         asRetVal := '3001'; 
         asRetMsg := SQLERRM; 
          
         OPEN asResult FOR 
         SELECT 1024 AS RTNCODE 
           FROM DUAL; 
            
        RETURN; 
  END GET_MEMB_CUPN_10; 
   
  ------------------------------------------------------------------------------ 
  --  Package Name     : GET_MEMB_CUPN_20 
  --  Description      : POS 멤버십 쿠폰 취소가능 여부조회 > POS에서만 가능 
  --  Ref. Table       : C_COUPON_MST  모바일쿠폰 마스터 
  --                     C_COUPON_CUST 모바일쿠폰 대상회원 
  --                     C_CARD        멤버십카드 마스터 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
    PROCEDURE GET_MEMB_CUPN_20 
   ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_SALE_DT           IN   VARCHAR2, -- 3. 판매일자 
    PSV_BRAND_CD          IN   VARCHAR2, -- 4 브랜드코드 
    PSV_STOR_CD           IN   VARCHAR2, -- 5. 매장코드 
    PSV_POS_NO            IN   VARCHAR2, -- 6. 포스번호 
    PSV_BILL_NO           IN   VARCHAR2, -- 7. 영수증번호 
    asRetVal              OUT  VARCHAR2, -- 8. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 9. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
   ) IS 
    lsCouponCd      C_COUPON_CUST.COUPON_CD%TYPE := NULL;   -- 쿠폰번호 
    lsStat          VARCHAR2(  1)   := NULL; 
    lsUseStat       C_COUPON_CUST.USE_STAT%TYPE  := NULL;   -- 사용상태[00:대기, 01:요청, 10:판매, 11:반품, 30:분실, 31:도난, 32:폐기, 33:유효기간만료, 99:에러] 
    lsUseStatNm     VARCHAR2(200)   := NULL; 
    lsCertYn        VARCHAR2(  1)   := NULL; 
    lsCertFdt       VARCHAR2(  8)   := NULL; 
    lsCertTdt       VARCHAR2(  8)   := NULL; 
     
    nRecCnt         NUMBER(7)       := 0; 
    nREMMLG         C_CARD_SAV_HIS.SAV_MLG%TYPE := 0;
    nSAVMLG         C_CARD_SAV_HIS.SAV_MLG%TYPE := 0;
    
    ERR_HANDLER     EXCEPTION; 
     
    BEGIN 
        asRetVal    := '0000'; 
        asRetMsg    := ''; 
        
        -- 영수증 존재여부 체크
        SELECT  COUNT(*) INTO nRecCnt 
        FROM    C_COUPON_CUST  CC1 -- 모바일쿠폰 대상회원 
        WHERE   CC1.COMP_CD     = PSV_COMP_CD 
        AND     CC1.PRT_SALE_DT = PSV_SALE_DT 
        AND     CC1.PRT_BRAND_CD= PSV_BRAND_CD 
        AND     CC1.PRT_STOR_CD = PSV_STOR_CD 
        AND    (PSV_POS_NO  IS NULL OR CC1.PRT_POS_NO  = PSV_POS_NO) 
        AND    (PSV_BILL_NO IS NULL OR CC1.PRT_BILL_NO = PSV_BILL_NO); 
        
        -- 사용가능크라운 수, 적립취소대상 크라운 수
        SELECT  NVL(SUM(CUH.SAV_MLG - CUH.USE_MLG - CUH.LOS_MLG_UNUSE), 0), NVL(MAX(CST.SAV_MLG), 0)
        INTO    nREMMLG, nSAVMLG
        FROM    C_CARD_SAV_USE_HIS CUH
              , C_CARD             CRD
              ,(
                SELECT  CRD.COMP_CD
                      , CRD.CUST_ID
                      , CSH.SAV_MLG
                FROM    C_CARD          CRD
                      , C_CARD_SAV_HIS  CSH
                WHERE   CRD.COMP_CD  = CSH.COMP_CD
                AND     CRD.CARD_ID  = CSH.CARD_ID
                AND     CSH.COMP_CD  = PSV_COMP_CD
                AND     CSH.USE_DT   = PSV_SALE_DT
                AND     CSH.BRAND_CD = PSV_BRAND_CD
                AND     CSH.STOR_CD  = PSV_STOR_CD
                AND     CSH.POS_NO   = PSV_POS_NO
                AND     CSH.BILL_NO  = PSV_BILL_NO
               ) CST
        WHERE   CST.COMP_CD = CRD.COMP_CD
        AND     CST.CUST_ID = CRD.CUST_ID
        AND     CRD.COMP_CD = CUH.COMP_CD
        AND     CRD.CARD_ID = CUH.CARD_ID
        AND     CUH.LOS_MLG_YN = 'N';
           
    IF nRecCnt = 0 THEN 
        OPEN asResult FOR 
            SELECT PSV_SALE_DT 
                 , PSV_BRAND_CD 
                 , PSV_STOR_CD 
                 , PSV_POS_NO 
                 , PSV_BILL_NO 
                 , CASE WHEN nRecCnt = 0  AND nREMMLG >= nSAVMLG THEN 'Y' ELSE 'N' END  VOID_YN 
              FROM DUAL;
    ELSE
        -- 인증번호 
        OPEN asResult FOR 
            SELECT CC1.PRT_SALE_DT 
                 , CC1.PRT_BRAND_CD 
                 , CC1.PRT_STOR_CD 
                 , CC1.PRT_POS_NO 
                 , CC1.PRT_BILL_NO 
                 , CASE WHEN SUM(CASE WHEN CC1.USE_STAT = '10' THEN 1 ELSE 0 END) = 0 AND nREMMLG >= nSAVMLG THEN 'Y' ELSE 'N' END VOID_YN 
              FROM C_COUPON_CUST  CC1 -- 모바일쿠폰 대상회원 
             WHERE CC1.COMP_CD     = PSV_COMP_CD 
               AND CC1.PRT_SALE_DT = PSV_SALE_DT 
               AND CC1.PRT_BRAND_CD= PSV_BRAND_CD 
               AND CC1.PRT_STOR_CD = PSV_STOR_CD 
               AND(PSV_POS_NO  IS NULL OR CC1.PRT_POS_NO  = PSV_POS_NO) 
               AND(PSV_BILL_NO IS NULL OR CC1.PRT_BILL_NO = PSV_BILL_NO)
             GROUP BY 
                   CC1.PRT_SALE_DT 
                 , CC1.PRT_BRAND_CD 
                 , CC1.PRT_STOR_CD 
                 , CC1.PRT_POS_NO 
                 , CC1.PRT_BILL_NO;     
    END IF; 
         
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상 처리되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN OTHERS THEN 
         asRetVal := '3001'; 
         asRetMsg := SQLERRM; 
          
         OPEN asResult FOR 
         SELECT 1024 AS RTNCODE 
           FROM DUAL; 
            
        RETURN; 
  END GET_MEMB_CUPN_20; 
     
  ------------------------------------------------------------------------------ 
  --  Package Name     : SET_MEMB_CUPN_10 
  --  Description      : POS 멤버십 쿠폰 사용/취소 > POS에서만 가능 
  --  Ref. Table       : C_COUPON_MST  모바일쿠폰 마스터 
  --                     C_COUPON_CUST 모바일쿠폰 대상회원 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE SET_MEMB_CUPN_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_COUPON_CD         IN   VARCHAR2, -- 3. 쿠폰번호 
    PSV_CERT_NO           IN   VARCHAR2, -- 4. 인증번호 
    PSV_SALE_DIV          IN   VARCHAR2, -- 6. 판매구분[1:판매, 2:반품] 
    PSV_USE_DT            IN   VARCHAR2, -- 7. 사용일자 
    PSV_USE_TM            IN   VARCHAR2, -- 8. 사용시각 
    PSV_BRAND_CD          IN   VARCHAR2, -- 9. 영업조직 
    PSV_STOR_CD           IN   VARCHAR2, -- 10. 점포코드 
    PSV_POS_NO            IN   VARCHAR2, -- 11. 포스번호 
    PSV_BILL_NO           IN   VARCHAR2, -- 12. 영수증번호 
    asRetVal              OUT  VARCHAR2, -- 14. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 15. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
    lsCustStat      C_CUST.CUST_STAT%TYPE        := NULL;   -- 고객상태
    lsCustId        C_COUPON_CUST.CUST_ID%TYPE   := NULL;   -- 고객ID
    lsCouponCd      C_COUPON_CUST.COUPON_CD%TYPE := NULL;   -- 쿠폰번호 
    lsStat          VARCHAR2(  1)   := NULL; 
    lsUseStat       C_COUPON_CUST.USE_STAT%TYPE  := NULL;   -- 사용상태[00:대기, 01:요청, 10:판매, 11:반품, 30:분실, 31:도난, 32:폐기, 33:유효기간만료, 99:에러] 
    lsUseStatNm     VARCHAR2(200)   := NULL; 
    lsCertYn        VARCHAR2(  1)   := NULL; 
    lsCertFdt       VARCHAR2(  8)   := NULL; 
    lsCertTdt       VARCHAR2(  8)   := NULL; 
     
    nRecCnt         NUMBER(7)       := 0; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000' ; 
    asRetMsg    := ''   ; 
     
    BEGIN 
      SELECT CCM.COUPON_CD  
           , CCM.COUPON_STAT 
           , CCC.USE_STAT 
           , CCM.CERT_YN 
           , CCC.CERT_FDT 
           , CCC.CERT_TDT 
           , GET_COMMON_CODE_NM('01615', CCC.USE_STAT, PSV_LANG_TP) USE_STAT_NM
           , CCC.CUST_ID 
        INTO lsCouponCd, lsStat, lsUseStat, lsCertYn, lsCertFdt, lsCertTdt, lsUseStatNm, lsCustId
        FROM C_COUPON_MST    CCM -- 모바일쿠폰 마스터 
           , C_COUPON_CUST   CCC -- 모바일쿠폰 대상회원 
       WHERE CCM.COMP_CD     = CCC.COMP_CD 
         AND CCM.COUPON_CD   = CCC.COUPON_CD 
         AND CCC.COMP_CD     = PSV_COMP_CD 
         AND CCM.COUPON_STAT = '2'    -- 쿠폰상태[1:계획, 2:확정, 3:확정취소] 
         AND CCM.USE_YN      = 'Y'    -- 사용여부[Y:사용, N:사용안함] 
         AND CCC.CERT_NO     = PSV_CERT_NO; 
          
      IF lsCertYn = 'N' THEN -- 인증여부[Y:인증, N:인증안함] 
         asRetVal := '1001'; 
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001372'); -- 인증대상 할인이 아닙니다. 
          
         OPEN asResult FOR 
         SELECT 1024 AS RTNCODE 
           FROM DUAL; 
            
         RETURN; 
      ELSE 
         IF PSV_SALE_DIV = '1' THEN -- 판매 
            IF lsUseStat IN ('10','30','31','32','33','34','99') THEN -- 10:판매, 30:분실, 31:도난, 32:일반폐기, 33:유효기간 만료, 34:탈퇴폐기, 99:에러 
               asRetVal := '10'||lsUseStat; 
               asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001361')||' ['||lsUseStatNm||']'; -- 사용 가능한 상태의 인증번호가 아닙니다. 
                
               OPEN asResult FOR 
               SELECT 1024 AS RTNCODE 
                 FROM DUAL; 
                  
               RETURN; 
            END IF; 
             
            IF (TO_CHAR(SYSDATE, 'YYYYMMDD') >= lsCertFdt AND TO_CHAR(SYSDATE, 'YYYYMMDD') <= lsCertTdt) THEN -- 유효기간 체크 
               asRetVal := '0000'; 
            ELSE 
               asRetVal := '1033'; 
               asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001364')||'[ '||TO_CHAR(TO_DATE(lsCertTdt, 'YYYYMMDD'), 'YYYY-MM-DD')||' ]'; -- 사용기간이 지난 인증번호입니다. 
                
               -- 유효기간이 만료된 쿠폰 상태변경 
               BEGIN 
                 UPDATE C_COUPON_CUST 
                    SET USE_STAT  = '33' -- 유효기간만료 
                      , USE_DT    = TO_CHAR(SYSDATE, 'YYYYMMDD') 
                      , UPD_DT    = SYSDATE 
                      , UPD_USER  = 'S_CUPN_10' 
                  WHERE COMP_CD   = PSV_COMP_CD 
                    AND COUPON_CD = PSV_COUPON_CD 
                    AND CERT_NO   = PSV_CERT_NO; 
               EXCEPTION 
                 WHEN OTHERS THEN  
                      ROLLBACK; 
               END; 
                
               OPEN asResult FOR 
               SELECT 1024 AS RTNCODE 
                 FROM DUAL; 
                  
               RETURN; 
            END IF; 
         ELSE -- 반품 
            IF lsUseStat NOT IN ('10') THEN -- 10:판매 
               asRetVal := '10'||lsUseStat; 
               asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001391')||' ['||lsUseStatNm||']'; -- 반품 가능한 상태의 인증번호가 아닙니다. 
                
               OPEN asResult FOR 
               SELECT 1024 AS RTNCODE 
                 FROM DUAL; 
                  
               RETURN; 
            END IF; 
         END IF; 
      END IF; 
    EXCEPTION 
      WHEN ERR_HANDLER THEN 
           RETURN; 
      WHEN OTHERS THEN 
           asRetVal := '2000'; 
           asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001359'); -- 존재하지 않는 인증번호입니다. 
            
           OPEN asResult FOR 
           SELECT 1024 AS RTNCODE 
             FROM DUAL; 
              
           RETURN; 
    END; 
    
    -- 회원상태 체크
    SELECT  CUST_STAT INTO lsCustStat
    FROM    C_CUST
    WHERE   COMP_CD = PSV_COMP_CD
    AND     CUST_ID = lsCustId;
     
    -- 상태 플래그 체크(매출/반품/유효기간경과) 
    UPDATE C_COUPON_CUST -- 모바일쿠폰 대상회원 
       SET USE_STAT    = CASE WHEN PSV_SALE_DIV = '1' THEN '10'  
                              ELSE (CASE WHEN CERT_TDT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '33' ELSE '11' END)   
                         END 
         , USE_DT      = PSV_USE_DT 
         , USE_TM      = PSV_USE_TM 
         , BRAND_CD    = PSV_BRAND_CD 
         , STOR_CD     = PSV_STOR_CD 
         , POS_NO      = PSV_POS_NO 
         , BILL_NO     = PSV_BILL_NO 
         , UPD_DT      = SYSDATE 
         , UPD_USER    = 'SYSTEM'
         , MEMB_DIV    = CASE WHEN lsCustStat IN ('3', '7') THEN '1' ELSE  MEMB_DIV END
     WHERE COMP_CD     = PSV_COMP_CD 
       AND COUPON_CD   = PSV_COUPON_CD 
       AND CERT_NO     = PSV_CERT_NO; 
        
    OPEN asResult FOR 
    SELECT 0 AS RTNCODE 
      FROM DUAL; 
       
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상 처리되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN OTHERS THEN 
         asRetVal := '3001'; 
         asRetMsg := '사용처리 중 오류가 발생하였습니다.['||SQLERRM||']'; 
          
         OPEN asResult FOR 
         SELECT 0 AS RTNCODE 
           FROM DUAL; 
            
         RETURN; 
  END SET_MEMB_CUPN_10; 
   
    ------------------------------------------------------------------------------ 
  --  Package Name     : SET_MEMB_CUPN_20 
  --  Description      : POS 멤버십 쿠폰 폐기처리 > POS에서만 가능 
  --  Ref. Table       : C_COUPON_MST  모바일쿠폰 마스터 
  --                     C_COUPON_CUST 모바일쿠폰 대상회원 
  --                     C_CARD        멤버십카드 마스터 
  ------------------------------------------------------------------------------ 
  --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT 
  --  Modify Date      :  
  ------------------------------------------------------------------------------ 
  PROCEDURE SET_MEMB_CUPN_20 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_SALE_DT           IN   VARCHAR2, -- 3. 판매일자 
    PSV_BRAND_CD          IN   VARCHAR2, -- 4 브랜드코드 
    PSV_STOR_CD           IN   VARCHAR2, -- 5. 매장코드 
    PSV_POS_NO            IN   VARCHAR2, -- 6. 포스번호 
    PSV_BILL_NO           IN   VARCHAR2, -- 7. 영수증번호 
    asRetVal              OUT  VARCHAR2, -- 8. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 9. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
  ) IS 
     
    CURSOR CUR_1 IS  
        SELECT  CC1.COMP_CD 
             ,  CC1.COUPON_CD 
             ,  CC1.CERT_NO 
        FROM    C_COUPON_CUST  CC1 -- 모바일쿠폰 대상회원 
        WHERE   CC1.COMP_CD     = PSV_COMP_CD 
        AND     CC1.PRT_SALE_DT = PSV_SALE_DT 
        AND     CC1.PRT_BRAND_CD= PSV_BRAND_CD 
        AND     CC1.PRT_STOR_CD = PSV_STOR_CD 
        AND    (PSV_POS_NO  IS NULL OR CC1.PRT_POS_NO  = PSV_POS_NO) 
        AND    (PSV_BILL_NO IS NULL OR CC1.PRT_BILL_NO = PSV_BILL_NO) 
        AND     CC1.USE_STAT   != '10' 
        AND     CC1.USE_YN      = 'Y'; 
        
    lsCouponCd      C_COUPON_CUST.COUPON_CD%TYPE := NULL;   -- 쿠폰번호 
    lsStat          VARCHAR2(  1)   := NULL; 
    lsUseStat       C_COUPON_CUST.USE_STAT%TYPE  := NULL;   -- 사용상태[00:대기, 01:요청, 10:판매, 11:반품, 30:분실, 31:도난, 32:일반폐기, 33:유효기간만료, 34:탈퇴폐기, 99:에러] 
    lsUseStatNm     VARCHAR2(200)   := NULL; 
    lsCertYn        VARCHAR2(  1)   := NULL; 
    lsCertFdt       VARCHAR2(  8)   := NULL; 
    lsCertTdt       VARCHAR2(  8)   := NULL; 
     
    nRecCnt         NUMBER(7)       := 0; 
     
    ERR_HANDLER     EXCEPTION; 
     
  BEGIN 
    asRetVal    := '0000'; 
    asRetMsg    := ''; 
     
    FOR MYREC IN CUR_1 LOOP 
        UPDATE  C_COUPON_CUST 
        SET     USE_STAT  = '32' 
             ,  USE_YN    = 'N' 
        WHERE   COMP_CD   = MYREC.COMP_CD 
        AND     COUPON_CD = MYREC.COUPON_CD 
        AND     CERT_NO   = MYREC.CERT_NO; 
    END LOOP; 
     
    -- 인증번호 
    OPEN asResult FOR 
        SELECT 0 
          FROM DUAL;     
         
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상 처리되었습니다. 
     
    RETURN; 
  EXCEPTION 
    WHEN OTHERS THEN 
         asRetVal := '3001'; 
         asRetMsg := SQLERRM; 
          
         OPEN asResult FOR 
         SELECT 1024 AS RTNCODE 
           FROM DUAL; 
            
        RETURN; 
  END SET_MEMB_CUPN_20; 
END PKG_POS_CUST_POS;

/
