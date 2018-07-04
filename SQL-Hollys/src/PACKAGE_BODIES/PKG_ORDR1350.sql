--------------------------------------------------------
--  DDL for Package Body PKG_ORDR1350
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ORDR1350" AS

    PROCEDURE SP_TAB01    /* 자재별 */
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
        PSV_BRAND_CD    IN  VARCHAR2 ,                -- 브랜드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01        사입점검 - 자재별탭
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-11-21         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2017-11-21
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  OI.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.STOR_TP      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.ITEM_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  OI.STOCK_UNIT_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(OI.ORD_QTY, 0)  AS ORD_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(SI.USE_QTY, 0)  AS USE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN NVL(SI.USE_QTY, 0) = 0 THEN 0 ELSE ROUND(NVL(OI.ORD_QTY, 0) / NVL(SI.USE_QTY, 0) * 100, 2) END    AS RATO ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  OD.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  OD.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)         AS BRAND_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_TP   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  OD.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.STOR_NM)          AS STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.L_CLASS_CD)       AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.L_CLASS_NM)       AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.L_SORT_ORDER)     AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.M_CLASS_CD)       AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.M_CLASS_NM)       AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.M_SORT_ORDER)     AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.S_CLASS_CD)       AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.S_CLASS_NM)       AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.S_SORT_ORDER)     AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  OD.ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.ITEM_NM)          AS ITEM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(I.STOCK_UNIT_NM)    AS STOCK_UNIT_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM((CASE WHEN OD.ORD_FG = '1' THEN NVL(OD.ORD_CQTY, 0) ELSE -1 * NVL(OD.ORD_CQTY, 0) END) * NVL(OD.ORD_UNIT_QTY, 1))  AS ORD_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  ORDER_DTV       OD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM          I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  OD.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  OD.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  OD.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  OD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  OD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  OD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  OD.STK_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY OD.COMP_CD, OD.BRAND_CD, S.STOR_TP, OD.STOR_CD, OD.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         )   OI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  R.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  R.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_TP   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  R.C_ITEM_CD     AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.SALE_QTY, 0) * NVL(R.DO_QTY, 0))     AS USE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  TABLE(FN_RCP_STD_0073(:PSV_COMP_CD, :PSV_BRAND_CD, :PSV_GTO_DATE))  R   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ITEM        I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  R.COMP_CD   = SJ.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  R.BRAND_CD  = SJ.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  R.R_ITEM_CD = SJ.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  R.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY R.COMP_CD, R.BRAND_CD, S.STOR_TP, SJ.STOR_CD, R.C_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         )   SI  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  OI.COMP_CD  = SI.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OI.BRAND_CD = SI.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  OI.STOR_CD  = SI.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  OI.ITEM_CD  = SI.ITEM_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY OI.COMP_CD, OI.BRAND_CD, OI.STOR_CD, OI.L_SORT_ORDER, OI.L_CLASS_CD, OI.M_SORT_ORDER, OI.M_CLASS_CD, OI.S_SORT_ORDER, OI.S_CLASS_CD, OI.ITEM_CD]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_BRAND_CD, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_TAB02    /* 메뉴/자재별 */
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
        PSV_BRAND_CD    IN  VARCHAR2 ,                -- 브랜드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     사입점검 - 메뉴/자재별
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-11-21         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2017-11-21
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  R.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)   AS STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R.R_ITEM_CD         AS R_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(RI.ITEM_NM)     AS R_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)    AS SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)     AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R.C_ITEM_CD         AS C_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CI.ITEM_NM)     AS C_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CI.DO_UNIT_NM)  AS DO_UNIT_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SJ.SALE_QTY, 0) * NVL(R.DO_QTY, 0))   AS USE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  TABLE(FN_RCP_STD_0073(:PSV_COMP_CD, :PSV_BRAND_CD, :PSV_GTO_DATE))  R   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      RI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      CI  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  R.COMP_CD   = SJ.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  R.BRAND_CD  = SJ.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  R.R_ITEM_CD = SJ.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  R.COMP_CD   = RI.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  R.R_ITEM_CD = RI.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  R.COMP_CD   = CI.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  R.C_ITEM_CD = CI.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  R.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY R.COMP_CD, R.BRAND_CD, S.STOR_TP, SJ.STOR_CD, R.R_ITEM_CD, R.C_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY R.COMP_CD, R.BRAND_CD, SJ.STOR_CD, R.R_ITEM_CD, R.C_ITEM_CD  ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_BRAND_CD, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_ORDR1350;

/
