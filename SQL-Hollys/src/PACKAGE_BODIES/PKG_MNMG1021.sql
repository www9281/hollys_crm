--------------------------------------------------------
--  DDL for Package Body PKG_MNMG1021
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MNMG1021" AS

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
        PSV_USER_TXT    IN  VARCHAR2 ,                -- 사용자ID/명
        PSV_PROG_TXT    IN  VARCHAR2 ,                -- 프로그램명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN          사용자 페이지 접속기록[본사]
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-10-27         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2017-10-27
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

        ls_sql := '';

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  PUH.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PUH.USE_DTM             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(PUH.USE_DTM, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS')  AS USE_DTM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PUH.BRAND_CD            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PUH.USER_ID             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PUH.USER_NM             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PUH.IP                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PUH.MENU_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M.MENU_NM               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M.PROG_NM               ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (                       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  PUH.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PUH.USE_DTM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PUH.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PUH.USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  HU.USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PUH.IP      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PUH.MENU_CD ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  PROGRAM_USE_HIS     PUH ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                       ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  B.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  B.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  NVL(L.LANG_NM, B.BRAND_NM) AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  BRAND       B   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  LANG_TABLE  L   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  L.COMP_CD(+)    = B.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  L.PK_COL(+)     = LPAD(B.BRAND_CD, 4, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  B.COMP_CD       = :PSV_COMP_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[                            AND  L.TABLE_NM(+)   = 'BRAND'       ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  L.COL_NM(+)     = 'BRAND_NM'    ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )   B       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                       ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  U.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  U.USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  NVL(L.LANG_NM, U.USER_NM)   AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  HQ_USER     U   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  LANG_TABLE  L   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  L.COMP_CD(+)    = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  L.PK_COL(+)     = LPAD(U.USER_ID, 15, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  U.COMP_CD       = :PSV_COMP_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[                            AND  L.TABLE_NM(+)   = 'HQ_USER'  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  L.COL_NM(+)     = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )   HU      ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  PUH.COMP_CD     = B.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PUH.BRAND_CD    = B.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PUH.COMP_CD     = HU.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PUH.USER_ID     = HU.USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PUH.COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SUBSTR(PUH.USE_DTM, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PUH.STOR_CD IS NULL             ]'
        ||CHR(13)||CHR(10)||Q'[         )   PUH     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  M.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MENU_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, M.MENU_NM)   AS MENU_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN M.MENU_CD = 99999           THEN 'LOGIN'  ]' 
        ||CHR(13)||CHR(10)||Q'[                          WHEN INSTR(M.PROG_NM, 'jsp') > 0 THEN SUBSTR(M.PROG_NM, INSTR(M.PROG_NM, '.jsp') - 10, 10) ]' 
        ||CHR(13)||CHR(10)||Q'[                          ELSE ''    ]'
        ||CHR(13)||CHR(10)||Q'[                     END                         AS PROG_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  W_MENU      M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(M.MENU_CD, 5, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD       = :PSV_COMP_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'W_MENU'      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'MENU_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   M           ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  PUH.COMP_CD     = M.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PUH.MENU_CD     = M.MENU_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_USER_TXT IS NULL OR (PUH.USER_ID LIKE '%'||:PSV_USER_TXT||'%' OR PUH.USER_NM LIKE '%'||:PSV_USER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_PROG_TXT IS NULL OR (M.MENU_NM   LIKE '%'||:PSV_PROG_TXT||'%' OR M.MENU_NM   LIKE '%'||:PSV_PROG_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY PUH.USE_DTM  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                       , PSV_COMP_CD, PSV_LANG_CD, PSV_USER_TXT, PSV_USER_TXT, PSV_USER_TXT, PSV_PROG_TXT, PSV_PROG_TXT, PSV_PROG_TXT;

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

END PKG_MNMG1021;

/
