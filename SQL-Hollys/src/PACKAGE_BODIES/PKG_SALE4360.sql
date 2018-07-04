--------------------------------------------------------
--  DDL for Package Body PKG_SALE4360
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4360" AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE4360
   --  Description      : 신용카드 승인조회
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
        PSV_APRV_TP     IN  VARCHAR2 ,                -- 공통코드 00506 -> 승인기준 : 1.영업일, 2.승인일
        PSV_CARD_CD     IN  VARCHAR2 ,                -- 카드사 코드
        PSV_VAN_CD      IN  VARCHAR2 ,                -- VAN사 코드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     신용카드 승인조회
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-18         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-18
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
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

    ls_sql_cm_00435 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_00945 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_00505 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_00440 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_00550 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00435') ;
        ls_sql_cm_00945 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00945') ;
        ls_sql_cm_00505 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00505') ;
        ls_sql_cm_00440 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00440') ;
        ls_sql_cm_00550 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00550') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  A.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.BUSI_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.POS_NO                    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.BILL_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_DT    AS   APPR_DT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_TM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_AMT * DECODE(A.SALE_DIV, '1', 1, -1) AS APPR_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(L.LANG_NM, C.CARD_NM)                   AS CARD_NM  ]'  -- 매입사명
        ||CHR(13)||CHR(10)||Q'[      ,  A.CARD_NM          AS ISSUE_NM  ]'                          -- 발급사명
        ||CHR(13)||CHR(10)||Q'[      ,  T.CAT_ID           AS CAT_ID    ]'                          -- 가맹점번호
        ||CHR(13)||CHR(10)||Q'[      ,  A.CARD_NO                   ]'                              -- 카드번호
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(A.APPR_DIV, '@', CL3.CODE_NM, A.APPR_NO) AS APPR_NO  ]' -- 승인번호
        ||CHR(13)||CHR(10)||Q'[      ,  CL1.CODE_NM AS SALE_DIV_NM  ]'                               -- 판매구분
        ||CHR(13)||CHR(10)||Q'[      ,  CL3.CODE_NM AS APPR_DIV_NM  ]'                               -- 승인구분
        --||CHR(13)||CHR(10)||Q'[      ,  NVL2(H.CANCEL_DT, FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR_N'), FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR')) AS  APPR_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  H.CANCEL_DT        AS CANCEL_DT ]'                           -- 취소일자  
        ||CHR(13)||CHR(10)||Q'[      ,  H.CANCEL_TM        AS CANCEL_TM ]'                           -- 취소시간 
        ||CHR(13)||CHR(10)||Q'[      ,  CL4.CODE_NM AS VAN_NM       ]'                                -- VAN
        ||CHR(13)||CHR(10)||Q'[   FROM  CARD_LOG A, S_STORE S, CARD C, CATID T,  ]'
        ||CHR(13)||CHR(10)||            ls_sql_cm_00435 || Q'[ CL1, ]'
        ||CHR(13)||CHR(10)||            ls_sql_cm_00945 || Q'[ CL2, ]'
        ||CHR(13)||CHR(10)||            ls_sql_cm_00505 || Q'[ CL3, ]'
        ||CHR(13)||CHR(10)||            ls_sql_cm_00550 || Q'[ CL4, ]'
        ||CHR(13)||CHR(10)||Q'[         (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_NM     ]'
        ||CHR(13)||CHR(10)||q'[               FROM  LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  TABLE_NM    = 'CARD'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  COL_NM      = 'CARD_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   L   ]'
        ||CHR(13)||CHR(10)||Q'[      ,(                                        ]'
        ||CHR(13)||CHR(10)||Q'[      SELECT  /*+ INDEX(H IDX01_SALE_HD) */    ]'
        ||CHR(13)||CHR(10)||Q'[              H.SALE_DT         AS CANCEL_DT   ]'
        ||CHR(13)||CHR(10)||Q'[           ,  H.SALE_TM         AS CANCEL_TM   ]'
        ||CHR(13)||CHR(10)||Q'[           ,  M.COMP_CD         AS COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[           ,  M.BRAND_CD        AS BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[           ,  M.STOR_CD         AS STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[           ,  M.POS_NO          AS POS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[           ,  H.VOID_BEFORE_NO  AS BILL_NO     ]'
        ||CHR(13)||CHR(10)||Q'[           ,  H.VOID_BEFORE_DT  AS SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      FROM    MOBILE_LOG M, SALE_HD H, S_STORE S ]'
        ||CHR(13)||CHR(10)||Q'[      WHERE   M.COMP_CD  = S.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.BRAND_CD = S.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.STOR_CD  = S.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.COMP_CD  = H.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.BRAND_CD = H.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.STOR_CD  = H.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.POS_NO   = H.POS_NO            ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.BILL_NO  = H.VOID_BEFORE_NO    ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.SALE_DT  = H.VOID_BEFORE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.COMP_CD  = :PSV_COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.MOBILE_DIV = '62'              ]'
        ||CHR(13)||CHR(10)||Q'[      AND     M.USE_YN   = 'Y'                 ]'
        ||CHR(13)||CHR(10)||Q'[      )    H                                   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  A.COMP_CD  = S.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD = S.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD  = S.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD  = C.COMP_CD  (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.MAEIP_CD = C.CARD_CD  (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.VAN_CD   = C.VAN_CD   (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.SALE_DIV = CL1.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.RSV_DIV  = CL2.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.APPR_DIV = CL3.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.VAN_CD   = CL4.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD  = H.COMP_CD  (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD = H.BRAND_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD  = H.STOR_CD  (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.POS_NO   = H.POS_NO   (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BILL_NO  = H.BILL_NO  (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.SALE_DT  = H.SALE_DT  (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD  = T.COMP_CD  (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD = T.BRAND_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD  = T.STOR_CD  (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.VAN_CD   = T.VAN_CD   (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  L.COMP_CD(+) = C.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  L.PK_COL(+)= LPAD(C.VAN_CD, 2, ' ')||LPAD(C.CARD_CD, 10, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CARD_CD  IS NULL OR C.CARD_CD  = :PSV_CARD_CD)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_VAN_CD IS NULL OR A.VAN_CD = :PSV_VAN_CD) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.USE_YN    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DECODE(:PSV_APRV_TP, '1', A.SALE_DT, A.APPR_DT) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY A.COMP_CD, A.BRAND_CD, A.STOR_CD,  A.SALE_DT ASC, A.POS_NO ASC, A.BILL_NO DESC   ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_CARD_CD, PSV_CARD_CD, 
                         PSV_VAN_CD,  PSV_VAN_CD, PSV_APRV_TP, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE4360;

/
