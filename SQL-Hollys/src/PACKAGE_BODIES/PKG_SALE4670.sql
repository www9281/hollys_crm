--------------------------------------------------------
--  DDL for Package Body PKG_SALE4670
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4670" AS
    PROCEDURE SP_TAB01 /*일별 시간대별 매출 - 매출금액*/
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,              -- 회사코드
        PSV_USER        IN  VARCHAR2 ,              -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,              -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,              -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,              -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,              -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,              -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,              -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,              -- Search 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,              -- 고객구분
        PSV_SALE_TYPE   IN  VARCHAR2 ,              -- 판매유형
        PSV_SEC_FG      IN  VARCHAR2 ,              -- 시간구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,              -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR, -- Result Set
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR, -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,              -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB01  일별 시간대별 매출 현황
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2010-02-01         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_SALE4670L0
          SYSDATE:         2011-04-15
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
        TYPE  rec_ct_hd IS RECORD
            ( sale_dt     VARCHAR2(8),
              sale_dt_nm  VARCHAR2(20)
            );
        TYPE tb_ct_hd IS TABLE OF rec_ct_hd
            INDEX BY PLS_INTEGER;

        qry_hd     tb_ct_hd  ;

        V_CROSSTAB     VARCHAR2(30000);
        V_SQL          VARCHAR2(30000);
        V_HD           VARCHAR2(30000);
        V_HD1         VARCHAR2(20000);
        V_HD2         VARCHAR2(20000);
        V_CNT          PLS_INTEGER;

        ls_sql          VARCHAR2(30000) ;
        ls_sql_with     VARCHAR2(30000) ;
        ls_sql_main     VARCHAR2(10000) ;
        ls_sql_date     VARCHAR2(1000) ;
        ls_sql_cm_00771 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
        ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
        ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
        ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
        ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
        ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
        ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
        ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
        ls_sql_pos      VARCHAR2(2000);     -- POS_NO

        ls_err_cd     VARCHAR2(7) := '0' ;
        ls_err_msg    VARCHAR2(500) ;

        lsRate        varchar2(200);


        ERR_HANDLER     EXCEPTION;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        dbms_output.enable( 1000000 ) ;

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00771 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00771') ;
        -------------------------------------------------------------------------------

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ;

    /* 가로축 데이타 FETCH */
       ls_sql_crosstab_main :=  Q'[ SELECT  A.SALE_DT, MAX('(' || SUBSTR(A.SALE_DT,1,4) || '-' || SUBSTR(A.SALE_DT,5,2)  || '-' || SUBSTR(A.SALE_DT,7,2)|| ')(' || W.CODE_NM || ')') AS SALE_DT_NM ]'
            ||chr(13)||chr(10)||Q'[   FROM  (   ]'
            ||chr(13)||chr(10)||Q'[             SELECT  A.COMP_CD, A.SALE_DT, A.BRAND_CD, A.STOR_CD ]'
            ||chr(13)||chr(10)||Q'[               FROM  SALE_HD A   ]'
            ||chr(13)||chr(10)||Q'[                  ,  (           ]'
            ||chr(13)||chr(10)||Q'[                         SELECT  COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO    ]'
            ||chr(13)||chr(10)||Q'[                           FROM  (   ]'
            ||chr(13)||chr(10)||Q'[                                     SELECT  COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO ]'
            ||chr(13)||chr(10)||Q'[                                          ,  SUM(CASE WHEN SALE_TYPE = '1' AND TAKE_DIV = '0' THEN 1 ELSE 0 END)     AS EAT_IN_CNT   ]'
            ||chr(13)||chr(10)||Q'[                                          ,  SUM(CASE WHEN SALE_TYPE = '1' AND TAKE_DIV = '1' THEN 1 ELSE 0 END)     AS TAKE_OUT_CNT ]'
            ||chr(13)||chr(10)||Q'[                                          ,  SUM(CASE WHEN SALE_TYPE = '2'                    THEN 1 ELSE 0 END)     AS DLV_CNT      ]'
            ||chr(13)||chr(10)||Q'[                                       FROM  SALE_DT     A   ]'
            ||chr(13)||chr(10)||Q'[                                      WHERE  A.COMP_CD   = :PSV_COMP_CD ]'
            ||chr(13)||chr(10)||Q'[                                        AND  A.SALE_DT  >= :PSV_GFR_DATE]'
            ||chr(13)||chr(10)||Q'[                                        AND  A.SALE_DT  <= :PSV_GTO_DATE]'
            ||chr(13)||chr(10)||Q'[                                        AND (:PSV_GIFT_DIV IS NULL OR A.GIFT_DIV = :PSV_GIFT_DIV)]'
            ||chr(13)||chr(10)||Q'[                                      GROUP  BY COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO ]'
            ||chr(13)||chr(10)||Q'[                                 )   D   ]'
            ||chr(13)||chr(10)||Q'[                          WHERE  (       ]'
            ||chr(13)||chr(10)||Q'[                                     :PSV_SALE_TYPE IS NULL  ]'
            ||chr(13)||chr(10)||Q'[                                     OR  ]'
            ||chr(13)||chr(10)||Q'[                                     (   ]'
            ||chr(13)||chr(10)||Q'[                                         (:PSV_SALE_TYPE = '01' AND EAT_IN_CNT > 0 AND TAKE_OUT_CNT = 0 AND DLV_CNT = 0) ]'
            ||chr(13)||chr(10)||Q'[                                         OR  ]'
            ||chr(13)||chr(10)||Q'[                                         (:PSV_SALE_TYPE = '02' AND EAT_IN_CNT = 0 AND TAKE_OUT_CNT > 0 AND DLV_CNT = 0) ]'
            ||chr(13)||chr(10)||Q'[                                         OR  ]'
            ||chr(13)||chr(10)||Q'[                                         (:PSV_SALE_TYPE = '03' AND EAT_IN_CNT > 0 AND TAKE_OUT_CNT > 0 AND DLV_CNT = 0) ]'
            ||chr(13)||chr(10)||Q'[                                         OR  ]'
            ||chr(13)||chr(10)||Q'[                                         (:PSV_SALE_TYPE = '04' AND EAT_IN_CNT = 0 AND TAKE_OUT_CNT = 0 AND DLV_CNT > 0) ]'
            ||chr(13)||chr(10)||Q'[                                     )   ]'
            ||chr(13)||chr(10)||Q'[                                 )   ]'
            ||chr(13)||chr(10)||Q'[                     )   D   ]'
            ||chr(13)||chr(10)||Q'[              WHERE  A.COMP_CD   = D.COMP_CD ]'
            ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT   = D.SALE_DT ]'
            ||chr(13)||chr(10)||Q'[                AND  A.BRAND_CD  = D.BRAND_CD]'
            ||chr(13)||chr(10)||Q'[                AND  A.STOR_CD   = D.STOR_CD ]'
            ||chr(13)||chr(10)||Q'[                AND  A.POS_NO    = D.POS_NO  ]'
            ||chr(13)||chr(10)||Q'[                AND  A.BILL_NO   = D.BILL_NO ]'
            ||chr(13)||chr(10)||Q'[                AND  A.COMP_CD   = :PSV_COMP_CD ]'
            ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT  >= :PSV_GFR_DATE]'
            ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT  <= :PSV_GTO_DATE]'
            ||chr(13)||chr(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR A.GIFT_DIV = :PSV_GIFT_DIV)]'
            ||chr(13)||chr(10)||Q'[         )   A       ]'
            ||chr(13)||chr(10)||Q'[      ,  S_STORE   B ]'
            ||chr(13)||chr(10)||Q'[      ,  ]' || ls_sql_cm_00771 || Q'[ W ]'
            ||chr(13)||chr(10)||Q'[  WHERE  A.COMP_CD  = B.COMP_CD  ]'
            ||chr(13)||chr(10)||Q'[    AND  A.BRAND_CD = B.BRAND_CD ]'
            ||chr(13)||chr(10)||Q'[    AND  A.STOR_CD  = B.STOR_CD  ]'
            ||chr(13)||chr(10)||Q'[    AND  TO_CHAR(TO_DATE(A.SALE_DT, 'YYYYMMDD'), 'D') = W.CODE_CD ]'
            ||chr(13)||chr(10)||Q'[  GROUP  BY A.SALE_DT        ]'
            ||chr(13)||chr(10)||Q'[  ORDER  BY A.SALE_DT DESC   ]';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;

        dbms_output.put_line(ls_sql) ;

        BEGIN
            EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd 
                USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV, 
                      PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE,
                      PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

             IF qry_hd.COUNT = 0 OR qry_hd.COUNT IS NULL  THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD , PSV_LANG_CD , ls_err_cd) ;
                RAISE ERR_HANDLER ;
            END IF ;
        EXCEPTION
            WHEN ERR_HANDLER THEN
                RAISE ERR_HANDLER ;
            WHEN NO_DATA_FOUND THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD , PSV_LANG_CD , ls_err_cd) ;
                RAISE ERR_HANDLER ;
            WHEN OTHERS THEN
                ls_err_cd := '4999999' ;
                ls_err_msg := SQLERRM ;
                RAISE ERR_HANDLER ;
        END;

        Begin
           select FC_GET_HEADER(PSV_COMP_CD, PSV_LANG_CD, 'RATE_01') INTO lsRate from dual ;
        Exception when no_data_found then
           lsRate := '점유비';
        end ;


        -- 조직, 점포, 점포명, 고객수, 수량, 시재매출액, 객단가, 점유비
    --    V_HD1 := ' SELECT CC01, CN01, CC05, CN05, V10, V01, V04, V11, R04, ' ;

    --     V_HD1 := ' SELECT CC01, CN01, CC05, CN05, ''' 
        V_HD1 := ' SELECT '
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD,PSV_LANG_CD,'BRAND_CD')||''' AS CC01, '
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD,PSV_LANG_CD,'BRAND_NM')||''' AS CN01, '              
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD,PSV_LANG_CD,'STOR_CD')||''' AS CC05, '
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD,PSV_LANG_CD,'STOR_NM')||''' AS CN05, '''              
              || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY') || ''', ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || ''', ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT') || ''', ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT1') || ''', ''' || lsRate || ''', ' ;
        V_HD2 := V_HD1 ;

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                   V_HD2 := V_HD2 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB || qry_hd(i).SALE_DT   ;
                V_HD1 := chr(13)||chr(10) ||V_HD1 || ''''   || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*5 - 4) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*5 - 3) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*5 - 2) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*5 - 1) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*5)   ;
                V_HD2 := V_HD2 || ' ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY') || ''' CT' || TO_CHAR(i*5 - 4 ) || ',' ;
                V_HD2 := V_HD2 || ' ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || ''' CT' || TO_CHAR(i*5 - 3 ) || ',' ;
                V_HD2 := V_HD2 || ' ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT') || ''' CT' || TO_CHAR(i*5 - 2 ) || ',' ;      -- 고객수
                V_HD2 := V_HD2 || ' ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT1') || ''' CT' || TO_CHAR(i*5 - 1 ) || ',' ;      -- 객단가
                V_HD2 := V_HD2 || ' ''' || lsRate || ''' ' || ' CT' || TO_CHAR(i*5)   ;
    --            V_HD2 := V_HD2 || ' R04  CT' || TO_CHAR(i*5)   ;                -- 점유비

            END;
        END LOOP;

        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
        V_HD   := PKG_REPORT.f_olap_hd(PSV_COMP_CD, PSV_LANG_CD)  ||  V_HD1 || ' UNION ALL ' || V_HD2 ;


        /* MAIN SQL */
        ls_sql_main :=      Q'[ SELECT  A.BRAND_CD, A.BRAND_NM, A.STOR_CD, A.STOR_NM, A.SALE_DT ]'
        ||chr(13)||chr(10)||Q'[      ,  SUM(A.SALE_QTY) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD)   AS TOT_SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[      ,  SUM(A.GRD_AMT)  OVER (PARTITION BY A.BRAND_CD, A.STOR_CD)   AS TOT_GRD_AMT  ]'
        ||chr(13)||chr(10)||Q'[      ,  SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD) AS TOT_CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[      ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD), 0, 0,   ]'
        ||chr(13)||chr(10)||Q'[                    SUM(A.GRD_AMT) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD) / SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD))  AS TOT_CUST_AMT ]'
        ||chr(13)||chr(10)||Q'[      ,  ROUND(SUM(A.GRD_AMT) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD) / SUM(A.GRD_AMT) OVER () * 100, 2)   AS TOT_RATIO ]'
        ||chr(13)||chr(10)||Q'[      ,  A.SALE_QTY  ]'
        ||chr(13)||chr(10)||Q'[      ,  A.GRD_AMT   ]'
        ||chr(13)||chr(10)||Q'[      ,  A.CUST_CNT  ]'
        ||chr(13)||chr(10)||Q'[      ,  A.CUST_AMT  ]'
        ||chr(13)||chr(10)||Q'[      ,  A.RATIO     ]'
        ||chr(13)||chr(10)||Q'[   FROM  ( ]'
        ||chr(13)||chr(10)||Q'[             SELECT  A.BRAND_CD, S.BRAND_NM, A.STOR_CD, S.STOR_NM, A.SALE_DT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.ETC_M_CNT) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) AS ETC_M_CNT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.ETC_F_CNT) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) AS ETC_F_CNT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.BILL_CNT)  OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) AS BILL_CNT  ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.R_BILL_CNT) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) AS R_BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.SALE_QTY) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) AS SALE_QTY   ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) AS GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) AS CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) / SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT)) AS CUST_AMT ]'
        ||chr(13)||chr(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.SALE_DT), 0, 0, ROUND(SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) / SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.SALE_DT) * 100, 2)) AS RATIO ]'
        ||chr(13)||chr(10)||Q'[               FROM  ( ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.SALE_DT ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(CASE WHEN A.SALE_DIV = '1' THEN 1 ELSE 0 END) AS BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(CASE WHEN A.SALE_DIV = '2' THEN 1 ELSE 0 END) AS R_BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(A.CUST_M_CNT) AS ETC_M_CNT ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(A.CUST_F_CNT) AS ETC_F_CNT ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(A.SALE_QTY)  AS SALE_QTY  ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(A.GRD_I_AMT + A.GRD_O_AMT) AS GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(A.SALE_AMT)  AS SALE_AMT  ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(A.VAT_I_AMT + A.VAT_O_AMT) AS VAT_AMT ]'
        ||chr(13)||chr(10)||Q'[                           FROM  SALE_HD A ]'
        ||chr(13)||chr(10)||Q'[                              ,  ( ]'
        ||chr(13)||chr(10)||Q'[                                     SELECT  COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO    ]'
        ||chr(13)||chr(10)||Q'[                                       FROM  (   ]'
        ||chr(13)||chr(10)||Q'[                                                 SELECT  COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO ]'
        ||chr(13)||chr(10)||Q'[                                                      ,  SUM(CASE WHEN SALE_TYPE = '1' AND TAKE_DIV = '0' THEN 1 ELSE 0 END)     AS EAT_IN_CNT   ]'
        ||chr(13)||chr(10)||Q'[                                                      ,  SUM(CASE WHEN SALE_TYPE = '1' AND TAKE_DIV = '1' THEN 1 ELSE 0 END)     AS TAKE_OUT_CNT ]'
        ||chr(13)||chr(10)||Q'[                                                      ,  SUM(CASE WHEN SALE_TYPE = '2'                    THEN 1 ELSE 0 END)     AS DLV_CNT      ]'
        ||chr(13)||chr(10)||Q'[                                                   FROM  SALE_DT     A   ]'
        ||chr(13)||chr(10)||Q'[                                                  WHERE  A.COMP_CD   = :PSV_COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                                                    AND  A.SALE_DT  >= :PSV_GFR_DATE ]'
        ||chr(13)||chr(10)||Q'[                                                    AND  A.SALE_DT  <= :PSV_GTO_DATE ]'
        ||chr(13)||chr(10)||Q'[                                                    AND (:PSV_GIFT_DIV IS NULL OR A.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||chr(13)||chr(10)||Q'[                                                  GROUP  BY COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO ]'
        ||chr(13)||chr(10)||Q'[                                             )   D   ]'
        ||chr(13)||chr(10)||Q'[                                      WHERE  (   ]'
        ||chr(13)||chr(10)||Q'[                                                    :PSV_SALE_TYPE IS NULL  ]'
        ||chr(13)||chr(10)||Q'[                                                 OR  ]'
        ||chr(13)||chr(10)||Q'[                                                 (   ]'
        ||chr(13)||chr(10)||Q'[                                                     (:PSV_SALE_TYPE = '01' AND EAT_IN_CNT > 0 AND TAKE_OUT_CNT = 0 AND DLV_CNT = 0) ]'
        ||chr(13)||chr(10)||Q'[                                                     OR  ]'
        ||chr(13)||chr(10)||Q'[                                                     (:PSV_SALE_TYPE = '02' AND EAT_IN_CNT = 0 AND TAKE_OUT_CNT > 0 AND DLV_CNT = 0) ]'
        ||chr(13)||chr(10)||Q'[                                                     OR  ]'
        ||chr(13)||chr(10)||Q'[                                                     (:PSV_SALE_TYPE = '03' AND EAT_IN_CNT > 0 AND TAKE_OUT_CNT > 0 AND DLV_CNT = 0) ]'
        ||chr(13)||chr(10)||Q'[                                                     OR  ]'
        ||chr(13)||chr(10)||Q'[                                                     (:PSV_SALE_TYPE = '04' AND EAT_IN_CNT = 0 AND TAKE_OUT_CNT = 0 AND DLV_CNT > 0) ]'
        ||chr(13)||chr(10)||Q'[                                                 )   ]'
        ||chr(13)||chr(10)||Q'[                                             )   ]'
        ||chr(13)||chr(10)||Q'[                                 )   D   ]'
        ||chr(13)||chr(10)||Q'[                          WHERE  A.COMP_CD   = D.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                            AND  A.SALE_DT   = D.SALE_DT ]'
        ||chr(13)||chr(10)||Q'[                            AND  A.BRAND_CD  = D.BRAND_CD]'
        ||chr(13)||chr(10)||Q'[                            AND  A.STOR_CD   = D.STOR_CD ]'
        ||chr(13)||chr(10)||Q'[                            AND  A.POS_NO    = D.POS_NO  ]'
        ||chr(13)||chr(10)||Q'[                            AND  A.BILL_NO   = D.BILL_NO ]'
        ||chr(13)||chr(10)||Q'[                            AND  A.COMP_CD   = :PSV_COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                            AND  A.SALE_DT  >= :PSV_GFR_DATE ]' 
        ||chr(13)||chr(10)||Q'[                            AND  A.SALE_DT  <= :PSV_GTO_DATE ]'
        ||chr(13)||chr(10)||Q'[                            AND (:PSV_GIFT_DIV IS NULL OR A.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||chr(13)||chr(10)||Q'[                          GROUP  BY A.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                              ,  A.BRAND_CD   ]'
        ||chr(13)||chr(10)||Q'[                              ,  A.STOR_CD    ]'
        ||chr(13)||chr(10)||Q'[                              ,  A.SALE_DT    ]'
        ||chr(13)||chr(10)||Q'[                     )  A ]'
        ||chr(13)||chr(10)||Q'[                  ,  S_STORE  S ]'
        ||chr(13)||chr(10)||Q'[              WHERE  A.COMP_CD  = S.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                AND  A.BRAND_CD = S.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                AND  A.STOR_CD  = S.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[         ) A ]'
        ;

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

    /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL :=             ' SELECT * '
        ||chr(13)||chr(10)|| ' FROM ( '
        ||chr(13)||chr(10)|| ls_sql
        ||chr(13)||chr(10)|| ' ) S_SALE '
        ||chr(13)||chr(10)|| ' PIVOT '
        ||chr(13)||chr(10)|| ' ( SUM(SALE_QTY) VCOL1 '
        ||chr(13)||chr(10)|| ' , SUM(GRD_AMT)  VCOL2 '
        ||chr(13)||chr(10)|| ' , SUM(CUST_CNT) VCOL3 '
        ||chr(13)||chr(10)|| ' , SUM(CUST_AMT) VCOL4 '
        ||chr(13)||chr(10)|| ' , SUM(RATIO)    VCOL5 '
        ||chr(13)||chr(10)|| ' FOR (SALE_DT ) IN ( '
        ||chr(13)||chr(10)|| V_CROSSTAB
        ||chr(13)||chr(10)|| ' ) ) '
        ||chr(13)||chr(10)|| 'ORDER BY BRAND_CD, STOR_CD ASC';

        dbms_output.put_line( V_HD) ;

        dbms_output.put_line( '==============================================================') ;
        dbms_output.put_line( V_SQL) ;

        OPEN PR_HEADER FOR      V_HD ;
        OPEN PR_RESULT FOR      V_SQL
            USING   PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, 
                    PSV_FILTER, PSV_CUST_DIV, PSV_CUST_DIV, PSV_FILTER, PSV_CUST_DIV, PSV_FILTER, PSV_FILTER, PSV_FILTER,
                    PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                    PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE,
                    PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;

            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;

            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END ;

    PROCEDURE SP_TAB02 /*일별 시간대별 매출 - 매출수량*/
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,              -- 회사코드
        PSV_USER        IN  VARCHAR2 ,              -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,              -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,              -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,              -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,              -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,              -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,              -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,              -- Search 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,              -- 고객구분
        PSV_SALE_TYPE   IN  VARCHAR2 ,              -- 판매유형
        PSV_SEC_FG      IN  VARCHAR2 ,              -- 시간구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,              -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,-- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,-- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,              -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB02  일별 시간대별 매출 현황 - 시간대 상세
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2010-02-01         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_SALE4670L1
          SYSDATE:         2011-04-15
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
        TYPE  rec_ct_hd IS RECORD
            ( sale_dt     VARCHAR2(8),
              sale_dt_nm  VARCHAR2(20)
            );
        TYPE tb_ct_hd IS TABLE OF rec_ct_hd
            INDEX BY PLS_INTEGER;

        qry_hd     tb_ct_hd  ;

        V_CROSSTAB     VARCHAR2(30000);
        V_SQL          VARCHAR2(30000);
        V_HD           VARCHAR2(30000);
        V_HD1          VARCHAR2(20000);
        V_HD2          VARCHAR2(20000);
        lsTitle1       VARCHAR2(200);
        lsTitle2       VARCHAR2(200);
        V_CNT          PLS_INTEGER;

        ls_sql          VARCHAR2(30000) ;
        ls_sql_with     VARCHAR2(30000) ;
        ls_sql_main     VARCHAR2(20000) ;
        ls_sql_date     VARCHAR2(1000) ;
        ls_sql_cm_00771 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
        ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
        ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
        ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
        ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
        ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
        ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
        ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
        ls_sql_pos      VARCHAR2(2000);     -- POS_NO

        ls_err_cd     VARCHAR2(7) := '0' ;
        ls_err_msg    VARCHAR2(500) ;

        ERR_HANDLER     EXCEPTION;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        dbms_output.enable( 1000000 ) ;

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        --   ls_sql_cm_01415 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '01415') ;
         ls_sql_cm_00771 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00771') ;
        -------------------------------------------------------------------------------

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ;

        /* 가로축 데이타 FETCH */
       ls_sql_crosstab_main :=  Q'[ SELECT  A.SALE_DT, MAX('(' || SUBSTR(A.SALE_DT,1,4) || '-' || SUBSTR(A.SALE_DT,5,2)  || '-' || SUBSTR(A.SALE_DT,7,2)|| ')(' || W.CODE_NM || ')') AS SALE_DT_NM ]'
            ||chr(13)||chr(10)||Q'[   FROM  (   ]'
            ||chr(13)||chr(10)||Q'[             SELECT  A.COMP_CD, A.SALE_DT, A.BRAND_CD, A.STOR_CD ]'
            ||chr(13)||chr(10)||Q'[               FROM  SALE_HD A   ]'
            ||chr(13)||chr(10)||Q'[                  ,  (           ]'
            ||chr(13)||chr(10)||Q'[                         SELECT  COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO    ]'
            ||chr(13)||chr(10)||Q'[                           FROM  (   ]'
            ||chr(13)||chr(10)||Q'[                                     SELECT  COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO ]'
            ||chr(13)||chr(10)||Q'[                                          ,  SUM(CASE WHEN SALE_TYPE = '1' AND TAKE_DIV = '0' THEN 1 ELSE 0 END)     AS EAT_IN_CNT   ]'
            ||chr(13)||chr(10)||Q'[                                          ,  SUM(CASE WHEN SALE_TYPE = '1' AND TAKE_DIV = '1' THEN 1 ELSE 0 END)     AS TAKE_OUT_CNT ]'
            ||chr(13)||chr(10)||Q'[                                          ,  SUM(CASE WHEN SALE_TYPE = '2'                    THEN 1 ELSE 0 END)     AS DLV_CNT      ]'
            ||chr(13)||chr(10)||Q'[                                       FROM  SALE_DT     A   ]'
            ||chr(13)||chr(10)||Q'[                                      WHERE  A.COMP_CD   = :PSV_COMP_CD  ]'
            ||chr(13)||chr(10)||Q'[                                        AND  A.SALE_DT  >= :PSV_GFR_DATE ]'
            ||chr(13)||chr(10)||Q'[                                        AND  A.SALE_DT  <= :PSV_GTO_DATE ]'
            ||chr(13)||chr(10)||Q'[                                        AND (:PSV_GIFT_DIV IS NULL OR A.GIFT_DIV = :PSV_GIFT_DIV)]'
            ||chr(13)||chr(10)||Q'[                                      GROUP  BY COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO ]'
            ||chr(13)||chr(10)||Q'[                                 )   D   ]'
            ||chr(13)||chr(10)||Q'[                          WHERE  (   ]'
            ||chr(13)||chr(10)||Q'[                                     :PSV_SALE_TYPE IS NULL  ]'
            ||chr(13)||chr(10)||Q'[                                     OR  ]'
            ||chr(13)||chr(10)||Q'[                                     (   ]'
            ||chr(13)||chr(10)||Q'[                                         (:PSV_SALE_TYPE = '01' AND EAT_IN_CNT > 0 AND TAKE_OUT_CNT = 0 AND DLV_CNT = 0) ]'
            ||chr(13)||chr(10)||Q'[                                         OR  ]'
            ||chr(13)||chr(10)||Q'[                                         (:PSV_SALE_TYPE = '02' AND EAT_IN_CNT = 0 AND TAKE_OUT_CNT > 0 AND DLV_CNT = 0) ]'
            ||chr(13)||chr(10)||Q'[                                         OR  ]'
            ||chr(13)||chr(10)||Q'[                                         (:PSV_SALE_TYPE = '03' AND EAT_IN_CNT > 0 AND TAKE_OUT_CNT > 0 AND DLV_CNT = 0) ]'
            ||chr(13)||chr(10)||Q'[                                         OR  ]'
            ||chr(13)||chr(10)||Q'[                                         (:PSV_SALE_TYPE = '04' AND EAT_IN_CNT = 0 AND TAKE_OUT_CNT = 0 AND DLV_CNT > 0) ]'
            ||chr(13)||chr(10)||Q'[                                     )   ]'
            ||chr(13)||chr(10)||Q'[                                 )   ]'
            ||chr(13)||chr(10)||Q'[                     )   D   ]'
            ||chr(13)||chr(10)||Q'[              WHERE  A.COMP_CD   = D.COMP_CD ]'
            ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT   = D.SALE_DT ]'
            ||chr(13)||chr(10)||Q'[                AND  A.BRAND_CD  = D.BRAND_CD]'
            ||chr(13)||chr(10)||Q'[                AND  A.STOR_CD   = D.STOR_CD ]'
            ||chr(13)||chr(10)||Q'[                AND  A.POS_NO    = D.POS_NO  ]'
            ||chr(13)||chr(10)||Q'[                AND  A.BILL_NO   = D.BILL_NO ]'
            ||chr(13)||chr(10)||Q'[                AND  A.COMP_CD   = :PSV_COMP_CD ]'
            ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT  >= :PSV_GFR_DATE ]'
            ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT  <= :PSV_GTO_DATE ]'
            ||chr(13)||chr(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR A.GIFT_DIV = :PSV_GIFT_DIV)]'
            ||chr(13)||chr(10)||Q'[         )   A       ]'
            ||chr(13)||chr(10)||Q'[      ,  S_STORE   B ]'
            ||chr(13)||chr(10)||Q'[      ,  ]' || ls_sql_cm_00771 || Q'[ W ]'
            ||chr(13)||chr(10)||Q'[  WHERE  A.COMP_CD  = B.COMP_CD  ]'
            ||chr(13)||chr(10)||Q'[    AND  A.BRAND_CD = B.BRAND_CD ]'
            ||chr(13)||chr(10)||Q'[    AND  A.STOR_CD  = B.STOR_CD  ]'
            ||chr(13)||chr(10)||Q'[    AND  TO_CHAR(TO_DATE(A.SALE_DT, 'YYYYMMDD'), 'D') = W.CODE_CD ]'
            ||chr(13)||chr(10)||Q'[  GROUP  BY A.SALE_DT        ]'
            ||chr(13)||chr(10)||Q'[  ORDER  BY A.SALE_DT DESC   ]';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;

        dbms_output.put_line(ls_sql) ;

        BEGIN
            EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd
                USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                      PSV_GIFT_DIV, PSV_GIFT_DIV,
                      PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE,
                      PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                      PSV_GIFT_DIV, PSV_GIFT_DIV;

             IF qry_hd.COUNT = 0 OR qry_hd.COUNT IS NULL  THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD , PSV_LANG_CD , ls_err_cd) ;
                RAISE ERR_HANDLER ;
            END IF ;
        EXCEPTION
            WHEN ERR_HANDLER THEN
                RAISE ERR_HANDLER ;
            WHEN NO_DATA_FOUND THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD , PSV_LANG_CD , ls_err_cd) ;
                RAISE ERR_HANDLER ;
            WHEN OTHERS THEN
                ls_err_cd := '4999999' ;
                ls_err_msg := SQLERRM ;
                RAISE ERR_HANDLER ;
        END;


        Begin
           select FC_GET_HEADER(PSV_COMP_CD, PSV_LANG_CD, 'RATE_01'), FC_GET_HEADER(PSV_COMP_CD, PSV_LANG_CD, 'ADD_AMT') INTO lsTitle1, lsTitle2 from DUAL ;
        Exception when no_data_found then
           lsTitle1 := '점유비';
           lsTitle2 := '누적액';
        end ;

        V_HD1 := ' SELECT ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB') || ''', ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY') || ''', ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || ''', ''' || lsTitle2 || ''',  ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT') || ''', ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT1') || ''',  ''' || lsTitle1 || ''', ' ;

        V_HD2 := V_HD1 ;

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                   V_HD2 := V_HD2 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB || qry_hd(i).SALE_DT   ;
                V_HD1 := chr(13)||chr(10) ||V_HD1 || '''' || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*6 - 5) || ',' ;
                V_HD1 := chr(13)||chr(10) ||V_HD1 || '''' || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*6 - 4) || ',' ;
                V_HD1 := chr(13)||chr(10) ||V_HD1 || '''' || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*6 - 3) || ',' ;
                V_HD1 := chr(13)||chr(10) ||V_HD1 || '''' || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*6 - 2) || ',' ;
                V_HD1 := chr(13)||chr(10) ||V_HD1 || '''' || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*6 - 1) || ',' ;
                V_HD1 := chr(13)||chr(10) ||V_HD1 || '''' || qry_hd(i).SALE_DT_NM  || ''' CT' || TO_CHAR(i*6)   ;
                V_HD2 := chr(13)||chr(10) ||V_HD2 || '''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY') || ''' CT' || TO_CHAR(i*6 - 5 ) || ',' ;
                V_HD2 := chr(13)||chr(10) ||V_HD2 || '''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || ''' CT' || TO_CHAR(i*6 - 4 ) || ',' ;
                V_HD2 := chr(13)||chr(10) ||V_HD2 || '''' || lsTitle2 || ''' ' || ' CT' || TO_CHAR(i*6 - 3)  || ',' ;
                V_HD2 := chr(13)||chr(10) ||V_HD2 || '''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT') || ''' CT' || TO_CHAR(i*6 - 2 ) || ',' ;
                V_HD2 := chr(13)||chr(10) ||V_HD2 || '''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT1') || ''' CT' || TO_CHAR(i*6 - 1 ) || ',' ;
                V_HD2 := chr(13)||chr(10) ||V_HD2 || '''' || lsTitle1 || ''' ' || ' CT' || TO_CHAR(i*6)   ;

            END;
        END LOOP;

        V_HD1 :=  V_HD1 || ' FROM DUAL ' ;
        V_HD2 :=  V_HD2 || ' FROM DUAL ' ;
        V_HD   := V_HD1 || ' UNION ALL ' || V_HD2 ;

        /* MAIN SQL */
        ls_sql_main :=      Q'[ SELECT  A.SEC_DIV, A.SALE_DT ]'
        ||chr(13)||chr(10)||Q'[      ,  SUM(A.SALE_QTY) OVER (PARTITION BY A.SEC_DIV) AS TOT_SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[      ,  SUM(A.GRD_AMT) OVER (PARTITION BY A.SEC_DIV) AS TOT_GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[      ,  SUM(A.GRD_AMT) OVER (ORDER BY A.SEC_DIV) AS TOT_ADD_GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[      ,  SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.SEC_DIV) AS TOT_CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[      ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.SEC_DIV), 0, 0, SUM(A.GRD_AMT) OVER (PARTITION BY A.SEC_DIV) / SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.SEC_DIV)) AS TOT_CUST_AMT ]'
        ||chr(13)||chr(10)||Q'[      ,  DECODE(SUM(A.GRD_AMT) OVER (), 0, 0, ROUND(SUM(A.GRD_AMT) OVER (PARTITION BY A.SEC_DIV) / SUM(A.GRD_AMT) over () * 100, 2)) AS TOT_RATIO ]'
        ||chr(13)||chr(10)||Q'[      ,  A.SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[      ,  A.GRD_AMT  ]'
        ||chr(13)||chr(10)||Q'[      ,  A.ADD_GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[      ,  A.CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[      ,  A.CUST_AMT ]'
        ||chr(13)||chr(10)||Q'[      ,  A.RATIO    ]'
        ||chr(13)||chr(10)||Q'[   FROM  ( ]'
        ||chr(13)||chr(10)||Q'[             SELECT  A.SEC_DIV, A.SALE_DT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.ETC_M_CNT) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV) AS ETC_M_CNT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.ETC_F_CNT) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV) AS ETC_F_CNT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.BILL_CNT)  OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV) AS BILL_CNT  ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.R_BILL_CNT) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV) AS R_BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(A.SALE_QTY) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV) AS SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV) AS GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT ORDER BY A.SALE_DT DESC, A.SEC_DIV ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ADD_GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV) AS CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV) / SUM(DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV)) AS CUST_AMT ]'
        ||chr(13)||chr(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT), 0, 0, ROUND(SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV) / SUM(DECODE(:PSV_FILTER, 'G', A.GRD_AMT, 'T', A.SALE_AMT, A.GRD_AMT - A.VAT_AMT)) OVER (PARTITION BY A.BRAND_CD, A.STOR_CD, A.SALE_DT) * 100, 2)) AS RATIO ]'
        ||chr(13)||chr(10)||Q'[               FROM  ( ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SEC_DIV ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(NVL(B.BILL_CNT, 0))     AS BILL_CNT   ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(NVL(B.R_BILL_CNT, 0))   AS R_BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(NVL(B.ETC_M_CNT, 0))    AS ETC_M_CNT  ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(NVL(B.ETC_F_CNT, 0))    AS ETC_F_CNT  ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(NVL(B.SALE_QTY, 0))     AS SALE_QTY   ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(NVL(B.GRD_AMT, 0))      AS GRD_AMT    ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(NVL(B.SALE_AMT, 0))     AS SALE_AMT   ]'
        ||chr(13)||chr(10)||Q'[                              ,  SUM(NVL(B.VAT_AMT, 0))      AS VAT_AMT    ]'
        ||chr(13)||chr(10)||Q'[                           FROM  ( ]'
        ||chr(13)||chr(10)||Q'[                                     SELECT  * ]'
        ||chr(13)||chr(10)||Q'[                                       FROM  ( ]'
        ||chr(13)||chr(10)||Q'[                                                 SELECT  LPAD(LEVEL-1, 2, '0') AS SEC_DIV ]'
        ||chr(13)||chr(10)||Q'[                                                   FROM  DUAL ]'
        ||chr(13)||chr(10)||Q'[                                                CONNECT  BY LEVEL <= 24 ]'
        ||chr(13)||chr(10)||Q'[                                             )   T ]'
        ||chr(13)||chr(10)||Q'[                                          ,  ( ]'
        ||chr(13)||chr(10)||Q'[                                                 SELECT  COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                                                      ,  SALE_DT     ]'
        ||chr(13)||chr(10)||Q'[                                                      ,  BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                                                      ,  STOR_CD     ]'
        ||chr(13)||chr(10)||Q'[                                                   FROM  SALE_JTS A  ]'
        ||chr(13)||chr(10)||Q'[                                                  WHERE  A.COMP_CD  = :PSV_COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                                                    AND  A.SALE_DT >= :PSV_GFR_DATE ]'
        ||chr(13)||chr(10)||Q'[                                                    AND  A.SALE_DT <= :PSV_GTO_DATE ]'
        ||chr(13)||chr(10)||Q'[                                                    AND  A.SEC_FG   = :PSV_SEC_FG   ]'
        ||chr(13)||chr(10)||Q'[                                                  GROUP  BY COMP_CD, SALE_DT, BRAND_CD, STOR_CD ]'
        ||chr(13)||chr(10)||Q'[                                             )   S ]'
        ||chr(13)||chr(10)||Q'[                                 )   A ]'
        ||chr(13)||chr(10)||Q'[                              ,  ( ]'
        ||chr(13)||chr(10)||Q'[                                     SELECT  A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.SALE_DT ]'
        ||chr(13)||chr(10)||Q'[                                          ,  DECODE(:PSV_SEC_FG, '1', SUBSTR(A.SORD_TM, 1, 2), SUBSTR(A.SALE_TM, 1, 2)) AS SEC_DIV ]'
        ||chr(13)||chr(10)||Q'[                                          ,  SUM(CASE WHEN A.SALE_DIV = '1' THEN 1 ELSE 0 END) AS BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                                          ,  SUM(CASE WHEN A.SALE_DIV = '2' THEN 1 ELSE 0 END) AS R_BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                                          ,  SUM(A.CUST_M_CNT) AS ETC_M_CNT ]'
        ||chr(13)||chr(10)||Q'[                                          ,  SUM(A.CUST_F_CNT) AS ETC_F_CNT ]'
        ||chr(13)||chr(10)||Q'[                                          ,  SUM(A.SALE_QTY)  AS SALE_QTY  ]'
        ||chr(13)||chr(10)||Q'[                                          ,  SUM(A.GRD_I_AMT + A.GRD_O_AMT) AS GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[                                          ,  SUM(A.SALE_AMT)  AS SALE_AMT  ]'
        ||chr(13)||chr(10)||Q'[                                          ,  SUM(A.VAT_I_AMT + A.VAT_O_AMT) AS VAT_AMT ]'
        ||chr(13)||chr(10)||Q'[                                       FROM  SALE_HD A ]'
        ||chr(13)||chr(10)||Q'[                                          ,  ( ]'
        ||chr(13)||chr(10)||Q'[                                                 SELECT  COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO    ]'
        ||chr(13)||chr(10)||Q'[                                                   FROM  (   ]'
        ||chr(13)||chr(10)||Q'[                                                             SELECT  COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO ]'
        ||chr(13)||chr(10)||Q'[                                                                  ,  SUM(CASE WHEN SALE_TYPE = '1' AND TAKE_DIV = '0' THEN 1 ELSE 0 END)     AS EAT_IN_CNT   ]'
        ||chr(13)||chr(10)||Q'[                                                                  ,  SUM(CASE WHEN SALE_TYPE = '1' AND TAKE_DIV = '1' THEN 1 ELSE 0 END)     AS TAKE_OUT_CNT ]'
        ||chr(13)||chr(10)||Q'[                                                                  ,  SUM(CASE WHEN SALE_TYPE = '2'                    THEN 1 ELSE 0 END)     AS DLV_CNT      ]'
        ||chr(13)||chr(10)||Q'[                                                               FROM  SALE_DT     A   ]'
        ||chr(13)||chr(10)||Q'[                                                              WHERE  A.COMP_CD   = :PSV_COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                                                                AND  A.SALE_DT  >= :PSV_GFR_DATE ]'
        ||chr(13)||chr(10)||Q'[                                                                AND  A.SALE_DT  <= :PSV_GTO_DATE ]'
        ||chr(13)||chr(10)||Q'[                                                                AND (:PSV_GIFT_DIV IS NULL OR A.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||chr(13)||chr(10)||Q'[                                                              GROUP  BY COMP_CD, SALE_DT, BRAND_CD, STOR_CD, POS_NO, BILL_NO ]'
        ||chr(13)||chr(10)||Q'[                                                         )   D   ]'
        ||chr(13)||chr(10)||Q'[                                                  WHERE  (   ]'
        ||chr(13)||chr(10)||Q'[                                                             :PSV_SALE_TYPE IS NULL  ]'
        ||chr(13)||chr(10)||Q'[                                                             OR  ]'
        ||chr(13)||chr(10)||Q'[                                                             (   ]'
        ||chr(13)||chr(10)||Q'[                                                                 (:PSV_SALE_TYPE = '01' AND EAT_IN_CNT > 0 AND TAKE_OUT_CNT = 0 AND DLV_CNT = 0) ]'
        ||chr(13)||chr(10)||Q'[                                                                 OR  ]'
        ||chr(13)||chr(10)||Q'[                                                                 (:PSV_SALE_TYPE = '02' AND EAT_IN_CNT = 0 AND TAKE_OUT_CNT > 0 AND DLV_CNT = 0) ]'
        ||chr(13)||chr(10)||Q'[                                                                 OR  ]'
        ||chr(13)||chr(10)||Q'[                                                                 (:PSV_SALE_TYPE = '03' AND EAT_IN_CNT > 0 AND TAKE_OUT_CNT > 0 AND DLV_CNT = 0) ]'
        ||chr(13)||chr(10)||Q'[                                                                 OR  ]'
        ||chr(13)||chr(10)||Q'[                                                                 (:PSV_SALE_TYPE = '04' AND EAT_IN_CNT = 0 AND TAKE_OUT_CNT = 0 AND DLV_CNT > 0) ]'
        ||chr(13)||chr(10)||Q'[                                                             )   ]'
        ||chr(13)||chr(10)||Q'[                                                         )   ]'
        ||chr(13)||chr(10)||Q'[                                             )   D   ]'
        ||chr(13)||chr(10)||Q'[                                      WHERE  A.COMP_CD   = D.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                                        AND  A.SALE_DT   = D.SALE_DT ]'
        ||chr(13)||chr(10)||Q'[                                        AND  A.BRAND_CD  = D.BRAND_CD]'
        ||chr(13)||chr(10)||Q'[                                        AND  A.STOR_CD   = D.STOR_CD ]'
        ||chr(13)||chr(10)||Q'[                                        AND  A.POS_NO    = D.POS_NO  ]'
        ||chr(13)||chr(10)||Q'[                                        AND  A.BILL_NO   = D.BILL_NO ]'
        ||chr(13)||chr(10)||Q'[                                        AND  A.COMP_CD   = :PSV_COMP_CD]'
        ||chr(13)||chr(10)||Q'[                                        AND  A.SALE_DT  >= :PSV_GFR_DATE ]'
        ||chr(13)||chr(10)||Q'[                                        AND  A.SALE_DT  <= :PSV_GTO_DATE ]'
        ||chr(13)||chr(10)||Q'[                                        AND (:PSV_GIFT_DIV IS NULL OR A.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||chr(13)||chr(10)||Q'[                                      GROUP  BY A.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                                          ,  A.BRAND_CD   ]'
        ||chr(13)||chr(10)||Q'[                                          ,  A.STOR_CD    ]'
        ||chr(13)||chr(10)||Q'[                                          ,  A.SALE_DT    ]'
        ||chr(13)||chr(10)||Q'[                                          ,  DECODE(:PSV_SEC_FG, '1', SUBSTR(A.SORD_TM, 1, 2), SUBSTR(A.SALE_TM, 1, 2)) ]'
        ||chr(13)||chr(10)||Q'[                                 )  B ]'
        ||chr(13)||chr(10)||Q'[                          WHERE  A.COMP_CD  = B.COMP_CD(+) ]'
        ||chr(13)||chr(10)||Q'[                            AND  A.SALE_DT  = B.SALE_DT(+) ]'
        ||chr(13)||chr(10)||Q'[                            AND  A.BRAND_CD = B.BRAND_CD(+)]'
        ||chr(13)||chr(10)||Q'[                            AND  A.STOR_CD  = B.STOR_CD(+) ]'
        ||chr(13)||chr(10)||Q'[                            AND  A.SEC_DIV  = B.SEC_DIV(+) ]'
        ||chr(13)||chr(10)||Q'[                          GROUP  BY A.COMP_CD]'
        ||chr(13)||chr(10)||Q'[                              ,  A.BRAND_CD  ]'
        ||chr(13)||chr(10)||Q'[                              ,  A.STOR_CD   ]'
        ||chr(13)||chr(10)||Q'[                              ,  A.SALE_DT   ]'
        ||chr(13)||chr(10)||Q'[                              ,  A.SEC_DIV   ]'
        ||chr(13)||chr(10)||Q'[                     )   A ]'
        ||chr(13)||chr(10)||Q'[                  ,  S_STORE  S ]'
        ||chr(13)||chr(10)||Q'[              WHERE  A.COMP_CD  = S.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                AND  A.BRAND_CD = S.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                AND  A.STOR_CD  = S.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[         )   A ]'
        ;

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

    /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL :=             ' SELECT * '
        ||chr(13)||chr(10)|| ' FROM ( '
        ||chr(13)||chr(10)|| ls_sql
        ||chr(13)||chr(10)|| ' ) S_SALE '
        ||chr(13)||chr(10)|| ' PIVOT '
        ||chr(13)||chr(10)|| ' (  SUM(SALE_QTY   )  VCOL1 '
        ||chr(13)||chr(10)|| '  , SUM(GRD_AMT    )  VCOL2 '
        ||chr(13)||chr(10)|| '  , SUM(ADD_GRD_AMT)  VCOL3 '
        ||chr(13)||chr(10)|| '  , SUM(CUST_CNT   )  VCOL4 '
        ||chr(13)||chr(10)|| '  , SUM(CUST_AMT   )  VCOL5 '
        ||chr(13)||chr(10)|| '  , SUM(RATIO      )  VCOL6 '
        ||chr(13)||chr(10)|| ' FOR (SALE_DT) IN ( '
        ||chr(13)||chr(10)|| V_CROSSTAB
        ||chr(13)||chr(10)|| ' ) ) '
        ||chr(13)||chr(10)|| 'ORDER BY 1, 2 ASC';

        dbms_output.put_line( V_HD) ;
        dbms_output.put_line( '==============================================================') ;
        dbms_output.put_line( V_SQL) ;

        OPEN PR_HEADER FOR      V_HD ;
        OPEN PR_RESULT FOR      V_SQL
            USING   PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV,
                    PSV_FILTER, PSV_FILTER, PSV_CUST_DIV, PSV_CUST_DIV, PSV_FILTER, PSV_CUST_DIV, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                    PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_SEC_FG, PSV_SEC_FG,
                    PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                    PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE, PSV_SALE_TYPE,
                    PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV, PSV_SEC_FG;


        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;

            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;

            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END ;
END PKG_SALE4670;

/
