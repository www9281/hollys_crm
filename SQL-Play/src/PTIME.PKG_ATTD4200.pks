CREATE OR REPLACE PACKAGE       PKG_ATTD4200 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ATTD4200
    --  Description      : AR ���� �η� ��Ȳ
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- ȸ���ڵ�
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- ��ȸ ��������
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- ��ȸ ��������
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- �ڵ屸��(��ǰ�ڵ�, ��ǥ�ڵ�)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    );
END PKG_ATTD4200;

/

CREATE OR REPLACE PACKAGE BODY       PKG_ATTD4200 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- ȸ���ڵ�
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- ��ȸ ��������
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- ��ȸ ��������
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- �ڵ屸��(��ǰ�ڵ�, ��ǥ�ڵ�)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    ��ǰ �������
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
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- ���� WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- ��ǰ WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- ��ȸ���� (����)
    ls_date2        VARCHAR2(2000);     -- ��ȸ���� (���)
    ls_ex_date1     VARCHAR2(2000);     -- ��ȸ���� ���� (����)
    ls_ex_date2     VARCHAR2(2000);     -- ��ȸ���� ���� (���)
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
    
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
        
        
        ||CHR(13)||CHR(10)||Q'[ SELECT B1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ ,   B1.USER_ID       ]'
        ||CHR(13)||CHR(10)||Q'[ ,   MAX(B1.STOR_NM)   AS STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[ ,   MAX(B1.SPACE)     AS SPACE      ]'
        ||CHR(13)||CHR(10)||Q'[ ,   MAX(B1.USER_NM)   AS USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[ ,   SUM(B1.WORK_TIME) AS WORK_TIME  ]'
        ||CHR(13)||CHR(10)||Q'[ ,   (FLOOR (SUM(B1.WORK_TIME)) ) ||'�ð�'||' ' || LPAD(FLOOR (MOD( (SUM(B1.WORK_TIME) *60), 60) ), 2, 0) ||'��' AS WORK_HHMM    ]'
        ||CHR(13)||CHR(10)||Q'[ ,   MAX(B1.HOUR_PAY)  AS HOUR_PAY   ]'
        ||CHR(13)||CHR(10)||Q'[ ,   SUM(B1.DAY_PAY)   AS DAY_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[ ,   SUM(B1.WEEK_PAY)  AS WEEK_PAY   ]'
        ||CHR(13)||CHR(10)||Q'[ ,   SUM(B1.DAY_PAY + B1.WEEK_PAY) AS TOTAL_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[ ,   MAX(B2.GRD_AMT)               AS GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[ ,   ROUND( (SUM(B1.DAY_PAY + B1.WEEK_PAY)) / MAX(B2.GRD_AMT) * 100 , 2) AS PAY_PERCENT    ]'
        ||CHR(13)||CHR(10)||Q'[ ,   1                   AS WORK_USER_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   (    ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT A1.COMP_CD    ]' 
        ||CHR(13)||CHR(10)||Q'[    ,   A1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ATTD_DT    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.SPACE    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.USER_ID     ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A3.USER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[    ,   NVL(A4.BASIC_PAY, 0) AS HOUR_PAY ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ROUND( (TO_DATE(A1.CONFIRM_CLOSE_DTM, 'YYYYMMDDHH24MISS') - TO_DATE(A1.CONFIRM_START_DTM, 'YYYYMMDDHH24MISS')) *24, 2 ) AS WORK_TIME    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   NVL(A4.BASIC_PAY, 0) * ROUND( (TO_DATE(A1.CONFIRM_CLOSE_DTM, 'YYYYMMDDHH24MISS') - TO_DATE(A1.CONFIRM_START_DTM, 'YYYYMMDDHH24MISS')) *24 , 2) AS DAY_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ROUND(DECODE( NVL(A1.WEEK_DIV, 'N') , 'Y', NVL(A4.BASIC_PAY, 0) , 0) * A4.DAY_HOURS ) AS WEEK_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   DENSE_RANK() over(PARTITION BY A4.COMP_CD, A4.BRAND_CD, A4.STOR_CD, A4.USER_ID ORDER BY ATTD_PAY_DT DESC)  ATTD_PAY_RANK    ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   ATTENDANCE     A1    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    STORE          A2    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    STORE_USER     A3    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    STORE_PAY_MST  A4    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    S_STORE        A5    ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD    = A2.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A2.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A2.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A3.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A3.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A3.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.USER_ID    = A3.USER_ID           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A3.EMP_DIV    = '5'                  ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A4.COMP_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A4.BRAND_CD(+)       ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A4.STOR_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.USER_ID    = A4.USER_ID(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ATTD_DT   >= A4.ATTD_PAY_DT(+)    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A4.ATTD_PAY_DIV(+) = '1'             ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A5.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A5.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A5.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ATTD_DT    BETWEEN :PSV_GFR_DATE AND  :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    ( A1.WORK_DIV = NVL(:PSV_CODE_DIV, A1.WORK_DIV )  OR (:PSV_CODE_DIV IS NULL AND A1.WORK_DIV IS NULL ))  ]'
        ||CHR(13)||CHR(10)||Q'[ --AND    A1.CONFIRM_YN = 'Y'    ]'
        ||CHR(13)||CHR(10)||Q'[ ) B1 , (                        ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT A1.COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[    ,   SUM(A2.GRD_AMT)  AS GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   S_STORE  A1                 ]'
        ||CHR(13)||CHR(10)||Q'[    ,   SALE_JDS A2                 ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD  = A2.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD = A2.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD  = A2.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP BY A1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    ,     A1.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,     A1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ ) B2                   ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE B1.COMP_CD  = B2.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[ AND   B1.BRAND_CD = B2.BRAND_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND   B1.STOR_CD  = B2.STOR_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[ AND   B1.ATTD_PAY_RANK = '1'         ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP BY B1.STOR_CD, B1.USER_ID      ]'
        ;
               
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line('==>' || PSV_CODE_DIV);
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR

            ls_sql USING PSV_GFR_DATE, PSV_GTO_DATE
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_GFR_DATE, PSV_GTO_DATE;
                           

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
    
END PKG_ATTD4200;

/
