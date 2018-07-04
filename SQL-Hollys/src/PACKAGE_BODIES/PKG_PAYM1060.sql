--------------------------------------------------------
--  DDL for Package Body PKG_PAYM1060
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_PAYM1060" AS

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
        NAME:       SP_MAIN      직영점 입금현황
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-02         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2018-01-02
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
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SC.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.CASH_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(SM.MOBILE_AMT, 0)                   AS MOBILE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.CASH_AMT + NVL(SM.MOBILE_AMT, 0)     AS CASH_TOTAL   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(SE.ETC_AMT, 0)                      AS ETC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.CASH_AMT + NVL(SM.MOBILE_AMT, 0) - NVL(SE.ETC_AMT, 0)    AS HQ_SEND_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(SR.RCP_AMT, 0)                      AS RCP_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SC.CASH_AMT + NVL(SM.MOBILE_AMT, 0) - NVL(SE.ETC_AMT, 0) - NVL(SR.RCP_AMT, 0)   AS DIFF_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.STOR_TP_NM)   AS STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.SV_USER_NM)   AS SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))   AS CASH_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.GIFT_DIV = '0'   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.PAY_DIV  IN ('10', '30') ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.SALE_DT, SJ.BRAND_CD, SJ.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         )   SC  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  ML.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ML.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ML.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ML.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN ML.RSV_DIV = '8' THEN -1*APPR_AMT ELSE APPR_AMT END)  AS MOBILE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MOBILE_LOG  ML  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  ML.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.RSV_DIV  IN ('8', '9')   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY ML.COMP_CD, ML.SALE_DT, ML.BRAND_CD, ML.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         )   SM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SE.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SE.PRC_DT   AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SE.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SE.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SE.ETC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_ETC_AMT_016   SE  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SE.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SE.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SE.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SE.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SE.PRC_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )   SE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SR.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  TO_CHAR(TO_DATE(SR.RCP_DT, 'YYYYMMDD') - 1, 'YYYYMMDD') AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SR.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SR.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SR.RCP_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_RCP_AMT_016   SR  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SR.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SR.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SR.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SR.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  TO_CHAR(TO_DATE(SR.RCP_DT, 'YYYYMMDD') - 1, 'YYYYMMDD') BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )   SR  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SC.COMP_CD      = SM.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.SALE_DT      = SM.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.BRAND_CD     = SM.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.STOR_CD      = SM.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.COMP_CD      = SE.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.SALE_DT      = SE.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.BRAND_CD     = SE.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.STOR_CD      = SE.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.COMP_CD      = SR.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.SALE_DT      = SR.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.BRAND_CD     = SR.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SC.STOR_CD      = SR.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SC.COMP_CD, SC.BRAND_CD, SC.STOR_CD, SC.SALE_DT  ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING  PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                       ,  PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                       ,  PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                       ,  PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_PAYM1060;

/
