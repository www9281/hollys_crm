CREATE OR REPLACE PACKAGE      PKG_ATTD4100 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_ATTD4100
   --  Description      : 출퇴근 현황(시간별조정)
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_MAIN_01
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
    );
    
    PROCEDURE SP_MAIN_02
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
    );
    
    PROCEDURE SP_MAIN_03
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
    );
    
END PKG_ATTD4100;

/

CREATE OR REPLACE PACKAGE BODY      PKG_ATTD4100 AS

    PROCEDURE SP_MAIN_01
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
       NAME:       SP_MAIN_01     출퇴근 현황(시간별조정) - 조정전
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_MAIN_01
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            ATTD_SEQ     NUMBER(2)
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
    ls_sql_main         VARCHAR2(30000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ls_sql_cm_00770     VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_01590     VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT ROW_NUMBER() OVER ( PARTITION BY A.BRAND_CD, A.STOR_CD , A.USER_ID, A.ATTD_DT ORDER BY WORK_START_DTM )    AS ATTD_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ATTENDANCE  A                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STORE_USER  SU                          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  A.COMP_CD   = S.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD  = S.BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD   = S.STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD   = SU.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD  = SU.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD   = SU.STOR_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.USER_ID   = SU.USER_ID                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD   = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.ATTD_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY 1                                    ]';
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_ID')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ROLE_DIV')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ATTD_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_ID')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ROLE_DIV')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ATTD_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]';
        
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).ATTD_SEQ || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).ATTD_SEQ                                           || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).ATTD_SEQ                                           || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'WORK_START_DTM')  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'WORK_CLOSE_DTM')  || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_01590 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '01590') ;
        -------------------------------------------------------------------------------
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ATTD_DT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R_NUM   AS SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM((DAY_OF_SECOND - MID_OF_SECOND) / 60)    AS REGULAR_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN (DAY_OF_SECOND - MID_OF_SECOND) / 60 ELSE 0 END) OVER (PARTITION BY STOR_CD, USER_ID)  AS REGULAR_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(MID_OF_SECOND / 60)  AS MIDNIGHT_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN MID_OF_SECOND / 60 ELSE 0 END) OVER (PARTITION BY STOR_CD, USER_ID)    AS MIDNIGHT_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN DAY_OF_SECOND > (8 * 60 * 60) THEN FN_GET_FROMAT_HHMM((DAY_OF_SECOND - (8 * 60 * 60)) / 60) ELSE '00:00' END  AS OVER_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 AND DAY_OF_SECOND > (8 * 60 * 60) THEN (DAY_OF_SECOND - (8 * 60 * 60)) / 60 ELSE 0 END) OVER(PARTITION BY  STOR_CD, USER_ID) AS OVER_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(DAY_OF_SECOND / 60) AS TOT_WORK_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN DAY_OF_SECOND / 60 ELSE 0 END) OVER(PARTITION BY STOR_CD, USER_ID) AS TOT_WORK_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOD_S_HM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOD_C_HM]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V02.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.ATTD_DT, 'YYYYMMDD'), 'YYYY-MM-DD') AS ATTD_DT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM((TO_DATE(V02.MOD_C_DT||V02.MOD_C_HM, 'YYYYMMDDHH24MI') - TO_DATE(V02.MOD_S_DT||V02.MOD_S_HM, 'YYYYMMDDHH24MI')) * 24 * 60 * 60) ]'
        ||CHR(13)||CHR(10)||Q'[                 OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT)    AS DAY_OF_SECOND ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.MOD_S_HM, 'HH24MI'), 'HH24:MI') AS MOD_S_HM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.MOD_C_HM, 'HH24MI'), 'HH24:MI') AS MOD_C_HM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(FN_GET_MIDNIGHT_WT(V02.MOD_S_DT||V02.MOD_S_HM, V02.MOD_C_DT||V02.MOD_C_HM)) OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT) AS MID_OF_SECOND ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  V01.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ATTD_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_START_DT, 'YYYYMMDDHH24MI'), 'YYYYMMDD') AS MOD_S_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, 'YYYYMMDDHH24MI'), 'YYYYMMDD') AS MOD_C_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_START_DT, 'YYYYMMDDHH24MI'), 'HH24MI')   AS MOD_S_HM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, 'YYYYMMDDHH24MI'), 'HH24MI')   AS MOD_C_HM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  ROW_NUMBER() OVER(PARTITION BY V01.STOR_CD, V01.USER_ID, V01.ATTD_DT ORDER BY V01.WORK_START_DT) AS R_NUM ]'
        ||CHR(13)||CHR(10)||Q'[                   FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  S.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.BRAND_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  A.ATTD_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  A.USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  U.USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C1.CODE_NM AS ROLE_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C2.CODE_CD AS ADJ_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C2.CODE_NM AS ADJ_DIV_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  NVL(CONFIRM_START_DTM, WORK_START_DTM) AS WORK_START_DT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  CASE WHEN NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) < NVL(CONFIRM_START_DTM, WORK_START_DTM) THEN NVL(CONFIRM_START_DTM, WORK_START_DTM) ELSE NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) END AS WORK_CLOSE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ATTENDANCE  A   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STORE_USER  U   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ]' || ls_sql_cm_00770 || Q'[ C1   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ]' || ls_sql_cm_01590 || Q'[ C2   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  A.COMP_CD  = U.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.BRAND_CD = U.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.STOR_CD  = U.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.USER_ID  = U.USER_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.COMP_CD  = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.BRAND_CD = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.STOR_CD  = S.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  U.COMP_CD  = C1.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  U.ROLE_DIV = C1.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  C2.CODE_CD = '1'        ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.ATTD_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                         )   V01 ]'
        ||CHR(13)||CHR(10)||Q'[                  WHERE  V01.WORK_START_DT != V01.WORK_CLOSE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                 )   V02 ]'
        ||CHR(13)||CHR(10)||Q'[         )   V03 ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  DAY_OF_SECOND >= 0 ]';
        
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
        ||CHR(13)||CHR(10)||Q'[       MAX(MOD_S_HM) AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , MAX(MOD_C_HM) AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SEQ) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY STOR_CD, USER_ID ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
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
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
    PROCEDURE SP_MAIN_02
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
       NAME:       SP_MAIN_02     출퇴근 현황(시간별조정) - 조정후
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_MAIN_02
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            ATTD_SEQ     NUMBER(2)
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
    ls_sql_main         VARCHAR2(30000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ls_sql_cm_00770     VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_01590     VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT ROW_NUMBER() OVER ( PARTITION BY A.BRAND_CD, A.STOR_CD , A.USER_ID, A.ATTD_DT ORDER BY WORK_START_DTM )    AS ATTD_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ATTENDANCE  A                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STORE_USER  SU                          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  A.COMP_CD   = S.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD  = S.BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD   = S.STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD   = SU.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD  = SU.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD   = SU.STOR_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.USER_ID   = SU.USER_ID                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD   = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.ATTD_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY 1                                    ]';
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_ID')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ROLE_DIV')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ATTD_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_ID')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ROLE_DIV')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ATTD_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]';
        
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).ATTD_SEQ || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).ATTD_SEQ                                           || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).ATTD_SEQ                                           || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'WORK_START_DTM')  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'WORK_CLOSE_DTM')  || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_01590 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '01590') ;
        -------------------------------------------------------------------------------
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ATTD_DT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R_NUM   AS SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM((DAY_OF_SECOND - MID_OF_SECOND) / 60)    AS REGULAR_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN (DAY_OF_SECOND - MID_OF_SECOND) / 60 ELSE 0 END) OVER (PARTITION BY STOR_CD, USER_ID)  AS REGULAR_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(MID_OF_SECOND / 60)  AS MIDNIGHT_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN MID_OF_SECOND / 60 ELSE 0 END) OVER (PARTITION BY STOR_CD, USER_ID)    AS MIDNIGHT_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN DAY_OF_SECOND > (8 * 60 * 60) THEN FN_GET_FROMAT_HHMM((DAY_OF_SECOND - (8 * 60 * 60)) / 60) ELSE '00:00' END  AS OVER_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 AND DAY_OF_SECOND > (8 * 60 * 60) THEN (DAY_OF_SECOND - (8 * 60 * 60)) / 60 ELSE 0 END) OVER(PARTITION BY  STOR_CD, USER_ID) AS OVER_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(DAY_OF_SECOND / 60) AS TOT_WORK_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN DAY_OF_SECOND / 60 ELSE 0 END) OVER(PARTITION BY STOR_CD, USER_ID) AS TOT_WORK_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOD_S_HM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOD_C_HM]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V02.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.ATTD_DT, 'YYYYMMDD'), 'YYYY-MM-DD') AS ATTD_DT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM((TO_DATE(V02.MOD_C_DT||V02.MOD_C_HM, 'YYYYMMDDHH24MI') - TO_DATE(V02.MOD_S_DT||V02.MOD_S_HM, 'YYYYMMDDHH24MI')) * 24 * 60 * 60) ]'
        ||CHR(13)||CHR(10)||Q'[                 OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT)    AS DAY_OF_SECOND ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.MOD_S_HM, 'HH24MI'), 'HH24:MI') AS MOD_S_HM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.MOD_C_HM, 'HH24MI'), 'HH24:MI') AS MOD_C_HM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(FN_GET_MIDNIGHT_WT(V02.MOD_S_DT||V02.MOD_S_HM, V02.MOD_C_DT||V02.MOD_C_HM)) OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT) AS MID_OF_SECOND ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  V01.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ATTD_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_START_DT, 'YYYYMMDDHH24MI') + 900 / (24 * 60 * 60),  'YYYYMMDD') AS MOD_S_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, 'YYYYMMDDHH24MI') - 900 / (24 * 60 * 60),  'YYYYMMDD') AS MOD_C_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  REPLACE(FN_GET_FROMAT_HHMM(CEIL(TO_NUMBER(TO_CHAR(TO_DATE(V01.WORK_START_DT,  'YYYYMMDDHH24MI'), 'SSSSS')) / 900) * 900 / 60), ':', '') AS MOD_S_HM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  REPLACE(FN_GET_FROMAT_HHMM(FLOOR(TO_NUMBER(TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, 'YYYYMMDDHH24MI'), 'SSSSS')) / 900) * 900 / 60), ':', '') AS MOD_C_HM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  ROW_NUMBER() OVER(PARTITION BY V01.STOR_CD, V01.USER_ID, V01.ATTD_DT ORDER BY V01.WORK_START_DT) AS R_NUM ]'
        ||CHR(13)||CHR(10)||Q'[                   FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  S.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.BRAND_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  A.ATTD_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  A.USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  U.USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C1.CODE_NM AS ROLE_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C2.CODE_CD AS ADJ_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C2.CODE_NM AS ADJ_DIV_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  NVL(CONFIRM_START_DTM, WORK_START_DTM) AS WORK_START_DT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  CASE WHEN NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) < NVL(CONFIRM_START_DTM, WORK_START_DTM) THEN NVL(CONFIRM_START_DTM, WORK_START_DTM) ELSE NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) END AS WORK_CLOSE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ATTENDANCE  A   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STORE_USER  U   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ]' || ls_sql_cm_00770 || Q'[ C1   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ]' || ls_sql_cm_01590 || Q'[ C2   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  A.COMP_CD  = U.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.BRAND_CD = U.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.STOR_CD  = U.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.USER_ID  = U.USER_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.COMP_CD  = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.BRAND_CD = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.STOR_CD  = S.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  U.COMP_CD  = C1.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  U.ROLE_DIV = C1.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  C2.CODE_CD = '2'        ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.ATTD_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                         )   V01 ]'
        ||CHR(13)||CHR(10)||Q'[                  WHERE  V01.WORK_START_DT != V01.WORK_CLOSE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                 )   V02 ]'
        ||CHR(13)||CHR(10)||Q'[         )   V03 ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  DAY_OF_SECOND >= 0 ]';
        
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
        ||CHR(13)||CHR(10)||Q'[       MAX(MOD_S_HM) AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , MAX(MOD_C_HM) AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SEQ) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY STOR_CD, USER_ID ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
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
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
    PROCEDURE SP_MAIN_03
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
       NAME:       SP_MAIN_03     출퇴근 현황(시간별조정) - 전체
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_MAIN_03
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            ATTD_SEQ     NUMBER(2)
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
    ls_sql_main         VARCHAR2(30000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ls_sql_cm_00770     VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_01590     VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT ROW_NUMBER() OVER ( PARTITION BY A.BRAND_CD, A.STOR_CD , A.USER_ID, A.ATTD_DT ORDER BY WORK_START_DTM )    AS ATTD_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ATTENDANCE  A                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STORE_USER  SU                          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  A.COMP_CD   = S.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD  = S.BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD   = S.STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD   = SU.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD  = SU.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD   = SU.STOR_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.USER_ID   = SU.USER_ID                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD   = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.ATTD_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY 1                                    ]';
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_ID')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ROLE_DIV')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ATTD_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_ID')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USER_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ROLE_DIV')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ATTD_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGULAR_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MIDNIGHT_HM')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OVER_HM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CONFIRM_HM')   ]';
        
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).ATTD_SEQ || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).ATTD_SEQ                                           || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).ATTD_SEQ                                           || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'WORK_START_DTM')  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'WORK_CLOSE_DTM')  || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_01590 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '01590') ;
        -------------------------------------------------------------------------------
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ATTD_DT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R_NUM   AS SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM((DAY_OF_SECOND - MID_OF_SECOND) / 60)    AS REGULAR_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN (DAY_OF_SECOND - MID_OF_SECOND) / 60 ELSE 0 END) OVER (PARTITION BY STOR_CD, USER_ID)  AS REGULAR_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(MID_OF_SECOND / 60)  AS MIDNIGHT_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN MID_OF_SECOND / 60 ELSE 0 END) OVER (PARTITION BY STOR_CD, USER_ID)    AS MIDNIGHT_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN DAY_OF_SECOND > (8 * 60 * 60) THEN FN_GET_FROMAT_HHMM((DAY_OF_SECOND - (8 * 60 * 60)) / 60) ELSE '00:00' END  AS OVER_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 AND DAY_OF_SECOND > (8 * 60 * 60) THEN (DAY_OF_SECOND - (8 * 60 * 60)) / 60 ELSE 0 END) OVER(PARTITION BY  STOR_CD, USER_ID) AS OVER_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(DAY_OF_SECOND / 60) AS TOT_WORK_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN DAY_OF_SECOND / 60 ELSE 0 END) OVER(PARTITION BY STOR_CD, USER_ID) AS TOT_WORK_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOD_S_HM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOD_C_HM]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V02.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.ATTD_DT, 'YYYYMMDD'), 'YYYY-MM-DD') AS ATTD_DT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM((TO_DATE(V02.MOD_C_DT||V02.MOD_C_HM, 'YYYYMMDDHH24MI') - TO_DATE(V02.MOD_S_DT||V02.MOD_S_HM, 'YYYYMMDDHH24MI')) * 24 * 60 * 60) ]'
        ||CHR(13)||CHR(10)||Q'[                 OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT)    AS DAY_OF_SECOND ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.MOD_S_HM, 'HH24MI'), 'HH24:MI') AS MOD_S_HM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.MOD_C_HM, 'HH24MI'), 'HH24:MI') AS MOD_C_HM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(FN_GET_MIDNIGHT_WT(V02.MOD_S_DT||V02.MOD_S_HM, V02.MOD_C_DT||V02.MOD_C_HM)) OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT) AS MID_OF_SECOND ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  V01.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ATTD_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_START_DT, 'YYYYMMDDHH24MI'), 'YYYYMMDD') AS MOD_S_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, 'YYYYMMDDHH24MI'), 'YYYYMMDD') AS MOD_C_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_START_DT, 'YYYYMMDDHH24MI'), 'HH24MI')   AS MOD_S_HM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, 'YYYYMMDDHH24MI'), 'HH24MI')   AS MOD_C_HM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  ROW_NUMBER() OVER(PARTITION BY V01.STOR_CD, V01.USER_ID, V01.ATTD_DT ORDER BY V01.WORK_START_DT) AS R_NUM ]'
        ||CHR(13)||CHR(10)||Q'[                   FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  S.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.BRAND_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  A.ATTD_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  A.USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  U.USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C1.CODE_NM AS ROLE_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C2.CODE_CD AS ADJ_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C2.CODE_NM AS ADJ_DIV_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  NVL(CONFIRM_START_DTM, WORK_START_DTM) AS WORK_START_DT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  CASE WHEN NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) < NVL(CONFIRM_START_DTM, WORK_START_DTM) THEN NVL(CONFIRM_START_DTM, WORK_START_DTM) ELSE NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) END AS WORK_CLOSE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ATTENDANCE  A   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STORE_USER  U   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ]' || ls_sql_cm_00770 || Q'[ C1   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ]' || ls_sql_cm_01590 || Q'[ C2   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  A.COMP_CD  = U.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.BRAND_CD = U.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.STOR_CD  = U.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.USER_ID  = U.USER_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.COMP_CD  = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.BRAND_CD = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.STOR_CD  = S.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  U.COMP_CD  = C1.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  U.ROLE_DIV = C1.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  C2.CODE_CD = '1'        ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.ATTD_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                         )   V01 ]'
        ||CHR(13)||CHR(10)||Q'[                  WHERE  V01.WORK_START_DT != V01.WORK_CLOSE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                 )   V02 ]'
        ||CHR(13)||CHR(10)||Q'[         )   V03 ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  DAY_OF_SECOND >= 0 ]'
        ||CHR(13)||CHR(10)||Q'[ UNION ALL ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT  STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ATTD_DT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R_NUM   AS SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM((DAY_OF_SECOND - MID_OF_SECOND) / 60)    AS REGULAR_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN (DAY_OF_SECOND - MID_OF_SECOND) / 60 ELSE 0 END) OVER (PARTITION BY STOR_CD, USER_ID)  AS REGULAR_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(MID_OF_SECOND / 60)  AS MIDNIGHT_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN MID_OF_SECOND / 60 ELSE 0 END) OVER (PARTITION BY STOR_CD, USER_ID)    AS MIDNIGHT_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN DAY_OF_SECOND > (8 * 60 * 60) THEN FN_GET_FROMAT_HHMM((DAY_OF_SECOND - (8 * 60 * 60)) / 60) ELSE '00:00' END  AS OVER_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 AND DAY_OF_SECOND > (8 * 60 * 60) THEN (DAY_OF_SECOND - (8 * 60 * 60)) / 60 ELSE 0 END) OVER(PARTITION BY  STOR_CD, USER_ID) AS OVER_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(DAY_OF_SECOND / 60) AS TOT_WORK_HM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN R_NUM = 1 THEN DAY_OF_SECOND / 60 ELSE 0 END) OVER(PARTITION BY STOR_CD, USER_ID) AS TOT_WORK_MM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOD_S_HM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOD_C_HM]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V02.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.ATTD_DT, 'YYYYMMDD'), 'YYYY-MM-DD') AS ATTD_DT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM((TO_DATE(V02.MOD_C_DT||V02.MOD_C_HM, 'YYYYMMDDHH24MI') - TO_DATE(V02.MOD_S_DT||V02.MOD_S_HM, 'YYYYMMDDHH24MI')) * 24 * 60 * 60) ]'
        ||CHR(13)||CHR(10)||Q'[                 OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT)    AS DAY_OF_SECOND ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.MOD_S_HM, 'HH24MI'), 'HH24:MI') AS MOD_S_HM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  TO_CHAR(TO_DATE(V02.MOD_C_HM, 'HH24MI'), 'HH24:MI') AS MOD_C_HM ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(FN_GET_MIDNIGHT_WT(V02.MOD_S_DT||V02.MOD_S_HM, V02.MOD_C_DT||V02.MOD_C_HM)) OVER(PARTITION BY V02.STOR_CD, V02.USER_ID, V02.ATTD_DT) AS MID_OF_SECOND ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  V01.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ROLE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ADJ_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ADJ_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ATTD_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_START_DT, 'YYYYMMDDHH24MI') + 900 / (24 * 60 * 60),  'YYYYMMDD') AS MOD_S_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, 'YYYYMMDDHH24MI') - 900 / (24 * 60 * 60),  'YYYYMMDD') AS MOD_C_DT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  REPLACE(FN_GET_FROMAT_HHMM(CEIL(TO_NUMBER(TO_CHAR(TO_DATE(V01.WORK_START_DT,  'YYYYMMDDHH24MI'), 'SSSSS')) / 900) * 900 / 60), ':', '') AS MOD_S_HM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  REPLACE(FN_GET_FROMAT_HHMM(FLOOR(TO_NUMBER(TO_CHAR(TO_DATE(V01.WORK_CLOSE_DT, 'YYYYMMDDHH24MI'), 'SSSSS')) / 900) * 900 / 60), ':', '') AS MOD_C_HM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  ROW_NUMBER() OVER(PARTITION BY V01.STOR_CD, V01.USER_ID, V01.ATTD_DT ORDER BY V01.WORK_START_DT) AS R_NUM ]'
        ||CHR(13)||CHR(10)||Q'[                   FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  S.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.BRAND_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  A.ATTD_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  A.USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  U.USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C1.CODE_NM AS ROLE_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C2.CODE_CD AS ADJ_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  C2.CODE_NM AS ADJ_DIV_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  NVL(CONFIRM_START_DTM, WORK_START_DTM) AS WORK_START_DT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  CASE WHEN NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) < NVL(CONFIRM_START_DTM, WORK_START_DTM) THEN NVL(CONFIRM_START_DTM, WORK_START_DTM) ELSE NVL(CONFIRM_CLOSE_DTM, WORK_CLOSE_DTM) END AS WORK_CLOSE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ATTENDANCE  A   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STORE_USER  U   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ]' || ls_sql_cm_00770 || Q'[ C1   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ]' || ls_sql_cm_01590 || Q'[ C2   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  A.COMP_CD  = U.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.BRAND_CD = U.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.STOR_CD  = U.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.USER_ID  = U.USER_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.COMP_CD  = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.BRAND_CD = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.STOR_CD  = S.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  U.COMP_CD  = C1.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  U.ROLE_DIV = C1.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  C2.CODE_CD = '2'        ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  A.ATTD_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                         )   V01 ]'
        ||CHR(13)||CHR(10)||Q'[                  WHERE  V01.WORK_START_DT != V01.WORK_CLOSE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                 )   V02 ]'
        ||CHR(13)||CHR(10)||Q'[         )   V03 ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  DAY_OF_SECOND >= 0 ]';
        
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
        ||CHR(13)||CHR(10)||Q'[       MAX(MOD_S_HM) AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , MAX(MOD_C_HM) AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SEQ) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY STOR_CD, USER_ID ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
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
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
END PKG_ATTD4100;

/
