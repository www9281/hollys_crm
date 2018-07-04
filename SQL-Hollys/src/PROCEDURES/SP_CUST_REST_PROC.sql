--------------------------------------------------------
--  DDL for Procedure SP_CUST_REST_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CUST_REST_PROC" /* 회원 휴면 처리 */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_PLAN_DT     IN  VARCHAR2 ,                -- 처리일자
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_CUST_REST_PROC      회원 휴면 처리
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-06-17         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_CUST_REST_PROC
      SYSDATE:         2015-06-17 
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ERR_HANDLER     EXCEPTION;

    CURSOR CUR_1 IS
        SELECT  CST.COMP_CD
             ,  CST.CUST_ID
             ,  CST.CUST_NM
             ,  CST.CUST_PW
             ,  CST.PW_DIV
             ,  CST.SEX_DIV
             ,  CST.LUNAR_DIV
             ,  CST.BIRTH_DT
             ,  CST.MOBILE
             ,  CST.MOBILE_N3
             ,  CST.M_PIN_NO
             ,  CST.PUSH_RCV_YN
             ,  CST.SMS_RCV_YN
             ,  CST.EMAIL
             ,  CST.EMAIL_RCV_YN
             ,  CST.ADDR_DIV
             ,  CST.ZIP_CD
             ,  CST.ADDR1
             ,  CST.ADDR2
             ,  CST.LVL_CD
             ,  CST.LVL_START_DT
             ,  CST.LVL_CLOSE_DT
             ,  CST.SAV_MLG
             ,  CST.LOS_MLG
             ,  CST.MLG_DIV
             ,  CST.MLG_SAV_DT
             ,  CST.SAV_PT
             ,  CST.USE_PT
             ,  CST.LOS_PT
             ,  CST.SAV_CASH
             ,  CST.USE_CASH
             ,  CST.CASH_USE_DT
             ,  CST.CUST_STAT
             ,  CST.REMARKS
             ,  CST.JOIN_DT
             ,  CST.LEAVE_DT
             ,  CST.LEAVE_RMK
             ,  CST.CUST_DIV
             ,  CST.BRAND_CD
             ,  CST.STOR_CD
             ,  CST.USE_YN
             ,  CST.DEVICE_TOKEN
             ,  CST.OSKIND
             ,  CST.MOBILE_KIND
             ,  CST.IPIN
             ,  CST.CASH_BILL_DIV
             ,  CST.ISSUE_MOBILE
             ,  CST.ISSUE_BUSI_NO
             ,  CST.RCMD_CUST_ID
             ,  CST.RCMD_DT
             ,  CST.INST_DT
             ,  CST.INST_USER
             ,  CST.UPD_DT
             ,  CST.UPD_USER
             ,  CST.LAST_LOGIN_DT
             ,  PLN.PLAN_DT
             ,  PLN.PRC_DIV
        FROM    C_CUST_PLAN PLN
             ,  C_CUST      CST
        WHERE   PLN.COMP_CD  = CST.COMP_CD
        AND     PLN.CUST_ID  = CST.CUST_ID
        AND     PLN.COMP_CD  = PSV_COMP_CD
        AND     PLN.PLAN_DT <= NVL(PSV_PLAN_DT, TO_CHAR(SYSDATE, 'YYYYMMDD'))
        AND     PLN.PRC_YN   = 'N'
        AND     PLN.PRC_DIV IN ('8','9'); -- 휴명예정, 탈퇴고객

    nRECCNT         NUMBER  (6  ) := 0;   

    ls_err_cd       VARCHAR2(7  ) := '0' ;
    ls_err_msg      VARCHAR2(500) ;

