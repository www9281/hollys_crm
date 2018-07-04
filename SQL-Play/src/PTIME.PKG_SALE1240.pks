CREATE OR REPLACE PACKAGE       PKG_SALE1240 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1240
   --  Description      : 회원권 사용내역
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
        PSV_MBS_DIV     IN  VARCHAR2 ,                -- 회원권종류
        PSV_CHARGE_YN   IN  VARCHAR2 ,                -- 유무상구분
        PSV_MEMBER_TXT  IN  VARCHAR2 ,                -- 회원번호/명
        PSV_CHILD_TXT   IN  VARCHAR2 ,                -- 자녀번호/명
        PSV_PROGRAM_TXT IN  VARCHAR2 ,                -- 프로그램ID/명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_SALE1240;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1240 AS

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
        PSV_MBS_DIV     IN  VARCHAR2 ,                -- 회원권종류
        PSV_CHARGE_YN   IN  VARCHAR2 ,                -- 유무상구분
        PSV_MEMBER_TXT  IN  VARCHAR2 ,                -- 회원번호/명
        PSV_CHILD_TXT   IN  VARCHAR2 ,                -- 자녀번호/명
        PSV_PROGRAM_TXT IN  VARCHAR2 ,                -- 프로그램ID/명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     회원권 사용내역
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-06-01
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  EM.MBS_NO   ]'                          -- 회원권번호
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_NM    ]'                          -- 회원권명
        ||CHR(13)||CHR(10)||Q'[      ,  REPLACE(EM.CERT_NO, SUBSTR(EM.CERT_NO, 9, 5), '*****') AS CERT_NO ]'  -- 인증번호
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_DIV   ]'                          -- 회원권종류
        ||CHR(13)||CHR(10)||Q'[      ,  M.CHARGE_YN ]'                          -- 유무상구분
        ||CHR(13)||CHR(10)||Q'[      ,  MS.MBS_STAT ]'                          -- 회원권상태
        ||CHR(13)||CHR(10)||Q'[      ,  EM.ENTRY_DT ]'                          -- 입장일자
        ||CHR(13)||CHR(10)||Q'[      ,  EM.BRAND_CD ]'                          -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM  ]'                          -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  EM.STOR_CD  ]'                          -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM   ]'                          -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  EM.MEMBER_NO]'                          -- 회원번호
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM)) AS MEMBER_NM ]' -- 회원명
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(C.MOBILE)) AS MOBILE ]' -- 핸드폰
        ||CHR(13)||CHR(10)||Q'[      ,  EM.CHILD_NO ]'                          -- 자녀번호
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(NVL(ED.ENTRY_NM, MC.CHILD_NM))  AS CHILD_NM ]'  -- 자녀명
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(ED.SEX_DIV, MC.SEX_DIV)     AS SEX_DIV  ]'          -- 성별
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(ED.AGES, MC.AGES)           AS AGES     ]'          -- 나이
        ||CHR(13)||CHR(10)||Q'[      ,  MS.PROGRAM_ID   ]'                      -- 프로그램ID
        ||CHR(13)||CHR(10)||Q'[      ,  M.PROGRAM_NM]'                          -- 프로그램명
        ||CHR(13)||CHR(10)||Q'[      ,  EP.MATL_ITEM_CD ]'                      -- 이용교구코드
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM   AS MATL_ITEM_NM ]'          -- 교구명
        ||CHR(13)||CHR(10)|| '       ,  CASE WHEN I.ITEM_NM IS NULL THEN M.PROGRAM_NM   '
        ||CHR(13)||CHR(10)|| '               ELSE M.PROGRAM_NM||''[''||I.ITEM_NM||'']'' '
        ||CHR(13)||CHR(10)|| '          END                 AS PROGRAM_MATL '   -- 프로그램[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(EP.USE_TM) AS EP_USE_TM  ]'  -- 이용시간
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ENTRY_FTM    ]'                      -- 입장시간
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ENTRY_TTM    ]'                      -- 퇴실시간
        ||CHR(13)||CHR(10)||Q'[      ,  EM.USE_TM   AS EM_USE_TM    ]'          -- 이용시간(분)(회원권결제)
        ||CHR(13)||CHR(10)||Q'[      ,  EM.USE_CNT  AS EM_USE_CNT   ]'          -- 이용횟수(회원권결제)
        ||CHR(13)||CHR(10)||Q'[      ,  EM.USE_AMT  AS EM_USE_AMT   ]'          -- 이용금액(회원권결제)
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_FDT ]'                          -- 구매일자
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_TDT ]'                          -- 만기일자
        ||CHR(13)||CHR(10)||Q'[      ,  MS.GRD_AMT  ]'                          -- 구매금액
        ||CHR(13)||CHR(10)||Q'[      ,  MS.REFUND_AMT   ]'                      -- 환불금액
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_TM ]'                          -- 제공시간(분)
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_TM   ]'                          -- 사용시간(분)
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_CNT]'                          -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_CNT  ]'                          -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_AMT]'                          -- 제공금액
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_AMT  ]'                          -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_AMT - MS.USE_AMT   AS REST_AMT ]'  -- 잔여금액
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_MCNT   ]'                      -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_MCNT ]'                          -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.OFFER_TM   ELSE 0 END AS TOT_OFFER_TM   ]'    -- 총제공시간(분)
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.USE_TM     ELSE 0 END AS TOT_USE_TM     ]'    -- 총사용시간(분)
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.OFFER_CNT  ELSE 0 END AS TOT_OFFER_CNT  ]'    -- 총제공횟수
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.USE_CNT    ELSE 0 END AS TOT_USE_CNT    ]'    -- 총사용횟수
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.OFFER_AMT  ELSE 0 END AS TOT_OFFER_AMT  ]'    -- 총제공금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.USE_AMT    ELSE 0 END AS TOT_USE_AMT    ]'    -- 총사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.OFFER_MCNT ELSE 0 END AS TOT_OFFER_MCNT ]'    -- 총제공교구수
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.USE_MCNT   ELSE 0 END AS TOT_USE_MCNT   ]'    -- 총사용교구수
        ||CHR(13)||CHR(10)||Q'[   FROM  CS_ENTRY_MEMBERSHIP EM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_PROGRAM    EP  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_DT         ED  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_HD         EH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  P.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  P.PROGRAM_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(PL.LANG_NM, P.PROGRAM_NM)   AS PROGRAM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MBS_NO        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(ML.LANG_NM, M.MBS_NM)       AS MBS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MBS_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.CHARGE_YN     ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  CS_PROGRAM      P   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBERSHIP   M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE      PL  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE      ML  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  P.COMP_CD       = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  P.PROGRAM_ID    = M.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.COMP_CD(+)   = P.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.PK_COL(+)    = LPAD(P.PROGRAM_ID, 30, ' ')   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.COMP_CD(+)   = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.PK_COL(+)    = LPAD(M.PROGRAM_ID, 30, ' ')||LPAD(M.MBS_NO, 30, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[                AND  P.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.TABLE_NM(+)  = 'CS_PROGRAM'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.COL_NM(+)    = 'PROGRAM_NM'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.LANGUAGE_TP(+) = :PSV_LANG_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.USE_YN(+)    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.TABLE_NM(+)  = 'CS_MEMBERSHIP']'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.COL_NM(+)    = 'MBS_NM'      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.LANGUAGE_TP(+) = :PSV_LANG_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.USE_YN(+)    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   M   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER               C   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER_CHILD         MC  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBERSHIP_SALE      MS  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM              I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  EM.COMP_CD      = EP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_NO     = EP.ENTRY_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_SEQ    = EP.ENTRY_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.PROGRAM_SEQ  = EP.PROGRAM_SEQ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.PROGRAM_ID   = EP.PROGRAM_ID ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MBS_NO       = EP.MBS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.CERT_NO      = EP.CERT_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = ED.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_NO     = ED.ENTRY_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_SEQ    = ED.ENTRY_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = EH.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_NO     = EH.ENTRY_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.PROGRAM_ID   = M.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MBS_NO       = M.MBS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MEMBER_NO    = C.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = MC.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MEMBER_NO    = MC.MEMBER_NO(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.CHILD_NO     = MC.CHILD_NO(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = MS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.PROGRAM_ID   = MS.PROGRAM_ID ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MBS_NO       = MS.MBS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.CERT_NO      = MS.CERT_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.COMP_CD      = I.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.MATL_ITEM_CD = I.ITEM_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_DT     BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.USE_YN       = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.USE_YN       = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.USE_YN       = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MBS_DIV     IS NULL OR MS.MBS_DIV   = :PSV_MBS_DIV)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CHARGE_YN   IS NULL OR MS.CHARGE_YN = :PSV_CHARGE_YN) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_TXT  IS NULL OR (EP.MEMBER_NO LIKE '%'||:PSV_MEMBER_TXT||'%' OR DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM))  LIKE '%'||:PSV_MEMBER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CHILD_TXT   IS NULL OR (EP.CHILD_NO  LIKE '%'||:PSV_CHILD_TXT||'%'  OR DECRYPT(MC.CHILD_NM) LIKE '%'||:PSV_CHILD_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_PROGRAM_TXT IS NULL OR (EP.PROGRAM_ID LIKE '%'||:PSV_PROGRAM_TXT||'%' OR M.PROGRAM_NM LIKE '%'||:PSV_PROGRAM_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY EM.MBS_NO    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EM.ENTRY_NO  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EM.ENTRY_SEQ    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EM.PROGRAM_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ENTRY_FTM    ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MBS_DIV, PSV_MBS_DIV, PSV_CHARGE_YN, PSV_CHARGE_YN, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_CHILD_TXT, PSV_CHILD_TXT, PSV_CHILD_TXT, PSV_PROGRAM_TXT, PSV_PROGRAM_TXT, PSV_PROGRAM_TXT;
     
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
    
END PKG_SALE1240;

/
