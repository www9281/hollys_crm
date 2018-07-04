--------------------------------------------------------
--  DDL for Procedure SP_ATTD4100L2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ATTD4100L2" 
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PR_HEADER       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
  PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set,
  PR_RTN_CD       OUT VARCHAR2 ,   -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_ATTD4100L2            출퇴근 조정전/조정후
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2010-02-01         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_ATTD4100L1
      SYSDATE:         2014-04-24
      USERNAME:
      TABLE NAME:
******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
        ( SEQ    NUMBER(2)   );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;

    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_crosstab_main     VARCHAR2(10000) ;
    ls_sql_with     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(10000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD_WITH     VARCHAR2(10000);
    V_HD          VARCHAR2(30000);
    V_HD1         VARCHAR2(20000);
    V_HD2         VARCHAR2(20000);

    ls_err_cd     VARCHAR2(7)  := 0 ;
    ls_err_msg    VARCHAR2(500) ;

    ERR_HANDLER   EXCEPTION;
BEGIN

    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER ,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2,     ls_ex_date2 );


    ls_sql_with := ' WITH  '
           ||  ls_sql_store -- S_STORE
--           ||  ', '
--           ||  ls_sql_item  -- S_ITEM
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
    ls_sql_date := ' A.ATTD_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND A.ATTD_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    /* 가로축 데이타 FETCH */
   ls_sql_crosstab_main :=
     chr(13)||chr(10)|| 'SELECT  DISTINCT ROW_NUMBER() OVER ( PARTITION BY A.BRAND_CD, A.STOR_CD , A.USER_ID, A.ATTD_DT  ORDER BY WORK_START_DTM ) SEQ '
   ||chr(13)||chr(10)|| '  FROM  ATTENDANCE  A  '
   ||chr(13)||chr(10)|| '     ,  STORE_USER  U  '
   ||chr(13)||chr(10)|| '     ,  S_STORE     S  '
   ||chr(13)||chr(10)|| ' WHERE  A.COMP_CD  = U.COMP_CD '
   ||chr(13)||chr(10)|| '   AND  A.BRAND_CD = U.BRAND_CD '
   ||chr(13)||chr(10)|| '   AND  A.STOR_CD  = U.STOR_CD '
   ||chr(13)||chr(10)|| '   AND  A.USER_ID  = U.USER_ID '
   ||chr(13)||chr(10)|| '   AND  A.COMP_CD  = S.COMP_CD '
   ||chr(13)||chr(10)|| '   AND  A.BRAND_CD = S.BRAND_CD '
   ||chr(13)||chr(10)|| '   AND  A.STOR_CD  = S.STOR_CD '
   ||chr(13)||chr(10)|| '   AND  A.COMP_CD  = ''' ||PSV_COMP_CD || ''''
   ||chr(13)||chr(10)|| '   AND  ' ||  ls_sql_date
   ||chr(13)||chr(10)|| ' ORDER  BY 1 ';

     ls_sql := ls_sql_with || ls_sql_crosstab_main ;
--     dbms_output.put_line(ls_sql) ;
     EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

     IF qry_hd.count = 0 THEN
        ls_err_cd  := '4000100' ;
        ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
        RAISE ERR_HANDLER ;
     END IF;

    V_HD_WITH  :=
      chr(13)||chr(10)|| q'[WITH S_HD AS                                                                ]'
    ||chr(13)||chr(10)|| q'[(                                                                           ]'   
    ||chr(13)||chr(10)|| q'[    SELECT  MAX(CASE CODE_CD WHEN '01' THEN CODE_NM ELSE NULL END ) CH01    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '02' THEN CODE_NM ELSE NULL END ) CH02    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '03' THEN CODE_NM ELSE NULL END ) CH03    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '04' THEN CODE_NM ELSE NULL END ) CH04    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '05' THEN CODE_NM ELSE NULL END ) CH05    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '06' THEN CODE_NM ELSE NULL END ) CH06    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '07' THEN CODE_NM ELSE NULL END ) CH07    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '08' THEN CODE_NM ELSE NULL END ) CH08    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '09' THEN CODE_NM ELSE NULL END ) CH09    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '10' THEN CODE_NM ELSE NULL END ) CH10    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '11' THEN CODE_NM ELSE NULL END ) CH11    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '12' THEN CODE_NM ELSE NULL END ) CH12    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '13' THEN CODE_NM ELSE NULL END ) CH13    ]'
    ||chr(13)||chr(10)|| q'[         ,  'REGULAR_MM'                                            CH14    ]'
    ||chr(13)||chr(10)|| q'[         ,  'OVER_MM'                                               CH15    ]'
    ||chr(13)||chr(10)|| q'[         ,  'CONFIRM_MM'                                            CH16    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '17' THEN CODE_NM ELSE NULL END ) CH17    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '18' THEN CODE_NM ELSE NULL END ) CH18    ]'
    ||chr(13)||chr(10)|| q'[         ,  MAX(CASE CODE_CD WHEN '19' THEN CODE_NM ELSE NULL END ) CH19    ]'
    ||chr(13)||chr(10)|| q'[         ,  'REST_MM'                                               CH28    ]'
    ||chr(13)||chr(10)|| q'[      FROM  (                                                               ]'
    ||chr(13)||chr(10)|| q'[                SELECT  C1.CODE_CD                                          ]'
    ||chr(13)||chr(10)|| q'[                     ,  CASE WHEN C2.CODE_NM IS NULL THEN C1.CODE_NM ELSE C2.CODE_NM END CODE_NM  ]'
    ||chr(13)||chr(10)|| q'[                  FROM  COMMON C1,LANG_COMMON C2                            ]'
    ||chr(13)||chr(10)|| q'[                 WHERE  C1.CODE_TP = '01396'                                ]'
    ||chr(13)||chr(10)|| q'[                   AND  C1.COMP_CD = :PSV_COMP_CD                           ]'
    ||chr(13)||chr(10)|| q'[                   AND  C2.COMP_CD (+) = C1.COMP_CD                         ]'
    ||chr(13)||chr(10)|| q'[                   AND  C2.CODE_TP (+) = C1.CODE_TP                         ]'
    ||chr(13)||chr(10)|| q'[                   AND  C2.CODE_CD (+) = C1.CODE_CD                         ]'
    ||chr(13)||chr(10)|| q'[                   AND  C2.LANGUAGE_TP (+) = :PSV_LANG_CD                   ]'
    ||chr(13)||chr(10)|| q'[            ) A                                                             ]'
    ||chr(13)||chr(10)|| q'[)                                                                           ]' ;

    V_HD1 := 'SELECT  CH03, CH04, CH05, CH06, CH07, CH08, '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'DIV')||''', ''ADJ_DIV'', CH09, CH14, CH18, CH19, CH10, CH15, CH17, CH28, CH13, CH16, '  ;
    V_HD2 := V_HD1 ;

    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ' , ';
               V_HD1 := V_HD1 || ' , ' ;
               V_HD2 := V_HD2 || ' , ' ;
             END IF;
            V_CROSSTAB := V_CROSSTAB || '''' || TO_CHAR(i)  || ''''  ;
            V_HD1 := V_HD1 || ''''   || TO_CHAR(i)  || ''' CT' || TO_CHAR(i*2 - 1) || ',' ;
            V_HD1 := V_HD1 || ''''   || TO_CHAR(i)  || ''' CT' || TO_CHAR(i*2 )  ;
            V_HD2 := V_HD2 || ' CH11  CT' || TO_CHAR(i*2 - 1 ) || ',' ;
            V_HD2 := V_HD2 || ' CH12  CT' || TO_CHAR(i*2)   ;
        END;
    END LOOP;

    V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
    V_HD2 :=  V_HD2 || ' FROM S_HD ' ;

    V_HD   :=  V_HD_WITH ||   V_HD1 || ' UNION ALL ' || V_HD2 ;

    dbms_output.put_line(V_HD) ;
    dbms_output.put_line('===================================') ;

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    --ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00770') ;
    -------------------------------------------------------------------------------

    ls_sql_main :=
      chr(13)||chr(10)|| 'SELECT STOR_CD '
    ||chr(13)||chr(10)|| '     , STOR_NM '
    ||chr(13)||chr(10)|| '     , USER_ID '
    ||chr(13)||chr(10)|| '     , USER_NM '
    ||chr(13)||chr(10)|| '     , ROLE_NM '
    ||chr(13)||chr(10)|| '     , ATTD_DT '
    ||chr(13)||chr(10)|| '     , ADJ_NM '
    ||chr(13)||chr(10)|| '     , ''1'' AS ADJ_DIV '
    ||chr(13)||chr(10)|| '     , R_NUM AS SEQ'
    ||chr(13)||chr(10)|| '     , FN_GET_FROMAT_HHMM((DAY_OF_SECOND - MID_OF_SECOND) / 60) AS REGULAR_HM '
    ||chr(13)||chr(10)|| '     , SUM(CASE WHEN R_NUM = 1 THEN (DAY_OF_SECOND - MID_OF_SECOND) / 60 '
    ||chr(13)||chr(10)|| '                ELSE 0 END) OVER (PARTITION BY  STOR_CD, USER_ID) AS REGULAR_MM '
    ||chr(13)||chr(10)|| '     , FN_GET_FROMAT_HHMM(MID_OF_SECOND / 60) AS MIDNIGHT_HM '
    ||chr(13)||chr(10)|| '     , SUM(CASE WHEN R_NUM = 1 THEN MID_OF_SECOND / 60 '
    ||chr(13)||chr(10)|| '                ELSE 0 END) OVER (PARTITION BY  STOR_CD, USER_ID) AS MIDNIGHT_MM '
    ||chr(13)||chr(10)|| '     , CASE WHEN DAY_OF_SECOND > (8 * 60 * 60) THEN FN_GET_FROMAT_HHMM((DAY_OF_SECOND - (8 * 60 * 60)) / 60) '
    ||chr(13)||chr(10)|| '            ELSE ''00:00'' END AS OVER_HM '
    ||chr(13)||chr(10)|| '     , SUM(CASE WHEN R_NUM = 1 AND DAY_OF_SECOND > (8 * 60 * 60) THEN (DAY_OF_SECOND - (8 * 60 * 60)) / 60 '
    ||chr(13)||chr(10)|| '                ELSE 0 END) OVER(PARTITION BY  STOR_CD, USER_ID)  AS OVER_MM '
    ||chr(13)||chr(10)|| '     , FN_GET_FROMAT_HHMM(SUM(CASE WHEN REST_C_DTM IS NULL THEN 0 ' 
    ||chr(13)||chr(10)|| '                                   ELSE TO_DATE(REST_C_DTM, ''YYYYMMDDHH24MI'') - TO_DATE(REST_S_DTM, ''YYYYMMDDHH24MI'') END * 24 * 60 * 60) '
    ||chr(13)||chr(10)|| '                              OVER(PARTITION BY STOR_CD, USER_ID, ATTD_DT) / 60) AS REST_HM '
    ||chr(13)||chr(10)|| '     , SUM((CASE WHEN REST_C_DTM IS NULL THEN 0 ' 
    ||chr(13)||chr(10)|| '                 ELSE TO_DATE(REST_C_DTM, ''YYYYMMDDHH24MI'') - TO_DATE(REST_S_DTM, ''YYYYMMDDHH24MI'') END * 24 * 60 * 60) / 60) OVER(PARTITION BY  STOR_CD, USER_ID)  AS REST_MM '
    ||chr(13)||chr(10)|| '     , FN_GET_FROMAT_HHMM(DAY_OF_SECOND/60)                AS TOT_WORK_HM '
    ||chr(13)||chr(10)|| '     , SUM(CASE WHEN R_NUM = 1 THEN DAY_OF_SECOND / 60 '
    ||chr(13)||chr(10)|| '                ELSE 0 END) OVER(PARTITION BY  STOR_CD, USER_ID)  AS TOT_WORK_MM '
    ||chr(13)||chr(10)|| '     , MOD_S_HM '
    ||chr(13)||chr(10)|| '     , MOD_C_HM '
    ||chr(13)||chr(10)|| '  FROM (           '
    ||chr(13)||chr(10)|| '       SELECT V02.STOR_CD '
    ||chr(13)||chr(10)|| '            , V02.STOR_NM '
    ||chr(13)||chr(10)|| '            , V02.USER_ID '
    ||chr(13)||chr(10)|| '            , V02.USER_NM '
    ||chr(13)||chr(10)|| '            , V02.ROLE_NM '
    ||chr(13)||chr(10)|| '            , SUBSTR(V02.ATTD_DT,1,4) || ''-'' || SUBSTR(V02.ATTD_DT,5,2) || ''-'' || SUBSTR(V02.ATTD_DT,7,2) ATTD_DT '
    ||chr(13)||chr(10)|| '            , V02.ADJ_NM '
    ||chr(13)||chr(10)|| '            , V02.WORK_START_DT '
    ||chr(13)||chr(10)|| '            , V02.WORK_CLOSE_DT '
    ||chr(13)||chr(10)|| '            , SUM((TO_DATE(V02.MOD_C_DT||V02.MOD_C_HM, ''YYYYMMDDHH24MI'') - '
    ||chr(13)||chr(10)|| '                   TO_DATE(V02.MOD_S_DT||V02.MOD_S_HM, ''YYYYMMDDHH24MI'')) * 24 * 60 * 60) '
    ||chr(13)||chr(10)|| '                  OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT) AS DAY_OF_SECOND '
    ||chr(13)||chr(10)|| '            , V02.MOD_S_DT||V02.MOD_S_HM AS MOD_S_DTM '
    ||chr(13)||chr(10)|| '            , V02.MOD_C_DT||V02.MOD_C_HM AS MOD_C_DTM '
    ||chr(13)||chr(10)|| '            , V02.MOD_C_DT||V02.MOD_C_HM AS REST_S_DTM '
    ||chr(13)||chr(10)|| '            , LEAD(V02.MOD_S_DT||V02.MOD_S_HM, 1) OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT ORDER BY V02.MOD_S_DT||V02.MOD_S_HM) AS REST_C_DTM '
    ||chr(13)||chr(10)|| '            , TO_CHAR(TO_DATE(V02.MOD_S_HM, ''HH24MI''), ''HH24:MI'') AS MOD_S_HM '
    ||chr(13)||chr(10)|| '            , TO_CHAR(TO_DATE(V02.MOD_C_HM, ''HH24MI''), ''HH24:MI'') AS MOD_C_HM '
    ||chr(13)||chr(10)|| '            , SUM(FN_GET_MIDNIGHT_WT(V02.MOD_S_DT||V02.MOD_S_HM, V02.MOD_C_DT||V02.MOD_C_HM)) '
    ||chr(13)||chr(10)|| '                  OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT) AS MID_OF_SECOND '
    ||chr(13)||chr(10)|| '            , V02.R_NUM '
    ||chr(13)||chr(10)|| '         FROM ( '
    ||chr(13)||chr(10)|| '              SELECT V01.STOR_CD '
    ||chr(13)||chr(10)|| '                   , V01.STOR_NM '
    ||chr(13)||chr(10)|| '                   , V01.USER_ID '
    ||chr(13)||chr(10)|| '                   , V01.USER_NM '
    ||chr(13)||chr(10)|| '                   , V01.ROLE_NM '
    ||chr(13)||chr(10)|| '                   , V01.ADJ_NM '
    ||chr(13)||chr(10)|| '                   , V01.ATTD_DT '
    ||chr(13)||chr(10)|| '                   , V01.WORK_START_DT '
    ||chr(13)||chr(10)|| '                   , V01.WORK_CLOSE_DT '
    ||chr(13)||chr(10)|| '                   , TO_CHAR(TO_DATE(V01.WORK_START_DT, ''YYYYMMDDHH24MI''), ''YYYYMMDD'') MOD_S_DT '
    ||chr(13)||chr(10)|| '                   , TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, ''YYYYMMDDHH24MI''), ''YYYYMMDD'') MOD_C_DT '
    ||chr(13)||chr(10)|| '                   , TO_CHAR(TO_DATE(V01.WORK_START_DT, ''YYYYMMDDHH24MI''), ''HH24MI'')   MOD_S_HM '
    ||chr(13)||chr(10)|| '                   , TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, ''YYYYMMDDHH24MI''), ''HH24MI'')   MOD_C_HM '
    ||chr(13)||chr(10)|| '                   , ROW_NUMBER() OVER(PARTITION BY V01.STOR_CD, V01.USER_ID, V01.ATTD_DT ORDER BY V01.WORK_START_DT) R_NUM '
    ||chr(13)||chr(10)|| '                FROM ( '
    ||chr(13)||chr(10)|| '                     SELECT S.BRAND_CD '
    ||chr(13)||chr(10)|| '                          , S.BRAND_NM '
    ||chr(13)||chr(10)|| '                          , S.STOR_CD '
    ||chr(13)||chr(10)|| '                          , S.STOR_NM '
    ||chr(13)||chr(10)|| '                          , A.ATTD_DT '
    ||chr(13)||chr(10)|| '                          , A.USER_ID '
    ||chr(13)||chr(10)|| '                          , U.USER_NM '
    ||chr(13)||chr(10)|| '                          , C1.CODE_NM AS ROLE_NM'
    ||chr(13)||chr(10)|| '                          , C2.CODE_NM AS ADJ_NM'
    ||chr(13)||chr(10)|| '                          , NVL(CONFIRM_START_DTM, WORK_START_DTM)     AS WORK_START_DT '
    ||chr(13)||chr(10)|| '                          , CASE WHEN NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) < NVL(CONFIRM_START_DTM, WORK_START_DTM) THEN NVL(CONFIRM_START_DTM, WORK_START_DTM) ELSE NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) END AS WORK_CLOSE_DT '
    ||chr(13)||chr(10)|| '                       FROM ATTENDANCE  A '
    ||chr(13)||chr(10)|| '                          , STORE_USER  U '
    ||chr(13)||chr(10)|| '                          , S_STORE S '
    ||chr(13)||chr(10)|| '                          , ( '
    ||chr(13)||chr(10)|| '                            SELECT C.COMP_CD '
    ||chr(13)||chr(10)|| '                                 , C.CODE_CD '
    ||chr(13)||chr(10)|| '                                 , NVL(L.CODE_NM, C.CODE_NM) AS CODE_NM '
    ||chr(13)||chr(10)|| '                              FROM COMMON C '
    ||chr(13)||chr(10)|| '                                 , ( '
    ||chr(13)||chr(10)|| '                                     SELECT COMP_CD '
    ||chr(13)||chr(10)|| '                                          , CODE_CD '
    ||chr(13)||chr(10)|| '                                          , CODE_NM '
    ||chr(13)||chr(10)|| '                                       FROM LANG_COMMON '
    ||chr(13)||chr(10)|| '                                      WHERE COMP_CD = :PSV_COMP_CD '
    ||chr(13)||chr(10)|| '                                        AND CODE_TP = ''00770'''
    ||chr(13)||chr(10)|| '                                        AND LANGUAGE_TP = :PSV_LANG_CD '
    ||chr(13)||chr(10)|| '                                        AND USE_YN = ''Y'''
    ||chr(13)||chr(10)|| '                                   ) L '
    ||chr(13)||chr(10)|| '                             WHERE C.COMP_CD = L.COMP_CD(+) '
    ||chr(13)||chr(10)|| '                               AND C.CODE_CD = L.CODE_CD(+) '
    ||chr(13)||chr(10)|| '                               AND C.COMP_CD = :PSV_COMP_CD '
    ||chr(13)||chr(10)|| '                               AND C.CODE_TP = ''00770'''
    ||chr(13)||chr(10)|| '                               AND C.USE_YN = ''Y'''
    ||chr(13)||chr(10)|| '                            ) C1 '
    ||chr(13)||chr(10)|| '                          , ( '
    ||chr(13)||chr(10)|| '                            SELECT C.COMP_CD '
    ||chr(13)||chr(10)|| '                                 , C.CODE_CD '
    ||chr(13)||chr(10)|| '                                 , NVL(L.CODE_NM, C.CODE_NM) AS CODE_NM '
    ||chr(13)||chr(10)|| '                              FROM COMMON C '
    ||chr(13)||chr(10)|| '                                 , ( '
    ||chr(13)||chr(10)|| '                                     SELECT COMP_CD '
    ||chr(13)||chr(10)|| '                                          , CODE_CD '
    ||chr(13)||chr(10)|| '                                          , CODE_NM '
    ||chr(13)||chr(10)|| '                                       FROM LANG_COMMON '
    ||chr(13)||chr(10)|| '                                      WHERE COMP_CD = :PSV_COMP_CD '
    ||chr(13)||chr(10)|| '                                        AND CODE_TP = ''01590'''
    ||chr(13)||chr(10)|| '                                        AND LANGUAGE_TP = :PSV_LANG_CD '
    ||chr(13)||chr(10)|| '                                        AND USE_YN = ''Y'''
    ||chr(13)||chr(10)|| '                                   ) L '
    ||chr(13)||chr(10)|| '                             WHERE C.COMP_CD = L.COMP_CD(+) '
    ||chr(13)||chr(10)|| '                               AND C.CODE_CD = L.CODE_CD(+) '
    ||chr(13)||chr(10)|| '                               AND C.COMP_CD = :PSV_COMP_CD '
    ||chr(13)||chr(10)|| '                               AND C.CODE_TP = ''01590'''
    ||chr(13)||chr(10)|| '                               AND C.CODE_CD = ''1'''
    ||chr(13)||chr(10)|| '                               AND C.USE_YN = ''Y'''
    ||chr(13)||chr(10)|| '                            ) C2 '
    ||chr(13)||chr(10)|| '                      WHERE A.COMP_CD  = U.COMP_CD '
    ||chr(13)||chr(10)|| '                        AND A.BRAND_CD = U.BRAND_CD '
    ||chr(13)||chr(10)|| '                        AND A.STOR_CD  = U.STOR_CD '
    ||chr(13)||chr(10)|| '                        AND A.USER_ID  = U.USER_ID '
    ||chr(13)||chr(10)|| '                        AND A.COMP_CD  = S.COMP_CD '
    ||chr(13)||chr(10)|| '                        AND A.BRAND_CD = S.BRAND_CD '
    ||chr(13)||chr(10)|| '                        AND A.STOR_CD  = S.STOR_CD '
    ||chr(13)||chr(10)|| '                        AND U.ROLE_DIV = C1.CODE_CD (+) '
    ||chr(13)||chr(10)|| '                        AND A.COMP_CD  = :PSV_COMP_CD  '
    ||chr(13)||chr(10)|| '                        AND ' ||  ls_sql_date
    ||chr(13)||chr(10)|| '                     ) V01 '
    ||chr(13)||chr(10)|| '               WHERE V01.WORK_START_DT != V01.WORK_CLOSE_DT'
    ||chr(13)||chr(10)|| '              ) V02 '
    ||chr(13)||chr(10)|| '       ) V03 '
    ||chr(13)||chr(10)|| ' WHERE DAY_OF_SECOND >= 0'
    ||chr(13)||chr(10)|| ' UNION ALL '
    ||chr(13)||chr(10)|| 'SELECT STOR_CD '
    ||chr(13)||chr(10)|| '     , STOR_NM '
    ||chr(13)||chr(10)|| '     , USER_ID '
    ||chr(13)||chr(10)|| '     , USER_NM '
    ||chr(13)||chr(10)|| '     , ROLE_NM '
    ||chr(13)||chr(10)|| '     , ATTD_DT '
    ||chr(13)||chr(10)|| '     , ADJ_NM '
    ||chr(13)||chr(10)|| '     , ''2'' AS ADJ_DIV '
    ||chr(13)||chr(10)|| '     , R_NUM AS SEQ'
    ||chr(13)||chr(10)|| '     , FN_GET_FROMAT_HHMM((DAY_OF_SECOND - MID_OF_SECOND) / 60) AS REGULAR_HM '
    ||chr(13)||chr(10)|| '     , SUM(CASE WHEN R_NUM = 1 THEN (DAY_OF_SECOND - MID_OF_SECOND) / 60 '
    ||chr(13)||chr(10)|| '                ELSE 0 END) OVER (PARTITION BY  STOR_CD, USER_ID) AS REGULAR_MM '
    ||chr(13)||chr(10)|| '     , FN_GET_FROMAT_HHMM(MID_OF_SECOND / 60) AS MIDNIGHT_HM '
    ||chr(13)||chr(10)|| '     , SUM(CASE WHEN R_NUM = 1 THEN MID_OF_SECOND / 60 '
    ||chr(13)||chr(10)|| '                ELSE 0 END) OVER (PARTITION BY  STOR_CD, USER_ID) AS MIDNIGHT_MM '
    ||chr(13)||chr(10)|| '     , CASE WHEN DAY_OF_SECOND > (8 * 60 * 60) THEN FN_GET_FROMAT_HHMM((DAY_OF_SECOND - (8 * 60 * 60)) / 60) '
    ||chr(13)||chr(10)|| '            ELSE ''00:00'' END AS OVER_HM '
    ||chr(13)||chr(10)|| '     , SUM(CASE WHEN R_NUM = 1 AND DAY_OF_SECOND > (8 * 60 * 60) THEN (DAY_OF_SECOND - (8 * 60 * 60)) / 60 '
    ||chr(13)||chr(10)|| '                ELSE 0 END) OVER(PARTITION BY  STOR_CD, USER_ID)  AS OVER_MM '
    ||chr(13)||chr(10)|| '     , FN_GET_FROMAT_HHMM(SUM(CASE WHEN REST_C_DTM IS NULL THEN 0 ' 
    ||chr(13)||chr(10)|| '                                   ELSE TO_DATE(REST_C_DTM, ''YYYYMMDDHH24MI'') - TO_DATE(REST_S_DTM, ''YYYYMMDDHH24MI'') END * 24 * 60 * 60) '
    ||chr(13)||chr(10)|| '                              OVER(PARTITION BY STOR_CD, USER_ID, ATTD_DT) / 60) AS REST_HM '
    ||chr(13)||chr(10)|| '     , SUM((CASE WHEN REST_C_DTM IS NULL THEN 0 ' 
    ||chr(13)||chr(10)|| '                 ELSE TO_DATE(REST_C_DTM, ''YYYYMMDDHH24MI'') - TO_DATE(REST_S_DTM, ''YYYYMMDDHH24MI'') END * 24 * 60 * 60) / 60) OVER(PARTITION BY  STOR_CD, USER_ID)  AS REST_MM '
    ||chr(13)||chr(10)|| '     , FN_GET_FROMAT_HHMM(DAY_OF_SECOND/60)                AS TOT_WORK_HM '
    ||chr(13)||chr(10)|| '     , SUM(CASE WHEN R_NUM = 1 THEN DAY_OF_SECOND / 60 '
    ||chr(13)||chr(10)|| '                ELSE 0 END) OVER(PARTITION BY  STOR_CD, USER_ID)  AS TOT_WORK_MM '
    ||chr(13)||chr(10)|| '     , MOD_S_HM '
    ||chr(13)||chr(10)|| '     , MOD_C_HM '
    ||chr(13)||chr(10)|| '  FROM (           '
    ||chr(13)||chr(10)|| '       SELECT V02.STOR_CD '
    ||chr(13)||chr(10)|| '            , V02.STOR_NM '
    ||chr(13)||chr(10)|| '            , V02.USER_ID '
    ||chr(13)||chr(10)|| '            , V02.USER_NM '
    ||chr(13)||chr(10)|| '            , V02.ROLE_NM '
    ||chr(13)||chr(10)|| '            , SUBSTR(V02.ATTD_DT,1,4) || ''-'' || SUBSTR(V02.ATTD_DT,5,2) || ''-'' || SUBSTR(V02.ATTD_DT,7,2) ATTD_DT '
    ||chr(13)||chr(10)|| '            , V02.ADJ_NM '
    ||chr(13)||chr(10)|| '            , V02.WORK_START_DT '
    ||chr(13)||chr(10)|| '            , V02.WORK_CLOSE_DT '
    ||chr(13)||chr(10)|| '            , SUM((TO_DATE(V02.MOD_C_DT||V02.MOD_C_HM, ''YYYYMMDDHH24MI'') - '
    ||chr(13)||chr(10)|| '                   TO_DATE(V02.MOD_S_DT||V02.MOD_S_HM, ''YYYYMMDDHH24MI'')) * 24 * 60 * 60) '
    ||chr(13)||chr(10)|| '                  OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT) AS DAY_OF_SECOND '
    ||chr(13)||chr(10)|| '            , V02.MOD_S_DT||V02.MOD_S_HM AS MOD_S_DTM '
    ||chr(13)||chr(10)|| '            , V02.MOD_C_DT||V02.MOD_C_HM AS MOD_C_DTM '
    ||chr(13)||chr(10)|| '            , V02.MOD_C_DT||V02.MOD_C_HM AS REST_S_DTM '
    ||chr(13)||chr(10)|| '            , LEAD(V02.MOD_S_DT||V02.MOD_S_HM, 1) OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT ORDER BY V02.MOD_S_DT||V02.MOD_S_HM) AS REST_C_DTM '
    ||chr(13)||chr(10)|| '            , TO_CHAR(TO_DATE(V02.MOD_S_HM, ''HH24MI''), ''HH24:MI'') AS MOD_S_HM '
    ||chr(13)||chr(10)|| '            , TO_CHAR(TO_DATE(V02.MOD_C_HM, ''HH24MI''), ''HH24:MI'') AS MOD_C_HM '
    ||chr(13)||chr(10)|| '            , SUM(FN_GET_MIDNIGHT_WT(V02.MOD_S_DT||V02.MOD_S_HM, V02.MOD_C_DT||V02.MOD_C_HM)) '
    ||chr(13)||chr(10)|| '                  OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT) AS MID_OF_SECOND '
    ||chr(13)||chr(10)|| '            , V02.R_NUM '
    ||chr(13)||chr(10)|| '         FROM ( '
    ||chr(13)||chr(10)|| '              SELECT V01.STOR_CD '
    ||chr(13)||chr(10)|| '                   , V01.STOR_NM '
    ||chr(13)||chr(10)|| '                   , V01.USER_ID '
    ||chr(13)||chr(10)|| '                   , V01.USER_NM '
    ||chr(13)||chr(10)|| '                   , V01.ROLE_NM '
    ||chr(13)||chr(10)|| '                   , V01.ADJ_NM '
    ||chr(13)||chr(10)|| '                   , V01.ATTD_DT '
    ||chr(13)||chr(10)|| '                   , V01.WORK_START_DT '
    ||chr(13)||chr(10)|| '                   , V01.WORK_CLOSE_DT '
    ||chr(13)||chr(10)|| '                   , TO_CHAR(TO_DATE(V01.WORK_START_DT, ''YYYYMMDDHH24MI'') + 900/(24 * 60 * 60), ''YYYYMMDD'') MOD_S_DT '
    ||chr(13)||chr(10)|| '                   , TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, ''YYYYMMDDHH24MI'') - 900/(24 * 60 * 60), ''YYYYMMDD'') MOD_C_DT '
    ||chr(13)||chr(10)|| '                   , REPLACE(FN_GET_FROMAT_HHMM(CEIL (TO_NUMBER(TO_CHAR(TO_DATE(V01.WORK_START_DT, ''YYYYMMDDHH24MI''), ''SSSSS'')) / 900) * 900 / 60), '':'', '''') MOD_S_HM '
    ||chr(13)||chr(10)|| '                   , REPLACE(FN_GET_FROMAT_HHMM(FLOOR(TO_NUMBER(TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, ''YYYYMMDDHH24MI''), ''SSSSS'')) / 900) * 900 / 60), '':'', '''') MOD_C_HM '
    ||chr(13)||chr(10)|| '                   , ROW_NUMBER() OVER(PARTITION BY V01.STOR_CD, V01.USER_ID, V01.ATTD_DT ORDER BY V01.WORK_START_DT) R_NUM '
    ||chr(13)||chr(10)|| '                FROM ( '
    ||chr(13)||chr(10)|| '                     SELECT S.BRAND_CD '
    ||chr(13)||chr(10)|| '                          , S.BRAND_NM '
    ||chr(13)||chr(10)|| '                          , S.STOR_CD '
    ||chr(13)||chr(10)|| '                          , S.STOR_NM '
    ||chr(13)||chr(10)|| '                          , A.ATTD_DT '
    ||chr(13)||chr(10)|| '                          , A.USER_ID '
    ||chr(13)||chr(10)|| '                          , U.USER_NM '
    ||chr(13)||chr(10)|| '                          , C1.CODE_NM AS ROLE_NM'
    ||chr(13)||chr(10)|| '                          , C2.CODE_NM AS ADJ_NM'
    ||chr(13)||chr(10)|| '                          , NVL(CONFIRM_START_DTM, WORK_START_DTM)     AS WORK_START_DT '
    ||chr(13)||chr(10)|| '                          , CASE WHEN NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) < NVL(CONFIRM_START_DTM, WORK_START_DTM) THEN NVL(CONFIRM_START_DTM, WORK_START_DTM) ELSE NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) END AS WORK_CLOSE_DT '
    ||chr(13)||chr(10)|| '                       FROM ATTENDANCE  A '
    ||chr(13)||chr(10)|| '                          , STORE_USER  U '
    ||chr(13)||chr(10)|| '                          , S_STORE S '
    ||chr(13)||chr(10)|| '                          , ( '
    ||chr(13)||chr(10)|| '                            SELECT C.COMP_CD '
    ||chr(13)||chr(10)|| '                                 , C.CODE_CD '
    ||chr(13)||chr(10)|| '                                 , NVL(L.CODE_NM, C.CODE_NM) AS CODE_NM '
    ||chr(13)||chr(10)|| '                              FROM COMMON C '
    ||chr(13)||chr(10)|| '                                 , ( '
    ||chr(13)||chr(10)|| '                                     SELECT COMP_CD '
    ||chr(13)||chr(10)|| '                                          , CODE_CD '
    ||chr(13)||chr(10)|| '                                          , CODE_NM '
    ||chr(13)||chr(10)|| '                                       FROM LANG_COMMON '
    ||chr(13)||chr(10)|| '                                      WHERE COMP_CD = :PSV_COMP_CD '
    ||chr(13)||chr(10)|| '                                        AND CODE_TP = ''00770'''
    ||chr(13)||chr(10)|| '                                        AND LANGUAGE_TP = :PSV_LANG_CD '
    ||chr(13)||chr(10)|| '                                        AND USE_YN = ''Y'''
    ||chr(13)||chr(10)|| '                                   ) L '
    ||chr(13)||chr(10)|| '                             WHERE C.COMP_CD = L.COMP_CD(+) '
    ||chr(13)||chr(10)|| '                               AND C.CODE_CD = L.CODE_CD(+) '
    ||chr(13)||chr(10)|| '                               AND C.COMP_CD = :PSV_COMP_CD '
    ||chr(13)||chr(10)|| '                               AND C.CODE_TP = ''00770'''
    ||chr(13)||chr(10)|| '                               AND C.USE_YN = ''Y'''
    ||chr(13)||chr(10)|| '                            ) C1 '
    ||chr(13)||chr(10)|| '                          , ( '
    ||chr(13)||chr(10)|| '                            SELECT C.COMP_CD '
    ||chr(13)||chr(10)|| '                                 , C.CODE_CD '
    ||chr(13)||chr(10)|| '                                 , NVL(L.CODE_NM, C.CODE_NM) AS CODE_NM '
    ||chr(13)||chr(10)|| '                              FROM COMMON C '
    ||chr(13)||chr(10)|| '                                 , ( '
    ||chr(13)||chr(10)|| '                                     SELECT COMP_CD '
    ||chr(13)||chr(10)|| '                                          , CODE_CD '
    ||chr(13)||chr(10)|| '                                          , CODE_NM '
    ||chr(13)||chr(10)|| '                                       FROM LANG_COMMON '
    ||chr(13)||chr(10)|| '                                      WHERE COMP_CD = :PSV_COMP_CD '
    ||chr(13)||chr(10)|| '                                        AND CODE_TP = ''01590'''
    ||chr(13)||chr(10)|| '                                        AND LANGUAGE_TP = :PSV_LANG_CD '
    ||chr(13)||chr(10)|| '                                        AND USE_YN = ''Y'''
    ||chr(13)||chr(10)|| '                                   ) L '
    ||chr(13)||chr(10)|| '                             WHERE C.COMP_CD = L.COMP_CD(+) '
    ||chr(13)||chr(10)|| '                               AND C.CODE_CD = L.CODE_CD(+) '
    ||chr(13)||chr(10)|| '                               AND C.COMP_CD = :PSV_COMP_CD '
    ||chr(13)||chr(10)|| '                               AND C.CODE_TP = ''01590'''
    ||chr(13)||chr(10)|| '                               AND C.CODE_CD = ''2'''
    ||chr(13)||chr(10)|| '                               AND C.USE_YN = ''Y'''
    ||chr(13)||chr(10)|| '                            ) C2 '
    ||chr(13)||chr(10)|| '                      WHERE A.COMP_CD  = U.COMP_CD '
    ||chr(13)||chr(10)|| '                        AND A.BRAND_CD = U.BRAND_CD '
    ||chr(13)||chr(10)|| '                        AND A.STOR_CD  = U.STOR_CD '
    ||chr(13)||chr(10)|| '                        AND A.USER_ID  = U.USER_ID '
    ||chr(13)||chr(10)|| '                        AND A.COMP_CD  = S.COMP_CD '
    ||chr(13)||chr(10)|| '                        AND A.BRAND_CD = S.BRAND_CD '
    ||chr(13)||chr(10)|| '                        AND A.STOR_CD  = S.STOR_CD '
    ||chr(13)||chr(10)|| '                        AND U.ROLE_DIV = C1.CODE_CD (+) '
    ||chr(13)||chr(10)|| '                        AND A.COMP_CD  = :PSV_COMP_CD  '
    ||chr(13)||chr(10)|| '                        AND ' ||  ls_sql_date
    ||chr(13)||chr(10)|| '                     ) V01 '
    ||chr(13)||chr(10)|| '               WHERE V01.WORK_START_DT != V01.WORK_CLOSE_DT'
    ||chr(13)||chr(10)|| '              ) V02 '
    ||chr(13)||chr(10)|| '       ) V03 '
    ||chr(13)||chr(10)|| ' WHERE DAY_OF_SECOND >= 900'
    ;


      ls_sql := ls_sql_with || ls_sql_main;

     /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
    V_SQL :=   ' SELECT * '
            || ' FROM ( '
            || ls_sql
            || ' ) S_MAIN '
            || ' PIVOT '
            || ' (MAX(MOD_S_HM) VCOL1 , '
            || '  MAX(MOD_C_HM) VCOL2   '
            || ' FOR (SEQ) IN ( '
            || V_CROSSTAB
            || ' ) ) '
            ||  'ORDER BY 1, 5, 3, 6, 7 '   ;

   dbms_output.put_line( V_SQL) ;
   --dbms_output.put_line( V_HD) ;


  OPEN PR_HEADER FOR V_HD  USING PSV_COMP_CD, PSV_LANG_CD;
  OPEN PR_RESULT FOR V_SQL USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD;

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
