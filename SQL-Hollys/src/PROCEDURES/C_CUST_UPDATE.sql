--------------------------------------------------------
--  DDL for Procedure C_CUST_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_UPDATE" (
    P_COMP_CD       IN  VARCHAR2,
    P_CUST_ID       IN  VARCHAR2,
    P_BRAND_CD      IN  VARCHAR2,
    P_CUST_STAT     IN  VARCHAR2,
    P_SEX_DIV       IN  VARCHAR2,
    N_CUST_NM       IN  VARCHAR2,
    P_LVL_CD        IN  VARCHAR2,
    P_BIRTH_DT      IN  VARCHAR2,
    P_LUNAR_DIV     IN  VARCHAR2,
    P_SMS_RCV_YN    IN  VARCHAR2,
    P_PUSH_RCV_YN   IN  VARCHAR2,
    P_MOBILE        IN  VARCHAR2, 
    P_EMAIL_RCV_YN  IN  VARCHAR2,
    N_EMAIL         IN  VARCHAR2,
    P_CASH_BILL_DIV IN  VARCHAR2, 
    N_ISSUE_MOBILE  IN  VARCHAR2,
    N_ISSUE_BUSI_NO IN  VARCHAR2,
    P_ADDR_DIV      IN  VARCHAR2,
    N_ZIP_CD        IN  VARCHAR2,
    N_ADDR1         IN  VARCHAR2,
    N_ADDR2         IN  VARCHAR2,
    N_REMARKS       IN  VARCHAR2,
    P_MLG_DIV       IN  VARCHAR2,
    N_LEAVE_DT      IN  VARCHAR2,
    N_NEGATIVE_USER_YN  IN  VARCHAR2,
    P_USE_YN        IN  VARCHAR2,
    P_MY_USER_ID      IN  VARCHAR2,
    O_PR_RTN_CD     OUT VARCHAR2,
    O_PR_RTN_MSG    OUT VARCHAR2
)IS
    ERR_HANDLER     EXCEPTION;
    
    v_dup_cnt       number;
    v_refund_cnt    number;
    v_cash          number;
    v_lvl           VARCHAR(10);
    v_negative      CHAR(1);
    v_di            CHAR(64);
    
    ls_err_cd       VARCHAR2(7) := '0' ;
    ls_err_msg      VARCHAR2(500) ;
