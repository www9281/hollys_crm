CREATE OR REPLACE PACKAGE       PKG_SALE1310 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1310
   --  Description      : 직원할인 현황 
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_YM              IN  VARCHAR2 ,                  -- 조회 년월
        PSV_DEPT_CD         IN  VARCHAR2 ,                  -- 부서
        PSV_USER_TXT        IN  VARCHAR2 ,                  -- 사원ID/명
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DEPT_CD         IN  VARCHAR2 ,                  -- 부서
        PSV_DC_GRPCD        IN  VARCHAR2 ,                  -- 할인구분
        PSV_USER_TXT        IN  VARCHAR2 ,                  -- 사원ID/명
        PSV_USER_ID         IN  VARCHAR2 ,                  -- 사원ID
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
END PKG_SALE1310;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1310 AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_YM              IN  VARCHAR2 ,                  -- 조회 년월
        PSV_DEPT_CD         IN  VARCHAR2 ,                  -- 부서
        PSV_USER_TXT        IN  VARCHAR2 ,                  -- 사원ID/명
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01     직원할인 현황(월별)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-01-09         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2017-01-09
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
    ls_sql_cm_00600 VARCHAR2(1000) ;    -- 공통코드(부서)
    ls_sql_cm_00730 VARCHAR2(1000) ;    -- 공통코드(직급)
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드(매장역할구분)
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00600 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00600') ;
        ls_sql_cm_00730 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00730') ;
        ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  UD.COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.USER_ID                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.USER_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.DEPT_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.POSITION_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.POSITION_NM               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  UD.FREE_CNT_M               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  UD.FREE_USE_M               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  UD.DC_CNT_M                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  UD.DC_USE_M                 ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  USER_DC         UD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  HU.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  HU.USER_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, HU.USER_NM)  AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  HU.DEPT_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C1.CODE_NM                  AS DEPT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  HU.POSITION_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C2.CODE_NM                  AS POSITION_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  HQ_USER     HU  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  LANG_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  TABLE_NM    = 'HQ_USER'     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  COL_NM      = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )           L   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ]' || ls_sql_cm_00600 || Q'[    C1      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ]' || ls_sql_cm_00730 || Q'[    C2      ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = HU.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(HU.USER_ID, 10, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.COMP_CD      = C1.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.DEPT_CD      = C1.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.COMP_CD      = C2.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.POSITION_CD  = C2.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DEPT_CD  IS NULL OR HU.DEPT_CD = :PSV_DEPT_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_USER_TXT IS NULL OR (HU.USER_ID LIKE '%'||:PSV_USER_TXT||'%' OR NVL(L.LANG_NM, HU.USER_NM) LIKE '%'||:PSV_USER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SU.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SU.USER_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, SU.USER_NM)  AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SU.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM                   AS DEPT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SU.ROLE_DIV                 AS POSITION_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C1.CODE_NM                  AS POSITION_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_USER  SU  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  LANG_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  TABLE_NM    = 'STORE_USER'  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  COL_NM      = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )           L   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STORE   S                               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ]' || ls_sql_cm_00770 || Q'[    C1      ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = SU.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(SU.USER_ID, 10, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.COMP_CD      = S.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.BRAND_CD     = S.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.STOR_CD      = S.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.COMP_CD      = C1.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.ROLE_DIV     = C1.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DEPT_CD  IS NULL OR SU.STOR_CD = :PSV_DEPT_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_USER_TXT IS NULL OR (SU.USER_ID LIKE '%'||:PSV_USER_TXT||'%' OR NVL(L.LANG_NM, SU.USER_NM) LIKE '%'||:PSV_USER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[         )   U                       ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  UD.COMP_CD  = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  UD.USER_ID  = U.USER_ID     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  UD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  UD.DC_DT    = :PSV_YM||'00' ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY U.DEPT_CD, U.USER_ID     ]'
        ;
        ls_sql := ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_DEPT_CD, PSV_DEPT_CD, PSV_USER_TXT, PSV_USER_TXT, PSV_USER_TXT, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_DEPT_CD, PSV_DEPT_CD, PSV_USER_TXT, PSV_USER_TXT, PSV_USER_TXT, PSV_COMP_CD, PSV_YM;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DEPT_CD         IN  VARCHAR2 ,                  -- 부서
        PSV_DC_GRPCD        IN  VARCHAR2 ,                  -- 할인구분
        PSV_USER_TXT        IN  VARCHAR2 ,                  -- 사원ID/명
        PSV_USER_ID         IN  VARCHAR2 ,                  -- 사원ID
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     직원할인 현황(상세정보)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-01-09         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2017-01-09
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
    ls_sql_cm_00600 VARCHAR2(1000) ;    -- 공통코드(부서)
    ls_sql_cm_00730 VARCHAR2(1000) ;    -- 공통코드(직급)
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드(매장역할구분)
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00600 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00600') ;
        ls_sql_cm_00730 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00730') ;
        ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  D.COMP_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.USER_ID                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.USER_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.DEPT_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.POSITION_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  U.POSITION_NM               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ED.ENTRY_DT     AS USE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SD.SALE_DIV = '1' THEN FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USED'  )    ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN SD.SALE_DIV = '2' THEN FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CANCEL')    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ''                ]'
        ||CHR(13)||CHR(10)||Q'[         END             AS DIV      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ED.ENTRY_FTM                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ED.ENTRY_TTM                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ED.USE_TM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(NVL(ED.ENTRY_NM, MC.CHILD_NM))  AS CHILD_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D.DC_NM                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D.DC_VALUE                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  P.PROGRAM_NM                ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  DC                  D   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_DT             SD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  HU.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  HU.USER_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, HU.USER_NM)  AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  HU.DEPT_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C1.CODE_NM                  AS DEPT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  HU.POSITION_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C2.CODE_NM                  AS POSITION_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  HQ_USER     HU  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  LANG_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  TABLE_NM    = 'HQ_USER'     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  COL_NM      = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )           L   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ]' || ls_sql_cm_00600 || Q'[    C1      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ]' || ls_sql_cm_00730 || Q'[    C2      ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = HU.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(HU.USER_ID, 10, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.COMP_CD      = C1.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.DEPT_CD      = C1.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.COMP_CD      = C2.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.POSITION_CD  = C2.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DEPT_CD  IS NULL OR HU.DEPT_CD = :PSV_DEPT_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_USER_TXT IS NULL OR (HU.USER_ID LIKE '%'||:PSV_USER_TXT||'%' OR NVL(L.LANG_NM, HU.USER_NM) LIKE '%'||:PSV_USER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_USER_ID  IS NULL OR HU.USER_ID = :PSV_USER_ID) ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SU.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SU.USER_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, SU.USER_NM)  AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SU.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM                   AS DEPT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SU.ROLE_DIV                 AS POSITION_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C1.CODE_NM                  AS POSITION_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_USER  SU  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  LANG_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  TABLE_NM    = 'STORE_USER'  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  COL_NM      = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )           L   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STORE   S                               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ]' || ls_sql_cm_00770 || Q'[    C1      ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = SU.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(SU.USER_ID, 10, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.COMP_CD      = S.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.BRAND_CD     = S.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.STOR_CD      = S.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.COMP_CD      = C1.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.ROLE_DIV     = C1.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DEPT_CD  IS NULL OR SU.STOR_CD = :PSV_DEPT_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_USER_TXT IS NULL OR (SU.USER_ID LIKE '%'||:PSV_USER_TXT||'%' OR NVL(L.LANG_NM, SU.USER_NM) LIKE '%'||:PSV_USER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_USER_ID  IS NULL OR SU.USER_ID = :PSV_USER_ID) ]'
        ||CHR(13)||CHR(10)||Q'[         )   U                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_DT         ED  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER_CHILD     MC  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_PROGRAM    EP  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_PROGRAM          P   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  D.COMP_CD       = SD.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.DC_DIV        = SD.DC_DIV         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = U.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.USER_ID      = U.USER_ID         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = S.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = S.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = S.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = ED.COMP_CD        ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ENTRY_NO     = ED.ENTRY_NO       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ENTRY_SEQ    = ED.ENTRY_SEQ      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.COMP_CD      = MC.COMP_CD(+)     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  ED.MEMBER_NO    = MC.MEMBER_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.CHILD_NO     = MC.CHILD_NO(+)    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.COMP_CD      = EP.COMP_CD        ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  ED.ENTRY_NO     = EP.ENTRY_NO       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.ENTRY_SEQ    = EP.ENTRY_SEQ      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.COMP_CD      = P.COMP_CD(+)      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.PROGRAM_ID   = P.PROGRAM_ID(+)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.COMP_CD       = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.DC_GRPCD      IN ('EFE', 'EDE')   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DC_GRPCD  IS NULL OR D.DC_GRPCD = :PSV_DC_GRPCD)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.ENTRY_DT     BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.USER_ID      IS NOT NULL         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ED.ENTRY_DIV    = '2'               ]'  
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SD.USER_ID, ED.ENTRY_DT, ED.ENTRY_FTM, ED.ENTRY_TTM, SD.SALE_DIV, ED.ENTRY_NO, ED.ENTRY_SEQ, EP.PROGRAM_SEQ ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_DEPT_CD, PSV_DEPT_CD, PSV_USER_TXT, PSV_USER_TXT, PSV_USER_TXT, PSV_USER_ID, PSV_USER_ID, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_DEPT_CD, PSV_DEPT_CD, PSV_USER_TXT, PSV_USER_TXT, PSV_USER_TXT, PSV_USER_ID, PSV_USER_ID, PSV_COMP_CD, PSV_DC_GRPCD, PSV_DC_GRPCD, PSV_GFR_DATE, PSV_GTO_DATE;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
END PKG_SALE1310;

/
