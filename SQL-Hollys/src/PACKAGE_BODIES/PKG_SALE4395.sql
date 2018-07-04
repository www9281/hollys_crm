--------------------------------------------------------
--  DDL for Package Body PKG_SALE4395
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4395" AS

    PROCEDURE SP_TAB01
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
        PSV_DC_DIV      IN  VARCHAR2 ,                -- 할인코드
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종료
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    할인내역(일자)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);
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

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD) AS WEEK_DAY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_QTY)                  AS DC_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)     AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDD    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DC_DIV   IS NULL OR SJ.DC_DIV   = :PSV_DC_DIV  ) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.FREE_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT                  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, 
                         PSV_DC_DIV, PSV_DC_DIV, PSV_GIFT_DIV, PSV_GIFT_DIV;

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

    PROCEDURE SP_TAB02
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
        PSV_DC_DIV      IN  VARCHAR2 ,                -- 할인코드
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종료
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    할인내역(할인종류)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-01-19
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(D.DC_NM)        AS DC_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD) AS WEEK_DAY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_QTY)                  AS DC_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)     AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDD    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  D.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D.DC_DIV        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, D.DC_NM) AS DC_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D.ORD_RANK      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  DC          D   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = D.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(D.BRAND_CD, 4, ' ') || LPAD(D.DC_DIV, 5, ' ')    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  D.COMP_CD       = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'               ]'
        ||CHR(13)||CHR(10)||Q'[         )   D           ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = D.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD =(CASE WHEN D.BRAND_CD = '0000' THEN SJ.BRAND_CD ELSE  D.BRAND_CD END) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.DC_DIV   = D.DC_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DC_DIV   IS NULL OR SJ.DC_DIV   = :PSV_DC_DIV  ) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.FREE_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_DIV                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(D.ORD_RANK)             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_DIV                   ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, 
                         PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, 
                         PSV_DC_DIV, PSV_DC_DIV, PSV_GIFT_DIV, PSV_GIFT_DIV;

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

    PROCEDURE SP_TAB03
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
        PSV_DC_DIV      IN  VARCHAR2 ,                -- 할인코드
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종료
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03   할인내역(상품)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-01-19
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               || ls_sql_store -- S_STORE
               || ', '
               || ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(D.DC_NM)        AS DC_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ITEM_NM)      AS ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD) AS WEEK_DAY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_QTY)                  AS DC_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)     AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDD    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  D.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D.DC_DIV        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, D.DC_NM) AS DC_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D.ORD_RANK      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  DC          D   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = D.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(D.BRAND_CD, 4, ' ') || LPAD(D.DC_DIV, 5, ' ')    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  D.COMP_CD       = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'               ]'
        ||CHR(13)||CHR(10)||Q'[         )   D           ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = D.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = (CASE WHEN D.BRAND_CD = '0000' THEN SJ.BRAND_CD ELSE  D.BRAND_CD END) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.DC_DIV   = D.DC_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DC_DIV   IS NULL OR SJ.DC_DIV   = :PSV_DC_DIV  ) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.FREE_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_DIV                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(D.ORD_RANK)             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_DIV                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_CD)           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_CD)           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_CD)           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD                  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, 
                         PSV_DC_DIV, PSV_DC_DIV, PSV_GIFT_DIV, PSV_GIFT_DIV;

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

END PKG_SALE4395;

/
