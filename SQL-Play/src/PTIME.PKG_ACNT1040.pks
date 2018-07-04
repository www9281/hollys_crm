CREATE OR REPLACE PACKAGE       PKG_ACNT1040 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ACNT1040
    --  Description      : ���������� ��볻�� ����
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    
     PROCEDURE SEARCH
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
        PSV_EVID_DOC    IN  VARCHAR2 ,                -- ��������
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    );
    
     PROCEDURE SAVE
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_PRC_DT      IN  VARCHAR2 , 
        PSV_BRAND_CD    IN  VARCHAR2 ,
        PSV_STOR_CD     IN  VARCHAR2 ,                  --
        PSV_POS_NO      IN  VARCHAR2 ,
        PSV_ETC_DIV     IN  VARCHAR2 ,        
        PSV_SEQ         IN  VARCHAR2 ,                  --
        PSV_ETC_AMT_HQ  IN  VARCHAR2 ,
        PSV_REMARKS     IN  VARCHAR2 ,
        PSV_DEL_YN      IN  VARCHAR2 ,
        PSV_CONFIRM_CHK IN  VARCHAR2 ,
        PSV_REJECT_CHK  IN  VARCHAR2 ,
        PSV_CANCEL_CHK  IN  VARCHAR2 ,
        PSV_USER_ID     IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                    -- ó��Message
    );
    
    PROCEDURE NEW
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,
        PSV_PRC_DT      IN  VARCHAR2 ,
        PSV_BRAND_CD    IN  VARCHAR2 ,
        PSV_STOR_CD     IN  VARCHAR2 ,
        PSV_SV_USER_ID  IN  VARCHAR2 ,
        PSV_ETC_DIV     IN  VARCHAR2 ,
        PSV_ETC_CD      IN  VARCHAR2 ,
        PSV_ETC_NM      IN  VARCHAR2 ,
        PSV_ETC_AMT     IN  VARCHAR2 ,
        PSV_ETC_AMT_HQ  IN  VARCHAR2 ,
        PSV_EVID_DOC    IN  VARCHAR2 ,
        PSV_USER_ID     IN  VARCHAR2 ,
        PSV_CONFIRM_YN  IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                    -- ó��Message
    );
                                    
    
END PKG_ACNT1040;

/

