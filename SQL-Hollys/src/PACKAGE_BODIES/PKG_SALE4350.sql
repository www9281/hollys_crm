--------------------------------------------------------
--  DDL for Package Body PKG_SALE4350
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4350" AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE4350
   --  Description      : 현금영수증 승인 조회
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     현금영수증 승인 조회(메인)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-18         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-18
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := 
          CHR(13)||CHR(10)||Q'[ SELECT  A.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DISTINCT BILL_NO)                           AS BILL_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(A.APPR_AMT * DECODE(A.SALE_DIV,'1',1,-1))   AS GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    CASH_LOG A, S_STORE S       ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   S.COMP_CD   = A.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S.BRAND_CD  = A.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S.STOR_CD   = A.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.SALE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.USE_YN    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP  BY                           ]'
        ||CHR(13)||CHR(10)||Q'[         A.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[       , A.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[       , S.STOR_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[       , A.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY                           ]'
        ||CHR(13)||CHR(10)||Q'[         A.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[       , A.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[       , A.SALE_DT DESC              ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

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

    PROCEDURE SP_SUB
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 판매일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_SUB     현금영수증 승인 조회(서브)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-18         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2016-01-18
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);

    ls_sql_cm_00435 VARCHAR2(1000);    -- 공통코드 참조 Table SQL( Role)

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER ,
                            ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00435');
        -------------------------------------------------------------------------------

        ls_sql_main := 
          CHR(13)||CHR(10)||Q'[ SELECT  A.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.POS_NO                    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.BILL_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_NM   AS SALE_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RPAD(SUBSTR(A.CARD_NO, 1, 4), LENGTH(A.CARD_NO), '*')   AS TEL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(A.SALE_DIV, '1', 1, -1) * APPR_AMT               AS APPR_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(A.SALE_DIV, '1', 1, -1) * APPR_AMT               AS APPR_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_TM                   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  CASH_LOG A, S_STORE S,      ]'
        ||CHR(13)||CHR(10)||            ls_sql_cm_00435 || Q'[ C    ]' 
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.COMP_CD   = A.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  S.BRAND_CD  = A.BRAND_CD    ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  S.STOR_CD   = A.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.SALE_DIV  = C.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.SALE_DT   = :PSV_SALE_DT  ]'     
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY A.APPR_TM                ]';

        dbms_output.put_line(ls_sql);
        dbms_output.put_line(ls_sql_main);

        ls_sql := ls_sql || ls_sql_main;

        OPEN PR_RESULT FOR
           ls_sql USING PSV_COMP_CD, PSV_SALE_DT;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

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

END PKG_SALE4350;

/
