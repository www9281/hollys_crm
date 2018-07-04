CREATE OR REPLACE PACKAGE       PKG_SALE4050 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4050
    --  Description      : ���� ���� ������ 
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
        PSV_SALE_DT     IN  VARCHAR2 ,                -- ��ȸ����
        PSV_POS_NO      IN  VARCHAR2 ,                -- ������ȣ
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- �Ǹ�����
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    );

END PKG_SALE4050;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4050 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- ȸ���ڵ�
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter(0:�Ϲ��Ǹ�, 1:��ǰ��(ȸ����) �Ǹ�)
        PSV_SALE_DT     IN  VARCHAR2 ,                -- ��ȸ����
        PSV_POS_NO      IN  VARCHAR2 ,                -- ������ȣ
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- �Ǹ�����
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     ���� ���� ������
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
    
    ls_sql_cm_00435 VARCHAR2(1000) ;    -- �����ڵ�SQL
    ls_sql_cm_00440 VARCHAR2(1000) ;    -- �����ڵ�SQL
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        -- �����ڵ� ���� Table ���� ---------------------------------------------------
        ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00435') ;
        ls_sql_cm_00440 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00440') ;
        -------------------------------------------------------------------------------
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SH.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.POS_NO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BILL_NO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_NM       AS SALE_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D.CODE_NM       AS GIFT_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_TM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_10_AMT + SS.PAY_30_AMT   AS PAY_10_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_20_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_30_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_40_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_50_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_60_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_67_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_6A_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_7A_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_7B_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_7C_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_7D_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_82_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_84_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_90_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_91_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SS.PAY_A0_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SH.COMP_CD, SH.SALE_DT, SH.BRAND_CD, SH.STOR_CD, SH.POS_NO, SH.BILL_NO, SH.SALE_DIV, SH.SALE_TM, SH.GIFT_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SALE_AMT, SH.GRD_I_AMT + SH.GRD_O_AMT AS GRD_AMT, SH.DC_AMT + SH.ENR_AMT AS DC_AMT           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (SH.GRD_I_AMT + SH.GRD_O_AMT) - (SH.VAT_I_AMT + SH.VAT_O_AMT) AS NET_AMT, (SH.VAT_I_AMT + SH.VAT_O_AMT) AS VAT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SH.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DT  = :PSV_SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_POS_NO   IS NULL OR SH.POS_NO   = :PSV_POS_NO)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_GIFT_DIV IS NULL OR SH.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[         )   SH          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SS.COMP_CD, SS.SALE_DT, SS.BRAND_CD, SS.STOR_CD, SS.POS_NO, SS.BILL_NO, SS.GIFT_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_10_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_20_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_30_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_40_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_50_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '60', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_60_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '67', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_67_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '69', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '6A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_6A_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', SS.PAY_AMT                                  )) ,0) AS PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_7A_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7B', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_7B_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7C', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_7C_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7D', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_7D_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '82', SS.PAY_AMT                                  )) ,0) AS PAY_82_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '84', SS.PAY_AMT                                  )) ,0) AS PAY_84_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '90', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_90_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '91', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_91_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, 'A0', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))) ,0) AS PAY_A0_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ( NVL(SUM(DECODE(SS.PAY_DIV, '10', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '20', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '30', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '40', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '50', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '60', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '67', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '68', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '69', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '6A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '70', SS.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '7A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '7B', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '7C', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '7D', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '82', SS.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '83', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '84', SS.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '90', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '91', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, '93', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SS.PAY_DIV, 'A0', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_ST     SS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.SALE_DT  = :PSV_SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_POS_NO   IS NULL OR SS.POS_NO   = :PSV_POS_NO)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_GIFT_DIV IS NULL OR SS.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SS.COMP_CD, SS.SALE_DT, SS.BRAND_CD, SS.STOR_CD, SS.POS_NO, SS.BILL_NO, SS.GIFT_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SS          ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00435 || Q'[ C]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00440 || Q'[ D]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SH.COMP_CD  = SS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DT  = SS.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BRAND_CD = SS.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.STOR_CD  = SS.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.POS_NO   = SS.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BILL_NO  = SS.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DIV = C.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.GIFT_DIV = D.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SH.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DIV                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.POS_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BILL_NO                  ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_SALE_DT, PSV_POS_NO, PSV_POS_NO, PSV_GIFT_DIV, PSV_GIFT_DIV,
                         PSV_COMP_CD, PSV_SALE_DT, PSV_POS_NO, PSV_POS_NO, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
    
END PKG_SALE4050;

/
