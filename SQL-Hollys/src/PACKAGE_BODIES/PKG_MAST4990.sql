--------------------------------------------------------
--  DDL for Package Body PKG_MAST4990
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MAST4990" AS

---------------------------------------------------------------------------------------------------
-- Package Name : PKG_MAST4990
-- Description : Package Body
-- Ref. Table :
---------------------------------------------------------------------------------------------------
-- Create Date : 2013-03-18
-- Create Programer : 나기호
-- Modify Date : 2013-03-18
-- Modify Programer :
---------------------------------------------------------------------------------------------------


PROCEDURE SP_GIFT_STOCK
(
    PSV_LANG_CD IN VARCHAR2 , -- Language Code
    PSV_BRAND_CD IN VARCHAR2 , -- BRAND_CD
    PSV_FR_DT IN VARCHAR2 ,
    PSV_TO_DT IN VARCHAR2 ,
    PSV_GIFT_CD IN VARCHAR2 ,
    PR_RESULT IN OUT PKG_REPORT.REF_CUR , -- Result Set
    PR_RTN_CD OUT VARCHAR2 , -- 처리코드
    PR_RTN_MSG OUT VARCHAR2 -- 처리Message -- 처리Message
)
IS
ls_date_fr VARCHAR2(8);
ls_date_to VARCHAR2(8);

ls_gift_cd VARCHAR2(5);

ln_cnt NUMBER(5);

ls_err_cd VARCHAR2(7) := '0' ;
ls_err_msg VARCHAR2(500) ;

ERR_HANDLER EXCEPTION;

BEGIN
    dbms_output.enable( 1000000 ) ;


    ls_date_fr := psv_fr_dt ;
    ls_date_to := psv_to_dt ;

    ls_gift_cd := CASE WHEN PSV_GIFT_CD = 'ALL' OR PSV_GIFT_CD = '' THEN '%' ELSE PSV_GIFT_CD END;

    OPEN PR_RESULT FOR
        SELECT  A.GIFT_CD,
                '[' || A.GIFT_CD || ']' || ' ' || B.GIFT_NM AS GIFT_NM,
                CASE WHEN GRP_ID = 0 THEN SUBSTR(A.PROC_DT, 1, 4) || '-' || SUBSTR(A.PROC_DT, 5, 2) || '-' || SUBSTR(A.PROC_DT, 7, 2)
                     ELSE FC_GET_WORDPACK(PSV_LANG_CD, 'SUB_SUM') END PROC_DT ,
                CASE WHEN GRP_ID = 0 THEN
                        LAG (A.STOCK_QTY, 1, PRE_STOCK_QTY) OVER (PARTITION BY A.GIFT_CD ORDER BY A.PROC_DT)
                     ELSE FIRST_VALUE (PRE_STOCK_QTY) OVER (PARTITION BY A.GIFT_CD ORDER BY A.PROC_DT ) END PRE_STOCK_QTY,
                A.IN_QTY,
                A.OUT_QTY,
                A.RTN_QTY,
                A.INOUT_QTY,
                CASE WHEN GRP_ID = 0 THEN A.STOCK_QTY
                     ELSE LAG (A.STOCK_QTY, 1, STOCK_QTY) OVER (PARTITION BY A.GIFT_CD ORDER BY A.PROC_DT) END STOCK_QTY
          FROM (
                    SELECT  GIFT_CD,
                            PROC_DT,
                            SUM(IN_QTY) IN_QTY,
                            SUM(OUT_QTY) OUT_QTY ,
                            SUM(RTN_QTY) RTN_QTY,
                            SUM(INOUT_QTY) INOUT_QTY,
                            SUM(STOCK_QTY) STOCK_QTY,
                            SUM(PRE_STOCK_QTY) PRE_STOCK_QTY ,
                            GROUPING_ID(A.GIFT_CD , A.PROC_DT) GRP_ID
                      FROM  (
                                SELECT  A.PROC_DT,
                                        A.GIFT_CD,
                                        A.IN_QTY,
                                        A.OUT_QTY,
                                        A.INOUT_QTY,
                                        A.RTN_QTY,
                                        A.STOCK_QTY + NVL (B.PRE_STOCK_QTY, 0) STOCK_QTY,
                                        NVL (B.PRE_STOCK_QTY, 0) PRE_STOCK_QTY
                                  FROM  (
                                            SELECT  A.PROC_DT,
                                                    A.GIFT_CD,
                                                    A.IN_QTY,
                                                    A.OUT_QTY,
                                                    A.RTN_QTY,
                                                    (A.IN_QTY - A.OUT_QTY + A.RTN_QTY) INOUT_QTY,
                                                    SUM (A.IN_QTY - OUT_QTY + A.RTN_QTY)
                                                    OVER (PARTITION BY A.GIFT_CD ORDER BY A.PROC_DT)    AS STOCK_QTY
                                              FROM  GIFT_STOCK A
                                             WHERE  A.PROC_DT BETWEEN ls_date_fr AND ls_date_to
                                        ) A,
                                        (
                                            SELECT  GIFT_CD,
                                                    NVL (SUM (IN_QTY - OUT_QTY + RTN_QTY), 0)
                                                    PRE_STOCK_QTY
                                              FROM  GIFT_STOCK
                                             WHERE  PROC_DT < ls_date_fr
                                             GROUP BY GIFT_CD
                                        ) B
                                 WHERE  A.GIFT_CD = B.GIFT_CD(+)
                                   AND  A.GIFT_CD LIKE ls_gift_cd
                            ) A
                 GROUP BY GROUPING SETS ( (A.GIFT_CD , A.PROC_DT ), (A.GIFT_CD) )
            ) A,
            GIFT_CODE_MST B
        WHERE A.GIFT_CD = B.GIFT_CD ;

        PR_RTN_CD := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXCEPTION
            WHEN ERR_HANDLER THEN
                PR_RTN_CD := ls_err_cd;
                PR_RTN_MSG := ls_err_msg ;
                dbms_output.put_line( PR_RTN_MSG ) ;
            WHEN OTHERS THEN
                PR_RTN_CD := '4999999' ;
                PR_RTN_MSG := SQLERRM ;
                dbms_output.put_line( PR_RTN_MSG ) ;
