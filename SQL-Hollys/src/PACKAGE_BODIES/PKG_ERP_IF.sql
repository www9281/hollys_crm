--------------------------------------------------------
--  DDL for Package Body PKG_ERP_IF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ERP_IF" AS
    
    CURSOR ERP_01_CUR IS
    SELECT  A.ROWID, A.*
      FROM  ERP_V_MA_Z_HLY_CODEDTL  A
     WHERE  PROC_YN     = 'N'
     ORDER  BY NVL(DTS_UPDATE, DTS_INSERT), CD_FIELD, CD_SYSDEF;

    ERP_01_REC  ERP_01_CUR%ROWTYPE;

    CURSOR ERP_02_M_CUR IS
    SELECT  A.ROWID, A.*
         ,  CASE WHEN TP_PARTNER = '100' THEN '10'
                 WHEN TP_PARTNER = '200' THEN '20'
                 ELSE ''
            END                                                 AS STOR_TP
         ,  DECODE(A.FG_MANAGEMENT, '04', 'N', 'Y')             AS USE_YN   -- 폐정인 경우 미사용 처리
      FROM  ERP_SA_FRAN_HLY_MMR_MNG  A
     WHERE  PROC_YN     = 'N'
     ORDER  BY NVL(DTS_UPDATE, DTS_INSERT), CD_COMPANY, CD_FRANCHISE;

    ERP_02_M_REC  ERP_02_M_CUR%ROWTYPE;

    CURSOR ERP_02_H_CUR IS
    SELECT  A.ROWID, A.*
      FROM  ERP_SA_FRAN_HLY_MMR_MNG_HIS     A
     WHERE  A.PROC_YN       = 'N'
     ORDER  BY NVL(A.DTS_UPDATE, A.DTS_INSERT), A.CD_COMPANY, A.CD_FRANCHISE;

    ERP_02_H_REC  ERP_02_H_CUR%ROWTYPE;

    CURSOR ERP_02_C_CUR IS
    SELECT  A.ROWID, A.*
      FROM  ERP_SA_FRAN_HLY_MMR_CONT_HIS    A
     WHERE  A.PROC_YN       = 'N'
     ORDER  BY NVL(A.DTS_UPDATE, A.DTS_INSERT), A.CD_COMPANY, A.CD_FRANCHISE, A.ORDER_CONTRACT;

    ERP_02_C_REC  ERP_02_C_CUR%ROWTYPE;

    CURSOR ERP_03_PI_CUR IS
    SELECT  A.ROWID, A.*
         ,  CASE WHEN A.FG_TAX_SA IN ('11', '12', '13', '14', '15', '1C', '1D') THEN 'Y'
                 WHEN A.FG_TAX_SA IN ('16', '17', '19') THEN 'N'
                 ELSE ''
            END                                         AS COST_VAT_YN
         ,  CASE WHEN A.CD_USERDEF10 = '001' THEN '1'
                 WHEN A.CD_USERDEF10 = '002' THEN '2'
                 ELSE ''
            END                                         AS COST_VAT_RULE
         ,  NVL(C1.VAL_C1, '0')                         AS COST_VAT_RATE
      FROM  ERP_V_MA_Z_HLY_PITEM    A
         ,  COMMON                  C1
     WHERE  A.FG_TAX_SA     = C1.CODE_CD(+)
       AND  A.PROC_YN       = 'N'
       AND  C1.COMP_CD(+)   = '016'
       AND  C1.CODE_TP(+)   = '02325'
     ORDER  BY NVL(A.DTS_UPDATE, A.DTS_INSERT), A.CD_ITEM;

    ERP_03_PI_REC  ERP_03_PI_CUR%ROWTYPE;

    CURSOR ERP_03_FI_CUR IS
    SELECT  A.ROWID, I.*
         ,  S.BRAND_CD  AS BRAND, S.STOR_TP, S.ERP_ITEM_GRP, S.ROW_NUM
      FROM  ERP_V_SA_Z_HLY_FRAN_ITEMORDER   A
         ,  ITEM                            I
         ,  (
                SELECT  BRAND_CD, STOR_TP, ERP_ITEM_GRP
                     ,  ROW_NUMBER() OVER(PARTITION BY BRAND_CD, STOR_TP ORDER  BY BRAND_CD, STOR_TP, ERP_ITEM_GRP)     AS ROW_NUM
                  FROM  (
                            SELECT  BRAND_CD, STOR_TP, ERP_ITEM_GRP
                              FROM  STORE
                             WHERE  COMP_CD = '016'
                               AND  STOR_TP IN ('10', '20')
                               AND  USE_YN  = 'Y'
                             GROUP  BY BRAND_CD, STOR_TP, ERP_ITEM_GRP
                        )
            )       S
     WHERE  A.CD_ITEM       = I.ITEM_CD
       AND  A.FG_ITEM       = S.ERP_ITEM_GRP
       AND  I.COMP_CD       = '016'
       AND  A.PROC_YN       = 'N'
     ORDER  BY A.DTS_INSERT, A.CD_ITEM;

    ERP_03_FI_REC  ERP_03_FI_CUR%ROWTYPE;

    CURSOR ERP_03_IU_CUR IS
    SELECT  A.ROWID, A.*
         ,  I.BRAND_CD, I.STOR_TP
      FROM  ERP_MA_ITEM_UM_HLY      A
         ,  ITEM_CHAIN              I
     WHERE  A.CD_ITEM   = I.ITEM_CD
       AND  A.PROC_YN   = 'N'
       AND  I.COMP_CD   = '016'
     ORDER  BY NVL(A.DTS_UPDATE, A.DTS_INSERT), A.CD_ITEM;

    ERP_03_IU_REC  ERP_03_IU_CUR%ROWTYPE;

    CURSOR ERP_04_W_CUR IS
    SELECT  A.ROWID, A.*
      FROM  ERP_MA_SL_HLY  A
     WHERE  PROC_YN     = 'N'
     ORDER  BY NVL(DTS_UPDATE, DTS_INSERT), CD_SL;

    ERP_04_W_REC  ERP_04_W_CUR%ROWTYPE;

    CURSOR ERP_04_P_CUR IS
    SELECT  A.ROWID, A.*
      FROM  ERP_MA_PARTNER_HLY  A
     WHERE  PROC_YN     = 'N'
     ORDER  BY NVL(DTS_UPDATE, DTS_INSERT), CD_PARTNER;

    ERP_04_P_REC  ERP_04_P_CUR%ROWTYPE;

    CURSOR ERP_04_PI_CUR IS
    SELECT  A.ROWID, A.*
      FROM  ERP_MA_ITEM_UMPARTNER_HLY  A
     WHERE  PROC_YN     = 'N'
     ORDER  BY NVL(DTS_UPDATE, DTS_INSERT), CD_PARTNER, CD_ITEM;

    CURSOR ERP_05_C_CUR IS
    SELECT  A.ROWID, A.*
         ,  CASE WHEN A.DT_END IS NOT NULL AND A.DT_END < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN 'N'
                 ELSE 'Y'
            END         AS USE_YN
      FROM  ERP_V_HR_Z_HLY_MA_DEPT  A
     WHERE  PROC_YN     = 'N'
     ORDER  BY NVL(DTS_UPDATE, DTS_INSERT), LB_DEPT, CD_DEPT;

    ERP_05_C_REC  ERP_05_C_CUR%ROWTYPE;

    CURSOR ERP_05_U_CUR IS
    SELECT  A.ROWID, A.*
         ,  S.STOR_CD
         ,  CASE WHEN S.SV_USER_ID IS NOT NULL THEN '40'
                 WHEN CD_BIZAREA = '1000' AND CD_DUTY_RESP = '100' THEN '10'
                 WHEN CD_BIZAREA = '1000' AND CD_DUTY_RESP = '110' THEN '20'
                 WHEN CD_BIZAREA = '1000' AND CD_DUTY_RESP IN ('120', '130') THEN '30'
                 ELSE ''
            END         AS USER_DIV
         ,  CASE WHEN S.SV_USER_ID IS NOT NULL THEN '40'
                 WHEN CD_BIZAREA = '1000' AND CD_DUTY_RESP = '100' THEN '10'
                 WHEN CD_BIZAREA = '1000' AND CD_DUTY_RESP = '110' THEN '20'
                 WHEN CD_BIZAREA = '1000' AND CD_DUTY_RESP IN ('120', '130') THEN '30'
                 ELSE '50'
            END         AS DUTY_CD
         ,  CASE WHEN CD_DUTY_RESP IN ('140', '150') THEN '1'
                 WHEN CD_DUTY_RESP IN ('170') THEN '2'
                 ELSE CD_DUTY_RANK
            END         AS EMP_DIV
         ,  CASE WHEN CD_DUTY_RESP IN ('140', '150') THEN '01'
                 WHEN CD_DUTY_RESP IN ('170') THEN '02'
                 ELSE CD_DUTY_RANK
            END         AS ROLE_DIV
         ,  CASE WHEN CD_INCOM = '099' THEN 'N'
                 ELSE 'Y'
            END         AS USE_YN
      FROM  ERP_V_HR_Z_HLY_MA_EMP   A
         ,  STORE                   S
     WHERE  A.CD_CC         = S.ERP_CC_CD(+)
       AND  A.PROC_YN       = 'N'
       AND  S.COMP_CD(+)    = '016'
       AND  S.STOR_TP(+)    IN ('10', '20')
     ORDER  BY NVL(A.DTS_UPDATE, A.DTS_INSERT), A.NO_EMP;

    ERP_05_U_REC  ERP_05_U_CUR%ROWTYPE;

    CURSOR ERP_06_CUR IS
    SELECT  A.ROWID, A.*, S.BRAND_CD, S.STOR_CD
      FROM  ERP_SA_Z_FRAN_ORDCON_HLY    A
         ,  STORE                       S
     WHERE  A.CD_PARTNER    = S.ERP_STOR_CD
       AND  A.PROC_YN       = 'N'
       AND  S.COMP_CD       = '016'
       AND  S.STOR_TP       IN ('10', '20')
     ORDER  BY NVL(A.DTS_UPDATE, A.DTS_INSERT), A.CON_DATE, A.CD_PARTNER;

    ERP_06_REC  ERP_06_CUR%ROWTYPE;

    CURSOR ERP_07_CUR IS
    SELECT  A.ROWID, A.*
      FROM  ERP_V_Z_MA_HLY_MA_COMPANY   A
     WHERE  A.PROC_YN       = 'N'
     --ORDER  BY NVL(A.DTS_UPDATE, A.DTS_INSERT), A.CD_COMPANY;
     ORDER  BY A.CD_COMPANY;

    ERP_07_REC  ERP_07_CUR%ROWTYPE;

    CURSOR ERP_08_CUR IS
    SELECT  A.ROWID, A.*
      FROM  ERP_V_FI_Z_HLY_PL_CODE   A
     WHERE  A.PROC_YN       = 'N'
     ORDER  BY NVL(A.DTS_UPDATE, A.DTS_INSERT), A.CD_ACCT;

    ERP_08_REC  ERP_08_CUR%ROWTYPE;

    CURSOR ERP_09_CUR IS
    SELECT  A.ROWID, A.*, S.BRAND_CD, S.STOR_CD
      FROM  ERP_V_FI_Z_HLY_MONEY    A
         ,  STORE                   S
     WHERE  A.CD_PARTNER    = S.ERP_STOR_CD
       AND  A.PROC_YN       = 'N'
       AND  S.COMP_CD       = '016'
       AND  S.STOR_TP       IN ('10', '20')
     ORDER  BY A.DT_ACCT, A.CD_PARTNER;

    ERP_09_REC  ERP_09_CUR%ROWTYPE;

    CURSOR ERP_10_CUR IS
    SELECT  A.ROWID, A.*, S.BRAND_CD, S.STOR_CD
      FROM  ERP_V_SA_Z_HLY_FRAN_RCP     A
         ,  STORE                       S
     WHERE  A.CD_PARTNER    = S.ERP_STOR_CD
       AND  A.PROC_YN       = 'N'
       AND  S.COMP_CD       = '016'
       AND  S.STOR_TP       IN ('10', '20')
     ORDER  BY A.DT_AR, A.CD_PARTNER;

    ERP_10_REC  ERP_10_CUR%ROWTYPE;

    CURSOR ERP_14_CUR IS
    SELECT  A.ROWID, A.*, S.BRAND_CD, S.STOR_CD
      FROM  ERP_SA_FRAN_POS     A
         ,  STORE               S
     WHERE  A.CD_PARTNER    = S.ERP_STOR_CD
       AND  A.PROC_YN       = 'N'
       AND  S.COMP_CD       = '016'
       AND  S.STOR_TP       IN ('10', '20')
     ORDER  BY A.NO_POS, A.NO_POS_LINE;

    ERP_14_REC  ERP_14_CUR%ROWTYPE;

    CURSOR ERP_21_CUR IS
    SELECT  A.ROWID, A.*, S.BRAND_CD, S.STOR_CD
      FROM  ERP_V_Z_HLY_BANKACCT_TRADE  A
         ,  STORE                       S
     WHERE  A.CUST_CODE     = S.ERP_STOR_CD
       AND  A.PROC_YN       = 'N'
       AND  S.COMP_CD       = '016'
       AND  S.STOR_TP       IN ('10', '20')
     ORDER  BY A.CUST_CODE, A.VIRTUAL_ACCT;

    ERP_21_REC  ERP_21_CUR%ROWTYPE;

    --------------------------------------------------------------------------------
    --  Procedure Name   : SP_ERP_IF_MAIN_HOLLYS
    --  Description      : 할리스 ERP I/F
    --                     01  => 공통코드   수신 처리
    --                     02  => 매장정보   수신 처리
    --                     03  => 자재정보   수신 처리
    --                     04  => 거래처정보  수신 처리
    --                     05  => 정직원정보  수신 처리
    --                     06  => 주문통제정보 수신 처리
    --                     07  => 회사마스터  수신 처리
    --                     08  => 손익계정과목 수신 처리
    --                     09  => 전도금    수신 처리
    --                     10  => 입금현황   수신 처리
    --                     14  => 주문/반품 확정 수신 처리
    --                     21  => 계좌정보   수신 처리
    --------------------------------------------------------------------------------
    PROCEDURE SP_ERP_IF_MAIN_HOLLYS
    (
        PSV_PROC_ID     IN  VARCHAR2
    ) IS

    BEGIN
        IF PSV_PROC_ID = '01' THEN        
            SP_ERP_IF_01_HOLLYS;
        ELSIF PSV_PROC_ID = '02' THEN        
            SP_ERP_IF_02_HOLLYS;
        ELSIF PSV_PROC_ID = '03' THEN        
            SP_ERP_IF_03_HOLLYS;
        ELSIF PSV_PROC_ID = '04' THEN        
            SP_ERP_IF_04_HOLLYS;
        ELSIF PSV_PROC_ID = '05' THEN        
            SP_ERP_IF_05_HOLLYS;
        ELSIF PSV_PROC_ID = '06' THEN        
            SP_ERP_IF_06_HOLLYS;
        ELSIF PSV_PROC_ID = '07' THEN        
            SP_ERP_IF_07_HOLLYS;
        ELSIF PSV_PROC_ID = '08' THEN        
            SP_ERP_IF_08_HOLLYS;
        ELSIF PSV_PROC_ID = '09' THEN        
            SP_ERP_IF_09_HOLLYS;
        ELSIF PSV_PROC_ID = '10' THEN        
            SP_ERP_IF_10_HOLLYS;
        ELSIF PSV_PROC_ID = '14' THEN        
            SP_ERP_IF_14_HOLLYS;
        ELSIF PSV_PROC_ID = '21' THEN        
            SP_ERP_IF_21_HOLLYS;
        END IF;

    END SP_ERP_IF_MAIN_HOLLYS;

    PROCEDURE SP_ERP_IF_01_HOLLYS
    IS

    LS_TARGET_TABLE     CODE_MAP.TARGET_TABLE%TYPE;
    LS_CODE_TP          CODE_MAP.CODE_TP%TYPE;
    LS_L_CLASS_CD       ITEM_L_CLASS.L_CLASS_CD%TYPE;
    LS_ERR_MSG          VARCHAR2(500) ;

    BEGIN
        FOR ERP_01_REC IN ERP_01_CUR LOOP
            BEGIN
                SELECT  TARGET_TABLE, CODE_TP
                  INTO  LS_TARGET_TABLE, LS_CODE_TP
                  FROM  CODE_MAP
                 WHERE  COMP_CD     = '016'
                   AND  MAP_DIV     = '1'
                   AND  MAP_CODE    = ERP_01_REC.CD_FIELD
                   AND  USE_YN      = 'Y';

                IF LS_TARGET_TABLE IS NULL THEN
                    UPDATE  ERP_V_MA_Z_HLY_CODEDTL
                       SET  ERR_MSG     = '처리대상 테이블이 지정되지 않았습니다.'
                     WHERE  ROWID       = ERP_01_REC.ROWID;
                    CONTINUE;
                END IF;

                IF LS_TARGET_TABLE = 'COMMON' AND LS_CODE_TP IS NULL THEN
                    UPDATE  ERP_V_MA_Z_HLY_CODEDTL
                       SET  ERR_MSG     = '처리대상 콩통코드타입이 지정되지 않았습니다.'
                     WHERE  ROWID       = ERP_01_REC.ROWID;
                    CONTINUE;
                END IF;

                IF LS_TARGET_TABLE = 'BRAND' THEN
                    MERGE   INTO BRAND
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  BRAND_CD        = ERP_01_REC.CD_SYSDEF
                       )
                    WHEN MATCHED THEN
                        UPDATE
                           SET  BRAND_NM        = ERP_01_REC.NM_SYSDEF
                             ,  USE_YN          = ERP_01_REC.USE_YN
                             ,  UPD_DT          = SYSDATE
                             ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BRAND_CD
                             ,  BRAND_NM
                             ,  NATION_CD
                             ,  MULTI_LANGUAGE_YN
                             ,  LANGUAGE_TP
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_01_REC.CD_SYSDEF
                             ,  ERP_01_REC.NM_SYSDEF
                             ,  'KOR'
                             ,  'Y'
                             ,  'kor'
                             ,  ERP_01_REC.USE_YN
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        );
                ELSIF LS_TARGET_TABLE = 'COMMON' THEN
                    IF ERP_01_REC.CD_FIELD = 'HR_H000002' THEN
                        IF ERP_01_REC.CD_SYSDEF < '300' THEN
                            MERGE   INTO COMMON
                            USING   DUAL
                            ON (
                                        COMP_CD         = '016'
                                   AND  CODE_TP         = '00730'
                                   AND  CODE_CD         = ERP_01_REC.CD_SYSDEF
                               )
                            WHEN MATCHED THEN
                                UPDATE
                                   SET  CODE_NM         = ERP_01_REC.NM_SYSDEF
                                     ,  VAL_C1          = ERP_01_REC.CD_FLAG1
                                     ,  VAL_C2          = ERP_01_REC.CD_FLAG2
                                     ,  VAL_C3          = ERP_01_REC.CD_FLAG3
                                     ,  USE_YN          = ERP_01_REC.USE_YN
                                     ,  UPD_DT          = SYSDATE
                                     ,  UPD_USER        = 'ERP'
                            WHEN NOT MATCHED THEN
                                INSERT
                                (
                                        COMP_CD
                                     ,  CODE_TP
                                     ,  CODE_CD
                                     ,  CODE_NM
                                     ,  BRAND_CD
                                     ,  SORT_SEQ
                                     ,  VAL_C1
                                     ,  VAL_C2
                                     ,  VAL_C3
                                     ,  REMARKS
                                     ,  POS_IF_YN
                                     ,  USE_YN
                                     ,  INST_DT
                                     ,  INST_USER
                                     ,  UPD_DT
                                     ,  UPD_USER
                                ) VALUES (
                                        '016'
                                     ,  '00730'
                                     ,  ERP_01_REC.CD_SYSDEF
                                     ,  ERP_01_REC.NM_SYSDEF
                                     ,  '0000'
                                     ,  '1'
                                     ,  ERP_01_REC.CD_FLAG1
                                     ,  ERP_01_REC.CD_FLAG2
                                     ,  ERP_01_REC.CD_FLAG3
                                     ,  'ERP I/F'
                                     ,  'N'
                                     ,  ERP_01_REC.USE_YN
                                     ,  SYSDATE
                                     ,  'ERP'
                                     ,  SYSDATE
                                     ,  'ERP'
                                );
                        ELSE
                            MERGE   INTO COMMON
                            USING   DUAL
                            ON (
                                        COMP_CD         = '016'
                                   AND  CODE_TP         = '00765'
                                   AND  CODE_CD         = ERP_01_REC.CD_SYSDEF
                               )
                            WHEN MATCHED THEN
                                UPDATE
                                   SET  CODE_NM         = ERP_01_REC.NM_SYSDEF
                                     ,  VAL_C1          = ERP_01_REC.CD_FLAG1
                                     ,  VAL_C2          = ERP_01_REC.CD_FLAG2
                                     ,  VAL_C3          = ERP_01_REC.CD_FLAG3
                                     ,  USE_YN          = ERP_01_REC.USE_YN
                                     ,  UPD_DT          = SYSDATE
                                     ,  UPD_USER        = 'ERP'
                            WHEN NOT MATCHED THEN
                                INSERT
                                (
                                        COMP_CD
                                     ,  CODE_TP
                                     ,  CODE_CD
                                     ,  CODE_NM
                                     ,  BRAND_CD
                                     ,  SORT_SEQ
                                     ,  VAL_C1
                                     ,  VAL_C2
                                     ,  VAL_C3
                                     ,  REMARKS
                                     ,  POS_IF_YN
                                     ,  USE_YN
                                     ,  INST_DT
                                     ,  INST_USER
                                     ,  UPD_DT
                                     ,  UPD_USER
                                ) VALUES (
                                        '016'
                                     ,  '00765'
                                     ,  ERP_01_REC.CD_SYSDEF
                                     ,  ERP_01_REC.NM_SYSDEF
                                     ,  '0000'
                                     ,  '1'
                                     ,  ERP_01_REC.CD_FLAG1
                                     ,  ERP_01_REC.CD_FLAG2
                                     ,  ERP_01_REC.CD_FLAG3
                                     ,  'ERP I/F'
                                     ,  'N'
                                     ,  ERP_01_REC.USE_YN
                                     ,  SYSDATE
                                     ,  'ERP'
                                     ,  SYSDATE
                                     ,  'ERP'
                                );

                            MERGE   INTO COMMON
                            USING   DUAL
                            ON (
                                        COMP_CD         = '016'
                                   AND  CODE_TP         = '00770'
                                   AND  CODE_CD         = ERP_01_REC.CD_SYSDEF
                               )
                            WHEN MATCHED THEN
                                UPDATE
                                   SET  CODE_NM         = ERP_01_REC.NM_SYSDEF
                                     ,  VAL_C1          = ERP_01_REC.CD_FLAG1
                                     ,  VAL_C2          = ERP_01_REC.CD_FLAG2
                                     ,  VAL_C3          = ERP_01_REC.CD_FLAG3
                                     ,  USE_YN          = ERP_01_REC.USE_YN
                                     ,  UPD_DT          = SYSDATE
                                     ,  UPD_USER        = 'ERP'
                            WHEN NOT MATCHED THEN
                                INSERT
                                (
                                        COMP_CD
                                     ,  CODE_TP
                                     ,  CODE_CD
                                     ,  CODE_NM
                                     ,  BRAND_CD
                                     ,  SORT_SEQ
                                     ,  VAL_C1
                                     ,  VAL_C2
                                     ,  VAL_C3
                                     ,  REMARKS
                                     ,  POS_IF_YN
                                     ,  USE_YN
                                     ,  INST_DT
                                     ,  INST_USER
                                     ,  UPD_DT
                                     ,  UPD_USER
                                ) VALUES (
                                        '016'
                                     ,  '00770'
                                     ,  ERP_01_REC.CD_SYSDEF
                                     ,  ERP_01_REC.NM_SYSDEF
                                     ,  '0000'
                                     ,  '1'
                                     ,  ERP_01_REC.CD_FLAG1
                                     ,  ERP_01_REC.CD_FLAG2
                                     ,  ERP_01_REC.CD_FLAG3
                                     ,  'ERP I/F'
                                     ,  'N'
                                     ,  ERP_01_REC.USE_YN
                                     ,  SYSDATE
                                     ,  'ERP'
                                     ,  SYSDATE
                                     ,  'ERP'
                                );
                        END IF;
                    ELSE
                        MERGE   INTO COMMON
                        USING   DUAL
                        ON (
                                    COMP_CD         = '016'
                               AND  CODE_TP         = LS_CODE_TP
                               AND  CODE_CD         = ERP_01_REC.CD_SYSDEF
                           )
                        WHEN MATCHED THEN
                            UPDATE
                               SET  CODE_NM         = ERP_01_REC.NM_SYSDEF
                                 ,  VAL_C1          = ERP_01_REC.CD_FLAG1
                                 ,  VAL_C2          = ERP_01_REC.CD_FLAG2
                                 ,  VAL_C3          = ERP_01_REC.CD_FLAG3
                                 ,  USE_YN          = ERP_01_REC.USE_YN
                                 ,  UPD_DT          = SYSDATE
                                 ,  UPD_USER        = 'ERP'
                        WHEN NOT MATCHED THEN
                            INSERT
                            (
                                    COMP_CD
                                 ,  CODE_TP
                                 ,  CODE_CD
                                 ,  CODE_NM
                                 ,  BRAND_CD
                                 ,  SORT_SEQ
                                 ,  VAL_C1
                                 ,  VAL_C2
                                 ,  VAL_C3
                                 ,  REMARKS
                                 ,  POS_IF_YN
                                 ,  USE_YN
                                 ,  INST_DT
                                 ,  INST_USER
                                 ,  UPD_DT
                                 ,  UPD_USER
                            ) VALUES (
                                    '016'
                                 ,  LS_CODE_TP
                                 ,  ERP_01_REC.CD_SYSDEF
                                 ,  ERP_01_REC.NM_SYSDEF
                                 ,  '0000'
                                 ,  '1'
                                 ,  ERP_01_REC.CD_FLAG1
                                 ,  ERP_01_REC.CD_FLAG2
                                 ,  ERP_01_REC.CD_FLAG3
                                 ,  'ERP I/F'
                                 ,  'N'
                                 ,  ERP_01_REC.USE_YN
                                 ,  SYSDATE
                                 ,  'ERP'
                                 ,  SYSDATE
                                 ,  'ERP'
                            );
                    END IF;
                ELSIF LS_TARGET_TABLE = 'ITEM_L_CLASS' THEN
                    MERGE   INTO ITEM_L_CLASS
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  ORG_CLASS_CD    = '00'
                           AND  L_CLASS_CD      = ERP_01_REC.CD_SYSDEF
                       )
                    WHEN MATCHED THEN
                        UPDATE
                           SET  L_CLASS_NM      = ERP_01_REC.NM_SYSDEF
                             ,  USE_YN          = ERP_01_REC.USE_YN
                             ,  UPD_DT          = SYSDATE
                             ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  ORG_CLASS_CD
                             ,  L_CLASS_CD
                             ,  L_CLASS_NM
                             ,  SORT_ORDER
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  '00'
                             ,  ERP_01_REC.CD_SYSDEF
                             ,  ERP_01_REC.NM_SYSDEF
                             ,  (
                                    SELECT  NVL(MAX(TO_NUMBER(SORT_ORDER)), 0) + 1
                                      FROM  ITEM_L_CLASS
                                     WHERE  COMP_CD     = '016'
                                       AND  ORG_CLASS_CD= '00'
                                       AND  USE_YN      = 'Y'
                                )
                             ,  ERP_01_REC.USE_YN
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        );
                ELSIF LS_TARGET_TABLE = 'ITEM_M_CLASS' THEN
                    MERGE   INTO ITEM_M_CLASS
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  ORG_CLASS_CD    = '00'
                           AND  L_CLASS_CD      = ERP_01_REC.CD_FLAG1
                           AND  M_CLASS_CD      = ERP_01_REC.CD_SYSDEF
                       )
                    WHEN MATCHED THEN
                        UPDATE
                           SET  M_CLASS_NM      = ERP_01_REC.NM_SYSDEF
                             ,  USE_YN          = ERP_01_REC.USE_YN
                             ,  UPD_DT          = SYSDATE
                             ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  ORG_CLASS_CD
                             ,  L_CLASS_CD
                             ,  M_CLASS_CD
                             ,  M_CLASS_NM
                             ,  SORT_ORDER
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  '00'
                             ,  ERP_01_REC.CD_FLAG1
                             ,  ERP_01_REC.CD_SYSDEF
                             ,  ERP_01_REC.NM_SYSDEF
                             ,  (
                                    SELECT  NVL(MAX(TO_NUMBER(SORT_ORDER)), 0) + 1
                                      FROM  ITEM_M_CLASS
                                     WHERE  COMP_CD     = '016'
                                       AND  ORG_CLASS_CD= '00'
                                       AND  L_CLASS_CD  = ERP_01_REC.CD_FLAG1
                                       AND  USE_YN      = 'Y'
                                )
                             ,  ERP_01_REC.USE_YN
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        );
                ELSIF LS_TARGET_TABLE = 'ITEM_S_CLASS' THEN
                    SELECT  CD_FLAG1
                      INTO  LS_L_CLASS_CD
                      FROM  ERP_V_MA_Z_HLY_CODEDTL
                     WHERE  CD_FIELD    = 'MA_B000031'
                       AND  CD_SYSDEF   = ERP_01_REC.CD_FLAG1
                       AND  ROWNUM      = 1;

                    MERGE   INTO ITEM_S_CLASS
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  ORG_CLASS_CD    = '00'
                           AND  L_CLASS_CD      = LS_L_CLASS_CD
                           AND  M_CLASS_CD      = ERP_01_REC.CD_FLAG1
                           AND  S_CLASS_CD      = ERP_01_REC.CD_SYSDEF
                       )
                    WHEN MATCHED THEN
                        UPDATE
                           SET  S_CLASS_NM      = ERP_01_REC.NM_SYSDEF
                             ,  USE_YN          = ERP_01_REC.USE_YN
                             ,  UPD_DT          = SYSDATE
                             ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  ORG_CLASS_CD
                             ,  L_CLASS_CD
                             ,  M_CLASS_CD
                             ,  S_CLASS_CD
                             ,  S_CLASS_NM
                             ,  SORT_ORDER
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  '00'
                             ,  LS_L_CLASS_CD
                             ,  ERP_01_REC.CD_FLAG1
                             ,  ERP_01_REC.CD_SYSDEF
                             ,  ERP_01_REC.NM_SYSDEF
                             ,  (
                                    SELECT  NVL(MAX(TO_NUMBER(SORT_ORDER)), 0) + 1
                                      FROM  ITEM_S_CLASS
                                     WHERE  COMP_CD     = '016'
                                       AND  ORG_CLASS_CD= '00'
                                       AND  L_CLASS_CD  = LS_L_CLASS_CD
                                       AND  M_CLASS_CD  = ERP_01_REC.CD_FLAG1
                                       AND  USE_YN      = 'Y'
                                )
                             ,  ERP_01_REC.USE_YN
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        );
                ELSIF LS_TARGET_TABLE = 'REGION' THEN
                    IF ERP_01_REC.CD_FIELD = 'SA_F000019' THEN

                        MERGE   INTO REGION
                        USING   DUAL
                        ON (
                                    COMP_CD         = '016'
                               AND  NATION_CD       = 'KOR'
                               AND  CITY_CD         = '000'
                               AND  REGION_CD       = ERP_01_REC.CD_SYSDEF
                           )
                        WHEN MATCHED THEN
                            UPDATE
                               SET  REGION_NM       = ERP_01_REC.NM_SYSDEF
                                 ,  USE_YN          = ERP_01_REC.USE_YN
                                 ,  UPD_DT          = SYSDATE
                                 ,  UPD_USER        = 'ERP'
                        WHEN NOT MATCHED THEN
                            INSERT
                            (
                                    COMP_CD
                                 ,  NATION_CD
                                 ,  CITY_CD
                                 ,  REGION_CD
                                 ,  REGION_NM
                                 ,  USE_YN
                                 ,  INST_DT
                                 ,  INST_USER
                                 ,  UPD_DT
                                 ,  UPD_USER
                            ) VALUES (
                                    '016'
                                 ,  'KOR'
                                 ,  '000'
                                 ,  ERP_01_REC.CD_SYSDEF
                                 ,  ERP_01_REC.NM_SYSDEF
                                 ,  ERP_01_REC.USE_YN
                                 ,  SYSDATE
                                 ,  'ERP'
                                 ,  SYSDATE
                                 ,  'ERP'
                            );
                    ELSIF ERP_01_REC.CD_FIELD = 'SA_F000020' THEN
                        MERGE   INTO REGION
                        USING   DUAL
                        ON (
                                    COMP_CD         = '016'
                               AND  NATION_CD       = 'KOR'
                               AND  CITY_CD         = ERP_01_REC.CD_FLAG1
                               AND  REGION_CD       = ERP_01_REC.CD_SYSDEF
                           )
                        WHEN MATCHED THEN
                            UPDATE
                               SET  REGION_NM       = ERP_01_REC.NM_SYSDEF
                                 ,  USE_YN          = ERP_01_REC.USE_YN
                                 ,  UPD_DT          = SYSDATE
                                 ,  UPD_USER        = 'ERP'
                        WHEN NOT MATCHED THEN
                            INSERT
                            (
                                    COMP_CD
                                 ,  NATION_CD
                                 ,  CITY_CD
                                 ,  REGION_CD
                                 ,  REGION_NM
                                 ,  USE_YN
                                 ,  INST_DT
                                 ,  INST_USER
                                 ,  UPD_DT
                                 ,  UPD_USER
                            ) VALUES (
                                    '016'
                                 ,  'KOR'
                                 ,  ERP_01_REC.CD_FLAG1
                                 ,  ERP_01_REC.CD_SYSDEF
                                 ,  ERP_01_REC.NM_SYSDEF
                                 ,  ERP_01_REC.USE_YN
                                 ,  SYSDATE
                                 ,  'ERP'
                                 ,  SYSDATE
                                 ,  'ERP'
                            );
                    END IF;
                END IF;

                UPDATE  ERP_V_MA_Z_HLY_CODEDTL
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_01_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        ROLLBACK;
                        UPDATE  ERP_V_MA_Z_HLY_CODEDTL
                           SET  ERR_MSG     = '처리대상 자료가 아닙니다.'
                             ,  PROC_YN     = 'Y'
                         WHERE  ROWID       = ERP_01_REC.ROWID;
                        COMMIT;

                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_MA_Z_HLY_CODEDTL
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_01_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_01_HOLLYS;

    PROCEDURE SP_ERP_IF_02_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;

    BEGIN
        FOR ERP_02_M_REC IN ERP_02_M_CUR LOOP
            BEGIN

                MERGE   INTO STORE
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  BRAND_CD        = ERP_02_M_REC.FG_BRAND
                       AND  STOR_CD         = ERP_02_M_REC.CD_FRANCHISE
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  STOR_NM         = ERP_02_M_REC.NM_KR_FRANCHISE
                         ,  STOR_TP         = ERP_02_M_REC.STOR_TP
                         ,  STOR_TG         = ERP_02_M_REC.FG_FRAN
                         ,  BUSI_NO         = ERP_02_M_REC.NO_COMPANY
                         ,  BUSI_NM         = ERP_02_M_REC.NM_CEO
                         ,  BUSI_TP         = ERP_02_M_REC.CLS_JOB
                         ,  BUSI_CT         = ERP_02_M_REC.TP_JOB
                         ,  COMM_YN         = ERP_02_M_REC.CD_TRUST_YN
                         ,  OPEN_DT         = ERP_02_M_REC.DT_OPEN
                         ,  CLOSE_DT        = ERP_02_M_REC.DT_CLOSEDOUT
                         ,  DV_USER_ID      = ERP_02_M_REC.CD_EMP_FRAN
                         ,  CONTRACT_NM     = ERP_02_M_REC.CONTRACTOR
                         ,  INSHOP_YN       = ERP_02_M_REC.CD_IN_SHOP_YN
                         ,  TRAD_AREA       = ERP_02_M_REC.FG_VOLUME2
                         ,  APP_DIV         = ERP_02_M_REC.FG_MANAGEMENT
                         ,  OFFER_TM        = ERP_02_M_REC.TIME_MANAGEMENT
                         ,  SIDO_CD         = ERP_02_M_REC.CD_AREA1
                         ,  REGION_CD       = ERP_02_M_REC.CD_AREA2
                         ,  ZIP_CD          = ERP_02_M_REC.NO_POST_MP
                         ,  ADDR1           = ERP_02_M_REC.DC_ADR1_MP
                         ,  ADDR2           = ERP_02_M_REC.DC_ADR2_MP
                         ,  ADDR1_ENG       = ERP_02_M_REC.EN_DC_ADR1_MP
                         ,  ADDR2_ENG       = ERP_02_M_REC.EN_DC_ADR2_MP
                         ,  E_MAIL          = ERP_02_M_REC.SHOP_EMAIL
                         ,  SELF_POS_YN     = ERP_02_M_REC.SELF_POS_YN
                         ,  ERP_ITEM_GRP    = ERP_02_M_REC.FG_ITEM_TYPE
                         ,  CENTER_CD       = ERP_02_M_REC.NM_USERDEF1
                         ,  ERP_SALE_GRP    = ERP_02_M_REC.CD_SALEGRP
                         ,  ERP_SL_CD       = ERP_02_M_REC.CD_SL_ISU
                         ,  ERP_BIZAREA     = ERP_02_M_REC.CD_BIZAREA
                         ,  USE_YN          = ERP_02_M_REC.USE_YN
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  STOR_NM
                             ,  STOR_TP 
                             ,  REP_STOR_CD
                             ,  ERP_STOR_CD
                             ,  ERP_CC_CD
                             ,  STOR_TG
                             ,  COMM_YN
                             ,  BUSI_NO
                             ,  BUSI_NM
                             ,  BUSI_TP
                             ,  BUSI_CT
                             ,  OPEN_DT
                             ,  CLOSE_DT
                             ,  DV_USER_ID
                             ,  CONTRACT_NM
                             ,  INSHOP_YN
                             ,  TRAD_AREA
                             ,  APP_DIV
                             ,  OFFER_TM
                             ,  SIDO_CD
                             ,  REGION_CD
                             ,  ZIP_CD
                             ,  ADDR1
                             ,  ADDR2
                             ,  ADDR1_ENG
                             ,  ADDR2_ENG
                             ,  E_MAIL
                             ,  SELF_POS_YN
                             ,  ERP_ITEM_GRP
                             ,  NATION_CD
                             ,  CENTER_CD
                             ,  ERP_SALE_GRP
                             ,  ERP_SL_CD
                             ,  ERP_BIZAREA
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_02_M_REC.FG_BRAND
                             ,  ERP_02_M_REC.CD_FRANCHISE
                             ,  ERP_02_M_REC.NM_KR_FRANCHISE
                             ,  ERP_02_M_REC.STOR_TP
                             ,  ERP_02_M_REC.CD_FRANCHISE_MASTER
                             ,  ERP_02_M_REC.CD_PARTNER
                             ,  ERP_02_M_REC.CD_CC
                             ,  ERP_02_M_REC.FG_FRAN
                             ,  ERP_02_M_REC.CD_TRUST_YN
                             ,  ERP_02_M_REC.NO_COMPANY
                             ,  ERP_02_M_REC.NM_CEO
                             ,  ERP_02_M_REC.CLS_JOB
                             ,  ERP_02_M_REC.TP_JOB
                             ,  ERP_02_M_REC.DT_OPEN
                             ,  ERP_02_M_REC.DT_CLOSEDOUT
                             ,  ERP_02_M_REC.CD_EMP_FRAN
                             ,  ERP_02_M_REC.CONTRACTOR
                             ,  ERP_02_M_REC.CD_IN_SHOP_YN
                             ,  ERP_02_M_REC.FG_VOLUME2
                             ,  ERP_02_M_REC.FG_MANAGEMENT
                             ,  ERP_02_M_REC.TIME_MANAGEMENT
                             ,  ERP_02_M_REC.CD_AREA1
                             ,  ERP_02_M_REC.CD_AREA2
                             ,  ERP_02_M_REC.NO_POST_MP
                             ,  ERP_02_M_REC.DC_ADR1_MP
                             ,  ERP_02_M_REC.DC_ADR2_MP
                             ,  ERP_02_M_REC.EN_DC_ADR1_MP
                             ,  ERP_02_M_REC.EN_DC_ADR2_MP
                             ,  ERP_02_M_REC.SHOP_EMAIL
                             ,  ERP_02_M_REC.SELF_POS_YN
                             ,  ERP_02_M_REC.FG_ITEM_TYPE
                             ,  'KOR'
                             ,  ERP_02_M_REC.NM_USERDEF1
                             ,  ERP_02_M_REC.CD_SALEGRP
                             ,  ERP_02_M_REC.CD_SL_ISU
                             ,  ERP_02_M_REC.CD_BIZAREA
                             ,  ERP_02_M_REC.USE_YN
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                MERGE   INTO STORE_OPTION
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  BRAND_CD        = ERP_02_M_REC.FG_BRAND
                       AND  STOR_CD         = ERP_02_M_REC.CD_FRANCHISE
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  MSG_BOARD_DIV   = ERP_02_M_REC.FG_ORDY_BOARD
                         ,  PST_CASE_DIV    = ERP_02_M_REC.FG_POSTER_CASE
                         ,  MENU_BOARD_SIZE = ERP_02_M_REC.FG_MENUBORD_SIZE
                         ,  MENU_BOARD_QTY  = ERP_02_M_REC.FG_MENU_BOARD_CNT
                         ,  SHOW_CASE_TP    = ERP_02_M_REC.FG_SHOW_CASE_TP
                         ,  BANN_HOLD_TP    = ERP_02_M_REC.FG_BANNER_DEFERM
                         ,  DROP_COFFEE_TP  = ERP_02_M_REC.FG_DREAM_DOFFEE
                         ,  SPCL_TEA_TP     = ERP_02_M_REC.FG_SPECIALTY
                         ,  PLAT_SALE_YN    = ERP_02_M_REC.FG_PLATE_SALE_YN
                         ,  COLD_MEAL_YN    = ERP_02_M_REC.FG_COLD_MIL_SALE_YN
                         ,  ALL_TIME_TP     = ERP_02_M_REC.CD_24HOUR_YN
                         ,  PARK_LOT_YN     = ERP_02_M_REC.CD_PARKING_YN
                         ,  FACI_USER_NM    = ERP_02_M_REC.FACUKUT_PERSON
                         ,  USE_YN          = ERP_02_M_REC.USE_YN
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  MSG_BOARD_DIV
                             ,  PST_CASE_DIV
                             ,  MENU_BOARD_SIZE
                             ,  MENU_BOARD_QTY
                             ,  SHOW_CASE_TP
                             ,  BANN_HOLD_TP
                             ,  DROP_COFFEE_TP
                             ,  SPCL_TEA_TP
                             ,  PLAT_SALE_YN
                             ,  COLD_MEAL_YN
                             ,  ALL_TIME_TP
                             ,  PARK_LOT_YN
                             ,  FACI_USER_NM
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_02_M_REC.FG_BRAND
                             ,  ERP_02_M_REC.CD_FRANCHISE
                             ,  ERP_02_M_REC.FG_ORDY_BOARD
                             ,  ERP_02_M_REC.FG_POSTER_CASE
                             ,  ERP_02_M_REC.FG_MENUBORD_SIZE
                             ,  ERP_02_M_REC.FG_MENU_BOARD_CNT
                             ,  ERP_02_M_REC.FG_SHOW_CASE_TP
                             ,  ERP_02_M_REC.FG_BANNER_DEFERM
                             ,  ERP_02_M_REC.FG_DREAM_DOFFEE
                             ,  ERP_02_M_REC.FG_SPECIALTY
                             ,  ERP_02_M_REC.FG_PLATE_SALE_YN
                             ,  ERP_02_M_REC.FG_COLD_MIL_SALE_YN
                             ,  ERP_02_M_REC.CD_24HOUR_YN
                             ,  ERP_02_M_REC.CD_PARKING_YN
                             ,  ERP_02_M_REC.FACUKUT_PERSON
                             ,  ERP_02_M_REC.USE_YN
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                MERGE   INTO STORE_CREDIT
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  BRAND_CD        = ERP_02_M_REC.FG_BRAND
                       AND  STOR_CD         = ERP_02_M_REC.CD_FRANCHISE
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  CREDIT_MNG      = ERP_02_M_REC.FG_CREDIT_GB
                         ,  CREDIT_LIMIT    = ERP_02_M_REC.TOT_CREDIT
                         ,  DIST_STATUS     = ERP_02_M_REC.FG_DIST_STATUS
                         ,  CHARGE_CNT      = ERP_02_M_REC.FG_CHARGE_CNT
                         ,  DEPO_CNT        = ERP_02_M_REC.FG_PAYMENT_CNT
                         ,  DEPO_DIV        = ERP_02_M_REC.FG_PAYMENT_GB
                         ,  FST_ORDER_YN    = ERP_02_M_REC.FST_ORDER_YN
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  CREDIT_MNG 
                             ,  CREDIT_LIMIT
                             ,  DIST_STATUS
                             ,  CHARGE_CNT
                             ,  DEPO_CNT
                             ,  DEPO_DIV
                             ,  FST_ORDER_YN
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_02_M_REC.FG_BRAND
                             ,  ERP_02_M_REC.CD_FRANCHISE
                             ,  ERP_02_M_REC.FG_CREDIT_GB 
                             ,  ERP_02_M_REC.TOT_CREDIT
                             ,  ERP_02_M_REC.FG_DIST_STATUS
                             ,  ERP_02_M_REC.FG_CHARGE_CNT
                             ,  ERP_02_M_REC.FG_PAYMENT_CNT
                             ,  ERP_02_M_REC.FG_PAYMENT_GB
                             ,  ERP_02_M_REC.FST_ORDER_YN
                             ,  'Y'
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                UPDATE  ERP_SA_FRAN_HLY_MMR_MNG
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_02_M_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_SA_FRAN_HLY_MMR_MNG
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_02_M_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        FOR ERP_02_H_REC IN ERP_02_H_CUR LOOP
            BEGIN
                MERGE   INTO STORE
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  BRAND_CD        = ERP_02_H_REC.FG_BRAND
                       AND  STOR_CD         = ERP_02_H_REC.CD_FRANCHISE
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  SV_USER_ID      = ERP_02_H_REC.CD_EMP_SC
                         ,  EXECUTE_NM      = ERP_02_H_REC.MNG_REAL_MAN
                         ,  SPACE           = ERP_02_H_REC.REAL_AREA
                         ,  SEAT            = ERP_02_H_REC.SEAT_CNT
                         ,  STOR_FORM       = ERP_02_H_REC.FG_SHOP_TP
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                ;

                MERGE   INTO STORE_OPTION
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  BRAND_CD        = ERP_02_H_REC.FG_BRAND
                       AND  STOR_CD         = ERP_02_H_REC.CD_FRANCHISE
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  STOR_CONCEPT    = ERP_02_H_REC.FG_SHOP_CONCEPT
                         ,  SPACE           = ERP_02_H_REC.REAL_AREA
                         ,  TERS_EXIST_YN   = ERP_02_H_REC.CD_TERRACE_YN
                         ,  SMOK_ROOM_YN    = ERP_02_H_REC.CD_SMOKING_YN
                         ,  REST_ROOM_TP    = ERP_02_H_REC.FG_BATHROOM
                         ,  SIGN_VENDOR     = ERP_02_H_REC.COMPANY_SIGN
                         ,  FACI_VENDOR     = ERP_02_H_REC.COMPANY_FACIL
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                ;

                UPDATE  ERP_SA_FRAN_HLY_MMR_MNG_HIS
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_02_H_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_SA_FRAN_HLY_MMR_MNG_HIS
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_02_H_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        FOR ERP_02_C_REC IN ERP_02_C_CUR LOOP
            BEGIN

                MERGE   INTO STORE_CONTRACT
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  BRAND_CD        = ERP_02_C_REC.FG_BRAND
                       AND  REP_STOR_CD     = ERP_02_C_REC.CD_FRANCHISE_MASTER
                       AND  SEQ_NO          = ERP_02_C_REC.ORDER_CONTRACT
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  STOR_CD         = ERP_02_C_REC.CD_FRANCHISE
                         ,  STOR_NM         = ERP_02_C_REC.NM_KR_FRANCHISE
                         ,  BUSI_NM         = ERP_02_C_REC.NM_SHOP_OWNER
                         ,  BUSI_NO         = ERP_02_C_REC.CD_PARTNER
                         ,  CONTRACT_DT     = ERP_02_C_REC.DT_ST_CONTRACT
                         ,  EXPIRATION_DT   = ERP_02_C_REC.DT_END_CONTRACT
                         ,  SEAL_DT         = ERP_02_C_REC.DT_SGN_CONTRACT
                         ,  RECONTRACT_DT   = ERP_02_C_REC.DT_RE_CONTRACT
                         ,  OPEN_DT         = ERP_02_C_REC.DT_OPEN
                         ,  ACC_BUSI_DAYS   = ERP_02_C_REC.DAY_SUM
                         ,  INSURE_YN       = ERP_02_C_REC.FG_INSURAN_JOIN_YN
                         ,  STOR_STAT       = ERP_02_C_REC.CD_ST_STORE
                         ,  REASON          = ERP_02_C_REC.REASON
                         ,  STOR_REMARK     = ERP_02_C_REC.SPECIAL_CONT
                         ,  INFO_OPEN_YN    = ERP_02_C_REC.CD_INFORM_RECP_YN
                         ,  EXPT_SALE_YN    = ERP_02_C_REC.CD_SALES_EXPT_YN
                         ,  LOCL_STOR_YN    = ERP_02_C_REC.CD_STORE_NEAR_YN
                         ,  CONTRACT_REMARK = ERP_02_C_REC.ORDER_SPECIAL_CONT
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BRAND_CD
                             ,  REP_STOR_CD
                             ,  SEQ_NO
                             ,  STOR_CD
                             ,  STOR_NM
                             ,  BUSI_NM
                             ,  BUSI_NO
                             ,  CONTRACT_DT
                             ,  EXPIRATION_DT
                             ,  SEAL_DT
                             ,  RECONTRACT_DT
                             ,  OPEN_DT
                             ,  ACC_BUSI_DAYS
                             ,  INSURE_YN
                             ,  STOR_STAT
                             ,  REASON
                             ,  STOR_REMARK
                             ,  INFO_OPEN_YN
                             ,  EXPT_SALE_YN
                             ,  LOCL_STOR_YN
                             ,  CONTRACT_REMARK
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_02_C_REC.FG_BRAND
                             ,  ERP_02_C_REC.CD_FRANCHISE_MASTER
                             ,  ERP_02_C_REC.ORDER_CONTRACT
                             ,  ERP_02_C_REC.CD_FRANCHISE
                             ,  ERP_02_C_REC.NM_KR_FRANCHISE
                             ,  ERP_02_C_REC.NM_SHOP_OWNER
                             ,  ERP_02_C_REC.CD_PARTNER
                             ,  ERP_02_C_REC.DT_ST_CONTRACT
                             ,  ERP_02_C_REC.DT_END_CONTRACT
                             ,  ERP_02_C_REC.DT_SGN_CONTRACT
                             ,  ERP_02_C_REC.DT_RE_CONTRACT
                             ,  ERP_02_C_REC.DT_OPEN
                             ,  ERP_02_C_REC.DAY_SUM
                             ,  ERP_02_C_REC.FG_INSURAN_JOIN_YN
                             ,  ERP_02_C_REC.CD_ST_STORE
                             ,  ERP_02_C_REC.REASON
                             ,  ERP_02_C_REC.SPECIAL_CONT
                             ,  ERP_02_C_REC.CD_INFORM_RECP_YN
                             ,  ERP_02_C_REC.CD_SALES_EXPT_YN
                             ,  ERP_02_C_REC.CD_STORE_NEAR_YN
                             ,  ERP_02_C_REC.ORDER_SPECIAL_CONT
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                UPDATE  ERP_SA_FRAN_HLY_MMR_CONT_HIS
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_02_C_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_SA_FRAN_HLY_MMR_CONT_HIS
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_02_C_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_02_HOLLYS;

    PROCEDURE SP_ERP_IF_03_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;
    PR_RTN_CD           VARCHAR2(10);
    PR_RTN_MSG          VARCHAR2(500);

    BEGIN
        FOR ERP_03_PI_REC IN ERP_03_PI_CUR LOOP
            BEGIN

                MERGE   INTO ITEM
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  ITEM_CD         = ERP_03_PI_REC.CD_ITEM
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  ITEM_NM         = ERP_03_PI_REC.NM_ITEM
                         ,  ITEM_POS_NM     = ERP_03_PI_REC.NM_ITEM
                         ,  ITEM_KDS_NM     = ERP_03_PI_REC.NM_ITEM
                         ,  L_CLASS_CD      = NVL(ERP_03_PI_REC.CLS_L, ' ')
                         ,  M_CLASS_CD      = NVL(ERP_03_PI_REC.CLS_M, ' ')
                         ,  S_CLASS_CD      = NVL(ERP_03_PI_REC.CLS_S, ' ')
                         ,  ITEM_DIV        = ERP_03_PI_REC.CLS_ITEM
                         ,  STANDARD        = ERP_03_PI_REC.STND_ITEM
                         ,  COST_VAT_YN     = ERP_03_PI_REC.COST_VAT_YN
                         ,  COST_VAT_RULE   = ERP_03_PI_REC.COST_VAT_RULE
                         ,  COST_VAT_RATE   = TO_NUMBER(ERP_03_PI_REC.COST_VAT_RATE) / 100
                         ,  VENDOR_CD       = ERP_03_PI_REC.PARTNER
                         ,  LEAD_TIME       = ERP_03_PI_REC.NUM_USERDEF3
                         ,  MIN_ORD_QTY     = ERP_03_PI_REC.NUM_USERDEF4
                         ,  MAX_ORD_QTY     = ERP_03_PI_REC.NUM_USERDEF6
                         ,  ORD_UNIT        = ERP_03_PI_REC.UNIT_SO
                         ,  ORD_UNIT_QTY    = ERP_03_PI_REC.UNIT_SO_FACT
                         ,  STOCK_UNIT      = ERP_03_PI_REC.UNIT_IM
                         ,  SERVICE_ITEM_YN = 'N'
                         ,  ERP_TAX_FG      = ERP_03_PI_REC.FG_TAX_SA
                         ,  USE_YN          = ERP_03_PI_REC.YN_USE
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BRAND_CD
                             ,  ITEM_CD
                             ,  REP_ITEM_CD
                             ,  ITEM_NM
                             ,  ITEM_POS_NM
                             ,  ITEM_KDS_NM
                             ,  L_CLASS_CD
                             ,  M_CLASS_CD
                             ,  S_CLASS_CD
                             ,  ITEM_DIV
                             ,  ORD_SALE_DIV
                             ,  STOCK_DIV
                             ,  STANDARD
                             ,  SALE_PRC
                             ,  SALE_VAT_YN
                             ,  SALE_VAT_RULE
                             ,  SALE_VAT_IN_RATE
                             ,  SALE_VAT_OUT_RATE
                             ,  SALE_PRC_CTRL
                             ,  SALE_START_DT
                             ,  SALE_CLOSE_DT
                             ,  SET_DIV
                             ,  EXT_YN
                             ,  AUTO_POPUP_YN
                             ,  OPEN_ITEM_YN
                             ,  DC_YN
                             ,  COST
                             ,  COST_VAT_YN
                             ,  COST_VAT_RULE
                             ,  COST_VAT_RATE
                             ,  ORD_START_DT
                             ,  ORD_CLOSE_DT
                             ,  VENDOR_CD
                             ,  LEAD_TIME
                             ,  MIN_ORD_QTY
                             ,  MAX_ORD_QTY
                             ,  ORD_MNG_DIV
                             ,  RJT_YN
                             ,  RECIPE_DIV
                             ,  YIELD_RATE
                             ,  PROD_QTY
                             ,  ORD_UNIT
                             ,  ORD_UNIT_QTY
                             ,  SALE_UNIT
                             ,  SALE_UNIT_QTY
                             ,  STOCK_UNIT
                             ,  REUSE_YN
                             ,  DO_YN
                             ,  DO_UNIT
                             ,  WEIGHT_UNIT
                             ,  SAV_MLG_YN
                             ,  POINT_YN
                             ,  ERP_ITEM_CD
                             ,  SEASON_DIV
                             ,  CUST_STD_CNT
                             ,  STOCK_PERIOD
                             ,  SERVICE_ITEM_YN
                             ,  ORD_B_CNT
                             ,  ALERT_ORD_QTY
                             ,  ERP_TAX_FG
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  '0000'
                             ,  ERP_03_PI_REC.CD_ITEM
                             ,  ERP_03_PI_REC.CD_ITEM
                             ,  ERP_03_PI_REC.NM_ITEM
                             ,  ERP_03_PI_REC.NM_ITEM
                             ,  ERP_03_PI_REC.NM_ITEM
                             ,  NVL(ERP_03_PI_REC.CLS_L, ' ')
                             ,  NVL(ERP_03_PI_REC.CLS_M, ' ')
                             ,  NVL(ERP_03_PI_REC.CLS_S, ' ')
                             ,  ERP_03_PI_REC.CLS_ITEM
                             ,  '1'
                             ,  'A'
                             ,  ERP_03_PI_REC.STND_ITEM
                             ,  0
                             ,  ERP_03_PI_REC.COST_VAT_YN
                             ,  ERP_03_PI_REC.COST_VAT_RULE
                             ,  TO_NUMBER(ERP_03_PI_REC.COST_VAT_RATE) / 100
                             ,  TO_NUMBER(ERP_03_PI_REC.COST_VAT_RATE) / 100
                             ,  'H'
                             ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                             ,  '99991231'
                             ,  '0'
                             ,  'N'
                             ,  'N'
                             ,  'N'
                             ,  'N'
                             ,  0
                             ,  ERP_03_PI_REC.COST_VAT_YN
                             ,  ERP_03_PI_REC.COST_VAT_RULE
                             ,  TO_NUMBER(ERP_03_PI_REC.COST_VAT_RATE) / 100
                             ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                             ,  '99991231'
                             ,  ERP_03_PI_REC.PARTNER
                             ,  ERP_03_PI_REC.NUM_USERDEF3
                             ,  ERP_03_PI_REC.NUM_USERDEF4
                             ,  ERP_03_PI_REC.NUM_USERDEF6
                             ,  '0'
                             ,  'Y'
                             ,  '2'
                             ,  1
                             ,  1
                             ,  ERP_03_PI_REC.UNIT_SO
                             ,  ERP_03_PI_REC.UNIT_SO_FACT
                             ,  ERP_03_PI_REC.UNIT_SO
                             ,  ERP_03_PI_REC.UNIT_SO_FACT
                             ,  ERP_03_PI_REC.UNIT_IM
                             ,  'N'
                             ,  'N'
                             ,  ERP_03_PI_REC.UNIT_IM
                             ,  1
                             ,  'N'
                             ,  'N'
                             ,  ERP_03_PI_REC.CD_ITEM
                             ,  ''
                             ,  0
                             ,  ''
                             ,  'N'
                             ,  ''
                             ,  ''
                             ,  ERP_03_PI_REC.FG_TAX_SA
                             ,  ERP_03_PI_REC.YN_USE
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                IF ERP_03_PI_REC.BARCODE IS NOT NULL THEN
                    MERGE   INTO BARCODE
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  BAR_CODE        = ERP_03_PI_REC.BARCODE
                           AND  ITEM_CD         = ERP_03_PI_REC.CD_ITEM
                       )
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BAR_CODE
                             ,  ITEM_CD
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_03_PI_REC.BARCODE
                             ,  ERP_03_PI_REC.CD_ITEM
                             ,  ERP_03_PI_REC.YN_USE
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        );
                END IF;

                IF ERP_03_PI_REC.EN_ITEM IS NOT NULL THEN
                    MERGE   INTO LANG_ITEM
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  ITEM_CD         = ERP_03_PI_REC.CD_ITEM
                           AND  LANGUAGE_TP     = 'eng'
                       )
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  ITEM_CD
                             ,  LANGUAGE_TP
                             ,  ITEM_NM
                             ,  ITEM_POS_NM
                             ,  ITEM_KDS_NM
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_03_PI_REC.CD_ITEM
                             ,  'eng'
                             ,  ERP_03_PI_REC.EN_ITEM
                             ,  ERP_03_PI_REC.EN_ITEM
                             ,  ERP_03_PI_REC.EN_ITEM
                             ,  ERP_03_PI_REC.YN_USE
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        );
                END IF;

                UPDATE  ERP_V_MA_Z_HLY_PITEM
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_03_PI_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_MA_Z_HLY_PITEM
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_03_PI_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        FOR ERP_03_FI_REC IN ERP_03_FI_CUR LOOP
            BEGIN

                MERGE   INTO ITEM_STORE_ORDER
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  ERP_ITEM_GRP    = ERP_03_FI_REC.ERP_ITEM_GRP
                       AND  ITEM_CD         = ERP_03_FI_REC.ITEM_CD
                   )
                WHEN NOT MATCHED THEN
                    INSERT
                    (
                            COMP_CD
                         ,  ERP_ITEM_GRP
                         ,  ITEM_CD
                         ,  USE_YN
                         ,  INST_DT
                         ,  INST_USER
                         ,  UPD_DT
                         ,  UPD_USER
                    ) VALUES (
                            '016'
                         ,  ERP_03_FI_REC.ERP_ITEM_GRP
                         ,  ERP_03_FI_REC.ITEM_CD
                         ,  'Y'
                         ,  SYSDATE
                         ,  'ERP'
                         ,  SYSDATE
                         ,  'ERP'
                    );    

                IF ERP_03_FI_REC.ROW_NUM = 1 THEN
                    MERGE   INTO ITEM_CHAIN
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  BRAND_CD        = ERP_03_FI_REC.BRAND
                           AND  STOR_TP         = ERP_03_FI_REC.STOR_TP
                           AND  ITEM_CD         = ERP_03_FI_REC.ITEM_CD
                       )
                    WHEN MATCHED THEN
                        UPDATE
                           SET  ITEM_NM         = ERP_03_FI_REC.ITEM_NM
                             ,  ITEM_POS_NM     = ERP_03_FI_REC.ITEM_POS_NM
                             ,  ITEM_KDS_NM     = ERP_03_FI_REC.ITEM_KDS_NM
                             ,  L_CLASS_CD      = ERP_03_FI_REC.L_CLASS_CD
                             ,  M_CLASS_CD      = ERP_03_FI_REC.M_CLASS_CD
                             ,  S_CLASS_CD      = ERP_03_FI_REC.S_CLASS_CD
                             ,  ITEM_DIV        = ERP_03_FI_REC.ITEM_DIV
                             ,  STANDARD        = ERP_03_FI_REC.STANDARD
                             ,  COST_VAT_YN     = ERP_03_FI_REC.COST_VAT_YN
                             ,  COST_VAT_RULE   = ERP_03_FI_REC.COST_VAT_RULE
                             ,  COST_VAT_RATE   = ERP_03_FI_REC.COST_VAT_RATE
                             ,  VENDOR_CD       = ERP_03_FI_REC.VENDOR_CD
                             ,  LEAD_TIME       = ERP_03_FI_REC.LEAD_TIME
                             ,  MIN_ORD_QTY     = ERP_03_FI_REC.MIN_ORD_QTY
                             ,  MAX_ORD_QTY     = ERP_03_FI_REC.MAX_ORD_QTY
                             ,  ORD_UNIT        = ERP_03_FI_REC.ORD_UNIT
                             ,  ORD_UNIT_QTY    = ERP_03_FI_REC.ORD_UNIT_QTY
                             ,  STOCK_UNIT      = ERP_03_FI_REC.STOCK_UNIT
                             ,  SERVICE_ITEM_YN = 'N'
                             ,  ERP_TAX_FG      = ERP_03_FI_REC.ERP_TAX_FG      
                             ,  USE_YN          = ERP_03_FI_REC.USE_YN
                             ,  UPD_DT          = SYSDATE
                             ,  UPD_USER        = 'ERP'
                        WHEN NOT MATCHED THEN
                            INSERT
                            (
                                    COMP_CD
                                 ,  BRAND_CD
                                 ,  STOR_TP
                                 ,  ITEM_CD
                                 ,  REP_ITEM_CD
                                 ,  ITEM_NM
                                 ,  ITEM_POS_NM
                                 ,  ITEM_KDS_NM
                                 ,  L_CLASS_CD
                                 ,  M_CLASS_CD
                                 ,  S_CLASS_CD
                                 ,  D_CLASS_CD
                                 ,  ITEM_DIV
                                 ,  ORD_SALE_DIV
                                 ,  STOCK_DIV
                                 ,  STANDARD
                                 ,  CAPACITY
                                 ,  COUNTRY_CD
                                 ,  SALE_PRC
                                 ,  SALE_VAT_YN
                                 ,  SALE_VAT_RULE
                                 ,  SALE_VAT_IN_RATE
                                 ,  SALE_VAT_OUT_RATE
                                 ,  SALE_PRC_CTRL
                                 ,  SALE_START_DT
                                 ,  SALE_CLOSE_DT
                                 ,  SET_DIV
                                 ,  EXT_YN
                                 ,  AUTO_POPUP_YN
                                 ,  OPEN_ITEM_YN
                                 ,  DC_YN
                                 ,  COST
                                 ,  COST_VAT_YN
                                 ,  COST_VAT_RULE
                                 ,  COST_VAT_RATE
                                 ,  ORD_START_DT
                                 ,  ORD_CLOSE_DT
                                 ,  VENDOR_CD
                                 ,  LEAD_TIME
                                 ,  MIN_ORD_QTY
                                 ,  MAX_ORD_QTY
                                 ,  ORD_MNG_DIV
                                 ,  RJT_YN
                                 ,  RECIPE_DIV
                                 ,  YIELD_RATE
                                 ,  PROD_QTY
                                 ,  ORD_UNIT
                                 ,  ORD_UNIT_QTY
                                 ,  SALE_UNIT
                                 ,  SALE_UNIT_QTY
                                 ,  STOCK_UNIT
                                 ,  REUSE_YN
                                 ,  DO_YN
                                 ,  DO_UNIT
                                 ,  WEIGHT_UNIT
                                 ,  SAV_MLG_YN
                                 ,  POINT_YN
                                 ,  ERP_ITEM_CD
                                 ,  ASIS_ITEM_CD
                                 ,  SEASON_DIV
                                 ,  CUST_STD_CNT
                                 ,  STOCK_PERIOD
                                 ,  SERVICE_ITEM_YN
                                 ,  ORD_B_CNT
                                 ,  ALERT_ORD_QTY
                                 ,  ERP_TAX_FG
                                 ,  USE_YN
                                 ,  INST_DT
                                 ,  INST_USER
                                 ,  UPD_DT
                                 ,  UPD_USER
                            ) VALUES (
                                    '016'
                                 ,  ERP_03_FI_REC.BRAND
                                 ,  ERP_03_FI_REC.STOR_TP
                                 ,  ERP_03_FI_REC.ITEM_CD
                                 ,  ERP_03_FI_REC.REP_ITEM_CD
                                 ,  ERP_03_FI_REC.ITEM_NM
                                 ,  ERP_03_FI_REC.ITEM_POS_NM
                                 ,  ERP_03_FI_REC.ITEM_KDS_NM
                                 ,  ERP_03_FI_REC.L_CLASS_CD
                                 ,  ERP_03_FI_REC.M_CLASS_CD
                                 ,  ERP_03_FI_REC.S_CLASS_CD
                                 ,  ERP_03_FI_REC.D_CLASS_CD
                                 ,  ERP_03_FI_REC.ITEM_DIV
                                 ,  ERP_03_FI_REC.ORD_SALE_DIV
                                 ,  ERP_03_FI_REC.STOCK_DIV
                                 ,  ERP_03_FI_REC.STANDARD
                                 ,  ERP_03_FI_REC.CAPACITY
                                 ,  ERP_03_FI_REC.COUNTRY_CD
                                 ,  ERP_03_FI_REC.SALE_PRC
                                 ,  ERP_03_FI_REC.SALE_VAT_YN
                                 ,  ERP_03_FI_REC.SALE_VAT_RULE
                                 ,  ERP_03_FI_REC.SALE_VAT_IN_RATE
                                 ,  ERP_03_FI_REC.SALE_VAT_OUT_RATE
                                 ,  ERP_03_FI_REC.SALE_PRC_CTRL
                                 ,  ERP_03_FI_REC.SALE_START_DT
                                 ,  ERP_03_FI_REC.SALE_CLOSE_DT
                                 ,  ERP_03_FI_REC.SET_DIV
                                 ,  ERP_03_FI_REC.EXT_YN
                                 ,  ERP_03_FI_REC.AUTO_POPUP_YN
                                 ,  ERP_03_FI_REC.OPEN_ITEM_YN
                                 ,  ERP_03_FI_REC.DC_YN
                                 ,  ERP_03_FI_REC.COST
                                 ,  ERP_03_FI_REC.COST_VAT_YN
                                 ,  ERP_03_FI_REC.COST_VAT_RULE
                                 ,  ERP_03_FI_REC.COST_VAT_RATE
                                 ,  ERP_03_FI_REC.ORD_START_DT
                                 ,  ERP_03_FI_REC.ORD_CLOSE_DT
                                 ,  ERP_03_FI_REC.VENDOR_CD
                                 ,  ERP_03_FI_REC.LEAD_TIME
                                 ,  ERP_03_FI_REC.MIN_ORD_QTY
                                 ,  ERP_03_FI_REC.MAX_ORD_QTY
                                 ,  ERP_03_FI_REC.ORD_MNG_DIV
                                 ,  ERP_03_FI_REC.RJT_YN
                                 ,  ERP_03_FI_REC.RECIPE_DIV
                                 ,  ERP_03_FI_REC.YIELD_RATE
                                 ,  ERP_03_FI_REC.PROD_QTY
                                 ,  ERP_03_FI_REC.ORD_UNIT
                                 ,  ERP_03_FI_REC.ORD_UNIT_QTY
                                 ,  ERP_03_FI_REC.SALE_UNIT
                                 ,  ERP_03_FI_REC.SALE_UNIT_QTY
                                 ,  ERP_03_FI_REC.STOCK_UNIT
                                 ,  ERP_03_FI_REC.REUSE_YN
                                 ,  ERP_03_FI_REC.DO_YN
                                 ,  ERP_03_FI_REC.DO_UNIT
                                 ,  ERP_03_FI_REC.WEIGHT_UNIT
                                 ,  ERP_03_FI_REC.SAV_MLG_YN
                                 ,  ERP_03_FI_REC.POINT_YN
                                 ,  ERP_03_FI_REC.ERP_ITEM_CD
                                 ,  ERP_03_FI_REC.ASIS_ITEM_CD
                                 ,  ERP_03_FI_REC.SEASON_DIV
                                 ,  ERP_03_FI_REC.CUST_STD_CNT
                                 ,  ERP_03_FI_REC.STOCK_PERIOD
                                 ,  ERP_03_FI_REC.SERVICE_ITEM_YN
                                 ,  ERP_03_FI_REC.ORD_B_CNT
                                 ,  ERP_03_FI_REC.ALERT_ORD_QTY
                                 ,  ERP_03_FI_REC.ERP_TAX_FG
                                 ,  ERP_03_FI_REC.USE_YN
                                 ,  SYSDATE
                                 ,  'ERP'
                                 ,  SYSDATE
                                 ,  'ERP'
                            )
                    ;
                END IF;

                UPDATE  ERP_V_SA_Z_HLY_FRAN_ITEMORDER
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_03_FI_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_SA_Z_HLY_FRAN_ITEMORDER
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_03_FI_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        FOR ERP_03_IU_REC IN ERP_03_IU_CUR LOOP
            BEGIN

                SP_ITEM_CHAIN_HIS_CHG(   '016'
                                       , 'ERP'
                                       , 'kor'
                                       , ERP_03_IU_REC.BRAND_CD
                                       , ERP_03_IU_REC.STOR_TP
                                       , ERP_03_IU_REC.CD_ITEM
                                       , ERP_03_IU_REC.SDT_UM
                                       , ERP_03_IU_REC.EDT_UM
                                       , '0'
                                       , ERP_03_IU_REC.UM_ITEM
                                       , 'Y'
                                       , PR_RTN_CD
                                       , PR_RTN_MSG
                                     );

                UPDATE  ERP_MA_ITEM_UM_HLY
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = PR_RTN_MSG
                 WHERE  ROWID       = ERP_03_IU_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_MA_ITEM_UM_HLY
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_03_IU_REC.ROWID;
                        COMMIT;

            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_03_HOLLYS;

    PROCEDURE SP_ERP_IF_04_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;
    PR_RTN_CD           VARCHAR2(10);
    PR_RTN_MSG          VARCHAR2(500);

    BEGIN
        FOR ERP_04_W_REC IN ERP_04_W_CUR LOOP
            BEGIN

                MERGE   INTO STORE
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  BRAND_CD        = '0000'
                       AND  STOR_CD         = ERP_04_W_REC.CD_SL
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  STOR_NM         = ERP_04_W_REC.NM_SL
                         ,  BUSI_TP         = ERP_04_W_REC.CLS_JOB
                         ,  BUSI_CT         = ERP_04_W_REC.TP_JOB
                         ,  ZIP_CD          = ERP_04_W_REC.NO_POST2
                         ,  ADDR1           = ERP_04_W_REC.DC_ADS2_H
                         ,  ADDR2           = ERP_04_W_REC.DC_ADS2_D
                         ,  TEL_NO          = ERP_04_W_REC.NO_TEL2
                         ,  FAX             = ERP_04_W_REC.NO_FAX2
                         ,  USE_YN          = ERP_04_W_REC.YN_USE
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  REP_STOR_CD
                             ,  ERP_STOR_CD
                             ,  STOR_NM
                             ,  STOR_TP
                             ,  BUSI_TP
                             ,  BUSI_CT
                             ,  ZIP_CD
                             ,  ADDR1
                             ,  ADDR2
                             ,  TEL_NO
                             ,  FAX
                             ,  NATION_CD
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  '0000'
                             ,  ERP_04_W_REC.CD_SL
                             ,  ERP_04_W_REC.CD_SL
                             ,  ERP_04_W_REC.CD_SL
                             ,  ERP_04_W_REC.NM_SL
                             ,  '31'
                             ,  ERP_04_W_REC.CLS_JOB
                             ,  ERP_04_W_REC.TP_JOB
                             ,  ERP_04_W_REC.NO_POST2
                             ,  ERP_04_W_REC.DC_ADS2_H
                             ,  ERP_04_W_REC.DC_ADS2_D
                             ,  ERP_04_W_REC.NO_TEL2
                             ,  ERP_04_W_REC.NO_FAX2
                             ,  'KOR'
                             ,  ERP_04_W_REC.YN_USE
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                UPDATE  ERP_MA_SL_HLY
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_04_W_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_MA_SL_HLY
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_04_W_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        FOR ERP_04_P_REC IN ERP_04_P_CUR LOOP
            BEGIN

                MERGE   INTO STORE
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  BRAND_CD        = '0000'
                       AND  STOR_CD         = ERP_04_P_REC.CD_PARTNER
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  STOR_NM         = ERP_04_P_REC.LN_PARTNER
                         ,  BUSI_NM         = ERP_04_P_REC.NM_CEO
                         ,  BUSI_NO         = ERP_04_P_REC.NO_COMPANY
                         ,  BUSI_TP         = ERP_04_P_REC.CLS_JOB
                         ,  BUSI_CT         = ERP_04_P_REC.TP_JOB
                         ,  CONTRACT_DT     = ERP_04_P_REC.SD_PARTNER
                         ,  EXPIRATION_DT   = ERP_04_P_REC.DT_TRADEND
                         ,  TEL_NO          = ERP_04_P_REC.NO_TEL
                         ,  FAX             = ERP_04_P_REC.NO_FAX
                         ,  E_MAIL          = ERP_04_P_REC.E_MAIL
                         ,  ZIP_CD          = ERP_04_P_REC.NO_POST1
                         ,  ADDR1           = ERP_04_P_REC.DC_ADS1_H
                         ,  ADDR2           = ERP_04_P_REC.DC_ADS1_D
                         ,  USE_YN          = ERP_04_P_REC.USE_YN
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  REP_STOR_CD
                             ,  ERP_STOR_CD
                             ,  STOR_NM
                             ,  STOR_TP 
                             ,  BUSI_NM
                             ,  BUSI_NO
                             ,  BUSI_TP 
                             ,  BUSI_CT
                             ,  CONTRACT_DT
                             ,  EXPIRATION_DT
                             ,  TEL_NO
                             ,  FAX
                             ,  E_MAIL
                             ,  ZIP_CD
                             ,  ADDR1
                             ,  ADDR2
                             ,  NATION_CD
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  '0000'
                             ,  ERP_04_P_REC.CD_PARTNER
                             ,  ERP_04_P_REC.CD_PARTNER
                             ,  ERP_04_P_REC.CD_PARTNER
                             ,  ERP_04_P_REC.LN_PARTNER
                             ,  '30' 
                             ,  ERP_04_P_REC.NM_CEO
                             ,  ERP_04_P_REC.NO_COMPANY
                             ,  ERP_04_P_REC.CLS_JOB
                             ,  ERP_04_P_REC.TP_JOB
                             ,  ERP_04_P_REC.SD_PARTNER
                             ,  ERP_04_P_REC.DT_TRADEND
                             ,  ERP_04_P_REC.NO_TEL
                             ,  ERP_04_P_REC.NO_FAX
                             ,  ERP_04_P_REC.E_MAIL
                             ,  ERP_04_P_REC.NO_POST1
                             ,  ERP_04_P_REC.DC_ADS1_H
                             ,  ERP_04_P_REC.DC_ADS1_D
                             ,  'KOR'
                             ,  ERP_04_P_REC.USE_YN
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                UPDATE  ERP_MA_PARTNER_HLY
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_04_P_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_MA_PARTNER_HLY
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_04_P_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        FOR ERP_04_PI_REC IN ERP_04_PI_CUR LOOP
            BEGIN

                SP_ITEM_STORE_CHG(   '016'
                                   , 'ERP'
                                   , 'kor'
                                   , '0000'
                                   , ERP_04_PI_REC.CD_PARTNER
                                   , '01'
                                   , ERP_04_PI_REC.CD_ITEM
                                   , ERP_04_PI_REC.SDT_UM
                                   , ERP_04_PI_REC.EDT_UM
                                   , ERP_04_PI_REC.UM_ITEM
                                   , 'Y'
                                   , PR_RTN_CD
                                   , PR_RTN_MSG
                                 );

                UPDATE  ERP_MA_ITEM_UMPARTNER_HLY
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = PR_RTN_MSG
                 WHERE  ROWID       = ERP_04_PI_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_MA_ITEM_UMPARTNER_HLY
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_04_PI_REC.ROWID;
                        COMMIT;

            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_04_HOLLYS;

    PROCEDURE SP_ERP_IF_05_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;
    PR_RTN_CD           VARCHAR2(10);
    PR_RTN_MSG          VARCHAR2(500);

    BEGIN
        FOR ERP_05_C_REC IN ERP_05_C_CUR LOOP
            BEGIN

                IF ERP_05_C_REC.LB_DEPT = '1' THEN
                    MERGE   INTO COMMON
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  CODE_TP         = '00600'
                           AND  CODE_CD         = ERP_05_C_REC.CD_DEPT
                       )
                    WHEN MATCHED THEN
                        UPDATE
                           SET  CODE_NM         = ERP_05_C_REC.NM_DEPT
                             ,  VAL_C1          = ERP_05_C_REC.H_DEPT
                             ,  USE_YN          = ERP_05_C_REC.USE_YN
                             ,  UPD_DT          = SYSDATE
                             ,  UPD_USER        = 'ERP'
                        WHEN NOT MATCHED THEN
                            INSERT
                            (
                                    COMP_CD
                                 ,  CODE_TP
                                 ,  CODE_CD
                                 ,  CODE_NM
                                 ,  BRAND_CD
                                 ,  SORT_SEQ
                                 ,  VAL_C1
                                 ,  REMARKS
                                 ,  POS_IF_YN
                                 ,  USE_YN
                                 ,  INST_DT
                                 ,  INST_USER
                                 ,  UPD_DT
                                 ,  UPD_USER
                            ) VALUES (
                                    '016'
                                 ,  '00600'
                                 ,  ERP_05_C_REC.CD_DEPT
                                 ,  ERP_05_C_REC.NM_DEPT
                                 ,  '0000'
                                 ,  (
                                        SELECT  NVL(MAX(TO_NUMBER(SORT_SEQ)), 0) + 1
                                          FROM  COMMON
                                         WHERE  COMP_CD     = '016'
                                           AND  CODE_TP     = '00600'
                                    )
                                 ,  ERP_05_C_REC.H_DEPT
                                 ,  'ERP I/F'
                                 ,  'N'
                                 ,  ERP_05_C_REC.USE_YN
                                 ,  SYSDATE
                                 ,  'ERP'
                                 ,  SYSDATE
                                 ,  'ERP'
                            )
                    ;

                ELSIF ERP_05_C_REC.LB_DEPT = '2' THEN
                    MERGE   INTO COMMON
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  CODE_TP         = '00605'
                           AND  CODE_CD         = ERP_05_C_REC.CD_DEPT
                       )
                    WHEN MATCHED THEN
                        UPDATE
                           SET  CODE_NM         = ERP_05_C_REC.NM_DEPT
                             ,  VAL_C1          = ERP_05_C_REC.H_DEPT
                             ,  USE_YN          = ERP_05_C_REC.USE_YN
                             ,  UPD_DT          = SYSDATE
                             ,  UPD_USER        = 'ERP'
                        WHEN NOT MATCHED THEN
                            INSERT
                            (
                                    COMP_CD
                                 ,  CODE_TP
                                 ,  CODE_CD
                                 ,  CODE_NM
                                 ,  BRAND_CD
                                 ,  SORT_SEQ
                                 ,  VAL_C1
                                 ,  VAL_C2
                                 ,  REMARKS
                                 ,  POS_IF_YN
                                 ,  USE_YN
                                 ,  INST_DT
                                 ,  INST_USER
                                 ,  UPD_DT
                                 ,  UPD_USER
                            ) VALUES (
                                    '016'
                                 ,  '00605'
                                 ,  ERP_05_C_REC.CD_DEPT
                                 ,  ERP_05_C_REC.NM_DEPT
                                 ,  '0000'
                                 ,  (
                                        SELECT  NVL(MAX(TO_NUMBER(SORT_SEQ)), 0) + 1
                                          FROM  COMMON
                                         WHERE  COMP_CD     = '016'
                                           AND  CODE_TP     = '00605'
                                    )
                                 ,  ERP_05_C_REC.H_DEPT
                                 ,  ERP_05_C_REC.CD_CC
                                 ,  'ERP I/F'
                                 ,  'N'
                                 ,  ERP_05_C_REC.USE_YN
                                 ,  SYSDATE
                                 ,  'ERP'
                                 ,  SYSDATE
                                 ,  'ERP'
                            )
                    ;
                END IF;

                UPDATE  ERP_V_HR_Z_HLY_MA_DEPT
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_05_C_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_HR_Z_HLY_MA_DEPT
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_05_C_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        FOR ERP_05_U_REC IN ERP_05_U_CUR LOOP
            BEGIN

                IF ERP_05_U_REC.CD_BIZAREA = '1000' THEN
                    MERGE   INTO HQ_USER
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  USER_ID         = ERP_05_U_REC.NO_EMP
                       )
                    WHEN MATCHED THEN
                        UPDATE
                           SET  USER_NM         = ERP_05_U_REC.NM_KOR
                             ,  BRAND_CD        = ERP_05_U_REC.BRAND_CD
                             ,  DEPT_CD         = ERP_05_U_REC.CD_DEPT
                             ,  TEAM_CD         = ERP_05_U_REC.CD_TEAM
                             ,  USER_DIV        = ERP_05_U_REC.USER_DIV
                             ,  POSITION_CD     = ERP_05_U_REC.CD_DUTY_RANK
                             ,  TEL_NO          = ERP_05_U_REC.NO_TEL
                             ,  MOBILE_NO       = ERP_05_U_REC.NO_TEL_EMER
                             ,  E_MAIL          = ERP_05_U_REC.NO_EMAIL
                             ,  ZIP_CD          = ERP_05_U_REC.NO_POST_RES
                             ,  ADDR1           = ERP_05_U_REC.DC_ADDRESS_RES1
                             ,  ADDR2           = ERP_05_U_REC.DC_ADDRESS_RES2
                             ,  USE_YN          = ERP_05_U_REC.USE_YN
                             ,  UPD_DT          = SYSDATE
                             ,  UPD_USER        = 'ERP'
                        WHEN NOT MATCHED THEN
                            INSERT
                            (
                                    COMP_CD
                                 ,  USER_ID
                                 ,  USER_NM
                                 ,  PWD
                                 ,  BRAND_CD
                                 ,  DEPT_CD
                                 ,  TEAM_CD
                                 ,  POSITION_CD
                                 ,  USER_DIV
                                 ,  DUTY_CD
                                 ,  WEB_AUTH_CD
                                 ,  TEL_NO
                                 ,  MOBILE_NO
                                 ,  E_MAIL
                                 ,  ZIP_CD
                                 ,  ADDR1
                                 ,  ADDR2
                                 ,  NATION_CD
                                 ,  LANGUAGE_TP
                                 ,  LOGIN_PERM_YN
                                 ,  USE_YN
                                 ,  INST_DT
                                 ,  INST_USER
                                 ,  UPD_DT
                                 ,  UPD_USER
                            ) VALUES (
                                    '016'
                                 ,  ERP_05_U_REC.NO_EMP
                                 ,  ERP_05_U_REC.NM_KOR
                                 ,  '1111'
                                 ,  ERP_05_U_REC.BRAND_CD
                                 ,  ERP_05_U_REC.CD_DEPT
                                 ,  ERP_05_U_REC.CD_TEAM
                                 ,  ERP_05_U_REC.CD_DUTY_RANK
                                 ,  ERP_05_U_REC.USER_DIV
                                 ,  ERP_05_U_REC.DUTY_CD
                                 ,  '10'
                                 ,  ERP_05_U_REC.NO_TEL
                                 ,  ERP_05_U_REC.NO_TEL_EMER
                                 ,  ERP_05_U_REC.NO_EMAIL
                                 ,  ERP_05_U_REC.NO_POST_RES
                                 ,  ERP_05_U_REC.DC_ADDRESS_RES1
                                 ,  ERP_05_U_REC.DC_ADDRESS_RES2
                                 ,  'KOR'
                                 ,  'kor'
                                 ,  'Y'
                                 ,  ERP_05_U_REC.USE_YN
                                 ,  SYSDATE
                                 ,  'ERP'
                                 ,  SYSDATE
                                 ,  'ERP'
                            )
                    ;
                ELSIF ERP_05_U_REC.CD_BIZAREA = '1100' THEN
                    MERGE   INTO STORE_USER
                    USING   DUAL
                    ON (
                                COMP_CD         = '016'
                           AND  BRAND_CD        = ERP_05_U_REC.BRAND_CD
                           AND  STOR_CD         = ERP_05_U_REC.STOR_CD
                           AND  USER_ID         = ERP_05_U_REC.NO_EMP
                       )
                    WHEN MATCHED THEN
                        UPDATE
                           SET  USER_NM         = ERP_05_U_REC.NM_KOR
                             ,  EMP_DIV         = ERP_05_U_REC.EMP_DIV
                             ,  ROLE_DIV        = ERP_05_U_REC.ROLE_DIV
                             ,  POSITION_CD     = ERP_05_U_REC.CD_DUTY_RANK
                             ,  TEL_NO          = ERP_05_U_REC.NO_TEL
                             ,  MOBILE_NO       = ERP_05_U_REC.NO_TEL_EMER
                             ,  E_MAIL          = ERP_05_U_REC.NO_EMAIL
                             ,  ZIP_CD          = ERP_05_U_REC.NO_POST_RES
                             ,  ADDR1           = ERP_05_U_REC.DC_ADDRESS_RES1
                             ,  ADDR2           = ERP_05_U_REC.DC_ADDRESS_RES2
                             ,  ENTER_DT        = ERP_05_U_REC.DT_ENTER
                             ,  RETIRE_DT       = ERP_05_U_REC.DT_RETIRE
                             ,  RESIDENT_NUM    = ERP_05_U_REC.NO_RES
                             ,  ACC_NO          = ERP_05_U_REC.NO_BANK1
                             ,  BANK_CD         = ERP_05_U_REC.CD_BANK1
                             ,  USE_YN          = ERP_05_U_REC.USE_YN
                             ,  UPD_DT          = SYSDATE
                             ,  UPD_USER        = 'ERP'
                        WHEN NOT MATCHED THEN
                            INSERT
                            (
                                    COMP_CD
                                 ,  BRAND_CD
                                 ,  STOR_CD
                                 ,  USER_ID
                                 ,  USER_NM
                                 ,  POS_PWD
                                 ,  WEB_PWD
                                 ,  EMP_DIV
                                 ,  ROLE_DIV
                                 ,  POSITION_CD
                                 ,  WEB_AUTH_CD
                                 ,  TEL_NO
                                 ,  MOBILE_NO
                                 ,  E_MAIL
                                 ,  ZIP_CD
                                 ,  ADDR1
                                 ,  ADDR2
                                 ,  ENTER_DT
                                 ,  RETIRE_DT
                                 ,  NATION_CD
                                 ,  LANGUAGE_TP
                                 ,  RESIDENT_NUM
                                 ,  ACC_NO
                                 ,  BANK_CD
                                 ,  USE_YN
                                 ,  INST_DT
                                 ,  INST_USER
                                 ,  UPD_DT
                                 ,  UPD_USER
                            ) VALUES (
                                    '016'
                                 ,  ERP_05_U_REC.BRAND_CD
                                 ,  ERP_05_U_REC.STOR_CD
                                 ,  ERP_05_U_REC.NO_EMP
                                 ,  ERP_05_U_REC.NM_KOR
                                 ,  '1111'
                                 ,  '1111'
                                 ,  ERP_05_U_REC.EMP_DIV
                                 ,  ERP_05_U_REC.ROLE_DIV
                                 ,  ERP_05_U_REC.CD_DUTY_RANK
                                 ,  '90'
                                 ,  ERP_05_U_REC.NO_TEL
                                 ,  ERP_05_U_REC.NO_TEL_EMER
                                 ,  ERP_05_U_REC.NO_EMAIL
                                 ,  ERP_05_U_REC.NO_POST_RES
                                 ,  ERP_05_U_REC.DC_ADDRESS_RES1
                                 ,  ERP_05_U_REC.DC_ADDRESS_RES2
                                 ,  ERP_05_U_REC.DT_ENTER
                                 ,  ERP_05_U_REC.DT_RETIRE
                                 ,  'KOR'
                                 ,  'kor'
                                 ,  ERP_05_U_REC.NO_RES
                                 ,  ERP_05_U_REC.NO_BANK1
                                 ,  ERP_05_U_REC.CD_BANK1
                                 ,  ERP_05_U_REC.USE_YN
                                 ,  SYSDATE
                                 ,  'ERP'
                                 ,  SYSDATE
                                 ,  'ERP'
                            )
                    ;
                END IF;

                UPDATE  ERP_V_HR_Z_HLY_MA_EMP
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_05_U_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_HR_Z_HLY_MA_EMP
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_05_U_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_05_HOLLYS;

    PROCEDURE SP_ERP_IF_06_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;

    BEGIN

        FOR ERP_06_REC IN ERP_06_CUR LOOP
            BEGIN

                MERGE   INTO ORDER_CTRL_DAY
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  CTRL_DT         = ERP_06_REC.CON_DATE
                       AND  BRAND_CD        = ERP_06_REC.BRAND_CD
                       AND  STOR_CD         = ERP_06_REC.STOR_CD
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  START_TM        = ERP_06_REC.ALLOW_FROM
                         ,  CLOSE_TM        = ERP_06_REC.ALLOW_TO
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  CTRL_DT
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  START_TM
                             ,  CLOSE_TM
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_06_REC.CON_DATE
                             ,  ERP_06_REC.BRAND_CD
                             ,  ERP_06_REC.STOR_CD
                             ,  ERP_06_REC.ALLOW_FROM
                             ,  ERP_06_REC.ALLOW_TO
                             ,  'Y'
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                UPDATE  ERP_SA_Z_FRAN_ORDCON_HLY
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_06_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_SA_Z_FRAN_ORDCON_HLY
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_06_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_06_HOLLYS;

    PROCEDURE SP_ERP_IF_07_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;

    BEGIN

        FOR ERP_07_REC IN ERP_07_CUR LOOP
            BEGIN

                UPDATE  COMPANY
                   SET  BUSI_NO     = ERP_07_REC.NO_COMPANY
                     ,  BUSI_NM     = ERP_07_REC.NM_CEO
                     ,  TEL_NO      = ERP_07_REC.NO_TEL
                     ,  FAX         = ERP_07_REC.NO_FAX
                     ,  ADDR        = ERP_07_REC.ADS_H
                     ,  ADDR2       = ERP_07_REC.ADS_D
                     ,  UPD_DT      = SYSDATE
                     ,  UPD_USER    = 'ERP'
                 WHERE  COMP_CD     = '016'
                ;

                UPDATE  ERP_V_Z_MA_HLY_MA_COMPANY
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_07_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_Z_MA_HLY_MA_COMPANY
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_07_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_07_HOLLYS;

    PROCEDURE SP_ERP_IF_08_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;

    BEGIN

        FOR ERP_08_REC IN ERP_08_CUR LOOP
            BEGIN

                MERGE   INTO PL_ACC_MST
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  STOR_TP         = '10'
                       AND  ACC_CD          = ERP_08_REC.CD_ACCT
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  ACC_NM          = ERP_08_REC.NM_ACCT
                         ,  ACC_LVL         = ERP_08_REC.TP_ACLEVEL
                         ,  REF_ACC_CD      = CASE WHEN ERP_08_REC.TP_ACLEVEL = '1' THEN '0' ELSE ERP_08_REC.CD_ACCT_P END
                         ,  ACC_SEQ         = ERP_08_REC.CD_ACCT_SEQ
                         ,  USE_YN          = ERP_08_REC.YN_BASIC
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  STOR_TP
                             ,  ACC_CD
                             ,  ACC_NM
                             ,  ACC_LVL
                             ,  REF_ACC_CD
                             ,  ACC_DIV
                             ,  TERM_DIV
                             ,  ACC_SEQ
                             ,  USE_YN
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  '10'
                             ,  ERP_08_REC.CD_ACCT
                             ,  ERP_08_REC.NM_ACCT
                             ,  ERP_08_REC.TP_ACLEVEL
                             ,  CASE WHEN ERP_08_REC.TP_ACLEVEL = '1' THEN '0' ELSE ERP_08_REC.CD_ACCT_P END
                             ,  '4'
                             ,  '2'
                             ,  ERP_08_REC.CD_ACCT_SEQ
                             ,  ERP_08_REC.YN_BASIC
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                UPDATE  ERP_V_FI_Z_HLY_PL_CODE
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_08_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_FI_Z_HLY_PL_CODE
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_08_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_08_HOLLYS;

    PROCEDURE SP_ERP_IF_09_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;

    BEGIN

        FOR ERP_09_REC IN ERP_09_CUR LOOP
            BEGIN

                MERGE   INTO STORE_ETC_AMT_016
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  PRC_DT          = ERP_09_REC.DT_ACCT
                       AND  BRAND_CD        = ERP_09_REC.BRAND_CD
                       AND  STOR_CD         = ERP_09_REC.STOR_CD
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  ETC_AMT         = ERP_09_REC.AM_DR
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  PRC_DT
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  ETC_AMT
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_09_REC.DT_ACCT
                             ,  ERP_09_REC.BRAND_CD
                             ,  ERP_09_REC.STOR_CD
                             ,  ERP_09_REC.AM_DR
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                UPDATE  ERP_V_FI_Z_HLY_MONEY
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_09_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_FI_Z_HLY_MONEY
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_09_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_09_HOLLYS;

    PROCEDURE SP_ERP_IF_10_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;

    BEGIN

        FOR ERP_10_REC IN ERP_10_CUR LOOP
            BEGIN

                MERGE   INTO STORE_RCP_AMT_016
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  RCP_DT          = ERP_10_REC.DT_AR
                       AND  BRAND_CD        = ERP_10_REC.BRAND_CD
                       AND  STOR_CD         = ERP_10_REC.STOR_CD
                       AND  ERP_RCP_NO      = ERP_10_REC.NO_RCP
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  RCP_AMT         = ERP_10_REC.RCP_AM_RCP
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  RCP_DT
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  SEQ
                             ,  RCP_AMT
                             ,  ERP_RCP_NO
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_10_REC.DT_AR
                             ,  ERP_10_REC.BRAND_CD
                             ,  ERP_10_REC.STOR_CD
                             ,  (
                                    SELECT  NVL(MAX(TO_NUMBER(SEQ)), 0) + 1
                                      FROM  STORE_RCP_AMT_016
                                     WHERE  COMP_CD     = '016'
                                       AND  RCP_DT      = ERP_10_REC.DT_AR
                                       AND  BRAND_CD    = ERP_10_REC.BRAND_CD
                                       AND  STOR_CD     = ERP_10_REC.STOR_CD
                                )
                             ,  ERP_10_REC.RCP_AM_RCP
                             ,  ERP_10_REC.NO_RCP
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                UPDATE  ERP_V_SA_Z_HLY_FRAN_RCP
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_10_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_SA_Z_HLY_FRAN_RCP
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_10_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_10_HOLLYS;

    PROCEDURE SP_ERP_IF_13_HOLLYS( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_ERP_IF_13_HOLLYS     주문/반품 송신 데이터 조회 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-03         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_ERP_IF_13_HOLLYS
            SYSDATE     :   2018-01-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    LS_ERR_CD       VARCHAR2(7) ;
    LS_ERR_MSG      VARCHAR2(500) ;
    ERR_HANDLER     EXCEPTION;

    BEGIN
        LS_ERR_CD := '0000' ;

        UPDATE  ORDER_DTV
           SET  MSF_IF_YN   = 'R'
         WHERE  COMP_CD     = PSV_COMP_CD
           AND  MSF_IF_YN   = 'N'
           AND  CFM_FG      = '1'
        ;

        COMMIT;

        OPEN PR_RESULT FOR
        SELECT  '1000'          AS CD_COMPANY
             ,  '1000'          AS CD_PLANT
             ,  OD.ORD_NO       AS NO_POS
             ,  OD.ORD_SEQ      AS NO_POS_LINE
             ,  OD.ORD_DT       AS DT_SO
             ,  S.ERP_STOR_CD   AS CD_PARTNER
             ,  '000'           AS CD_EXCH
             ,  '1'             AS RT_EXCH
             ,  S.ERP_SALE_GRP  AS CD_SALEGRP
             ,  S.DV_USER_ID    AS NO_EMP
             ,  CASE WHEN OD.ORD_FG = '1' AND OD.ORD_DIV = '0' THEN '1200'
                     WHEN OD.ORD_FG = '1' AND OD.ORD_DIV = '1' THEN '1210'
                     WHEN OD.ORD_FG = '2'                      THEN '2000'
                     ELSE ''
                END             AS TP_SO
             ,  OD.ITEM_CD      AS CD_ITEM
             ,  S.ERP_SL_CD     AS CD_SL
             ,  OD.ORD_QTY      AS QT_SO_UNIT
             ,  OD.ORD_QTY * OD.ORD_UNIT_QTY    AS QT_SO
             ,  OD.ORD_COST     AS UM_SO_UNIT
             ,  ROUND(OD.ORD_COST / OD.ORD_UNIT_QTY, 2) AS UM_SO
             ,  OD.ORD_AMT      AS AM_WONAMT
             ,  0               AS AM_DISCOUNT
             ,  OD.ORD_VAT      AS AM_VAT
             ,  OD.ORD_AMT + OD.ORD_VAT AS AM_TOT
             ,  I.ERP_TAX_FG    AS TP_VAT
             ,  '200'           AS FG_DATA
             ,  S.ERP_STOR_CD   AS GI_PARTNER
             ,  OD.ORD_DT       AS DT_DUEDATE
             ,  OD.ORD_UNIT     AS UNIT_SO_UNIT
             ,  I.STOCK_UNIT    AS UNIT_SO
             ,  OD.REMARKS      AS DC_RMK
             ,  ''              AS DC_RMK2
             ,  '200'           AS FG_SOSTATS
             ,  TO_CHAR(OD.INST_DT, 'YYYYMMDDHH24MISS') AS DTS_INSERT
             ,  NVL(OD.INST_USER, 'POS')    AS ID_INSERT
             ,  TO_CHAR(OD.UPD_DT , 'YYYYMMDDHH24MISS') AS DTS_UPDATE
             ,  NVL(OD.UPD_USER, 'POS')     AS ID_UPDATE
             ,  OD.DLV_DT       AS DT_DUEREQ
             ,  OD.DLV_DT       AS DT_DUE
             ,  'Y'             AS YN_UM
             ,  0               AS UM_IN
             ,  'N'             AS YN_CGI
             ,  'N'             AS YN_DOWNLOAD
             ,  OD.ORD_QTY * OD.ORD_UNIT_QTY    AS QT_IM  
             ,  I.STOCK_UNIT    AS UNIT_IM
             ,  OD.ORG_ORD_NO   AS NO_ORI_POS
             ,  OD.ORG_ORD_SEQ  AS NO_ORI_POS_LINE
             ,  ROUND(OD.ORD_COST / OD.ORD_UNIT_QTY, 2) AS UM_IM 
          FROM  ORDER_DTV   OD
             ,  STORE       S
             ,  ITEM        I
         WHERE  OD.COMP_CD      = S.COMP_CD
           AND  OD.BRAND_CD     = S.BRAND_CD
           AND  OD.STOR_CD      = S.STOR_CD
           AND  OD.COMP_CD      = I.COMP_CD
           AND  OD.ITEM_CD      = I.ITEM_CD
           AND  OD.COMP_CD      = PSV_COMP_CD
           AND  OD.MSF_IF_YN    = 'R'
           AND  OD.CFM_FG       = '1'
        ;

        PR_RTN_CD  := LS_ERR_CD;
        PR_RTN_MSG := LS_ERR_MSG ;
        dbms_output.put_line( 'SUCCESS') ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := LS_ERR_CD;
            PR_RTN_MSG := LS_ERR_MSG ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    END;

    PROCEDURE SP_ERP_IF_14_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;

    BEGIN

        FOR ERP_14_REC IN ERP_14_CUR LOOP
            BEGIN

                UPDATE  ORDER_DTV
                   SET  STK_DT      = ERP_14_REC.DT_CONFIRM
                     ,  ORD_CQTY    = ERP_14_REC.CF_QT
                     ,  ORD_CAMT    = ERP_14_REC.CF_AM
                     ,  ORD_CVAT    = ERP_14_REC.CF_VAT
                     ,  DLV_CDT     = ERP_14_REC.DT_CONFIRM
                     ,  DLV_QTY     = ERP_14_REC.CF_QT
                     ,  DLV_AMT     = ERP_14_REC.CF_AM
                     ,  DLV_VAT     = ERP_14_REC.CF_VAT
                     ,  SAP_IF_YN   = 'Y'
                     ,  SAP_IF_DT   = SYSDATE
                     ,  UPD_DT      = TO_DATE(ERP_14_REC.DTS_UPDATE, 'YYYYMMDDHH24MISS')
                     ,  UPD_USER    = ERP_14_REC.ID_UPDATE
                 WHERE  COMP_CD     = '016'
                   AND  ORD_NO      = ERP_14_REC.NO_POS
                   AND  ORD_SEQ     = ERP_14_REC.NO_POS_LINE
                ;

                UPDATE  ERP_SA_FRAN_POS
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_14_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_SA_FRAN_POS
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_14_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_14_HOLLYS;

    PROCEDURE SP_ERP_IF_15_HOLLYS( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_ERP_STOR_CD IN  VARCHAR2 ,                -- ERP  매장코드
        PSV_PROC_YM     IN  VARCHAR2 ,                -- 처리년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_ERP_IF_15_HOLLYS    직영점 재고실사 송신 데이터 조회 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-03         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_ERP_IF_15_HOLLYS
            SYSDATE     :   2018-01-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    LS_ERR_CD       VARCHAR2(7) ;
    LS_ERR_MSG      VARCHAR2(500) ;
    ERR_HANDLER     EXCEPTION;

    BEGIN
        LS_ERR_CD := '0000' ;

        UPDATE  ERP_SA_Z_HLY_FRAN_MM_QTIO
           SET  ERP_IF_YN   = 'R'
         WHERE  CD_COMPANY  = '1000'
           AND  CD_PARTNER  = PSV_ERP_STOR_CD
           AND  DT_IO       BETWEEN PSV_PROC_YM||'01' AND PSV_PROC_YM||'31'
           AND  ERP_IF_YN   = 'N'
        ;

        COMMIT;

        OPEN PR_RESULT FOR
        SELECT  *
          FROM  ERP_SA_Z_HLY_FRAN_MM_QTIO
         WHERE  CD_COMPANY  = '1000'
           AND  ERP_IF_YN   = 'R'    
        ;

        PR_RTN_CD  := LS_ERR_CD;
        PR_RTN_MSG := LS_ERR_MSG ;
        dbms_output.put_line( 'SUCCESS') ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := LS_ERR_CD;
            PR_RTN_MSG := LS_ERR_MSG ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    END;

    PROCEDURE SP_ERP_IF_16_HD_HOLLYS( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_ERP_STOR_CD IN  VARCHAR2 ,                -- ERP  매장코드
        PSV_PROC_YM     IN  VARCHAR2 ,                -- 처리년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_ERP_IF_16_HD_HOLLYS    판매헤더 송신 데이터 조회 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-03         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_ERP_IF_16_HD_HOLLYS
            SYSDATE     :   2018-01-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    LS_ERR_CD       VARCHAR2(7) ;
    LS_ERR_MSG      VARCHAR2(500) ;
    ERR_HANDLER     EXCEPTION;

    BEGIN
        LS_ERR_CD := '0000' ;

        UPDATE  ERP_SA_FRAN_POSLINK_SALEH
           SET  ERP_IF_YN   = 'R'
         WHERE  CD_COMPANY  = '1000'
           AND  CD_PARTNER  = PSV_ERP_STOR_CD
           AND  DT_SALE     BETWEEN PSV_PROC_YM||'01' AND PSV_PROC_YM||'31'
           AND  ERP_IF_YN   = 'N'
        ;

        COMMIT;

        OPEN PR_RESULT FOR
        SELECT  *
          FROM  ERP_SA_FRAN_POSLINK_SALEH
         WHERE  CD_COMPANY  = '1000'
           AND  ERP_IF_YN   = 'R'    
        ;

        PR_RTN_CD  := LS_ERR_CD;
        PR_RTN_MSG := LS_ERR_MSG ;
        dbms_output.put_line( 'SUCCESS') ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := LS_ERR_CD;
            PR_RTN_MSG := LS_ERR_MSG ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    END;

    PROCEDURE SP_ERP_IF_16_ST_HOLLYS( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_ERP_STOR_CD IN  VARCHAR2 ,                -- ERP  매장코드
        PSV_PROC_YM     IN  VARCHAR2 ,                -- 처리년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_ERP_IF_16_ST_HOLLYS    판매결제 송신 데이터 조회 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-03         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_ERP_IF_16_ST_HOLLYS
            SYSDATE     :   2018-01-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    LS_ERR_CD       VARCHAR2(7) ;
    LS_ERR_MSG      VARCHAR2(500) ;
    ERR_HANDLER     EXCEPTION;

    BEGIN
        LS_ERR_CD := '0000' ;

        UPDATE  ERP_SA_FRAN_POSLINK_SALEL
           SET  ERP_IF_YN   = 'R'
         WHERE  CD_COMPANY  = '1000'
           AND  CD_PARTNER  = PSV_ERP_STOR_CD
           AND  DT_SALE     BETWEEN PSV_PROC_YM||'01' AND PSV_PROC_YM||'31'
           AND  ERP_IF_YN   = 'N'
        ;

        COMMIT;

        OPEN PR_RESULT FOR
        SELECT  *
          FROM  ERP_SA_FRAN_POSLINK_SALEL
         WHERE  CD_COMPANY  = '1000'
           AND  ERP_IF_YN   = 'R'    
        ;

        PR_RTN_CD  := LS_ERR_CD;
        PR_RTN_MSG := LS_ERR_MSG ;
        dbms_output.put_line( 'SUCCESS') ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := LS_ERR_CD;
            PR_RTN_MSG := LS_ERR_MSG ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    END;

    PROCEDURE SP_ERP_IF_21_HOLLYS
    IS

    LS_ERR_MSG          VARCHAR2(500) ;

    BEGIN

        FOR ERP_21_REC IN ERP_21_CUR LOOP
            BEGIN

                MERGE   INTO STORE_BANKACCT
                USING   DUAL
                ON (
                            COMP_CD         = '016'
                       AND  BRAND_CD        = ERP_21_REC.BRAND_CD
                       AND  STOR_CD         = ERP_21_REC.STOR_CD
                       AND  ACCT_NO         = ERP_21_REC.VIRTUAL_ACCT
                   )
                WHEN MATCHED THEN
                    UPDATE
                       SET  BANK_CD         = ERP_21_REC.BANK_CODE
                         ,  ACCT_NM         = ERP_21_REC.RECEIPT_WHO
                         ,  REMARKS         = ERP_21_REC.DC_RMK
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'ERP'
                    WHEN NOT MATCHED THEN
                        INSERT
                        (
                                COMP_CD
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  ACCT_NO
                             ,  BANK_CD
                             ,  ACCT_NM
                             ,  REMARKS
                             ,  INST_DT
                             ,  INST_USER
                             ,  UPD_DT
                             ,  UPD_USER
                        ) VALUES (
                                '016'
                             ,  ERP_21_REC.BRAND_CD
                             ,  ERP_21_REC.STOR_CD
                             ,  ERP_21_REC.VIRTUAL_ACCT
                             ,  ERP_21_REC.BANK_CODE
                             ,  ERP_21_REC.RECEIPT_WHO
                             ,  ERP_21_REC.DC_RMK
                             ,  SYSDATE
                             ,  'ERP'
                             ,  SYSDATE
                             ,  'ERP'
                        )
                ;

                UPDATE  ERP_V_Z_HLY_BANKACCT_TRADE
                   SET  PROC_YN     = 'Y'
                     ,  ERR_MSG     = ''
                 WHERE  ROWID       = ERP_21_REC.ROWID;

                COMMIT;

                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        LS_ERR_MSG := SQLERRM;
                        UPDATE  ERP_V_Z_HLY_BANKACCT_TRADE
                           SET  ERR_MSG     = LS_ERR_MSG
                         WHERE  ROWID       = ERP_21_REC.ROWID;
                        COMMIT;
            END;
        END LOOP;

        COMMIT;

    END SP_ERP_IF_21_HOLLYS;

END PKG_ERP_IF;

/
