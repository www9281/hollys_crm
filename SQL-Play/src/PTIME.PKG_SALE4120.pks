CREATE OR REPLACE PACKAGE       PKG_SALE4120 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4120
    --  Description      : ��ǰ �������(��-����)
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
END PKG_SALE4120;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4120 AS

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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.L_CLASS_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.M_CLASS_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.S_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.S_CLASS_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.ITEM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.ITEM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SALE_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SALE_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DC_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.GRD_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.NET_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.VAT_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_QTY)                AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)                AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)     AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||q'[               FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) ]'
        ||CHR(13)||CHR(10)||Q'[         )       S   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.GRD_AMT DESC       ]';
               
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV;

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
    
END PKG_SALE4120;

/
