CREATE OR REPLACE PACKAGE       PKG_SALE1280 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1280
   --  Description      : ����� ���� ���� ��ȸ 
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    );
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    );
    
    PROCEDURE SP_TAB03
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    );
    
    PROCEDURE SP_TAB04
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    );
    
    PROCEDURE SP_TAB05
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    );
    
END PKG_SALE1280;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1280 AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01     ����� ���� ���� ��ȸ(�����)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- ���� WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- ��ǰ WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- ��ȸ���� (����)
    ls_date2        VARCHAR2(2000);     -- ��ȸ���� (���)
    ls_ex_date1     VARCHAR2(2000);     -- ��ȸ���� ���� (����)
    ls_ex_date2     VARCHAR2(2000);     -- ��ȸ���� ���� (���)
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                                     ]'  -- ������ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM                         ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV                                                   ]'  -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(CH.CERT_NO)                                   AS USE_CNT  ]'  -- ���Ǽ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT))   AS USE_AMT  ]'  -- ���ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CI.SALE_AMT)                                    AS SALE_AMT ]'  -- �Ǹűݾ�
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, CM.COUPON_DIV ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CM.COUPON_DIV ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     ����� ���� ���� ��ȸ(��������)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- ���� WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- ��ǰ WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- ��ȸ���� (����)
    ls_date2        VARCHAR2(2000);     -- ��ȸ���� (���)
    ls_ex_date1     VARCHAR2(2000);     -- ��ȸ���� ���� (����)
    ls_ex_date2     VARCHAR2(2000);     -- ��ȸ���� ���� (���)
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                                     ]'  -- ������ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM                         ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.BRAND_CD                                                     ]'  -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM                             ]'  -- ����������
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV                                                   ]'  -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(CH.CERT_NO)                                   AS USE_CNT  ]'  -- ���Ǽ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT))   AS USE_AMT  ]'  -- ���ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CI.SALE_AMT)                                    AS SALE_AMT ]'  -- �Ǹűݾ�
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, CH.BRAND_CD, CM.COUPON_DIV ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CH.BRAND_CD, CM.COUPON_DIV ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB03
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03     ����� ���� ���� ��ȸ(����)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- ���� WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- ��ǰ WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- ��ȸ���� (����)
    ls_date2        VARCHAR2(2000);     -- ��ȸ���� (���)
    ls_ex_date1     VARCHAR2(2000);     -- ��ȸ���� ���� (����)
    ls_ex_date2     VARCHAR2(2000);     -- ��ȸ���� ���� (���)
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                                     ]'  -- ������ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM                         ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.BRAND_CD                                                     ]'  -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM                             ]'  -- ����������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.STOR_CD                                                      ]'  -- �����ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)          AS STOR_NM                              ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV                                                   ]'  -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(CH.CERT_NO)                                   AS USE_CNT  ]'  -- ���Ǽ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT))   AS USE_AMT  ]'  -- ���ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CI.SALE_AMT)                                    AS SALE_AMT ]'  -- �Ǹűݾ�
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CM.COUPON_DIV ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CM.COUPON_DIV ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB04
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB04     ����� ���� ���� ��ȸ(����)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB04
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- ���� WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- ��ǰ WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- ��ȸ���� (����)
    ls_date2        VARCHAR2(2000);     -- ��ȸ���� (���)
    ls_ex_date1     VARCHAR2(2000);     -- ��ȸ���� ���� (����)
    ls_ex_date2     VARCHAR2(2000);     -- ��ȸ���� ���� (���)
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                                     ]'  -- ������ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM                         ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.BRAND_CD                                                     ]'  -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM                             ]'  -- ����������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.STOR_CD                                                      ]'  -- �����ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)          AS STOR_NM                              ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.USE_DT                                                       ]'  -- �������
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WEEK(:PSV_COMP_CD, CH.USE_DT, :PSV_LANG_CD)  AS USE_DY   ]'  -- ����
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV                                                   ]'  -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(CH.CERT_NO)                                   AS USE_CNT  ]'  -- ���Ǽ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT))   AS USE_AMT  ]'  -- ���ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CI.SALE_AMT)                                    AS SALE_AMT ]'  -- �Ǹűݾ�
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CH.USE_DT, CM.COUPON_DIV ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CH.USE_DT, CM.COUPON_DIV ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB05
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- ǰ�� ��/��/�� �з� �׷�
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- ��ȸ ��������
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- ��������
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- �Ӵ뱸��
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG          OUT VARCHAR2                    -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB05     ����� ���� ���� ��ȸ(������)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB05
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- ���� WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- ��ǰ WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- ��ȸ���� (����)
    ls_date2        VARCHAR2(2000);     -- ��ȸ���� (���)
    ls_ex_date1     VARCHAR2(2000);     -- ��ȸ���� ���� (����)
    ls_ex_date2     VARCHAR2(2000);     -- ��ȸ���� ���� (���)
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP         ]'  -- ������ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP_NM      ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.BRAND_CD         ]'  -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM          ]'  -- ����������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.STOR_CD          ]'  -- �����ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM           ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.USE_DT           ]'  -- �������
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WEEK(:PSV_COMP_CD, CH.USE_DT, :PSV_LANG_CD)  AS USE_DY  ]'  -- ����
        ||CHR(13)||CHR(10)||Q'[      ,  CH.USE_TM           ]'  -- ���ð�
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV       ]'  -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.USE_STAT         ]'  -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  CH.CERT_NO          ]'  -- ������ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(M.MEMBER_NM)                                AS CUST_NM  ]'  -- ȸ����
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(CH.MOBILE))             AS MOBILE   ]'  -- �ڵ���
        ||CHR(13)||CHR(10)||Q'[      ,  ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT)        AS USE_AMT  ]'  -- ���ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  CI.SALE_AMT                                         AS SALE_AMT ]'  -- �Ǹűݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  CH.RETURN_MSG       ]'  -- ����޼���
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER           M   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CUST_ID  = M.MEMBER_NO   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CH.USE_DT, CM.COUPON_DIV, CH.USE_TM ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
END PKG_SALE1280;

/
