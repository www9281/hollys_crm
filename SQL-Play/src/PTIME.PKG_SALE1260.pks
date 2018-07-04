CREATE OR REPLACE PACKAGE       PKG_SALE1260 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1260
   --  Description      : 입장내역(한점포)
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_PROGRAM_ID  IN  VARCHAR2 ,                -- 프로그램ID
        PSV_MEMBER_DIV  IN  VARCHAR2 ,                -- 회원구분
        PSV_USE_YN      IN  VARCHAR2 ,                -- 입장구분
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_SALE1260;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1260 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_PROGRAM_ID  IN  VARCHAR2 ,                -- 프로그램ID
        PSV_MEMBER_DIV  IN  VARCHAR2 ,                -- 회원구분
        PSV_USE_YN      IN  VARCHAR2 ,                -- 입장구분
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     입장내역(한점포)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-06-02
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  ENTRY_DT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MEMBER_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MEMBER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(ORG_NM, '-')    AS ORG_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOBILE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ENTRY_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUM = 1 THEN ENTRY_CNT  ELSE 0 END AS TOT_ENTRY_CNT ]' -- 총입장객수   
        ||CHR(13)||CHR(10)||Q'[      ,  GRD_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUM = 1 THEN GRD_AMT    ELSE 0 END AS TOT_GRD_AMT   ]' -- 총결제금액
        ||CHR(13)||CHR(10)||Q'[      ,  UNPAID_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUM = 1 THEN UNPAID_AMT ELSE 0 END AS TOT_UNPAID_AMT]' -- 총미수금
        ||CHR(13)||CHR(10)||Q'[      ,  CUST_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CHILD_NO    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CHILD_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SEX_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  AGES        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ENTRY_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PROGRAM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MATL_ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  MATL_ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  PROGRAM_MATL]'
        ||CHR(13)||CHR(10)||Q'[      ,  ENTRY_SALE_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ENTRY_FTM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ENTRY_TTM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(EP_USE_TM)   AS EP_USE_TM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(IDLE_TM)     AS IDLE_TM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(ADD_TM)      AS ADD_TM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EP_USE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADD_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MBS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MBS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CERT_NO     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MBS_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CHARGE_YN   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USE_TM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USE_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USE_MCNT    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (           ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT  EH.ENTRY_DT ]'                          -- 입장일자
        ||CHR(13)||CHR(10)||Q'[      ,  EH.BRAND_CD ]'                          -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM  ]'                          -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  EH.STOR_CD  ]'                          -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM   ]'                          -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  EH.MEMBER_DIV   ]'                      -- 회원구분
        ||CHR(13)||CHR(10)||Q'[      ,  EH.MEMBER_NO]'                          -- 회원번호
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(EH.MEMBER_NM)   AS MEMBER_NM]'  -- 회원명
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(EH.ORG_NM)      AS ORG_NM   ]'  -- 단체명
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(EH.MOBILE)) AS MOBILE ]' -- 핸드폰
        ||CHR(13)||CHR(10)||Q'[      ,  EH.ENTRY_CNT                        ]'  -- 입장객수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN ED.USE_YN = 'Y' THEN EP.GRD_AMT - NVL(M.USE_AMT, 0)    ELSE 0 END) OVER (PARTITION BY EH.COMP_CD, EH.ENTRY_NO)    AS GRD_AMT   ]'  -- 결제금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ED.USE_YN = 'Y' THEN EH.UNPAID_AMT ELSE 0 END    AS UNPAID_AMT]'  -- 미수금
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ED.USE_YN = 'Y' AND EH.ENTRY_CNT > 0 THEN ROUND((ED.GRD_AMT - NVL(M.USE_AMT, 0)) / EH.ENTRY_CNT) ELSE 0 END AS CUST_AMT ]'  -- 객단가
        ||CHR(13)||CHR(10)||Q'[      ,  ED.CHILD_NO ]'                          -- 자녀번호
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(NVL(ED.ENTRY_NM, MC.CHILD_NM))  AS CHILD_NM ]'  -- 자녀명
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(ED.SEX_DIV, MC.SEX_DIV) AS SEX_DIV]'-- 성별
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(ED.AGES, MC.AGES)   AS AGES ]'      -- 나이
        ||CHR(13)||CHR(10)||Q'[      ,  ED.ENTRY_DIV]'                          -- 입장자구분
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ED.USE_YN = 'Y' THEN FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR')   ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ENTRY_CANCEL')   ]'
        ||CHR(13)||CHR(10)||Q'[         END         AS ENTRY_SALE_DIV   ]'      -- 입장구분
        ||CHR(13)||CHR(10)||Q'[      ,  EP.PROGRAM_ID   ]'                      -- 프로그램ID
        ||CHR(13)||CHR(10)||Q'[      ,  P.PROGRAM_NM]'                          -- 프로그램명
        ||CHR(13)||CHR(10)||Q'[      ,  EP.MATL_ITEM_CD ]'                      -- 이용교구코드
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM   AS MATL_ITEM_NM ]'          -- 교구명
        ||CHR(13)||CHR(10)|| '       ,  CASE WHEN I.ITEM_NM IS NULL THEN P.PROGRAM_NM   '
        ||CHR(13)||CHR(10)|| '               ELSE P.PROGRAM_NM||''[''||I.ITEM_NM||'']'' '
        ||CHR(13)||CHR(10)|| '          END                 AS PROGRAM_MATL '   -- 프로그램[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ENTRY_FTM]'                          -- 입장시간
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ENTRY_TTM]'                          -- 퇴실시간
        ||CHR(13)||CHR(10)||Q'[      ,  EP.USE_TM   AS EP_USE_TM    ]'          -- 이용시간
        ||CHR(13)||CHR(10)||Q'[      ,  EP.IDLE_TM  ]'                          -- 대기시간
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ADD_TM   ]'                          -- 추가시간
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ED.USE_YN = 'Y' THEN EP.USE_AMT ELSE 0 END    AS EP_USE_AMT   ]'  -- 이용금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ED.USE_YN = 'Y' THEN EP.ADD_AMT ELSE 0 END    AS ADD_AMT      ]'  -- 추가금액
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_NO    ]'                          -- 회원권번호
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_NM    ]'                          -- 회원권명
        ||CHR(13)||CHR(10)||Q'[      ,  REPLACE(M.CERT_NO, SUBSTR(M.CERT_NO, 9, 5), '*****') AS CERT_NO ]'  -- 인증번호
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_DIV   ]'                          -- 회원권종류
        ||CHR(13)||CHR(10)||Q'[      ,  M.CHARGE_YN ]'                          -- 유무상구분
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ED.USE_YN = 'Y' THEN M.USE_TM   ELSE 0 END    AS USE_TM   ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ED.USE_YN = 'Y' THEN M.USE_CNT  ELSE 0 END    AS USE_CNT  ]'  -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ED.USE_YN = 'Y' THEN M.USE_AMT  ELSE 0 END    AS USE_AMT  ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ED.USE_YN = 'Y' AND M.MBS_NO IS NOT NULL AND EP.MATL_ITEM_CD IS NOT NULL THEN 1 ELSE 0 END AS USE_MCNT ]'  -- 이용[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  ROW_NUMBER() OVER (PARTITION BY EH.COMP_CD, EH.ENTRY_NO ORDER BY EH.COMP_CD, EH.ENTRY_NO)  AS ROW_NUM ]'   
        ||CHR(13)||CHR(10)||Q'[   FROM  CS_ENTRY_HD         EH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER           C   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_DT         ED  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER_CHILD     MC  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_PROGRAM    EP  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  P.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  P.PROGRAM_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, P.PROGRAM_NM)    AS PROGRAM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  CS_PROGRAM      P   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE      L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = P.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(P.PROGRAM_ID, 30, ' ')   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  P.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'CS_PROGRAM'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'PROGRAM_NM'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   P   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM                  I   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  M.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.PROGRAM_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MBS_NO        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  EM.CERT_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(NVL(L.LANG_NM, M.MBS_NM))   AS MBS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(M.MBS_DIV)      AS MBS_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(M.CHARGE_YN)    AS CHARGE_YN]'
        ||CHR(13)||CHR(10)||Q'[                  ,  EM.ENTRY_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  EM.ENTRY_SEQ    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  EM.PROGRAM_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(EM.USE_TM)      AS USE_TM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(EM.USE_CNT)     AS USE_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(EM.USE_AMT)     AS USE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  CS_MEMBERSHIP       M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_ENTRY_MEMBERSHIP EM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE          L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  M.COMP_CD       = EM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.PROGRAM_ID    = EM.PROGRAM_ID ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MBS_NO        = EM.MBS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COMP_CD(+)    = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(M.PROGRAM_ID, 30, ' ')||LPAD(M.MBS_NO, 30, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  EM.USE_YN(+)    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'CS_MEMBERSHIP']'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'MBS_NM'      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY M.COMP_CD, M.PROGRAM_ID, M.MBS_NO, EM.CERT_NO, EM.ENTRY_NO, EM.ENTRY_SEQ, EM.PROGRAM_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[         )   M   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  EH.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.COMP_CD      = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.MEMBER_NO    = C.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.COMP_CD      = ED.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.ENTRY_NO     = ED.ENTRY_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.COMP_CD      = MC.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.MEMBER_NO    = MC.MEMBER_NO(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.CHILD_NO     = MC.CHILD_NO(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.COMP_CD      = EP.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.ENTRY_NO     = EP.ENTRY_NO(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.ENTRY_SEQ    = EP.ENTRY_SEQ(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.COMP_CD      = P.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.PROGRAM_ID   = P.PROGRAM_ID(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.COMP_CD      = I.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.MATL_ITEM_CD = I.ITEM_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.COMP_CD      = M.COMP_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.ENTRY_NO     = M.ENTRY_NO(+)    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.ENTRY_SEQ    = M.ENTRY_SEQ(+)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.PROGRAM_SEQ  = M.PROGRAM_SEQ(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.ENTRY_DT     BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_USE_YN IS NULL OR ED.USE_YN = :PSV_USE_YN)    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_PROGRAM_ID IS NULL OR EP.PROGRAM_ID = :PSV_PROGRAM_ID)    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_DIV IS NULL OR EH.MEMBER_DIV = :PSV_MEMBER_DIV)    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY EH.ENTRY_NO  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ED.ENTRY_SEQ    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EP.PROGRAM_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ENTRY_FTM    ]'
        ||CHR(13)||CHR(10)||Q'[         )   ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_USE_YN, PSV_USE_YN, PSV_PROGRAM_ID, PSV_PROGRAM_ID, PSV_MEMBER_DIV, PSV_MEMBER_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
END PKG_SALE1260;

/
