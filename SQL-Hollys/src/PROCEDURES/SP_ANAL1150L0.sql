--------------------------------------------------------
--  DDL for Procedure SP_ANAL1150L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1150L0" /* 매장손익분석 */
(   
  PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
  PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR  , -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드 
  PR_RTN_MSG      OUT VARCHAR2    -- 처리Message 
)    
IS       
/******************************************************************************
   NAME:       SP_ANAL1160L0 매장손익분석
   PURPOSE:    

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-01-10         1. CREATED THIS PROCEDURE.

   NOTES: 

      OBJECT NAME:     SP_ANAL1160L0
      SYSDATE:          
      USERNAME:        
      TABLE NAME:       
******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    ( 
        SEC_DIV     VARCHAR2(10),
        SEC_DIV_NM  VARCHAR2(60)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
    INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB      VARCHAR2(30000);
    V_SQL           VARCHAR2(30000);
    V_HD            VARCHAR2(30000);
    V_HD1           VARCHAR2(20000);
    V_HD2           VARCHAR2(20000);
    V_CNT           PLS_INTEGER;

    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_date2    VARCHAR2(1000) ;
    ls_ymd_date     VARCHAR2(1000) ;
    ls_ymd_date2    VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role) 
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
    lsTitle1        VARCHAR2(20);

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    ERR_HANDLER   EXCEPTION;

BEGIN

    dbms_output.enable( 1000000 ) ; 

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql_with := ' WITH  '
                ||  ls_sql_store -- S_STORE
    --     ||  ', '
    --     ||  ls_sql_item  -- S_ITEM  
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
    ls_sql_date := ' GOAL_YM ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND GOAL_YM ' || ls_ex_date1 ;
    END IF;            

    -- 대비기간 처리--------------------------------------------------------------- 
    --ls_sql_date2 := ' ICR.CALC_YM ' || ls_date2;
    /****************************************************************************** 
    IF ls_ex_date2 IS NOT NULL THEN
       ls_sql_date2 := ls_sql_date2 || ' AND S.SALE_DT ' || ls_ex_date2 ;
    END IF;
    *******************************************************************************/

    /*** 가로축 데이타 FETCH ***/
    ls_sql_crosstab_main :=
               ' SELECT  DISTINCT STO.STOR_CD, STO.STOR_NM'
            || ' FROM    PL_GOAL_YM  PGY,'
            || '        S_STORE     STO'
            || ' WHERE   STO.COMP_CD  = PGY.COMP_CD  '
            || ' AND     STO.BRAND_CD = PGY.BRAND_CD '
            || ' AND     STO.STOR_CD  = PGY.STOR_CD '
            || ' AND     STO.COMP_CD  = ''' || PSV_COMP_CD || ''''
            || ' AND     ' ||  ls_sql_date
            || ' AND     PGY.GOAL_DIV = ''3'''
            || ' ORDER BY STO.STOR_CD ';

    --dbms_output.put_line(ls_sql_crosstab_main) ;

    ls_sql := ls_sql_with || ls_sql_crosstab_main ;
    --dbms_output.put_line(ls_sql) ;

    BEGIN
        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

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

    /*** HEADER MAKE START ***/
    SELECT  FC_GET_WORDPACK(PSV_COMP_CD , PSV_LANG_CD, 'ACC_TITLE') INTO lsTitle1  from DUAL ;

    V_HD1 := ' SELECT ''' || lsTitle1 || ''' , '  ;

    V_HD2 := V_HD1 ;

    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ' , ';
               V_HD1 := V_HD1 || ' , ' ;
               --V_HD2 := V_HD2 || ' , ' ;
            END IF;

            V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).SEC_DIV || ''' AS COL_'|| TO_CHAR(i, 'FM000');
            --V_HD1 := V_HD1 || ' V04  CT' || TO_CHAR(i)  ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SEC_DIV_NM  ||  ''' CT' || TO_CHAR(i) ;

        END;
    END LOOP;

    V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
    --V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
    V_HD   := PKG_REPORT.f_olap_hd(PSV_COMP_CD , PSV_LANG_CD)  ||  V_HD1 ; --|| ' UNION ALL ' || V_HD2 ;

    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
    -------------------------------------------------------------------------------
    ls_sql_main :=              '   SELECT  ''[''||V03.ACC_CD||'']''||V03.ACC_NM AS ACC_NM,                                 '
        || chr(13)||chr(10) ||  '           V03.ACC_CD                       AS ACC_CD,                                     '
        || chr(13)||chr(10) ||  '           V03.ACC_LVL                      AS ACC_LVL,                                    '
        || chr(13)||chr(10) ||  '           V03.STOR_CD                      AS STOR_CD,                                    '
        || chr(13)||chr(10) ||  '           V03.R_NUM                        AS R_NUM,                                      '
        || chr(13)||chr(10) ||  '           V03.ACC_GRD_HALL                 AS ACC_GRD_HALL,                               '
        || chr(13)||chr(10) ||  '           CASE WHEN TO_NUMBER(V03.ACC_CD) >= 10800 AND SUM(V03.ACC_GRD_STD) OVER(PARTITION BY V03.STOR_CD) > 0 '
        || chr(13)||chr(10) ||  '                THEN V03.ACC_GRD_HALL/SUM(V03.ACC_GRD_STD) OVER(PARTITION BY V03.STOR_CD)  '
        || chr(13)||chr(10) ||  '                ELSE NULL END *100          AS ACC_GRD_HALL_RATE,                          '
        || chr(13)||chr(10) ||  '           V03.ACC_GRD_COOK                 AS ACC_GRD_COOK,                               '
        || chr(13)||chr(10) ||  '           CASE WHEN TO_NUMBER(V03.ACC_CD) >= 10800 AND SUM(V03.ACC_GRD_STD) OVER(PARTITION BY V03.STOR_CD) > 0 '
        || chr(13)||chr(10) ||  '                THEN V03.ACC_GRD_COOK/SUM(V03.ACC_GRD_STD) OVER(PARTITION BY V03.STOR_CD)  '
        || chr(13)||chr(10) ||  '                ELSE NULL END *100          AS ACC_GRD_COOK_RATE,                          '
        || chr(13)||chr(10) ||  '           V03.ACC_GRD_TOT                  AS ACC_GRD_TOT,                                '
        || chr(13)||chr(10) ||  '           CASE WHEN TO_NUMBER(V03.ACC_CD) >= 10800 AND SUM(V03.ACC_GRD_STD) OVER(PARTITION BY V03.STOR_CD) > 0 '
        || chr(13)||chr(10) ||  '                THEN V03.ACC_GRD_TOT/SUM(V03.ACC_GRD_STD) OVER(PARTITION BY V03.STOR_CD)   '
        || chr(13)||chr(10) ||  '                ELSE NULL END *100          AS ACC_GRD_TOT_RATE                            '
        || chr(13)||chr(10) ||  '   FROM   (                                                                                '
        || chr(13)||chr(10) ||  '           SELECT  V02.STOR_CD                      AS STOR_CD,                            '
        || chr(13)||chr(10) ||  '                   V02.ACC_CD                       AS ACC_CD,                             '
        || chr(13)||chr(10) ||  '                   V02.ACC_NM                       AS ACC_NM,                             '
        || chr(13)||chr(10) ||  '                   V02.ACC_LVL                      AS ACC_LVL,                            '
        || chr(13)||chr(10) ||  '                   V02.R_NUM                        AS R_NUM,                              '
        || chr(13)||chr(10) ||  '                   SUM(V02.ACC_GRD_HALL)            AS ACC_GRD_HALL,                       '
        || chr(13)||chr(10) ||  '                   SUM(V02.ACC_GRD_COOK)            AS ACC_GRD_COOK,                       '
        || chr(13)||chr(10) ||  '                   SUM(V02.ACC_GRD_TOT )            AS ACC_GRD_TOT,                        '
        || chr(13)||chr(10) ||  '                   SUM(CASE WHEN V02.ACC_CD = ''10800''                                    '
        || chr(13)||chr(10) ||  '                            THEN V02.ACC_GRD_TOT                                           '
        || chr(13)||chr(10) ||  '                            ELSE 0 END)             AS ACC_GRD_STD                         '
        || chr(13)||chr(10) ||  '           FROM   (                                                                        '
        || chr(13)||chr(10) ||  '                   SELECT  V01.STOR_CD                      AS STOR_CD,                    '
        || chr(13)||chr(10) ||  '                           V01.ACC_CD                       AS ACC_CD,                     '
        || chr(13)||chr(10) ||  '                           V01.ACC_NM                       AS ACC_NM,                     '
        || chr(13)||chr(10) ||  '                           V01.ACC_LVL                      AS ACC_LVL,                    '
        || chr(13)||chr(10) ||  '                           V01.R_NUM                        AS R_NUM,                      '
        || chr(13)||chr(10) ||  '                           0                                AS ACC_GRD_HALL,               '
        || chr(13)||chr(10) ||  '                           0                                AS ACC_GRD_COOK,               '
        || chr(13)||chr(10) ||  '                           NVL(PGD.G_SUM, 0)                AS ACC_GRD_TOT                 '
        || chr(13)||chr(10) ||  '                   FROM   (                                                                '
        || chr(13)||chr(10) ||  '                           SELECT  PGD.COMP_CD,                                            '
        || chr(13)||chr(10) ||  '                                   PGD.STOR_CD,                                            '
        || chr(13)||chr(10) ||  '                                   PGD.ACC_CD,                                             '
        || chr(13)||chr(10) ||  '                                   PGD.GOAL_YM,                                            '
        || chr(13)||chr(10) ||  '                                   PGD.GOAL_DIV,                                           '
        || chr(13)||chr(10) ||  '                                   PGD.G_SUM                                               '
        || chr(13)||chr(10) ||  '                           FROM    PL_GOAL_DD    PGD,                                      '
        || chr(13)||chr(10) ||  '                                   S_STORE       STR                                       '
        || chr(13)||chr(10) ||  '                           WHERE   STR.COMP_CD   = PGD.COMP_CD                             '
        || chr(13)||chr(10) ||  '                           AND     STR.BRAND_CD  = PGD.BRAND_CD                            '
        || chr(13)||chr(10) ||  '                           AND     STR.STOR_CD   = PGD.STOR_CD                             '
        || chr(13)||chr(10) ||  '                           AND     STR.COMP_CD   = ''' || PSV_COMP_CD || ''''
        || chr(13)||chr(10) ||  '                           AND     ' ||  ls_sql_date
        || chr(13)||chr(10) ||  '                           AND     PGD.GOAL_DIV  = ''3'''
        || chr(13)||chr(10) ||  '                          ) PGD,                                                           '
        || chr(13)||chr(10) ||  '                          (                                                                '
        || chr(13)||chr(10) ||  '                           SELECT  STO.COMP_CD,                                            '
        || chr(13)||chr(10) ||  '                                   STO.STOR_CD,                                            '
        || chr(13)||chr(10) ||  '                                   STO.STOR_NM,                                            '
        || chr(13)||chr(10) ||  '                                   PAM.ACC_CD,                                             '
        || chr(13)||chr(10) ||  '                                   PAM.ACC_NM,                                             '
        || chr(13)||chr(10) ||  '                                   PAM.ACC_LVL,                                            '
        || chr(13)||chr(10) ||  '                                   PAM.R_NUM                                               '
        || chr(13)||chr(10) ||  '                           FROM   (                                                        '
        || chr(13)||chr(10) ||  '                                   SELECT  COMP_CD,                                        '
        || chr(13)||chr(10) ||  '                                           STOR_CD,                                        '
        || chr(13)||chr(10) ||  '                                           STOR_NM                                         '
        || chr(13)||chr(10) ||  '                                   FROM    S_STORE                                         '
        || chr(13)||chr(10) ||  '                                   WHERE   EXISTS (                                        '
        || chr(13)||chr(10) ||  '                                                   SELECT  1                               '
        || chr(13)||chr(10) ||  '                                                   FROM    PL_GOAL_YM PGY                  '
        || chr(13)||chr(10) ||  '                                                   WHERE   PGY.COMP_CD  = S_STORE.COMP_CD  '
        || chr(13)||chr(10) ||  '                                                   AND     PGY.STOR_CD  = S_STORE.STOR_CD  '
        || chr(13)||chr(10) ||  '                                                   AND     ' ||  ls_sql_date
        || chr(13)||chr(10) ||  '                                                   AND     PGY.GOAL_DIV = ''3'''
        || chr(13)||chr(10) ||  '                                                  )                                        '
        || chr(13)||chr(10) ||  '                                  ) STO,                                                   '
        || chr(13)||chr(10) ||  '                                  (                                                        '
        || chr(13)||chr(10) ||  '                                   SELECT  /*+ INDEX(PAM PK_PL_ACC_MST) */                 '
        || chr(13)||chr(10) ||  '                                           PAM.COMP_CD,                                    '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_CD,                                     '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_NM,                                     '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_LVL,                                    '
        || chr(13)||chr(10) ||  '                                           PAM.REF_ACC_CD,                                 '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_DIV,                                    '
        || chr(13)||chr(10) ||  '                                           PAM.TERM_DIV,                                   '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_SEQ,                                    '
        || chr(13)||chr(10) ||  '                                           ROWNUM R_NUM                                    '
        || chr(13)||chr(10) ||  '                                   FROM    PL_ACC_MST PAM                                  '
        || chr(13)||chr(10) ||  '                                   WHERE   PAM.COMP_CD = ''' || PSV_COMP_CD || ''''
        || chr(13)||chr(10) ||  '                                   AND     PAM.USE_YN  = ''Y'''
        || chr(13)||chr(10) ||  '                                   AND     PAM.ACC_CD <= ''30000'''
        || chr(13)||chr(10) ||  '                                   START WITH PAM.REF_ACC_CD = 0                           '
        || chr(13)||chr(10) ||  '                                   CONNECT BY PRIOR PAM.ACC_CD  = PAM.REF_ACC_CD           '
        || chr(13)||chr(10) ||  '                                          AND PRIOR PAM.COMP_CD = PAM.COMP_CD              '
        || chr(13)||chr(10) ||  '                                   ORDER SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ               '
        || chr(13)||chr(10) ||  '                                  ) PAM                                                    '
        || chr(13)||chr(10) ||  '                           WHERE   PAM.COMP_CD = STO.COMP_CD                               '
        || chr(13)||chr(10) ||  '                          ) V01                                                            '
        || chr(13)||chr(10) ||  '                   WHERE   V01.COMP_CD     = PGD.COMP_CD (+)                               '
        || chr(13)||chr(10) ||  '                   AND     V01.STOR_CD     = PGD.STOR_CD (+)                               '
        || chr(13)||chr(10) ||  '                   AND     V01.ACC_CD      = PGD.ACC_CD  (+)                               '
        || chr(13)||chr(10) ||  '                   UNION ALL                                                               '          
        || chr(13)||chr(10) ||  '                   SELECT  V01.STOR_CD,                                                    '
        || chr(13)||chr(10) ||  '                           V01.ACC_CD,                                                     '
        || chr(13)||chr(10) ||  '                           V01.ACC_NM,                                                     '
        || chr(13)||chr(10) ||  '                           V01.ACC_LVL,                                                    '
        || chr(13)||chr(10) ||  '                           V01.R_NUM,                                                      '
        || chr(13)||chr(10) ||  '                           DECODE(COST_DIV, 1, NVL(PGY.GOAL_AMT ,0), 0) AS ACC_GRD_HALL,   '
        || chr(13)||chr(10) ||  '                           DECODE(COST_DIV, 2, NVL(PGY.GOAL_AMT ,0), 0) AS ACC_GRD_COOK,   '
        || chr(13)||chr(10) ||  '                           DECODE(COST_DIV, 3, NVL(PGY.GOAL_AMT ,0), 0) AS ACC_GRD_TOT     '
        || chr(13)||chr(10) ||  '                   FROM   (                                                                '
        || chr(13)||chr(10) ||  '                           SELECT  PGY.COMP_CD,                                            '
        || chr(13)||chr(10) ||  '                                   PGY.STOR_CD,                                            '
        || chr(13)||chr(10) ||  '                                   PGY.ACC_CD,                                             '
        || chr(13)||chr(10) ||  '                                   PGY.GOAL_YM,                                            '
        || chr(13)||chr(10) ||  '                                   PGY.GOAL_DIV,                                           '
        || chr(13)||chr(10) ||  '                                   PGY.COST_DIV,                                           '
        || chr(13)||chr(10) ||  '                                   PGY.GOAL_AMT                                            '
        || chr(13)||chr(10) ||  '                           FROM    PL_GOAL_YM    PGY,                                      '
        || chr(13)||chr(10) ||  '                                   S_STORE       STR                                       '
        || chr(13)||chr(10) ||  '                           WHERE   STR.COMP_CD   = PGY.COMP_CD                             '
        || chr(13)||chr(10) ||  '                           AND     STR.BRAND_CD  = PGY.BRAND_CD                            '
        || chr(13)||chr(10) ||  '                           AND     STR.STOR_CD   = PGY.STOR_CD                             '
        || chr(13)||chr(10) ||  '                           AND     STR.COMP_CD   = ''' || PSV_COMP_CD || ''''
        || chr(13)||chr(10) ||  '                           AND     ' ||  ls_sql_date
        || chr(13)||chr(10) ||  '                           AND     PGY.GOAL_DIV  = ''3'''
        || chr(13)||chr(10) ||  '                          ) PGY,                                                           '
        || chr(13)||chr(10) ||  '                          (                                                                '
        || chr(13)||chr(10) ||  '                           SELECT  STO.COMP_CD,                                            '
        || chr(13)||chr(10) ||  '                                   STO.STOR_CD,                                            '
        || chr(13)||chr(10) ||  '                                   STO.STOR_NM,                                            '
        || chr(13)||chr(10) ||  '                                   PAM.ACC_CD,                                             '
        || chr(13)||chr(10) ||  '                                   PAM.ACC_NM,                                             '
        || chr(13)||chr(10) ||  '                                   PAM.ACC_LVL,                                            '
        || chr(13)||chr(10) ||  '                                   PAM.R_NUM                                               '
        || chr(13)||chr(10) ||  '                           FROM   (                                                        '
        || chr(13)||chr(10) ||  '                                   SELECT  COMP_CD,                                        '
        || chr(13)||chr(10) ||  '                                           STOR_CD,                                        '
        || chr(13)||chr(10) ||  '                                           STOR_NM                                         '
        || chr(13)||chr(10) ||  '                                   FROM    S_STORE                                         '
        || chr(13)||chr(10) ||  '                                   WHERE   EXISTS (                                        '
        || chr(13)||chr(10) ||  '                                                    SELECT  1                              '
        || chr(13)||chr(10) ||  '                                                    FROM    PL_GOAL_YM PGY                 '
        || chr(13)||chr(10) ||  '                                                    WHERE   PGY.COMP_CD  = S_STORE.COMP_CD '
        || chr(13)||chr(10) ||  '                                                    AND     PGY.STOR_CD  = S_STORE.STOR_CD '
        || chr(13)||chr(10) ||  '                                                    AND     ' ||  ls_sql_date
        || chr(13)||chr(10) ||  '                                                    AND     PGY.GOAL_DIV = ''3'''
        || chr(13)||chr(10) ||  '                                                   )                                       '
        || chr(13)||chr(10) ||  '                                  ) STO,                                                   '
        || chr(13)||chr(10) ||  '                                  (                                                        '
        || chr(13)||chr(10) ||  '                                   SELECT  /*+ INDEX(PAM PK_PL_ACC_MST) */                 '
        || chr(13)||chr(10) ||  '                                           PAM.COMP_CD,                                    '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_CD,                                     '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_NM,                                     '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_LVL,                                    '
        || chr(13)||chr(10) ||  '                                           PAM.REF_ACC_CD,                                 '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_DIV,                                    '
        || chr(13)||chr(10) ||  '                                           PAM.TERM_DIV,                                   '
        || chr(13)||chr(10) ||  '                                           PAM.ACC_SEQ,                                    '
        || chr(13)||chr(10) ||  '                                           ROWNUM R_NUM                                    '
        || chr(13)||chr(10) ||  '                                   FROM    PL_ACC_MST PAM                                  '
        || chr(13)||chr(10) ||  '                                   WHERE   PAM.COMP_CD = ''' || PSV_COMP_CD || ''''
        || chr(13)||chr(10) ||  '                                   AND     PAM.USE_YN  = ''Y'''
        || chr(13)||chr(10) ||  '                                   AND     PAM.ACC_CD <= ''30000'''
        || chr(13)||chr(10) ||  '                                   START WITH PAM.REF_ACC_CD = 0                           '
        || chr(13)||chr(10) ||  '                                   CONNECT BY PRIOR PAM.ACC_CD  = PAM.REF_ACC_CD           '
        || chr(13)||chr(10) ||  '                                          AND PRIOR PAM.COMP_CD = PAM.COMP_CD              '
        || chr(13)||chr(10) ||  '                                   ORDER SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ               '
        || chr(13)||chr(10) ||  '                                  ) PAM                                                    '
        || chr(13)||chr(10) ||  '                           WHERE   PAM.COMP_CD = STO.COMP_CD                               '
        || chr(13)||chr(10) ||  '                          ) V01                                                            '
        || chr(13)||chr(10) ||  '                   WHERE   V01.COMP_CD     = PGY.COMP_CD (+)                               '
        || chr(13)||chr(10) ||  '                   AND     V01.STOR_CD     = PGY.STOR_CD (+)                               '
        || chr(13)||chr(10) ||  '                   AND     V01.ACC_CD      = PGY.ACC_CD  (+)                               '
        || chr(13)||chr(10) ||  '                  ) V02                                                                    '
        || chr(13)||chr(10) ||  '           GROUP BY                                                                        '
        || chr(13)||chr(10) ||  '                   V02.STOR_CD,                                                            '
        || chr(13)||chr(10) ||  '                   V02.ACC_CD,                                                             '
        || chr(13)||chr(10) ||  '                   V02.ACC_NM,                                                             '
        || chr(13)||chr(10) ||  '                   V02.ACC_LVL,                                                            '
        || chr(13)||chr(10) ||  '                   V02.R_NUM                                                               '
        || chr(13)||chr(10) ||  '          ) V03                                                                            '
        ;

 --   dbms_output.put_line(ls_sql_main) ;
    V_CNT := qry_hd.LAST;

    ls_sql := ls_sql_with || ls_sql_main;  
    --dbms_output.put_line(ls_sql) ;

    /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
    V_SQL :=   ' SELECT * '
            || ' FROM (   '
            || ls_sql
            || ' ) S_GOAL '
            || ' PIVOT    '
            || ' (        '
            || '    SUM(ACC_GRD_TOT)        VCOL1,  '
            || '    AVG(ACC_GRD_TOT_RATE)   VCOL2,  '
            || '    SUM(ACC_GRD_HALL)       VCOL3,  '
            || '    MAX(ACC_GRD_HALL_RATE)  VCOL4,  '
            || '    SUM(ACC_GRD_COOK)       VCOL5,  '
            || '    AVG(ACC_GRD_COOK_RATE)  VCOL6   '
            || '    FOR (STOR_CD ) IN (         '
            ||      V_CROSSTAB
            || ' ))                             '
            || ' ORDER BY R_NUM                 '
          ;

    dbms_output.put_line(V_SQL) ;
    OPEN PR_HEADER FOR
        V_HD;
    OPEN PR_RESULT FOR
        V_SQL;

    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;

EXCEPTION
    WHEN ERR_HANDLER THEN 
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
       dbms_output.put_line( PR_RTN_MSG ) ;       
    WHEN OTHERS THEN
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
        dbms_output.put_line( PR_RTN_MSG ) ;
END ;

/
