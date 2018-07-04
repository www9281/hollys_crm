--------------------------------------------------------
--  DDL for Package Body PKG_SALE4032
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4032" AS
    PROCEDURE SP_MAIN /* 시간대별 전일/전주대비 매출현황   */
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                  -- Search 시작일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                  -- 고객구분
        PSV_SEC_FG      IN  VARCHAR2 ,                  -- 시간구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR  ,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       PKG_SALE4032.SP_MAIN 시간대별 전일/전주대비 매출현황
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2012-08-27         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     PKG_SALE4032.SP_MAIN
          SYSDATE:         2012-08-27
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
        ls_sql          VARCHAR2(30000) ;
        ls_sql_main     VARCHAR2(30000) ;
        ls_sql_date     VARCHAR2(1000) ;
        ls_sql_date2     VARCHAR2(1000) ;

        ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
        ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
        ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
        ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
        ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
        ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

        ls_from_date1   VARCHAR2(12);       -- 조회일자
        ls_from_date2   VARCHAR2(12);       -- 조회일자
        ls_date_1       VARCHAR2(12);
        ls_date_7       VARCHAR2(12);
        ls_date_364     VARCHAR2(12);

        ls_err_cd     VARCHAR2(7) := '0' ;
        ls_err_msg    VARCHAR2(500) ;

        ERR_HANDLER   EXCEPTION;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        dbms_output.enable( 1000000 ) ;

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
    --           ||  ', '
    --           ||  ls_sql_item  -- S_ITEM
               ;

    /*
      S_STORE AS
      (
     SELECT S.BRAND_CD , B.BRAND_NM, S.STOR_CD, S.STOR_NM, S.USE_YN ,
            S.STOR_TP, CM1.CODE_NM STOR_TP_NM , S.SIDO_CD, CM2.CODE_NM SIDO_CD_NM,
            S.REGION_CD, R.REGION_NM , S.TRAD_AREA, CM3.CODE_NM TRAD_AREA_NM, '
            S.DEPT_CD, CM4.CODE_NM DEPT_CD_NM, S.TEAM_CD, CM5.CODE_NM TEAM_CD_NM,
            S.SV_USER_ID , U.USER_NM
      )
    */

    /*
      S_ITEM AS
      (
       SELECT I.BRAND_CD, I.ITEM_CD, I.SALE_PRC,
              I.ITEM_NM , I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD,
             IC1.L_CLASS_NM , IC2.M_CLASS_NM , IC3.S_CLASS_NM
      )
    */

        -- 조회일자 분리
        ls_date_1   := TO_CHAR( TO_DATE(PSV_GFR_DATE,'YYYYMMDD') -   1, 'YYYYMMDD');
        ls_date_7   := TO_CHAR( TO_DATE(PSV_GFR_DATE,'YYYYMMDD') -   7, 'YYYYMMDD');
        ls_date_364 := TO_CHAR( TO_DATE(PSV_GFR_DATE,'YYYYMMDD') - 364, 'YYYYMMDD');

        --dbms_output.put_line('date2 : ' ||  ls_from_date2 ) ;

        ls_sql_main := ''
            || CHR(13) || CHR(10) || Q'[ SELECT A.*, ]'
            || CHR(13) || CHR(10) || Q'[ DECODE(A.LD_TOT_SALE_AMT,0,100, ROUND(( (DECODE(A.TD_TOT_SALE_AMT,0,1,TD_TOT_SALE_AMT)   / DECODE(A.LD_TOT_SALE_AMT,0,1,A.LD_TOT_SALE_AMT)) * 100 ),2) )    || '' AS TD_VS_LD_SALE_AMT, ]'
            || CHR(13) || CHR(10) || Q'[ DECODE(A.LW_TOT_SALE_AMT,0,100, ROUND(( (DECODE(A.TD_TOT_SALE_AMT,0,1,TD_TOT_SALE_AMT)   / DECODE(A.LW_TOT_SALE_AMT,0,1,A.LW_TOT_SALE_AMT)) * 100 ),2) )    || '' AS TD_VS_LW_SALE_AMT, ]'
            || CHR(13) || CHR(10) || Q'[ DECODE(A.LY_TOT_SALE_AMT,0,100, ROUND(( (DECODE(A.TD_TOT_SALE_AMT,0,1,TD_TOT_SALE_AMT)   / DECODE(A.LY_TOT_SALE_AMT,0,1,A.LY_TOT_SALE_AMT)) * 100 ),2) )    || '' AS TD_VS_LY_SALE_AMT, ]'
            || CHR(13) || CHR(10) || Q'[ DECODE(A.BILL_CNT21,0,100, ROUND(( (DECODE(A.BILL_CNT12,0,1,BILL_CNT12) / DECODE(A.BILL_CNT21,0,1,A.BILL_CNT21)) * 100 ),2) ) || '' AS TD_VS_LD_CUST_CNT, ]'
            || CHR(13) || CHR(10) || Q'[ DECODE(A.BILL_CNT31,0,100, ROUND(( (DECODE(A.BILL_CNT12,0,1,BILL_CNT12) / DECODE(A.BILL_CNT31,0,1,A.BILL_CNT31)) * 100 ),2) ) || '' AS TD_VS_LW_CUST_CNT, ]'
            || CHR(13) || CHR(10) || Q'[ DECODE(A.BILL_CNT41,0,100, ROUND(( (DECODE(A.BILL_CNT12,0,1,BILL_CNT12) / DECODE(A.BILL_CNT41,0,1,A.BILL_CNT41)) * 100 ),2) ) || '' AS TD_VS_LY_CUST_CNT, ]'
            || CHR(13) || CHR(10) || Q'[ '1' AS DIV ]'
            || CHR(13) || CHR(10) || Q'[  FROM ( ]'
            || CHR(13) || CHR(10) || Q'[      SELECT SEC_DIV, ]'
            || CHR(13) || CHR(10) || Q'[             SEC_DIV_NM, ]'
            || CHR(13) || CHR(10) || Q'[             GRD_AMT1   AS TD_SALE_AMT,  ]' -- 금일 실매출액
            || CHR(13) || CHR(10) || Q'[             BILL_CNT1  AS TD_CUST_CNT,     ]' -- 금일 고객수
            || CHR(13) || CHR(10) || Q'[             STOR_CNT1,  ]' -- 점포수
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT1) OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) TD_TOT_SALE_AMT,   ]' -- 금일 매출누계
            || CHR(13) || CHR(10) || Q'[             GRD_AMT2   AS LD_SALE_AMT,  ]' -- 전일 실매출액
            || CHR(13) || CHR(10) || Q'[             BILL_CNT2  AS LD_CUST_CNT,     ]' -- 전일 고객수
            || CHR(13) || CHR(10) || Q'[             STOR_CNT2,  ]' -- 점포수
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT2) OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) LD_TOT_SALE_AMT,   ]' -- 전일 매출누계
            || CHR(13) || CHR(10) || Q'[             GRD_AMT3   AS LW_SALE_AMT,  ]' -- 전주 실매출액
            || CHR(13) || CHR(10) || Q'[             BILL_CNT3  AS LW_CUST_CNT,     ]' -- 전주 고객수
            || CHR(13) || CHR(10) || Q'[             STOR_CNT3,  ]' -- 점포수
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT3) OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) LW_TOT_SALE_AMT,   ]' -- 전주 매출누계
            || CHR(13) || CHR(10) || Q'[             GRD_AMT4   AS LY_SALE_AMT,  ]' -- 전년 실매출액
            || CHR(13) || CHR(10) || Q'[             BILL_CNT4  AS LY_CUST_CNT,     ]' -- 전년 고객수
            || CHR(13) || CHR(10) || Q'[             STOR_CNT4,  ]' -- 점포수
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT4)  OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) LY_TOT_SALE_AMT,  ]' -- 전년 매출누계
            || CHR(13) || CHR(10) || Q'[             STOR_CNT5,  ]'
            || CHR(13) || CHR(10) || Q'[             STOR_CNT6,  ]'
            || CHR(13) || CHR(10) || Q'[             STOR_CNT7,  ]'
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT12)  OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) GRD_SAMT12, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT13)  OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) GRD_SAMT13, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT14)  OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) GRD_SAMT14, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT21)  OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) GRD_SAMT21, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT31)  OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) GRD_SAMT31, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(GRD_AMT41)  OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) GRD_SAMT41, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(BILL_CNT12) OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) BILL_CNT12, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(BILL_CNT13) OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) BILL_CNT13, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(BILL_CNT14) OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) BILL_CNT14, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(BILL_CNT21) OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) BILL_CNT21, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(BILL_CNT31) OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) BILL_CNT31, ]'
            || CHR(13) || CHR(10) || Q'[             SUM(BILL_CNT41) OVER (ORDER BY SEC_DIV RANGE UNBOUNDED PRECEDING) BILL_CNT41, ]'
            || CHR(13) || CHR(10) || Q'[             :PSV_GFR_DATE                                                   AS DATE1,     ]'-- 금일
            || CHR(13) || CHR(10) || Q'[             TO_CHAR( TO_DATE(:PSV_GFR_DATE ,'YYYYMMDD') - 1   , 'YYYYMMDD') AS DATE2,     ]'-- 전일
            || CHR(13) || CHR(10) || Q'[             TO_CHAR( TO_DATE(:PSV_GFR_DATE ,'YYYYMMDD') - 7   , 'YYYYMMDD') AS DATE3,     ]'-- 전주
            || CHR(13) || CHR(10) || Q'[             TO_CHAR( TO_DATE(:PSV_GFR_DATE ,'YYYYMMDD') - 364 , 'YYYYMMDD') AS DATE4,     ]'-- 전년
            || CHR(13) || CHR(10) || Q'[             DECODE(STOR_CNT1,0,0, GRD_AMT1/STOR_CNT1 )  AS TD_AVG_SALE_AMT,     ]' -- 점일 평균매출
            || CHR(13) || CHR(10) || Q'[             DECODE(STOR_CNT2,0,0, GRD_AMT2/STOR_CNT2 )  AS LD_AVG_SALE_AMT,     ]' -- 점일 평균매출
            || CHR(13) || CHR(10) || Q'[             DECODE(STOR_CNT3,0,0, GRD_AMT3/STOR_CNT3 )  AS LW_AVG_SALE_AMT,     ]' -- 점일 평균매출
            || CHR(13) || CHR(10) || Q'[             DECODE(STOR_CNT4,0,0, GRD_AMT4/STOR_CNT4 )  AS LY_AVG_SALE_AMT      ]' -- 점일 평균매출
            || CHR(13) || CHR(10) || Q'[        FROM ( ]'
            || CHR(13) || CHR(10) || Q'[            WITH ST1    AS ]'
            || CHR(13) || CHR(10) || Q'[            ( ]'
            || CHR(13) || CHR(10) || Q'[              SELECT A.COMP_CD, A.BRAND_CD, A.STOR_CD ]'
            || CHR(13) || CHR(10) || Q'[                FROM SALE_JDS A                   ]'
            || CHR(13) || CHR(10) || Q'[                   , S_STORE  B                   ]'
            || CHR(13) || CHR(10) || Q'[               WHERE A.SALE_DT  = :PSV_GFR_DATE   ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.COMP_CD  = B.COMP_CD       ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.BRAND_CD = B.BRAND_CD      ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.STOR_CD  = B.STOR_CD       ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.COMP_CD  = :PSV_COMP_CD    ]'
            || CHR(13) || CHR(10) || Q'[               GROUP BY A.COMP_CD, A.BRAND_CD, A.STOR_CD ]'
            || CHR(13) || CHR(10) || Q'[            ), ]'
            || CHR(13) || CHR(10) || Q'[            ST2    AS ]'
            || CHR(13) || CHR(10) || Q'[            ( ]'
            || CHR(13) || CHR(10) || Q'[              SELECT A.COMP_CD, A.BRAND_CD, A.STOR_CD ]'
            || CHR(13) || CHR(10) || Q'[                FROM SALE_JDS A                   ]'
            || CHR(13) || CHR(10) || Q'[                   , S_STORE  B                   ]'
            || CHR(13) || CHR(10) || Q'[               WHERE A.SALE_DT  = TO_CHAR(TO_DATE(:PSV_GFR_DATE,'YYYYMMDD') - 1 , 'YYYYMMDD') ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.COMP_CD  = B.COMP_CD       ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.BRAND_CD = B.BRAND_CD      ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.STOR_CD  = B.STOR_CD       ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.COMP_CD  = :PSV_COMP_CD    ]'
            || CHR(13) || CHR(10) || Q'[               GROUP BY A.COMP_CD, A.BRAND_CD, A.STOR_CD ]'
            || CHR(13) || CHR(10) || Q'[            ), ]'
            || CHR(13) || CHR(10) || Q'[            ST3    AS ]'
            || CHR(13) || CHR(10) || Q'[            ( ]'
            || CHR(13) || CHR(10) || Q'[              SELECT A.COMP_CD, A.BRAND_CD, A.STOR_CD ]'
            || CHR(13) || CHR(10) || Q'[                FROM SALE_JDS A                   ]'
            || CHR(13) || CHR(10) || Q'[                   , S_STORE  B                   ]'
            || CHR(13) || CHR(10) || Q'[               WHERE A.SALE_DT  = TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 7 , 'YYYYMMDD') ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.COMP_CD  = B.COMP_CD       ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.BRAND_CD = B.BRAND_CD      ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.STOR_CD  = B.STOR_CD       ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.COMP_CD  = :PSV_COMP_CD    ]'
            || CHR(13) || CHR(10) || Q'[               GROUP BY A.COMP_CD, A.BRAND_CD, A.STOR_CD ]'
            || CHR(13) || CHR(10) || Q'[            ), ]'
            || CHR(13) || CHR(10) || Q'[            ST4    AS ]'
            || CHR(13) || CHR(10) || Q'[            ( ]'
            || CHR(13) || CHR(10) || Q'[              SELECT A.COMP_CD, A.BRAND_CD, A.STOR_CD ]'
            || CHR(13) || CHR(10) || Q'[                FROM SALE_JDS A                   ]'
            || CHR(13) || CHR(10) || Q'[                   , S_STORE  B                   ]'
            || CHR(13) || CHR(10) || Q'[               WHERE A.SALE_DT  = TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 364 , 'YYYYMMDD') ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.COMP_CD  = B.COMP_CD       ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.BRAND_CD = B.BRAND_CD      ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.STOR_CD  = B.STOR_CD       ]'
            || CHR(13) || CHR(10) || Q'[                 AND A.COMP_CD  = :PSV_COMP_CD    ]'
            || CHR(13) || CHR(10) || Q'[               GROUP BY A.COMP_CD, A.BRAND_CD, A.STOR_CD ]'
            || CHR(13) || CHR(10) || Q'[            ) ]'
            || CHR(13) || CHR(10) || Q'[            SELECT SS.SEC_DIV, ]'
            || CHR(13) || CHR(10) || Q'[                   NVL(LC.CODE_NM,C.CODE_NM) AS SEC_DIV_NM, ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT1,   ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT1,  ]'
            || CHR(13) || CHR(10) || Q'[                   SC.STOR_CNT1,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT2,   ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT2,  ]'
            || CHR(13) || CHR(10) || Q'[                   SC.STOR_CNT2,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT3,   ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT3,  ]'
            || CHR(13) || CHR(10) || Q'[                   SC.STOR_CNT3,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT4,   ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT4,  ]'
            || CHR(13) || CHR(10) || Q'[                   SC.STOR_CNT4,  ]'
            || CHR(13) || CHR(10) || Q'[                   SC.STOR_CNT5,  ]'
            || CHR(13) || CHR(10) || Q'[                   SC.STOR_CNT6,  ]'
            || CHR(13) || CHR(10) || Q'[                   SC.STOR_CNT7,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT12,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT13,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT14,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT21,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT31,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.GRD_AMT41,  ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT12, ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT13, ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT14, ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT21, ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT31, ]'
            || CHR(13) || CHR(10) || Q'[                   SS.BILL_CNT41  ]'
            || CHR(13) || CHR(10) || Q'[              FROM                ]'
            || CHR(13) || CHR(10) || Q'[                (                 ]'
            || CHR(13) || CHR(10) || Q'[                SELECT SUM(NVL2(B.STOR_CD,1,0))     AS STOR_CNT1,  ]'
            || CHR(13) || CHR(10) || Q'[                       SUM(NVL2(C.STOR_CD,1,0))     AS STOR_CNT2,  ]'
            || CHR(13) || CHR(10) || Q'[                       SUM(NVL2(D.STOR_CD,1,0))     AS STOR_CNT3,  ]'
            || CHR(13) || CHR(10) || Q'[                       SUM(NVL2(E.STOR_CD,1,0))     AS STOR_CNT4,  ]'
            || CHR(13) || CHR(10) || Q'[                       SUM(NVL2(F.STOR_CD,1,0))     AS STOR_CNT5,  ]'
            || CHR(13) || CHR(10) || Q'[                       SUM(NVL2(G.STOR_CD,1,0))     AS STOR_CNT6,  ]'
            || CHR(13) || CHR(10) || Q'[                       SUM(NVL2(H.STOR_CD,1,0))     AS STOR_CNT7   ]'
            || CHR(13) || CHR(10) || Q'[                 FROM S_STORE      A,                              ]'
            || CHR(13) || CHR(10) || Q'[                      ST1          B,                              ]'
            || CHR(13) || CHR(10) || Q'[                      ST2          C,                              ]'
            || CHR(13) || CHR(10) || Q'[                      ST3          D,                              ]'
            || CHR(13) || CHR(10) || Q'[                      ST4          E,                              ]'
            || CHR(13) || CHR(10) || Q'[                      (SELECT F1.COMP_CD, F1.BRAND_CD, F1.STOR_CD  ]'
            || CHR(13) || CHR(10) || Q'[                        FROM ST1 F1, ST2 F2                      ]'
            || CHR(13) || CHR(10) || Q'[                        WHERE F2.COMP_CD = F1.COMP_CD            ]'
            || CHR(13) || CHR(10) || Q'[                         AND F2.BRAND_CD = F1.BRAND_CD           ]'
            || CHR(13) || CHR(10) || Q'[                         AND F2.STOR_CD = F1.STOR_CD) F,         ]'
            || CHR(13) || CHR(10) || Q'[                      (SELECT G1.COMP_CD, G1.BRAND_CD, G1.STOR_CD   ]'
            || CHR(13) || CHR(10) || Q'[                        FROM ST1 G1, ST3 G2                      ]'
            || CHR(13) || CHR(10) || Q'[                        WHERE G2.COMP_CD = G1.COMP_CD            ]'
            || CHR(13) || CHR(10) || Q'[                         AND G2.BRAND_CD = G1.BRAND_CD           ]'
            || CHR(13) || CHR(10) || Q'[                         AND G2.STOR_CD = G1.STOR_CD) G,         ]'
            || CHR(13) || CHR(10) || Q'[                      (SELECT H1.COMP_CD, H1.BRAND_CD, H1.STOR_CD            ]'
            || CHR(13) || CHR(10) || Q'[                        FROM ST1 H1, ST4 H2                      ]'
            || CHR(13) || CHR(10) || Q'[                        WHERE H2.COMP_CD = H1.COMP_CD            ]'
            || CHR(13) || CHR(10) || Q'[                         AND H2.BRAND_CD = H1.BRAND_CD           ]'
            || CHR(13) || CHR(10) || Q'[                         AND H2.STOR_CD = H1.STOR_CD) H          ]'
            || CHR(13) || CHR(10) || Q'[                WHERE B.COMP_CD  (+) = A.COMP_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND B.BRAND_CD (+) = A.BRAND_CD                ]'
            || CHR(13) || CHR(10) || Q'[                  AND B.STOR_CD  (+) = A.STOR_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND C.COMP_CD  (+) = A.COMP_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND C.BRAND_CD (+) = A.BRAND_CD                ]'
            || CHR(13) || CHR(10) || Q'[                  AND C.STOR_CD  (+) = A.STOR_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND D.BRAND_CD (+) = A.BRAND_CD                ]'
            || CHR(13) || CHR(10) || Q'[                  AND D.COMP_CD  (+) = A.COMP_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND D.STOR_CD  (+) = A.STOR_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND E.COMP_CD  (+) = A.COMP_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND E.BRAND_CD (+) = A.BRAND_CD                ]'
            || CHR(13) || CHR(10) || Q'[                  AND E.STOR_CD  (+) = A.STOR_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND F.COMP_CD  (+) = A.COMP_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND F.BRAND_CD (+) = A.BRAND_CD                ]'
            || CHR(13) || CHR(10) || Q'[                  AND F.STOR_CD  (+) = A.STOR_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND G.COMP_CD  (+) = A.COMP_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND G.BRAND_CD (+) = A.BRAND_CD                ]'
            || CHR(13) || CHR(10) || Q'[                  AND G.STOR_CD  (+) = A.STOR_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND H.COMP_CD  (+) = A.COMP_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                  AND H.BRAND_CD (+) = A.BRAND_CD                ]'
            || CHR(13) || CHR(10) || Q'[                  AND H.STOR_CD  (+) = A.STOR_CD                 ]'
            || CHR(13) || CHR(10) || Q'[                ) SC ,                                           ]'
            || CHR(13) || CHR(10) || Q'[                (                                                ]'
            || CHR(13) || CHR(10) || Q'[                SELECT /*+ INDEX (A IDX01_SALE_JTS) */           ]'
            || CHR(13) || CHR(10) || Q'[                    A.COMP_CD            AS COMP_CD,             ]'
            || CHR(13) || CHR(10) || Q'[                    A.SEC_DIV            AS SEC_DIV,             ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, :PSV_GFR_DATE, DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT), 0))     AS BILL_CNT1,   ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, :PSV_GFR_DATE, DECODE(:PSV_FILTER  , 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT), 0)) AS GRD_AMT1, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 1  , 'YYYYMMDD'), DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT), 0))     AS BILL_CNT2, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 1  , 'YYYYMMDD'), DECODE(:PSV_FILTER  , 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT), 0)) AS GRD_AMT2, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 7  , 'YYYYMMDD'), DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT), 0))     AS BILL_CNT3, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 7  , 'YYYYMMDD'), DECODE(:PSV_FILTER  , 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT), 0)) AS GRD_AMT3, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 364, 'YYYYMMDD'), DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT), 0))     AS BILL_CNT4, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 364, 'YYYYMMDD'), DECODE(:PSV_FILTER  , 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT), 0)) AS GRD_AMT4, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, :PSV_GFR_DATE, NVL2(B.STOR_CD, DECODE(:PSV_FILTER, 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT),0), 0))    AS GRD_AMT12, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, :PSV_GFR_DATE, NVL2(C.STOR_CD, DECODE(:PSV_FILTER, 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT),0), 0))    AS GRD_AMT13, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, :PSV_GFR_DATE, NVL2(D.STOR_CD, DECODE(:PSV_FILTER, 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT),0), 0))    AS GRD_AMT14, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 1   ,  'YYYYMMDD'), NVL2(B.STOR_CD, DECODE(:PSV_FILTER, 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT),0), 0)) AS GRD_AMT21, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 7   ,  'YYYYMMDD'), NVL2(C.STOR_CD, DECODE(:PSV_FILTER, 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT),0), 0)) AS GRD_AMT31, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 364 ,  'YYYYMMDD'), NVL2(D.STOR_CD, DECODE(:PSV_FILTER, 'G', A.GRD_AMT, A.GRD_AMT - A.VAT_AMT),0), 0)) AS GRD_AMT41, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, :PSV_GFR_DATE, NVL2(B.STOR_CD, DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT),0), 0))     AS BILL_CNT12, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, :PSV_GFR_DATE, NVL2(C.STOR_CD, DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT),0), 0))     AS BILL_CNT13, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, :PSV_GFR_DATE, NVL2(D.STOR_CD, DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT),0), 0))     AS BILL_CNT14, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 1   ,  'YYYYMMDD'), NVL2(B.STOR_CD, DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT),0), 0))     AS BILL_CNT21, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 7   ,  'YYYYMMDD'), NVL2(C.STOR_CD, DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT),0), 0))     AS BILL_CNT31, ]'
            || CHR(13) || CHR(10) || Q'[                    SUM(DECODE(A.SALE_DT, TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 364 ,  'YYYYMMDD'), NVL2(D.STOR_CD, DECODE(:PSV_CUST_DIV, 'C', A.ETC_M_CNT + A.ETC_F_CNT, A.BILL_CNT - A.R_BILL_CNT),0), 0))     AS BILL_CNT41  ]'
            || CHR(13) || CHR(10) || Q'[                 FROM SALE_JTS A,                          ]'
            || CHR(13) || CHR(10) || Q'[                      S_STORE ST,                          ]'
            || CHR(13) || CHR(10) || Q'[                    (SELECT B1.COMP_CD, B1.BRAND_CD, B1.STOR_CD        ]'
            || CHR(13) || CHR(10) || Q'[                      FROM ST1 B1, ST2 B2                  ]'
            || CHR(13) || CHR(10) || Q'[                      WHERE B2.COMP_CD = B1.COMP_CD        ]'
            || CHR(13) || CHR(10) || Q'[                       AND B2.BRAND_CD = B1.BRAND_CD       ]'
            || CHR(13) || CHR(10) || Q'[                       AND B2.STOR_CD  = B1.STOR_CD) B,    ]'
            || CHR(13) || CHR(10) || Q'[                    (SELECT C1.COMP_CD, C1.BRAND_CD, C1.STOR_CD        ]'
            || CHR(13) || CHR(10) || Q'[                      FROM ST1 C1, ST3 C2                  ]'
            || CHR(13) || CHR(10) || Q'[                      WHERE C2.COMP_CD = C1.COMP_CD        ]'
            || CHR(13) || CHR(10) || Q'[                       AND C2.BRAND_CD = C1.BRAND_CD       ]'
            || CHR(13) || CHR(10) || Q'[                       AND C2.STOR_CD  = C1.STOR_CD) C,    ]'
            || CHR(13) || CHR(10) || Q'[                    (SELECT D1.COMP_CD, D1.BRAND_CD, D1.STOR_CD        ]'
            || CHR(13) || CHR(10) || Q'[                      FROM ST1 D1, ST4 D2                  ]'
            || CHR(13) || CHR(10) || Q'[                      WHERE D2.COMP_CD = D1.COMP_CD        ]'
            || CHR(13) || CHR(10) || Q'[                       AND D2.BRAND_CD = D1.BRAND_CD       ]'
            || CHR(13) || CHR(10) || Q'[                       AND D2.STOR_CD  = D1.STOR_CD) D     ]'
            || CHR(13) || CHR(10) || Q'[                WHERE A.COMP_CD   = ST.COMP_CD              ]'
            || CHR(13) || CHR(10) || Q'[                   AND A.BRAND_CD = ST.BRAND_CD             ]'
            || CHR(13) || CHR(10) || Q'[                  AND A.STOR_CD   = ST.STOR_CD              ]'
            || CHR(13) || CHR(10) || Q'[                  AND A.COMP_CD   = :PSV_COMP_CD            ]'
            || CHR(13) || CHR(10) || Q'[                  AND A.SEC_FG    = :PSV_SEC_FG             ]'
            || CHR(13) || CHR(10) || Q'[                  AND A.SALE_DT   IN (:PSV_GFR_DATE, :ls_date_1, :ls_date_7, :ls_date_364) ]'
            || CHR(13) || CHR(10) || Q'[                  AND B.COMP_CD   (+) = ST.COMP_CD          ]'
            || CHR(13) || CHR(10) || Q'[                  AND B.BRAND_CD  (+) = ST.BRAND_CD         ]'
            || CHR(13) || CHR(10) || Q'[                  AND B.STOR_CD   (+) = ST.STOR_CD          ]'
            || CHR(13) || CHR(10) || Q'[                  AND C.COMP_CD   (+) = ST.COMP_CD          ]'
            || CHR(13) || CHR(10) || Q'[                  AND C.BRAND_CD  (+) = ST.BRAND_CD         ]'
            || CHR(13) || CHR(10) || Q'[                  AND C.STOR_CD   (+) = ST.STOR_CD          ]'
            || CHR(13) || CHR(10) || Q'[                  AND D.COMP_CD   (+) = ST.COMP_CD          ]'
            || CHR(13) || CHR(10) || Q'[                  AND D.BRAND_CD  (+) = ST.BRAND_CD         ]'
            || CHR(13) || CHR(10) || Q'[                  AND D.STOR_CD   (+) = ST.STOR_CD          ]'
            || CHR(13) || CHR(10) || Q'[                GROUP BY  A.SEC_DIV                        ]'
            || CHR(13) || CHR(10) || Q'[                        , A.COMP_CD                        ]'
            || CHR(13) || CHR(10) || Q'[                ) SS                                       ]'
            || CHR(13) || CHR(10) || Q'[                , COMMON C                                 ]'
            || CHR(13) || CHR(10) || Q'[                , ( SELECT    CODE_TP, CODE_CD, CODE_NM    ]'
            || CHR(13) || CHR(10) || Q'[                      FROM  LANG_COMMON                    ]'
            || CHR(13) || CHR(10) || Q'[                     WHERE  COMP_CD = :PSV_COMP_CD         ]'
            || CHR(13) || CHR(10) || Q'[                       AND  CODE_TP  = '01385'             ]'
            || CHR(13) || CHR(10) || Q'[                       AND  LANGUAGE_TP = :PSV_LANG_CD     ]'
            || CHR(13) || CHR(10) || Q'[                       AND  USE_YN  = 'Y' )  LC            ]'
            || CHR(13) || CHR(10) || Q'[            WHERE SS.SEC_DIV = C.CODE_CD                   ]'
            || CHR(13) || CHR(10) || Q'[              AND SS.COMP_CD = C.COMP_CD                   ]'
            || CHR(13) || CHR(10) || Q'[              AND C.CODE_TP  = '01385'                     ]'
            || CHR(13) || CHR(10) || Q'[              AND C.CODE_CD  = LC.CODE_CD(+)               ]'
            || CHR(13) || CHR(10) || Q'[              AND C.CODE_TP  = LC.CODE_TP(+)               ]'
            || CHR(13) || CHR(10) || Q'[        ) T                                                ]'
            || CHR(13) || CHR(10) || Q'[    ) A                                                    ]'
         ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
           ls_sql 
           USING PSV_GFR_DATE, PSV_GFR_DATE, PSV_GFR_DATE, PSV_GFR_DATE, 
                 PSV_GFR_DATE, PSV_COMP_CD,  
                 PSV_GFR_DATE, PSV_COMP_CD,
                 PSV_GFR_DATE, PSV_COMP_CD,
                 PSV_GFR_DATE, PSV_COMP_CD,
                 PSV_GFR_DATE, PSV_CUST_DIV, 
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_CUST_DIV,
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_CUST_DIV,
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_CUST_DIV,
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_FILTER,
                 PSV_GFR_DATE, PSV_CUST_DIV,
                 PSV_GFR_DATE, PSV_CUST_DIV,
                 PSV_GFR_DATE, PSV_CUST_DIV,
                 PSV_GFR_DATE, PSV_CUST_DIV,
                 PSV_GFR_DATE, PSV_CUST_DIV,
                 PSV_GFR_DATE, PSV_CUST_DIV,
                 PSV_COMP_CD,  PSV_SEC_FG, PSV_GFR_DATE, ls_date_1, ls_date_7, ls_date_364,
                 PSV_COMP_CD,  PSV_LANG_CD;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END ;
END PKG_SALE4032;

/