CREATE OR REPLACE PACKAGE BODY       PKG_ACNT1040 AS

    
    PROCEDURE SEARCH
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
        PSV_EVID_DOC    IN  VARCHAR2 ,                -- ��������
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                  -- ó��Message
    )
    IS
    /******************************************************************************
       NAME:       SEARCH     ���� ������ �Ա� Ȯ��   
  
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
       OBJECT NAME:     SEARCH
       SYSDATE:         2017-08-08
       USERNAME:
       TABLE NAME:
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
        
        /* MAIN SQL */
        ls_sql_main := ''
        
        ||CHR(13)||CHR(10)||Q'[ SELECT A1.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.PRC_DT        ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_CD||A1.RMK_SEQ            AS ETC_CD ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A4.ETC_NM||'('||A5.RMK_NM||')'   AS ETC_NM ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.RMK_SEQ       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.POS_NO        ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.SEQ           ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_AMT_HQ    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_AMT - A1.ETC_AMT_HQ       AS ETC_AMT_DIFF ]'
        ||CHR(13)||CHR(10)||Q'[    ,   GET_COMMON_CODE_NM(A1.COMP_CD, '02010', A1.EVID_DOC, :PSV_LANG_CD) AS EVID_DOC ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.USER_ID       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A3.USER_NM       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.CONFIRM_YN    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   CASE WHEN A1.CONFIRM_YN = 'Y' THEN FC_GET_WORDPACK(A1.COMP_CD, :PSV_LANG_CD, 'CONFIRM_Y') ]'
        ||CHR(13)||CHR(10)||Q'[             WHEN A1.CONFIRM_YN = 'N' THEN FC_GET_WORDPACK(A1.COMP_CD, :PSV_LANG_CD, 'CONFIRM_N') ]'
        ||CHR(13)||CHR(10)||Q'[             WHEN A1.CONFIRM_YN = 'R' THEN FC_GET_WORDPACK(A1.COMP_CD, :PSV_LANG_CD, 'REJECT_Y' ) ]'
        ||CHR(13)||CHR(10)||Q'[        END CONFIRM_YN_NM]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.DEL_YN        ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   STORE_ETC_AMT  A1    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   S_STORE        A2    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   STORE_USER     A3    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ACC_MST        A4    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ACC_RMK        A5    ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD    = A2.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A2.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A2.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A3.COMP_CD(+)]'        
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A3.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A3.STOR_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.USER_ID    = A3.USER_ID(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A4.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ETC_CD     = A4.ETC_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.STOR_TP    = A4.STOR_TP   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A5.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ETC_CD     = A5.ETC_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.RMK_SEQ    = A5.RMK_SEQ   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.STOR_TP    = A5.STOR_TP   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.PRC_DT     BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[ AND   (:PSV_EVID_DOC IS NULL OR A1.EVID_DOC = :PSV_EVID_DOC) ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ETC_DIV    = '02'         ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.DEL_YN     = 'N'          ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY A1.PRC_DT, A1.BRAND_CD, A1.STOR_CD, A1.ETC_CD ]'
        ;
        
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_LANG_CD, PSV_LANG_CD, PSV_LANG_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_EVID_DOC, PSV_EVID_DOC;
                       
     
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
    
    PROCEDURE SAVE
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- ȸ���ڵ�
        PSV_PRC_DT      IN  VARCHAR2 , 
        PSV_BRAND_CD    IN  VARCHAR2 ,
        PSV_STOR_CD     IN  VARCHAR2 ,                  --
        PSV_POS_NO      IN  VARCHAR2 ,
        PSV_ETC_DIV     IN  VARCHAR2 ,        
        PSV_SEQ         IN  VARCHAR2 ,                  --
        PSV_ETC_AMT_HQ  IN  VARCHAR2 ,
        PSV_REMARKS     IN  VARCHAR2 ,
        PSV_DEL_YN      IN  VARCHAR2 ,
        PSV_CONFIRM_CHK IN  VARCHAR2 ,
        PSV_REJECT_CHK  IN  VARCHAR2 ,
        PSV_CANCEL_CHK  IN  VARCHAR2 ,
        PSV_USER_ID     IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                    -- ó��Message
    )
    IS
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    ps_rtn_cd     VARCHAR2(7);
    ps_rtn_msg    VARCHAR2(500) ;
    
    
    V_DATE_CHECK  VARCHAR2(1) ;
    
    v_confirm_yn   STORE_ETC_AMT.CONFIRM_YN%TYPE;
    
    ERR_HANDLER      EXCEPTION;
    ERR_SKIP_HANDLER EXCEPTION;
    
    BEGIN
        
        BEGIN
        
            SELECT NVL(CONFIRM_YN, 'N')
            INTO   v_confirm_yn
            FROM   STORE_ETC_AMT
            WHERE  COMP_CD  = PSV_COMP_CD
            AND    PRC_DT   = PSV_PRC_DT
            AND    BRAND_CD = PSV_BRAND_CD
            AND    STOR_CD  = PSV_STOR_CD
            AND    POS_NO   = PSV_POS_NO
            AND    ETC_DIV  = PSV_ETC_DIV
            AND    SEQ      = PSV_SEQ
            ;
        
        EXCEPTION 
            WHEN OTHERS THEN
                ls_err_cd     := '-1' ;
                ls_err_msg    := '�����͸� ã���� �����ϴ�.';
                
                RAISE ERR_HANDLER;
                
        END;
        
        
        -- Ȯ��ó��, ���ó�� ���� ���� ����
        IF( ( PSV_CONFIRM_CHK = '0' ) AND( PSV_REJECT_CHK = '0' ) AND ( PSV_CANCEL_CHK = '0' )  ) THEN
            IF( v_confirm_yn = 'Y' ) THEN
                ls_err_cd     := '-1' ;
                ls_err_msg    := '�̹� Ȯ��ó���� �����Ͱ� �ֽ��ϴ�. ��ȸ�� ����Ͻʽÿ�.';
                
                RAISE ERR_HANDLER;
            ELSE
                UPDATE STORE_ETC_AMT
                SET    ETC_AMT_HQ = PSV_ETC_AMT_HQ
                   ,   DEL_YN     = PSV_DEL_YN
                   ,   REMARKS    = PSV_REMARKS
                   ,   UPD_DT     = SYSDATE
                   ,   UPD_USER   = PSV_USER_ID
                WHERE  COMP_CD    = PSV_COMP_CD
                AND    PRC_DT     = PSV_PRC_DT
                AND    BRAND_CD   = PSV_BRAND_CD
                AND    STOR_CD    = PSV_STOR_CD
                AND    POS_NO     = PSV_POS_NO
                AND    ETC_DIV    = PSV_ETC_DIV
                AND    SEQ        = PSV_SEQ  
                ;
            END IF;
        
        -- Ȯ��ó��/�ݷ�ó��
        ELSIF( ( PSV_CONFIRM_CHK = '1' OR PSV_REJECT_CHK = '1' ) AND ( PSV_CANCEL_CHK = '0' )  ) THEN
            IF( v_confirm_yn = 'Y' ) THEN
                ls_err_cd     := '-1' ;
                ls_err_msg    := '�̹� Ȯ��ó���� �����Ͱ� �ֽ��ϴ�. ��ȸ�� ����Ͻʽÿ�.';
                
                RAISE ERR_HANDLER;
            ELSE
                UPDATE STORE_ETC_AMT
                SET    ETC_AMT_HQ = PSV_ETC_AMT_HQ
                   ,   DEL_YN     = PSV_DEL_YN
                   ,   REMARKS    = PSV_REMARKS
                   ,   CONFIRM_YN = CASE WHEN PSV_CONFIRM_CHK = '1' THEN 'Y'
                                         WHEN PSV_REJECT_CHK  = '1' THEN 'R'
                                    END
                   ,   CONFIRM_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
                   ,   UPD_DT     = SYSDATE
                   ,   UPD_USER   = PSV_USER_ID
                WHERE  COMP_CD    = PSV_COMP_CD
                AND    PRC_DT     = PSV_PRC_DT
                AND    BRAND_CD   = PSV_BRAND_CD
                AND    STOR_CD    = PSV_STOR_CD
                AND    POS_NO     = PSV_POS_NO
                AND    ETC_DIV    = PSV_ETC_DIV
                AND    SEQ        = PSV_SEQ  
                ;
                
                BEGIN
                
                    SP_SET_STORE_ETC_YM( PSV_COMP_CD, SUBSTR( PSV_PRC_DT , 0,6) , PSV_BRAND_CD, PSV_STOR_CD,  ps_rtn_cd, ps_rtn_msg) ;
                    
                EXCEPTION 
                    WHEN OTHERS THEN
                        ls_err_cd     := '-1' ;
                        ls_err_msg    := 'SP_SET_STORE_ETC_YM ���ν��� ����';
                        
                        RAISE ERR_HANDLER;
                END;
                
                IF( ps_rtn_cd <> '0000' ) THEN
                    ls_err_cd     := '-1' ;
                    ls_err_msg    := ps_rtn_msg;
                        
                    RAISE ERR_HANDLER;
                END IF;
            END IF;
        -- ���ó��
        ELSIF( ( PSV_CONFIRM_CHK = '0' OR PSV_REJECT_CHK = '0') AND ( PSV_CANCEL_CHK = '1' )  ) THEN
            IF(v_confirm_yn = 'Y' OR v_confirm_yn = 'R') THEN
                UPDATE STORE_ETC_AMT
                SET    CONFIRM_YN = 'N'
                   ,   CONFIRM_DT = NULL
                   ,   UPD_DT     = SYSDATE
                   ,   UPD_USER   = PSV_USER_ID
                WHERE  COMP_CD    = PSV_COMP_CD
                AND    PRC_DT     = PSV_PRC_DT
                AND    BRAND_CD   = PSV_BRAND_CD
                AND    STOR_CD    = PSV_STOR_CD
                AND    POS_NO     = PSV_POS_NO
                AND    ETC_DIV    = PSV_ETC_DIV
                AND    SEQ        = PSV_SEQ
                ;
                
                BEGIN
                    SP_SET_STORE_ETC_YM( PSV_COMP_CD, SUBSTR( PSV_PRC_DT , 0,6) , PSV_BRAND_CD, PSV_STOR_CD,  ps_rtn_cd, ps_rtn_msg) ;
                EXCEPTION 
                    WHEN OTHERS THEN
                        ls_err_cd     := '-1' ;
                        ls_err_msg    := 'SP_SET_STORE_ETC_YM ���ν��� ����';
                        
                        RAISE ERR_HANDLER;
                END;
                
                IF( ps_rtn_cd <> '0000' ) THEN
                    ls_err_cd     := '-1' ;
                    ls_err_msg    := ps_rtn_msg;
                        
                    RAISE ERR_HANDLER;
                END IF;    
            ELSE
                ls_err_cd     := '-1' ;
                ls_err_msg    := '�̹� Ȯ����ҵ� �����Ͱ� �ֽ��ϴ�. ��ȸ�� ����Ͻʽÿ�.';
                
                RAISE ERR_HANDLER;
            END IF;
        ELSE 
            ls_err_cd     := '-1' ;
            ls_err_msg    := '�߸��� ó������ �����Դϴ�.';
                
            RAISE ERR_HANDLER;
        END IF;    
        
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
    
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
    
    PROCEDURE NEW
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,
        PSV_PRC_DT      IN  VARCHAR2 ,
        PSV_BRAND_CD    IN  VARCHAR2 ,
        PSV_STOR_CD     IN  VARCHAR2 ,
        PSV_SV_USER_ID  IN  VARCHAR2 ,
        PSV_ETC_DIV     IN  VARCHAR2 ,
        PSV_ETC_CD      IN  VARCHAR2 ,
        PSV_ETC_NM      IN  VARCHAR2 ,
        PSV_ETC_AMT     IN  VARCHAR2 ,
        PSV_ETC_AMT_HQ  IN  VARCHAR2 ,
        PSV_EVID_DOC    IN  VARCHAR2 ,
        PSV_USER_ID     IN  VARCHAR2 ,
        PSV_CONFIRM_YN  IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- ó���ڵ�
        PR_RTN_MSG      OUT VARCHAR2                    -- ó��Message
    )
    IS
    
    BEGIN
    
        INSERT INTO STORE_ETC_AMT(
              COMP_CD
            , PRC_DT
            , BRAND_CD
            , STOR_CD
            , POS_NO
            , ETC_DIV
            , SEQ
            , ETC_CD
            , ETC_AMT
            , ETC_AMT_HQ
            , CARD_AMT
            , CUST_ID
            , USER_ID
            , ETC_TP
            , ETC_TM
            , RMK_SEQ
            , EVID_DOC
            , ETC_DESC
            , PURCHASE_CD
            , STOR_PAY_DIV
            , APPR_NO
            , APPR_DT
            , APPR_TM
            , HQ_USER_ID
            , BANK_NM
            , ACC_NO
            , ACC_NM
            , INPUT_TP
            , SEQ_EXCEL
            , REMARKS
            , CONFIRM_YN
            , CONFIRM_DT
            , DEL_YN
            , INST_DT
            , INST_USER
            , UPD_DT
            , UPD_USER
            , SV_USER_ID
            , SV_CONF_YN
            , SV_CONF_DT
        )VALUES(
              PSV_COMP_CD
            , PSV_PRC_DT
            , PSV_BRAND_CD
            , PSV_STOR_CD
            , NULL
            , NULL
            , NULL ----XXXXX
            , PSV_ETC_CD
            , PSV_ETC_AMT
            , PSV_ETC_AMT_HQ
            , NULL
            , NULL
            , PSV_USER_ID
            , NULL
            , NULL
            , NULL ---XX
            , PSV_EVID_DOC
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , PSV_USER_ID
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , 'N'
            , SYSDATE
            , PSV_USER_ID
            , NULL
            , NULL
            , PSV_SV_USER_ID
            , NULL
            , NULL
        );
    
    END;
    
END PKG_ACNT1040;

/
