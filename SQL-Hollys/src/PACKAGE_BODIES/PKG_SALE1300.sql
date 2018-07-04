--------------------------------------------------------
--  DDL for Package Body PKG_SALE1300
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1300" AS

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_MAIN       부가메뉴 매출현황(부가메뉴) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql              VARCHAR2(30000) ;
    ls_sql_with         VARCHAR2(30000) ;
    ls_sql_main         VARCHAR2(20000) ;
    ls_sql_date         VARCHAR2(1000) ;
    ls_sql_store        VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_common_01415 VARCHAR2(1000) ;    -- 공통코드SQL
    ls_txt              VARCHAR2(1000) ;    -- 테스트

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
        --       ||  ', '
        --       ||  ls_sql_item  -- S_ITEM
        ;

        ------------------------------------------------------------------------------
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_common_01415 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01415') ;
        -------------------------------------------------------------------------------
        ls_txt := FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SERVICE');
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT ']' || ls_txt ||Q'[' AS CLASS_NM                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.GUBUN                                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM.CODE_NM AS GUBUN_NM                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.QTY                                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.AMT                                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.DC_CNT                                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.DC_AMT                                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.SALE_AMT                                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.NET_AMT                                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RATIO_TO_REPORT(V2.NET_AMT)     OVER () * 100 AS DAY_RATE]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.ACC_QTY                                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.ACC_SALE_AMT                                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.ACC_NET_AMT                                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RATIO_TO_REPORT(V2.ACC_NET_AMT) OVER () * 100 AS MON_RATE]'  
        ||CHR(13)||CHR(10)||Q'[ FROM  ]' || ls_sql_common_01415 || Q'[ CM               ]'
        ||CHR(13)||CHR(10)||Q'[      , (                                                ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V1.COMP_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V1.GUBUN                                ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CASE WHEN V1.GUBUN = '056' THEN '900'   ]'
        ||CHR(13)||CHR(10)||Q'[                      ELSE V1.GUBUN                      ]'
        ||CHR(13)||CHR(10)||Q'[                 END                     AS SORT_SEQ     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.QTY)             AS QTY          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.AMT)             AS AMT          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.DC_CNT)          AS DC_CNT       ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.DC_AMT)          AS DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.SALE_AMT)        AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.NET_AMT)         AS NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.ACC_QTY)         AS ACC_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.ACC_SALE_AMT)    AS ACC_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.ACC_NET_AMT)     AS ACC_NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[         FROM   (                                        ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CL.GUBUN                        ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.QTY ELSE 0 END) AS QTY]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.AMT ELSE 0 END) AS AMT]'
        ||CHR(13)||CHR(10)||Q'[                      ,  0 AS DC_CNT                     ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  0 AS DC_AMT                     ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE AND CL.GUBUN IN ('072', '073') THEN CL.AMT       ELSE 0 END) AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE AND CL.GUBUN IN ('072', '073') THEN CL.AMT / 1.1 ELSE 0 END) AS NET_AMT                    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CL.QTY)         AS ACC_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN CL.GUBUN IN ('072', '073') THEN CL.AMT      ELSE 0 END) AS ACC_SALE_AMT               ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN CL.GUBUN IN ('072', '073') THEN CL.AMT /1.1 ELSE 0 END) AS ACC_NET_AMT                ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    SALE_CL   CL                    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S_STORE   ST                    ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   CL.COMP_CD  = ST.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.BRAND_CD = ST.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.STOR_CD  = ST.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.GUBUN   IN ('051','052','053','054','070','071','072','073') ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.SEQ      = 99                ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                ]'
        ||CHR(13)||CHR(10)||Q'[                         CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CL.GUBUN                        ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                               ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  '051'   AS GUBUN                ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  0       AS QTY                  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  0       AS AMT                  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  0       AS CST_CNT              ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  0       AS DC_AMT               ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.AMT * (-1) ELSE 0 END)                    AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  ROUND(SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.AMT * (-1) ELSE 0 END) / 1.1, 0)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  0 AS ACC_QTY                                        ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CL.AMT * (-1))                 AS ACC_SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  ROUND(SUM(CL.AMT * (-1)) / 1.1, 0) AS ACC_NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    SALE_CL   CL                    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S_STORE   ST                    ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   CL.COMP_CD  = ST.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.BRAND_CD = ST.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.STOR_CD  = ST.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'  
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.GUBUN   IN ('072','073')     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CL.SEQ      = 99                ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                ]'
        ||CHR(13)||CHR(10)||Q'[                         CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                               ]'  
        ||CHR(13)||CHR(10)||Q'[                 SELECT  /*+ NO_MERGE LEADING(HD) */     ]'
        ||CHR(13)||CHR(10)||Q'[                         HD.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CASE WHEN HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN '051' ]' -- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.MBS_USE_YN = 'Y' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN '052' ]' -- 회원입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '2' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN '053' ]' -- 단체입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT != 0 THEN '054' ]' -- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN                                                 DT.ENTRY_DIV = '2'        AND DT.GRD_AMT  = 0 THEN '070' ]' -- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT  = 0 THEN '071' ]' -- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                         END     AS GUBUN                ]'
        ||CHR(13)||CHR(10)||Q'[                       , 0 QTY                           ]'
        ||CHR(13)||CHR(10)||Q'[                       , 0 AMT                           ]'
        ||CHR(13)||CHR(10)||Q'[                       , CASE WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 AND (DT.DC_AMT - NVL(AD.DC_AMT, 0)) != 0 THEN 1 ]'     -- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'Y' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 AND (DT.DC_AMT - NVL(AD.DC_AMT, 0)) != 0 THEN 1 ]'     -- 회원입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '2' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 AND (DT.DC_AMT - NVL(AD.DC_AMT, 0)) != 0 THEN 1 ]'     -- 단체입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT != 0 AND (DT.DC_AMT - NVL(AD.DC_AMT, 0)) != 0 THEN 1 ]'     -- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV = '2'        AND DT.GRD_AMT  = 0 AND (DT.DC_AMT - NVL(AD.DC_AMT, 0)) != 0 THEN 1 ]'     -- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT  = 0 AND (DT.DC_AMT - NVL(AD.DC_AMT, 0)) != 0 THEN 1 ]'     -- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              ELSE 0                     ]'
        ||CHR(13)||CHR(10)||Q'[                         END     AS DC_CNT               ]'  
        ||CHR(13)||CHR(10)||Q'[                       , CASE WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.DC_AMT - NVL(AD.DC_AMT, 0) ]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'Y' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.DC_AMT - NVL(AD.DC_AMT, 0) ]'-- 회원입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '2' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.DC_AMT - NVL(AD.DC_AMT, 0) ]'-- 단체입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT != 0 THEN DT.DC_AMT - NVL(AD.DC_AMT, 0) ]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV = '2'        AND DT.GRD_AMT  = 0 THEN DT.DC_AMT - NVL(AD.DC_AMT, 0) ]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT  = 0 THEN DT.DC_AMT - NVL(AD.DC_AMT, 0) ]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              ELSE 0                     ]'
        ||CHR(13)||CHR(10)||Q'[                         END     AS DC_AMT               ]'
        ||CHR(13)||CHR(10)||Q'[                       , CASE WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'Y' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 회원입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '2' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 단체입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT != 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV = '2'        AND DT.GRD_AMT  = 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT  = 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              ELSE 0                     ]'
        ||CHR(13)||CHR(10)||Q'[                         END     AS SALE_AMT             ]'
        ||CHR(13)||CHR(10)||Q'[                       , CASE WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.USE_AMT/1.1 ]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'Y' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.USE_AMT/1.1 ]'-- 회원입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '2' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.USE_AMT/1.1 ]'-- 단체입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT != 0 THEN DT.USE_AMT/1.1 ]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV = '2'        AND DT.GRD_AMT  = 0 THEN DT.USE_AMT/1.1 ]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.ENTRY_DT = :PSV_GTO_DATE AND                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT  = 0 THEN DT.USE_AMT/1.1 ]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              ELSE 0                     ]'
        ||CHR(13)||CHR(10)||Q'[                         END     AS NET_AMT              ]'
        ||CHR(13)||CHR(10)||Q'[                       , 0       AS ACC_QTY              ]'
        ||CHR(13)||CHR(10)||Q'[                       , CASE WHEN HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.MBS_USE_YN = 'Y' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 회원입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '2' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 단체입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT != 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN                                                 DT.ENTRY_DIV = '2'        AND DT.GRD_AMT  = 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT  = 0 THEN DT.SALE_AMT - (DT.ADD_AMT + NVL(AD.DC_AMT, 0))]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              ELSE 0                     ]'
        ||CHR(13)||CHR(10)||Q'[                         END     AS ACC_SALE_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[                       , CASE WHEN HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.USE_AMT/1.1 ]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.MBS_USE_YN = 'Y' AND HD.MEMBER_DIV = '1' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.USE_AMT/1.1 ]'-- 회원입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN HD.MBS_USE_YN = 'N' AND HD.MEMBER_DIV = '2' AND DT.ENTRY_DIV = '2'        AND DT.GRD_AMT != 0 THEN DT.USE_AMT/1.1 ]'-- 단체입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT != 0 THEN DT.USE_AMT/1.1 ]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN                                                 DT.ENTRY_DIV = '2'        AND DT.GRD_AMT  = 0 THEN DT.USE_AMT/1.1 ]'-- 일반입장
        ||CHR(13)||CHR(10)||Q'[                              WHEN                                                 DT.ENTRY_DIV IN('1', '3') AND DT.GRD_AMT  = 0 THEN DT.USE_AMT/1.1 ]'-- 보호자입장
        ||CHR(13)||CHR(10)||Q'[                              ELSE 0                     ]'
        ||CHR(13)||CHR(10)||Q'[                         END     AS ACC_NET_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    CS_ENTRY_DT DT                  ]'
        ||CHR(13)||CHR(10)||Q'[                       ,(                                ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  DT.COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                               , DT.ENTRY_NO             ]'
        ||CHR(13)||CHR(10)||Q'[                               , DT.ENTRY_SEQ            ]'
        ||CHR(13)||CHR(10)||Q'[                               , SUM(DT.SALE_AMT)            AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                               , SUM(DT.DC_AMT + DT.ENR_AMT) AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                         FROM    SALE_DT             DT  ]'
        ||CHR(13)||CHR(10)||Q'[                               , S_STORE   ST                    ]'
        ||CHR(13)||CHR(10)||Q'[                         WHERE   DT.COMP_CD   = ST.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     DT.BRAND_CD  = ST.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     DT.STOR_CD   = ST.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     EXISTS(                         ]'
        ||CHR(13)||CHR(10)||Q'[                                        SELECT   1               ]'
        ||CHR(13)||CHR(10)||Q'[                                        FROM     CS_PROGRAM  CP  ]'
        ||CHR(13)||CHR(10)||Q'[                                        WHERE    CP.COMP_CD     = DT.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND      CP.ADD_ITEM_CD = DT.ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                       )                         ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     DT.COMP_CD   = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     DT.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                         GROUP BY                        ]'
        ||CHR(13)||CHR(10)||Q'[                                 DT.COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                               , DT.ENTRY_NO             ]'
        ||CHR(13)||CHR(10)||Q'[                               , DT.ENTRY_SEQ            ]'
        ||CHR(13)||CHR(10)||Q'[                        ) AD                             ]'
        ||CHR(13)||CHR(10)||Q'[                       ,(                                ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  HD.COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                               , HD.ENTRY_NO             ]'
        ||CHR(13)||CHR(10)||Q'[                               , HD.ENTRY_DT             ]'
        ||CHR(13)||CHR(10)||Q'[                               , DT.ENTRY_SEQ            ]'
        ||CHR(13)||CHR(10)||Q'[                               , HD.MEMBER_DIV           ]'  
        ||CHR(13)||CHR(10)||Q'[                               , MAX(CASE WHEN EM.CERT_NO IS NULL THEN 'N' ELSE 'Y' END) AS MBS_USE_YN   ]'
        ||CHR(13)||CHR(10)||Q'[                         FROM    S_STORE             ST  ]'
        ||CHR(13)||CHR(10)||Q'[                               , CS_ENTRY_HD         HD  ]'
        ||CHR(13)||CHR(10)||Q'[                               , CS_ENTRY_DT         DT  ]'
        ||CHR(13)||CHR(10)||Q'[                               , CS_ENTRY_MEMBERSHIP EM  ]'
        ||CHR(13)||CHR(10)||Q'[                         WHERE   HD.COMP_CD   = ST.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     HD.BRAND_CD  = ST.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     HD.STOR_CD   = ST.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     HD.COMP_CD   = DT.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     HD.ENTRY_NO  = DT.ENTRY_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     DT.COMP_CD   = EM.COMP_CD  (+)  ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     DT.ENTRY_NO  = EM.ENTRY_NO (+)  ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     DT.ENTRY_SEQ = EM.ENTRY_SEQ(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     HD.COMP_CD   = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     HD.ENTRY_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     HD.USE_YN    = 'Y'              ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     DT.USE_YN    = 'Y'              ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     EM.USE_YN(+) = 'Y'              ]'
        ||CHR(13)||CHR(10)||Q'[                         GROUP BY                        ]'
        ||CHR(13)||CHR(10)||Q'[                                 HD.COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                               , HD.ENTRY_NO             ]'
        ||CHR(13)||CHR(10)||Q'[                               , DT.ENTRY_SEQ            ]'
        ||CHR(13)||CHR(10)||Q'[                               , HD.ENTRY_DT             ]'
        ||CHR(13)||CHR(10)||Q'[                               , HD.MEMBER_DIV           ]'
        ||CHR(13)||CHR(10)||Q'[                        ) HD                             ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   HD.COMP_CD   = DT.COMP_CD       ]'  
        ||CHR(13)||CHR(10)||Q'[                 AND     HD.ENTRY_NO  = DT.ENTRY_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HD.ENTRY_SEQ = DT.ENTRY_SEQ     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     DT.COMP_CD   = AD.COMP_CD  (+)  ]'  
        ||CHR(13)||CHR(10)||Q'[                 AND     DT.ENTRY_NO  = AD.ENTRY_NO (+)  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     DT.ENTRY_SEQ = AD.ENTRY_SEQ(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     DT.USE_YN    = 'Y'              ]'
        ||CHR(13)||CHR(10)||Q'[             )   V1                                      ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                                        ]'
        ||CHR(13)||CHR(10)||Q'[                 V1.COMP_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V1.GUBUN                                ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CASE WHEN V1.GUBUN = '056' THEN '900'   ]'
        ||CHR(13)||CHR(10)||Q'[                      ELSE GUBUN                         ]'
        ||CHR(13)||CHR(10)||Q'[                 END                                     ]'
        ||CHR(13)||CHR(10)||Q'[        ) V2                                             ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   CM.COMP_CD = V2.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[ AND     CM.CODE_CD = V2.GUBUN                           ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY                                                ]'
        ||CHR(13)||CHR(10)||Q'[         V2.SORT_SEQ                                     ]'     
        ;

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_COMP_CD,  PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_GTO_DATE, PSV_GTO_DATE, PSV_COMP_CD,  PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE,
                         PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE,
                         PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE,
                         PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD,  PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD,  PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_SUB
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_SUB       분류별 매출
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql              VARCHAR2(30000) ;
    ls_sql_with         VARCHAR2(30000) ;
    ls_sql_main         VARCHAR2(20000) ;
    ls_sql_date         VARCHAR2(1000) ;
    ls_sql_store        VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_txt              VARCHAR2(1000) ;    -- 테스트
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

        ------------------------------------------------------------------------------
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        --ls_sql_common_01415 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01415') ;
        -------------------------------------------------------------------------------
        ls_txt := FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'M_CLASS_CD');
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT ']' || ls_txt ||Q'[' AS CLASS_NM             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.M_CLASS_CD                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.M_CLASS_NM                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.SALE_QTY                                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.GRD_AMT                                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.DC_CNT                                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.DC_AMT                                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.SALE_AMT                                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.NET_AMT                                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RATIO_TO_REPORT(V1.NET_AMT)     OVER () * 100 AS DAY_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.ACC_SALE_QTY                             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.ACC_SALE_AMT                             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.ACC_NET_AMT                              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RATIO_TO_REPORT(V1.ACC_NET_AMT) OVER() * 100 AS MON_RATE ]'
        ||CHR(13)||CHR(10)||Q'[ FROM  (                                             ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  I.M_CLASS_CD                                ]'
        ||CHR(13)||CHR(10)||Q'[              ,  I.M_CLASS_NM                                ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN SM.SALE_DT  = :PSV_GTO_DATE THEN SM.SALE_QTY             ELSE 0 END) AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN SM.SALE_DT  = :PSV_GTO_DATE THEN SM.GRD_AMT              ELSE 0 END) AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN SM.SALE_DT  = :PSV_GTO_DATE AND  SM.DC_AMT + SM.ENR_AMT != 0 THEN 1 ELSE 0 END) AS DC_CNT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN SM.SALE_DT  = :PSV_GTO_DATE THEN SM.DC_AMT + SM.ENR_AMT  ELSE 0 END) AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN SM.SALE_DT  = :PSV_GTO_DATE THEN SM.SALE_AMT             ELSE 0 END) AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN SM.SALE_DT  = :PSV_GTO_DATE THEN SM.GRD_AMT - SM.VAT_AMT ELSE 0 END) AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SM.SALE_QTY)             AS ACC_SALE_QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SM.SALE_AMT)             AS ACC_SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SM.GRD_AMT - SM.VAT_AMT) AS ACC_NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_JDM    SM  ]'
        ||CHR(13)||CHR(10)||q'[              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   SM.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SM.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SM.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SM.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SM.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SM.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SM.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         AND     NOT EXISTS(                 ]'
        ||CHR(13)||CHR(10)||Q'[                             SELECT  1       ]'
        ||CHR(13)||CHR(10)||Q'[                             FROM    CS_PROGRAM CP               ]'
        ||CHR(13)||CHR(10)||Q'[                             WHERE   CP.COMP_CD     = SM.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                             AND    (                            ]'
        ||CHR(13)||CHR(10)||Q'[                                     CP.PGM_ITEM_CD = SM.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                     OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                                     CP.GDN_ITEM_CD = SM.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                    )        ]'
        ||CHR(13)||CHR(10)||Q'[                            )    ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP  BY               ]'
        ||CHR(13)||CHR(10)||Q'[                 I.M_CLASS_CD,   ]'
        ||CHR(13)||CHR(10)||Q'[                 I.M_CLASS_NM    ]'
        ||CHR(13)||CHR(10)||Q'[        ) V1                     ]'      
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.M_CLASS_CD  ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_ACC
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_ACC       유통사정산 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql              VARCHAR2(30000) ;
    ls_sql_with         VARCHAR2(30000) ;
    ls_sql_main         VARCHAR2(20000) ;
    ls_sql_date         VARCHAR2(1000) ;
    ls_sql_store        VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_common_01415 VARCHAR2(1000) ;    -- 공통코드SQL
    ls_txt              VARCHAR2(1000) ;    -- 테스트
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
        --     ||  ', '
        --     ||  ls_sql_item  -- S_ITEM
        ;

        ------------------------------------------------------------------------------
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_common_01415 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01415') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  CM.CODE_NM GUBUN_NM                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.QTY                                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.AMT                                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.ACC_AMT                                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.GOAL_MON                                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN NVL(V2.GOAL_MON, 0) = 0 THEN 0 ELSE SUM(V1.ACC_AMT) OVER() / V2.GOAL_MON END * 100 AS MON_RATE ]'
        ||CHR(13)||CHR(10)||Q'[ FROM  ]' || ls_sql_common_01415 || Q'[ CM           ]'
        ||CHR(13)||CHR(10)||Q'[      , (                                            ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CL.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CASE WHEN CL.GUBUN IN ('021', '022') THEN '101']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('024')        THEN '102']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('034')        THEN '103']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('025')        THEN '104']'
        ||CHR(13)||CHR(10)||Q'[                      ELSE '105'                                ]'
        ||CHR(13)||CHR(10)||Q'[                 END             AS GUBUN                       ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.QTY ELSE 0 END) AS QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.AMT ELSE 0 END) AS AMT]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CL.AMT)     AS ACC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_CL   CL                    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE   ST                    ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   CL.COMP_CD  = ST.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.BRAND_CD = ST.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.STOR_CD  = ST.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.GUBUN   IN ('021','022','024','025','031','032','033','034') ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.SEQ      = 99                ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                                ]'
        ||CHR(13)||CHR(10)||Q'[                 CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CASE WHEN CL.GUBUN IN ('021', '022') THEN '101']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('024')        THEN '102']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('034')        THEN '103']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('025')        THEN '104']'
        ||CHR(13)||CHR(10)||Q'[                      ELSE '105'                                ]'
        ||CHR(13)||CHR(10)||Q'[                 END         ]'
        ||CHR(13)||CHR(10)||Q'[        ) V1                 ]'
        ||CHR(13)||CHR(10)||Q'[      , (                    ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  GL.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  GOAL_MON    ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_GOAL_DAY   GL  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE         ST  ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   GL.COMP_CD  = ST.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GL.BRAND_CD = ST.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GL.STOR_CD  = ST.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GL.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GL.GOAL_YM = SUBSTR(:PSV_GTO_DATE, 1, 6)]'
        ||CHR(13)||CHR(10)||Q'[        ) V2                         ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   CM.COMP_CD = V1.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[ AND     CM.CODE_CD = V1.GUBUN       ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V1.COMP_CD = V2.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.GUBUN                 ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_GTO_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GTO_DATE;

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

    PROCEDURE SP_DSTN
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_ACC       자사정산 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql              VARCHAR2(30000) ;
    ls_sql_with         VARCHAR2(30000) ;
    ls_sql_main         VARCHAR2(20000) ;
    ls_sql_date         VARCHAR2(1000) ;
    ls_sql_store        VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_common_01415 VARCHAR2(1000) ;    -- 공통코드SQL
    ls_txt              VARCHAR2(1000) ;    -- 테스트
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
        --     ||  ', '
        --     ||  ls_sql_item  -- S_ITEM
        ;

        ------------------------------------------------------------------------------
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_common_01415 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01415') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  CM.CODE_NM GUBUN_NM                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.QTY                                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.AMT                                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.ACC_AMT                              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.AMT     - V2.AMT     AS DEF_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.ACC_AMT - V2.ACC_AMT AS DEF_ACC_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[ FROM  ]' || ls_sql_common_01415 || Q'[ CM       ]'
        ||CHR(13)||CHR(10)||Q'[      , (                                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CL.GUBUN                        ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.QTY ELSE 0 END) AS QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.AMT ELSE 0 END) AS AMT]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CL.AMT)     AS ACC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_CL   CL                    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE   ST                    ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   CL.COMP_CD  = ST.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.BRAND_CD = ST.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.STOR_CD  = ST.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.GUBUN   IN ('101','102','103','104','105') ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.SEQ      = 99                ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                                ]'
        ||CHR(13)||CHR(10)||Q'[                 CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CL.GUBUN                        ]'
        ||CHR(13)||CHR(10)||Q'[        ) V1                 ]'
        ||CHR(13)||CHR(10)||Q'[      , (                    ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CASE WHEN CL.GUBUN IN ('021', '022') THEN '101']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('024')        THEN '102']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('034')        THEN '103']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('025')        THEN '104']'
        ||CHR(13)||CHR(10)||Q'[                      ELSE '105'                                ]'
        ||CHR(13)||CHR(10)||Q'[                 END             AS GUBUN                       ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.QTY ELSE 0 END) AS QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CL.SALE_DT = :PSV_GTO_DATE THEN CL.AMT ELSE 0 END) AS AMT]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CL.AMT)     AS ACC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_CL   CL                    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE   ST                    ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   CL.COMP_CD  = ST.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.BRAND_CD = ST.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.STOR_CD  = ST.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.GUBUN   IN ('021','022','024','025','031','032','033','034') ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.SEQ      = 99                ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                                ]'
        ||CHR(13)||CHR(10)||Q'[                 CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CASE WHEN CL.GUBUN IN ('021', '022') THEN '101']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('024')        THEN '102']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('034')        THEN '103']'
        ||CHR(13)||CHR(10)||Q'[                      WHEN CL.GUBUN IN ('025')        THEN '104']'
        ||CHR(13)||CHR(10)||Q'[                      ELSE '105'                                ]'
        ||CHR(13)||CHR(10)||Q'[                 END         ]'
        ||CHR(13)||CHR(10)||Q'[        ) V2                 ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   CM.COMP_CD = V1.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[ AND     CM.CODE_CD = V1.GUBUN   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V1.COMP_CD = V2.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V1.GUBUN   = V2.GUBUN   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.GUBUN             ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_GTO_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_GTO_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_GIFT
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_ACC       유통사정산 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql              VARCHAR2(30000) ;
    ls_sql_with         VARCHAR2(30000) ;
    ls_sql_main         VARCHAR2(20000) ;
    ls_sql_date         VARCHAR2(1000) ;
    ls_sql_store        VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_common_01105 VARCHAR2(1000) ;    -- 공통코드SQL
    ls_txt              VARCHAR2(1000) ;    -- 테스트
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
        --     ||  ', '
        --     ||  ls_sql_item  -- S_ITEM
        ;

        ------------------------------------------------------------------------------
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_common_01105 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '01105') ;
        -------------------------------------------------------------------------------
        ls_txt := FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CS_MEMBERSHIP_SALE');
        -------------------------------------------------------------------------------


        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V1.DIV_CD                                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.DIV_NM                                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.QTY                                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.AMT                                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.MON_QTY                                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.MON_AMT                                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.YEAR_QTY                                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.YEAR_AMT                                 ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   (                                            ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  PY.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  GM.GIFT_PUB_DIV   AS DIV_CD         ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CM.CODE_NM        AS DIV_NM         ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN PY.SALE_DT = :PSV_GTO_DATE                        THEN DECODE(PY.SALE_DIV, '1', 1, -1) ELSE 0 END) AS QTY     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN PY.SALE_DT = :PSV_GTO_DATE                        THEN PY.PAY_AMT ELSE 0 END) AS AMT     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN PY.SALE_DT LIKE SUBSTR(:PSV_GTO_DATE, 1, 6) ||'%' THEN DECODE(PY.SALE_DIV, '1', 1, -1) ELSE 0 END) AS MON_QTY ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN PY.SALE_DT LIKE SUBSTR(:PSV_GTO_DATE, 1, 6) ||'%' THEN PY.PAY_AMT ELSE 0 END) AS MON_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN PY.SALE_DT LIKE SUBSTR(:PSV_GTO_DATE, 1, 4) ||'%' THEN DECODE(PY.SALE_DIV, '1', 1, -1) ELSE 0 END) AS YEAR_QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN PY.SALE_DT LIKE SUBSTR(:PSV_GTO_DATE, 1, 4) ||'%' THEN PY.PAY_AMT ELSE 0 END) AS YEAR_AMT]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_ST         PY                  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  GIFT_CODE_MST   GM                  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE         ST                  ]'
        ||CHR(13)||CHR(10)||Q'[              , ]' || ls_sql_common_01105 || Q'[ CM  ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   PY.COMP_CD      = ST.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     PY.BRAND_CD     = ST.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     PY.STOR_CD      = ST.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     PY.COMP_CD      = GM.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     PY.APPR_MAEIP_CD= GM.GIFT_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GM.COMP_CD      = CM.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GM.GIFT_PUB_DIV = CM.CODE_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     PY.COMP_CD      = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     PY.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     PY.PAY_DIV      = '40'              ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                 PY.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  GM.GIFT_PUB_DIV                     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CM.CODE_NM                          ]'
        ||CHR(13)||CHR(10)||Q'[         UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  MS.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  '99'                 AS DIV_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  ']' || ls_txt ||Q'[' AS DIV_NM      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN MS.CERT_FDT = :PSV_GTO_DATE                        THEN 1          ELSE 0 END) AS QTY     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN MS.CERT_FDT = :PSV_GTO_DATE                        THEN MS.GRD_AMT ELSE 0 END) AS AMT     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN MS.CERT_FDT LIKE SUBSTR(:PSV_GTO_DATE, 1, 6) ||'%' THEN 1          ELSE 0 END) AS MON_QTY ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN MS.CERT_FDT LIKE SUBSTR(:PSV_GTO_DATE, 1, 6) ||'%' THEN MS.GRD_AMT ELSE 0 END) AS MON_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN MS.CERT_FDT LIKE SUBSTR(:PSV_GTO_DATE, 1, 4) ||'%' THEN 1          ELSE 0 END) AS YEAR_QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN MS.CERT_FDT LIKE SUBSTR(:PSV_GTO_DATE, 1, 4) ||'%' THEN MS.GRD_AMT ELSE 0 END) AS YEAR_AMT]'
        ||CHR(13)||CHR(10)||Q'[         FROM    CS_MEMBERSHIP_SALE   MS             ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE              ST             ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   MS.COMP_CD       = ST.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.SALE_BRAND_CD = ST.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.SALE_STOR_CD  = ST.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.COMP_CD       = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.CERT_FDT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.MBS_STAT IN ('10','11','90')     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     NOT EXISTS (                        ]'
        ||CHR(13)||CHR(10)||Q'[                             SELECT  1                               ]'
        ||CHR(13)||CHR(10)||Q'[                             FROM    CS_MEMBERSHIP_SALE_HIS HIS      ]'
        ||CHR(13)||CHR(10)||Q'[                             WHERE   HIS.COMP_CD    = MS.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                             AND     HIS.PROGRAM_ID = MS.PROGRAM_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                             AND     HIS.MBS_NO     = MS.MBS_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                             AND     HIS.CERT_NO    = MS.CERT_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                             AND     HIS.SALE_DIV   = '3'            ]'
        ||CHR(13)||CHR(10)||Q'[                            )                                        ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                 MS.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[         ORDER BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                 2                                   ]'
        ||CHR(13)||CHR(10)||Q'[        ) V1                 ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.DIV_CD        ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE1300;

/
