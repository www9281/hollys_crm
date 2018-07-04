--------------------------------------------------------
--  DDL for Procedure API_C_CUST_STATS_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_STATS_UPDATE" (
      P_COMP_CD       IN  VARCHAR2,
      P_BRAND_CD      IN  VARCHAR2,
      P_USER_ID       IN  VARCHAR2,
      N_CUST_ID       IN  VARCHAR2,
      P_CUST_STAT     IN  VARCHAR2,
      N_LEAVE_RMK     IN  VARCHAR2,
      N_DI_STR        IN  VARCHAR2,
      O_RTN_CD        OUT VARCHAR2
) IS
      v_result_cd VARCHAR2(7) := '1';
      STR_ERROR1 VARCHAR2(50) ;
      STR_ERROR2 VARCHAR2(3000) ;
      
      v_cust_cnt NUMBER;
      REQ_EXCEPTION EXCEPTION;
BEGIN  
      -- ==========================================================================================
      -- Author        :   박동수
      -- Create date   :   2017-11-15
      -- API REQUEST   :   HLS_CRM_IF_0004
      -- Description   :   회원 정지, 사용, 탈퇴, 휴면해제, 잠김해제
      -- ==========================================================================================
      BEGIN 
        -- 고객번호 필수체크
        IF N_CUST_ID IS NULL THEN
            RAISE REQ_EXCEPTION;
        END IF; 
           
        -- 회원상태변경 [1:대기, 2:정상, 3:중지(미사용), 8:휴면(미사용), 9:탈퇴]
        IF P_CUST_STAT IN ('1', '2', '3') THEN
            UPDATE C_CUST 
            SET
                   CUST_STAT = P_CUST_STAT
                 , UPD_DT    = SYSDATE
                 , UPD_USER  = P_USER_ID
            WHERE  COMP_CD   = P_COMP_CD
            AND    BRAND_CD  = P_BRAND_CD
            AND    CUST_ID   = N_CUST_ID
            ;
          
          IF SQL%ROWCOUNT < 1 THEN
            Dbms_Output.Put_Line('수정하려는 대상을 찾을 수 없습니다.');
            v_result_cd := '170';
          END IF;
        END IF;
        
        -- 탈퇴의 경우 회원 정보 삭제
        IF P_CUST_STAT = '9' THEN   
        
            UPDATE C_CUST
            SET    CUST_STAT        = '9'
                 , SEX_DIV          = ''                          
                 , CUST_NM          = ''                          
                 , LVL_CD           = LVL_CD                      
                 , BIRTH_DT         = '99999999'                  
                 , LUNAR_DIV        = 'S'                         
                 , SMS_RCV_YN       = 'N'                         
                 , PUSH_RCV_YN      = 'N'                         
                 , MOBILE           = ''                          
                 , MOBILE_N3        = ''                          
                 , EMAIL_RCV_YN     = 'N'                         
                 , EMAIL            = ''                          
                 , CASH_BILL_DIV    = ''                          
                 , ISSUE_MOBILE     = ''                          
                 , ISSUE_BUSI_NO    = ''                          
                 , ADDR_DIV         = ''                          
                 , ZIP_CD           = ''                          
                 , ADDR1            = ''                          
                 , ADDR2            = ''                          
                 , REMARKS          = ''                          
                 , LEAVE_DT         = TO_CHAR(SYSDATE, 'YYYYMMDD')
                 , MLG_DIV          = 'N'                         
                 , USE_YN           = 'Y'                         
                 , NEGATIVE_USER_YN = 'N'                         
                 , UPD_DT           = SYSDATE
                 , UPD_USER         = P_USER_ID
            WHERE  COMP_CD          = P_COMP_CD
            AND    BRAND_CD         = P_BRAND_CD
            AND    CUST_ID          = N_CUST_ID
            ;
        
        
           
            --
            UPDATE C_CARD
            SET    CARD_STAT = '99'
                 , DISUSE_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
                 , REMARKS   = '회원탈퇴로 인한 폐기처리'
                 , USE_YN    = 'N'
            WHERE  COMP_CD   = '016'
            AND    CUST_ID   = N_CUST_ID
            AND    CARD_STAT IN ('00','10')
            ;
           
            --유효 왕관 소멸...
            UPDATE C_CUST_CROWN
            SET    LOS_MLG_DT  = TO_CHAR(SYSDATE-1, 'YYYYMMDD')
                 , NOTES       = '회원탈퇴로 인한 소멸일자 조정'
            WHERE  COMP_CD     = '016'
            AND    CUST_ID     = N_CUST_ID
            AND    SAV_USE_DIV = '201'
            ;
            
            UPDATE C_CARD_SAV_USE_HIS
            SET    USE_YN      = 'N'
                 , LOS_MLG_YN  = 'Y'
                 , LOS_MLG_DT  = TO_CHAR(SYSDATE-1, 'YYYYMMDD')
            WHERE  COMP_CD     = '016'
            AND    CARD_ID    IN (SELECT CARD_ID FROM C_CARD WHERE CUST_ID = N_CUST_ID)
            AND    SAV_USE_DIV = '201'
            ;
            
            --유효 포인트 소멸...
            UPDATE C_CARD_SAV_USE_PT_HIS
            SET    USE_YN      = 'N'
                 , LOS_PT_YN   = 'Y'
                 , LOS_PT_DT   = TO_CHAR(SYSDATE-1, 'YYYYMMDD')         
            WHERE  COMP_CD     = '016'
            AND    CARD_ID    IN (SELECT CARD_ID FROM C_CARD WHERE CUST_ID = N_CUST_ID)
            ;
          
        END IF;
        
        -- 휴면회원 해제 처리
        IF P_CUST_STAT = '10' THEN
          -- 휴면회원인지 체크
          SELECT COUNT(*) INTO v_cust_cnt
          FROM C_CUST_REST
          WHERE COMP_CD = P_COMP_CD
            AND BRAND_CD = P_BRAND_CD
            AND CUST_ID = N_CUST_ID;
           
          IF v_cust_cnt > 0 THEN
            -- 휴면회원테이블에서 회원테이블로 정보 이동
            INSERT INTO C_CUST
            SELECT * FROM C_CUST_REST
            WHERE COMP_CD = P_COMP_CD
              AND BRAND_CD = P_BRAND_CD
              AND CUST_ID = N_CUST_ID;
              
            -- 기존 휴면테이블에있는정보 제거
            DELETE FROM C_CUST_REST
            WHERE COMP_CD = P_COMP_CD
              AND BRAND_CD = P_BRAND_CD
              AND CUST_ID = N_CUST_ID;
          ELSE
            v_result_cd := '360'; -- 휴면회원이 아닙니다
          END IF;
        END IF;
        
      EXCEPTION
        WHEN REQ_EXCEPTION THEN
          v_result_cd  := '170';
      END;
      
      -- 잠김회원 해제 처리
      IF P_CUST_STAT = '11' THEN
        BEGIN
          -- 잠김회원해제의 경우 DI값으로 처리
          IF N_DI_STR IS NULL THEN
            RAISE REQ_EXCEPTION;
          END IF;
          
          -- 패스워드 불일치 횟수 초기화
          DELETE FROM C_CUST_LOGIN_FAIL A
          WHERE A.CUST_ID IN (SELECT CUST_ID FROM C_CUST WHERE CUST_ID = A.CUST_ID AND DI_STR = N_DI_STR);
          
        EXCEPTION
          WHEN REQ_EXCEPTION THEN
              v_result_cd  := '170';
        END;
      END IF;
      
      O_RTN_CD := v_result_cd;
EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '110';
        
        STR_ERROR1  := SQLCODE;
        STR_ERROR2 := SQLERRM;
        
        INSERT INTO XX_SP_LOG (MSG, SP_NM, INST_DT) VALUES( STR_ERROR1 ||STR_ERROR2 ,'API_C_CUST_STATS_UPDATE',SYSDATE)        ;
        
        --dbms_output.put_line(SQLERRM) ;
END API_C_CUST_STATS_UPDATE;

/