BEGIN
    FOR MYREC IN CUR_1 LOOP
        IF MYREC.PRC_DIV = '8' THEN
            SELECT  COUNT(*) INTO nRECCNT
            FROM    C_CUST      CST
            WHERE   CST.COMP_CD  = MYREC.COMP_CD
            AND     CST.CUST_ID  = MYREC.CUST_ID
            AND     CST.CUST_STAT= '2'
            AND     CST.JOIN_DT  < TO_CHAR(SYSDATE - 365, 'YYYYMMDD')
            AND     CST.SAV_CASH = CST.USE_CASH
            AND    (CST.LAST_LOGIN_DT IS NULL OR CST.LAST_LOGIN_DT <= SYSDATE - 365)
            AND     NOT EXISTS (                 -- 충전이력이 1년 미만
                                SELECT  1
                                FROM    C_CARD_CHARGE_HIS HIS
                                      , C_CARD            CRD
                                WHERE   CRD.COMP_CD   = CST.COMP_CD
                                AND     CRD.CUST_ID   = CST.CUST_ID
                                AND     CRD.COMP_CD   = HIS.COMP_CD
                                AND     CRD.CARD_ID   = HIS.CARD_ID
                                AND     HIS.CRG_DT   >= TO_CHAR(SYSDATE - 365, 'YYYYMMDD')
                                AND     HIS.CRG_DT   <= TO_CHAR(SYSDATE      , 'YYYYMMDD')
                                AND     HIS.USE_YN    = 'Y'
                               )
            AND     NOT EXISTS (                 -- 마일리지적립이력이 1년 미만
                                SELECT  1
                                FROM    C_CARD_SAV_HIS    HIS
                                      , C_CARD            CRD
                                WHERE   CRD.COMP_CD   = CST.COMP_CD
                                AND     CRD.CUST_ID   = CST.CUST_ID
                                AND     CRD.COMP_CD   = HIS.COMP_CD
                                AND     CRD.CARD_ID   = HIS.CARD_ID
                                AND     HIS.USE_DT   >= TO_CHAR(SYSDATE - 365, 'YYYYMMDD')
                                AND     HIS.USE_DT   <= TO_CHAR(SYSDATE      , 'YYYYMMDD')
                                AND     HIS.USE_YN    = 'Y'
                               )
            AND     NOT EXISTS (                 -- 사용이력이 1년 미만
                                SELECT  1
                                FROM    C_CARD_USE_HIS    HIS
                                      , C_CARD            CRD
                                WHERE   CRD.COMP_CD   = CST.COMP_CD
                                AND     CRD.CUST_ID   = CST.CUST_ID
                                AND     CRD.COMP_CD   = HIS.COMP_CD
                                AND     CRD.CARD_ID   = HIS.CARD_ID
                                AND     HIS.USE_DT   >= TO_CHAR(SYSDATE - 365, 'YYYYMMDD')
                                AND     HIS.USE_DT   <= TO_CHAR(SYSDATE      , 'YYYYMMDD')
                                AND     HIS.USE_YN    = 'Y'
                               )
            AND     NOT EXISTS (                 -- 쿠폰사용이력이 1년 미만
                                SELECT  1
                                FROM    C_COUPON_CUST     CCC
                                WHERE   CCC.COMP_CD   = CST.COMP_CD
                                AND     CCC.CUST_ID   = CST.CUST_ID
                                AND     CCC.USE_DT   >= TO_CHAR(SYSDATE - 365, 'YYYYMMDD')
                                AND     CCC.USE_DT   <= TO_CHAR(SYSDATE      , 'YYYYMMDD')
                                AND     CCC.USE_STAT != '32'
                               );

            -- 사용/적립 이력이 있는경우 계획을 예외 처리하고 다음 레코드 처리                 
            IF nRECCNT = 0 THEN
                UPDATE  C_CUST_PLAN
                SET     PRC_YN   = 'X'
                WHERE   COMP_CD  = MYREC.COMP_CD
                AND     PLAN_DT  = MYREC.PLAN_DT
                AND     CUST_ID  = MYREC.CUST_ID
                AND     PRC_DIV  = MYREC.PRC_DIV;

                CONTINUE;
            END IF;
        END IF;

        -- 휴면 테이블 작성
        MERGE INTO C_CUST_REST RST
        USING DUAL
        ON (
                RST.COMP_CD = MYREC.COMP_CD
            AND RST.CUST_ID = MYREC.CUST_ID
           )
        WHEN MATCHED THEN
            UPDATE  
            SET     RST.CUST_NM       = MYREC.CUST_NM           
                 ,  RST.CUST_PW       = MYREC.CUST_PW      
                 ,  RST.PW_DIV        = MYREC.PW_DIV       
                 ,  RST.SEX_DIV       = MYREC.SEX_DIV      
                 ,  RST.LUNAR_DIV     = MYREC.LUNAR_DIV    
                 ,  RST.BIRTH_DT      = MYREC.BIRTH_DT     
                 ,  RST.MOBILE        = MYREC.MOBILE       
                 ,  RST.MOBILE_N3     = MYREC.MOBILE_N3    
                 ,  RST.M_PIN_NO      = MYREC.M_PIN_NO     
                 ,  RST.PUSH_RCV_YN   = MYREC.PUSH_RCV_YN  
                 ,  RST.SMS_RCV_YN    = MYREC.SMS_RCV_YN   
                 ,  RST.EMAIL         = MYREC.EMAIL        
                 ,  RST.EMAIL_RCV_YN  = MYREC.EMAIL_RCV_YN 
                 ,  RST.ADDR_DIV      = MYREC.ADDR_DIV     
                 ,  RST.ZIP_CD        = MYREC.ZIP_CD       
                 ,  RST.ADDR1         = MYREC.ADDR1        
                 ,  RST.ADDR2         = MYREC.ADDR2        
                 ,  RST.LVL_CD        = MYREC.LVL_CD       
                 ,  RST.LVL_START_DT  = MYREC.LVL_START_DT 
                 ,  RST.LVL_CLOSE_DT  = MYREC.LVL_CLOSE_DT 
                 ,  RST.SAV_MLG       = MYREC.SAV_MLG      
                 ,  RST.LOS_MLG       = MYREC.LOS_MLG      
                 ,  RST.MLG_DIV       = MYREC.MLG_DIV      
                 ,  RST.MLG_SAV_DT    = MYREC.MLG_SAV_DT   
                 ,  RST.SAV_PT        = MYREC.SAV_PT       
                 ,  RST.USE_PT        = MYREC.USE_PT       
                 ,  RST.LOS_PT        = MYREC.LOS_PT       
                 ,  RST.SAV_CASH      = MYREC.SAV_CASH     
                 ,  RST.USE_CASH      = MYREC.USE_CASH     
                 ,  RST.CASH_USE_DT   = MYREC.CASH_USE_DT  
                 ,  RST.CUST_STAT     = MYREC.PRC_DIV     -- 상태를 휴면계정으로 백업함
                 ,  RST.REMARKS       = MYREC.REMARKS      
                 ,  RST.JOIN_DT       = MYREC.JOIN_DT      
                 ,  RST.LEAVE_DT      = MYREC.LEAVE_DT     
                 ,  RST.LEAVE_RMK     = MYREC.LEAVE_RMK    
                 ,  RST.CUST_DIV      = MYREC.CUST_DIV     
                 ,  RST.BRAND_CD      = MYREC.BRAND_CD     
                 ,  RST.STOR_CD       = MYREC.STOR_CD      
                 ,  RST.USE_YN        = MYREC.USE_YN       
                 ,  RST.DEVICE_TOKEN  = MYREC.DEVICE_TOKEN 
                 ,  RST.OSKIND        = MYREC.OSKIND       
                 ,  RST.MOBILE_KIND   = MYREC.MOBILE_KIND  
                 ,  RST.IPIN          = MYREC.IPIN         
                 ,  RST.CASH_BILL_DIV = MYREC.CASH_BILL_DIV
                 ,  RST.ISSUE_MOBILE  = MYREC.ISSUE_MOBILE 
                 ,  RST.ISSUE_BUSI_NO = MYREC.ISSUE_BUSI_NO
                 ,  RST.RCMD_CUST_ID  = MYREC.RCMD_CUST_ID 
                 ,  RST.RCMD_DT       = MYREC.RCMD_DT      
                 ,  RST.INST_DT       = MYREC.INST_DT      
                 ,  RST.INST_USER     = MYREC.INST_USER    
                 ,  RST.UPD_DT        = MYREC.UPD_DT       
                 ,  RST.UPD_USER      = MYREC.UPD_USER     
                 ,  RST.LAST_LOGIN_DT = MYREC.LAST_LOGIN_DT
        WHEN NOT MATCHED THEN
            INSERT 
                   (
                    COMP_CD
                 ,  CUST_ID
                 ,  CUST_NM
                 ,  CUST_PW
                 ,  PW_DIV
                 ,  SEX_DIV
                 ,  LUNAR_DIV
                 ,  BIRTH_DT
                 ,  MOBILE
                 ,  MOBILE_N3
                 ,  M_PIN_NO
                 ,  PUSH_RCV_YN
                 ,  SMS_RCV_YN
                 ,  EMAIL
                 ,  EMAIL_RCV_YN
                 ,  ADDR_DIV
                 ,  ZIP_CD
                 ,  ADDR1
                 ,  ADDR2
                 ,  LVL_CD
                 ,  LVL_START_DT
                 ,  LVL_CLOSE_DT
                 ,  SAV_MLG
                 ,  LOS_MLG
                 ,  MLG_DIV
                 ,  MLG_SAV_DT
                 ,  SAV_PT
                 ,  USE_PT
                 ,  LOS_PT
                 ,  SAV_CASH
                 ,  USE_CASH
                 ,  CASH_USE_DT
                 ,  CUST_STAT
                 ,  REMARKS
                 ,  JOIN_DT
                 ,  LEAVE_DT
                 ,  LEAVE_RMK
                 ,  CUST_DIV
                 ,  BRAND_CD
                 ,  STOR_CD
                 ,  USE_YN
                 ,  DEVICE_TOKEN
                 ,  OSKIND
                 ,  MOBILE_KIND
                 ,  IPIN
                 ,  CASH_BILL_DIV
                 ,  ISSUE_MOBILE
                 ,  ISSUE_BUSI_NO
                 ,  RCMD_CUST_ID
                 ,  RCMD_DT
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
                 ,  LAST_LOGIN_DT
                   )
            VALUES
                   (
                    MYREC.COMP_CD
                 ,  MYREC.CUST_ID
                 ,  MYREC.CUST_NM
                 ,  MYREC.CUST_PW
                 ,  MYREC.PW_DIV
                 ,  MYREC.SEX_DIV
                 ,  MYREC.LUNAR_DIV
                 ,  MYREC.BIRTH_DT
                 ,  MYREC.MOBILE
                 ,  MYREC.MOBILE_N3
                 ,  MYREC.M_PIN_NO
                 ,  MYREC.PUSH_RCV_YN
                 ,  MYREC.SMS_RCV_YN
                 ,  MYREC.EMAIL
                 ,  MYREC.EMAIL_RCV_YN
                 ,  MYREC.ADDR_DIV
                 ,  MYREC.ZIP_CD
                 ,  MYREC.ADDR1
                 ,  MYREC.ADDR2
                 ,  MYREC.LVL_CD
                 ,  MYREC.LVL_START_DT
                 ,  MYREC.LVL_CLOSE_DT
                 ,  MYREC.SAV_MLG
                 ,  MYREC.LOS_MLG
                 ,  MYREC.MLG_DIV
                 ,  MYREC.MLG_SAV_DT
                 ,  MYREC.SAV_PT
                 ,  MYREC.USE_PT
                 ,  MYREC.LOS_PT
                 ,  MYREC.SAV_CASH
                 ,  MYREC.USE_CASH
                 ,  MYREC.CASH_USE_DT
                 ,  MYREC.PRC_DIV     -- 상태를 휴면계정으로 백업함
                 ,  MYREC.REMARKS
                 ,  MYREC.JOIN_DT
                 ,  MYREC.LEAVE_DT
                 ,  MYREC.LEAVE_RMK
                 ,  MYREC.CUST_DIV
                 ,  MYREC.BRAND_CD
                 ,  MYREC.STOR_CD
                 ,  MYREC.USE_YN
                 ,  MYREC.DEVICE_TOKEN
                 ,  MYREC.OSKIND
                 ,  MYREC.MOBILE_KIND
                 ,  MYREC.IPIN
                 ,  MYREC.CASH_BILL_DIV
                 ,  MYREC.ISSUE_MOBILE
                 ,  MYREC.ISSUE_BUSI_NO
                 ,  MYREC.RCMD_CUST_ID
                 ,  MYREC.RCMD_DT
                 ,  MYREC.INST_DT
                 ,  MYREC.INST_USER
                 ,  MYREC.UPD_DT
                 ,  MYREC.UPD_USER
                 ,  MYREC.LAST_LOGIN_DT
                   );

        -- C_CUST UPDATE               
        UPDATE  C_CUST
        SET     CUST_NM       = encrypt('***')        
             ,  CUST_PW       = GET_SHA1_STR('***')
             ,  SEX_DIV       = '*'
             ,  LUNAR_DIV     = '*'
             ,  BIRTH_DT      = '***'
             ,  MOBILE        = encrypt('***')
             ,  MOBILE_N3     = '***'
             ,  IPIN          = '***' 
             ,  EMAIL         = '***'
             ,  ZIP_CD        = '***'
             ,  ADDR1         = '***'  
             ,  ADDR2         = '***'
             ,  CASH_BILL_DIV = '*'
             ,  ISSUE_MOBILE  = encrypt('***') 
             ,  ISSUE_BUSI_NO = '***'
             ,  CUST_STAT     = MYREC.PRC_DIV
        WHERE   COMP_CD       = MYREC.COMP_CD
        AND     CUST_ID       = MYREC.CUST_ID;

        -- 계획테이블 UPDATE
        UPDATE  C_CUST_PLAN
        SET     PRC_YN = 'Y'
        WHERE   COMP_CD = MYREC.COMP_CD
        AND     PLAN_DT = MYREC.PLAN_DT
        AND     CUST_ID = MYREC.CUST_ID
        AND     PRC_DIV = MYREC.PRC_DIV;
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
