--------------------------------------------------------
--  DDL for Package Body PKG_STCK6000
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_STCK6000" AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_STCK6000
   --  Description      : 월 매출현황 (폐기현황포함)
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2012-06-29
   --  Create Programer : 박인수
   --  Modify Date      : 2012-06-29
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : SP_SEARCH_01
   --  Description      : 월 매출현황 (폐기현황포함)
   -- Ref. Table        : SALE_JDS
   ---------------------------------------------------------------------------------------------------
   /*
   exec PKG_SALE6000.SP_SEARCH_01('level_10', 'k', 'KOR', '00', 'DATE↙I↙01↙B↙20120613↙20120613↙↙#!LOGIN↙I↙70↙S↙H↙↙↙', '', '20120601', '20120613', :PR_RTN_CD, :PR_RTN_MSG);
   */
   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : SP_SEARCH_01
   --  Description      : 월 매출현황 (폐기현황포함) - 기간별매출현황 탭
   -- Ref. Table        : DSTOCK
   ---------------------------------------------------------------------------------------------------
   PROCEDURE SP_SEARCH_01
      (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
      ) IS

       TYPE  rec_ct_hd IS RECORD
            ( STOR_CD  VARCHAR2(10) ,
              STOR_NM  VARCHAR2(100)
            ) ;
            TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

       qry_hd     tb_ct_hd  ;

       V_CROSSTAB     VARCHAR2(30000);
       V_SQL          VARCHAR2(30000);
       V_HD           VARCHAR2(30000);
       V_HD1          VARCHAR2(20000);
       V_HD2          VARCHAR2(30000);

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
       ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE

       ERR_HANDLER     EXCEPTION;

       ls_err_cd     VARCHAR2(7) := '0' ;
       ls_err_msg    VARCHAR2(500) ;

       ls_where_date1  VARCHAR2(200);
       ls_where_date2  VARCHAR2(200);
       ls_where_date3  VARCHAR2(200);
       ls_pre_from_dt  VARCHAR2(8);
       ls_pre_to_dt    VARCHAR2(8);

       lsLine  varchar2(3) ;
   BEGIN

       --dbms_output.enable( 10000000 ) ;
       PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                           ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

       -- 조회기간 처리---------------------------------------------------------------
       ls_sql_date := ' S.PRC_DT ' || ls_date1;
       IF ls_ex_date1 IS NOT NULL THEN
          ls_sql_date := ls_sql_date || ' AND S.PRC_DT ' || ls_ex_date1 ;
       END IF;

       lsLine := '000';
       ------------------------------------------------------------------------------

       -- 공통코드 참조 Table 생성 ---------------------------------------------------
       --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
       -------------------------------------------------------------------------------

        ls_sql_with := ' WITH  '
        ||  ls_sql_store -- S_STORE
--        ||  ', '
--        ||  ls_sql_item  -- S_ITEM
        ;
       lsLine := '002';

        /* 가로축 데이타 FETCH */
         ls_sql_crosstab_main := ' SELECT S.STOR_CD, A.STOR_NM '
                              || '   FROM STORE_ETC_AMT S, '
                              || '        S_STORE       A  '
                              || '  WHERE S.COMP_CD  = A.COMP_CD  '
                              || '    AND S.BRAND_CD = A.BRAND_CD '
                              || '    AND S.STOR_CD  = A.STOR_CD  '
                              || '    AND S.COMP_CD  = ''' || PSV_COMP_CD || ''''
                              || '    AND ' || ls_sql_date
                              || ' GROUP BY S.STOR_CD, A.STOR_NM '
                              || ' ORDER BY S.STOR_CD '
                              ;

       lsLine := '005';

        ls_sql := ls_sql_with  || ls_sql_crosstab_main ;

        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD , PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;


       /* 계정코드/명    {금액}   점포코드
          계정코드/명             점포명
       */

        V_HD1 := ' SELECT FC_GET_WORDPACK('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''ACC_CD'') AS H_ACC_CD,  FC_GET_WORDPACK('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''ACC_NM'') AS H_ACC_NM '   -- 입/출금계정
 --       V_HD1 := ' SELECT ''' || '계정코드' || '''  AS ACC_CD,                            ''' || '계정명' || ''' AS ACC_NM    '   -- 입/출금계정
                ;
--        V_HD2 := V_HD1 || Q'[ , V01 AS H_QTY, V02 AS H_GRD_AMT, V03 AS H_CUST_CNT, V04,  ]' ;  -- 수량,순매출액,고객수
        V_HD2 := V_HD1 || chr(13)||chr(10) || '   , FC_GET_WORDPACK('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''HAP'') AS H_ETC_AMT,   '    ;
        V_HD1 := V_HD1 || chr(13)||chr(10) || '   , FC_GET_WORDPACK('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''HAP'') AS H_ETC_AMT,   '    ;

        lsLine := '030';
        FOR i IN qry_hd.FIRST..qry_hd.LAST LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ';
                   V_HD2 := V_HD2 || ' , ';
                END IF;

                V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).STOR_CD || ''''  ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).STOR_CD  || ''' CT' || TO_CHAR(i*3);
                V_HD2 := V_HD2 || ''''   || qry_hd(i).STOR_NM  || ''' CT' || TO_CHAR(i*3);
