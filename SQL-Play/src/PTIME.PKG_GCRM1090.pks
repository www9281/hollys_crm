CREATE OR REPLACE PACKAGE       PKG_GCRM1090 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_GCRM1090
   --  Description      : 월별일반/다회권 매출현황
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

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
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_GCRM1090;

/

CREATE OR REPLACE PACKAGE BODY       PKG_GCRM1090 AS

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
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_MAIN         월별 일반/다회권 매출현황
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2017-09-06         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_MAIN
          SYSDATE:          2017-09-06
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    ( 
        DIV             VARCHAR2(1),
        PROGRAM_ID      VARCHAR2(30),
        PROGRAM_NM      VARCHAR2(100)
    );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;
    
    qry_hd     tb_ct_hd  ;
    
    V_CROSSTAB              VARCHAR2(30000);
    V_SQL                   VARCHAR2(30000);
    V_HD                    VARCHAR2(30000);
    V_HD1                   VARCHAR2(30000);
    V_HD2                   VARCHAR2(30000);
    V_HD3                   VARCHAR2(30000);
    ls_sql                  VARCHAR2(30000);
    ls_sql_with             VARCHAR2(30000);
    ls_sql_main             VARCHAR2(30000);
    ls_sql_date             VARCHAR2(1000) ;
    ls_sql_store            VARCHAR2(30000);    -- 점포 WITH  S_STORE
    ls_sql_item             VARCHAR2(30000);    -- 제품 WITH  S_ITEM
    ls_date1                VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2                VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1             VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2             VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main         VARCHAR2(30000) ;   -- CORSSTAB TITLE
    ERR_HANDLER             EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    --||  ', '
                    --||  ls_sql_item  -- S_ITEM
                    ;
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  *   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  '1'                 AS DIV          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  '1'||SD.PROGRAM_ID  AS PROGRAM_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(P.PROGRAM_NM)   AS PROGRAM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT         SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_PROGRAM      P   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         S   ]'                
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD      = P.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.PROGRAM_ID   = P.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ENTRY_DIV    = '2'           ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ENTRY_NO     IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.PROGRAM_ID   IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.MBS_NO       IS NULL         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.CERT_NO      IS NULL         ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SD.PROGRAM_ID                ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  '2'                 AS DIV          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  '2'||SD.MBS_NO      AS PROGRAM_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(M.MBS_NM)       AS PROGRAM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT         SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBERSHIP   M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD      = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.PROGRAM_ID   = M.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.MBS_NO       = M.MBS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ENTRY_NO     IS NULL         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.PROGRAM_ID   IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.MBS_NO       IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.CERT_NO      IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  EXISTS (                        ]'
        ||CHR(13)||CHR(10)||Q'[                                 SELECT  '1'         ]'
        ||CHR(13)||CHR(10)||Q'[                                   FROM  CS_MEMBERSHIP_SALE_HIS      ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHERE  COMP_CD         = SD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  APPR_DT         = SD.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  SALE_BRAND_CD   = SD.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  SALE_STOR_CD    = SD.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  SALE_BILL_NO    = SD.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  SALE_SEQ        = SD.SEQ        ]'
        ||CHR(13)||CHR(10)||Q'[                            )                        ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SD.MBS_NO                    ]'
        ||CHR(13)||CHR(10)||Q'[         )   ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY DIV, PROGRAM_ID   ]';
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        --dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                                                              , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_CD, '1001000413');
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOT_SALE_AMT') ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOT_SALE_AMT') ]';
        
        V_HD3 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOT_SALE_AMT') ]';
        
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).PROGRAM_ID || Q'[']';
                IF qry_hd(i).DIV = '1' THEN
                    V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NORMAL') || Q'[' AS CT]';
                    V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NORMAL') || Q'[' AS CT]';
                    V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NORMAL') || Q'[' AS CT]';
                ELSE
                    V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMBERSHIP') || Q'[' AS CT]';
                    V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMBERSHIP') || Q'[' AS CT]';
                    V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMBERSHIP') || Q'[' AS CT]';
                END IF;
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).PROGRAM_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).PROGRAM_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).PROGRAM_NM  || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY') || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT') || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RATIO') || Q'[' AS CT]' || TO_CHAR(i*3);
            END;
        END LOOP;
    
        V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        --V_HD  := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD3;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(BRAND_NM)   AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(STOR_NM)    AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(GRD_AMT)) OVER (PARTITION BY COMP_CD, BRAND_CD, STOR_CD)   AS TOT_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(GRD_AMT)) OVER (PARTITION BY COMP_CD, BRAND_CD, STOR_CD)   AS COL_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_QTY)   AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(GRD_AMT)    AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SD.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  '1'||SD.PROGRAM_ID   AS PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT         SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_PROGRAM      P   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         S   ]'                
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD      = P.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.PROGRAM_ID   = P.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ENTRY_DIV    = '2'           ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ENTRY_NO     IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.PROGRAM_ID   IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.MBS_NO       IS NULL         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.CERT_NO      IS NULL         ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  '2'||SD.MBS_NO          AS PROGRAM_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT         SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBERSHIP   M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD      = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.PROGRAM_ID   = M.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.MBS_NO       = M.MBS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ENTRY_NO     IS NULL         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.PROGRAM_ID   IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.MBS_NO       IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.CERT_NO      IS NOT NULL     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  EXISTS (                        ]'
        ||CHR(13)||CHR(10)||Q'[                                 SELECT  '1'         ]'
        ||CHR(13)||CHR(10)||Q'[                                   FROM  CS_MEMBERSHIP_SALE_HIS      ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHERE  COMP_CD         = SD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  APPR_DT         = SD.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  SALE_BRAND_CD   = SD.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  SALE_STOR_CD    = SD.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  SALE_BILL_NO    = SD.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  SALE_SEQ        = SD.SEQ        ]'
        ||CHR(13)||CHR(10)||Q'[                            )                        ]'
        ||CHR(13)||CHR(10)||Q'[         )   ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY COMP_CD, BRAND_CD, STOR_CD, PROGRAM_ID   ]';
    
        ls_sql := ls_sql_with || ls_sql_main;
        
        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  *   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(SALE_QTY) AS COL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(SALE_AMT) AS COL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CASE WHEN COL_SALE_AMT = 0 THEN 0 ELSE ROUND(SALE_AMT / COL_SALE_AMT * 100, 2) END)  AS COL3 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (PROGRAM_ID) IN     ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY 1, 2, 3 ]';
        
        --dbms_output.put_line(V_HD) ;
        --dbms_output.put_line(V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD3 USING PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                      , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
END PKG_GCRM1090;

/
