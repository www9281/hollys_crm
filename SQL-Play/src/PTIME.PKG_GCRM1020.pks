CREATE OR REPLACE PACKAGE       PKG_GCRM1020 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_GCRM1020
   --  Description      : 회원권 환불내역
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_MBS_DIV     IN  VARCHAR2 ,                -- 회원권종류
        PSV_MBS_STAT    IN  VARCHAR2 ,                -- 회원권상태
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_MBS_DIV     IN  VARCHAR2 ,                -- 회원권종류
        PSV_MBS_STAT    IN  VARCHAR2 ,                -- 회원권상태
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_GCRM1020;

/

CREATE OR REPLACE PACKAGE BODY       PKG_GCRM1020 AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_MBS_DIV     IN  VARCHAR2 ,                -- 회원권종류
        PSV_MBS_STAT    IN  VARCHAR2 ,                -- 회원권상태
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01     회원권 환불내역
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
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
    
    ls_sql_cm_01870 VARCHAR2(32000) ; -- 공통코드
    ls_sql_cm_00315 VARCHAR2(32000) ; -- 공통코드
    
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
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_01870 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01870') ;
        ls_sql_cm_00315 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00315') ;
        -------------------------------------------------------------------------------
           
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[,W_MEM AS (             ]'                      
        ||CHR(13)||CHR(10)||Q'[     SELECT  MEM.COMP_CD     ]'                      -- 회사코드
        ||CHR(13)||CHR(10)||Q'[          ,  MEM.BRAND_CD    ]'                      -- 영업조직
        ||CHR(13)||CHR(10)||Q'[          ,  STO.BRAND_NM    ]'                      -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[          ,  MEM.STOR_CD     ]'                      -- 점포코드
        ||CHR(13)||CHR(10)||Q'[          ,  STO.STOR_NM     ]'                      -- 점포명칭
        ||CHR(13)||CHR(10)||Q'[          ,  MEM.MEMBER_NO   ]'                      -- 회원번호
        ||CHR(13)||CHR(10)||Q'[          ,  DECRYPT(MEM.MEMBER_NM) AS MEMBER_NM ]'  -- 회원명
        ||CHR(13)||CHR(10)||Q'[          ,  MEM.MEMBER_DIV  ]'                      -- 회원권종류
        ||CHR(13)||CHR(10)||Q'[          ,  CM1.CODE_NM AS MEMBER_DIV_NM        ]'  -- 회원권종류
        ||CHR(13)||CHR(10)||Q'[          ,  DECRYPT(MEM.ORG_NM)    AS ORG_NM    ]'  -- 단체명
        ||CHR(13)||CHR(10)||Q'[          ,  FN_GET_FORMAT_HP_NO(DECRYPT(MEM.MOBILE)) AS MOBILE   ]'  -- 연락처
        ||CHR(13)||CHR(10)||Q'[          ,  MEM.JOIN_DT     ]'                      -- 가입일자
        ||CHR(13)||CHR(10)||Q'[          ,  CHD.CHILD_NO    ]'                      -- 회원자녀
        ||CHR(13)||CHR(10)||Q'[          ,  DECRYPT(CHD.CHILD_NM) AS CHILD_NM   ]'  -- 회원자녀명
        ||CHR(13)||CHR(10)||Q'[          ,  CHD.SEX_DIV     ]'                      -- 성별
        ||CHR(13)||CHR(10)||Q'[          ,  CM2.CODE_NM AS SEX_DIV_NM           ]'  -- 성별
        ||CHR(13)||CHR(10)||Q'[          ,  CHD.BIRTH_DT    ]'                      -- 생일
        ||CHR(13)||CHR(10)||Q'[          ,  CHD.AGES        ]'                      -- 나이
        ||CHR(13)||CHR(10)||Q'[          ,  CHD.ANVS_DT     ]'                      -- 기념일
        ||CHR(13)||CHR(10)||Q'[     FROM    CS_MEMBER       MEM ]'
        ||CHR(13)||CHR(10)||Q'[          ,  CS_MEMBER_CHILD CHD ]'
        ||CHR(13)||CHR(10)||Q'[          ,  S_STORE         STO ]'
        ||CHR(13)||CHR(10)|| '           , ' || ls_sql_cm_01870 ||' CM1 '
        ||CHR(13)||CHR(10)|| '           , ' || ls_sql_cm_00315 ||' CM2 '
        ||CHR(13)||CHR(10)||Q'[     WHERE   MEM.COMP_CD   = CHD.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[     AND     MEM.MEMBER_NO = CHD.MEMBER_NO ]'
        ||CHR(13)||CHR(10)||Q'[     AND     MEM.COMP_CD   = STO.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[     AND     MEM.BRAND_CD  = STO.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND     MEM.STOR_CD   = STO.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[     AND     MEM.MEMBER_DIV= CM1.CODE_CD   ]'
        ||CHR(13)||CHR(10)||Q'[     AND     CHD.SEX_DIV   = CM2.CODE_CD   ]'
        ||CHR(13)||CHR(10)||Q'[     AND     MEM.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND     MEM.USE_YN    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[     AND     CHD.USE_YN    = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[  )                          ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT  V01.BRAND_CD        ]'                  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[      ,  V01.BRAND_NM        ]'                  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[      ,  V01.STOR_CD         ]'                  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  V01.STOR_NM         ]'                  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  V01.MEMBER_NO       ]'                  -- 점포명칭
        ||CHR(13)||CHR(10)||Q'[      ,  V01.MEMBER_NM       ]'                  -- 회원권명
        ||CHR(13)||CHR(10)||Q'[      ,  V01.MEMBER_DIV      ]'                  -- 회원권종류
        ||CHR(13)||CHR(10)||Q'[      ,  V01.MEMBER_DIV_NM   ]'                  -- 회원권종류
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(V01.ORG_NM, ' ') ORG_NM ]'          -- 단체명
        ||CHR(13)||CHR(10)||Q'[      ,  V01.MOBILE          ]'                  -- 연락처
        ||CHR(13)||CHR(10)||Q'[      ,  V01.JOIN_DT         ]'                  -- 가입일자
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN NVL(V02.MBS_STAT_CNT, 0) = 0 THEN 'N' ELSE 'Y' END AS MBS_POSS_YN]' -- 회원권 보유 유무
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CHILD_NO        ]'                  -- 회원자녀
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CHILD_NM        ]'                  -- 회원자녀명
        ||CHR(13)||CHR(10)||Q'[      ,  V01.SEX_DIV         ]'                  -- 성별
        ||CHR(13)||CHR(10)||Q'[      ,  V01.SEX_DIV_NM      ]'                  -- 성별
        ||CHR(13)||CHR(10)||Q'[      ,  V01.BIRTH_DT        ]'                  -- 생일
        ||CHR(13)||CHR(10)||Q'[      ,  V01.AGES            ]'                  -- 나이
        ||CHR(13)||CHR(10)||Q'[      ,  V01.ANVS_DT         ]'                  -- 기념일
        ||CHR(13)||CHR(10)||Q'[      ,  V03.LAST_VISIT_DT   ]'                  -- 최근 방문 일자
        ||CHR(13)||CHR(10)||Q'[ FROM    W_MEM       V01     ]'
        ||CHR(13)||CHR(10)||Q'[      , (                    ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  MEM.COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[               , MEM.MEMBER_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[               , COUNT(*) MBS_STAT_CNT           ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    CS_MEMBERSHIP_SALE CMS          ]'
        ||CHR(13)||CHR(10)||Q'[               , W_MEM              MEM          ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   MEM.COMP_CD   = CMS.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MEM.MEMBER_NO = CMS.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         AND     '10'          = CMS.MBS_STAT    ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP  BY                               ]'
        ||CHR(13)||CHR(10)||Q'[                 MEM.COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[               , MEM.MEMBER_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[        ) V02                                    ]'
        ||CHR(13)||CHR(10)||Q'[      , (                                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  MEM.COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[               , MEM.MEMBER_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[               , MEM.CHILD_NO                    ]'
        ||CHR(13)||CHR(10)||Q'[               , MAX(EDT.ENTRY_DT) AS LAST_VISIT_DT ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    CS_ENTRY_DT EDT                 ]'
        ||CHR(13)||CHR(10)||Q'[               , W_MEM                  MEM      ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   MEM.COMP_CD   = EDT.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MEM.MEMBER_NO = EDT.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MEM.CHILD_NO  = EDT.CHILD_NO    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     'Y'           = EDT.USE_YN      ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP  BY                               ]'
        ||CHR(13)||CHR(10)||Q'[                 MEM.COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[               , MEM.MEMBER_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[               , MEM.CHILD_NO                    ]'
        ||CHR(13)||CHR(10)||Q'[        ) V03                                    ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   V01.COMP_CD   = V02.COMP_CD  (+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.MEMBER_NO = V02.MEMBER_NO(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.COMP_CD   = V03.COMP_CD  (+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.MEMBER_NO = V03.MEMBER_NO(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.CHILD_NO  = V03.CHILD_NO (+)        ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY              ]'
        ||CHR(13)||CHR(10)||Q'[         V01.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.MEMBER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CHILD_NM    ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD;
     
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
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_MBS_DIV     IN  VARCHAR2 ,                -- 회원권종류
        PSV_MBS_STAT    IN  VARCHAR2 ,                -- 회원권상태
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     회원권 환불요청내역
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
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
    
    ls_sql_cm_01850 VARCHAR2(32000) ; -- 공통코드
    ls_sql_cm_01860 VARCHAR2(32000) ; -- 공통코드
    ls_sql_cm_01870 VARCHAR2(32000) ; -- 공통코드
    ls_sql_cm_01880 VARCHAR2(32000) ; -- 공통코드
    ls_sql_cm_01935 VARCHAR2(32000) ; -- 공통코드
    
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
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_01850 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01850') ; -- 회원권 종류
        ls_sql_cm_01860 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01860') ; -- 유무상 구분
        ls_sql_cm_01870 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01870') ; -- 회원 구분
        ls_sql_cm_01880 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01880') ; -- 회원권 상태
        ls_sql_cm_01935 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01935') ; -- 판매구분
        -------------------------------------------------------------------------------
                   
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  CMS.COMP_CD     ]'                      -- 회사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MEM.MEMBER_NO   ]'                      -- 회원번호
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(MEM.MEMBER_NM) AS MEMBER_NM ]'  -- 회원명
        ||CHR(13)||CHR(10)||Q'[      ,  MEM.MEMBER_DIV  ]'                      -- 회원구분
        ||CHR(13)||CHR(10)||Q'[      ,  CM3.CODE_NM AS MEMBER_DIV_NM        ]'  -- 회원구분
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(DECRYPT(MEM.ORG_NM), '_')            AS ORG_NM ]' -- 단체명
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(MEM.MOBILE)) AS MOBILE ]' -- 연락처
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.PROGRAM_ID  ]'                      -- 프로그램ID
        ||CHR(13)||CHR(10)||Q'[      ,  PGM.PROGRAM_NM  ]'                      -- 프로그램명
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.MBS_NO      ]'                      -- 회원권번호
        ||CHR(13)||CHR(10)||Q'[      ,  PGM.MBS_NM      ]'                      -- 회원권명
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.MBS_DIV     ]'                      -- 회원권종류
        ||CHR(13)||CHR(10)||Q'[      ,  CM1.CODE_NM AS MBS_DIV_NM ]'            -- 회원권종류명
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.MBS_STAT    ]'                      -- 회원권상태
        ||CHR(13)||CHR(10)||Q'[      ,  CM4.CODE_NM AS MBS_STAT_NM ]'           -- 회원권상태명
        ||CHR(13)||CHR(10)||Q'[      ,  SUBSTR(CMS.CERT_NO, 1, 8)||'****'||SUBSTR(CMS.CERT_NO, 14, 2) AS CERT_NO ]'                      -- 승인번호
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.SALE_DIV    ]'                      -- 판매구분
        ||CHR(13)||CHR(10)||Q'[      ,  CM5.CODE_NM AS SALE_DIV_NM  ]'          -- 판매구분명
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.CHARGE_YN   ]'                      -- 유무상구분
        ||CHR(13)||CHR(10)||Q'[      ,  CM2.CODE_NM AS CHARGE_YN_NM ]'          -- 유무상구분명
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.GRD_AMT     ]'                      -- 결제금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CMS.MBS_STAT= '92' THEN   ]'  -- 환불완료금액
        ||CHR(13)||CHR(10)||Q'[                  CMS.REFUND_AMT             ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN CMS.MBS_DIV = '1' THEN    ]'  -- 시간권의 환불금액 계산
        ||CHR(13)||CHR(10)||Q'[                  CASE WHEN TRUNC(CMS.GRD_AMT - (CMS.ENTR_PRC * (CMS.USE_TM / PGM.BASE_USE_TM)), -2) <= 0 THEN 0   ]'  -- 사용시간금액이 구매금액을 초과하는 경우 환불금액은 0
        ||CHR(13)||CHR(10)||Q'[                       ELSE TRUNC(CMS.GRD_AMT - (CMS.ENTR_PRC * (CMS.USE_TM / PGM.BASE_USE_TM)), -2)               ]'  -- 환불금액 10원단위 절삭
        ||CHR(13)||CHR(10)||Q'[                  END ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN CMS.MBS_DIV = '2' THEN     ]'      -- 횟수권의 환불금액 계산
        ||CHR(13)||CHR(10)||Q'[                  CASE WHEN TRUNC(CMS.GRD_AMT - (CMS.ENTR_PRC * CMS.USE_CNT), -2) <= 0THEN 0                     ]'  -- 사용횟수금액이 구매금액을 초과하는 경우 환불금액은 0
        ||CHR(13)||CHR(10)||Q'[                       ELSE TRUNC(CMS.GRD_AMT - (CMS.ENTR_PRC * CMS.USE_CNT), -2)                                ]'  -- 환불금액 10원단위 절삭
        ||CHR(13)||CHR(10)||Q'[                  END ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN CMS.MBS_DIV = '3' THEN     ]'      -- 금액권의 환불금액 계산
        ||CHR(13)||CHR(10)||Q'[                  CASE WHEN TRUNC(CMS.GRD_AMT - CMS.USE_AMT, -2) <= 0 THEN 0                                    ]'  -- 사용금액이 구매금액을 초과하는 경우 환불금액은 0
        ||CHR(13)||CHR(10)||Q'[                       ELSE TRUNC(CMS.GRD_AMT - CMS.USE_AMT, -2)                                                ]'  -- 환불금액 10원단위 절삭
        ||CHR(13)||CHR(10)||Q'[                  END ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE 0                         ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS REFUND_AMT   ]'  -- 환불금액
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.SALE_BRAND_CD    AS BRAND_CD ]'     -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[      ,  STO.BRAND_NM    ]'                      -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.SALE_STOR_CD     AS STOR_CD  ]'     -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  STO.STOR_NM     ]'                      -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.CERT_FDT    ]'                      -- 유효기간 시작일자
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.CERT_TDT    ]'                      -- 유효기간 종료일자
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.OFFER_TM    ]'                      -- 제공시간
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.USE_TM      ]'                      -- 사용시간
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.OFFER_CNT   ]'                      -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.USE_CNT     ]'                      -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.OFFER_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.USE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CMS.MBS_STAT IN ('92', '99') THEN 0 ELSE CMS.OFFER_AMT - CMS.USE_AMT END   AS REST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.OFFER_MCNT  ]'                      -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.USE_MCNT    ]'                      -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  CMS.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.MBS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.MBS_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.MBS_STAT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.CERT_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.CHARGE_YN   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.ENTR_PRC    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.GRD_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.REFUND_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.SALE_BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.SALE_STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.CERT_FDT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.CERT_TDT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.OFFER_TM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.USE_TM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.OFFER_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.USE_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.OFFER_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.USE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.OFFER_MCNT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMS.USE_MCNT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CMSH.SALE_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  S_STORE                 STO           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBERSHIP_SALE      CMS           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBERSHIP_SALE_HIS  CMSH          ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  CMS.COMP_CD       = STO.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CMS.SALE_BRAND_CD = STO.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CMS.SALE_STOR_CD  = STO.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CMS.COMP_CD       = CMSH.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CMS.PROGRAM_ID    = CMSH.PROGRAM_ID(+)]'
        ||CHR(13)||CHR(10)||Q'[                AND  CMS.MBS_NO        = CMSH.MBS_NO(+)    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CMS.CERT_NO       = CMSH.CERT_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CMS.COMP_CD       = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[                         (CMSH.SALE_USE_DIV(+) = '1' AND CMSH.SALE_DIV(+) = '1' AND CMSH.USE_STAT(+) = '00') ]'
        ||CHR(13)||CHR(10)||Q'[                         OR                              ]'
        ||CHR(13)||CHR(10)||Q'[                         (CMSH.SALE_USE_DIV(+) = '2' AND CMSH.SALE_DIV(+) = '3' AND CMSH.USE_STAT(+) = '10') ]'
        ||CHR(13)||CHR(10)||Q'[                     )                                   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_MBS_STAT   IS NULL OR CMS.MBS_STAT = :PSV_MBS_STAT ) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_MBS_DIV    IS NULL OR CMS.MBS_DIV  = :PSV_MBS_DIV  ) ]'
        ||CHR(13)||CHR(10)||Q'[         )   CMS ]'
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
        ||CHR(13)||CHR(10)||Q'[         )                       PGM          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER               MEM          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE                 STO          ]'
        ||CHR(13)||CHR(10)|| '       , ' || ls_sql_cm_01850 ||' CM1 '
        ||CHR(13)||CHR(10)|| '       , ' || ls_sql_cm_01860 ||' CM2 '
        ||CHR(13)||CHR(10)|| '       , ' || ls_sql_cm_01870 ||' CM3 '
        ||CHR(13)||CHR(10)|| '       , ' || ls_sql_cm_01880 ||' CM4 '
        ||CHR(13)||CHR(10)|| '       , ' || ls_sql_cm_01935 ||' CM5 '
        ||CHR(13)||CHR(10)||Q'[  WHERE  CMS.COMP_CD          = STO.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.SALE_BRAND_CD    = STO.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.SALE_STOR_CD     = STO.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.COMP_CD          = PGM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.PROGRAM_ID       = PGM.PROGRAM_ID]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.MBS_NO           = PGM.MBS_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.COMP_CD          = MEM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.MEMBER_NO        = MEM.MEMBER_NO ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.MBS_DIV          = CM1.CODE_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.CHARGE_YN        = CM2.CODE_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MEM.MEMBER_DIV       = CM3.CODE_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.MBS_STAT         = CM4.CODE_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CMS.SALE_DIV         = CM5.CODE_CD   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY                  ]'
        ||CHR(13)||CHR(10)||Q'[         2                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PGM.PROGRAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PGM.MBS_NM          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CMS.CERT_FDT        ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_MBS_STAT, PSV_MBS_STAT, PSV_MBS_DIV, PSV_MBS_DIV, PSV_COMP_CD, PSV_LANG_CD, PSV_LANG_CD;
     
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
    
END PKG_GCRM1020;

/
