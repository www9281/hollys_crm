CREATE OR REPLACE PACKAGE       PKG_SALE1240 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1240
   --  Description      : ȸ���� ��볻��
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
        PSV_MBS_DIV     IN  VARCHAR2 ,                -- ȸ��������
        PSV_CHARGE_YN   IN  VARCHAR2 ,                -- �����󱸺�
        PSV_MEMBER_TXT  IN  VARCHAR2 ,                -- ȸ����ȣ/��
        PSV_CHILD_TXT   IN  VARCHAR2 ,                -- �ڳ��ȣ/��
        PSV_PROGRAM_TXT IN  VARCHAR2 ,                -- ���α׷�ID/��
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    );
    
END PKG_SALE1240;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1240 AS

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
        PSV_MBS_DIV     IN  VARCHAR2 ,                -- ȸ��������
        PSV_CHARGE_YN   IN  VARCHAR2 ,                -- �����󱸺�
        PSV_MEMBER_TXT  IN  VARCHAR2 ,                -- ȸ����ȣ/��
        PSV_CHILD_TXT   IN  VARCHAR2 ,                -- �ڳ��ȣ/��
        PSV_PROGRAM_TXT IN  VARCHAR2 ,                -- ���α׷�ID/��
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     ȸ���� ��볻��
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-06-01
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  EM.MBS_NO   ]'                          -- ȸ���ǹ�ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_NM    ]'                          -- ȸ���Ǹ�
        ||CHR(13)||CHR(10)||Q'[      ,  REPLACE(EM.CERT_NO, SUBSTR(EM.CERT_NO, 9, 5), '*****') AS CERT_NO ]'  -- ������ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_DIV   ]'                          -- ȸ��������
        ||CHR(13)||CHR(10)||Q'[      ,  M.CHARGE_YN ]'                          -- �����󱸺�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.MBS_STAT ]'                          -- ȸ���ǻ���
        ||CHR(13)||CHR(10)||Q'[      ,  EM.ENTRY_DT ]'                          -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  EM.BRAND_CD ]'                          -- ���������ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM  ]'                          -- ����������
        ||CHR(13)||CHR(10)||Q'[      ,  EM.STOR_CD  ]'                          -- �����ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM   ]'                          -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  EM.MEMBER_NO]'                          -- ȸ����ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM)) AS MEMBER_NM ]' -- ȸ����
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(C.MOBILE)) AS MOBILE ]' -- �ڵ���
        ||CHR(13)||CHR(10)||Q'[      ,  EM.CHILD_NO ]'                          -- �ڳ��ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(NVL(ED.ENTRY_NM, MC.CHILD_NM))  AS CHILD_NM ]'  -- �ڳ��
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(ED.SEX_DIV, MC.SEX_DIV)     AS SEX_DIV  ]'          -- ����
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(ED.AGES, MC.AGES)           AS AGES     ]'          -- ����
        ||CHR(13)||CHR(10)||Q'[      ,  MS.PROGRAM_ID   ]'                      -- ���α׷�ID
        ||CHR(13)||CHR(10)||Q'[      ,  M.PROGRAM_NM]'                          -- ���α׷���
        ||CHR(13)||CHR(10)||Q'[      ,  EP.MATL_ITEM_CD ]'                      -- �̿뱳���ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM   AS MATL_ITEM_NM ]'          -- ������
        ||CHR(13)||CHR(10)|| '       ,  CASE WHEN I.ITEM_NM IS NULL THEN M.PROGRAM_NM   '
        ||CHR(13)||CHR(10)|| '               ELSE M.PROGRAM_NM||''[''||I.ITEM_NM||'']'' '
        ||CHR(13)||CHR(10)|| '          END                 AS PROGRAM_MATL '   -- ���α׷�[����]
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FROMAT_HHMM(EP.USE_TM) AS EP_USE_TM  ]'  -- �̿�ð�
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ENTRY_FTM    ]'                      -- ����ð�
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ENTRY_TTM    ]'                      -- ��ǽð�
        ||CHR(13)||CHR(10)||Q'[      ,  EM.USE_TM   AS EM_USE_TM    ]'          -- �̿�ð�(��)(ȸ���ǰ���)
        ||CHR(13)||CHR(10)||Q'[      ,  EM.USE_CNT  AS EM_USE_CNT   ]'          -- �̿�Ƚ��(ȸ���ǰ���)
        ||CHR(13)||CHR(10)||Q'[      ,  EM.USE_AMT  AS EM_USE_AMT   ]'          -- �̿�ݾ�(ȸ���ǰ���)
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_FDT ]'                          -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_TDT ]'                          -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  MS.GRD_AMT  ]'                          -- ���űݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.REFUND_AMT   ]'                      -- ȯ�ұݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_TM ]'                          -- �����ð�(��)
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_TM   ]'                          -- ���ð�(��)
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_CNT]'                          -- ����Ƚ��
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_CNT  ]'                          -- ���Ƚ��
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_AMT]'                          -- �����ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_AMT  ]'                          -- ���ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_AMT - MS.USE_AMT   AS REST_AMT ]'  -- �ܿ��ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_MCNT   ]'                      -- ����Ƚ��[����]
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_MCNT ]'                          -- ���Ƚ��[����]
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.OFFER_TM   ELSE 0 END AS TOT_OFFER_TM   ]'    -- �������ð�(��)
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.USE_TM     ELSE 0 END AS TOT_USE_TM     ]'    -- �ѻ��ð�(��)
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.OFFER_CNT  ELSE 0 END AS TOT_OFFER_CNT  ]'    -- ������Ƚ��
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.USE_CNT    ELSE 0 END AS TOT_USE_CNT    ]'    -- �ѻ��Ƚ��
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.OFFER_AMT  ELSE 0 END AS TOT_OFFER_AMT  ]'    -- �������ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.USE_AMT    ELSE 0 END AS TOT_USE_AMT    ]'    -- �ѻ��ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.OFFER_MCNT ELSE 0 END AS TOT_OFFER_MCNT ]'    -- ������������
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EM.COMP_CD, EM.CERT_NO ORDER BY EM.COMP_CD, EM.CERT_NO) = 1 THEN MS.USE_MCNT   ELSE 0 END AS TOT_USE_MCNT   ]'    -- �ѻ�뱳����
        ||CHR(13)||CHR(10)||Q'[   FROM  CS_ENTRY_MEMBERSHIP EM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_PROGRAM    EP  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_DT         ED  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_ENTRY_HD         EH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  P.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  P.PROGRAM_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(PL.LANG_NM, P.PROGRAM_NM)   AS PROGRAM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MBS_NO        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(ML.LANG_NM, M.MBS_NM)       AS MBS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MBS_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.CHARGE_YN     ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  CS_PROGRAM      P   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBERSHIP   M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE      PL  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE      ML  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  P.COMP_CD       = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  P.PROGRAM_ID    = M.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.COMP_CD(+)   = P.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.PK_COL(+)    = LPAD(P.PROGRAM_ID, 30, ' ')   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.COMP_CD(+)   = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.PK_COL(+)    = LPAD(M.PROGRAM_ID, 30, ' ')||LPAD(M.MBS_NO, 30, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[                AND  P.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.TABLE_NM(+)  = 'CS_PROGRAM'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.COL_NM(+)    = 'PROGRAM_NM'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.LANGUAGE_TP(+) = :PSV_LANG_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  PL.USE_YN(+)    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.TABLE_NM(+)  = 'CS_MEMBERSHIP']'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.COL_NM(+)    = 'MBS_NM'      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.LANGUAGE_TP(+) = :PSV_LANG_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  ML.USE_YN(+)    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   M   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER               C   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER_CHILD         MC  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBERSHIP_SALE      MS  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM              I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  EM.COMP_CD      = EP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_NO     = EP.ENTRY_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_SEQ    = EP.ENTRY_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.PROGRAM_SEQ  = EP.PROGRAM_SEQ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.PROGRAM_ID   = EP.PROGRAM_ID ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MBS_NO       = EP.MBS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.CERT_NO      = EP.CERT_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = ED.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_NO     = ED.ENTRY_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_SEQ    = ED.ENTRY_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = EH.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_NO     = EH.ENTRY_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.PROGRAM_ID   = M.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MBS_NO       = M.MBS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MEMBER_NO    = C.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = MC.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MEMBER_NO    = MC.MEMBER_NO(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.CHILD_NO     = MC.CHILD_NO(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = MS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.PROGRAM_ID   = MS.PROGRAM_ID ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.MBS_NO       = MS.MBS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.CERT_NO      = MS.CERT_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.COMP_CD      = I.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.MATL_ITEM_CD = I.ITEM_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.ENTRY_DT     BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EH.USE_YN       = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EP.USE_YN       = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  EM.USE_YN       = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MBS_DIV     IS NULL OR MS.MBS_DIV   = :PSV_MBS_DIV)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CHARGE_YN   IS NULL OR MS.CHARGE_YN = :PSV_CHARGE_YN) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_TXT  IS NULL OR (EP.MEMBER_NO LIKE '%'||:PSV_MEMBER_TXT||'%' OR DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM))  LIKE '%'||:PSV_MEMBER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CHILD_TXT   IS NULL OR (EP.CHILD_NO  LIKE '%'||:PSV_CHILD_TXT||'%'  OR DECRYPT(MC.CHILD_NM) LIKE '%'||:PSV_CHILD_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_PROGRAM_TXT IS NULL OR (EP.PROGRAM_ID LIKE '%'||:PSV_PROGRAM_TXT||'%' OR M.PROGRAM_NM LIKE '%'||:PSV_PROGRAM_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY EM.MBS_NO    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EM.ENTRY_NO  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EM.ENTRY_SEQ    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EM.PROGRAM_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EP.ENTRY_FTM    ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MBS_DIV, PSV_MBS_DIV, PSV_CHARGE_YN, PSV_CHARGE_YN, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_CHILD_TXT, PSV_CHILD_TXT, PSV_CHILD_TXT, PSV_PROGRAM_TXT, PSV_PROGRAM_TXT, PSV_PROGRAM_TXT;
     
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
    
END PKG_SALE1240;

/
