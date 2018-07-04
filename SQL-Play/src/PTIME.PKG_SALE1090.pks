CREATE OR REPLACE PACKAGE      PKG_SALE1090 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1090L0
   --  Description      : 시간대별 매출분석(30분단위)
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    PROCEDURE SP_TAB01 /* 점포별 시간대 */
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
        PSV_FR_TM       IN  VARCHAR2 ,                -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB02  /* 상품별 시간대 */
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
        PSV_FR_TM       IN  VARCHAR2 ,                -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
END PKG_SALE1090;

/

CREATE OR REPLACE PACKAGE BODY      PKG_SALE1090 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1090L0
   --  Description      : 시간대별 매출분석(30분단위)
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    PROCEDURE SP_TAB01 /* 점포별 시간대 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2,               -- 회사코드
        PSV_USER        IN  VARCHAR2,               -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2,               -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2,               -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2,               -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2,               -- Search Parameter
        PSV_FILTER      IN  VARCHAR2,               -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_FR_TM       IN  VARCHAR2 ,              -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,              -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR, -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR, -- Result Set
        PR_RTN_CD       OUT VARCHAR2,               -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_STORE_TIME        점포별 시간대
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2014-08-25         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_STORE_TIME
          SYSDATE:         2014-08-25
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    ( 
        TIME_DIV     VARCHAR2(2),
        TIME_DIV_NM  VARCHAR2(20)
    );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;
    
    qry_hd     tb_ct_hd  ;
    
    V_CROSSTAB              VARCHAR2(30000);
    V_SQL                   VARCHAR2(30000);
    V_HD                    VARCHAR2(30000);
    V_HD1                   VARCHAR2(20000);
    V_HD2                   VARCHAR2(20000);
    ls_sql                  VARCHAR2(30000);
    ls_sql_with             VARCHAR2(30000);
    ls_sql_main             VARCHAR2(10000);
    ls_sql_date             VARCHAR2(1000) ;
    ls_sql_time             VARCHAR2(1000) ;
    ls_sql_store            VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item             VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1                VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2                VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1             VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2             VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main    VARCHAR2(20000) ;   -- CORSSTAB TITLE
    ERR_HANDLER             EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        dbms_output.enable( 10000000 ) ;
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        -- 조쇠시간 처리
        IF PSV_FR_TM IS NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SH.SALE_TM, 0, 4) <= '''||PSV_TO_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SH.SALE_TM, 0, 4) >= '''||PSV_FR_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SH.SALE_TM, 0, 4) BETWEEN '''||PSV_FR_TM||''' AND '''||PSV_TO_TM||'''';
        END IF;
        
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;
    
        V_HD  := '  SELECT     '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BRAND_CD')   ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BRAND_NM')   ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STOR_TP')    ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STOR_TP')    ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STOR_CD')    ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STOR_NM')    ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')   ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')   ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')   ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT')||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')   ||''''
        ||CHR(13)||CHR(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT1')  ||''''
        ||CHR(13)||CHR(10)||' FROM DUAL ' ;
        
    
        /* MAIN SQL */
        ls_sql_main :=
          chr(13)||chr(10)||Q'[ SELECT  SH.BRAND_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)    AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)  AS STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)     AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_CD          AS TIME_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(C.CODE_NM)     AS TIME_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(SH.SALE_DIV, '1', 1, -1))   AS BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', (SH.GRD_I_AMT + SH.GRD_O_AMT), 'T', SH.SALE_AMT, (SH.GRD_I_AMT + SH.GRD_O_AMT) - (SH.VAT_I_AMT + SH.VAT_O_AMT)))  AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SH.CUST_M_CNT + SH.CUST_F_CNT)   AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SH.CUST_M_CNT + SH.CUST_F_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', (SH.GRD_I_AMT + SH.GRD_O_AMT), 'T', SH.SALE_AMT, (SH.GRD_I_AMT + SH.GRD_O_AMT) - (SH.VAT_I_AMT + SH.VAT_O_AMT))) / SUM(SH.CUST_M_CNT + SH.CUST_F_CNT))   AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_HD    SH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[            SELECT  COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CODE_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CODE_NM                  ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  VAL_C1                   ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  VAL_C2                   ]'
        ||CHR(13)||CHR(10)||Q'[              FROM  COMMON                   ]'
        ||CHR(13)||CHR(10)||Q'[             WHERE  COMP_CD = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[               AND  CODE_TP = '01530'        ]'
        ||CHR(13)||CHR(10)||Q'[               AND  USE_YN  = 'Y'            ]'
        ||CHR(13)||CHR(10)||Q'[         )      C                            ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SH.COMP_CD  = S.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BRAND_CD = S.BRAND_CD            ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.STOR_CD  = S.STOR_CD             ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = C.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(SH.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = :PSV_COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DT >= :PSV_GFR_DATE         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DT <= :PSV_GTO_DATE         ]'
        ||CHR(13)||CHR(10)||Q'[    ]' || ls_sql_time
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_CD      ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_CD      ]';
    
        V_SQL := ls_sql_with || ls_sql_main;
    
        dbms_output.put_line( V_HD) ;
        dbms_output.put_line( V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD;
        OPEN PR_RESULT FOR
            V_SQL USING PSV_FILTER, PSV_FILTER, PSV_COMP_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    END;
    
    PROCEDURE SP_TAB02  /* 상품별 시간대 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2,               -- 회사코드
        PSV_USER        IN  VARCHAR2,               -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2,               -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2,               -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2,               -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2,               -- Search Parameter
        PSV_FILTER      IN  VARCHAR2,               -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_FR_TM       IN  VARCHAR2 ,              -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,              -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR, -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR, -- Result Set
        PR_RTN_CD       OUT VARCHAR2,               -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_ITEM_TIME        상품별 시간대
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2014-08-25         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_ITEM_TIME
          SYSDATE:         2014-08-25
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    ( 
        TIME_DIV     VARCHAR2(2),
        TIME_DIV_NM  VARCHAR2(20)
    );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;
    
    qry_hd     tb_ct_hd  ;
    
    V_CROSSTAB              VARCHAR2(30000);
    V_SQL                   VARCHAR2(30000);
    V_HD                    VARCHAR2(30000);
    V_HD1                   VARCHAR2(20000);
    V_HD2                   VARCHAR2(20000);
    ls_sql                  VARCHAR2(30000);
    ls_sql_with             VARCHAR2(30000);
    ls_sql_main             VARCHAR2(10000);
    ls_sql_date             VARCHAR2(1000) ;
    ls_sql_time             VARCHAR2(1000) ;
    ls_sql_store            VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item             VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1                VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2                VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1             VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2             VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main    VARCHAR2(20000) ;   -- CORSSTAB TITLE
    ERR_HANDLER             EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        dbms_output.enable( 10000000 ) ;
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        -- 조쇠시간 처리
        IF PSV_FR_TM IS NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SD.SALE_TM, 0, 4) <= '''||PSV_TO_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SD.SALE_TM, 0, 4) >= '''||PSV_FR_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SD.SALE_TM, 0, 4) BETWEEN '''||PSV_FR_TM||''' AND '''||PSV_TO_TM||'''';
        END IF;
        
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
    
        /* 가로축 데이타 FETCH */
        ls_sql_crosstab_main :=
          chr(13)||chr(10)||Q'[ SELECT  C.CODE_CD       AS TIME_DIV            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(C.CODE_NM)  AS TIME_DIV_NM         ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_DT SD                             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE S                              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM  I                              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                      ]'
        ||CHR(13)||CHR(10)||Q'[            SELECT  COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CODE_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CODE_NM                     ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  VAL_C1                      ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  VAL_C2                      ]'
        ||CHR(13)||CHR(10)||Q'[              FROM  COMMON                      ]'
        ||CHR(13)||CHR(10)||Q'[             WHERE  COMP_CD = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[               AND  CODE_TP = '01530'           ]'
        ||CHR(13)||CHR(10)||Q'[               AND  USE_YN  = 'Y'               ]'
        ||CHR(13)||CHR(10)||Q'[         )      C                   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD  = S.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD = S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD  = S.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = I.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ITEM_CD  = I.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = C.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(SD.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (SD.T_SEQ    = '0' OR SD.SUB_ITEM_DIV = '2')           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT >= :PSV_GFR_DATE]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT <= :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||ls_sql_time 
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY C.CODE_CD               ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY C.CODE_CD               ]';
 
        ls_sql := ls_sql_with || ls_sql_crosstab_main ;
        dbms_output.put_line(ls_sql) ;
    
        --   DELETE FROM REPORT_QUERY WHERE PGM_ID = PSV_PGM_ID;
        --   INSERT INTO REPORT_QUERY( COMP_CD, PGM_ID, SEQ, QUERY_TEXT ) VALUES ( PSV_COMP_CD, PSV_PGM_ID, 1, ls_sql );
        --   COMMIT;
           
        EXECUTE IMMEDIATE  ls_sql BULK COLLECT 
            INTO qry_hd USING PSV_COMP_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := '  SELECT       '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'ITEM_CD')
        ||CHR(13)||CHR(10)||''', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'ITEM_NM')
        ||CHR(13)||CHR(10)||''', ';
        V_HD2 := '  SELECT       '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'ITEM_CD')
        ||CHR(13)||CHR(10)||''', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'ITEM_NM')
        ||CHR(13)||CHR(10)||''', ';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                   V_HD2 := V_HD2 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).TIME_DIV  || '''';
                V_HD1 := V_HD1 || ''''   || qry_hd(i).TIME_DIV_NM  || ''' CT' || TO_CHAR(i*2 - 2) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).TIME_DIV_NM  || ''' CT' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || ' ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')         || ''' CT' || TO_CHAR(i*2 - 1 ) || ',' ;
                V_HD2 := V_HD2 || ' ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT')|| ''' CT' || TO_CHAR(i*2);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || ' FROM DUAL ' ;
        V_HD2 :=  V_HD2 || ' FROM DUAL ' ;
        V_HD   := V_HD1 || ' UNION ALL ' || V_HD2 ;
        
    
        /* MAIN SQL */
        ls_sql_main :=
          chr(13)||chr(10)||Q'[ SELECT  /*+ ORDERED */                      ]'
        ||CHR(13)||CHR(10)||Q'[         SD.ITEM_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ITEM_NM)     AS ITEM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_CD          AS TIME_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SD.SALE_QTY)   AS SALE_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', SD.GRD_AMT, 'T', SD.SALE_AMT, SD.GRD_AMT - SD.VAT_AMT))  AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_DT    SD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM     I   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[            SELECT  COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CODE_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CODE_NM                  ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  VAL_C1                   ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  VAL_C2                   ]'
        ||CHR(13)||CHR(10)||Q'[              FROM  COMMON                   ]'
        ||CHR(13)||CHR(10)||Q'[             WHERE  COMP_CD = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[               AND  CODE_TP = '01530'        ]'
        ||CHR(13)||CHR(10)||Q'[               AND  USE_YN  = 'Y'            ]'
        ||CHR(13)||CHR(10)||Q'[         )      C       ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD  = S.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD = S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD  = S.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = I.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ITEM_CD  = I.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = C.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(SD.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (SD.T_SEQ   = '0' OR SD.SUB_ITEM_DIV = '2')             ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT >= :PSV_GFR_DATE]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT <= :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||ls_sql_time
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SD.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_CD      ]';
    
        ls_sql := ls_sql_with || ls_sql_main;
    
        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL :=   
          chr(13)||chr(10)||'SELECT  *  '
        ||CHR(13)||CHR(10)||'  FROM  (  '
        ||CHR(13)||CHR(10)||ls_sql
        ||CHR(13)||CHR(10)||'        ) S'
        ||CHR(13)||CHR(10)||' PIVOT     '
        ||CHR(13)||CHR(10)||' (         '
        ||CHR(13)||CHR(10)||'        SUM(SALE_QTY)   VCOL1 '
        ||CHR(13)||CHR(10)||'    ,   SUM(GRD_AMT)    VCOL2 '
        ||CHR(13)||CHR(10)||'    FOR ( TIME_DIV ) IN   '
        ||CHR(13)||CHR(10)||'    ( '
        ||CHR(13)||CHR(10)||V_CROSSTAB
        ||CHR(13)||CHR(10)||'    )  '
        ||CHR(13)||CHR(10)||' )     '
        ||CHR(13)||CHR(10)||' ORDER  BY 1, 2';
    
        dbms_output.put_line( V_HD) ;
        dbms_output.put_line( V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD;
        OPEN PR_RESULT FOR
            V_SQL USING PSV_FILTER, PSV_COMP_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    END;
    
END PKG_SALE1090;

/