BEGIN
     -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [회원 수정] 탭 정보 수정
    -- Test          :   C_CUST_UPDATE ()
    -- ==========================================================================================
    
    -- 등급변경이 있으면 등급변경일자 설정
    SELECT
      LVL_CD, NEGATIVE_USER_YN, DI_STR INTO v_lvl, v_negative, v_di
    FROM C_CUST
    WHERE CUST_ID = P_CUST_ID;
    
    -- 등급변경일자 갱신
    IF v_lvl <> P_LVL_CD THEN
      UPDATE C_CUST SET
        LVL_CHG_DT = SYSDATE
        ,DEGRADE_YN = 'Y'
      WHERE CUST_ID = P_CUST_ID;
    END IF;
    
    -- 부정회원 설정 시 해당 DI로 설정된 모든 대상들의 DI항목을 비워준다
    IF v_negative <> N_NEGATIVE_USER_YN AND N_NEGATIVE_USER_YN = 'Y' THEN
      FOR C_CUR IN (
                      SELECT CUST_ID
                      FROM C_CUST
                      WHERE CUST_ID <> P_CUST_ID
                        AND DI_STR = v_di
                  )
      LOOP
        UPDATE C_CUST SET
          DI_STR = ''
        WHERE CUST_ID = C_CUR.CUST_ID;
      END LOOP;
    END IF;
    /*
    UPDATE C_CUST SET 
       CUST_STAT    = P_CUST_STAT
       , SEX_DIV      = P_SEX_DIV
       , CUST_NM      = encrypt(N_CUST_NM)
       , LVL_CD       = P_LVL_CD
       , BIRTH_DT     = NVL(P_BIRTH_DT, '99999999')
       , LUNAR_DIV    = P_LUNAR_DIV
       , SMS_RCV_YN   = P_SMS_RCV_YN
       , PUSH_RCV_YN  = P_PUSH_RCV_YN
       , MOBILE       = encrypt(REPLACE(P_MOBILE,'-'))
       , MOBILE_N3    = SUBSTR(REPLACE(P_MOBILE,'-'),8,4)
       , EMAIL_RCV_YN = P_EMAIL_RCV_YN
       , EMAIL        = N_EMAIL
       , CASH_BILL_DIV= P_CASH_BILL_DIV
       , ISSUE_MOBILE = encrypt(REPLACE(N_ISSUE_MOBILE,'-'))
       , ISSUE_BUSI_NO= REPLACE(N_ISSUE_BUSI_NO,'-')
       , ADDR_DIV     = P_ADDR_DIV
       , ZIP_CD       = REPLACE(N_ZIP_CD,'-')
       , ADDR1        = N_ADDR1
       , ADDR2        = N_ADDR2
       , REMARKS      = N_REMARKS
       , LEAVE_DT     = CASE WHEN P_CUST_STAT = '9' THEN TO_CHAR(SYSDATE, 'YYYYMMDD') 
                             ELSE ''
                        END
       , MLG_DIV      = P_MLG_DIV
       , USE_YN       = P_USE_YN
       , NEGATIVE_USER_YN = N_NEGATIVE_USER_YN
       , UPD_DT       = SYSDATE
       , UPD_USER     = P_MY_USER_ID
     WHERE COMP_CD        = P_COMP_CD
       AND BRAND_CD       = P_BRAND_CD
       AND CUST_ID        = P_CUST_ID;
       */
       UPDATE C_CUST
    SET    CUST_STAT        = P_CUST_STAT
         , SEX_DIV          = DECODE(P_CUST_STAT,'9',''                          ,P_SEX_DIV                           )
         , CUST_NM          = DECODE(P_CUST_STAT,'9',''                          ,ENCRYPT(N_CUST_NM)                  )
         , LVL_CD           = DECODE(P_CUST_STAT,'9',LVL_CD                      ,P_LVL_CD                            )
         , BIRTH_DT         = DECODE(P_CUST_STAT,'9','99999999'                  ,NVL(P_BIRTH_DT, '99999999')         )
         , LUNAR_DIV        = DECODE(P_CUST_STAT,'9','S'                         ,P_LUNAR_DIV                         )
         , SMS_RCV_YN       = DECODE(P_CUST_STAT,'9','N'                         ,P_SMS_RCV_YN                        )
         , PUSH_RCV_YN      = DECODE(P_CUST_STAT,'9','N'                         ,P_PUSH_RCV_YN                       )
         , MOBILE           = DECODE(P_CUST_STAT,'9',''                          ,ENCRYPT(REPLACE(P_MOBILE,'-'))      )
         , MOBILE_N3        = DECODE(P_CUST_STAT,'9',''                          ,SUBSTR(REPLACE(P_MOBILE,'-'),8,4)   )
         , EMAIL_RCV_YN     = DECODE(P_CUST_STAT,'9','N'                         ,P_EMAIL_RCV_YN                      )
         , EMAIL            = DECODE(P_CUST_STAT,'9',''                          ,N_EMAIL                             )
         , CASH_BILL_DIV    = DECODE(P_CUST_STAT,'9',''                          ,P_CASH_BILL_DIV                     )
         , ISSUE_MOBILE     = DECODE(P_CUST_STAT,'9',''                          ,ENCRYPT(REPLACE(N_ISSUE_MOBILE,'-')))
         , ISSUE_BUSI_NO    = DECODE(P_CUST_STAT,'9',''                          ,REPLACE(N_ISSUE_BUSI_NO,'-')        )
         , ADDR_DIV         = DECODE(P_CUST_STAT,'9',''                          ,P_ADDR_DIV                          )
         , ZIP_CD           = DECODE(P_CUST_STAT,'9',''                          ,REPLACE(N_ZIP_CD,'-')               )
         , ADDR1            = DECODE(P_CUST_STAT,'9',''                          ,N_ADDR1                             )
         , ADDR2            = DECODE(P_CUST_STAT,'9',''                          ,N_ADDR2                             )
         , REMARKS          = DECODE(P_CUST_STAT,'9',''                          ,N_REMARKS                           )
         , LEAVE_DT         = DECODE(P_CUST_STAT,'9',TO_CHAR(SYSDATE, 'YYYYMMDD'),''                                  )
         , MLG_DIV          = DECODE(P_CUST_STAT,'9','N'                         ,P_MLG_DIV                           )
         , USE_YN           = DECODE(P_CUST_STAT,'9','Y'                         ,P_USE_YN                            )
         , NEGATIVE_USER_YN = DECODE(P_CUST_STAT,'9','N'                         ,N_NEGATIVE_USER_YN                  )
         , UPD_DT           = SYSDATE
         , UPD_USER         = P_MY_USER_ID
    WHERE  COMP_CD          = P_COMP_CD
    AND    BRAND_CD         = P_BRAND_CD
    AND    CUST_ID          = P_CUST_ID
    ;
   
   IF P_CUST_STAT = '9' THEN 
   
      UPDATE C_CARD
      SET    CARD_STAT = '99'
           , DISUSE_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
           , REMARKS   = '회원탈퇴로 인한 폐기처리'
           , USE_YN    = 'N'
      WHERE  COMP_CD   = '016'
      AND    CUST_ID   = P_CUST_ID
      AND    CARD_STAT IN ('00','10')
      ;
     
      --유효 왕관 소멸...
      UPDATE C_CUST_CROWN
      SET    LOS_MLG_DT  = TO_CHAR(SYSDATE-1, 'YYYYMMDD')
           , NOTES       = '회원탈퇴로 인한 소멸일자 조정'
      WHERE  COMP_CD     = '016'
      AND    CUST_ID     = P_CUST_ID
      AND    SAV_USE_DIV = '201'
      ;
      
      UPDATE C_CARD_SAV_USE_HIS
      SET    USE_YN      = 'N'
           , LOS_MLG_YN  = 'Y'
           , LOS_MLG_DT  = TO_CHAR(SYSDATE-1, 'YYYYMMDD')
      WHERE  COMP_CD     = '016'
      AND    CARD_ID    IN (SELECT CARD_ID FROM C_CARD WHERE CUST_ID = P_CUST_ID)
      AND    SAV_USE_DIV = '201'
      ;
      
      --유효 포인트 소멸...
      UPDATE C_CARD_SAV_USE_PT_HIS
      SET    USE_YN      = 'N'
           , LOS_PT_YN   = 'Y'
           , LOS_PT_DT   = TO_CHAR(SYSDATE-1, 'YYYYMMDD')         
      WHERE  COMP_CD     = '016'
      AND    CARD_ID    IN (SELECT CARD_ID FROM C_CARD WHERE CUST_ID = P_CUST_ID)
      ;
  END IF;
    O_PR_RTN_CD  := '0';
    O_PR_RTN_MSG := FC_GET_WORDPACK_MSG('', 'KOR', '1001000416');
    
    commit;
     
EXCEPTION
    WHEN ERR_HANDLER THEN
        O_PR_RTN_CD  := SQLCODE;
        O_PR_RTN_MSG := SQLERRM ;
    WHEN OTHERS THEN
        O_PR_RTN_CD  := '999999' ;
        O_PR_RTN_MSG := SQLERRM ;
END C_CUST_UPDATE;

/
