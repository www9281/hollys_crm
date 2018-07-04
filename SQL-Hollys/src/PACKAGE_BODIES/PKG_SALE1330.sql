--------------------------------------------------------
--  DDL for Package Body PKG_SALE1330
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1330" AS

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
        PSV_WORK_DIV    IN  VARCHAR2 ,                -- 처리구분
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     담당자 처리현황
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-09-33         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2017-09-13
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
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  SC.COMP_CD      ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[      ,  SC.BRAND_CD     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[      ,  SC.STOR_CD      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM       ]'  -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  SC.SALE_DT      ]'  -- 처리일자
        ||CHR(13)||CHR(10)||Q'[      ,  SC.POS_NO       ]'  -- 포스번호
        ||CHR(13)||CHR(10)||Q'[      ,  SC.SEQ          ]'  -- 순번
        ||CHR(13)||CHR(10)||Q'[      ,  SC.WORK_DIV     ]'  -- 처리구분
        ||CHR(13)||CHR(10)||Q'[      ,  SC.BILL_NO      ]'  -- 영수번호
        ||CHR(13)||CHR(10)||Q'[      ,  SC.USER_ID      ]'  -- 사원번호
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(SC.USER_NM, SU.USER_NM)     AS USER_NM  ]'  -- 사원명
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_CASHIER    SC  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  U.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.USER_ID       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, U.USER_NM)   AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_USER      U   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE      L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  U.COMP_CD       = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.BRAND_CD      = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.STOR_CD       = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COMP_CD(+)    = U.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(U.BRAND_CD, 4, ' ')||LPAD(U.STOR_CD, 10, ' ')||LPAD(U.USER_ID, 10, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'STORE_USER'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )               SU          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SC.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.COMP_CD  = SU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.BRAND_CD = SU.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.STOR_CD  = SU.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.USER_ID  = SU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SC.STOR_CD, SC.SALE_DT, SC.POS_NO, SC.SEQ ]';

        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE1330;

/
