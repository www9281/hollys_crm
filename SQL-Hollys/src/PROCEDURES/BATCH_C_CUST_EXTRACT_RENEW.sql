--------------------------------------------------------
--  DDL for Procedure BATCH_C_CUST_EXTRACT_RENEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_C_CUST_EXTRACT_RENEW" (
      O_CURSOR        OUT SYS_REFCURSOR
) IS
BEGIN 
      -- ==========================================================================================
      -- Author        :   박동수
      -- Create date   :   2017-11-15
      -- Description   :   휴면계정 추출 배치(매일 00시)
      -- ==========================================================================================
      -- 1. 휴면예정자(11개월), 계정삭제대상자(71개월) 대상자 메일 전송을 위해 추출

      OPEN O_CURSOR FOR 
          SELECT 
                 CUST.*
               , '11' AS MONTH_TERM
               , TO_CHAR(CUST.LAST_LOGIN_DT, 'YYYY-MM-DD')                 AS LAST_LOGIN
               , TO_CHAR(ADD_MONTHS(CUST.LAST_LOGIN_DT, 12), 'YYYY-MM-DD') AS LIMIT_DATE 
            FROM C_CUST CUST
           WHERE TO_CHAR(LAST_LOGIN_DT, 'YYYYMMDD') = TO_CHAR(ADD_MONTHS(SYSDATE, -11), 'YYYYMMDD')
             AND  CASH_USE_DT  < TO_CHAR(ADD_MONTHS(SYSDATE, -11), 'YYYYMMDD')
             AND  CUST_STAT != '9' 
          UNION ALL 
          SELECT 
                 CUST.*
               , '59' AS MONTH_TERM
               , TO_CHAR(CUST.LAST_LOGIN_DT, 'YYYY-MM-DD')                 AS LAST_LOGIN
               , TO_CHAR(ADD_MONTHS(CUST.LAST_LOGIN_DT, 60), 'YYYY-MM-DD') AS LIMIT_DATE 
            FROM C_CUST_REST CUST
           WHERE TO_CHAR(LAST_LOGIN_DT, 'YYYYMMDD') = TO_CHAR(ADD_MONTHS(SYSDATE, -71), 'YYYYMMDD')
             AND CASH_USE_DT  < TO_CHAR(ADD_MONTHS(SYSDATE, -71), 'YYYYMMDD')
             AND CUST_STAT != '9'; 

      /*       
      -- 2. 12개월이 지난 대상자는 C_CUST에 있는 정보를 C_CUST_REST로 이관
      INSERT INTO C_CUST_REST
      SELECT * 
      FROM   C_CUST
      WHERE  TO_CHAR(LAST_LOGIN_DT, 'YYYYMMDD') < TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMMDD')
      AND    CASH_USE_DT  < TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMMDD')
      AND    CUST_STAT IN ('1','2','3')
      ;
      
      DELETE 
      FROM   C_CUST
      WHERE  TO_CHAR(LAST_LOGIN_DT, 'YYYYMMDD') < TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMMDD')
      AND    CASH_USE_DT  < TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMMDD')
      AND    CUST_STAT IN ('1','2','3')
      ;
      
      -- 3. 휴면전화후 60개월이 지난 대상자는 회원 정보 삭제
      DELETE FROM C_CUST_REST
      WHERE TO_CHAR(LAST_LOGIN_DT, 'YYYYMMDD') < TO_CHAR(ADD_MONTHS(SYSDATE, -72), 'YYYYMMDD')
      AND  CASH_USE_DT  < TO_CHAR(ADD_MONTHS(SYSDATE, -72), 'YYYYMMDD')
      ;
      
      -- 4. 탈퇴이후 1개월이 지난 대상자 정보 삭제
      -- DELETE 
      -- FROM   C_CUST
      -- WHERE  LEAVE_DT < TO_CHAR(SYSDATE-30, 'YYYYMMDD')
      -- AND    LEAVE_DT IS NOT NULL;
       
     -- 20180425 수정 김수련과장 요청 반영
     UPDATE C_CUST
     SET    CUST_WEB_ID = NULL
          , CUST_NM = ENCRYPT('탈퇴회원')
          , USE_YN = 'N'
          , DI_STR = NULL
          , UPD_DT = SYSDATE
          , UPD_USER = 'BATCH'
     WHERE  LEAVE_DT < TO_CHAR(SYSDATE-30, 'YYYYMMDD')
     AND    LEAVE_DT IS NOT NULL
     AND    CUST_STAT = '9'
     ;
        */
END BATCH_C_CUST_EXTRACT_RENEW;

/
