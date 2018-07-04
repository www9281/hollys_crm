--------------------------------------------------------
--  DDL for Package Body PKG_SALE1340
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1340" AS

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
        PSV_USER_DIV    IN  VARCHAR2 ,                -- 사용자구분
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     복지포인트 집계현황
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-11-07         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2017-11-07
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  UD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  UD.USER_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  UD.USER_ID      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CASE WHEN UD.USER_DIV = '1' THEN HU.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  WHEN UD.USER_DIV = '2' THEN SU.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ELSE ''                                ]'
        ||CHR(13)||CHR(10)||Q'[             END)                AS USER_NM              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(UD.DC_LIMIT)        AS DC_LIMIT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(UD.DC_USE_CNT)      AS DC_USE_CNT           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(UD.DC_USE_AMT)      AS DC_USE_AMT           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(UD.DC_CANCEL_CNT)   AS DC_CANCEL_CNT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(UD.DC_CANCEL_AMT)   AS DC_CANCEL_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(UD.DC_LIMIT) - (SUM(UD.DC_USE_AMT) - SUM(UD.DC_CANCEL_AMT)) AS DC_REMAIN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  USER_DC_016     UD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  U.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, U.USER_NM)   AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  HQ_USER     U   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = U.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(U.USER_ID, 15, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.COMP_CD       = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'HQ_USER'                 ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'USER_NM'                 ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'                       ]'
        ||CHR(13)||CHR(10)||Q'[         )   HU          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  U.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(NVL(L.LANG_NM, U.USER_NM))  AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_USER  U   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(U.BRAND_CD, 4, ' ')||LPAD(U.STOR_CD, 10, ' ')||LPAD(U.USER_ID, 15, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'STORE_USER'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY U.COMP_CD, U.USER_ID         ]'
        ||CHR(13)||CHR(10)||Q'[         )   SU          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  UD.COMP_CD  = HU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  UD.USER_ID  = HU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  UD.COMP_CD  = SU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  UD.USER_ID  = SU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  UD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  UD.DC_DT    BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_USER_DIV IS NULL OR UD.USER_DIV = :PSV_USER_DIV)  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY UD.COMP_CD, UD.USER_DIV, UD.USER_ID  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY UD.COMP_CD, UD.USER_DIV, UD.USER_ID  ]'  
        ;

        dbms_output.put_line(ls_sql_main);

        OPEN PR_RESULT FOR
            ls_sql_main USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_USER_DIV, PSV_USER_DIV;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

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

END PKG_SALE1340;

/
