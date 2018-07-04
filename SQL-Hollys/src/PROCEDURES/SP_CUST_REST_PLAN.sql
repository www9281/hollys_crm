--------------------------------------------------------
--  DDL for Procedure SP_CUST_REST_PLAN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CUST_REST_PLAN" /* 회원 휴면 예정 처리 */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_PLAN_DT     IN  VARCHAR2 ,                -- 예정일자
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_CUST_REST_PLAN      회원 휴면 예정 처리
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-06-17         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_CUST_REST_PLAN
      SYSDATE: 
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ERR_HANDLER     EXCEPTION;

    CURSOR CUR_1 IS
        WITH W1 AS 
       (
        SELECT  /*+ NO_MERGE INDEX(CST IDX05_C_CUST)*/
                CST.COMP_CD
             ,  CST.CUST_ID
             ,  DECRYPT(CST.CUST_NM)                          AS CUST_NM
             ,  CST.EMAIL                                     AS EMAIL
             ,  FN_GET_CUST_LAST_DT(CST.COMP_CD, CST.CUST_ID) AS PLAN_DT
             ,  '8'                                           AS PRC_DIV
             ,  DECRYPT(CST.MOBILE)                           AS MOBILE
             ,  BRAND_CD
             ,  STOR_CD
             ,  MEMBER_NO
        FROM    C_CUST      CST
        WHERE   CST.COMP_CD  = PSV_COMP_CD
        AND     CST.CUST_STAT= '2'
        AND     CST.JOIN_DT  < TO_CHAR(SYSDATE - 335, 'YYYYMMDD')
        AND     CST.SAV_CASH = CST.USE_CASH
        AND    (CST.LAST_LOGIN_DT IS NULL OR CST.LAST_LOGIN_DT <= SYSDATE - 335)
       )
        SELECT  COMP_CD
             ,  CUST_ID
             ,  CUST_NM
             ,  EMAIL
             ,  PLAN_DT
             ,  TO_CHAR(TO_DATE(PLAN_DT, 'YYYYMMDD')    , 'YYYY"년"MM"월"DD"일"') PLAN_DT_NM
             ,  TO_CHAR(TO_DATE(PLAN_DT, 'YYYYMMDD') - 1, 'YYYY"년"MM"월"DD"일"') LIMIT_DT_NM
             ,  PRC_DIV
             ,  MOBILE
             ,  BRAND_CD
             ,  STOR_CD
             ,  STOR_NM
             ,  TEL_NO
             ,  MEMBER_NO
        FROM   (
                SELECT  CST.COMP_CD
                     ,  CST.CUST_ID
                     ,  CST.CUST_NM
                     ,  CST.EMAIL
                     ,  CASE WHEN CST.PLAN_DT < TO_CHAR(SYSDATE + 7, 'YYYYMMDD') THEN TO_CHAR(SYSDATE + 7, 'YYYYMMDD') ELSE CST.PLAN_DT END PLAN_DT
                     ,  CST.PRC_DIV
                     ,  CST.MOBILE
                     ,  CST.BRAND_CD
                     ,  CST.STOR_CD
                     ,  STO.STOR_NM
                     ,  REPLACE(STO.TEL_NO, '-', '') AS TEL_NO
                     ,  CST.MEMBER_NO
                FROM    W1      CST
                     ,  STORE   STO
                WHERE   CST.COMP_CD  = STO.COMP_CD
                AND     CST.BRAND_CD = STO.BRAND_CD
                AND     CST.STOR_CD  = STO.STOR_CD
                AND     NOT EXISTS (                 -- 충전이력이 1년 미만(30일전 체크)
                                    SELECT  1
                                    FROM    C_CARD_CHARGE_HIS HIS
                                          , C_CARD            CRD
                                    WHERE   CRD.COMP_CD   = CST.COMP_CD
                                    AND     CRD.CUST_ID   = CST.CUST_ID
                                    AND     CRD.COMP_CD   = HIS.COMP_CD
                                    AND     CRD.CARD_ID   = HIS.CARD_ID
                                    AND     HIS.CRG_DT   >= TO_CHAR(SYSDATE - 335, 'YYYYMMDD')
                                    AND     HIS.CRG_DT   <= TO_CHAR(SYSDATE      , 'YYYYMMDD')
                                    AND     HIS.USE_YN    = 'Y'
                                   )
                AND     NOT EXISTS (                 -- 마일리지적립이력이 1년 미만(30일전 체크)
                                    SELECT  /*+ LEADING(CRD) INDEX(HIS PK_C_CARD_USE_HIS) */
                                            1
                                    FROM    C_CARD_SAV_HIS    HIS
                                          , C_CARD            CRD
                                    WHERE   CRD.COMP_CD   = CST.COMP_CD
                                    AND     CRD.CUST_ID   = CST.CUST_ID
                                    AND     CRD.COMP_CD   = HIS.COMP_CD
                                    AND     CRD.CARD_ID   = HIS.CARD_ID
                                    AND     HIS.USE_DT   >= TO_CHAR(SYSDATE - 335, 'YYYYMMDD')
                                    AND     HIS.USE_DT   <= TO_CHAR(SYSDATE      , 'YYYYMMDD')
                                    AND     HIS.USE_YN    = 'Y'
                                   )
                AND     NOT EXISTS (                 -- 사용이력이 1년 미만(30일전 체크)
                                    SELECT  1
                                    FROM    C_CARD_USE_HIS    HIS
                                          , C_CARD            CRD
                                    WHERE   CRD.COMP_CD   = CST.COMP_CD
                                    AND     CRD.CUST_ID   = CST.CUST_ID
                                    AND     CRD.COMP_CD   = HIS.COMP_CD
                                    AND     CRD.CARD_ID   = HIS.CARD_ID
                                    AND     HIS.USE_DT   >= TO_CHAR(SYSDATE - 335, 'YYYYMMDD')
                                    AND     HIS.USE_DT   <= TO_CHAR(SYSDATE      , 'YYYYMMDD')
                                    AND     HIS.USE_YN    = 'Y'
                                   )
                AND     NOT EXISTS (                 -- 쿠폰사용이력이 1년 미만(30일전 체크)
                                    SELECT  1
                                    FROM    C_COUPON_CUST     CCC
                                    WHERE   CCC.COMP_CD   = CST.COMP_CD
                                    AND     CCC.CUST_ID   = CST.CUST_ID
                                    AND     CCC.USE_DT   >= TO_CHAR(SYSDATE - 335, 'YYYYMMDD')
                                    AND     CCC.USE_DT   <= TO_CHAR(SYSDATE      , 'YYYYMMDD')
                                    AND     CCC.USE_STAT != '32'
                                   )
                AND     NOT EXISTS (                 -- 입장내역 확인
                                    SELECT  1
                                    FROM    CS_ENTRY_HD  ENT
                                    WHERE   ENT.COMP_CD   = CST.COMP_CD
                                    AND     ENT.MEMBER_NO = CST.CUST_ID
                                    AND     ENT.ENTRY_DT >= TO_CHAR(SYSDATE - 335, 'YYYYMMDD')
                                    AND     ENT.ENTRY_DT <= TO_CHAR(SYSDATE      , 'YYYYMMDD')
                                    AND     ENT.USE_YN    = 'Y'
                                   )
                AND     NOT EXISTS (                 -- 휴면예정 이력
                                    SELECT  1
                                    FROM    C_CUST_PLAN     CCP
                                    WHERE   CCP.COMP_CD   = CST.COMP_CD
                                    AND     CCP.CUST_ID   = CST.CUST_ID
                                    AND     CCP.PRC_DIV   = '8'  -- 고객상태
                                    AND     CCP.PRC_YN    = 'N'
                                    )
               )
        WHERE PLAN_DT < TO_CHAR(SYSDATE + 30, 'YYYYMMDD')
        UNION ALL
        SELECT  CST.COMP_CD
             ,  CST.CUST_ID
             ,  DECRYPT(CST.CUST_NM)              AS CUST_NM
             ,  CST.EMAIL                         AS EMAIL
             ,  TO_CHAR(SYSDATE    , 'YYYYMMDD')  AS PLAN_DT
             ,  TO_CHAR(SYSDATE    , 'YYYY"년"MM"월"DD"일"') AS PLAN_DT_NM
             ,  TO_CHAR(SYSDATE - 1, 'YYYY"년"MM"월"DD"일"') AS LIMIT_DT_NM
             ,  '9'                               AS PRC_DIV
             ,  DECRYPT(CST.MOBILE)                           AS MOBILE
             ,  CST.BRAND_CD
             ,  CST.STOR_CD
             ,  STO.STOR_NM
             ,  REPLACE(STO.TEL_NO, '-', '') AS TEL_NO
             ,  CST.MEMBER_NO
        FROM    C_CUST      CST
             ,  STORE       STO
        WHERE   CST.COMP_CD  = STO.COMP_CD
        AND     CST.BRAND_CD = STO.BRAND_CD
        AND     CST.STOR_CD  = STO.STOR_CD
        AND     CST.COMP_CD  = PSV_COMP_CD
        AND     CST.CUST_STAT= '9'
        AND     CST.LEAVE_DT < TO_CHAR(SYSDATE - 90, 'YYYYMMDD')
        AND     NOT EXISTS (
                            SELECT  1
                            FROM    C_CUST_PLAN CCP
                            WHERE   CCP.COMP_CD = CST.COMP_CD
                            AND     CCP.CUST_ID = CST.CUST_ID
                            AND     CCP.PRC_DIV = '9' -- 고객상태
                           );

    vSENDMSG        VARCHAR2(2000) := NULL;
    nRECCNT         NUMBER  (6  )  := 0;   

    vRtnVal         VARCHAR2(1000) := NULL;
    vRtnMsg         VARCHAR2(1000) := NULL;
    cResult         REC_SET.M_REFCUR;

    ls_err_cd       VARCHAR2(7  )  := '0' ;
    ls_err_msg      VARCHAR2(500)  ;

