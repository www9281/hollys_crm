--------------------------------------------------------
--  DDL for Package Body PKG_MEPA1020
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MEPA1020" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹        
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 종료일자
        PSV_CUST_LVL    IN  VARCHAR2 ,                -- 고객등급
        PSV_CUST_SEX    IN  VARCHAR2 ,                -- 고객성별
        PSV_CUST_AGE    IN  VARCHAR2 ,                -- 고객연령대
        PSV_CUST_ID     IN  VARCHAR2 ,                -- 고객아이디
        PSV_CARD_ID     IN  VARCHAR2 ,                -- 고객카드번호
        PSV_MOBLIE      IN  VARCHAR2 ,                -- 고객핸드폰번호
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN      회원별 포인트 적립현황
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-24         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-03-24
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);

    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM

    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_sql_cm01740  VARCHAR2(1000) ;    -- 공통코드SQL
    ls_sql_cm00435  VARCHAR2(1000) ;    -- 공통코드SQL
    ERR_HANDLER         EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm01740 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01740') ;
        ls_sql_cm00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00435') ;
        -------------------------------------------------------------------------------

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  /*+ NO_MERGE LEADING(V02) */ ]'
        ||CHR(13)||CHR(10)||Q'[         V02.USE_DT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  decrypt(V02.CARD_ID) AS CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  decrypt(V02.CUST_NM) AS CUST_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V02.BILL_NO IS NULL THEN FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ADMIN_YN')||' '||FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SUB_TOUCH_08') ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE V02.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[         END  AS STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.POS_NO ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.BILL_NO ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.SALE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM00435.CODE_NM           AS SALE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.DC_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.SAV_USE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM01740.CODE_NM           AS SAV_USE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[           SELECT  /*+ NO_MERGE LEADING(V01) */ ]'
        ||CHR(13)||CHR(10)||Q'[                   V01.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.CUST_NM ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.USE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SDT.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.POS_NO ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.BILL_NO ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SDT.SALE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SDT.SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SDT.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SDT.SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SDT.SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SDT.DC_AMT + SDT.ENR_AMT AS DC_AMT ]' 
        ||CHR(13)||CHR(10)||Q'[                ,  SDT.GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  V01.SAV_USE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                ,  TRUNC(SDT.SAV_PT * V01.POINT_S / 100) AS SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[             FROM  SALE_DT   SDT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  ( ]'
        ||CHR(13)||CHR(10)||Q'[                    SELECT  /*+ NO_MERGE LEADING(C) */ ]'
        ||CHR(13)||CHR(10)||Q'[                            C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  C.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  C.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  S.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  C.POS_NO ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  C.BILL_NO ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  C.CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  C02.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  C02.CUST_NM ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  C.USE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  MAX(C.SAV_USE_DIV)    AS SAV_USE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  SUM(C.SAV_PT)         AS SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  MAX(P.POINT_S)        AS POINT_S ]'
        ||CHR(13)||CHR(10)||Q'[                      FROM  POINT_LOG         P ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  C_CARD_SAV_HIS    C ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  S_STORE           S ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  ( ]'
        ||CHR(13)||CHR(10)||Q'[                              SELECT  /*+ NO_MERGE LEADING(C01) */ ]'
        ||CHR(13)||CHR(10)||Q'[                                      C01.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                   ,  C01.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                                   ,  C01.CUST_NM ]'
        ||CHR(13)||CHR(10)||Q'[                                   ,  CRD.CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[                                   ,  GET_AGE_GROUP(C01.COMP_CD, C01.CUST_AGE) AGE_GROUP ]'
        ||CHR(13)||CHR(10)||Q'[                                FROM  C_CARD CRD ]'
        ||CHR(13)||CHR(10)||Q'[                                   ,  ( ]'
        ||CHR(13)||CHR(10)||Q'[                                         SELECT  CST.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                              ,  CST.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                                              ,  CST.CUST_NM ]'
        ||CHR(13)||CHR(10)||Q'[                                              ,  CST.LVL_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                              ,  CASE WHEN REGEXP_INSTR(CASE WHEN CST.LUNAR_DIV = 'L' THEN UF_LUN2SOL(CST.BIRTH_DT, '0') ELSE CST.BIRTH_DT END, '^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])') = 1 ]'
        ||CHR(13)||CHR(10)||Q'[                                                      THEN  TRUNC((TO_NUMBER(SUBSTR(:PSV_GTO_DATE, 1, 6)) - TO_NUMBER(SUBSTR(CASE WHEN CST.LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE CST.BIRTH_DT END, 1, 6))) / 100 + 1) ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ELSE 999 ]' 
        ||CHR(13)||CHR(10)||Q'[                                                 END AS CUST_AGE ]'
        ||CHR(13)||CHR(10)||Q'[                                           FROM  C_CUST     CST ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHERE  CST.COMP_CD = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                            AND  (:PSV_CUST_ID IS NULL OR CST.CUST_ID = :PSV_CUST_ID) ]'
        ||CHR(13)||CHR(10)||Q'[                                            AND  (:PSV_CUST_LVL IS NULL OR CST.LVL_CD = :PSV_CUST_LVL) ]'
        ||CHR(13)||CHR(10)||Q'[                                            AND  (:PSV_CUST_SEX IS NULL OR CST.SEX_DIV = :PSV_CUST_SEX) ]'
        ||CHR(13)||CHR(10)||Q'[                                            AND  (:PSV_MOBLIE IS NULL OR CST.MOBILE = encrypt(REPLACE(:PSV_MOBLIE,'-',''))) ]'
        ||CHR(13)||CHR(10)||Q'[                                      )  C01 ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHERE  C01.COMP_CD = CRD.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  C01.CUST_ID = CRD.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  (:PSV_CARD_ID IS NULL OR CRD.CARD_ID = :PSV_CARD_ID) ]'
        ||CHR(13)||CHR(10)||Q'[                             ) C02 ]'
        ||CHR(13)||CHR(10)||Q'[                      WHERE  C.COMP_CD  = P.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.USE_DT   = P.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.BRAND_CD = P.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.STOR_CD  = P.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.POS_NO   = P.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.BILL_NO  = P.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  TO_CHAR(C.USE_SEQ)  = P.APPR_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.BRAND_CD = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.COMP_CD  = C02.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.CARD_ID  = C02.CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.USE_DT  >= :PSV_GFR_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.USE_DT  <= :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  (:PSV_CARD_ID IS NULL OR C.CARD_ID  = encrypt(:PSV_CARD_ID)) ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  C.SAV_USE_FG = '1' ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  (:PSV_CUST_AGE IS NULL OR C02.AGE_GROUP = :PSV_CUST_AGE) ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  '68'         = P.PAY_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  'Y'          = P.USE_YN ]' 
        ||CHR(13)||CHR(10)||Q'[                      GROUP  BY C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  C.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  C.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  S.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  C.POS_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  C.BILL_NO ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  C.CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  C02.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  C02.CUST_NM ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  C.USE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                   ) V01 ]'
        ||CHR(13)||CHR(10)||Q'[            WHERE  V01.USE_DT   = SDT.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[              AND  V01.COMP_CD  = SDT.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              AND  V01.BRAND_CD = SDT.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[              AND  V01.STOR_CD  = SDT.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              AND  V01.POS_NO   = SDT.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[              AND  V01.BILL_NO  = SDT.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[              AND  0           <> SDT.SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[         ) V02 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ]' || ls_sql_cm00435 || Q'[ CM00435 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ]' || ls_sql_cm01740 || Q'[ CM01740 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM I ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V02.SALE_DIV     = CM00435.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V02.SAV_USE_DIV  = CM01740.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V02.ITEM_CD      = I.ITEM_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V02.USE_DT DESC ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.POS_NO  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.BILL_NO ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V02.SEQ ]';


        ls_sql := ''||CHR(13)||CHR(10)|| ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,  
                         PSV_GTO_DATE,
                         PSV_COMP_CD, 
                         PSV_CUST_ID,  PSV_CUST_ID,
                         PSV_CUST_LVL, PSV_CUST_LVL, 
                         PSV_CUST_SEX, PSV_CUST_SEX,
                         PSV_MOBLIE,   PSV_MOBLIE,
                         PSV_CARD_ID,  PSV_CARD_ID,
                         PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_CARD_ID,  PSV_CARD_ID,
                         PSV_CUST_AGE, PSV_CUST_AGE;

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

END PKG_MEPA1020;

/
