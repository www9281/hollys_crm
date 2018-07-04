--------------------------------------------------------
--  DDL for Package Body PKG_SALE1360
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1360" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회종료일자
        PSV_POS_NO      IN  VARCHAR2 ,                -- 포스번호
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     매출 취소 현황
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-13         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2017-12-13
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

    ls_sql_cm_00435 VARCHAR2(1000) ;    -- 공통코드SQL
    ls_sql_cm_00440 VARCHAR2(1000) ;    -- 공통코드SQL

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00435') ;
        ls_sql_cm_00440 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00440') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_NM       AS SALE_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D.CODE_NM       AS GIFT_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_TM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.RTN_MEMO ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.DC_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.CUST_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.CARD_ID  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SAV_MLG  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_10_AMT + SS.PAY_30_AMT   AS PAY_10_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_20_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_40_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_50_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_62_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_68_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_70_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_71_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_72_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_73_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_74_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_75_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_76_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_77_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_83_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_93_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_94_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (             ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SH.COMP_CD, SH.SALE_DT, SH.BRAND_CD, S.BRAND_NM, SH.STOR_CD, S.STOR_NM, SH.POS_NO, SH.BILL_NO, SH.SALE_DIV, SH.SALE_TM, SH.RTN_MEMO ,SH.GIFT_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SALE_AMT                                 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.GRD_I_AMT   + SH.GRD_O_AMT   AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.DC_AMT      + SH.ENR_AMT     AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SDC.DC_NM                       AS DC_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (SH.CUST_M_CNT + SH.CUST_F_CNT) AS CUST_CNT ]' 
        ||CHR(13)||CHR(10)||Q'[                  ,  DECRYPT(CUST_NM)                AS CUST_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.CARD_ID ]'          
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SAV_PT  ]'          
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SAV_MLG ]'          
        ||CHR(13)||CHR(10)||Q'[                  ,  (SH.GRD_I_AMT + SH.GRD_O_AMT) - (SH.VAT_I_AMT + SH.VAT_O_AMT) AS NET_AMT, (SH.VAT_I_AMT + SH.VAT_O_AMT) AS VAT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  , (   SELECT  B.DC_NM, A.COMP_CD, A.SALE_DT, A.BRAND_CD, A.STOR_CD, A.POS_NO, A.BILL_NO ]'
        ||CHR(13)||CHR(10)||Q'[                        FROM    SALE_DC A, DC B ]'
        ||CHR(13)||CHR(10)||Q'[                        WHERE   A.COMP_CD  = B.COMP_CD(+) AND  A.BRAND_CD = B.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[                          AND   A.DC_DIV   = B.DC_DIV(+)  AND  A.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          AND   A.SALE_DIV = '2'          AND  A.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                     ) SDC  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SH.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_POS_NO   IS NULL OR SH.POS_NO   = :PSV_POS_NO)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_GIFT_DIV IS NULL OR SH.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD  = SDC.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DT  = SDC.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD = SDC.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD  = SDC.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.POS_NO   = SDC.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BILL_NO  = SDC.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DIV = '2' ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         ORDER  BY SH.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[             ,  SH.SALE_DT       ]'
        ||CHR(13)||CHR(10)||Q'[             ,  SH.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[             ,  SH.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[             ,  SH.SALE_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[             ,  SH.POS_NO        ]'
        ||CHR(13)||CHR(10)||Q'[             ,  SH.BILL_NO DESC  ]'
        ||CHR(13)||CHR(10)||Q'[         )   SH ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (      ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SS.COMP_CD, SS.SALE_DT, SS.BRAND_CD, SS.STOR_CD, SS.POS_NO, SS.BILL_NO, SS.GIFT_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_10_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_20_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_30_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_40_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_50_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '62', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_62_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_68_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_70_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '71', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_71_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '72', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_72_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '73', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_73_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '74', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_74_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '75', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_75_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '76', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_76_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '77', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_77_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_83_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_93_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '94', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_94_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ( NVL(SUM(DECODE(SS.PAY_DIV, '10', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '20', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '30', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '40', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '50', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '62', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '68', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '70', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '71', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '72', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '73', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '74', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '75', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '76', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '77', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '83', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '93', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0) ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '94', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_ST     SS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_POS_NO   IS NULL OR SS.POS_NO   = :PSV_POS_NO)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_GIFT_DIV IS NULL OR SS.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SS.COMP_CD, SS.BRAND_CD, SS.STOR_CD, SS.SALE_DT,SS.POS_NO, SS.BILL_NO, SS.GIFT_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SS          ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00435 || Q'[ C]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00440 || Q'[ D]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SH.COMP_CD  = SS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DT  = SS.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BRAND_CD = SS.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.STOR_CD  = SS.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.POS_NO   = SS.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BILL_NO  = SS.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DIV = C.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.GIFT_DIV = D.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DIV = '2'  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SH.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.POS_NO        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BILL_NO DESC  ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DIV      ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE , PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_POS_NO   , PSV_POS_NO   , PSV_GIFT_DIV, PSV_GIFT_DIV, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE , PSV_GTO_DATE , PSV_POS_NO  , PSV_POS_NO  , PSV_GIFT_DIV, PSV_GIFT_DIV  ;

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

END PKG_SALE1360;

/
