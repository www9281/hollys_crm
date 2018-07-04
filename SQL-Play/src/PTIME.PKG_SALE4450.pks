CREATE OR REPLACE PACKAGE       PKG_SALE4450 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4450
    --  Description      : ������ ��� ������Ȳ 
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- ��������
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- �Ǹ�����
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    );

END PKG_SALE4450;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4450 AS

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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- ��������
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- �Ǹ�����
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     ������ ��� ���� ��Ȳ
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
    ls_sql_main     VARCHAR2(20000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CD                          ]'  -- ���������ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'  -- ����������
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                           ]'  -- �μ��ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'  -- �μ���
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                           ]'  -- ���ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TEAM_NM)      AS TEAM_NM      ]'  -- ����
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID                        ]'  -- �����ID
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.SV_USER_NM)   AS SV_USER_NM   ]' -- ����ڸ�
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD                           ]'  -- �����ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM      ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA                         ]'  -- ����ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TRAD_AREA_NM) AS TRAD_AREA_NM ]'  -- ��Ǹ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT     ]'   -- ���� : �Ѹ����
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)     AS DC_AMT       ]'   -- ���� : ���ξ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT      ]'   -- ���� : �������(������)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT      ]'   -- ���� : �������(������)
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(DISTINCT SJ.SALE_DT)      AS SALE_DAY_CNT ]'   -- ���� : �����ϼ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)) AS CUST_CNT ]'  -- ���� : ����
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)), 0, 0, SUM(SJ.GRD_AMT) / SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)))    AS CUST_AMT ]'  -- ���� : ���ܰ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT) / (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT))                AS SALE_AMT_AVG ]'  -- ��ո��� : �Ѹ����
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT) / (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT))     AS DC_AMT_AVG   ]'  -- ��ո��� : ���ξ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)  / (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT))                AS GRD_AMT_AVG  ]'  -- ��ո��� : �����(������)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)/ (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT))     AS NET_AMT_AVG  ]'  -- ��ո��� : �����(������)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)) / (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT)) AS CUST_CNT_AVG ]'  -- ��ո��� : ��հ���
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.SALE_AMT             ELSE 0 END) AS DAY_SALE_AMT   ]'  -- ���� : �����
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.DC_AMT + SJ.ENR_AMT  ELSE 0 END) AS DAY_DC_AMT     ]'  -- ���� : ���αݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.GRD_AMT              ELSE 0 END) AS DAY_GRD_AMT    ]'  -- ���� : �����(������)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.GRD_AMT - SJ.VAT_AMT ELSE 0 END) AS DAY_NET_AMT    ]'  -- ���� : �����(������)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END)    AS DAY_CUST_CNT ]'  -- ���� : ���� ����
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END), 0, 0,  ]'
        ||CHR(13)||CHR(10)||Q'[           SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN GRD_AMT  ELSE 0 END)  / ]'
        ||CHR(13)||CHR(10)||Q'[           SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END)) AS DAY_CUST_AMT ]'  -- ���� : ���� ���ܰ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1            ELSE 0 END)  AS DAY_CNT      ]'      -- ���� : �����ϼ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.SALE_AMT  ELSE 0 END)                  ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END),0 ,1 ,             ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END))   AS DAY_SALE_AVG ]'  -- ���� : ����Ѹ����
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN  ('2', '3', '4', '5', '6') THEN SJ.GRD_AMT  ELSE 0 END)                  ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END),0 ,1 ,             ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END))   AS DAY_GRD_AVG  ]'  -- ���� : ��ռ������
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN  ('2', '3', '4', '5', '6') THEN SJ.GRD_AMT - SJ.VAT_AMT  ELSE 0 END)     ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END), 0, 1,             ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END))   AS DAY_NET_AVG  ]'  -- ���� : ��ռ������
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.SALE_AMT              ELSE 0 END)     AS WEEK_SALE_AMT]'  -- �ָ� : �Ѹ����
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.DC_AMT + SJ.ENR_AMT   ELSE 0 END)     AS WEEK_DC_AMT  ]'  -- �ָ� : ���αݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.GRD_AMT               ELSE 0 END)     AS WEEK_GRD_AMT ]'  -- �ָ� : �������(������)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.GRD_AMT - SJ.VAT_AMT  ELSE 0 END)     AS WEEK_NET_AMT ]'  -- �ָ� : �������(������)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END)   AS WEEK_CUST_CNT    ]'  -- �ָ� ����
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END), 0, 0, ]'
        ||CHR(13)||CHR(10)||Q'[         SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.GRD_AMT ELSE 0 END) / ]'
        ||CHR(13)||CHR(10)||Q'[         SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END))  AS WEEK_CUST_AMT    ]'  -- �ָ� ���ܰ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1           ELSE 0 END)  AS WEEK_CNT     ]'  -- �ָ� : �����ϼ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.SALE_AMT ELSE 0 END)                  ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1  ELSE 0 END), 0, 1,           ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1  ELSE 0 END)) AS WEEK_SALE_AVG]'  -- �ָ� : ��ո����
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.GRD_AMT  ELSE 0 END)                  ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN  ('1', '7') THEN 1 ELSE 0 END),0 ,1 ,           ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN  ('1', '7') THEN 1 ELSE 0 END)) AS WEEK_GRD_AVG ]'  -- �ָ� : ��ո����
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN  SJ.GRD_AMT - SJ.VAT_AMT ELSE 0 END)     ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1  ELSE 0 END),0 ,1 ,           ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1 ELSE 0 END))  AS WEEK_NET_AVG ]'  -- �ָ� : ��ո����
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)        AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.DC_AMT)          AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ENR_AMT)         AS ENR_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)         AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.VAT_AMT)         AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ETC_M_CNT)       AS ETC_M_CNT]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ETC_F_CNT)       AS ETC_F_CNT]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT)        AS BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.RTN_BILL_CNT)    AS RTN_BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.SALE_DT, SJ.BRAND_CD, SJ.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA     ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA     ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV
                       , PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV
                       , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
    
END PKG_SALE4450;

/