END ;


PROCEDURE SP_GIFT_STOCK_DT
(
    PSV_LANG_CD IN VARCHAR2 , -- Language Code
    PSV_BRAND_CD IN VARCHAR2 , -- BRAND_CD
    PSV_DT IN VARCHAR2 ,
    PSV_GIFT_CD IN VARCHAR2 ,
    PR_RESULT IN OUT PKG_REPORT.REF_CUR , -- Result Set
    PR_RTN_CD OUT VARCHAR2 , -- 처리코드
    PR_RTN_MSG OUT VARCHAR2 -- 처리Message -- 처리Message
)
IS
ls_date VARCHAR2(8);
ln_cnt NUMBER(5);


ls_err_cd VARCHAR2(7) := '0' ;
ls_err_msg VARCHAR2(500) ;
ERR_HANDLER EXCEPTION;

BEGIN
    dbms_output.enable( 1000000 ) ;


    ls_date := psv_dt ;


    OPEN PR_RESULT FOR
        SELECT  SUBSTR(A.IN_DT, 1, 4) || '-' || SUBSTR(A.IN_DT, 5, 2) || '-' || SUBSTR(A.IN_DT, 7, 2) IN_DT,
                A.GUBUN,
                A.IN_SEQ,
                A.GIFT_NO_FROM,
                A.GIFT_NO_TO,
                B.CODE_NM GIFT_STAT,
                A.BRAND_CD,
                A.STOR_CD ,
                D.STOR_NM ,
                A.CUSTOMER
          FROM  (
                    SELECT  FC_GET_WORDPACK(PSV_LANG_CD, 'IN') GUBUN,
                            '1' GUBUN_CD,
                            A.IN_DT,
                            A.IN_SEQ,
                            A.GIFT_NO_FROM,
                            A.GIFT_NO_TO,
                            '' GIFT_STAT_CD,
                            '' SALE_TP,
                            '' BRAND_CD,
                            '' STOR_CD,
                            '' CUSTOMER
                      FROM  GIFT_IN_HD A
                     WHERE  A.CONFIRM_YN = 'Y'
                       AND A.USE_YN = 'Y'
                       AND A.IN_DT = ls_date
                       AND A.GIFT_CD = psv_gift_cd
                    UNION ALL
                    SELECT  FC_GET_WORDPACK(PSV_LANG_CD, 'SALE') GUBUN,
                            '2' GUBUN_CD,
                            A.SALE_DT AS IN_DT,
                            A.SALE_SEQ AS IN_SEQ,
                            C.GIFT_NO GIFT_NO_FR,
                            '' GIFT_NO_TO,
                            C.GIFT_STAT_CD,
                            A.GIFT_SALE_TP,
                            A.BRAND_CD,
                            A.STOR_CD,
                            A.CUSTOMER
                      FROM  GIFT_SALE A, GIFT_MST C
                     WHERE  A.SALE_DT = C.SALE_DT
                       AND  A.SALE_SEQ = C.SALE_SEQ
                       AND  A.GIFT_CD = C.GIFT_CD
                       AND  A.SALE_DT = ls_date
                       AND  A.GIFT_CD = psv_gift_cd
                    UNION ALL
                    SELECT  FC_GET_WORDPACK(PSV_LANG_CD, 'RETURN') GUBUN,
                            '3' GUBUN_CD,
                            A.RTN_DT AS IN_DT,
                            ' ' AS IN_SEQ,
                            C.GIFT_NO GIFT_NO_FR,
                            '' GIFT_NO_TO,
                            C.GIFT_STAT_CD,
                            '' SALE_TP,
                            A.BRAND_CD,
                            A.STOR_CD,
                            '' CUSTOMER
                      FROM  GIFT_UNSOLD A, GIFT_MST C
                     WHERE  C.GIFT_CD = psv_gift_cd
                       AND  A.RTN_DT = ls_date
                       AND  A.GIFT_NO = C.GIFT_NO
                       AND  C.GIFT_STAT_CD IN ('1', '4')
                ) A,
                COMMON B ,
                BRAND C ,
                STORE D
        WHERE   B.CODE_TP = '00185'
          AND   A.GIFT_STAT_CD = B.CODE_CD (+)
          AND   A.BRAND_CD = C.BRAND_CD (+)
          AND   A.BRAND_CD = D.BRAND_CD (+)
          AND   A.STOR_CD = D.STOR_CD (+)
        ORDER BY IN_DT, GUBUN_CD , IN_SEQ , GIFT_NO_FROM;

    PR_RTN_CD := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG ) ;
        WHEN OTHERS THEN
            PR_RTN_CD := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
END ;


END PKG_MAST4990 ;

/
