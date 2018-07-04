--------------------------------------------------------
--  DDL for Package Body PKG_SALE1120
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1120" AS

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
    )   IS
    /******************************************************************************
        NAME:       SP_MAIN       세트상품 선호도 붆석(세트상품) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.ITEM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SALE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DC_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.VAT_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.ITEM_CD                                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.ITEM_NM)                  AS ITEM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_QTY)                AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)                AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.DC_AMT + ENR_AMT)        AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND  I.SET_DIV = '1'     ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.ITEM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         )   S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.SALE_QTY > 0                  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.SALE_QTY DESC, S.ITEM_CD   ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING  PSV_COMP_CD
                        , PSV_GFR_DATE, PSV_GTO_DATE
                        ;

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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_ITEM_CD     IN  VARCHAR2 ,                -- 조회 상품코드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_SUB       세트상품 선호도 붆석(옵션상품) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.ITEM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SALE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DC_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.VAT_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SD.ITEM_CD                                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.ITEM_NM)                  AS ITEM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.SALE_QTY)                AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.SALE_AMT)                AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.DC_AMT + SD.ENR_AMT)     AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.GRD_AMT)                 AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.VAT_AMT)                 AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.GRD_AMT - SD.VAT_AMT)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SALE_DT         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  POS_NO          ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  BILL_NO         ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  SALE_DT SD      ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ITEM_CD = :PSV_ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO ]' 
        ||CHR(13)||CHR(10)||Q'[                     )           A   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SALE_DT     SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  O.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  O.ITEM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  SET_RULE    S   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  OPTION_ITEM O   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  S.COMP_CD   = O.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.BRAND_CD  = O.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.OPTN_ITEM_CD  = O.OPT_GRP ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.ITEM_CD   = :PSV_ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.USE_YN    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY O.COMP_CD, O.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                      )          OI  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  A.COMP_CD   = SD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.SALE_DT   = SD.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.BRAND_CD  = SD.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.STOR_CD   = SD.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.POS_NO    = SD.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.BILL_NO   = SD.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD  = OI.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_CD  = OI.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.MAIN_ITEM_CD = :PSV_ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.T_SEQ   <> '0'           ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.FREE_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SD.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         )   S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.SALE_QTY > 0                  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.SALE_QTY DESC, S.ITEM_CD   ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_ITEM_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_ITEM_CD, PSV_ITEM_CD;

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

END PKG_SALE1120;

/
