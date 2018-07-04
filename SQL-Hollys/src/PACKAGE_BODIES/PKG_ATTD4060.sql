--------------------------------------------------------
--  DDL for Package Body PKG_ATTD4060
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ATTD4060" AS

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
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_MAIN     출퇴근 현황(직원별)
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_MAIN
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            USER_ID     VARCHAR2(15)
        ,   USER_NM     VARCHAR2(60)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd;

    V_CROSSTAB          VARCHAR2(30000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);
    V_CNT               PLS_INTEGER;
    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000);
    ls_sql_main         VARCHAR2(10000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);

        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    --||  ', '
                    --||  ls_sql_item  -- S_ITEM
                    ;


        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  A.USER_ID                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(NVL(L.LANG_NM, SU.USER_NM)) AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ATTENDANCE  A                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STORE_USER  SU                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PK_COL                      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_NM                     ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  LANG_TABLE                  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  TABLE_NM    = 'STORE_USER'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  COL_NM      = 'YSER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   L                                   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  A.COMP_CD   = S.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD  = S.BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD   = S.STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD   = SU.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD  = SU.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD   = SU.STOR_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.USER_ID   = SU.USER_ID                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  L.COMP_CD(+)= SU.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  L.PK_COL(+) = LPAD(SU.BRAND_CD, 4, ' ')||LPAD(SU.STOR_CD, 10, ' ')||LPAD(SU.USER_ID, 15, ' ')   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD   = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.ATTD_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY A.USER_ID                            ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY A.USER_ID                            ]';

        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ATTD_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ATTD_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).USER_ID || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || '[' || qry_hd(i).USER_ID || ']' || qry_hd(i).USER_NM     || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || '[' || qry_hd(i).USER_ID || ']' || qry_hd(i).USER_NM     || Q'[' AS CT]' || TO_CHAR(i*4 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || '[' || qry_hd(i).USER_ID || ']' || qry_hd(i).USER_NM     || Q'[' AS CT]' || TO_CHAR(i*4 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || '[' || qry_hd(i).USER_ID || ']' || qry_hd(i).USER_NM     || Q'[' AS CT]' || TO_CHAR(i*4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'REGULAR_HM')  || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MIDNIGHT_HM') || Q'[' AS CT]' || TO_CHAR(i*4 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'OVER_HM')     || Q'[' AS CT]' || TO_CHAR(i*4 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CONFIRM_HM')  || Q'[' AS CT]' || TO_CHAR(i*4);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  A.ATTD_DT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(ROUND(SUM(CASE WHEN R_NUM = 1 THEN DAY_OF_MINUTE ELSE 0 END) OVER (PARTITION BY  BRAND_CD, STOR_CD, ATTD_DT) / 60, 0))   AS CONFIRM_THM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM((DAY_OF_MINUTE - MID_OF_MINUTE) / 60)    AS REGULAR_HM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(MID_OF_MINUTE / 60)                      AS MIDNIGHT_HM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN DAY_OF_MINUTE < (8 * 60 * 60) THEN '00:00' ELSE FN_GET_FROMAT_HHMM(ROUND((DAY_OF_MINUTE - (8 * 60 * 60)) / 60, 0)) END            AS OVER_HM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(ROUND(DAY_OF_MINUTE / 60, 0))            AS CONFIRM_HM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  A.BRAND_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM                              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_CD                               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM                               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  A.ATTD_DT                               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  A.USER_ID                               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, SU.USER_NM)  AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM((TO_DATE(CASE WHEN NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) < NVL(CONFIRM_START_DTM, WORK_START_DTM) THEN NVL(CONFIRM_START_DTM, WORK_START_DTM) ELSE NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) END,'YYYYMMDDHH24MISS') - TO_DATE(NVL(A.CONFIRM_START_DTM, A.WORK_START_DTM),'YYYYMMDDHH24MISS')) * 24 * 60 * 60)    ]'
        ||CHR(13)||CHR(10)||Q'[                     OVER(PARTITION BY A.BRAND_CD, A.STOR_CD, A.USER_ID, A.ATTD_DT)      AS DAY_OF_MINUTE    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(FN_GET_MIDNIGHT_WT(NVL(A.CONFIRM_START_DTM, A.WORK_START_DTM), CASE WHEN NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) < NVL(CONFIRM_START_DTM, WORK_START_DTM) THEN NVL(CONFIRM_START_DTM, WORK_START_DTM) ELSE NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) END))  ]'
        ||CHR(13)||CHR(10)||Q'[                     OVER(PARTITION BY A.BRAND_CD, A.STOR_CD, A.USER_ID, A.ATTD_DT)      AS MID_OF_MINUTE    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ROW_NUMBER() OVER(PARTITION BY A.BRAND_CD, A.STOR_CD, A.USER_ID, A.ATTD_DT ORDER BY A.ATTD_SEQ) AS R_NUM    ]'  
        ||CHR(13)||CHR(10)||Q'[               FROM  ATTENDANCE  A                           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S                           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STORE_USER  SU                          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                                       ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PK_COL                      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  LANG_NM                     ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  LANG_TABLE                  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  TABLE_NM    = 'STORE_USER'  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  COL_NM      = 'YSER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )   L                                   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  A.COMP_CD   = S.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.BRAND_CD  = S.BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.STOR_CD   = S.STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.COMP_CD   = SU.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.BRAND_CD  = SU.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.STOR_CD   = SU.STOR_CD                ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.USER_ID   = SU.USER_ID                ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COMP_CD(+)= SU.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+) = LPAD(SU.BRAND_CD, 4, ' ')||LPAD(SU.STOR_CD, 10, ' ')||LPAD(SU.USER_ID, 15, ' ')   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.COMP_CD   = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                AND  A.ATTD_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )   A   ]';

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  *   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       MAX(REGULAR_HM)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , MAX(MIDNIGHT_HM)  AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , MAX(OVER_HM)      AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , MAX(CONFIRM_HM)   AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (USER_ID) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ATTD_DT ]';

        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_ATTD4060;

/
