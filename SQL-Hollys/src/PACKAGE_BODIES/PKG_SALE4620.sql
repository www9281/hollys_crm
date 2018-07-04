--------------------------------------------------------
--  DDL for Package Body PKG_SALE4620
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4620" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                  -- 조회 종료일자
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,    -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_MAIN   터치키 매출현황
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2014-02-11         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_MAIN
          SYSDATE:         2014-02-13
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
        ls_sql          VARCHAR2(30000) ;
        ls_sql_main     VARCHAR2(30000) ;

        ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
        ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
        ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
        ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
        ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
        ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

        ls_err_cd     VARCHAR2(7) := '0' ;
        ls_err_msg    VARCHAR2(500) ;

        ERR_HANDLER   EXCEPTION;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  T.TOUCH_GR_CD                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(T.TOUCH_GR_NM)              AS TOUCH_GR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(T.G_POSITION)               AS G_POSITION   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD                                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(T.TOUCH_NM)                 AS ITEM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(T.M_POSITION)               AS M_POSITION   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)     AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDM    SJ                              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  G.COMP_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  G.BRAND_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  G.STOR_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  G.TOUCH_GR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(GL.LANG_NM, G.TOUCH_NM) AS TOUCH_GR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  G.POSITION  AS G_POSITION       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.TOUCH_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.ITEM_NM   AS TOUCH_NM         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.POSITION  AS M_POSITION       ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (                               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  T.*                 ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  TOUCH_STORE_UI  T   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  T.COMP_CD   = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  T.BRAND_CD  = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  T.STOR_CD   = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  T.TOUCH_TP  = 'G'       ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  T.USE_YN    = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[                     )   G           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  T.*                 ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  TOUCH_STORE_UI  T   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  T.COMP_CD   = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  T.BRAND_CD  = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  T.STOR_CD   = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  T.TOUCH_TP  = 'M'       ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  T.USE_YN    = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[                     )   M           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PK_COL              ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  LANG_NM             ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  LANG_TABLE          ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  TABLE_NM    = 'TOUCH_STORE_UI'  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  COL_NM      = 'TOUCH_NM'        ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[                     )   GL          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM  I       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  G.COMP_CD     = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  G.BRAND_CD    = M.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  G.STOR_CD     = M.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  G.TOUCH_GR_CD = M.TOUCH_GR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  G.TOUCH_DIV   = M.TOUCH_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  GL.COMP_CD(+) = G.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  GL.PK_COL(+)  = LPAD(G.BRAND_CD, 4, ' ')||LPAD(G.STOR_CD, 10, ' ')||G.TOUCH_DIV||LPAD(G.TOUCH_GR_CD, 10, ' ')||LPAD(G.TOUCH_CD ,10 ,' ')    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD     = I.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.TOUCH_CD    = I.ITEM_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[         )   T                       ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = T.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = T.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = T.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = T.TOUCH_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY T.TOUCH_GR_CD            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY MAX(T.G_POSITION)        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(T.M_POSITION)           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD                  ]'
        ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
           ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
           dbms_output.put_line( PR_RTN_MSG ) ;
           EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END ;

END PKG_SALE4620;

/
