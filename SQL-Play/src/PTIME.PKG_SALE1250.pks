CREATE OR REPLACE PACKAGE       PKG_SALE1250 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1250
   --  Description      : ȸ���� ȯ�ҳ���
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_TAB01
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    );
    
    PROCEDURE SP_TAB02
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    );
    
END PKG_SALE1250;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1250 AS

    PROCEDURE SP_TAB01
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01     ȸ���� ȯ�ҳ���
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-02         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-06-02
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  SH.PROGRAM_ID   AS PROGRAM_ID   ]'      -- ���α׷�ID
        ||CHR(13)||CHR(10)||Q'[      ,  M.PROGRAM_NM    ]'                      -- ���α׷���
        ||CHR(13)||CHR(10)||Q'[      ,  M.BASE_USE_TM   ]'                      -- �⺻�̿�ð�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.ENTR_PRC     ]'                      -- 1ȸ ������
        ||CHR(13)||CHR(10)||Q'[      ,  SH.MBS_NO       ]'                      -- ȸ���ǹ�ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_NM        ]'                      -- ȸ���Ǹ�
        ||CHR(13)||CHR(10)||Q'[      ,  REPLACE(SH.CERT_NO, SUBSTR(SH.CERT_NO, 9, 5), '*****') AS CERT_NO ]'  -- ������ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_DIV       ]'                      -- ȸ��������
        ||CHR(13)||CHR(10)||Q'[      ,  M.CHARGE_YN     ]'                      -- �����󱸺�
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_BRAND_CD    AS BRAND_CD ]'      -- ���������ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM      ]'                      -- ����������
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_STOR_CD     AS STOR_CD  ]'      -- �����ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM       ]'                      -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  SH.APPR_DT      ]'                      -- ȯ������
        ||CHR(13)||CHR(10)||Q'[      ,  SH.APPR_TM      ]'                      -- ȯ�ҽð�
        ||CHR(13)||CHR(10)||Q'[      ,  SH.MEMBER_NO    ]'                      -- ����ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM)) AS MEMBER_NM    ]'  -- ����
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(MS.MOBILE)) AS MOBILE   ]'  -- �޴�����ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  SH.GRD_AMT  AS REFUND_AMT   ]'      -- ȯ�ұݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.REFUND_YN    ]'                      -- ȯ�ҽ��ο���
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(MS.REFUND_REQ_DT, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS')  AS REFUND_REQ_DT   ]'  -- ȯ�ҽ�û�Ͻ�
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(MS.REFUND_APPR_DT, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS') AS REFUND_APPR_DT  ]'  -- ȯ�ҽ����Ͻ�
        ||CHR(13)||CHR(10)||Q'[      ,  HU.USER_NM  AS REFUND_USER_NM       ]'  -- ȯ�ҽ��δ����
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_FDT     ]'                      -- �Ǹ�����
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_TDT     ]'                      -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  MS.SALE_AMT     ]'                      -- �Ǹűݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.DC_AMT       ]'                      -- ���αݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.GRD_AMT      ]'                      -- �����ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN MS.MBS_DIV = '1' THEN MS.OFFER_TM ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '2' THEN MS.OFFER_CNT]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '3' THEN MS.OFFER_AMT]'
        ||CHR(13)||CHR(10)||Q'[         END             AS OFFER            ]'  -- ����
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN MS.MBS_DIV = '1' THEN MS.OFFER_TM  - MS.USE_TM    ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '2' THEN MS.OFFER_CNT - MS.USE_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '3' THEN MS.OFFER_AMT - MS.USE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[         END             AS REST             ]'  -- �ܿ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_MCNT - MS.USE_MCNT AS REST_MCNT    ]'  -- �ܿ�[����]
        ||CHR(13)||CHR(10)||Q'[      ,  MS.ENTR_PRC     ]'                      -- �����
        ||CHR(13)||CHR(10)||Q'[   FROM  CS_MEMBERSHIP_SALE_HIS  SH          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE                 S           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  P.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  P.PROGRAM_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  P.BASE_USE_TM   ]'
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
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER               C           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  U.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.USER_ID               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, U.USER_NM)   AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  HQ_USER         U       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE      L       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(U.USER_ID, 15, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'HQ_USER'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[         )   HU                              ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SH.COMP_CD          = MS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.PROGRAM_ID       = MS.PROGRAM_ID ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.MBS_NO           = MS.MBS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.CERT_NO          = MS.CERT_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD          = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_BRAND_CD    = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_STOR_CD     = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD          = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.PROGRAM_ID       = M.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.MBS_NO           = M.MBS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD          = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.MEMBER_NO        = C.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.COMP_CD          = HU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.REFUND_USER      = HU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD          = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_USE_DIV     = '1'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DIV         = '2'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.MBS_STAT         = '92'          ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.APPR_DT          BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MBS_DIV    IS NULL OR SH.MBS_DIV   = :PSV_MBS_DIV)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CHARGE_YN  IS NULL OR MS.CHARGE_YN = :PSV_CHARGE_YN) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_TXT IS NULL OR (SH.MEMBER_NO LIKE '%'||:PSV_MEMBER_TXT||'%' OR DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM))  LIKE '%'||:PSV_MEMBER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SH.APPR_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.APPR_TM          ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MBS_DIV, PSV_MBS_DIV, PSV_CHARGE_YN, PSV_CHARGE_YN, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MEMBER_TXT;
     
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
    
    PROCEDURE SP_TAB02
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     ȸ���� ȯ�ҿ�û����
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-02         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-06-02
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  MS.COMP_CD      ]'                      -- ȸ���ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  REPLACE(MS.CERT_NO, SUBSTR(MS.CERT_NO, 9, 5), '*****') AS CERT_NO_MASK ]'  -- ������ȣ(*ó��)
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_NO      ]'                      -- ������ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  MS.PROGRAM_ID   ]'                      -- ���α׷�ID
        ||CHR(13)||CHR(10)||Q'[      ,  M.PROGRAM_NM    ]'                      -- ���α׷���
        ||CHR(13)||CHR(10)||Q'[      ,  M.BASE_USE_TM   ]'                      -- �⺻�̿�ð�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.ENTR_PRC     ]'                      -- 1ȸ ������
        ||CHR(13)||CHR(10)||Q'[      ,  MS.MBS_NO       ]'                      -- ȸ���ǹ�ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_NM        ]'                      -- ȸ���Ǹ�
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_DIV       ]'                      -- ȸ��������
        ||CHR(13)||CHR(10)||Q'[      ,  M.CHARGE_YN     ]'                      -- �����󱸺�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.SALE_BRAND_CD    AS BRAND_CD ]'      -- ���������ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM      ]'                      -- ����������
        ||CHR(13)||CHR(10)||Q'[      ,  MS.SALE_STOR_CD     AS STOR_CD  ]'      -- �����ڵ�
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM       ]'                      -- ������
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(MS.REFUND_REQ_DT, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS')  AS REFUND_REQ_DT   ]'  -- ȯ�ҽ�û�Ͻ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.MEMBER_NO    ]'                      -- ����ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM)) AS MEMBER_NM    ]'  -- ����
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(MS.MOBILE)) AS MOBILE   ]'  -- �޴�����ȣ
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN MS.MBS_DIV = '1' THEN     ]'      -- �ð����� ȯ�ұݾ� ���
        ||CHR(13)||CHR(10)||Q'[                                         CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / M.BASE_USE_TM)), -2) <= 0 THEN 0   ]'  -- ���ð��ݾ��� ���űݾ��� �ʰ��ϴ� ��� ȯ�ұݾ��� 0
        ||CHR(13)||CHR(10)||Q'[                                              ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / M.BASE_USE_TM)), -2)               ]'  -- ȯ�ұݾ� 10������ ����
        ||CHR(13)||CHR(10)||Q'[                                         END ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '2' THEN     ]'      -- Ƚ������ ȯ�ұݾ� ���
        ||CHR(13)||CHR(10)||Q'[                                         CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2) <= 0THEN 0                     ]'  -- ���Ƚ���ݾ��� ���űݾ��� �ʰ��ϴ� ��� ȯ�ұݾ��� 0
        ||CHR(13)||CHR(10)||Q'[                                              ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2)                                ]'  -- ȯ�ұݾ� 10������ ����
        ||CHR(13)||CHR(10)||Q'[                                         END ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '3' THEN     ]'      -- �ݾױ��� ȯ�ұݾ� ���
        ||CHR(13)||CHR(10)||Q'[                                         CASE WHEN TRUNC(MS.GRD_AMT - MS.USE_AMT, -2) <= 0 THEN 0                                    ]'  -- ���ݾ��� ���űݾ��� �ʰ��ϴ� ��� ȯ�ұݾ��� 0
        ||CHR(13)||CHR(10)||Q'[                                              ELSE TRUNC(MS.GRD_AMT - MS.USE_AMT, -2)                                                ]'  -- ȯ�ұݾ� 10������ ����
        ||CHR(13)||CHR(10)||Q'[                                         END ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE 0                         ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS REFUND_AMT   ]'  -- ȯ�ұݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_FDT     ]'                      -- �Ǹ�����
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_TDT     ]'                      -- ��������
        ||CHR(13)||CHR(10)||Q'[      ,  MS.SALE_AMT     ]'                      -- �Ǹűݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.DC_AMT       ]'                      -- ���αݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.GRD_AMT      ]'                      -- �����ݾ�
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN MS.MBS_DIV = '1' THEN MS.OFFER_TM ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '2' THEN MS.OFFER_CNT]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '3' THEN MS.OFFER_AMT]'
        ||CHR(13)||CHR(10)||Q'[         END             AS OFFER            ]'  -- ����
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN MS.MBS_DIV = '1' THEN MS.OFFER_TM  - MS.USE_TM    ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '2' THEN MS.OFFER_CNT - MS.USE_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '3' THEN MS.OFFER_AMT - MS.USE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[         END             AS REST             ]'  -- �ܿ�
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_MCNT - MS.USE_MCNT AS REST_MCNT    ]'  -- �ܿ�[����]
        ||CHR(13)||CHR(10)||Q'[      ,  MS.ENTR_PRC     ]'                      -- �����
        ||CHR(13)||CHR(10)||Q'[      ,  MS.REFUND_YN    ]'                      -- ȯ�ҽ��ο���
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(MS.REFUND_APPR_DT, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS')  AS REFUND_APPR_DT ]'  -- ȯ�ҽ����Ͻ�
        ||CHR(13)||CHR(10)||Q'[      ,  HU.USER_NM  AS REFUND_USER_NM       ]'  -- ȯ�ҽ��δ����
        ||CHR(13)||CHR(10)||Q'[   FROM  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE                 S           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  P.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  P.PROGRAM_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  P.BASE_USE_TM   ]'
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
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER               C           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  U.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.USER_ID               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, U.USER_NM)   AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  HQ_USER         U       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE      L       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(U.USER_ID, 15, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'HQ_USER'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'USER_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[         )   HU                              ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  MS.COMP_CD          = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.SALE_BRAND_CD    = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.SALE_STOR_CD     = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.COMP_CD          = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.PROGRAM_ID       = M.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.MBS_NO           = M.MBS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.COMP_CD          = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.MEMBER_NO        = C.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.COMP_CD          = HU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.REFUND_USER      = HU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.COMP_CD          = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.MBS_STAT         IN ('91', '93') ]'
        ||CHR(13)||CHR(10)||Q'[    AND  TO_CHAR(TO_DATE(MS.REFUND_REQ_DT, 'YYYYMMDDHH24MISS'), 'YYYYMMDD') BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MBS_DIV    IS NULL OR MS.MBS_DIV   = :PSV_MBS_DIV)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CHARGE_YN  IS NULL OR MS.CHARGE_YN = :PSV_CHARGE_YN) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_TXT IS NULL OR (MS.MEMBER_NO LIKE '%'||:PSV_MEMBER_TXT||'%' OR DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM))  LIKE '%'||:PSV_MEMBER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY MS.REFUND_REQ_DT    ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MBS_DIV, PSV_MBS_DIV, PSV_CHARGE_YN, PSV_CHARGE_YN, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MEMBER_TXT;
     
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
    
END PKG_SALE1250;

/
