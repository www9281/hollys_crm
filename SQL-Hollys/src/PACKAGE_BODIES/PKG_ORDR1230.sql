--------------------------------------------------------
--  DDL for Package Body PKG_ORDR1230
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ORDR1230" AS

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
        PSV_DT_TP       IN  VARCHAR2 ,                -- 일자구분
        PSV_ORD_FG      IN  VARCHAR2 ,                -- 주문구분
        PSV_ORD_DIV     IN  VARCHAR2 ,                -- 주문유형
        PSV_ITEM_TXT    IN  VARCHAR2 ,                -- 상품코드/명
        PSV_VENDOR_CD   IN  VARCHAR2 ,                -- 공급업체코드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    주문현황(점포) - 점포별
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
    ls_sql_main     VARCHAR2(30000);
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  OH.COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)  AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_QTY , 0))     AS ORD_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_AMT , 0))     AS ORD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_VAT , 0))     AS ORD_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_QTY , 0))     AS DLV_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_AMT , 0))     AS DLV_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_VAT , 0))     AS DLV_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CQTY, 0))     AS ORD_CQTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CAMT, 0))     AS ORD_CAMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CVAT, 0))     AS ORD_CVAT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_QTY , 0))     AS RJT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_AMT , 0))     AS RJT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_VAT , 0))     AS RJT_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CQTY, 0))     AS RJT_CQTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CAMT, 0))     AS RJT_CAMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CVAT, 0))     AS RJT_CVAT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ORDER_HDV   OH              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ORDER_DTV   OD              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I               ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  OH.COMP_CD  = OD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_NO   = OD.ORD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_FG   = :PSV_ORD_FG   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DECODE(:PSV_DT_TP, 'O', OD.ORD_DT, 'D', OD.DLV_DT, 'C', OD.DLV_CDT, 'S', OD.STK_DT) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ORD_DIV IS NULL OR OH.ORD_DIV = :PSV_ORD_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_VENDOR_CD IS NULL OR I.VENDOR_CD = :PSV_VENDOR_CD) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (OD.ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY OH.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY OH.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.STOR_CD                  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_ORD_FG, PSV_DT_TP, PSV_GFR_DATE, PSV_GTO_DATE, PSV_ORD_DIV, PSV_ORD_DIV, PSV_VENDOR_CD, PSV_VENDOR_CD, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

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
        PSV_DT_TP       IN  VARCHAR2 ,                -- 일자구분
        PSV_ORD_FG      IN  VARCHAR2 ,                -- 주문구분
        PSV_ORD_DIV     IN  VARCHAR2 ,                -- 주문유형
        PSV_ITEM_TXT    IN  VARCHAR2 ,                -- 상품코드/명
        PSV_VENDOR_CD   IN  VARCHAR2 ,                -- 공급업체코드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     주문현황(점포) - 일자별
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
    ls_sql_main     VARCHAR2(30000);
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  OH.ORD_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_QTY , 0))     AS ORD_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_AMT , 0))     AS ORD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_VAT , 0))     AS ORD_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_QTY , 0))     AS DLV_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_AMT , 0))     AS DLV_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_VAT , 0))     AS DLV_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CQTY, 0))     AS ORD_CQTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CAMT, 0))     AS ORD_CAMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CVAT, 0))     AS ORD_CVAT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_QTY , 0))     AS RJT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_AMT , 0))     AS RJT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_VAT , 0))     AS RJT_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CQTY, 0))     AS RJT_CQTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CAMT, 0))     AS RJT_CAMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CVAT, 0))     AS RJT_CVAT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ORDER_HDV   OH              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ORDER_DTV   OD              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I               ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  OH.COMP_CD  = OD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_NO   = OD.ORD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_FG   = :PSV_ORD_FG   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DECODE(:PSV_DT_TP, 'O', OD.ORD_DT, 'D', OD.DLV_DT, 'C', OD.DLV_CDT, 'S', OD.STK_DT) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ORD_DIV IS NULL OR OH.ORD_DIV = :PSV_ORD_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_VENDOR_CD IS NULL OR I.VENDOR_CD = :PSV_VENDOR_CD) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (OD.ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY OH.ORD_DT                ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY OH.ORD_DT                ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_ORD_FG, PSV_DT_TP, PSV_GFR_DATE, PSV_GTO_DATE, PSV_ORD_DIV, PSV_ORD_DIV, PSV_VENDOR_CD, PSV_VENDOR_CD, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

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
        PSV_DT_TP       IN  VARCHAR2 ,                -- 일자구분
        PSV_ORD_FG      IN  VARCHAR2 ,                -- 주문구분
        PSV_ORD_DIV     IN  VARCHAR2 ,                -- 주문유형
        PSV_ITEM_TXT    IN  VARCHAR2 ,                -- 상품코드/명
        PSV_VENDOR_CD   IN  VARCHAR2 ,                -- 공급업체코드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03     주문현황(점포) - 상품별
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
    ls_sql_main     VARCHAR2(30000);
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OD.ITEM_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ITEM_NM)      AS ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_QTY , 0))     AS ORD_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_AMT , 0))     AS ORD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_VAT , 0))     AS ORD_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_QTY , 0))     AS DLV_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_AMT , 0))     AS DLV_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_VAT , 0))     AS DLV_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CQTY, 0))     AS ORD_CQTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CAMT, 0))     AS ORD_CAMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CVAT, 0))     AS ORD_CVAT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_QTY , 0))     AS RJT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_AMT , 0))     AS RJT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_VAT , 0))     AS RJT_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CQTY, 0))     AS RJT_CQTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CAMT, 0))     AS RJT_CAMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CVAT, 0))     AS RJT_CVAT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ORDER_HDV   OH              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ORDER_DTV   OD              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I               ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  OH.COMP_CD  = OD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_NO   = OD.ORD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_FG   = :PSV_ORD_FG   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DECODE(:PSV_DT_TP, 'O', OD.ORD_DT, 'D', OD.DLV_DT, 'C', OD.DLV_CDT, 'S', OD.STK_DT) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ORD_DIV IS NULL OR OH.ORD_DIV = :PSV_ORD_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_VENDOR_CD IS NULL OR I.VENDOR_CD = :PSV_VENDOR_CD) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (OD.ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY OD.ITEM_CD               ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY MAX(I.L_SORT_ORDER), MAX(I.L_CLASS_CD), MAX(I.M_SORT_ORDER), MAX(I.M_CLASS_CD), MAX(I.S_SORT_ORDER), MAX(I.S_CLASS_CD), OD.ITEM_CD   ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_ORD_FG, PSV_DT_TP, PSV_GFR_DATE, PSV_GTO_DATE, PSV_ORD_DIV, PSV_ORD_DIV, PSV_VENDOR_CD, PSV_VENDOR_CD, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

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

    PROCEDURE SP_TAB04
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
        PSV_DT_TP       IN  VARCHAR2 ,                -- 일자구분
        PSV_ORD_FG      IN  VARCHAR2 ,                -- 주문구분
        PSV_ORD_DIV     IN  VARCHAR2 ,                -- 주문유형
        PSV_ITEM_TXT    IN  VARCHAR2 ,                -- 상품코드/명
        PSV_VENDOR_CD   IN  VARCHAR2 ,                -- 공급업체코드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB04     주문현황(점포) - 거래처별
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB04
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  OD.VENDOR_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(V.VENDOR_NM)    AS VENDOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_QTY , 0))     AS ORD_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_AMT , 0))     AS ORD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_VAT , 0))     AS ORD_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_QTY , 0))     AS DLV_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_AMT , 0))     AS DLV_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.DLV_VAT , 0))     AS DLV_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CQTY, 0))     AS ORD_CQTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CAMT, 0))     AS ORD_CAMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '1', OD.ORD_CVAT, 0))     AS ORD_CVAT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_QTY , 0))     AS RJT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_AMT , 0))     AS RJT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_VAT , 0))     AS RJT_VAT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CQTY, 0))     AS RJT_CQTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CAMT, 0))     AS RJT_CAMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(OD.ORD_FG, '2', OD.ORD_CVAT, 0))     AS RJT_CVAT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ORDER_HDV   OH              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ORDER_DTV   OD              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_CD                   AS VENDOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.STOR_NM, S.STOR_NM)   AS VENDOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE   S       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COMMON  C       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STOR_NM         ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  LANG_STORE      ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )       L       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  S.COMP_CD   = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.STOR_TP   = C.CODE_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.COMP_CD   = L.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.BRAND_CD  = L.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.STOR_CD   = L.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  C.CODE_TP   = '00565'       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  INSTR('V', C.VAL_C1, 1) > 0 ]'
        ||CHR(13)||CHR(10)||Q'[         )       V                   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  OH.COMP_CD  = OD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_NO   = OD.ORD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.COMP_CD  = V.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.VENDOR_CD= V.VENDOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_FG   = :PSV_ORD_FG   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DECODE(:PSV_DT_TP, 'O', OD.ORD_DT, 'D', OD.DLV_DT, 'C', OD.DLV_CDT, 'S', OD.STK_DT) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ORD_DIV IS NULL OR OH.ORD_DIV = :PSV_ORD_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_VENDOR_CD IS NULL OR I.VENDOR_CD = :PSV_VENDOR_CD) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (OD.ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY OD.VENDOR_CD             ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY OD.VENDOR_CD             ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_ORD_FG, PSV_DT_TP, PSV_GFR_DATE, PSV_GTO_DATE, PSV_ORD_DIV, PSV_ORD_DIV, PSV_VENDOR_CD, PSV_VENDOR_CD, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

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

    PROCEDURE SP_TAB05
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
        PSV_DT_TP       IN  VARCHAR2 ,                -- 일자구분
        PSV_ORD_FG      IN  VARCHAR2 ,                -- 주문구분
        PSV_ORD_DIV     IN  VARCHAR2 ,                -- 주문유형
        PSV_ITEM_TXT    IN  VARCHAR2 ,                -- 상품코드/명
        PSV_VENDOR_CD   IN  VARCHAR2 ,                -- 공급업체코드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB05     주문현황(점포) - 상세조회
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB05
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  OH.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.ORD_NO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.ORD_DT     , NULL)    AS ORD_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.ORD_FG       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.ORD_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.CFM_FG       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(OH.CFM_DT, 'YYYYMMDD')                  AS CFM_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.REMARKS                                      AS HD_REMARKS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OD.ORD_SEQ      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OD.ITEM_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  F.CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.COST_VAT_YN   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.COST_VAT_RULE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.COST_VAT_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OD.ORD_UNIT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OD.ORD_UNIT_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OD.ORD_COST     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.ORD_QTY    , 0)       AS ORD_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.ORD_AMT    , 0)       AS ORD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.ORD_VAT    , 0)       AS ORD_VAT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.REMARKS    , NULL)    AS REMARKS      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.ORD_CQTY   , 0)       AS ORD_CQTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.ORD_CAMT   , 0)       AS ORD_CAMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.ORD_CVAT   , 0)       AS ORD_CVAT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.ORD_REMARKS, NULL)    AS ORD_REMARKS  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OD.VENDOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.DLV_DT     , NULL)    AS DLV_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.STK_DT     , NULL)    AS STK_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.DLV_QTY    , 0)       AS DLV_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.DLV_AMT    , 0)       AS DLV_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.DLV_VAT    , 0)       AS DLV_VAT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.DLV_CDT    , NULL)    AS DLV_CDT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '1', OD.DLV_REMARKS, NULL)    AS DLV_REMARKS  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  VS.VENDOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.ORD_DT     , NULL)    AS RJT_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.ORD_QTY    , 0)       AS RJT_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.ORD_AMT    , 0)       AS RJT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.ORD_VAT    , 0)       AS RJT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.REMARKS    , NULL)    AS RJT_REMARKS  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.STK_DT     , NULL)    AS RJT_CDT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.ORD_CQTY   , 0)       AS RJT_CQTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.ORD_CAMT   , 0)       AS RJT_CAMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.ORD_CVAT   , 0)       AS RJT_CVAT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(OD.ORD_FG, '2', OD.DLV_REMARKS, NULL)    AS RJT_CREMARKS ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(SU.USER_NM, HU.USER_NM)                     AS INST_USER    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(OD.INST_DT, 'YYYY-MM-DD HH24:MI:SS')    AS INST_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN OH.ORD_DIV = '0' AND OH.CFM_FG = '0'  THEN '00'       ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN OH.ORD_DIV = '0' AND OH.CFM_FG = '1' AND OD.DLV_CDT IS NULL AND OD.STK_DT IS NULL     THEN '10'   ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN OH.ORD_DIV = '0' AND OH.CFM_FG = '1' AND OD.DLV_CDT IS NOT NULL AND OD.STK_DT IS NULL THEN '20'   ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN OH.ORD_DIV = '0' AND OH.CFM_FG = '1' AND OD.DLV_CDT IS NULL AND OD.STK_DT IS NOT NULL THEN '30'   ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN OH.ORD_DIV = '0' AND OH.CFM_FG = '1' AND OD.DLV_CDT IS NOT NULL AND OD.STK_DT IS NOT NULL THEN '30'   ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN OH.ORD_DIV IN ('1', '9')                                                              THEN '30'   ]'
        ||CHR(13)||CHR(10)||Q'[         END                                             AS ORD_STAT     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ORDER_HDV   OH              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ORDER_DTV   OD              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_CD                   AS VENDOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.STOR_NM, S.STOR_NM)   AS VENDOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE   S       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COMMON  C       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STOR_NM         ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  LANG_STORE      ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )       L       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  S.COMP_CD   = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.STOR_TP   = C.CODE_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.COMP_CD   = L.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.BRAND_CD  = L.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.STOR_CD   = L.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  C.CODE_TP   = '00565'       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  INSTR('V', C.VAL_C1, 1) > 0 ]'
        ||CHR(13)||CHR(10)||Q'[         )       VS                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  F.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  F.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(F.CLASS_CD)     AS CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(FC.CLASS_NM)    AS CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  F.ITEM_CD           ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  ORDER_FAVORITE  F   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  FC.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  FC.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  FC.CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  NVL(L.LANG_NM, FC.CLASS_NM) AS CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ORDER_FAVORITE_CLASS    FC  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  LANG_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  TABLE_NM    = 'ORDER_FAVORITE_CLASS'    ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  COL_NM      = 'CLASS_NM'    ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                                 )                       L               ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  L.COMP_CD(+) = FC.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  L.PK_COL(+)  = LPAD(FC.BRAND_CD, 4, ' ')||LPAD(FC.CLASS_CD, 10, ' ')    ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  FC.COMP_CD   = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  FC.USE_YN    = 'Y'          ]'
        ||CHR(13)||CHR(10)||Q'[                     )   FC  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  F.COMP_CD   = FC.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  F.BRAND_CD  = FC.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  F.CLASS_CD  = FC.CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  F.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  F.USE_YN    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY F.COMP_CD, F.BRAND_CD, F.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[         )   F                       ]'
        ||CHR(13)||CHR(10)||Q'[     ,   (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SU.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SU.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SU.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SU.USER_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, SU.USER_NM)  AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_USER  SU  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = SU.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(SU.BRAND_CD, 4, ' ')||LPAD(SU.STOR_CD, 10, ' ')||LPAD(SU.USER_ID, 15, ' ')   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SU.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'STORE_USER'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         ) SU                        ]'
        ||CHR(13)||CHR(10)||Q'[     ,   (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  HU.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  HU.USER_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, HU.USER_NM)  AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  HQ_USER     HU  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = HU.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(HU.USER_ID, 15, ' ')   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  HU.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'HQ_USER'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         ) HU                        ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  OH.COMP_CD  = OD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_NO   = OD.ORD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.COMP_CD  = VS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.VENDOR_CD= VS.VENDOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  I.COMP_CD   = F.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  I.ITEM_CD   = F.ITEM_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.COMP_CD  = SU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.BRAND_CD = SU.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.STOR_CD  = SU.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.INST_USER= SU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.COMP_CD  = HU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OD.INST_USER= HU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OH.ORD_FG   = :PSV_ORD_FG   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DECODE(:PSV_DT_TP, 'O', OD.ORD_DT, 'D', OD.DLV_DT, 'C', OD.DLV_CDT, 'S', OD.STK_DT) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ORD_DIV IS NULL OR OH.ORD_DIV = :PSV_ORD_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_VENDOR_CD IS NULL OR I.VENDOR_CD = :PSV_VENDOR_CD) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (OD.ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY OH.STOR_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OH.ORD_DT DESC              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_SORT_ORDER              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_SORT_ORDER              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_SORT_ORDER              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OD.ITEM_CD                  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD
                       , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD
                       , PSV_COMP_CD, PSV_LANG_CD
                       , PSV_COMP_CD, PSV_LANG_CD
                       , PSV_COMP_CD, PSV_ORD_FG, PSV_DT_TP, PSV_GFR_DATE, PSV_GTO_DATE, PSV_ORD_DIV, PSV_ORD_DIV, PSV_VENDOR_CD, PSV_VENDOR_CD, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

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

END PKG_ORDR1230;

/
