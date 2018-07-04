CREATE OR REPLACE PACKAGE      PKG_ORDR4720 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_ORDR4720
   --  Description      : 점포별 마감현황 조회용 Package
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-05-06
   --  Create Programer : 최세원
   --  Modify Date      : 2010-05-06
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : SP_ORDER_HD
   --  Description      : 점포별 마감현황 조회용 프로시져
   -- Ref. Table        : ORDER_HD
   ---------------------------------------------------------------------------------------------------

    PROCEDURE SP_ORDER_HD
    (
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_SHIP_DT     IN  VARCHAR2 ,                -- 배송일자
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR    -- Result Set
    );

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : SP_ORDER_DT
   --  Description      : 점포별 마감현황 상세 조회용 프로시져
   -- Ref. Table        : ORDER_DT
   ---------------------------------------------------------------------------------------------------
    PROCEDURE SP_ORDER_DT
    (
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_SHIP_DT     IN  VARCHAR2 ,                -- 배송일자
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR   -- Result Set
    );

END PKG_ORDR4720;

/

CREATE OR REPLACE PACKAGE BODY      PKG_ORDR4720 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_ORDR4720
   --  Description      : 점포별 마감현황 조회용 Package
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-05-06
   --  Create Programer : 최세원
   --  Modify Date      : 2010-05-06
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : SP_ORDER_HD
   --  Description      : 점포별 마감현황 조회용 프로시져
   -- Ref. Table        : ORDER_HD
   ---------------------------------------------------------------------------------------------------

    PROCEDURE SP_ORDER_HD
    (
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_SHIP_DT     IN  VARCHAR2 ,                -- 배송일자
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR   -- Result Set
    )
    IS
        ls_sql          VARCHAR2(30000) ;
        ls_sql_main     VARCHAR2(10000) ;
        ls_sql_date     VARCHAR2(1000) ;
        ls_sql_date2    VARCHAR2(1000) ;
        ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
        ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
        ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
        ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
        ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
        ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
        ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    BEGIN
        dbms_output.enable( 1000000 ) ;

        PKG_REPORT.RPT_PARA(PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        /*
          S_STORE AS
          (
         SELECT S.BRAND_CD , B.BRAND_NM, S.STOR_CD, S.STOR_NM, S.USE_YN ,
                S.STOR_TP, CM1.CODE_NM STOR_TP_NM , S.SIDO_CD, CM2.CODE_NM SIDO_CD_NM,
                S.REGION_CD, R.REGION_NM , S.TRAD_AREA, CM3.CODE_NM TRAD_AREA_NM, '
                S.DEPT_CD, CM4.CODE_NM DEPT_CD_NM, S.TEAM_CD, CM5.CODE_NM TEAM_CD_NM,
                S.SV_USER_ID , U.USER_NM
          )
        */

        /*
          S_ITEM AS
          (
           SELECT I.BRAND_CD, I.ITEM_CD, I.SALE_PRC,
                  I.ITEM_NM , I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD,
                 IC1.L_CLASS_NM , IC2.M_CLASS_NM , IC3.S_CLASS_NM
          )
        */

        -- 조회기간 처리---------------------------------------------------------------
        ls_sql_date := ' O.SHIP_DT ' || ls_date1;
        IF ls_ex_date1 IS NOT NULL THEN
            ls_sql_date := ls_sql_date || ' AND O.SHIP_DT ' || ls_ex_date1 ;
        END IF;
        ------------------------------------------------------------------------------

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------

        ls_sql_main :=  'SELECT  BRAND_CD                            '
                    ||  '      , STOR_CD                             '
                    ||  '      , STOR_NM                             '
                    ||  '      , WRK_DIV                             '
                    ||  '      , SUM(ORD_AMT) ORD_AMT                '
                    ||  '  FROM (                                    '
                    ||  '         SELECT  O.BRAND_CD                 '
                    ||  '             ,   O.STOR_CD                  '
                    ||  '             ,   S.STOR_NM                  '
                    ||  '             ,   O.WRK_DIV                  '
                    ||  '             ,   SUM(O.ORD_AMT)  AS ORD_AMT '
                    ||  '         FROM ORDER_HD O,                   '
                    ||  '              S_STORE  S                    '
                    ||  '         WHERE O.BRAND_CD = S.BRAND_CD      '
                    ||  '           AND O.STOR_CD  = S.STOR_CD       '
                    ||  '           AND ' ||  ls_sql_date
                    || q'[          AND O.ORD_SEQ  = '1'             ]'
                    || q'[          AND O.ORD_FG  IN ( '01', '02' )  ]'
                    ||  '         GROUP BY O.BRAND_CD,               '
                    ||  '                  O.STOR_CD ,               '
                    ||  '                  S.STOR_NM ,               '
                    ||  '                  O.WRK_DIV                 '
                    ||  '         UNION ALL                          '
                    ||  '         SELECT  O.BRAND_CD                 '
                    ||  '             ,   O.STOR_CD                  '
                    ||  '             ,   S.STOR_NM                  '
                    ||  '             ,   O.WRK_DIV                  '
                    ||  '             ,   SUM(O.ORD_AMT)  AS ORD_AMT '
                    ||  '         FROM ORDER_HD O,                   '
                    ||  '              S_STORE  S                    '
                    ||  '         WHERE O.BRAND_CD = S.BRAND_CD      '
                    ||  '           AND O.STOR_CD  = S.STOR_CD       '
                    || q'[          AND O.SHIP_DT  = TO_CHAR( TO_DATE(:PSV_SHIP_DT, 'YYYYMMDD') -1, 'YYYYMMDD')  ]'
                    || q'[          AND O.ORD_SEQ  = '2'             ]'
                    || q'[          AND O.ORD_FG  IN ( '01', '02' )  ]'
                    ||  '         GROUP BY O.BRAND_CD,               '
                    ||  '                  O.STOR_CD ,               '
                    ||  '                  S.STOR_NM ,               '
                    ||  '                  O.WRK_DIV                 '
                    ||  '         UNION ALL                          '
                    ||  '         SELECT  O.BRAND_CD                 '
                    ||  '             ,   O.STOR_CD                  '
                    ||  '             ,   S.STOR_NM                  '
                    ||  '             ,   O.WRK_DIV                  '
                    ||  '             ,   SUM(O.ORD_AMT)  AS ORD_AMT '
                    ||  '         FROM ORDER_HD O,                   '
                    ||  '              S_STORE  S                    '
                    ||  '         WHERE O.BRAND_CD = S.BRAND_CD      '
                    ||  '           AND O.STOR_CD  = S.STOR_CD       '
                    || q'[          AND O.SHIP_DT  = TO_CHAR( TO_DATE(:PSV_SHIP_DT, 'YYYYMMDD') +1, 'YYYYMMDD')  ]'
                    || q'[          AND O.ORD_SEQ  = '3'             ]'
                    || q'[          AND O.ORD_FG  IN ( '01', '02' )  ]'
                    ||  '         GROUP BY O.BRAND_CD,               '
                    ||  '                  O.STOR_CD ,               '
                    ||  '                  S.STOR_NM ,               '
                    ||  '                  O.WRK_DIV                 '
                    ||  '       )                                    '
                    ||  ' GROUP BY BRAND_CD, STOR_CD, STOR_NM, WRK_DIV '
                    ||  ' ORDER BY BRAND_CD, STOR_CD                 '
                    ;
        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;
        OPEN PR_RESULT FOR
            ls_sql USING  PSV_SHIP_DT, PSV_SHIP_DT ;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN OTHERS THEN RAISE;
    END;


   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : SP_ORDER_DT
   --  Description      : 점포별 마감현황 상세 조회용 프로시져
   -- Ref. Table        : ORDER_DT
   ---------------------------------------------------------------------------------------------------
    PROCEDURE SP_ORDER_DT
    (
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_SHIP_DT     IN  VARCHAR2 ,                -- 배송일자
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR   -- Result Set
    )
    IS
        ls_sql          VARCHAR2(30000) ;
        ls_sql_main     VARCHAR2(10000) ;
        ls_sql_date     VARCHAR2(1000) ;
        ls_sql_date2    VARCHAR2(1000) ;
        ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
        ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
        ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
        ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
        ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
        ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
        ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    BEGIN
        dbms_output.enable( 1000000 ) ;

        PKG_REPORT.RPT_PARA(PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        /*
          S_STORE AS
          (
         SELECT S.BRAND_CD , B.BRAND_NM, S.STOR_CD, S.STOR_NM, S.USE_YN ,
                S.STOR_TP, CM1.CODE_NM STOR_TP_NM , S.SIDO_CD, CM2.CODE_NM SIDO_CD_NM,
                S.REGION_CD, R.REGION_NM , S.TRAD_AREA, CM3.CODE_NM TRAD_AREA_NM, '
                S.DEPT_CD, CM4.CODE_NM DEPT_CD_NM, S.TEAM_CD, CM5.CODE_NM TEAM_CD_NM,
                S.SV_USER_ID , U.USER_NM
          )
        */

        /*
          S_ITEM AS
          (
           SELECT I.BRAND_CD, I.ITEM_CD, I.SALE_PRC,
                  I.ITEM_NM , I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD,
                 IC1.L_CLASS_NM , IC2.M_CLASS_NM , IC3.S_CLASS_NM
          )
        */

        -- 조회기간 처리---------------------------------------------------------------
        ls_sql_date := ' D.SHIP_DT ' || ls_date1;
        IF ls_ex_date1 IS NOT NULL THEN
            ls_sql_date := ls_sql_date || ' AND D.SHIP_DT ' || ls_ex_date1 ;
        END IF;
        ------------------------------------------------------------------------------

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------

        ls_sql_main :=  'SELECT  D.BRAND_CD      AS BRAND_CD  '
                    ||  '      , D.STOR_CD       AS STOR_CD   '
                    ||  '      , I.M_CLASS_CD    AS M_CLASS_CD'
                    ||  '      , I.M_CLASS_NM    AS M_CLASS_NM'
                    ||  '      , D.ITEM_CD       AS ITEM_CD   '
                    ||  '      , I.ITEM_NM       AS ITEM_NM   '
                    ||  '      , D.ORD_UNIT      AS ORD_UNIT  '
                    ||  '      , SUM(D.ORD_QTY_1)     AS ORD_QTY_1 '
                    ||  '      , SUM(D.ORD_QTY_2)     AS ORD_QTY_2 '
                    ||  '      , SUM(D.ORD_QTY_3)     AS ORD_QTY_3 '
                    ||  '      , SUM(D.ORD_AMT  )     AS ORD_AMT   '
                    ||  '  FROM (                             '
                    ||  '         SELECT  D.BRAND_CD          '
                    ||  '             ,   D.STOR_CD           '
                    ||  '             ,   D.ITEM_CD           '
                    ||  '             ,   D.ORD_UNIT          '
                    || q'[            ,   SUM(DECODE(D.ORD_SEQ,'1',D.ORD_QTY,0)) AS ORD_QTY_1]' --1차주문 건수
                    || q'[            ,   SUM(DECODE(D.ORD_SEQ,'2',D.ORD_QTY,0)) AS ORD_QTY_2]' --2차주문 건수
                    || q'[            ,   SUM(DECODE(D.ORD_SEQ,'3',D.ORD_QTY,0)) AS ORD_QTY_3]' --3차주문 건수
                    ||  '             ,   SUM(D.ORD_AMT)                         AS ORD_AMT   '
                    ||  '         FROM ORDER_DT D                                             '
                    ||  '         WHERE ' ||  ls_sql_date
                    || q'[          AND D.ORD_SEQ  = '1'             ]'
                    || q'[          AND D.ORD_FG  IN ( '01', '02' )  ]'
                    || q'[          AND D.ORD_QTY IS NOT NULL        ]'
                    || q'[          AND D.ORD_QTY  > 0               ]'
                    ||  '         GROUP BY D.BRAND_CD , '
                    ||  '                  D.STOR_CD  , '
                    ||  '                  D.ITEM_CD  , '
                    ||  '                  D.ORD_UNIT   '
                    ||  '         UNION ALL             '
                    ||  '         SELECT  D.BRAND_CD    '
                    ||  '             ,   D.STOR_CD     '
                    ||  '             ,   D.ITEM_CD     '
                    ||  '             ,   D.ORD_UNIT    '
                    || q'[            ,   SUM(DECODE(D.ORD_SEQ,'1',D.ORD_QTY,0)) AS ORD_QTY_1]' --1차주문 건수
                    || q'[            ,   SUM(DECODE(D.ORD_SEQ,'2',D.ORD_QTY,0)) AS ORD_QTY_2]' --2차주문 건수
                    || q'[            ,   SUM(DECODE(D.ORD_SEQ,'3',D.ORD_QTY,0)) AS ORD_QTY_3]' --3차주문 건수
                    ||  '             ,   SUM(D.ORD_AMT)                         AS ORD_AMT   '
                    ||  '         FROM ORDER_DT D                                             '
                    || q'[         WHERE D.SHIP_DT = TO_CHAR(TO_DATE(:PSV_SHIP_DT, 'YYYYMMDD') -1, 'YYYYMMDD')  ]'
                    || q'[          AND D.ORD_SEQ  = '2'            ]'
                    || q'[          AND D.ORD_FG  IN ( '01', '02' ) ]'
                    || q'[          AND D.ORD_QTY IS NOT NULL       ]'
                    || q'[          AND D.ORD_QTY  > 0              ]'
                    ||  '         GROUP BY D.BRAND_CD , '
                    ||  '                  D.STOR_CD  , '
                    ||  '                  D.ITEM_CD  , '
                    ||  '                  D.ORD_UNIT   '
                    ||  '         UNION ALL             '
                    ||  '         SELECT  D.BRAND_CD    '
                    ||  '             ,   D.STOR_CD     '
                    ||  '             ,   D.ITEM_CD     '
                    ||  '             ,   D.ORD_UNIT    '
                    || q'[            ,   SUM(DECODE(D.ORD_SEQ,'1',D.ORD_QTY,0)) AS ORD_QTY_1]' --1차주문 건수
                    || q'[            ,   SUM(DECODE(D.ORD_SEQ,'2',D.ORD_QTY,0)) AS ORD_QTY_2]' --2차주문 건수
                    || q'[            ,   SUM(DECODE(D.ORD_SEQ,'3',D.ORD_QTY,0)) AS ORD_QTY_3]' --3차주문 건수
                    ||  '             ,   SUM(D.ORD_AMT)                         AS ORD_AMT   '
                    ||  '         FROM ORDER_DT D                                             '
                    || q'[         WHERE D.SHIP_DT = TO_CHAR(TO_DATE(:PSV_SHIP_DT, 'YYYYMMDD') +1, 'YYYYMMDD')  ]'
                    || q'[          AND D.ORD_SEQ  = '3'            ]'
                    || q'[          AND D.ORD_FG  IN ( '01', '02' ) ]'
                    || q'[          AND D.ORD_QTY IS NOT NULL       ]'
                    || q'[          AND D.ORD_QTY  > 0              ]'
                    ||  '         GROUP BY D.BRAND_CD , '
                    ||  '                  D.STOR_CD  , '
                    ||  '                  D.ITEM_CD  , '
                    ||  '                  D.ORD_UNIT   '
                    ||  '       )       D,              '
                    ||  '       S_STORE S,              '
                    ||  '       S_ITEM  I               '
                    ||  ' WHERE D.BRAND_CD = S.BRAND_CD '
                    ||  '   AND D.STOR_CD  = S.STOR_CD  '
                    ||  '   AND D.ITEM_CD  = I.ITEM_CD  '
                    ||  ' GROUP BY D.BRAND_CD, D.STOR_CD, I.M_CLASS_CD, D.ITEM_CD, I.M_CLASS_NM, I.ITEM_NM, D.ORD_UNIT '
                    ||  ' ORDER BY D.BRAND_CD, D.STOR_CD, I.M_CLASS_CD, D.ITEM_CD '
                    ;

/*
        ls_sql_main :=
            '   SELECT  D.BRAND_CD'
        ||  '       ,   D.STOR_CD'
        ||  '       ,   I.M_CLASS_CD'
        ||  '       ,   I.M_CLASS_NM'
        ||  '       ,   D.ITEM_CD'
        ||  '       ,   I.ITEM_NM'
        ||  '       ,   D.ORD_UNIT'
        || q'[      ,   SUM(DECODE(D.ORD_SEQ,'1',D.ORD_QTY,0)) AS ORD_QTY_1]'
        || q'[      ,   SUM(DECODE(D.ORD_SEQ,'2',D.ORD_QTY,0)) AS ORD_QTY_2]'
        || q'[      ,   SUM(DECODE(D.ORD_SEQ,'3',D.ORD_QTY,0)) AS ORD_QTY_3]'
        ||  '       ,   SUM(D.ORD_AMT)  AS ORD_AMT'
        ||  '   FROM ORDER_HD H,'
        ||  '        ORDER_DT D,'
        ||  '        S_STORE S,'
        ||  '        S_ITEM I'
        ||  '   WHERE H.SHIP_DT  = D.SHIP_DT '
        ||  '     AND H.BRAND_CD = D.BRAND_CD '
        ||  '     AND H.STOR_CD  = D.STOR_CD '
        ||  '     AND H.ORD_SEQ  = D.ORD_SEQ '
        ||  '     AND H.ORD_FG   = D.ORD_FG '
        ||  '     AND D.BRAND_CD = S.BRAND_CD '
        ||  '     AND D.STOR_CD  = S.STOR_CD '
        ||  '     AND D.ITEM_CD  = I.ITEM_CD '
        ||  '     AND ' ||  ls_sql_date
        ||  '   GROUP BY D.BRAND_CD,'
        ||  '            D.STOR_CD,'
        ||  '            I.M_CLASS_CD,'
        ||  '            I.M_CLASS_NM,'
        ||  '            D.ITEM_CD,'
        ||  '            I.ITEM_NM,'
        ||  '            D.ORD_UNIT'
        ||  '   ORDER BY D.BRAND_CD, D.STOR_CD, I.M_CLASS_CD, D.ITEM_CD'
*/

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;
        OPEN PR_RESULT FOR
            ls_sql USING  PSV_SHIP_DT, PSV_SHIP_DT ;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN OTHERS THEN RAISE;
   END   ;

END PKG_ORDR4720;

/
