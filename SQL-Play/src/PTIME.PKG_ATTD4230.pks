CREATE OR REPLACE PACKAGE       PKG_ATTD4230 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ATTD4200
    --  Description      : 매장 AR별 근무이력 현황
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
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
END PKG_ATTD4230;

/

CREATE OR REPLACE PACKAGE BODY       PKG_ATTD4230 AS

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
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    상품 매출순위
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(32000);
    ls_sql_with     VARCHAR2(32000);
    ls_sql_main     VARCHAR2(12000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
    
    ls_time       VARCHAR2(4) := '';
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        --       ||  ', '
        --       ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        
        
        ||CHR(13)||CHR(10)||Q'[ SELECT D1.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    ,   D1.STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[    ,   D1.ROW_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   D1.SUBJECT_NM  ]'
        ;
   
        FOR i in 1..28 LOOP
            ls_time := TO_CHAR(TO_DATE('0800','HH24MI') + ((i -1) * (30/24/60))   , 'HH24MI');
            
            ls_sql_main := ls_sql_main ||CHR(13)||CHR(10) || '   ,   TO_CHAR(SUM(CASE WHEN AA = ''' || ls_time || ''' THEN SUBJECT_SUM ELSE 0 END))    AS TZONE_' || ls_time ;
        
        END LOOP;
        
        ls_sql_main := ls_sql_main
        
        ||CHR(13)||CHR(10)||Q'[ FROM (   ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT C1.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.AA ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.PERSON ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.WORK_TIME ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.DAY_PAY ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C2.ROW_NO ]'
        ||CHR(13)||CHR(10)||Q'[    ,   DECODE( C2.ROW_NO ,1, '시간합계', 2, '인원합계', 3, '시급합계'  ) AS SUBJECT_NM ]'
        ||CHR(13)||CHR(10)||Q'[    ,   DECODE( C2.ROW_NO ,1,  C1.WORK_TIME , 2, C1.PERSON, 3, C1.DAY_PAY  ) AS SUBJECT_SUM ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   ( ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[        ,   STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[        ,   AA    ]'
        ||CHR(13)||CHR(10)||Q'[        ,   SUM(PERSON)                AS PERSON    ]'
        ||CHR(13)||CHR(10)||Q'[        ,   SUM(WORK_TIME)             AS WORK_TIME    ]'
        ||CHR(13)||CHR(10)||Q'[        ,   SUM(BASIC_PAY * WORK_TIME) AS DAY_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[     FROM   (    ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   ATTD_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   BASIC_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   AA    ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   BB    ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   CC    ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   DD    ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   CASE WHEN CC <= AA AND DD >= BB THEN 1    ]'
        ||CHR(13)||CHR(10)||Q'[                             WHEN CC <= AA AND DD > AA AND DD < BB THEN 1    ]'
        ||CHR(13)||CHR(10)||Q'[                             WHEN CC >  AA AND DD < BB  THEN 1     ]'
        ||CHR(13)||CHR(10)||Q'[                             WHEN CC >  AA AND CC < BB AND DD >= BB THEN 1    ]'
        ||CHR(13)||CHR(10)||Q'[                             ELSE  0 END AS PERSON      ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   CASE WHEN CC <= AA AND DD >= BB THEN 0.5    ]'
        ||CHR(13)||CHR(10)||Q'[                             WHEN CC <= AA AND DD > AA AND DD < BB THEN ROUND((TO_DATE(DD , 'HH24MI') - TO_DATE(AA , 'HH24MI')) * 24, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[                             WHEN CC >  AA AND DD < BB  THEN ROUND((TO_DATE(DD , 'HH24MI') - TO_DATE(CC , 'HH24MI')) * 24, 2)     ]'
        ||CHR(13)||CHR(10)||Q'[                             WHEN CC >  AA AND CC < BB AND DD >= BB THEN ROUND((TO_DATE(BB , 'HH24MI') - TO_DATE(CC , 'HH24MI')) * 24, 2)    ]'  
        ||CHR(13)||CHR(10)||Q'[                             ELSE 0 END  AS WORK_TIME    ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM   (    ]'
        ||CHR(13)||CHR(10)||Q'[                          SELECT  TO_CHAR(TO_DATE('0800','HH24MI') + ((LEVEL -1) * (30/24/60))   , 'HH24MI')   AS AA    ]'
        ||CHR(13)||CHR(10)||Q'[                             ,    TO_CHAR(TO_DATE('0800','HH24MI') + ((LEVEL )   * (30/24/60))   , 'HH24MI')   AS BB    ]'
        ||CHR(13)||CHR(10)||Q'[                          FROM    DUAL    ]'
        ||CHR(13)||CHR(10)||Q'[                          CONNECT BY LEVEL <= 28    ]'
        ||CHR(13)||CHR(10)||Q'[                 ) B1,  (    ]'
        ||CHR(13)||CHR(10)||Q'[                          SELECT  *    ]'    
        ||CHR(13)||CHR(10)||Q'[                          FROM   (        ]'
        ||CHR(13)||CHR(10)||Q'[                          SELECT A1.ATTD_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                             ,   A1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                             ,   A2.STOR_NM         ]'
        ||CHR(13)||CHR(10)||Q'[                             ,   A1.USER_ID         ]'
        ||CHR(13)||CHR(10)||Q'[                             ,   A3.USER_NM         ]'
        ||CHR(13)||CHR(10)||Q'[                             ,   SUBSTR(A1.CONFIRM_START_DTM, 9 , 4) AS CC    ]'   
        ||CHR(13)||CHR(10)||Q'[                             ,   SUBSTR(A1.CONFIRM_CLOSE_DTM, 9 , 4) AS DD    ]'
        ||CHR(13)||CHR(10)||Q'[                             ,   A4.BASIC_PAY        ]'
        ||CHR(13)||CHR(10)||Q'[                             ,   DENSE_RANK() over(PARTITION BY A4.COMP_CD, A4.BRAND_CD, A4.STOR_CD, A4.USER_ID ORDER BY ATTD_PAY_DT DESC)  ATTD_PAY_RANK    ]'    
        ||CHR(13)||CHR(10)||Q'[                          FROM   ATTENDANCE     A1        ]'
        ||CHR(13)||CHR(10)||Q'[                            ,    S_STORE        A2    ]'    
        ||CHR(13)||CHR(10)||Q'[                            ,    STORE_USER     A3        ]'
        ||CHR(13)||CHR(10)||Q'[                            ,    STORE_PAY_MST  A4        ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  A1.COMP_CD    = A2.COMP_CD     ]'          
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.BRAND_CD   = A2.BRAND_CD          ]'    
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.STOR_CD    = A2.STOR_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.COMP_CD    = A3.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.BRAND_CD   = A3.BRAND_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.STOR_CD    = A3.STOR_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.USER_ID    = A3.USER_ID               ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A3.EMP_DIV    = '5'                      ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.COMP_CD    = A4.COMP_CD(+)            ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.BRAND_CD   = A4.BRAND_CD(+)           ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.STOR_CD    = A4.STOR_CD(+)            ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.USER_ID    = A4.USER_ID(+)            ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.ATTD_DT   >= A4.ATTD_PAY_DT(+)        ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A4.ATTD_PAY_DIV(+) = '1'                 ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    A1.ATTD_DT    BETWEEN :PSV_GFR_DATE AND :PSV_GT_DATE   ]'  
        ||CHR(13)||CHR(10)||Q'[                          --AND    A1.CONFIRM_YN = 'Y'        ]'
        ||CHR(13)||CHR(10)||Q'[                          )    ]'    
        ||CHR(13)||CHR(10)||Q'[                          WHERE ATTD_PAY_RANK = '1'    ]'   
        ||CHR(13)||CHR(10)||Q'[                 ) B2    ]'         
        ||CHR(13)||CHR(10)||Q'[     )    ]'
        ||CHR(13)||CHR(10)||Q'[     GROUP BY STOR_CD, STOR_NM , AA    ]'
        ||CHR(13)||CHR(10)||Q'[     )  C1 ,  (]'
        ||CHR(13)||CHR(10)||Q'[SELECT  LEVEL AS ROW_NO]'
        ||CHR(13)||CHR(10)||Q'[FROM    DUAL]'
        ||CHR(13)||CHR(10)||Q'[CONNECT BY LEVEL <=3]'
        ||CHR(13)||CHR(10)||Q'[) C2     ]'
        ||CHR(13)||CHR(10)||Q'[) D1     ]'
        ||CHR(13)||CHR(10)||Q'[GROUP BY D1.STOR_CD]'  
        ||CHR(13)||CHR(10)||Q'[,   D1.STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[,   D1.ROW_NO  ]'        
        ||CHR(13)||CHR(10)||Q'[,   D1.SUBJECT_NM ]'
        ||CHR(13)||CHR(10)||Q'[ORDER BY D1.STOR_CD]'  
        ||CHR(13)||CHR(10)||Q'[,   D1.STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[,   D1.ROW_NO  ]'
        ;
        
               
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line('==>' || PSV_CODE_DIV);
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR

            ls_sql USING PSV_GFR_DATE, PSV_GTO_DATE;
                           

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
        
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
    
END PKG_ATTD4230;

/