--                V_HD2 := V_HD2 || Q'[ '객단가'  CT]'   || TO_CHAR(i*3) ;  -- 폐기율
            END;
        END LOOP;
        lsLine := '040';

        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
        V_HD   := PKG_REPORT.f_olap_hd(PSV_COMP_CD , PSV_LANG_CD)  || V_HD || V_HD1 || ' UNION ALL ' || V_HD2 ;
        lsLine := '050';

       /* MAIN SQL */
       ls_sql_main :=
               chr(13)||chr(10) || q'[ SELECT  ETC_CD, ETC_NM   ]'
            || chr(13)||chr(10) || q'[       , STOR_CD                AS STOR_CD ]'
            || chr(13)||chr(10) || q'[       , ETC_AMT                AS ETC_AMT          ]'
            || chr(13)||chr(10) || q'[       , SUM(ETC_AMT )          OVER( PARTITION BY ETC_CD )  AS T_ETC_ATM        ]'
            || chr(13)||chr(10) || q'[  FROM (                      ]'
            || chr(13)||chr(10) || q'[         SELECT  S.STOR_CD  ]'
            || chr(13)||chr(10) || q'[               , A.ETC_CD   ]'
            || chr(13)||chr(10) || q'[               , NVL(LT.LANG_NM,A.ETC_NM)    AS ETC_NM   ]'
            || chr(13)||chr(10) || q'[               , SUM(S.ETC_AMT)     AS ETC_AMT          ]'
            || chr(13)||chr(10) || q'[           FROM STORE_ETC_AMT S,                                                                           ]'
            || chr(13)||chr(10) ||  '                 (SELECT * FROM ACC_MST WHERE STOR_TP = ''10'' AND COMP_CD = ''' || PSV_COMP_CD ||''' ) A,   '
            || chr(13)||chr(10) || q'[                S_STORE       O,  ]'
            || chr(13)||chr(10) || q'[        (                          ]'
            || chr(13)||chr(10) || q'[          SELECT  PK_COL, LANG_NM ]'
            || chr(13)||chr(10) || q'[            FROM  LANG_TABLE      ]'
            || chr(13)||chr(10) ||  '            WHERE  COMP_CD  = '''||PSV_COMP_CD||''''
            || chr(13)||chr(10) || q'[             AND  TABLE_NM = 'ACC_MST']'
            || chr(13)||chr(10) || q'[             AND  COL_NM   = 'ETC_NM' ]'
            || chr(13)||chr(10) ||  '              AND  LANGUAGE_TP = '''||PSV_LANG_CD||''''
            || chr(13)||chr(10) || q'[        )    LT                         ]'        
            || chr(13)||chr(10) || q'[          WHERE S.COMP_CD  = O.COMP_CD                                                               ]'
            || chr(13)||chr(10) || q'[            AND S.BRAND_CD = O.BRAND_CD                                                              ]'
            || chr(13)||chr(10) || '              AND S.STOR_CD  = O.STOR_CD                                                                '
            || chr(13)||chr(10) || '              AND S.COMP_CD  = A.COMP_CD                                                                '
            || chr(13)||chr(10) || '              AND S.ETC_CD   = A.ETC_CD                                                                 '
            || chr(13)||chr(10) || q'[            AND LPAD(A.ETC_CD,3,' ')||LPAD(A.STOR_TP,2,' ') = LT.PK_COL(+)                            ]'
            --|| chr(13)||chr(10) || q'[              AND S.ETC_DIV   = '02'                                                               ]'
            || chr(13)||chr(10) || '              AND S.COMP_CD  = ''' || PSV_COMP_CD || ''''
            || chr(13)||chr(10) || '              AND ' || ls_sql_date
            || chr(13)||chr(10) || q'[          GROUP BY S.STOR_CD, A.ETC_CD, NVL(LT.LANG_NM,A.ETC_NM)   ]'
            || chr(13)||chr(10) || q'[        )   ]'
            || chr(13)||chr(10) || q'[  GROUP BY  ETC_CD, ETC_NM          ]'
            || chr(13)||chr(10) || q'[          , ETC_AMT         ]'
            || chr(13)||chr(10) || q'[          , STOR_CD         ]'
           ;


       ls_sql := ls_sql_with || ls_sql_main;

        V_SQL :=             ' SELECT * '
        || chr(13)||chr(10) || ' FROM ( '
        || chr(13)||chr(10) ||         ls_sql
        || chr(13)||chr(10) || ' ) S '
        || chr(13)||chr(10) || ' PIVOT '
        || chr(13)||chr(10) || ' ( '
        || chr(13)||chr(10) || '   SUM(ETC_AMT )          AS ETC_AMT     '
        || chr(13)||chr(10) || '  FOR ( STOR_CD ) IN ( '
        || chr(13)||chr(10) ||     V_CROSSTAB
        || chr(13)||chr(10) || '                   ) '
        || chr(13)||chr(10) || ' ) '
        || chr(13)||chr(10) || ' ORDER BY ETC_NM '
        ;

       OPEN PR_HEADER FOR V_HD;
       OPEN PR_RESULT FOR V_SQL;
       dbms_output.put_line( V_SQL ) ;

       PR_RTN_CD  := ls_err_cd;
       PR_RTN_MSG := ls_err_msg ;

   EXCEPTION
       WHEN ERR_HANDLER THEN
           PR_RTN_CD  := ls_err_cd;
           PR_RTN_MSG := '[' || lsLine || ']' || ls_err_msg ;
          dbms_output.put_line( PR_RTN_MSG ) ;
       WHEN OTHERS THEN
           PR_RTN_CD  := '4999999' ;
           PR_RTN_MSG := '[' || lsLine || ']' || SQLERRM ;
           dbms_output.put_line( PR_RTN_MSG ) ;
   END ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : SP_SEARCH_02
   --  Description      : 월 매출현황 (폐기현황포함) - 기간별매출현황 (폐기포함) 탭
   -- Ref. Table        : DSTOCK
   ---------------------------------------------------------------------------------------------------
   PROCEDURE SP_SEARCH_02
      (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
      ) IS

       TYPE  rec_ct_hd IS RECORD
            ( PRC_DT  VARCHAR2(10)
            ) ;
            TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

       qry_hd     tb_ct_hd  ;

       V_CROSSTAB     VARCHAR2(30000);
       V_SQL          VARCHAR2(30000);
       V_HD           VARCHAR2(30000);
       V_HD1          VARCHAR2(20000);
       V_HD2          VARCHAR2(30000);

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
       ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE

       ERR_HANDLER     EXCEPTION;

       ls_err_cd     VARCHAR2(7) := '0' ;
       ls_err_msg    VARCHAR2(500) ;

       ls_where_date1  VARCHAR2(200);
       ls_where_date2  VARCHAR2(200);
       ls_where_date3  VARCHAR2(200);
       ls_pre_from_dt  VARCHAR2(8);
       ls_pre_to_dt    VARCHAR2(8);

       lsLine  varchar2(3) ;
   BEGIN

--       delete from report_query where pgm_id = PSV_PGM_ID ;

       --dbms_output.enable( 10000000 ) ;
       PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                           ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

       -- 조회기간 처리---------------------------------------------------------------
       ls_sql_date := ' S.PRC_DT ' || ls_date1;
       IF ls_ex_date1 IS NOT NULL THEN
          ls_sql_date := ls_sql_date || ' AND S.PRC_DT ' || ls_ex_date1 ;
       END IF;

       lsLine := '000';
       ------------------------------------------------------------------------------

       -- 공통코드 참조 Table 생성 ---------------------------------------------------
       --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
       -------------------------------------------------------------------------------

        ls_sql_with := ' WITH  '
        ||  ls_sql_store -- S_STORE
        ;


      /* MAIN SQL */
       ls_sql_main :=
               chr(13)||chr(10) || q'[     SELECT  S.STOR_CD   ]'
            || chr(13)||chr(10) || q'[               , O.STOR_NM   ]'
            || chr(13)||chr(10) || q'[               , S.PRC_DT    ]'
            || chr(13)||chr(10) || q'[               , NVL(LT.LANG_NM,A.ETC_NM)    AS ETC_NM    ]'
            || chr(13)||chr(10) || q'[               , S.ETC_AMT   AS ETC_AMT          ]'
            || chr(13)||chr(10) || q'[               , S.ETC_DESC  AS ETC_DESC         ]'
            || chr(13)||chr(10) || q'[               , S.ETC_CD    ]'
            || chr(13)||chr(10) || q'[           FROM STORE_ETC_AMT S,                 ]'
            || chr(13)||chr(10) ||  '                 (SELECT * FROM ACC_MST WHERE STOR_TP = ''10'' AND COMP_CD = '''||PSV_COMP_CD||''' ) A,   '
            || chr(13)||chr(10) || q'[                S_STORE       O,   ]'
            || chr(13)||chr(10) || q'[        (                          ]'
            || chr(13)||chr(10) || q'[          SELECT  PK_COL, LANG_NM ]'
            || chr(13)||chr(10) || q'[            FROM  LANG_TABLE      ]'
            || chr(13)||chr(10) ||  '            WHERE  COMP_CD  = '''||PSV_COMP_CD||''''
            || chr(13)||chr(10) || q'[             AND  TABLE_NM = 'ACC_MST']'
            || chr(13)||chr(10) || q'[             AND  COL_NM   = 'ETC_NM' ]'
            || chr(13)||chr(10) ||  '              AND  LANGUAGE_TP = '''||PSV_LANG_CD||''''
            || chr(13)||chr(10) || q'[        )    LT                             ]'
            || chr(13)||chr(10) || q'[          WHERE S.COMP_CD  = O.COMP_CD               ]'
            || chr(13)||chr(10) || q'[            AND S.BRAND_CD = O.BRAND_CD              ]'
            || chr(13)||chr(10) || '              AND S.STOR_CD  = O.STOR_CD                '
            || chr(13)||chr(10) || '              AND S.COMP_CD  = A.COMP_CD                '
            || chr(13)||chr(10) || '              AND S.ETC_CD   = A.ETC_CD                 '
            || chr(13)||chr(10) || q'[            AND LPAD(A.ETC_CD,3,' ')||LPAD(A.STOR_TP,2,' ') = LT.PK_COL(+)   ]'
            --|| chr(13)||chr(10) || q'[              AND S.ETC_DIV   = '02'                   ]'
            || chr(13)||chr(10) || '              AND S.COMP_CD  = ''' || PSV_COMP_CD || ''''
            || chr(13)||chr(10) || '              AND ' || ls_sql_date
                                || ' ORDER BY S.STOR_CD,S.PRC_DT '
           ;


       ls_sql := ls_sql_with || ls_sql_main;

       lsLine := '020';
--       dbms_output.put_line( ls_sql ) ;
       OPEN PR_RESULT FOR ls_sql;

       PR_RTN_CD  := ls_err_cd;
       PR_RTN_MSG := ls_err_msg ;

   EXCEPTION
       WHEN ERR_HANDLER THEN
           PR_RTN_CD  := ls_err_cd;
           PR_RTN_MSG := '[' || lsLine || ']' || ls_err_msg ;
          dbms_output.put_line( PR_RTN_MSG ) ;
       WHEN OTHERS THEN
           PR_RTN_CD  := '4999999' ;
           PR_RTN_MSG := '[' || lsLine || ']' || SQLERRM ;
           dbms_output.put_line( PR_RTN_MSG ) ;
   END ;



END PKG_STCK6000;

/
