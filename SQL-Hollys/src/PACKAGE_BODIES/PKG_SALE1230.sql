--------------------------------------------------------
--  DDL for Package Body PKG_SALE1230
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1230" AS

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
        PSV_MBS_DIV     IN  VARCHAR2 ,                -- 회원권종류
        PSV_CHARGE_YN   IN  VARCHAR2 ,                -- 유무상구분
        PSV_SALE_CHAN   IN  VARCHAR2 ,                -- 유무상구분
        PSV_MEMBER_TXT  IN  VARCHAR2 ,                -- 회원번호/명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     회원권 판매내역
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-05-30         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-05-30
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  SH.SALE_BRAND_CD        AS BRAND_CD ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM                          ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_STOR_CD         AS STOR_CD  ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM                           ]'  -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  SH.APPR_DT                          ]'  -- 승인일자
        ||CHR(13)||CHR(10)||Q'[      ,  SH.APPR_TM                          ]'  -- 승인시간
        ||CHR(13)||CHR(10)||Q'[      ,  SH.MBS_NO                           ]'  -- 회원권번호
        ||CHR(13)||CHR(10)||Q'[      ,  M.MBS_NM                            ]'  -- 회원권명
        ||CHR(13)||CHR(10)||Q'[      ,  REPLACE(SH.CERT_NO, SUBSTR(SH.CERT_NO, 9, 5), '*****') AS CERT_NO ]'  -- 인증번호
        ||CHR(13)||CHR(10)||Q'[      ,  SH.MBS_DIV                          ]'  -- 회원권종류
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CHARGE_YN                        ]'  -- 유무상구분
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_TM                         ]'  -- 제공시간
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_TM                           ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_CNT                        ]'  -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_CNT                          ]'  -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_AMT                        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_AMT                          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_AMT - MS.USE_AMT   AS REST_AMT ]'  -- 잔여금액
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_MCNT                       ]'  -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_MCNT                         ]'  -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  SH.MEMBER_NO                        ]'  -- 고객번호
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM)) AS MEMBER_NM    ]'  -- 고객명
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(MS.MOBILE)) AS MOBILE   ]'  -- 휴대폰번호
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DIV                         ]'  -- 판매구분
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SH.SALE_DIV = '3' THEN MS.OFFER_AMT - SH.USE_AMT ELSE SH.SALE_AMT END AS SALE_AMT]'  -- 판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  SH.DC_AMT                           ]'  -- 할인금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SH.SALE_DIV = '3' THEN MS.OFFER_AMT - SH.USE_AMT ELSE SH.GRD_AMT  END AS GRD_AMT ]'  -- 결제금액
        ||CHR(13)||CHR(10)||Q'[      ,  D.DC_NM                 AS DC_DIV_NM]'  -- 할인종류
        ||CHR(13)||CHR(10)||Q'[   FROM  CS_MEMBERSHIP_SALE_HIS  SH          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE                 S           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  M.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.PROGRAM_ID            ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MBS_NO                ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, M.MBS_NM) AS MBS_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  CS_MEMBERSHIP   M       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE      L       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = M.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(M.PROGRAM_ID, 30, ' ')||LPAD(M.MBS_NO, 30, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD       = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'CS_MEMBERSHIP'   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'MBS_NM'          ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[         )   M                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER               C           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_DT                 SD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  D.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D.BRAND_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D.DC_DIV                ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, D.DC_NM) AS DC_NM    ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  DC          D           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L           ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = D.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(D.BRAND_CD, 4, ' ')||LPAD(D.DC_DIV, 5, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  D.COMP_CD       = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.TABLE_NM(+)   = 'DC'  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.COL_NM(+)     = 'DC_NM'   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'   ]' 
        ||CHR(13)||CHR(10)||Q'[         )   D                               ]'
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
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD          = SD.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.APPR_DT          = SD.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_BRAND_CD    = SD.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_STOR_CD     = SD.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_POS_NO      = SD.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_BILL_NO     = SD.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_SEQ         = SD.SEQ(+)     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD          = D.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD         = CASE WHEN D.BRAND_CD = '0000' THEN SD.BRAND_CD ELSE D.BRAND_CD END]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.DC_DIV           = D.DC_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD          = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.MBS_STAT        != '99'          ]'
        ||CHR(13)||CHR(10)||Q'[    AND (SH.SALE_USE_DIV     = '1' OR (SH.SALE_USE_DIV = '2' AND SH.SALE_DIV = '3'))]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.APPR_DT          BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MBS_DIV    IS NULL OR SH.MBS_DIV   = :PSV_MBS_DIV)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CHARGE_YN  IS NULL OR MS.CHARGE_YN = :PSV_CHARGE_YN) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_SALE_CHAN  IS NULL OR :PSV_SALE_CHAN = (CASE WHEN SH.SALE_BILL_NO IS NULL THEN '02' ELSE '01' END))   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_TXT IS NULL OR (SH.MEMBER_NO LIKE '%'||:PSV_MEMBER_TXT||'%' OR DECRYPT(NVL(C.MEMBER_NM, C.ORG_NM))  LIKE '%'||:PSV_MEMBER_TXT||'%')) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SH.SALE_BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.APPR_DT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.APPR_TM          ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MBS_DIV, PSV_MBS_DIV, PSV_CHARGE_YN, PSV_CHARGE_YN, 
                         PSV_SALE_CHAN, PSV_SALE_CHAN, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MEMBER_TXT;

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

END PKG_SALE1230;

/
