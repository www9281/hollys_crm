--------------------------------------------------------
--  DDL for Package Body PKG_CUST1040
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_CUST1040" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN      회원 등급/연령대 조회
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-22         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-03-22
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);

    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM

    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_sql_cm       VARCHAR2(1000) ;    -- 공통코드SQL
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    TYPE  rec_ct_hd IS RECORD
    (
            LVL_CD      VARCHAR2(10)
        ,   LVL_NM      VARCHAR2(100)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd;

    V_CROSSTAB          VARCHAR2(10000);
    V_CROSSFIELD        VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
            ||  ls_sql_store -- S_STORE
            ;

        /* 가로축 데이타 FETCH */
        ls_sql := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  LVL_CD                                    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(L.LANG_NM, CL.LVL_NM)    AS LVL_NM    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  C_CUST_LVL CL                             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                         ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  COMP_CD, PK_COL, LANG_NM      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  LANG_TABLE                    ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  COMP_CD     = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  TABLE_NM    = 'C_CUST_LVL'    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  COL_NM      = 'LVL_NM'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  LANGUAGE_TP = :PSV_LANG_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  USE_YN      = 'Y'             ]'
        ||CHR(13)||CHR(10)||Q'[         )   L                                     ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CL.COMP_CD||CL.LVL_CD = L.PK_COL(+)       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.COMP_CD  = :PSV_COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.USE_YN   = 'Y'                         ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY CL.LVL_RANK                            ]';

        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')       ]'; 

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')       ]'; 

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB  := V_CROSSTAB || Q'[, ]';
                END IF;
                V_CROSSTAB  := V_CROSSTAB  || Q'[']'  || qry_hd(i).LVL_CD || Q'[' AS LVL_]' || qry_hd(i).LVL_CD;
                V_CROSSFIELD:= V_CROSSFIELD
                || CHR(13)||CHR(10)||Q'[      ,  NVL(A.LVL_]' || qry_hd(i).LVL_CD || Q'[, 0) AS CNT_]' || qry_hd(i).LVL_CD 
                || CHR(13)||CHR(10)||Q'[      ,  NVL(ROUND((A.LVL_]' || qry_hd(i).LVL_CD || Q'[ / A.TOTAL) * 100, 2), 0) AS RATE_]' || qry_hd(i).LVL_CD ;

                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).LVL_NM  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).LVL_NM  || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMB_CUST_CNT') || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RATO') || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SEX_DIV')         ]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SEX_DIV')         ]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SEX_DIV')         ]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SEX_DIV')         ]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'LEAVE_MEMBER_CNT')]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL_MEMBER_CNT')]'        
        ||CHR(13)||CHR(10)||Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MAN_CNT')         ]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'RATO')            ]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'WOMAN_CNT')       ]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'RATO')            ]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'LEAVE_MEMBER_CNT')]'
        ||CHR(13)||CHR(10)||Q'[ ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL_MEMBER_CNT')]'        
        ||CHR(13)||CHR(10)||Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;


        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01760') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  C.CODE_NM                                           AS AGE_GROUP_NM]'
        ||V_CROSSFIELD
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(A.MAN_CNT,  0)                                  AS MAN_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(ROUND((A.MAN_CNT / A.TOTAL) * 100, 2), 0)       AS MAN_RATE]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(A.WOMAN_CNT, 0)                                 AS WOMAN_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(ROUND((A.WOMAN_CNT / A.TOTAL) * 100, 2), 0)     AS WOMAN_RATE]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(A.LEAVE_CNT, 0)                                 AS LEAVE_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(A.TOTAL, 0)                                     AS TOTAL]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ]' || ls_sql_cm || Q'[ C]'
        ||CHR(13)||CHR(10)||Q'[      ,  (]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  *]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  AGE_GROUP]'
        ||CHR(13)||CHR(10)||Q'[                              ,  LVL_CD]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CNT)       AS CNT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  MAX(MAN_CNT)   AS MAN_CNT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  MAX(WOMAN_CNT) AS WOMAN_CNT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  MAX(TOTAL)     AS TOTAL]'
        ||CHR(13)||CHR(10)||Q'[                              ,  MAX(LEAVE_CNT) AS LEAVE_CNT]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  C.AGE_GROUP]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  C.LVL_CD]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  CASE WHEN C.CUST_STAT <> '3' THEN 1 ELSE 0 END                           AS CNT]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(CASE WHEN C.SEX_DIV = 'M'  AND C.CUST_STAT <> '3' THEN 1 ELSE 0 END) OVER (PARTITION BY AGE_GROUP) AS MAN_CNT]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(CASE WHEN C.SEX_DIV = 'F'  AND C.CUST_STAT <> '3' THEN 1 ELSE 0 END) OVER (PARTITION BY AGE_GROUP) AS WOMAN_CNT]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(CASE WHEN C.CUST_STAT <> '3' THEN 1 ELSE 0 END)                      OVER (PARTITION BY AGE_GROUP) AS TOTAL]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(CASE WHEN C.CUST_STAT = '3'  THEN 1 ELSE 0 END)                      OVER (PARTITION BY AGE_GROUP) AS LEAVE_CNT]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  (]'
        ||CHR(13)||CHR(10)||Q'[                                                 SELECT  GET_AGE_GROUP(C.COMP_CD, CASE WHEN REGEXP_INSTR(CASE WHEN C.LUNAR_DIV = 'L' THEN UF_LUN2SOL(C.BIRTH_DT, '0') ELSE C.BIRTH_DT END, '^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])') = 1 THEN]'
        ||CHR(13)||CHR(10)||Q'[                                                                       TRUNC((SUBSTR(TO_CHAR(SYSDATE,'YYYYMMDD'), 1, 6) - SUBSTR(CASE WHEN C.LUNAR_DIV = 'L' THEN UF_LUN2SOL(C.BIRTH_DT, '0') ELSE C.BIRTH_DT END, 1, 6)) / 100 + 1)]'
        ||CHR(13)||CHR(10)||Q'[                                                            ELSE 999 END) as AGE_GROUP]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  C.LVL_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  C.SEX_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  C.CUST_STAT     ]'
        ||CHR(13)||CHR(10)||Q'[                                                 FROM    C_CUST   C      ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  S_STORE  S      ]'
        ||CHR(13)||CHR(10)||Q'[                                                 WHERE   C.COMP_CD  = S.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                                 AND     C.BRAND_CD = S.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                                 AND     C.STOR_CD  = S.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                                 AND     C.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                             ) C ]'
        ||CHR(13)||CHR(10)||Q'[                                 ) C]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY C.AGE_GROUP, C.LVL_CD]'
        ||CHR(13)||CHR(10)||Q'[                     )   S]'
        ||CHR(13)||CHR(10)||Q'[              PIVOT  (]'
        ||CHR(13)||CHR(10)||Q'[                         SUM(CNT)]'
        ||CHR(13)||CHR(10)||Q'[                         FOR LVL_CD]'
        ||CHR(13)||CHR(10)||Q'[                         IN (]' || V_CROSSTAB || Q'[)]'
        ||CHR(13)||CHR(10)||Q'[                     )]'
        ||CHR(13)||CHR(10)||Q'[         )   A]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  C.CODE_CD   = A.AGE_GROUP(+)]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY C.SORT_SEQ]';

        dbms_output.put_line(V_HD) ;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD;

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

END PKG_CUST1040;

/