BEGIN
    FOR MYREC IN CUR_1 LOOP
        -- 휴면고객 전환 대상자 작성
        MERGE INTO C_CUST_PLAN
        USING DUAL
        ON (
                COMP_CD = MYREC.COMP_CD
            AND PLAN_DT = MYREC.PLAN_DT
            AND CUST_ID = MYREC.CUST_ID
           )
        WHEN NOT MATCHED THEN
            INSERT
                   (
                    COMP_CD
                  , PLAN_DT
                  , CUST_ID
                  , PRC_DIV
                  , PRC_YN
                  , REMARKS
                  , INST_DT
                  , INST_USER
                  , UPD_DT
                  , UPD_USER
                   )
            VALUES (
                    MYREC.COMP_CD
                  , MYREC.PLAN_DT
                  , MYREC.CUST_ID
                  , MYREC.PRC_DIV
                  , 'N'
                  , NULL
                  , SYSDATE
                  , 'SYS'
                  , SYSDATE
                  , 'SYS'
                   );

            -- 휴면고객 전환 문자 전송 작성
            IF MYREC.PRC_DIV = '8' AND MYREC.MOBILE IS NOT NULL AND LENGTH(MYREC.MOBILE) >= 10 THEN           
                vSENDMSG := REPLACE(FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_CD, '1010001588'), '{STOR_NM}', MYREC.STOR_NM);
                vSENDMSG := REPLACE(vSENDMSG, '{PALAN_DT}',  MYREC.PLAN_DT_NM);

                PKG_CS_MEMBER_ACK.SEND_SMS(
                                            MYREC.COMP_CD
                                          , PSV_LANG_CD
                                          , MYREC.BRAND_CD
                                          , MYREC.STOR_CD
                                          , MYREC.MEMBER_NO
                                          , MYREC.MOBILE
                                          , '4'
                                          , MYREC.STOR_NM
                                          , vSENDMSG
                                          , MYREC.TEL_NO
                                          , vRtnVal
                                          , vRtnMsg
                                          , cResult
                                         );

            END IF;    

    END LOOP;

    COMMIT;

    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;
EXCEPTION
    WHEN ERR_HANDLER THEN
        ROLLBACK;

        PR_RTN_CD  := SQLCODE;
        PR_RTN_MSG := SQLERRM ;
       dbms_output.put_line( PR_RTN_MSG ) ;
    WHEN OTHERS THEN
        ROLLBACK;

        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
        dbms_output.put_line( PR_RTN_MSG ) ;
END ;

/
